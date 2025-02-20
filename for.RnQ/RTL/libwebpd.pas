{**************************************************************************
                Copyright (c) PilotLogic Software House

 Package pl_WebP
 This file is part Of CodeTyphon Studio (https://www.pilotlogic.com)

 ***** BEGIN LICENSE BLOCK *****
 * Version: LGPL-2.1 with link exception (Modified LGPL)
 *
 * The contents Of this file are subject to the
 * GNU LIBRARY GENERAL PUBLIC LICENSE Version 2.1 (the "License")
 * with the following modification:
 *
 * As a special exception, the copyright holders Of this library give you
 * permission to link this library with independent modules to produce an
 * executable, regardless Of the license terms Of these independent modules,
 * and to copy and distribute the resulting executable under terms Of your choice,
 * provided that you also meet, For each linked independent module, the terms
 * and conditions Of the license Of that module. An independent module is a
 * module which is NOT derived from or based on this library. If you modify this
 * library, you may extend this exception to your version Of the library, but
 * you are NOT obligated to do so. If you do NOT wish to do so, delete this
 * exception statement from your version.
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * For the specific language governing rights and limitations under the
 * License.
 *
 * ***** END LICENSE BLOCK *****

 ***************************************************************************}

Unit libwebpd;

{$IFDEF FPC}
  {$MODE ObjFPC}{$H+}
  {$PACKENUM 4} // GCC on x86 enums have size of 4 bytes
  {$PACKRECORDS C}
{$ENDIF FPC}
{$ALIGN ON}
{$MINENUMSIZE 4}

Interface

Uses
{$IFDEF FPC}
   ctypes, dynlibs,
{$ENDIF FPC}
  Windows,
   Classes, SysUtils;


Const
{$IFDEF FPC}
   {$if defined(Windows)}
   clibWebpName = 'libwebp.dll';
   clibWebpName2 = 'libwebp-7.dll';
   libWebpName = 'libwebp-7.dll';
   {$elseif defined(darwin)}
   libWebpName = 'libwebp.7.dylib';
   {$elseif defined(linux)}
   libWebpName = 'libwebp.so.7';
   {$else}
   libWebpName = 'libwebp.so.7';
   {$endif}
{$ELSE ~FPC}
   clibWebpName = 'libwebp.dll';
   clibWebpName2 = 'libwebp-7.dll';
{$ENDIF FPC}

Type

// Output colorspaces
  WEBP_CSP_MODE = (
    MODE_RGB = 0,
    MODE_RGBA = 1,
    MODE_BGR = 2,
    MODE_BGRA = 3,
    MODE_ARGB = 4,
    MODE_RGBA_4444 = 5,
    MODE_RGB_565 = 6,
  // RGB-premultiplied transparent modes (alpha value is preserved)
  MODE_rgbATr = 7,
  MODE_bgrATr = 8,
  MODE_ArgbTr = 9,
  MODE_rgbATr_4444 = 10,
  // YUV modes must come after RGB ones.
  MODE_YUV = 11, MODE_YUVA = 12,  // yuv 4:2:0
  MODE_LAST = 13);

// Enumeration of the status codes
  TVP8StatusCode = (
    VP8_STATUS_OK = 0,
    VP8_STATUS_OUT_OF_MEMORY,
    VP8_STATUS_INVALID_PARAM,
    VP8_STATUS_BITSTREAM_ERROR,
    VP8_STATUS_UNSUPPORTED_FEATURE,
    VP8_STATUS_SUSPENDED,
    VP8_STATUS_USER_ABORT,
    VP8_STATUS_NOT_ENOUGH_DATA
  );
  TDecState = (
    STATE_HEADER = 0,
    STATE_PARTS0 = 1,
    STATE_DATA = 2,
    STATE_DONE = 3,
    STATE_ERROR = 4);
  // Decoding output parameters.
  PWebPDecParams = ^TWebPDecParams;
  TWebPDecParams = record
    output: PByte;              // rgb(a) or luma
    u, v: PByte;                // chroma u/v
    top_y, top_u, top_v: PByte; // cache for the fancy upscaler
    stride: Integer;            // rgb(a) stride or luma stride
    u_stride: Integer;          // chroma-u stride
    v_stride: Integer;          // chroma-v stride
    mode: WEBP_CSP_MODE;        // rgb(a) or yuv
    last_y: Integer;            // coordinate of the line that was last output
    output_size: Integer;       // size of 'output' buffer
    output_u_size: Integer;     // size of 'u' buffer
    output_v_size: Integer;     // size of 'v' buffer
    external_buffer: Integer;   // If true, the output buffers are externally owned
  end;
  PWebPIDecoder = ^TWebPIDecoder;
  TWebPIDecoder = record
    state_: TDecState;         // current decoding state
    w_, h_: integer;           // width and height
    params_: TWebPDecParams;   // Params to store output info
    dec_: Pointer;
  end;
  // Input / Output
  PVP8Io = ^VP8Io;
  VP8Io = record
    // set by VP8GetHeaders()
    width, height: Integer;    // picture dimensions, in pixels
    // set before calling put()
    mb_y: Integer;                  // position of the current rows (in pixels)
    mb_h: Integer;                  // number of rows in the sample
    y, u, v: PByte;                 // rows to copy (in yuv420 format)
    y_stride: Integer;              // row stride for luma
    uv_stride: Integer;             // row stride for chroma
    opaque: Pointer;              // user data
    // called when fresh samples are available. Currently, samples are in
    // YUV420 format, and can be up to width x 24 in size (depending on the
    // in-loop filtering level, e.g.). Should return false in case of error
    // or abort request.
    put: function(const io: PVP8Io): Integer; cdecl;
    // called just before starting to decode the blocks.
    // Should returns 0 in case of error.
    setup: function(io: PVP8Io): Integer; cdecl;
    // called just after block decoding is finished (or when an error occurred).
    teardown: procedure(const io: PVP8Io); cdecl;
    // this is a recommendation for the user-side yuv->rgb converter. This flag
    // is set when calling setup() hook and can be overwritten by it. It then
    // can be taken into consideration during the put() method.
    fancy_upscaling: Integer;
    // Input buffer.
    data_size: Cardinal;
    data: PByte;
    // If true, in-loop filtering will not be performed even if present in the
    // bitstream. Switching off filtering may speed up decoding at the expense
    // of more visible blocking. Note that output will also be non-compliant
    // with the VP8 specifications.
    bypass_filtering: Integer;
  end;
  // Main decoding object. This is an opaque structure.
  PVP8Decoder = ^VP8Decoder;
  VP8Decoder = record end;
//-----------------------------------------------------------------------------
// Coding parameters
  PWebPConfig = ^TWebPConfig;
  TWebPConfig = record
    quality: Single;            // between 0 (smallest file) and 100 (biggest)
    target_size: Integer;       // if non-zero, set the desired target size in bytes.
                                // Takes precedence over the 'compression' parameter.
    target_PSNR: Single;        // if non-zero, specifies the minimal distortion to
                                // try to achieve. Takes precedence over target_size.
    method: Integer;            // quality/speed trade-off (0=fast, 6=slower-better)
    segments: Integer;          // maximum number of segments to use, in [1..4]
    sns_strength: Integer;      // Spatial Noise Shaping. 0=off, 100=maximum.
    filter_strength: Integer;   // range: [0 = off .. 100 = strongest]
    filter_sharpness: Integer;  // range: [0 = off .. 7 = least sharp]
    filter_type: Integer;       // filtering type: 0 = simple, 1 = strong
                                // (only used if filter_strength > 0 or autofilter > 0)
    autofilter: Integer;        // Auto adjust filter's strength [0 = off, 1 = on]
    pass: Integer;              // number of entropy-analysis passes (in [1..10]).
    show_compressed: Integer;   // if true, export the compressed picture back.
                                // In-loop filtering is not applied.
    preprocessing: Integer;     // preprocessing filter (0=none, 1=segment-smooth)
    partitions: Integer;        // log2(number of token partitions) in [0..3]
                                // Default is set to 0 for easier progressive decoding.
  end;
// Enumerate some predefined settings for WebPConfig, depending on the type
// of source picture. These presets are used when calling WebPConfigPreset().
  TWebPPreset = (
    WEBP_PRESET_DEFAULT = 0,  // default preset.
    WEBP_PRESET_PICTURE,      // digital picture, like portrait, inner shot
    WEBP_PRESET_PHOTO,        // outdoor photograph, with natural lighting
    WEBP_PRESET_DRAWING,      // hand or line drawing, with high-contrast details
    WEBP_PRESET_ICON,         // small-sized colorful images
    WEBP_PRESET_TEXT          // text-like
  );
  PWebPPicture = ^TWebPPicture;
  //TWebPPicture = record end; // main structure for I/O
  // non-essential structure for storing auxilliary statistics
  PWebPAuxStats = ^TWebPAuxStats;
  TWebPAuxStats = record
    PSNR: array[0..3] of Single;                   // peak-signal-to-noise ratio for Y/U/V/All
    coded_size: Integer;                           // final size
    block_count: array[0..2] of Integer;           // number of intra4/intra16/skipped macroblocks
    header_bytes: array[0..1] of Integer;          // approximative number of bytes spent for header
                                                   // and mode-partition #0
    residual_bytes: array[0..2, 0..3] of Integer;  // approximative number of bytes spent for
                                                   // DC/AC/uv coefficients for each (0..3) segments.
    segment_size: array[0..3] of Integer;          // number of macroblocks in each segments
    segment_quant: array[0..3] of Integer;         // quantizer values for each segments
    segment_level: array[0..3] of Integer;         // filtering strength for each segments [0..63]
  end;
  // Signature for output function. Should return 1 if writing was successful.
  // data/data_size is the segment of data to write, and 'picture' is for
  // reference (and so one can make use of picture->custom_ptr).
  TWebPWriterFunction = function(const data: PByte; data_size: Cardinal;
    const picture: PWebPPicture): Integer; cdecl;
  TWebPPicture = record
    // input
    colorspace: Integer;            // colorspace: should be 0 for now (=Y'CbCr).
    width, height: Integer;         // dimensions.
    y, u, v: PByte;                 // pointers to luma/chroma planes.
    y_stride, uv_stride: Integer;   // luma/chroma strides.
    a: PByte;                       // pointer to the alpha plane (unused for now).
    // output
    writer: TWebPWriterFunction ;   // can be NULL
    custom_ptr: Pointer;            // can be used by the writer.
    // map for extra information
    extra_info_type: Integer;    // 1: intra type, 2: segment, 3: quant
                                 // 4: intra-16 prediction mode,
                                 // 5: chroma prediction mode,
                                 // 6: bit cost, 7: distortion
    extra_info: PByte;           // if not NULL, points to an array of size
                                 // ((width + 15) / 16) * ((height + 15) / 16) that
                                 // will be filled with a macroblock map, depending
                                 // on extra_info_type.
    // where to store statistics, if not NULL:
    stats: PWebPAuxStats;
  end;

// added in 1.2.4

  TWebPBitstreamFeatures = record
    width: Integer;          // Width in pixels, as read from the bitstream.
    height: Integer;         // Height in pixels, as read from the bitstream.
    has_alpha: Integer;      // True if the bitstream contains an alpha channel.
    has_animation: Integer;  // True if the bitstream is an animation.
    format: Integer;         // 0 = undefined (/mixed), 1 = lossy, 2 = lossless
    pad: array[0..4] of Cardinal;
  end;
  PWebPBitStreamFeatures= ^TWebPBitstreamFeatures;

  TWebpRGBABuffer = record
    rgba: PByte;             // pointer to RGBA samples
    stride: Integer;         // stride in bytes from one scanline to the next.
    size: size_t;            // total size of the *rgba buffer.
  end;

  TWebPYUVABuffer = record
    y, u, v, a: PByte;     // pointer to luma, chroma U/V, alpha samples
    y_stride: Integer;               // luma stride
    u_stride, v_stride: Integer;     // chroma strides
    a_stride: Integer;               // alpha stride
    y_size: size_t;              // luma plane size
    u_size, v_size: size_t;      // chroma planes size
    a_size: size_t;
  end;

  TGWebPDecodeBuffer = record  // to replace the C++ union
    RGBA: TWebPRGBABuffer;
    YuvSizeMinusRGBaSize: array[1..48 - 12] of Byte;
  end;

  TWebpDecBuffer = record
    colorspace: WEBP_CSP_MODE ;  // Colorspace.
    width, height: Integer;         // Dimensions.
    is_external_memory: Integer;    // If non-zero, 'internal_memory' pointer is not
                             // used. If value is '2' or more, the external
                             // memory is considered 'slow' and multiple
                             // read/write will be avoided.
//    RGBA: TGWebPDecodeBuffer;    // replacing:
    {case stupidanduseless: Boolean of
      true: (RGBA: TWebPRGBABuffer);
      false: (YUVA: TWebPYUVABuffer);}
    u: record {union}
       case longint of
         0: (RGBA: TWebPRGBABuffer);
         1: (YUVA: TWebPYUVABuffer);
       end;

    pad: array[0..3] of Cardinal;
    private_memory: PByte;   // Internally allocated memory (only when
                             // is_external_memory is 0). Should not be used
  end;
  PWebpDecBuffer = ^TWebpDecBuffer;

  TWebpDecBufferYUVA = record
    colorspace: WEBP_CSP_MODE ;  // Colorspace.
    width, height: Integer;         // Dimensions.
    is_external_memory: Integer;    // If non-zero, 'internal_memory' pointer is not
                             // used. If value is '2' or more, the external
                             // memory is considered 'slow' and multiple
                             // read/write will be avoided.
    YUVA: TWebPYUVABuffer;
    pad: array[0..3] of Cardinal;
    private_memory: PByte;   // Internally allocated memory (only when
                             // is_external_memory is 0). Should not be used
    {case stupid: Boolean of
      true: (RGBA: TWebPRGBABuffer);
      false: (YUVA: TWebPYUVABuffer);}
  end;
  PWebpDecBufferYUVA = ^TWebpDecBufferYUVA;


  TWebPDecoderOptions = record
    bypass_filtering: Integer;               // if true, skip the in-loop filtering
    no_fancy_upsampling: Integer;            // if true, use faster pointwise upsampler
    use_cropping: Integer;                   // if true, cropping is applied _first_
    crop_left, crop_top: Integer;            // top-left position for cropping.
                                        // Will be snapped to even values.
    crop_width, crop_height: Integer;        // dimension of the cropping area
    use_scaling: Integer;                    // if true, scaling is applied _afterward_
    scaled_width, scaled_height: Integer;    // final resolution
    use_threads: Integer;                    // if true, use multi-threaded decoding
    dithering_strength: Integer;             // dithering strength (0=Off, 100=full)
    flip: Integer;                           // if true, flip output vertically
    alpha_dithering_strength: Integer;       // alpha dithering strength in [0..100]
    pad: array[0..4] of UInt32;  // padding for later use
  end;

  TWebPDecoderConfig = record
    input: TWebPBitstreamFeatures;
    output: TWebPDecBuffer;         // Output buffer (can point to external mem)
    options: TWebPDecoderOptions;   // Decoding options
  end;
  PWebPDecoderConfig = ^TWebPDecoderConfig;

   //-------------------------------------------------
Type

// Return the encoder's version number, packed in hexadecimal using 8bits for
// each of major/minor/revision. E.g: v2.5.7 is 0x020507.
   TWebPGetEncoderVersion = function: Integer; cdecl;
   TWebPFree = Procedure(p: pointer); Cdecl;
   TWebPGetInfo = Function(Const Data: Pbyte; data_size: size_t; Width, Height: PInteger): Integer; Cdecl;
   TWebPDecodeRGB = Function(Const Data: Pbyte; data_size: size_t; Width, Height: PInteger): Pbyte; Cdecl;
   TWebPDecodeRGBA = Function(Const Data: Pbyte; data_size: size_t; Width, Height: PInteger): Pbyte; Cdecl;
   TWebPDecodeBGR = Function(Const Data: Pbyte; data_size: size_t; Width, Height: PInteger): Pbyte; Cdecl;
   TWebPDecodeBGRA = Function(Const Data: Pbyte; data_size: size_t; Width, Height: PInteger): Pbyte; Cdecl;
   TWebPDecodeARGB = Function(Const Data: Pbyte; data_size: size_t; Width, Height: PInteger): Pbyte; Cdecl;
   TWebPDecodeYUV = Function(Const Data: Pbyte; data_size: size_t; Width, Height: PInteger; Var u, v: Pbyte; stride, uv_stride: PInteger): Pbyte; Cdecl;
   TWebPDecodeRGBInto = Function(Const Data: Pbyte; data_size: size_t; output_buffer: Pbyte; output_buffer_size, output_stride: Integer): Pbyte; Cdecl;
   TWebPDecodeRGBAInto = Function(Const Data: Pbyte; data_size: size_t; output_buffer: Pbyte; output_buffer_size, output_stride: Integer): Pbyte; Cdecl;
   TWebPDecodeBGRInto = Function(Const Data: Pbyte; data_size: size_t; output_buffer: Pbyte; output_buffer_size, output_stride: Integer): Pbyte; Cdecl;
   TWebPDecodeBGRAInto = Function(Const Data: Pbyte; data_size: size_t; output_buffer: Pbyte; output_buffer_size, output_stride: Integer): Pbyte; Cdecl;
   TWebPDecodeYUVInto = Function(Const Data: Pbyte; data_size: size_t; luma: Pbyte; luma_size, luma_stride: Integer; u: Pbyte; u_size, u_stride: Integer; v: Pbyte; v_size, v_stride: Integer): Pbyte; Cdecl;
   TWebPINewRGB = Function(mode: WEBP_CSP_MODE; output_buffer: Pbyte; output_buffer_size, output_stride: Integer): PWebPIDecoder; Cdecl;
   TWebPINewYUV = Function(luma: Pbyte; luma_size, luma_stride: Integer; u: Pbyte; u_size, u_stride: Integer; v: Pbyte; v_size, v_stride: Integer): PWebPIDecoder; Cdecl;
   TWebPIDelete = Procedure(Const idec: PWebPIDecoder); Cdecl;
   TWebPIAppend = Function(Const idec: PWebPIDecoder; Const Data: Pbyte; data_size: size_t): TVP8StatusCode; Cdecl;
   TWebPIUpdate = Function(Const idec: PWebPIDecoder; Const Data: Pbyte; data_size: size_t): TVP8StatusCode; Cdecl;
   TWebPIDecGetRGB = Function(Const idec: PWebPIDecoder; last_y, Width, Height, stride: PInteger): Pbyte; Cdecl;
   TWebPEncodeRGB = Function(Const rgb: Pbyte; Width, Height, stride: Integer; quality_factor: Single; Var output: Pbyte): Cardinal; Cdecl;
   TWebPEncodeBGR = Function(Const bgr: Pbyte; Width, Height, stride: Integer; quality_factor: Single; Var output: Pbyte): Cardinal; Cdecl;
   TWebPEncodeRGBA = Function(Const rgba: Pbyte; Width, Height, stride: Integer; quality_factor: Single; Var output: Pbyte): Cardinal; Cdecl;
   TWebPEncodeBGRA = Function(Const bgra: Pbyte; Width, Height, stride: Integer; quality_factor: Single; Var output: Pbyte): Cardinal; Cdecl;
   TWebPEncodeLosslessRGB = Function(Const bgra: Pbyte; Width, Height, stride: Integer; Var output: Pbyte): size_t; Cdecl;
   TWebPEncodeLosslessBGR = Function(Const bgra: Pbyte; Width, Height, stride: Integer; Var output: Pbyte): size_t; Cdecl;
   TWebPEncodeLosslessRGBA = Function(Const bgra: Pbyte; Width, Height, stride: Integer; Var output: Pbyte): size_t; Cdecl;
   TWebPEncodeLosslessBGRA = Function(Const bgra: Pbyte; Width, Height, stride: Integer; Var output: Pbyte): size_t; Cdecl;
   TWebPValidateConfig = Function(Const config: PWebPConfig): Integer; Cdecl;
   TWebPPictureAlloc = Function(Const picture: PWebPPicture): Integer; Cdecl;
   TWebPPictureFree = Procedure(Const picture: PWebPPicture); Cdecl;
   TWebPPictureCopy = Function(Const src, dst: PWebPPicture): Integer; Cdecl;
   TWebPPictureCrop = Function(Const picture: PWebPPicture; left, top, Width, Height: Integer): Integer; Cdecl;
   TWebPPictureImportRGB = Function(Const picture: PWebPPicture; Const rgb: Pbyte; rgb_stride: Integer): Integer; Cdecl;
   TWebPPictureImportRGBA = Function(Const picture: PWebPPicture; Const rgba: Pbyte; rgba_stride: Integer): Integer; Cdecl;
   TWebPPictureImportBGR = Function(Const picture: PWebPPicture; Const bgr: Pbyte; bgr_stride: Integer): Integer; Cdecl;
   TWebPPictureImportBGRA = Function(Const picture: PWebPPicture; Const bgra: Pbyte; bgra_stride: Integer): Integer; Cdecl;
   TWebPEncode = Function(Const config: PWebPConfig; Const picture: PWebPPicture): Integer; Cdecl;


// added in 1.2.4
const
  WEBP_DECODER_ABI_VERSION = $0209;

type
//  TWebPGetFeaturesInternal = function (const data: PByte; data_size: Cardinal; features: PWebPBitstreamFeatures;
//                             version: Integer): TVP8StatusCode; cdecl;
  TWebPGetFeaturesInternal = function (const data: PByte; data_size: size_t; features: PWebPBitstreamFeatures;
                             version: Integer): TVP8StatusCode; cdecl;

  TWebPInitDecoderConfigInternal = function (config: PWebPDecoderConfig; version: Integer): Integer; cdecl;
  TWebPInitDecBufferInternal = function(buffer: PWebPDecBuffer; version: Integer): Integer; cdecl;
  TWebPFreeDecBuffer = procedure(buffer: PWebPDecBuffer); cdecl;
  TWebPDecode = function(const data: PByte; data_size: size_t; config: PWebPDecoderConfig): TVP8StatusCode; cdecl;

(*******************************************************************************
   decode_vp8.h
   Low-level API for VP8 decoder
 ******************************************************************************)
//-----------------------------------------------------------------------------
// Lower-level API
//
// Thes functions provide fine-grained control of the decoding process.
// The call flow should resemble:
//
//   VP8Io io;
//   VP8InitIo(&io);
//   io.data = data;
//   io.data_size = size;
//   /* customize io's functions (setup()/put()/teardown()) if needed. */
//
//   VP8Decoder* dec = VP8New();
//   bool ok = VP8Decode(dec);
//   if (!ok) printf("Error: %s\n", VP8StatusMessage(dec));
//   VP8Delete(dec);
//   return ok;

// Create a new decoder object.
  TVP8New = function: PWebPIDecoder; cdecl;
// Must be called to make sure 'io' is initialized properly.
// Returns false in case of version mismatch. Upon such failure, no other
// decoding function should be called (VP8Decode, VP8GetHeaders, ...)
  TVP8InitIoInternal = function(const io: PVP8Io; bersion: Integer): Integer; cdecl;
// Start decoding a new picture. Returns true if ok.
  TVP8GetHeaders = function(const dec: PVP8Decoder; const io: PVP8Io): Integer; cdecl;
// Decode a picture. Will call VP8GetHeaders() if it wasn't done already.
// Returns false in case of error.
  TVP8Decode = function(const dec: PVP8Decoder; const io: PVP8Io): Integer; cdecl;
// Return current status of the decoder:
  TVP8Status = function(const dec: PVP8Decoder): TVP8StatusCode; cdecl;
// return readable string corresponding to the last status.
  TVP8StatusMessage = function(const dec: PVP8Decoder): PAnsiChar; cdecl;
// Resets the decoder in its initial state, reclaiming memory.
// Not a mandatory call between calls to VP8Decode().
  TVP8Clear = procedure(const dec: PVP8Decoder); cdecl;
// Destroy the decoder object.
  TVP8Delete = procedure(const dec: PVP8Decoder); cdecl;

  function VP8InitIo(const io: PVP8Io): Integer;
  function WebPGetFeatures(data: PByte; data_size: NativeUint;
    features: PWebPBitstreamFeatures): TVp8StatusCode; Inline;
  function WebPInitDecoderConfig(config: PWebPDecoderConfig): Integer; Inline;
  function WebPInitDecBuffer(buffer: PWebPDecBuffer): Integer;


   //-------------------------------------------------
Var

   WebPGetEncoderVersion: TWebPGetEncoderVersion = NIL;
   WebPFree: TWebPFree = nil;
   WebPGetInfo: TWebPGetInfo = nil;
   WebPDecodeRGB: TWebPDecodeRGB = nil;
   WebPDecodeRGBA: TWebPDecodeRGBA = nil;
   WebPDecodeBGR: TWebPDecodeBGR = nil;
   WebPDecodeBGRA: TWebPDecodeBGRA = nil;
   WebPDecodeARGB: TWebPDecodeARGB = nil;
   WebPDecodeYUV: TWebPDecodeYUV = nil;
   WebPDecodeRGBInto: TWebPDecodeRGBInto = nil;
   WebPDecodeRGBAInto: TWebPDecodeRGBAInto = nil;
   WebPDecodeBGRInto: TWebPDecodeBGRInto = nil;
   WebPDecodeBGRAInto: TWebPDecodeBGRAInto = nil;
   WebPDecodeYUVInto: TWebPDecodeYUVInto = nil;
   WebPINewRGB: TWebPINewRGB = nil;
   WebPINewYUV: TWebPINewYUV = nil;
   WebPIDelete: TWebPIDelete = nil;
   WebPIAppend: TWebPIAppend = nil;
   WebPIUpdate: TWebPIUpdate = nil;
   WebPIDecGetRGB: TWebPIDecGetRGB = nil;
   VP8GetHeaders: TVP8GetHeaders = nil;
   VP8Decode: TVP8Decode = nil;
   VP8Status: TVP8Status = nil;
   VP8StatusMessage: TVP8StatusMessage = nil;
   VP8Clear: TVP8Clear = nil;
   VP8Delete: TVP8Delete = nil;
   WebPEncodeRGB: TWebPEncodeRGB = nil;
   WebPEncodeBGR: TWebPEncodeBGR = nil;
   WebPEncodeRGBA: TWebPEncodeRGBA = nil;
   WebPEncodeBGRA: TWebPEncodeBGRA = nil;
   WebPEncodeLosslessRGB: TWebPEncodeLosslessRGB = nil;
   WebPEncodeLosslessBGR: TWebPEncodeLosslessBGR = nil;
   WebPEncodeLosslessRGBA: TWebPEncodeLosslessRGBA = nil;
   WebPEncodeLosslessBGRA: TWebPEncodeLosslessBGRA = nil;
   WebPValidateConfig: TWebPValidateConfig = nil;
   WebPPictureAlloc: TWebPPictureAlloc = nil;
   WebPPictureFree: TWebPPictureFree = nil;
   WebPPictureCopy: TWebPPictureCopy = nil;
   WebPPictureCrop: TWebPPictureCrop = nil;
   WebPPictureImportRGB: TWebPPictureImportRGB = nil;
   WebPPictureImportRGBA: TWebPPictureImportRGBA = nil;
   WebPPictureImportBGR: TWebPPictureImportBGR = nil;
   WebPPictureImportBGRA: TWebPPictureImportBGRA = nil;
   WebPEncode: TWebPEncode = nil;
   VP8InitIoInternal: TVP8InitIoInternal = NIL;
   WebPDecode: TWebPDecode = NIL;
   WebPGetFeaturesInternal: TWebPGetFeaturesInternal = NIL;
   WebPInitDecoderConfigInternal: TWebPInitDecoderConfigInternal = NIL;
   WebPInitDecBufferInternal: TWebPInitDecBufferInternal = NIL;

   //=====================================================

Function  libWebp_Load(Const alibName: String = cLibWebpName): Boolean;
Procedure libWebp_Free;
Function  libWebp_IsLoaded: Boolean;

Implementation

Var
   VarWebp_Handle: THandle;

Function libWebp_IsLoaded: Boolean;
Begin
   Result := VarWebp_Handle <> 0;
End;

Procedure libWebp_Free;
Begin
   If (VarWebp_Handle <> 0) Then
      FreeLibrary(VarWebp_Handle);
End;

Function libWebp_Load(Const alibName: String = cLibWebpName): Boolean;
   //.............................
   Function _GetProcAddress(Const aProcName: String):
   {$IFDEF cpui8086}
FarPointer
   {$ELSE}
   Pointer
   {$ENDIF}
   ;
   var
     pn: WideString;
   Begin
      Result := nil;
      If aProcName = '' Then
         exit;
     {$IFDEF FPC}
      Result := dynlibs.GetProcedureAddress(VarWebp_Handle, Ansistring(aProcName));
     {$ELSE ~FPC}
      pn := aProcName;
      Result := GetProcAddress(VarWebp_Handle, PWideChar(pn));
     {$ENDIF FPC}
   End;
   //.....................................
Var
  {$IFDEF FPC}
   thelib: String;
  {$ELSE ~FPC}
   thelib: WideString;
  {$ENDIF FPC}
   {$IF DEFINED(UNIX) and (NOT DEFINED(DARWIN))}
  ssl:Integer;
  ssp:Integer;
   {$ENDIF}
Begin
   Result := False;

   If VarWebp_Handle <> 0 Then
   Begin
      Result := True;
      exit;
   End;

   If aLibName = '' Then
      thelib := clibWebpName
   Else
      thelib := aLibName;

  {$IFDEF FPC}
   VarWebp_Handle := dynlibs.LoadLibrary(thelib);
  {$ELSE ~FPC}
   VarWebp_Handle := LoadLibrary(PWideChar(thelib));
  {$ENDIF FPC}

   //.....................................
   // On UNIX If Library NOT load, try to load .so file
   {$IF DEFINED(UNIX) and (NOT DEFINED(DARWIN))}
   If VarWebp_Handle = 0 Then
   Begin
      ssl := length(thelib);
      ssp := Pos('.so.', thelib);
      If ssp > 0 Then
         delete(thelib, ssp, ssl - ssp + 1);

      VarWebp_Handle := dynlibs.LoadLibrary(thelib + '.so');
   End;
   {$ENDIF}

   If VarWebp_Handle = 0 Then
      Exit;

   //-------------------------------------------------
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPGetEncoderVersion) := _GetProcAddress('WebPGetEncoderVersion');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPFree) := _GetProcAddress('WebPFree');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPGetInfo) := _GetProcAddress('WebPGetInfo');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeRGB) := _GetProcAddress('WebPDecodeRGB');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeRGBA) := _GetProcAddress('WebPDecodeRGBA');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeBGR) := _GetProcAddress('WebPDecodeBGR');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeBGRA) := _GetProcAddress('WebPDecodeBGRA');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeARGB) := _GetProcAddress('WebPDecodeARGB');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeYUV) := _GetProcAddress('WebPDecodeYUV');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeRGBInto) := _GetProcAddress('WebPDecodeRGBInto');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeRGBAInto) := _GetProcAddress('WebPDecodeRGBAInto');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeBGRInto) := _GetProcAddress('WebPDecodeBGRInto');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeBGRAInto) := _GetProcAddress('WebPDecodeBGRAInto');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecodeYUVInto) := _GetProcAddress('WebPDecodeYUVInto');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPINewRGB) := _GetProcAddress('WebPINewRGB');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPINewYUV) := _GetProcAddress('WebPINewYUV');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPIDelete) := _GetProcAddress('WebPIDelete');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPIAppend) := _GetProcAddress('WebPIAppend');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPIUpdate) := _GetProcAddress('WebPIUpdate');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPIDecGetRGB) := _GetProcAddress('WebPIDecGetRGB');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPEncodeRGB) := _GetProcAddress('WebPEncodeRGB');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPEncodeBGR) := _GetProcAddress('WebPEncodeBGR');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPEncodeRGBA) := _GetProcAddress('WebPEncodeRGBA');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPEncodeBGRA) := _GetProcAddress('WebPEncodeBGRA');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPEncodeLosslessRGB) := _GetProcAddress('WebPEncodeLosslessRGB');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPEncodeLosslessBGR) := _GetProcAddress('WebPEncodeLosslessBGR');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPEncodeLosslessRGBA) := _GetProcAddress('WebPEncodeLosslessRGBA');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPEncodeLosslessBGRA) := _GetProcAddress('WebPEncodeLosslessBGRA');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPValidateConfig) := _GetProcAddress('WebPValidateConfig');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPPictureAlloc) := _GetProcAddress('WebPPictureAlloc');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPPictureFree) := _GetProcAddress('WebPPictureFree');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPPictureCopy) := _GetProcAddress('WebPPictureCopy');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPPictureCrop) := _GetProcAddress('WebPPictureCrop');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPPictureImportRGB) := _GetProcAddress('WebPPictureImportRGB');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPPictureImportRGBA) := _GetProcAddress('WebPPictureImportRGBA');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPPictureImportBGR) := _GetProcAddress('WebPPictureImportBGR');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPPictureImportBGRA) := _GetProcAddress('WebPPictureImportBGRA');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPEncode) := _GetProcAddress('WebPEncode');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPDecode) := _GetProcAddress('WebPDecode');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPGetFeaturesInternal) := _GetProcAddress('WebPGetFeaturesInternal');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPInitDecoderConfigInternal) := _GetProcAddress('WebPInitDecoderConfigInternal');
   Pointer({$IFNDEF FPC}@{$ENDIF}WebPInitDecBufferInternal) := _GetProcAddress('WebPInitDecBufferInternal');
