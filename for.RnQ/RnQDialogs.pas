{
  This file is part of R&Q.
  Under same license
}
unit RnQDialogs;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

{$DEFINE usesVCL}

interface
{$IFDEF usesVCL}
 uses
   Windows, Forms, StdCtrls, Graphics, Classes,
   {$IFNDEF FPC}
   Consts,
   {$ENDIF ~FPC}
   Math, ExtCtrls,
   System.UITypes, RDGlobal;
{$ELSE}
 uses Windows, Winapi.CommDlg;
{$ENDIF}

var
  IconIDs: array[TMsgDlgType] of PChar = (IDI_EXCLAMATION, IDI_HAND,
    IDI_ASTERISK, IDI_QUESTION, IDI_ASTERISK, nil);
  IconNames: array[TMsgDlgType] of TPicName = (PIC_EXCLAMATION, PIC_HAND,
    PIC_ASTERISK, PIC_QUEST, PIC_ASTERISK, '');
  MsgShowTime: array[TMsgDlgType] of integer = (60, 99, 30, 60, 15, 60);

{
const
  mbYesNo = [mbYes, mbNo];
  mbYesNoCancel = [mbYes, mbNo, mbCancel];
  mbYesAllNoAllCancel = [mbYes, mbYesToAll, mbNo, mbNoToAll, mbCancel];
  mbOKCancel = [mbOK, mbCancel];
  mbAbortRetryIgnore = [mbAbort, mbRetry, mbIgnore];
  mbAbortIgnore = [mbAbort, mbIgnore];
}

{$IFDEF usesVCL}
resourcestring
  SMsgDlgWarning = 'Warning';
  SMsgDlgError = 'Error';
  SMsgDlgInformation = 'Information';
  SMsgDlgConfirm = 'Confirm';
  SMsgDlgBuzz = 'Buzz';
  SMsgDlgYes = '&Yes';
  SMsgDlgNo = '&No';
  SMsgDlgOK = 'OK';
  SMsgDlgCancel = 'Cancel';
  SMsgDlgHelp = '&Help';
  SMsgDlgHelpNone = 'No help available';
  SMsgDlgHelpHelp = 'Help';
  SMsgDlgAbort = '&Abort';
  SMsgDlgRetry = '&Retry';
  SMsgDlgIgnore = '&Ignore';
  SMsgDlgAll = '&All';
  SMsgDlgNoToAll = 'N&o to All';
  SMsgDlgYesToAll = 'Yes to &All';
  SMsgDlgClose    = 'Close';
  SCannotOpenClipboard = 'Cannot open clipboard: %s';
  SMessage = 'Message';

 function InputQueryBig(const ACaption, APrompt: string;
   var Value: string): Boolean;
 function InputQuery(const ACaption, APrompt: string;
   var Value: string): Boolean;
 function MessageDlg(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint = 0): integer; Overload;
 function MessageDlg(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; pDefaultButton: TMsgDlgBtn;
  Seconds: integer): integer; Overload;

{$ENDIF}

 function OpenSaveFileDialog(ParentHandle: THandle;
   const DefExt, Filter, InitialDir, Title: UnicodeString;
   var FileNames: UnicodeString; IsOpenDialog: Boolean;
   Multi: Boolean = false; pFlags: Cardinal = 0): Boolean;


// function OpenDirDialogW(ParentHandle: THandle; Title : WideString; var DirName: WideString) : boolean;
 function OpenDirDialog(ParentHandle: THandle; Title: UnicodeString; var DirName: UnicodeString): boolean;
 function ChooseFontDlg(ParentHandle: THandle; Title: String; var Font: TFont): boolean;

{$IFDEF usesVCL}
var
  Captions: array [TMsgDlgType] of Pointer = (
    @SMsgDlgWarning,
    @SMsgDlgError,
    @SMsgDlgInformation,
    @SMsgDlgConfirm,
    @SMsgDlgBuzz,
    nil
  );
{$ENDIF usesVCL}



implementation
uses
  ShlObj,
    Messages, CommCtrl, ActiveX,
//   ShellAPI, ShlObj,
  {$IFDEF usesVCL}
   Controls, CommDlg,
 {$IFDEF RNQ}
   RnQLangs,
 {$ENDIF RNQ}
 {$IFDEF RNQ_VCL}
   RQThemes, RnQGlobal, RnQButtons,
 {$ELSE}
   NotRnQUtils,
 {$ENDIF RNQ_VCL}
   RDUtils,
 {$IFDEF RNQ_PLUGIN}
   RDPlugins,
 {$ENDIF RNQ_PLUGIN}
  {$ENDIF}
   SysUtils, StrUtils;

