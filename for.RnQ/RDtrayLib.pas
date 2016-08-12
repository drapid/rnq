{
This file is part of R&Q.
Under same license
}
unit RDtraylib;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Messages, windows, RDGlobal,
  graphics, ShellApi;

const
  WM_TRAY = WM_USER+1;
  cTRAY_uID = 100;
  flags_v2 = NIF_MESSAGE or NIF_ICON or NIF_TIP;
  flags_v4 = NIF_MESSAGE or NIF_ICON or NIF_TIP or NIF_SHOWTIP or NIF_GUID;
  flags_info = NIF_INFO or NIF_SHOWTIP or NIF_GUID;

type
   TNotifyIconDataW_V2 = record
     cbSize: DWORD;
     Wnd: HWND;
     uID: UINT;
     uFlags: UINT;
     uCallbackMessage: UINT;
     hIcon: HICON;
     szTip: array [0..127] of WideChar;
     dwState: DWORD;
     dwStateMask: DWORD;
     szInfo: array [0..255] of WideChar;
     case Integer of
      0: (
        uTimeout: UINT);
      1: (uVersion: UINT;
        szInfoTitle: array [0..63] of WideChar;
        dwInfoFlags: DWORD);
//     TimeoutOrVersion: TTimeoutOrVersion;
//     szInfoTitle: array [0..63] of WideChar;
//     dwInfoFlags: DWORD;
   end;

  TNotifyIconDataW_V4 = record
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0 .. 127] of WideChar;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0 .. 255] of WideChar;
    case Integer of
      0: (uTimeout: UINT);
      1: (uVersion: UINT;
        szInfoTitle: array [0..63] of WideChar;
        dwInfoFlags: DWORD;
        guidItem: TGUID;        // Requires Windows Vista or later
        hBalloonIcon: HICON);   // Requires Windows Vista or later
  end;

  PNotifyIconDataW_V2 = ^TNotifyIconDataW_V2;
  PNotifyIconDataW_V4 = ^TNotifyIconDataW_V4;

const
  NOTIFYIconDataW_V2_SIZE = SizeOf(TNotifyIconDataW_V2);
  NOTIFYIconDataW_V4_SIZE = SizeOf(TNotifyIconDataW_V4);

type
 {$IFDEF Use_Baloons}
  TBalloonIconType = (bitNone,    // нет иконки
                      bitInfo,    // информационная иконка (синяя)
                      bitWarning, // иконка восклицания (жёлтая)
                      bitError);  // иконка ошибки (красная)
 {$ENDIF Use_Baloons}
{  TBalloonType=(btNone, btError, btInfo, btWarning);
}
  TtrayIcon=class
    private
//      data:TNotifyIconData;
      data: TNotifyIconDataW_V4;
      shown, fHidden: Boolean;
      Ico: TIcon;
    public
      constructor Create(hndl: HWND);
      destructor Destroy; override;
      procedure minimize;
      procedure update;
      procedure hide;
      procedure show;
      procedure setIcon(icon: Ticon); overload;
      procedure setIcon(const iName: TPicName); overload;
      procedure setTip(const s: String);
//      procedure setIconFile(fn: String);
      procedure updateHandle(hndl: HWND);
      property Hidden: boolean read fHidden;
    end; // TtrayIcon

type
  TGetPicTipFunc = Procedure(var vPic: TPicName; var vTip: String); // of object;

  TstatusIcon = class
   private
    FOnGetPicTip: TGetPicTipFunc;
   public
    trayIcon: TtrayIcon;
    IcoName: TPicName;
    lastTip: String;
    constructor Create;
    destructor Destroy; override;
    procedure update;
    procedure empty;
    procedure ReDraw;
    procedure handleChanged(hndl: THandle);
 {$IFDEF Use_Baloons}
    procedure showballoon(const bldelay: Integer;
                          const BalloonText, BalloonTitle: String;
                          const BalloonIconType: TBalloonIconType);
    procedure hideBalloon;
 {$ENDIF Use_Baloons}
    property  OnGetPicTip: TGetPicTipFunc      read  FOnGetPicTip
                                               write FOnGetPicTip;
