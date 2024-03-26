{
  BASS 2.4 Delphi unit (dynamic)
  Copyright (c) 1999-2022 Un4seen Developments Ltd.

  See the BASS.CHM file for more detailed documentation

  How to install
  ----------------
  Copy DYNAMIC_BASS.PAS to the \LIB subdirectory of your Delphi path or your project dir

  Call Load_BASSDLL (eg. in FormCreate) to load BASS before using any functions, and
  Unload_BASSDLL (eg. in FormDestory) to unload it when you're done.

  NOTE: Delphi users should use the BASS_UNICODE flag where possible
}

unit Dynamic_Bass;

interface

uses
  Windows,
  SysUtils;

const
  BASSVERSION = $204;             // API version
  BASSVERSIONTEXT = '2.4';

  // Use these to test for error from functions that return a DWORD or QWORD
  DW_ERROR = Cardinal(-1); // -1 (DWORD)
  QW_ERROR = Int64(-1);    // -1 (QWORD)

  // Error codes returned by BASS_ErrorGetCode()
  BASS_OK                 = 0;    // all is OK
  BASS_ERROR_MEM          = 1;    // memory error
  BASS_ERROR_FILEOPEN     = 2;    // can't open the file
  BASS_ERROR_DRIVER       = 3;    // can't find a free sound driver
  BASS_ERROR_BUFLOST      = 4;    // the sample buffer was lost
  BASS_ERROR_HANDLE       = 5;    // invalid handle
  BASS_ERROR_FORMAT       = 6;    // unsupported sample format
  BASS_ERROR_POSITION     = 7;    // invalid position
  BASS_ERROR_INIT         = 8;    // BASS_Init has not been successfully called
  BASS_ERROR_START        = 9;    // BASS_Start has not been successfully called
  BASS_ERROR_SSL          = 10;   // SSL/HTTPS support isn't available
  BASS_ERROR_REINIT       = 11;   // device needs to be reinitialized
  BASS_ERROR_ALREADY      = 14;   // already initialized/paused/whatever
  BASS_ERROR_NOTAUDIO     = 17;   // file does not contain audio
  BASS_ERROR_NOCHAN       = 18;   // can't get a free channel
  BASS_ERROR_ILLTYPE      = 19;   // an illegal type was specified
  BASS_ERROR_ILLPARAM     = 20;   // an illegal parameter was specified
  BASS_ERROR_NO3D         = 21;   // no 3D support
  BASS_ERROR_NOEAX        = 22;   // no EAX support
  BASS_ERROR_DEVICE       = 23;   // illegal device number
  BASS_ERROR_NOPLAY       = 24;   // not playing
  BASS_ERROR_FREQ         = 25;   // illegal sample rate
  BASS_ERROR_NOTFILE      = 27;   // the stream is not a file stream
  BASS_ERROR_NOHW         = 29;   // no hardware voices available
  BASS_ERROR_EMPTY        = 31;   // the file has no sample data
  BASS_ERROR_NONET        = 32;   // no internet connection could be opened
  BASS_ERROR_CREATE       = 33;   // couldn't create the file
  BASS_ERROR_NOFX         = 34;   // effects are not available
  BASS_ERROR_NOTAVAIL     = 37;   // requested data/action is not available
  BASS_ERROR_DECODE       = 38;   // the channel is/isn't a "decoding channel"
  BASS_ERROR_DX           = 39;   // a sufficient DirectX version is not installed
  BASS_ERROR_TIMEOUT      = 40;   // connection timedout
  BASS_ERROR_FILEFORM     = 41;   // unsupported file format
  BASS_ERROR_SPEAKER      = 42;   // unavailable speaker
  BASS_ERROR_VERSION      = 43;   // invalid BASS version (used by add-ons)
  BASS_ERROR_CODEC        = 44;   // codec is not available/supported
  BASS_ERROR_ENDED        = 45;   // the channel/file has ended
  BASS_ERROR_BUSY         = 46;   // the device is busy
  BASS_ERROR_UNSTREAMABLE = 47;   // unstreamable file
  BASS_ERROR_PROTOCOL     = 48;   // unsupported protocol
  BASS_ERROR_DENIED       = 49;   // access denied
  BASS_ERROR_UNKNOWN      = -1;   // some other mystery problem

  // BASS_SetConfig options
  BASS_CONFIG_BUFFER        = 0;
  BASS_CONFIG_UPDATEPERIOD  = 1;
  BASS_CONFIG_GVOL_SAMPLE   = 4;
  BASS_CONFIG_GVOL_STREAM   = 5;
  BASS_CONFIG_GVOL_MUSIC    = 6;
  BASS_CONFIG_CURVE_VOL     = 7;
  BASS_CONFIG_CURVE_PAN     = 8;
  BASS_CONFIG_FLOATDSP      = 9;
  BASS_CONFIG_3DALGORITHM   = 10;
  BASS_CONFIG_NET_TIMEOUT   = 11;
  BASS_CONFIG_NET_BUFFER    = 12;
  BASS_CONFIG_PAUSE_NOPLAY  = 13;
  BASS_CONFIG_NET_PREBUF    = 15;
  BASS_CONFIG_NET_PASSIVE   = 18;
  BASS_CONFIG_REC_BUFFER    = 19;
  BASS_CONFIG_NET_PLAYLIST  = 21;
  BASS_CONFIG_MUSIC_VIRTUAL = 22;
  BASS_CONFIG_VERIFY        = 23;
  BASS_CONFIG_UPDATETHREADS = 24;
  BASS_CONFIG_DEV_BUFFER    = 27;
  BASS_CONFIG_REC_LOOPBACK  = 28;
  BASS_CONFIG_VISTA_TRUEPOS = 30;
  BASS_CONFIG_IOS_SESSION   = 34;
  BASS_CONFIG_IOS_MIXAUDIO  = 34;
  BASS_CONFIG_MP3_ERRORS    = 35;
  BASS_CONFIG_DEV_DEFAULT   = 36;
  BASS_CONFIG_NET_READTIMEOUT = 37;
  BASS_CONFIG_VISTA_SPEAKERS = 38;
  BASS_CONFIG_IOS_SPEAKER   = 39;
  BASS_CONFIG_MF_DISABLE    = 40;
  BASS_CONFIG_HANDLES       = 41;
  BASS_CONFIG_UNICODE       = 42;
  BASS_CONFIG_SRC           = 43;
  BASS_CONFIG_SRC_SAMPLE    = 44;
  BASS_CONFIG_ASYNCFILE_BUFFER = 45;
  BASS_CONFIG_OGG_PRESCAN   = 47;
  BASS_CONFIG_MF_VIDEO      = 48;
  BASS_CONFIG_AIRPLAY       = 49;
  BASS_CONFIG_DEV_NONSTOP   = 50;
  BASS_CONFIG_IOS_NOCATEGORY = 51;
  BASS_CONFIG_VERIFY_NET    = 52;
  BASS_CONFIG_DEV_PERIOD    = 53;
  BASS_CONFIG_FLOAT         = 54;
  BASS_CONFIG_NET_SEEK      = 56;
  BASS_CONFIG_AM_DISABLE    = 58;
  BASS_CONFIG_NET_PLAYLIST_DEPTH = 59;
  BASS_CONFIG_NET_PREBUF_WAIT = 60;
  BASS_CONFIG_ANDROID_SESSIONID = 62;
  BASS_CONFIG_WASAPI_PERSIST = 65;
  BASS_CONFIG_REC_WASAPI    = 66;
  BASS_CONFIG_ANDROID_AAUDIO = 67;
  BASS_CONFIG_SAMPLE_ONEHANDLE = 69;
  BASS_CONFIG_NET_META      = 71;
  BASS_CONFIG_NET_RESTRATE  = 72;
  BASS_CONFIG_REC_DEFAULT = 73;
  BASS_CONFIG_NORAMP = 74;

  // BASS_SetConfigPtr options
  BASS_CONFIG_NET_AGENT     = 16;
  BASS_CONFIG_NET_PROXY     = 17;
  BASS_CONFIG_ANDROID_JAVAVM = 63;
  BASS_CONFIG_LIBSSL        = 64;
  BASS_CONFIG_FILENAME      = 75;

  BASS_CONFIG_THREAD = $40000000; // flag: thread-specific setting

  // BASS_CONFIG_IOS_SESSION flags
  BASS_IOS_SESSION_MIX      = 1;
  BASS_IOS_SESSION_DUCK     = 2;
  BASS_IOS_SESSION_AMBIENT  = 4;
  BASS_IOS_SESSION_SPEAKER  = 8;
  BASS_IOS_SESSION_DISABLE  = 16;
  BASS_IOS_SESSION_DEACTIVATE = 32;
  BASS_IOS_SESSION_AIRPLAY = 64;
  BASS_IOS_SESSION_BTHFP = 128;
  BASS_IOS_SESSION_BTA2DP = $100;

  // Initialization flags
  BASS_DEVICE_8BITS       = 1;    // use 8 bit resolution, else 16 bit - unused
  BASS_DEVICE_MONO        = 2;    // use mono, else stereo
  BASS_DEVICE_3D          = 4;    // enable 3D functionality - unused
  BASS_DEVICE_16BITS      = 8;    // limit output to 16-bit
  BASS_DEVICE_REINIT      = 128;  // reinitialize
  BASS_DEVICE_LATENCY     = 256;  // calculate device latency (BASS_INFO struct)
  BASS_DEVICE_CPSPEAKERS  = 1024; // detect speakers via Windows control panel
  BASS_DEVICE_SPEAKERS    = $800; // force enabling of speaker assignment
  BASS_DEVICE_NOSPEAKER   = $1000; // ignore speaker arrangement
  BASS_DEVICE_DMIX        = $2000; // use ALSA "dmix" plugin
  BASS_DEVICE_FREQ        = $4000; // set device sample rate
  BASS_DEVICE_STEREO      = $8000; // limit output to stereo
  BASS_DEVICE_AUDIOTRACK  = $20000; // use AudioTrack output
  BASS_DEVICE_DSOUND      = $40000; // use DirectSound output
  BASS_DEVICE_SOFTWARE    = $80000; // disable hardware/fastpath output

  // DirectSound interfaces (for use with BASS_GetDSoundObject)
  BASS_OBJECT_DS          = 1;   // IDirectSound
  BASS_OBJECT_DS3DL       = 2;   // IDirectSound3DListener

  // BASS_DEVICEINFO flags
  BASS_DEVICE_ENABLED     = 1;
  BASS_DEVICE_DEFAULT     = 2;
  BASS_DEVICE_INIT        = 4;
  BASS_DEVICE_LOOPBACK    = 8;
  BASS_DEVICE_DEFAULTCOM = 128;

  BASS_DEVICE_TYPE_MASK        = $ff000000;
  BASS_DEVICE_TYPE_NETWORK     = $01000000;
  BASS_DEVICE_TYPE_SPEAKERS    = $02000000;
  BASS_DEVICE_TYPE_LINE        = $03000000;
  BASS_DEVICE_TYPE_HEADPHONES  = $04000000;
  BASS_DEVICE_TYPE_MICROPHONE  = $05000000;
  BASS_DEVICE_TYPE_HEADSET     = $06000000;
  BASS_DEVICE_TYPE_HANDSET     = $07000000;
  BASS_DEVICE_TYPE_DIGITAL     = $08000000;
  BASS_DEVICE_TYPE_SPDIF       = $09000000;
  BASS_DEVICE_TYPE_HDMI        = $0a000000;
  BASS_DEVICE_TYPE_DISPLAYPORT = $40000000;

  // BASS_GetDeviceInfo flags
  BASS_DEVICES_AIRPLAY         = $1000000;

  // BASS_INFO flags (from DSOUND.H)
  DSCAPS_CONTINUOUSRATE   = $00000010;     // supports all sample rates between min/maxrate
  DSCAPS_EMULDRIVER       = $00000020;     // device does NOT have hardware DirectSound support
  DSCAPS_CERTIFIED        = $00000040;     // device driver has been certified by Microsoft
  DSCAPS_SECONDARYMONO    = $00000100;     // mono
  DSCAPS_SECONDARYSTEREO  = $00000200;     // stereo
  DSCAPS_SECONDARY8BIT    = $00000400;     // 8 bit
  DSCAPS_SECONDARY16BIT   = $00000800;     // 16 bit
  DSCAPS_HARDWARE         = $80000000;     // hardware mixed

  // BASS_RECORDINFO flags (from DSOUND.H)
  DSCCAPS_EMULDRIVER = DSCAPS_EMULDRIVER;  // device does NOT have hardware DirectSound recording support
  DSCCAPS_CERTIFIED = DSCAPS_CERTIFIED;    // device driver has been certified by Microsoft

  // defines for formats field of BASS_RECORDINFO (from MMSYSTEM.H)
  WAVE_FORMAT_1M08       = $00000001;      // 11.025 kHz, Mono,   8-bit
  WAVE_FORMAT_1S08       = $00000002;      // 11.025 kHz, Stereo, 8-bit
  WAVE_FORMAT_1M16       = $00000004;      // 11.025 kHz, Mono,   16-bit
  WAVE_FORMAT_1S16       = $00000008;      // 11.025 kHz, Stereo, 16-bit
  WAVE_FORMAT_2M08       = $00000010;      // 22.05  kHz, Mono,   8-bit
  WAVE_FORMAT_2S08       = $00000020;      // 22.05  kHz, Stereo, 8-bit
  WAVE_FORMAT_2M16       = $00000040;      // 22.05  kHz, Mono,   16-bit
  WAVE_FORMAT_2S16       = $00000080;      // 22.05  kHz, Stereo, 16-bit
  WAVE_FORMAT_4M08       = $00000100;      // 44.1   kHz, Mono,   8-bit
  WAVE_FORMAT_4S08       = $00000200;      // 44.1   kHz, Stereo, 8-bit
  WAVE_FORMAT_4M16       = $00000400;      // 44.1   kHz, Mono,   16-bit
  WAVE_FORMAT_4S16       = $00000800;      // 44.1   kHz, Stereo, 16-bit

  BASS_SAMPLE_8BITS       = 1;   // 8 bit
  BASS_SAMPLE_FLOAT       = 256; // 32-bit floating-point
  BASS_SAMPLE_MONO        = 2;   // mono
  BASS_SAMPLE_LOOP        = 4;   // looped
  BASS_SAMPLE_3D          = 8;   // 3D functionality
  BASS_SAMPLE_SOFTWARE    = 16;  // not using hardware mixing
  BASS_SAMPLE_MUTEMAX     = 32;  // mute at max distance (3D only)
  BASS_SAMPLE_VAM         = 64;  // DX7 voice allocation & management
  BASS_SAMPLE_FX          = 128; // old implementation of DX8 effects
  BASS_SAMPLE_OVER_VOL    = $10000; // override lowest volume
  BASS_SAMPLE_OVER_POS    = $20000; // override longest playing
  BASS_SAMPLE_OVER_DIST   = $30000; // override furthest from listener (3D only)

  BASS_STREAM_PRESCAN     = $20000; // enable pin-point seeking/length (MP3/MP2/MP1)
  BASS_STREAM_AUTOFREE	  = $40000; // automatically free the stream when it stops/ends
  BASS_STREAM_RESTRATE	  = $80000; // restrict the download rate of internet file streams
  BASS_STREAM_BLOCK       = $100000;// download/play internet file stream in small blocks
  BASS_STREAM_DECODE      = $200000;// don't play the stream, only decode
  BASS_STREAM_STATUS      = $800000;// give server status info (HTTP/ICY tags) in DOWNLOADPROC

  BASS_MP3_IGNOREDELAY    = $200; // ignore LAME/Xing/VBRI/iTunes delay & padding info
  BASS_MP3_SETPOS         = BASS_STREAM_PRESCAN;

  BASS_MUSIC_FLOAT        = BASS_SAMPLE_FLOAT;
  BASS_MUSIC_MONO         = BASS_SAMPLE_MONO;
  BASS_MUSIC_LOOP         = BASS_SAMPLE_LOOP;
  BASS_MUSIC_3D           = BASS_SAMPLE_3D;
  BASS_MUSIC_FX           = BASS_SAMPLE_FX;
  BASS_MUSIC_AUTOFREE     = BASS_STREAM_AUTOFREE;
  BASS_MUSIC_DECODE       = BASS_STREAM_DECODE;
  BASS_MUSIC_PRESCAN      = BASS_STREAM_PRESCAN; // calculate playback length
  BASS_MUSIC_CALCLEN      = BASS_MUSIC_PRESCAN;
  BASS_MUSIC_RAMP         = $200;  // normal ramping
  BASS_MUSIC_RAMPS        = $400;  // sensitive ramping
  BASS_MUSIC_SURROUND     = $800;  // surround sound
  BASS_MUSIC_SURROUND2    = $1000; // surround sound (mode 2)
  BASS_MUSIC_FT2PAN       = $2000; // apply FastTracker 2 panning to XM files
  BASS_MUSIC_FT2MOD       = $2000; // play .MOD as FastTracker 2 does
  BASS_MUSIC_PT1MOD       = $4000; // play .MOD as ProTracker 1 does
  BASS_MUSIC_NONINTER     = $10000; // non-interpolated sample mixing
  BASS_MUSIC_SINCINTER    = $800000; // sinc interpolated sample mixing
  BASS_MUSIC_POSRESET     = $8000; // stop all notes when moving position
  BASS_MUSIC_POSRESETEX   = $400000; // stop all notes and reset bmp/etc when moving position
  BASS_MUSIC_STOPBACK     = $80000; // stop the music on a backwards jump effect
  BASS_MUSIC_NOSAMPLE     = $100000; // don't load the samples

  // Speaker assignment flags
  BASS_SPEAKER_FRONT      = $1000000;  // front speakers
  BASS_SPEAKER_REAR       = $2000000;  // rear speakers
  BASS_SPEAKER_CENLFE     = $3000000;  // center & LFE speakers (5.1)
  BASS_SPEAKER_SIDE       = $4000000;  // side speakers (7.1)
  BASS_SPEAKER_LEFT       = $10000000; // modifier: left
  BASS_SPEAKER_RIGHT      = $20000000; // modifier: right
  BASS_SPEAKER_FRONTLEFT  = BASS_SPEAKER_FRONT or BASS_SPEAKER_LEFT;
  BASS_SPEAKER_FRONTRIGHT = BASS_SPEAKER_FRONT or BASS_SPEAKER_RIGHT;
  BASS_SPEAKER_REARLEFT   = BASS_SPEAKER_REAR or BASS_SPEAKER_LEFT;
  BASS_SPEAKER_REARRIGHT  = BASS_SPEAKER_REAR or BASS_SPEAKER_RIGHT;
  BASS_SPEAKER_CENTER     = BASS_SPEAKER_CENLFE or BASS_SPEAKER_LEFT;
  BASS_SPEAKER_LFE        = BASS_SPEAKER_CENLFE or BASS_SPEAKER_RIGHT;
  BASS_SPEAKER_SIDELEFT   = BASS_SPEAKER_SIDE or BASS_SPEAKER_LEFT;
  BASS_SPEAKER_SIDERIGHT  = BASS_SPEAKER_SIDE or BASS_SPEAKER_RIGHT;
  BASS_SPEAKER_REAR2      = BASS_SPEAKER_SIDE;
  BASS_SPEAKER_REAR2LEFT  = BASS_SPEAKER_SIDELEFT;
  BASS_SPEAKER_REAR2RIGHT = BASS_SPEAKER_SIDERIGHT;

  BASS_ASYNCFILE          = $40000000; // read file asynchronously
  BASS_UNICODE            = $80000000; // UTF-16

  BASS_RECORD_PAUSE       = $8000; // start recording paused

  // DX7 voice allocation & management flags
  BASS_VAM_HARDWARE       = 1;
  BASS_VAM_SOFTWARE       = 2;
  BASS_VAM_TERM_TIME      = 4;
  BASS_VAM_TERM_DIST      = 8;
  BASS_VAM_TERM_PRIO      = 16;

  BASS_ORIGRES_FLOAT      = $10000;

  // BASS_CHANNELINFO types
  BASS_CTYPE_SAMPLE       = 1;
  BASS_CTYPE_RECORD       = 2;
  BASS_CTYPE_STREAM       = $10000;
  BASS_CTYPE_STREAM_VORBIS = $10002;
  BASS_CTYPE_STREAM_OGG   = $10002;
  BASS_CTYPE_STREAM_MP1   = $10003;
  BASS_CTYPE_STREAM_MP2   = $10004;
  BASS_CTYPE_STREAM_MP3   = $10005;
  BASS_CTYPE_STREAM_AIFF  = $10006;
  BASS_CTYPE_STREAM_CA    = $10007;
  BASS_CTYPE_STREAM_MF    = $10008;
  BASS_CTYPE_STREAM_AM    = $10009;
  BASS_CTYPE_STREAM_SAMPLE = $1000a;
  BASS_CTYPE_STREAM_DUMMY = $18000;
  BASS_CTYPE_STREAM_DEVICE = $18001;
  BASS_CTYPE_STREAM_WAV   = $40000; // WAVE flag (LOWORD=codec)
  BASS_CTYPE_STREAM_WAV_PCM = $50001;
  BASS_CTYPE_STREAM_WAV_FLOAT = $50003;
  BASS_CTYPE_MUSIC_MOD    = $20000;
  BASS_CTYPE_MUSIC_MTM    = $20001;
  BASS_CTYPE_MUSIC_S3M    = $20002;
  BASS_CTYPE_MUSIC_XM     = $20003;
  BASS_CTYPE_MUSIC_IT     = $20004;
  BASS_CTYPE_MUSIC_MO3    = $00100; // MO3 flag

  // BASS_PluginLoad flags
  BASS_PLUGIN_PROC        = 1;

  // 3D channel modes
  BASS_3DMODE_NORMAL      = 0; // normal 3D processing
  BASS_3DMODE_RELATIVE    = 1; // position is relative to the listener
  BASS_3DMODE_OFF         = 2; // no 3D processing

  // software 3D mixing algorithms (used with BASS_CONFIG_3DALGORITHM)
  BASS_3DALG_DEFAULT      = 0;
  BASS_3DALG_OFF          = 1;
  BASS_3DALG_FULL         = 2;
  BASS_3DALG_LIGHT        = 3;

  // EAX environments, use with BASS_SetEAXParameters
  EAX_ENVIRONMENT_GENERIC           = 0;
  EAX_ENVIRONMENT_PADDEDCELL        = 1;
  EAX_ENVIRONMENT_ROOM              = 2;
  EAX_ENVIRONMENT_BATHROOM          = 3;
  EAX_ENVIRONMENT_LIVINGROOM        = 4;
  EAX_ENVIRONMENT_STONEROOM         = 5;
  EAX_ENVIRONMENT_AUDITORIUM        = 6;
  EAX_ENVIRONMENT_CONCERTHALL       = 7;
  EAX_ENVIRONMENT_CAVE              = 8;
  EAX_ENVIRONMENT_ARENA             = 9;
  EAX_ENVIRONMENT_HANGAR            = 10;
  EAX_ENVIRONMENT_CARPETEDHALLWAY   = 11;
  EAX_ENVIRONMENT_HALLWAY           = 12;
  EAX_ENVIRONMENT_STONECORRIDOR     = 13;
  EAX_ENVIRONMENT_ALLEY             = 14;
  EAX_ENVIRONMENT_FOREST            = 15;
  EAX_ENVIRONMENT_CITY              = 16;
  EAX_ENVIRONMENT_MOUNTAINS         = 17;
  EAX_ENVIRONMENT_QUARRY            = 18;
  EAX_ENVIRONMENT_PLAIN             = 19;
  EAX_ENVIRONMENT_PARKINGLOT        = 20;
  EAX_ENVIRONMENT_SEWERPIPE         = 21;
  EAX_ENVIRONMENT_UNDERWATER        = 22;
  EAX_ENVIRONMENT_DRUGGED           = 23;
  EAX_ENVIRONMENT_DIZZY             = 24;
  EAX_ENVIRONMENT_PSYCHOTIC         = 25;
  // total number of environments
  EAX_ENVIRONMENT_COUNT             = 26;

  // BASS_SampleGetChannel flags
  BASS_SAMCHAN_NEW        = 1; // get a new playback channel
  BASS_SAMCHAN_STREAM     = 2; // create a stream

  BASS_STREAMPROC_END = $80000000; // end of user stream flag

  // BASS_StreamCreateFileUser file systems
  STREAMFILE_NOBUFFER     = 0;
  STREAMFILE_BUFFER       = 1;
  STREAMFILE_BUFFERPUSH   = 2;

  // BASS_StreamPutFileData options
  BASS_FILEDATA_END       = 0; // end & close the file

  // BASS_StreamGetFilePosition modes
  BASS_FILEPOS_CURRENT    = 0;
  BASS_FILEPOS_DECODE     = BASS_FILEPOS_CURRENT;
  BASS_FILEPOS_DOWNLOAD   = 1;
  BASS_FILEPOS_END        = 2;
  BASS_FILEPOS_START      = 3;
  BASS_FILEPOS_CONNECTED  = 4;
  BASS_FILEPOS_BUFFER     = 5;
  BASS_FILEPOS_SOCKET     = 6;
  BASS_FILEPOS_ASYNCBUF   = 7;
  BASS_FILEPOS_SIZE       = 8;
  BASS_FILEPOS_BUFFERING  = 9;
  BASS_FILEPOS_AVAILABLE  = 10;

  // BASS_ChannelSetSync types
  BASS_SYNC_POS           = 0;
  BASS_SYNC_END           = 2;
  BASS_SYNC_META          = 4;
  BASS_SYNC_SLIDE         = 5;
  BASS_SYNC_STALL         = 6;
  BASS_SYNC_DOWNLOAD      = 7;
  BASS_SYNC_FREE          = 8;
  BASS_SYNC_SETPOS        = 11;
  BASS_SYNC_MUSICPOS      = 10;
  BASS_SYNC_MUSICINST     = 1;
  BASS_SYNC_MUSICFX       = 3;
  BASS_SYNC_OGG_CHANGE    = 12;
  BASS_SYNC_DEV_FAIL      = 14;
  BASS_SYNC_DEV_FORMAT    = 15;
  BASS_SYNC_THREAD        = $20000000; // flag: call sync in other thread
  BASS_SYNC_MIXTIME       = $40000000; // flag: sync at mixtime, else at playtime
  BASS_SYNC_ONETIME       = $80000000; // flag: sync only once, else continuously

  // BASS_ChannelIsActive return values
  BASS_ACTIVE_STOPPED = 0;
  BASS_ACTIVE_PLAYING = 1;
  BASS_ACTIVE_STALLED = 2;
  BASS_ACTIVE_PAUSED  = 3;
  BASS_ACTIVE_PAUSED_DEVICE = 4;

  // Channel attributes
  BASS_ATTRIB_FREQ                  = 1;
  BASS_ATTRIB_VOL                   = 2;
  BASS_ATTRIB_PAN                   = 3;
  BASS_ATTRIB_EAXMIX                = 4;
  BASS_ATTRIB_NOBUFFER              = 5;
  BASS_ATTRIB_VBR                   = 6;
  BASS_ATTRIB_CPU                   = 7;
  BASS_ATTRIB_SRC                   = 8;
  BASS_ATTRIB_NET_RESUME            = 9;
  BASS_ATTRIB_SCANINFO              = 10;
  BASS_ATTRIB_NORAMP                = 11;
  BASS_ATTRIB_BITRATE               = 12;
  BASS_ATTRIB_BUFFER                = 13;
  BASS_ATTRIB_GRANULE               = 14;
  BASS_ATTRIB_USER                  = 15;
  BASS_ATTRIB_TAIL                  = 16;
  BASS_ATTRIB_PUSH_LIMIT            = 17;
  BASS_ATTRIB_DOWNLOADPROC          = 18;
  BASS_ATTRIB_VOLDSP                = 19;
  BASS_ATTRIB_VOLDSP_PRIORITY       = 20;
  BASS_ATTRIB_MUSIC_AMPLIFY         = $100;
  BASS_ATTRIB_MUSIC_PANSEP          = $101;
  BASS_ATTRIB_MUSIC_PSCALER         = $102;
  BASS_ATTRIB_MUSIC_BPM             = $103;
  BASS_ATTRIB_MUSIC_SPEED           = $104;
  BASS_ATTRIB_MUSIC_VOL_GLOBAL      = $105;
  BASS_ATTRIB_MUSIC_ACTIVE          = $106;
  BASS_ATTRIB_MUSIC_VOL_CHAN        = $200; // + channel #
  BASS_ATTRIB_MUSIC_VOL_INST        = $300; // + instrument #

  // BASS_ChannelSlideAttribute flags
  BASS_SLIDE_LOG                    = $1000000;

  // BASS_ChannelGetData flags
  BASS_DATA_AVAILABLE = 0;        // query how much data is buffered
  BASS_DATA_NOREMOVE  = $10000000; // flag: don't remove data from recording buffer
  BASS_DATA_FIXED     = $20000000; // unused
  BASS_DATA_FLOAT     = $40000000; // flag: return floating-point sample data
  BASS_DATA_FFT256    = $80000000; // 256 sample FFT
  BASS_DATA_FFT512    = $80000001; // 512 FFT
  BASS_DATA_FFT1024   = $80000002; // 1024 FFT
  BASS_DATA_FFT2048   = $80000003; // 2048 FFT
  BASS_DATA_FFT4096   = $80000004; // 4096 FFT
  BASS_DATA_FFT8192   = $80000005; // 8192 FFT
  BASS_DATA_FFT16384  = $80000006; // 16384 FFT
  BASS_DATA_FFT32768  = $80000007; // 32768 FFT
  BASS_DATA_FFT_INDIVIDUAL = $10; // FFT flag: FFT for each channel, else all combined
  BASS_DATA_FFT_NOWINDOW = $20;   // FFT flag: no Hanning window
  BASS_DATA_FFT_REMOVEDC = $40;   // FFT flag: pre-remove DC bias
  BASS_DATA_FFT_COMPLEX = $80;    // FFT flag: return complex data
  BASS_DATA_FFT_NYQUIST = $100;   // FFT flag: return extra Nyquist value

  // BASS_ChannelGetLevelEx flags
  BASS_LEVEL_MONO     = 1; // get mono level
  BASS_LEVEL_STEREO   = 2; // get stereo level
  BASS_LEVEL_RMS      = 4; // get RMS levels
  BASS_LEVEL_VOLPAN   = 8; // apply VOL/PAN attributes to the levels
  BASS_LEVEL_NOREMOVE = 16; // don't remove data from recording buffer

  // BASS_ChannelGetTags types : what's returned
  BASS_TAG_ID3        = 0; // ID3v1 tags : TAG_ID3 structure
  BASS_TAG_ID3V2      = 1; // ID3v2 tags : variable length block
  BASS_TAG_OGG        = 2; // OGG comments : series of null-terminated UTF-8 strings
  BASS_TAG_HTTP       = 3; // HTTP headers : series of null-terminated ASCII strings
  BASS_TAG_ICY        = 4; // ICY headers : series of null-terminated ANSI strings
  BASS_TAG_META       = 5; // ICY metadata : ANSI string
  BASS_TAG_APE        = 6; // APEv2 tags : series of null-terminated UTF-8 strings
  BASS_TAG_MP4        = 7; // MP4/iTunes metadata : series of null-terminated UTF-8 strings
  BASS_TAG_WMA        = 8; // WMA tags : series of null-terminated UTF-8 strings
  BASS_TAG_VENDOR     = 9; // OGG encoder : UTF-8 string
  BASS_TAG_LYRICS3    = 10; // Lyric3v2 tag : ASCII string
  BASS_TAG_CA_CODEC   = 11;	// CoreAudio codec info : TAG_CA_CODEC structure
  BASS_TAG_MF         = 13;	// Media Foundation tags : series of null-terminated UTF-8 strings
  BASS_TAG_WAVEFORMAT = 14;	// WAVE format : WAVEFORMATEEX structure
  BASS_TAG_AM_NAME    = 16; // Android Media codec name : ASCII string
  BASS_TAG_ID3V2_2    = 17; // ID3v2 tags (2nd block) : variable length block
  BASS_TAG_AM_MIME    = 18; // Android Media MIME type : ASCII string
  BASS_TAG_LOCATION   = 19; // redirected URL : ASCII string
  BASS_TAG_RIFF_INFO  = $100; // RIFF "INFO" tags : series of null-terminated ANSI strings
  BASS_TAG_RIFF_BEXT  = $101; // RIFF/BWF "bext" tags : TAG_BEXT structure
  BASS_TAG_RIFF_CART  = $102; // RIFF/BWF "cart" tags : TAG_CART structure
  BASS_TAG_RIFF_DISP  = $103; // RIFF "DISP" text tag : ANSI string
  BASS_TAG_RIFF_CUE   = $104; // RIFF "cue " chunk : TAG_CUE structure
  BASS_TAG_RIFF_SMPL  = $105; // RIFF "smpl" chunk : TAG_SMPL structure
  BASS_TAG_APE_BINARY = $1000; // + index #, binary APEv2 tag : TAG_APE_BINARY structure
  BASS_TAG_MUSIC_NAME = $10000;	// MOD music name : ANSI string
  BASS_TAG_MUSIC_MESSAGE = $10001; // MOD message : ANSI string
  BASS_TAG_MUSIC_ORDERS = $10002; // MOD order list : BYTE array of pattern numbers
  BASS_TAG_MUSIC_AUTH = $10003; // MOD author : UTF-8 string
  BASS_TAG_MUSIC_INST = $10100; // + instrument #, MOD instrument name : ANSI string
  BASS_TAG_MUSIC_CHAN = $10200; // + channel #, MOD channel name : ANSI string
  BASS_TAG_MUSIC_SAMPLE = $10300; // + sample #, MOD sample name : ANSI string

  // BASS_ChannelGetLength/GetPosition/SetPosition modes
  BASS_POS_BYTE           = 0; // byte position
  BASS_POS_MUSIC_ORDER    = 1; // order.row position, MAKELONG(order,row)
  BASS_POS_OGG            = 3; // OGG bitstream number
  BASS_POS_END            = $10; // trimmed end position
  BASS_POS_LOOP           = $11; // loop start positiom
  BASS_POS_FLUSH          = $1000000; // flag: flush decoder/FX buffers
  BASS_POS_RESET          = $2000000; // flag: reset user file buffers
  BASS_POS_RELATIVE       = $4000000; // flag: seek relative to the current position
  BASS_POS_INEXACT        = $8000000; // flag: allow seeking to inexact position
  BASS_POS_DECODE         = $10000000; // flag: get the decoding (not playing) position
  BASS_POS_DECODETO       = $20000000; // flag: decode to the position instead of seeking
  BASS_POS_SCAN           = $40000000; // flag: scan to the position

  // BASS_ChannelSetDevice/GetDevice option
  BASS_NODEVICE           = $20000;

  // BASS_RecordSetInput flags
  BASS_INPUT_OFF    = $10000;
  BASS_INPUT_ON     = $20000;

  BASS_INPUT_TYPE_MASK    = $FF000000;
  BASS_INPUT_TYPE_UNDEF   = $00000000;
  BASS_INPUT_TYPE_DIGITAL = $01000000;
  BASS_INPUT_TYPE_LINE    = $02000000;
  BASS_INPUT_TYPE_MIC     = $03000000;
  BASS_INPUT_TYPE_SYNTH   = $04000000;
  BASS_INPUT_TYPE_CD      = $05000000;
  BASS_INPUT_TYPE_PHONE   = $06000000;
  BASS_INPUT_TYPE_SPEAKER = $07000000;
  BASS_INPUT_TYPE_WAVE    = $08000000;
  BASS_INPUT_TYPE_AUX     = $09000000;
  BASS_INPUT_TYPE_ANALOG  = $0A000000;

  // BASS_ChannelSetFX effect types
  BASS_FX_DX8_CHORUS	  = 0;
  BASS_FX_DX8_COMPRESSOR  = 1;
  BASS_FX_DX8_DISTORTION  = 2;
  BASS_FX_DX8_ECHO        = 3;
  BASS_FX_DX8_FLANGER     = 4;
  BASS_FX_DX8_GARGLE      = 5;
  BASS_FX_DX8_I3DL2REVERB = 6;
  BASS_FX_DX8_PARAMEQ     = 7;
  BASS_FX_DX8_REVERB      = 8;
  BASS_FX_VOLUME          = 9;

  BASS_DX8_PHASE_NEG_180 = 0;
  BASS_DX8_PHASE_NEG_90  = 1;
  BASS_DX8_PHASE_ZERO    = 2;
  BASS_DX8_PHASE_90      = 3;
  BASS_DX8_PHASE_180     = 4;

