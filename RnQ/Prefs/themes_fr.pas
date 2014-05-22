unit themes_fr;

interface
{$I Compilers.inc}
{$I RnQConfig.inc}

 {$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
 {$ENDIF COMPILER_14_UP}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, utilLib, globalLib, RQThemes, RQGlobal, RnQButtons;

type
  TthemesFr = class(TPrefFrame)
    themeBox: TComboBox;
    descBox: TMemo;
    logoImg: TImage;
    refreshBtn: TRnQSpeedButton;
    procedure refreshBtnClick(Sender: TObject);
    procedure themeBoxSelect(Sender: TObject);
  public
//    function  current:Pthemeinfo;
    function  current:ToThemeinfo;
    procedure select(fn:string);
    procedure initPage; Override;
    procedure applyPage; Override;
    procedure resetPage; Override;
    procedure updateVisPage; Override;
  end;

implementation
uses
  RQUtil;

{$R *.dfm}

function TthemesFr.current:ToThemeinfo;
begin
with themeBox do
  if (Items.Count = 0) or (itemIndex<0) or (itemIndex > Items.Count) then
    result:=NIL
  else
    result:=ToThemeinfo(Items.Objects[itemIndex])
end;

procedure TthemesFr.select(fn:string);
var
  i:integer;
begin
  if Length(themelist2)>0 then
  for i:=0 to length(themelist2)-1 do
   if themelist2[i].fn=fn then
    begin
     themeBox.itemindex:=i;
     exit;
    end;
end;

procedure TthemesFr.refreshBtnClick(Sender: TObject);
var
  i,idx:integer;
  old:string;
begin
if current=NIL then
  old:=theme.fn
else
  old:=current.fn;
refreshThemelist;
themeBox.Clear;
for i:=0 to length(themelist2)-1 do
  begin
  idx:=themeBox.Items.addObject(themelist2[i].title, themelist2[i]);
  if themelist2[i].fn = old then
    themeBox.ItemIndex:=idx;
  end;
if themeBox.ItemIndex < 0 then
  themeBox.ItemIndex:=0;
themeBoxSelect(NIL);
end;

procedure TthemesFr.themeBoxSelect(Sender: TObject);
begin
if current=NIL then exit;
descBox.Text:=current.desc;
if (current.logo = '') or (not FileExists(myPath+themesPath+current.logo)) then
  logoImg.Height:=0
else
 begin
  loadPic(myPath+themesPath+current.logo, logoImg);
  logoImg.Height := logoImg.Picture.Height;
 end;
end;

procedure TthemesFr.applyPage;
begin
  if theme.fn<>current.fn then
    begin
      theme.fn:=current.fn;
      reloadCurrentTheme;
    end;
end;

procedure TthemesFr.resetPage;
begin
  select(theme.fn);
end;

procedure TthemesFr.updateVisPage;
begin
end;

procedure TthemesFr.initPage;
begin
//  theme.getPic(PIC_REFRESH, refreshBtn.glyph);
  refreshBtnClick(NIL);
end;


INITIALIZATION

  AddPrefPage(125, TthemesFr, 'Themes');
end.

