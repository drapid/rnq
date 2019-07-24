{
  This file is part of R&Q.
  Under same license
}
unit WIMConsts;
{$I RnQConfig.inc}

interface

uses
  Windows, RDGlobal, RQThemes, RnQProtocol, RnQPics, themesLib;

{$I NoRTTI.inc}

type
  TWIMStatus = (SC_ONLINE = 0, SC_OFFLINE, SC_UNK, SC_OCCUPIED, SC_NA, SC_AWAY);
  TWIMContactType = (CT_UNK = 0, CT_ICQ, CT_OLDICQ, CT_SMS, CT_PHONE);

  TGroupAction = (GA_None = 0, GA_Add, GA_Rename, GA_Remove);

  TMsgType = (MSG_TEXT = 0, MSG_STICKER);

const
  SC_Last = SC_AWAY;
  StatusPriority: array [TWIMStatus] of byte = (0, 8, 9, 1, 2, 3);

type
//  TVisibility = (VI_normal, VI_invisible, VI_privacy, VI_all, VI_CL);
  TVisibility = (VI_normal, VI_invisible);

const
  SupportedPresenceFields: array [1 .. 34] of String = ('aimId', 'displayId', 'friendly', 'moodIcon', 'moodTitle',
    'offlineMsg', 'state', 'statusMsg', 'userType', 'phoneNumber', 'cellNumber', 'smsNumber', 'workNumber', 'otherNumber',
    'capabilities', 'ssl', 'abPhoneNumber', 'lastName', 'abPhones', 'abContactName', 'lastseen', 'mute', 'livechat', 'official',
    'profile', 'statusTime', 'onlineTime', 'awayTime', 'awayMsg', 'profileMsg', 'presenceIcon', 'location', 'memberSince',
    'iconId');
//    buddyIcon,bigBuddyIcon,bigIconId,largeIconId

  visibility2ShowStr: array [TVisibility] of String = ('Normal (all but invisible-list)',
    'Invisible'); //, 'Privacy (only visible-list)' , 'Visible to all', 'Visible to contact-list');
  visibility2imgName: array [TVisibility] of TPicName = (PIC_VISIBILITY_NORMAL, PIC_VISIBILITY_NONE);
//    PIC_VISIBILITY_PRIVACY, PIC_VISIBILITY_ALL, PIC_VISIBILITY_CL);
//  visib2str: array [Tvisibility] of TPicName = ('normal', 'invisible', 'privacy', 'all', 'cl');
  visib2str: array [TVisibility] of TPicName = ('normal', 'invisible');
  status2ShowStr: array [TWIMStatus] of string = ('Online', 'Offline', 'Unknown', 'Occupied', 'N/A', 'Away');
  status2Img: array [0 .. Byte(SC_AWAY)] of TPicName = ('online', 'offline', 'unk', 'occupied', 'na', 'away');
  Status2Srv: array [0 .. Byte(SC_AWAY)] of TPicName =
              ('online', 'offline', 'offline', 'occupied', 'na', 'away');
  statusWithAutoMsg = [byte(SC_AWAY), byte(SC_NA), byte(SC_OCCUPIED)];

const
  maxRefs = 2000;
  // directProtoVersion=8;
  maxPwdLength = 16;
  AIM_MD5_STRING: AnsiString = 'AOL Instant Messenger (SM)';
  ICQ_DEV_ID: AnsiString = 'ic1nmMjqg7Yu-0hL'; // ic1nmMjqg7Yu-0hL - ICQ Windows, ic1rtwz1s1Hj1O0r - Web
  LOGIN_HOST: AnsiString = 'https://api.login.icq.net/';
  SMS_REG: AnsiString = 'https://www.icq.com/smsreg/';
  WIM_HOST: AnsiString = 'https://api.icq.net/';
  REST_HOST: AnsiString = 'https://rapi.icq.net/';
  STORE_HOST: AnsiString = 'https://store.icq.com/';
  UINToUpdate = 223223181;
  AIMprefix = 'AIM_';
  ICQMaxAvatarSize = 7800;
  // AOL_FILE_TRANSFER_SERVER = 'ars.oscar.aol.com';
  // ICQ_SECURE_LOGIN_SERVER = 'slogin.oscar.aol.com';
  AOL_FILE_TRANSFER_SERVER0 = 'ars.icq.com';
  ICQ_SECURE_LOGIN_SERVER0 = 'slogin.icq.com';

  ICQErrorReconnectDelay = 5000; // Default attempt delay after error

  BALLOON_NEVER = 0;
  BALLOON_ALWAYS = 1;
  BALLOON_BDAY = 2;
  BALLOON_DATE = 3;

  // Client IDs
  RnQclientID = $FFFFF666;

