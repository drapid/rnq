{
This file is part of R&Q.
Under same license
}
unit RnQMenu;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   Classes, Menus, RDGlobal, RQMenuItem;

type
//  TMenuEvent = procedure(mi: TRQMenuItem);

  TaMenuItem = record
   amiIdx     : Integer;
   amiName    : String;
   amiCaption : String;
   amiHint    : String;
   amiImage   : TPicName;
   amiEv      : TNotifyEvent;
   amiUpd     : TNotifyEvent;
   amiTag     : Integer;
  end;
  aTaMenuItem = array of TaMenuItem;

type
  TaMenuItemUpd = record
   amiuMenu    : TRQMenuItem;
   amiuEv      : TNotifyEvent;
  end;
  aTaMenuItemUpd = array of TaMenuItemUpd;


  function AddToMenu(ppi : TMenuItem; const Cptn : String; ImName : TPicName;
      isDef : Boolean; Ev : TNotifyEvent=nil; Translate : Boolean = True) : TRQMenuItem; overload;

  function AddToMenu(const namePrefix : String;
                     ami : TaMenuItem; ppi : TMenuItem;
                     var updArr : aTaMenuItemUpd;
                     idx : Integer = -1) : TRQMenuItem; overload;


  procedure clearMenu(root:Tmenuitem);
  procedure clearAMI(var pAMI : TaMenuItem);


  procedure createMenuAs(ami : aTaMenuItem; var ppm : TPopupMenu; Own : TComponent);

  procedure addToMenuMass(var mass : aTaMenuItem; idx : Integer; const name : String;
              const Cptn, Hint : String;
              const ImName : TPicName; Ev, Upd : TNotifyEvent);

  procedure ClearMenuMass(var mass : aTaMenuItem);

implementation  uses
    SysUtils,
    RnQLangs, RQUtil;

var
  aMainMenu : aTaMenuItem;
  aStsMenu : aTaMenuItem;
  aVisMenu : aTaMenuItem;

//const
//  aMainMenu: array[0..1] of TaMenuItem =
//        ((amiName: 'About'; Ev: TmainFrm.About1Click),
//        ( ID: 2; Value: 'Male'));

procedure ClearMenuMass(var mass : aTaMenuItem);
var
  i : Byte;
begin
  if Length(mass) > 0 then
  begin
    for I := 0 to Length(mass) - 1 do
    with mass[i] do
      begin
        amiName := '';
        amiCaption := '';
        amiImage := '';
        amiEv := NIL;
        amiUpd := NIL;
      end;
    SetLength(mass, 0);
  end;
end;

procedure addToMenuMass(var mass : aTaMenuItem; idx : Integer; const name : String;
              const Cptn, Hint : String;
              const ImName : TPicName; Ev, Upd : TNotifyEvent);
var
  i : Byte;
begin
  i := length(mass);
  SetLength(mass, i+1);
  with mass[i] do
    begin
      amiIdx  := idx;
      amiName := name;
      amiCaption := Cptn;
      amiImage := imName;
      amiEv := ev;
      amiUpd := Upd;
    end;
end;

function AddToMenu(const namePrefix : String;
                   ami : TaMenuItem; ppi : TMenuItem;
                   var updArr : aTaMenuItemUpd;
                   idx : Integer = -1) : TRQMenuItem; overload;
var
  k : Integer;
begin
  result := TRQMenuItem.Create(ppi);
  result.Name      := namePrefix + ami.amiName;
  result.Caption   := ami.amiCaption;
  result.Hint      := ami.amiHint;
  result.ImageName := ami.amiImage;
  result.OnClick   := ami.amiEv;
  result.Tag       := ami.amiTag;
  if (idx <0) or (idx >= ppi.Count) then
    ppi.Add(Result)
   else
    ppi.Insert(idx, Result);
//  if Assigned(ami.amiUpd) and (Assigned(updArr)) then
  if Assigned(ami.amiUpd) then
     begin
      k := length(updArr);
      SetLength(updArr, k+1);
      updArr[k].amiuMenu := Result;
      updArr[k].amiuEv   := ami.amiUpd;
     end;
end;

function AddToMenu(ppi : TMenuItem; const Cptn : String; ImName : TPicName;
      isDef : Boolean; Ev : TNotifyEvent = nil; Translate : Boolean = True) : TRQMenuItem;
begin
  result := TRQMenuItem.Create(ppi);
//  result.Name := ;
  if Translate then
    result.Caption := getTranslation(Cptn)
   else
    result.Caption := Cptn;
  result.ImageName := ImName;
  result.OnClick := Ev;
  ppi.Add(result);
end;

procedure createMenuAs(ami : aTaMenuItem; var ppm : TPopupMenu; Own : TComponent);
var
  i : Integer;
//  , k
//  mi : TRQMenuItem;
  updArr : aTaMenuItemUpd;
begin
  ppm := TPopupMenu.Create(Own);
  for i := 0 to Length(ami) - 1 do
    begin
      AddToMenu('', ami[i], ppm.Items, updArr);
    end;
  SetLength(updArr, 0);
end;

procedure clearMenu(root:Tmenuitem);
var
  i:integer;
begin
  if not Assigned(root) then Exit;
  
i:=root.count-1;
while i >= 0 do
  begin
  clearmenu(root.Items[i]);
  root.Items[i].Free;
//  root.Delete(i);
  dec(i);
  end;
end; // clearMenu

procedure clearAMI(var pAMI : TaMenuItem);
begin
  pAMI.amiIdx     := 0;
  pAMI.amiName    := '';
  pAMI.amiCaption := '';
  pAMI.amiHint    := '';
  pAMI.amiImage   := '';
  pAMI.amiEv      := NIL;
  pAMI.amiUpd     := NIL;
  pAMI.amiTag     := 0;
end;

end.