type
  DWORD = Cardinal;
  BOOL = LongBool;
  FLOAT = Single;
  QWORD = Int64;

  HMUSIC = DWORD;       // MOD music handle
  HSAMPLE = DWORD;      // sample handle
  HCHANNEL = DWORD;     // sample playback handle
  HSTREAM = DWORD;      // sample stream handle
  HRECORD = DWORD;      // recording handle
  HSYNC = DWORD;        // synchronizer handle
  HDSP = DWORD;         // DSP handle
  HFX = DWORD;          // DX8 effect handle
  HPLUGIN = DWORD;      // Plugin handle

  // Device info structure
  BASS_DEVICEINFO = record
    name: PAnsiChar;    // description
    driver: PAnsiChar;  // driver
    flags: DWORD;
  end;

  BASS_INFO = record
    flags: DWORD;       // device capabilities (DSCAPS_xxx flags)
    hwsize: DWORD;      // size of total device hardware memory
    hwfree: DWORD;      // size of free device hardware memory
    freesam: DWORD;     // number of free sample slots in the hardware
    free3d: DWORD;      // number of free 3D sample slots in the hardware
    minrate: DWORD;     // min sample rate supported by the hardware
    maxrate: DWORD;     // max sample rate supported by the hardware
    eax: BOOL;          // device supports EAX? (always FALSE if BASS_DEVICE_3D was not used)
    minbuf: DWORD;      // recommended minimum buffer length in ms (requires BASS_DEVICE_LATENCY)
    dsver: DWORD;       // DirectSound version
    latency: DWORD;     // average delay (in ms) before start of playback
    initflags: DWORD;   // BASS_Init "flags" parameter
    speakers: DWORD;    // number of speakers available
    freq: DWORD;        // current output rate
  end;

  // Recording device info structure
  BASS_RECORDINFO = record
    flags: DWORD;       // device capabilities (DSCCAPS_xxx flags)
    formats: DWORD;     // supported standard formats (WAVE_FORMAT_xxx flags)
    inputs: DWORD;      // number of inputs
    singlein: BOOL;     // only 1 input can be set at a time
    freq: DWORD;        // current input rate
  end;

  // Sample info structure
  BASS_SAMPLE = record
    freq: DWORD;        // default playback rate
    volume: Single;     // default volume (0-100)
    pan: Single;        // default pan (-100=left, 0=middle, 100=right)
    flags: DWORD;       // BASS_SAMPLE_xxx flags
    length: DWORD;      // length (in samples, not bytes)
    max: DWORD;         // maximum simultaneous playbacks
    origres: DWORD;     // original resolution
    chans: DWORD;       // number of channels
    mingap: DWORD;      // minimum gap (ms) between creating channels
    mode3d: DWORD;      // BASS_3DMODE_xxx mode
    mindist: Single;    // minimum distance
    maxdist: Single;    // maximum distance
    iangle: DWORD;      // angle of inside projection cone
    oangle: DWORD;      // angle of outside projection cone
    outvol: Single;     // delta-volume outside the projection cone
    vam: DWORD;         // unused
    priority: DWORD;    // unused
  end;

  // Channel info structure
  BASS_CHANNELINFO = record
    freq: DWORD;        // default playback rate
    chans: DWORD;       // channels
    flags: DWORD;
    ctype: DWORD;       // type of channel
    origres: DWORD;     // original resolution
    plugin: HPLUGIN;
    sample: HSAMPLE;
    {$IFDEF CPUX64}
    padding: DWORD;
    {$ENDIF}
    filename: PChar;
  end;

  BASS_PLUGINFORM = record
    ctype: DWORD;       // channel type
    {$IFDEF CPUX64}
    padding: DWORD;
    {$ENDIF}
    name: PAnsiChar;    // format description
    exts: PAnsiChar;    // file extension filter (*.ext1;*.ext2;etc...)
  end;
  PBASS_PLUGINFORMS = ^TBASS_PLUGINFORMS;
  TBASS_PLUGINFORMS = array[0..maxInt div sizeOf(BASS_PLUGINFORM) - 1] of BASS_PLUGINFORM;

  PBASS_PLUGININFO = ^BASS_PLUGININFO;
  BASS_PLUGININFO = record
    version: DWORD;             // version (same form as BASS_GetVersion)
    formatc: DWORD;             // number of formats
    formats: PBASS_PLUGINFORMS; // the array of formats
  end;

  // 3D vector (for 3D positions/velocities/orientations)
  BASS_3DVECTOR = record
    x: Single;          // +=right, -=left
    y: Single;          // +=up, -=down
    z: Single;          // +=front, -=behind
  end;

  // User file stream callback functions
  FILECLOSEPROC = procedure(user: Pointer); stdcall;
  FILELENPROC = function(user: Pointer): QWORD; stdcall;
  FILEREADPROC = function(buffer: Pointer; length: DWORD; user: Pointer): DWORD; stdcall;
  FILESEEKPROC = function(offset: QWORD; user: Pointer): BOOL; stdcall;

  BASS_FILEPROCS = record
    close: FILECLOSEPROC;
    length: FILELENPROC;
    read: FILEREADPROC;
    seek: FILESEEKPROC;
  end;

  // ID3v1 tag structure
  PTAG_ID3 = ^TAG_ID3;
  TAG_ID3 = record
    id: Array[0..2] of AnsiChar;
    title: Array[0..29] of AnsiChar;
    artist: Array[0..29] of AnsiChar;
    album: Array[0..29] of AnsiChar;
    year: Array[0..3] of AnsiChar;
    comment: Array[0..29] of AnsiChar;
    genre: Byte;
  end;

  // Binary APEv2 tag structure
  PTAG_APE_BINARY = ^TAG_APE_BINARY;
  TAG_APE_BINARY = record
    key: PAnsiChar;
    data: PAnsiChar;
    length: DWORD;
  end;

  // BWF "bext" tag structure
  PTAG_BEXT = ^TAG_BEXT;
  TAG_BEXT = packed record
    Description: Array[0..255] of AnsiChar;     // description
    Originator: Array[0..31] of AnsiChar;       // name of the originator
    OriginatorReference: Array[0..31] of AnsiChar; // reference of the originator
    OriginationDate: Array[0..9] of AnsiChar;   // date of creation (yyyy-mm-dd)
    OriginationTime: Array[0..7] of AnsiChar;   // time of creation (hh-mm-ss)
    TimeReference: QWORD;                       // first sample count since midnight (little-endian)
    Version: Word;                              // BWF version (little-endian)
    UMID: Array[0..63] of Byte;                 // SMPTE UMID
    Reserved: Array[0..189] of Byte;
    CodingHistory: AnsiChar;                    // history
  end;

  BASS_DX8_CHORUS = record
    fWetDryMix: Single;
    fDepth: Single;
    fFeedback: Single;
    fFrequency: Single;
    lWaveform: DWORD;   // 0=triangle, 1=sine
    fDelay: Single;
    lPhase: DWORD;      // BASS_DX8_PHASE_xxx
  end;

  BASS_DX8_COMPRESSOR = record
    fGain: Single;
    fAttack: Single;
    fRelease: Single;
    fThreshold: Single;
    fRatio: Single;
    fPredelay: Single;
  end;

  BASS_DX8_DISTORTION = record
    fGain: Single;
    fEdge: Single;
    fPostEQCenterFrequency: Single;
    fPostEQBandwidth: Single;
    fPreLowpassCutoff: Single;
  end;

  BASS_DX8_ECHO = record
    fWetDryMix: Single;
    fFeedback: Single;
    fLeftDelay: Single;
    fRightDelay: Single;
    lPanDelay: BOOL;
  end;

  BASS_DX8_FLANGER = record
    fWetDryMix: Single;
    fDepth: Single;
    fFeedback: Single;
    fFrequency: Single;
    lWaveform: DWORD;   // 0=triangle, 1=sine
    fDelay: Single;
    lPhase: DWORD;      // BASS_DX8_PHASE_xxx
  end;

  BASS_DX8_GARGLE = record
    dwRateHz: DWORD;               // Rate of modulation in hz
    dwWaveShape: DWORD;            // 0=triangle, 1=square
  end;

  BASS_DX8_I3DL2REVERB = record
    lRoom: Integer;                // [-10000, 0]      default: -1000 mB
    lRoomHF: Integer;              // [-10000, 0]      default: 0 mB
    flRoomRolloffFactor: Single;   // [0.0, 10.0]      default: 0.0
    flDecayTime: Single;           // [0.1, 20.0]      default: 1.49s
    flDecayHFRatio: Single;        // [0.1, 2.0]       default: 0.83
    lReflections: Integer;         // [-10000, 1000]   default: -2602 mB
    flReflectionsDelay: Single;    // [0.0, 0.3]       default: 0.007 s
    lReverb: Integer;              // [-10000, 2000]   default: 200 mB
    flReverbDelay: Single;         // [0.0, 0.1]       default: 0.011 s
    flDiffusion: Single;           // [0.0, 100.0]     default: 100.0 %
    flDensity: Single;             // [0.0, 100.0]     default: 100.0 %
    flHFReference: Single;         // [20.0, 20000.0]  default: 5000.0 Hz
  end;

  BASS_DX8_PARAMEQ = record
    fCenter: Single;
    fBandwidth: Single;
    fGain: Single;
  end;

  BASS_DX8_REVERB = record
    fInGain: Single;               // [-96.0,0.0]            default: 0.0 dB
    fReverbMix: Single;            // [-96.0,0.0]            default: 0.0 db
    fReverbTime: Single;           // [0.001,3000.0]         default: 1000.0 ms
    fHighFreqRTRatio: Single;      // [0.001,0.999]          default: 0.001
  end;

  BASS_FX_VOLUME_PARAM = record
    fTarget: Single;
    fCurrent: Single;
    fTime: Single;
    lCurve: DWORD;
  end;

  // callback function types
  STREAMPROC = function(handle: HSTREAM; buffer: Pointer; length: DWORD; user: Pointer): DWORD; stdcall;
  {
    User stream callback function.
    handle : The stream that needs writing
    buffer : Buffer to write the samples in
    length : Number of bytes to write
    user   : The 'user' parameter value given when calling BASS_StreamCreate
    RETURN : Number of bytes written. Set the BASS_STREAMPROC_END flag to end
             the stream.
  }

