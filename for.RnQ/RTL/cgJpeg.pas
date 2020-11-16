Unit cgJpeg;

Interface

Uses
  {$IFDEF FPC}
   Windows, SysUtils, Classes, Graphics, libJPEG;
  {$ELSE ~FPC}
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, libJPEG;
  {$ENDIF FPC}

Type
  TJpegImage = Class(TBitmap)

  Private
    { Déclarations privées }
  public
    class var LibPathName: String;
  Public
    function LoadFromStream(Stream: TStream): Boolean; ReIntroduce;
    { Déclarations publiques }
  End;

  my_source_mgr_ptr = ^my_source_mgr;

  my_source_mgr = Record
    pub: jpeg_source_mgr;

    SrcStream: TStream;
    SrcBuffer: Array [1 .. 4096] Of byte;
  End;

  TRGBArray = ARRAY [0 .. 0] OF TRGBTriple; // élément de bitmap (API windows)
  pRGBArray = ^TRGBArray; // type pointeur vers tableau 3 octets 24 bits

  function init_libJPEGCS(LibPath: String): Boolean;
  procedure UnInit_libJPEG;

Implementation

uses
  SyncObjs,
  RDGlobal, RDUtils;

var
  initCS: TCriticalSection;


Procedure error_exit(cinfo: j_common_ptr); Cdecl;
Var
  Msg: AnsiString;
Begin
  SetLength(Msg, 256);
  cinfo^.err^.format_message(cinfo, PAnsiChar(Msg));
  OutputDebugStringA(PAnsiChar('ERROR [' + IntToStrA(cinfo^.err^.msg_code) + '] ' + Msg));
  cinfo^.global_state := 0;
  jpeg_abort(cinfo);
End;

Procedure output_message(cinfo: j_common_ptr); Cdecl;
Var
  Msg: AnsiString;
Begin
  SetLength(Msg, 256);
  cinfo^.err^.format_message(cinfo, PAnsiChar(Msg));
  OutputDebugStringA(PAnsiChar('OUTPUT [' + IntToStrA(cinfo^.err^.msg_code) + '] ' + Msg));
  cinfo^.global_state := 0;
End;

Procedure init_source(cinfo: j_decompress_ptr); Cdecl;
Begin
End;

Function fill_input_buffer(cinfo: j_decompress_ptr): boolean; Cdecl;
Var
  src: my_source_mgr_ptr;
  bytes: integer;
Begin
  src := my_source_mgr_ptr(cinfo^.src);
  bytes := src^.SrcStream.Read(src^.SrcBuffer[1], 4096);
  If (bytes <= 0) Then
  Begin
    // Insert a fake EOI marker
    src^.SrcBuffer[1] := $FF;
    src^.SrcBuffer[2] := JPEG_EOI;
    bytes := 2;
  End;
  src^.pub.next_input_byte := @(src^.SrcBuffer[1]);
  src^.pub.bytes_in_buffer := bytes;
  result := true;
End;

Procedure skip_input_data(cinfo: j_decompress_ptr; num_bytes: Longint); Cdecl;
Var
  src: my_source_mgr_ptr;
Begin
  src := my_source_mgr_ptr(cinfo^.src);
  { Just a dumb implementation for now.	Could use fseek() except
    it doesn't work on pipes.  Not clear that being smart is worth
    any trouble anyway --- large skips are infrequent. }
  If (num_bytes > 0) Then
  Begin
    While num_bytes > src^.pub.bytes_in_buffer Do
    Begin
      num_bytes := num_bytes - src^.pub.bytes_in_buffer;
      src^.pub.fill_input_buffer(cinfo);
      { note we assume that fill_input_buffer will never
        return FALSE, so suspension need not be handled. }
    End;
    inc(src^.pub.next_input_byte, num_bytes);
    dec(src^.pub.bytes_in_buffer, num_bytes);
  End;
End;

Procedure term_source(cinfo: j_decompress_ptr); Cdecl;
Begin
End;

function init_libJPEGCS(LibPath: String): Boolean;
begin
  initCS.Acquire;
  try
    Result := init_libJPEG(LibPath);
  finally
    initCS.Release;
  end;
end;

procedure UnInit_libJPEG;
begin
  quit_libJPEG;
end;



function TJpegImage.LoadFromStream(Stream: TStream): Boolean;
Var
  jpeg: jpeg_decompress_struct;
  jpeg_err: jpeg_error_mgr;
//  prow: Prgbarray;
  RowD: Prgbarray;
  y: Integer;
  a: Byte;
Begin
  // *** initialization ***
  If Not init_libJPEGCS(LibPathName) Then
  Begin
//    msgDlg('Initialization of libJPEG failed', false, mtError);
//    halt;
    Result := false;
    Exit;
  End;

  // *** quering informations ***

  FillChar(jpeg, SizeOf(jpeg_decompress_struct), $00);
  FillChar(jpeg_err, SizeOf(jpeg_error_mgr), $00);

  // error managment
  jpeg.err := jpeg_std_error(@jpeg_err);
  jpeg_err.error_exit := error_exit;
  jpeg_err.output_message := output_message;

  // decompression struct
  jpeg_create_decompress(@jpeg);

  If jpeg.src = Nil Then
  Begin
    // allocation space for streaming methods
    jpeg.src := jpeg.mem^.alloc_small(@jpeg, JPOOL_PERMANENT, SizeOf(my_source_mgr));

    // seeting up custom functions
    With my_source_mgr_ptr(jpeg.src)^ Do
    Begin
      pub.init_source := init_source;
      pub.fill_input_buffer := fill_input_buffer;
      pub.skip_input_data := skip_input_data;
      pub.resync_to_restart := jpeg_resync_to_restart; // use default method
      pub.term_source := term_source;

      pub.bytes_in_buffer := 0; // forces fill_input_buffer on first read
      pub.next_input_byte := Nil; // until buffer loaded

      SrcStream := Stream;
    End;
  End;

  // very important state
  jpeg.global_state := DSTATE_START;

  // read header of jpeg
  jpeg_read_header(@jpeg, False);

  // setting output parameter
  jpeg.out_color_space := JCS_EXT_BGR; // We need BGR!

  // Scaling
  jpeg.scale_num := 1;
  jpeg.scale_denom := 1; // use 2, 4, or 8 to load an scaled image

  // speedup or quality
  jpeg.do_fancy_upsampling := 1; // False;
  jpeg.do_block_smoothing := 1; // False;
  jpeg.dct_method := JDCT_IFAST;

  // Palette (why ever)
  // jpeg.quantize_colors := True;

  // reading image
  jpeg_start_decompress(@jpeg);

  Inherited SetSize(jpeg.output_width, jpeg.output_height);
  Inherited PixelFormat := pf24bit;
  For y := 0 To jpeg.output_height - 1 Do
  Begin
    // reading row
    rowD := scanline[y];
    a := jpeg_read_scanlines(@jpeg, @rowD, 1);
    if a = 0 then
      Break;
  End;

  // finish decompression
  jpeg_finish_decompress(@jpeg);

  // *** finallization ***
  jpeg_destroy_decompress(@jpeg);

  // not really necessary
  quit_libJPEG;
  Result := True;
End;

initialization
  initCS := TCriticalSection.Create;

finalization
  FreeAndNil(initCS);
End.
