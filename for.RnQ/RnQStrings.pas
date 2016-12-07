{
This file is part of R&Q.
Under same license
}
unit RnQStrings;

{ $MODE Delphi}

{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface
   uses
     RDGlobal;
const
   Str_message = 'Message';
   Str_roster = 'roaster';
   Str_unk     = 'Unknown';
   Str_Error   = 'Error';
   Str_already_run = 'There is another instance with this user already running';
   Str_unsupported = 'This function is not supported yet'+CRLF + 'Please inform us if you need it!';
//   Str_authRequest = 'Authorization Request\nPlease authorize my request and add me to your Contact List.';
   Str_authRequest = 'Please authorize my request and add me to your Contact List.';
//   not2Translate: array[0..2] of string = ('R&Q', 'http://RnQ.ru', 'Rapid D');
   not2Translate: array[0..4] of AnsiString = ('R&Q', 'http://RnQ.ru',
     'Massimo Melina', 'Rapid D', 'R&&Q Team');
   not2TranslateSite = 1;
implementation

end.
