unit uIconStream;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
   {$IFDEF FPC}
     JwaWinGDI,
   {$ENDIF}
   Windows, Classes, Types, Graphics, SysUtils,
  {$IFNDEF FPC}
   UITypes,
  {$ENDIF}
   Dialogs;

type
  PColor32 = ^TColor32;
 {$IFDEF FPC}
  TColor32 = packed record
   case boolean of
    True:
      (B,R,G,A: Byte);
//      (B,G,R,A: Byte);
    false:
      (color : Cardinal);
//   end;
  end;
 {$ELSE ~FPC}
  TColor32 = TAlphaColorRec;
 {$ENDIF}
  PColor32Array = ^TColor32Array;
  TColor32Array = array [0..MaxInt div SizeOf(TColor32) - 1] of TColor32;


  PColor24 = ^TColor24;

  TColor24= packed record
    B,R,G: Byte;
  end;
  PColor24Array = ^TColor24Array;
  TColor24Array = array [0..MaxInt div SizeOf(TColor24) - 1] of TColor24;

  PIconDirEntry = ^TIconDirEntry;
  TIconDirEntry = packed record
    bWidth: Byte;
    bHeight: Byte;
    bColorCount: Byte;
    bReserved: Byte;
    wPlanes: Word;
    wBitCount: Word;
    dwBytesInRes: Longint;
    dwImageOffset: Longint;
  end;

  PIconHeader = ^TIconHeader;
  TIconHeader = packed record
    idReserved: Word;
    idType: Word;
    idCount: Word;
  end;

  LPRESDIR = ^RESDIR;
  RESDIR = packed record
    bWidth: Byte;
    bHeight: Byte;
    bColorCount: Byte;
    bReserved: Byte;
    wPlanes: Word;
    wBitCount: Word;
    dwBytesInRes: Longint;
    IconCursorId: Word;
  end;


  TMaskBitmapInfo = packed record
    Header: TBitmapInfoHeader;
    Black,
    White: TRGBQuad;
  end;

  TIconStream = class(TObject)
  private
    FData: TMemoryStream;
    FNames: TStringList;
    FIconType: Integer;
    function GetCount: Integer;
    function GetIsIcon: Boolean;
    function GetFrame(Index: Integer): TIconDirEntry;
    function GetHeader(Index: Integer): TBitmapInfoHeader;
    function GetHotspot(Index: Integer): TPoint;
    function GetName(Index: Integer): String;
    procedure SaveMultiToStream(Stream: TStream; Count: Integer);
  protected
    function CheckIconFormat: Integer;
    procedure LoadNames(FileName: string); overload;
    procedure LoadNames(Stream: TStream); overload;
  public
    //------------------------------------------------------------------------//
    constructor Create;
    destructor  Destroy; override;
    //------------------------------------------------------------------------//
    procedure Clear;
    function  Size: Integer;
    //------------------------------------------------------------------------//
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
    //------------------------------------------------------------------------//
    procedure SaveToFile(const FileName: string; Index: Integer);
    procedure SaveToStream(Stream: TStream; Index: Integer);
    //------------------------------------------------------------------------//
    property Count: Integer read GetCount;
    property IsIcon: Boolean read GetIsIcon;
    //------------------------------------------------------------------------//
    property Frame[Index: Integer]: TIconDirEntry read GetFrame; default;
    property Header[Index: Integer]: TBitmapInfoHeader read GetHeader;
    property Hotspot[Index: Integer]: TPoint read GetHotspot;
    property Name[Index: Integer]: String  read GetName;
    //------------------------------------------------------------------------//
    procedure Draw(DC: HDC; DX, DY: Integer; Index: Integer; AlphaMode: Integer = 1);

    function getBestFrameIdx : Integer;
  end;
implementation

//----------------------------------------------------------------------------//
//                                TIconStream                                 //
//----------------------------------------------------------------------------//
constructor TIconStream.Create;
begin
  FData:= TMemoryStream.Create;
  FData.Size:= 0;
  FNames:= TStringList.Create;

end;

destructor TIconStream.Destroy;
begin
  FData.Clear;
  FData.Free;
  FNames.Clear;
  FNames.Free;
  inherited;
