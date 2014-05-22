// Freepascal
{$ifdef FPC}
  {$MODE DELPHI}
  {$define D7UP}
{$endif FPC}

{$IFNDEF FPC}
 {$I \VTV\Source\Compilers.inc}
{$ENDIF}

 {$DEFINE HAS_INLINE}  // Added 20140409

 { $DEFINE RNQ}
 {$DEFINE RNQ_FULL}

 { $DEFINE USE_REGUIN}
 { $DEFINE USE_SECUREIM}

 {$DEFINE NO_WIN98}      //NOT allow use of hooks and some hacks special under Win98
    {$IFDEF UNICODE}
      {$DEFINE NO_WIN98}
    {$ENDIF UNICODE}


 {$IFDEF RNQ2}
   {$DEFINE DB_ENABLED}   // Enable SQLite use
 {$ENDIF RNQ2}


 {$DEFINE NOT_USE_GDIPLUS}
 {$DEFINE UseNTLMAuthentication}
 {$DEFINE USE_SSL}      // SSL

 { $DEFINE LANGDEBUG}
 { $DEFINE RQDEBUG}


 {$DEFINE Use_Baloons}

{$IFNDEF FPC}

  {$DEFINE USE_ZIP}
   { $DEFINE USE_7Z}
  {$DEFINE USE_RAR}
{$ENDIF}
 { $DEFINE RNQ_LITE}
 { $DEFINE RNQ_PLAYER}
 { $DEFINE RNQ_FULL2}

 // { $DEFINE EUREKALOG}
// { $DEFINE EUREKALOG_VER5}


{$IFNDEF FPC}

  { $IFDEF DELPHI_9_UP}
   { $INLINE AUTO}
   {$INLINE ON}
   {$STRINGCHECKS OFF}
  { $ENDIF DELPHI_9_UP}

  { $IFDEF DELPHI_16_UP}
  {$O+}
  {$EXCESSPRECISION OFF}
  { $ENDIF DELPHI_16_UP}


  { $WEAKLINKRTTI ON}
  { $RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF}
