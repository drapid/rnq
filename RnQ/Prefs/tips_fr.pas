{
This file is part of R&Q.
Under same license
}
unit tips_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ExtCtrls,
  RnQPrefsInt, RnQPrefsTypes,
  RnQSpin, RnQButtons;

type
  TTipsFr = class(TPrefFrame)
    Label4: TLabel;
    Label7: TLabel;
    TipsMaxCntSpin: TRnQSpinEdit;
    TipsSpaceSpn: TRnQSpinEdit;
    TranspTrayGroup: TGroupBox;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    traytranspChk: TCheckBox;
    transpTray: TTrackBar; //transparency-vtray
    PosGrp: TRadioGroup; //'show-tips-align'
    IndGrp: TGroupBox;
    HorIndSpn: TRnQSpinEdit;
    VerIndSpn: TRnQSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    RnQButton1: TRnQButton;
    DisLbl: TLabel;
    procedure RnQButton1Click(Sender: TObject);
    procedure TipsMaxCntSpinChange(Sender: TObject);
  private
    { Private declarations }
  public
    procedure initPage(prefs: IRnQPref); Override; final;
    procedure applyPage; Override; final;
    procedure resetPage; Override; final;
    { Public declarations }
  end;

implementation
uses
   RnQTips, RDGlobal, RnQLangs, tipDlg,
   RnQConst, events, globalLib;
{$R *.dfm}

procedure TTipsFr.initPage;
begin
  Inherited;
  TranspTrayGroup.left := GAP_SIZE;
  TranspTrayGroup.width := Self.Clientwidth - GAP_SIZE2;

  PosGrp.left  := GAP_SIZE;
  PosGrp.width := TranspTrayGroup.width div 2 - GAP_SIZE;
  IndGrp.Width := TranspTrayGroup.width - PosGrp.width - GAP_SIZE ;
end;

procedure TTipsFr.applyPage;
begin
  transparency.forTray := traytranspChk.checked;
  transparency.tray := transpTray.position;

  TipsMaxCnt :=  TipsMaxCntSpin.AsInteger;
  TipsBtwSpace := TipsSpaceSpn.AsInteger;
  TipsAlign := TtipsAlign( byte(PosGrp.ItemIndex) );
  TipVerIndent := VerIndSpn.AsInteger;
  TipHorIndent := HorIndSpn.AsInteger;
end;

procedure TTipsFr.resetPage;
begin
  traytranspChk.checked  := transparency.forTray;
  transpTray.position    := transparency.tray;

  TipsMaxCntSpin.AsInteger := TipsMaxCnt;
  TipsSpaceSpn.AsInteger   := TipsBtwSpace;

  VerIndSpn.AsInteger := TipVerIndent;
  HorIndSpn.AsInteger := TipHorIndent;

  PosGrp.ItemIndex := byte( TipsAlign );
end;


procedure TTipsFr.RnQButton1Click(Sender: TObject);
//const
//  str = AnsiString('http://hh.ru/applicant/vacancySearch.do?keyword1=Oracle&allFields=true&areaId=1'+
//                    '&professionalAreaId=1&specializationId=50&specializationId=113&specializationId=221&'+
//                    'isFromAgency=10&isWithoutSalary=10&compensationCurrencyId=1&desireableCompensation=70000&'+
//                    'searchPeriod=30&orderBy=2&itemsOnPage=20&page=5&actionSearch=actionSearch&showRss=1');
var
  e: Thevent;
  i: Integer;
  s: AnsiString;
begin
  i := EK_msg;
  s := '';
  if i = EK_AUTOMSG then
   s := AnsiChar(#00);
//  e := Thevent.new(i, icq.myInfo, now, s+'Testing', 0);
  e := Thevent.new(i, Account.AccProto.getMyInfo, now, s
            {$IFDEF DB_ENABLED}
              , getTranslation('Testing')
            {$ELSE ~DB_ENABLED}
              +AnsiString(getTranslation('Testing'))
//              + str
            {$ENDIF DB_ENABLED}
              +CRLF  + 'Second row ------- :)', 0);
//  TipAdd(e);
  TipAdd3(e);
//  tipfrm.show(e);
  e.Free;
end;

procedure TTipsFr.TipsMaxCntSpinChange(Sender: TObject);
begin
  DisLbl.Visible := TipsMaxCntSpin.Value = 0;
end;

end.