end;
//----------------------------------------------------------------------------//
function TIconStream.CheckIconFormat: Integer;
var
  IH: TIconHeader;
begin
  Result:= -1;

  if FData.Size = 0 then Exit;

  FData.Seek(0,soFromBeginning);
  FData.Read(IH, SizeOf(TIconHeader));

  if IH.idReserved <> 0 then Exit;

  FIconType:= -1;
  FIconType:= IH.idType;

  if (FIconType = 1) or (FIconType = 2) then
    Result:= FIconType;
end;


procedure TIconStream.LoadFromFile(const FileName: string);
begin
  FData.Clear;
  FData.LoadFromFile(FileName);

  LoadNames(FileName);

  if CheckIconFormat = -1 then Clear;
end;

procedure TIconStream.LoadFromStream(Stream: TStream);
begin
  FData.Clear;
  FData.LoadFromStream(Stream);

  LoadNames(Stream);

  if CheckIconFormat = -1 then Clear;
end;
//----------------------------------------------------------------------------//
procedure TIconStream.SaveToFile(const FileName: string; Index: Integer);
var
  Stream: TFileStream;
  hFile: Text;
  S: String;
  I: Integer;
begin
  Stream:= TFileStream.Create(FileName, fmCreate);
  //SaveToStream(Stream, Index);
  SaveMultiToStream(Stream, 170);
  Stream.Free;

  {$I-}
  AssignFile(hFile, PChar(FileName+'.xml'));
  {$I+}
  Rewrite(hFile);

  S:= '<?xml version="1.0" encoding="Windows-1251"?>';
  WriteLn(hFile, S);

  S:= '<DATA>';
  WriteLn(hFile, S);

  for I:= 0 to  Count-1 do
  begin
    S:= Format('<item name="%s" index="%d"/>', [FNames[I], I]);
    WriteLn(hFile, S);
  end;

  S:= '</DATA>';
  WriteLn(hFile, S);

  CloseFile(hFile);
end;

procedure TIconStream.SaveToStream(Stream: TStream; Index: Integer);
var
  Offset, iNumberColor, iRgbTable: Integer;

  IH:  TIconHeader;
  IDE: TIconDirEntry;

  iXOR: PBitmapInfo;

  iXORSize, pANDSize, pXORSize : Integer;
  pXOR, pAND: Pointer;

  HasPalette: Boolean;
begin
  if Stream = nil  then Exit;

  Stream.Position:= 0;

  Offset:= GetFrame(Index).dwImageOffset;
  FData.Seek(Offset, soFromBeginning);

  GetMem(iXOR, SizeOf(TBitmapInfoHeader));
  FData.Read(iXOR^,SizeOf(TBitmapInfoHeader));

  iNumberColor := 1 shl iXOR.bmiHeader.biBitCount;
  HasPalette   := iXOR.bmiHeader.biBitCount in [1,4,8];

  if HasPalette then
  begin
    iRgbTable := sizeof(RGBQUAD) * iNumberColor;

    ReallocMem(iXOR,SizeOf(TBitmapInfoHeader) + iRgbTable);
    FData.Read(iXOR.bmiColors,iRgbTable);
    iXORSize:= SizeOf(TBitmapInfoHeader) + iRgbTable;
  end
  else
  begin
    iXORSize:= SizeOf(TBitmapInfoHeader);
  end;  

  iXOR.bmiHeader.biHeight:= iXOR.bmiHeader.biHeight shr 1;

  pXORSize:= ((iXOR.bmiHeader.biWidth*iXOR.bmiHeader.biBitCount+31)shr 5)shl 2 * iXOR.bmiHeader.biHeight;
  pANDSize:= ((iXOR.bmiHeader.biWidth+31)shr 5)shl 2 * iXOR.bmiHeader.biHeight;

  GetMem(pXOR,pXORSize);
  FData.Read(pXOR^,pXORSize);

  GetMem(pAND,pANDSize);
  FData.Read(pAND^,pANDSize);

  IH.idReserved := 0;
  IH.idType     := 1;
  IH.idCount    := 1;

  IDE.bWidth := iXOR.bmiHeader.biWidth;
  IDE.bHeight:= iXOR.bmiHeader.biHeight;
  
  if iXOR.bmiHeader.biBitCount <= 8 then
    IDE.bColorCount := iNumberColor
  else
    IDE.bColorCount := 0;

  IDE.bReserved    := 0;
  IDE.wPlanes      := 1;
  IDE.wBitCount    := iXOR.bmiHeader.biBitCount;
  IDE.dwBytesInRes := iXORSize + pXORSize + pANDSize;
  IDE.dwImageOffset:= 22;

  Stream.Write(IH,SizeOf(TIconHeader));
  Stream.Write(IDE,SizeOf(TIconDirEntry));

  iXOR.bmiHeader.biHeight:= iXOR.bmiHeader.biHeight shl 1;
  Stream.Write(iXOR^, iXORSize);
  iXOR.bmiHeader.biHeight:= iXOR.bmiHeader.biHeight shr 1;

  Stream.Write(pXOR^, pXORSize);
  Stream.Write(pAND^, pANDSize);

  FreeMem(pXOR);
  FreeMem(pAND);
  FreeMem(iXOR);
