{
This file is part of R&Q.
Under same license
}
unit ICQConsts;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
  uses
    windows, RDGlobal, RnQNet, RQThemes, RnQProtocol, RnQPics,
    themesLib;

type
//  Tstatus=(SC_ONLINE, SC_OCCUPIED, SC_DND, SC_NA, SC_AWAY, SC_F4C, SC_OFFLINE, SC_UNK,
//           SC_Evil, SC_Depression);
  TICQStatus=(SC_ONLINE = 0, SC_OFFLINE, SC_UNK, SC_OCCUPIED, SC_DND, SC_NA,
           SC_AWAY, SC_F4C, SC_Evil, SC_Depression, SC_home, SC_work, SC_Lunch
           );
const
  SC_Last = SC_Lunch;
  StatusPriority : array[TICQStatus] of byte= (0,8,9, 1,2,3,4,5,6,7, 101, 102, 103);

Type
  Tvisibility=(VI_normal, VI_invisible, VI_privacy, VI_all, VI_CL);
//  Tstatus=(SC_ONLINE = 0, SC_OCCUPIED, SC_DND, SC_NA, SC_AWAY, SC_F4C, SC_OFFLINE, SC_UNK,
//           SC_Evil, SC_Depression);
const
  LOGIN_CHANNEL=1;
  SNAC_CHANNEL=2;
  LOGOUT_CHANNEL=4;
  KEEPALIVE_CHANNEL=5;

  visibility2ShowStr : array [Tvisibility] of String =
       ('Normal (all but invisible-list)', 'Invisible', 'Privacy (only visible-list)',
        'Visible to all', 'Visible to contact-list');
  visibility2imgName : array [Tvisibility] of TPicName =
       (PIC_VISIBILITY_NORMAL, PIC_VISIBILITY_NONE, PIC_VISIBILITY_PRIVACY,
        PIC_VISIBILITY_ALL, PIC_VISIBILITY_CL);
  visib2str:array [Tvisibility] of TPicName =('normal','invisible','privacy',
    'all', 'cl');
  visibility2SSIcode : array[Tvisibility] of byte = (04, 02, 03, 01, 05);
  visibilitySSI2vis : array[1..5] of Tvisibility =
          (VI_all, VI_invisible, VI_privacy, VI_normal, VI_CL);
//  visibility2str:array [Tvisibility] of string=
//     ('Invisible', 'Privacy (only visible-list)',
//      'Normal (all but invisible-list)', 'All', 'Only contact-list');
//  status2str:array [TICQStatus] of AnsiString=('online','offline','unk',
//    'occupied','dnd','na','away', 'f4c', 'evil', 'depression');
  status2ShowStr:array [TICQStatus] of string=('Online','Offline','Unknown',
    'Occupied','Don''t disturb', 'N/A', 'Away', 'Free for chat', 'Evil', 'Depression', 'At home', 'At work', 'Lunch');
//  status2Img:array [TICQStatus] of TPicName=('online','offline','unk',
  status2Img:array [0..byte(SC_Last)] of TPicName=('online','offline','unk',
      'occupied','dnd','na','away', 'f4c',
      'evil', 'depression', 'home', 'work', 'lunch');
//  status2code:array [Tstatus] of dword=(0,$11,$13,5,1,$20,0,0, $3000, $4000);
  status2code:array [TICQStatus] of dword=(0,0,0, $11,$13,5,1,$20,
    $3000, $4000,
    $5000, //Home [qip]
    $6000, //Work [qip]
    $2001  //Lunch [qip]
   );
  statusWithAutoMsg=[byte(SC_away), byte(SC_na), byte(SC_dnd),
                     byte(SC_occupied)//, byte(SC_f4c)
//                     , byte(SC_Evil),byte(SC_Depression)
                    ];
//  Tvisibility=(VI_invisible, VI_privacy, VI_normal, VI_all, VI_CL);
//  visibility2SSIcode : array[Tvisibility] of byte = (02, 03, 04, 01, 05);
//  overrideStatus2code:array [Tstatus] of dword=(0,9,$A,$E,4,0,0,0);

const
  maxRefs=2000;
//  directProtoVersion=8;
  My_proto_ver = 9;
  ICQ_TCP_VERSION = My_proto_ver;
  maxPwdLength=16;
  AIM_MD5_STRING : AnsiString = 'AOL Instant Messenger (SM)';
  uinToUpdate    =  223223181;
  AIMprefix = 'AIM_';
  ICQMaxAvatarSize = 7800;
//  AOL_FILE_TRANSFER_SERVER = 'ars.oscar.aol.com';
//  ICQ_SECURE_LOGIN_SERVER = 'slogin.oscar.aol.com';
  AOL_FILE_TRANSFER_SERVER0 = 'ars.icq.com';
  ICQ_SECURE_LOGIN_SERVER0  = 'slogin.icq.com';

  BALLOON_NEVER  = 0;
  BALLOON_ALWAYS = 1;
  BALLOON_BDAY   = 2;
  BALLOON_DATE   = 3;

// Client IDs
  RnQclientID     =$FFFFF666;

const

 // By Rapid D 
  IF_Simple     = 1 shl 5;      // msg is simple
