unit RnQxml;
  // By Rapid D

interface

uses
  Windows, Messages, SysUtils, Classes,
//  Graphics, Controls, Forms,
//  Dialogs, StdCtrls,
  NativeXML;


type
  TRnQXml = class(TNativeXml)
   private
//    openedNodeName: String;
    openedNodeName: UTF8String;
    openedNodeCount: Integer;
    FUnxpEOFErr: Boolean;
    FUnxpEOFPos: Int64;
//    pos: Int64;
    procedure NodeNewEvent(Sender: TObject; ANode: TXmlNode);
    procedure NodeClsEvent(Sender: TObject; ANode: TXmlNode);
    procedure UnxpEOF(Sender: TObject; const Pos: Int64);
   public
    function LoadNodeFromStream(AStream: TStream) : Int64; overload;
    function LoadNodeFromStream(AStream: TStream; var xPos: Int64): Byte; overload;
    function WriteToRaw: RawByteString; virtual;
    property UnxpEOFPos: Int64 read FUnxpEOFPos;
  end;


implementation
//uses
//  sdStreams;

procedure TRnQXml.NodeClsEvent(Sender: TObject; ANode: TXmlNode);
begin
// For declaration just skip
  if ANode.ElementType = xeDeclaration then
    Exit;

  if openedNodeName = ANode.Name then
    Dec(openedNodeCount);
  if openedNodeCount = 0 then
   begin
    ANode.Document.AbortParsing := True;
   end;

end;
procedure TRnQXml.NodeNewEvent(Sender: TObject; ANode: TXmlNode);
begin
// For declaration just skip
  if ANode.ElementType = xeDeclaration then
    Exit;


  if openedNodeName > '' then
    begin
       if openedNodeName = ANode.Name then
        inc(openedNodeCount);
    end
   else
    if (ANode.Name <> 'stream:stream')AND (ANode.ElementType <> xeCharData) then
    begin
     openedNodeName := ANode.Name;
     openedNodeCount := 1;
    end;
end;

procedure TRnQXml.UnxpEOF(Sender: TObject; const Pos: Int64);
begin
  FUnxpEOFErr := True;
  FUnxpEOFPos := Pos;
end;

function TRnQXml.LoadNodeFromStream(AStream: TStream; var xPos : Int64) : Byte;
var
  Parser: TsdXmlParser;
begin
  FSymbolTable.Clear;
  FRootNodes.Clear;

   OnNodeNew    := NodeNewEvent;
   OnNodeLoaded := NodeClsEvent;
   openedNodeName  := '';
   openedNodeCount := 0;
   FUnxpEOFErr := false;
   FUnxpEOFPos := 0;

  Parser := TsdXmlParser.Create(AStream, cParserChunkSize);
  try
    Parser.Owner := Self;

    Parser.OnUnexpectedEOF := UnxpEOF;

    // parse the stream
    ParseStream(Parser);
    xPos := Parser.Position;
    if FUnxpEOFErr then
      begin
       if openedNodeName > '' then
         Result := 1
        else
         Result := 0;
      end
     else
      if openedNodeCount = 0 then
        if openedNodeName > '' then
          Result := 2
         else
          Result := 0
       else
        Result := 1;

    // copy encoding data from the parser
    FExternalEncoding := Parser.Encoding;
    FExternalCodePage := Parser.CodePage;
    FExternalBomInfo  := Parser.BomInfo;

    // final onprogress
    DoProgress(AStream.Size);
  finally
    FreeAndNil(Parser);
  end;
end;

function TRnQXml.LoadNodeFromStream(AStream: TStream) : Int64;
var
  Parser: TsdXmlParser;
begin
  FSymbolTable.Clear;
  FRootNodes.Clear;

   OnNodeNew    := NodeNewEvent;
   OnNodeLoaded := NodeClsEvent;
   openedNodeName  := '';
   openedNodeCount := 0;
   FUnxpEOFErr := false;
   FUnxpEOFPos := 0;

  Parser := TsdXmlParser.Create(AStream, cParserChunkSize);
  try
    Parser.Owner := Self;

    Parser.OnUnexpectedEOF := UnxpEOF;

    // parse the stream
    ParseStream(Parser);
    result := Parser.Position;

    // copy encoding data from the parser
    FExternalEncoding := Parser.Encoding;
    FExternalCodePage := Parser.CodePage;
    FExternalBomInfo  := Parser.BomInfo;

    // final onprogress
    DoProgress(AStream.Size);
  finally
    FreeAndNil(Parser);
  end;
end;

function TRnQXml.WriteToRaw: RawByteString;
var
  S: TsdFastMemStream;
  res : RawByteString;
begin
  Result := '';
  S := TsdFastMemStream.Create;
  try
    SaveToStream(S);
    SetLength(res, S.Size);
    if Length(res) > 0 then
      CopyMemory(@res[1], s.Memory, Length(res));
    Result := res;
  finally
    S.Free;
  end;
end;

end.