//    function AcceptBalloons: Boolean;
//    procedure BalloonHint (Title, Value: String; BalloonType: TBalloonType; Delay: Integer);
   end; // TstatusIcon

var
  ShowBalloonTime: Int64;
  EnabledBaloons: Boolean;
  TrayIconDataVersion: Integer = 2;

implementation

uses
  forms, sysutils,
  RDUtils, RnQStrings, RnQLangs, //themesLib,
  RQUtil, RQThemes, RnQGlobal
//  dwTaskbarComponents, dwTaskbarList,
//  fspTaskbarCommon, fspTaskbarApi,
  ;

const
     NIF_INFO = $00000010;

{
type
  TRnQTaskbarComponent = class(TdwTaskbarComponent)
   public
    property TaskbarList;
    property TaskbarList2;
    property TaskbarList3;
  end;
var
  tbcmp : TRnQTaskbarComponent;
}

constructor TstatusIcon.create;
begin
  if CheckWin32Version(6, 1) then
    TrayIconDataVersion := 4;
  trayIcon := TtrayIcon.create(0);
  trayIcon.setTip(Application.Title);
  IcoName := '';
  lastTip := '';
   {$IFDEF Use_Baloons}
     if GetShellVersion >= $00050000 then
      begin
       EnabledBaloons := true;
//       htimer := tmCreateIntervalTimerEx(handler, 2000, tmPeriod,
//        false, tnWinMsg, WM_TIMERNOTIFY, 2);
      end
     else
       EnabledBaloons := false;
   {$ENDIF Use_Baloons}
end; // create

destructor TstatusIcon.Destroy;
begin
  trayIcon.hide;
  trayIcon.free;
  trayIcon := NIL;
end; // destroy

procedure TstatusIcon.update;
var
//  nIco : String;
//  IcoDtl : TRnQThemedElementDtls;
  IcoPicName: TPicName;
  s: String;
begin
  if self = nil then
    exit;
  if Assigned(FOnGetPicTip) then
    FOnGetPicTip(IcoPicName, S)
   else
    begin
//      IcoPicName := PIC_CLIENT_LOGO;
      IcoPicName := 'tray';
      s := Application.Title;
    end;

//if IcoDtl.picName <> IcoName then
 if IcoPicName <> IcoName then
  begin
    IcoName := IcoPicName;
    trayIcon.setIcon(IcoName);
  end;
 if s <> lastTip then
  begin
   lastTip := s;
   trayIcon.setTip(s);
  end;
end; // update

procedure TstatusIcon.empty;
begin
  IcoName := PIC_EMPTY;
  trayIcon.setIcon(IcoName);
end;

procedure TstatusIcon.handleChanged(hndl: THandle);
begin
  if Assigned(trayIcon) then
    trayIcon.updateHandle(hndl)
end;

procedure TstatusIcon.showballoon(const bldelay: integer;
                          const BalloonText, BalloonTitle: String;
                          const BalloonIconType: TBalloonIconType);
const
  aBalloonIconTypes: array[TBalloonIconType] of Byte = (NIIF_NONE, NIIF_INFO, NIIF_WARNING, NIIF_ERROR);
var
//  NID_50: NotifyIconData_50;
//  NID_50: TNotifyIconData;
  NID_50: TNotifyIconDataW_V4;
  t: String;
begin
  if (not EnabledBaloons) or (not ShowBalloons) then
    exit;
  if balloontext = '' then
    t := '_'
   else
    t := balloontext;
  ShowBalloonTime := 0;
//  tmStopTimer(hTimer);
//  DZBalloonTrayIcon(window, IconID, t, balloontitle, balloonicontype);
  ShowBalloonTime := bldelay;
  ZeroMemory(@NID_50, NOTIFYIconDataW_V4_SIZE);
  with NID_50 do
  begin
    if TrayIconDataVersion = 4 then
      cbSize := NOTIFYIconDataW_V4_SIZE
     else
      cbSize := NOTIFYIconDataW_V2_SIZE;
    Wnd := trayIcon.data.Wnd;
    uID := trayIcon.data.uID;
    uFlags := NIF_INFO;
    StrLCopy(PWideChar(@szInfo[0]), PChar(BalloonText), 255);
