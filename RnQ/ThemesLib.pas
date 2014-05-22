{
This file is part of R&Q.
Under same license
}
unit themesLib;
{$I RnQConfig.inc}


{$WRITEABLECONST OFF} // Read-only typed constants

{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}

interface

uses
  Graphics, Controls, Classes,
  RQMenuItem, Menus, RDGlobal,
  RQThemes,
  RDFileUtil;

procedure ResetThemePaths;
procedure resetTheme;
procedure applyTheme;
procedure ApplyThemeComponent(c : Tcontrol);
procedure repaintAllWindows;
procedure refreshMenuThemelist(menuItem : TMenuItem; StartIDX : byte; proc : TnotifyEvent);
procedure refreshMenuSmileslist(menuItem : TMenuItem; StartIDX : byte; proc : TnotifyEvent);
procedure refreshMenuSoundslist(menuItem : TMenuItem; StartIDX : byte; proc : TnotifyEvent);
procedure SetContactsThemeUse(b : Boolean);

procedure reloadCurrentTheme();

var
  statusPics : array[0..15] of array[boolean] of TRnQThemedElementDtls;
  RQSmilesPath, RQSoundsPath : TThemePath;

implementation

uses
  Forms, virtualtrees, SysUtils, Math, StrUtils,
  RQUtil, RnQMenu, RnQbuttons, RnQGlobal, RnQGraphics32, RnQPics,
  utilLib, globalLib, chatDlg, historyVCL, events,
  mainDlg,
//  menusUnit,
 {$IFNDEF RNQ_LITE}
  themedit_fr
  ,
 {$ENDIF}
  RnQProtocol,
 {$IFDEF PROTOCOL_ICQ}
  Protocol_ICQ, ICQClients, icqConsts,
 {$ENDIF PROTOCOL_ICQ}
  roasterlib;

procedure applyTheme;
//var
// bmp : TBitmap;
begin

  LoadClientsDefs;

if (chatFrm<>NIL) then
  begin
  setupChatButtons;
  chatFrm.updateGraphics;
  end;
 TextBGColor := theme.GetColor(ClrHistBG, clWindow);
 historyVCL.hisBGColor  := theme.GetColor(ClrHistBG+'.his', TextBGColor);
 historyVCL.myBGColor   := theme.GetColor(ClrHistBG+'.my', TextBGColor);
  with theme.GetPicSize(RQteDefault, PIC_MSG_OK) do
   hasMsgOK := (cx > 0) and (cy > 0);
  with theme.GetPicSize(RQteDefault, PIC_MSG_SERVER) do
   hasMsgSRV := (cx > 0) and (cy > 0);
{mainFrm.roaster.background.Bitmap.Dormant;
mainFrm.roaster.background.bitmap.FreeImage;
mainFrm.roaster.background.bitmap.ReleaseHandle;}
//  bmp := TBitmap.Create;
  with RnQmain, roster.treeoptions do
  begin
  if theme.GetPicOld(PIC_RSTR_BG, roster.background.bitmap) then
   begin
       if (roster.background.bitmap.Width > 0)
          and (roster.background.bitmap.Height > 0) then
       begin
         paintoptions:=paintoptions+[toShowBackground];
        end
   end     
     else
        paintoptions:=paintoptions-[toShowBackground];
//   RnQmain.roaster.TreeOptions.PaintOptions
//  bmp.Free;
    {with mainfrm.roaster.treeoptions do
      if mainFrm.roaster.background.bitmap.width > 0 then
        paintoptions:=paintoptions+[toShowBackground]
      else
        paintoptions:=paintoptions-[toShowBackground];}

    roster.color:=theme.GetColor(PIC_RSTR_BG, clWindow); //roster.bgcolor;
    bar.color:= theme.GetColor('roaster.bar', clBtnFace); //roster.barcolor;
    color := bar.color;

    {  mainfrm.color := $FFFFccFF;
      mainfrm.TransparentColorValue := mainfrm.color;
      mainfrm.TransparentColor := True;}
{    sbar.color := bar.color;
    sbar.BorderWidth := 0;
    sbar.Brush.Color := sbar.color;}
//    PntBar.Color := bar.color;
    roster.colors.focusedselectioncolor:= theme.GetColor('roaster.selection', clHighlight); //roaster.selectioncolor;
    roster.colors.focusedselectionbordercolor   := roster.colors.focusedselectioncolor;
    roster.colors.unfocusedselectioncolor       := roster.colors.focusedselectioncolor;
    roster.colors.unfocusedselectionbordercolor := roster.colors.focusedselectioncolor;


    menuBtn.Top:=0;
    statusBtn.Top:=0;
    visibilityBtn.Top:=0;
    menuBtn.ImageName := PIC_CLIENT_LOGO;
    //mainfrm.menuBtn.glyph.FreeImage;
