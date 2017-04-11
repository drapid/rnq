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
              WL_sent_text, WL_rcvd_text);

const
  LogWhatNames: array [TwhatLog] of string=('CONNECTED', 'DISCONNECTED',
                                            'CLIENT', 'SERVER', 'DC RCVD', 'DC SENT',
                                            'CONNECTING', 'CLIENT', 'SERVER');
  LogPics: array[TwhatLog] of TPicName = (PIC_CONNECTING, PIC_OFFGOING,
            PIC_LEFT, PIC_RIGHT,
            PIC_RIGHT, PIC_LEFT, PIC_CONNECTING,
            PIC_LEFT, PIC_RIGHT );


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
begin
  needHash := not (what in [WL_sent_text, WL_rcvd_text]);
  if needHash then
    begin
      sA := data;
      sU := '';
    end
   else
    begin
      sA := '';
      sU := String(data);
    end;

  if (logpref.pkts.onwindow) then
    logEvPkt(head, sU, sA, LogPics[what], needHash);

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