//    StrPCopy(szTip, BalloonText);
    uTimeout := 30000;
    StrLCopy(PWideChar(@szInfoTitle[0]), PChar(BalloonTitle), 63);
    dwInfoFlags := aBalloonIconTypes[BalloonIconType];
    guidItem := TrayIcon.data.guidItem;
  end;
  Shell_NotifyIcon(NIM_MODIFY, @NID_50);
end;

procedure TstatusIcon.hideBalloon;
var
//  NID_50: NotifyIconData_50;
//  NID_50: TNotifyIconData;
  NID_50: TNotifyIconDataW_V2;
begin
  ShowBalloonTime := 0;
  if (not EnabledBaloons) or (not ShowBalloons) then
    exit;
//  ZeroMemory(@NID_50, SizeOf(NID_50));
  ZeroMemory(@NID_50, NOTIFYIconDataW_V2_SIZE);
  with NID_50 do
  begin
    cbSize := NOTIFYIconDataW_V2_SIZE;
    Wnd := trayIcon.data.Wnd;
    uID := trayIcon.data.uID;
    uFlags := NIF_INFO;
//    StrPCopy(PWideChar(@szInfo[0]), '');
//    StrPCopy(PWideChar(@szInfoTitle[0]), '');
//     := trayIcon.data.;
  end;
  Shell_NotifyIcon(NIM_MODIFY, @NID_50);
end;

constructor TtrayIcon.create(hndl: HWND);
var
  FGUID: TGUID;
begin
  ZeroMemory(@data, NOTIFYIconDataW_V4_SIZE);
  if TrayIconDataVersion = 4 then
      CreateGUID(FGUID);

 with data do
  begin
    uCallbackMessage := WM_TRAY;
    if TrayIconDataVersion = 4 then
      cbSize := NOTIFYIconDataW_V4_SIZE
     else
      cbSize := NOTIFYIconDataW_V2_SIZE;

   Wnd := hndl;
   uID := cTRAY_uID;
   hIcon := 0;
    if TrayIconDataVersion = 4 then
      uFlags := flags_v4
     else
      uFlags := flags_v2;
   uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
   guidItem := FGUID;
  end;
// tbcmp := TRnQTaskbarComponent.Create(Application);

 setIcon(application.icon);
 setTip(application.title);

{
//        if fspTaskbarMainAppWnd = 0 then
          if Application.MainFormOnTaskBar then
            fspTaskbarMainAppWnd := hndl
          else
            fspTaskbarMainAppWnd := Application.Handle; //Legacy App
}
end; // create

destructor TtrayIcon.Destroy;
begin
  if Assigned(ico) then
   ico.Free;
  ico := NIL;
//  tbcmp.Free;
end;

procedure TtrayIcon.updateHandle(hndl: HWND);
begin
{
//        if fspTaskbarMainAppWnd = 0 then
          if Application.MainFormOnTaskBar then
            fspTaskbarMainAppWnd := hndl
          else
            fspTaskbarMainAppWnd := Application.Handle; //Legacy App
}
  if not shown then
   begin
    data.wnd := hndl;
    exit;
   end;
  hide;
  data.wnd := hndl;
  Shell_NotifyIcon(NIM_ADD, @data);
 // Для балунов тоже нада бы...
end;

procedure TtrayIcon.update;
//var
//  ic : HICON;
begin
{ if shown then
   begin
     ic := CopyIcon(data.hIcon);
     tbcmp.TaskbarList3.SetOverlayIcon(tbcmp.TaskBarEntryHandle,
//                data.hIcon, PWideChar(@data.szTip[0]))
                ic, PWideChar(@data.szTip[0]))
   end
  else
   tbcmp.TaskbarList3.SetOverlayIcon(tbcmp.TaskBarEntryHandle, 0, nil);
 tbcmp.SendUpdateMessage;}

 if shown and not hidden then
  if not Shell_NotifyIcon(NIM_MODIFY, @data) then
    Shell_NotifyIcon(NIM_ADD, @data);

