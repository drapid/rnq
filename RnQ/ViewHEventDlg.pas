{
This file is part of R&Q.
Under same license
}
unit ViewHEventDlg;

interface
{$I Compilers.inc}
{$I RnQConfig.inc}
{$I NoRTTI.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, vcl.ComCtrls, Winapi.CommCtrl,
  RnQGraphics32, Vcl.ExtCtrls, Vcl.Menus;

type
   TImgRec = record
      bytes: RawByteString;
      ff: TPAFormat;
      img: TRnQBitmap;
    end;
type
  THEventFrm = class(TForm)
    PageCtl: TPageControl;
    imgmenu: TPopupMenu;
    savePicMnuImg: TMenuItem;
    procedure savePicMnuImgClick(Sender: TObject);
  private
    { Private declarations }
    imgs: array of TImgRec; //RawByteString;
    StartX, StartY: Integer;
    procedure ImgPaint(Sender: TObject);
  public
    { Public declarations }
    procedure onCloseSomeWindows(Sender: TObject; var Action: TCloseAction);
    procedure previewFormKeyPress(Sender: TObject; var Key: Char);
    procedure imgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

//var
//  Form1: TForm1;
  function  viewTextWindow(const title, body: string; const bin: RawByteString = ''): Tform;

implementation

{$R *.dfm}
uses
   Base64,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
   System.UITypes, StrUtils, RnQLangs, RnQSysUtils, RDFileUtil,
   globalLib, utilLib, langLib;

function viewTextWindow(const title, body: string; const bin: RawByteString = ''): Tform;
var
  form: THEventFrm;
  memo: Tmemo;
{
  img: TImageEx;
  ff: TPAFormat;
  png: TPNGImage;
  winimg: TWICImage;
  bmp: TBitmap;
  gif: TGIFImage;
  // rnqbmp: TRnQBitmap;
  pic: IPicture;
  a, b: integer;
  h, w: integer;
  r: Trect;
  // NonAnimated: Boolean;
  imgList: TStringList;
  imgtag: RawByteString;
}
  pagetab: TTabSheet;
//  imgs : array of TImgRec;
  img64 : RawByteString;
  imgcnt, pos1, pos2: integer;
  ofs : Integer;
  i,  j: integer;
  scroll: TScrollBox;
  PIn, POut: Pointer;
  RnQPicStream: TMemoryStream;
  OutSize: Cardinal;
//  img: TImage;
  imgp : TPaintBox;
  bmp : TRnQBitmap;
begin
  form:= THEventFrm.create(Application.MainForm);
  result:=form;
  form.caption:=title;
  form.position:=poDefaultPosOnly;

  if (trim(body) <> '') then
  begin
    pagetab := TTabSheet.Create(form.PageCtl);
    pagetab.Caption := getTranslation('message');
    pagetab.PageControl := form.pagectl;
    pagetab.BorderWidth := 0;
    pagetab.ControlStyle := pagetab.ControlStyle + [csOpaque];

    memo := Tmemo.Create(pagetab);
    memo.parent := pagetab;
    memo.text:=body;
    memo.align:=alClient;
    memo.WordWrap:= bViewTextWrap;
    memo.borderstyle := bsNone;
    if memo.WordWrap then
      memo.ScrollBars:=ssVertical
     else
      memo.ScrollBars:=ssBoth;
//  form.InsertControl(memo);
    memo.OnKeyDown := form.MemoKeyDown;
  end;

  if (trim(bin) <> '') then
  begin
//    imgList := TStringList.Create;
    ofs := 1;
    repeat
      pos1 := PosEx(RnQImageTag, bin, ofs);
      if (pos1 > 0) then
      begin
        pos2 := PosEx(RnQImageUnTag, bin, pos1 + length(RnQImageTag));
        if pos2 > 0  then
          begin
           imgcnt := length(form.imgs);
           SetLength(form.imgs, imgcnt+1);
           form.imgs[imgcnt].bytes := Copy(bin, pos1 + length(RnQImageTag), pos2 - (pos1 + length(RnQImageTag)));
          end;
        ofs := pos2 + length(RnQImageUnTag);
      end
      else
        break;
    until pos1 <= 0;

    repeat
      pos1 := PosEx(RnQImageExTag, bin, ofs);
      if (pos1 > 0) then
      begin
        pos2 := PosEx(RnQImageExUnTag, bin, pos1 + length(RnQImageExTag));
        if pos2 > 0  then
          begin
            imgcnt := length(form.imgs);
            SetLength(form.imgs, imgcnt+1);
            img64 := Copy(bin, pos1 + length(RnQImageExTag), pos2 - (pos1 + length(RnQImageExTag)));
            PIn := @img64[1];
            OutSize := CalcDecodedSize(PIn, length(img64));
            SetLength(form.imgs[imgcnt].bytes, OutSize);
            POut := @form.imgs[imgcnt].bytes[1];
            Base64Decode(PIn^, length(img64), POut^);
          end;
        ofs := pos2 + length(RnQImageExUnTag);
      end
      else
        break;
    until pos1 <= 0;

    for imgcnt := 0 to Length(form.imgs) - 1 do
    begin
      RnQPicStream := TMemoryStream.Create;
      RnQPicStream.SetSize(Length(form.imgs[imgcnt].bytes));
      CopyMemory(RnQPicStream.Memory, @form.imgs[imgcnt].bytes[1], Length(form.imgs[imgcnt].bytes));

      form.imgs[imgcnt].img := NIL;
      form.imgs[imgcnt].ff := DetectFileFormatStream(RnQPicStream);
      RnQPicStream.Seek(0, soFromBeginning);

      if loadPic(TStream(RnQPicStream), bmp) then
      begin
        form.imgs[imgcnt].img := bmp;
        bmp := NIL;
        pagetab := TTabSheet.Create(form.pagectl);
        pagetab.PageControl := form.pagectl;
        pagetab.BorderWidth := 0;
        pagetab.ControlStyle := pagetab.ControlStyle + [csOpaque];

        j := form.pagectl.PageCount - 1;
        pagetab.name := 'pagetab' + IntToStr(j);

        scroll := TScrollBox.Create(pagetab);
        scroll.Align := alClient;
        scroll.parent := pagetab;
        scroll.HorzScrollBar.Smooth := True;
        scroll.HorzScrollBar.Tracking := True;
        scroll.VertScrollBar.Smooth := True;
        scroll.VertScrollBar.Tracking := True;
        scroll.DoubleBuffered := True;
        scroll.borderstyle := bsNone;
        scroll.name := 'scroll' + IntToStr(j);


        imgp := TPaintBox.Create(scroll);
        imgp.parent := scroll;
        imgp.OnMouseDown := form.imgMouseDown;
        imgp.OnMouseMove := form.imgMouseMove;
        imgp.name := 'image' + IntToStr(j);
        imgp.PopupMenu := form.imgmenu;
        imgp.Tag := imgcnt;
        imgp.OnPaint := form.ImgPaint;
        imgp.Width := form.imgs[imgcnt].img.Width;
        imgp.Height := form.imgs[imgcnt].img.Height;
      end;
      FreeAndNil(RnQPicStream);
    end;
  end;

  if (form.pagectl.PageCount = 1) then
  begin
    form.pagectl.Pages[0].TabVisible := False;
    form.pagectl.Pages[0].Visible := True;
  end;

  form.OnClose := form.onCloseSomeWindows;
  with desktopworkarea do
    begin
      form.width:=(right-left) div 2;
      form.height:=(bottom-top) div 2;
    end;
  applyCommonsettings(form);
  translateWindow(form);
  applyTaskButton(form);
  form.OnKeyPress := form.previewFormKeyPress;
  form.KeyPreview := True;
  form.show;
end; // viewTextWindow


procedure THEventFrm.onCloseSomeWindows(Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
  // if sender is TForm then
  Action := caFree;
end;

procedure THEventFrm.previewFormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #27:
      begin
        (Sender as TForm).close;
        Key := #0;
      end;
  end;
end;

procedure THEventFrm.imgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  StartX := X;
  StartY := Y;
end;

procedure THEventFrm.imgMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var ShfX, ShfY: Integer; ks: TKeyBoardState;
  vertScroll, horizScroll: TControlScrollBar;
//  img: TImage;
  imgp: TPaintBox;
begin
  imgp := Sender as TPaintBox;
  vertScroll := (imgp.parent as TScrollBox).VertScrollBar;
  horizScroll := (imgp.parent as TScrollBox).HorzScrollBar;

  if (vertScroll.IsScrollBarVisible) or (horizScroll.IsScrollBarVisible) then
  begin
    imgp.Cursor := crSizeAll;
    imgp.DragCursor := crSizeAll;
  end
  else
  begin
    imgp.Cursor := crDefault;
    imgp.DragCursor := crDefault;
  end;

  GetKeyBoardState(ks);
  if ks[VK_LBUTTON] >= 128 then
  begin
    ShfY := StartY - Y;
    ShfX := StartX - X;

    vertScroll.Position := vertScroll.Position + ShfY;
    horizScroll.Position := horizScroll.Position + ShfX;
  end;
end;

procedure THEventFrm.ImgPaint(Sender: TObject);
var
  cnv:Tcanvas;
begin
  cnv:=(Sender as TPaintBox).Canvas;
  cnv.Font.Assign(Screen.MenuFont);
  imgs[(Sender as TPaintBox).Tag].img.Draw(cnv.Handle, 0, 0);
end;

procedure THEventFrm.MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Sender is TMemo) then
  begin
    if (Key = $41) and (ssCtrl in Shift) then
      TMemo(Sender).SelectAll
  end
  else
    Inherited;
end;

procedure THEventFrm.savePicMnuImgClick(Sender: TObject);
var
  fl, ext: String;
  imgIdx: Integer;
//  img: TImageEx;
begin
  ext := '';
  imgIdx := ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent.Tag;
  if imgIdx < Length(imgs) then
    ext := PAFormat[imgs[imgIdx].ff];

  if (ext <> '') then
    fl := openSavedlg(self, '', False, ReplaceStr(ext, '.', ''));

  if not(fl = '') and (imgs[imgIdx].bytes > '') then
    saveFile2(fl, imgs[imgIdx].bytes);
end;

end.