const
  // Special STREAMPROCs
  STREAMPROC_DUMMY = Pointer(0);   // "dummy" stream
  STREAMPROC_PUSH = Pointer(-1);   // push stream
  STREAMPROC_DEVICE = Pointer(-2); // device mix stream
  STREAMPROC_DEVICE_3D = Pointer(-3); // device 3D mix stream

type
  DOWNLOADPROC = procedure(buffer: Pointer; length: DWORD; user: Pointer); stdcall;
  {
    Internet stream download callback function.
    buffer : Buffer containing the downloaded data... NULL=end of download
    length : Number of bytes in the buffer
    user   : The 'user' parameter value given when calling BASS_StreamCreateURL
  }

  SYNCPROC = procedure(handle: HSYNC; channel, data: DWORD; user: Pointer); stdcall;
  {
    Sync callback function.
    handle : The sync that has occured
    channel: Channel that the sync occured in
    data   : Additional data associated with the sync's occurance
    user   : The 'user' parameter given when calling BASS_ChannelSetSync
  }

  DSPPROC = procedure(handle: HDSP; channel: DWORD; buffer: Pointer; length: DWORD; user: Pointer); stdcall;
  {
    DSP callback function.
    handle : The DSP handle
    channel: Channel that the DSP is being applied to
    buffer : Buffer to apply the DSP to
    length : Number of bytes in the buffer
    user   : The 'user' parameter given when calling BASS_ChannelSetDSP
  }

  RECORDPROC = function(handle: HRECORD; buffer: Pointer; length: DWORD; user: Pointer): BOOL; stdcall;
  {
    Recording callback function.
    handle : The recording handle
    buffer : Buffer containing the recorded sample data
    length : Number of bytes
    user   : The 'user' parameter value given when calling BASS_RecordStart
    RETURN : TRUE = continue recording, FALSE = stop
  }


