{
  This file is part of R&Q.
  Under same license
}
unit SpellCheck;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  System.SysUtils, System.Types, Winapi.Windows, Winapi.Messages, System.Classes, System.Character, System.Threading, System.StrUtils,
  Generics.Collections, Vcl.Graphics, Vcl.StdCtrls, Vcl.Menus, Vcl.Controls, Vcl.Forms, Winapi.ActiveX, System.Win.ComObj,
  MsSpellCheckLib_TLB;


type
  TMultiReadSingleWrite = class
  private
    FSRWLock: Pointer;
  public
    procedure BeginRead; inline;
    function TryBeginRead: Boolean; inline;
    procedure EndRead; inline;
    procedure BeginWrite; inline;
    function TryBeginWrite: Boolean; inline;
    procedure EndWrite; inline;
  end;



  TMemoEx = class(TMemo)
  private
    SuggestMenu: TPopupMenu;
  protected
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure UseSuggestion(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
   public
    class var
      spellLangs: TList<DWORD>;
      spellWrong: TList<TArray<Integer>>;
      spellGIT: IGlobalInterfaceTable;
      spellLock: TMultiReadSingleWrite;
      spellTask: ITask;
      spellText: String;

    class constructor Create;
    class destructor Destroy;
    class function GetSpellWrongCopy: TList<TArray<Integer>>;
    class procedure AssignSpellWrongCopy(var copy: TList<TArray<Integer>>);
    class procedure DoInitSpellCheck;
    class function ExecSpellCheck: Boolean;
    class procedure DoSpellCheck;
  end;

  TMenuItemEx = class(TMenuItem)
  public
    Data: record
      Suggestion: String;
      Position: Integer;
      Length: Integer;
    end;
  end;

  SRWLOCK = Pointer;

  procedure AcquireSRWLockExclusive(var SRWLock: SRWLOCK); stdcall; external 'kernel32.dll' delayed;
  function TryAcquireSRWLockExclusive(var SRWLock: SRWLOCK): BOOL; stdcall; external 'kernel32.dll' delayed;
  procedure ReleaseSRWLockExclusive(var SRWLock: SRWLOCK); stdcall; external 'kernel32.dll' delayed;
  procedure AcquireSRWLockShared(var SRWLock: SRWLOCK); stdcall; external 'kernel32.dll' delayed;
  function TryAcquireSRWLockShared(var SRWLock: SRWLOCK): BOOL; stdcall; external 'kernel32.dll' delayed;
  procedure ReleaseSRWLockShared(var SRWLock: SRWLOCK); stdcall; external 'kernel32.dll' delayed;

//  procedure DoInitSpellCheck;
//  procedure DoSpellCheck;
  procedure CreateThreading;
  procedure ReleaseThreading;
  procedure SetSpellText(const txt: String);
  function SpellTextChanged(const txt: String): Boolean;

implementation

uses
  RnQGlobal, RQUtil, RnQLangs, globalLib, chatDlg;

const
  CLSID_StdGlobalInterfaceTable: TGUID = '{00000323-0000-0000-C000-000000000046}';
  IID_IGlobalInterfaceTable: TGUID = '{00000146-0000-0000-C000-000000000046}';

procedure CreateThreading;
begin
  CoInitializeEx(nil, COINIT_MULTITHREADED);
  CoCreateInstance(CLSID_StdGlobalInterfaceTable, nil, CLSCTX_INPROC_SERVER, IID_IGlobalInterfaceTable, TMemoEx.spellGIT);
  TMemoEx.spellLock := TMultiReadSingleWrite.Create;
end;

procedure ReleaseThreading;
begin
  FreeAndNil(TMemoEx.spellLock);
  FreeAndNil(TMemoEx.spellLangs);
  FreeAndNil(TMemoEx.spellWrong);
  CoUninitialize;
end;

procedure SetSpellText(const txt: String);
var
  chr: Char;
  i, delim: Integer;
begin
  i := 0; delim := 0;
  // Skip unfinished word in the end
  for chr in ReverseString(txt) do
  begin
    Inc(i);
    if chr.IsSeparator or chr.IsPunctuation or chr.IsWhiteSpace then
    begin
      delim := i;
      Break;
    end;
  end;
  if delim > 0 then
    TMemoEx.spellText := Copy(txt, 1, Length(txt) - delim)
  else
    TMemoEx.spellText := '';
end;

function SpellTextChanged(const txt: String): Boolean;
begin
  Result := AnsiCompareStr(TMemoEx.spellText, txt) <> 0;
end;

class function TMemoEx.GetSpellWrongCopy: TList<TArray<Integer>>;
begin
  Result := TList<TArray<Integer>>.Create;
  spellLock.BeginRead;
  Result.AddRange(spellWrong);
  spellLock.EndRead;
end;

class procedure TMemoEx.AssignSpellWrongCopy(var copy: TList<TArray<Integer>>);
begin
  spellLock.BeginWrite;
  spellWrong.Clear;
  spellWrong.AddRange(copy);
  spellLock.EndWrite;
  copy.Free;
end;

class procedure TMemoEx.DoInitSpellCheck;
var
  iscf: ISpellCheckerFactory;
  isc: ISpellChecker;
  lang: String;
  supported: Integer;
  cookie: DWORD;
  spellLanguages2: TStringList;
begin
  if not EnableSpellCheck or not Assigned(spellGIT) then
    Exit;

  iscf := nil;

  if Assigned(spellLangs) then
    for cookie in spellLangs do
      spellGIT.RevokeInterfaceFromGlobal(cookie);

  FreeAndNil(spellLangs);
  FreeAndNil(spellWrong);
  spellLangs := TList<DWORD>.Create;
  spellWrong := TList<TArray<Integer>>.Create;

  if Succeeded(CoCreateInstance(CLASS_SpellCheckerFactory, nil, CLSCTX_INPROC_SERVER, IID_ISpellCheckerFactory, iscf)) and Assigned(iscf) then
  begin
    spellLanguages2 := TStringList.Create;
    MainPrefs.getPrefStrList('spellcheck-languages', spellLanguages2);
    for lang in spellLanguages2 do
    begin
      supported := 0;
      iscf.IsSupported(PChar(lang), supported);
      if not (supported = 0) then
      begin
        isc := nil;
        iscf.CreateSpellChecker(PChar(lang), isc);
        if Assigned(isc) then
        begin
          spellGIT.RegisterInterfaceInGlobal(isc, ISpellChecker, cookie);
          spellLangs.Add(cookie);
        end;
      end;
    end;
  end;
end;

//function ExecSpellCheck(ch: Pointer): Boolean;
class function TMemoEx.ExecSpellCheck: Boolean;
var
  spellWrongCopy: TList<TArray<Integer>>;
  checker: ISpellChecker;
  lngCnt: Integer;

  function getErrData(spellErr: ISpellingError): TArray<Integer>;
  var
    st, len: Cardinal;
  begin
    st := 0; len := 0;
    spellErr.Get_StartIndex(st);
    spellErr.Get_Length(len);
    SetLength(Result, 6);
    Result[0] := st;
    Result[1] := len;
  end;

  procedure FirstCheck(spellErrs: IEnumSpellingError);
  var
    spellErr: ISpellingError;
    action: CORRECTIVE_ACTION;
  begin
    if TTask.CurrentTask.Status = TTaskStatus.Canceled then
      Exit;

    if Assigned(spellErrs) then
    while spellErrs.Next(spellErr) = S_OK do
    if Assigned(spellErr) then
    begin
      action := CORRECTIVE_ACTION_NONE;
      spellErr.Get_CorrectiveAction(action);
      if action = CORRECTIVE_ACTION_GET_SUGGESTIONS then
        spellWrongCopy.Add(getErrData(spellErr));
    end;
  end;

  procedure SecondaryChecks(cookie: DWORD);
  var
    spellErrs: IEnumSpellingError;
    spellErr: ISpellingError;
    word: PChar;
//    lng: PChar;
    i: Integer;
  begin
    if TTask.CurrentTask.Status = TTaskStatus.Canceled then
      Exit;
    if Assigned(spellWrongCopy) and (spellWrongCopy.Count>0) then
     for i := spellWrongCopy.Count - 1 downto 0 do
      begin
        word := PChar(Copy(spellText, spellWrongCopy[i][0] + 1, spellWrongCopy[i][1]));
        spellErrs := nil;
        spellGIT.GetInterfaceFromGlobal(cookie, ISpellChecker, checker);
        checker.Check(word, spellErrs);
        if not Assigned(spellErrs) or not (spellErrs.Next(spellErr) = S_OK) then
          spellWrongCopy.Delete(i);
      end;
  end;

var
  spellErrs: IEnumSpellingError;
  cookie: DWORD;

//  Freq, StartCount, StopCount: Int64;
//  TimingSeconds: real;
begin
//QueryPerformanceFrequency(Freq);
//Freq := Freq div 1000;
//QueryPerformanceCounter(StartCount);
  Result := False;
  spellWrongCopy := TList<TArray<Integer>>.Create;
  lngCnt := 0;
  if Assigned(spellLangs) then
   for cookie in spellLangs do
    begin
      if lngCnt = 0 then
      begin
        spellErrs := nil;
        if Assigned(spellGIT) then
         begin
           spellGIT.GetInterfaceFromGlobal(cookie, ISpellChecker, checker);
           checker.Check(PChar(spellText), spellErrs);
           FirstCheck(spellErrs);
         end;
      end else
        SecondaryChecks(cookie);
      Inc(lngCnt);
    end;

  if TTask.CurrentTask.Status = TTaskStatus.Canceled then
    Exit;
  AssignSpellWrongCopy(spellWrongCopy);
  Result := True;
//QueryPerformanceCounter(StopCount);
//TimingSeconds := (StopCount - StartCount) / Freq;
//OutputDebugString(PChar(floattostr(TimingSeconds)));
end;

procedure RefreshInput;
begin
  TThread.Synchronize(nil, procedure
  begin
    if Assigned(chatFrm) then
      chatFrm.RefreshThisInput;
  end);
end;

class procedure TMemoEx.DoSpellCheck;
begin
  if not EnableSpellCheck then
  begin
    RefreshInput;
    Exit;
  end;

  if Assigned(spellTask) then
    spellTask.Cancel;

  spellTask := TTask.Create(procedure
  begin
    CoInitializeEx(nil, COINIT_MULTITHREADED);

    if TTask.CurrentTask.Status = TTaskStatus.Canceled then
      Exit;

    if ExecSpellCheck then
      RefreshInput;

    CoUninitialize;
  end);
  spellTask.Start;
end;

constructor TMemoEx.Create(AOwner: TComponent);
begin
  inherited;
  SuggestMenu := TPopupMenu.Create(Self);
end;

class constructor TMemoEx.Create;
begin
  spellLangs := nil;
  spellWrong := nil;
  spellGIT := nil;
  spellTask := nil;
  CreateThreading;
end;

class destructor TMemoEx.Destroy;
begin
  spellGIT := NIL;
  ReleaseThreading;
end;

destructor TMemoEx.Destroy;
begin
  FreeAndNil(SuggestMenu);

  if Assigned(spellTask) then
    spellTask.Cancel;

  inherited;
end;

procedure TMemoEx.WMPaint(var Message: TWMPaint);
var
  spellWrongCopy: TList<TArray<Integer>>;
  wrong: TArray<Integer>;
  DC: HDC;
  cnv: TCanvas;
  S, E: TPoint;
//  ending: String;
//  chr: Char;
  posST, posEN: LRESULT;
//  cnt,
  hgt, add: Integer;
  Òbrush: LOGBRUSH;
  Òuserstyle: array of DWORD;
  fheight: Integer;

//  Freq, StartCount, StopCount: Int64;
//  TimingSeconds: real;
begin
  inherited;

  if not EnableSpellCheck or not Assigned(spellWrong) or (spellWrong.Count = 0) then
    Exit;
//QueryPerformanceFrequency(Freq);
//Freq := Freq div 1000;
//QueryPerformanceCounter(StartCount);
  DC := GetDC(Self.Handle);

  cnv := TCanvas.Create;
  cnv.Lock;
  cnv.Handle := DC;

  Òbrush.lbStyle := BS_SOLID;
  Òbrush.lbColor := ColorToRGB(spellErrorColor);
  Òbrush.lbHatch := 0;

  SetLength(Òuserstyle, 2);
  Òuserstyle[0] := 1;
  Òuserstyle[1] := 1;
  hgt := 1; add := 0;
  case spellErrorStyle of
    0: begin Òuserstyle[0] := 1;  Òuserstyle[1] := 1; hgt := 1; add := 0; end;
    1: begin Òuserstyle[0] := 1;  Òuserstyle[1] := 1; hgt := 2; add := 1; end;
    2: begin Òuserstyle[0] := 2;  Òuserstyle[1] := 1; hgt := 1; add := 0; end;
    3: begin Òuserstyle[0] := 2;  Òuserstyle[1] := 2; hgt := 2; add := 1; end;
    4: begin Òuserstyle[0] := 1;  Òuserstyle[1] := 0; hgt := 1; add := 0; end;
    5: begin Òuserstyle[0] := 1;  Òuserstyle[1] := 0; hgt := 2; add := 1; end;
  end;

  cnv.Pen.Handle := ExtCreatePen(PS_GEOMETRIC or PS_USERSTYLE or PS_ENDCAP_FLAT, hgt, Òbrush, 2, Òuserstyle);
  spellWrongCopy := GetSpellWrongCopy;

  try
//    cnt := 0;
    if Assigned(spellWrongCopy) then
    for wrong in spellWrongCopy do
    try
      posST := Self.Perform(EM_POSFROMCHAR, wrong[0], 0);
      posEN := Self.Perform(EM_POSFROMCHAR, wrong[0] + wrong[1], 0);
      if (posST = -1) or (posEN = -1) then
        Continue;

//      fheight := Abs(muldiv(Self.Font.Height, 96, 72))
      fheight := cnv.TextHeight('Qq”Û') - 1;
      S.X := LoWord(posST);
      S.Y := HiWord(posST) + fheight + add;
      E.X := LoWord(posEN);
      E.Y := HiWord(posEN) + fheight + add;

      // Horizontal lines only
      if S.Y = E.Y then
      begin
        cnv.MoveTo(S.X, S.Y);
        cnv.LineTo(E.X, E.Y);
      end;
{
      // Sine underline
      S.X := LoWord(posST);
      S.Y := HiWord(posST);
      X := S.X;
      Y := S.Y;
      for X := LoWord(posST) to LoWord(posEN) do
      begin
        Y := HiWord(posST) + 20 + Round(Sin(Math.GradToDeg(PI / 4 * X - 1)));
        SetPixel(DC, X, Y, RGB(206, 86, 84));
        S.X := X;
        S.Y := Y;
      end;
}
//     Inc(cnt);
    except end;
  finally
    spellWrongCopy.Free;
    DeleteObject(cnv.Pen.Handle);
    cnv.Handle := 0;
    cnv.Unlock;
    cnv.Free;
  end;

  ReleaseDC(Self.Handle, DC);
//QueryPerformanceCounter(StopCount);
//TimingSeconds := (StopCount - StartCount) / Freq;
//OutputDebugString(PChar(floattostr(TimingSeconds)));
end;

procedure TMemoEx.UseSuggestion(Sender: TObject);
var
  txt: String;
  cpos: TPoint;
begin
  if Assigned(Sender) then
  begin
    txt := Self.Text;
    cpos := Self.CaretPos;
    Delete(txt, (Sender as TMenuItemEx).Data.Position + 1, (Sender as TMenuItemEx).Data.Length);
    Insert((Sender as TMenuItemEx).Data.Suggestion, txt, (Sender as TMenuItemEx).Data.Position + 1);
    Self.Text := txt;
    SetSpellText(txt);
    Self.SetCaretPos(cpos);
    chatFrm.SpellCheck;
  end;
end;

procedure TMemoEx.WMContextMenu(var Message: TWMContextMenu);
var
  spellWrongCopy: TList<TArray<Integer>>;
  wrong: TArray<Integer>;
  c: TPoint;
  pos: Integer;
  word, suggest: PChar;
  cookie: DWORD;
  spellSuggest: IEnumString;
  fetched: LongWord;
  mi, md: TMenuItemEx;
  msg: tagMSG;
  checker: ISpellChecker;

  procedure AddSuggestion(suggestion: PChar; pos, len: Integer);
  begin
    mi := TMenuItemEx.Create(SuggestMenu);
    SuggestMenu.Items.Add(mi);
    mi.Caption := suggestion;
    mi.Hint := suggestion;
    mi.OnClick := UseSuggestion;
    mi.Data.Suggestion := suggestion;
    mi.Data.Position := pos;
    mi.Data.Length := len;
  end;

begin
  if not (Message.Result = 0) then
    Exit;
  if csDesigning in ComponentState then
    Exit;
  if not (PopupMenu = nil) or not EnableSpellCheck or not Assigned(spellGIT) or (spellWrong.Count = 0) then
    inherited
  else
  begin
    // Convert CaretPos to char index
    c := Self.ScreenToClient(MousePos);
    pos := LoWord(Perform(EM_CHARFROMPOS, 0, MakeLParam(c.X, c.Y)));
    SuggestMenu.Items.Clear;

    spellWrongCopy := GetSpellWrongCopy;
    for wrong in spellWrongCopy do
    if (pos >= wrong[0]) and (pos <= wrong[0] + wrong[1]) then
    begin
      word := PChar(Copy(Self.Text, wrong[0] + 1, wrong[1]));
      for cookie in spellLangs do
      begin
        spellGIT.GetInterfaceFromGlobal(cookie, ISpellChecker, checker);
        checker.Suggest(word, spellSuggest);
        if Assigned(spellSuggest) then
        while spellSuggest.RemoteNext(1, suggest, fetched) = S_OK do
        AddSuggestion(suggest, wrong[0], wrong[1]);
      end;
    end;
    spellWrongCopy.Free;

    if SuggestMenu.Items.Count > 0 then
    begin
      md := TMenuItemEx.Create(SuggestMenu);
      SuggestMenu.Items.Add(md);
      md.MenuIndex := SuggestMenu.Items.Count - 1;
      md.Caption := GetTranslation('Default menu');

      mi := TMenuItemEx.Create(SuggestMenu);
      SuggestMenu.Items.Add(mi);
      mi.MenuIndex := SuggestMenu.Items.Count - 2;
      mi.Caption := '-';

      SuggestMenu.Popup(Message.Pos.X, Message.Pos.Y);
      if PeekMessage(Msg, PopupList.Window, WM_COMMAND, WM_COMMAND, PM_NOREMOVE) then
      if md.Command = LoWord(Msg.wParam) then
        inherited;
      Message.Result := 1;
    end;

    if Message.Result = 0 then
      inherited;
  end;
end;

procedure TMemoEx.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Refresh;
end;

procedure TMultiReadSingleWrite.BeginRead;
begin
  AcquireSRWLockShared(FSRWLock);
end;

function TMultiReadSingleWrite.TryBeginRead: Boolean;
begin
  Result := TryAcquireSRWLockShared(FSRWLock);
end;

procedure TMultiReadSingleWrite.EndRead;
begin
  ReleaseSRWLockShared(FSRWLock)
end;

procedure TMultiReadSingleWrite.BeginWrite;
begin
  AcquireSRWLockExclusive(FSRWLock);
end;

function TMultiReadSingleWrite.TryBeginWrite: Boolean;
begin
  Result := TryAcquireSRWLockExclusive(FSRWLock);
end;

procedure TMultiReadSingleWrite.EndWrite;
begin
  ReleaseSRWLockExclusive(FSRWLock)
end;

end.