end;

//----------------------------------------------------------------------------//
function TIconStream.Size: Integer;
begin
  Result:= FData.Size;
end;

procedure TIconStream.Clear;
begin
  FData.Clear;
  FData.Size:= 0;
  FNames.Clear;
end;
//----------------------------------------------------------------------------//
function TIconStream.GetCount: Integer;
var
  IH: TIconHeader;
begin
  Result:= -1;

  if FData.Size = 0 then Exit;

  FData.Seek(0,soFromBeginning);
  FData.Read(IH, SizeOf(TIconHeader));

  Result:= IH.idCount;
end;

function TIconStream.GetIsIcon: Boolean;
begin
  Result:= (FIconType = 1);
end;

function TIconStream.GetHotspot(Index: Integer): TPoint;
var
  IE: TIconDirEntry;
begin
  IE:= GetFrame(Index);

  case FIconType of
    1: Result:= Point(-1,-1);
    2: Result:= Point(IE.wPlanes,IE.wBitCount);
  end;
end;
//----------------------------------------------------------------------------//
function TIconStream.GetFrame(Index: Integer): TIconDirEntry;
var
  Offset: Cardinal;
  IE: TIconDirEntry;
begin
  if FData.Size = 0 then Exit;

  Offset:= SizeOf(TIconHeader) + SizeOf(TIconDirEntry)* Index;
  FData.Seek(Offset,soFromBeginning);
  FData.Read(IE, SizeOf(TIconDirEntry));

  Result:= IE;
end;

function TIconStream.GetHeader(Index: Integer): TBitmapInfoHeader;
var
  Offset: Cardinal;
  BI: TBitmapInfoHeader;
begin
  Offset:= GetFrame(Index).dwImageOffset;

  FData.Seek(Offset,soFromBeginning);
  FData.Read(BI, SizeOf(TBitmapInfoHeader));

  Result:= BI;
end;
//----------------------------------------------------------------------------//
procedure TIconStream.Draw(DC: HDC; DX, DY, Index, AlphaMode: Integer);
var
  Offset,
  iNumberColor,
  iRgbTable : Integer;

//  IDE: TIconDirEntry;

  iXOR: PBitmapInfo;
  iAND: TMaskBitmapInfo;

//  iXORSize,
  pANDSize, pXORSize : Integer;
  pXOR, pAND: Pointer;

  HasPalette: Boolean;
 {$IFDEF FPC}
  function BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
  begin
    Dec(Alignment);
    Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
    Result := Result div 8;
  end;
 {$ENDIF}

  function GetScanLine(Row: Integer): Pointer;
  begin
    Row := iXOR.bmiHeader.biHeight - Row - 1;
    PByte(Result) := PByte(pXOR) +
        Row * BytesPerScanline(iXOR.bmiHeader.biWidth, 32, 32);
  end;


  procedure Draw32(Bits: PColor32Array);
  var
    Y,X: Integer;
    Scan: pColor24Array;
    Scan32: pColor32Array;
    tmp_bmp: TBitmap;
    A: Double;

