{
This file is part of R&Q.
Under same license
}
unit other_fr;
{$I Compilers.inc}
{$I RnQConfig.inc}

 {$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
 {$ENDIF COMPILER_14_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ExtCtrls, RnQButtons, RnQSpin,
  RDGlobal, RnQPrefsLib;

type
  TotherFr = class(TPrefFrame)
    PageCtrl: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label8: TLabel;
    quitChk: TCheckBox;
    minimizeroasterChk: TCheckBox;
    inactivehideSpin: TRnQSpinEdit;
    inactivehideChk: TCheckBox;
    fixwindowsChk: TCheckBox;
    wheel: TRnQSpinEdit;
    oncomingDlgChk: TCheckBox;
    switchklChk: TCheckBox;
    GroupBox1: TGroupBox;
    fnBoxButton: TRnQSpeedButton;
    defaultbrowserChk: TRadioButton;
    custombrowserChk: TRadioButton;
    fnBox: TEdit;
    plBg: TPanel;
    NILdoGrp: TRadioGroup;
    RcvPathEdit: TLabeledEdit;
    PathInfoBtn: TRnQSpeedButton;
    ChkPathBtn: TRnQSpeedButton;
    procedure FrameResize(Sender: TObject);
    procedure inactivehideChkClick(Sender: TObject);
    procedure custombrowserChkClick(Sender: TObject);
    procedure fnBoxButtonClick(Sender: TObject);
    procedure PathInfoBtnClick(Sender: TObject);
    procedure ChkPathBtnClick(Sender: TObject);
   public
    procedure initPage; Override;
    procedure applyPage; Override;
    procedure resetPage; Override;
    procedure updateVisPage; Override;

  end;

implementation

{$R *.dfm}

uses
  globalLib, utilLib, langLib, mainDlg,
  RnQDialogs, RnQLangs, RDUtils, RnQGlobal;

procedure TotherFr.inactivehideChkClick(Sender: TObject);
begin updateVisPage end;

procedure TotherFr.custombrowserChkClick(Sender: TObject);
begin
  fnBox.Enabled := custombrowserChk.checked;
  fnBoxButton.Enabled := fnBox.Enabled
end;

procedure TotherFr.fnBoxButtonClick(Sender: TObject);
var
  fn : String;
begin
  fn := openSaveDlg(TForm(parent), '', True, 'exe', 'Exe file (*.exe)', fnBox.Text);
  if fn > '' then
    fnBox.Text := FN;
end;

procedure TotherFr.initPage;
begin
  fnBoxButton.Left := fnBox.Left + fnBox.Width + 2;
end;

procedure TotherFr.PathInfoBtnClick(Sender: TObject);
const
  help = 'You can use this templates:\n%userpath%\n%rnqpath%\n%uid%\n%nick%';
begin
  MessageDlg(getTranslation(help), mtInformation, [mbOK], 0, mbOK, 60);
end;

procedure TotherFr.ChkPathBtnClick(Sender: TObject);
var
  fpath : String;
begin
//  fileIncomePath()
  fpath := template(RcvPathEdit.Text,[
                    '%userpath%', ExcludeTrailingPathDelimiter(AccPath),
                    '%rnqpath%', ExcludeTrailingPathDelimiter(mypath),
                    '%uid%', 'UID',
                    '%nick%', 'NICK'
                    ]);
  fpath := IncludeTrailingPathDelimiter(fpath)+ 'FILE';
  MessageDlg(getTranslation(fpath), mtInformation, [mbOK], 0, mbOK, 60);
end;

procedure TotherFr.applyPage;
begin
  quitconfirmation:=quitChk.checked;
  minimizeroster:=minimizeroasterChk.checked;
  browserCmdLine:=fnBox.text;
  useDefaultBrowser:=defaultbrowserChk.checked;
  autoswitchKL:=switchklChk.checked;
  NILdoWith := 2 - NILdoGrp.ItemIndex;
  showOncomingDlg:=oncomingDlgChk.checked;
  doFixWindows:=fixwindowsChk.checked;
  wheelVelocity:=round(wheel.value);
  inactivehideTime:=round(inactivehideSpin.value*10);
  inactiveHide:=inactivehideChk.checked;
  FileSavePath := RcvPathEdit.Text;
end;

procedure TotherFr.resetPage;
begin
  GroupBox1.width:= TabSheet1.ClientWidth - GAP_SIZE2;
  fnBox.width:= GroupBox1.width - 24 - GAP_SIZE2 - fnBoxButton.width;
  fnBoxButton.left:=  fnBox.left + fnBox.width + GAP_SIZE;


  minimizeroasterChk.checked:=minimizeroster;
  switchklChk.checked:=autoswitchKL;
  NILdoGrp.ItemIndex := 2 - NILdoWith;
  fixwindowsChk.checked:=doFixWindows;
  wheel.value:=wheelVelocity;
  inactivehideChk.checked:=inactivehide;
  quitChk.checked:=quitconfirmation;
  inactivehideSpin.value := inactivehideTime div 10;
  fnBox.text:=browserCmdLine;
  defaultbrowserChk.checked:=useDefaultBrowser;
  custombrowserChk.checked:=not useDefaultBrowser;
  RcvPathEdit.Text := FileSavePath;
end;

procedure TotherFr.updateVisPage;
begin
  inactivehideSpin.enabled:=inactivehideChk.checked;
end;

procedure TotherFr.FrameResize(Sender: TObject);
begin
//  fnBoxButton.Left := fnBox.Left + fnBox.Width + 2;
end;

end.