// Vars that will hold our dynamically loaded functions...
var
  BASS_SetConfig:function(option, value: DWORD): BOOL; stdcall;
  BASS_GetConfig:function(option: DWORD): DWORD; stdcall;
  BASS_SetConfigPtr:function(option: DWORD; value: Pointer): BOOL; stdcall;
  BASS_GetConfigPtr:function(option: DWORD): Pointer; stdcall;
  BASS_GetVersion:function: DWORD; stdcall;
  BASS_ErrorGetCode:function: Integer; stdcall;
  BASS_GetDeviceInfo:function(device: DWORD; var info: BASS_DEVICEINFO): BOOL; stdcall;
  BASS_Init:function(device: Integer; freq, flags: DWORD; win: HWND; clsid: Pointer): BOOL; stdcall;
  BASS_SetDevice:function(device: DWORD): BOOL; stdcall;
  BASS_GetDevice:function: DWORD; stdcall;
  BASS_Free:function: BOOL; stdcall;
  BASS_GetDSoundObject:function(obj: DWORD): Pointer; stdcall;
  BASS_GetInfo:function(var info: BASS_INFO): BOOL; stdcall;
  BASS_Update:function(length: DWORD): BOOL; stdcall;
  BASS_GetCPU:function: FLOAT; stdcall;
  BASS_Start:function: BOOL; stdcall;
  BASS_Stop:function: BOOL; stdcall;
  BASS_Pause:function: BOOL; stdcall;
  BASS_IsStarted:function: DWORD; stdcall;
  BASS_SetVolume:function(volume: FLOAT): BOOL; stdcall;
  BASS_GetVolume:function: FLOAT; stdcall;

  BASS_Set3DFactors:function(distf, rollf, doppf: FLOAT): BOOL; stdcall;
  BASS_Get3DFactors:function(var distf, rollf, doppf: FLOAT): BOOL; stdcall;
  BASS_Set3DPosition:function(var pos, vel, front, top: BASS_3DVECTOR): BOOL; stdcall;
  BASS_Get3DPosition:function(var pos, vel, front, top: BASS_3DVECTOR): BOOL; stdcall;
  BASS_Apply3D:procedure; stdcall;
  BASS_SetEAXParameters:function(env: Integer; vol, decay, damp: FLOAT): BOOL; stdcall;
  BASS_GetEAXParameters:function(var env: DWORD; var vol, decay, damp: FLOAT): BOOL; stdcall;

  BASS_PluginLoad:function(filename: PChar; flags: DWORD): HPLUGIN; stdcall;
  BASS_PluginFree:function(handle: HPLUGIN): BOOL; stdcall;
  BASS_PluginEnable:function(handle: HPLUGIN; enable: BOOL): BOOL; stdcall;
  BASS_PluginGetInfo:function(handle: HPLUGIN): PBASS_PLUGININFO; stdcall;

  BASS_SampleLoad:function(mem: BOOL; f: Pointer; offset: QWORD; length, max, flags: DWORD): HSAMPLE; stdcall;
  BASS_SampleCreate:function(length, freq, chans, max, flags: DWORD): HSAMPLE; stdcall;
  BASS_SampleFree:function(handle: HSAMPLE): BOOL; stdcall;
  BASS_SampleSetData:function(handle: HSAMPLE; buffer: Pointer): BOOL; stdcall;
  BASS_SampleGetData:function(handle: HSAMPLE; buffer: Pointer): BOOL; stdcall;
  BASS_SampleGetInfo:function(handle: HSAMPLE; var info: BASS_SAMPLE): BOOL; stdcall;
  BASS_SampleSetInfo:function(handle: HSAMPLE; var info: BASS_SAMPLE): BOOL; stdcall;
  BASS_SampleGetChannel:function(handle: HSAMPLE; flags: DWORD): DWORD; stdcall;
  BASS_SampleGetChannels:function(handle: HSAMPLE; channels: Pointer): DWORD; stdcall;
  BASS_SampleStop:function(handle: HSAMPLE): BOOL; stdcall;

  BASS_StreamCreate:function(freq, chans, flags: DWORD; proc: STREAMPROC; user: Pointer): HSTREAM; stdcall;
  BASS_StreamCreateFile:function(mem: BOOL; f: Pointer; offset, length: QWORD; flags: DWORD): HSTREAM; stdcall;
  BASS_StreamCreateURL:function(url: PChar; offset: DWORD; flags: DWORD; proc: DOWNLOADPROC; user: Pointer):HSTREAM; stdcall;
  BASS_StreamCreateFileUser:function(system, flags: DWORD; var procs: BASS_FILEPROCS; user: Pointer): HSTREAM; stdcall;
  BASS_StreamFree:function(handle: HSTREAM): BOOL; stdcall;
  BASS_StreamGetFilePosition:function(handle: HSTREAM; mode: DWORD): QWORD; stdcall;
  BASS_StreamPutData:function(handle: HSTREAM; buffer: Pointer; length: DWORD): DWORD; stdcall;
  BASS_StreamPutFileData:function(handle: HSTREAM; buffer: Pointer; length: DWORD): DWORD; stdcall;

  BASS_MusicLoad:function(mem: BOOL; f: Pointer; offset: QWORD; length, flags, freq: DWORD): HMUSIC; stdcall;
  BASS_MusicFree:function(handle: HMUSIC): BOOL; stdcall;

  BASS_RecordGetDeviceInfo:function(device: DWORD; var info: BASS_DEVICEINFO): BOOL; stdcall;
  BASS_RecordInit:function(device: Integer): BOOL; stdcall;
  BASS_RecordSetDevice:function(device: DWORD): BOOL; stdcall;
  BASS_RecordGetDevice:function: DWORD; stdcall;
  BASS_RecordFree:function: BOOL; stdcall;
  BASS_RecordGetInfo:function(var info: BASS_RECORDINFO): BOOL; stdcall;
  BASS_RecordGetInputName:function(input: Integer): PAnsiChar; stdcall;
  BASS_RecordSetInput:function(input: Integer; flags: DWORD; volume: FLOAT): BOOL; stdcall;
  BASS_RecordGetInput:function(input: Integer; var volume: FLOAT): DWORD; stdcall;
  BASS_RecordStart:function(freq, chans, flags: DWORD; proc: RECORDPROC; user: Pointer): HRECORD; stdcall;

  BASS_ChannelBytes2Seconds:function(handle: DWORD; pos: QWORD): Double; stdcall;
  BASS_ChannelSeconds2Bytes:function(handle: DWORD; pos: Double): QWORD; stdcall;
  BASS_ChannelGetDevice:function(handle: DWORD): DWORD; stdcall;
  BASS_ChannelSetDevice:function(handle, device: DWORD): BOOL; stdcall;
  BASS_ChannelIsActive:function(handle: DWORD): DWORD; stdcall;
  BASS_ChannelGetInfo:function(handle: DWORD; var info: BASS_CHANNELINFO):BOOL; stdcall;
  BASS_ChannelGetTags:function(handle: HSTREAM; tags: DWORD): PAnsiChar; stdcall;
  BASS_ChannelFlags:function(handle, flags, mask: DWORD): DWORD; stdcall;
  BASS_ChannelUpdate:function(handle, length: DWORD): BOOL; stdcall;
  BASS_ChannelLock:function(handle: DWORD; lock: BOOL): BOOL; stdcall;
  BASS_ChannelFree:function(handle: DWORD): BOOL; stdcall;
  BASS_ChannelPlay:function(handle: DWORD; restart: BOOL): BOOL; stdcall;
  BASS_ChannelStart:function(handle: DWORD): BOOL; stdcall;
  BASS_ChannelStop:function(handle: DWORD): BOOL; stdcall;
  BASS_ChannelPause:function(handle: DWORD): BOOL; stdcall;
  BASS_ChannelSetAttribute:function(handle, attrib: DWORD; value: FLOAT): BOOL; stdcall;
  BASS_ChannelGetAttribute:function(handle, attrib: DWORD; var value: FLOAT): BOOL; stdcall;
  BASS_ChannelSetAttributeEx:function(handle, attrib: DWORD; value: Pointer; size: DWORD): BOOL; stdcall;
  BASS_ChannelGetAttributeEx:function(handle, attrib: DWORD; value: Pointer; size: DWORD): DWORD; stdcall;
  BASS_ChannelSlideAttribute:function(handle, attrib: DWORD; value: FLOAT; time: DWORD): BOOL; stdcall;
  BASS_ChannelIsSliding:function(handle, attrib: DWORD): BOOL; stdcall;
  BASS_ChannelSet3DAttributes:function(handle: DWORD; mode: Integer; min, max: FLOAT; iangle, oangle, outvol: Integer): BOOL; stdcall;
  BASS_ChannelGet3DAttributes:function(handle: DWORD; var mode: DWORD; var min, max: FLOAT; var iangle, oangle, outvol: DWORD): BOOL; stdcall;
  BASS_ChannelSet3DPosition:function(handle: DWORD; var pos, orient, vel: BASS_3DVECTOR): BOOL; stdcall;
  BASS_ChannelGet3DPosition:function(handle: DWORD; var pos, orient, vel: BASS_3DVECTOR): BOOL; stdcall;
  BASS_ChannelGetLength:function(handle, mode: DWORD): QWORD; stdcall;
  BASS_ChannelSetPosition:function(handle: DWORD; pos: QWORD; mode: DWORD): BOOL; stdcall;
  BASS_ChannelGetPosition:function(handle, mode: DWORD): QWORD; stdcall;
  BASS_ChannelGetLevel:function(handle: DWORD): DWORD; stdcall;
  BASS_ChannelGetLevelEx:function(handle: DWORD; levels: PSingle; length: Single; flags: DWORD): BOOL; stdcall;
  BASS_ChannelGetData:function(handle: DWORD; buffer: Pointer; length: DWORD): DWORD; stdcall;
  BASS_ChannelSetSync:function(handle: DWORD; type_: DWORD; param: QWORD; proc: SYNCPROC; user: Pointer): HSYNC; stdcall;
  BASS_ChannelRemoveSync:function(handle: DWORD; sync: HSYNC): BOOL; stdcall;
  BASS_ChannelSetDSP:function(handle: DWORD; proc: DSPPROC; user: Pointer; priority: Integer): HDSP; stdcall;
  BASS_ChannelRemoveDSP:function(handle: DWORD; dsp: HDSP): BOOL; stdcall;
  BASS_ChannelSetLink:function(handle, chan: DWORD): BOOL; stdcall;
  BASS_ChannelRemoveLink:function(handle, chan: DWORD): BOOL; stdcall;
  BASS_ChannelSetFX:function(handle, type_: DWORD; priority: Integer): HFX; stdcall;
  BASS_ChannelRemoveFX:function(handle: DWORD; fx: HFX): BOOL; stdcall;

  BASS_FXSetParameters:function(handle: HFX; par: Pointer): BOOL; stdcall;
  BASS_FXGetParameters:function(handle: HFX; par: Pointer): BOOL; stdcall;
  BASS_FXSetPriority:function(handle: HFX; priority : integer): BOOL; stdcall;
  BASS_FXReset:function(handle: HFX): BOOL; stdcall;