//    iNum: Integer;
  begin
    tmp_bmp:= TBitmap.Create;
    tmp_bmp.Width:= iXOR.bmiHeader.biWidth;
    tmp_bmp.Height:= iXOR.bmiHeader.biHeight;
    tmp_bmp.PixelFormat:= pf24bit;

    BitBlt(tmp_bmp.Canvas.Handle,
      0,0,iXOR.bmiHeader.biWidth,iXOR.bmiHeader.biHeight,
      DC,DX,DY,SrcCopy);


    for Y := 0 to iXOR.bmiHeader.biHeight - 1 do
    begin
      Scan := pColor24Array(tmp_bmp.ScanLine[Y]);
      Scan32:= pColor32Array(GetScanLine(Y));

      for X := 0 to iXOR.bmiHeader.biWidth - 1 do
        begin
          A:= Scan32^[X].A;

          if A<>0 then
          begin
            A:= A/255;
            Scan^[X].R := round(Scan32^[X].R * (A) + Scan^[X].R * (1-A));
            Scan^[X].G := round(Scan32^[X].G * (A) + Scan^[X].G * (1-A));
            Scan^[X].B := round(Scan32^[X].B * (A) + Scan^[X].B * (1-A));
          end; 
        end;
    end;


    BitBlt(DC,
      DX,DY,iXOR.bmiHeader.biWidth,iXOR.bmiHeader.biHeight,
      tmp_bmp.Canvas.Handle,0,0,SrcCopy);

    tmp_bmp.Free;
  end;

    procedure Draw32Native;
  var
    {$IFDEF FPC}
      blend: JwaWinGDI.BLENDFUNCTION;
    {$ELSE ~FPC}
    blend: BLENDFUNCTION;
    {$ENDIF}
    hDC, hdcColor, hOldC: Integer;
    colorBitmap: HBITMAP;
    pcolorBits: pointer;
    Width, Height : Integer;
  begin
    Width := iXOR.bmiHeader.biWidth;
    Height:= iXOR.bmiHeader.biHeight;
    
    hDC:= CreateCompatibleDC(0);

    pcolorBits:= nil;

    colorBitmap := CreateDIBSection(hDC, iXOR^, DIB_RGB_COLORS, pcolorBits,0, 0);
    hdcColor := CreateCompatibleDC(hDC);
    ReleaseDC(0,hDC);

    hOldC := SelectObject(hdcColor, colorBitmap);

    SetDIBitsToDevice (hdcColor,0,0,Width,Height,0,0,0,Height, pXOR, iXOR^, DIB_RGB_COLORS);

    blend.BlendOp             := AC_SRC_OVER;
    blend.BlendFlags          := 0;
    blend.SourceConstantAlpha := 255;
    blend.AlphaFormat         := AC_SRC_ALPHA;

    //StretchDIBits(DC,DX,DY,Width,Height,0, 0, Width, Height,pAND, PBitmapInfo(@iAND)^, DIB_RGB_COLORS,SRCAND);

  {$IFDEF FPC}
    JwaWinGDI.
  {$ELSE ~FPC}
    Windows.
  {$ENDIF}
    AlphaBlend(DC,DX,DY,Width,Height, hdcColor,0,0,Width, Height, blend);

    SelectObject(hdcColor, hOldC);
    DeleteObject(hdcColor);
    DeleteObject(colorBitmap);
    DeleteDC(hDC);

    pcolorBits := nil;
  end;


begin
  if FData.Size = 0 then Exit;

  Offset:= GetFrame(Index).dwImageOffset;
  FData.Seek(Offset, soFromBeginning);

  GetMem(iXOR, SizeOf(TBitmapInfoHeader));
  FData.Read(iXOR^,SizeOf(TBitmapInfoHeader));

  iNumberColor := 1 shl iXOR.bmiHeader.biBitCount;
  HasPalette:= iXOR.bmiHeader.biBitCount in [1,4,8];

