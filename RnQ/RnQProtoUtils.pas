{
  This file is part of R&Q.
  Under same license
}
unit RnQProtoUtils;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
uses
  RDGlobal, RnQPics;

type
  TwhatLog = (WL_connected, WL_disconnected,
              WL_serverGot, WL_serverSent,
              WL_heSent, WL_meSent, WL_connecting,
              WL_sent_text, WL_rcvd_text,
              WL_sent_text8, WL_rcvd_text8, // Data in UTF8
              WL_sent_json8, WL_rcvd_json8, // JSON in UTF8
              WL_sent_xml8, WL_rcvd_xml8 // XML in UTF8
            );

const
  LogWhatNames: array [TwhatLog] of string=('CONNECTED', 'DISCONNECTED',
                                            'CLIENT', 'SERVER', 'DC RCVD', 'DC SENT',
                                            'CONNECTING', 'CLIENT', 'SERVER',
                                            'CLIENT', 'SERVER',
                                            'CLIENT', 'SERVER',
                                            'CLIENT', 'SERVER'
                                            );
  LogPics: array[TwhatLog] of TPicName = (PIC_CONNECTING, PIC_OFFGOING,
            PIC_LEFT, PIC_RIGHT,
            PIC_RIGHT, PIC_LEFT, PIC_CONNECTING,
            PIC_LEFT, PIC_RIGHT,
            PIC_LEFT, PIC_RIGHT,
            PIC_LEFT, PIC_RIGHT,
            PIC_LEFT, PIC_RIGHT
             );


procedure logProtoPkt(what: TwhatLog; const head: String; const data: RawByteString='');
procedure FlushLogPktFile;


implementation
uses
  RQLog, RnQGlobal, RDUtils, RDFileUtil, RnQFileUtil,
  rnqConst, globalLib;

var
  logPktFileData: RawByteString;


procedure logProtoPkt(what: TwhatLog; const head: String; const data: RawByteString='');
var
  sA: RawByteString;
  sU: String;
  needHash: Boolean;
  pt: TPktType;
begin
  needHash := not (what in [WL_sent_text, WL_rcvd_text,
                            WL_sent_text8, WL_rcvd_text8,
                            WL_sent_json8, WL_rcvd_json8,
                            WL_sent_xml8, WL_rcvd_xml8
                            ]);
  if needHash then
    begin
      sA := data;
      sU := '';
      pt := ptBin;
    end
   else
    begin
//      sA := '';
      if what in [WL_sent_text8, WL_rcvd_text8] then
        begin
//          sU := UTF8Decode(data);
          sA := data;
          pt := ptUTF8;
        end
       else
      if what in [WL_sent_json8, WL_rcvd_json8] then
        begin
          sA := data;
          pt := ptJSON;
        end
       else
      if what in [WL_sent_xml8, WL_rcvd_xml8] then
        begin
          sA := data;
          pt := ptXML;
        end
       else
        begin
//          sU := String(data);
          sA := data;
          pt := ptString;
        end;
    end;

  if (logpref.pkts.onwindow) then
    logEvPkt(head, sU, sA, LogPics[what], pt);

  if logpref.pkts.onfile then
   begin
    if needHash then
      sA := hexDump(data)
     else
      sA := data;
    logPktFileData := logPktFileData + AnsiString(head)+CRLF+ sA +CRLF;
   end;
end;

procedure FlushLogPktFile;
begin
  if Length(logPktFileData) > 0 then
   if
   appendFile(logPath+packetslogFilename, logPktFileData)
      or (Length(logPktFileData) > MByte) then
    logPktFileData := '';
end;



end.
