unit RnQPrefsTypes;

interface
uses
   Windows, Forms, Classes, iniFiles,
   RDGlobal, RnQPrefsInt;

type
  TPrefFrame = class(TFrame)
   public
    FOldCreateOrder: Boolean;
    FPixelsPerInch: Integer;
    FTextHeight: Integer;
    fAccIDX: Integer;
    lPrefs: IRnQPref;
    procedure applyPage; virtual; abstract;
    procedure resetPage; virtual; abstract;
    procedure updateVisPage; virtual;
    procedure initPage(prefs: IRnQPref); virtual;
    procedure unInitPage; virtual;
    function  getPrefForm: TForm;
   published
    property ParentFont default True;
    property TabOrder;
    property TabStop;
    property OldCreateOrder: Boolean read FOldCreateOrder write FOldCreateOrder;
    property PixelsPerInch: Integer read FPixelsPerInch write FPixelsPerInch stored False;
    property TextHeight: Integer read FTextHeight write FTextHeight;
//    property prefs: TRnQPref read lPrefs^;
//    property OldCreateOrder;
//    property PixelsPerInch;
//    property TextHeight;
    property ClientHeight;
    property ClientWidth;
  end;

  TPrefFrameClass = class of TPrefFrame;

  PPrefPage = ^TPrefPage;
  TPrefPage = class
   public
    idx: byte;
    frame: TPrefFrame;
    frameClass: TPrefFrameClass;
    GroupName: String;
    Name,
    Caption: string;
    fProtoIDX: Integer;
   public
     destructor Destroy; override;
     function Clone: TPrefPage;
  end;
  TPrefPagesArr = array of TPrefPage;

type
  TPortElement =  Class(TObject) //record
   public
    Count: Integer;
    lPort, rPort: Integer;
  end;

  TPortList = class(TStringList)
    public
     PortsCount: Integer;
     procedure AddPorts(pLPort: Integer; pRPort: Integer = 0);
     procedure parseString(const s: String);
     function getString: String;
     function getRandomPort: Integer;
  end;

implementation

uses
   SysUtils, Character, ExtCtrls, StdCtrls, Controls, Types,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
   RDUtils;

function TPrefFrame.getPrefForm: TForm;
var
  p: TWinControl;
begin
  if Self = NIL then
   Exit(NIL);
  p := Self.Parent;
  while p <> NIL do
   begin
    if p is TForm then
      Exit(p as TForm);
    p := p.Parent;
   end;
end;

procedure TPrefFrame.updateVisPage;
begin
end;

procedure TPrefFrame.initPage(prefs: IRnQPref);
begin
  lPrefs := prefs;
end;

procedure TPrefFrame.unInitPage;
begin
end;



destructor TPrefPage.Destroy;
begin
  SetLength(Self.Name, 0);
  SetLength(Self.Caption, 0);
end;

function TPrefPage.Clone: TPrefPage;
begin
  Result := TPrefPage.Create;
  Result.idx := Self.idx;
  Result.frame := Self.frame;
  Result.frameClass := Self.frameClass;
  Result.Name := Self.Name;
  Result.Caption := Self.Caption;
  Result.GroupName := Self.GroupName;
end;


procedure TPortList.AddPorts(pLPort: Integer; pRPort: Integer = 0);
var
  pe: TPortElement;
begin
  pe := TPortElement.Create;
  pe.Count := 1;
  pe.lPort := 0;
  pe.rPort := 0;
  if (pLPort > 0) and (pRPort > 0) then
    begin
      pe.Count := pRPort - pLPort + 1;
      pe.lPort := pLPort;
      pe.rPort := pRPort;
    end
   else
    if (pLPort > 0) then
      pe.lPort := pLPort
     else
      if (pRPort > 0) then
        pe.lPort := pRPort
       else
        pe.Count := 0;

  Inc(PortsCount, pe.Count);
  if pe.Count = 0 then
    pe.Free
   else
    begin
      AddObject(Format('%5.5d', [pe.lPort]), pe);
    end;
end;

function TPortList.getRandomPort: Integer;
var
  r, i, a, p: Integer;