//////////
   Pointer({$IFNDEF FPC}@{$ENDIF}VP8InitIoInternal) := _GetProcAddress('VP8InitIoInternal');
   Pointer({$IFNDEF FPC}@{$ENDIF}VP8GetHeaders) := _GetProcAddress('VP8GetHeaders');
   Pointer({$IFNDEF FPC}@{$ENDIF}VP8Decode) := _GetProcAddress('VP8Decode');
   Pointer({$IFNDEF FPC}@{$ENDIF}VP8Status) := _GetProcAddress('VP8Status');
   Pointer({$IFNDEF FPC}@{$ENDIF}VP8StatusMessage) := _GetProcAddress('VP8StatusMessage');
   Pointer({$IFNDEF FPC}@{$ENDIF}VP8Clear) := _GetProcAddress('VP8Clear');
   Pointer({$IFNDEF FPC}@{$ENDIF}VP8Delete) := _GetProcAddress('VP8Delete');

   //-------------------------------------------------

   Result := True;
End;

function VP8InitIo(const io: PVP8Io): Integer;
begin
  Result := VP8InitIoInternal(io, WEBP_DECODER_ABI_VERSION);
end;
// added in 1.2.4
function WebPGetFeatures(data: PByte; data_size: NativeUint;
    features: PWebPBitstreamFeatures): TVp8StatusCode;
begin
  Result := WebPGetFeaturesInternal(data, data_size, features,
                                 WEBP_DECODER_ABI_VERSION);
end;

function WebPInitDecoderConfig(config: PWebPDecoderConfig): Integer;
begin
  Result := WebPInitDecoderConfigInternal(config,
    WEBP_DECODER_ABI_VERSION);
end;

function WebPInitDecBuffer(buffer: PWebPDecBuffer): Integer;
begin
  Result := WebPInitDecBufferInternal(buffer, WEBP_DECODER_ABI_VERSION);
end;


//=================================================================
//=================================================================
//=================================================================

Initialization

Finalization

   libWebp_Free;
End.
