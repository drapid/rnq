
 {$I ForRnQConfig.inc}

 {$DEFINE RNQ}
 {$DEFINE RNQ_FULL}
 { $DEFINE RNQ_FULL2} // For History Recoding

// defined in ForRnQConfig.inc { $DEFINE CHAT_CEF} // Chromium

   {$IFNDEF CHAT_SCI}
   {$IFNDEF CHAT_CEF}
     {$DEFINE CHAT_USE_LSB}
   {$ENDIF ~CHAT_CEF}
   {$ENDIF ~CHAT_SCI}

 { $DEFINE USE_REGUIN}
 { $DEFINE USE_SECUREIM}

 { $DEFINE USE_SMILE_MENU} // allow use menu but not only panel

 {$DEFINE ICQ_ONLY} // Use only ICQ!

 {$IFDEF ICQ_ONLY}
   {$DEFINE PROTOCOL_ICQ} // OSCAR protocol
   {$UNDEF UID_IS_UNICODE}
 {$ELSE ~ICQ_ONLY}
   {$DEFINE UID_IS_UNICODE}
   { $DEFINE PROTOCOL_ICQ} // OSCAR protocol
   { $DEFINE PROTOCOL_MRA} // Mail.ru Agent protocol
   {$DEFINE PROTOCOL_XMP} // XMPP
//   {$DEFINE PROTOCOL_BIM} // Obimp protocol
 {$ENDIF ~ICQ_ONLY}


////////////// For ICQ ------->
 {$IFDEF PROTOCOL_ICQ}
   { $DEFINE usesRSA}
   {$DEFINE usesECC}
  { $DEFINE UseNotSSI}
   {$DEFINE ICQ_OLD_STATUS}
   {$DEFINE usesDC} // Enable File-transfer
   {$DEFINE CHECK_INVIS}
 {$ENDIF PROTOCOL_ICQ}
////////////////// <-------

 {$DEFINE RNQ_AVATARS}
 { $DEFINE AVATARS_DEBUG} // Show packets of avatar session


 { $DEFINE RNQ_FULL2}

 // { $DEFINE EUREKALOG}
// { $DEFINE EUREKALOG_VER5}

