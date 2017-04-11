{
  This file is part of R&Q.
  Under same license
}
unit RnQLangFrm;
{$I ForRnQConfig.inc}

{$I NoRTTI.inc}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, RnQButtons, Vcl.ExtCtrls,
  VirtualTrees, RnQLangs;

type
  TFrmLangs = class(TForm)
    LangsBox: TVirtualDrawTree;
    PnlBtn: TPanel;
    BtnOk: TRnQButton;
    BtnCncl: TRnQButton;
    procedure FormCreate(Sender: TObject);
    procedure LangsBoxFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure LangsBoxDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure LangsBoxFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure BtnOkClick(Sender: TObject);
    procedure LangsBoxDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SelectedLang: Integer;
  end;

function showLangsFrm(lngs: aLangInfo): Integer;

//var
//  FrmLangs: TFrmLangs;

implementation

{$R *.dfm}

type
  PRnQLang = ^TRnQLang;
  TRnQLang = record
     path, fn: string;
     desc: String;
     utf: Boolean;
     idx: Integer;
   end;

function showLangsFrm(lngs: aLangInfo): Integer;
var
  i: Integer;
  n: PVirtualNode;
  FrmLangs: TFrmLangs;
  lr: PRnQLang;

begin
  if Length(lngs) <= 1 then
    begin
      Result := Length(lngs) - 1;
      Exit;
    end;
  FrmLangs := TFrmLangs.Create(nil);
  FrmLangs.LangsBox.NodeDataSize := SizeOf(TRnQLang);

    begin
      n := FrmLangs.LangsBox.AddChild(nil);
      lr := FrmLangs.LangsBox.GetNodeData(n);
      lr^.desc := 'Original (English)';
      lr^.path := '';
      lr^.fn   := '';
      lr^.idx  := -5;
      lr^.utf  := True;
    end;

  for I := 0 to Length(lngs)-1 do
    begin
      n := FrmLangs.LangsBox.AddChild(nil);
      lr := FrmLangs.LangsBox.GetNodeData(n);
      lr^.path := lngs[i].fn;
      lr^.desc := lngs[i].desc;
      lr^.fn   := lngs[i].subFile;
//      lr^.utf  := lngs[i].isUTF;
      lr^.idx  := i;
    end;
  FrmLangs.ShowModal;
  if FrmLangs.ModalResult = mrOk then
    Result := FrmLangs.SelectedLang
   else
    Result := -1;
  FrmLangs.Free;
end;

procedure TFrmLangs.BtnOkClick(Sender: TObject);
begin
  if LangsBox.FocusedNode <> NIL then
//    SelectedLang := LangsBox.FocusedNode.Index
    SelectedLang := TRnQLang(PRnQLang(LangsBox.GetNodeData(LangsBox.FocusedNode))^).idx
   else
    SelectedLang := -1;
end;

procedure TFrmLangs.FormCreate(Sender: TObject);
begin
  SelectedLang := -1;
end;

procedure TFrmLangs.LangsBoxDblClick(Sender: TObject);
begin
  BtnOkClick(Sender);
  ModalResult := mrOk;
end;

procedure TFrmLangs.LangsBoxDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  s: String;
  x: Integer;
//  cr: Boolean;
begin
  with TRnQLang(PRnQLang(LangsBox.GetNodeData(PaintInfo.Node))^) do
   begin
    s := '';
    if desc > '' then
    begin
      s := desc + ' ';
      if (path > '') or (fn > '') then
        s := s + '( ';
    end;

    s := s + path;
    if fn > '' then
      s := s + ' \\ ' + fn;

    if (desc > '') and ((path > '') or (fn > '')) then
      s := s + ' )';
   end;
  PaintInfo.Canvas.Font.Assign(Application.DefaultFont);
  if vsSelected in PaintInfo.Node.States then
   begin
    if Sender.Focused then
      PaintInfo.Canvas.Font.Color := clHighlightText
    else
      PaintInfo.Canvas.Font.Color := clWindowText;
   end
  else
    PaintInfo.Canvas.Font.Color := clWindowText;
  x := PaintInfo.ContentRect.Left;
//  inc(x, theme.drawPic(PaintInfo.Canvas, PaintInfo.ContentRect.Left +3, 0,
//         TlogItem(PLogItem(LogList.getnodedata(PaintInfo.Node)^)^).Img).cx+6);
  SetBkMode(PaintInfo.Canvas.Handle, TRANSPARENT);
//  PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left + x, 2, s);
  PaintInfo.Canvas.textout(x, 2, s);
end;

procedure TFrmLangs.LangsBoxFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  BtnOk.enabled := LangsBox.FocusedNode <> NIL
end;

procedure TFrmLangs.LangsBoxFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
   with TRnQLang(PRnQLang(LangsBox.GetNodeData(Node))^) do
    begin
     SetLength(path, 0);
     SetLength(fn, 0);
     SetLength(desc, 0);
    end;
end;

end.