const
  // By Rapid D
  IF_Simple = 1 shl 5; // msg is simple
  // IF_MSG_OK   = 1 shl 8;      // msg was delivered!
  // IF_MSG_ERROR= 1 shl 9;      // msg was NOT delivered!
  IF_no_matter = 1 shl 10;
  last_IF = 1 shl 10; // useful for external additional flags

  AvtHash_NoAvt = AnsiString(#$B4#$32#$5C#$25#$34#$3D#$41#$13#$72#$90#$9D#$C0#$E7#$3A#$71#$73);
  // Hash of Avatar "No photo has been uploaded"

  word_Zero = AnsiString(#00#00);
  dword_Zero = AnsiString(#00#00#00#00);
  Z = dword_Zero;

  BigCapability: array [1 .. 32] of record
    v: String[16];
    s: AnsiString;
  end = (
  (v: #$97#$B1#$27#$51#$24#$3C#$43#$34#$AD#$22#$D6#$AB#$F7#$3F#$14#$92; s: 'RTF messages'), // RTF
  (v: #$2E#$7A#$64#$75#$FA#$DF#$4D#$C8#$88#$6F#$EA#$35#$95#$FD#$B6#$DF; s: 'ICQ 2001'),
  // AIM_CAPS_2001 or OLD_UTF
  (v: #$56#$3F#$C8#$09#$0B#$6F#$41#$BD#$9F#$79#$42#$26#$09#$DF#$A2#$F3; s: 'Typing notifications'),
  // mini typing notification (MTN) (for 2003b, ..., lite4)
  (v: #$97#$B1#$27#$51#$24#$3C#$43#$34#$AD#$22#$D6#$AB#$F7#$3F#$14#$09; s: 'Secure IM Trillian'),
  // Is Trillian
  (v: #$74#$8F#$24#$20#$62#$87#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00; s: 'Chat'),
  // Can participate in centralized text conferences
  (v: #$1A#$09#$3C#$6C#$D7#$FD#$4E#$C5#$9D#$51#$A6#$47#$4E#$34#$F5#$A0; s: 'Xtraz'),
  (v: #$D3#$D4#$53#$19#$8B#$32#$40#$3B#$AC#$C7#$D1#$A9#$E2#$B5#$81#$3E; s: 'QIP-ProtectMsg'),
  // (V: #$17#$8C#$2D#$9B#$DA#$A5#$45#$BB#$8D#$DB#$F3#$BD#$BD#$53#$A1#$0A; s: 'Lite-AIM Cap1'),
  (v: #$17#$8C#$2D#$9B#$DA#$A5#$45#$BB#$8D#$DB#$F3#$BD#$BD#$53#$A1#$0A; s: 'IM is ICQLite'),
  // );
  // ExtCapability:array [1..6] of record v : string[16]; s : String end=(

  (v: #$F2#$E7#$C7#$F4#$FE#$AD#$4D#$FB#$B2#$35#$36#$79#$8B#$DF#$00#$00; s: 'Trillian'), // Trillian
  (v: #$09#$49#$13#$44#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00; s: 'kxICQ2'), // Is kxICQ2
  (v: #$DD#$16#$F2#$02#$84#$E6#$11#$D4#$90#$DB#$00#$10#$4B#$9B#$4B#$7D; s: 'MacICQ'), // MacICQ
  (v: #$09#$49#$13#$49#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00; s: 'LICQ'), // LICQ
  (v: #$56#$3F#$C8#$09#$0B#$6F#$41#$51#$49#$50#$20#$32#$30#$30#$35#$61; s: 'QIP 2005'), // QIP 2005
  (v: #$74#$ED#$C3#$36#$44#$DF#$48#$5B#$8B#$1C#$67#$1A#$1F#$86#$09#$9F; s: 'IM2'),

  (v: #$E3#$62#$C1#$E9#$12#$1A#$4B#$94#$A6#$26#$7A#$74#$DE#$24#$27#$0D; s: 'Push2Talk'),
  (v: #$B9#$97#$08#$B5#$3A#$92#$42#$02#$B0#$69#$F1#$E7#$57#$BB#$2E#$17; s: 'ICQ Voice Chat'),
  (v: #$67#$36#$15#$15#$61#$2D#$4C#$07#$8F#$3D#$BD#$E6#$40#$8E#$A0#$41; s: 'Xtraz MultiUser Chat'),
  (v: #$7E#$11#$B7#$78#$A3#$53#$49#$26#$A8#$02#$44#$73#$52#$08#$C4#$2A; s: 'Lsp-RU-Rambler'),
  (v: #$B6#$07#$43#$78#$F5#$0C#$4A#$C7#$90#$92#$59#$38#$50#$2D#$05#$91; s: 'ICQ-XVideo'),
  (v: #$01#$00#$11#$00#$00#$00#$00#$00#$11#$00#$00#$00#$00#$2a#$02#$b5; s: 'AIM'),
  (v: #$B2#$EC#$8F#$16#$7C#$6F#$45#$1B#$BD#$79#$DC#$58#$49#$78#$88#$B9; s: 'tZers'), // 21
  (v: #$01#$38#$CA#$7B#$76#$9A#$49#$15#$88#$F2#$13#$FC#$00#$97#$9E#$A8; s: 'ICQ6'),
  (v: #$D6#$68#$7F#$4F#$3D#$C3#$4b#$db#$8A#$8C#$4C#$1A#$57#$27#$63#$CD; s: 'R&Q-ProtectMsg'), // 23
  (v: #$7C#$73#$75#$02#$C3#$BE#$4F#$3E#$A6#$9F#$01#$53#$13#$43#$1E#$1A; s: 'qip Infium'),
  (v: #$56#$6D#$49#$43#$51#$20#$76#$30#$2E#$31#$2E#$34#$62#$00#$00#$00; s: 'vmICQ'),
  (v: #$7C#$53#$3F#$FA#$68#$00#$4F#$21#$BC#$FB#$C7#$D2#$43#$9A#$AD#$31; s: 'qip-plugins'),
  (v: #$56#$3F#$C8#$09#$0B#$6F#$41#$51#$49#$50#$20#$20#$20#$20#$20#$21; s: 'QIP PDA WM'),
  (v: #$51#$AD#$D1#$90#$72#$04#$47#$3D#$A1#$A1#$49#$F4#$A3#$97#$A4#$1F; s: 'QIP PDA Symbian'),
  (v: #$7A#$7B#$7C#$7D#$7E#$7F#$0A#$03#$0B#$04#$01#$53#$13#$43#$1E#$1A; s: 'qip 2010'),
  (v: #$35#$CA#$0A#$C9#$E4#$67#$48#$AB#$9D#$FA#$1D#$23#$41#$F0#$08#$32; s: 'tZers [Mults]'),
  (v: #$4D#$6F#$64#$20#$62#$79#$20#$4D#$69#$6B#$61#$6E#$6F#$73#$68#$69; s: 'R&Q build by Mikanoshi'),
  (v: #$F2#$3D#$D3#$84#$7B#$52#$40#$EC#$B5#$CE#$10#$64#$59#$A4#$C9#$7D; s: 'Buzz support')
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$70; s: 'Status [Sad]'),
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$75; s: 'Status [Free for chat]'),
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$76; s: 'Status [At home]'),
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$77; s: 'Status [At work]'),
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$78; s: 'Status [At Lunch]'),
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$79; s: 'Status [Angry]')
  // 8C543DFC69024D25BFFAC0D3419CAF30 -- ????
  );
// capIs2002    = {0x10, 0xcf, 0x40, 0xd1, 0x4c, 0x7f, 0x11, 0xd1, 0x82, 0x22, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00};
// capStr20012  = {0xa0, 0xe9, 0x3f, 0x37, 0x4f, 0xe9, 0xd3, 0x11, 0xbc, 0xd2, 0x00, 0x04, 0xac, 0x96, 0xdd, 0x96};
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

  CapsSmall: array [1 .. 39] of record
    v: RawByteString;
    s: AnsiString;
    Desc: AnsiString;
  end
= ((v: #$01#$00; s: 'Video'; Desc: ''), // = Video
  (v: #$01#$01; s: 'SIP/RTP video'; Desc: 'Can do live video streaming, using SIP/RTP'),
  // 2 = RtpVideo
  (v: #$01#$02; s: 'Has camera'; Desc: 'Has a video camera connected'), // = HasCamera
  (v: #$01#$03; s: 'Has microphone'; Desc: 'Has a microphone connected (may not be set for non-USB mics)'), // 4 = HasMicrophone
  (v: #$01#$04; s: 'RTP audio'; Desc: 'Can do live audio streaming, using SIP/RTP'), // = RtpAudio
  (v: #$01#$05; s: 'Available for call'; Desc: 'Can receive an a/v call at this time'),
  // 6 = AvailableForCall
  (v: #$01#$06; s: 'Aca'), // = Aca
  (v: #$01#$07; s: 'Audio conferences'; Desc: 'Can participate in centralized audio conferences'),
  // 8 = MultiAudio
  (v: #$01#$08; s: 'Video conferences'; Desc: 'Can participate in centralized video conferences'),
  // = MultiVideo
  (v: #$01#$FF; s: 'Smart caps'; Desc: 'Whether caps reflect opt-in features vs. features the software supports'),
  // 10 = SmartCaps
  (v: #$F0#$04; s: 'Viceroy'), // = Viceroy
  (v: #$13#$49; s: 'ICQ Server Relay'), // 12  AIM_CAPS_ICQSERVERRELAY
  (v: #$13#$44; s: 'IM is ICQ'), // AIM_CAPS_ICQ
  (v: #$13#$4E; s: 'UTF-8 Messages'), // 14 UTF-8
  (v: #$13#$4C; s: 'Avatar support'), // CAP_AVATAR
  // (V: #$13#$4c; s: 'Lite-AIM Cap1'),        // CAP_AVATAR
  (v: #$13#$45; s: 'Direct IM'; Desc: 'Can participate in direct IM sessions'), // 16
  (v: #$13#$46; s: 'Buddy icon'; Desc: 'Can receive non-BART buddy icons'),
  (v: #$13#$48; s: 'File sharing'; Desc: 'Offering files for download'), // 18   CAP_FILE_SHARING
  (v: #$14#$49; s: 'ICQ 2001a'), // CAP_ICQ_SERVER_RELAY
  (v: #$13#$43; s: 'File transfer'; Desc: 'Can receive files'), // 20  CAP_FILE_TRANSFER
  (v: #$13#$41; s: 'Old audio'; Desc: 'Can do live audio streaming, using JGTK'), // CAP_AOL_TALK
  (v: #$13#$42; s: 'Direct Play'), // 22   CAP_DIRECT_PLAY
  (v: #$13#$4B; s: 'Share buddies'; Desc: 'Can receive sent buddy lists'), // CAP_SHARE_BUDDIES
  // (V: #$13#$42; s: 'Preakness')        //24   CAP_PREAKNESS

  (v: #$13#$4D; s: 'Talk with ICQ'), // 24
  (v: #$00#$00; s: 'Short caps'), // 25
  (v: #$00#$01; s: 'Secure IM'; Desc: 'Can receive "application/pkcs7-mime" encoded IMs'), // 26
  (v: #$00#$02; s: 'XHTML IM'; Desc: 'Can receive "application/xhtml+xml" encoded IMs'), // 27
  (v: #$01#$0A; s: 'New status message features'), // 28  = HOST_STATUS_TEXT_AWARE
  (v: #$01#$0B; s: '"See as I type" IMs'), // 29  RTIM

  (v: #$13#$50; s: 'VoIP Audio'; Desc: 'Supports voice over VoIP'), // 30
  (v: #$13#$51; s: 'VoIP Video'; Desc: 'Supports video over VoIP'), // 31
  (v: #$13#$53; s: 'Unique request ID'),  // 32
  (v: #$13#$54; s: 'Emoji support'),  // 33
  (v: #$13#$59; s: 'Mail notifications'),  // 34
  (v: #$13#$5A; s: 'Dialog messages position support'; desc: 'Receive intro/tail messages'),  // 35
  (v: #$13#$5B; s: 'Mentions support'),  // 36

  (v: #$13#$58; s: '1358'),  // 37
  (v: #$13#$5C; s: '135c'),  // 38
  (v: #$13#$5E; s: '135e')  // 39
  );
  // #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00  // Anti-invischeck
  MsgCapabilities: array [1 .. 1] of RawByteString = (#$3B#$60#$B3#$EF#$D8#$2A#$6C#$45#$A4#$E0#$9C#$5A#$5E#$67#$E8#$65
  // XStatus
  // #$09#$46#$13#$43#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00 // file transfer (Send)
  // D9122DF0-9130-11D3-8DD7-00104B06462E //File transfer plugin.
  // #$09#$46#$13#$48#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00 // file transfer (Recieve)
  // #$09#$46#$13#$49#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00, // Plugin MSG
  // #$f0#$2d#$12#$d9#$30#$91#$d3#$11#$8d#$d7#$00#$10#$4b#$06#$46#$2e,
  );
  // msgUTF : TGUID = '{0946134E-4C7F-11D1-8222-444553540000}';
  msgUTFstr = '{0946134E-4C7F-11D1-8222-444553540000}';
  msgRTF: TGUID = '{97B12751-243C-4334-AD22-D6ABF73F1492}';
  msgRnQpass: TGUID = '{e92a62a2-e32a-49dc-acc6-22066bd4f316}';
  // msgQIPpass : TGUID = '{d3d45319-8b32-403b-acc7-d1a9e2b5813e}';
  msgQIPpassStr = AnsiString('{D3D45319-8B32-403B-ACC7-D1A9E2B5813E}');

  CAPS_sm_SmartCaps = 10;
  CAPS_sm_ICQServerRelay = 12;
  CAPS_sm_ICQ = 13;
  CAPS_sm_UTF8 = 14;
  CAPS_sm_Avatar = 15;
  CAPS_sm_BuddyIcon = 17;
  CAPS_sm_File = 18;
  CAPS_sm_FileTransfer = 20;
  CAPS_sm_ShareBuddies = 23;
  CAPS_sm_AIM = 24;
  CAPS_sm_ShortCaps = 25;
  CAPS_sm_SecIM = 26;
  CAPS_sm_NewStat = 28;
  CAPS_sm_UniqueID = 32;
  CAPS_sm_Emoji = 33;
  CAPS_sm_MailNotify = 34;
  CAPS_sm_IntroDlgStates = 35;
  CAPS_sm_Mentions = 36;

  CAPS_big_RTF = 1;
  CAPS_big_2001 = 2;
  CAPS_big_MTN = 3;
  CAPS_big_SecIM = 4;
  CAPS_big_Chat = 5;
  CAPS_big_Xtraz = 6;
  CAPS_big_QIP_Secure = 7;
  CAPS_big_Lite = 8;
  CAPS_big_Tril = 9;
  CAPS_big_macICQ = 11;
  CAPS_big_LICQ = 12;
  CAPS_big_QIP = 13;
  CAPS_big_MultiUserChat = 17;
  CAPS_big_RMBLR = 18;
  CAPS_BIG_Xtraz5 = 20;
  CAPS_big_tZers = 21;
  CAPS_big_ICQ6 = 22;
  CAPS_big_CryptMsg = 23;
  CAPS_big_qipInf = 24;
  CAPS_big_qipWM = 27;
  CAPS_big_qipSym = 28;
  CAPS_big_qip2010 = 29;
  CAPS_big_tZers_Mults = 30;
  CAPS_big_Build = 31;
  CAPS_big_Buzz = 32;

  CAPS_Ext_CLI_Last = 14;
  CAPS_Ext_CLI_First = 9;

  // Message types
  MTYPE_PLAIN = $01; // Plain text (simple) message
  MTYPE_CHAT = $02; // Chat request message
  MTYPE_FILEREQ = $03; // File request / file ok message
  MTYPE_URL = $04; // URL message (0xFE formatted)
  MTYPE_AUTHREQ = $06; // Authorization request message (0xFE formatted)
  MTYPE_AUTHDENY = $07; // Authorization denied message (0xFE formatted)
  MTYPE_AUTHOK = $08; // Authorization given message (empty)
  MTYPE_SERVER = $09; // Message from OSCAR server (0xFE formatted)
  MTYPE_ADDED = $0C; // "You-were-added" message (0xFE formatted)
  MTYPE_WWP = $0D; // Web pager message (0xFE formatted)
  MTYPE_EEXPRESS = $0E; // Email express message (0xFE formatted)
  MTYPE_CONTACTS = $13; // Contact list message
  MTYPE_PLUGIN = $1A; // Plugin message described by text string
  MTYPE_AUTOAWAY = $E8; // Auto away message
  MTYPE_AUTOBUSY = $E9; // Auto occupied message
  MTYPE_AUTONA = $EA; // Auto not available message
  MTYPE_AUTOFFC = $EC; // Auto free for chat message

  MTYPE_XSTATUS = $61;
  MTYPE_GCARD = $62;

  MTYPE_UNKNOWN = $00; // Unknown message, only used internally by this plugin

  MTYPE_AUTOMSGS = [MTYPE_AUTOAWAY, MTYPE_AUTOBUSY, MTYPE_AUTONA, MTYPE_AUTOFFC];

  PLUGIN_SCRIPT = AnsiString('Script Plug-in: Remote Notification Arrive');
  ACK_OK = 0;
  ACK_FILEDENY = 1;
  ACK_OCCUPIED = 9;
  ACK_AWAY = 4;
  ACK_NA = $E;
  ACK_NOBLINK = $C;

  MTN_FINISHED = $0000; // typing finished sign
  MTN_TYPED = $0001; // text typed sign
  MTN_BEGUN = $0002; // typing begun sign
  MTN_CLOSED = $000F; // Closed chat

type
  TICQAccept = (AC_OK, AC_DENIED, AC_AWAY);

  TICQError = (EC_rateExceeded, EC_cantConnect, EC_socket, EC_other, EC_badUIN,
    // at login-time, referred to my own uin
    EC_missingLogin, EC_anotherLogin, EC_serverDisconnected, EC_badPwd, EC_cantChangePwd,
    EC_loginDelay, EC_cantCreateUIN, EC_invalidFlap, EC_badContact, EC_cantConnect_dc,
    EC_proxy_error, EC_proxy_badPwd, EC_proxy_unk, // unknown reply
    EC_MalformedMsg, EC_AddContact_Error, EC_Login_Seq_Failed, EC_FailedDecrypt,
    EC_StoreProblem);

  TICQAuthError = (
    EAC_Not_Enough_Data = -1,
    EAC_Unknown = 0,
    EAC_OK = 200, // no error
    EAC_Wrong_Login = 330,
    EAC_Invalid_Request = 400,
    EAC_Auth_Required = 401,
    EAC_Req_Timeout = 408,
    EAC_Wrong_DevKey = 440,
    EAC_Missing_Param = 460,
    EAC_Param_Error = 462,
    EAC_Rate_Limit = 607
  );

const
  ICQError2Str: array [TICQError] of String =
    ('Server says you''re reconnecting too fastly, try later or change user.', // 'rate exceeded',
    'Cannot connect\n[%d] %s', // 'can''t connect',
    'Disconnected\n[%d] %s', // 'disconnected',
    'Unknown error', // 'unknown',
    'Your uin is not correct', // 'incorrect uin',
    'Missing password', // 'missing pwd',
    'Your current UIN is used by someone else right now, server disconnected you',
    // 'another login',
    'Server disconnected', // 'server disconnected',
    'Wrong password, correct it and try again', // 'wrong pwd',
    'Cannot change password', // 'can''t change pwd',
    'Server is sick, wait 2 seconds and try again', // 'delay',
    'Can''t create UIN', // 'can''t create uin',
    'FLAP level error', // 'invalid flap',
    'Queried contact is invalid', // 'bad contact',
    'can''t directly connect\n[%d] %s', 'proxy: error', 'PROXY: Invalid user/password',
    // 'proxy: wrong user/pwd',
    'PROXY: Unknown reply\n[%d] %s',      // 'proxy: unk'
    'Couldn''t parse incoming event\nRaw input:\n%s',
    'Failed to add contact\n%s',
    'Login sequence cannot be completed due to error on one of the stages',
    'Could''t decrypt message\n%s',
    'Failed to process store purchase\n%s');
(*
  ICQAuthErrors: array [330, 408] of String = (

    'Invalid nick or password', 'Service temporarily unavailable', 'All other errors',
    'Wrong password, correct it and try again', // 'AUTH_ERR_INCORR_NICK_OR_PASSWORD',
    'Mismatch nick or password, re-enter', 'Internal client error (bad input to authorizer)',
    'Invalid account', 'Deleted account', 'Expired account', 'No access to database', // $0A
    'No access to resolver', 'Invalid database fields', // $0C
    'Bad database status', 'Bad resolver status', 'Internal error', 'Service temporarily offline',
    // $10
    'Suspended account', 'DB send error', 'DB link error', 'Reservation map error',
    'Reservation link error', // $15
    'Too many clients from the same ip address',
    'Too many clients from the same ip address (reservation)',
    'Server says you''re reconnecting too fastly, try later or change user.',
    // 'AUTH_ERR_RESERVATION_RATE',        // $18
    'User too heavily warned', 'Reservation timeout', // $1A
    'You are using an older version of ICQ. Upgrade required', // $1B
    'You are using an older version of ICQ. Upgrade recommended',
    'Rate limit exceeded. Please try to reconnect in a few minutes', // $1D
    'Can ''t register on the ICQ network. Reconnect in a few minutes', // $1E
    'AUTH_ERR_SECURID_TIMEOUT', // upd, 2006: AUTH_ERR_TOKEN_SERVER_TIMEOUT
    'Invalid SecurID', // upd, 2006: AUTH_ERR_INVALID_TOKEN_KEY
    'AUTH_ERR_MC_ERROR', 'AUTH_ERR_CREDIT_CARD_VALIDATION', // upd 2006 // ...
    'AUTH_ERR_REQUIRE_REVALIDATION', // upd 2006
    'AUTH_ERR_LINK_RULE_REJECT', // upd 2006
    'AUTH_ERR_MISS_INFO_OR_INVALID_SNAC', // upd 2006
    'AUTH_ERR_LINK_BROKEN', // upd 2006
    'AUTH_ERR_INVALID_CLIENT_IP', // upd 2006
    'AUTH_ERR_PARTNER_REJECT', // upd 2006
    'AUTH_ERR_SECUREID_MISSING', // upd 2006
    'AUTH_ERR_BUMP_USER',
    'Failed to get all the data required for starting a new session'); // upd 2019
*)
type
  XStatusFlags = (xsf_Old, xsf_6);
  XStatusFlagsSet = set of XStatusFlags;

const
  XStatusArray: array [0 .. 98] of record
    flags: XStatusFlagsSet;
    pidOld: RawByteString;
    pid6: RawByteString;
    PicName: TPicName;
    Caption: String;
  end
  = ((flags: [xsf_Old, xsf_6]; pidOld: ''; pid6: ''; PicName: 'st_custom.none'; Caption: 'None'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$16#$0C#$60#$BB#$DD#$44#$43#$f3#$91#$40#$05#$0F#$00#$E6#$C0#$09;
  pid6: 'status_mobile'; PicName: 'st_custom.mailrumobile'; Caption: 'Mail.ru mobile'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$75;
  pid6: 'status_chat'; PicName: 'st_custom.f4c'; Caption: 'Free for chat'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$76;
  pid6: '0icqmood63'; PicName: 'st_custom.home'; Caption: 'At home'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$77;
  pid6: '0icqmood21'; PicName: 'st_custom.atwork'; Caption: 'At work'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$ba#$74#$db#$3e#$9e#$24#$43#$4b#$87#$b6#$2f#$6b#$8d#$fe#$e5#$0f;
  pid6: '0icqmood64'; PicName: 'st_custom.engineering'; Caption: 'Engineering'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$48#$8e#$14#$89#$8a#$ca#$4a#$08#$82#$aa#$77#$ce#$7a#$16#$52#$08;
  pid6: '0icqmood11'; PicName: 'st_custom.business'; Caption: 'Business'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$63#$14#$36#$FF#$3F#$8A#$40#$D0#$A5#$CB#$7B#$66#$E0#$51#$B3#$64; //Quest
  pid6: 'icqmood209'; PicName: 'st_custom.whereami'; Caption: 'Where am I?'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$64#$43#$C6#$AF#$22#$60#$45#$17#$B5#$8C#$D7#$DF#$8E#$29#$03#$52;
  pid6: '0icqmood18'; PicName: 'st_custom.asleep'; Caption: 'Asleep'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$78#$5e#$8c#$48#$40#$d3#$4c#$65#$88#$6f#$04#$cf#$3f#$3f#$43#$df;
  pid6: '0icqmood70'; PicName: 'st_custom.sleeping'; Caption: 'Sleeping'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$B7#$08#$67#$F5#$38#$25#$43#$27#$A1#$FF#$CF#$4C#$C1#$93#$97#$97; //Geometry
  pid6: '0icqmood74'; PicName: 'st_custom.doublerainbow'; Caption: 'Double Rainbow'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$12#$d0#$7e#$3e#$f8#$85#$48#$9e#$8e#$97#$a7#$2a#$65#$51#$e5#$8d;
  pid6: '0icqmood20'; PicName: 'st_custom.internet'; Caption: 'In Internet'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$63#$62#$73#$37#$a0#$3f#$49#$ff#$80#$e5#$f7#$09#$cd#$e0#$a4#$ee;
  pid6: '0icqmood0'; PicName: 'st_custom.shopping'; Caption: 'Shopping'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$D4#$E2#$B0#$BA#$33#$4E#$4F#$A5#$98#$D0#$11#$7D#$BF#$4D#$3C#$C8; //In search
  pid6: '0icqmood38'; PicName: 'st_custom.rocket'; Caption: 'Rocket'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$60#$9d#$52#$f8#$a2#$9a#$49#$a6#$b2#$a0#$25#$24#$c5#$e9#$d2#$60;
  pid6: '0icqmood16'; PicName: 'st_custom.college'; Caption: 'College'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$12#$92#$e5#$50#$1b#$64#$4f#$66#$b2#$06#$b2#$9a#$f3#$78#$e4#$8d;
  pid6: '0icqmood14'; PicName: 'st_custom.phone'; Caption: 'Phone'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$00#$72#$D9#$08#$4A#$D1#$43#$DD#$91#$99#$6F#$02#$69#$66#$02#$6F;
  pid6: '0icqmood22'; PicName: 'st_custom.typing'; Caption: 'Typing'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$1f#$7a#$40#$71#$bf#$3b#$4e#$60#$bc#$32#$4c#$57#$87#$b0#$4c#$f1;
  pid6: '0icqmood17'; PicName: 'st_custom.sick'; Caption: 'Sick'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$f8#$e8#$d7#$b2#$82#$c4#$41#$42#$90#$f8#$10#$c6#$ce#$0a#$89#$a6;
  pid6: '0icqmood80'; PicName: 'st_custom.eating'; Caption: 'Eating'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$f8#$e8#$d7#$b2#$82#$c4#$41#$42#$90#$f8#$10#$c6#$ce#$0a#$89#$a6; //Eating
  pid6: '0icqmood6'; PicName: 'st_custom.cooking'; Caption: 'Cooking'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$1b#$78#$ae#$31#$fa#$0b#$4d#$38#$93#$d1#$99#$7e#$ee#$af#$b2#$18;
  pid6: '0icqmood9'; PicName: 'st_custom.coffee'; Caption: 'Coffee'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$8c#$50#$db#$ae#$81#$ed#$47#$86#$ac#$ca#$16#$cc#$32#$13#$c7#$b7;
  pid6: '0icqmood4'; PicName: 'st_custom.beer'; Caption: 'Beer'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$3f#$b0#$bd#$36#$af#$3b#$4a#$60#$9e#$ef#$cf#$19#$0f#$6a#$5a#$7E;
  pid6: 'icqmood202'; PicName: 'st_custom.cigarette'; Caption: 'Smoking'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$16#$F5#$B7#$6F#$A9#$D2#$40#$35#$8C#$C5#$C0#$84#$70#$3C#$98#$FA;
  pid6: '0icqmood68'; PicName: 'st_custom.wc'; Caption: 'WC'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$5A#$58#$1E#$A1#$E5#$80#$43#$0C#$A0#$6F#$61#$22#$98#$B7#$E4#$C7;
  pid6: '0icqmood1'; PicName: 'st_custom.duck'; Caption: 'Bathing'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$d4#$a6#$11#$d0#$8f#$01#$4e#$c0#$92#$23#$c5#$b6#$be#$c6#$cc#$f0;
  pid6: '0icqmood15'; PicName: 'st_custom.games'; Caption: 'Games'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$3f#$b0#$bd#$36#$af#$3b#$4a#$60#$9e#$ef#$cf#$19#$0f#$6a#$5a#$7f;
  pid6: '0icqmood5'; PicName: 'st_custom.thinking'; Caption: 'Thinking'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$61#$BE#$E0#$DD#$8B#$DD#$47#$5D#$8D#$EE#$5F#$4B#$AA#$CF#$19#$A7;
  pid6: '0icqmood3'; PicName: 'st_custom.music'; Caption: 'Listening to music'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$DD#$CF#$0E#$A9#$71#$95#$40#$48#$A9#$C6#$41#$32#$06#$D6#$F2#$80;
  pid6: '0icqmood61'; PicName: 'st_custom.love'; Caption: 'Love'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$e6#$01#$e4#$1c#$33#$73#$4b#$d1#$bc#$06#$81#$1d#$6c#$32#$3d#$82;
  pid6: '0icqmood61'; PicName: 'st_custom.sex'; Caption: 'Sex'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$83#$c9#$b7#$8e#$77#$e7#$43#$78#$b2#$c5#$fb#$6c#$fc#$c3#$5b#$ec;
  pid6: '0icqmood2'; PicName: 'st_custom.tired'; Caption: 'Tired'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$6f#$49#$30#$98#$4f#$7c#$4a#$ff#$a2#$76#$34#$a0#$3b#$ce#$ae#$a7;
  pid6: '0icqmood13'; PicName: 'st_custom.funny'; Caption: 'Funny'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$70;
  pid6: '0icqmood72'; PicName: 'st_custom.depression'; Caption: 'Depression'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$01#$D8#$D7#$EE#$AC#$3B#$49#$2A#$A5#$8D#$D3#$D8#$77#$E6#$6B#$92;
  pid6: '0icqmood23'; PicName: 'st_custom.angry'; Caption: 'Angry'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$79; //Evil
  pid6: '0icqmood33'; PicName: 'st_custom.evil'; Caption: 'Evil'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$a6#$ed#$55#$7e#$6b#$f7#$44#$d4#$a5#$d4#$d2#$e7#$d9#$5c#$e8#$1f;
  pid6: '0icqmood19'; PicName: 'st_custom.surfing'; Caption: 'Surfing'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$80#$53#$7d#$e2#$a4#$67#$4a#$76#$b3#$54#$6d#$fd#$07#$5f#$5e#$c6;
  pid6: '0icqmood7'; PicName: 'st_custom.tv'; Caption: 'TV'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$10#$7a#$9a#$18#$12#$32#$4d#$a4#$b6#$cd#$08#$79#$db#$78#$0f#$09;
  pid6: '0icqmood12'; PicName: 'st_custom.camera'; Caption: 'Camera'),
   (flags: [xsf_Old, xsf_6]; pidOld: #$63#$4f#$6b#$d8#$ad#$d2#$4a#$a1#$aa#$b9#$11#$5b#$c2#$6d#$05#$a1;
  pid6: '0icqmood84'; PicName: 'st_custom.diary'; Caption: 'Diary'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$16#$0C#$60#$BB#$DD#$44#$43#$f3#$91#$40#$05#$0F#$00#$E6#$C0#$09;
  pid6: '0icqmood71'; PicName: 'st_custom.mobile'; Caption: 'Mobile'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$10#$11#$17#$C9#$A3#$B0#$40#$f9#$81#$AC#$49#$E1#$59#$FB#$D5#$D4;
  pid6: '0icqmood71'; PicName: 'st_custom.ppc'; Caption: 'PPC'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$e6#$01#$e4#$1c#$33#$73#$4b#$d1#$bc#$06#$81#$1d#$6c#$32#$3d#$81; //Party
  pid6: '0icqmood3'; PicName: 'st_custom.party'; Caption: 'Party'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$f1#$8a#$b5#$2e#$dc#$57#$49#$1d#$99#$dc#$64#$44#$50#$24#$57#$af; //Friends
  pid6: '0icqmood3'; PicName: 'st_custom.friends'; Caption: 'With friends'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$78; //Lunch
  pid6: '0icqmood66'; PicName: 'st_custom.burger'; Caption: 'Burger'),
  (flags: [xsf_Old, xsf_6]; pidOld: #$2C#$E0#$E4#$E5#$7C#$64#$43#$70#$9C#$3A#$7A#$1C#$E8#$78#$A7#$DC;
  pid6: '0icqmood80'; PicName: 'st_custom.unk'; Caption: 'Barbecue'),
  (flags: [xsf_6]; pid6: '0icqmood31'; PicName: 'st_custom.chicken'; Caption: 'Chicken'),
  (flags: [xsf_6]; pid6: '0icqmood32'; PicName: 'st_custom.cool'; Caption: 'Cool'),
  (flags: [xsf_6]; pid6: 'icqmood205'; PicName: 'st_custom.wrongnumber'; Caption: 'Wrong number'),
  (flags: [xsf_6]; pid6: '0icqmood28'; PicName: 'st_custom.death'; Caption: 'Death'),
  (flags: [xsf_6]; pid6: '0icqmood50'; PicName: 'st_custom.overexcited'; Caption: 'Overexcited'),
  (flags: [xsf_6]; pid6: 'icqmood201'; PicName: 'st_custom.inthewoods'; Caption: 'In the woods'),
  (flags: [xsf_6]; pid6: '0icqmood34'; PicName: 'st_custom.alien'; Caption: 'Alien'),
  (flags: [xsf_6]; pid6: '0icqmood55'; PicName: 'st_custom.thumbsup'; Caption: 'Thumbs up'),
  (flags: [xsf_6]; pid6: 'icqmood217'; PicName: 'st_custom.thumbsdown'; Caption: 'Thumbs down'),
  (flags: [xsf_6]; pid6: 'icqmood215'; PicName: 'st_custom.fig'; Caption: 'Fig'),
  (flags: [xsf_6]; pid6: '0icqmood53'; PicName: 'st_custom.fist'; Caption: 'Fist'),
  (flags: [xsf_6]; pid6: '0icqmood45'; PicName: 'st_custom.fuckyou'; Caption: 'Fuck you'),
  (flags: [xsf_6]; pid6: '0icqmood39'; PicName: 'st_custom.fuckyoutoo'; Caption: 'Fuck you too'),
  (flags: [xsf_6]; pid6: '0icqmood75'; PicName: 'st_custom.basketball'; Caption: 'Basketball'),
  (flags: [xsf_6]; pid6: '0icqmood27'; PicName: 'st_custom.football'; Caption: 'Football'),
  (flags: [xsf_6]; pid6: '0icqmood40'; PicName: 'st_custom.leprechaun'; Caption: 'Leprechaun'),
  (flags: [xsf_6]; pid6: '0icqmood48'; PicName: 'st_custom.candy'; Caption: 'Candy'),
  (flags: [xsf_6]; pid6: '0icqmood56'; PicName: 'st_custom.lollipop'; Caption: 'Lollipop'),
  (flags: [xsf_6]; pid6: '0icqmood69'; PicName: 'st_custom.pizza'; Caption: 'Pizza'),
  (flags: [xsf_6]; pid6: '0icqmood43'; PicName: 'st_custom.icecream'; Caption: 'Ice cream'),
  (flags: [xsf_6]; pid6: '0icqmood65'; PicName: 'st_custom.strawberry'; Caption: 'Strawberry'),
  (flags: [xsf_6]; pid6: '0icqmood54'; PicName: 'st_custom.donut'; Caption: 'Donut'),
  (flags: [xsf_6]; pid6: '0icqmood79'; PicName: 'st_custom.rolls'; Caption: 'Rolls'),
  (flags: [xsf_6]; pid6: '0icqmood76'; PicName: 'st_custom.arrowheart'; Caption: 'Arrow heart'),
  (flags: [xsf_6]; pid6: '0icqmood42'; PicName: 'st_custom.tongue'; Caption: 'Tongue'),
  (flags: [xsf_6]; pid6: '0icqmood60'; PicName: 'st_custom.brokenheart'; Caption: 'Broken heart'),
  (flags: [xsf_6]; pid6: '0icqmood73'; PicName: 'st_custom.ladybug'; Caption: 'Ladybug'),
  (flags: [xsf_6]; pid6: '0icqmood37'; PicName: 'st_custom.dollarsign'; Caption: 'Dollar sign'),
  (flags: [xsf_6]; pid6: '0icqmood81'; PicName: 'st_custom.consolegames'; Caption: 'Console games'),
  (flags: [xsf_6]; pid6: '0icqmood41'; PicName: 'st_custom.moustache'; Caption: 'Moustache'),
  (flags: [xsf_6]; pid6: '0icqmood36'; PicName: 'st_custom.beaglepuss'; Caption: 'Groucho glasses'),
  (flags: [xsf_6]; pid6: '0icqmood67'; PicName: 'st_custom.angel'; Caption: 'Angel'),
  (flags: [xsf_6]; pid6: '0icqmood26'; PicName: 'st_custom.pacifier'; Caption: 'Pacifier'),
  (flags: [xsf_6]; pid6: '0icqmood35'; PicName: 'st_custom.riding'; Caption: 'Riding'),
  (flags: [xsf_6]; pid6: '0icqmood78'; PicName: 'st_custom.balloons'; Caption: 'Balloons'),
  (flags: [xsf_6]; pid6: 'icqmood200'; PicName: 'st_custom.shrimp'; Caption: 'Shrimp'),
  (flags: [xsf_6]; pid6: 'icqmood218'; PicName: 'st_custom.squirrel'; Caption: 'Squirrel'),
  (flags: [xsf_6]; pid6: '0icqmood30'; PicName: 'st_custom.monkey'; Caption: 'Monkey'),
  (flags: [xsf_6]; pid6: '0icqmood57'; PicName: 'st_custom.pig'; Caption: 'Pig'),
  (flags: [xsf_6]; pid6: '0icqmood58'; PicName: 'st_custom.cat'; Caption: 'Cat'),
  (flags: [xsf_6]; pid6: '0icqmood47'; PicName: 'st_custom.dog'; Caption: 'Dog'),
  (flags: [xsf_6]; pid6: '0icqmood51'; PicName: 'st_custom.blackface'; Caption: 'Black face'),
  (flags: [xsf_6]; pid6: '0icqmood44'; PicName: 'st_custom.pinkface'; Caption: 'Pink face'),
  (flags: [xsf_6]; pid6: '0icqmood29'; PicName: 'st_custom.cyclops'; Caption: 'Cyclops'),
  (flags: [xsf_6]; pid6: '0icqmood24'; PicName: 'st_custom.hipster'; Caption: 'Hipster'),
  (flags: [xsf_6]; pid6: '0icqmood25'; PicName: 'st_custom.kissfacepaint'; Caption: 'Kiss'),
  (flags: [xsf_6]; pid6: '0icqmood59'; PicName: 'st_custom.sumo'; Caption: 'Sumo'),

  // Old
  (flags: [xsf_Old]; pidOld: #$f1#$8a#$b5#$2e#$dc#$57#$49#$1d#$99#$dc#$64#$44#$50#$24#$57#$af;
  PicName: 'st_custom.friends'; Caption: 'Friends'),
  (flags: [xsf_Old]; pidOld: #$63#$14#$36#$FF#$3F#$8A#$40#$D0#$A5#$CB#$7B#$66#$E0#$51#$B3#$64;
  PicName: 'st_custom.quest'; Caption: 'Quest'),
  (flags: [xsf_Old]; pidOld: #$B7#$08#$67#$F5#$38#$25#$43#$27#$A1#$FF#$CF#$4C#$C1#$93#$97#$97;
  PicName: 'st_custom.geometry'; Caption: 'Geometry'),
  (flags: [xsf_Old]; pidOld: #$D4#$E2#$B0#$BA#$33#$4E#$4F#$A5#$98#$D0#$11#$7D#$BF#$4D#$3C#$C8;
  PicName: 'st_custom.search'; Caption: 'In search'),
  (flags: [xsf_Old]; pidOld: #$CD#$56#$43#$A2#$C9#$4C#$47#$24#$B5#$2C#$DC#$01#$24#$A1#$D0#$CD; // Not used in new XStatuses
  PicName: 'st_custom.sex'; Caption: 'Sex'),
  (flags: [xsf_Old]; pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$78;
  PicName: 'status.lunch'; Caption: 'Lunch'),
  (flags: [xsf_Old]; pidOld: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$79;
  PicName: 'status.evil'; Caption: 'Evil')

  );

icq_missed_msgs:
array [0 .. 4] of string = ('Message was invalid', 'Message was too large', 'Message rate exceeded',
  'Sender too evil (sender warn level > your max_msgs_evil)',
  'You are too evil (sender max_msg_revil < your warn level)');

function CAPS_sm2big(i: byte): RawByteString; inline;
var
  // ExtStsStrings : array[low(aXStatus)..High(aXStatus),0..1] of string;
  // ExtStsStrings : array[low(XStatus6)..High(XStatus6)] of string;
  // ExtStsStrings : array[low(XStatusArray)..High(XStatusArray)] of string;
  ExtStsStrings: array [Low(XStatusArray) .. High(XStatusArray)] of TXStatStr;
  StatusesArray: TStatusArray;

var
  useFBcontacts: Boolean = False;

type
  TFileAbout = class(TObject)
    fPath: String;
    fName: String;
    Size: Int64;
    Processed: Int64;
    CheckSum: Cardinal;
  end;

const
  ICQServers: array [0 .. 5] of string = ('login.icq.com', 'login.oscar.aol.com',
    'ibucp-vip-d.blue.aol.com', 'ibucp-vip-m.blue.aol.com', 'ibucp2-vip-m.blue.aol.com',
    'bucp-m08.blue.aol.com' { ,
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
      '205.188.252.28' } );

  function AllFieldsAsQuery(Enabled: Boolean = True): String;
  function AllFieldsAsParam: String;

implementation

uses
  SysUtils, RDUtils;

function CAPS_sm2big(i: byte): RawByteString; inline;
begin
  result := CapsMakeBig1 + CapsSmall[i].v + CapsMakeBig2;
end;

function AllFieldsAsQuery(Enabled: Boolean = True): String;
var
  Val: String;
begin
  Val := IfThen(Enabled, '1', '0');
  Result := '&' + String.Join('=' + Val + '&', SupportedPresenceFields) + '=' + Val;
end;

function AllFieldsAsParam: String;
begin
  Result := String.Join(',', SupportedPresenceFields)
end;

end.
