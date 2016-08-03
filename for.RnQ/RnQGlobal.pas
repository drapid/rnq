{
This file is part of R&Q.
Under same license
}
unit RnQGlobal;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

 { $ DEFINE RNQ_PLAYER}

interface
uses
  Forms, Classes, Messages, ExtCtrls, Types,
 {$IFDEF RNQ_PLAYER}
  BASSplayer,
 {$ENDIF RNQ_PLAYER}
//  fxRegistryFile,
//  RQThemes,
//  SXZipUtils,
  Graphics;

const
  eventslogFilename='events.log';
  defaultThemePrefix='RQ.';
  defaultThemePostfix='theme.ini';
  // paths
  themesPath= 'themes\';
  pluginsPath= 'plugins\';
  accountsPath= 'Accounts\';
 {$IFDEF CPUX64}
  modulesPath= 'modules.x64\';
 {$ELSE}
  modulesPath= 'modules\';
 {$ENDIF CPUX64}

  maxPICAVTW = 200;
  maxPICAVTH = 200;
  maxSWFAVTW = 100;
  maxSWFAVTH = 100;



var
  timeformat :record chat,info,clock,log,automsg:string; end;
  logpref :record
    pkts, evts :record
      onFile,onWindow,clear:boolean;
      end;
    writehistory :boolean;
   end;


var
  myPath           : String;
  logPath          : String;
  RnQUser          : String;
  RnQMainPath      : String;
//  rqSmiles         : TRQTheme;
  ShowSmileCaption,
  MenuHeightPerm,
  MenuDrawExt,
  bringInfoFrgd,
//  MakeBakups,
 {$IFDEF LANGDEBUG}
  lang_debug,
 {$ENDIF LANGDEBUG}
  disableSounds,
  playSounds,
  showBalloons : Boolean;
  audioPresent     : Boolean = false;
  picDrawFirstLtr  : boolean = false;
  TranslitList     : TStringList;
  SoundVolume      : Integer;
  TextBGColor      : TColor;

var
 {$IFDEF RNQ_PLAYER}
  RnQbPlayer : TBASSplayer;
 {$ELSE RNQ_PLAYER}
  Soundhndl : THandle;
 {$ENDIF RNQ_PLAYER}

implementation
   uses
     Windows, Controls;


end.