{
 if Assigned(pTaskBarList) then
  pTaskBarList.SetOverlayIcon(fspTaskbarMainAppWnd, data.hIcon, data.szTip);
}
end; { update }

procedure TtrayIcon.setIcon(icon: Ticon);
begin
  if icon=NIL then
    exit;
  if ico = NIL then
    ico := TIcon.Create;
  ico.Assign(icon);
//if data.hIcon <> 0 then
  data.hIcon:=ico.Handle;
  if TrayIconDataVersion = 4 then
    data.hBalloonIcon := Ico.Handle;
  update;
end; { setIcon }

procedure TtrayIcon.setIcon(const iName: TPicName);
begin
  if ico = NIL then
    ico := TIcon.Create;
  if theme.pic2ico(RQteTrayNotify, iName, ico) then
//  ico := theme.GetIco(iName);
//  if ico <> nil then
   begin
     data.hIcon:=ico.Handle;
     if TrayIconDataVersion = 4 then
       data.hBalloonIcon := Ico.Handle;
   end
  else
   begin
     ico.Handle := 0; // Application.Icon.Handle;
     data.hIcon := 0;
     data.hBalloonIcon := 0;
   end;
  update;
end;
{
procedure TtrayIcon.setIconFile(fn: String);
var
  ico:Ticon;
begin
ico:=Ticon.create;
ico.loadFromFile(fn);
setIcon(ico);
end; // setIconFile}

procedure TtrayIcon.setTip(const s: String);
begin
//  strPCopy(data.szTip, s);
  strLCopy(data.szTip, PChar(s), 127);
  update;
end; // setTip

procedure TtrayIcon.minimize;
begin
  show;
//  Application.ShowMainForm := False;
// Toolwindows dont have a TaskIcon. (Remove if TaskIcon is to be show when form is visible)
//  SetWindowLong(Application.Handle, GWL_EXSTYLE, WS_EX_TOOLWINDOW);
end; // minimizeToTray

procedure TtrayIcon.show;
begin
  shown := true;
  fHidden := False;
  Shell_NotifyIcon(NIM_ADD, @data)
end; { show }

procedure TtrayIcon.hide;
begin
 fHidden := True;
 Shell_NotifyIcon(NIM_DELETE, @data)
end;

procedure TstatusIcon.ReDraw;
begin
  trayIcon.setIcon(IcoName);
end;

{
function TstatusIcon.AcceptBalloons: Boolean;
begin
     Result:=GetShellVersion>=$00050000;
end;

procedure TstatusIcon.BalloonHint (Title, Value: string; BalloonType: TBalloonType; Delay: Integer);
//http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/Shell/reference/functions/shell_notifyicon.asp
begin
     if AcceptBalloons
        then begin
//             FTime :=Now;
//             FTimeDelay:=Delay;
//             FIc.uFlags:=NIF_INFO;
             trayIcon.data.uFlags := NIF_INFO;
             with FIc
                  do StrPLCopy (szInfoTitle, Title, SizeOf (szInfoTitle)-1);
             with FIc
                  do StrPLCopy (szInfo, Value, SizeOf (szInfo)-1);
             FIc.uFlags:=NIF_MESSAGE or NIF_ICON or NIF_INFO or NIF_TIP;
             FIc.uTimeOut:=Delay;
             case BalloonType of
                  btError: FIc.dwInfoFlags:=NIIF_ERROR;
                  btInfo: FIc.dwInfoFlags:=NIIF_INFO;
                  btNone: FIc.dwInfoFlags:=NIIF_NONE;
                  btWarning: FIc.dwInfoFlags:=NIIF_WARNING;
             end;
             Shell_NotifyIcon (NIM_MODIFY, PNotifyIconData (@FIc));
        end;
end;
}

end.