//  iRgbTable := 0;
  if HasPalette then
  begin
    iRgbTable := sizeof(RGBQUAD) * iNumberColor;

    ReallocMem(iXOR,SizeOf(TBitmapInfoHeader) + iRgbTable);
    FData.Read(iXOR.bmiColors,iRgbTable);
//    iXORSize:= SizeOf(TBitmapInfoHeader) + iRgbTable;
  end
  else
  begin
//    iXORSize:= SizeOf(TBitmapInfoHeader);
  end;

  iXOR.bmiHeader.biHeight:= iXOR.bmiHeader.biHeight div 2;

  pXORSize:=((iXOR.bmiHeader.biWidth*iXOR.bmiHeader.biBitCount+31)shr 5)shl 2 * iXOR.bmiHeader.biHeight;
  GetMem(pXOR,pXORSize);
  FData.Read(pXOR^,pXORSize);

  pANDSize := ((iXOR.bmiHeader.biWidth+31)shr 5)shl 2 * iXOR.bmiHeader.biHeight;
  GetMem(pAND,pANDSize);
  FData.Read(pAND^,pANDSize);

  iAND.Header.biSize          := SizeOf(TBitmapInfoHeader);
  iAND.Header.biWidth         := iXOR.bmiHeader.biWidth;
  iAND.Header.biHeight        := iXOR.bmiHeader.biHeight;
  iAND.Header.biSizeImage     := pANDSize;
  iAND.Header.biPlanes        := 1;
  iAND.Header.biBitCount      := 1;
  iAND.Header.biCompression   := BI_RGB;
  iAND.Header.biXPelsPerMeter := 0;
  iAND.Header.biYPelsPerMeter := 0;
  iAND.Header.biClrUsed       := 2;
  iAND.Header.biClrImportant  := 0;

  iAND.Black.rgbBlue          := 0;
  iAND.Black.rgbGreen         := 0;
  iAND.Black.rgbRed           := 0;
  iAND.Black.rgbReserved      := 0;
  iAND.White.rgbBlue          := 255;
  iAND.White.rgbGreen         := 255;
  iAND.White.rgbRed           := 255;
  iAND.White.rgbReserved      := 255;

  if iXOR.bmiHeader.biBitCount = 32 then
  begin
    Draw32(pXOR);
    //Draw32Native;
  end
  else
  begin
    StretchDIBits(DC,
      DX,DY,iXOR.bmiHeader.biWidth, iXOR.bmiHeader.biHeight,
      0, 0, iXOR.bmiHeader.biWidth, iXOR.bmiHeader.biHeight,
      pAND, PBitmapInfo(@iAND)^, DIB_RGB_COLORS,SRCAND);

    StretchDIBits(DC,
      DX,DY,iXOR.bmiHeader.biWidth, iXOR.bmiHeader.biHeight,
      0, 0, iXOR.bmiHeader.biWidth, iXOR.bmiHeader.biHeight,
      pXOR, iXOR^, DIB_RGB_COLORS,SRCINVERT);
  end;

  FreeMem(pXOR);
  FreeMem(pAND);
  FreeMem(iXOR);
end;

// By Rapid D. Try to get icon
function TIconStream.getBestFrameIdx: Integer;
var
  de : PIconDirEntry;
  lprd : LPRESDIR;
  frm : TIconDirEntry;
  I, cnt: Integer;
begin
  cnt := GetCount;
  de := AllocMem(sizeof(TIconHeader) + (cnt * sizeof(RESDIR)));
  lprd := Pointer(UINT_PTR( de ) + sizeof(TIconHeader) );
  for I := 0 to cnt-1 do
    begin
      frm := GetFrame(i);
      lprd.bWidth := frm.bWidth;
      lprd.bHeight := frm.bHeight;
      lprd.bColorCount := frm.bColorCount;
      lprd.wPlanes := frm.wPlanes;
      lprd.wBitCount := frm.wBitCount;
      lprd.dwBytesInRes := frm.dwBytesInRes;
      lprd.IconCursorId := i;

      inc(lprd, sizeof(RESDIR));
    end;
  FreeMemory(de);
end;

//----------------------------------------------------------------------------//

