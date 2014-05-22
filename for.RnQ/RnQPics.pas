{
This file is part of R&Q.
Under same license
}
unit RnQPics;
{$I RnQConfig.inc}


{$WRITEABLECONST OFF} // Read-only typed constants

{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}

interface

uses
  RDGlobal,
//  RQMenuItem, Menus, 
//  RQThemes,
  RnQFileUtil;

const
  PIC_STATUS_UNK                  = TPicName('status.unk');//01;
  PIC_STATUS_ONLINE               = TPicName('status.online');//02;
{  PIC_STATUS_OCCUPIED             ='status.occupied';//03;
  PIC_STATUS_DND                  ='status.dnd';//04;
  PIC_STATUS_NA                   ='status.na';//05;
  PIC_STATUS_AWAY                 ='status.away';//06;
  PIC_STATUS_F4C                  ='status.f4c';//07;
  PIC_STATUS_OFFLINE              ='status.offline';//08;
  PIC_STATUS_EVIL                 ='status.evil';//;
  PIC_STATUS_DEPRESS              ='status.depression';//
}
//  PIC_INVISIBLE_STATUS_ONLINE     ='invisible.status.online'; //10
//  PIC_INVISIBLE_STATUS_OCCUPIED   ='invisible.status.occupied'; //11;
//  PIC_INVISIBLE_STATUS_DND        ='invisible.status.dnd';  //12;
//  PIC_INVISIBLE_STATUS_NA         ='invisible.status.na';   //13;
//  PIC_INVISIBLE_STATUS_AWAY       ='invisible.status.away'; //14;
//  PIC_INVISIBLE_STATUS_F4C        ='invisible.status.f4c';  //15;
//  PIC_INVISIBLE_STATUS_OFFLINE    ='invisible.status.offline';  //16;
  PIC_CONNECTING                  = TPicName('connecting');//09;
//  PIC_INVISIBLE_CONNECTING        ='invisible.connecting';//17;
  PIC_RENAME                      = TPicName('rename');//18;
  PIC_RSTR_BG                     = TPicName('roaster.bg');
  PIC_QUIT                        = TPicName('quit');//19;
  PIC_MINIMIZE                    = TPicName('minimize');//20;
  PIC_RESTORE                     = TPicName('restore');//21;
  PIC_HELP                        = TPicName('help');
  PIC_HIDE                        = TPicName('hide');
  PIC_DELETE                      = TPicName('delete');//22;
  PIC_KEY                         = TPicName('key');//23;
  PIC_ADD_CONTACT                 = TPicName('add.contact');//24;
  PIC_INFO                        = TPicName('info');//25;
  PIC_SEARCH                      = TPicName('search');//26;
//  PIC_1_MSG                       ='1.msg';//27;
//  PIC_QUOTE                       ='quote';//28;
//  PIC_SMILES                      ='smiles';//29;
  PIC_PREFERENCES                 = TPicName('preferences');//30;
  PIC_USERS                       = TPicName('users');//31;
  PIC_WP                          = TPicName('wp');//32;
  PIC_UIN                         = TPicName('uin');//33;
  PIC_OFFGOING                    = TPicName('offgoing');//34;
  PIC_MAIL                        = TPicName('mail');//35;
  PIC_CONTACTS                    = TPicName('contacts');//36;
  PIC_MSG                         = TPicName('msg');//37;
  PIC_MSG_OK                       = TPicName('msgok');
  PIC_MSG_BAD                      = TPicName('msgbad');
  PIC_MSG_SERVER                   = TPicName('msgserver');
  PIC_AUTH_REQ                    = TPicName('auth.req');//38;
  PIC_AUTH_NEED                   = TPicName('auth.need');
  PIC_OTHER_EVENT                 = TPicName('other.event');//39;
  PIC_ONCOMING                    = TPicName('oncoming');//40;
  PIC_URL                         = TPicName('url');//41;
  PIC_FILE                        = TPicName('file');//42;
  PIC_GCARD                       = TPicName('gcard');//43;
  PIC_NEW_GROUP                   = TPicName('new.group');//44;
  PIC_OPEN_GROUP                  = TPicName('open.group');//45;
  PIC_CLOSE_GROUP                 = TPicName('close.group');//46;
  PIC_OUT_OF_GROUPS               = TPicName('out.of.groups');//47;
  PIC_SAVE                        = TPicName('save');//48;
  PIC_OUTBOX                      = TPicName('outbox');//49;
  PIC_OUTBOX_EMPTY                = TPicName('outbox.empty');//50;
