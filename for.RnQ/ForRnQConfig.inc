// Freepascal
{$ifdef FPC}
  {/$MODE DELPHIUNICODE}
  {$define D7UP}
  {$IFNDEF UNICODE}
     {$DEFINE STRING_NOT_UNICODE}
  {$ENDIF}
 {$ELSE ~FPC}
  {$IFNDEF UNICODE}
   {$DEFINE STRING_NOT_UNICODE}
  {$ENDIF}
{$endif FPC}

{ $IFNDEF FPC}
 { $I \VTV\Source\Compilers.inc}
{ $ENDIF}

 {$DEFINE HAS_INLINE}  // Added 20140409

 {$DEFINE HAS_FINAL}

 { $DEFINE RNQ}
 {$DEFINE RNQ_FULL}
 { $DEFINE CHAT_CEF}
 { $DEFINE RNQ_SERVICES}

 { $DEFINE DB_ENABLED}   // Enable SQLite use

 { $DEFINE USE_REGUIN}
 { $DEFINE USE_SECUREIM}

 {$DEFINE NO_WIN98}      //NOT allow use of hooks and some hacks special under Win98
    {$IFDEF UNICODE}
      {$DEFINE NO_WIN98}
    {$ENDIF UNICODE}


 {$IFDEF RNQ2}
   {$DEFINE DB_ENABLED}   // Enable SQLite use
   {$DEFINE PREF_IN_DB}   // Preferences in db
 {$ENDIF RNQ2}


 {$DEFINE NOT_USE_GDIPLUS}

 {$IF Defined(CHAT_CEF) or Defined(CHAT_SCI)}
   {$DEFINE PRESERVE_BIG_FILE}
 {$ELSE old CHAT}

   {$DEFINE SMILES_ANI_ENGINE}
 {$IFEND}

 { $DEFINE LANGDEBUG}
 { $DEFINE RQDEBUG}


 {$DEFINE Use_Baloons}

{$DEFINE USE_ZIP}
 {$IFDEF RNQ}
   {$DEFINE ZIP_AES}
 {$ENDIF RNQ}
{ $DEFINE ZIP_ZSTD}


{$DEFINE USE_SYMCRYPTO}
{$DEFINE USE_MORMOT_COLLECTIONS}

{$IFNDEF FPC}
  {$DEFINE UseNTLMAuthentication}
  {$DEFINE USE_IPv6}      // IPv6
  {$DEFINE USE_SSL}      // SSL
  { $DEFINE USE_7Z}
  {$DEFINE USE_RAR}
 {$IFDEF RNQ}
    {$DEFINE USE_SYMCRYPTO}
 {$ENDIF}
{$ENDIF}


 { $DEFINE RNQ_LITE}
 { $DEFINE RNQ_PLAYER}
 { $DEFINE RNQ_FULL2}

 // { $DEFINE EUREKALOG}
// { $DEFINE EUREKALOG_VER5}


{$IFNDEF FPC}
  {$I Include\OverbyteIcsDefs.inc}

  { $IFDEF DELPHI9_UP}
   {$INLINE AUTO}
   { $INLINE ON}
   {$STRINGCHECKS OFF}
  { $ENDIF DELPHI9_UP}

  { $IFDEF DELPHI16_UP}
  {$O+}
  {$EXCESSPRECISION OFF}
  { $ENDIF DELPHI16_UP}

{$ENDIF}


