{Portable Network Graphics Delphi 1.4361   (8 March 2003)     }

{This is the latest implementation for TPngImage component    }
{It's meant to be a full replacement for the previous one.    }
{There are lots of new improvements, including cleaner code,  }
{full partial transparency support, speed improvements,       }
{saving using ADAM 7 interlacing, better error handling, also }
{the best compression for the final image ever. And now it's  }
{truly able to read about any png image.                      }

{
  Version 1.4361
  2003-03-04 - Fixed important bug for simple transparency when using
               RGB, Grayscale color modes

  Version 1.436
  2003-03-04 - * NEW * Property Pixels for direct access to pixels
               * IMPROVED * Palette property (TPngObject) (read only)
               Slovenian traslation for the component (Miha Petelin)
               Help file update (scanline article/png->jpg example)

  Version 1.435
  2003-11-03 - * NEW * New chunk implementation zTXt (method AddzTXt)
               * NEW * New compiler flags to store the extra 8 bits
               from 16 bits samples (when saving it is ignored), the
               extra data may be acessed using ExtraScanline property
               * Fixed * a bug on tIMe chunk
               French translation included (Thanks to IBE Software)
               Bugs fixed

  Version 1.432
  2002-08-24 - * NEW *  A new method, CreateAlpha will transform the
               current image into partial transparency.
               Help file updated with a new article on how to handle
               partial transparency.

  Version 1.431
  2002-08-14 - Fixed and tested to work on:
               C++ Builder 3
               C++ Builder 5
               Delphi 3
               There was an error when setting TransparentColor, fixed
               New method, RemoveTransparency to remove image
               BIT TRANSPARENCY

  Version 1.43
  2002-08-01 - * NEW * Support for Delphi 3 and C++ Builder 3
               Implements mostly some things that were missing,
               a few tweaks and fixes.

  Version 1.428
  2002-07-24 - More minor fixes (thanks to Ian Boyd)
               Bit transparency fixes
               * NEW * Finally support to bit transparency
               (palette / rgb / grayscale -> all)

  Version 1.427
  2002-07-19 - Lots of bugs and leaks fixed
               * NEW * method to easy adding text comments, AddtEXt
               * NEW * property for setting bit transparency,
                       TransparentColor

  Version 1.426
  2002-07-18 - Clipboard finally fixed and working
               Changed UseDelphi trigger to UseDelphi
               * NEW * Support for bit transparency bitmaps
                       when assigning from/to TBitmap objects
               Altough it does not support drawing transparent
               parts of bit transparency pngs (only partial)
               it is closer than ever

  Version 1.425
  2002-07-01 - Clipboard methods implemented
               Lots of bugs fixed

  Version 1.424
  2002-05-16 - Scanline and AlphaScanline are now working correctly.
               New methods for handling the clipboard

  Version 1.423
  2002-05-16 - * NEW * Partial transparency for 1, 2, 4 and 8 bits is
               also supported using the tRNS chunk (for palette and
               grayscaling).
               New bug fixes (Peter Haas).

  Version 1.422
  2002-05-14 - Fixed some critical leaks, thanks to Peter Haas tips.
               New translation for German (Peter Haas).

  Version 1.421
  2002-05-06 - Now uses new ZLIB version, 1.1.4 with some security
               fixes.
               LoadFromResourceID and LoadFromResourceName added and
               help file updated for that.
               The resources strings are now located in pnglang.pas.
               New translation for Brazilian Portuguese.
               Bugs fixed.

 IMPORTANT: I'm currently looking for bugs on the library. If
            anyone has found one, please send me an email and
            I will fix right away. Thanks for all the help and
            ideias I'm receiving so far.}

{My email is    : gustavo.daud@terra.com.br}
{Website link   : http://pngdelphi.sourceforge.net}
{Gustavo Huffenbacher Daud}

unit RnQpngimage;
{$I forRnQConfig.inc}
{$ifdef FPC}
  {$MODE DELPHI}
  {$define D7UP}
{$endif FPC}

{$I NoRTTI.inc}

interface

{Triggers avaliable (edit the fields bellow)}
{$TYPEDADDRESS OFF}

{$DEFINE UseDelphi}              //Disable fat vcl units (perfect for small apps)
{$DEFINE ErrorOnUnknownCritical} //Error when finds an unknown critical chunk
{.$DEFINE CheckCRC}               //Enables CRC checking
{ $DEFINE isTGraphic}        //TPNGObject is under TGraphic
{ $DEFINE RegisterGraphic}        //Registers TPNGObject to use with TPicture

{$DEFINE PartialTransparentDraw} //Draws partial transparent images
{.$DEFINE Store16bits}            //Stores the extra 8 bits from 16bits/sample
{.$DEFINE Debug}                 //For programming purposes
{$UNDEF Debug}                 //For programming purposes
{$DEFINE UseAnimation}         // New APNG support
{ $DEFINE SavePicture} //Support encoding

{$RANGECHECKS OFF} {$J+}



uses
 {$IFDEF FPC}
   JwaWinGDI,
   paszlib, zbase,
 {$ENDIF}
 Windows {$IFDEF UseDelphi} {$ENDIF}
 ,
  Classes,
  Graphics,
 {$IFNDEF FPC}
//    OverbyteIcsZLibObj,
    System.ZLib,
 {$ENDIF}
  SysUtils
;

{$IFNDEF UseDelphi}
  const
    soFromBeginning = 0;
    soFromCurrent = 1;
    soFromEnd = 2;
{$ENDIF}

resourcestring

  EPNGInvalidCRCText='This "Portable Network Graphics" image is not valid '+
      'because it contains invalid pieces of data (crc error)';
  EPNGInvalidIHDRText='The "Portable Network Graphics" image could not be '+
      'loaded because one of its main piece of data (ihdr) might be corrupted';
  EPNGMissingMultipleIDATText='This "Portable Network Graphics" image is '+
    'invalid because it has missing image parts.';
  EPNGZLIBErrorText='Could not decompress the image because it contains '+
    'invalid compressed data.'#13#10+' Description: ';
  EPNGInvalidPaletteText='The "Portable Network Graphics" image contains '+
    'an invalid palette.';
  EPNGInvalidFileHeaderText='The file being readed is not a valid '+
    '"Portable Network Graphics" image because it contains an invalid header.'+
    ' This file may be corruped, try obtaining it again.';
  EPNGIHDRNotFirstText='This "Portable Network Graphics" image is not '+
    'supported or it might be invalid.'#13#10+'(IHDR chunk is not the first)';
  EPNGNotExistsText='The PNG file could not be loaded because it does not '+
    'exists.';
  EPNGSizeExceedsText='This "Portable Network Graphics" image is not '+
    'supported because either it''s width or height exceeds the maximum '+
    'size, which is 65535 pixels length.';
  EPNGUnknownPalEntryText='There is no such palette entry.';
  EPNGMissingPaletteText='This "Portable Network Graphics" could not be '+
    'loaded because it uses a color table which is missing.';
  EPNGUnknownCriticalChunkText='This "Portable Network Graphics" image '+
    'contains an unknown critical part which could not be decoded.';
  EPNGUnknownCompressionText='This "Portable Network Graphics" image is '+
    'encoded with an unknown compression scheme which could not be decoded.';
  EPNGUnknownInterlaceText='This "Portable Network Graphics" image uses '+
    'an unknown interlace scheme which could not be decoded.';
  EPNGCannotAssignChunkText='The chunks must be compatible to be assigned.';
  EPNGUnexpectedEndText='This "Portable Network Graphics" image is invalid '+
    'because the decoder found an unexpected end of the file.';
  EPNGNoImageDataText='This "Portable Network Graphics" image contains no '+
    'data.';
  EPNGCannotChangeSizeText='The "Portable Network Graphics" image can not '+
    'be resize by changing width and height properties. Try assigning the '+
    'image from a bitmap.';
  EPNGCannotAddChunkText='The program tried to add a existent critical '+
    'chunk to the current image which is not allowed.';
  EPNGCannotAddInvalidImageText='It''s not allowed to add a new chunk '+
    'because the current image is invalid.';
  EPNGCouldNotLoadResourceText='The PNG image could not be loaded from the '+
    'resource ID.';
  EPNGOutMemoryText='Some operation could not be performed because the '+
    'system is out of resources. Close some windows and try again.';
  EPNGCannotChangeTransparentText='Setting bit transparency color is not '+
    'allowed for PNG images containing alpha value for each pixel '+
    '(COLOR_RGBALPHA and COLOR_GRAYSCALEALPHA)';
  EPNGHeaderNotPresentText='This operation is not valid because the '+
    'current image contains no valid header.';
  EInvalidNewSize = 'The new size provided for image resizing is invalid.';
  EInvalidSpec = 'The "Portable Network Graphics" could not be created ' +
    'because invalid image type parameters have being provided.';

const
  {ZLIB constants}
  ZLIBErrors: Array[-6..2] of string = ('incompatible version (-6)',
    'buffer error (-5)', 'insufficient memory (-4)', 'data error (-3)',
    'stream error (-2)', 'file error (-1)', '(0)', 'stream end (1)',
    'need dictionary (2)');
  Z_NO_FLUSH      = 0;
  Z_FINISH        = 4;
  Z_STREAM_END    = 1;

  {Avaliable PNG filters for mode 0}
  FILTER_NONE    = 0;
  FILTER_SUB     = 1;
  FILTER_UP      = 2;
  FILTER_AVERAGE = 3;
  FILTER_PAETH   = 4;

  {Avaliable color modes for PNG}
  COLOR_GRAYSCALE      = 0;
  COLOR_RGB            = 2;
  COLOR_PALETTE        = 3;
  COLOR_GRAYSCALEALPHA = 4;
  COLOR_RGBALPHA       = 6;


  {$IFDEF FPC}
  type
   UInt32      = LongWord; //Cardinal; // [Should be] unsigned 32 bit integer
  {$ENDIF FPC}

type
  {$IFNDEF UseDelphi}
    {Custom exception handler}
    Exception = class(TObject)
      constructor Create(Msg: String);
    end;
    ExceptClass = class of Exception;
    TColor = ColorRef;
  {$ENDIF}

  {Error types}
  EPNGOutMemory = class(Exception);
  EPngError = class(Exception);
  EPngUnexpectedEnd = class(Exception);
  EPngInvalidCRC = class(Exception);
  EPngInvalidIHDR = class(Exception);
  EPNGMissingMultipleIDAT = class(Exception);
  EPNGZLIBError = class(Exception);
  EPNGInvalidPalette = class(Exception);
  EPNGInvalidFileHeader = class(Exception);
  EPNGIHDRNotFirst = class(Exception);
  EPNGNotExists = class(Exception);
  EPNGSizeExceeds = class(Exception);
  EPNGMissingPalette = class(Exception);
  EPNGUnknownCriticalChunk = class(Exception);
  EPNGUnknownCompression = class(Exception);
  EPNGUnknownInterlace = class(Exception);
  EPNGNoImageData = class(Exception);
  EPNGCouldNotLoadResource = class(Exception);
  EPNGCannotChangeTransparent = class(Exception);
  EPNGHeaderNotPresent = class(Exception);
  EPNGInvalidNewSize = class(Exception);
  EPNGInvalidSpec = class(Exception);

type
  {Direct access to pixels using R,G,B}
  TRGBLine = array[word] of TRGBTriple;
  pRGBLine = ^TRGBLine;

  {Same as TBitmapInfo but with allocated space for}
  {palette entries}
  TMAXBITMAPINFO = packed record
    bmiHeader: TBitmapInfoHeader;
    bmiColors: packed array[0..255] of TRGBQuad;
  end;

  {Transparency mode for pngs}
  TPNGTransparencyMode = (ptmNone, ptmBit, ptmPartial);
  {Pointer to a cardinal type}
  pCardinal = ^Cardinal;
  {Access to a rgb pixel}
  pRGBPixel = ^TRGBPixel;
  TRGBPixel = packed record
    B, G, R: Byte;
  end;

  {Pointer to an array of bytes type}
  TByteArray = Array[Word] of Byte;
  pByteArray = ^TByteArray;

  {Forward}
  TPNGObject = class;
  pPointerArray = ^TPointerArray;
  TPointerArray = Array[Word] of Pointer;

  {Contains a list of objects}
  TPNGPointerList = class
  private
    fOwner: TPNGObject;
    fCount : Cardinal;
    fMemory: pPointerArray;
    function GetItem(Index: Cardinal): Pointer;
    procedure SetItem(Index: Cardinal; const Value: Pointer);
  protected
    {Removes an item}
    function Remove(Value: Pointer): Pointer; virtual;
    {Inserts an item}
    procedure Insert(Value: Pointer; Position: Cardinal);
    {Add a new item}
    procedure Add(Value: Pointer);
    {Returns an item}
    property Item[Index: Cardinal]: Pointer read GetItem write SetItem;
    {Set the size of the list}
    procedure SetSize(const Size: Cardinal);
    {Returns owner}
    property Owner: TPNGObject read fOwner;
  public
    {Returns number of items}
    property Count: Cardinal read fCount write SetSize;
    {Object being either created or destroyed}
    constructor Create(AOwner: TPNGObject);
    destructor Destroy; override;
  end;

 {$IFDEF UseAnimation}

  TPNGFrame = class
  const
     APNG_DISPOSE_OP_NONE       = 0;
     APNG_DISPOSE_OP_BACKGROUND = 1;
     APNG_DISPOSE_OP_PREVIOUS   = 2;
     APNG_BLEND_OP_SOURCE = 0;
     APNG_BLEND_OP_OVER   = 1;
  private
    FBitmapInfo: TMaxBitmapInfo;
    {Current image}
    ImageHandle: HBitmap;
    ImageDC: HDC;
    ImagePalette: HPalette;
    {Output windows bitmap}
//    HasPalette: Boolean;
    {Contains data}
    FImageData: Pointer;
    FImageSize: Cardinal;
    FAlphaData: Pointer;
    FAlphaSize: Cardinal;

    FSelfWidth: Cardinal;
    FSelfHeight: Cardinal;

    FXOffset: Cardinal;
    FYOffset: Cardinal;

    FDelayNum: Word;
    FDelayDenum: Word;
    FDelayMS : Word; // in miliseconds

    FDisposeOp: Byte;
    FBlendOp: Byte;

    {Stores owner}
    FOwner: TPngObject;

    {Used with property index}
    function GetIndex: Integer;
    {Returns data and size}
  public
    {Returns index from list}
    property Index: Integer read GetIndex;

    property ImageData: Pointer read FImageData;
    property AlphaData: Pointer read FAlphaData;

    property SelfWidth: Cardinal read FSelfWidth;
    property SelfHeight: Cardinal read FSelfHeight;

    property XOffset: Cardinal read FXOffset;
    property YOffset: Cardinal read FYOffset;

    property DelayNum: Word read FDelayNum;
    property DelayDenum: Word read FDelayDenum;
    property DelayMS: Word read FDelayMS;

    property DisposeOp: Byte read FDisposeOp;
    property BlendOp: Byte read FBlendOp;

    function Clone : TPNGFrame;
{
    procedure AssignImage(Data: Pointer; DataSize: Cardinal);
    procedure AssignAlpha(Data: Pointer; DataSize: Cardinal);
{
    procedure AssignImageTo(var Dest: Pointer);
    procedure AssignAlphaTo(var Dest: Pointer);
}
    {Returns owner}
    property Owner: TPngObject read fOwner;
    {Being destroyed/created}
    constructor Create(Owner: TPngObject); virtual;
    destructor Destroy; override;

    function IsEmpty: Boolean;
    procedure FromHDR;
    procedure ToBitmap32(var B32:TBitmap);
    procedure PaletteToDIB(Palette: HPalette);
    procedure FreeImageData;
    procedure PrepareImageData();
  end;

  {Contains a list of objects}
  TPNGFrameList = class(TPNGPointerList)
  private
    {Used with property Item}
    function GetItem(Index: Cardinal): TPNGFrame;
    {Removes an item}
    procedure RemoveFrame(Frame: TPNGFrame); overload;
  public
    {Add a new chunk using the class from the parameter}
    function Add: TPNGFrame; overload;
    {Returns a chunk item from the list}
    property Item[Index: Cardinal]: TPNGFrame read GetItem;
  end;

  TAniPNG = class
    {Stores owner}
    fOwner: TPngObject;

    FCurrentFrame: Integer;
//    FImageWidth : Integer;
//    FImageHeight: Integer;
    fPicHeight  : Integer;
    FNumFrames: Integer;
    FNumIterations: Integer;

    Frames: TPNGFrameList;

//    BitmapInfo: TMaxBitmapInfo;

    CurrentIteration: Integer;
    LastTime: DWord;
    CurrentInterval: DWord;

    constructor Create(AOwner: TPNGObject); OverLoad;
    destructor Destroy; override;
    procedure clear;
    function getFullBitmap : TBitmap;
    function AddFrame : TPNGFrame;
    property Owner: TPNGObject read fOwner;
  end;

 {$ENDIF UseAnimation}

  {Forward declaration}
  TChunk = class;
  TChunkClass = class of TChunk;

  {Same as TPNGPointerList but providing typecasted values}
  TPNGList = class(TPNGPointerList)
  private
    {Used with property Item}
    function GetItem(Index: Cardinal): TChunk;
  public
    {Finds the first item with this class}
    function FindChunk(ChunkClass: TChunkClass): TChunk;
    {Removes an item}
    procedure RemoveChunk(Chunk: TChunk); overload;
    {Add a new chunk using the class from the parameter}
    function Add(ChunkClass: TChunkClass): TChunk;
    {Returns pointer to the first chunk of class}
    function ItemFromClass(ChunkClass: TChunkClass): TChunk;
    {Returns a chunk item from the list}
    property Item[Index: Cardinal]: TChunk read GetItem;
  end;

  {$IFNDEF UseDelphi}
    {The STREAMs bellow are only needed in case delphi provided ones is not}
    {avaliable (UseDelphi trigger not set)}
    {Object becomes handles}
    TCanvas = THandle;
//    TBitmap = HBitmap;
    {Trick to work}
    TPersistent = TObject;

    {Base class for all streams}
    TStream = class
    protected
      {Returning/setting size}
      function GetSize: Longint; virtual;
      procedure SetSize(const Value: Longint); virtual; abstract;
      {Returns/set position}
      function GetPosition: Longint; virtual;
      procedure SetPosition(const Value: Longint); virtual;
    public
      {Returns/sets current position}
      property Position: Longint read GetPosition write SetPosition;
      {Property returns/sets size}
      property Size: Longint read GetSize write SetSize;
      {Allows reading/writing data}
      function Read(var Buffer; Count: Longint): Cardinal; virtual; abstract;
      function Write(const Buffer; Count: Longint): Cardinal; virtual; abstract;
      {Copies from another Stream}
      function CopyFrom(Source: TStream;
        Count: Cardinal): Cardinal; virtual;
      {Seeks a stream position}
      function Seek(Offset: Longint; Origin: Word): Longint; virtual; abstract;
    end;

    {File stream modes}
    TFileStreamMode = (fsmRead, fsmWrite, fsmCreate);
    TFileStreamModeSet = set of TFileStreamMode;

    {File stream for reading from files}
    TFileStream = class(TStream)
    private
      {Opened mode}
      Filemode: TFileStreamModeSet;
      {Handle}
      fHandle: THandle;
    protected
      {Set the size of the file}
      procedure SetSize(const Value: Longint); override;
    public
      {Seeks a file position}
      function Seek(Offset: Longint; Origin: Word): Longint; override;
      {Reads/writes data from/to the file}
      function Read(var Buffer; Count: Longint): Cardinal; override;
      function Write(const Buffer; Count: Longint): Cardinal; override;
      {Stream being created and destroy}
      constructor Create(Filename: String; Mode: TFileStreamModeSet);
      destructor Destroy; override;
    end;

    {Stream for reading from resources}
    TResourceStream = class(TStream)
      constructor Create(Instance: HInst; const ResName: String; ResType:PChar);
    private
      {Variables for reading}
      Size: Integer;
      Memory: Pointer;
      Position: Integer;
    protected
      {Set the size of the file}
      procedure SetSize(const Value: Longint); override;
    public
      {Stream processing}
      function Read(var Buffer; Count: Integer): Cardinal; override;
      function Seek(Offset: Integer; Origin: Word): Longint; override;
      function Write(const Buffer; Count: Longint): Cardinal; override;
    end;
  {$ENDIF}

  {Forward}
  TChunkIHDR = class;
  TChunkpHYs = class;
  {Interlace method}
  TInterlaceMethod = (imNone, imAdam7);
  {Compression level type}
  TCompressionLevel = 0..9;
  {Filters type}
  TFilter = (pfNone, pfSub, pfUp, pfAverage, pfPaeth);
  TFilters = set of TFilter;

  {Png implementation object}

  TPngObject = class{$IFDEF isTGraphic}
                      (TGraphic)
                    {$ELSE }  
                      (TPersistent)
                    {$ENDIF}
  protected
    {Gamma table values}
    GammaTable,
    InverseGamma: Array[Byte] of Byte;
    procedure InitializeGamma;
  private
    FAnimated: Boolean;
 {$IFDEF UseAnimation}
    apng : TAniPNG;
//    FFramesCount: Integer;
//    FCurrentFrame: Integer;
//    FFrameList: TPNGFrameList;
 {$ENDIF UseAnimation}

//    ImagePalette: HPalette;
    {Output windows bitmap}
    HasPalette: Boolean;

    {Temporary palette}
    TempPalette: HPalette;
    {Filters to test to encode}
    fFilters: TFilters;
    {Compression level for ZLIB}
    fCompressionLevel: TCompressionLevel;
    {Maximum size for IDAT chunks}
    fMaxIdatSize: Cardinal;
    {Returns if image is interlaced}
    fInterlaceMethod: TInterlaceMethod;
    {Chunks object}
    fChunkList: TPngList;
    {Clear all chunks in the list}
    procedure ClearChunks;
    {Returns if header is present}
    function HeaderPresent: Boolean;
    {Returns linesize and byte offset for pixels}
    procedure GetPixelInfo(var LineSize, Offset: Cardinal);
    procedure SetMaxIdatSize(const Value: Cardinal);
    function GetAlphaScanline(const LineIndex: Integer): pByteArray;
    function GetScanline(const LineIndex: Integer): Pointer;
    {$IFDEF Store16bits}
    function GetExtraScanline(const LineIndex: Integer): Pointer;
    {$ENDIF}
    function GetPixelInformation: TChunkpHYs;
    function GetTransparencyMode: TPNGTransparencyMode;
    function GetTransparentColor: TColor;
    procedure SetTransparentColor(const Value: TColor);
 {$IFDEF UseAnimation}
    procedure SetCurrentFrame(const Value: Integer);
 {$ENDIF UseAnimation}
  protected
    BeingCreated: Boolean;
    {Creates a grayscale palette}
    function CreateGrayscalePalette(Bitdepth: Integer): HPalette;
    {Returns the image palette}
    function GetPalette: HPALETTE; {$IFDEF isTGraphic}override;{$ENDIF}
    {THANY: Sets a new palette}
    procedure SetPalette(Value: HPALETTE); {$IFDEF isTGraphic}override;{$ENDIF}
    procedure DoSetPalette(Value: HPALETTE; const UpdateColors: Boolean);
    {Returns/sets image width and height}
    function GetWidth: Integer; {$IFDEF isTGraphic}override;{$ENDIF}
    function GetHeight: Integer; {$IFDEF isTGraphic}override; {$ENDIF}
  {$IFDEF SavePicture}
    procedure SetWidth(Value: Integer);  {$IFDEF isTGraphic}override; {$ENDIF}
    procedure SetHeight(Value: Integer);  {$IFDEF isTGraphic}override;{$ENDIF}
  {$ENDIF SavePicture}
    {Assigns from another TPNGObject}
    procedure AssignPNG(Source: TPNGObject);
    {Returns if the image is empty}
    function GetEmpty: Boolean; {$IFDEF isTGraphic}override; {$ENDIF}
    {Used with property Header}
    function GetHeader: TChunkIHDR;
    {Draws using partial transparency}
    procedure DrawPartialTrans(DC: HDC; Rect: TRect);
    {$IFDEF UseDelphi2}
    {Returns if the image is transparent}
    function GetTransparent: Boolean; override;
    {$ENDIF}
    {Returns a pixel}
    {$IFDEF isTGraphic}
    function GetPixels(const X, Y: Integer): TColor; virtual;
    procedure SetPixels(const X, Y: Integer; const Value: TColor); virtual;
    {$ENDIF isTGraphic}
  public
    property Animated: Boolean read FAnimated;
 {$IFDEF UseAnimation}
    property AniPNG: TAniPNG read aPNG;
//    property FramesCount: Integer read FFramesCount;
//    property CurrentFrame: Integer read FCurrentFrame write SetCurrentFrame;

//    property FrameList: TPngFrameList read FFrameList;
 {$ENDIF UseAnimation}
  {$IFDEF SavePicture}
    {Resizes the PNG image}
    procedure Resize(const CX, CY: Integer);
  {$ENDIF SavePicture}
    {Generates alpha information}
    procedure CreateAlpha;
    {Removes the image transparency}
    procedure RemoveTransparency;
    {Transparent color}
    property TransparentColor: TColor read GetTransparentColor write
      SetTransparentColor;
    {Add text chunk, TChunkTEXT, TChunkzTXT}
    procedure AddtEXt(const Keyword, Text: AnsiString);
    procedure AddzTXt(const Keyword, Text: AnsiString);
    {$IFDEF UseDelphi2}
    {Saves to clipboard format (thanks to Antoine Pottern)}
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPalette); override;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPalette); override;
    {$ENDIF}
    {Calling errors}
    procedure RaiseError(ExceptionClass: ExceptClass; Text: String);
    {Returns a scanline from png}
    property Scanline[const Index: Integer]: Pointer read GetScanline;
    {$IFDEF Store16bits}
    property ExtraScanline[const Index: Integer]: Pointer read GetExtraScanline;
    {$ENDIF}
    {Used to return pixel information}
    function HasPixelInformation: Boolean;
    property PixelInformation: TChunkpHYs read GetPixelInformation;
    property AlphaScanline[const Index: Integer]: pByteArray read GetAlphaScanline;
    procedure DrawUsingPixelInformation(Canvas: TCanvas; Point: TPoint);
    {Returns pointer to the header}
    property Header: TChunkIHDR read GetHeader;
    {Returns the transparency mode used by this png}
    property TransparencyMode: TPNGTransparencyMode read GetTransparencyMode;
    {Assigns from another object}
    procedure Assign(Source: TPersistent);{$IFDEF UseDelphi}override;{$ENDIF}
    {Assigns to another object}
    procedure AssignTo(Dest: TPersistent);{$IFDEF UseDelphi}override;{$ENDIF}
  {$IFDEF SavePicture}
    {Assigns from a windows bitmap handle}
    procedure AssignHandle(Handle: HBitmap; Transparent: Boolean;
      TransparentColor: ColorRef);
  {$ENDIF SavePicture}
    {Draws the image into a canvas}
    procedure Draw(ACanvas: TCanvas; const Rect: TRect);
      {$IFDEF isTGraphic}override;{$ENDIF}
    {Width and height properties}
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    {Returns if the image is interlaced}
    property InterlaceMethod: TInterlaceMethod read fInterlaceMethod
      write fInterlaceMethod;
    {Filters to test to encode}
    property Filters: TFilters read fFilters write fFilters;
    {Maximum size for IDAT chunks, default and minimum is 65536}
    property MaxIdatSize: Cardinal read fMaxIdatSize write SetMaxIdatSize;
    {Property to return if the image is empty or not}
    property Empty: Boolean read GetEmpty;
    {Compression level}
    property CompressionLevel: TCompressionLevel read fCompressionLevel
      write fCompressionLevel;
    {Access to the chunk list}
    property Chunks: TPngList read fChunkList;
    {Object being created and destroyed}
    constructor Create; {$IFDEF isTGraphic}override;{$ENDIF}
  {$IFDEF SavePicture}
    constructor CreateBlank(ColorType, Bitdepth: Cardinal; cx, cy: Integer);
  {$ENDIF SavePicture}
    destructor Destroy; override;
    {$IFNDEF UseDelphi}procedure LoadFromFile(const Filename: String);{$ENDIF}
  {$IFDEF SavePicture}
    {$IFNDEF UseDelphi}procedure SaveToFile(const Filename: String);{$ENDIF}
  {$ENDIF SavePicture}
    procedure LoadFromStream(Stream: TStream); {$IFDEF isTGraphic}override;{$ENDIF}
  {$IFDEF SavePicture}
    procedure SaveToStream(Stream: TStream); {$IFDEF isTGraphic}override;{$ENDIF}
  {$ENDIF SavePicture}
    {$IFDEF isTGraphic}
    {Loading the image from resources}
    procedure LoadFromResourceName(Instance: HInst; const Name: String);
    procedure LoadFromResourceID(Instance: HInst; ResID: Integer);
    {Access to the png pixels}
    property Pixels[const X, Y: Integer]: TColor read GetPixels write SetPixels;
    {$ENDIF isTGraphic}
    {Palette property}
    {THANY: Palette is now writeable}
    { $IFNDEF UseDelphi}
    {$IFNDEF isTGraphic}
     property Palette: HPalette read GetPalette write SetPalette;
    {$ENDIF isTGraphic}
    { $ENDIF}
    procedure ToBitmap32(var B32:TBitmap);
  end;

  {Chunk name object}
  TChunkName = Array[0..3] of AnsiChar;

  {Global chunk object}
  TChunk = class
  private
    {Contains data}
    fData: Pointer;
    fDataSize: Cardinal;
    {Stores owner}
    fOwner: TPngObject;
    {Stores the chunk name}
    fName: TChunkName;
    {Returns pointer to the TChunkIHDR}
    function GetHeader: TChunkIHDR;
    {Used with property index}
    function GetIndex: Integer;
    {Should return chunk class/name}
    class function GetName: String; virtual;
    {Returns the chunk name}
    function GetChunkName: AnsiString;
  public
    {Returns index from list}
    property Index: Integer read GetIndex;
    {Returns pointer to the TChunkIHDR}
    property Header: TChunkIHDR read GetHeader;
    {Resize the data}
    procedure ResizeData(const NewSize: Cardinal);
    {Returns data and size}
    property Data: Pointer read fData;
    property DataSize: Cardinal read fDataSize;
    {Assigns from another TChunk}
    procedure Assign(Source: TChunk); virtual;
    {Returns owner}
    property Owner: TPngObject read fOwner;
    {Being destroyed/created}
    constructor Create(Owner: TPngObject); virtual;
    destructor Destroy; override;
    {Returns chunk class/name}
    property Name: AnsiString read GetChunkName;
    {Loads the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; virtual;
    {Saves the chunk to a stream}
  {$IFDEF SavePicture}
    function SaveData(Stream: TStream): Boolean;
    function SaveToStream(Stream: TStream): Boolean; virtual;
  {$ENDIF SavePicture}
  end;

  {Chunk classes}
  TChunkIEND = class(TChunk);     {End chunk}

{$ALIGN 1}
  {IHDR data}
  pIHDRData = ^TIHDRData;
  TIHDRData = packed record
    Width, Height: Cardinal;
    BitDepth,
    ColorType,
    CompressionMethod,
    FilterMethod,
    InterlaceMethod: Byte;
  end;
{$ALIGN ON}

  {Information header chunk}
  TChunkIHDR = class(TChunk)
  private
    {Current image}
    ImageHandle: HBitmap;
    ImageDC: HDC;
    ImagePalette: HPalette;
    {Output windows bitmap}
//    HasPalette: Boolean;
    BitmapInfo: TMaxBitmapInfo;
    {Stores the image bytes}
    fImageData: pointer;
    fImageAlpha: Pointer;
    {$IFDEF Store16bits}fExtraImageData: Pointer;{$ENDIF}

    {Contains all the ihdr data}
    IHDRData: TIHDRData;
  protected
    BytesPerRow: Integer;
    {Copies the palette to the Device Independent bitmap header}
    procedure PaletteToDIB(Palette: HPalette);
    {Resizes the image data to fill the color type, bit depth, }
    {width and height parameters}
    procedure PrepareImageData;
    {Release allocated ImageData memory}
    procedure FreeImageData;
  public
    {Access to ImageHandle}
    property ImageHandleValue: HBitmap read ImageHandle;
    {Properties}
    property Width: Cardinal read IHDRData.Width write IHDRData.Width;
    property Height: Cardinal read IHDRData.Height write IHDRData.Height;
    property BitDepth: Byte read IHDRData.BitDepth write IHDRData.BitDepth;
    property ColorType: Byte read IHDRData.ColorType write IHDRData.ColorType;
    property CompressionMethod: Byte read IHDRData.CompressionMethod
      write IHDRData.CompressionMethod;
    property FilterMethod: Byte read IHDRData.FilterMethod
      write IHDRData.FilterMethod;
    property InterlaceMethod: Byte read IHDRData.InterlaceMethod
      write IHDRData.InterlaceMethod;
    {Loads the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  {$IFDEF SavePicture}
    {Saves the chunk to a stream}
    function SaveToStream(Stream: TStream): Boolean; override;
  {$ENDIF SavePicture}
    {Destructor/constructor}
    constructor Create(Owner: TPngObject); override;
    destructor Destroy; override;
    {Assigns from another TChunk}
    procedure Assign(Source: TChunk); override;
  end;

  {pHYs chunk}
  pUnitType = ^TUnitType;
  TUnitType = (utUnknown, utMeter);
  TChunkpHYs = class(TChunk)
  private
    fPPUnitX, fPPUnitY: Cardinal;
    fUnit: TUnitType;
  public
    {Returns the properties}
    property PPUnitX: Cardinal read fPPUnitX write fPPUnitX;
    property PPUnitY: Cardinal read fPPUnitY write fPPUnitY;
    property UnitType: TUnitType read fUnit write fUnit;
    {Loads the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  {$IFDEF SavePicture}
    {Saves the chunk to a stream}
    function SaveToStream(Stream: TStream): Boolean; override;
  {$ENDIF SavePicture}
    {Assigns from another TChunk}
    procedure Assign(Source: TChunk); override;
  end;

  {Gamma chunk}
  TChunkgAMA = class(TChunk)
  private
    {Returns/sets the value for the gamma chunk}
    function GetValue: Cardinal;
    procedure SetValue(const Value: Cardinal);
  public
    {Returns/sets gamma value}
    property Gamma: Cardinal read GetValue write SetValue;
    {Loading the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
    {Being created}
    constructor Create(Owner: TPngObject); override;
    {Assigns from another TChunk}
    procedure Assign(Source: TChunk); override;
  end;

  {$IFDEF FPC}
  TZStreamRec = z_stream;
  {$ENDIF}

  {ZLIB Decompression extra information}
  TZStreamRec2 = packed record
    {From ZLIB}
    ZLIB: TZStreamRec;
    {Additional info}
    Data: Pointer;
    fStream   : TStream;
  end;

  {Palette chunk}
  TChunkPLTE = class(TChunk)
  protected
    {Number of items in the palette}
    fCount: Integer;
  private
    {Contains the palette handle}
    function GetPaletteItem(Index: Byte): TRGBQuad;
  public
    {Returns the color for each item in the palette}
    property Item[Index: Byte]: TRGBQuad read GetPaletteItem;
    {Returns the number of items in the palette}
    property Count: Integer read fCount;
    {Loads the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  {$IFDEF SavePicture}
    {Saves the chunk to a stream}
    function SaveToStream(Stream: TStream): Boolean; override;
  {$ENDIF SavePicture}
    {Assigns from another TChunk}
    procedure Assign(Source: TChunk); override;
  end;

  {Transparency information}
  TChunktRNS = class(TChunk)
  private
    fBitTransparency: Boolean;
    function GetTransparentColor: ColorRef;
    {Returns the transparent color}
    procedure SetTransparentColor(const Value: ColorRef);
  public
    {Palette values for transparency}
    PaletteValues: Array[Byte] of Byte;
    {Returns if it uses bit transparency}
    property BitTransparency: Boolean read fBitTransparency;
    {Returns the transparent color}
    property TransparentColor: ColorRef read GetTransparentColor write
      SetTransparentColor;
    {Loads/saves the chunk from/to a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  {$IFDEF SavePicture}
    function SaveToStream(Stream: TStream): Boolean; override;
  {$ENDIF SavePicture}
    {Assigns from another TChunk}
    procedure Assign(Source: TChunk); override;
  end;

  {Actual image information}
  TChunkIDAT = class(TChunk)
  private
    {Holds another pointer to the TChunkIHDR}
    Header: TChunkIHDR;

    frmImageData, frmImageAlpha : pByte;
    frmBytesPerRow : Cardinal;
    {Stores temporary image width and height}
    frmWidth, frmHeight: Integer;

    {Size in bytes of each line and offset}
    Row_Bytes, Offset : Cardinal;
    {Contains data for the lines}
  {$IFDEF SavePicture}
    Encode_Buffer: Array[0..5] of pByteArray;
  {$ENDIF SavePicture}
    Row_Buffer: Array[Boolean] of pByteArray;
    {Variable to invert the Row_Buffer used}
    RowUsed: Boolean;
    {Ending position for the current IDAT chunk}
    EndPos: Integer;
    {Filter the current line}
    procedure FilterRow;
  {$IFDEF SavePicture}
    {Filter to encode and returns the best filter}
    function FilterToEncode: Byte;
  {$ENDIF SavePicture}
    {Reads ZLIB compressed data}
    function IDATZlibRead(var ZLIBStream: TZStreamRec2; Buffer: Pointer;
      Count: Integer; var EndPos: Integer; var crcfile: Cardinal): Integer; Virtual;
  {$IFDEF SavePicture}
    {Compress and writes IDAT data}
    procedure IDATZlibWrite(var ZLIBStream: TZStreamRec2; Buffer: Pointer;
      const Length: Cardinal); Virtual;
    procedure FinishIDATZlib(var ZLIBStream: TZStreamRec2);
  {$ENDIF SavePicture}
    {Prepares the palette}
    procedure PreparePalette;
  protected
    {Decode interlaced image}
    procedure DecodeInterlacedAdam7(Stream: TStream;
      var ZLIBStream: TZStreamRec2; const Size: Integer; var crcfile: Cardinal);
    {Decode non interlaced imaged}
    procedure DecodeNonInterlaced(Stream: TStream;
      var ZLIBStream: TZStreamRec2; const Size: Integer;
      var crcfile: Cardinal);
  protected
  {$IFDEF SavePicture}
    {Encode non interlaced images}
    procedure EncodeNonInterlaced(Stream: TStream;
      var ZLIBStream: TZStreamRec2);
    {Encode interlaced images}
    procedure EncodeInterlacedAdam7(Stream: TStream;
      var ZLIBStream: TZStreamRec2);
  {$ENDIF SavePicture}
  protected
    {Memory copy methods to decode}
    procedure CopyNonInterlacedRGB8(
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyNonInterlacedRGB16(
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyNonInterlacedPalette148(
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyNonInterlacedPalette2(
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyNonInterlacedGray2(
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyNonInterlacedGrayscale16(
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyNonInterlacedRGBAlpha8(
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyNonInterlacedRGBAlpha16(
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyNonInterlacedGrayscaleAlpha8(
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyNonInterlacedGrayscaleAlpha16(
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyInterlacedRGB8(const Pass: Byte;
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyInterlacedRGB16(const Pass: Byte;
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyInterlacedPalette148(const Pass: Byte;
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyInterlacedPalette2(const Pass: Byte;
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyInterlacedGray2(const Pass: Byte;
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyInterlacedGrayscale16(const Pass: Byte;
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyInterlacedRGBAlpha8(const Pass: Byte;
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyInterlacedRGBAlpha16(const Pass: Byte;
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyInterlacedGrayscaleAlpha8(const Pass: Byte;
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
    procedure CopyInterlacedGrayscaleAlpha16(const Pass: Byte;
      Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
  protected
    {Memory copy methods to encode}
  {$IFDEF SavePicture}
    procedure EncodeNonInterlacedRGB8(Src, Dest, Trans: pByte);
    procedure EncodeNonInterlacedRGB16(Src, Dest, Trans: pByte);
    procedure EncodeNonInterlacedGrayscale16(Src, Dest, Trans: pByte);
    procedure EncodeNonInterlacedPalette148(Src, Dest, Trans: pByte);
    procedure EncodeNonInterlacedRGBAlpha8(Src, Dest, Trans: pByte);
    procedure EncodeNonInterlacedRGBAlpha16(Src, Dest, Trans: pByte);
    procedure EncodeNonInterlacedGrayscaleAlpha8(Src, Dest, Trans: pByte);
    procedure EncodeNonInterlacedGrayscaleAlpha16(Src, Dest, Trans: pByte);
    procedure EncodeInterlacedRGB8(const Pass: Byte; Src, Dest, Trans: pByte);
    procedure EncodeInterlacedRGB16(const Pass: Byte; Src, Dest, Trans: pByte);
    procedure EncodeInterlacedPalette148(const Pass: Byte;
      Src, Dest, Trans: pByte);
    procedure EncodeInterlacedGrayscale16(const Pass: Byte;
      Src, Dest, Trans: pByte);
    procedure EncodeInterlacedRGBAlpha8(const Pass: Byte;
      Src, Dest, Trans: pByte);
    procedure EncodeInterlacedRGBAlpha16(const Pass: Byte;
      Src, Dest, Trans: pByte);
    procedure EncodeInterlacedGrayscaleAlpha8(const Pass: Byte;
      Src, Dest, Trans: pByte);
    procedure EncodeInterlacedGrayscaleAlpha16(const Pass: Byte;
      Src, Dest, Trans: pByte);
  {$ENDIF SavePicture}
  public
    {Loads the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  {$IFDEF SavePicture}
    {Saves the chunk to a stream}
    function SaveToStream(Stream: TStream): Boolean; override;
  {$ENDIF SavePicture}
  end;

  //**************************************************************************//

 {$IFDEF UseAnimation}
  {The Animation Control Chunk}
  TChunkacTL = class(TChunk)
    Fnum_frames : UInt32;
    Fnum_plays  : UInt32;
  public
    {Loading the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  end;

  {The Frame Control Chunk}
  TChunkfcTL = class(TChunk)
  private
    FSelfWidth: Cardinal;
    FSelfHeight: Cardinal;

    FXOffset: Cardinal;
    FYOffset: Cardinal;

    FDelayNum: Word;
    FDelayDenum: Word;

    FDisposeOp: Byte;
    FBlendOp: Byte;
  public
    property SelfWidth: Cardinal read FSelfWidth;
    property SelfHeight: Cardinal read FSelfHeight;

    property XOffset: Cardinal read FXOffset;
    property YOffset: Cardinal read FYOffset;

    property DelayNum: Word read FDelayNum;
    property DelayDenum: Word read FDelayDenum;

    property DisposeOp: Byte read FDisposeOp;
    property BlendOp: Byte read FBlendOp;

    {Loading the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  end;

  {Frame image information}
  TChunkfdAT = class(TChunkIDAT)
  public
    Sequence: Cardinal;
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  protected
    function IDATZlibRead(var ZLIBStream: TZStreamRec2; Buffer: Pointer;
      Count: Integer; var EndPos: Integer; var crcfile: Cardinal): Integer; override;
  {$IFDEF SavePicture}
    {Compress and writes IDAT data}
    procedure IDATZlibWrite(var ZLIBStream: TZStreamRec2; Buffer: Pointer;
      const Length: Cardinal); override;
  {$ENDIF SavePicture}
  end;
 {$ENDIF UseAnimation}

  //**************************************************************************//

  {Image last modification chunk}
  TChunktIME = class(TChunk)
  private
    {Holds the variables}
    fYear: Word;
    fMonth, fDay, fHour, fMinute, fSecond: Byte;
  public
    {Returns/sets variables}
    property Year: Word read fYear write fYear;
    property Month: Byte read fMonth write fMonth;
    property Day: Byte read fDay write fDay;
    property Hour: Byte read fHour write fHour;
    property Minute: Byte read fMinute write fMinute;
    property Second: Byte read fSecond write fSecond;
    {Loads the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  {$IFDEF SavePicture}
    {Saves the chunk to a stream}
    function SaveToStream(Stream: TStream): Boolean; override;
  {$ENDIF SavePicture}
    {Assigns from another TChunk}
    procedure Assign(Source: TChunk); override;
  end;

  {Textual data}
  TChunktEXt = class(TChunk)
  private
    fKeyword, fText: AnsiString;
  public
    {Keyword and text}
    property Keyword: AnsiString read fKeyword write fKeyword;
    property Text: AnsiString read fText write fText;
    {Loads the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  {$IFDEF SavePicture}
    {Saves the chunk to a stream}
    function SaveToStream(Stream: TStream): Boolean; override;
  {$ENDIF SavePicture}
    {Assigns from another TChunk}
    procedure Assign(Source: TChunk); override;
  end;

  {zTXT chunk}
  TChunkzTXt = class(TChunktEXt)
    {Loads the chunk from a stream}
    function LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
      Size: Integer): Boolean; override;
  {$IFDEF SavePicture}
    {Saves the chunk to a stream}
    function SaveToStream(Stream: TStream): Boolean; override;
  {$ENDIF SavePicture}
  end;

{Here we test if it's c++ builder or delphi version 3 or less}
{$IFDEF VER110}{$DEFINE DelphiBuilder3Less}{$ENDIF}
{$IFDEF VER100}{$DEFINE DelphiBuilder3Less}{$ENDIF}
{$IFDEF VER93}{$DEFINE DelphiBuilder3Less}{$ENDIF}
{$IFDEF VER90}{$DEFINE DelphiBuilder3Less}{$ENDIF}
{$IFDEF VER80}{$DEFINE DelphiBuilder3Less}{$ENDIF}


{Registers a new chunk class}
//procedure RegisterChunk(ChunkClass: TChunkClass);
{Calculates crc}
//function update_crc(crc: {$IFNDEF DelphiBuilder3Less}Cardinal{$ELSE}Integer
//  {$ENDIF}; buf: pByteArray; len: Integer): Cardinal;
{Invert bytes using assembly}
function ByteSwap(const a: integer): integer;

implementation

var
  ChunkClasses: TPngPointerList;
  {Table of CRCs of all 8-bit messages}
//  crc_table: Array[0..255] of Cardinal;
  {Flag: has the table been computed? Initially false}
//  crc_table_computed: Boolean;

{Draw transparent image using transparent color}
procedure DrawTransparentBitmap(dc: HDC; srcBits: Pointer;
  var srcHeader: TBitmapInfoHeader;
  srcBitmapInfo: pBitmapInfo; Rect: TRect; cTransparentColor: COLORREF);
var
  cColor:   COLORREF;
  bmAndBack, bmAndObject, bmAndMem: HBITMAP;
  bmBackOld, bmObjectOld, bmMemOld: HBITMAP;
  hdcMem, hdcBack, hdcObject, hdcTemp: HDC;
  ptSize, orgSize: TPOINT;
  OldBitmap, DrawBitmap: HBITMAP;
begin
  hdcTemp := CreateCompatibleDC(dc);
  // Select the bitmap
  DrawBitmap := CreateDIBitmap(dc, srcHeader, CBM_INIT, srcBits, srcBitmapInfo^,
    DIB_RGB_COLORS);
  OldBitmap := SelectObject(hdcTemp, DrawBitmap);

  // Sizes
  OrgSize.x := abs(srcHeader.biWidth);
  OrgSize.y := abs(srcHeader.biHeight);
  ptSize.x := Rect.Right - Rect.Left;        // Get width of bitmap
  ptSize.y := Rect.Bottom - Rect.Top;        // Get height of bitmap

  // Create some DCs to hold temporary data.
  hdcBack  := CreateCompatibleDC(dc);
  hdcObject := CreateCompatibleDC(dc);
  hdcMem   := CreateCompatibleDC(dc);

  // Create a bitmap for each DC. DCs are required for a number of
  // GDI functions.

  // Monochrome DCs
  bmAndBack  := CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);
  bmAndObject := CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);

  bmAndMem   := CreateCompatibleBitmap(dc, ptSize.x, ptSize.y);

  // Each DC must select a bitmap object to store pixel data.
  bmBackOld  := SelectObject(hdcBack, bmAndBack);
  bmObjectOld := SelectObject(hdcObject, bmAndObject);
  bmMemOld   := SelectObject(hdcMem, bmAndMem);

  // Set the background color of the source DC to the color.
  // contained in the parts of the bitmap that should be transparent
  cColor := SetBkColor(hdcTemp, cTransparentColor);

  // Create the object mask for the bitmap by performing a BitBlt
  // from the source bitmap to a monochrome bitmap.
  StretchBlt(hdcObject, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0,
    orgSize.x, orgSize.y, SRCCOPY);

  // Set the background color of the source DC back to the original
  // color.
  SetBkColor(hdcTemp, cColor);

  // Create the inverse of the object mask.
  BitBlt(hdcBack, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0,
       NOTSRCCOPY);

  // Copy the background of the main DC to the destination.
  BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, dc, Rect.Left, Rect.Top,
       SRCCOPY);

  // Mask out the places where the bitmap will be placed.
  BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, SRCAND);

  // Mask out the transparent colored pixels on the bitmap.
//  BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcBack, 0, 0, SRCAND);
  StretchBlt(hdcTemp, 0, 0, OrgSize.x, OrgSize.y, hdcBack, 0, 0,
    PtSize.x, PtSize.y, SRCAND);

  // XOR the bitmap with the background on the destination DC.
  StretchBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0,
    OrgSize.x, OrgSize.y, SRCPAINT);

  // Copy the destination to the screen.
  BitBlt(dc, Rect.Left, Rect.Top, ptSize.x, ptSize.y, hdcMem, 0, 0,
       SRCCOPY);

  // Delete the memory bitmaps.
  DeleteObject(SelectObject(hdcBack, bmBackOld));
  DeleteObject(SelectObject(hdcObject, bmObjectOld));
  DeleteObject(SelectObject(hdcMem, bmMemOld));
  DeleteObject(SelectObject(hdcTemp, OldBitmap));

  // Delete the memory DCs.
  DeleteDC(hdcMem);
  DeleteDC(hdcBack);
  DeleteDC(hdcObject);
  DeleteDC(hdcTemp);
end;

{Make the table for a fast CRC.}
(*
procedure make_crc_table;
var
  c: Cardinal;
  n, k: Integer;
begin

  {fill the crc table}
  for n := 0 to 255 do
  begin
    c := Cardinal(n);
    for k := 0 to 7 do
    begin
      if Boolean(c and 1) then
        c := $edb88320 xor (c shr 1)
      else
        c := c shr 1;
    end;
    crc_table[n] := c;
  end;

  {The table has already being computated}
  crc_table_computed := true;
end;

{Update a running CRC with the bytes buf[0..len-1]--the CRC
 should be initialized to all 1's, and the transmitted value
 is the 1's complement of the final running CRC (see the
 crc() routine below)).}
function update_crc(crc: {$IFNDEF DelphiBuilder3Less}Cardinal{$ELSE}Integer
  {$ENDIF}; buf: pByteArray; len: Integer): Cardinal;
var
  c: Cardinal;
  n: Integer;
begin
  c := crc;

  {Create the crc table in case it has not being computed yet}
  if not crc_table_computed then make_crc_table;

  {Update}
  for n := 0 to len - 1 do
    c := crc_table[(c XOR buf^[n]) and $FF] XOR (c shr 8);

  {Returns}
  Result := c;
end;

{$IFNDEF UseDelphi}
  function FileExists(Filename: String): Boolean;
  var
    FindFile: THandle;
    FindData: TWin32FindData;
  begin
    FindFile := FindFirstFile(PChar(Filename), FindData);
    Result := FindFile <> INVALID_HANDLE_VALUE;
    if Result then Windows.FindClose(FindFile);
  end;


{$ENDIF}

{$IFNDEF UseDelphi}
  {Exception implementation}
  constructor Exception.Create(Msg: String);
  begin
  end;
{$ENDIF}
*)
{Calculates the paeth predictor}
function PaethPredictor(a, b, c: Byte): Byte;
var
  pa, pb, pc: Integer;
begin
  { a = left, b = above, c = upper left }
  pa := abs(b - c);      { distances to a, b, c }
  pb := abs(a - c);
  pc := abs(a + b - c * 2);

  { return nearest of a, b, c, breaking ties in order a, b, c }
  if (pa <= pb) and (pa <= pc) then
    Result := a
  else
    if pb <= pc then
      Result := b
    else
      Result := c;
end;

{$IFDEF FPC}
function ByteSwap(const a: integer): integer;
begin
  PByte(@Result)[0] := PByte(@A)[3];
  PByte(@Result)[1] := PByte(@A)[2];
  PByte(@Result)[2] := PByte(@A)[1];
  PByte(@Result)[3] := PByte(@A)[0];
end;
{$ELSE}
{Invert bytes using assembly}
function ByteSwap(const a: integer): integer;
{$IFDEF PUREPASCAL OR FPC}
begin
  PByte(@Result)[0] := PByte(@A)[3];
  PByte(@Result)[1] := PByte(@A)[2];
  PByte(@Result)[2] := PByte(@A)[1];
  PByte(@Result)[3] := PByte(@A)[0];
end;
{$ELSE !PUREPASCAL}
{$IFDEF CPUX86}
asm
  BSWAP EAX
end;
{$ENDIF}
{$IFDEF CPUX64}
asm
  MOV   EAX, ECX
  BSWAP EAX
end;
{$ENDIF}
{$ENDIF PUREPASCAL}

{$ENDIF}
function ByteSwap16(inp:word): word; inline;
begin
  Result := Swap(inp);
end;
(*
function ByteSwap16(inp:word): word;
{$IFDEF PUREPASCAL}
begin
  PByte(@Result)[0] := PByte(@inp)[1];
  PByte(@Result)[1] := PByte(@inp)[0];
end;
{$ELSE !PUREPASCAL}
{$IFDEF CPUX86}
asm
  BSWAP EAX
  SHR   EAX, 16
end;
{$ENDIF}
{$IFDEF CPUX64}
asm
  MOV   EAX, ECX
  BSWAP EAX
  SHR   EAX, 16
end;
{$ENDIF}
{$ENDIF PUREPASCAL}
*)

{Calculates number of bytes for the number of pixels using the}
{color mode in the paramenter}
function BytesForPixels(const Pixels: Integer; const ColorType,
  BitDepth: Byte): Integer;
begin
  case ColorType of
    {Palette and grayscale contains a single value, for palette}
    {an value of size 2^bitdepth pointing to the palette index}
    {and grayscale the value from 0 to 2^bitdepth with color intesity}
    COLOR_GRAYSCALE, COLOR_PALETTE:
      Result := (Pixels * BitDepth + 7) div 8;
    {RGB contains 3 values R, G, B with size 2^bitdepth each}
    COLOR_RGB:
      Result := (Pixels * BitDepth * 3) div 8;
    {Contains one value followed by alpha value booth size 2^bitdepth}
    COLOR_GRAYSCALEALPHA:
      Result := (Pixels * BitDepth * 2) div 8;
    {Contains four values size 2^bitdepth, Red, Green, Blue and alpha}
    COLOR_RGBALPHA:
      Result := (Pixels * BitDepth * 4) div 8;
    else
      Result := 0;
  end {case ColorType}
end;

type
  pChunkClassInfo = ^TChunkClassInfo;
  TChunkClassInfo = record
    ClassName: TChunkClass;
  end;

{Register a chunk type}
procedure RegisterChunk(ChunkClass: TChunkClass);
var
  NewClass: pChunkClassInfo;
begin
  {In case the list object has not being created yet}
  if ChunkClasses = nil then ChunkClasses := TPngPointerList.Create(nil);

  {Add this new class}
  new(NewClass);
  NewClass^.ClassName := ChunkClass;
  ChunkClasses.Add(NewClass);
end;

{Free chunk class list}
procedure FreeChunkClassList;
var
  i: Integer;
begin
  if (ChunkClasses <> nil) then
  begin
    FOR i := 0 TO ChunkClasses.Count - 1 do
      Dispose(pChunkClassInfo(ChunkClasses.Item[i]));
    ChunkClasses.Free;
  end;
end;

{Registering of common chunk classes}
procedure RegisterCommonChunks;
begin
  {Important chunks}
  RegisterChunk(TChunkIEND);
  RegisterChunk(TChunkIHDR);
  RegisterChunk(TChunkIDAT);
  RegisterChunk(TChunkPLTE);
  RegisterChunk(TChunkgAMA);
  RegisterChunk(TChunktRNS);

  {Not so important chunks}
  RegisterChunk(TChunkpHYs);
  RegisterChunk(TChunktIME);
  RegisterChunk(TChunktEXt);
  RegisterChunk(TChunkzTXt);

 {$IFDEF UseAnimation}
  {Animated chunks}
  RegisterChunk(TChunkacTL);
  RegisterChunk(TChunkfcTL);
  RegisterChunk(TChunkfdAT);
 {$ENDIF UseAnimation}
end;

{Creates a new chunk of this class}
function CreateClassChunk(Owner: TPngObject; Name: TChunkName): TChunk;
var
  i       : Integer;
  thisChunk,
  NewChunk: TChunkClass;
begin
  {Looks for this chunk}
  NewChunk := TChunk;  {In case there is no registered class for this}

  {Looks for this class in all registered chunks}
  if Assigned(ChunkClasses) then
    FOR i := 0 TO ChunkClasses.Count - 1 DO
    begin
      thisChunk := pChunkClassInfo(ChunkClasses.Item[i])^.ClassName;
      if thisChunk.GetName = Name then
      begin
        NewChunk := thisChunk;
        break;
      end;
    end;

  {Returns chunk class}
  Result := NewChunk.Create(Owner);
  Result.fName := Name;
end;

{ZLIB support}

const
  ZLIBAllocate = High(Word);

{Initializes ZLIB for decompression}
function ZLIBInitInflate(Stream: TStream): TZStreamRec2;
begin
  {Fill record}
  Fillchar(Result, SIZEOF(TZStreamRec2), #0);

  {Set internal record information}
  with Result do
  begin
    GetMem(Data, ZLIBAllocate);
    fStream := Stream;
  end;

  {Init decompression}
  {$IFDEF FPC}
  InflateInit_(Result.zlib, @zlib_version[1], SIZEOF(z_stream));
  {$ELSE}
  InflateInit_(Result.zlib, zlib_version, SIZEOF(TZStreamRec));
  {$ENDIF}

end;

{Initializes ZLIB for compression}
function ZLIBInitDeflate(Stream: TStream;
  Level: TCompressionlevel; Size: Cardinal): TZStreamRec2;
begin
  {Fill record}
  Fillchar(Result, SIZEOF(TZStreamRec2), #0);

  {Set internal record information}
  with Result, ZLIB do
  begin
    GetMem(Data, Size);
    fStream := Stream;
    next_out := Data;
    avail_out := Size;
  end;

  {Inits compression}
  {$IFDEF FPC}
  deflateInit_(Result.zlib, Level, @zlib_version[1], sizeof(z_stream));
  {$ELSE ~FPC}
  deflateInit_(Result.zlib, Level, zlib_version, sizeof(TZStreamRec));
  {$ENDIF ~FPC}
end;

{Terminates ZLIB for compression}
procedure ZLIBTerminateDeflate(var ZLIBStream: TZStreamRec2);
begin
  {Terminates decompression}
  DeflateEnd(ZLIBStream.zlib);
  {Free internal record}
  FreeMem(ZLIBStream.Data, ZLIBAllocate);
end;

{Terminates ZLIB for decompression}
procedure ZLIBTerminateInflate(var ZLIBStream: TZStreamRec2);
begin
  {Terminates decompression}
  InflateEnd(ZLIBStream.zlib);
  {Free internal record}
  FreeMem(ZLIBStream.Data, ZLIBAllocate);
end;

{Decompresses ZLIB into a memory address}
function DecompressZLIB(const Input: Pointer; InputSize: Integer;
  var Output: Pointer; var OutputSize: Integer;
  var ErrorOutput: AnsiString): Boolean;
var
  StreamRec : TZStreamRec;
  Buffer    : Array[Byte] of Byte;
  InflateRet: Integer;
begin
  with StreamRec do
  begin
    {Initializes}
    Result := True;
    OutputSize := 0;

    {Prepares the data to decompress}
    FillChar(StreamRec, SizeOf(TZStreamRec), #0);
  {$IFDEF FPC}
    InflateInit_(StreamRec, @zlib_version[1], SIZEOF(z_stream));
  {$ELSE ~FPC}
    InflateInit_(StreamRec, zlib_version, SIZEOF(TZStreamRec));
  {$ENDIF}
    next_in := Input;
    avail_in := InputSize;

    {Decodes data}
    repeat
      {In case it needs an output buffer}
      if (avail_out = 0) then
      begin
        next_out := @Buffer;
        avail_out := SizeOf(Buffer);
      end {if (avail_out = 0)};

      {Decompress and put in output}
      InflateRet := inflate(StreamRec, 0);
      if (InflateRet = Z_STREAM_END) or (InflateRet = 0) then
      begin
        {Reallocates output buffer}
        inc(OutputSize, total_out);
        if Output = nil then
          GetMem(Output, OutputSize) else ReallocMem(Output, OutputSize);
        {Copies the new data}
        CopyMemory(Pointer(Longint(Output) + OutputSize - total_out),
          @Buffer, total_out);
      end {if (InflateRet = Z_STREAM_END) or (InflateRet = 0)}
      {Now tests for errors}
      else if InflateRet < 0 then
      begin
        Result := False;
        ErrorOutput := StreamRec.msg;
        InflateEnd(StreamRec);
        Exit;
      end {if InflateRet < 0}
    until InflateRet = Z_STREAM_END;

    {Terminates decompression}
    InflateEnd(StreamRec);
  end {with StreamRec}

end;

{Compresses ZLIB into a memory address}
function CompressZLIB(Input: Pointer; InputSize, CompressionLevel: Integer;
  var Output: Pointer; var OutputSize: Integer;
  var ErrorOutput: AnsiString): Boolean;
var
  StreamRec : TZStreamRec;
  Buffer    : Array[Byte] of Byte;
  DeflateRet: Integer;
begin
  with StreamRec do
  begin
    Result := True; {By default returns TRUE as everything might have gone ok}
    OutputSize := 0; {Initialize}
    {Prepares the data to compress}
    FillChar(StreamRec, SizeOf(TZStreamRec), #0);
  {$IFDEF FPC}
    DeflateInit_(StreamRec, CompressionLevel, @zlib_version[1], SIZEOF(z_stream));
  {$ELSE}
    DeflateInit_(StreamRec, CompressionLevel,zlib_version, SIZEOF(TZStreamRec));
  {$ENDIF}

    next_in := Input;
    avail_in := InputSize;

    while avail_in > 0 do
    begin
      {When it needs new buffer to stores the compressed data}
      if avail_out = 0 then
      begin
        {Restore buffer}
        next_out := @Buffer;
        avail_out := SizeOf(Buffer);
      end {if avail_out = 0};

      {Compresses}
      DeflateRet := deflate(StreamRec, Z_FINISH);

      if (DeflateRet = Z_STREAM_END) or (DeflateRet = 0) then
      begin
        {Updates the output memory}
        inc(OutputSize, total_out);
        if Output = nil then
          GetMem(Output, OutputSize) else ReallocMem(Output, OutputSize);

        {Copies the new data}
        CopyMemory(PByte(Output) + OutputSize - total_out,
          @Buffer, total_out);
      end {if (InflateRet = Z_STREAM_END) or (InflateRet = 0)}
      {Now tests for errors}
      else if DeflateRet < 0 then
      begin
        Result := False;
        ErrorOutput := StreamRec.msg;
        DeflateEnd(StreamRec);
        Exit;
      end {if InflateRet < 0}

    end {while avail_in > 0};

    {Finishes compressing}
    DeflateEnd(StreamRec);
  end {with StreamRec}

end;

{TPngPointerList implementation}

{Object being created}
constructor TPngPointerList.Create(AOwner: TPNGObject);
begin
  inherited Create; {Let ancestor work}
  {Holds owner}
  fOwner := AOwner;
  {Memory pointer not being used yet}
  fMemory := nil;
  {No items yet}
  fCount := 0;
end;

{Removes value from the list}
function TPngPointerList.Remove(Value: Pointer): Pointer;
var
  I, Position: Integer;
begin
  {Gets item position}
  Position := -1;
  FOR I := 0 TO Count - 1 DO
    if Value = Item[I] then Position := I;
  {In case a match was found}
  if Position >= 0 then
  begin
    Result := Item[Position]; {Returns pointer}
    {Remove item and move memory}
    Dec(fCount);
    if Position < Integer(FCount) then
      System.Move(fMemory^[Position + 1], fMemory^[Position],
      (Integer(fCount) - Position) * SizeOf(Pointer));
  end {if Position >= 0} else Result := nil
end;

{Add a new value in the list}
procedure TPngPointerList.Add(Value: Pointer);
begin
  Count := Count + 1;
  Item[Count - 1] := Value;
end;


{Object being destroyed}
destructor TPngPointerList.Destroy;
begin
  {Release memory if needed}
  if fMemory <> nil then
    FreeMem(fMemory, fCount * sizeof(Pointer));

  {Free things}
  inherited Destroy;
end;

{Returns one item from the list}
function TPngPointerList.GetItem(Index: Cardinal): Pointer;
begin
  if (Index <= Count - 1) then
    Result := fMemory[Index]
  else
    {In case it's out of bounds}
    Result := nil;
end;

{Inserts a new item in the list}
procedure TPngPointerList.Insert(Value: Pointer; Position: Cardinal);
begin
  if (Position < Count) or (Count = 0) then
  begin
    {Increase item count}
    SetSize(Count + 1);
    {Move other pointers}
    if Position < Count then
      System.Move(fMemory^[Position], fMemory^[Position + 1],
        (Count - Position - 1) * SizeOf(Pointer));
    {Sets item}
    Item[Position] := Value;
  end;
end;

{Sets one item from the list}
procedure TPngPointerList.SetItem(Index: Cardinal; const Value: Pointer);
begin
  {If index is in bounds, set value}
  if (Index <= Count - 1) then
    fMemory[Index] := Value
end;

{This method resizes the list}
procedure TPngPointerList.SetSize(const Size: Cardinal);
begin
  {Sets the size}
  if (fMemory = nil) and (Size > 0) then
    GetMem(fMemory, Size * SIZEOF(Pointer))
  else
    if Size > 0 then  {Only realloc if the new size is greater than 0}
      ReallocMem(fMemory, Size * SIZEOF(Pointer))
    else
    {In case user is resize to 0 items}
    begin
      FreeMem(fMemory);
      fMemory := nil;
    end;
  {Update count}
  fCount := Size;
end;

{TPNGList implementation}

{Finds the first chunk of this class}
function TPNGList.FindChunk(ChunkClass: TChunkClass): TChunk;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if Item[i] is ChunkClass then
    begin
      Result := Item[i];
      Break
    end
end;


{Removes an item}
procedure TPNGList.RemoveChunk(Chunk: TChunk);
begin
  Remove(Chunk);
  Chunk.Free
end;

{Add a new item}
function TPNGList.Add(ChunkClass: TChunkClass): TChunk;
var
  IHDR: TChunkIHDR;
  IEND: TChunkIEND;

  IDAT: TChunkIDAT;
  PLTE: TChunkPLTE;
begin
  Result := nil; {Default result}

  {Adding these is not allowed}
  if ((ChunkClass = TChunkIHDR) or (ChunkClass = TChunkIDAT) or
    (ChunkClass = TChunkPLTE) or (ChunkClass = TChunkIEND)) and not
    (Owner.BeingCreated) then
    fOwner.RaiseError(EPngError, EPNGCannotAddChunkText)
  {Two of these is not allowed}
  else if ((ChunkClass = TChunkgAMA) and (ItemFromClass(TChunkgAMA) <> nil)) or
     ((ChunkClass = TChunktRNS) and (ItemFromClass(TChunktRNS) <> nil)) or
     ((ChunkClass = TChunkpHYs) and (ItemFromClass(TChunkpHYs) <> nil)) then
    fOwner.RaiseError(EPngError, EPNGCannotAddChunkText)
  {There must have an IEND and IHDR chunk}
  else if ((ItemFromClass(TChunkIEND) = nil) or
    (ItemFromClass(TChunkIHDR) = nil)) and not Owner.BeingCreated then
    fOwner.RaiseError(EPngError, EPNGCannotAddInvalidImageText)
  else
  begin
    {Get common chunks}
    IHDR := ItemFromClass(TChunkIHDR) as TChunkIHDR;
    IEND := ItemFromClass(TChunkIEND) as TChunkIEND;
    {Create new chunk}
    Result := ChunkClass.Create(Owner);
    {Add to the list}
    if (ChunkClass = TChunkgAMA) or (ChunkClass = TChunkpHYs) or
      (ChunkClass = TChunkPLTE) then
      Insert(Result, IHDR.Index + 1)
    {Header and end}
    else if (ChunkClass = TChunkIEND) then
      Insert(Result, Count)
    else if (ChunkClass = TChunkIHDR) then
      Insert(Result, 0)
    {Transparency chunk (fix by Ian Boyd)}
    else if (ChunkClass = TChunktRNS) then
    begin
      {Transparecy chunk must be after PLTE; before IDAT}
      IDAT := ItemFromClass(TChunkIDAT) as TChunkIDAT;
      PLTE := ItemFromClass(TChunkPLTE) as TChunkPLTE;

      if Assigned(PLTE) then
        Insert(Result, PLTE.Index + 1)
      else if Assigned(IDAT) then
        Insert(Result, IDAT.Index)
      else
        Insert(Result, IHDR.Index + 1)
    end
    else {All other chunks}
      Insert(Result, IEND.Index);
  end {if}
end;

{Returns item from the list}
function TPNGList.GetItem(Index: Cardinal): TChunk;
begin
  Result := inherited GetItem(Index);
end;

{Returns first item from the list using the class from parameter}
function TPNGList.ItemFromClass(ChunkClass: TChunkClass): TChunk;
var
  i: Integer;
begin
  Result := nil; {Initial result}
  FOR i := 0 TO Count - 1 DO
    {Test if this item has the same class}
    if Item[i] is ChunkClass then
    begin
      {Returns this item and exit}
      Result := Item[i];
      break;
    end {if}
end;

{$IFNDEF UseDelphi}

  {TStream implementation}

  {Copies all from another stream}
  function TStream.CopyFrom(Source: TStream; Count: Cardinal): Cardinal;
  const
    MaxBytes = $f000;
  var
    Buffer:  PAnsiChar;
    BufSize, N: Cardinal;
  begin
    {If count is zero, copy everything from Source}
    if Count = 0 then
    begin
      Source.Seek(0, soFromBeginning);
      Count := Source.Size;
    end;

    Result := Count; {Returns the number of bytes readed}
    {Allocates memory}
    if Count > MaxBytes then BufSize := MaxBytes else BufSize := Count;
    GetMem(Buffer, BufSize);

    {Copy memory}
    while Count > 0 do
    begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.Read(Buffer^, N);
      Write(Buffer^, N);
      dec(Count, N);
    end;

    {Deallocates memory}
    FreeMem(Buffer, BufSize);
  end;

{Set current stream position}
procedure TStream.SetPosition(const Value: Longint);
begin
  Seek(Value, soFromBeginning);
end;

{Returns position}
function TStream.GetPosition: Longint;
begin
  Result := Seek(0, soFromCurrent);
end;

  {Returns stream size}
function TStream.GetSize: Longint;
  var
    Pos: Cardinal;
  begin
    Pos := Seek(0, soFromCurrent);
    Result := Seek(0, soFromEnd);
    Seek(Pos, soFromBeginning);
  end;

  {TFileStream implementation}

  {Filestream object being created}
  constructor TFileStream.Create(Filename: String; Mode: TFileStreamModeSet);
    {Makes file mode}
    function OpenMode: DWORD;
    begin
      Result := 0;
      if fsmRead in Mode then Result := GENERIC_READ;
      if (fsmWrite in Mode) or (fsmCreate in Mode) then
        Result := Result OR GENERIC_WRITE;
    end;
  const
    IsCreate: Array[Boolean] of Integer = (OPEN_ALWAYS, CREATE_ALWAYS);
  begin
    {Call ancestor}
    inherited Create;

    {Create handle}
    fHandle := CreateFile(PChar(Filename), OpenMode, FILE_SHARE_READ or
      FILE_SHARE_WRITE, nil, IsCreate[fsmCreate in Mode], 0, 0);
    {Store mode}
    FileMode := Mode;
  end;

  {Filestream object being destroyed}
  destructor TFileStream.Destroy;
  begin
    {Terminates file and close}
    if FileMode = [fsmWrite] then
      SetEndOfFile(fHandle);
    CloseHandle(fHandle);

    {Call ancestor}
    inherited Destroy;
  end;

  {Writes data to the file}
  function TFileStream.Write(const Buffer; Count: Longint): Cardinal;
  begin
    if not WriteFile(fHandle, Buffer, Count, Result, nil) then
      Result := 0;
  end;

  {Reads data from the file}
  function TFileStream.Read(var Buffer; Count: Longint): Cardinal;
  begin
    if not ReadFile(fHandle, Buffer, Count, Result, nil) then
      Result := 0;
  end;

  {Seeks the file position}
  function TFileStream.Seek(Offset: Integer; Origin: Word): Longint;
  begin
    Result := SetFilePointer(fHandle, Offset, nil, Origin);
  end;

  {Sets the size of the file}
  procedure TFileStream.SetSize(const Value: Longint);
  begin
    Seek(Value, soFromBeginning);
    SetEndOfFile(fHandle);
  end;

  {TResourceStream implementation}

  {Creates the resource stream}
  constructor TResourceStream.Create(Instance: HInst; const ResName: String;
    ResType: PChar);
  var
    ResID: HRSRC;
    ResGlobal: HGlobal;
  begin
    {Obtains the resource ID}
    ResID := FindResource(hInstance, PChar(ResName), RT_RCDATA);
    if ResID = 0 then raise EPNGError.Create('');
    {Obtains memory and size}
    ResGlobal := LoadResource(hInstance, ResID);
    Size := SizeOfResource(hInstance, ResID);
    Memory := LockResource(ResGlobal);
    if (ResGlobal = 0) or (Memory = nil) then EPNGError.Create('');
  end;


  {Setting resource stream size is not supported}
  procedure TResourceStream.SetSize(const Value: Integer);
  begin
  end;

  {Writing into a resource stream is not supported}
  function TResourceStream.Write(const Buffer; Count: Integer): Cardinal;
  begin
    Result := 0;
  end;

  {Reads data from the stream}
  function TResourceStream.Read(var Buffer; Count: Integer): Cardinal;
  begin
    //Returns data
    CopyMemory(@Buffer, PByte(Memory) + Position, Count);
    //Update position
    inc(Position, Count);
    //Returns
    Result := Count;
  end;

  {Seeks data}
  function TResourceStream.Seek(Offset: Integer; Origin: Word): Longint;
  begin
    {Move depending on the origin}
    case Origin of
      soFromBeginning: Position := Offset;
      soFromCurrent: inc(Position, Offset);
      soFromEnd: Position := Size + Offset;
    end;

    {Returns the current position}
    Result := Position;
  end;

{$ENDIF}

{TChunk implementation}

{Resizes the data}
procedure TChunk.ResizeData(const NewSize: Cardinal);
begin
  fDataSize := NewSize;
  ReallocMem(fData, NewSize + 1);
end;

{Returns index from list}
function TChunk.GetIndex: Integer;
var
  i: Integer;
begin
  Result := -1; {Avoiding warnings}
  {Searches in the list}
  FOR i := 0 TO Owner.Chunks.Count - 1 DO
    if Owner.Chunks.Item[i] = Self then
    begin
      {Found match}
      Result := i;
      exit;
    end {for i}
end;

{Returns pointer to the TChunkIHDR}
function TChunk.GetHeader: TChunkIHDR;
begin
  Result := Owner.Chunks.Item[0] as TChunkIHDR;
end;

{Assigns from another TChunk}
procedure TChunk.Assign(Source: TChunk);
begin
  {Copy properties}
  fName := Source.fName;
  {Set data size and realloc}
  ResizeData(Source.fDataSize);

  {Copy data (if there's any)}
  if fDataSize > 0 then CopyMemory(fData, Source.fData, fDataSize);
end;

{Chunk being created}
constructor TChunk.Create(Owner: TPngObject);
var
  ChunkName: AnsiString;
begin
  {Ancestor create}
  inherited Create;

  {If it's a registered class, set the chunk name based on the class}
  {name. For instance, if the class name is TChunkgAMA, the GAMA part}
  {will become the chunk name}
  ChunkName := System.Copy(ClassName, Length('TChunk') + 1, Length(ClassName));
  if Length(ChunkName) = 4 then CopyMemory(@fName[0], @ChunkName[1], 4);

  {Initialize data holder}
  GetMem(fData, 1);
  fDataSize := 0;
  {Record owner}
  fOwner := Owner;
end;

{Chunk being destroyed}
destructor TChunk.Destroy;
begin
  {Free data holder}
  FreeMem(fData, fDataSize + 1);
  {Let ancestor destroy}
  inherited Destroy;
end;

{Returns the chunk name 1}
function TChunk.GetChunkName: AnsiString;
begin
  Result := fName
end;

{Returns the chunk name 2}
class function TChunk.GetName: String;
begin
  {For avoid writing GetName for each TChunk descendent, by default for}
  {classes which don't declare GetName, it will look for the class name}
  {to extract the chunk kind. Example, if the class name is TChunkIEND }
  {this method extracts and returns IEND}
  Result := system.Copy(ClassName, Length('TChunk') + 1, Length(ClassName));
end;

  {$IFDEF SavePicture}
{Saves the data to the stream}
function TChunk.SaveData(Stream: TStream): Boolean;
var
  ChunkSize, ChunkCRC: Cardinal;
begin
  {First, write the size for the following data in the chunk}
  ChunkSize := ByteSwap(DataSize);
  Stream.Write(ChunkSize, 4);
  {The chunk name}
  Stream.Write(fName, 4);
  {If there is data for the chunk, write it}
  if DataSize > 0 then Stream.Write(Data^, DataSize);
  {Calculates and write CRC}
//  ChunkCRC := update_crc($ffffffff, @fName[0], 4);
//  ChunkCRC := Byteswap(update_crc(ChunkCRC, Data, DataSize) xor $ffffffff);
  ChunkCRC := Crc32($ffffffff,@fName[0],4);
  ChunkCRC:=Byteswap(Crc32(ChunkCRC,Data,DataSize) xor $ffffffff);
  Stream.Write(ChunkCRC, 4);

  {Returns that everything went ok}
  Result := TRUE;
end;

{Saves the chunk to the stream}
function TChunk.SaveToStream(Stream: TStream): Boolean;
begin
  Result := SaveData(Stream)
end;
  {$ENDIF SavePicture}


{Loads the chunk from a stream}
function TChunk.LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
  Size: Integer): Boolean;
var
  CheckCRC: Cardinal;
  {$IFDEF CheckCRC}RightCRC: Cardinal;{$ENDIF}
begin
  {Copies data from source}
  ResizeData(Size);
  if Size > 0 then Stream.Read(fData^, Size);
  {Reads CRC}
  Stream.Read(CheckCRC, 4);
  CheckCrc := ByteSwap(CheckCRC);

  {Check if crc readed is valid}
  {$IFDEF CheckCRC}
    RightCRC := update_crc($ffffffff, @ChunkName[0], 4);
    RightCRC := update_crc(RightCRC, fData, Size) xor $ffffffff;
    Result := RightCRC = CheckCrc;

    {Handle CRC error}
    if not Result then
    begin
      {In case it coult not load chunk}
      Owner.RaiseError(EPngInvalidCRC, EPngInvalidCRCText);
      exit;
    end
  {$ELSE}Result := TRUE; {$ENDIF}

end;

{TChunktIME implementation}

{Chunk being loaded from a stream}
function TChunktIME.LoadFromStream(Stream: TStream;
  const ChunkName: TChunkName; Size: Integer): Boolean;
begin
  {Let ancestor load the data}
  Result := inherited LoadFromStream(Stream, ChunkName, Size);
  if not Result or (Size <> 7) then exit; {Size must be 7}

  {Reads data}
  fYear := ((pByte(UIntPtr(Data) )^) * 256)+ (pByte(PByte(Data) + 1)^);
  fMonth := pByte(PByte(Data) + 2)^;
  fDay := pByte(PByte(Data) + 3)^;
  fHour := pByte(PByte(Data) + 4)^;
  fMinute := pByte(PByte(Data) + 5)^;
  fSecond := pByte(PByte(Data) + 6)^;
end;

{Assigns from another TChunk}
procedure TChunktIME.Assign(Source: TChunk);
begin
  fYear := TChunktIME(Source).fYear;
  fMonth := TChunktIME(Source).fMonth;
  fDay := TChunktIME(Source).fDay;
  fHour := TChunktIME(Source).fHour;
  fMinute := TChunktIME(Source).fMinute;
  fSecond := TChunktIME(Source).fSecond;
end;

  {$IFDEF SavePicture}
{Saving the chunk to a stream}
function TChunktIME.SaveToStream(Stream: TStream): Boolean;
begin
  {Update data}
  ResizeData(7);  {Make sure the size is 7}
  pWord(Data)^ := ByteSwap16(Year);
  pByte(PByte(Data) + 2)^ := Month;
  pByte(PByte(Data) + 3)^ := Day;
  pByte(PByte(Data) + 4)^ := Hour;
  pByte(PByte(Data) + 5)^ := Minute;
  pByte(PByte(Data) + 6)^ := Second;

  {Let inherited save data}
  Result := inherited SaveToStream(Stream);
end;
  {$ENDIF SavePicture}

{TChunkztXt implementation}

{Loading the chunk from a stream}
function TChunkzTXt.LoadFromStream(Stream: TStream;
  const ChunkName: TChunkName; Size: Integer): Boolean;
var
  ErrorOutput: AnsiString;
  CompressionMethod: Byte;
  Output: Pointer;
  OutputSize: Integer;
begin
  {Load data from stream and validate}
  Result := inherited LoadFromStream(Stream, ChunkName, Size);
  if not Result or (Size < 4) then exit;
  fKeyword := PAnsiChar(Data);  {Get keyword and compression method bellow}
  if UIntPtr(fKeyword) = 0 then
    CompressionMethod := pByte(Data)^
  else
    CompressionMethod := PByte(PByte(fKeyword) + Length(fKeyword))^;
  fText := '';

  {In case the compression is 0 (only one accepted by specs), reads it}
  if CompressionMethod = 0 then
  begin
    Output := nil;
    if DecompressZLIB(PAnsiChar(PByte(Data) + Length(fKeyword) + 2),
      Size - Length(fKeyword) - 2, Output, OutputSize, ErrorOutput) then
    begin
      SetLength(fText, OutputSize);
      CopyMemory(@fText[1], Output, OutputSize);
    end {if DecompressZLIB(...};
    FreeMem(Output);
  end {if CompressionMethod = 0}

end;

  {$IFDEF SavePicture}
{Saving the chunk to a stream}
function TChunkztXt.SaveToStream(Stream: TStream): Boolean;
var
  Output: Pointer;
  OutputSize: Integer;
  ErrorOutput: AnsiString;
begin
  Output := nil; {Initializes output}
  if fText = '' then fText := ' ';

  {Compresses the data}
  if CompressZLIB(@fText[1], Length(fText), Owner.CompressionLevel, Output,
    OutputSize, ErrorOutput) then
  begin
    {Size is length from keyword, plus a null character to divide}
    {plus the compression method, plus the length of the text (zlib compressed)}
    ResizeData(Length(fKeyword) + 2 + OutputSize);

    Fillchar(Data^, DataSize, #0);
    {Copies the keyword data}
    if Keyword <> '' then
      CopyMemory(Data, @fKeyword[1], Length(Keyword));
    {Compression method 0 (inflate/deflate)}
    PByte(PByte(Data) + Length(Keyword) + 1)^ := 0;
    if OutputSize > 0 then
      CopyMemory(PByte(Data) + Length(Keyword) + 2, Output, OutputSize);

    {Let ancestor calculate crc and save}
    Result := SaveData(Stream);
  end {if CompressZLIB(...} else Result := False;

  {Frees output}
  if Output <> nil then FreeMem(Output)
end;
  {$ENDIF SavePicture}

{TChunktEXt implementation}

{Assigns from another text chunk}
procedure TChunktEXt.Assign(Source: TChunk);
begin
  fKeyword := TChunktEXt(Source).fKeyword;
  fText := TChunktEXt(Source).fText;
end;

{Loading the chunk from a stream}
function TChunktEXt.LoadFromStream(Stream: TStream;
  const ChunkName: TChunkName; Size: Integer): Boolean;
begin
  {Load data from stream and validate}
  Result := inherited LoadFromStream(Stream, ChunkName, Size);
  if not Result or (Size < 3) then exit;
  {Get text}
  fKeyword := PAnsiChar(Data);
  SetLength(fText, Size - Length(fKeyword) - 1);
  CopyMemory(@fText[1], PByte(Data) + Length(fKeyword) + 1, Length(fText));
end;

  {$IFDEF SavePicture}
{Saving the chunk to a stream}
function TChunktEXt.SaveToStream(Stream: TStream): Boolean;
begin
  {Size is length from keyword, plus a null character to divide}
  {plus the length of the text}
  ResizeData(Length(fKeyword) + 1 + Length(fText));
  Fillchar(Data^, DataSize, #0);
  {Copy data}
  if Keyword <> '' then
    CopyMemory(Data, @fKeyword[1], Length(Keyword));
  if Text <> '' then
    CopyMemory(PByte(Data) + Length(Keyword) + 1, @fText[1],
      Length(Text));
  {Let ancestor calculate crc and save}
  Result := inherited SaveToStream(Stream);
end;
  {$ENDIF SavePicture}


{TChunkIHDR implementation}

{Chunk being created}
constructor TChunkIHDR.Create(Owner: TPngObject);
begin
  {Prepare pointers}
  ImageHandle := 0;
  ImagePalette := 0;
  ImageDC := 0;

  {Call inherited}
  inherited Create(Owner);
end;

{Chunk being destroyed}
destructor TChunkIHDR.Destroy;
begin
  {Free memory}
  FreeImageData();

  {Calls TChunk destroy}
  inherited Destroy;
end;

{Copies the palette}
procedure CopyPalette(Source: HPALETTE; Destination: HPALETTE);
var
  PaletteSize: Integer;
  Entries: Array[Byte] of TPaletteEntry;
begin
  PaletteSize := 0;
  if GetObject(Source, SizeOf(PaletteSize), @PaletteSize) = 0 then Exit;
  if PaletteSize = 0 then Exit;
  ResizePalette(Destination, PaletteSize);
  GetPaletteEntries(Source, 0, PaletteSize, Entries);
  SetPaletteEntries(Destination, 0, PaletteSize, Entries);
end;

{Assigns from another IHDR chunk}
procedure TChunkIHDR.Assign(Source: TChunk);
begin
  {Copy the IHDR data}
  if Source is TChunkIHDR then
  begin
    {Copy IHDR values}
    IHDRData := TChunkIHDR(Source).IHDRData;

    {Prepare to hold data by filling BitmapInfo structure and}
    {resizing ImageData and ImageAlpha memory allocations}
    PrepareImageData();

    {Copy image data}
    CopyMemory(fImageData, TChunkIHDR(Source).fImageData,
      BytesPerRow * Integer(Height));
    CopyMemory(fImageAlpha, TChunkIHDR(Source).fImageAlpha,
      Integer(Width) * Integer(Height));

    {Copy palette colors}
    BitmapInfo.bmiColors := TChunkIHDR(Source).BitmapInfo.bmiColors;
    {Copy palette also}
    CopyPalette(TChunkIHDR(Source).ImagePalette, ImagePalette);
  end
  else
    Owner.RaiseError(EPNGError, EPNGCannotAssignChunkText);
end;

{Release allocated image data}
procedure TChunkIHDR.FreeImageData;
begin
  {Free old image data}
  if ImageHandle <> 0  then DeleteObject(ImageHandle);
  if ImageDC     <> 0  then DeleteDC(ImageDC);
//  if fImageData <> nil then FreeMem(fImageData);
  if fImageAlpha <> nil then FreeMem(fImageAlpha);
  if ImagePalette <> 0 then DeleteObject(ImagePalette);
  {$IFDEF Store16bits}
  if fExtraImageData <> nil then FreeMem(fExtraImageData);
  {$ENDIF}
  ImageHandle := 0; ImageDC := 0; fImageAlpha := nil; fImageData := nil;
  ImagePalette := 0;
  {$IFDEF Store16bits} ExtraImageData := nil; {$ENDIF}
end;

{Chunk being loaded from a stream}
function TChunkIHDR.LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
  Size: Integer): Boolean;
begin
  {Let TChunk load it}
  Result := inherited LoadFromStream(Stream, ChunkName, Size);
  if not Result then Exit;

  {Now check values}
  {Note: It's recommended by png specification to make sure that the size}
  {must be 13 bytes to be valid, but some images with 14 bytes were found}
  {which could be loaded by internet explorer and other tools}
  if (fDataSize < SIZEOF(TIHdrData)) then
  begin
    {Ihdr must always have at least 13 bytes}
    Result := False;
    Owner.RaiseError(EPNGInvalidIHDR, EPNGInvalidIHDRText);
    exit;
  end;

  {Everything ok, reads IHDR}
  IHDRData := pIHDRData(fData)^;
  IHDRData.Width := ByteSwap(IHDRData.Width);
  IHDRData.Height := ByteSwap(IHDRData.Height);

  {The width and height must not be larger than 65535 pixels}
  if (IHDRData.Width > High(Word)) or (IHDRData.Height > High(Word)) then
  begin
    Result := False;
    Owner.RaiseError(EPNGSizeExceeds, EPNGSizeExceedsText);
    exit;
  end {if IHDRData.Width > High(Word)};
  {Compression method must be 0 (inflate/deflate)}
  if (IHDRData.CompressionMethod <> 0) then
  begin
    Result := False;
    Owner.RaiseError(EPNGUnknownCompression, EPNGUnknownCompressionText);
    exit;
  end;
  {Interlace must be either 0 (none) or 7 (adam7)}
  if (IHDRData.InterlaceMethod <> 0) and (IHDRData.InterlaceMethod <> 1) then
  begin
    Result := False;
    Owner.RaiseError(EPNGUnknownInterlace, EPNGUnknownInterlaceText);
    exit;
  end;

  {Updates owner properties}
  Owner.InterlaceMethod := TInterlaceMethod(IHDRData.InterlaceMethod);

  {Prepares data to hold image}
  PrepareImageData();
end;

  {$IFDEF SavePicture}
{Saving the IHDR chunk to a stream}
function TChunkIHDR.SaveToStream(Stream: TStream): Boolean;
begin
  {Ignore 2 bits images}
  if BitDepth = 2 then BitDepth := 4;

  {It needs to do is update the data with the IHDR data}
  {structure containing the write values}
  ResizeData(SizeOf(TIHDRData));
  pIHDRData(fData)^ := IHDRData;
  {..byteswap 4 byte types}
  pIHDRData(fData)^.Width := ByteSwap(pIHDRData(fData)^.Width);
  pIHDRData(fData)^.Height := ByteSwap(pIHDRData(fData)^.Height);
  {..update interlace method}
  pIHDRData(fData)^.InterlaceMethod := Byte(Owner.InterlaceMethod);
  {..and then let the ancestor SaveToStream do the hard work}
  Result := inherited SaveToStream(Stream);
end;
  {$ENDIF SavePicture}

{Creates a grayscale palette}
function TPNGObject.CreateGrayscalePalette(Bitdepth: Integer): HPalette;
var
  j: Integer;
  palEntries: TMaxLogPalette;
begin
  {Prepares and fills the strucutre}
  if Bitdepth = 16 then Bitdepth := 8;
  fillchar(palEntries, sizeof(palEntries), 0);
  palEntries.palVersion := $300;
  palEntries.palNumEntries := 1 shl Bitdepth;
  {Fill it with grayscale colors}
  for j := 0 to palEntries.palNumEntries - 1 do
  begin
    palEntries.palPalEntry[j].peRed  :=
      GammaTable[MulDiv(j, 255, palEntries.palNumEntries - 1)];
    palEntries.palPalEntry[j].peGreen := palEntries.palPalEntry[j].peRed;
    palEntries.palPalEntry[j].peBlue := palEntries.palPalEntry[j].peRed;
  end;
  {Creates and returns the palette}
  Result := CreatePalette(pLogPalette(@palEntries)^);
end;

{Copies the palette to the Device Independent bitmap header}
procedure TChunkIHDR.PaletteToDIB(Palette: HPalette);
var
  j: Integer;
  palEntries: TMaxLogPalette;
begin
  {Copy colors}
  Fillchar(palEntries, sizeof(palEntries), #0);
  BitmapInfo.bmiHeader.biClrUsed := GetPaletteEntries(Palette, 0, 256, palEntries.palPalEntry[0]);
  for j := 0 to BitmapInfo.bmiHeader.biClrUsed - 1 do
  begin
    BitmapInfo.bmiColors[j].rgbBlue  := palEntries.palPalEntry[j].peBlue;
    BitmapInfo.bmiColors[j].rgbRed   := palEntries.palPalEntry[j].peRed;
    BitmapInfo.bmiColors[j].rgbGreen := palEntries.palPalEntry[j].peGreen;
  end;
end;

{Resizes the image data to fill the color type, bit depth, }
{width and height parameters}
procedure TChunkIHDR.PrepareImageData();
  {Set the bitmap info}
  procedure SetInfo(const Bitdepth: Integer; const Palette: Boolean);
  begin

    {Copy if the bitmap contain palette entries}
//    HasPalette := Palette;
    Owner.HasPalette := Palette;
    {Initialize the structure with zeros}
    fillchar(BitmapInfo, sizeof(BitmapInfo), #0);
    {Fill the strucutre}
    with BitmapInfo.bmiHeader do
    begin
      biSize := sizeof(TBitmapInfoHeader);
      biHeight := Height;
      biWidth := Width;
      biPlanes := 1;
      biBitCount := BitDepth;
      biCompression := BI_RGB;
    end {with BitmapInfo.bmiHeader}
  end;
var
  bd : byte;
  sz : Integer;
begin
  {Prepare bitmap info header}
  Fillchar(BitmapInfo, sizeof(TMaxBitmapInfo), #0);
  {Release old image data}
  FreeImageData();

  {Obtain number of bits for each pixel}
  case ColorType of
    COLOR_GRAYSCALE, COLOR_PALETTE, COLOR_GRAYSCALEALPHA:
      case BitDepth of
        {These are supported by windows}
        1, 4, 8: bd := BitDepth;
        {2 bits for each pixel is not supported by windows bitmap}
        2      : bd := 4;
        {Also 16 bits (2 bytes) for each pixel is not supported}
        {and should be transormed into a 8 bit grayscale}
        16     : bd := 8;
      end;
    {Only 1 byte (8 bits) is supported}
    COLOR_RGB, COLOR_RGBALPHA: bd := 24;
  end {case ColorType};
  SetInfo(bd, not((ColorType=COLOR_RGB)or (ColorType=COLOR_RGBALPHA)));
  {Number of bytes for each scanline}
  BytesPerRow := (((BitmapInfo.bmiHeader.biBitCount * Width) + 31)
    and not 31) div 8;

  {Build array for alpha information, if necessary}
  if (ColorType = COLOR_RGBALPHA) or (ColorType = COLOR_GRAYSCALEALPHA) then
  begin
    sz := Integer(Width) * Integer(Height);
    GetMem(fImageAlpha, sz);
    FillChar(fImageAlpha^, sz, #0);
  end;

  {Build array for extra byte information}
  {$IFDEF Store16bits}
  if (BitDepth = 16) then
  begin
    GetMem(ExtraImageData, BytesPerRow * Integer(Height));
    FillChar(ExtraImageData^, BytesPerRow * Integer(Height), #0);
  end;
  {$ENDIF}

  {Creates the image to hold the data, CreateDIBSection does a better}
  {work in allocating necessary memory}
  ImageDC := CreateCompatibleDC(0);
  {$IFDEF UseDelphi2}Self.Owner.Canvas.Handle := ImageDC;{$ENDIF}

  {In case it is a palette image, create the palette}
  if Owner.HasPalette then
  begin
    {Create a standard palette}
    if ColorType = COLOR_PALETTE then
      ImagePalette := CreateHalfTonePalette(ImageDC)
    else
      ImagePalette := Owner.CreateGrayscalePalette(Bitdepth);
    ResizePalette(ImagePalette, 1 shl BitmapInfo.bmiHeader.biBitCount);
    BitmapInfo.bmiHeader.biClrUsed := 1 shl BitmapInfo.bmiHeader.biBitCount;
    SelectPalette(ImageDC, ImagePalette, False);
    RealizePalette(ImageDC);
    PaletteTODIB(ImagePalette);
  end;

  {Create the device independent bitmap}
  ImageHandle := CreateDIBSection(ImageDC, pBitmapInfo(@BitmapInfo)^,
    DIB_RGB_COLORS, fImageData, 0, 0);
  SelectObject(ImageDC, ImageHandle);

  {Clears the old palette (if any)}
  with Owner do
    if  TempPalette <> 0 then
    begin
      DeleteObject(TempPalette);
      TempPalette := 0;
    end {with Owner, if TempPalette <> 0};

  {Build array and allocate bytes for each row}
//  zeromemory(ImageData, BytesPerRow * Integer(Height));
  fillchar(fImageData^, BytesPerRow * Integer(Height), 0);
end;

{TChunktRNS implementation}

{$IFNDEF UseDelphi}
function CompareMem(P1, P2: pByte; const Size: Integer): Boolean;
var i: Integer;
begin
  Result := True;
  for i := 1 to Size do
  begin
    if P1^ <> P2^ then Result := False;
    inc(P1); inc(P2);
  end {for i}
end;
{$ENDIF}

{Sets the transpararent color}
procedure TChunktRNS.SetTransparentColor(const Value: ColorRef);
var
  i: Byte;
  LookColor: TRGBQuad;
begin
  {Clears the palette values}
  Fillchar(PaletteValues, SizeOf(PaletteValues), #0);
  {Sets that it uses bit transparency}
  fBitTransparency := True;


  {Depends on the color type}
  with Header do
    case ColorType of
      COLOR_GRAYSCALE:
      begin
        Self.ResizeData(2);
        pWord(@PaletteValues[0])^ := ByteSwap16(GetRValue(Value));
      end;
      COLOR_RGB:
      begin
        Self.ResizeData(6);
        pWord(@PaletteValues[0])^ := ByteSwap16(GetRValue(Value));
        pWord(@PaletteValues[2])^ := ByteSwap16(GetGValue(Value));
        pWord(@PaletteValues[4])^ := ByteSwap16(GetBValue(Value));
      end;
      COLOR_PALETTE:
      begin
        {Creates a RGBQuad to search for the color}
        LookColor.rgbRed := GetRValue(Value);
        LookColor.rgbGreen := GetGValue(Value);
        LookColor.rgbBlue := GetBValue(Value);
        {Look in the table for the entry}
        for i := 0 to BitmapInfo.bmiHeader.biClrUsed - 1 do
          if CompareMem(@BitmapInfo.bmiColors[i], @LookColor, 3) then
            Break;
        {Fill the transparency table}
        Fillchar(PaletteValues, i, 255);
        Self.ResizeData(i + 1)

      end
    end {case / with};

end;

{Returns the transparent color for the image}
function TChunktRNS.GetTransparentColor: ColorRef;
var
  PaletteChunk: TChunkPLTE;
  i: Integer;
  Value: Byte;
begin
  Result := 0; {Default: Unknown transparent color}

  {Depends on the color type}
  with Header do
    case ColorType of
      COLOR_GRAYSCALE:
      begin
        Value := BitmapInfo.bmiColors[PaletteValues[1]].rgbRed;
        Result := RGB(Value, Value, Value);
      end;
      COLOR_RGB:
        Result := RGB(fOwner.GammaTable[PaletteValues[1]],
        fOwner.GammaTable[PaletteValues[3]],
        fOwner.GammaTable[PaletteValues[5]]);
      COLOR_PALETTE:
      begin
        {Obtains the palette chunk}
        PaletteChunk := Owner.Chunks.ItemFromClass(TChunkPLTE) as TChunkPLTE;

        {Looks for an entry with 0 transparency meaning that it is the}
        {full transparent entry}
        for i := 0 to Self.DataSize - 1 do
          if PaletteValues[i] = 0 then
            with PaletteChunk.GetPaletteItem(i) do
            begin
              Result := RGB(rgbRed, rgbGreen, rgbBlue);
              break
            end
      end {COLOR_PALETTE}
    end {case Header.ColorType};
end;

  {$IFDEF SavePicture}
{Saving the chunk to a stream}
function TChunktRNS.SaveToStream(Stream: TStream): Boolean;
begin
  {Copy palette into data buffer}
  if DataSize <= 256 then
    CopyMemory(fData, @PaletteValues[0], DataSize);

  Result := inherited SaveToStream(Stream);
end;
  {$ENDIF SavePicture}

{Assigns from another chunk}
procedure TChunktRNS.Assign(Source: TChunk);
begin
  CopyMemory(@PaletteValues[0], @TChunkTrns(Source).PaletteValues[0], 256);
  fBitTransparency := TChunkTrns(Source).fBitTransparency;
  inherited Assign(Source);
end;

{Loads the chunk from a stream}
function TChunktRNS.LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
  Size: Integer): Boolean;
var
  i, Differ255: Integer;
begin
  {Let inherited load}
  Result := inherited LoadFromStream(Stream, ChunkName, Size);

  if not Result then Exit;

  {Make sure size is correct}
  if Size > 256 then Owner.RaiseError(EPNGInvalidPalette,
    EPNGInvalidPaletteText);

  {The unset items should have value 255}
  Fillchar(PaletteValues[0], 256, 255);
  {Copy the other values}
  CopyMemory(@PaletteValues[0], fData, Size);

  {Create the mask if needed}
  case Header.ColorType of
    {Mask for grayscale and RGB}
    COLOR_RGB, COLOR_GRAYSCALE: fBitTransparency := True;
    COLOR_PALETTE:
    begin
      Differ255 := 0; {Count the entries with a value different from 255}
      {Tests if it uses bit transparency}
      for i := 0 to Size - 1 do
        if PaletteValues[i] <> 255 then inc(Differ255);

      {If it has one value different from 255 it is a bit transparency}
      fBitTransparency := (Differ255 = 1);
    end {COLOR_PALETTE}
  end {case Header.ColorType};

end;

{Prepares the image palette}
procedure TChunkIDAT.PreparePalette;
var
  Entries: Word;
  j      : Integer;
  palEntries: TMaxLogPalette;
  val : byte;
begin
  {In case the image uses grayscale, build a grayscale palette}
  with Header do
    if (ColorType = COLOR_GRAYSCALE) or (ColorType = COLOR_GRAYSCALEALPHA) then
    begin
      {Calculate total number of palette entries}
      Entries := (1 shl Byte(BitmapInfo.bmiHeader.biBitCount));
      Fillchar(palEntries, sizeof(palEntries), #0);
      palEntries.palVersion := $300;
      palEntries.palNumEntries := Entries;

      FOR j := 0 TO Entries - 1 DO
        with palEntries.palPalEntry[j] do
        begin

          {Calculate each palette entry}
          val := fOwner.GammaTable[MulDiv(j, 255, Entries - 1)];
          peRed := val;
          peGreen := val;
          peBlue := val;
        end {with BitmapInfo.bmiColors[j]};
        Owner.SetPalette(CreatePalette(pLogPalette(@palEntries)^));
    end {if ColorType = COLOR_GRAYSCALE..., with Header}
end;

{Reads from ZLIB}
function TChunkIDAT.IDATZlibRead(var ZLIBStream: TZStreamRec2;
  Buffer: Pointer; Count: Integer; var EndPos: Integer;
  var crcfile: Cardinal): Integer;
var
  ProcResult : Integer;
  IDATHeader : Array[0..3] of AnsiChar;
  IDATCRC    : Cardinal;
begin
  {Uses internal record pointed by ZLIBStream to gather information}
  with ZLIBStream, ZLIBStream.zlib do
  begin
    {Set the buffer the zlib will read into}
    next_out := Buffer;
    avail_out := Count;

    {Decode until it reach the Count variable}
    while avail_out > 0 do
    begin
      {In case it needs more data and it's in the end of a IDAT chunk,}
      {it means that there are more IDAT chunks}
      while (fStream.Position = EndPos) and (avail_out > 0) and
        (avail_in = 0) do

//      if (fStream.Position = EndPos) and (avail_out > 0) and
//        (avail_in = 0) then
      begin
        {End this chunk by reading and testing the crc value}
        fStream.Read(IDATCRC, 4);

        {$IFDEF CheckCRC}
          if crcfile xor $ffffffff <> Cardinal(ByteSwap(IDATCRC)) then
          begin
            Result := -1;
            Owner.RaiseError(EPNGInvalidCRC, EPNGInvalidCRCText);
            exit;
          end;
        {$ENDIF}

        {Start reading the next chunk}
        fStream.Read(EndPos, 4);        {Reads next chunk size}
        fStream.Read(IDATHeader[0], 4); {Next chunk header}
        {It must be a IDAT chunk since image data is required and PNG}
        {specification says that multiple IDAT chunks must be consecutive}
        if IDATHeader <> 'IDAT' then
        begin
          Owner.RaiseError(EPNGMissingMultipleIDAT, EPNGMissingMultipleIDATText);
          result := -1;
          exit;
        end;

        {Calculate chunk name part of the crc}
        {$IFDEF CheckCRC}
          crcfile := update_crc($ffffffff, @IDATHeader[0], 4);
        {$ENDIF}
        EndPos := fStream.Position + ByteSwap(EndPos);
      end;


      {In case it needs compressed data to read from}
      if avail_in = 0 then
      begin
        {In case it's trying to read more than it is avaliable}
        if fStream.Position + ZLIBAllocate > EndPos then
          avail_in := fStream.Read(Data^, EndPos - fStream.Position)
         else
          avail_in := fStream.Read(Data^, ZLIBAllocate);
        {Update crc}
        {$IFDEF CheckCRC}
          crcfile := update_crc(crcfile, Data, avail_in);
        {$ENDIF}

        {In case there is no more compressed data to read from}
        if avail_in = 0 then
        begin
          Result := Cardinal(Count) - Cardinal(avail_out);
          Exit;
        end;

        {Set next buffer to read and record current position}
        next_in := Data;

      end {if avail_in = 0};

      ProcResult := inflate(zlib, 0);

      {In case the result was not sucessfull}
      if (ProcResult < 0) then
      begin
        Result := -1;
        Owner.RaiseError(EPNGZLIBError,
          EPNGZLIBErrorText + zliberrors[procresult]);
        exit;
      end;

    end {while avail_out > 0};

  end {with};

  {If everything gone ok, it returns the count bytes}
  Result := Count;
end;

{TChunkIDAT implementation}

const
  {Adam 7 interlacing values}
  RowStart: array[0..6] of Integer = (0, 0, 4, 0, 2, 0, 1);
  ColumnStart: array[0..6] of Integer = (0, 4, 0, 2, 0, 1, 0);
  RowIncrement: array[0..6] of Integer = (8, 8, 8, 4, 4, 2, 2);
  ColumnIncrement: array[0..6] of Integer = (8, 8, 4, 4, 2, 2, 1);

{Copy interlaced images with 1 byte for R, G, B}
procedure TChunkIDAT.CopyInterlacedRGB8(const Pass: Byte;
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
//  Dest := pByte(Longint(Dest) + Col * 3);
  Dest := Dest + Col * 3;
  repeat
    {Copy this row}
    Dest^ := fOwner.GammaTable[pByte(Src + 2)^]; inc(Dest);
    Dest^ := fOwner.GammaTable[pByte(Src + 1)^]; inc(Dest);
    Dest^ := fOwner.GammaTable[pByte(Src    )^]; inc(Dest);

    {Move to next column}
    inc(Src, 3);
    inc(Dest, ColumnIncrement[Pass] * 3 - 3);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= frmWidth;
end;

{Copy interlaced images with 2 bytes for R, G, B}
procedure TChunkIDAT.CopyInterlacedRGB16(const Pass: Byte;
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Dest := Dest + Col * 3;
  repeat
    {Copy this row}
    Dest^ := Owner.GammaTable[pByte(Src + 4)^]; inc(Dest);
    Dest^ := Owner.GammaTable[pByte(Src + 2)^]; inc(Dest);
    Dest^ := Owner.GammaTable[pByte(Src    )^]; inc(Dest);
    {$IFDEF Store16bits}
    {Copy extra pixel values}
    Extra^ := fOwner.GammaTable[pByte(Src + 5)^]; inc(Extra);
    Extra^ := fOwner.GammaTable[pByte(Src + 3)^]; inc(Extra);
    Extra^ := fOwner.GammaTable[pByte(Src + 1)^]; inc(Extra);
    {$ENDIF}

    {Move to next column}
    inc(Src, 6);
    inc(Dest, ColumnIncrement[Pass] * 3 - 3);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= frmWidth;
end;

{Copy нmages with palette using bit depths 1, 4 or 8}
procedure TChunkIDAT.CopyInterlacedPalette148(const Pass: Byte;
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
const
  BitTable: Array[1..8] of Integer = ($1, $3, 0, $F, 0, 0, 0, $FF);
  StartBit: Array[1..8] of Integer = (7 , 0 , 0, 4,  0, 0, 0, 0);
var
  CurBit, Col: Integer;
  Dest2: pByte;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  repeat
    {Copy data}
    CurBit := StartBit[Header.BitDepth];
    repeat
      {Adjust pointer to pixel byte bounds}
      Dest2 := Dest + (Header.BitDepth * Col) div 8;
      {Copy data}
      PByte(Dest2)^ := Byte(Dest2^) or
        ( ((Byte(Src^) shr CurBit) and BitTable[Header.BitDepth])
          shl (StartBit[Header.BitDepth] - (Col * Header.BitDepth mod 8)));

      {Move to next column}
      inc(Col, ColumnIncrement[Pass]);
      {Will read next bits}
      dec(CurBit, Header.BitDepth);
    until CurBit < 0;

    {Move to next byte in source}
    inc(Src);
  until Col >= frmWidth;
end;

{Copy нmages with palette using bit depth 2}
procedure TChunkIDAT.CopyInterlacedPalette2(const Pass: Byte; Src, Dest,
  Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  CurBit, Col: Integer;
  Dest2: pByte;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  repeat
    {Copy data}
    CurBit := 6;
    repeat
      {Adjust pointer to pixel byte bounds}
      Dest2 := Dest + Col div 2;
      {Copy data}
      PByte(Dest2)^ := Byte(Dest2^) or (((Byte(Src^) shr CurBit) and $3)
         shl (4 - (4 * Col) mod 8));
      {Move to next column}
      inc(Col, ColumnIncrement[Pass]);
      {Will read next bits}
      dec(CurBit, 2);
    until CurBit < 0;

    {Move to next byte in source}
    inc(Src);
  until Col >= frmWidth;
end;

{Copy нmages with grayscale using bit depth 2}
procedure TChunkIDAT.CopyInterlacedGray2(const Pass: Byte;
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  CurBit, Col: Integer;
  Dest2: pByte;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  repeat
    {Copy data}
    CurBit := 6;
    repeat
      {Adjust pointer to pixel byte bounds}
      Dest2 := Dest + Col div 2;
      {Copy data}
      PByte(Dest2)^ := Byte(Dest2^) or ((((Byte(Src^) shr CurBit) shl 2) and $F)
         shl (4 - (Col*4) mod 8));
      {Move to next column}
      inc(Col, ColumnIncrement[Pass]);
      {Will read next bits}
      dec(CurBit, 2);
    until CurBit < 0;

    {Move to next byte in source}
    inc(Src);
  until Col >= frmWidth;
end;

{Copy нmages with palette using 2 bytes for each pixel}
procedure TChunkIDAT.CopyInterlacedGrayscale16(const Pass: Byte;
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Dest := Dest + Col;
  repeat
    {Copy this row}
    Dest^ := Src^; inc(Dest);
    {$IFDEF Store16bits}
    Extra^ := PByte(Src + 1)^; inc(Extra);
    {$ENDIF}

    {Move to next column}
    inc(Src, 2);
    inc(Dest, ColumnIncrement[Pass] - 1);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= frmWidth;
end;

{Decodes interlaced RGB alpha with 1 byte for each sample}
procedure TChunkIDAT.CopyInterlacedRGBAlpha8(const Pass: Byte;
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Dest := Dest + Col * 3;
  Trans := Trans + Col;
  repeat
    {Copy this row and alpha value}
    Trans^ := pByte(Src + 3)^;
    Dest^ := fOwner.GammaTable[pByte(Src + 2)^]; inc(Dest);
    Dest^ := fOwner.GammaTable[pByte(Src + 1)^]; inc(Dest);
    Dest^ := fOwner.GammaTable[pByte(Src    )^]; inc(Dest);

    {Move to next column}
    inc(Src, 4);
    inc(Dest, ColumnIncrement[Pass] * 3 - 3);
    inc(Trans, ColumnIncrement[Pass]);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= frmWidth;
end;

{Decodes interlaced RGB alpha with 2 bytes for each sample}
procedure TChunkIDAT.CopyInterlacedRGBAlpha16(const Pass: Byte;
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Dest := Dest + Col * 3;
  Trans := Trans + Col;
  repeat
    {Copy this row and alpha value}
    Trans^ := pByte(Src + 6)^;
    PByte(Dest)^  := fOwner.GammaTable[pByte(Src + 4)^]; inc(Dest);
    PByte(Dest)^  := fOwner.GammaTable[pByte(Src + 2)^]; inc(Dest);
    PByte(Dest)^  := fOwner.GammaTable[pByte(Src    )^]; inc(Dest);
    {$IFDEF Store16bits}
    {Copy extra pixel values}
    Extra^ := fOwner.GammaTable[pByte(Src + 5)^]; inc(Extra);
    Extra^ := fOwner.GammaTable[pByte(Src + 3)^]; inc(Extra);
    Extra^ := fOwner.GammaTable[pByte(Src + 1)^]; inc(Extra);
    {$ENDIF}

    {Move to next column}
    inc(Src, 8);
    inc(Dest, ColumnIncrement[Pass] * 3 - 3);
    inc(Trans, ColumnIncrement[Pass]);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= frmWidth;
end;

{Decodes 8 bit grayscale image followed by an alpha sample}
procedure TChunkIDAT.CopyInterlacedGrayscaleAlpha8(const Pass: Byte;
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  Col: Integer;
begin
  {Get first column, pointers to the data and enter in loop}
  Col := ColumnStart[Pass];
  Dest := Dest + Col;
  Trans := Trans + Col;
  repeat
    {Copy this grayscale value and alpha}
    Dest^ := Src^;  inc(Src);
    Trans^ := Src^; inc(Src);

    {Move to next column}
    inc(Dest, ColumnIncrement[Pass]);
    inc(Trans, ColumnIncrement[Pass]);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= frmWidth;
end;

{Decodes 16 bit grayscale image followed by an alpha sample}
procedure TChunkIDAT.CopyInterlacedGrayscaleAlpha16(const Pass: Byte;
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  Col: Integer;
begin
  {Get first column, pointers to the data and enter in loop}
  Col := ColumnStart[Pass];
  Dest := Dest + Col;
  Trans := Trans + Col;
  repeat
    {$IFDEF Store16bits}
    Extra^ := pByte(Src + 1)^; inc(Extra);
    {$ENDIF}
    {Copy this grayscale value and alpha, transforming 16 bits into 8}
    Dest^ := Src^;  inc(Src, 2);
    Trans^ := Src^; inc(Src, 2);

    {Move to next column}
    inc(Dest, ColumnIncrement[Pass]);
    inc(Trans, ColumnIncrement[Pass]);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= frmWidth;
end;

{Decodes an interlaced image}
procedure TChunkIDAT.DecodeInterlacedAdam7(Stream: TStream;
  var ZLIBStream: TZStreamRec2; const Size: Integer; var crcfile: Cardinal);
var
  CurrentPass: Byte;
  PixelsThisRow: Integer;
  CurrentRow: Integer;
  Trans, Data{$IFDEF Store16bits}, Extra{$ENDIF}: pByte;
  CopyProc: procedure(const Pass: Byte; Src, Dest,
    Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte) of object;
begin

  CopyProc := nil; {Initialize}
  {Determine method to copy the image data}
  case Header.ColorType of
    {R, G, B values for each pixel}
    COLOR_RGB:
      case Header.BitDepth of
        8:  CopyProc := CopyInterlacedRGB8;
       16:  CopyProc := CopyInterlacedRGB16;
      end {case Header.BitDepth};
    {Palette}
    COLOR_PALETTE, COLOR_GRAYSCALE:
      case Header.BitDepth of
        1, 4, 8: CopyProc := CopyInterlacedPalette148;
        2      : if Header.ColorType = COLOR_PALETTE then
                   CopyProc := CopyInterlacedPalette2
                 else
                   CopyProc := CopyInterlacedGray2;
        16     : CopyProc := CopyInterlacedGrayscale16;
      end;
    {RGB followed by alpha}
    COLOR_RGBALPHA:
      case Header.BitDepth of
        8:  CopyProc := CopyInterlacedRGBAlpha8;
       16:  CopyProc := CopyInterlacedRGBAlpha16;
      end;
    {Grayscale followed by alpha}
    COLOR_GRAYSCALEALPHA:
      case Header.BitDepth of
        8:  CopyProc := CopyInterlacedGrayscaleAlpha8;
       16:  CopyProc := CopyInterlacedGrayscaleAlpha16;
      end;
  end {case Header.ColorType};

  {Adam7 method has 7 passes to make the final image}
  FOR CurrentPass := 0 TO 6 DO
  begin
    {Calculates the number of pixels and bytes for this pass row}
    PixelsThisRow := (frmWidth - ColumnStart[CurrentPass] +
      ColumnIncrement[CurrentPass] - 1) div ColumnIncrement[CurrentPass];
    Row_Bytes := BytesForPixels(PixelsThisRow, Header.ColorType,
      Header.BitDepth);
    {Clear buffer for this pass}
    ZeroMemory(Row_Buffer[not RowUsed], Row_Bytes);

    {Get current row index}
    CurrentRow := RowStart[CurrentPass];
    {Get a pointer to the current row image data}
    Data := PByte(frmImageData) + frmBytesPerRow *
      (frmHeight - 1 - CurrentRow);
    Trans := PByte(frmImageAlpha) + frmWidth * CurrentRow;
    {$IFDEF Store16bits}
    Extra := PByte(hdrExtraImageData) + frmBytesPerRow *
      (frmHeight - 1 - CurrentRow);
    {$ENDIF}

    if Row_Bytes > 0 then {There must have bytes for this interlaced pass}
      while CurrentRow < frmHeight do
      begin
        {Reads this line and filter}
        if IDATZlibRead(ZLIBStream, @Row_Buffer[RowUsed][0], Row_Bytes + 1,
          EndPos, CRCFile) = 0 then break;

        FilterRow;
        {Copy image data}

        CopyProc(CurrentPass, @Row_Buffer[RowUsed][1], Data, Trans
          {$IFDEF Store16bits}, Extra{$ENDIF});

        {Use the other RowBuffer item}
        RowUsed := not RowUsed;

        {Move to the next row}
        inc(CurrentRow, RowIncrement[CurrentPass]);
        {Move pointer to the next line}
        dec(Data, RowIncrement[CurrentPass] * frmBytesPerRow);
        if Trans <> NIL then
          inc(Trans, RowIncrement[CurrentPass] * frmWidth);
        {$IFDEF Store16bits}
        dec(Extra, RowIncrement[CurrentPass] * frmBytesPerRow);
        {$ENDIF}
      end {while CurrentRow < ImageHeight};

  end {FOR CurrentPass};

end;

{Copy 8 bits RGB image}
procedure TChunkIDAT.CopyNonInterlacedRGB8(
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  I: Integer;
begin
  FOR I := 1 TO frmWidth DO
  begin
    {Copy pixel values}
    Dest^ := fOwner.GammaTable[pByte(Src + 2)^]; inc(Dest);
    Dest^ := fOwner.GammaTable[pByte(Src + 1)^]; inc(Dest);
    Dest^ := fOwner.GammaTable[pByte(Src    )^]; inc(Dest);
    {Move to next pixel}
    inc(Src, 3);
  end {for I}
end;

{Copy 16 bits RGB image}
procedure TChunkIDAT.CopyNonInterlacedRGB16(
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  I: Integer;
begin
  FOR I := 1 TO frmWidth DO
  begin
    //Since windows does not supports 2 bytes for
    //each R, G, B value, the method will read only 1 byte from it
    {Copy pixel values}
    Dest^ := fOwner.GammaTable[pByte(Src + 4)^]; inc(Dest);
    Dest^ := fOwner.GammaTable[pByte(Src + 2)^]; inc(Dest);
    Dest^ := fOwner.GammaTable[pByte(Src    )^]; inc(Dest);
    {$IFDEF Store16bits}
    {Copy extra pixel values}
    Extra^ := fOwner.GammaTable[pByte(Src + 5)^]; inc(Extra);
    Extra^ := fOwner.GammaTable[pByte(Src + 3)^]; inc(Extra);
    Extra^ := fOwner.GammaTable[pByte(Src + 1)^]; inc(Extra);
    {$ENDIF}

    {Move to next pixel}
    inc(Src, 6);
  end {for I}
end;

{Copy types using palettes (1, 4 or 8 bits per pixel)}
procedure TChunkIDAT.CopyNonInterlacedPalette148(
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
begin
  {It's simple as copying the data}
  CopyMemory(Dest, Src, Row_Bytes);
end;

{Copy grayscale types using 2 bits for each pixel}
procedure TChunkIDAT.CopyNonInterlacedGray2(
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  i: Integer;
begin
  {2 bits is not supported, this routine will converted into 4 bits}
  FOR i := 1 TO Row_Bytes do
  begin
    Dest^ := ((Byte(Src^) shr 2) and $F) or ((Byte(Src^)) and $F0);
      inc(Dest);
    Dest^ := ((Byte(Src^) shl 2) and $F) or ((Byte(Src^) shl 4) and $F0);
      inc(Dest);
    inc(Src);
  end {FOR i}
end;

{Copy types using palette with 2 bits for each pixel}
procedure TChunkIDAT.CopyNonInterlacedPalette2(
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  i: Integer;
begin
  {2 bits is not supported, this routine will converted into 4 bits}
  FOR i := 1 TO Row_Bytes do
  begin
    Dest^ := ((Byte(Src^) shr 4) and $3) or ((Byte(Src^) shr 2) and $30);
      inc(Dest);
    Dest^ := (Byte(Src^) and $3) or ((Byte(Src^) shl 2) and $30);
      inc(Dest);
    inc(Src);
  end {FOR i}
end;

{Copy grayscale images with 16 bits}
procedure TChunkIDAT.CopyNonInterlacedGrayscale16(
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  I: Integer;
begin
  FOR I := 1 TO frmWidth DO
  begin
    {Windows does not supports 16 bits for each pixel in grayscale}
    {mode, so reduce to 8}
    Dest^ := Src^; inc(Dest);
    {$IFDEF Store16bits}
    Extra^ := pByte(Src + 1)^; inc(Extra);
    {$ENDIF}

    {Move to next pixel}
    inc(Src, 2);
  end {for I}
end;

{Copy 8 bits per sample RGB images followed by an alpha byte}
procedure TChunkIDAT.CopyNonInterlacedRGBAlpha8(
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  i: Integer;
begin
  FOR I := 1 TO frmWidth DO
  begin
    {Copy pixel values and transparency}
    Trans^ := pByte(Src + 3)^;
    Dest^ := fOwner.GammaTable[pByte(Src + 2)^]; inc(Dest);
    Dest^ := fOwner.GammaTable[pByte(Src + 1)^]; inc(Dest);
    Dest^ := fOwner.GammaTable[pByte(Src    )^]; inc(Dest);
    {Move to next pixel}
    inc(Src, 4); inc(Trans);
  end {for I}
end;

{Copy 16 bits RGB image with alpha using 2 bytes for each sample}
procedure TChunkIDAT.CopyNonInterlacedRGBAlpha16(
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  I: Integer;
begin
  FOR I := 1 TO frmWidth DO
  begin
    //Copy rgb and alpha values (transforming from 16 bits to 8 bits)
    {Copy pixel values}
    Trans^ := pByte(Src + 6)^;
    PByte(Dest)^  := fOwner.GammaTable[pByte(Src + 4)^]; inc(Dest);
    PByte(Dest)^  := fOwner.GammaTable[pByte(Src + 2)^]; inc(Dest);
    PByte(Dest)^  := fOwner.GammaTable[pByte(Src    )^]; inc(Dest);
    {$IFDEF Store16bits}
    {Copy extra pixel values}
    Extra^ := fOwner.GammaTable[pByte(Src + 5)^]; inc(Extra);
    Extra^ := fOwner.GammaTable[pByte(Src + 3)^]; inc(Extra);
    Extra^ := fOwner.GammaTable[pByte(Src + 1)^]; inc(Extra);
    {$ENDIF}
    {Move to next pixel}
    inc(Src, 8); inc(Trans);
  end {for I}
end;

{Copy 8 bits per sample grayscale followed by alpha}
procedure TChunkIDAT.CopyNonInterlacedGrayscaleAlpha8(
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  I: Integer;
begin
  FOR I := 1 TO frmWidth DO
  begin
    {Copy alpha value and then gray value}
    Dest^  := Src^;  inc(Src);
    Trans^ := Src^;  inc(Src);
    inc(Dest); inc(Trans);
  end;
end;

{Copy 16 bits per sample grayscale followed by alpha}
procedure TChunkIDAT.CopyNonInterlacedGrayscaleAlpha16(
  Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte);
var
  I: Integer;
begin
  FOR I := 1 TO frmWidth DO
  begin
    {Copy alpha value and then gray value}
    {$IFDEF Store16bits}
    Extra^ := pByte(Src + 1)^; inc(Extra);
    {$ENDIF}
    Dest^  := Src^;  inc(Src, 2);
    Trans^ := Src^;  inc(Src, 2);
    inc(Dest); inc(Trans);
  end;
end;

{Decode non interlaced image}
procedure TChunkIDAT.DecodeNonInterlaced(Stream: TStream;
  var ZLIBStream: TZStreamRec2; const Size: Integer; var crcfile: Cardinal);
var
  j: Cardinal;
  Trans, Data{$IFDEF Store16bits}, Extra{$ENDIF}: pByte;
  CopyProc: procedure(
    Src, Dest, Trans{$IFDEF Store16bits}, Extra{$ENDIF}: pByte) of object;
begin
  CopyProc := nil; {Initialize}
  {Determines the method to copy the image data}
  case Header.ColorType of
    {R, G, B values}
    COLOR_RGB:
      case Header.BitDepth of
        8: CopyProc := CopyNonInterlacedRGB8;
       16: CopyProc := CopyNonInterlacedRGB16;
      end;
    {Types using palettes}
    COLOR_PALETTE, COLOR_GRAYSCALE:
      case Header.BitDepth of
        1, 4, 8: CopyProc := CopyNonInterlacedPalette148;
        2      : if Header.ColorType = COLOR_PALETTE then
                   CopyProc := CopyNonInterlacedPalette2
                 else
                   CopyProc := CopyNonInterlacedGray2;
        16     : CopyProc := CopyNonInterlacedGrayscale16;
      end;
    {R, G, B followed by alpha}
    COLOR_RGBALPHA:
      case Header.BitDepth of
        8  : CopyProc := CopyNonInterlacedRGBAlpha8;
       16  : CopyProc := CopyNonInterlacedRGBAlpha16;
      end;
    {Grayscale followed by alpha}
    COLOR_GRAYSCALEALPHA:
      case Header.BitDepth of
        8  : CopyProc := CopyNonInterlacedGrayscaleAlpha8;
       16  : CopyProc := CopyNonInterlacedGrayscaleAlpha16;
      end;
  end;

  {Get the image data pointer}
  Data := PByte(frmImageData) + frmBytesPerRow * (frmHeight - 1);
  Trans := frmImageAlpha;
  {$IFDEF Store16bits}
  Extra := PByte(frmExtraImageData) + frmBytesPerRow * (frmHeight - 1);
  {$ENDIF}
  {Reads each line}
  FOR j := 0 to frmHeight - 1 do
  begin
    {Read this line Row_Buffer[RowUsed][0] if the filter type for this line}
    if IDATZlibRead(ZLIBStream, @Row_Buffer[RowUsed][0], Row_Bytes + 1, EndPos,
      CRCFile) = 0 then break;

    {Filter the current row}
    FilterRow;
    {Copies non interlaced row to image}
    CopyProc(@Row_Buffer[RowUsed][1], Data, Trans{$IFDEF Store16bits}, Extra
      {$ENDIF});

    {Invert line used}
    RowUsed := not RowUsed;
    dec(Data, frmBytesPerRow);
    {$IFDEF Store16bits}dec(Extra, frmBytesPerRow);{$ENDIF}
    inc(Trans, frmWidth);
  end {for I};


end;

{Filter the current line}
procedure TChunkIDAT.FilterRow;
var
  pp: Byte;
  vv, left, above, aboveleft: Integer;
  Col: Cardinal;
begin
  {Test the filter}
  case Row_Buffer[RowUsed]^[0] of
    {No filtering for this line}
    FILTER_NONE: begin end;
    {AND 255 serves only to never let the result be larger than one byte}
    {Sub filter}
    FILTER_SUB:
      FOR Col := Offset + 1 to Row_Bytes DO
        Row_Buffer[RowUsed][Col] := (Row_Buffer[RowUsed][Col] +
          Row_Buffer[RowUsed][Col - Offset]) and 255;
    {Up filter}
    FILTER_UP:
      FOR Col := 1 to Row_Bytes DO
        Row_Buffer[RowUsed][Col] := (Row_Buffer[RowUsed][Col] +
          Row_Buffer[not RowUsed][Col]) and 255;
    {Average filter}
    FILTER_AVERAGE:
      FOR Col := 1 to Row_Bytes DO
      begin
        {Obtains up and left pixels}
        above := Row_Buffer[not RowUsed][Col];
        if col - 1 < Offset then
          left := 0
        else
          Left := Row_Buffer[RowUsed][Col - Offset];

        {Calculates}
        Row_Buffer[RowUsed][Col] := (Row_Buffer[RowUsed][Col] +
          (left + above) div 2) and 255;
      end;
    {Paeth filter}
    FILTER_PAETH:
    begin
      {Initialize}
      left := 0;
      aboveleft := 0;
      {Test each byte}
      FOR Col := 1 to Row_Bytes DO
      begin
        {Obtains above pixel}
        above := Row_Buffer[not RowUsed][Col];
        {Obtains left and top-left pixels}
        if (col - 1 >= offset) Then
        begin
          left := row_buffer[RowUsed][col - offset];
          aboveleft := row_buffer[not RowUsed][col - offset];
        end;

        {Obtains current pixel and paeth predictor}
        vv := row_buffer[RowUsed][Col];
        pp := PaethPredictor(left, above, aboveleft);

        {Calculates}
        Row_Buffer[RowUsed][Col] := (pp + vv) and $FF;
      end {for};
    end;
      
  end {case};
end;

{Reads the image data from the stream}
function TChunkIDAT.LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
  Size: Integer): Boolean;
var
  ZLIBStream: TZStreamRec2;
  CRCCheck,
  CRCFile  : Cardinal;
 {$IFDEF UseAnimation}
  frame : TPNGFrame;
 {$ENDIF UseAnimation}
begin
  {Get pointer to the header chunk}
  Header := Owner.Chunks.Item[0] as TChunkIHDR;
  {Build palette if necessary}
  if Owner.HasPalette then
    PreparePalette();

  {Copy image width and height}
  frmWidth := Header.Width;
  frmHeight := Header.Height;

  frmImageData := Header.fImageData;
  frmImageAlpha := Header.fImageAlpha;
 {$IFDEF Store16bits}
  hdrExtraImageData := Header.fExtraImageData;
 {$ENDIF}
  {Initialize to calculate CRC}
  {$IFDEF CheckCRC}
    CRCFile := update_crc($ffffffff, @ChunkName[0], 4);
  {$ENDIF}

  Owner.GetPixelInfo(Row_Bytes, Offset); {Obtain line information}
//  frmBytesPerRow := (((BitmapInfo.bmiHeader.biBitCount * frmWidth) + 31)
//    and not 31) div 8;
  frmBytesPerRow := Header.BytesPerRow;

  ZLIBStream := ZLIBInitInflate(Stream);  {Initializes decompression}

  {Calculate ending position for the current IDAT chunk}
  EndPos := Stream.Position + Size;

  {Allocate memory}
  GetMem(Row_Buffer[false], Row_Bytes + 1);
  GetMem(Row_Buffer[true], Row_Bytes + 1);
  ZeroMemory(Row_Buffer[false], Row_Bytes + 1);
  {Set the variable to alternate the Row_Buffer item to use}
  RowUsed := TRUE;

  {Call special methods for the different interlace methods}
  case Owner.InterlaceMethod of
    imNone:  DecodeNonInterlaced(stream, ZLIBStream, Size, crcfile);
    imAdam7: DecodeInterlacedAdam7(stream, ZLIBStream, size, crcfile);
  end;

  {Free memory}
  ZLIBTerminateInflate(ZLIBStream); {Terminates decompression}
  FreeMem(Row_Buffer[False], Row_Bytes + 1);
  FreeMem(Row_Buffer[True], Row_Bytes + 1);

  {Now checks CRC}
  Stream.Read(CRCCheck, 4);
  {$IFDEF CheckCRC}
    CRCFile := CRCFile xor $ffffffff;
    CRCCheck := ByteSwap(CRCCheck);
    Result := CRCCheck = CRCFile;

    {Handle CRC error}
    if not Result then
    begin
      {In case it coult not load chunk}
      Owner.RaiseError(EPngInvalidCRC, EPngInvalidCRCText);
      exit;
    end;
  {$ELSE}Result := TRUE; {$ENDIF}

 {$IFDEF UseAnimation}
    if Owner.FAnimated then
     begin
//      if ((ChunkName = 'IDAT') or (ChunkName = 'fdAT')) then
        begin
//          if Owner.apng.Frames.Count = 0 then
//            Owner.RaiseError(EPNGInvalidSpec, EPNGMissingMultipleIDATText);
          if Owner.apng.Frames.Count > 0 then
            begin
              Frame:= Owner.apng.Frames.Item[Owner.apng.Frames.Count-1];
              if Frame = nil then Exit;
              frame.FromHDR;
            end;
        end;
     end;
 {$ENDIF UseAnimation}

end;

const
  IDATHeader: Array[0..3] of AnsiChar = ('I', 'D', 'A', 'T');
  fdATHeader: Array[0..3] of AnsiChar = ('f', 'd', 'A', 'T');
  BUFFER = 5;

  {$IFDEF SavePicture}
{Saves the IDAT chunk to a stream}
function TChunkIDAT.SaveToStream(Stream: TStream): Boolean;
var
  ZLIBStream : TZStreamRec2;
begin
  {Get pointer to the header chunk}
  Header := Owner.Chunks.Item[0] as TChunkIHDR;
  {Copy image width and height}
  ImageWidth := Header.Width;
  ImageHeight := Header.Height;
  Owner.GetPixelInfo(Row_Bytes, Offset); {Obtain line information}
  frmBytesPerRow := Row_Bytes;

  {Allocate memory}
  GetMem(Encode_Buffer[BUFFER], Row_Bytes);
  ZeroMemory(Encode_Buffer[BUFFER], Row_Bytes);
  {Allocate buffers for the filters selected}
  {Filter none will always be calculated to the other filters to work}
  GetMem(Encode_Buffer[FILTER_NONE], Row_Bytes);
  ZeroMemory(Encode_Buffer[FILTER_NONE], Row_Bytes);
  if pfSub in Owner.Filters then
    GetMem(Encode_Buffer[FILTER_SUB], Row_Bytes);
  if pfUp in Owner.Filters then
    GetMem(Encode_Buffer[FILTER_UP], Row_Bytes);
  if pfAverage in Owner.Filters then
    GetMem(Encode_Buffer[FILTER_AVERAGE], Row_Bytes);
  if pfPaeth in Owner.Filters then
    GetMem(Encode_Buffer[FILTER_PAETH], Row_Bytes);

  {Initialize ZLIB}
  ZLIBStream := ZLIBInitDeflate(Stream, Owner.fCompressionLevel,
    Owner.MaxIdatSize);
  {Write data depending on the interlace method}
  case Owner.InterlaceMethod of
    imNone: EncodeNonInterlaced(stream, ZLIBStream);
    imAdam7: EncodeInterlacedAdam7(stream, ZLIBStream);
  end;
  {Terminates ZLIB}
  ZLIBTerminateDeflate(ZLIBStream);

  {Release allocated memory}
  FreeMem(Encode_Buffer[BUFFER], Row_Bytes);
  FreeMem(Encode_Buffer[FILTER_NONE], Row_Bytes);
  if pfSub in Owner.Filters then
    FreeMem(Encode_Buffer[FILTER_SUB], Row_Bytes);
  if pfUp in Owner.Filters then
    FreeMem(Encode_Buffer[FILTER_UP], Row_Bytes);
  if pfAverage in Owner.Filters then
    FreeMem(Encode_Buffer[FILTER_AVERAGE], Row_Bytes);
  if pfPaeth in Owner.Filters then
    FreeMem(Encode_Buffer[FILTER_PAETH], Row_Bytes);

  {Everything went ok}
  Result := True;
end;

{Writes the IDAT using the settings}
procedure WriteIDAT(Stream: TStream; Data: Pointer; const Length: Cardinal);
var
  ChunkLen, CRC: Cardinal;
begin
  {Writes IDAT header}
  ChunkLen := ByteSwap(Length);
  Stream.Write(ChunkLen, 4);                      {Chunk length}
  Stream.Write(IDATHeader[0], 4);                 {Idat header}
//  CRC := update_crc($ffffffff, @IDATHeader[0], 4); {Crc part for header}
  CRC := Crc32($ffffffff,@IDATHeader[0],4);

  {Writes IDAT data and calculates CRC for data}
  Stream.Write(Data^, Length);
//  CRC := Byteswap(update_crc(CRC, Data, Length) xor $ffffffff);
  CRC := Byteswap(Crc32(CRC, Data, Length) xor $ffffffff);
  {Writes final CRC}
  Stream.Write(CRC, 4);
end;

{Compress and writes IDAT chunk data}
procedure TChunkIDAT.IDATZlibWrite(var ZLIBStream: TZStreamRec2;
  Buffer: Pointer; const Length: Cardinal);
begin
  with ZLIBStream, ZLIBStream.ZLIB do
  begin
    {Set data to be compressed}
    next_in := Buffer;
    avail_in := Length;

    {Compress all the data avaliable to compress}
    while avail_in > 0 do
    begin
      deflate(ZLIB, Z_NO_FLUSH);

      {The whole buffer was used, save data to stream and restore buffer}
      if avail_out = 0 then
      begin
        {Writes this IDAT chunk}
        WriteIDAT(fStream, Data, Owner.MaxIdatSize);

        {Restore buffer}
        next_out := Data;
        avail_out := Owner.MaxIdatSize;
      end {if avail_out = 0};

    end {while avail_in};

  end {with ZLIBStream, ZLIBStream.ZLIB}
end;

{Finishes compressing data to write IDAT chunk}
procedure TChunkIDAT.FinishIDATZlib(var ZLIBStream: TZStreamRec2);
begin
  with ZLIBStream, ZLIBStream.ZLIB do
  begin
    {Set data to be compressed}
    next_in := nil;
    avail_in := 0;

    while deflate(ZLIB,Z_FINISH) <> Z_STREAM_END do
    begin
      {Writes this IDAT chunk}
      WriteIDAT(fStream, Data, Owner.MaxIdatSize - avail_out);
      {Re-update buffer}
      next_out := Data;
      avail_out := Owner.MaxIdatSize;
    end;

    if avail_out < Owner.MaxIdatSize then
      {Writes final IDAT}
      WriteIDAT(fStream, Data, Owner.MaxIdatSize - avail_out);

  end {with ZLIBStream, ZLIBStream.ZLIB};
end;

{Copy memory to encode RGB image with 1 byte for each color sample}
procedure TChunkIDAT.EncodeNonInterlacedRGB8(Src, Dest, Trans: pByte);
var
  I: Integer;
begin
  FOR I := 1 TO ImageWidth DO
  begin
    {Copy pixel values}
    Dest^ := fOwner.InverseGamma[pByte(Src + 2)^]; inc(Dest);
    Dest^ := fOwner.InverseGamma[pByte(Src + 1)^]; inc(Dest);
    Dest^ := fOwner.InverseGamma[pByte(Src    )^]; inc(Dest);
    {Move to next pixel}
    inc(Src, 3);
  end {for I}
end;

{Copy memory to encode RGB images with 16 bits for each color sample}
procedure TChunkIDAT.EncodeNonInterlacedRGB16(Src, Dest, Trans: pByte);
var
  I: Integer;
begin
  FOR I := 1 TO ImageWidth DO
  begin
    //Now we copy from 1 byte for each sample stored to a 2 bytes (or 1 word)
    //for sample
    {Copy pixel values}
    pWORD(Dest)^ := fOwner.InverseGamma[pByte(Src + 2)^]; inc(Dest, 2);
    pWORD(Dest)^ := fOwner.InverseGamma[pByte(Src + 1)^]; inc(Dest, 2);
    pWORD(Dest)^ := fOwner.InverseGamma[pByte(Src    )^]; inc(Dest, 2);
    {Move to next pixel}
    inc(Src, 3);
  end {for I}

end;

{Copy memory to encode types using palettes (1, 4 or 8 bits per pixel)}
procedure TChunkIDAT.EncodeNonInterlacedPalette148(Src, Dest, Trans: pByte);
begin
  {It's simple as copying the data}
  CopyMemory(Dest, Src, Row_Bytes);
end;

{Copy memory to encode grayscale images with 2 bytes for each sample}
procedure TChunkIDAT.EncodeNonInterlacedGrayscale16(Src, Dest, Trans: pByte);
var
  I: Integer;
begin
  FOR I := 1 TO ImageWidth DO
  begin
    //Now we copy from 1 byte for each sample stored to a 2 bytes (or 1 word)
    //for sample
    pWORD(Dest)^ := pByte(Src)^; inc(Dest, 2);
    {Move to next pixel}
    inc(Src);
  end {for I}
end;

{Encode images using RGB followed by an alpha value using 1 byte for each}
procedure TChunkIDAT.EncodeNonInterlacedRGBAlpha8(Src, Dest, Trans: pByte);
var
  i: Integer;
begin
  {Copy the data to the destination, including data from Trans pointer}
  FOR i := 1 TO ImageWidth do
  begin
    Dest^ := Owner.InverseGamma[PByte(Src + 2)^]; inc(Dest);
    Dest^ := Owner.InverseGamma[PByte(Src + 1)^]; inc(Dest);
    Dest^ := Owner.InverseGamma[PByte(Src    )^]; inc(Dest);
    Dest^ := Trans^; inc(Dest);
    inc(Src, 3); inc(Trans);
  end {for i};
end;

{Encode images using RGB followed by an alpha value using 2 byte for each}
procedure TChunkIDAT.EncodeNonInterlacedRGBAlpha16(Src, Dest, Trans: pByte);
var
  i: Integer;
begin
  {Copy the data to the destination, including data from Trans pointer}
  FOR i := 1 TO ImageWidth do
  begin
    pWord(Dest)^ := Owner.InverseGamma[PByte(Src + 2)^]; inc(Dest, 2);
    pWord(Dest)^ := Owner.InverseGamma[PByte(Src + 1)^]; inc(Dest, 2);
    pWord(Dest)^ := Owner.InverseGamma[PByte(Src    )^]; inc(Dest, 2);
    pWord(Dest)^ := Trans^; inc(Dest, 2);
    inc(Src, 3); inc(Trans);
  end {for i};
end;

{Encode grayscale images followed by an alpha value using 1 byte for each}
procedure TChunkIDAT.EncodeNonInterlacedGrayscaleAlpha8(
  Src, Dest, Trans: pByte);
var
  i: Integer;
begin
  {Copy the data to the destination, including data from Trans pointer}
  FOR i := 1 TO ImageWidth do
  begin
    Dest^ := Src^; inc(Dest);
    Dest^ := Trans^; inc(Dest);
    inc(Src); inc(Trans);
  end {for i};
end;

{Encode grayscale images followed by an alpha value using 2 byte for each}
procedure TChunkIDAT.EncodeNonInterlacedGrayscaleAlpha16(
  Src, Dest, Trans: pByte);
var
  i: Integer;
begin
  {Copy the data to the destination, including data from Trans pointer}
  FOR i := 1 TO ImageWidth do
  begin
    pWord(Dest)^ := pByte(Src)^;    inc(Dest, 2);
    pWord(Dest)^ := pByte(Trans)^;  inc(Dest, 2);
    inc(Src); inc(Trans);
  end {for i};
end;

{Encode non interlaced images}
procedure TChunkIDAT.EncodeNonInterlaced(Stream: TStream;
  var ZLIBStream: TZStreamRec2);
var
  {Current line}
  j: Cardinal;
  {Pointers to image data}
  Data, Trans: pByte;
  {Filter used for this line}
  Filter: Byte;
  {Method which will copy the data into the buffer}
  CopyProc: procedure(Src, Dest, Trans: pByte) of object;
begin
  CopyProc := nil;  {Initialize to avoid warnings}
  {Defines the method to copy the data to the buffer depending on}
  {the image parameters}
  case Header.ColorType of
    {R, G, B values}
    COLOR_RGB:
      case Header.BitDepth of
        8: CopyProc := EncodeNonInterlacedRGB8;
       16: CopyProc := EncodeNonInterlacedRGB16;
      end;
    {Palette and grayscale values}
    COLOR_GRAYSCALE, COLOR_PALETTE:
      case Header.BitDepth of
        1, 4, 8: CopyProc := EncodeNonInterlacedPalette148;
             16: CopyProc := EncodeNonInterlacedGrayscale16;
      end;
    {RGB with a following alpha value}
    COLOR_RGBALPHA:
      case Header.BitDepth of
          8: CopyProc := EncodeNonInterlacedRGBAlpha8;
         16: CopyProc := EncodeNonInterlacedRGBAlpha16;
      end;
    {Grayscale images followed by an alpha}
    COLOR_GRAYSCALEALPHA:
      case Header.BitDepth of
        8:  CopyProc := EncodeNonInterlacedGrayscaleAlpha8;
       16:  CopyProc := EncodeNonInterlacedGrayscaleAlpha16;
      end;
  end {case Header.ColorType};

  {Get the image data pointer}
  Data := PByte(frmImageData) + frmBytesPerRow * (ImageHeight - 1);
  Trans := frmImageAlpha;

  {Writes each line}
  FOR j := 0 to ImageHeight - 1 do
  begin
    {Copy data into buffer}
    CopyProc(Data, @Encode_Buffer[BUFFER][0], Trans);
    {Filter data}
    Filter := FilterToEncode;

    {Compress data}
    IDATZlibWrite(ZLIBStream, @Filter, 1);
    IDATZlibWrite(ZLIBStream, @Encode_Buffer[Filter][0], Row_Bytes);

    {Adjust pointers to the actual image data}
    dec(Data, frmBytesPerRow);
    inc(Trans, ImageWidth);
  end;

  {Compress and finishes copying the remaining data}
  FinishIDATZlib(ZLIBStream);
end;

{Copy memory to encode interlaced images using RGB value with 1 byte for}
{each color sample}
procedure TChunkIDAT.EncodeInterlacedRGB8(const Pass: Byte;
  Src, Dest, Trans: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Src := Src + Col * 3;
  repeat
    {Copy this row}
    Dest^ := fOwner.InverseGamma[pByte(Src + 2)^]; inc(Dest);
    Dest^ := fOwner.InverseGamma[pByte(Src + 1)^]; inc(Dest);
    Dest^ := fOwner.InverseGamma[pByte(Src    )^]; inc(Dest);

    {Move to next column}
    inc(Src, ColumnIncrement[Pass] * 3);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= ImageWidth;
end;

{Copy memory to encode interlaced RGB images with 2 bytes each color sample}
procedure TChunkIDAT.EncodeInterlacedRGB16(const Pass: Byte;
  Src, Dest, Trans: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Src := Src + Col * 3;
  repeat
    {Copy this row}
    pWord(Dest)^ := Owner.InverseGamma[pByte(Src + 2)^]; inc(Dest, 2);
    pWord(Dest)^ := Owner.InverseGamma[pByte(Src + 1)^]; inc(Dest, 2);
    pWord(Dest)^ := Owner.InverseGamma[pByte(Src    )^]; inc(Dest, 2);

    {Move to next column}
    inc(Src, ColumnIncrement[Pass] * 3);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= ImageWidth;
end;

{Copy memory to encode interlaced images using palettes using bit depths}
{1, 4, 8 (each pixel in the image)}
procedure TChunkIDAT.EncodeInterlacedPalette148(const Pass: Byte;
  Src, Dest, Trans: pByte);
const
  BitTable: Array[1..8] of Integer = ($1, $3, 0, $F, 0, 0, 0, $FF);
  StartBit: Array[1..8] of Integer = (7 , 0 , 0, 4,  0, 0, 0, 0);
var
  CurBit, Col: Integer;
  Src2: pByte;
begin
  {Clean the line}
  fillchar(Dest^, Row_Bytes, #0);
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  with Header.BitmapInfo.bmiHeader do
    repeat
      {Copy data}
      CurBit := StartBit[biBitCount];
      repeat
        {Adjust pointer to pixel byte bounds}
        Src2 := Src + (biBitCount * Col) div 8;
        {Copy data}
        Dest^ := Byte(Dest^) or
          (((Byte(Src2^) shr (StartBit[Header.BitDepth] - (biBitCount * Col)
            mod 8))) and (BitTable[biBitCount])) shl CurBit;

        {Move to next column}
        inc(Col, ColumnIncrement[Pass]);
        {Will read next bits}
        dec(CurBit, biBitCount);
      until CurBit < 0;

      {Move to next byte in source}
      inc(Dest);
    until Col >= ImageWidth;
end;

{Copy to encode interlaced grayscale images using 16 bits for each sample}
procedure TChunkIDAT.EncodeInterlacedGrayscale16(const Pass: Byte;
  Src, Dest, Trans: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Src := Src + Col;
  repeat
    {Copy this row}
    pWord(Dest)^ := Byte(Src^); inc(Dest, 2);

    {Move to next column}
    inc(Src, ColumnIncrement[Pass]);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= ImageWidth;
end;

{Copy to encode interlaced rgb images followed by an alpha value, all using}
{one byte for each sample}
procedure TChunkIDAT.EncodeInterlacedRGBAlpha8(const Pass: Byte;
  Src, Dest, Trans: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Src := Src + Col * 3;
  Trans := Trans + Col;
  repeat
    {Copy this row}
    Dest^ := Owner.InverseGamma[pByte(Src + 2)^]; inc(Dest);
    Dest^ := Owner.InverseGamma[pByte(Src + 1)^]; inc(Dest);
    Dest^ := Owner.InverseGamma[pByte(Src    )^]; inc(Dest);
    Dest^ := Trans^; inc(Dest);

    {Move to next column}
    inc(Src, ColumnIncrement[Pass] * 3);
    inc(Trans, ColumnIncrement[Pass]);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= ImageWidth;
end;

{Copy to encode interlaced rgb images followed by an alpha value, all using}
{two byte for each sample}
procedure TChunkIDAT.EncodeInterlacedRGBAlpha16(const Pass: Byte;
  Src, Dest, Trans: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Src := Src + Col * 3;
  Trans := Trans + Col;
  repeat
    {Copy this row}
    pWord(Dest)^ := Owner.InverseGamma[pByte(Src + 2)^]; inc(Dest, 2);
    pWord(Dest)^ := Owner.InverseGamma[pByte(Src + 1)^]; inc(Dest, 2);
    pWord(Dest)^ := Owner.InverseGamma[pByte(Src    )^]; inc(Dest, 2);
    pWord(Dest)^ := pByte(Trans)^; inc(Dest, 2);

    {Move to next column}
    inc(Src, ColumnIncrement[Pass] * 3);
    inc(Trans, ColumnIncrement[Pass]);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= ImageWidth;
end;

{Copy to encode grayscale interlaced images followed by an alpha value, all}
{using 1 byte for each sample}
procedure TChunkIDAT.EncodeInterlacedGrayscaleAlpha8(const Pass: Byte;
  Src, Dest, Trans: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Src := Src + Col;
  Trans := Trans + Col;
  repeat
    {Copy this row}
    Dest^ := Src^;   inc(Dest);
    Dest^ := Trans^; inc(Dest);

    {Move to next column}
    inc(Src, ColumnIncrement[Pass]);
    inc(Trans, ColumnIncrement[Pass]);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= ImageWidth;
end;

{Copy to encode grayscale interlaced images followed by an alpha value, all}
{using 2 bytes for each sample}
procedure TChunkIDAT.EncodeInterlacedGrayscaleAlpha16(const Pass: Byte;
  Src, Dest, Trans: pByte);
var
  Col: Integer;
begin
  {Get first column and enter in loop}
  Col := ColumnStart[Pass];
  Src := Src + Col;
  Trans := Trans + Col;
  repeat
    {Copy this row}
    pWord(Dest)^ := Src^; inc(Dest, 2);
    pWord(Dest)^ := Trans^; inc(Dest, 2);

    {Move to next column}
    inc(Src, ColumnIncrement[Pass]);
    inc(Trans, ColumnIncrement[Pass]);
    inc(Col, ColumnIncrement[Pass]);
  until Col >= ImageWidth;
end;

{Encode interlaced images}
procedure TChunkIDAT.EncodeInterlacedAdam7(Stream: TStream;
  var ZLIBStream: TZStreamRec2);
var
  CurrentPass, Filter: Byte;
  PixelsThisRow: Integer;
  CurrentRow : Integer;
  Trans, Data: pByte;
  CopyProc: procedure(const Pass: Byte;
    Src, Dest, Trans: pByte) of object;
begin
  CopyProc := nil;  {Initialize to avoid warnings}
  {Defines the method to copy the data to the buffer depending on}
  {the image parameters}
  case Header.ColorType of
    {R, G, B values}
    COLOR_RGB:
      case Header.BitDepth of
        8: CopyProc := EncodeInterlacedRGB8;
       16: CopyProc := EncodeInterlacedRGB16;
      end;
    {Grayscale and palette}
    COLOR_PALETTE, COLOR_GRAYSCALE:
      case Header.BitDepth of
        1, 4, 8: CopyProc := EncodeInterlacedPalette148;
             16: CopyProc := EncodeInterlacedGrayscale16;
      end;
    {RGB followed by alpha}
    COLOR_RGBALPHA:
      case Header.BitDepth of
          8: CopyProc := EncodeInterlacedRGBAlpha8;
         16: CopyProc := EncodeInterlacedRGBAlpha16;
      end;
    COLOR_GRAYSCALEALPHA:
    {Grayscale followed by alpha}
      case Header.BitDepth of
          8: CopyProc := EncodeInterlacedGrayscaleAlpha8;
         16: CopyProc := EncodeInterlacedGrayscaleAlpha16;
      end;
  end {case Header.ColorType};

  {Compress the image using the seven passes for ADAM 7}
  FOR CurrentPass := 0 TO 6 DO
  begin
    {Calculates the number of pixels and bytes for this pass row}
    PixelsThisRow := (ImageWidth - ColumnStart[CurrentPass] +
      ColumnIncrement[CurrentPass] - 1) div ColumnIncrement[CurrentPass];
    Row_Bytes := BytesForPixels(PixelsThisRow, Header.ColorType,
      Header.BitDepth);
    ZeroMemory(Encode_Buffer[FILTER_NONE], Row_Bytes);

    {Get current row index}
    CurrentRow := RowStart[CurrentPass];
    {Get a pointer to the current row image data}
    Data := PByte(frmImageData) + frmBytesPerRow *
      (ImageHeight - 1 - CurrentRow);
    Trans := PByte(frmImageAlpha) + ImageWidth * CurrentRow;

    {Process all the image rows}
    if Row_Bytes > 0 then
      while CurrentRow < ImageHeight do
      begin
        {Copy data into buffer}
        CopyProc(CurrentPass, Data, @Encode_Buffer[BUFFER][0], Trans);
        {Filter data}
        Filter := FilterToEncode;

        {Compress data}
        IDATZlibWrite(ZLIBStream, @Filter, 1);
        IDATZlibWrite(ZLIBStream, @Encode_Buffer[Filter][0], Row_Bytes);

        {Move to the next row}
        inc(CurrentRow, RowIncrement[CurrentPass]);
        {Move pointer to the next line}
        dec(Data, RowIncrement[CurrentPass] * frmBytesPerRow);
        inc(Trans, RowIncrement[CurrentPass] * ImageWidth);
      end {while CurrentRow < ImageHeight}

  end {CurrentPass};

  {Compress and finishes copying the remaining data}
  FinishIDATZlib(ZLIBStream);
end;

{Filters the row to be encoded and returns the best filter}
function TChunkIDAT.FilterToEncode: Byte;
var
  Run, LongestRun, ii, jj: Cardinal;
  Last, Above, LastAbove: Byte;
begin
  {Selecting more filters using the Filters property from TPngObject}
  {increases the chances to the file be much smaller, but decreases}
  {the performace}

  {This method will creates the same line data using the different}
  {filter methods and select the best}

  {Sub-filter}
  if pfSub in Owner.Filters then
    for ii := 0 to Row_Bytes - 1 do
    begin
      {There is no previous pixel when it's on the first pixel, so}
      {set last as zero when in the first}
      if (ii >= Offset) then
        last := Encode_Buffer[BUFFER]^[ii - Offset]
      else
        last := 0;
      Encode_Buffer[FILTER_SUB]^[ii] := Encode_Buffer[BUFFER]^[ii] - last;
    end;

  {Up filter}
  if pfUp in Owner.Filters then
    for ii := 0 to Row_Bytes - 1 do
      Encode_Buffer[FILTER_UP]^[ii] := Encode_Buffer[BUFFER]^[ii] -
        Encode_Buffer[FILTER_NONE]^[ii];

  {Average filter}
  if pfAverage in Owner.Filters then
    for ii := 0 to Row_Bytes - 1 do
    begin
      {Get the previous pixel, if the current pixel is the first, the}
      {previous is considered to be 0}
      if (ii >= Offset) then
        last := Encode_Buffer[BUFFER]^[ii - Offset]
      else
        last := 0;
      {Get the pixel above}
      above := Encode_Buffer[FILTER_NONE]^[ii];

      {Calculates formula to the average pixel}
      Encode_Buffer[FILTER_AVERAGE]^[ii] := Encode_Buffer[BUFFER]^[ii] -
        (above + last) div 2 ;
    end;

  {Paeth filter (the slower)}
  if pfPaeth in Owner.Filters then
  begin
    {Initialize}
    last := 0;
    lastabove := 0;
    for ii := 0 to Row_Bytes - 1 do
    begin
      {In case this pixel is not the first in the line obtains the}
      {previous one and the one above the previous}
      if (ii >= Offset) then
      begin
        last := Encode_Buffer[BUFFER]^[ii - Offset];
        lastabove := Encode_Buffer[FILTER_NONE]^[ii - Offset];
      end;
      {Obtains the pixel above}
      above := Encode_Buffer[FILTER_NONE]^[ii];
      {Calculate paeth filter for this byte}
      Encode_Buffer[FILTER_PAETH]^[ii] := Encode_Buffer[BUFFER]^[ii] -
        PaethPredictor(last, above, lastabove);
    end;
  end;

  {Now calculates the same line using no filter, which is necessary}
  {in order to have data to the filters when the next line comes}
  CopyMemory(@Encode_Buffer[FILTER_NONE]^[0],
    @Encode_Buffer[BUFFER]^[0], Row_Bytes);

  {If only filter none is selected in the filter list, we don't need}
  {to proceed and further}
  if (Owner.Filters = [pfNone]) or (Owner.Filters = []) then
  begin
    Result := FILTER_NONE;
    exit;
  end {if (Owner.Filters = [pfNone...};

  {Check which filter is the best by checking which has the larger}
  {sequence of the same byte, since they are best compressed}
  LongestRun := 0; Result := FILTER_NONE;
  for ii := FILTER_NONE TO FILTER_PAETH do
    {Check if this filter was selected}
    if TFilter(ii) in Owner.Filters then
    begin
      Run := 0;
      {Check if it's the only filter}
      if Owner.Filters = [TFilter(ii)] then
      begin
        Result := ii;
        exit;
      end;

      {Check using a sequence of four bytes}
      for jj := 2 to Row_Bytes - 1 do
        if (Encode_Buffer[ii]^[jj] = Encode_Buffer [ii]^[jj-1]) or
            (Encode_Buffer[ii]^[jj] = Encode_Buffer [ii]^[jj-2]) then
          inc(Run);  {Count the number of sequences}

      {Check if this one is the best so far}
      if (Run > LongestRun) then
      begin
        Result := ii;
        LongestRun := Run;
      end {if (Run > LongestRun)};

    end {if TFilter(ii) in Owner.Filters};
end;
  {$ENDIF SavePicture}

{TChunkPLTE implementation}

{Returns an item in the palette}
function TChunkPLTE.GetPaletteItem(Index: Byte): TRGBQuad;
begin
  {Test if item is valid, if not raise error}
  if Index > Count - 1 then
    Owner.RaiseError(EPNGError, EPNGUnknownPalEntryText)
  else
    {Returns the item}
    Result := Header.BitmapInfo.bmiColors[Index];
end;

{Loads the palette chunk from a stream}
function TChunkPLTE.LoadFromStream(Stream: TStream;
  const ChunkName: TChunkName; Size: Integer): Boolean;
type
  pPalEntry = ^PalEntry;
  PalEntry = record
    r, g, b: Byte;
  end;
var
  j        : Integer;          {For the FOR}
  PalColor : pPalEntry;
  palEntries: TMaxLogPalette;
begin
  {Let ancestor load data and check CRC}
  Result := inherited LoadFromStream(Stream, ChunkName, Size);
  if not Result then exit;

  {This chunk must be divisible by 3 in order to be valid}
  if (Size mod 3 <> 0) or (Size div 3 > 256) then
  begin
    {Raise error}
    Result := FALSE;
    Owner.RaiseError(EPNGInvalidPalette, EPNGInvalidPaletteText);
    exit;
  end {if Size mod 3 <> 0};

  {Fill array with the palette entries}
  fCount := Size div 3;
  Fillchar(palEntries, sizeof(palEntries), #0);
  palEntries.palVersion := $300;
  palEntries.palNumEntries := fCount;
  PalColor := Data;
  FOR j := 0 TO fCount - 1 DO
    with palEntries.palPalEntry[j] do
    begin
      peRed  :=  Owner.GammaTable[PalColor.r];
      peGreen := Owner.GammaTable[PalColor.g];
      peBlue :=  Owner.GammaTable[PalColor.b];
      peFlags := 0;
      {Move to next palette entry}
      inc(PalColor);
    end;
  Owner.SetPalette(CreatePalette(pLogPalette(@palEntries)^));
end;

  {$IFDEF SavePicture}
{Saves the PLTE chunk to a stream}
function TChunkPLTE.SaveToStream(Stream: TStream): Boolean;
var
  J: Integer;
  DataPtr: pByte;
  BitmapInfo: TMAXBITMAPINFO;
  palEntries: TMaxLogPalette;
begin
  {Adjust size to hold all the palette items}
  if fCount = 0 then fCount := Header.BitmapInfo.bmiHeader.biClrUsed;
  ResizeData(fCount * 3);
  {Get all the palette entries}
  fillchar(palEntries, sizeof(palEntries), #0);
  GetPaletteEntries(Header.ImagePalette, 0, 256, palEntries.palPalEntry[0]);
  {Copy pointer to data}
  DataPtr := fData;

  {Copy palette items}
  BitmapInfo := Header.BitmapInfo;
  FOR j := 0 TO fCount - 1 DO
    with palEntries.palPalEntry[j] do
    begin
      DataPtr^ := Owner.InverseGamma[peRed]; inc(DataPtr);
      DataPtr^ := Owner.InverseGamma[peGreen]; inc(DataPtr);
      DataPtr^ := Owner.InverseGamma[peBlue]; inc(DataPtr);
    end {with BitmapInfo};

  {Let ancestor do the rest of the work}
  Result := inherited SaveToStream(Stream);
end;
  {$ENDIF SavePicture}

{Assigns from another PLTE chunk}
procedure TChunkPLTE.Assign(Source: TChunk);
begin
  {Copy the number of palette items}
  if Source is TChunkPLTE then
    fCount := TChunkPLTE(Source).fCount
  else
    Owner.RaiseError(EPNGError, EPNGCannotAssignChunkText);
end;

{TChunkgAMA implementation}

{Assigns from another chunk}
procedure TChunkgAMA.Assign(Source: TChunk);
begin
  {Copy the gamma value}
  if Source is TChunkgAMA then
    Gamma := TChunkgAMA(Source).Gamma
  else
    Owner.RaiseError(EPNGError, EPNGCannotAssignChunkText);
end;

{Gamma chunk being created}
constructor TChunkgAMA.Create(Owner: TPngObject);
begin
  {Call ancestor}
  inherited Create(Owner);
  Gamma := 1;  {Initial value}
end;

{Returns gamma value}
function TChunkgAMA.GetValue: Cardinal;
begin
  {Make sure that the size is four bytes}
  if DataSize <> 4 then
  begin
    {Adjust size and returns 1}
    ResizeData(4);
    Result := 1;
  end
  {If it's right, read the value}
  else Result := Cardinal(ByteSwap(pCardinal(Data)^))
end;

function Power(Base, Exponent: Extended): Extended;
begin
  if Exponent = 0.0 then
    Result := 1.0               {Math rule}
  else if (Base = 0) or (Exponent = 0) then Result := 0
  else
    Result := Exp(Exponent * Ln(Base));
end;

{Loading the chunk from a stream}
function TChunkgAMA.LoadFromStream(Stream: TStream;
  const ChunkName: TChunkName; Size: Integer): Boolean;
var
  i: Integer;
  Value: Cardinal;
  Val1 : Extended;
begin
  {Call ancestor and test if it went ok}
  Result := inherited LoadFromStream(Stream, ChunkName, Size);
  if not Result then exit;
  Value := Gamma;
  {Build gamma table and inverse table for saving}
  if Value <> 0 then
    with Owner do
     begin
      val1 := 1 / (Value / 100000 * 2.2);
      FOR i := 0 TO 255 DO
      begin
        GammaTable[I] := Round(Power((I / 255), Val1) * 255);
        InverseGamma[GammaTable[I]] := I;
      end
     end;
end;

{Sets the gamma value}
procedure TChunkgAMA.SetValue(const Value: Cardinal);
begin
  {Make sure that the size is four bytes}
  if DataSize <> 4 then ResizeData(4);
  {If it's right, set the value}
  pCardinal(Data)^ := ByteSwap(Value);
end;

{TPngObject implementation}

{Assigns from another object}
procedure TPngObject.Assign(Source: TPersistent);
begin
  {Being cleared}
  if Source = nil then
    ClearChunks
  {Assigns contents from another TPNGObject}
  else if Source is TPNGObject then
    AssignPNG(Source as TPNGObject)
 {$IFDEF SavePicture}
  {Copy contents from a TBitmap}
  {$IFDEF UseDelphi}else if Source is TBitmap then
    with Source as TBitmap do
      AssignHandle(Handle, Transparent,
        ColorToRGB(TransparentColor)){$ENDIF}
 {$ENDIF SavePicture}
  {Unknown source, let ancestor deal with it}
  else
    inherited;
end;

{Clear all the chunks in the list}
procedure TPngObject.ClearChunks;
var
  i: Integer;
begin
  FAnimated:= False;
  {Initialize gamma}
  InitializeGamma();
  {Free all the objects and memory (0 chunks Bug fixed by Noel Sharpe)}
  for i := 0 TO Integer(Chunks.Count) - 1 do
    TChunk(Chunks.Item[i]).Free;
  Chunks.Count := 0;

 {$IFDEF UseAnimation}
  if Assigned(apng) then
    apng.clear;
 {$ENDIF UseAnimation}


end;

  {$IFDEF SavePicture}
{Portable Network Graphics object being created as a blank image}
constructor TPNGObject.CreateBlank(ColorType, BitDepth: Cardinal;
  cx, cy: Integer);
var NewIHDR: TChunkIHDR;
begin
  {Calls creator}
  Create;
  {Checks if the parameters are ok}
  if not (ColorType in [COLOR_GRAYSCALE, COLOR_RGB, COLOR_PALETTE,
    COLOR_GRAYSCALEALPHA, COLOR_RGBALPHA]) or not (BitDepth in
    [1,2,4,8, 16]) or ((ColorType = COLOR_PALETTE) and (BitDepth = 16)) or
    ((ColorType = COLOR_RGB) and (BitDepth < 8)) then
  begin
    RaiseError(EPNGInvalidSpec, EInvalidSpec);
    exit;
  end;
  if Bitdepth = 2 then Bitdepth := 4;

  {Add the basis chunks}
  InitializeGamma;
  BeingCreated := True;
  Chunks.Add(TChunkIEND);
  NewIHDR := Chunks.Add(TChunkIHDR) as TChunkIHDR;
  NewIHDR.IHDRData.ColorType := ColorType;
  NewIHDR.IHDRData.BitDepth := BitDepth;
  NewIHDR.IHDRData.Width := cx;
  NewIHDR.IHDRData.Height := cy;
  NewIHDR.PrepareImageData;
  if NewIHDR.HasPalette then
    TChunkPLTE(Chunks.Add(TChunkPLTE)).fCount := 1 shl BitDepth;
  Chunks.Add(TChunkIDAT);
  BeingCreated := False;
end;
  {$ENDIF SavePicture}

{Portable Network Graphics object being created}
constructor TPngObject.Create;
begin
  {Let it be created}
  inherited Create;

  FAnimated:= False;
  {Initial properties}
  {$IFDEF UseDelphi2}fCanvas := TCanvas.Create;{$ENDIF}
  TempPalette := 0;
  fFilters := [pfSub];
  fCompressionLevel := 7;
  fInterlaceMethod := imNone;
  fMaxIdatSize := High(Word);
  {Create chunklist object}
  fChunkList := TPngList.Create(Self);

end;

{Portable Network Graphics object being destroyed}
destructor TPngObject.Destroy;
begin
  {Free object list}
  ClearChunks;
  FreeAndNil(FChunkList);
  {$IFDEF UseDelphi2}if fCanvas <> nil then
    fCanvas.Free;{$ENDIF}
 {$IFDEF UseAnimation}
//  FreeAndNil(FFrameList);
  if Assigned(apng) then
    FreeAndNil(apng);
 {$ENDIF UseAnimation}

  {Free the temporary palette}
  if TempPalette <> 0 then DeleteObject(TempPalette);

  {Call ancestor destroy}
  inherited Destroy;
end;

{Returns linesize and byte offset for pixels}
procedure TPngObject.GetPixelInfo(var LineSize, Offset: Cardinal);
begin
  {There must be an Header chunk to calculate size}
  if HeaderPresent then
  begin
    {Calculate number of bytes for each line}
    LineSize := BytesForPixels(Header.Width, Header.ColorType, Header.BitDepth);

    {Calculates byte offset}
    Case Header.ColorType of
      {Grayscale}
      COLOR_GRAYSCALE:
        If Header.BitDepth = 16 Then
          Offset := 2
        Else
          Offset := 1 ;
      {It always smaller or equal one byte, so it occupes one byte}
      COLOR_PALETTE:
        offset := 1;
      {It might be 3 or 6 bytes}
      COLOR_RGB:
        offset := 3 * Header.BitDepth Div 8;
      {It might be 2 or 4 bytes}
      COLOR_GRAYSCALEALPHA:
        offset := 2 * Header.BitDepth Div 8;
      {4 or 8 bytes}
      COLOR_RGBALPHA:
        offset := 4 * Header.BitDepth Div 8;
      else
        Offset := 0;
      End ;

  end
  else
  begin
    {In case if there isn't any Header chunk}
    Offset := 0;
    LineSize := 0;
  end;

end;

{Returns image height}
function TPngObject.GetHeight: Integer;
begin
  {There must be a Header chunk to get the size, otherwise returns 0}
  if HeaderPresent then
    Result := TChunkIHDR(Chunks.Item[0]).Height
  else Result := 0;
end;

{Returns image width}
function TPngObject.GetWidth: Integer;
begin
  {There must be a Header chunk to get the size, otherwise returns 0}
  if HeaderPresent then
    Result := Header.Width
//    Result := TChunkIHDR(Chunks.Item[0]).Width
  else Result := 0;
end;

{Returns if the image is empty}
function TPngObject.GetEmpty: Boolean;
begin
  Result := (Chunks.Count = 0);
end;

{Raises an error}
procedure TPngObject.RaiseError(ExceptionClass: ExceptClass; Text: String);
begin
  raise ExceptionClass.Create(Text);
end;

{Set the maximum size for IDAT chunk}
procedure TPngObject.SetMaxIdatSize(const Value: Cardinal);
begin
  {Make sure the size is at least 65535}
  if Value < High(Word) then
    fMaxIdatSize := High(Word) else fMaxIdatSize := Value;
end;

{Draws the image using pixel information from TChunkpHYs}
procedure TPNGObject.DrawUsingPixelInformation(Canvas: TCanvas; Point: TPoint);
  function Rect(Left, Top, Right, Bottom: Integer): TRect;
  begin
    Result.Left := Left;
    Result.Top := Top;
    Result.Right := Right;
    Result.Bottom := Bottom;
  end;
var
  PPMeterY, PPMeterX: Double;
  NewSizeX, NewSizeY: Integer;
  DC: HDC;
begin
  {Get system information}
  DC := GetDC(0);
  PPMeterY := GetDeviceCaps(DC, LOGPIXELSY) / 0.0254;
  PPMeterX := GetDeviceCaps(DC, LOGPIXELSX) / 0.0254;
  ReleaseDC(0, DC);

  {In case it does not has pixel information}
  if not HasPixelInformation then
    Draw(Canvas, Rect(Point.X, Point.Y, Point.X + Width,
      Point.Y + Height))
  else
    with PixelInformation do
    begin
      NewSizeX := Trunc(Self.Width / (PPUnitX / PPMeterX));
      NewSizeY := Trunc(Self.Height / (PPUnitY / PPMeterY));
      Draw(Canvas, Rect(Point.X, Point.Y, Point.X + NewSizeX,
      Point.Y + NewSizeY));
    end;
end;

{$IFNDEF UseDelphi}
  {Creates a file stream reading from the filename in the parameter and load}
  procedure TPngObject.LoadFromFile(const Filename: String);
  var
    FileStream: TFileStream;
  begin
    {Test if the file exists}
    if not FileExists(Filename) then
    begin
      {In case it does not exists, raise error}
      RaiseError(EPNGNotExists, EPNGNotExistsText);
      exit;
    end;

    {Creates the file stream to read}
    FileStream := TFileStream.Create(Filename, [fsmRead]);
    LoadFromStream(FileStream);  {Loads the data}
    FileStream.Free;             {Free file stream}
  end;

  {Saves the current png image to a file}
  procedure TPngObject.SaveToFile(const Filename: String);
  var
    FileStream: TFileStream;
  begin
    {Creates the file stream to write}
    FileStream := TFileStream.Create(Filename, [fsmWrite]);
    SaveToStream(FileStream);    {Saves the data}
    FileStream.Free;             {Free file stream}
  end;

{$ENDIF}

{Returns if it has the pixel information chunk}
function TPngObject.HasPixelInformation: Boolean;
begin
  Result := (Chunks.ItemFromClass(TChunkpHYs) as tChunkpHYs) <> nil;
end;

{Returns the pixel information chunk}
function TPngObject.GetPixelInformation: TChunkpHYs;
begin
  Result := Chunks.ItemFromClass(TChunkpHYs) as tChunkpHYs;
  if not Assigned(Result) then
  begin
    Result := Chunks.Add(tChunkpHYs) as tChunkpHYs;
    Result.fUnit := utMeter;
  end;
end;

{Returns pointer to the chunk TChunkIHDR which should be the first}
function TPngObject.GetHeader: TChunkIHDR;
var
  ch : TChunk;
begin
  Result := NIL;
  {If there is a TChunkIHDR returns it, otherwise returns nil}
  if (Chunks.Count <> 0) then
   begin
    ch := Chunks.Item[0];
    if (ch is TChunkIHDR) then
     Result := ch as TChunkIHDR
   end;
  if Result=NIL then
  begin
    {No header, throw error message}
    RaiseError(EPNGHeaderNotPresent, EPNGHeaderNotPresentText);
//    Result := nil
  end
end;

{Draws using partial transparency}
{THANY: -1*Header.Height changed to -Integer(Header.Height) to prevent range errors}
procedure TPngObject.DrawPartialTrans(DC: HDC; Rect: TRect);
  {Adjust the rectangle structure}
  procedure AdjustRect(var Rect: TRect);
  var
    t: Integer;
  begin
    if Rect.Right < Rect.Left then
    begin
      t := Rect.Right;
      Rect.Right := Rect.Left;
      Rect.Left := t;
    end;
    if Rect.Bottom < Rect.Top then
    begin
      t := Rect.Bottom;
      Rect.Bottom := Rect.Top;
      Rect.Top := t;
    end
  end;

type
  {Access to pixels}
  TPixelLine = Array[Word] of TRGBQuad;
  pPixelLine = ^TPixelLine;
const
  {Structure used to create the bitmap}
  BitmapInfoHeader: TBitmapInfoHeader =
    (biSize: sizeof(TBitmapInfoHeader);
     biWidth: 100;
     biHeight: 100;
     biPlanes: 1;
     biBitCount: 32;
     biCompression: BI_RGB;
     biSizeImage: 0;
     biXPelsPerMeter: 0;
     biYPelsPerMeter: 0;
     biClrUsed: 0;
     biClrImportant: 0);
var
  {Buffer bitmap creation}
  BitmapInfo  : TBitmapInfo;
  BufferDC    : HDC;
  BufferBits  : Pointer;
  OldBitmap,
  BufferBitmap: HBitmap;
  Header: TChunkIHDR;

  {Transparency/palette chunks}
  TransparencyChunk: TChunktRNS;
  PaletteChunk: TChunkPLTE;
  TransValue, PaletteIndex: Byte;
  CurBit: Integer;
  Data: PByte;

  {Buffer bitmap modification}
  BytesPerRowDest,
  BytesPerRowSrc,
  BytesPerRowAlpha: Integer;
  ImageSource, ImageSourceOrg,
  AlphaSource     : pByteArray;
  ImageData       : pPixelLine;
  i, j, i2, j2    : Integer;

  {For bitmap stretching}
  W, H            : Cardinal;
  Stretch         : Boolean;
  FactorX, FactorY: Double;
begin
  {Prepares the rectangle structure to stretch draw}
  if (Rect.Right = Rect.Left) or (Rect.Bottom = Rect.Top) then exit;
  AdjustRect(Rect);
  {Gets the width and height}
  W := Rect.Right - Rect.Left;
  H := Rect.Bottom - Rect.Top;
  Header := Self.Header; {Fast access to header}
  Stretch := (W <> Header.Width) or (H <> Header.Height);
  if Stretch then FactorX := W / Header.Width else FactorX := 1;
  if Stretch then FactorY := H / Header.Height else FactorY := 1;

  {Prepare to create the bitmap}
  Fillchar(BitmapInfo, sizeof(BitmapInfo), #0);
  BitmapInfoHeader.biWidth := W;
  BitmapInfoHeader.biHeight := -Integer(H);
  BitmapInfo.bmiHeader := BitmapInfoHeader;

  {Create the bitmap which will receive the background, the applied}
  {alpha blending and then will be painted on the background}
  BufferDC := CreateCompatibleDC(0);
  {In case BufferDC could not be created}
  if (BufferDC = 0) then RaiseError(EPNGOutMemory, EPNGOutMemoryText);
  BufferBitmap := CreateDIBSection(BufferDC, BitmapInfo, DIB_RGB_COLORS,
    BufferBits, 0, 0);
  {In case buffer bitmap could not be created}
  if (BufferBitmap = 0) or (BufferBits = Nil) then
  begin
    if BufferBitmap <> 0 then DeleteObject(BufferBitmap);
    DeleteDC(BufferDC);
    RaiseError(EPNGOutMemory, EPNGOutMemoryText);
  end;

  {Selects new bitmap and release old bitmap}
  OldBitmap := SelectObject(BufferDC, BufferBitmap);

  {Draws the background on the buffer image}
  BitBlt(BufferDC, 0, 0, W, H, DC, Rect.Left, Rect.Top, SRCCOPY);

  {Obtain number of bytes for each row}
  BytesPerRowAlpha := Header.Width;
  BytesPerRowDest := (((BitmapInfo.bmiHeader.biBitCount * W) + 31)
    and not 31) div 8; {Number of bytes for each image row in destination}
  BytesPerRowSrc := (((Header.BitmapInfo.bmiHeader.biBitCount * Header.Width) +
    31) and not 31) div 8; {Number of bytes for each image row in source}

  {Obtains image pointers}
  ImageData := BufferBits;
  AlphaSource := Header.fImageAlpha;
  PByte(ImageSource) := PByte(Header.fImageData) +
    Header.BytesPerRow * Longint(Header.Height - 1);
  ImageSourceOrg := ImageSource;

  case Header.BitmapInfo.bmiHeader.biBitCount of
    {R, G, B images}
    24:
      FOR j := 1 TO H DO
      begin
        {Process all the pixels in this line}
        FOR i := 0 TO W - 1 DO
        begin
          if Stretch then i2 := trunc(i / FactorX) else i2 := i;
          {Optmize when we donґt have transparency}
          if not Assigned(AlphaSource) then
            begin
              ImageData[i] := pRGBQuad(@ImageSource[i2 * 3])^;
              ImageData[i].rgbReserved := $FF;
            end
          else    
          if (AlphaSource[i2] <> 0) then
            if (AlphaSource[i2] = 255) then
            begin
              pRGBTriple(@ImageData[i])^ := pRGBTriple(@ImageSource[i2 * 3])^;
              ImageData[i].rgbReserved := 255;
            end
            else
              with ImageData[i] do
              begin
////////////////////////// 255 or $7F ????????????
                rgbRed := (255+ImageSource[2+i2*3] * AlphaSource[i2] + rgbRed *
                  (not AlphaSource[i2])) shr 8;
                rgbGreen := (255+ImageSource[1+i2*3] * AlphaSource[i2] +
                  rgbGreen * (not AlphaSource[i2])) shr 8;
                rgbBlue := (255+ImageSource[i2*3] * AlphaSource[i2] + rgbBlue *
                 (not AlphaSource[i2])) shr 8;
                rgbReserved := not ((255 + (not rgbReserved) * (not AlphaSource[i2])) shr 8);
            end;
          end;

        {Move pointers}
        inc(PByte(ImageData), BytesPerRowDest);
        if Stretch then j2 := trunc(j / FactorY) else j2 := j;
        PByte(ImageSource) := PByte(ImageSourceOrg) - BytesPerRowSrc * j2;
        if Header.fImageAlpha <> NIL then
          PByte(AlphaSource) := PByte(Header.fImageAlpha) +
                                   BytesPerRowAlpha * j2;
      end;
    {Palette images with 1 byte for each pixel}
    1,4,8: if Header.ColorType = COLOR_GRAYSCALEALPHA then
      FOR j := 1 TO H DO
      begin
        {Process all the pixels in this line}
        FOR i := 0 TO W - 1 DO
          with ImageData[i], Header.BitmapInfo do begin
            if Stretch then i2 := trunc(i / FactorX) else i2 := i;
            rgbRed := (255 + ImageSource[i2] * AlphaSource[i2] +
              rgbRed * (255 - AlphaSource[i2])) shr 8;
            rgbGreen := (255 + ImageSource[i2] * AlphaSource[i2] +
              rgbGreen * (255 - AlphaSource[i2])) shr 8;
            rgbBlue := (255 + ImageSource[i2] * AlphaSource[i2] +
              rgbBlue * (255 - AlphaSource[i2])) shr 8;
          end;

        {Move pointers}
        PByte(ImageData) := PByte(ImageData) + BytesPerRowDest;
        if Stretch then j2 := trunc(j / FactorY) else j2 := j;
        PByte(ImageSource) := PByte(ImageSourceOrg) - BytesPerRowSrc * j2;
        PByte(AlphaSource) := PByte(Header.fImageAlpha) +
          BytesPerRowAlpha * j2;
      end
    else {Palette images}
    begin
      {Obtain pointer to the transparency chunk}
      TransparencyChunk := TChunktRNS(Chunks.ItemFromClass(TChunktRNS));
      PaletteChunk := TChunkPLTE(Chunks.ItemFromClass(TChunkPLTE));

      FOR j := 1 TO H DO
      begin
        {Process all the pixels in this line}
        i := 0;
          Data := @ImageSource[0];
        repeat
          CurBit := 0;
          repeat
           if Stretch then i2 := trunc(i / FactorX) else i2 := i;
            {Obtains the palette index}
            case Header.BitDepth of
              1: PaletteIndex := (Data^ shr (7-(I2 Mod 8))) and 1;
            2,4: PaletteIndex := (Data^ shr ((1-(I2 Mod 2))*4)) and $0F;
             else PaletteIndex := Data^;
            end;

            {Updates the image with the new pixel}
            with ImageData[i] do
            begin
               if PaletteIndex >= TransparencyChunk.DataSize then
                 begin
//                  TransValue := $FF;
                  rgbRed   := PaletteChunk.Item[PaletteIndex].rgbRed;
                  rgbGreen := PaletteChunk.Item[PaletteIndex].rgbGreen;
                  rgbBlue  := PaletteChunk.Item[PaletteIndex].rgbBlue;
                 end
                else
                 begin
                  TransValue := TransparencyChunk.PaletteValues[PaletteIndex];
                  rgbRed := (255 + PaletteChunk.Item[PaletteIndex].rgbRed *
                     TransValue + rgbRed   * (255 - TransValue)) shr 8;
                  rgbGreen := (255 + PaletteChunk.Item[PaletteIndex].rgbGreen *
                     TransValue + rgbGreen * (255 - TransValue)) shr 8;
                  rgbBlue := (255 + PaletteChunk.Item[PaletteIndex].rgbBlue *
                     TransValue + rgbBlue  * (255 - TransValue)) shr 8;
                 end;
            end;

            {Move to next data}
            inc(i);
            inc(CurBit, Header.BitmapInfo.bmiHeader.biBitCount);
          until CurBit >= 8;
          {Move to next source data}
          inc(Data);
        until i >= Integer(W);

        {Move pointers}
        PByte(ImageData) := PByte(ImageData) + BytesPerRowDest;
        if Stretch then j2 := trunc(j / FactorY) else j2 := j;
        PByte(ImageSource) := PByte(ImageSourceOrg) - BytesPerRowSrc * j2;
      end
    end {Palette images}
  end {case Header.BitmapInfo.bmiHeader.biBitCount};

  {Draws the new bitmap on the foreground}
  BitBlt(DC, Rect.Left, Rect.Top, W, H, BufferDC, 0, 0, SRCCOPY);

  {Free bitmap}
  SelectObject(BufferDC, OldBitmap);
  DeleteObject(BufferBitmap);
  DeleteDC(BufferDC);
end;

{Draws the image into a canvas}
procedure TPngObject.Draw(ACanvas: TCanvas; const Rect: TRect);
var
  Header: TChunkIHDR;
begin
  {Quit in case there is no header, otherwise obtain it}
  if Empty then Exit;
  Header := Chunks.GetItem(0) as TChunkIHDR;

  {Copy the data to the canvas}
  case Self.TransparencyMode of
  {$IFDEF PartialTransparentDraw}
    ptmPartial:
      DrawPartialTrans(ACanvas{$IFDEF UseDelphi}.Handle{$ENDIF}, Rect);
  {$ENDIF}
    ptmBit:
     if Header.ColorType = COLOR_PALETTE then
       DrawPartialTrans(ACanvas{$IFDEF UseDelphi}.Handle{$ENDIF}, Rect)
      else
    DrawTransparentBitmap(ACanvas{$IFDEF UseDelphi}.Handle{$ENDIF},
      Header.fImageData, Header.BitmapInfo.bmiHeader,
      pBitmapInfo(@Header.BitmapInfo), Rect,
      {$IFDEF UseDelphi}ColorToRGB({$ENDIF}TransparentColor)
      {$IFDEF UseDelphi}){$ENDIF}
    else
    begin
//      SetStretchBltMode(ACanvas{$IFDEF UseDelphi}.Handle{$ENDIF}, COLORONCOLOR);
      StretchDiBits(ACanvas{$IFDEF UseDelphi}.Handle{$ENDIF}, Rect.Left,
        Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top, 0, 0,
        Header.Width, Header.Height, Header.fImageData,
        pBitmapInfo(@Header.BitmapInfo)^, DIB_RGB_COLORS, SRCCOPY)
    end
  end {case}
end;

{Characters for the header}
const
  PngHeader: Array[0..7] of AnsiChar = (#137, #80, #78, #71, #13, #10, #26, #10);

{Loads the image from a stream of data}
procedure TPngObject.LoadFromStream(Stream: TStream);
var
  Header    : Array[0..7] of AnsiChar;
  HasIDAT   : Boolean;
//  HasFDAT   : Boolean;

  {Chunks reading}
  ChunkCount : Cardinal;
  ChunkLength: Cardinal;
  ChunkName  : TChunkName;
begin
  {Initialize before start loading chunks}
  ChunkCount := 0;
  ClearChunks();
  {Reads the header}
  Stream.Read(Header[0], 8);

  {Test if the header matches}
  if Header <> PngHeader then
  begin
    RaiseError(EPNGInvalidFileHeader, EPNGInvalidFileHeaderText);
    Exit;
  end;

  HasIDAT := False;
  Chunks.Count := 10;
//  HasFDAT := False;
  FAnimated:= False;

  {Load chunks}
  repeat
    inc(ChunkCount);  {Increment number of chunks}
    if Chunks.Count < ChunkCount then  {Resize the chunks list if needed}
      Chunks.Count := Chunks.Count + 10;

    {Reads chunk length and invert since it is in network order}
    {also checks the Read method return, if it returns 0, it}
    {means that no bytes was readed, probably because it reached}
    {the end of the file}
    if Stream.Read(ChunkLength, 4) = 0 then
    begin
      {In case it found the end of the file here}
      Chunks.Count := ChunkCount - 1;
      RaiseError(EPNGUnexpectedEnd, EPNGUnexpectedEndText);
    end;

    ChunkLength := ByteSwap(ChunkLength);
    {Reads chunk name}
    Stream.Read(ChunkName, 4);

    {Here we check if the first chunk is the Header which is necessary}
    {to the file in order to be a valid Portable Network Graphics image}
    if (ChunkCount = 1) and (ChunkName <> 'IHDR') then
    begin
      Chunks.Count := ChunkCount - 1;
      RaiseError(EPNGIHDRNotFirst, EPNGIHDRNotFirstText);
      Exit;
    end;

    {Has a previous IDAT, FDAT}
    if (HasIDAT and (ChunkName = 'IDAT')) or
//       (HasFDAT and (ChunkName = 'fdAT')) or
       (ChunkName = 'cHRM')
    then
    begin
      Dec(ChunkCount);
      Stream.Seek(ChunkLength + 4, soFromCurrent);
      Continue;
    end;

    {Tell it has an IDAT chunk}
    if ChunkName = 'IDAT' then HasIDAT := True;

    {Creates object for this chunk}
    Chunks.SetItem(ChunkCount - 1, CreateClassChunk(Self, ChunkName));

    {Check if the chunk is critical and unknown}
    {$IFDEF ErrorOnUnknownCritical}
      if (TChunk(Chunks.Item[ChunkCount - 1]).ClassType = TChunk) and
        ((Byte(ChunkName[0]) AND $20) = 0) and (ChunkName <> '') then
      begin
        Chunks.Count := ChunkCount;
        RaiseError(EPNGUnknownCriticalChunk, EPNGUnknownCriticalChunkText);
      end;
    {$ENDIF}

    {Loads it}
    try if not TChunk(Chunks.Item[ChunkCount - 1]).LoadFromStream(Stream,
       ChunkName, ChunkLength) then break;
    except
      Chunks.Count := ChunkCount;
      raise;
    end;

  {Terminates when it reaches the IEND chunk}
  until (ChunkName = 'IEND');

  {Resize the list to the appropriate size}
  Chunks.Count := ChunkCount;

  {Check if there is data}
  if not HasIDAT then
    RaiseError(EPNGNoImageData, EPNGNoImageDataText);
end;

 {$IFDEF UseAnimation}
procedure TPngObject.SetCurrentFrame(const Value: Integer);
//var
//  Frame: TPngFrame;
begin
  apng.FCurrentFrame:= 0;
  if (not Animated) or (apng.FNumFrames = 0) then Exit;
  if not (Value in [0..apng.FNumFrames-1]) then Exit;
  apng.FCurrentFrame:= Value;

//  Frame:= apng.Frames.Item[FCurrentFrame];
//  Frame.AssignImageTo(Header.ImageData);
//  Frame.AssignAlphaTo(Header.ImageAlpha);
end;
 {$ENDIF UseAnimation}

  {$IFDEF SavePicture}
{Changing height is not supported}
procedure TPngObject.SetHeight(Value: Integer);
begin
  Resize(Width, Value)
end;

{Changing width is not supported}
procedure TPngObject.SetWidth(Value: Integer);
begin
  Resize(Value, Height)
end;
  {$ENDIF SavePicture}

{$IFDEF UseDelphi2}
{Saves to clipboard format (thanks to Antoine Pottern)}
procedure TPNGObject.SaveToClipboardFormat(var AFormat: Word;
  var AData: THandle; var APalette: HPalette);
begin
  with TBitmap.Create do
    try
      Width := Self.Width;
      Height := Self.Height;
      Self.Draw(Canvas, Rect(0, 0, Width, Height));
      SaveToClipboardFormat(AFormat, AData, APalette);
    finally
      Free;
    end {try}
end;

{Loads data from clipboard}
procedure TPngObject.LoadFromClipboardFormat(AFormat: Word;
  AData: THandle; APalette: HPalette);
begin
  with TBitmap.Create do
    try
      LoadFromClipboardFormat(AFormat, AData, APalette);
      Self.AssignHandle(Handle, False, 0);
    finally
      Free;
    end {try}
end;

{Returns if the image is transparent}
function TPngObject.GetTransparent: Boolean;
begin
  Result := (TransparencyMode <> ptmNone);
end;

{$ENDIF}

  {$IFDEF SavePicture}
{Saving the PNG image to a stream of data}
procedure TPngObject.SaveToStream(Stream: TStream);
var
  j: Integer;
begin
  {Reads the header}
  Stream.Write(PNGHeader[0], 8);
  {Write each chunk}
  FOR j := 0 TO Chunks.Count - 1 DO
    Chunks.Item[j].SaveToStream(Stream)
end;

{Prepares the Header chunk}
procedure BuildHeader(Header: TChunkIHDR; Handle: HBitmap; Info: pBitmap);
var
  DC: HDC;
begin
  {Set width and height}
  Header.Width := Info.bmWidth;
  Header.Height := abs(Info.bmHeight);
  {Set bit depth}
  if Info.bmBitsPixel >= 16 then
    Header.BitDepth := 8 else Header.BitDepth := Info.bmBitsPixel;
  {Set color type}
  if Info.bmBitsPixel >= 16 then
    Header.ColorType := COLOR_RGB else Header.ColorType := COLOR_PALETTE;
  {Set other info}
  Header.CompressionMethod := 0;  {deflate/inflate}
  Header.InterlaceMethod := 0;    {no interlace}

  {Prepares bitmap headers to hold data}
  Header.PrepareImageData();
  {Copy image data}
  DC := CreateCompatibleDC(0);
  GetDIBits(DC, Handle, 0, Header.Height, Header.ImageData,
    pBitmapInfo(@Header.BitmapInfo)^, DIB_RGB_COLORS);
  DeleteDC(DC);
end;
  {$ENDIF SavePicture}

 {$IFDEF isTGraphic}
{Loads the image from a resource}
procedure TPngObject.LoadFromResourceName(Instance: HInst;
  const Name: String);
var
  ResStream: TResourceStream;
begin
  {Creates an especial stream to load from the resource}
  try ResStream := TResourceStream.Create(Instance, Name, RT_RCDATA);
  except RaiseError(EPNGCouldNotLoadResource, EPNGCouldNotLoadResourceText);
  exit; end;

  {Loads the png image from the resource}
  try
    LoadFromStream(ResStream);
  finally
    ResStream.Free;
  end;
end;

{Loads the png from a resource ID}
procedure TPngObject.LoadFromResourceID(Instance: HInst; ResID: Integer);
begin
  LoadFromResourceName(Instance, String(ResID));
end;
 {$ENDIF}

{Assigns this tpngobject to another object}
procedure TPngObject.AssignTo(Dest: TPersistent);
{$IFDEF UseDelphi}
  function DetectPixelFormat: TPixelFormat;
  begin
    with Header do
    begin
      {Always use 24bits for partial transparency}
      if TransparencyMode = ptmPartial then
        DetectPixelFormat := pf24bit
      else
        case BitDepth of
          {Only supported by COLOR_PALETTE}
          1: DetectPixelFormat := pf1bit;
          2, 4: DetectPixelFormat := pf4bit;
          {8 may be palette or r, g, b values}
          8, 16:
            case ColorType of
              COLOR_RGB, COLOR_GRAYSCALE: DetectPixelFormat := pf24bit;
              COLOR_PALETTE: DetectPixelFormat := pf8bit;
              else raise Exception.Create('');
            end {case ColorFormat of}
          else raise Exception.Create('');
        end {case BitDepth of}
    end {with Header}
  end;
var
  DeskDC: HDC;
  TRNS: TChunkTRNS;
{$ENDIF}
begin
  {If the destination is also a TPNGObject make it assign}
  {this one}
  if Dest is TPNGObject then
    TPNGObject(Dest).AssignPNG(Self)
  {$IFDEF UseDelphi}
  {In case the destination is a bitmap}
  else if (Dest is TBitmap) and HeaderPresent then
   if TransparencyMode=ptmPartial then
     ToBitmap32(TBitmap(Dest))
   else
      if (TransparencyMode = ptmBit)and (Header.ColorType = COLOR_PALETTE) then
     ToBitmap32(TBitmap(Dest))
   else
  begin
    {Copies the handle using CopyImage API}
{    TBitmap(Dest).PixelFormat := DetectPixelFormat;
    TBitmap(Dest).SetSize(Width, Height);
    TBitmap(Dest).Canvas.Draw(0, 0, Self);
}
   case Header.BitmapInfo.bmiHeader.biBitCount of
   1,4 :
     begin
      TBitmap(Dest).PixelFormat := pf8Bit;
 {$IFDEF DELPHI9_UP}
      TBitmap(Dest).SetSize(Width, Height);
 {$ELSE DELPHI_9_dn}
      TBitmap(Dest).Height := 0;
      TBitmap(Dest).Width := Width;
      TBitmap(Dest).Height := Height;
 {$ENDIF DELPHI9_UP}
      StretchDiBits(TBitmap(Dest).Canvas.Handle, 0,0, Width, Height,0,0,
        Header.Width, Header.Height, Header.fImageData,
        pBitmapInfo(@Header.BitmapInfo)^, DIB_RGB_COLORS, SRCCOPY);
      {Copy transparency mode}
      if (TransparencyMode = ptmBit) then
      begin
        TRNS := Chunks.ItemFromClass(TChunkTRNS) as TChunkTRNS;
        TBitmap(Dest).TransparentColor := TRNS.TransparentColor;
        TBitmap(Dest).Transparent := True
      end {if (TransparencyMode = ptmBit)}
     end
   else
   begin
    {Device context}
    DeskDC := GetDC(0);

    case Header.BitmapInfo.bmiHeader.biBitCount of // By Rapid D
      1: TBitmap(Dest).PixelFormat := pf1Bit;
      4: TBitmap(Dest).PixelFormat := pf4Bit;
      8: TBitmap(Dest).PixelFormat := pf8Bit;
     24: TBitmap(Dest).PixelFormat := pf24Bit;
     32: TBitmap(Dest).PixelFormat := pf32Bit;
    end {case Header.BitmapInfo.bmiHeader.biBitCount};

    {Copy the data}
    TBitmap(Dest).Handle := CreateDIBitmap(DeskDC,
      Header.BitmapInfo.bmiHeader, CBM_INIT, Header.fImageData,
      pBitmapInfo(@Header.BitmapInfo)^, DIB_RGB_COLORS);
    ReleaseDC(0, DeskDC);
    {Tests for the best pixelformat}
{    case Header.BitmapInfo.bmiHeader.biBitCount of
      1: TBitmap(Dest).PixelFormat := pf1Bit;
      4: TBitmap(Dest).PixelFormat := pf4Bit;
      8: TBitmap(Dest).PixelFormat := pf8Bit;
     24: TBitmap(Dest).PixelFormat := pf24Bit;
     32: TBitmap(Dest).PixelFormat := pf32Bit;
    end {case Header.BitmapInfo.bmiHeader.biBitCount};

    {Copy transparency mode}
    if (TransparencyMode = ptmBit) then
    begin
      TRNS := Chunks.ItemFromClass(TChunkTRNS) as TChunkTRNS;
      TBitmap(Dest).TransparentColor := TRNS.TransparentColor;
      TBitmap(Dest).Transparent := True
    end {if (TransparencyMode = ptmBit)}
   end;
   end;

  end
  else
    {Unknown destination kind}
    inherited AssignTo(Dest);
  {$ENDIF}
end;

  {$IFDEF SavePicture}
{Assigns from a bitmap object}
procedure TPngObject.AssignHandle(Handle: HBitmap; Transparent: Boolean;
  TransparentColor: ColorRef);
var
  BitmapInfo: Windows.TBitmap;
  {Chunks}
  Header: TChunkIHDR;
  PLTE: TChunkPLTE;
  IDAT: TChunkIDAT;
  IEND: TChunkIEND;
  TRNS: TChunkTRNS;
  i: Integer;
  palEntries : TMaxLogPalette;
begin
  {Obtain bitmap info}
  GetObject(Handle, SizeOf(BitmapInfo), @BitmapInfo);

  {Clear old chunks and prepare}
  ClearChunks();

  {Create the chunks}
  Header := TChunkIHDR.Create(Self);

  {This method will fill the Header chunk with bitmap information}
  {and copy the image data}
  BuildHeader(Header, Handle, @BitmapInfo);

  if Header.HasPalette then PLTE := TChunkPLTE.Create(Self) else PLTE := nil;
  if Transparent then TRNS := TChunkTRNS.Create(Self) else TRNS := nil;
  IDAT := TChunkIDAT.Create(Self);
  IEND := TChunkIEND.Create(Self);

  {Add chunks}
  TPNGPointerList(Chunks).Add(Header);
  if Header.HasPalette then TPNGPointerList(Chunks).Add(PLTE);
  if Transparent then TPNGPointerList(Chunks).Add(TRNS);
  TPNGPointerList(Chunks).Add(IDAT);
  TPNGPointerList(Chunks).Add(IEND);

  {In case there is a image data, set the PLTE chunk fCount variable}
  {to the actual number of palette colors which is 2^(Bits for each pixel)}
  if Header.HasPalette then
  begin
    PLTE.fCount := 1 shl BitmapInfo.bmBitsPixel;

    {Create and set palette}
    fillchar(palEntries, sizeof(palEntries), 0);
    palEntries.palVersion := $300;
    palEntries.palNumEntries := 1 shl BitmapInfo.bmBitsPixel;
    for i := 0 to palEntries.palNumEntries - 1 do
    begin
      palEntries.palPalEntry[i].peRed   := Header.BitmapInfo.bmiColors[i].rgbRed;
      palEntries.palPalEntry[i].peGreen := Header.BitmapInfo.bmiColors[i].rgbGreen;
      palEntries.palPalEntry[i].peBlue  := Header.BitmapInfo.bmiColors[i].rgbBlue;
    end;
    DoSetPalette(CreatePalette(pLogPalette(@palEntries)^), false);
  end;

  {In case it is a transparent bitmap, prepares it}
  if Transparent then TRNS.TransparentColor := TransparentColor;
end;
  {$ENDIF SavePicture}

{Assigns from another PNG}
procedure TPngObject.AssignPNG(Source: TPNGObject);
var
  J: Integer;
begin
  {Copy properties}
  InterlaceMethod := Source.InterlaceMethod;
  MaxIdatSize := Source.MaxIdatSize;
  CompressionLevel := Source.CompressionLevel;
  Filters := Source.Filters;

  {Clear old chunks and prepare}
  ClearChunks();
  Chunks.Count := Source.Chunks.Count;
  {Create chunks and makes a copy from the source}
  FOR J := 0 TO Chunks.Count - 1 DO
    with Source.Chunks do
    begin
      Chunks.SetItem(J, TChunkClass(TChunk(Item[J]).ClassType).Create(Self));
      TChunk(Chunks.Item[J]).Assign(TChunk(Item[J]));
    end {with};

  InverseGamma := Source.InverseGamma;
end;

{Returns a alpha data scanline}
function TPngObject.GetAlphaScanline(const LineIndex: Integer): pByteArray;
begin
  with Header do
    if (ColorType = COLOR_RGBALPHA) or (ColorType = COLOR_GRAYSCALEALPHA) then
      PByte(Result) := PByte(fImageAlpha) + (Cardinal(LineIndex) * Width)
    else Result := nil;  {In case the image does not use alpha information}
end;

{$IFDEF Store16bits}
{Returns a png data extra scanline}
function TPngObject.GetExtraScanline(const LineIndex: Integer): Pointer;
begin
  with Header do
    PByte(Result) := (PByte(ExtraImageData) + ((Longint(Height) - 1) *
      BytesPerRow)) - (LineIndex * BytesPerRow);
end;
{$ENDIF}

{Returns a png data scanline}
function TPngObject.GetScanline(const LineIndex: Integer): Pointer;
begin
  with Header do
    PByte(Result) := (PByte(fImageData) + ((Longint(Height) - 1) *
      BytesPerRow)) - (LineIndex * BytesPerRow);
end;

{Initialize gamma table}
procedure TPngObject.InitializeGamma;
var
  i: Integer;
begin
  {Build gamma table as if there was no gamma}
  FOR i := 0 to 255 do
  begin
    GammaTable[i] := i;
    InverseGamma[i] := i;
  end {for i}
end;

{Returns the transparency mode used by this png}
function TPngObject.GetTransparencyMode: TPNGTransparencyMode;
var
  TRNS: TChunkTRNS;
begin
  with Header do
  begin
    Result := ptmNone; {Default result}
    {Gets the TRNS chunk pointer}
    TRNS := Chunks.ItemFromClass(TChunkTRNS) as TChunkTRNS;

    {Test depending on the color type}
    case ColorType of
      {This modes are always partial}
      COLOR_RGBALPHA, COLOR_GRAYSCALEALPHA: Result := ptmPartial;
      {This modes support bit transparency}
      COLOR_RGB, COLOR_GRAYSCALE: if TRNS <> nil then Result := ptmBit;
      {Supports booth translucid and bit}
      COLOR_PALETTE:
        {A TRNS chunk must be present, otherwise it won't support transparency}
        if TRNS <> nil then
          if TRNS.BitTransparency then
            Result := ptmBit else Result := ptmPartial
    end {case}

  end {with Header}
end;

{Add a text chunk}
procedure TPngObject.AddtEXt(const Keyword, Text: AnsiString);
var
  TextChunk: TChunkTEXT;
begin
  TextChunk := Chunks.Add(TChunkText) as TChunkTEXT;
  TextChunk.Keyword := Keyword;
  TextChunk.Text := Text;
end;

{Add a text chunk}
procedure TPngObject.AddzTXt(const Keyword, Text: AnsiString);
var
  TextChunk: TChunkzTXt;
begin
  TextChunk := Chunks.Add(TChunkzTXt) as TChunkzTXt;
  TextChunk.Keyword := Keyword;
  TextChunk.Text := Text;
end;

{Removes the image transparency}
procedure TPngObject.RemoveTransparency;
var
  TRNS: TChunkTRNS;
begin
  {Removes depending on the color type}
  with Header do
    case ColorType of
      {Palette uses the TChunktRNS to store alpha}
      COLOR_PALETTE:
      begin
       TRNS := Chunks.ItemFromClass(TChunkTRNS) as TChunkTRNS;
       if TRNS <> nil then Chunks.RemoveChunk(TRNS)
      end;
      {Png allocates different memory space to hold alpha information}
      {for these types}
      COLOR_GRAYSCALEALPHA, COLOR_RGBALPHA:
      begin
        {Transform into the appropriate color type}
        if ColorType = COLOR_GRAYSCALEALPHA then
          ColorType := COLOR_GRAYSCALE
        else ColorType := COLOR_RGB;
        {Free the pointer data}
        if fImageAlpha <> nil then FreeMem(fImageAlpha);
        fImageAlpha := nil
      end
    end
end;

{Generates alpha information}
procedure TPngObject.CreateAlpha;
var
  TRNS: TChunkTRNS;
begin
  {Generates depending on the color type}
  with Header do
    case ColorType of
      {Png allocates different memory space to hold alpha information}
      {for these types}
      COLOR_GRAYSCALE, COLOR_RGB:
      begin
        {Transform into the appropriate color type}
        if ColorType = COLOR_GRAYSCALE then
          ColorType := COLOR_GRAYSCALEALPHA
        else ColorType := COLOR_RGBALPHA;
        {Allocates memory to hold alpha information}
        GetMem(fImageAlpha, Integer(Width) * Integer(Height));
        FillChar(fImageAlpha^, Integer(Width) * Integer(Height), #255);
      end;
      {Palette uses the TChunktRNS to store alpha}
      COLOR_PALETTE:
      begin
        {Gets/creates TRNS chunk}
        if Chunks.ItemFromClass(TChunkTRNS) = nil then
          TRNS := Chunks.Add(TChunkTRNS) as TChunkTRNS
        else
          TRNS := Chunks.ItemFromClass(TChunkTRNS) as TChunkTRNS;

          {Prepares the TRNS chunk}
          with TRNS do
          begin
            ResizeData(256);
            Fillchar(PaletteValues[0], 256, 255);
            fDataSize := 1 shl Header.BitDepth;
            fBitTransparency := False
          end {with Chunks.Add};
        end;
    end {case Header.ColorType}

end;

{Returns transparent color}
function TPngObject.GetTransparentColor: TColor;
var
  TRNS: TChunkTRNS;
begin
  TRNS := Chunks.ItemFromClass(TChunkTRNS) as TChunkTRNS;
  {Reads the transparency chunk to get this info}
  if Assigned(TRNS) then Result := TRNS.TransparentColor
    else Result := 0
end;

{$OPTIMIZATION OFF}
procedure TPngObject.SetTransparentColor(const Value: TColor);
var
  TRNS: TChunkTRNS;
begin
  if HeaderPresent then
    {Tests the ColorType}
    case Header.ColorType of
    {Not allowed for this modes}
    COLOR_RGBALPHA, COLOR_GRAYSCALEALPHA: Self.RaiseError(
      EPNGCannotChangeTransparent, EPNGCannotChangeTransparentText);
    {Allowed}
    COLOR_PALETTE, COLOR_RGB, COLOR_GRAYSCALE:
      begin
        TRNS := Chunks.ItemFromClass(TChunkTRNS) as TChunkTRNS;
        if not Assigned(TRNS) then TRNS := Chunks.Add(TChunkTRNS) as TChunkTRNS;

        {Sets the transparency value from TRNS chunk}
        TRNS.TransparentColor := {$IFDEF UseDelphi}ColorToRGB({$ENDIF}Value
          {$IFDEF UseDelphi}){$ENDIF}
      end {COLOR_PALETTE, COLOR_RGB, COLOR_GRAYSCALE)}
    end {case}
end;

{Returns if header is present}
function TPngObject.HeaderPresent: Boolean;
begin
  Result := ((Chunks.Count <> 0) and (Chunks.Item[0] is TChunkIHDR))
end;

{Returns pixel for png using palette and grayscale}
function GetByteArrayPixel(const png: TPngObject; const X, Y: Integer): TColor;
var
  ByteData: Byte;
  DataDepth: Byte;
begin
  with png, Header do
  begin
    {Make sure the bitdepth is not greater than 8}
    DataDepth := BitDepth;
    if DataDepth > 8 then DataDepth := 8;
    {Obtains the byte containing this pixel}
    ByteData := pByteArray(png.Scanline[Y])^[X div (8 div DataDepth)];
    {Moves the bits we need to the right}
    ByteData := (ByteData shr ((8 - DataDepth) -
      (X mod (8 div DataDepth)) * DataDepth));
    {Discard the unwanted pixels}
    ByteData:= ByteData and ($FF shr (8 - DataDepth));

    {For palette mode map the palette entry and for grayscale convert and
    returns the intensity}
    case ColorType of
      COLOR_PALETTE:
        with TChunkPLTE(png.Chunks.ItemFromClass(TChunkPLTE)).Item[ByteData] do
          Result := rgb(GammaTable[rgbRed], GammaTable[rgbGreen],
            GammaTable[rgbBlue]);
      COLOR_GRAYSCALE:
      begin
        if BitDepth = 1
        then ByteData := GammaTable[Byte(ByteData * 255)]
        else ByteData := GammaTable[Byte(ByteData * ((1 shl DataDepth) + 1))];
        Result := rgb(ByteData, ByteData, ByteData);
      end;
      else Result := 0;
    end {case};
  end {with}
end;

{In case vcl units are not being used}
{$IFNDEF UseDelphi}
function ColorToRGB(const Color: TColor): COLORREF;
begin
  Result := Color
end;
{$ENDIF}

{Sets a pixel for grayscale and palette pngs}
procedure SetByteArrayPixel(const png: TPngObject; const X, Y: Integer;
  const Value: TColor);
const
  ClearFlag: Array[1..8] of Integer = (1, 3, 0, 15, 0, 0, 0, $FF);
var
  ByteData: pByte;
  DataDepth: Byte;
  ValEntry: Byte;
begin
  with png.Header do
  begin
    {Map into a palette entry}
    ValEntry := GetNearestPaletteIndex(Png.Palette, ColorToRGB(Value));

    {16 bits grayscale extra bits are discarted}
    DataDepth := BitDepth;
    if DataDepth > 8 then DataDepth := 8;
    {Gets a pointer to the byte we intend to change}
    ByteData := @pByteArray(png.Scanline[Y])^[X div (8 div DataDepth)];
    {Clears the old pixel data}
    ByteData^ := ByteData^ and not (ClearFlag[DataDepth] shl ((8 - DataDepth) -
      (X mod (8 div DataDepth)) * DataDepth));

    {Setting the new pixel}
    ByteData^ := ByteData^ or (ValEntry shl ((8 - DataDepth) -
      (X mod (8 div DataDepth)) * DataDepth));
  end {with png.Header}
end;

{Returns pixel when png uses RGB}
function GetRGBLinePixel(const png: TPngObject;
  const X, Y: Integer): TColor;
begin
  with pRGBLine(png.Scanline[Y])^[X] do
    Result := RGB(rgbtRed, rgbtGreen, rgbtBlue)
end;

{Sets pixel when png uses RGB}
procedure SetRGBLinePixel(const png: TPngObject;
 const X, Y: Integer; Value: TColor);
begin
  with pRGBLine(png.Scanline[Y])^[X] do
  begin
    rgbtRed := GetRValue(Value);
    rgbtGreen := GetGValue(Value);
    rgbtBlue := GetBValue(Value)
  end
end;

{Returns pixel when png uses grayscale}
function GetGrayLinePixel(const png: TPngObject;
  const X, Y: Integer): TColor;
var
  B: Byte;
begin
  B := PByteArray(png.Scanline[Y])^[X];
  Result := RGB(B, B, B);
end;

{Sets pixel when png uses grayscale}
procedure SetGrayLinePixel(const png: TPngObject;
 const X, Y: Integer; Value: TColor);
begin
  PByteArray(png.Scanline[Y])^[X] := GetRValue(Value);
end;

  {$IFDEF SavePicture}
{Resizes the PNG image}
procedure TPngObject.Resize(const CX, CY: Integer);
  function Min(const A, B: Integer): Integer;
  begin
    if A < B then Result := A else Result := B;
  end;
var
  Header: TChunkIHDR;
  Line, NewBytesPerRow: Integer;
  NewHandle: HBitmap;
  NewDC: HDC;
  NewImageData: Pointer;
  NewImageAlpha: Pointer;
//  NewImageExtra: Pointer;
begin
  if (CX > 0) and (CY > 0) then
  begin
    {Gets some actual information}
    Header := Self.Header;

    {Creates the new image}
    NewDC := CreateCompatibleDC(Header.ImageDC);
    Header.BitmapInfo.bmiHeader.biWidth := cx;
    Header.BitmapInfo.bmiHeader.biHeight := cy;
    NewHandle := CreateDIBSection(NewDC, pBitmapInfo(@Header.BitmapInfo)^,
      DIB_RGB_COLORS, NewImageData, 0, 0);
    SelectObject(NewDC, NewHandle);
    {$IFDEF UseDelphi2}Canvas.Handle := NewDC;{$ENDIF}
    NewBytesPerRow := (((Header.BitmapInfo.bmiHeader.biBitCount * cx) + 31)
      and not 31) div 8;

    {Copies the image data}
    for Line := 0 to Min(CY - 1, Height - 1) do
      CopyMemory(PByte(NewImageData) + (Longint(CY) - 1) *
        NewBytesPerRow - (Line * NewBytesPerRow), Scanline[Line],
      Min(NewBytesPerRow, Header.BytesPerRow));

    {Build array for alpha information, if necessary}
    if (Header.ColorType = COLOR_RGBALPHA) or
      (Header.ColorType = COLOR_GRAYSCALEALPHA) then
    begin
      GetMem(NewImageAlpha, CX * CY);
      Fillchar(NewImageAlpha^, CX * CY, 255);
      for Line := 0 to Min(CY - 1, Height - 1) do
        CopyMemory(PByte(NewImageAlpha) + (Line * CX),
          AlphaScanline[Line], Min(CX, Width));
      FreeMem(Header.ImageAlpha);
      Header.ImageAlpha := NewImageAlpha;
    end;

    {$IFDEF Store16bits}
    if (Header.BitDepth = 16) then
    begin
      GetMem(NewImageExtra, CX * CY);
      Fillchar(NewImageExtra^, CX * CY, 0);
      for Line := 0 to Min(CY - 1, Height - 1) do
        CopyMemory(PByte(NewImageExtra) + (Line * CX),
          ExtraScanline[Line], Min(CX, Width));
      FreeMem(Header.ExtraImageData);
      Header.ExtraImageData := NewImageExtra;
    end;
    {$ENDIF}

    {Deletes the old image}
    DeleteObject(Header.ImageHandle);
    DeleteDC(Header.ImageDC);

    {Prepares the header to get the new image}
    Header.BytesPerRow := NewBytesPerRow;
    Header.IHDRData.Width := CX;
    Header.IHDRData.Height := CY;
    Header.ImageData := NewImageData;

    {Replaces with the new image}
    Header.ImageHandle := NewHandle;
    Header.ImageDC := NewDC;
  end
  else
    {The new size provided is invalid}
    RaiseError(EPNGInvalidNewSize, EInvalidNewSize)

end;
  {$ENDIF SavePicture}

 {$IFDEF isTGraphic}
{Sets a pixel}
{THANY: Added support for COLOR_GRAYSCALEALPHA}
procedure TPngObject.SetPixels(const X, Y: Integer; const Value: TColor);
begin
  if ((X >= 0) and (X <= Width - 1)) and
        ((Y >= 0) and (Y <= Height - 1)) then
    with Header do
    begin
      case ColorType of
        COLOR_GRAYSCALE, COLOR_PALETTE:
          SetByteArrayPixel(Self, X, Y, Value);
        COLOR_GRAYSCALEALPHA:
          SetGrayLinePixel(Self, X, Y, Value);
        else
          SetRGBLinePixel(Self, X, Y, Value)
      end; {case}
    end {with}
end;

{Returns a pixel}
function TPngObject.GetPixels(const X, Y: Integer): TColor;
begin
  if ((X >= 0) and (X <= Width - 1)) and
        ((Y >= 0) and (Y <= Height - 1)) then
    with Header do
    begin
      case ColorType of
        COLOR_GRAYSCALE, COLOR_PALETTE:
          Result := GetByteArrayPixel(Self, X, Y);
        COLOR_GRAYSCALEALPHA:
          Result := GetGrayLinePixel(Self, X, Y);
        else
          Result := GetRGBLinePixel(Self, X, Y)
      end; {case}
    end {with}
  else Result := 0
end;
 {$ENDIF isTGraphic}

{Returns the image palette}
function TPngObject.GetPalette: HPALETTE;
begin
  Result := Header.ImagePalette;
end;

{Assigns from another TChunk}
procedure TChunkpHYs.Assign(Source: TChunk);
begin
  fPPUnitY := TChunkpHYs(Source).fPPUnitY;
  fPPUnitX := TChunkpHYs(Source).fPPUnitX;
  fUnit := TChunkpHYs(Source).fUnit;
end;

{Loads the chunk from a stream}
function TChunkpHYs.LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
  Size: Integer): Boolean;
begin
  {Let ancestor load the data}
  Result := inherited LoadFromStream(Stream, ChunkName, Size);
  if not Result or (Size <> 9) then exit; {Size must be 9}

  {Reads data}
  fPPUnitX := ByteSwap(pCardinal(PByte(Data))^);
  fPPUnitY := ByteSwap(pCardinal(PByte(Data) + 4)^);
  fUnit := pUnitType(PByte(Data) + 8)^;
end;

  {$IFDEF SavePicture}
{Saves the chunk to a stream}
function TChunkpHYs.SaveToStream(Stream: TStream): Boolean;
begin
  {Update data}
  ResizeData(9);  {Make sure the size is 9}
  pCardinal(Data)^ := ByteSwap(fPPUnitX);
  pCardinal(PByte(Data) + 4)^ := ByteSwap(fPPUnitY);
  pUnitType(PByte(Data) + 8)^ := fUnit;

  {Let inherited save data}
  Result := inherited SaveToStream(Stream);
end;
  {$ENDIF SavePicture}

procedure TPngObject.DoSetPalette(Value: HPALETTE; const UpdateColors: boolean);
begin
  if (HasPalette)  then
  begin
    {Update the palette entries}
    if UpdateColors then
      Header.PaletteToDIB(Value);
    {Resize the new palette}
    SelectPalette(Header.ImageDC, Value, False);
    RealizePalette(Header.ImageDC);

    {Replaces}
    DeleteObject(Header.ImagePalette);
    Header.ImagePalette := Value;
  end
end;

{Set palette based on a windows palette handle}
procedure TPngObject.SetPalette(Value: HPALETTE);
begin
  DoSetPalette(Value, true);
end;

 {$IFDEF UseAnimation}

{ TChunkfdAT }

{Reads from ZLIB}
function TChunkfdAT.IDATZlibRead(var ZLIBStream: TZStreamRec2;
  Buffer: Pointer; Count: Integer; var EndPos: Integer;
  var crcfile: Cardinal): Integer;
var
  ProcResult : Integer;
  fdATHdr : Array[0..3] of AnsiChar;
  fdATCRC    : Cardinal;
begin
  {Uses internal record pointed by ZLIBStream to gather information}
  with ZLIBStream, ZLIBStream.zlib do
  begin
    {Set the buffer the zlib will read into}
    next_out := Buffer;
    avail_out := Count;

    {Decode until it reach the Count variable}
    while avail_out > 0 do
    begin
      {In case it needs more data and it's in the end of a fdAT chunk,}
      {it means that there are more fdAT chunks}

      while (fStream.Position = EndPos) and (avail_out > 0) and (avail_in = 0) do
      begin
        {End this chunk by reading and testing the crc value}
        fStream.Read(fdATCRC, 4);

        {$IFDEF CheckCRC}
          if crcfile xor $ffffffff <> Cardinal(ByteSwap(fdATCRC)) then
          begin
            Result := -1;
            Owner.RaiseError(EPNGInvalidCRC, EPNGInvalidCRCText);
            exit;
          end;
        {$ENDIF}

        {Start reading the next chunk}
        fStream.Read(EndPos, 4);        {Reads next chunk size}
        EndPos := ByteSwap(EndPos);
        fStream.Read(fdATHdr[0], 4); {Next chunk header}

        fStream.Read(Sequence, 4);
        Sequence:= ByteSwap(Sequence);
        Dec(EndPos, 4);


        {It must be a fdAT chunk since image data is required and PNG}
        {specification says that multiple fdAT chunks must be consecutive}
        if fdATHdr <> 'fdAT' then
        begin
          Owner.RaiseError(EPNGMissingMultipleIDAT, EPNGMissingMultipleIDATText);
          result := -1;
          exit;
        end;

        {Calculate chunk name part of the crc}
        {$IFDEF CheckCRC}
          crcfile := update_crc($ffffffff, @fdATHdr[0], 4);
        {$ENDIF}
        EndPos := fStream.Position + EndPos;
      end;


      {In case it needs compressed data to read from}
      if avail_in = 0 then
      begin
        {In case it's trying to read more than it is avaliable}
        if fStream.Position + ZLIBAllocate > EndPos then
          avail_in := fStream.Read(Data^, EndPos - fStream.Position)
         else
          avail_in := fStream.Read(Data^, ZLIBAllocate);
        {Update crc}
        {$IFDEF CheckCRC}
          crcfile := update_crc(crcfile, Data, avail_in);
        {$ENDIF}

        {In case there is no more compressed data to read from}
        if avail_in = 0 then
        begin
          Result := Count - avail_out;
          Exit;
        end;

        {Set next buffer to read and record current position}
        next_in := Data;

      end {if avail_in = 0};

      ProcResult := inflate(zlib, 0);

      {In case the result was not sucessfull}
      if (ProcResult < 0) then
      begin
        Result := -1;
        Owner.RaiseError(EPNGZLIBError,
          EPNGZLIBErrorText + zliberrors[procresult]);
        exit;
      end;

    end {while avail_out > 0};

  end {with};

  {If everything gone ok, it returns the count bytes}
  Result := Count;
end;

{Reads the image data from the stream}
function TChunkfdAT.LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
  Size: Integer): Boolean;
var
  ZLIBStream: TZStreamRec2;
  CRCCheck,
  CRCFile  : Cardinal;
  Frame : TPNGFrame;
begin
  {Get pointer to the header chunk}
  Header := Owner.Chunks.Item[0] as TChunkIHDR;
  {Build palette if necessary}
  if Owner.HasPalette then
    PreparePalette();
  Frame := Owner.apng.Frames.Item[Owner.apng.Frames.Count-1];
  if Frame = NIL then
   begin
    Result := false;
    Exit;
   end;

  {Copy image width and height}
  frmWidth := Frame.FSelfWidth;
  frmHeight := Frame.FSelfHeight;

  frmImageData := Frame.FImageData;
  frmImageAlpha := Frame.FAlphaData;
 {$IFDEF Store16bits}
  hdrExtraImageData := Frame.fExtraImageData;
 {$ENDIF}

  {Initialize to calculate CRC}
  {$IFDEF CheckCRC}
    CRCFile := update_crc($ffffffff, @ChunkName[0], 4);
  {$ENDIF}


//  Owner.GetPixelInfo(Row_Bytes, Offset); {Obtain line information}
  Row_Bytes := BytesForPixels(frmWidth, Header.ColorType, Header.BitDepth);

  frmBytesPerRow := (((Frame.FBitmapInfo.bmiHeader.biBitCount * frmWidth) + 31)
    and not 31) div 8;

    {Calculates byte offset}
    Case Header.ColorType of
      {Grayscale}
      COLOR_GRAYSCALE:
        If Header.BitDepth = 16 Then
          Offset := 2
        Else
          Offset := 1 ;
      {It always smaller or equal one byte, so it occupes one byte}
      COLOR_PALETTE:
        offset := 1;
      {It might be 3 or 6 bytes}
      COLOR_RGB:
        offset := 3 * Header.BitDepth Div 8;
      {It might be 2 or 4 bytes}
      COLOR_GRAYSCALEALPHA:
        offset := 2 * Header.BitDepth Div 8;
      {4 or 8 bytes}
      COLOR_RGBALPHA:
        offset := 4 * Header.BitDepth Div 8;
      else
        Offset := 0;
      End ;

  ZLIBStream := ZLIBInitInflate(Stream);  {Initializes decompression}

  {Calculate ending position for the current IDAT chunk}
  EndPos := Stream.Position + Size;

  Stream.Read(Sequence, 4);
  Sequence:= ByteSwap(Sequence);

  {Allocate memory}
  GetMem(Row_Buffer[false], Row_Bytes + 1);
  GetMem(Row_Buffer[true], Row_Bytes + 1);
  ZeroMemory(Row_Buffer[false], Row_bytes + 1);
  {Set the variable to alternate the Row_Buffer item to use}
  RowUsed := TRUE;

  {Call special methods for the different interlace methods}
  case Owner.InterlaceMethod of
    imNone:  DecodeNonInterlaced(stream, ZLIBStream, Size, crcfile);
    imAdam7: DecodeInterlacedAdam7(stream, ZLIBStream, size, crcfile);
  end;

  {Free memory}
  ZLIBTerminateInflate(ZLIBStream); {Terminates decompression}
  FreeMem(Row_Buffer[False], Row_Bytes + 1);
  FreeMem(Row_Buffer[True], Row_Bytes + 1);

  {Now checks CRC}
  Stream.Read(CRCCheck, 4);
  {$IFDEF CheckCRC}
    CRCFile := CRCFile xor $ffffffff;
    CRCCheck := ByteSwap(CRCCheck);
    Result := CRCCheck = CRCFile;

    {Handle CRC error}
    if not Result then
    begin
      {In case it coult not load chunk}
      Owner.RaiseError(EPngInvalidCRC, EPngInvalidCRCText);
      exit;
    end;
  {$ELSE}Result := TRUE; {$ENDIF}
end;

  {$IFDEF SavePicture}
{Writes the IDAT using the settings}
procedure WritefdAT(Stream: TStream; Data: Pointer; const Length: Cardinal);
var
  ChunkLen, CRC: Cardinal;
begin
  {Writes fdAT header}
  ChunkLen := ByteSwap(Length);
  Stream.Write(ChunkLen, 4);                      {Chunk length}
  Stream.Write(sequence, 4);                      {Chunk sequence}
  Stream.Write(fdATHeader[0], 4);                 {fdAT header}
//  CRC := update_crc($ffffffff, @fdATHeader[0], 4); {Crc part for header}
  CRC := Crc32($ffffffff, @fdATHeader[0], 4); {Crc part for header}

  {Writes fdAT data and calculates CRC for data}
  Stream.Write(Data^, Length);
//  CRC := Byteswap(update_crc(CRC, Data, Length) xor $ffffffff);
  CRC := Byteswap(Crc32(CRC, Data, Length) xor $ffffffff);
  {Writes final CRC}
  Stream.Write(CRC, 4);
end;

{Compress and writes fdAT chunk data}
procedure TChunkfdAT.IDATZlibWrite(var ZLIBStream: TZStreamRec2;
  Buffer: Pointer; const Length: Cardinal);
begin
  Owner.RaiseError(EPngError, 'Can''t save animated image!');

//  with ZLIBStream, ZLIBStream.ZLIB do
//  begin
//    {Set data to be compressed}
//    next_in := Buffer;
//    avail_in := Length;
//
//    {Compress all the data avaliable to compress}
//    while avail_in > 0 do
//    begin
//      deflate(ZLIB, Z_NO_FLUSH);
//
//      {The whole buffer was used, save data to stream and restore buffer}
//      if avail_out = 0 then
//      begin
//        {Writes this fdAT chunk}
//        WritefdAT(fStream, Data, ZLIBAllocate);
//
//        {Restore buffer}
//        next_out := Data;
//        avail_out := ZLIBAllocate;
//      end {if avail_out = 0};
//
//    end {while avail_in};
//
//  end {with ZLIBStream, ZLIBStream.ZLIB}
end;
  {$ENDIF SavePicture}

{ TPNGFrameList }

function TPNGFrameList.Add: TPNGFrame;
begin
  Result:= TPNGFrame.Create(Self.FOwner);
  Add(Result);
end;

function TPNGFrameList.GetItem(Index: Cardinal): TPNGFrame;
begin
  Result := inherited GetItem(Index);
end;

procedure TPNGFrameList.RemoveFrame(Frame: TPNGFrame);
begin
  Remove(Frame);
  Frame.Free
end;

{ TPNGFrame }
{
procedure TPNGFrame.AssignAlpha(Data: Pointer; DataSize: Cardinal);
begin
  if FAlphaSize > 0 then FreeMem(FAlphaData, FAlphaSize);
  GetMem(FAlphaData, DataSize);
  FAlphaSize:= DataSize;
  IF (Data <> NIL) and (DataSize > 0) then
    Move(Data^, FAlphaData^, FAlphaSize);
end;

procedure TPNGFrame.AssignAlphaTo(var Dest: Pointer);
begin
  Move(FAlphaData^, Dest^, FAlphaSize);
end;

procedure TPNGFrame.AssignImage(Data: Pointer; DataSize: Cardinal);
begin
  if FImageSize > 0 then FreeMem(FImageData, FImageSize);
  GetMem(FImageData, DataSize);
  FImageSize:= DataSize;
  Move(Data^, FImageData^, FImageSize);
end;

procedure TPNGFrame.AssignImageTo(var Dest: Pointer);
begin
  Move(FImageData^, Dest^, FImageSize);
end;
}

constructor TPNGFrame.Create(Owner: TPngObject);
begin
  {Ancestor create}
  inherited Create;

  FImageSize:= 0;
  FAlphaSize:= 0;
  FreeImageData;

  {Record owner}
  FOwner:= Owner;
end;

destructor TPNGFrame.Destroy;
begin
  FreeImageData;
  inherited Destroy;
end;

function TPNGFrame.Clone : TPNGFrame;
begin
  Result := TPNGFrame.Create(Owner);
  Result.FSelfWidth := FSelfWidth;
  Result.FSelfHeight := FSelfHeight;
  Result.FXOffset := FXOffset;
  Result.FYOffset := FYOffset;
  Result.FDelayNum := FDelayNum;
  Result.FDelayDenum := FDelayDenum;
  Result.FDisposeOp := FDisposeOp;
  Result.FBlendOp := FBlendOp;
  Result.FImageSize := FImageSize;
  Result.FAlphaSize := FAlphaSize;

  {Copy palette colors}
//  Result.BitmapInfo.bmiColors := BitmapInfo.bmiColors;
  {Copy palette also}
//  CopyPalette(ImagePalette, Result.ImagePalette);
{
  CopyMemory(Result.FImageData, FImageData, vBytesPerRow * Integer(FSelfHeight));
  if ImageAlpha <> NIL then
    CopyMemory(Result.FAlphaData, ImageAlpha,
        Integer(FSelfWidth) * Integer(FSelfHeight));
}
end;
function TPNGFrame.GetIndex: Integer;
var
  i: Integer;
begin
  Result := -1; {Avoiding warnings}
  {Searches in the list}
  FOR i := 0 TO Owner.apng.Frames.Count - 1 DO
    if Owner.apng.Frames.Item[i] = Self then
    begin
      {Found match}
      Result := i;
      exit;
    end {for i}

end;

function TPNGFrame.IsEmpty: Boolean;
begin
  Result:= (FImageSize > 0) and (FAlphaSize > 0);
end;

procedure TPNGFrame.FreeImageData;
begin
  {Free old image data}
  if ImageHandle <> 0  then DeleteObject(ImageHandle);
  if ImageDC     <> 0  then DeleteDC(ImageDC);
  if FAlphaData <> nil then FreeMem(FAlphaData);
  if ImagePalette <> 0 then DeleteObject(ImagePalette);
  {$IFDEF Store16bits}
  if ExtraImageData <> nil then FreeMem(ExtraImageData);
  {$ENDIF}
  ImageHandle := 0; ImageDC := 0; FAlphaData := nil; FImageData := nil;
  FImageSize := 0;
  FAlphaSize := 0;
  ImagePalette := 0;
  {$IFDEF Store16bits} ExtraImageData := nil; {$ENDIF}
end;

procedure TPNGFrame.PaletteToDIB(Palette: HPalette);
var
  j: Integer;
  palEntries: TMaxLogPalette;
begin
  {Copy colors}
  Fillchar(palEntries, sizeof(palEntries), #0);
  FBitmapInfo.bmiHeader.biClrUsed := GetPaletteEntries(Palette, 0, 256, palEntries.palPalEntry[0]);
  for j := 0 to FBitmapInfo.bmiHeader.biClrUsed - 1 do
  begin
    FBitmapInfo.bmiColors[j].rgbBlue  := palEntries.palPalEntry[j].peBlue;
    FBitmapInfo.bmiColors[j].rgbRed   := palEntries.palPalEntry[j].peRed;
    FBitmapInfo.bmiColors[j].rgbGreen := palEntries.palPalEntry[j].peGreen;
  end;
end;


procedure TPNGFrame.PrepareImageData();
  {Set the bitmap info}
  procedure SetInfo(const Bitdepth: Integer; const Palette: Boolean);
  begin

    {Copy if the bitmap contain palette entries}
//    HasPalette := Palette;
    {Initialize the structure with zeros}
    fillchar(FBitmapInfo, sizeof(FBitmapInfo), #0);
    {Fill the strucutre}
    with FBitmapInfo.bmiHeader do
    begin
      biSize := sizeof(TBitmapInfoHeader);
      biHeight :=  FSelfHeight;// Height;
      biWidth := FSelfWidth;
      biPlanes := 1;
      biBitCount := BitDepth;
      biCompression := BI_RGB;
    end {with BitmapInfo.bmiHeader}
  end;
var
  bd : byte;
  h : TChunkIHDR;
  vBytesPerRow : Integer;
//  plt : HPALETTE;
begin
  {Prepare bitmap info header}
  Fillchar(FBitmapInfo, sizeof(TMaxBitmapInfo), #0);
  {Release old image data}
  FreeImageData();

  h := Owner.Header;
  if h = NIL then
    Exit;
  {Obtain number of bits for each pixel}
  case h.ColorType of
    COLOR_GRAYSCALE, COLOR_PALETTE, COLOR_GRAYSCALEALPHA:
      case h.BitDepth of
        {These are supported by windows}
        1, 4, 8: bd := h.BitDepth;
        {2 bits for each pixel is not supported by windows bitmap}
        2      : bd := 4;
        {Also 16 bits (2 bytes) for each pixel is not supported}
        {and should be transormed into a 8 bit grayscale}
        16     : bd := 8;
      end;
    {Only 1 byte (8 bits) is supported}
    COLOR_RGB, COLOR_RGBALPHA: bd := 24;
  end {case ColorType};
  SetInfo(bd, not((h.ColorType=COLOR_RGB)or (h.ColorType=COLOR_RGBALPHA)));
  {Number of bytes for each scanline}
  vBytesPerRow := (((FBitmapInfo.bmiHeader.biBitCount * FSelfWidth) + 31)
    and not 31) div 8;

  FImageSize := vBytesPerRow * Integer(fSelfHeight);
  FAlphaSize := Integer(FSelfWidth) * Integer(FSelfHeight);

  {Build array for alpha information, if necessary}
  if (h.ColorType = COLOR_RGBALPHA) or (h.ColorType = COLOR_GRAYSCALEALPHA) then
  begin
    GetMem(FAlphaData, FAlphaSize);
    FillChar(FAlphaData^, FAlphaSize, #0);
  end;

  {Build array for extra byte information}
  {$IFDEF Store16bits}
  if (BitDepth = 16) then
  begin
    GetMem(ExtraImageData, FImageSize);
    FillChar(ExtraImageData^, FImageSize, #0);
  end;
  {$ENDIF}

  {Creates the image to hold the data, CreateDIBSection does a better}
  {work in allocating necessary memory}
  ImageDC := CreateCompatibleDC(0);
  {$IFDEF UseDelphi2}Self.Owner.Canvas.Handle := ImageDC;{$ENDIF}

  {In case it is a palette image, create the palette}
  if Owner.HasPalette then
  begin
    {Create a standard palette}
{
    if h.ColorType = COLOR_PALETTE then
      ImagePalette := CreateHalfTonePalette(ImageDC)
    else
      ImagePalette := Owner.CreateGrayscalePalette(h.Bitdepth);
}
//    plt := CreateHalfTonePalette(ImageDC);
    ImagePalette := Owner.CreateGrayscalePalette(h.Bitdepth);
    CopyPalette(h.ImagePalette, ImagePalette);
    if ImagePalette <> 0 then
     begin

      ResizePalette(ImagePalette, 1 shl FBitmapInfo.bmiHeader.biBitCount);
      FBitmapInfo.bmiHeader.biClrUsed := 1 shl FBitmapInfo.bmiHeader.biBitCount;
      SelectPalette(ImageDC, ImagePalette, False);
      RealizePalette(ImageDC);
      PaletteTODIB(ImagePalette);
     end;
  end;

  {Create the device independent bitmap}
  ImageHandle := CreateDIBSection(ImageDC, pBitmapInfo(@FBitmapInfo)^,
    DIB_RGB_COLORS, FImageData, 0, 0);
  SelectObject(ImageDC, ImageHandle);

  {Build array and allocate bytes for each row}
//  zeromemory(ImageData, BytesPerRow * Integer(Height));
  fillchar(ImageData^, FImageSize, 0);
end;

procedure TPNGFrame.FromHDR;
var
  vHDR : TChunkIHDR;
begin
  vHDR := Owner.Header;

  FXOffset := 0; FYOffset := 0;
  fSelfHeight := vHDR.Height;
  FSelfWidth  := vHDR.Width;

  FImageSize := vHDR.BytesPerRow * Integer(fSelfHeight);
  FAlphaSize := Integer(FSelfWidth) * Integer(FSelfHeight);

  if FImageData <> NIL then
    begin
      CopyMemory(FImageData, vHDR.fImageData, FImageSize);
    end;
  if FAlphaData <> NIL then
    begin
      CopyMemory(FAlphaData, vHDR.fImageAlpha, FAlphaSize );
    end;
end;

procedure TPNGFrame.ToBitmap32(var B32:TBitmap);
type
  PColor32 = ^TColor32;
  TColor32 = type Cardinal;
  function SetAlpha(Color32: TColor32; NewAlpha: Byte): TColor32; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
    begin
      Result := (Color32 and $00FFFFFF) or (NewAlpha shl 24);
    end;

var
  PB:PByte;
  PC:PColor32;
  r, C:Cardinal;
  frmRect : TRect;

//  i, j : Integer;
  TransparencyChunk:TChunktRNS;
//  PaletteChunk:TChunkPLTE;
//  TransValue,
  PaletteIndex :Byte;
  CurBit:Integer;
  Data:PByte;
  ImageSource//,ImageSourceOrg
//     ,AlphaSource
    :PByteArray;
//  ImageData:pPixelLine;
  BytesPerRowSrc : Integer;
  vHDR : TChunkIHDR;
begin
 vHDR := Owner.Header;
 {$IFDEF DELPHI_9_UP}
    B32.SetSize(FSelfWidth, FSelfHeight);
 {$ELSE DELPHI_9_dn}
    B32.Height := 0;
    B32.Width := FSelfWidth;
    B32.Height := FSelfHeight;
 {$ENDIF DELPHI_9_UP}
 if (FSelfWidth=0) or (FSelfHeight=0) then exit;
 SetStretchBltMode(B32.Canvas.Handle,COLORONCOLOR);
{ StretchDiBits(B32.Canvas.Handle,0,0, Width, Height,0,0,
               Width, Height, Header.Data,
               pBitmapInfo(@Header.BitmapInfo)^,DIB_RGB_COLORS,SRCCOPY);}
// StretchDiBits(B32.Canvas.Handle, 0,0, vHDR.Width, vHDR.Height,0,0,
//        vHDR.Width, vHDR.Height, vHDR.fImageData,
//        pBitmapInfo(@vHDR.BitmapInfo)^, DIB_RGB_COLORS, SRCCOPY);
 StretchDiBits(B32.Canvas.Handle, 0, 0, FSelfWidth, FSelfHeight,
        0,0, FSelfWidth, FSelfHeight, FImageData,
        pBitmapInfo(@FBitmapInfo)^, DIB_RGB_COLORS, SRCCOPY);

// frmRect := Rect(FXOffset, FYOffset, FSelfWidth-1, FSelfHeight-1);
 case vHDR.ColorType of
  COLOR_GRAYSCALEALPHA,COLOR_RGBALPHA:
    begin

     PB:=Pointer(FAlphaData);
     if PB<>nil then
      begin
       for R:=0 to FSelfHeight-1 do
        begin
         PC:=Pointer(b32.ScanLine[r]);
         for C:=0 to FSelfWidth-1 do
          begin
            PC^:=SetAlpha(PC^,PByte(PB)^);
            Inc(PB);
            Inc(PC);
          end;
        end;
      end;
    end;
   COLOR_PALETTE:
    begin
      TransparencyChunk:=TChunktRNS(Owner.Chunks.ItemFromClass(TChunktRNS));
//      PaletteChunk:=TChunkPLTE(Chunks.ItemFromClass(TChunkPLTE));
      BytesPerRowSrc := (((vHDR.BitmapInfo.bmiHeader.biBitCount * FSelfWidth) +
          31) and not 31) div 8; {Number of bytes for each image row in source}
//      ImageSourceOrg:=ImageSource;

      PByte(ImageSource):=PByte(FImageData)+
                          BytesPerRowSrc * Longint(FSelfHeight-1);

      for r:=1 to FSelfHeight do
      begin
        c:=0;
        {Process all the pixels in this line}
        PC:=Pointer(b32.ScanLine[r-1]);
        Data := @ImageSource[0];
        repeat
          CurBit:=0;
//            Data:= @ImageSource[c];
          repeat
            if TransparencyChunk = NIL then
             begin
               PC^:=SetAlpha(PC^, $FF);
               Inc(PC);
             end
            else
             begin
              case vHDR.BitDepth of
                 1:PaletteIndex:=(Data^ shr (7-(c Mod 8))) and 1;
               2,4:PaletteIndex:=(Data^ shr ((1-(c Mod 2))*4)) and $0F;
               else PaletteIndex:=Data^;
              end;
              begin
                 if PaletteIndex >= TransparencyChunk.DataSize then
                   PC^:=SetAlpha(PC^, $FF)
                  else
                   PC^:=SetAlpha(PC^,TransparencyChunk.PaletteValues[PaletteIndex]);
                 Inc(PC);
              end;
              Inc(CurBit,vHDR.BitmapInfo.bmiHeader.biBitCount);
             end;
            Inc(c);
          until (CurBit>=8)or(c>=Integer(FSelfWidth));
          {Move to next source data}
          inc(Data);
        until c>=Integer(FSelfWidth);
//        Longint(ImageData):=Longint(ImageData)+BytesPerRowDest;
//        if Stretch then j2:=trunc(j / FactorY) else j2:=j;
//        Longint(ImageSource):=Longint(ImageSourceOrg)-BytesPerRowSrc*r;
        PByte(ImageSource) := PByte(ImageSource)-BytesPerRowSrc;
      end
    end
   else
   begin
     for R:=0 to FSelfHeight-1 do
      begin
       PC:=Pointer(b32.ScanLine[r]);
       for C:=0 to FSelfWidth-1 do
        begin
          PC^:=SetAlpha(PC^,$FF);
          Inc(PC);
        end;
      end;
{    PC:=Pointer(B32.Bits);
    for C:=0 to PNG.Width*PNG.Height-1 do
     begin
      PC^:=SetAlpha(PC^,$FF);
      Inc(PC);
     end;}
   end;
  end; // end case

//  b32.Canvas.Brush.Color := RGB((10* 5 mod 255), (10* 5 mod 255), (10* 5 mod 255) );
//  Ellipse(b32.Canvas.Handle, 5, 2, vHDR.Width - 5, vHDR.Height-2);

end;

{ TChunkacTL }

function TChunkacTL.LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
  Size: Integer): Boolean;

begin
  {Let ancestor load the data}
  Result := inherited LoadFromStream(Stream, ChunkName, Size);
  if not Result or (Size <> 8) then exit; {Size must be 7}

  {Reads data}
  Fnum_frames := ByteSwap(pinteger(Longint(Data) + 0)^);
  Fnum_plays := ByteSwap(pinteger(Longint(Data) + 4)^);

  {Copies data from source}
//  Stream.Read(Fnum_frames, 4); Fnum_frames:= ByteSwap(Fnum_frames);
//  Stream.Read(Fnum_plays, 4); Fnum_plays:= ByteSwap(Fnum_plays);

  if not Owner.Animated then
   begin
    Owner.FAnimated:= True;
    if not Assigned(Owner.apng) then
      Owner.apng := TAniPNG.Create(Owner)
     else
      Owner.apng.clear;
   end;

//  Owner.apng.FImageWidth := Owner.Width;
//  Owner.apng.FImageHeight := Owner.Height;
  Owner.apng.FNumFrames := Fnum_frames;
  Owner.apng.FNumIterations := Fnum_plays;
//  Owner.apng.fPicHeight := Owner.HeightFnum_frames
  {Prepares data to hold image}
//  Owner.apng.PrepareImageData();

  Result := True;
end;


{ TChunkfcTL }

function TChunkfcTL.LoadFromStream(Stream: TStream; const ChunkName: TChunkName;
  Size: Integer): Boolean;
var
  CheckCRC: Cardinal;
  {$IFDEF CheckCRC}RightCRC: Cardinal;{$ENDIF}
  Frame: TPngFrame;
begin
  {Copies data from source}
  ResizeData(Size);
  if Size > 0 then Stream.Read(fData^, Size);
  Stream.Seek(-Size+4, soFromCurrent); // skip sequence

  Stream.Read(FSelfWidth, 4); FSelfWidth:= ByteSwap(FSelfWidth);
  Stream.Read(FSelfHeight, 4); FSelfHeight:= ByteSwap(FSelfHeight);

  Stream.Read(FXOffset, 4); FXOffset:= ByteSwap(FXOffset);
  Stream.Read(FYOffset, 4); FYOffset:= ByteSwap(FYOffset);

  Stream.Read(FDelayNum, 2); FDelayNum:= ByteSwap16(FDelayNum);
  Stream.Read(FDelayDenum, 2); FDelayDenum:= ByteSwap16(FDelayDenum);
  if FDelayDenum <= 0 then FDelayDenum:= 100;
  

  Stream.Read(FDisposeOp, 1);
  Stream.Read(FBlendOp, 1); 

  {Reads CRC}
  Stream.Read(CheckCRC, 4);
  CheckCrc := ByteSwap(CheckCRC);

  {Check if crc readed is valid}
  {$IFDEF CheckCRC}
    RightCRC := update_crc($ffffffff, @ChunkName[0], 4);
    RightCRC := update_crc(RightCRC, fData, Size) xor $ffffffff;
    Result := RightCRC = CheckCrc;

    {Handle CRC error}
    if not Result then
    begin
      {In case it coult not load chunk}
      Owner.RaiseError(EPngInvalidCRC, EPngInvalidCRCText);
      exit;
    end
  {$ELSE}Result := TRUE; {$ENDIF}

  if not Owner.Animated then
    begin
      Owner.FAnimated:= True;
      if not Assigned(Owner.apng) then
        Owner.apng := TAniPNG.Create(Owner);
    end;

  if Owner.FAnimated then
   begin
      Frame:= Owner.apng.AddFrame;
//          if Frame = nil then Break;
      if Frame = nil then Exit;

//          lfcTL := TChunkfcTL(Chunks.Item[ChunkCount - 1]);
      Frame.FSelfWidth := Self.SelfWidth;
      Frame.FSelfHeight:= Self.SelfHeight;

      Frame.FXOffset   := Self.XOffset;
      Frame.FYOffset   := Self.YOffset;

      Frame.FDelayNum  := Self.DelayNum;
      Frame.FDelayDenum:= Self.DelayDenum;
      Frame.FDelayMS   := Word(Integer(1000 * Frame.FDelayNum) div Frame.FDelayDenum);

      Frame.FDisposeOp := Self.DisposeOp;
      Frame.FBlendOp   := Self.BlendOp;
      Frame.PrepareImageData;
   end;
end;

 {$ENDIF UseAnimation}



procedure TPNGObject.ToBitmap32(var B32:TBitmap);
type
  PColor32 = ^TColor32;
  TColor32 = type Cardinal;
{function SetAlpha(Color32: TColor32; NewAlpha: Byte): TColor32;
begin
  if NewAlpha < 0 then NewAlpha := 0
  else if NewAlpha > 255 then NewAlpha := 255;
  Result := (Color32 and $00FFFFFF) or (TColor32(NewAlpha) shl 24);
end;}
  function SetAlpha(Color32: TColor32; NewAlpha: Byte): TColor32; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
    begin
//      Result := (Color32 and $00FFFFFF) or (NewAlpha shl 24);
      Result := (Color32 and $00FFFFFF) or TColor32(TColor32(NewAlpha) shl 24);
    end;


var
  PB:PByte;
  PC:PColor32;
  r, C:Cardinal;

//  i, j : Integer;
  TransparencyChunk:TChunktRNS;
//  PaletteChunk:TChunkPLTE;
//  TransValue,
  PaletteIndex :Byte;
  CurBit:Integer;
  Data:PByte;
  ImageSource//,ImageSourceOrg
//     ,AlphaSource
    :PByteArray;
//  ImageData:pPixelLine;
  BytesPerRowSrc : Integer;
  vHDR : TChunkIHDR;
begin
 if not HeaderPresent then
  begin
 {$IFDEF DELPHI9_UP}
    B32.SetSize(0, 0);
 {$ELSE DELPHI_9_dn}
    B32.Height := 0;
    B32.Width := 0;
 {$ENDIF DELPHI9_UP}
    Exit;
  end;
 vHDR := Header;
 B32.PixelFormat := pf32bit;
 {$IFDEF DELPHI9_UP}
    B32.SetSize(vHDR.Width, vHDR.Height);
 {$ELSE DELPHI_9_dn}
    B32.Height := 0;
    B32.Width := vHDR.Width;
    B32.Height := vHDR.Height;
 {$ENDIF DELPHI9_UP}
 if (vHDR.Width=0) or (vHDR.Height=0) then exit;
 SetStretchBltMode(B32.Canvas.Handle,COLORONCOLOR);
{ StretchDiBits(B32.Canvas.Handle,0,0, Width, Height,0,0,
               Width, Height, Header.Data,
               pBitmapInfo(@Header.BitmapInfo)^,DIB_RGB_COLORS,SRCCOPY);}
 StretchDiBits(B32.Canvas.Handle, 0,0, vHDR.Width, vHDR.Height,
        0,0, vHDR.Width, vHDR.Height, vHDR.fImageData,
        pBitmapInfo(@vHDR.BitmapInfo)^, DIB_RGB_COLORS, SRCCOPY);
 case vHDR.ColorType of
  COLOR_GRAYSCALEALPHA,COLOR_RGBALPHA:
    begin
     PB:=Pointer(AlphaScanline[0]);
     if PB<>nil then
      begin
       for R:=0 to Height-1 do
        begin
         PC:=Pointer(b32.ScanLine[r]);
         for C:=0 to vHDR.Width-1 do
          begin
            PC^:=SetAlpha(PC^,PByte(PB)^);
            Inc(PB); Inc(PC);
          end;
        end;
      end;
    end;
   COLOR_PALETTE:
    begin
      TransparencyChunk:=TChunktRNS(Chunks.ItemFromClass(TChunktRNS));
//      PaletteChunk:=TChunkPLTE(Chunks.ItemFromClass(TChunkPLTE));
      PByte(ImageSource) := PByte(vHDR.fImageData)+
          vHDR.BytesPerRow*Longint(vHDR.Height-1);
      BytesPerRowSrc := (((vHDR.BitmapInfo.bmiHeader.biBitCount * vHDR.Width) +
          31) and not 31) div 8; {Number of bytes for each image row in source}
//      ImageSourceOrg:=ImageSource;

      for r:=1 to Height do
      begin
        c:=0;
        {Process all the pixels in this line}
        PC:=Pointer(b32.ScanLine[r-1]);
        Data := @ImageSource[0];
        repeat
          CurBit:=0;
//            Data:= @ImageSource[c];
          repeat
            case vHDR.BitDepth of
              1:PaletteIndex:=(Data^ shr (7-(c Mod 8))) and 1;
            2,4:PaletteIndex:=(Data^ shr ((1-(c Mod 2))*4)) and $0F;
             else PaletteIndex:=Data^;
            end;
//            with ImageData[i] do
            begin
//             for C:=0 to Width-1 do
//              begin
               if PaletteIndex >= TransparencyChunk.DataSize then
                 PC^:=SetAlpha(PC^, $FF)
                else
                 PC^:=SetAlpha(PC^,TransparencyChunk.PaletteValues[PaletteIndex]);
               Inc(PC);
            end;
            Inc(c);Inc(CurBit,vHDR.BitmapInfo.bmiHeader.biBitCount);
          until (CurBit>=8)or(c>=Integer(vHDR.Width));
          {Move to next source data}
          inc(Data);
        until c>=Integer(vHDR.Width);
//        Longint(ImageData):=Longint(ImageData)+BytesPerRowDest;
//        if Stretch then j2:=trunc(j / FactorY) else j2:=j;
//        Longint(ImageSource):=Longint(ImageSourceOrg)-BytesPerRowSrc*r;
        PByte(ImageSource):= PByte(ImageSource)-BytesPerRowSrc;
      end
    end
   else
   begin
     for R:=0 to Height-1 do
      begin
       PC:=Pointer(b32.ScanLine[r]);
       for C:=0 to vHDR.Width-1 do
        begin
          PC^:=SetAlpha(PC^,$FF);
          Inc(PC);
        end;
      end;
{    PC:=Pointer(B32.Bits);
    for C:=0 to PNG.Width*PNG.Height-1 do
     begin
      PC^:=SetAlpha(PC^,$FF);
      Inc(PC);
     end;}
   end;
  end; // end case
end;

 {$IFDEF UseAnimation}

{ TAniPNG }

function TAniPNG.AddFrame: TPNGFrame;
begin
  Result := Frames.Add;
end;

procedure TAniPNG.clear;
var
  i : Integer;
begin
  for i := 0 TO Integer(Frames.Count) - 1 do
    TPNGFrame(Frames.Item[I]).Free;
  Frames.Count:= 0;
  FCurrentFrame:= 0;
  FNumFrames := 0;
end;

constructor TAniPNG.Create(AOwner: TPNGObject);
begin
  FOwner := AOwner;
//  inherited;
  Frames := TPNGFrameList.Create(AOwner);
end;

destructor TAniPNG.Destroy;
begin
  FreeAndNil(Frames);
  inherited;
end;


function TAniPNG.getFullBitmap : TBitmap;
type
  PColor32 = ^TColor32;
  TColor32 = type Cardinal;
  function SetAlpha(Color32: TColor32; NewAlpha: Byte): TColor32; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
    begin
      Result := (Color32 and $00FFFFFF) or (NewAlpha shl 24);
    end;

  procedure Premultiply(var bmp : TBitmap);
    function mult1(a, b: byte) : byte; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
    var
      i : Integer;
    begin
      if b = 255 then
        Result := a
       else
        begin
         i := a;
         i := (i*b + $7F)shr 8;
         Result := i;
        end;
    end;
  type
    TColor32 = packed record
     case boolean of
      True:
        (B,R,G,A: Byte);
  //      (B,G,R,A: Byte);
      false:
        (c : Cardinal);
  //   end;
    end;
    PColor32Array = ^TColor32Array;
    TColor32Array = array [0..MaxInt div SizeOf(TColor32) - 1] of TColor32;
  var
   Scan32: pColor32Array;
   I, X: Cardinal;
  // A1: Double;
   h,w : Integer;
  begin
    h := bmp.Height-1; // Сразу вычетаем 1 !!!
    w := bmp.Width-1;  // Сразу вычетаем 1 !!!
    for I := 0 to h do
     begin
      Scan32 := Bmp.ScanLine[i];
      for X := 0 to w do
       begin
        with Scan32^[X] do
         begin
  {         A1:= A / $FF;
           R := round(R * A1);
           G := round(G * A1);
           B := round(B * A1);}
  //         B := (Integer(B)*A + $7F) shl 8;
  //         R := (Integer(R)*A + $7F) shl 8;
  //         G := (Integer(G)*A + $7F) shl 8;
          B := mult1(B, A);
          R := mult1(R, A);
          G := mult1(G, A);
         end;
       end;
     end;
  end;

var
  FImageWidth, FImageHeight : Integer;
  I, j: Integer;
  rBMP, b32 : TBitmap;
  vHDR : TChunkIHDR;
  vDC : HDC;
  fr : TPNGFrame;
  fullHeight : Integer;
  l_Top : Integer;
  lastDisposeOp : Byte;
  lastFrameRect : TRect;
  bf : {$IFDEF FPC}JwaWinGDI.{$ENDIF} BLENDFUNCTION;      // structure for alpha blending
begin
  rBMP := TBitmap.Create;
  Result := rBMP;
  if not Owner.HeaderPresent then
    begin
   {$IFDEF DELPHI_9_UP}
      rBMP.SetSize(0, 0);
   {$ELSE DELPHI_9_dn}
      rBMP.Height := 0;
      rBMP.Width := 0;
   {$ENDIF DELPHI_9_UP}
      Exit;
    end;
  vHDR := Owner.Header;
  FImageWidth := Owner.Width;
  FImageHeight := Owner.Height;
//  fullWidth := FNumFrames * FImageWidth;
  fullHeight := FNumFrames * FImageHeight;

  if (vHDR.Width=0) or (vHDR.Height=0) then exit;

  rBMP.PixelFormat := pf32bit;
  rBMP.SetSize(FImageWidth, fullHeight);
  vDC := rBMP.Canvas.Handle;


 SetStretchBltMode(vDC,COLORONCOLOR);
 lastDisposeOp := TPNGFrame.APNG_DISPOSE_OP_BACKGROUND;
 lastFrameRect := Rect(0, 0, FImageWidth, FImageHeight);
 for i := 0 to FNumFrames-1 do
   begin
     l_Top := 0 + FImageHeight*i;
     fr := Frames.Item[i];
{
    with tempBitmapInfo.bmiHeader do
     begin
      biHeight := Fr.SelfHeight;
      biWidth := Fr.SelfWidth;
     end;
}
     if lastDisposeOp = TPNGFrame.APNG_DISPOSE_OP_NONE then
       begin
         StretchBlt(vDC, 0, l_Top, FImageWidth, FImageHeight,
              vDC, 0, l_Top - FImageHeight, FImageWidth, FImageHeight,
              SRCCOPY);
//         FillRect(vDC, Rect(0, l_Top, FImageWidth, l_Top + FImageHeight), CreateSolidBrush(0));
{
         b32 := TBitmap.Create;
         b32.PixelFormat := pf32bit;
         Owner.ToBitmap32(b32);
         StretchBlt(vDC,
              0, l_Top, FImageWidth, FImageHeight,
              b32.Canvas.Handle, 0, 0, FImageWidth, FImageHeight,
              SRCCOPY);
         b32.Free;
{
         StretchDiBits(vDC,
              0, l_Top, FImageWidth, FImageHeight,
              0, 0, FImageWidth, FImageHeight,
              vHDR.fImageData, pBitmapInfo(@vHDR.BitmapInfo)^, DIB_RGB_COLORS, SRCCOPY);
         for j := 0 to FImageHeight - 1 do
          begin
      //     PC:=Pointer(LongInt(vImgData) + i * lBytesPerRow);
           PC:= rBMP.ScanLine[l_Top + j];
          for C:=0 to FImageWidth -1 do
           begin
            PC^:=SetAlpha(PC^,$FF);
      //      PC^:= $FF8800FF;
      //      PC^:=SetAlpha(PC^, 0);
            Inc(PC);
           end;
          end;}

//         StretchBlt(vDC,
//              0, l_Top, FImageWidth, FImageHeight,
//              vDC, 0, l_Top - FImageHeight, FImageWidth, FImageHeight,
//              SRCCOPY)
//         StretchDiBits(rBMP.Canvas.Handle,
//              0, l_Top, FImageWidth, FImageHeight,
//              l_Top - FImageWidth, 0, FImageWidth, FImageHeight,
//              Result.ScanLine[0], tempBitmapInfo, DIB_RGB_COLORS, SRCCOPY)
       end
      else
     if (lastDisposeOp = TPNGFrame.APNG_DISPOSE_OP_PREVIOUS) and (i > 0) then
       begin
         j := i-1;
         while (j > 0)and (Frames.Item[j].FDisposeOp = TPNGFrame.APNG_DISPOSE_OP_PREVIOUS) do
           dec(j);
         if j>=0 then //Frames.Item[j].FDisposeOp = TPNGFrame.APNG_DISPOSE_OP_NONE then
           StretchBlt(vDC, 0, l_Top, FImageWidth, FImageHeight,
              vDC, 0, FImageHeight*j, FImageWidth, FImageHeight,
              SRCCOPY)
          else
           FillRect(vDC, Rect(0, l_Top, FImageWidth, l_Top + FImageHeight), CreateSolidBrush(0));
       end
      else
//       FillRect(vDC, Rect(0, l_Top, FImageWidth, l_Top + FImageHeight), CreateSolidBrush(0));
       begin
         if i > 0 then
           StretchBlt(vDC, 0, l_Top, FImageWidth, FImageHeight,
              vDC, 0, l_Top - FImageHeight, FImageWidth, FImageHeight,
              SRCCOPY);
         FillRect(vDC, lastFrameRect, CreateSolidBrush($00000000));
       end;

     lastDisposeOp := fr.FDisposeOp;
     lastFrameRect := Rect(fr.XOffset, l_Top + FImageHeight + fr.YOffset,
                           fr.XOffset + Fr.SelfWidth, l_Top + FImageHeight + fr.YOffset + Fr.SelfHeight);
     b32 := TBitmap.Create;
     b32.PixelFormat := pf32bit;
     fr.ToBitmap32(b32);
     Premultiply(b32);

     if fr.FBlendOp = TPNGFrame.APNG_BLEND_OP_SOURCE then
       begin
         StretchBlt(vDC,
            fr.XOffset, l_Top + fr.YOffset, Fr.SelfWidth, Fr.SelfHeight,
            b32.Canvas.Handle, 0, 0, Fr.SelfWidth, Fr.SelfHeight,
            SRCCOPY);

{         StretchDiBits(vDC,
              0, l_Top, FImageWidth, FImageHeight,
              0, 0, FImageWidth, FImageHeight,
              vHDR.fImageData, pBitmapInfo(@vHDR.BitmapInfo)^, DIB_RGB_COLORS, SRCCOPY);
}
//  rBMP.Canvas.Brush.Color := RGB((10* i mod 255), (10* i mod 255), (10* i mod 255) );
//  Ellipse(vDC, 5, l_Top + 2, vHDR.Width - 5, l_Top + vHDR.Height-2);

{
       StretchDiBits(Result.Canvas.Handle,
            0, l_Top, FImageWidth, FImageHeight,
            0, 0, FImageWidth, FImageHeight,
            b32.ScanLine[0], tempBitmapInfo, DIB_RGB_COLORS, SRCCOPY)
}
       end
      else
      // TPNGFrame.APNG_BLEND_OP_OVER
       begin
          bf.BlendOp := AC_SRC_OVER;
//          bf.BlendFlags := AC_DST_NO_PREMULT_ALPHA or AC_SRC_NO_PREMULT_ALPHA;
//          bf.BlendFlags := AC_SRC_NO_PREMULT_ALPHA;
          bf.BlendFlags := 0;
          bf.SourceConstantAlpha := $FF;
//          bf.SourceConstantAlpha := 0;
          bf.AlphaFormat := AC_SRC_ALPHA;
//         Premultiply(b32);
         AlphaBlend(vDC,
            fr.FXOffset, l_Top + fr.FYOffset, fr.FSelfWidth, fr.FSelfHeight,
            b32.Canvas.Handle, 0,0, fr.FSelfWidth, fr.FSelfHeight, bf)
       end;
     b32.Free;

   end;

  Result := rBMP;
end;

 {$ENDIF UseAnimation}

initialization
  {Initialize}
  ChunkClasses := nil;
  {crc table has not being computed yet}
//  crc_table_computed := FALSE;
  {Register the necessary chunks for png}
  RegisterCommonChunks;
  {Registers TPNGObject to use with TPicture}
  {$IFDEF UseDelphi}{$IFDEF RegisterGraphic}
    TPicture.RegisterFileFormat('PNG', 'Portable Network Graphics', TPNGObject);
  {$ENDIF}{$ENDIF}
finalization
  {$IFDEF UseDelphi}{$IFDEF RegisterGraphic}
    TPicture.UnregisterGraphicClass(TPNGObject);
  {$ENDIF}{$ENDIF}
  {Free chunk classes}
  FreeChunkClassList;
end.