begin
  p := 0;
  if PortsCount > 0 then
   begin
     r := Random(PortsCount);
     for I := 0 to Count do
       begin
         a := TPortElement(Objects[i]).Count;
         if a > r then
           begin
             p := TPortElement(Objects[i]).lPort + r;
             Break;
           end
          else
           dec(r, a);
       end;
   end;
  Result := p;
end;

function TPortList.getString: String;
var
  I: Integer;
  pe: TPortElement;
  res: String;
  s: String;
begin
  res := '';
  for I := 1 to Self.Count do
   begin
    pe := TPortElement(self.Objects[i-1]);
    s := IntToStr( pe.lPort );
    if pe.rPort > 0 then
      s := s + '-' + IntToStr( pe.rPort );
    if i > 1 then
      res := res + ', ' + s
     else
      res := res + s;
   end;
  Result := res;

end;

procedure TPortList.parseString(const s: String);
type
  TLastState = (LS_numberL, LS_numberR, LS_delimiter, LS_hyphen, LS_end);
var
  st, ost: tlastState;
  I: Integer;
  ch: Char;
  lastNum: String;
  lastPort, rPort: Integer;
begin
  Clear;
  PortsCount := 0;
  st := LS_numberL;
  ost := LS_delimiter;
  lastNum := '';
  lastPort := 0;
  for I := 1 to Length(s)+1 do
    begin
      if I <= Length(s) then
        begin
          ch := s[i];
          if ch.IsDigit then
              st := LS_numberL
           else
            if ch = '-' then
              st := LS_hyphen
             else
              st := LS_delimiter;
        end
       else
        begin
          ch := #0;
          st := LS_end;
        end;
      case st of
        LS_numberL:
            case ost of
              LS_numberL: lastNum := lastNum + ch;
              LS_numberR:
                  begin
                    lastNum := lastNum + ch;
                    st := LS_numberR;
                  end;
              LS_delimiter:
                  begin
                    if lastPort >0 then
                      AddPorts(lastPort);
                    lastPort := 0;
                    lastNum := ch;
                  end;
              LS_hyphen:
                  begin
                    lastNum := lastNum + ch;
                    st := LS_numberR;
                  end;
            end;
        LS_numberR:
             // Can't be here
             ;
        LS_delimiter:
            case ost of
              LS_numberL:
                begin
                  lastPort :=  StrToIntDef(lastNum, 0);
                  lastNum := '';
                end;
              LS_numberR:
                begin
                  rPort := StrToIntDef(lastNum, 0);
                  lastNum := '';
                  if rPort > 0 then
                    AddPorts(lastPort, rPort)
                   else
                    AddPorts(lastPort);
                  st := LS_numberL;
                end;
              LS_delimiter: ;
              LS_hyphen: st := LS_hyphen;
            end;
        LS_hyphen:
            case ost of
              LS_numberL:
                begin
                  lastPort := StrToIntDef(lastNum, 0);
                  lastNum := '';
                  if lastPort > 0 then
                    st := LS_numberR
                   else
                    st := LS_numberL;
                end;
              LS_numberR:
                begin
                  rPort := StrToIntDef(lastNum, 0);
                  lastNum := '';
                  if rPort > 0 then
                    begin
                      AddPorts(lastPort, rPort);
                      st := LS_numberL;
                    end
                   else
                    //Add(IntToStr(lastPort))
                     ;
                end;
              LS_delimiter:
                begin
                  if lastPort > 0 then
                    st := LS_numberR
                   else
                    st := LS_numberL;
                end;
              LS_hyphen: ;
            end;
        LS_end:
            case ost of
              LS_numberL:
                begin
                  lastPort := StrToIntDef(lastNum, 0);
                  lastNum := '';
                  if lastPort > 0 then
                    AddPorts(lastPort);
                end;
              LS_numberR:
                begin
                  rPort := StrToIntDef(lastNum, 0);
                  lastNum := '';
                  if rPort > 0 then
                    AddPorts(lastPort, rPort)
                   else
                    AddPorts(lastPort);
                end;
              LS_delimiter, LS_hyphen:
                begin
                  if lastPort > 0 then
                    AddPorts(lastPort);
                end;
            end;
      end;
      ost := st;
    end;
  Sort;
end;


end.