function TIconStream.GetName(Index: Integer): String;
begin
  if Index in [0..FNames.Count-1] then
     Result:= FNames[Index];
end;

procedure TIconStream.LoadNames(FileName: string);
  function GetItemName(const S: String): String;
  begin
    Result:= Copy(S, Pos('name="', S)+6, Length(S));
    Delete(Result, Pos('"', Result), Length(Result));
  end;

var
  hFile: Text;
  S: String;
  I: Integer;
begin
  If not FileExists(FileName+'.xml') then
  begin
    FNames.Clear;
    for i:= 0 to Count-1 do
      FNames.Add('');
    Exit;
  end;

  {$I-}
  AssignFile(hFile, PChar(FileName+'.xml'));
  {$I+}
  Reset(hFile);

  FNames.Clear;
//  I:= 0;
  While not(EOF(hFile)) do
  begin
    ReadLn(hFile, S);

    if Pos('<item', S) = 0 then
      Continue;
    begin
      FNames.Add(GetItemName(S));
//      Inc(I);
    end;
  end;

  //if FNames.Count = Count then ShowMessage('OK');
  CloseFile(hFile);
end;

procedure TIconStream.LoadNames(Stream: TStream);
begin

end;

function GetPaletteSize(Bpp: Integer): Integer;
begin
  if Bpp <= 8 then
    Result := 1 shl Bpp
  else
    Result := 0;
end;

procedure TIconStream.SaveMultiToStream(Stream: TStream; Count: Integer);
var
  nOffset, Offset,
  iNumberColor, iRgbTable,
  I, RSize, Index: Integer;

  IH:  TIconHeader;
  PID: TIconDirEntry;
  iXOR: PBitmapInfo;

  iXORSize, pANDSize, pXORSize : Integer;
  pXOR, pAND: Pointer;

  HasPalette: Boolean;
begin
  if Stream = nil  then Exit;

  //Count := 1;
  
  Stream.Position:= 0;
  Offset := SizeOf(TIconHeader) + Count * SizeOf(TIconDirEntry);
  //** TIconHeader **//
  IH.idReserved := 0;
  IH.idType := 1;
  IH.idCount := Count;
  Stream.Write(IH, SizeOf(TIconHeader));
  //** TIconHeader **//

  Index:= 4;
  //** TIconDirEntry **//
  for I := 0 to Count - 1 do
  begin
    PID:= GetFrame(Index);

    nOffset:= PID.dwImageOffset;
    FData.Seek(nOffset, soFromBeginning);

    GetMem(iXOR, SizeOf(TBitmapInfoHeader));
    FData.Read(iXOR^,SizeOf(TBitmapInfoHeader));

    iNumberColor := 1 shl iXOR.bmiHeader.biBitCount;
    HasPalette   := iXOR.bmiHeader.biBitCount in [1,4,8];

    if HasPalette then
    begin
      iRgbTable := sizeof(RGBQUAD) * iNumberColor;

      ReallocMem(iXOR,SizeOf(TBitmapInfoHeader) + iRgbTable);
      FData.Read(iXOR.bmiColors,iRgbTable);
      iXORSize:= SizeOf(TBitmapInfoHeader) + iRgbTable;
    end
    else
    begin
      iXORSize:= SizeOf(TBitmapInfoHeader);
    end;

    iXOR.bmiHeader.biHeight:= iXOR.bmiHeader.biHeight shr 1;
    pXORSize:= ((iXOR.bmiHeader.biWidth*iXOR.bmiHeader.biBitCount+31)shr 5)shl 2 * iXOR.bmiHeader.biHeight;
    pANDSize:= ((iXOR.bmiHeader.biWidth+31)shr 5)shl 2 * iXOR.bmiHeader.biHeight;

    RSize := iXORSize + pXORSize + pANDSize;
    PID.dwBytesInRes := RSize;
    PID.dwImageOffset := Offset;
    Stream.Write(PID, SizeOf(TIconDirEntry));
    Inc(Offset, RSize);
    
    FreeMem(iXOR);
  end;
  //** TIconDirEntry **//

  //** XOR & AND Data **//

  for I := 0 to Count - 1 do
  begin
    Offset:= GetFrame(Index).dwImageOffset;
    FData.Seek(Offset, soFromBeginning);

    GetMem(iXOR, SizeOf(TBitmapInfoHeader));
    FData.Read(iXOR^,SizeOf(TBitmapInfoHeader));

    iNumberColor := 1 shl iXOR.bmiHeader.biBitCount;
    HasPalette   := iXOR.bmiHeader.biBitCount in [1,4,8];

    if HasPalette then
    begin
      iRgbTable := sizeof(RGBQUAD) * iNumberColor;

      ReallocMem(iXOR,SizeOf(TBitmapInfoHeader) + iRgbTable);
      FData.Read(iXOR.bmiColors,iRgbTable);
      iXORSize:= SizeOf(TBitmapInfoHeader) + iRgbTable;
    end
    else
    begin
      iXORSize:= SizeOf(TBitmapInfoHeader);
    end;

    iXOR.bmiHeader.biHeight:= iXOR.bmiHeader.biHeight shr 1;
    pXORSize:= ((iXOR.bmiHeader.biWidth*iXOR.bmiHeader.biBitCount+31)shr 5)shl 2 * iXOR.bmiHeader.biHeight;
    pANDSize:= ((iXOR.bmiHeader.biWidth+31)shr 5)shl 2 * iXOR.bmiHeader.biHeight;
    //ShowMessage(Format('pXORSize = %d pANDSize = %d', [pXORSize, pANDSize]));

    GetMem(pXOR,pXORSize);
    FData.Read(pXOR^,pXORSize);

    GetMem(pAND,pANDSize);
    FData.Read(pAND^,pANDSize);

    iXOR.bmiHeader.biHeight:= iXOR.bmiHeader.biHeight shl 1;
    Stream.Write(iXOR^, iXORSize);
    iXOR.bmiHeader.biHeight:= iXOR.bmiHeader.biHeight shr 1;

    Stream.Write(pXOR^, pXORSize);
    Stream.Write(pAND^, pANDSize);

    FreeMem(pXOR);
    FreeMem(pAND);
    FreeMem(iXOR);
  end;