type
 {$IFDEF RNQ_VCL}
//      with TRnQSpeedButton.Create(Form) do
  TDialogButton = TRnQButton;
 {$ELSE ~RNQ}
  TDialogButton = TButton;
 {$ENDIF ~RNQ}

function CharReplace(const Source: string; oldChar, newChar: Char): string;
var
   i: Integer;
begin
   Result := Source;
   for i := 1 to Length(Result) do
     if Result[i] = oldChar then
       Result[i] := newChar
end;

function OpenSaveFileDialog(ParentHandle: THandle;
   const DefExt, Filter, InitialDir, Title: UnicodeString; var FileNames: UnicodeString;
   IsOpenDialog: Boolean; Multi: Boolean = false; pFlags: Cardinal = 0): Boolean;
const
   OPENFILENAME_SIZE_VERSION_400 = 76;
var
   ofn: TOpenFilenameW;
   szFile: array[0..32000] of WideChar;
   szDir: array[0..32000] of WideChar;
   fltr, vDir: UnicodeString;
   i, j: Integer;
//   vEnd : Boolean;
begin
   Result := False;
   FillChar(ofn, SizeOf(TOpenFileName), 0);
   with ofn do
   begin
     if Win32MajorVersion < 5 then
       lStructSize := OPENFILENAME_SIZE_VERSION_400
      else
       lStructSize := SizeOf(TOpenFileName);
     hwndOwner := ParentHandle;
     lpstrFile := szFile;
     nMaxFile := SizeOf(szFile);
     if (Title <> '') then
       lpstrTitle := PWideChar(Title);
     if (InitialDir <> '') then
       lpstrInitialDir := PWideChar(InitialDir);
     StrPCopy(lpstrFile, FileNames);
     fltr := CharReplace(Filter, '|', #0) + #0#0;
     lpstrFilter := PWideChar(fltr);
   if DefExt <> '' then
       lpstrDefExt := PWideChar(DefExt);
   end;
  try
   ofn.Flags := ofn.Flags or pFlags;
   if IsOpenDialog then
   begin
     i := -1;
     try
       i := GetCurrentDirectoryW(length(szDir), szDir);
       if Multi then
         ofn.Flags := ofn.Flags or OFN_ALLOWMULTISELECT or OFN_EXPLORER or OFN_LONGNAMES;
{$IFDEF FPC}
       if GetOpenFileNameW(@ofn) then
{$ELSE ~FPC}
       if GetOpenFileName(ofn) then
{$ENDIF FPC}
       begin
         Result := True;
         if Multi then
          begin
            vDir := StrPas(szFile);
            j := ofn.nFileOffset;
  //          j := Pos(#0, szFile);
            if j > Length(vDir) then
             begin
              repeat
    //            i := PosEx(#0, szFile, j);
    //            vEnd := (i=j) or (szFile[i+1] = #0);
                FileNames := FileNames + vDir + PathDelim + StrPas(szFile+j) + ';';
    //            FileNames := FileNames + vDir + '\'+ Copy(szFile+j, j, i-j) + ';';
                j := j + StrLen(szFile+j) + 1;
              until szFile[j]=#0;
              SetLength(FileNames, length(FileNames)-1);
             end
            else
             FileNames := vDir;
          end
         else
          FileNames := StrPas(szFile);
       end;
      finally
       if i > 0 then
         SetCurrentDirectoryW(szDir);
     end;
   end
   else
   begin
     i := -1;
     try
       i := GetCurrentDirectoryW(length(szDir), szDir);
{$IFDEF FPC}
       if GetOpenFileNameW(@ofn) then
{$ELSE ~FPC}
       if GetOpenFileName(ofn) then
{$ENDIF FPC}
       begin
         Result := True;
         FileNames := StrPas(szFile);
       end;
      finally
       if i > 0 then
         SetCurrentDirectoryW(szDir);
     end;
   end;
  except
    Result := False;
  end;
end;

function OpenDirDialog(ParentHandle: THandle; Title: UnicodeString; var DirName: UnicodeString): boolean;
{$IFNDEF BIF_NONEWFOLDERBUTTON}
const
  BIF_UAHINT = $100;   // Add a UA hint to the dialog, in place of the edit box. May not be combined with BIF_EDITBOX
  BIF_NONEWFOLDERBUTTON = $200;   // Do not add the "New Folder" button to the dialog.  Only applicable with BIF_NEWDIALOGSTYLE.
{$ENDIF BIF_NONEWFOLDERBUTTON}
var
//   TitleName: string;
   lpItemID: PItemIDList;
   //BrowseInfo: TBrowseInfo;
   BrowseInfo: TBrowseInfoW;
   DisplayName: array[0..MAX_PATH] of WideChar;
   TempPath: array[0..MAX_PATH] of WideChar;
//   TempPath: array[0..MAX_PATH] of WideChar;
//   TempPath : PWideChar;
begin
   FillChar(BrowseInfo, sizeof(BrowseInfo), #0);
   BrowseInfo.hwndOwner := ParentHandle;
   BrowseInfo.pszDisplayName := @DisplayName;
//   TitleName := 'Please specify a directory';

//   BrowseInfo.lpszTitle := PWideChar(Title);
   BrowseInfo.lpszTitle := PWideChar(Title);
   BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE or BIF_NONEWFOLDERBUTTON or BIF_UAHINT;
   lpItemID := SHBrowseForFolderW(BrowseInfo);
   if lpItemId <> nil then
   begin
    SHGetPathFromIDListW(lpItemID, TempPath);
//    SHGetPathFromIDList(lpItemID, TempPath);
    Result := True;
//    DirName := WideCharToString(TempPath);
    DirName := StrPas(TempPath);
    GlobalFreePtr(lpItemID);
   end
   else
    Result := false;
end;

{$IFDEF usesVCL}

function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  I: Integer;
  Buffer: array[0..51] of Char;
begin
  for I := 0 to 25 do
    Buffer[I] := Chr(I + Ord('A'));
  for I := 0 to 25 do
    Buffer[I + 26] := Chr(I + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;

{var

  ModalResults: array[TMsgDlgBtn] of Integer = (
    mrYes, mrNo, mrOk, mrCancel, mrAbort, mrRetry, mrIgnore, mrAll, mrNoToAll,
    mrYesToAll, 0);}

function InputQuery(const ACaption, APrompt: string;
  var Value: string): Boolean;
var
  Form: TForm;
  Prompt: TLabel;
  Edit: TEdit;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;
begin
  Result := False;
  Form := TForm.Create(Application);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      Position := poScreenCenter;
      Prompt := TLabel.Create(Form);
      with Prompt do
      begin
        Parent := Form;
        Caption := APrompt;
        Left := MulDiv(8, DialogUnits.X, 4);
        Top := MulDiv(8, DialogUnits.Y, 8);
        Constraints.MaxWidth := MulDiv(164, DialogUnits.X, 4);
        WordWrap := True;
      end;
      Edit := TEdit.Create(Form);
      with Edit do
      begin
        Parent := Form;
        Left := Prompt.Left;
        Top := Prompt.Top + Prompt.Height + 5;
        Width := MulDiv(164, DialogUnits.X, 4);
        MaxLength := 255;
        Text := Value;
        SelectAll;
      end;
      ButtonTop := Edit.Top + Edit.Height + 15;
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with TDialogButton.Create(Form) do
      begin
        Parent := Form;
//        Caption := getTranslation(SMsgDlgOK);
        Caption := SMsgDlgOK;
        ModalResult := mrOk;
        Default := True;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
      end;
      with TDialogButton.Create(Form) do
      begin
        Parent := Form;
        Caption := getTranslation(SMsgDlgCancel);
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(MulDiv(92, DialogUnits.X, 4), Edit.Top + Edit.Height + 15,
          ButtonWidth, ButtonHeight);
        Form.ClientHeight := Top + Height + 13;
      end;
      if ShowModal = mrOk then
      begin
        Value := Edit.Text;
        Result := True;
      end;
    finally
      Form.Free;
    end;
end;

function InputQueryBig(const ACaption, APrompt: string;
  var Value: string): Boolean;
var
  Form: TForm;
  Prompt: TLabel;
  memo: TMemo;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;
begin
  Result := False;
  Form := TForm.Create(Application);
  with Form do
    try
      Visible := False;
      Canvas.Font := Font;
      DialogUnits := GetAveCharSize(Canvas);
//      BorderStyle := bsDialog;
      BorderStyle := bsSizeToolWin;
      Caption := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      Position := poScreenCenter;
      Prompt := TLabel.Create(Form);
      with Prompt do
      begin
        Parent := Form;
        Caption := APrompt;
        Left := MulDiv(8, DialogUnits.X, 4);
        Top := MulDiv(8, DialogUnits.Y, 8);
        Constraints.MaxWidth := MulDiv(164, DialogUnits.X, 4);
        WordWrap := True;
      end;
      memo := TMemo.Create(Form);
      with memo do
      begin
        Parent := Form;
        Left := Prompt.Left;
        Top := Prompt.Top + Prompt.Height + 5;
        Width := MulDiv(164, DialogUnits.X, 4);
        MaxLength := 1000;
        Text := Value;
        SelectAll;
      end;
      ButtonTop := memo.Top + memo.Height + 15;
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with TDialogButton.Create(Form) do
      begin
        Parent := Form;
        Caption := getTranslation(SMsgDlgOK);
//        Caption := SMsgDlgOK;
        ModalResult := mrOk;
        Default := True;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
        Form.ClientHeight := Top + Height + 13;
        Anchors := [akBottom];
      end;
      with TDialogButton.Create(Form) do
      begin
        Parent := Form;
        Caption := getTranslation(SMsgDlgCancel);
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(MulDiv(92, DialogUnits.X, 4), memo.Top + memo.Height + 15,
          ButtonWidth, ButtonHeight);
        Anchors := [akBottom];
      end;
      memo.Anchors := [akLeft, akTop, akRight, akBottom];
      Form.Constraints.MinWidth := 250;
      Form.Constraints.MinHeight := 200;
      if ShowModal = mrOk then
      begin
        Value := memo.Text;
        Result := True;
      end;
    finally
      Form.Free;
    end;
end;

var
  ModalResults: array[RDGlobal.TMsgDlgBtn] of Integer = (
    mrYes, mrNo, mrOk, mrCancel, mrAbort, mrRetry, mrIgnore, mrAll, mrNoToAll,
    mrYesToAll, 0, mrClose);
  ButtonCaptions: array[RDGlobal.TMsgDlgBtn] of Pointer = (
    @SMsgDlgYes, @SMsgDlgNo, @SMsgDlgOK, @SMsgDlgCancel, @SMsgDlgAbort,
    @SMsgDlgRetry, @SMsgDlgIgnore, @SMsgDlgAll, @SMsgDlgNoToAll, @SMsgDlgYesToAll,
    @SMsgDlgHelp, @SMsgDlgClose);


type
  TMessageForm = class(TForm)
  public
    class var
      MsgSuffix: String;
  private
    FTimer: TTimer;
    FSeconds: Integer;
    DefaultButton: TMsgDlgBtn;
    DefButton: TDialogButton;
    Message: TLabel;
    procedure HelpButtonClick(Sender: TObject);
  protected
    procedure CustomKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WriteToClipBoard(Text: String);
    function GetFormText: String;
  public
    procedure onTimer(Sender: TObject);
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

procedure TMessageForm.onTimer(Sender: TObject);
begin
  Dec(FSeconds);
    DefButton.Caption := getTranslation( LoadResString(ButtonCaptions[DefaultButton]) +
      ' (%d)', [FSeconds]);
//      ' (' + IntToStr(FSeconds) + ')';
  if FSeconds <= 0 then
  begin
    ModalResult := ModalResults[DefaultButton];
    FTimer.Enabled := False
  end
end;

constructor TMessageForm.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
var
  LPPI: Integer;
begin
  inherited CreateNew(AOwner, Dummy);
  {$IFDEF FPC}
  Font.Assign(Screen.SystemFont);
  {$ELSE ~FPC}
  Font.Assign(Screen.MessageFont);
  {$ENDIF ~FPC}
  LPPI := Screen.PixelsPerInch;
  if Screen.ActiveForm <> nil then
  {$IFDEF FPC}
    LPPI := Screen.ActiveForm.PixelsPerInch
  {$ELSE FPC}
    LPPI := Screen.ActiveForm.CurrentPPI
  {$ENDIF FPC}
  else
    if Application.MainForm <> nil then
    {$IFDEF FPC}
      LPPI := Application.MainForm.PixelsPerInch;
    {$ELSE FPC}
      LPPI := Application.MainForm.CurrentPPI;
    {$ENDIF FPC}
  {$IFNDEF FPC}
  ScaleForPPI(LPPI);
  {$ENDIF ~FPC}
end;

procedure TMessageForm.HelpButtonClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TMessageForm.CustomKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Key = Word('C')) then
  begin
    Beep;
    WriteToClipBoard(GetFormText);
  end;
end;

procedure TMessageForm.WriteToClipBoard(Text: String);
var
  Data: THandle;
  DataPtr: Pointer;
begin
  if OpenClipBoard(0) then
  begin
    try
      Data := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, Length(Text) + 1);
      try
        DataPtr := GlobalLock(Data);
        try
          Move(PChar(Text)^, DataPtr^, Length(Text) + 1);
          EmptyClipBoard;
          SetClipboardData(CF_TEXT, Data);
        finally
          GlobalUnlock(Data);
        end;
      except
        GlobalFree(Data);
        raise;
      end;
    finally
      CloseClipBoard;
    end;
  end
  else
    raise Exception.CreateRes(@SCannotOpenClipboard);
end;

function TMessageForm.GetFormText: String;
var
  DividerLine, ButtonCaptions: string;
  I: integer;
begin
  DividerLine := StringOfChar('-', 27) + sLineBreak;
  ButtonCaptions := '';
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TDialogButton then
      ButtonCaptions := ButtonCaptions + TDialogButton(Components[I]).Caption +
        StringOfChar(' ', 3);
  ButtonCaptions := StringReplace(ButtonCaptions, '&', '', [rfReplaceAll]);
  Result := Format('%s%s%s%s%s%s%s%s%s%s', [DividerLine, Caption, sLineBreak,
    DividerLine, Message.Caption, sLineBreak, DividerLine, ButtonCaptions,
    sLineBreak, DividerLine]);
end;

var
  ButtonNames: array[TMsgDlgBtn] of string = (
    'Yes', 'No', 'OK', 'Cancel', 'Abort', 'Retry', 'Ignore', 'All', 'NoToAll',
    'YesToAll', 'Help', 'Close');
var
  ButtonWidths : array[TMsgDlgBtn] of integer;  // initialized to zero

function CreateMessageDialog(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; pDefaultButton: TMsgDlgBtn;
  Seconds: Integer = 0): TForm;
var
  B, CancelButton: TMsgDlgBtn;

const
  mcHorzMargin = 8;
  mcVertMargin = 8;
  mcHorzSpacing = 10;
  mcVertSpacing = 10;
  mcButtonWidth = 50;
  mcButtonHeight = 14;
  mcButtonSpacing = 4;
var
  DialogUnits: TPoint;
  HorzMargin, VertMargin, HorzSpacing, VertSpacing, ButtonWidth,
  ButtonHeight, ButtonSpacing, ButtonCount, ButtonGroupWidth,
  IconTextWidth, IconTextHeight, X, ALeft: Integer;
  IconSize: Integer;
  IconID: PChar;
  TextRect: TRect;
  FormPPI: Integer;
  tB: TDialogButton;
  function GetMsgIconResourceName: String;
  begin
    Result := '';
    case DlgType of
      mtWarning:
        Result := 'MSG_WARNING';
      mtError:
        Result := 'MSG_ERROR';
      mtInformation,
      mtConfirmation:
        Result := 'MSG_INFO';
    end;
  end;
begin
  Result := TMessageForm.CreateNew(Application);
  with Result do
  begin
    {$IFDEF FPC}
    Font.Assign(Screen.SystemFont);
    FormPPI := PixelsPerInch;
    IconSize := ScaleFormTo96(32);
    {$ELSE FPC}
    Font.Assign(Screen.MessageFont);
    FormPPI := CurrentPPI;
    IconSize := ScaleValue(32);
    {$ENDIF FPC}
    Font.Height := Muldiv(Font.Height, FormPPI, Screen.PixelsPerInch);
    BiDiMode := Application.BiDiMode;
    BorderStyle := bsDialog;
    Canvas.Font := Font;
    KeyPreview := True;
    Position := poDesigned;
    OnKeyDown := TMessageForm(Result).CustomKeyDown;
    DialogUnits := GetAveCharSize(Canvas);
    HorzMargin := MulDiv(mcHorzMargin, DialogUnits.X, 4);
    VertMargin := MulDiv(mcVertMargin, DialogUnits.Y, 8);
    HorzSpacing := MulDiv(mcHorzSpacing, DialogUnits.X, 4);
    VertSpacing := MulDiv(mcVertSpacing, DialogUnits.Y, 8);
    ButtonWidth := MulDiv(mcButtonWidth, DialogUnits.X, 4);
    if Seconds > 0 then
     begin
       TMessageForm(Result).FSeconds := Seconds;
       TMessageForm(Result).FTimer := TTimer.Create(result);
       TMessageForm(Result).FTimer.OnTimer := TMessageForm(Result).onTimer;
     end;
    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
    begin
      if B in Buttons then
      begin
        if ButtonWidths[B] = 0 then
        begin
          TextRect := Rect(0,0,0,0);
          Windows.DrawText( canvas.handle,
            PChar(LoadResString(ButtonCaptions[B])), -1,
            TextRect, DT_CALCRECT or DT_LEFT or DT_SINGLELINE
  {$IFNDEF FPC}
            or DrawTextBiDiModeFlagsReadingOnly
  {$ENDIF ~FPC}
            );
          with TextRect do ButtonWidths[B] := Right - Left + 8;
        end;
        if ButtonWidths[B] > ButtonWidth then
          ButtonWidth := ButtonWidths[B];
      end;
    end;
    ButtonHeight := MulDiv(mcButtonHeight, DialogUnits.Y, 8);
    ButtonSpacing := MulDiv(mcButtonSpacing, DialogUnits.X, 4);
    SetRect(TextRect, 0, 0, Screen.Width div 2, 0);
    DrawText(Canvas.Handle, PChar(Msg), Length(Msg)+1, TextRect,
      DT_EXPANDTABS or DT_CALCRECT or DT_WORDBREAK
  {$IFNDEF FPC}
      or DrawTextBiDiModeFlagsReadingOnly
  {$ENDIF ~FPC}
      );
    IconID := IconIDs[DlgType];
    IconTextWidth := TextRect.Right;
    IconTextHeight := TextRect.Bottom;
    if IconID <> nil then
    begin
      Inc(IconTextWidth, IconSize + HorzSpacing);
      if IconTextHeight < IconSize then IconTextHeight := IconSize;
    end;
    ButtonCount := 0;
    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      if B in Buttons then Inc(ButtonCount);
    ButtonGroupWidth := 0;
    if ButtonCount <> 0 then
      ButtonGroupWidth := ButtonWidth * ButtonCount +
        ButtonSpacing * (ButtonCount - 1);
    ClientWidth := Max(IconTextWidth, ButtonGroupWidth) + HorzMargin * 2;
    ClientHeight := IconTextHeight + ButtonHeight + VertSpacing +
      VertMargin * 2;
    if FormPPI > Screen.PixelsPerInch then
      ClientHeight := ClientHeight + Muldiv(VertMargin div 2, FormPPI, Screen.PixelsPerInch)
    else if FormPPI < Screen.PixelsPerInch then
      ClientHeight := ClientHeight - Muldiv(VertMargin div 2, Screen.PixelsPerInch, FormPPI);
{    begin
      GlassFrame.Enabled := True;
      GlassFrame.SheetOfGlass := True;
      DoubleBuffered := True;
    end;}
    Left := (Screen.Width div 2) - (Width div 2);
    Top := (Screen.Height div 2) - (Height div 2);
    if DlgType <> mtCustom then
      Caption := getTranslation(LoadResString(Captions[DlgType]))
     else
      Caption := Application.Title;
 {$IFDEF RNQ}
    if TMessageForm.msgSuffix > '' then
      Caption := Caption + ' ' + TMessageForm.msgSuffix;
 {$ENDIF RNQ}
    if IconID <> nil then
      with TImage.Create(Result) do
      begin
        Name := 'Image';
        Parent := Result;
 {$IFNDEF FPC}
        if TOSVersion.Check(6, 2) then
        begin
          Picture.WICImage.LoadFromResourceName(HInstance, GetMsgIconResourceName);
          Picture.WICImage.InterpolationMode := wipmHighQualityCubic;
          AutoSize := False;
          Stretch := True;
          Proportional := True;
        end
        else
  {$ENDIF ~FPC}
        begin
          Picture.Icon.Handle := LoadIcon(0, IconID);
          AutoSize := True;
        end;
        if Result.BiDiMode = bdRightToLeft then
          SetBounds(Result.ClientWidth - HorzMargin - IconSize, VertMargin, IconSize, IconSize)
        else
          SetBounds(HorzMargin, VertMargin, IconSize, IconSize);
      end;
    TMessageForm(Result).Message := TLabel.Create(Result);
    with TMessageForm(Result).Message do
    begin
      Name := SMessage;
      Parent := Result;
      WordWrap := True;
//      GlowSize := 5;
      Caption := getTranslation(Msg);
      BoundsRect := TextRect;
      BiDiMode := Result.BiDiMode;
      ALeft := IconTextWidth - TextRect.Right + HorzMargin;
      if UseRightToLeftAlignment then
        ALeft := Result.ClientWidth - ALeft - Width;
      SetBounds(ALeft, VertMargin,
        TextRect.Right, TextRect.Bottom);
    end;
    if mbOk in Buttons then TMessageForm(Result).DefaultButton := mbOk else
      if mbYes in Buttons then TMessageForm(Result).DefaultButton := mbYes else
        TMessageForm(Result).DefaultButton := mbRetry;
    if mbCancel in Buttons then CancelButton := mbCancel else
      if mbNo in Buttons then CancelButton := mbNo else
        CancelButton := mbOk;
    X := (ClientWidth - ButtonGroupWidth) div 2;
    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      if B in Buttons then
      begin
        tB := TDialogButton.Create(Result);
        with tB do
        begin
          Name := ButtonNames[B];
          Parent := Result;
          Caption := getTranslation(LoadResString(ButtonCaptions[B]));
          ModalResult := ModalResults[B];
          if B = TMessageForm(Result).DefaultButton then
            begin
              Default := True;
              TMessageForm(Result).DefButton := tB;
            end;
          if B = CancelButton then Cancel := True;
          SetBounds(X, IconTextHeight + VertMargin + VertSpacing,
            ButtonWidth, ButtonHeight);
          Inc(X, ButtonWidth + ButtonSpacing);
          if B = mbHelp then
            OnClick := TMessageForm(Result).HelpButtonClick;
          ParentDoubleBuffered := False;
          DoubleBuffered := False;
        end;
     end;
  end;
end;

function MessageDlg(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
begin
  with CreateMessageDialog(Msg, DlgType, Buttons, mbAll) do
    try
      HelpContext := HelpCtx;
//      HelpFile := HelpFileName;
//      if X >= 0 then Left := X;
//      if Y >= 0 then Top := Y;
//      if (Y < 0) and (X < 0) then
       Position := poScreenCenter;
      Result := ShowModal;
    finally
      Free;
    end;
//  Result := MessageDlgPosHelp(Msg, DlgType, Buttons, HelpCtx, -1, -1, '');
end;

function MessageDlg(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; HelpCtx: Longint; pDefaultButton: TMsgDlgBtn;
  Seconds: Integer): Integer;
begin
  with CreateMessageDialog(Msg, DlgType, Buttons, pDefaultButton, Seconds) do
    try
      HelpContext := HelpCtx;
       Position := poScreenCenter;
      Result := ShowModal;
    finally
      Free;
    end;
end;
{$ENDIF}

function ChooseFontDlg(ParentHandle: THandle; Title: String; var Font: TFont): boolean;
var
  vCF: TChooseFont;
  ff: Windows.LOGFONT;
begin
//  ff.lfHeight  := Font.Height;
  ff.lfCharSet := Font.Charset;
  StrPCopy(ff.lfFaceName, Font.Name);
  ff.lfHeight := Font.Height;
  {$IFDEF DELPHI9_UP}
   ff.lfOrientation := Font.Orientation;
  {$ENDIF DELPHI9_UP}
  ff.lfPitchAndFamily := DEFAULT_PITCH;// or FF_SWISS;

  if TFontStyle.fsBold in font.Style then
   begin
   ff.lfWeight := FW_BOLD
   end
  else
//   ff.lfWeight := FW_NORMAL;
    ff.lfWeight := FW_REGULAR;
  ff.lfItalic := -byte(TFontStyle.fsItalic in font.Style);
  ff.lfUnderline := -byte(TFontStyle.fsUnderline in font.Style);
  ff.lfEscapement := 0;
  ff.lfStrikeOut := -byte(TFontStyle.fsStrikeOut in font.Style);
  ff.lfQuality := DEFAULT_QUALITY;
// ff.lfItalic := Font.
  With vcf do begin
      lStructSize := SizeOf(TChooseFont);
      hWndOwner := ParentHandle;
//      hInstance := CF_ENABLETEMPLATE;
      nFontType := SCREEN_FONTTYPE; //SIMULATED_FONTTYPE;
      if TFontStyle.fsBold in font.Style then
        nFontType := nFontType or BOLD_FONTTYPE;
      if TFontStyle.fsItalic in font.Style then
        nFontType := nFontType or ITALIC_FONTTYPE;

      rgbColors := ColorToRGB(Font.Color);
      lpLogFont := @ff;
      vcf.iPointSize := Font.Size;
//      Flags := (CF_SCREENFONTS or CF_SCRIPTSONLY);
      Flags := CF_SCREENFONTS or CF_EFFECTS {or CF_NOSTYLESEL }or CF_INITTOLOGFONTSTRUCT;
  end;
  try
{$IFDEF FPC}
    Result := ChooseFont(@vCF);
{$ELSE ~FPC}
    Result := ChooseFont(vCF);
{$ENDIF FPC}
   except
    Result := False;
   end;
  if Result then
  begin
    Font.Handle := CreateFontIndirect(ff);
//  Font.Name := ff.lfFaceName;
    Font.Color := vcf.rgbColors;
    if ff.lfItalic <> 0 then
      Font.Style := Font.Style + [fsItalic];
//    if ff.lfWeight > 1 then
//      Font.Style :=
    Font.Size := vcf.iPointSize div 10;
    if ff.lfWeight = FW_BOLD then
      font.Style := Font.Style + [fsBold];
  end;
//  cnv := TCanvas.Create;
//  cnv.Font := Font;
//  vCF.hDC := cnv.Handle;
//  font := cnv.Font;
//  cnv.Free;
end;


const
TD_ICON_BLANK = 100;
TD_ICON_WARNING = 101;
TD_ICON_QUESTION = 102;
TD_ICON_ERROR = 103;
TD_ICON_INFORMATION = 104;
TD_ICON_BLANK_AGAIN = 105;
TD_ICON_SHIELD = 106;

TD_OK = 1;
TD_YES = 2;
TD_NO = 4;
TD_CANCEL = 8;
TD_RETRY = 16;
TD_CLOSE = 32;

DLGRES_OK = 1;
DLGRES_CANCEL = 2;
DLGRES_RETRY = 4;
DLGRES_YES = 6;
DLGRES_NO = 7;
DLGRES_CLOSE = 8;

{ Example:
 HRESULT TaskDialog(HWND hWndParent,
    HINSTANCE hInstance,
    PCWSTR pszWindowTitle,
    PCWSTR pszMainInstruction,
    PCWSTR pszContent,
    TASKDIALOG_COMMON_BUTTON_FLAGS dwCommonButtons,
    PCWSTR pszIcon,
    int *pnButton
);

this translates in Delphi to a function:

 TaskDialog: function(HWND: THandle; hInstance: THandle; cTitle, cDescription, cContent: pwidechar; Buttons: Integer; Icon: integer; ResButton: pinteger): integer;
procedure TaskMessage(AForm: TCustomForm; AMessage: string);
begin
  TaskDialog(AForm, '', '', AMessage, TD_OK, 0);
end;
if TaskDialog(self, 'Hello world','Ready to enjoy the new Vista task dialog ?',
   'The new Vista task dialog presents an easy to use and user-friendly replacement for messageboxes.', 
   TD_YES + TD_NO, TD_ICON_QUESTION) = mrYes then
     TaskMessage(self,'yes');
}
function TaskDialog(AForm: TCustomForm; ATitle, ADescription, AContent: string; Buttons, Icon: integer): integer;
var
  VerInfo: TOSVersioninfo;
  DLLHandle: THandle;
  res: integer;
  wTitle, wDescription, wContent: array[0..1024] of widechar;
  Btns: TMsgDlgButtons;
  DlgType: TMsgDlgType;
  TaskDialogProc: function(HWND: THandle; hInstance: THandle;
       cTitle, cDescription, cContent: pwidechar; Buttons: Integer; Icon: integer;
       ResButton: pinteger): integer; cdecl stdcall;

begin
  Result := 0;

  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(verinfo);

  if (verinfo.dwMajorVersion >= 6) then
  begin
    DLLHandle := LoadLibrary(comctl32); // 'comctl32.dll');
    if DLLHandle >= 32 then
    begin
      @TaskDialogProc := GetProcAddress(DLLHandle, 'TaskDialog');
 
      if Assigned(TaskDialogProc) then
      begin
        StringToWideChar(ATitle, wTitle, sizeof(wTitle));
        StringToWideChar(ADescription, wDescription, sizeof(wDescription));
        StringToWideChar(AContent, wContent, sizeof(wContent));
        TaskDialogProc(AForm.Handle, 0, wTitle, wDescription, wContent, Buttons, Icon, @res);

        Result := mrOK;

        case res of
        DLGRES_CANCEL : Result := mrCancel;
        DLGRES_RETRY : Result := mrRetry;
        DLGRES_YES : Result := mrYes;
        DLGRES_NO : Result := mrNo;
        DLGRES_CLOSE : Result := mrAbort;
        end;
      end;
      FreeLibrary(DLLHandle);
    end;
  end
  else
  begin
    Btns := [];
    if Buttons and TD_OK = TD_OK then
      Btns := Btns + [MBOK];
  
    if Buttons and TD_YES = TD_YES then
      Btns := Btns + [MBYES];

    if Buttons and TD_NO = TD_NO then
      Btns := Btns + [MBNO];

    if Buttons and TD_CANCEL = TD_CANCEL then
      Btns := Btns + [MBCANCEL];

    if Buttons and TD_RETRY = TD_RETRY then
      Btns := Btns + [MBRETRY];

    if Buttons and TD_CLOSE = TD_CLOSE then
      Btns := Btns + [MBABORT];

    DlgType := mtCustom;

    case Icon of
    TD_ICON_WARNING : DlgType := mtWarning;
    TD_ICON_QUESTION : DlgType := mtConfirmation;
    TD_ICON_ERROR : DlgType := mtError;
    TD_ICON_INFORMATION: DlgType := mtInformation;
    end;

    Result := MessageDlg(AContent, DlgType, Btns, 0);
  end;
end;

end.