//  IF_MSG_OK   = 1 shl 8;      // msg was delivered!
//  IF_MSG_ERROR= 1 shl 9;      // msg was NOT delivered!
  IF_no_matter  = 1 shl 10;
  last_IF       = 1 shl 10;     // useful for external additional flags

  AvtHash_NoAvt = AnsiString(#$B4#$32#$5C#$25#$34#$3D#$41#$13#$72#$90#$9D#$C0#$E7#$3A#$71#$73); // Hash of Avatar "No photo has been uploaded"

  Z=AnsiString(#0#0#0#0);
  BigCapability:array [1..29] of record v : String[16]; s : AnsiString; end=(
//  BigCapability:array [1..28] of record v : AnsiString; s : AnsiString; end=(
    (V: #$97#$B1#$27#$51#$24#$3C#$43#$34#$AD#$22#$D6#$AB#$F7#$3F#$14#$92; s: 'RTF messages'),// RTF
    (V: #$2E#$7A#$64#$75#$FA#$DF#$4D#$C8#$88#$6F#$EA#$35#$95#$FD#$B6#$DF; s: 'ICQ 2001'), // AIM_CAPS_2001 or OLD_UTF
    (V: #$56#$3F#$C8#$09#$0B#$6F#$41#$BD#$9F#$79#$42#$26#$09#$DF#$A2#$F3; s: 'Typing Notifications'), // mini typing notification (MTN) (for 2003b, ..., lite4)
    (V: #$97#$B1#$27#$51#$24#$3C#$43#$34#$AD#$22#$D6#$AB#$F7#$3F#$14#$09; s: 'SecureIM Trillian'), // Is Trillian
    (V: #$74#$8F#$24#$20#$62#$87#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00; s: 'Chat'), // Can participate in centralized text conferences
    (V: #$1A#$09#$3C#$6C#$D7#$FD#$4E#$C5#$9D#$51#$A6#$47#$4E#$34#$F5#$A0; s: 'Xtraz'),
    (V: #$D3#$D4#$53#$19#$8B#$32#$40#$3B#$AC#$C7#$D1#$A9#$E2#$B5#$81#$3E; s: 'QIP-ProtectMsg'),
//    (V: #$17#$8C#$2D#$9B#$DA#$A5#$45#$BB#$8D#$DB#$F3#$BD#$BD#$53#$A1#$0A; s: 'Lite-AIM Cap1'),
    (V: #$17#$8C#$2D#$9B#$DA#$A5#$45#$BB#$8D#$DB#$F3#$BD#$BD#$53#$A1#$0A; s: 'IM is ICQLite'),
//	);
//  ExtCapability:array [1..6] of record v : string[16]; s : String end=(

    (V: #$F2#$E7#$C7#$F4#$FE#$AD#$4D#$FB#$B2#$35#$36#$79#$8B#$DF#$00#$00; s: 'Trillian'), // Trillian
    (V: #$09#$49#$13#$44#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00; s: 'kxICQ2'), // Is kxICQ2
    (V: #$DD#$16#$F2#$02#$84#$E6#$11#$D4#$90#$DB#$00#$10#$4B#$9B#$4B#$7D; s: 'MacICQ'), // MacICQ
    (V: #$09#$49#$13#$49#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00; s: 'LICQ'), // LICQ
    (V: #$56#$3F#$C8#$09#$0B#$6F#$41#$51#$49#$50#$20#$32#$30#$30#$35#$61; s: 'QIP 2005'), // QIP 2005
    (V: #$74#$ED#$C3#$36#$44#$DF#$48#$5B#$8B#$1C#$67#$1A#$1F#$86#$09#$9F; s: 'IM2'),

    (V: #$E3#$62#$C1#$E9#$12#$1A#$4B#$94#$A6#$26#$7A#$74#$DE#$24#$27#$0D; s: 'Push2Talk'),
    (V: #$B9#$97#$08#$B5#$3A#$92#$42#$02#$B0#$69#$F1#$E7#$57#$BB#$2E#$17; s: 'ICQ Voice Chat'),
    (V: #$67#$36#$15#$15#$61#$2D#$4C#$07#$8F#$3D#$BD#$E6#$40#$8E#$A0#$41; s: 'Xtraz MultiUser Chat'),
    (V: #$7E#$11#$B7#$78#$A3#$53#$49#$26#$A8#$02#$44#$73#$52#$08#$C4#$2A; s: 'Lsp-RU-Rambler'),
    (V: #$B6#$07#$43#$78#$F5#$0C#$4A#$C7#$90#$92#$59#$38#$50#$2D#$05#$91; s: 'ICQ-XVideo'),
    (V: #$01#$00#$11#$00#$00#$00#$00#$00#$11#$00#$00#$00#$00#$2a#$02#$b5; s: 'AIM'),
    (V: #$B2#$EC#$8F#$16#$7C#$6F#$45#$1B#$BD#$79#$DC#$58#$49#$78#$88#$B9; s: 'tZers' ),   // 21
    (V: #$01#$38#$CA#$7B#$76#$9A#$49#$15#$88#$F2#$13#$FC#$00#$97#$9E#$A8; s: 'ICQ6'),
    (V: #$D6#$68#$7F#$4F#$3D#$C3#$4b#$db#$8A#$8C#$4C#$1A#$57#$27#$63#$CD; s: 'R&Q-ProtectMsg'), //23
    (V: #$7C#$73#$75#$02#$C3#$BE#$4F#$3E#$A6#$9F#$01#$53#$13#$43#$1E#$1A; s: 'qip Infium'),
    (V: #$56#$6D#$49#$43#$51#$20#$76#$30#$2E#$31#$2E#$34#$62#$00#$00#$00; s: 'vmICQ'),
    (V: #$7C#$53#$3F#$FA#$68#$00#$4F#$21#$BC#$FB#$C7#$D2#$43#$9A#$AD#$31; s: 'qip-plugins'),
    (V: #$56#$3F#$C8#$09#$0B#$6F#$41#$51#$49#$50#$20#$20#$20#$20#$20#$21; s: 'QIP PDA WM'),
    (V: #$51#$AD#$D1#$90#$72#$04#$47#$3D#$A1#$A1#$49#$F4#$A3#$97#$A4#$1F; s: 'QIP PDA Symbian'),
    (V: #$7A#$7B#$7C#$7D#$7E#$7F#$0A#$03#$0B#$04#$01#$53#$13#$43#$1E#$1A; s: 'qip 2010')
//    (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$70; s: 'Status [Sad]'),
//    (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$75; s: 'Status [Free for chat]'),
//    (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$76; s: 'Status [At home]'),
//    (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$77; s: 'Status [At work]'),
//    (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$78; s: 'Status [At Lunch]'),
//    (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$79; s: 'Status [Angry]')
//    8C543DFC69024D25BFFAC0D3419CAF30 -- ????
  );
  //capIs2002    = {0x10, 0xcf, 0x40, 0xd1, 0x4c, 0x7f, 0x11, 0xd1, 0x82, 0x22, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00};
  //capStr20012  = {0xa0, 0xe9, 0x3f, 0x37, 0x4f, 0xe9, 0xd3, 0x11, 0xbc, 0xd2, 0x00, 0x04, 0xac, 0x96, 0xdd, 0x96};
  CapsMakeBig1 = AnsiString(#$09#$46);
  CapsMakeBig2 = AnsiString(#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00);

(*
#define kAccCap_SecureIm   OLESTR( "{09460001-4C7F-11D1-8222-444553540000}")
#define kAccCap_XhtmlIm   OLESTR( "{09460002-4C7F-11D1-8222-444553540000}")
#define kAccCap_RtpVideo   OLESTR( "{09460101-4C7F-11D1-8222-444553540000}")
#define kAccCap_HasCamera   OLESTR( "{09460102-4C7F-11D1-8222-444553540000}")
#define kAccCap_HasMic   OLESTR( "{09460103-4C7F-11D1-8222-444553540000}")
#define kAccCap_RtpAudio   OLESTR( "{09460104-4C7F-11D1-8222-444553540000}")
#define kAccCap_AvailForCall   OLESTR("{09460105-4C7F-11D1-8222-444553540000}")
#define kAccCap_MultiAudio   OLESTR( "{09460107-4C7F-11D1-8222-444553540000}")
#define kAccCap_MultiVideo   OLESTR( "{09460108-4C7F-11D1-8222-444553540000}")
#define kAccCap_OldAudio   OLESTR( "{09461341-4C7F-11D1-8222-444553540000}")
#define kAccCap_FileXfer   OLESTR( "{09461343-4C7F-11D1-8222-444553540000}")
#define kAccCap_DirectIm   OLESTR( "{09461345-4C7F-11D1-8222-444553540000}")
#define kAccCap_BuddyIcon   OLESTR( "{09461346-4C7F-11D1-8222-444553540000}")
#define kAccCap_FileSharing   OLESTR( "{09461348-4C7F-11D1-8222-444553540000}")
#define kAccCap_ShareBuddies   OLESTR("{0946134B-4C7F-11D1-8222-444553540000}")
#define kAccCap_Chat   OLESTR( "{748F2420-6287-11D1-8222-444553540000}")
#define kAccCap_SmartCaps   OLESTR( "{094601FF-4C7F-11D1-8222-444553540000}")
*)

  CapsSmall: array[1..29] of record v : RawByteString; s : AnsiString; Desc : AnsiString; end = (
    (V: #$01#$00; s: 'Video'; Desc: ''),           // = Video
    (V: #$01#$01; s: 'SIP/RTP video'; Desc: 'Can do live video streaming, using SIP/RTP'),       //2 = RtpVideo
    (V: #$01#$02; s: 'Has camera'; Desc: 'Has a video camera connected'),      // = HasCamera
    (V: #$01#$03; s: 'Has microphone'; Desc: 'Has a microphone connected (may not be set for non-USB mics)'),  //4 = HasMicrophone
    (V: #$01#$04; s: 'Rtp audio'; Desc: 'Can do live audio streaming, using SIP/RTP'),       // = RtpAudio
    (V: #$01#$05; s: 'Available for call'; Desc : 'Can receive an a/v call at this time'), //6 = AvailableForCall
    (V: #$01#$06; s: 'Aca'),             // = Aca
    (V: #$01#$07; s: 'Multi audio'; Desc: 'Can participate in centralized audio conferences'),     //8 = MultiAudio
    (V: #$01#$08; s: 'Multi video'; Desc: 'Can participate in centralized video conferences'),     // = MultiVideo
    (V: #$01#$FF; s: 'Smart caps'; Desc: 'Whether caps reflect opt-in features vs. features the software supports'),    //10 = SmartCaps
    (V: #$F0#$04; s: 'Viceroy'),         // = Viceroy
    (V: #$13#$49; s: 'ICQ Server Relay'), //12  AIM_CAPS_ICQSERVERRELAY
    (V: #$13#$44; s: 'is ICQ'),              // AIM_CAPS_ICQ
    (V: #$13#$4E; s: 'UTF-8 Messages'),  //14 UTF-8
    (V: #$13#$4c; s: 'Avatar'),              // CAP_AVATAR
//    (V: #$13#$4c; s: 'Lite-AIM Cap1'),        // CAP_AVATAR
    (V: #$13#$45; s: 'Direct IM'; Desc : 'Can participate in direct IM sessions'),  //16
    (V: #$13#$46; s: 'Buddy icon'; Desc : 'Can receive non-BART buddy icons'),
    (V: #$13#$48; s: 'File sharing'; Desc : 'Offering files for download'),    //18   CAP_FILE_SHARING
    (V: #$14#$49; s: 'ICQ 2001a'),           // CAP_ICQ_SERVER_RELAY
    (V: #$13#$43; s: 'File Transfer'; Desc : 'Can receive files'),   // 20  CAP_FILE_TRANSFER
    (V: #$13#$41; s: 'Old Audio'; Desc: 'Can do live audio streaming, using JGTK'), // CAP_AOL_TALK
    (V: #$13#$42; s: 'Direct Play'),     //22   CAP_DIRECT_PLAY
    (V: #$13#$4B; s: 'Share Buddies'; Desc: 'Can receive sent buddy lists'),        // CAP_SHARE_BUDDIES
//    (V: #$13#$42; s: 'Preakness')        //24   CAP_PREAKNESS

    (V: #$13#$4D; s: 'Talk with ICQ'),
    (V: #$00#$00; s: 'Short caps'),            // 25
    (V: #$00#$01; s: 'Secure IM'; Desc: 'Can receive "application/pkcs7-mime" encoded IMs'),       // 26
    (V: #$00#$02; s: 'Xhtml IM'; Desc: 'Can receive "application/xhtml+xml" encoded IMs'),         // 27
    (V: #$01#$0A; s: 'New status message features'),    // 28  = HOST_STATUS_TEXT_AWARE
    (V: #$01#$0B; s: '"see as I type" IMs')             // 29  RTIM
//         #$13#$4D

    );
//    #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00  // Anti-invischeck
  MsgCapabilities : array [1..1] of RawByteString=(
      #$3B#$60#$B3#$EF#$D8#$2A#$6C#$45#$A4#$E0#$9C#$5A#$5E#$67#$E8#$65 // XStatus
//      #$09#$46#$13#$43#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00 // file transfer (Send)
//      D9122DF0-9130-11D3-8DD7-00104B06462E //File transfer plugin.
//      #$09#$46#$13#$48#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00 // file transfer (Recieve)
//      #$09#$46#$13#$49#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00, // Plugin MSG
//      #$f0#$2d#$12#$d9#$30#$91#$d3#$11#$8d#$d7#$00#$10#$4b#$06#$46#$2e,

  );
//  msgUTF : TGUID = '{0946134E-4C7F-11D1-8222-444553540000}';
  msgUTFstr = '{0946134E-4C7F-11D1-8222-444553540000}';
  msgRTF : TGUID = '{97B12751-243C-4334-AD22-D6ABF73F1492}';
  msgRnQpass : TGUID = '{e92a62a2-e32a-49dc-acc6-22066bd4f316}';
//  msgQIPpass : TGUID = '{d3d45319-8b32-403b-acc7-d1a9e2b5813e}';
  msgQIPpassStr = AnsiString('{D3D45319-8B32-403B-ACC7-D1A9E2B5813E}');

  CAPS_sm_ICQSERVERRELAY = 12;
  CAPS_sm_ICQ            = 13;
  CAPS_big_RTF           = 1;
  CAPS_big_2001          = 2;
  CAPS_big_Lite          = 8;
  CAPS_sm_UTF8           = 14;
  CAPS_big_MTN           = 3;
  CAPS_big_SecIM         = 4;
  CAPS_sm_Avatar         = 15;
  CAPS_big_Xtraz         = 6;
  CAPS_sm_FILE_TRANSFER  = 20;
  CAPS_BIG_Xtraz5        = 20;

  CAPS_Ext_CLI_First     = 9;
  CAPS_big_Tril          = 9;
  CAPS_big_ICQ6          = 22;
  CAPS_big_macICQ        = 11;
  CAPS_big_LICQ          = 12;
  CAPS_big_QIP_SEQURE    = 7;
  CAPS_big_QIP           = 13;
  CAPS_Ext_CLI_Last      = 14;
  CAPS_sm_FILE           = 18;

  CAPS_big_RMBLR         = 18;
  CAPS_big_tZers         = 21;
  CAPS_big_CryptMsg      = 23;
  CAPS_sm_AIM            = 24;
  CAPS_big_qipInf        = 24;
  CAPS_big_qip2010       = 29;
  CAPS_big_qipWM         = 27;
  CAPS_big_qipSym        = 28;

  CAPS_sm_SecIM          = 26;

  CAPS_sm_ShortCaps      = 25;
  CAPS_sm_NEW_STAT       = 28;
  header2711_0= AnsiString(#$1B#0)+ AnsiChar(My_proto_ver)+Z+Z+Z+Z+#00#00#00;
  header2711  = header2711_0 + AnsiString(#03#00#00#00)
            +#04#$FF#$FF#$E#0#$FF#$FF+Z+Z+Z;
  header2711_1=header2711_0 + #01#00#00#00
            +#00#$FF#$FF#$E#0#$FF#$FF+Z+Z+Z;
  header2711_2=header2711_0 + #03#00#00#00
            +#00#00#00#$0E#00#00#00+Z+Z+Z;

  publicEmailTab:array [boolean] of byte=(0, 1);

// Message types
    MTYPE_PLAIN    = $01; // Plain text (simple) message
    MTYPE_CHAT     = $02; // Chat request message
    MTYPE_FILEREQ  = $03; // File request / file ok message
    MTYPE_URL      = $04; // URL message (0xFE formatted)
    MTYPE_AUTHREQ  = $06; // Authorization request message (0xFE formatted)
    MTYPE_AUTHDENY = $07; // Authorization denied message (0xFE formatted)
    MTYPE_AUTHOK   = $08; // Authorization given message (empty)
    MTYPE_SERVER   = $09; // Message from OSCAR server (0xFE formatted)
    MTYPE_ADDED    = $0C; // "You-were-added" message (0xFE formatted)
    MTYPE_WWP      = $0D; // Web pager message (0xFE formatted)
    MTYPE_EEXPRESS = $0E; // Email express message (0xFE formatted)
    MTYPE_CONTACTS = $13; // Contact list message
    MTYPE_PLUGIN   = $1A; // Plugin message described by text string
    MTYPE_AUTOAWAY = $E8; // Auto away message
    MTYPE_AUTOBUSY = $E9; // Auto occupied message
    MTYPE_AUTONA   = $EA; // Auto not available message
    MTYPE_AUTODND  = $EB; // Auto do not disturb message
    MTYPE_AUTOFFC  = $EC; // Auto free for chat message

    MTYPE_XSTATUS = $61;
    MTYPE_GCARD   = $62;

    MTYPE_UNKNOWN  = $00; // Unknown message, only used internally by this plugin

  MTYPE_AUTOMSGS =[ MTYPE_AUTOAWAY, MTYPE_AUTOBUSY, MTYPE_AUTONA,
  	            MTYPE_AUTODND, MTYPE_AUTOFFC ];

   PLUGIN_SCRIPT = AnsiString('Script Plug-in: Remote Notification Arrive');
  ACK_OK=0;
  ACK_FILEDENY=1;
  ACK_OCCUPIED=9;
  ACK_DND=$A;
  ACK_AWAY=4;
  ACK_NA=$E;
  ACK_NOBLINK=$C;

  flag_invisible=$00000100;
  flag_webaware =$00010000;
  flag_showip   =$00020000;
  flag_birthday =$00080000;
  flag_unknown  =$00100000;
  // if none of the following direct connection is for everyone
  flag_dcForNone   =$01000000;  // DC not supported
  flag_dcByRequest =$10000000;  // DC upon authorization
  flag_dcForRoster =$20000000;  // DC only with contact users

  MTN_FINISHED = $0000; //typing finished sign
  MTN_TYPED    = $0001; //text typed sign
  MTN_BEGUN    = $0002; //typing begun sign
  MTN_CLOSED   = $000F; // Closed chat

  // Channels
  ICQ_LOGIN_CHAN = 01;
  ICQ_DATA_CHAN	 = 02;
  ICQ_ERROR_CHAN = 03;
  ICQ_CLOSE_CHAN = 04;
  ICQ_PING_CHAN	 = 05;

  // Families
  ICQ_SERVICE_FAMILY    = $0001;
  ICQ_LOCATION_FAMILY   = $0002;
  ICQ_BUDDY_FAMILY      = $0003;
  ICQ_MSG_FAMILY        = $0004;
  ICQ_BOS_FAMILY        = $0009;
  ICQ_STATUS_FAMILY     = $000b;
  ICQ_AVATAR_FAMILY     = $0010;
  ICQ_LISTS_FAMILY      = $0013; // Feedbag (Buddylist)
  ICQ_EXTENSIONS_FAMILY	= $0015;

  ICQ_BUCP_FAMILY       = $0017; // BUCP Service (Login)


// FLAGS BUDDY__RIGHTS_QUERY_FLAGS for Snac 0302
BART_SUPPORTED =	$0001;//	Want to receive BART items
INITIAL_DEPARTS	= $0002;//	Want to receive ARRIVE/DEPART for all users on a Buddy List, even those offline
OFFLINE_BART_SUPPORTED =	$0004;//	Want to receive BART items for offline buddies, excluding location
REJECT_PENDING_BUDDIES =	$0008;//	If set and INITIAL_DEPARTS is set, use REJECT on pending buddies instead of DEPART

// SNACS for ICQ Extensions Family 0x0015
  SRV_ICQEXT_ERROR      = $0001;
  CLI_META_REQ          = $0002;
  SRV_META_REPLY        = $0003;

// Reply types for SNAC 15/02 & 15/03
  CLI_OFFLINE_MESSAGE_REQ     = $003C;
  CLI_DELETE_OFFLINE_MSGS_REQ = $003E;
  SRV_OFFLINE_MESSAGE         = $0041;
  SRV_END_OF_OFFLINE_MSGS     = $0042;
  CLI_META_INFO_REQ           = $07D0;
  SRV_META_INFO_REPLY         = $07DA;

// Reply subtypes for SNAC 15/02 & 15/03
  META_PROCESSING_ERROR = $0001; // Meta processing error server reply;
  META_SET_HOMEINFO_ACK = $0064; // Set user home info server ack;
  META_SET_WORKINFO_ACK = $006E; // Set user work info server ack;
  META_SET_MOREINFO_ACK = $0078; // Set user more info server ack;
  META_SET_NOTES_ACK    = $0082; // Set user notes info server ack;
  META_SET_EMAILINFO_ACK= $0087; // Set user email(s) info server ack;
  META_SET_INTINFO_ACK  = $008C; // Set user interests info server ack;
  META_SET_AFFINFO_ACK  = $0096; // Set user affilations info server ack;
  META_SMS_DELIVERY_RECEIPT   = $0096; // Server SMS response (delivery receipt) NOTE: same as ID above;
  META_SET_PERMS_ACK    = $00A0; // Set user permissions server ack;
  META_SET_PASSWORD_ACK = $00AA; // Set user password server ack;
  META_UNREGISTER_ACK   = $00B4; // Unregister account server ack;
  META_SET_HPAGECAT_ACK = $00BE; // Set user homepage category server ack;
  META_BASIC_USERINFO   = $00C8; // User basic info reply;
  META_WORK_USERINFO    = $00D2; // User work info reply;
  META_MORE_USERINFO    = $00DC; // User more info reply;
  META_NOTES_USERINFO   = $00E6; // User notes (about) info reply;
  META_EMAIL_USERINFO   = $00EB; // User extended email info reply;
  META_INTERESTS_USERINFO     = $00F0; // User interests info reply;
  META_AFFILATIONS_USERINFO   = $00FA; // User past/affilations info reply;
  META_SHORT_USERINFO   = $0104; // Short user information reply;
  META_HPAGECAT_USERINFO= $010E; // User homepage category information reply;
  META_simple_query     = $019A;
  SRV_USER_FOUND        = $01A4; // Search: user found reply;
  SRV_LAST_USER_FOUND   = $01AE; // Search: last user found reply;
  META_REGISTRATION_STATS_ACK = $0302; // Registration stats ack;
  SRV_RANDOM_FOUND      = $0366; // Random search server reply;
  META_REQUEST_FULL_INFO= $04B2; // Request full user info;
  META_REQUEST_SHORT_INFO     = $04BA; // Request short user info;
  META_REQUEST_SELF_INFO= $04D0; // Request full self user info;
  META_SEARCH_GENERIC   = $055F; // Search user by details (TLV);
  META_SEARCH_UIN       = $0569; // Search user by UIN (TLV);
  META_SEARCH_EMAIL     = $0573; // Search user by E-mail (TLV);
  META_XML_INFO         = $08A2; // Server variable requested via xml;
  META_SET_FULLINFO_ACK = $0C3F; // Server ack for set fullinfo command;
  META_SPAM_REPORT_ACK  = $2012; // Server ack for user spam report;

  User_email = $015E;
  User_First = $0140;
  User_Last  = $014A;
  User_Nick  = $0154;
  User_Nick_U = $015F;
  User_City  = $0190;
  User_State = $019A;
  User_Cntry = $01A4;
  User_Inter = $01EA;
  User_Gender= $017C;
  User_Lang  = $0186;
  User_Age   = $0168;
//  User_Age   = $0172;
  User_URL   = $0213;
  User_OnOf  = $0230;
  User_Birth = $023A;
  User_Notes = $0258;
  User_HmStr = $0262;
//  User_HmZip = $026C;
  User_HmZip2 = $026D;
  User_HmCel = $028A;
  User_Auth  = $02F8;
  User_WebSt = $030C;
  User_GMTos = $0316;
  User_MarSts= $033E;

// Work
  User_WkURL   = $02DA;
  User_WkPos   = $01C2;
  User_WkDept  = $01B8;
  User_WkCmpny = $01AE;
  User_WkCity  = $029E;
  User_WkState = $02A8;
  User_WkCntry = $02B2;
  User_WkZip   = $02BC;
  User_WkCell  = $02C6;




// Made in COMPAD!!!!!!!!!!!
  META_SEARCH_COMPAD    = $0FA0; // Adv Search in ComPad

  CP_User_Gender= $0082;     // 1 байт
  CP_User_City  = $00A0;     // Chars
  CP_User_Cntry = $00BE;     // 4 байта юзать!!!
  CP_User_Lang  = $00FA;     // 2 байта юзать!!!
  CP_User_Age   = $0154;     // Сначала большее, потом меньшее 4 байта
  CP_User_NICK  = $017C;     // Chars        Nick or Name
  CP_User_ONLINE  = $0136;     // WOrd #0001

  META_COMPAD_UID    = $0032;
  META_COMPAD_INFO_HASH = $003C;
  META_COMPAD_UNK1  = $0046; // Пустое
  META_COMPAD_EMAIL  = $0050; // E-Mail
  META_COMPAD_EMAIL_INACTIVE  = $0055; // Неподтверждёное мыло!
  META_COMPAD_FNAME  = $0064; // First Name // Имя
  META_COMPAD_LNAME  = $006E; // Фамилия
  META_COMPAD_NICK   = $0078; // Ник
  META_COMPAD_GENDER = $0082;  // Пол
  META_COMPAD_Mails  = $008C;  // #00#00     // Содержит TLV 1 -> содержит TLV $64=Мыло для подключения
  META_COMPAD_HOMES  = $0096; // Содержит внутри себя TLV с городом, областью, страной.
    META_COMPAD_HOMES_UNK1  = $0064;
    META_COMPAD_HOMES_CITY  = $006E;
    META_COMPAD_HOMES_STATE = $0078;
    META_COMPAD_HOMES_UNK2  = $0084;
    META_COMPAD_HOMES_COUNTRY = $008C;
  META_COMPAD_FROM  = $00A0; // Я из
    META_COMPAD_FROM_UNK1  = $0064;
    META_COMPAD_FROM_CITY  = $006E;
    META_COMPAD_FROM_STATE = $0078;
    META_COMPAD_FROM_UNK2  = $0082;
    META_COMPAD_FROM_UNK3  = $0084;
    META_COMPAD_FROM_COUNTRY = $008C;
  META_COMPAD_LANG1  = $00AA; // $0026
  META_COMPAD_LANG2  = $00B4; // $000C
  META_COMPAD_LANG3  = $00BE; // $0000
  META_COMPAD_CELL  = $00C8; // $0000  Сотовые
    META_COMPAD_CELL_NUMM  = $0064; // Номерa
  META_COMPAD_HP    = $00FA; // HomePage
  META_COMPAD_UNK9  = $0104; // $0000

  META_COMPAD_MAIL_UN  = $010E; // $0000  - Пропала после запроса подтверждения мыла
  META_COMPAD_WORKS  = $0118; // Работа
    META_COMPAD_WORKS_POSITION = $0064; //Должность
    META_COMPAD_WORKS_ORG      = $006E; // Организация
    META_COMPAD_WORKS_PAGE     = $0078; // WorkPage
    META_COMPAD_WORKS_DEPT     = $007D; // Department
    META_COMPAD_WORKS_UNK2     = $0082; // ???   $0003
    META_COMPAD_WORKS_UNK3     = $0096; // Похоже на дату устройства. 8 символов
    META_COMPAD_WORKS_UNK4     = $00A0; // Похоже на дату увольнения. 8 символов
    META_COMPAD_WORKS_STREET   = $00AA; // Улица
    META_COMPAD_WORKS_CITY     = $00B4; // Город
    META_COMPAD_WORKS_STATE    = $00BE; // Область
    META_COMPAD_WORKS_COUNTRY  = $00D2; // Страна
  META_COMPAD_MarSts = $0121; // #$000C      Marital status
  META_COMPAD_INTERESTs = $0122; //  word - count; 4*(Length_BE(TLV($64, InterestStr) + TLV($6E, InterestInt))
    META_COMPAD_INTEREST_TEXT = $0064;
    META_COMPAD_INTEREST_ID   = $006E;
  META_COMPAD_UNK10 = $0123; // $0000
  META_COMPAD_UNK11 = $0124; // $0000
  META_COMPAD_UNK12 = $012C; // $000C
  META_COMPAD_UNK13 = $0136; // $00 00 00 00 00 00 00 00
  META_COMPAD_UNK14 = $0140; // $0000
  META_COMPAD_UNK15 = $014A; // $0000
  META_COMPAD_UNK16 = $0154; // $0000
  META_COMPAD_UNK17 = $015E; // $0000
  META_COMPAD_UNK18 = $0168; // $0000
  META_COMPAD_UNK19 = $0172; // $0000
  META_COMPAD_GMT     = $017C; // $FFFA  GMTs
  META_COMPAD_ABOUT   = $0186; // About
  META_COMPAD_STS_MSG = $0226;
  META_COMPAD_MOBILE  = $024E;

  META_COMPAD_STATUS  = $0190;
  META_COMPAD_AUTH  = $01B8; // AUTH
  META_COMPAD_BDAY  = $01A4; // BirthDay

  META_COMPAD_INFO_CHG = $01CC; // Time of info changed (maybe)
  META_COMPAD_WEBAWEARE = $019A;// WebAware (1= show status)
  META_COMPAD_INFO_SHOW = $01F9; // Show info (2 = Cont; 1 = All but email; 0 = nobody)
//...
  META_COMPAD_WP  = $00; //
//  META_COMPAD_  = $01; //
//  META_COMPAD_  = $00; //


const
 FEEDBAG_CLASS_ID_BUDDY            = $00;
 FEEDBAG_CLASS_ID_GROUP            = $01;
 FEEDBAG_CLASS_ID_PERMIT           = $02;
 FEEDBAG_CLASS_ID_DENY             = $03;
 FEEDBAG_CLASS_ID_PDINFO           = $04; // (R) PDMODE/PDMASK/PDFLAGS
 FEEDBAG_CLASS_ID_BUDDY_PREFS      = $05; // (R) Buddy List preferences
 FEEDBAG_CLASS_ID_NONBUDDY         = $06; // (R) Users not in the Buddy List; use this to store aliases or other information for future use
 FEEDBAG_CLASS_ID_TPA_PROVIDER     = $07;
 FEEDBAG_CLASS_ID_TPA_SUBSCRIPTION = $08;
 FEEDBAG_CLASS_ID_CLIENT_PREFS     = $09; // (R) Client-specific preferences; name is name of client, e.g., "AIM Express"
 FEEDBAG_CLASS_ID_STOCK            = $0A;
 FEEDBAG_CLASS_ID_WEATHER          = $0B;
 FEEDBAG_CLASS_ID_WATCH_LIST       = $0D;
 FEEDBAG_CLASS_ID_IGNORE_LIST      = $0E;
 FEEDBAG_CLASS_ID_DATE_TIME        = $0F; // (R) Timestamp
 FEEDBAG_CLASS_ID_EXTERNAL_USER    = $10;
 FEEDBAG_CLASS_ID_ROOT_CREATOR     = $11;
 FEEDBAG_CLASS_ID_FISH             = $12;
 FEEDBAG_CLASS_ID_IMPORT_TIMESTAMP = $13;
 FEEDBAG_CLASS_ID_BART             = $14; // (R) BART IDs; name is the BART Type
 FEEDBAG_CLASS_ID_RB_ORDER         = $15; // (R) Order attribute lists recent buddies in the least to most recently used order
 FEEDBAG_CLASS_ID_PERSONALITY      = $16; // (R) Collection of BART ids 
 FEEDBAG_CLASS_ID_AL_PROF          = $17; // (R) Information about Account Linking prefrences
 FEEDBAG_CLASS_ID_AL_INFO          = $18; // (R) Account linking information
 FEEDBAG_CLASS_ID_DELETED          = $19;
// FEEDBAG_CLASS_ID_INTERACTION      = $19; // (R) Non-Buddy interaction record
 FEEDBAG_CLASS_ID_INFO_COLLECTION  = $1D; // (R) Vanity information kept at user logoff
 FEEDBAG_CLASS_ID_FAVORITE_LOCATION =$1E; // (R) User's favorite locations
 FEEDBAG_CLASS_ID_BART_PDINFO      = $1F; // (R) BART PDMODE
 FEEDBAG_CLASS_ID_UNKNOWN          = $20;


//FEEDBAG_STATUS_CODES (возвращаемые значения сервером после модификации)
 FEEDBAG_STATUS_CODES_SUCCESS        = $00;
 FEEDBAG_STATUS_CODES_DB_ERROR       = $01;
 FEEDBAG_STATUS_CODES_NOT_FOUND      = $02;
 FEEDBAG_STATUS_CODES_ALREADY_EXISTS = $03;
 FEEDBAG_STATUS_CODES_BAD_REQUEST    = $0A;
 FEEDBAG_STATUS_CODES_DB_TIME_OUT    = $0B;
 FEEDBAG_STATUS_CODES_OVER_ROW_LIMIT = $0C;
 FEEDBAG_STATUS_CODES_NOT_EXECUTED   = $0D;
 FEEDBAG_STATUS_CODES_AUTH_REQUIRED  = $0E;
 FEEDBAG_STATUS_CODES_AUTO_AUTH      = $0F;

 SSI_OPERATION_CODES_ADD    = $08;
 SSI_OPERATION_CODES_UPDATE = $09;
 SSI_OPERATION_CODES_REMOVE = $0A;

 FEEDBAG_CLASS_NAMES:array [FEEDBAG_CLASS_ID_BUDDY..FEEDBAG_CLASS_ID_UNKNOWN]
    of string=('Buddy', 'Group', 'Visible', 'Invisible',
               'PDINFO', 'BUDDY_PREFS', 'NONBUDDY', 'TPA_PROVIDER',
               'TPA_SUBSCRIPTION', 'CLIENT_PREFS', 'STOCK', 'Weather',
               'Unk 0C', 'WATCH_LIST', 'Ignore list', 'Date time',
               'EXTERNAL_USER', 'ROOT_CREATOR', 'FISH', 'Import time', 'BART',
               'RB_ORDER', 'PERSONALITY', 'AL_PROF', 'AL_INFO',
               'Deleted', '1A', '1B', '1C',
               'INFO_COLLECTION', 'FAVORITE_LOCATION',
               'Unk', 'Unk');

BART_ID_EMPTY  = #$02#$01#$d2#$04#$72;

//Class: BART__ID_FLAGS
BART_FLAGS_CUSTOM  = $01; // This is a custom blob; the opaque data will also be 16 bytes
BART_FLAGS_DATA    = $04; // The opaque field is really data the client knows how to process; these items do not need to be downloaded from BART
BART_FLAGS_UNKNOWN = $40; // Used in OSERVICE__BART_REPLY; BART does not know about this ID, please upload
BART_FLAGS_REDIRECT= $80; // Used in OSERVICE__BART_REPLY; BART says use this ID instead for the matching type

//Class: BART__ID_TYPES
BART_TYPE_BUDDY_ICON_SMALL = 0; // GIF/JPG/BMP, <= 32 pixels and 2k
BART_TYPE_BUDDY_ICON   = 1; // GIF/JPG/BMP, <= 64 pixels and 7k
BART_TYPE_STATUS_STR   = 2; //StringTLV format; DATA flag is always set
BART_TYPE_ARRIVE_SOUND = 3; // WAV/MP3/MID, <= 10K
BART_TYPE_RICH_TEXT    = 4; // byte array of rich text codes; DATA flag is always set
BART_TYPE_SUPERBUDDY_ICON = 5;  // XML
BART_TYPE_RADIO_STATION   = 6;  // Opaque struct; DATA flag is always set
BART_TYPE_BUDDY_ICON_BIG  = 12; // SWF
BART_TYPE_STATUS_STR_TOD  = 13; // Time when the status string is set
BART_TYPE_STATUS_MOOD = 14; // $0E
BART_TYPE_CURRENT_AV_TRACK = 15; // XML file; Data flag should not be set
//BART_TYPE_DEPART_SOUND 96 WAV/MP3/MID, <= 10K
//BART_TYPE_IM_CHROME 129 GIF/JPG/BMP wallpaper
//BART_TYPE_IM_SOUND 131 WAV/MP3, <= 10K
//BART_TYPE_IM_CHROME_XML 136 XML
//BART_TYPE_IM_CHROME_IMMERS 137 Immersive Expressions
//BART_TYPE_EMOTICON_SET 1024 Set of default Emoticons
//BART_TYPE_ENCR_CERT_CHAIN 1026 Cert chain for encryption certs
//BART_TYPE_SIGN_CERT_CHAIN 1027 Cert chain for signing certs
//BART_TYPE_GATEWAY_CERT 1028 Cert for enterprise gateway


 BART__REPLY_CODES: array[0..7] of string=
       ('Success', 'ID is malformed', 'Custom blobs are not allowed for this type',
        'Item uploaded is too small for this type',
        'Item uploaded is too big for this type',
        'Item uploaded is the wrong type',
        'Item uploaded has been banned',
        'Item downloaded was not found');
{
 snac(13.37)!!!
FEEDBAG__REPORT_INTERACTION

It's used for reporting out-of-band interactions with other users to the OSCAR backend.

Packet dump:
> 2a 02 58 12 00 1c 00 13-00 37 00 00 00 00 00 37
> 01 01 00 0c 61 6f 6c 73-79 73 74 65 6d 6d 73 67
> 00 00

01 — interaction type
01 — number of screennames
00 0c — length of screenname
61 6f 6c 73-79 73 74 65 6d 6d 73 67 — screenname
00 00 — empty tlv block
}
//const
  //Buddy types
//  BUDDY_NORMAL    = $0000;      //A normal contact list entry
//  BUDDY_GROUP     = $0001;      //A larger group header
//  BUDDY_VISIBLE   = $0002;      //A contact on the visible list
//  BUDDY_INVISIBLE = $0003;      //A contact on the invisible list
//  BUDDY_IGNORE    = $000e;      //A contact on the ignore list
//  BUDDY_ICON      = $0014;      //My Icon


//  CRLF=#13#10;


type
  TicqAccept=( AC_OK, AC_DENIED, AC_AWAY );

  TicqError=(
    EC_rateExceeded,
    EC_cantConnect,
    EC_socket,
    EC_other,
    EC_badUIN,           // at login-time, referred to my own uin
    EC_missingLogin,
    EC_anotherLogin,
    EC_serverDisconnected,
    EC_badPwd,
    EC_cantChangePwd,
    EC_loginDelay,
    EC_cantCreateUIN,
    EC_invalidFlap,
    EC_badContact,
    EC_cantConnect_dc,
    EC_proxy_error,
    EC_proxy_badPwd,
    EC_proxy_unk         // unknown reply
  );

const
  icqerror2str:array [TicqError] of string=(
    'Server says you''re reconnecting too fastly, try later or change user.', //'rate exceeded',
    'Cannot connect\n[%d]\n%s',         // 'can''t connect',
    'Disconnected\n[%d]\n%s',           // 'disconnected',
    'Unknown error',                // 'unknown',
    'Your uin is not correct',      // 'incorrect uin',
    'Missing password',             // 'missing pwd',
    'Your current UIN is used by someone else right now, server disconnected you', //'another login',
    'Server disconnected',          // 'server disconnected',
    'Wrong password, correct it and try again', // 'wrong pwd',
    'Cannot change password',       // 'can''t change pwd',
    'Server is sick, wait 2 seconds and try again',   // 'delay',
    'Can''t create UIN',            //'can''t create uin',
    'FLAP level error',             // 'invalid flap',
    'Queried contact is invalid',   // 'bad contact',
    'can''t directly connect\n[%d]\n%s',
    'proxy: error',
    'PROXY: Invalid user/password', // 'proxy: wrong user/pwd',
//    'PROXY: Unknown reply\n[%d]\n%s'      // 'proxy: unk'
    ProxyUnkError   
  );


 ICQauthErrors : array[1..$2A] of string = (

'Invalid nick or password',
'Service temporarily unavailable',
'All other errors',
'Wrong password, correct it and try again', //'AUTH_ERR_INCORR_NICK_OR_PASSWORD',
'Mismatch nick or password, re-enter',
'Internal client error (bad input to authorizer)',
'Invalid account',
'Deleted account',
'Expired account',
'No access to database',            // $0A
'No access to resolver',
'Invalid database fields',          // $0C
'Bad database status',
'Bad resolver status',
'Internal error',
'Service temporarily offline',      // $10
'Suspended account',
'DB send error',
'DB link error',
'Reservation map error',
'Reservation link error',           // $15
'Too many clients from the same ip address',
'Too many clients from the same ip address (reservation)',
'Server says you''re reconnecting too fastly, try later or change user.', //'AUTH_ERR_RESERVATION_RATE',        // $18
'User too heavily warned',
'Reservation timeout',             // $1A
'You are using an older version of ICQ. Upgrade required',       // $1B
'You are using an older version of ICQ. Upgrade recommended',
'Rate limit exceeded. Please try to reconnect in a few minutes', // $1D
'Can ''t register on the ICQ network. Reconnect in a few minutes',  // $1E
'AUTH_ERR_SECURID_TIMEOUT', // upd, 2006: AUTH_ERR_TOKEN_SERVER_TIMEOUT
'Invalid SecurID', // upd, 2006: AUTH_ERR_INVALID_TOKEN_KEY
'AUTH_ERR_MC_ERROR',
'AUTH_ERR_CREDIT_CARD_VALIDATION', // upd 2006 // ...
'AUTH_ERR_REQUIRE_REVALIDATION', // upd 2006
'AUTH_ERR_LINK_RULE_REJECT', // upd 2006
'AUTH_ERR_MISS_INFO_OR_INVALID_SNAC', // upd 2006
'AUTH_ERR_LINK_BROKEN', // upd 2006
'AUTH_ERR_INVALID_CLIENT_IP', // upd 2006
'AUTH_ERR_PARTNER_REJECT', // upd 2006
'AUTH_ERR_SECUREID_MISSING', // upd 2006
'AUTH_ERR_BUMP_USER'); // upd 2006

{
const
  OldXStatus : array[0..36] of record pid : String[16];
                                PicName : AnsiString;
                                Caption : String;
                        end =
    ((pid: '';
      PicName: 'st_custom.none'; Caption: 'None'),
    (pid: #$01#$D8#$D7#$EE#$AC#$3B#$49#$2A#$A5#$8D#$D3#$D8#$77#$E6#$6B#$92;
      PicName: 'st_custom.angry'; Caption: 'Angry'),
     (pid: #$5A#$58#$1E#$A1#$E5#$80#$43#$0C#$A0#$6F#$61#$22#$98#$B7#$E4#$C7;
      PicName: 'st_custom.duck'; Caption: 'Duck'),
     (pid: #$83#$c9#$b7#$8e#$77#$e7#$43#$78#$b2#$c5#$fb#$6c#$fc#$c3#$5b#$ec;
      PicName: 'st_custom.tired'; Caption: 'Tired'),
     (pid: #$e6#$01#$e4#$1c#$33#$73#$4b#$d1#$bc#$06#$81#$1d#$6c#$32#$3d#$81;
      PicName: 'st_custom.party'; Caption: 'Party'),
     (pid: #$8c#$50#$db#$ae#$81#$ed#$47#$86#$ac#$ca#$16#$cc#$32#$13#$c7#$b7;
      PicName: 'st_custom.beer'; Caption: 'Beer'),
     (pid: #$3f#$b0#$bd#$36#$af#$3b#$4a#$60#$9e#$ef#$cf#$19#$0f#$6a#$5a#$7f;
      PicName: 'st_custom.thinking'; Caption: 'Thinking'),
     (pid: #$f8#$e8#$d7#$b2#$82#$c4#$41#$42#$90#$f8#$10#$c6#$ce#$0a#$89#$a6;
      PicName: 'st_custom.eating'; Caption: 'Eating'),
     (pid: #$80#$53#$7d#$e2#$a4#$67#$4a#$76#$b3#$54#$6d#$fd#$07#$5f#$5e#$c6;
      PicName: 'st_custom.tv'; Caption: 'TV'),
     (pid: #$f1#$8a#$b5#$2e#$dc#$57#$49#$1d#$99#$dc#$64#$44#$50#$24#$57#$af;
      PicName: 'st_custom.friends'; Caption: 'Friends'),
     (pid: #$1b#$78#$ae#$31#$fa#$0b#$4d#$38#$93#$d1#$99#$7e#$ee#$af#$b2#$18;
      PicName: 'st_custom.coffee'; Caption: 'Coffee'),
     (pid: #$61#$BE#$E0#$DD#$8B#$DD#$47#$5D#$8D#$EE#$5F#$4B#$AA#$CF#$19#$A7;
      PicName: 'st_custom.music'; Caption: 'Music'),
     (pid: #$48#$8e#$14#$89#$8a#$ca#$4a#$08#$82#$aa#$77#$ce#$7a#$16#$52#$08;
      PicName: 'st_custom.business'; Caption: 'Business'),
     (pid: #$10#$7a#$9a#$18#$12#$32#$4d#$a4#$b6#$cd#$08#$79#$db#$78#$0f#$09;
      PicName: 'st_custom.camera'; Caption: 'Camera'),
     (pid: #$6f#$49#$30#$98#$4f#$7c#$4a#$ff#$a2#$76#$34#$a0#$3b#$ce#$ae#$a7;
      PicName: 'st_custom.funny'; Caption: 'Funny'),
     (pid: #$12#$92#$e5#$50#$1b#$64#$4f#$66#$b2#$06#$b2#$9a#$f3#$78#$e4#$8d;
      PicName: 'st_custom.phone'; Caption: 'Phone'),
     (pid: #$d4#$a6#$11#$d0#$8f#$01#$4e#$c0#$92#$23#$c5#$b6#$be#$c6#$cc#$f0;
      PicName: 'st_custom.games'; Caption: 'Games'),
     (pid: #$60#$9d#$52#$f8#$a2#$9a#$49#$a6#$b2#$a0#$25#$24#$c5#$e9#$d2#$60;
      PicName: 'st_custom.college'; Caption: 'College'),
     (pid: #$63#$62#$73#$37#$a0#$3f#$49#$ff#$80#$e5#$f7#$09#$cd#$e0#$a4#$ee;
      PicName: 'st_custom.shopping'; Caption: 'Shopping'),
     (pid: #$1f#$7a#$40#$71#$bf#$3b#$4e#$60#$bc#$32#$4c#$57#$87#$b0#$4c#$f1;
      PicName: 'st_custom.sick'; Caption: 'Sick'),
     (pid: #$78#$5e#$8c#$48#$40#$d3#$4c#$65#$88#$6f#$04#$cf#$3f#$3f#$43#$df;
      PicName: 'st_custom.sleeping'; Caption: 'Sleeping'),
     (pid: #$a6#$ed#$55#$7e#$6b#$f7#$44#$d4#$a5#$d4#$d2#$e7#$d9#$5c#$e8#$1f;
      PicName: 'st_custom.surfing'; Caption: 'Surfing'),
     (pid: #$12#$d0#$7e#$3e#$f8#$85#$48#$9e#$8e#$97#$a7#$2a#$65#$51#$e5#$8d;
      PicName: 'st_custom.internet'; Caption: 'Internet'),
     (pid: #$ba#$74#$db#$3e#$9e#$24#$43#$4b#$87#$b6#$2f#$6b#$8d#$fe#$e5#$0f;
      PicName: 'st_custom.engineering'; Caption: 'Engineering'),
     (pid: #$63#$4f#$6b#$d8#$ad#$d2#$4a#$a1#$aa#$b9#$11#$5b#$c2#$6d#$05#$a1;
      PicName: 'st_custom.typing'; Caption: 'Typing'),

     (pid: #$2C#$E0#$E4#$E5#$7C#$64#$43#$70#$9C#$3A#$7A#$1C#$E8#$78#$A7#$DC;
      PicName: 'st_custom.unk'; Caption: 'Barbecue'),
     (pid: #$10#$11#$17#$C9#$A3#$B0#$40#$f9#$81#$AC#$49#$E1#$59#$FB#$D5#$D4;
      PicName: 'st_custom.ppc'; Caption: 'PPC'),
     (pid: #$16#$0C#$60#$BB#$DD#$44#$43#$f3#$91#$40#$05#$0F#$00#$E6#$C0#$09;
      PicName: 'st_custom.mobile'; Caption: 'Mobile'),
     (pid: #$64#$43#$C6#$AF#$22#$60#$45#$17#$B5#$8C#$D7#$DF#$8E#$29#$03#$52;
      PicName: 'st_custom.man'; Caption: 'Man'),
     (pid: #$16#$F5#$B7#$6F#$A9#$D2#$40#$35#$8C#$C5#$C0#$84#$70#$3C#$98#$FA;
      PicName: 'st_custom.wc'; Caption: 'WC'),

  //QIP

     (pid: #$63#$14#$36#$FF#$3F#$8A#$40#$D0#$A5#$CB#$7B#$66#$E0#$51#$B3#$64;
      PicName: 'st_custom.quest'; Caption: 'Quest'),
     (pid: #$B7#$08#$67#$F5#$38#$25#$43#$27#$A1#$FF#$CF#$4C#$C1#$93#$97#$97;
      PicName: 'st_custom.geometry'; Caption: ''),
     (pid: #$DD#$CF#$0E#$A9#$71#$95#$40#$48#$A9#$C6#$41#$32#$06#$D6#$F2#$80;
      PicName: 'st_custom.love'; Caption: 'Love'),

  // In R&Q added :)))
     (pid: #$3f#$b0#$bd#$36#$af#$3b#$4a#$60#$9e#$ef#$cf#$19#$0f#$6a#$5a#$7E;
      PicName: 'st_custom.cigarette'; Caption: 'Smoking'),
     (pid: #$e6#$01#$e4#$1c#$33#$73#$4b#$d1#$bc#$06#$81#$1d#$6c#$32#$3d#$82;
      PicName: 'st_custom.sex'; Caption: 'Sex'),
//      pid: #$3E#$DD#$CF#$0E#$A9#$71#$95#$40#$48#$A9#$C6#$41#$32#$06#$D6#$F2;
//      PicName: 'st_custom.'; Caption:
     (pid: #$D4#$E2#$B0#$BA#$33#$4E#$4F#$A5#$98#$D0#$11#$7D#$BF#$4D#$3C#$C8;
      PicName: 'st_custom.search'; Caption:'In search'),
     (pid: #$00#$72#$D9#$08#$4A#$D1#$43#$DD#$91#$99#$6F#$02#$69#$66#$02#$6F;
      PicName: 'st_custom.diary'; Caption:'Diary')
    );


  XStatus6 : array[0..26] of record pid : AnsiString;
                                PicName : AnsiString;
                                Caption : String;
                        end =
    ((pid: '';
      PicName: 'st_custom.none'; Caption: 'None'),
     (pid: 'icqmood23';
      PicName: 'st_custom.angry'; Caption: 'Angry'),
     (pid: 'icqmood1';
      PicName: 'st_custom.duck'; Caption: 'Duck'),
     (pid: 'icqmood2';
      PicName: 'st_custom.tired'; Caption: 'Tired'),
     (pid: 'icqmood3';
      PicName: 'st_custom.party'; Caption: 'Party'),
     (pid: 'icqmood4';
      PicName: 'st_custom.beer'; Caption: 'Beer'),
     (pid: 'icqmood5';
      PicName: 'st_custom.thinking'; Caption: 'Thinking'),
     (pid: 'icqmood6';
      PicName: 'st_custom.eating'; Caption: 'Eating'),
     (pid: 'icqmood7';
      PicName: 'st_custom.tv'; Caption: 'TV'),
     (pid: 'icqmood8';
      PicName: 'st_custom.friends'; Caption: 'Friends'),
     (pid: 'icqmood9';
      PicName: 'st_custom.coffee'; Caption: 'Coffee'),
     (pid: 'icqmood10';
      PicName: 'st_custom.music'; Caption: 'Music'),
     (pid: 'icqmood11';
      PicName: 'st_custom.business'; Caption: 'Business'),
     (pid: 'icqmood12';
      PicName: 'st_custom.camera'; Caption: 'Camera'),
     (pid: 'icqmood13';
      PicName: 'st_custom.funny'; Caption: 'Funny'),
     (pid: 'icqmood14';
      PicName: 'st_custom.phone'; Caption: 'Phone'),
     (pid: 'icqmood15';
      PicName: 'st_custom.games'; Caption: 'Games'),
     (pid: 'icqmood16';
      PicName: 'st_custom.college'; Caption: 'College'),
     (pid: 'icqmood0';
      PicName: 'st_custom.shopping'; Caption: 'Shopping'),
     (pid: 'icqmood17';
      PicName: 'st_custom.sick'; Caption: 'Sick'),
     (pid: 'icqmood18';
      PicName: 'st_custom.sleeping'; Caption: 'Sleeping'),
     (pid: 'icqmood19';
      PicName: 'st_custom.surfing'; Caption: 'Surfing'),
     (pid: 'icqmood20';
      PicName: 'st_custom.internet'; Caption: 'Internet'),
     (pid: 'icqmood21';
      PicName: 'st_custom.engineering'; Caption: 'Engineering'),
     (pid: 'icqmood22';
      PicName: 'st_custom.typing'; Caption: 'Typing'),


  // In R&Q added :)))
     (pid: 'icqmood32';
      PicName: 'st_custom.cigarette'; Caption: 'Smoking'),
     (pid: 'icqmood33';
      PicName: 'st_custom.sex'; Caption: 'Sex')
    );
}
type
 XStatusFlags = (xsf_Old, xsf_6);
 XStatusFlagsSet = set of XStatusFlags;
const
  XStatusArray : array[0..43] of record flags : XStatusFlagsSet;
                                pidOld : RawByteString;
                                pid6 : RawByteString;
                                PicName : TPicName;
                                Caption : String;
                        end =
    ((flags: [xsf_Old, xsf_6]; pidOld: ''; pid6: '';
      PicName: 'st_custom.none'; Caption: 'None'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$01#$D8#$D7#$EE#$AC#$3B#$49#$2A#$A5#$8D#$D3#$D8#$77#$E6#$6B#$92;
      pid6: 'icqmood23'; PicName: 'st_custom.angry'; Caption: 'Angry'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$5A#$58#$1E#$A1#$E5#$80#$43#$0C#$A0#$6F#$61#$22#$98#$B7#$E4#$C7;
      pid6: 'icqmood1';  PicName: 'st_custom.duck';  Caption: 'Duck'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$83#$c9#$b7#$8e#$77#$e7#$43#$78#$b2#$c5#$fb#$6c#$fc#$c3#$5b#$ec;
      pid6: 'icqmood2';  PicName: 'st_custom.tired'; Caption: 'Tired'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$e6#$01#$e4#$1c#$33#$73#$4b#$d1#$bc#$06#$81#$1d#$6c#$32#$3d#$81;
      pid6: 'icqmood3';  PicName: 'st_custom.party'; Caption: 'Party'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$8c#$50#$db#$ae#$81#$ed#$47#$86#$ac#$ca#$16#$cc#$32#$13#$c7#$b7;
      pid6: 'icqmood4';  PicName: 'st_custom.beer';  Caption: 'Beer'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$3f#$b0#$bd#$36#$af#$3b#$4a#$60#$9e#$ef#$cf#$19#$0f#$6a#$5a#$7f;
      pid6: 'icqmood5';  PicName: 'st_custom.thinking'; Caption: 'Thinking'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$f8#$e8#$d7#$b2#$82#$c4#$41#$42#$90#$f8#$10#$c6#$ce#$0a#$89#$a6;
      pid6: 'icqmood6';  PicName: 'st_custom.eating'; Caption: 'Eating'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$80#$53#$7d#$e2#$a4#$67#$4a#$76#$b3#$54#$6d#$fd#$07#$5f#$5e#$c6;
      pid6: 'icqmood7';  PicName: 'st_custom.tv'; Caption: 'TV'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$f1#$8a#$b5#$2e#$dc#$57#$49#$1d#$99#$dc#$64#$44#$50#$24#$57#$af;
      pid6: 'icqmood8';  PicName: 'st_custom.friends'; Caption: 'Friends'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$1b#$78#$ae#$31#$fa#$0b#$4d#$38#$93#$d1#$99#$7e#$ee#$af#$b2#$18;
      pid6: 'icqmood9';  PicName: 'st_custom.coffee'; Caption: 'Coffee'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$61#$BE#$E0#$DD#$8B#$DD#$47#$5D#$8D#$EE#$5F#$4B#$AA#$CF#$19#$A7;
      pid6: 'icqmood10'; PicName: 'st_custom.music'; Caption: 'Music'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$48#$8e#$14#$89#$8a#$ca#$4a#$08#$82#$aa#$77#$ce#$7a#$16#$52#$08;
      pid6: 'icqmood11'; PicName: 'st_custom.business'; Caption: 'Business'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$10#$7a#$9a#$18#$12#$32#$4d#$a4#$b6#$cd#$08#$79#$db#$78#$0f#$09;
      pid6: 'icqmood12'; PicName: 'st_custom.camera'; Caption: 'Camera'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$6f#$49#$30#$98#$4f#$7c#$4a#$ff#$a2#$76#$34#$a0#$3b#$ce#$ae#$a7;
      pid6: 'icqmood13'; PicName: 'st_custom.funny'; Caption: 'Funny'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$12#$92#$e5#$50#$1b#$64#$4f#$66#$b2#$06#$b2#$9a#$f3#$78#$e4#$8d;
      pid6: 'icqmood14'; PicName: 'st_custom.phone'; Caption: 'Phone'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$d4#$a6#$11#$d0#$8f#$01#$4e#$c0#$92#$23#$c5#$b6#$be#$c6#$cc#$f0;
      pid6: 'icqmood15'; PicName: 'st_custom.games'; Caption: 'Games'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$60#$9d#$52#$f8#$a2#$9a#$49#$a6#$b2#$a0#$25#$24#$c5#$e9#$d2#$60;
      pid6: 'icqmood16'; PicName: 'st_custom.college'; Caption: 'College'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$63#$62#$73#$37#$a0#$3f#$49#$ff#$80#$e5#$f7#$09#$cd#$e0#$a4#$ee;
      pid6: 'icqmood0';  PicName: 'st_custom.shopping'; Caption: 'Shopping'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$1f#$7a#$40#$71#$bf#$3b#$4e#$60#$bc#$32#$4c#$57#$87#$b0#$4c#$f1;
      pid6: 'icqmood17'; PicName: 'st_custom.sick'; Caption: 'Sick'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$78#$5e#$8c#$48#$40#$d3#$4c#$65#$88#$6f#$04#$cf#$3f#$3f#$43#$df;
      pid6: 'icqmood18'; PicName: 'st_custom.sleeping'; Caption: 'Sleeping'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$a6#$ed#$55#$7e#$6b#$f7#$44#$d4#$a5#$d4#$d2#$e7#$d9#$5c#$e8#$1f;
      pid6: 'icqmood19'; PicName: 'st_custom.surfing'; Caption: 'Surfing'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$12#$d0#$7e#$3e#$f8#$85#$48#$9e#$8e#$97#$a7#$2a#$65#$51#$e5#$8d;
      pid6: 'icqmood20'; PicName: 'st_custom.internet'; Caption: 'Internet'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$ba#$74#$db#$3e#$9e#$24#$43#$4b#$87#$b6#$2f#$6b#$8d#$fe#$e5#$0f;
      pid6: 'icqmood21'; PicName: 'st_custom.engineering'; Caption: 'Engineering'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$63#$4f#$6b#$d8#$ad#$d2#$4a#$a1#$aa#$b9#$11#$5b#$c2#$6d#$05#$a1;
      pid6: 'icqmood22'; PicName: 'st_custom.typing'; Caption: 'Typing'),
//25
     (flags: [xsf_Old];        pidOld: #$2C#$E0#$E4#$E5#$7C#$64#$43#$70#$9C#$3A#$7A#$1C#$E8#$78#$A7#$DC;
                         PicName: 'st_custom.unk'; Caption: 'Barbecue'),
     (flags: [xsf_Old];        pidOld: #$10#$11#$17#$C9#$A3#$B0#$40#$f9#$81#$AC#$49#$E1#$59#$FB#$D5#$D4;
                         PicName: 'st_custom.ppc'; Caption: 'PPC'),
     (flags: [xsf_Old];        pidOld: #$16#$0C#$60#$BB#$DD#$44#$43#$f3#$91#$40#$05#$0F#$00#$E6#$C0#$09;
                         PicName: 'st_custom.mobile'; Caption: 'Mobile'),
     (flags: [xsf_Old];        pidOld: #$64#$43#$C6#$AF#$22#$60#$45#$17#$B5#$8C#$D7#$DF#$8E#$29#$03#$52;
                         PicName: 'st_custom.man'; Caption: 'Man'),
     (flags: [xsf_Old];        pidOld: #$16#$F5#$B7#$6F#$A9#$D2#$40#$35#$8C#$C5#$C0#$84#$70#$3C#$98#$FA;
                         PicName: 'st_custom.wc'; Caption: 'WC'),

  //QIP
 //30
     (flags: [xsf_Old];        pidOld: #$63#$14#$36#$FF#$3F#$8A#$40#$D0#$A5#$CB#$7B#$66#$E0#$51#$B3#$64;
                         PicName: 'st_custom.quest'; Caption: 'Quest'),
     (flags: [xsf_Old];        pidOld: #$B7#$08#$67#$F5#$38#$25#$43#$27#$A1#$FF#$CF#$4C#$C1#$93#$97#$97;
                         PicName: 'st_custom.geometry'; Caption: ''),
     (flags: [xsf_Old];        pidOld: #$DD#$CF#$0E#$A9#$71#$95#$40#$48#$A9#$C6#$41#$32#$06#$D6#$F2#$80;
                         PicName: 'st_custom.love'; Caption: 'Love'),

  // In R&Q added :)))
//33
     (flags: [xsf_Old, xsf_6]; pidOld: #$3f#$b0#$bd#$36#$af#$3b#$4a#$60#$9e#$ef#$cf#$19#$0f#$6a#$5a#$7E;
      pid6: 'icqmood32'; PicName: 'st_custom.cigarette'; Caption: 'Smoking'),
     (flags: [xsf_Old, xsf_6]; pidOld: #$e6#$01#$e4#$1c#$33#$73#$4b#$d1#$bc#$06#$81#$1d#$6c#$32#$3d#$82;
      pid6: 'icqmood33'; PicName: 'st_custom.sex'; Caption: 'Sex'),
//      pid: #$3E#$DD#$CF#$0E#$A9#$71#$95#$40#$48#$A9#$C6#$41#$32#$06#$D6#$F2;
//      PicName: 'st_custom.'; Caption:
     (flags: [xsf_Old];        pidOld: #$D4#$E2#$B0#$BA#$33#$4E#$4F#$A5#$98#$D0#$11#$7D#$BF#$4D#$3C#$C8;
                         PicName: 'st_custom.search'; Caption:'In search'),
     (flags: [xsf_Old];        pidOld: #$00#$72#$D9#$08#$4A#$D1#$43#$DD#$91#$99#$6F#$02#$69#$66#$02#$6F;
                         PicName: 'st_custom.diary'; Caption:'Diary'),
 // Added in Agent
     (flags: [];               pidOld: #$CD#$56#$43#$A2#$C9#$4C#$47#$24#$B5#$2C#$DC#$01#$24#$A1#$D0#$CD;
                         PicName: 'st_custom.sex'; Caption: 'Sex'),

     (flags: [xsf_Old];        pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$70;
                         PicName: 'status.depression'; Caption: 'Depression'),
     (flags: [xsf_Old];        pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$75;
                         PicName: 'status.f4c'; Caption: 'Free for chat'),
     (flags: [xsf_Old];        pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$76;
                         PicName: 'status.home'; Caption: 'At home'),
     (flags: [xsf_Old];        pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$77;
                         PicName: 'status.work'; Caption: 'At work'),
     (flags: [xsf_Old];        pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$78;
                         PicName: 'status.lunch'; Caption: 'Lunch'),
     (flags: [xsf_Old];        pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$79;
                         PicName: 'status.evil'; Caption: 'Evil')

    );
//  XStatus6Set = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
//                 20,21,22,23,24, 33,34];
//  XStatus6Count = 27;

  icq_missed_msgs: array[0..4] of string = (
  'Message was invalid',
  'Message was too large',
  'Message rate exceeded',
  'Sender too evil (sender warn level > your max_msgs_evil)',
  'You are too evil (sender max_msg_revil < your warn level)');

var
  AntiSpamMsgs: array[0..6] of String =
   (
//   (
    ('Your message has been blocked for antispam reason.'),
    ('You entered invalid code. Try again.'),
    ('Confirmation accepted. Your message recieved. Thank you.'),
    ('You failed antispam verification. You have no attemts. Your UIN (%uin%) is ignored.'),
    ('Please, type digital CODE which you can see below (3 digits).'),
    ('You have attempts: %attempt%.'), //%code%
    ('Please, type answer on question which you can see below.')
{    )
   (
    ('Ваше сообщение заблокировано антиспам плагином.'),
    ('Вы ввели не правильный код. Попробуйте еще раз.'),
    ('Код принят. Ваше сообщение получено. Спасибо.'),
    ('Вы не прошли антиспам проверку. У вас не осталось попыток. Ваш UIN (%uin%) игнорируется.'),
    ('Пожалуйста, введите цифровой КОД который вы видите ниже (3 цифры). '),
    ('Осталось попыток: %attempt%.'#13#10'%code%')
   )}
   );

  function CAPS_sm2big(i : byte): RawByteString; {$IFDEF DELPHI_9_UP} inline; {$ENDIF DELPHI_9_UP}
var
//   ExtStsStrings : array[low(aXStatus)..High(aXStatus),0..1] of string;
//   ExtStsStrings : array[low(XStatus6)..High(XStatus6)] of string;
//   ExtStsStrings : array[low(XStatusArray)..High(XStatusArray)] of string;
   ExtStsStrings : array[low(XStatusArray)..High(XStatusArray)] of TXStatStr;
   StatusesArray : TStatusArray;

var
   useFBcontacts : Boolean = false;

type
  TFileAbout  = class(TObject)
    fPath : String;
    fName : String;
    Size : Int64;
    Processed : Int64;
    CheckSum : Cardinal;
  end;

const
  ICQServers : array[0..5] of string =(
'login.icq.com',
'login.oscar.aol.com',
'ibucp-vip-d.blue.aol.com',
'ibucp-vip-m.blue.aol.com',
'ibucp2-vip-m.blue.aol.com',
'bucp-m08.blue.aol.com'{,
'icq.mirabilis.com',
'icqalpha.mirabilis.com',
'icq1.mirabilis.com',
'icq2.mirabilis.com',
'icq3.mirabilis.com',
'icq4.mirabilis.com',
'icq5.mirabilis.com',
'205.188.252.24',
'205.188.252.27',
'205.188.252.21',
'205.188.254.5',
'205.188.252.33',
'205.188.252.22',
'205.188.252.31',
'205.188.254.3',
'205.188.254.11',
'205.188.252.30',
'205.188.252.18',
'205.188.254.10',
'205.188.254.1',
'205.188.252.19',
'205.188.252.28'});

implementation

  function CAPS_sm2big(i : byte): RawByteString; {$IFDEF DELPHI_9_UP} inline; {$ENDIF DELPHI_9_UP}
  begin
   result := CapsMakeBig1 + CAPSSmall[i].v + CapsMakeBig2;
  end;

end.