end;

{
procedure TKIcon.SaveToStream(Stream: TStream);
var
  I, Offset, RSize: Integer;
  IH: TIconHeader;
  PID: PIconData;
  II: TIconDirEntry;
begin
  if (Stream <> nil) and (FIconData <> nil) then
  begin
    Offset := SizeOf(TIconHeader) + FIconCount * SizeOf(TIconDirEntry);
    IH.idReserved := 0;
    IH.idType := 1;
    IH.idCount := 0;
    for I := 0 to FIconCount - 1 do
      if FIconData[I].iXOR <> nil then
        Inc(IH.idCount);
    Stream.Write(IH, SizeOf(TIconHeader));
    FillChar(II, SizeOf(TIconDirEntry), 0);
    for I := 0 to FIconCount - 1 do
    begin
      PID := @FIconData[I];
      if PID.iXOR <> nil then
      begin
        II.bWidth := PID.Width;
        II.bHeight := PID.Height;
        II.bColorCount := GetPaletteSize(PID.Bpp);
        II.wPlanes := 1;
        II.wBitCount := PID.Bpp;
        RSize := PID.iXORSize + PID.pXORSize + PID.pANDSize;
        II.dwBytesInRes := RSize;
        II.dwImageOffset := Offset;
        Stream.Write(II, SizeOf(TIconDirEntry));
        Inc(Offset, RSize);
      end;
    end;
    for I := 0 to FIconCount - 1 do
    begin
      PID := @FIconData[I];
      if PID.iXOR <> nil then
      begin
        PID.iXOR.bmiHeader.biHeight := PID.iXOR.bmiHeader.biHeight * 2;
        Stream.Write(PID.iXOR^, PID.iXORSize);
        PID.iXOR.bmiHeader.biHeight := PID.iXOR.bmiHeader.biHeight div 2;
        Stream.Write(PID.pXOR^, PID.pXORSize);
        Stream.Write(PID.pAND^, PID.pANDSize);
      end;
    end;
  end;
end;
}

END.