//  PIC_HISTORY                     ='history';//51;
//  PIC_UNCHECKED                   ='unchecked';//52;
//  PIC_CHECKED                     ='checked';//53;
  PIC_CHECK_UN : array[boolean] of TPicName  = ('unchecked', 'checked');
//  PIC_RATMAN                      ='ratman';//54;
  PIC_SPECIAL                     = TPicName('special');//55;
//  PIC_EYE                         ='eye';//56;
  PIC_DOWN                        = TPicName('down');//57;
  PIC_UP                          = TPicName('up');//58;
  PIC_RIGHT                       = TPicName('right');//59;
  PIC_LEFT                        = TPicName('left');//60;
  PIC_VISIBILITY                  = TPicName('visibility');//61;

  PIC_VISIBILITY_NONE             = TPicName('visibility.none');//62;
  PIC_VISIBILITY_PRIVACY          = TPicName('visibility.privacy');//63;
  PIC_VISIBILITY_NORMAL           = TPicName('visibility.normal');//64;
  PIC_VISIBILITY_ALL              = TPicName('visibility.all');//65;
  PIC_VISIBILITY_CL               = TPicName('visibility.cl');
  INVIS_PREFIX                    = TPicName('invisible.');
  PIC_VISIBLE_TO                  = TPicName('visible.to');//66;
  PIC_SMS                         = TPicName('sms');//67;
//  PIC_MENUBAR                     ='menubar';//68;
//  PIC_WALLPAPER                   ='wallpaper';//69;
  PIC_LOAD_NET                    = TPicName('load.net');//70;
  PIC_SAVE_NET                    = TPicName('save.net');//71;
  PIC_SCROLL_UP                   = TPicName('scroll.up');//72;
  PIC_SCROLL_DOWN                 = TPicName('scroll.down');//73;
  PIC_ADDEDYOU                    = TPicName('addedyou');//74;
  PIC_SPLASH                      = TPicName('splash');//75;
  PIC_DB                          = TPicName('db');//76;
  PIC_REFRESH                     = TPicName('refresh');//77;
  PIC_DOWNLOAD                    = TPicName('download');//78;
  PIC_SUPPORT                     = TPicName('support');//79;
//  PIC_THEME                       = 'theme';
//  PIC_THEMECUR                    = 'theme.current';
//  PIC_CURRENT                     = 'current';
  PIC_TYPING                      = TPicName('typing');
  PIC_RNQ                         = TPicName('rnq');
  PIC_PLAYER                      = TPicName('player');
  PIC_CHAT_BG                     = TPicName('chat.bg');
  PIC_CLOSE                       = TPicName('close');
  PIC_LOCAL                       = TPicName('contact.local');
//  PIC_LAST                        =80;

  PIC_BIRTH                       = TPicName('birth');
  PIC_BIRTH1                      = TPicName('birth1');
  PIC_BIRTH2                      = TPicName('birth2');

const
  PIC_CLI_MAGENT                  = TPicName('magent');
  PIC_CLI_QIP                     = TPicName('qip');
  PIC_CLI_RNQ                     = TPicName('rnq');
  PIC_CLI_NRQ                     = TPicName('andrq');
  PIC_CLI_smaper                  = TPicName('smaper');
  PIC_CLI_pigeon                  = TPicName('pigeon');
  PIC_CLI_SIM                     = TPicName('sim');


implementation

end.