//    ApplyThemeComponent(menuBtn);
//    ApplyThemeComponent(statusBtn);
//    ApplyThemeComponent(visibilityBtn);
     with theme.getPicSize(RQteButton, PIC_CLIENT_LOGO, icon_size) do
      begin
        bar.Height:=cy+7;
        menuBtn.height:=cy+5;
        menuBtn.width:=cx+6;
      end;
//     with theme.getPicSize(PIC_STATUS_ONLINE, 16) do
      with theme.GetPicSize(RQteButton, status2imgName(byte(SC_ONLINE)), icon_size) do
      begin
        statusBtn.height := max(cy+5, icon_size);
        statusBtn.width  := cx+6;
    //  end;
    // with theme.getPicSize(PIC_STATUS_ONLINE) do
    //  begin
        visibilityBtn.height := max(cy+5, icon_size);
        visibilityBtn.width  := cx+6;
        roster.DefaultNodeHeight := cy+2;
    //    for i in mainfrm.roster.
      end;
    menuBtn.left:=0;
    statusBtn.left:=menuBtn.boundsrect.right+1;
    visibilityBtn.left:=statusBtn.boundsrect.right+1;

    mainmenugetthemes1Click(nil);
    updateStatusGlyphs;
    roasterlib.rebuild;
{     menuBtn.Repaint;
     statusBtn.Invalidate;
     visibilityBtn.Invalidate;}
    FormResize(NIL);
  end;
statusIcon.ReDraw;
repaintAllWindows;
end; // applyTheme

procedure resetTheme;
begin
{theme.addProp('roaster', mainfrm.font);
theme.addProp('history.my', mainfrm.font);
theme.addProp('history.his', mainfrm.font);}
end; // resetTheme

procedure ResetThemePaths;
begin
  theme.ThemePath.pathType:= pt_zip;
  theme.ThemePath.fn:= 'RnQ.theme.rtz';
  theme.ThemePath.subfn := defaultThemePrefix + defaultThemePostfix;
  RQSmilesPath.pathType := pt_path;
  RQSmilesPath.fn:= '';
  RQSmilesPath.subfn := '';
  RQSoundsPath.pathType := pt_path;
  RQSoundsPath.fn:= '';
  RQSoundsPath.subfn := '';
end;


procedure ApplyThemeComponent(c : Tcontrol);
//var
// pe : TRnQThemedElementDtls;
begin
{if c is TSpeedButton then
  with TSpeedButton(c) do
   begin
     if HelpKeyword <> '' then
      begin
       Theme.getPic(HelpKeyword, Glyph);
       width := Glyph.Width+5;
      end;
   end;
}
if c is TRnQSpeedButton then
  with TRnQSpeedButton(c) do
   begin
     if ImageName <> '' then
      begin
       if Caption = '' then
        begin
         with theme.getPicSize(RQteButton, ImageName, icon_size) do
//         pe := ImageElm;
//         with theme.getPicSize(pe, 16) do
          begin
           TRnQSpeedButton(c).Height := max(cy, icon_size)+5;
           TRnQSpeedButton(c).width  := max(cx, icon_size)+6;
          end;
        end;
      end;
   end;

end;

procedure repaintAllWindows;

  procedure repaintRecur(c:Tcontrol);
  var
    i:integer;
  begin
    if c = NIL then Exit;
    if c is Twincontrol then
     with c as Twincontrol do
      for i:=controlCount-1 downto 0 do
       repaintRecur(controls[i]);
    ApplyThemeComponent(c);
    c.repaint;
  end; // repaintRecur

var
  i:integer;
begin
for i:=0 to Screen.FormCount-1 do
  repaintRecur(screen.forms[i]);
end;


procedure refreshMenuThemelist(menuItem : TMenuItem; StartIDX : byte; proc : TnotifyEvent);
var
  i : Integer;
  old, oldSub:string;
  bCh : Boolean;
begin
  for i := StartIDX to menuItem.Count - 1 do
    begin
     menuItem.Items[StartIDX].Destroy;
    end;
  old:=theme.ThemePath.fn;
  oldSub := theme.ThemePath.subfn;
  for i:=0 to length(theme.themelist2)-1 do
  begin
   bCh := ((theme.themelist2[i].fn = old)and(oldSub = theme.themelist2[i].subFile));
   with AddToMenu(menuItem, theme.themelist2[i].title,
//      StrUtils.IfThen(((themelist2[i].fn = old)and(oldSub = themelist2[i].subFile)), PIC_CHECKED, PIC_UNCHECKED)
      PIC_CHECK_UN[bCh],
      false,  proc) do
    begin
      Tag := i;
      if (Win32MajorVersion >=6) then
//        Checked := ImageName = PIC_CHECKED;
        Checked := bCh;
    end;
  end;
end;

procedure refreshMenuSmileslist(menuItem : TMenuItem; StartIDX : byte; proc : TnotifyEvent);
var
  i : Integer;
  old, oldSub:string;
  bCh : Boolean;
