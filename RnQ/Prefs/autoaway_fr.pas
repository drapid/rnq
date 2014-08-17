{
This file is part of R&Q.
Under same license
}
unit autoaway_fr;
{$I Compilers.inc}
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, RnQSpin, RDGlobal, RnQPrefsLib, ExtCtrls, ComCtrls;

type
  TautoawayFr = class(TPrefFrame)
    plBg: TPanel;
    Label26: TLabel;
    Label28: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    setawayChk: TCheckBox;
    awaySpin: TRnQSpinEdit;
    naSpin: TRnQSpinEdit;
    setnaChk: TCheckBox;
    exitawayChk: TCheckBox;
    automsgBox: TMemo;
    setnaSSChk: TCheckBox;
    setNAVolChk: TCheckBox;
    naVolSl: TTrackBar;
    bossnaChk: TCheckBox;
    procedure UpdVis(Sender: TObject);
  private
    { Private declarations }
  public
//    procedure initProps;
    procedure applyPage; Override; final;
    procedure resetPage; Override; final;
    procedure updateVisPage; Override; final;
    { Public declarations }
  end;

implementation

{$R *.dfm}
uses
  globalLib;

procedure TautoawayFr.applyPage;
begin
  autoaway.autoexit := exitawayChk.checked;
  autoaway.away     := setawayChk.checked;
  autoaway.na       := setnaChk.checked;
  autoaway.ss       := setnaSSChk.checked;
  autoaway.boss     := bossnaChk.Checked;
  autoaway.awayTime := round(awaySpin.Value*(10*60));
  autoaway.naTime   := round(naSpin.Value*(10*60));
  autoaway.msg      := automsgBox.text;
  autoaway.setVol   := setNAVolChk.Checked;
  autoaway.vol      := naVolSl.Position;
end;

procedure TautoawayFr.resetPage;
begin
  automsgBox.Width:= plBg.Width - GAP_SIZE - GAP_SIZE;
  automsgBox.left:= GAP_SIZE;;

  exitawayChk.checked:= autoaway.autoexit;
  setawayChk.checked := autoaway.away;
  setnaChk.checked   := autoaway.na;
  setnaSSChk.checked := autoaway.ss;
  bossnaChk.Checked  := autoaway.boss;
  awaySpin.Value     := autoaway.awayTime div (10*60);
  naSpin.Value       := autoaway.naTime div (10*60);
  automsgBox.text    := autoaway.msg;
  setNAVolChk.Checked:= autoaway.setVol;
  naVolSl.Position   := autoaway.vol;
end;

procedure TautoawayFr.UpdVis(Sender: TObject);
begin updateVisPage end;

procedure TautoawayFr.updateVisPage;
begin
  awaySpin.enabled:=setawayChk.checked;
  naSpin.enabled:=setnaChk.checked;
end;

end.
