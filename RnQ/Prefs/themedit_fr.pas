{
This file is part of R&Q.
Under same license
}
unit themedit_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ToolWin, ComCtrls, RnQButtons,
  RDGlobal, RQUtil, RQThemes, RnQDialogs, RnQSpin, RnQPrefsLib;

type
  TthemeditFr = class(TPrefFrame)
    sizeSpin: TRnQSpinEdit;
    sizeLbl: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    stringBox: TMemo;
    propsBox: TComboBox;
    textBox: TMemo;
    fontLbl: TLabel;
    MPlayerBar: TToolBar;
    PlayBtn: TRnQSpeedButton;
    ColorBtn: TColorPickerButton;
    fnBox: TEdit;
    fnBoxButton: TRnQSpeedButton;
    FontBox: TEdit;
    FontBoxButton: TRnQSpeedButton;
    ImgPBox: TPaintBox;
    addBtn: TRnQButton;
    procedure ColorBtnChange(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure propsBoxChange(Sender: TObject);
    procedure addBtnClick(Sender: TObject);
    procedure fileBox11Change(Sender: TObject);
    procedure setupGUI;
    procedure updateGUI;
    procedure fontBox11Change(Sender: TObject);
    procedure FontBoxButtonClick(Sender: TObject);
    procedure fnBoxButtonClick(Sender: TObject);
    procedure propsBoxKeyPress(Sender: TObject; var Key: Char);
    procedure ImgPBoxPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
   protected
    haveToApplyTheme : Boolean;
    fImgElm : TRnQThemedElementDtls;
//    img_PicLoc : TPicLocation;
//    img_themetkn : Integer;
//    img_idx : Integer;
    themeprops : aTthemeproperty;
    Sound_FileName : String;
   public
    procedure applyPage; Override; final;
    procedure resetPage; Override; final;
    procedure initPage; Override; final;
    procedure unInitPage; Override; final;

//    procedure applyPage;
//    procedure resetPage;
  end;

implementation

uses
  Types, RDFileUtil, RDUtils,
  utilLib, prefDlg, globalLib, themesLib
  ;

{$R *.dfm}

procedure TthemeditFr.setupGUI;
const
  gap=15;
var
  p:^Tthemeproperty;
  y:integer;
  s : String;
//  f: TFont;
begin
if propsBox.itemIndex<0 then
 begin
  fontBox.visible:= false;
  FontBoxButton.visible:= false;
  sizeSpin.visible:= false;
  sizeLbl.visible:= false;
  fontLbl.visible:= false;
  ColorBtn.Visible := false;
  fnBox.Visible := false;
  fnBoxButton.Visible := false;
  MPlayerBar.Visible := false;
  exit;
 end;
p:=@themeprops[propsBox.itemIndex];
//f := TFont
case p.kind of
  TP_color: colorBtn.SelectionColor:=theme.GetColor(copy(p.name, 1, length(p.name)-6));
  TP_font:
     begin
      fontBox.Font.Assign(Screen.MenuFont);
      s := copy(p.name, 1, length(p.name)-5);
      theme.ApplyFont(s, fontBox.Font);
//    with f do
      begin
       colorBtn.SelectionColor:= fontBox.Font.color;
       fontBox.Text := fontBox.Font.name;//findInStrings(name, fontBox.items);
//      fontBox.Font := f;
       sizeSpin.Value:=fontBox.Font.size;
      end; end;
  TP_pic, TP_ico:
     begin
       fImgElm.picName := p.name;
       with theme.GetPicSize(fImgElm) do
        begin
          fImgElm.ThemeToken := -1;
         ImgPBox.Width := cx;
         ImgPBox.Height := cy;
        end;
       ImgPBox.Repaint;
//       img.Refresh;
     end;
//   assignImgPic(img.Picture.Bitmap, p.name);
//  TP_ico: assignImgIco(img,theme.GetIco(p.name));
//  TP_ico: assignImgPic(img, p.name);
//  TP_string: stringBox.text:=string(p.ptr^);
  TP_sound:
    begin
//    Sound_FileName:= '';
    Sound_FileName:=theme.GetSound(p.name);
    fnBox.Text:=Sound_FileName;
//    try mplayer.open except end;
    end;
  TP_string:
    begin
    stringBox.Text:=theme.GetString(p.name);
//    try mplayer.open except end;
    end;
  end;
y:=propsBox.BoundsRect.Bottom+gap;
colorBtn.visible:= p.kind in [TP_color,TP_font];
if colorBtn.visible then
  begin
  colorBtn.top:=y;
  inc(y, colorBtn.height+gap);
  end;
fontBox.visible:= p.kind=TP_font;
FontBoxButton.visible:= fontBox.Visible;
sizeSpin.visible:= p.kind=TP_font;
sizeLbl.visible:= p.kind=TP_font;
fontLbl.visible:= p.kind=TP_font;
if fontBox.visible then
  begin
  fontBox.top:=y;
  FontBoxButton.top:=y;
  sizeSpin.top:=y;
  sizeLbl.top:=y;
  inc(y, fontBox.height+gap);
  FontBoxButton.height := fontBox.height;
  fontLbl.Top:=y;
  inc(y, 150+gap);
  end;
ImgPBox.visible:= p.kind in [TP_pic,TP_ico];
if ImgPBox.visible then
  begin
  ImgPBox.top:=y;
  ImgPBox.Height := Self.Height - ImgPBox.Top - gap;
  inc(y, ImgPBox.height+gap);
  end;
stringBox.visible:= p.kind=TP_string;
if stringBox.visible then
  begin
  stringBox.top:=y;
  inc(y, stringBox.height+gap);
  end;
fnBox.visible:= p.kind=TP_sound;
fnBoxButton.visible:= fnBox.visible;
if fnBox.visible then
  begin
  fnBox.top:=y;  fnBoxButton.top:=y;
  inc(y, fnbox.height+gap);
  fnBoxButton.Height := fnBox.Height;
  end;
MPlayerBar.visible:= p.kind=TP_sound;
if MPlayerBar.visible then
  begin
  MPlayerBar.top:=y;
  //inc(y, mplayer.height+gap);
  end;

updateGUI;
end; // setupGUI

procedure TthemeditFr.updateGUI;
begin
  fontLbl.Font := fontBox.Font;
//  fontLbl.Font.name  := fontBox.Text;
//  fontLbl.font.size  := sizeSpin.AsInteger;
//  fontLbl.font.color :=colorBtn.SelectionColor;
//  fontLbl.Font.Charset :=
end; // updateGUI

procedure TthemeditFr.propsBoxChange(Sender: TObject);
begin setupGUI end;

procedure TthemeditFr.propsBoxKeyPress(Sender: TObject; var Key: Char);
begin
  setupGUI;
end;

procedure TthemeditFr.addBtnClick(Sender: TObject);
var
  p:^Tthemeproperty;
  s,line:string;
  lastsection:string;
  color:Tcolor;
  bak:Tpoint;
  chrst : String;
begin
bak:=textBox.caretpos;
// find the last section
s:=textBox.text;
while s>'' do
  begin
  line:=trim(chopline(s));
  if (line>'') and (line[1]='[') and (line[length(line)]=']') then
    lastsection:=line;
  end;
lastsection:=copy(lastsection,2,length(lastsection)-2);

s:=textBox.text+CRLF;
p:=@themeprops[propsBox.itemIndex];
if lastsection<>p.section then
  s:=s+'['+p.section+']'+CRLF;
color:=colorBtn.SelectionColor;
case p.kind of
  TP_color: s:=s+p.name+'='+color2str(color);
  TP_font:
   begin
    s:=s+
    p.name+'.color='+color2str(color)+CRLF+
    p.name+'.size='+intToStr(trunc(sizeSpin.value))+CRLF+
    p.name+'.name='+fontbox.text;
    if CharsetToIdent(FontBox.Font.Charset, chrst) then
     s := s+CRLF+p.name+'.charset='+ chrst;
    if fontstyle2str(FontBox.Font.Style) > '' then
     s:=s+CRLF+ p.name + '.style=' +fontstyle2str(FontBox.Font.Style);
   end;
  TP_sound: s:=s+p.name+'='+fnBox.text;
  TP_string: s:=s+p.name+'=' + newline2slashn(stringBox.text);
  end;
textBox.text:=s;
textBox.caretpos:=bak;
textBox.Modified:=TRUE;
end;

procedure TthemeditFr.fileBox11Change(Sender: TObject);
begin
  Sound_FileName:=fnbox.text;
end;

procedure TthemeditFr.fontBox11Change(Sender: TObject);
begin updateGUI end;

procedure TthemeditFr.fnBoxButtonClick(Sender: TObject);
var
  fn : String;
begin
  fn := openSavedlg(prefFrm, '', True, '', '', fnBox.Text);
  if fn > '' then
    fnBox.Text := fn;
end;

procedure TthemeditFr.ImgPBoxPaint(Sender: TObject);
var
  p:^Tthemeproperty;
begin
  if propsBox.itemIndex<0 then Exit;
  p:=@themeprops[propsBox.itemIndex];
  if p.kind in [TP_pic, TP_ico, TP_smile] then
   theme.drawPic(TPaintBox(Sender).Canvas.Handle, 0,0, p.name);
end;

procedure TthemeditFr.InitPage;
var
  i:integer;
begin
  propsBox.items.clear();
  Theme.getprops(themeprops);
  for i:=0 to length(themeprops)-1 do
    propsBox.items.add(format('[%s] %s',[themeprops[i].section,themeprops[i].name]));

 propsBox.itemIndex:=0;
 propsBoxChange(self);
end;
procedure TthemeditFr.unInitPage;
begin
  ImgPBox.Visible := False;
  SetLength(themeprops, 0);
  SetLength(Sound_FileName, 0);
end;

procedure TthemeditFr.applyPage;
begin
// if prefPages[thisPrefIdx].frame = NIL then exit;
  if textBox.Modified then
    begin
      savefile2(AccPath+userthemeFilename, textBox.text);
      reloadCurrentTheme;
    end;
end;

procedure TthemeditFr.resetPage;
begin
  textBox.text:=loadfileA(AccPath+userthemeFilename);
end;

procedure TthemeditFr.FontBoxButtonClick(Sender: TObject);
var
  vF : TFont;
begin
  vF := TFont.Create;
  vf := FontBox.Font;
  if ChooseFontDlg(self.ParentWindow, 'Choose font', vF) then
//  if FontBoxDialog.Execute then
   begin
    FontBox.Text := vF.Name;
    FontBox.Font := vF;
    sizeSpin.Value := FontBox.Font.Size;
    colorBtn.SelectionColor := FontBox.Font.Color;
    updateGUI
   end;
end;

procedure TthemeditFr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 SetLength(themeprops, 0);
end;

procedure TthemeditFr.PlayBtnClick(Sender: TObject);
begin
  try SoundPlay(Sound_FileName); except end;
end;

procedure TthemeditFr.ColorBtnChange(Sender: TObject);
begin
  FontBox.Font.Color := colorBtn.SelectionColor;
  updateGUI
end;

end.