{ok, now we need something that loads our DLL and gets rid of it as well...}

var
  BASS_Handle: THandle = 0; // this will hold our handle for the dll; it functions nicely as a mutli-dll prevention unit as well...

function Load_BASSDLL(const dllfilename: String) :boolean;
procedure Unload_BASSDLL;
{
  This function frees the dynamically linked-in functions from memory...don't forget to call it once you're done !
  Best place to put this is probably the OnDestroy of your Main-Form;
  suggested use in OnDestroy :
  - Call BASS_Free to get rid of everything that's eating memory (automatically called, but just to be on the safe-side !),
  - Then call this function.
}


function BASS_SPEAKER_N(n: DWORD): DWORD;
function BASS_SetEAXPreset(env: Integer): BOOL;
{
  This function is defined in the implementation part of this unit.
  It is not part of BASS.DLL but an extra function which makes it easier
  to set the predefined EAX environments.
  env    : a EAX_ENVIRONMENT_xxx constant
}

implementation

Function Load_BASSDLL (const dllfilename : String) :boolean;
const szBassDll = 'bass.dll' + #0;
var
  oldmode:integer;
  P: PChar;
  s: string;
  dllfile: array[0..MAX_PATH + 1] of Char;
begin
  Result := False;
  if BASS_Handle<>0 then
    Result := True {is it already there ?}
   else
   begin {go & load the dll}
    s := dllfilename;
    if Length(s) = 0 then begin
      P := nil;
      if SearchPath(nil, PChar(szBassDll), nil, MAX_PATH, dllfile, P) > 0 then
        s := StrPas(dllfile)
      else exit;
      end;
    oldmode := SetErrorMode($8001);
    s := s + #0;
    {$IFDEF UNICODE}
    BASS_Handle := LoadLibraryW(PWideChar(s));
    {$ELSE}
    BASS_Handle := LoadLibrary(PChar(s));
    {$ENDIF}
    SetErrorMode(oldmode);
    if BASS_Handle<>0 then
    begin {now we tie the functions to the VARs from above}
      @BASS_SetConfig:= GetProcAddress(BASS_Handle, PChar('BASS_SetConfig'));
      @BASS_GetConfig:= GetProcAddress(BASS_Handle, PChar('BASS_GetConfig'));
      @BASS_SetConfigPtr:= GetProcAddress(BASS_Handle, PChar('BASS_SetConfigPtr'));
      @BASS_GetConfigPtr:= GetProcAddress(BASS_Handle, PChar('BASS_GetConfigPtr'));
      @BASS_GetVersion:= GetProcAddress(BASS_Handle, PChar('BASS_GetVersion'));
      @BASS_ErrorGetCode:= GetProcAddress(BASS_Handle, PChar('BASS_ErrorGetCode'));
      @BASS_GetDeviceInfo:= GetProcAddress(BASS_Handle, PChar('BASS_GetDeviceInfo'));
      @BASS_Init:= GetProcAddress(BASS_Handle, PChar('BASS_Init'));
      @BASS_SetDevice:= GetProcAddress(BASS_Handle, PChar('BASS_SetDevice'));
      @BASS_GetDevice:= GetProcAddress(BASS_Handle, PChar('BASS_GetDevice'));
      @BASS_Free:= GetProcAddress(BASS_Handle, PChar('BASS_Free'));
      @BASS_GetDSoundObject:= GetProcAddress(BASS_Handle, PChar('BASS_GetDSoundObject'));
      @BASS_GetInfo:= GetProcAddress(BASS_Handle, PChar('BASS_GetInfo'));
      @BASS_Update:= GetProcAddress(BASS_Handle, PChar('BASS_Update'));
      @BASS_GetCPU:= GetProcAddress(BASS_Handle, PChar('BASS_GetCPU'));
      @BASS_Start:= GetProcAddress(BASS_Handle, PChar('BASS_Start'));
      @BASS_Stop:= GetProcAddress(BASS_Handle, PChar('BASS_Stop'));
      @BASS_Pause:= GetProcAddress(BASS_Handle, PChar('BASS_Pause'));
      @BASS_IsStarted:= GetProcAddress(BASS_Handle, PChar('BASS_IsStarted'));
      @BASS_SetVolume:= GetProcAddress(BASS_Handle, PChar('BASS_SetVolume'));
      @BASS_GetVolume:= GetProcAddress(BASS_Handle, PChar('BASS_GetVolume'));

      @BASS_Set3DFactors:= GetProcAddress(BASS_Handle, PChar('BASS_Set3DFactors'));
      @BASS_Get3DFactors:= GetProcAddress(BASS_Handle, PChar('BASS_Get3DFactors'));
      @BASS_Set3DPosition:= GetProcAddress(BASS_Handle, PChar('BASS_Set3DPosition'));
      @BASS_Get3DPosition:= GetProcAddress(BASS_Handle, PChar('BASS_Get3DPosition'));
      @BASS_Apply3D:= GetProcAddress(BASS_Handle, PChar('BASS_Apply3D'));
      @BASS_SetEAXParameters:= GetProcAddress(BASS_Handle, PChar('BASS_SetEAXParameters'));
      @BASS_GetEAXParameters:= GetProcAddress(BASS_Handle, PChar('BASS_GetEAXParameters'));

      @BASS_PluginLoad:= GetProcAddress(BASS_Handle, PChar('BASS_PluginLoad'));
      @BASS_PluginFree:= GetProcAddress(BASS_Handle, PChar('BASS_PluginFree'));
      @BASS_PluginEnable:= GetProcAddress(BASS_Handle, PChar('BASS_PluginEnable'));
      @BASS_PluginGetInfo:= GetProcAddress(BASS_Handle, PChar('BASS_PluginGetInfo'));

      @BASS_SampleLoad:= GetProcAddress(BASS_Handle, PChar('BASS_SampleLoad'));
      @BASS_SampleCreate:= GetProcAddress(BASS_Handle, PChar('BASS_SampleCreate'));
      @BASS_SampleFree:= GetProcAddress(BASS_Handle, PChar('BASS_SampleFree'));
      @BASS_SampleSetData:= GetProcAddress(BASS_Handle, PChar('BASS_SampleSetData'));
      @BASS_SampleGetData:= GetProcAddress(BASS_Handle, PChar('BASS_SampleGetData'));
      @BASS_SampleGetInfo:= GetProcAddress(BASS_Handle, PChar('BASS_SampleGetInfo'));
      @BASS_SampleSetInfo:= GetProcAddress(BASS_Handle, PChar('BASS_SampleSetInfo'));
      @BASS_SampleGetChannel:= GetProcAddress(BASS_Handle, PChar('BASS_SampleGetChannel'));
      @BASS_SampleGetChannels:= GetProcAddress(BASS_Handle, PChar('BASS_SampleGetChannels'));
      @BASS_SampleStop:= GetProcAddress(BASS_Handle, PChar('BASS_SampleStop'));

      @BASS_StreamCreate:= GetProcAddress(BASS_Handle, PChar('BASS_StreamCreate'));
      @BASS_StreamCreateFile:= GetProcAddress(BASS_Handle, PChar('BASS_StreamCreateFile'));
      @BASS_StreamCreateURL:= GetProcAddress(BASS_Handle, PChar('BASS_StreamCreateURL'));
      @BASS_StreamCreateFileUser:= GetProcAddress(BASS_Handle, PChar('BASS_StreamCreateFileUser'));
      @BASS_StreamFree:= GetProcAddress(BASS_Handle, PChar('BASS_StreamFree'));
      @BASS_StreamGetFilePosition:= GetProcAddress(BASS_Handle, PChar('BASS_StreamGetFilePosition'));
      @BASS_StreamPutData:= GetProcAddress(BASS_Handle, PChar('BASS_StreamPutData'));
      @BASS_StreamPutFileData:= GetProcAddress(BASS_Handle, PChar('BASS_StreamPutFileData'));

      @BASS_MusicLoad:= GetProcAddress(BASS_Handle, PChar('BASS_MusicLoad'));
      @BASS_MusicFree:= GetProcAddress(BASS_Handle, PChar('BASS_MusicFree'));

      @BASS_RecordGetDeviceInfo:= GetProcAddress(BASS_Handle, PChar('BASS_RecordGetDeviceInfo'));
      @BASS_RecordInit:= GetProcAddress(BASS_Handle, PChar('BASS_RecordInit'));
      @BASS_RecordSetDevice:= GetProcAddress(BASS_Handle, PChar('BASS_RecordSetDevice'));
      @BASS_RecordGetDevice:= GetProcAddress(BASS_Handle, PChar('BASS_RecordGetDevice'));
      @BASS_RecordFree:= GetProcAddress(BASS_Handle, PChar('BASS_RecordFree'));
      @BASS_RecordGetInfo:= GetProcAddress(BASS_Handle, PChar('BASS_RecordGetInfo'));
      @BASS_RecordGetInputName:= GetProcAddress(BASS_Handle, PChar('BASS_RecordGetInputName'));
      @BASS_RecordSetInput:= GetProcAddress(BASS_Handle, PChar('BASS_RecordSetInput'));
      @BASS_RecordGetInput:= GetProcAddress(BASS_Handle, PChar('BASS_RecordGetInput'));
      @BASS_RecordStart:= GetProcAddress(BASS_Handle, PChar('BASS_RecordStart'));

      @BASS_ChannelBytes2Seconds:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelBytes2Seconds'));
      @BASS_ChannelSeconds2Bytes:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSeconds2Bytes'));
      @BASS_ChannelGetDevice:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGetDevice'));
      @BASS_ChannelSetDevice:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSetDevice'));
      @BASS_ChannelIsActive:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelIsActive'));
      @BASS_ChannelGetInfo:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGetInfo'));
      @BASS_ChannelGetTags:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGetTags'));
      @BASS_ChannelFlags:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelFlags'));
      @BASS_ChannelUpdate:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelUpdate'));
      @BASS_ChannelLock:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelLock'));
      @BASS_ChannelFree:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelFree'));
      @BASS_ChannelPlay:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelPlay'));
      @BASS_ChannelStart:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelStart'));
      @BASS_ChannelStop:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelStop'));
      @BASS_ChannelPause:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelPause'));
      @BASS_ChannelSetAttribute:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSetAttribute'));
      @BASS_ChannelGetAttribute:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGetAttribute'));
      @BASS_ChannelSetAttributeEx:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSetAttributeEx'));
      @BASS_ChannelGetAttributeEx:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGetAttributeEx'));
      @BASS_ChannelSlideAttribute:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSlideAttribute'));
      @BASS_ChannelIsSliding:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelIsSliding'));
      @BASS_ChannelSet3DAttributes:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSet3DAttributes'));
      @BASS_ChannelGet3DAttributes:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGet3DAttributes'));
      @BASS_ChannelSet3DPosition:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSet3DPosition'));
      @BASS_ChannelGet3DPosition:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGet3DPosition'));
      @BASS_ChannelGetLength:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGetLength'));
      @BASS_ChannelSetPosition:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSetPosition'));
      @BASS_ChannelGetPosition:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGetPosition'));
      @BASS_ChannelGetLevel:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGetLevel'));
      @BASS_ChannelGetLevelEx:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGetLevelEx'));
      @BASS_ChannelGetData:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelGetData'));
      @BASS_ChannelSetSync:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSetSync'));
      @BASS_ChannelRemoveSync:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelRemoveSync'));
      @BASS_ChannelSetDSP:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSetDSP'));
      @BASS_ChannelRemoveDSP:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelRemoveDSP'));
      @BASS_ChannelSetLink:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSetLink'));
      @BASS_ChannelRemoveLink:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelRemoveLink'));
      @BASS_ChannelSetFX:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelSetFX'));
      @BASS_ChannelRemoveFX:= GetProcAddress(BASS_Handle, PChar('BASS_ChannelRemoveFX'));

      @BASS_FXSetParameters:= GetProcAddress(BASS_Handle, PChar('BASS_FXSetParameters'));
      @BASS_FXGetParameters:= GetProcAddress(BASS_Handle, PChar('BASS_FXGetParameters'));
      @BASS_FXSetPriority:= GetProcAddress(BASS_Handle, PChar('BASS_FXSetPriority'));
      @BASS_FXReset:= GetProcAddress(BASS_Handle, PChar('BASS_FXReset'));

      {now check if everything is linked in correctly}
   if (@BASS_SetConfig  = nil) or
      (@BASS_GetConfig  = nil) or
      (@BASS_SetConfigPtr  = nil) or
      (@BASS_GetConfigPtr  = nil) or
      (@BASS_GetVersion  = nil) or
      (@BASS_ErrorGetCode  = nil) or
      (@BASS_GetDeviceInfo = nil) or
      (@BASS_Init = nil) or
      (@BASS_SetDevice = nil) or
      (@BASS_GetDevice = nil) or
      (@BASS_Free = nil) or
      (@BASS_GetDSoundObject = nil) or
      (@BASS_GetInfo = nil) or
      (@BASS_Update = nil) or
      (@BASS_GetCPU = nil) or
      (@BASS_Start = nil) or
      (@BASS_Stop = nil) or
      (@BASS_Pause = nil) or
      (@BASS_IsStarted = nil) or
      (@BASS_SetVolume = nil) or
      (@BASS_GetVolume = nil) or

      (@BASS_Set3DFactors = nil) or
      (@BASS_Get3DFactors = nil) or
      (@BASS_Set3DPosition = nil) or
      (@BASS_Get3DPosition = nil) or
      (@BASS_Apply3D = nil) or
      (@BASS_SetEAXParameters = nil) or
      (@BASS_GetEAXParameters = nil) or

      (@BASS_PluginLoad = nil) or
      (@BASS_PluginFree = nil) or
      (@BASS_PluginEnable = nil) or
      (@BASS_PluginGetInfo = nil) or

      (@BASS_SampleLoad = nil) or
      (@BASS_SampleCreate = nil) or
      (@BASS_SampleFree = nil) or
      (@BASS_SampleSetData = nil) or
      (@BASS_SampleGetData = nil) or
      (@BASS_SampleGetInfo = nil) or
      (@BASS_SampleSetInfo = nil) or
      (@BASS_SampleGetChannel = nil) or
      (@BASS_SampleGetChannels = nil) or
      (@BASS_SampleStop = nil) or

      (@BASS_StreamCreate = nil) or
      (@BASS_StreamCreateFile = nil) or
      (@BASS_StreamCreateURL = nil) or
      (@BASS_StreamCreateFileUser = nil) or
      (@BASS_StreamFree = nil) or
      (@BASS_StreamGetFilePosition = nil) or
      (@BASS_StreamPutData = nil) or
      (@BASS_StreamPutFileData = nil) or

      (@BASS_MusicLoad = nil) or
      (@BASS_MusicFree = nil) or

      (@BASS_RecordGetDeviceInfo = nil) or
      (@BASS_RecordInit = nil) or
      (@BASS_RecordSetDevice = nil) or
      (@BASS_RecordGetDevice = nil) or
      (@BASS_RecordFree = nil) or
      (@BASS_RecordGetInfo = nil) or
      (@BASS_RecordGetInputName = nil) or
      (@BASS_RecordSetInput = nil) or
      (@BASS_RecordGetInput = nil) or
      (@BASS_RecordStart = nil) or

      (@BASS_ChannelBytes2Seconds = nil) or
      (@BASS_ChannelSeconds2Bytes = nil) or
      (@BASS_ChannelGetDevice = nil) or
      (@BASS_ChannelSetDevice = nil) or
      (@BASS_ChannelIsActive = nil) or
      (@BASS_ChannelGetInfo = nil) or
      (@BASS_ChannelGetTags = nil) or
      (@BASS_ChannelFlags = nil) or
      (@BASS_ChannelUpdate = nil) or
      (@BASS_ChannelLock = nil) or
      (@BASS_ChannelFree = nil) or
      (@BASS_ChannelPlay = nil) or
      (@BASS_ChannelStart = nil) or
      (@BASS_ChannelStop = nil) or
      (@BASS_ChannelPause = nil) or
      (@BASS_ChannelSetAttribute = nil) or
      (@BASS_ChannelGetAttribute = nil) or
      (@BASS_ChannelSetAttributeEx = nil) or
      (@BASS_ChannelGetAttributeEx = nil) or
      (@BASS_ChannelSlideAttribute = nil) or
      (@BASS_ChannelIsSliding = nil) or
      (@BASS_ChannelSet3DAttributes = nil) or
      (@BASS_ChannelGet3DAttributes = nil) or
      (@BASS_ChannelSet3DPosition = nil) or
      (@BASS_ChannelGet3DPosition = nil) or
      (@BASS_ChannelGetLength = nil) or
      (@BASS_ChannelSetPosition = nil) or
      (@BASS_ChannelGetPosition = nil) or
      (@BASS_ChannelGetLevel = nil) or
      (@BASS_ChannelGetLevelEx = nil) or
      (@BASS_ChannelGetData = nil) or
      (@BASS_ChannelSetSync = nil) or
      (@BASS_ChannelRemoveSync = nil) or
      (@BASS_ChannelSetDSP = nil) or
      (@BASS_ChannelRemoveDSP = nil) or
      (@BASS_ChannelSetLink = nil) or
      (@BASS_ChannelRemoveLink = nil) or
      (@BASS_ChannelSetFX = nil) or
      (@BASS_ChannelRemoveFX = nil) or

      (@BASS_FXSetParameters = nil) or
      (@BASS_FXGetParameters = nil) or
      (@BASS_FXSetPriority = nil) or
      (@BASS_FXReset = nil) then
      begin {if something went wrong during linking, free library & reset handle}
       FreeLibrary(BASS_Handle);
       BASS_Handle:= 0;
      end;
     end;
    Result:= (BASS_Handle <> 0);
  end;
