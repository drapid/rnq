{
This file is part of R&Q.
Under same license
}
unit update_fr;
{$I Compilers.inc}
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, RnQSpin, RDGlobal, RnQPrefsLib;

type
  TupdateFr = class(TPrefFrame)
    updateChk: TCheckBox;
    updateGrp: TGroupBox;
    checkSpin: TRnQSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    betaChk: TCheckBox;
    LoginUpdChk: TCheckBox;
    procedure updateChkClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure applyPage; Override;
    procedure resetPage; Override;
    procedure updateVisPage; Override;
    { Public declarations }
  end;

implementation

uses
  globalLib;

{$R *.dfm}

procedure TupdateFr.updateChkClick(Sender: TObject);
begin updateVisPage end;

procedure TupdateFr.applyPage;
begin
  checkupdate.enabled:=updateChk.checked;
  checkupdate.betas:=betaChk.checked;
  checkupdate.every:=round(checkSpin.value);
end;

procedure TupdateFr.resetPage;
begin
  updateGrp.width:= ClientWidth - GAP_SIZE2;
  
  betaChk.checked:=checkupdate.betas;
  updateChk.checked:=checkupdate.enabled or PREVIEWversion;
  checkSpin.value:=checkupdate.every;
end;

procedure TupdateFr.updateVisPage;
begin
  updateGrp.visible:=updateChk.checked;
  LoginUpdChk.Visible := PREVIEWversion;
  updateChk.Enabled := not PREVIEWversion;
end;

end.