begin
  for i := StartIDX to menuItem.Count - 1 do
    begin
     menuItem.Items[StartIDX].Destroy;
    end;
  if length(theme.smileList) = 0 then
   Exit;
  old:=RQSmilesPath.fn;
  oldSub := RQSmilesPath.subfn;
{  with AddToMenu(menuItem, 'From theme',
      StrUtils.IfThen((('' = old)), PIC_CHECKED, PIC_UNCHECKED),
      false, proc) do
      begin
        Tag := -1;
        if (Win32MajorVersion >=6) then
          Checked := ImageName = PIC_CHECKED;
      end;
}
  for i:=0 to length(theme.smileList)-1 do
  begin
   bCh := ((theme.smileList[i].fn = old)and(oldSub = theme.smileList[i].subFile));
    with AddToMenu(menuItem, theme.smileList[i].title,
//      StrUtils.IfThen(((smileList[i].fn = old)and(oldSub = smileList[i].subFile)), PIC_CHECKED, PIC_UNCHECKED),
      PIC_CHECK_UN[bCh],
      false, proc) do
      begin
        Tag := i;
        if (Win32MajorVersion >=6) then
          Checked := bCh;
      end;
  end;
end;

procedure refreshMenuSoundslist(menuItem : TMenuItem; StartIDX : byte; proc : TnotifyEvent);
var
  i : Integer;
  old, oldSub:string;
  bCh : Boolean;
begin
  for i := StartIDX to menuItem.Count - 1 do
    begin
     menuItem.Items[StartIDX].Destroy;
    end;
  if length(theme.soundList) = 0 then
   Exit;
  old    := RQSoundsPath.fn;
  oldSub := RQSoundsPath.SubFN;
{  with AddToMenu(menuItem, 'From theme',
      StrUtils.IfThen((('' = old)), PIC_CHECKED, PIC_UNCHECKED),
      false, proc) do
      begin
        Tag := -1;
        if (Win32MajorVersion >=6) then
          Checked := ImageName = PIC_CHECKED;
      end;
}
  for i:=0 to length(theme.soundList)-1 do
  begin
   bCh := ((theme.soundList[i].fn = old)and(oldSub = theme.soundList[i].subFile));
    with AddToMenu(menuItem, theme.soundList[i].title,
//      StrUtils.IfThen(((soundList[i].fn = old)and(oldSub = soundList[i].subFile)), PIC_CHECKED, PIC_UNCHECKED),
      PIC_CHECK_UN[bCh],
      false, proc) do
      begin
        Tag := i;
        if (Win32MajorVersion >=6) then
          Checked := bCh;
      end;
  end;
end;


procedure SetContactsThemeUse(b : Boolean);
//var

begin
  if UseContactThemes <> b then
   begin
    if b then
      begin
        UseContactThemes := True;
        if not FileExists(AccPath + contactsthemeFilename) then
          Exit;
        if not Assigned(ContactsTheme) then
          ContactsTheme := TRQtheme.Create;
        ContactsTheme.load(AccPath + contactsthemeFilename, '', False);
        ContactsTheme.loadThemeScript(userthemeFilename, AccPath);
      end
     else
      begin
        if Assigned(ContactsTheme) then
          ContactsTheme.Free;
        ContactsTheme := NIL;
        UseContactThemes := false;
      end;
   end
{  else
   if b then
     if not Assigned(ContactThemes) then
      begin

      end;
}
end;

procedure reloadCurrentTheme();
begin
  Theme.load(theme.ThemePath.fn, theme.ThemePath.subfn);

   if (RQSmilesPath.fn > '')and FileExists(mypath+themesPath+RQSmilesPath.fn) then
     theme.load(RQSmilesPath.fn, RQSmilesPath.subfn, false, tsc_smiles)
    else
     begin
       RQSmilesPath.fn := '';
       RQSmilesPath.subfn := '';
     end;

   if (RQSoundsPath.fn > '')and FileExists(mypath+themesPath+RQSoundsPath.fn) then
     theme.load(RQSoundsPath.fn, RQSoundsPath.subfn, false, tsc_sounds)
    else
     begin
       RQSoundsPath.fn := '';
       RQSoundsPath.subfn := '';
     end;

  Theme.loadThemeScript(userthemeFilename, AccPath);
  if useContactThemes then
    begin
     if FileExists(AccPath + contactsthemeFilename) then
      begin
       if not Assigned(ContactsTheme) then
         ContactsTheme := TRQtheme.Create;
      end
     else
       FreeAndNil(ContactsTheme);
     if Assigned(ContactsTheme) then
      begin
       ContactsTheme.load(AccPath + contactsthemeFilename, '', false);
       ContactsTheme.loadThemeScript(userthemeFilename, AccPath);
      end;
   end;
  applyTheme;
end; // reloadCurrentTheme

end.