end;

procedure Unload_BASSDLL;
begin
 if BASS_Handle <> 0 then
  begin
   BASS_Free; // make sure we release everything
   FreeLibrary(BASS_Handle);
  end;
 BASS_Handle:= 0;
end;

function BASS_SPEAKER_N(n: DWORD): DWORD;
begin
  Result := n shl 24;
end;

function BASS_SetEAXPreset(env: Integer): BOOL;
begin
  case (env) of
    EAX_ENVIRONMENT_GENERIC:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_GENERIC, 0.5, 1.493, 0.5);
    EAX_ENVIRONMENT_PADDEDCELL:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_PADDEDCELL, 0.25, 0.1, 0);
    EAX_ENVIRONMENT_ROOM:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_ROOM, 0.417, 0.4, 0.666);
    EAX_ENVIRONMENT_BATHROOM:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_BATHROOM, 0.653, 1.499, 0.166);
    EAX_ENVIRONMENT_LIVINGROOM:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_LIVINGROOM, 0.208, 0.478, 0);
    EAX_ENVIRONMENT_STONEROOM:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_STONEROOM, 0.5, 2.309, 0.888);
    EAX_ENVIRONMENT_AUDITORIUM:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_AUDITORIUM, 0.403, 4.279, 0.5);
    EAX_ENVIRONMENT_CONCERTHALL:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_CONCERTHALL, 0.5, 3.961, 0.5);
    EAX_ENVIRONMENT_CAVE:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_CAVE, 0.5, 2.886, 1.304);
    EAX_ENVIRONMENT_ARENA:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_ARENA, 0.361, 7.284, 0.332);
    EAX_ENVIRONMENT_HANGAR:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_HANGAR, 0.5, 10.0, 0.3);
    EAX_ENVIRONMENT_CARPETEDHALLWAY:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_CARPETEDHALLWAY, 0.153, 0.259, 2.0);
    EAX_ENVIRONMENT_HALLWAY:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_HALLWAY, 0.361, 1.493, 0);
    EAX_ENVIRONMENT_STONECORRIDOR:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_STONECORRIDOR, 0.444, 2.697, 0.638);
    EAX_ENVIRONMENT_ALLEY:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_ALLEY, 0.25, 1.752, 0.776);
    EAX_ENVIRONMENT_FOREST:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_FOREST, 0.111, 3.145, 0.472);
    EAX_ENVIRONMENT_CITY:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_CITY, 0.111, 2.767, 0.224);
    EAX_ENVIRONMENT_MOUNTAINS:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_MOUNTAINS, 0.194, 7.841, 0.472);
    EAX_ENVIRONMENT_QUARRY:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_QUARRY, 1, 1.499, 0.5);
    EAX_ENVIRONMENT_PLAIN:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_PLAIN, 0.097, 2.767, 0.224);
    EAX_ENVIRONMENT_PARKINGLOT:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_PARKINGLOT, 0.208, 1.652, 1.5);
    EAX_ENVIRONMENT_SEWERPIPE:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_SEWERPIPE, 0.652, 2.886, 0.25);
    EAX_ENVIRONMENT_UNDERWATER:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_UNDERWATER, 1, 1.499, 0);
    EAX_ENVIRONMENT_DRUGGED:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_DRUGGED, 0.875, 8.392, 1.388);
    EAX_ENVIRONMENT_DIZZY:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_DIZZY, 0.139, 17.234, 0.666);
    EAX_ENVIRONMENT_PSYCHOTIC:
      Result := BASS_SetEAXParameters(EAX_ENVIRONMENT_PSYCHOTIC, 0.486, 7.563, 0.806);
    else
      Result := FALSE;
  end;
end;

end.

