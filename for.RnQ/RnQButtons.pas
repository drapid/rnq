{*******************************************************}
{                                                       }
{            Delphi Visual Component Library            }
{                                                       }
{ Copyright(c) 1995-2012 Embarcadero Technologies, Inc. }
{                                                       }
{*******************************************************}
// This unit contains a special speed button which can be used to let the user select
// a specific color. The control does not use the standard Windows color dialog, but
// a popup window very similar to the one in Office97, which has been improved a lot
// to support the task of picking one color out of millions. Included is also the
// ability to pick one of the predefined system colors (e.g. clBtnFace).
// Note: The layout is somewhat optimized to look pretty with the predefined box size
//       of 18 pixels (the size of one little button in the predefined color area) and
//       the number of color comb levels. It is easily possible to change this, but
//       if you want to do so then you have probably to make some additional
//       changes to the overall layout.
//
// TColorPickerButton works only with D4 and BCB!
// (BCB check by Josue Andrade Gomes gomesj@bsi.com.br)
//
// (c) 1999, written by Dipl. Ing. Mike Lischke (public@lischke-online.de)
// All rights reserved. This unit is freeware and may be used in any software
// product (free or commercial) under the condition that I'm given proper credit
// (Titel, Name and eMail address in the documentation or the About box of the
// product this source code is used in).
// Portions copyright by Borland. The implementation of the speed button has been
// taken from Delphi sources.
//
// 22-JUN-99 ml: a few improvements for the overall layout (mainly indicator rectangle
//               does now draw in four different styles and considers the layout
//               property of the button (changed to version 1.2, BCB compliance is
//               now proved by Josue Andrade Gomes)
// 18-JUN-99 ml: message redirection bug removed (caused an AV under some circumstances)
//               and accelerator key handling bug removed (wrong flag for EndSelection)
//               (changed to version 1.1)
// 16-JUN-99 ml: initial release


unit RnQButtons;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

{$S-,W-,R-,H+,X+}
{$C PRELOAD}

interface

uses Windows, Messages, Forms, Classes, Controls, Graphics, StdCtrls, Themes,
  RnQGraphics32,
  ExtCtrls, CommCtrl, Menus,
 {$IFDEF RNQ}
  RQThemes,
 {$ENDIF RNQ}
  RDGlobal;
//  SysUtils,

const // constants used in OnHint and internally to indicate a specific cell
      DefaultCell = -3;
      CustomCell = -2;
      NoCell = -1;

type
  TButtonLayout = (blGlyphLeft, blGlyphRight, blGlyphTop, blGlyphBottom);
  TButtonState = (bsUp, bsDisabled, bsDown, bsExclusive);
//  TButtonStyle = (bsAutoDetect, bsWin31, bsNew);
//  TButtonStyle = (bsNew, bsDropDown);
  TButtonType = (btSimple, btDropDown);

  TRnQSpeedButton = class;

  TRnQSpeedButtonActionLink = class(TControlActionLink)
  protected
    FClient: TRnQSpeedButton;
    procedure AssignClient(AClient: TObject); override;
    function IsCheckedLinked: Boolean; override;
    function IsGroupIndexLinked: Boolean; override;
    procedure SetGroupIndex(Value: Integer); override;
    procedure SetChecked(Value: Boolean); override;
  end;

  TRnQSpeedButton = class(TGraphicControl)
  private
    FGroupIndex: Integer;
//    FGlyph: TObject;
    FDragging   : Boolean;
    FAllowAllUp : Boolean;
    FLayout: TButtonLayout;
    FSpacing: Integer;
    FTransparent: Boolean;
    FMargin: Integer;
    FFlat       : Boolean;
    FMouseInControl: Boolean;
    FActive     : Boolean;
    FDefault    : Boolean;
    FCancel     : Boolean;
 {$IFDEF RNQ}
    fImgElm   : TRnQThemedElementDtls;
 {$ELSE ~RNQ}
    fImgName  : TPicName;
 {$ENDIF RNQ}
    FModalResult: TModalResult;
//    FTempCanvas : TCanvas;
//    procedure GlyphChanged(Sender: TObject);
    procedure UpdateExclusive;
    procedure SetImageName(const Value: TPicName);
//    function GetGlyph: TBitmap;
//    procedure SetGlyph(Value: TBitmap);
//    function GetNumGlyphs: TNumGlyphs;
//    procedure SetNumGlyphs(Value: TNumGlyphs);
    procedure SetDown(Value: Boolean);
    procedure SetFlat(Value: Boolean);
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetGroupIndex(Value: Integer);
    procedure SetLayout(Value: TButtonLayout);
    procedure SetSpacing(Value: Integer);
    procedure SetTransparent(Value: Boolean);
    procedure SetMargin(Value: Integer);
    procedure UpdateTracking;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;

    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
//    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
  protected
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    function GetActionLinkClass: TControlActionLinkClass; override;
    function GetPalette: HPALETTE; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
    property MouseInControl: Boolean read FMouseInControl;
//    procedure CreateWnd; override;

  public
    FState: TButtonState;
    FDown: Boolean;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
  published
    property Action;
    property Align;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property Down: Boolean read FDown write SetDown default False;
    property Caption;
    property Enabled;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Font;
//    property Glyph: TBitmap read GetGlyph write SetGlyph;
//    property NumGlyphs: TNumGlyphs read GetNumGlyphs write SetNumGlyphs default 1;
    property Layout: TButtonLayout read FLayout write SetLayout default blGlyphLeft;
    property Margin: Integer read FMargin write SetMargin default -1;
    property ModalResult: TModalResult read FModalResult write FModalResult default 0;
    property ParentFont;
    property ParentShowHint;
    property ParentBiDiMode;
    property PopupMenu;
    property ShowHint;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
    property Visible;
 {$IFDEF RNQ}
    property ImageName : TPicName read fImgElm.picName write SetImageName;
    property ImageElm : TRnQThemedElementDtls read fImgElm;
 {$ELSE ~RNQ}
    property ImageName : TPicName read fImgName write SetImageName;
 {$ENDIF RNQ}
    property Default : Boolean read FDefault write FDefault default False;
    property Cancel : Boolean read FCancel write FCancel default False;
    property OnClick;
    property OnDblClick;
  {$IFDEF DELPHI9_UP}
    property OnMouseActivate;
    property OnMouseEnter;
    property OnMouseLeave;
  {$ENDIF DELPHI9_UP}
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;


  TIndicatorBorder = (ibNone, ibFlat, ibSunken, ibRaised);

  THintEvent = procedure(Sender: TObject; Cell: Integer; var Hint: String) of object;
  TDropChangingEvent = procedure(Sender: TObject; var Allowed: Boolean) of object;

  TColorPickerButton = class(TGraphicControl)
  private
    FGroupIndex: Integer;
//    FGlyph: Pointer;
    FDown: Boolean;
    FDragging: Boolean;
    FAllowAllUp: Boolean;
    FLayout: TButtonLayout;
    FSpacing: Integer;
    FMargin: Integer;
    FFlat: Boolean;
    FMouseInControl: Boolean;
    FTransparent: Boolean;
    FIndicatorBorder: TIndicatorBorder;

    FDropDownArrowColor: TColor;
    FDropDownWidth: Integer;
    FDropDownZone: Boolean;
    FDroppedDown: Boolean;
    FSelectionColor: TColor;
    FState: TButtonState;
    FColorPopup: TWinControl;
    FPopupWnd: HWND;

    FOnChange,
    FOnDefaultSelect,
    FOnDropChanged: TNotifyEvent;
    FOnDropChanging: TDropChangingEvent;
    FOnHint: THintEvent;
//    procedure GlyphChanged(Sender: TObject);
    procedure UpdateExclusive;
//    function GetGlyph: TBitmap;
    procedure SetDropDownArrowColor(Value: TColor);
    procedure SetDropDownWidth(Value: integer);
//    procedure SetImageName(Value: String);
//    procedure SetGlyph(Value: TBitmap);
//    function GetNumGlyphs: TNumGlyphs;
//    procedure SetNumGlyphs(Value: TNumGlyphs);
    procedure SetDown(Value: Boolean);
    procedure SetFlat(Value: Boolean);
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetGroupIndex(Value: Integer);
    procedure SetLayout(Value: TButtonLayout);
    procedure SetSpacing(Value: Integer);
    procedure SetMargin(Value: Integer);
    procedure UpdateTracking;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMLButtonDblClk(var Message: TWMLButtonDown); message WM_LBUTTONDBLCLK;

    procedure DrawButtonSeperatorUp(Canvas: TCanvas);
    procedure DrawButtonSeperatorDown(Canvas: TCanvas);
    procedure DrawTriangle(Canvas: TCanvas; Top, Left, Width: Integer);
    procedure SetDroppedDown(const Value: Boolean);
    procedure SetSelectionColor(const Value: TColor);
    procedure PopupWndProc(var Msg: TMessage);
    function GetCustomText: String;
    procedure SetCustomText(const Value: String);
    function GetDefaultText: String;
    procedure SetDefaultText(const Value: String);
    procedure SetShowSystemColors(const Value: Boolean);
    function GetShowSystemColors: Boolean;
    procedure SetTransparent(const Value: Boolean);
    procedure SetIndicatorBorder(const Value: TIndicatorBorder);
    function GetPopupSpacing: Integer;
    procedure SetPopupSpacing(const Value: Integer);
  protected
    procedure DoDefaultEvent; virtual;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    function GetPalette: HPALETTE; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Click; override;

    property DroppedDown: Boolean read FDroppedDown write SetDroppedDown;
  published
    property Action;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Constraints;
    property CustomText: String read GetCustomText write SetCustomText;
    property DefaultText: String read GetDefaultText write SetDefaultText;
    property Down: Boolean read FDown write SetDown default False;
    property DropDownArrowColor: TColor read FDropDownArrowColor write SetDropDownArrowColor default clBlack;
    property DropDownWidth: integer read FDropDownWidth write SetDropDownWidth default 15;
    property Enabled;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Font;
//    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property IndicatorBorder: TIndicatorBorder read FIndicatorBorder write SetIndicatorBorder default ibFlat;
    property Layout: TButtonLayout read FLayout write SetLayout default blGlyphLeft;
    property Margin: Integer read FMargin write SetMargin default -1;
//    property NumGlyphs: TNumGlyphs read GetNumGlyphs write SetNumGlyphs default 1;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupSpacing: Integer read GetPopupSpacing write SetPopupSpacing;
    property SelectionColor: TColor read FSelectionColor write SetSelectionColor default clBlack;
    property ShowHint;
    property ShowSystemColors: Boolean read GetShowSystemColors write SetShowSystemColors;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
    property Visible;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
    property OnDefaultSelect: TNotifyEvent read FOnDefaultSelect write FOnDefaultSelect;
    property OnDropChanged: TNotifyEvent read FOnDropChanged write FOnDropChanged;
    property OnDropChanging: TDropChangingEvent read FOnDropChanging write FOnDropChanging;
    property OnHint: THintEvent read FOnHint write FOnHint;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;


  TRnQToolButton = class(TGraphicControl)
  private
    FGroupIndex: Integer;
    FDown: Boolean;
    FDragging: Boolean;
    FAllowAllUp: Boolean;
    FLayout: TButtonLayout;
    FSpacing: Integer;
    FMargin: Integer;
    FFlat: Boolean;
    FMouseInControl: Boolean;
    FTransparent: Boolean;
    FIndicatorBorder: TIndicatorBorder;
 {$IFDEF RNQ}
    fImgElm   : TRnQThemedElementDtls;
 {$ELSE ~RNQ}
    fImgName  : TPicName;
 {$ENDIF RNQ}
//    FImageName : String;
//    FthemeToken : Integer;
//    FimgIdx     : Integer;
//    FimgLoc     : TPicLocation;

    FDropdownMenu: TPopupMenu;
    FDropDownArrowColor: TColor;
    FDropDownWidth: Integer;
    FDropDownZone: Boolean;
    FDroppedDown: Boolean;
    FState: TButtonState;

    FOnChange,
    FOnDefaultSelect,
    FOnDropChanged: TNotifyEvent;
    FOnDropChanging: TDropChangingEvent;
    FOnHint: THintEvent;
    procedure SetImageName(const Value: TPicName);
    procedure UpdateExclusive;
    procedure SetDropdownMenu(Value: TPopupMenu);
    procedure SetDropDownArrowColor(Value: TColor);
    procedure SetDropDownWidth(Value: integer);
    procedure SetDown(Value: Boolean);
    procedure SetFlat(Value: Boolean);
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetGroupIndex(Value: Integer);
    procedure SetLayout(Value: TButtonLayout);
    procedure SetSpacing(Value: Integer);
    procedure SetMargin(Value: Integer);
    procedure UpdateTracking;
    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMLButtonDblClk(var Message: TWMLButtonDown); message WM_LBUTTONDBLCLK;

    procedure DrawButtonSeperatorUp(Canvas: TCanvas);
    procedure DrawButtonSeperatorDown(Canvas: TCanvas);
    procedure DrawTriangle(Canvas: TCanvas; Top, Left, Width: Integer);
    procedure SetDroppedDown(const Value: Boolean);
    procedure SetTransparent(const Value: Boolean);
    procedure SetIndicatorBorder(const Value: TIndicatorBorder);
  protected
    procedure DoDefaultEvent; virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Click; override;

    property DroppedDown: Boolean read FDroppedDown write SetDroppedDown;
  published
    property Action;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Constraints;
    property Down: Boolean read FDown write SetDown default False;
    property DropdownMenu: TPopupMenu read FDropdownMenu write SetDropdownMenu;
    property DropDownArrowColor: TColor read FDropDownArrowColor write SetDropDownArrowColor default clBlack;
    property DropDownWidth: integer read FDropDownWidth write SetDropDownWidth default 15;
    property Enabled;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Font;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property IndicatorBorder: TIndicatorBorder read FIndicatorBorder write SetIndicatorBorder default ibFlat;
    property Layout: TButtonLayout read FLayout write SetLayout default blGlyphLeft;
    property Margin: Integer read FMargin write SetMargin default -1;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
 {$IFDEF RNQ}
    property ImageName : TPicName read fImgElm.picName write SetImageName;
 {$ELSE ~RNQ}
    property ImageName : TPicName read fImgName write SetImageName;
 {$ENDIF RNQ}
    property MouseInControl: Boolean read FMouseInControl;
    property Visible;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
    property OnDefaultSelect: TNotifyEvent read FOnDefaultSelect write FOnDefaultSelect;
    property OnDropChanged: TNotifyEvent read FOnDropChanged write FOnDropChanged;
    property OnDropChanging: TDropChangingEvent read FOnDropChanging write FOnDropChanging;
    property OnHint: THintEvent read FOnHint write FOnHint;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  TRnQButton = class(TButton)
  private
    FCanvas: TCanvas;
//    FGlyph: TObject;
//    FStyle: TButtonStyle;
//    FKind: TRnQButtonKind;
    FLayout: TButtonLayout;
    FSpacing: Integer;
    FMargin: Integer;
 {$IFDEF RNQ}
    fImgElm   : TRnQThemedElementDtls;
 {$ELSE ~RNQ}
    fImgName  : TPicName;
 {$ENDIF RNQ}
//    FImageName : String;
//    FthemeToken : Integer;
//    FimgIdx     : Integer;
//    FimgLoc     : TPicLocation;
    FTransparent : Boolean;
    IsFocused: Boolean;
//    FModifiedGlyph: Boolean;
    FMouseInControl: Boolean;
//    FModalResult: TModalResult;
    procedure DrawItem(const DrawItemStruct: TDrawItemStruct);
    procedure SetGlyph(const PicName: TPicName);
//    function GetGlyph: String;
//    function GetNumGlyphs: TNumGlyphs;
//    procedure SetNumGlyphs(Value: TNumGlyphs);
    procedure GlyphChanged(Sender: TObject);
//    function IsCustom: Boolean;
//    function IsCustomCaption: Boolean;
//    procedure SetStyle(Value: TButtonStyle);
//    procedure SetKind(Value: TRnQButtonKind);
//    function GetKind: TRnQButtonKind;
    procedure SetLayout(Value: TButtonLayout);
    procedure SetSpacing(Value: Integer);
    procedure SetMargin(Value: Integer);
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk);
      message WM_LBUTTONDBLCLK;
    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;
  protected
//    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
//    procedure CopyImage(ImageList: TCustomImageList; Index: Integer);
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
//    function GetActionLinkClass: TControlActionLinkClass; override;
    function GetPalette: HPALETTE; override;
    procedure SetButtonStyle(ADefault: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
//    procedure Click; override;
  published
    property Action;
    property Align;
    property Anchors;
    property BiDiMode;
    property Cancel;
    property Caption;
    property Constraints;
    property Default;
    property Enabled;
 {$IFDEF RNQ}
    property ImageName : TPicName read fImgElm.picName write SetGlyph;
 {$ELSE ~RNQ}
    property ImageName : TPicName read fImgName write SetGlyph;
 {$ENDIF RNQ}
//    property Kind: TRnQButtonKind read GetKind write SetKind default bkCustom;
    property Layout: TButtonLayout read FLayout write SetLayout default blGlyphLeft;
    property Margin: Integer read FMargin write SetMargin default -1;
    property ModalResult;
//    property NumGlyphs: TNumGlyphs read GetNumGlyphs write SetNumGlyphs stored IsCustom default 1;
    property ParentShowHint;
    property ParentBiDiMode;
    property ShowHint;
//    property Style: TButtonStyle read FStyle write SetStyle default bsAutoDetect;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnEnter;
    property OnExit;
  end;


function RnQButtonDrawFull(Canvas: TCanvas; const Client: TRect; //const Offset: TPoint;
      const Caption: string; Layout: TButtonLayout; Margin, Spacing: Integer;
      State: TButtonState; MouseInControl : Boolean; Transparent: Boolean; BiDiFlags: Longint;
 {$IFDEF RNQ}
      var ImgElm : TRnQThemedElementDtls;
 {$ENDIF RNQ}
//      ImageName : String;
      const DropDownWidth: Integer=0): TRect;

function RnQButtonDraw(//Canvas: TCanvas;
      CanvasHnd : HDC; pFontColor : TColor;
      const Client: TRect; const Offset: TPoint;
      const Caption: string; Layout: TButtonLayout; Margin, Spacing: Integer;
      thmBtn : TThemedButton; State: TButtonState;
      Transparent: Boolean; BiDiFlags: Longint;
 {$IFDEF RNQ}
      var ImgElm : TRnQThemedElementDtls;
 {$ENDIF RNQ}
//      ImageName : String;
      const DropDownWidth: Integer=0; PaintOnGlass : Boolean = False): TRect;

procedure RnQDrawButtonGlyph(DC: HDC; //const GlyphPos: TPoint;
      const PicRect : TGPRect;
      State: TButtonState; Transparent: Boolean;
 {$IFDEF RNQ}
      var ImgElm : TRnQThemedElementDtls;
 {$ENDIF RNQ}
//      ImageName : String;
      const PaintOnGlass : Boolean = false);
procedure RnQDrawButtonText(//Canvas: TCanvas;
            CanvasHnd : HDC; pColor : TColor;
            const Caption: string; thmBtn : TThemedButton;
            TextBounds: TRect; State: TButtonState; BiDiFlags: Longint;
            PaintOnGlass: Boolean = false);
procedure RnQCalcButtonLayout(DC : HDC; const Client: TRect;
  const Offset: TPoint; const Caption: string; Layout: TButtonLayout; Margin,
  Spacing: Integer; // var GlyphPos: TPoint;
  var GlyphRect: TGPRect;
  var TextBounds: TRect;
  BiDiFlags: LongInt;
 {$IFDEF RNQ}
  var ImgElm : TRnQThemedElementDtls;
 {$ENDIF RNQ}
//  ImageName : String;
  const DropDownWidth: Integer = 0);

{function DrawButtonFace(Canvas: TCanvas; const Client: TRect;
  BevelWidth: Integer; //Style: TButtonStyle;
  IsRounded, IsDown, IsFocused: Boolean): TRect;
}
procedure Register;

implementation

uses Consts, SysUtils, ActnList,
 UxTheme,
 {$IFDEF DELPHI9_UP}
 DwmApi,
 {$ENDIF DELPHI9_UP}
 {$IFDEF RNQ}
 RQUtil,
 {$ENDIF RNQ}
 Types
 ;

var
  ButtonCount: Integer = 0;


{ DrawButtonFace - returns the remaining usable area inside the Client rect.}
function DrawButtonFace(Canvas: TCanvas; const Client: TRect;
  BevelWidth: Integer; //Style: TButtonStyle;
  IsRounded, IsDown, IsFocused: Boolean): TRect;
var
//  NewStyle: Boolean;
  R: TRect;
  DC: THandle;
begin
//  NewStyle := ((Style = bsAutoDetect) and NewStyleControls) or (Style = bsNew);

  R := Client;
  with Canvas do
  begin
//    if NewStyle then
    begin
      Brush.Color := clBtnFace;
      Brush.Style := bsSolid;
      DC := Canvas.Handle;    { Reduce calls to GetHandle }
    
      if IsDown then
      begin    { DrawEdge is faster than Polyline }
        DrawEdge(DC, R, BDR_SUNKENINNER, BF_TOPLEFT);              { black     }
        DrawEdge(DC, R, BDR_SUNKENOUTER, BF_BOTTOMRIGHT);          { btnhilite }
        Dec(R.Bottom);
        Dec(R.Right);
        Inc(R.Top);
        Inc(R.Left);
        DrawEdge(DC, R, BDR_SUNKENOUTER, BF_TOPLEFT or BF_MIDDLE); { btnshadow }
      end
      else
      begin
        DrawEdge(DC, R, BDR_RAISEDOUTER, BF_BOTTOMRIGHT);          { black }
        Dec(R.Bottom);
        Dec(R.Right);
        DrawEdge(DC, R, BDR_RAISEDINNER, BF_TOPLEFT);              { btnhilite }
        Inc(R.Top);
        Inc(R.Left);
        DrawEdge(DC, R, BDR_RAISEDINNER, BF_BOTTOMRIGHT or BF_MIDDLE); { btnshadow }
      end;
    end
(*    else
    begin
      Pen.Color := clWindowFrame;
      Brush.Color := clBtnFace;
      Brush.Style := bsSolid;
      Rectangle(R.Left, R.Top, R.Right, R.Bottom);

      { round the corners - only applies to Win 3.1 style buttons }
      if IsRounded then
      begin
        Pixels[R.Left, R.Top] := clBtnFace;
        Pixels[R.Left, R.Bottom - 1] := clBtnFace;
        Pixels[R.Right - 1, R.Top] := clBtnFace;
        Pixels[R.Right - 1, R.Bottom - 1] := clBtnFace;
      end;

      if IsFocused then
      begin
        InflateRect(R, -1, -1);
        Brush.Style := bsClear;
        Rectangle(R.Left, R.Top, R.Right, R.Bottom);
      end;

      InflateRect(R, -1, -1);
      if not IsDown then
        Frame3D(Canvas, R, clBtnHighlight, clBtnShadow, BevelWidth)
      else
      begin
        Pen.Color := clBtnShadow;
        PolyLine([Point(R.Left, R.Bottom - 1), Point(R.Left, R.Top),
          Point(R.Right, R.Top)]);
      end;
    end;*)
  end;

  Result := Rect(Client.Left + 1, Client.Top + 1,
    Client.Right - 2, Client.Bottom - 2);
  if IsDown then OffsetRect(Result, 1, 1);
end;

{ TRnQSpeedButtonActionLink }

procedure TRnQSpeedButtonActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient := AClient as TRnQSpeedButton;
end;

function TRnQSpeedButtonActionLink.IsCheckedLinked: Boolean;
begin
  Result := inherited IsCheckedLinked and (FClient.GroupIndex <> 0) and
    FClient.AllowAllUp and (FClient.Down = (Action as TCustomAction).Checked);
end;

function TRnQSpeedButtonActionLink.IsGroupIndexLinked: Boolean;
begin
  Result := (FClient is TRnQSpeedButton) and
    (TRnQSpeedButton(FClient).GroupIndex = (Action as TCustomAction).GroupIndex);
end;

procedure TRnQSpeedButtonActionLink.SetChecked(Value: Boolean);
begin
  if IsCheckedLinked then TRnQSpeedButton(FClient).Down := Value;
end;

procedure TRnQSpeedButtonActionLink.SetGroupIndex(Value: Integer);
begin
  if IsGroupIndexLinked then TRnQSpeedButton(FClient).GroupIndex := Value;
end;

{ TRnQSpeedButton }
    
constructor TRnQSpeedButton.Create(AOwner: TComponent);
begin
//  FGlyph := TButtonGlyph.Create;
//  TButtonGlyph(FGlyph).OnChange := GlyphChanged;
  inherited Create(AOwner);
  SetBounds(0, 0, 23, 22);
  ControlStyle := [csCaptureMouse, csDoubleClicks];
  ParentFont := True;
  Color := clBtnFace;
  FSpacing := 4;
  FMargin := -1;
  FLayout := blGlyphLeft;
  FTransparent := True;
  Inc(ButtonCount);
 {$IFDEF RNQ}
  fImgElm.picName := '';
  fImgElm.ThemeToken := -1;
 {$ELSE ~RNQ}
  fImgName := '';
 {$ENDIF RNQ}
//  FTempCanvas := TCanvas.Create;
  Invalidate; // By Rapid D
end;
    
destructor TRnQSpeedButton.Destroy;
begin
  Dec(ButtonCount);
 {$IFDEF RNQ}
  fImgElm.picName := '';
  fImgElm.ThemeToken := -1;
 {$ELSE ~RNQ}
  fImgName := '';
 {$ENDIF RNQ}
//  FTempCanvas.Free;
//  FTempCanvas := NIL;
  inherited Destroy;
//  TButtonGlyph(FGlyph).Free;
end;
    
procedure TRnQSpeedButton.Paint;
const
  DownStyles: array[Boolean] of Integer = (BDR_RAISEDINNER, BDR_SUNKENOUTER);
  FillStyles: array[Boolean] of Integer = (BF_MIDDLE, 0);

 {$IFNDEF DELPHI9_UP}
  PaintOnGlass = False;
 {$ENDIF DELPHI9_UP}
var
  PaintRect: TRect;
  DrawFlags: Integer;
  Offset: TPoint;
  Button: TThemedButton;
  ToolButton: TThemedToolBar;
  Details: TThemedElementDetails;
 {$IFDEF DELPHI9_UP}
  PaintOnGlass: Boolean;
  PaintBuffer: HPAINTBUFFER;
 {$ENDIF DELPHI9_UP}
 {$IFNDEF 1=2 and COMPILER_12_UP}
  LForm: TCustomForm;
 {$ENDIF COMPILER_12_UP}
//  cnv : TCanvas;
//    saveDC,
    MemDC: HDC;
  brF : HBRUSH;
  PatternBMP : TBitmap;
//   vImgElm : TRnQThemedElementDtls;
//  FTempCanvas : TCanvas;
begin
  if not Assigned(self) then
    exit;
 {$IFDEF DELPHI9_UP}
  PaintOnGlass := False;
  PaintBuffer := 0;
 {$ENDIF DELPHI9_UP}
  if not Enabled then
  begin
    FState := bsDisabled;
    FDragging := False;
  end
  else if FState = bsDisabled then
    if FDown and (GroupIndex <> 0) then
      FState := bsExclusive
    else
      FState := bsUp;
//  FTempCanvas.Font := Self.Font;
  Canvas.Font := Self.Font;
  MemDC := Canvas.Handle;
   //FTempCanvas := NIL;
  Button := tbPushButtonNormal;
  try
  if ThemeControl(Self) then
  begin
 {$IFDEF DELPHI9_UP}
    PaintOnGlass := ThemeServices.ThemesEnabled and DwmCompositionEnabled and
      not (csDesigning in ComponentState);
    if PaintOnGlass then
    begin
     {$IFDEF 1=2 and COMPILER_12_UP}
      PaintOnGlass := csGlassPaint in ControlState;
     {$ELSE not COMPILER_12_UP}
      LForm := GetParentForm(Self);
      PaintOnGlass := (LForm <> nil) and LForm.GlassFrame.FrameExtended and
        LForm.GlassFrame.IntersectsControl(Self);
     {$ENDIF COMPILER_12_UP}
    end;
 {$ENDIF DELPHI9_UP}

    if not PaintOnGlass then
      if Transparent then
//        ThemeServices.DrawParentBackground(Parent.Handle, Canvas.Handle, nil, False)
        ThemeServices.DrawParentBackground(0, MemDC, nil, False)
      else
        PerformEraseBackground(Self, MemDC)
    else
      FillRect(MemDC, ClientRect, GetStockObject(BLACK_BRUSH));

//    if Flat then
//     PerformEraseBackground(Self, Canvas.Handle);

    if not Enabled then
      Button := tbPushButtonDisabled
    else
      if FState in [bsDown, bsExclusive] then
        Button := tbPushButtonPressed
      else
        if MouseInControl then
          Button := tbPushButtonHot
        else
          Button := tbPushButtonNormal;

    ToolButton := ttbToolbarDontCare;
    if FFlat then
    begin
      case Button of
        tbPushButtonDisabled:
          Toolbutton := ttbButtonDisabled;
        tbPushButtonPressed:
          Toolbutton := ttbButtonPressed;
        tbPushButtonHot:
          Toolbutton := ttbButtonHot;
        tbPushButtonNormal:
          Toolbutton := ttbButtonNormal;
      end;
    end;


    PaintRect := ClientRect;
 {$IFDEF DELPHI9_UP}
     if PaintOnGlass then
     begin
//      cnv := TCanvas.Create;
//      cnv := Canvas;
//      saveDC := FTempCanvas.Handle;
      PaintBuffer := BeginBufferedPaint(//Canvas.Handle,
                         MemDC,
                         PaintRect, BPBF_TOPDOWNDIB, nil, MemDC);
//      try
        BufferedPaintClear(PaintBuffer, @PaintRect);
//        cnv.
//        cnv.Handle := Canvas.Handle;
//        saveDC := Cnv.Handle;
{
        FTempCanvas := TCanvas.Create;
        FTempCanvas.Handle := MemDC;
//        cnv.Lock;

        FTempCanvas.Font := Self.Font;
}
//       oldFont := SelectObject(MemDC, Self.Font.Handle);
     end
//     else
 {$ENDIF DELPHI9_UP}
//      FTempCanvas := Canvas
;

    if ToolButton = ttbToolbarDontCare then
    begin
      Details := ThemeServices.GetElementDetails(Button);
      ThemeServices.DrawElement(MemDC, Details, PaintRect);
      PaintRect := ThemeServices.ContentRect(MemDC, Details, PaintRect);
    end
    else
    begin
      Details := ThemeServices.GetElementDetails(ToolButton);
      ThemeServices.DrawElement(MemDC, Details, PaintRect);
      PaintRect := ThemeServices.ContentRect(MemDC, Details, PaintRect);
    end;

    if Button = tbPushButtonPressed then
    begin
      // A pressed speed button has a white text. This applies however only to flat buttons.
      if ToolButton <> ttbToolbarDontCare then
        begin
//          FTempCanvas.Font.Color := clHighlightText;
          SetTextColor(MemDC, ColorToRGB(clHighlightText));
        end;
      Offset := Point(1, 0);
    end
    else
      Offset := Point(0, 0);
//    if ImageName <> '' then
//      theme.drawPic(Canvas, PaintRect.Left, PaintRect.Top, ImageName, FState<>bsDisabled)
//    else
//     TButtonGlyph(FGlyph).Draw(Canvas, PaintRect, Offset, Caption, FLayout, FMargin, FSpacing, FState, Transparent,
//       DrawTextBiDiModeFlags(0));
  end
  else
  begin
//    FTempCanvas := Canvas;
    PaintRect := Rect(0, 0, Width, Height);
    if not FFlat then
    begin
      DrawFlags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
      if FState in [bsDown, bsExclusive] then
        DrawFlags := DrawFlags or DFCS_PUSHED;
//      if FState  = bsDisabled then
//        DrawFlags := DrawFlags or DFCS_INACTIVE;
      DrawFrameControl(MemDC, PaintRect, DFC_BUTTON, DrawFlags);
    end
    else
    begin
      if (FState in [bsDown, bsExclusive]) or
        (FMouseInControl and (FState <> bsDisabled)) or
        (csDesigning in ComponentState) then
        DrawEdge(MemDC, PaintRect, DownStyles[FState in [bsDown, bsExclusive]],
          FillStyles[Transparent] or BF_RECT)
      else if not Transparent then
      begin
//        Canvas.Brush.Color := Color;
//        Canvas.FillRect(PaintRect);

         brF := CreateSolidBrush(ColorToRGB(Color));
         FillRect(MemDC, PaintRect, brF);
         DeleteObject(brF);
      end;
      InflateRect(PaintRect, -1, -1);
    end;
    if FState in [bsDown, bsExclusive] then
    begin
      if (FState = bsExclusive) and (not FFlat or not FMouseInControl) then
      begin
//        Canvas.Brush.Bitmap := AllocPatternBitmap(clBtnFace, clBtnHighlight);
//        Canvas.FillRect(PaintRect);

        PatternBMP := AllocPatternBitmap(clBtnFace, clBtnHighlight);
        if PatternBMP <> NIL then
         begin
          brF := CreatePatternBrush(PatternBMP.Handle);
          FillRect(MemDC, PaintRect, brF);
          DeleteObject(brF);
          PatternBMP := NIL;
         end;
//        PatternBMP.Free;
      end;
      Offset.X := 1;
      Offset.Y := 1;
    end
    else
    begin
      Offset.X := 0;
      Offset.Y := 0;
    end;
//    TButtonGlyph(FGlyph).
//    RnQButtonDraw(Canvas, PaintRect, Offset, Caption, FLayout, FMargin,
//      FSpacing, FState, Transparent, DrawTextBiDiModeFlags(0), ImageName);
  end;

  RnQButtonDraw(//FTempCanvas,
      MemDC, GetTextColor(MemDC),
      PaintRect, Offset, Caption, FLayout, FMargin,
      FSpacing, Button, FState, Transparent, DrawTextBiDiModeFlags(0),
 {$IFDEF RNQ}
      fImgElm,
 {$ENDIF RNQ}
      0, PaintOnGlass);

  finally
 {$IFDEF DELPHI9_UP}
      if PaintOnGlass then
       begin
//         cnv.Handle := saveDC;
//         cnv.Free;
//         FTempCanvas.Handle := saveDC;
//         FTempCanvas.Handle := 0;
//         FTempCanvas.Free;
//         BufferedPaintMakeOpaque(PaintBuffer, @PaintRect);
         EndBufferedPaint(PaintBuffer, True);
//         EndBufferedPaint(PaintBuffer, False);
       end;
 {$ENDIF DELPHI9_UP}
    end;
end;

procedure TRnQSpeedButton.UpdateTracking;
var
  P: TPoint;
begin
  if FFlat then
  begin
    if Enabled then
    begin
      GetCursorPos(P);
      FMouseInControl := not (FindDragTarget(P, True) = Self);
      if FMouseInControl then
        Perform(CM_MOUSELEAVE, 0, 0)
      else
        Perform(CM_MOUSEENTER, 0, 0);
    end;
  end;
end;
    
procedure TRnQSpeedButton.Loaded;
//var
//  State: TButtonState;
begin
  inherited Loaded;
//  if Enabled then
//    State := bsUp
//  else
//    State := bsDisabled;

  Invalidate; // By Rapid D
  Repaint;
//  TButtonGlyph(FGlyph).CreateButtonGlyph(State);
end;
    
procedure TRnQSpeedButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Enabled then
  begin
    if not FDown then
    begin
      FState := bsDown;
      Invalidate;
    end;
    FDragging := True;
  end;
end;
    
procedure TRnQSpeedButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewState: TButtonState;
begin
  inherited MouseMove(Shift, X, Y);
  if FDragging then
  begin
    if not FDown then NewState := bsUp
    else NewState := bsExclusive;
    if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
      if FDown then NewState := bsExclusive else NewState := bsDown;
    if NewState <> FState then
    begin
      FState := NewState;
      Invalidate;
    end;
  end
  else if not FMouseInControl then
    UpdateTracking;
end;
    
procedure TRnQSpeedButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  DoClick: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FDragging then
  begin
    FDragging := False;
    DoClick := (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight);
    if FGroupIndex = 0 then
    begin
      { Redraw face in-case mouse is captured }
      FState := bsUp;
      FMouseInControl := False;
      if DoClick and not (FState in [bsExclusive, bsDown]) then
        Invalidate;
    end
    else
      if DoClick then
      begin
        SetDown(not FDown);
        if FDown then Repaint;
      end
      else
      begin
        if FDown then FState := bsExclusive;
        Repaint;
      end;
    if DoClick then Click;
    UpdateTracking;
  end;
end;
    
procedure TRnQSpeedButton.Click;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);
  if Form <> nil then Form.ModalResult := ModalResult;
  inherited Click;
end;
    
function TRnQSpeedButton.GetPalette: HPALETTE;
begin
  Result := 0;
//  Result := Glyph.Palette;
end;

function TRnQSpeedButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TRnQSpeedButtonActionLink;
end;


procedure TRnQSpeedButton.SetImageName(const Value: TPicName);
begin
 {$IFDEF RNQ}
   fImgElm.picName := Value;
   fImgElm.Element := RQteButton;
   fImgElm.picIdx := -1;
   fImgElm.themeToken := -1;
 {$ELSE ~RNQ}
   fImgName := Value;
 {$ENDIF RNQ}
 Invalidate;
end;

{
function TRnQSpeedButton.GetGlyph: TBitmap;
begin
  Result := NIL;
//  Result := TButtonGlyph(FGlyph).Glyph;
end;

procedure TRnQSpeedButton.SetGlyph(Value: TBitmap);
begin
//  TButtonGlyph(FGlyph).Glyph := Value;
  Invalidate;
end;

{function TRnQSpeedButton.GetNumGlyphs: TNumGlyphs;
begin
  Result := TButtonGlyph(FGlyph).NumGlyphs;
end;

procedure TRnQSpeedButton.SetNumGlyphs(Value: TNumGlyphs);
begin
  if Value < 0 then Value := 1
  else if Value > 4 then Value := 4;
  if Value <> TButtonGlyph(FGlyph).NumGlyphs then
  begin
    TButtonGlyph(FGlyph).NumGlyphs := Value;
    Invalidate;
  end;
end;

procedure TRnQSpeedButton.GlyphChanged(Sender: TObject);
begin
  Invalidate;
end;
}
procedure TRnQSpeedButton.UpdateExclusive;
var
  Msg: TMessage;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    Msg.Msg := CM_BUTTONPRESSED;
    Msg.WParam := FGroupIndex;
    Msg.LParam := Longint(Self);
    Msg.Result := 0;
    Parent.Broadcast(Msg);
  end;
end;
    
procedure TRnQSpeedButton.SetDown(Value: Boolean);
begin
  if FGroupIndex = 0 then Value := False;
  if Value <> FDown then
  begin
    if FDown and (not FAllowAllUp) then Exit;
    FDown := Value;
    if Value then
    begin
      if FState = bsUp then Invalidate;
      FState := bsExclusive
    end
    else
    begin
      FState := bsUp;
      Repaint;
    end;
    if Value then UpdateExclusive;
  end;
end;
    
procedure TRnQSpeedButton.SetFlat(Value: Boolean);
begin
  if Value <> FFlat then
  begin
    FFlat := Value;
    Invalidate;
  end;
end;
    
procedure TRnQSpeedButton.SetGroupIndex(Value: Integer);
begin
  if FGroupIndex <> Value then
  begin
    FGroupIndex := Value;
    UpdateExclusive;
  end;
end;
    
procedure TRnQSpeedButton.SetLayout(Value: TButtonLayout);
begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Invalidate;
  end;
end;
    
procedure TRnQSpeedButton.SetMargin(Value: Integer);
begin
  if (Value <> FMargin) and (Value >= -1) then
  begin
    FMargin := Value;
    Invalidate;
  end;
end;
    
procedure TRnQSpeedButton.SetSpacing(Value: Integer);
begin
  if Value <> FSpacing then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;

procedure TRnQSpeedButton.SetTransparent(Value: Boolean);
begin
  if Value <> FTransparent then
  begin
    FTransparent := Value;
    if Value then
      ControlStyle := ControlStyle - [csOpaque]
     else
      ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
end;

procedure TRnQSpeedButton.SetAllowAllUp(Value: Boolean);
begin
  if FAllowAllUp <> Value then
  begin
    FAllowAllUp := Value;
    UpdateExclusive;
  end;
end;
    
procedure TRnQSpeedButton.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
//var
// cnv : TCanvas;
// ps: tagPAINTSTRUCT;
begin

 begin
   msg.Result := 1;
   msg.Msg := 0;
 end;
end;

procedure TRnQSpeedButton.WMLButtonDblClk(var Message: TWMLButtonDown);
begin
  inherited;
  if FDown then DblClick;
end;
    
procedure TRnQSpeedButton.CMEnabledChanged(var Message: TMessage);
const
  NewState: array[Boolean] of TButtonState = (bsDisabled, bsUp);
begin
//  TButtonGlyph(FGlyph).CreateButtonGlyph(NewState[Enabled]);
  Invalidate;
  UpdateTracking;
  Repaint;
end;
    
procedure TRnQSpeedButton.CMButtonPressed(var Message: TMessage);
var
  Sender: TRnQSpeedButton;
begin
  if Message.WParam = FGroupIndex then
  begin
    Sender := TRnQSpeedButton(Message.LParam);
    if Sender <> Self then
    begin
      if Sender.Down and FDown then
      begin
        FDown := False;
        FState := bsUp;
        if (Action is TCustomAction) then
          TCustomAction(Action).Checked := False;
        Invalidate;
      end;
      FAllowAllUp := Sender.AllowAllUp;
    end;
  end;
end;
    
procedure TRnQSpeedButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, Caption) and Enabled and Visible and
      (Parent <> nil) and Parent.Showing then
    begin
      Click;
      Result := 1;
    end else
      inherited;
end;
    
procedure TRnQSpeedButton.CMFontChanged(var Message: TMessage);
begin
  Invalidate;
end;
    
procedure TRnQSpeedButton.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;
    
procedure TRnQSpeedButton.CMSysColorChange(var Message: TMessage);
begin
  Invalidate;
{  with TButtonGlyph(FGlyph) do
  begin
    Invalidate;
    CreateButtonGlyph(FState);
  end;
  }
end;
    
procedure TRnQSpeedButton.CMMouseEnter(var Message: TMessage);
var
  NeedRepaint: Boolean;
begin
  inherited;
  { Don't draw a border if DragMode <> dmAutomatic since this button is meant to 
    be used as a dock client. }
  NeedRepaint := FFlat and not FMouseInControl and Enabled and (DragMode <> dmAutomatic) and (GetCapture = 0);

  { Windows XP introduced hot states also for non-flat buttons. }
  if (NeedRepaint or ThemeServices.ThemesEnabled) and not (csDesigning in ComponentState) then
  begin
    FMouseInControl := True;
    if Enabled then
//      Repaint;
      Invalidate;
  end;
end;

procedure TRnQSpeedButton.CMMouseLeave(var Message: TMessage);
var
  NeedRepaint: Boolean;
begin
  inherited;
  NeedRepaint := FFlat and FMouseInControl and Enabled and not FDragging;
  { Windows XP introduced hot states also for non-flat buttons. }
  if NeedRepaint or ThemeServices.ThemesEnabled then
  begin
    FMouseInControl := False;
    if Enabled then
//      Repaint;
      Invalidate;
  end;
end;

procedure TRnQSpeedButton.CMDialogKey(var Message: TCMDialogKey);
begin
  with Message do
    if  (((CharCode = VK_RETURN) and FActive) or
      ((CharCode = VK_ESCAPE) and FCancel)) and
      (KeyDataToShiftState(Message.KeyData) = []) //and CanFocus
       then
    begin
      Click;
      Result := 1;
    end else
      inherited;
end;

{
procedure TRnQSpeedButton.CMFocusChanged(var Message: TCMFocusChanged);
begin
  with Message do
    if Sender is TButton then
      FActive := Sender = Self
    else
      FActive := FDefault;
  SetButtonStyle(FActive);
  inherited;
end;

procedure TRnQSpeedButton.CreateWnd;
begin
  inherited CreateWnd;
  FActive := FDefault;
end;}



procedure TRnQSpeedButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
{
  procedure CopyImage(ImageList: TCustomImageList; Index: Integer);
  begin
    with Glyph do
    begin
      Width := ImageList.Width;
      Height := ImageList.Height;
      Canvas.Brush.Color := clFuchsia;//! for lack of a better color
      Canvas.FillRect(Rect(0,0, Width, Height));
      ImageList.Draw(Canvas, 0, 0, Index);
    end;
  end;
}
begin
  inherited ActionChange(Sender, CheckDefaults);
  if Sender is TCustomAction then
    with TCustomAction(Sender) do
    begin
      if CheckDefaults or (Self.GroupIndex = 0) then
        Self.GroupIndex := GroupIndex;
      { Copy image from action's imagelist }
{      if (Glyph.Empty) and (ActionList <> nil) and (ActionList.Images <> nil) and
        (ImageIndex >= 0) and (ImageIndex < ActionList.Images.Count) then
        CopyImage(ActionList.Images, ImageIndex);}
    end;
end;


const DRAW_BUTTON_UP = 8208;
      DRAW_BUTTON_DOWN = 8720;

type TColorEntry = record
       Name: PChar;
       case Boolean of
         True: (R, G, B, reserved: Byte);
         False: (Color: COLORREF);
     end;

const DefaultColorCount = 40;
      // these colors are the same as used in Office 97/2000
      DefaultColors : array[0..DefaultColorCount - 1] of TColorEntry = (
        (Name: 'Black'; Color: $000000),
        (Name: 'Brown'; Color: $003399),
        (Name: 'Olive Green'; Color: $003333),
        (Name: 'Dark Green'; Color: $003300),
        (Name: 'Dark Teal'; Color: $663300),
        (Name: 'Dark blue'; Color: $800000),
        (Name: 'Indigo'; Color: $993333),
        (Name: 'Gray-80%'; Color: $333333),

        (Name: 'Dark Red'; Color: $000080),
        (Name: 'Orange'; Color: $0066FF),
        (Name: 'Dark Yellow'; Color: $008080),
        (Name: 'Green'; Color: $008000),
        (Name: 'Teal'; Color: $808000),
        (Name: 'Blue'; Color: $FF0000),
        (Name: 'Blue-Gray'; Color: $996666),
        (Name: 'Gray-50%'; Color: $808080),

        (Name: 'Red'; Color: $0000FF),
        (Name: 'Light Orange'; Color: $0099FF),
        (Name: 'Lime'; Color: $00CC99),
        (Name: 'Sea Green'; Color: $669933),
        (Name: 'Aqua'; Color: $CCCC33),
        (Name: 'Light Blue'; Color: $FF6633),
        (Name: 'Violet'; Color: $800080),
        (Name: 'Grey-40%'; Color: $969696),

        (Name: 'Pink'; Color: $FF00FF),
        (Name: 'Gold'; Color: $00CCFF),
        (Name: 'Yellow'; Color: $00FFFF),
        (Name: 'Bright Green'; Color: $00FF00),
        (Name: 'Turquoise'; Color: $FFFF00),
        (Name: 'Sky Blue'; Color: $FFCC00),
        (Name: 'Plum'; Color: $663399),
        (Name: 'Gray-25%'; Color: $C0C0C0),

        (Name: 'Rose'; Color: $CC99FF),
        (Name: 'Tan'; Color: $99CCFF),
        (Name: 'Light Yellow'; Color: $99FFFF),
        (Name: 'Light Green'; Color: $CCFFCC),
        (Name: 'Light Turquoise'; Color: $FFFFCC),
        (Name: 'Pale Blue'; Color: $FFCC99),
        (Name: 'Lavender'; Color: $FF99CC),
        (Name: 'White'; Color: $FFFFFF)
      );

      SysColorCount = 25;
      SysColors : array[0..SysColorCount - 1] of TColorEntry = (
        (Name: 'system color: scroll bar'; Color: COLORREF(clScrollBar)),
        (Name: 'system color: background'; Color: COLORREF(clBackground)),
        (Name: 'system color: active caption'; Color: COLORREF(clActiveCaption)),
        (Name: 'system color: inactive caption'; Color: COLORREF(clInactiveCaption)),
        (Name: 'system color: menu'; Color: COLORREF(clMenu)),
        (Name: 'system color: window'; Color: COLORREF(clWindow)),
        (Name: 'system color: window frame'; Color: COLORREF(clWindowFrame)),
        (Name: 'system color: menu text'; Color: COLORREF(clMenuText)),
        (Name: 'system color: window text'; Color: COLORREF(clWindowText)),
        (Name: 'system color: caption text'; Color: COLORREF(clCaptionText)),
        (Name: 'system color: active border'; Color: COLORREF(clActiveBorder)),
        (Name: 'system color: inactive border'; Color: COLORREF(clInactiveBorder)),
        (Name: 'system color: application workspace'; Color: COLORREF(clAppWorkSpace)),
        (Name: 'system color: highlight'; Color: COLORREF(clHighlight)),
        (Name: 'system color: highlight text'; Color: COLORREF(clHighlightText)),
        (Name: 'system color: button face'; Color: COLORREF(clBtnFace)),
        (Name: 'system color: button shadow'; Color: COLORREF(clBtnShadow)),
        (Name: 'system color: gray text'; Color: COLORREF(clGrayText)),
        (Name: 'system color: button text'; Color: COLORREF(clBtnText)),
        (Name: 'system color: inactive caption text'; Color: COLORREF(clInactiveCaptionText)),
        (Name: 'system color: button highlight'; Color: COLORREF(clBtnHighlight)),
        (Name: 'system color: 3D dark shadow'; Color: COLORREF(cl3DDkShadow)),
        (Name: 'system color: 3D light'; Color: COLORREF(cl3DLight)),
        (Name: 'system color: info text'; Color: COLORREF(clInfoText)),
        (Name: 'system color: info background'; Color: COLORREF(clInfoBk))
      );
type
  TCombEntry = record
    Position: TPoint;
    Color: COLORREF;
  end;

  TCombArray = array of TCombEntry;

  TFloatPoint = record
    X, Y: Extended;
  end;

  TRGB = record
    Red, Green, Blue: Single;
  end;

  TSelectionMode = (smNone, smColor, smBW, smRamp);

  TColorPopup = class(TWinControl)
  private
    FDefaultText,
    FCustomText: String;
    FCurrentColor: TCOlor;
    FCanvas: TCanvas;
    FMargin,
    FSpacing,
    FColumnCount,
    FRowCount,
    FSysRowCount,
    FBoxSize: Integer;
    FSelectedIndex,
    FHoverIndex: Integer;
    FWindowRect,
    FCustomTextRect,
    FDefaultTextRect,
    FColorCombRect,
    FBWCombRect,
    FSliderRect,
    FCustomColorRect: TRect;
    FShowSysColors: Boolean;

    // custom color picking
    FCombSize,
    FLevels: Integer;
    FBWCombs,
    FColorCombs: TCombArray;
    FCombCorners: array[0..5] of TFloatPoint;
    FCenterColor: TRGB;
    FCenterIntensity: Single; // scale factor for the center color
    FCustomIndex,             // If FSelectedIndex contains CustomCell then this index shows
                              // which index in the custom area has been selected.
                              // Positive values indicate the color comb and negativ values
                              // indicate the B&W combs (complement). This value is offset with
                              // 1 to use index 0 to show no selection.
    FRadius: Integer;
    FSelectionMode: TSelectionMode; // indicates where the user has clicked
                                    // with the mouse to restrict draw selection
    procedure SelectColor(Color: TColor);
    procedure ChangeHoverSelection(Index: Integer);
    procedure DrawCell(Index: Integer);
    procedure InvalidateCell(Index: Integer);
    procedure EndSelection(Cancel: Boolean);
    function GetCellRect(Index: Integer; var Rect: TRect): Boolean;
    function GetColumn(Index: Integer): Integer;
    function GetIndex(Row, Col: Integer): Integer;
    function GetRow(Index: Integer): Integer;
    procedure Initialise;
    procedure AdjustWindow;
    procedure SetSpacing(Value: Integer);
    procedure SetSelectedColor(const Value: TColor);
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure CNSysKeyDown(var Message: TWMChar); message CN_SYSKEYDOWN;
    procedure WMActivateApp(var Message: TWMActivateApp); message WM_ACTIVATEAPP;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    function SelectionFromPoint(P: TPoint): Integer;
    procedure DrawCombControls;
    procedure DrawComb(Canvas: TCanvas; X, Y, Size: Integer);
    function HandleBWArea(const Message: TWMMouse): Boolean;
    function HandleColorComb(const Message: TWMMouse): Boolean;
    function HandleSlider(const Message: TWMMouse): Boolean;
    function PtInComb(Comb: TCombEntry; P: TPoint; Scale: Integer): Boolean;
    procedure HandleCustomColors(var Message: TWMMouse);
    function GetHint(Cell: Integer): String;
    function FindBWArea(X, Y: Integer): Integer;
    function FindColorArea(X, Y: Integer): Integer;
    procedure DrawSeparator(Left, Top, Right: Integer);
    procedure ChangeSelection(NewSelection: Integer);
  protected
    procedure CalculateCombLayout;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure ShowPopupAligned;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property SelectedColor: TColor read FCurrentColor write SetSelectedColor;
    property Spacing: Integer read FSpacing write SetSpacing;
  end;

const DefCenterColor: TRGB =(Red: 1; Green: 1; Blue: 1);  // White
      DefColors: array[0..5] of TRGB = (
        (Red: 1; Green: 0; Blue: 1),     // Magenta
        (Red: 1; Green: 0; Blue: 0),     // Red
        (Red: 1; Green: 1; Blue: 0),     // Yellow
        (Red: 0; Green: 1; Blue: 0),     // Green
        (Red: 0; Green: 1; Blue: 1),     // Cyan
        (Red: 0; Green: 0; Blue: 1)       // Blue
      );
      DefCenter: TFloatPoint = (X: 0; Y: 0);

//----------------- TColorPopup ------------------------------------------------

constructor TColorPopup.Create(AOwner: TComponent);

begin
  inherited;
  ControlStyle := ControlStyle - [csAcceptsControls] + [csOpaque];

  FCanvas := TCanvas.Create;
  Color := clBtnFace;
  ShowHint := True;

  Initialise;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.Initialise;

var I: Integer;

begin
  FBoxSize := 18;
  FMargin := GetSystemMetrics(SM_CXEDGE);
  FSpacing := 8;
  FHoverIndex := NoCell;
  FSelectedIndex := NoCell;

  // init comb caclulation
  for I := 0 to 5 do
  begin
    FCombCorners[I].X := 0.5 * cos(Pi * (90 - I * 60) / 180);
    FCombCorners[I].Y := 0.5 * sin(Pi * (90 - I * 60) / 180);
  end;
  FRadius := 66;
  FLevels := 7;
  FCombSize := Trunc(FRadius / (FLevels - 1));
  FCenterColor := DefCenterColor;
  FCenterIntensity := 1;
end;

//------------------------------------------------------------------------------

destructor TColorPopup.Destroy;

begin
  FBWCombs := nil;
  FColorCombs := nil;
  FCanvas.Free;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.CNSysKeyDown(var Message: TWMKeyDown);

// handles accelerator keys

begin
  with Message do
  begin
    if (Length(FDefaultText) > 0) and IsAccel(CharCode, FDefaultText) then
    begin
      ChangeSelection(DefaultCell);
      EndSelection(False);
      Result := 1;
    end
    else
      if (FSelectedIndex <> CustomCell) and
         (Length(FCustomText) > 0) and
         IsAccel(CharCode, FCustomText) then
      begin
        ChangeSelection(CustomCell);
        Result := 1;
      end
      else inherited;
    end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.CNKeyDown(var Message: TWMKeyDown);

// if an arrow key is pressed, then move the selection

var Row,
    MaxRow,
    Column: Integer;

begin
  inherited;

  if FHoverIndex <> NoCell then
  begin
    Row := GetRow(FHoverIndex);
    Column := GetColumn(FHoverIndex);
  end
  else
  begin
    Row := GetRow(FSelectedIndex);
    Column := GetColumn(FSelectedIndex);
  end;

  if FShowSysColors then MaxRow := DefaultColorCount + SysColorCount - 1
                    else MaxRow := DefaultColorCount - 1;
                    
  case Message.CharCode of
    VK_DOWN:
      begin
        if Row = DefaultCell then
        begin
          Row := 0;
          Column := 0;
        end
        else
          if Row = CustomCell then
          begin
            if Length(FDefaultText) > 0 then
            begin
              Row := DefaultCell;
              Column := Row;
            end
            else
            begin
              Row := 0;
              Column := 0;
            end;
          end
          else
          begin
            Inc(Row);
            if GetIndex(Row, Column) < 0 then
            begin
              if Length(FCustomText) > 0 then
              begin
                Row := CustomCell;
                Column := Row;
              end
              else
              begin
                if Length(FDefaultText) > 0 then
                begin
                  Row := DefaultCell;
                  Column := Row;
                end
                else
                begin
                  Row := 0;
                  Column := 0;
                end;
              end;
            end;
          end;
        ChangeHoverSelection(GetIndex(Row, Column));
        Message.Result := 1;
      end;

    VK_UP:
      begin
        if Row = DefaultCell then
        begin
          if Length(FCustomText) > 0 then
          begin
            Row := CustomCell;
            Column := Row;
          end
          else
          begin
            Row := GetRow(MaxRow);
            Column := GetColumn(MaxRow);
          end
        end
        else
          if Row = CustomCell then
          begin
            Row := GetRow(MaxRow);
            Column := GetColumn(MaxRow);
          end
          else
            if Row > 0 then Dec(Row)
                       else
            begin
              if Length(FDefaultText) > 0 then
              begin
                Row := DefaultCell;
                Column := Row;
              end
              else
                if Length(FCustomText) > 0 then
                begin
                  Row := CustomCell;
                  Column := Row;
                end
                else
                begin
                  Row := GetRow(MaxRow);
                  Column := GetColumn(MaxRow);
                end;
            end;
        ChangeHoverSelection(GetIndex(Row, Column));
        Message.Result := 1;
      end;

    VK_RIGHT:
      begin
        if Row = DefaultCell then
        begin
          Row := 0;
          Column := 0;
        end
        else
          if Row = CustomCell then
          begin
            if Length(FDefaultText) > 0 then
            begin
              Row := DefaultCell;
              Column := Row;
            end
            else
            begin
              Row := 0;
              Column := 0;
            end;  
          end
          else
            if Column < FColumnCount - 1 then Inc(Column)
                                            else
            begin
              Column := 0;
              Inc(Row);
            end;

          if GetIndex(Row, Column) = NoCell then
          begin
            if Length(FCustomText) > 0 then
            begin
              Row := CustomCell;
              Column := Row;
            end
            else
              if Length(FDefaultText) > 0 then
              begin
                Row := DefaultCell;
                Column := Row;
              end
              else
              begin
                Row := 0;
                Column := 0;
              end;
          end;
        ChangeHoverSelection(GetIndex(row, Column));
        Message.Result := 1;
      end;

    VK_LEFT:
      begin
        if Row = DefaultCell then
        begin
          if Length(FCustomText) > 0 then
          begin
            Row := CustomCell;
            Column := Row;
          end
          else
          begin
            Row := GetRow(MaxRow);
            Column := GetColumn(MaxRow);
          end;
        end
        else
          if Row = CustomCell then
          begin
            Row := GetRow(MaxRow);
            Column := GetColumn(MaxRow);
          end
          else
            if Column > 0 then Dec(Column)
                          else
            begin
              if Row > 0 then
              begin
                Dec(Row);
                Column := FColumnCount - 1;
              end
              else
              begin
                if Length(FDefaultText) > 0 then
                begin
                  Row := DefaultCell;
                  Column := Row;
                end
                else
                  if Length(FCustomText) > 0 then
                  begin
                    Row := CustomCell;
                    Column := Row;
                  end
                  else
                  begin
                    Row := GetRow(MaxRow);
                    Column := GetColumn(MaxRow);
                  end;
              end;
            end;
        ChangeHoverSelection(GetIndex(Row, Column));
        Message.Result := 1;
      end;

    VK_ESCAPE:
      begin
        EndSelection(True);
        Message.Result := 1;
      end;

    VK_RETURN,
    VK_SPACE:
      begin
        // this case can only occur if there was no click on the window
        // hence the hover index is the new color
        FSelectedIndex := FHoverIndex;
        EndSelection(False);
        Message.Result := 1;
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.DrawSeparator(Left, Top, Right: Integer);

var R: TRect;

begin
  R := Rect(Left, Top, Right, Top);
  DrawEdge(FCanvas.Handle, R, EDGE_ETCHED, BF_TOP);
end;

//------------------------------------------------------------------------------

procedure TColorPopup.DrawCell(Index: Integer);

var R, MarkRect: TRect;
    CellColor: TColor;

begin
  // for the custom text area
  if (Length(FCustomText) > 0) and (Index = CustomCell) then
  begin
    // the extent of the actual text button
    R := FCustomTextRect;

    // fill background
    FCanvas.Brush.Color := clBtnFace;
    FCanvas.FillRect(R);

    with FCustomTextRect do DrawSeparator(Left, Top - 2 * FMargin, Right);

    InflateRect(R, -1, 0);

    // fill background
    if (FSelectedIndex = Index) and (FHoverIndex <> Index) then FCanvas.Brush.Color := clBtnHighlight
                                                           else FCanvas.Brush.Color := clBtnFace;

    FCanvas.FillRect(R);
    // draw button
    if (FSelectedIndex = Index) or
       ((FHoverIndex = Index) and (csLButtonDown in ControlState)) then DrawEdge(FCanvas.Handle, R, BDR_SUNKENOUTER, BF_RECT)
                                                                   else
      if FHoverIndex = Index then DrawEdge(FCanvas.Handle, R, BDR_RAISEDINNER, BF_RECT);

    // draw custom text
    DrawText(FCanvas.Handle, PChar(FCustomText), Length(FCustomText), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE);

    // draw preview color rectangle
    if FCustomIndex = 0 then
    begin
      FCanvas.Brush.Color := clBtnShadow;
      FCanvas.FrameRect(FCustomColorRect);
    end
    else
    begin
      FCanvas.Pen.Color := clGray;
      if FCustomIndex > 0 then FCanvas.Brush.Color := FColorCombs[FCustomIndex - 1].Color
                          else FCanvas.Brush.Color := FBWCombs[- (FCustomIndex + 1)].Color;
      with FCustomColorRect do
        FCanvas.Rectangle(Left, Top, Right, Bottom);
    end;
  end
  else
    // for the default text area
    if (Length(FDefaultText) > 0) and (Index = DefaultCell) then
    begin
      R := FDefaultTextRect;

      // Fill background
      FCanvas.Brush.Color := clBtnFace;
      FCanvas.FillRect(R);

      InflateRect(R, -1, -1);

      // fill background
      if (FSelectedIndex = Index) and (FHoverIndex <> Index) then FCanvas.Brush.Color := clBtnHighlight
                                                             else FCanvas.Brush.Color := clBtnFace;

      FCanvas.FillRect(R);
      // draw button
      if (FSelectedIndex = Index) or
         ((FHoverIndex = Index) and (csLButtonDown in ControlState)) then DrawEdge(FCanvas.Handle, R, BDR_SUNKENOUTER, BF_RECT)
                                                                     else
        if FHoverIndex = Index then DrawEdge(FCanvas.Handle, R, BDR_RAISEDINNER, BF_RECT);

      // draw small rectangle
      with MarkRect do
      begin
        MarkRect := R;
        InflateRect(MarkRect, -FMargin - 1, -FMargin - 1);
        FCanvas.Brush.Color := clBtnShadow;
        FCanvas.FrameRect(MarkRect);
      end;

      // draw default text
      SetBkMode(FCanvas.Handle, TRANSPARENT);
      DrawText(FCanvas.Handle, PChar(FDefaultText), Length(FDefaultText), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end
    else
    begin
      if GetCellRect(Index, R) then
      begin
        if Index < DefaultColorCount then CellColor := TColor(DefaultColors[Index].Color)
                                     else CellColor := TColor(SysColors[Index - DefaultColorCount].Color);
        FCanvas.Pen.Color := clGray;
        // fill background
        if (FSelectedIndex = Index) and (FHoverIndex <> Index) then FCanvas.Brush.Color := clBtnHighlight
                                                               else FCanvas.Brush.Color := clBtnFace;
        FCanvas.FillRect(R);

        // draw button
        if (FSelectedIndex = Index) or
           ((FHoverIndex = Index) and (csLButtonDown in ControlState)) then DrawEdge(FCanvas.Handle, R, BDR_SUNKENOUTER, BF_RECT)
                                                                       else
          if FHoverIndex = Index then DrawEdge(FCanvas.Handle, R, BDR_RAISEDINNER, BF_RECT);

        FCanvas.Brush.Color := CellColor;

        // draw the cell colour
        InflateRect(R, -(FMargin + 1), -(FMargin + 1));
        FCanvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
      end;
    end;
end;
         
//------------------------------------------------------------------------------

procedure TColorPopup.DrawComb(Canvas: TCanvas; X, Y: Integer; Size: Integer);

// draws one single comb at position X, Y and with size Size
// fill color must already be set on call

var I: Integer;
    P: array[0..5] of TPoint;

begin
  for I := 0 to 5 do
  begin
    P[I].X := Round(FCombCorners[I].X * Size + X);
    P[I].Y := Round(FCombCorners[I].Y * Size + Y);
  end;
  Canvas.Polygon(P);
end;

//------------------------------------------------------------------------------

procedure TColorPopup.DrawCombControls;

var I, Index: Integer;
    XOffs, YOffs,
    Count: Integer;
    dColor: Single;
    OffScreen: TBitmap;
    {$ifdef DEBUG}
      R: TRect;
    {$endif}

begin
  // to make the painting (and selecting) flicker free we use an offscreen
  // bitmap here
  OffScreen := TBitmap.Create;
  try
    OffScreen.Width := Width;
    OffScreen.Height := FColorCombRect.Bottom - FColorCombRect.Top +
                        FBWCombRect.Bottom - FBWCombRect.Top + 2 * FMargin;

    with OffScreen.Canvas do
    begin
      Brush.Color := clBtnFace;
      FillRect(ClipRect);
      Pen.Style := psClear;
      // draw color comb from FColorCombs array
      XOffs := FRadius + FColorCombRect.Left;
      YOffs := FRadius;

      // draw the combs
      for I := 0 to High(FColorCombs) do
      begin
        Brush.Color := FColorCombs[I].Color;
        DrawComb(OffScreen.Canvas, FColorCombs[I].Position.X + XOffs, FColorCombs[I].Position.Y + YOffs, FCombSize);
      end;

      // mark selected comb
      if FCustomIndex > 0 then
      begin
        Index := FCustomIndex - 1;
        Pen.Style := psSolid;
        Pen.Mode := pmXOR;
        Pen.Color := clWhite;
        Pen.Width := 2;
        Brush.Style := bsClear;
        DrawComb(OffScreen.Canvas, FColorCombs[Index].Position.X + XOffs, FColorCombs[Index].Position.Y + YOffs, FCombSize);
        Pen.Style := psClear;
        Pen.Mode := pmCopy;
        Pen.Width := 1;
      end;

      // draw white-to-black combs
      XOffs := FColorCombRect.Left;
      YOffs := FColorCombRect.Bottom - FColorCombRect.Top - 4;
      // brush is automatically reset to bsSolid
      for I := 0 to High(FBWCombs) do
      begin
        Brush.Color := FBWCombs[I].Color;
        if (I>=0) and (i <= High(FBWCombs))
          then DrawComb(OffScreen.Canvas, FBWCombs[I].Position.X + XOffs, FBWCombs[I].Position.Y + YOffs, 2 * FCombSize)
          else DrawComb(OffScreen.Canvas, FBWCombs[I].Position.X + XOffs, FBWCombs[I].Position.Y + YOffs, FCombSize);
      end;

      // mark selected comb 
      if FCustomIndex < 0 then
      begin
        Index := -(FCustomIndex + 1);
        Pen.Style := psSolid;
        Pen.Mode := pmXOR;
        Pen.Color := clWhite;
        Pen.Width := 2;
        Brush.Style := bsClear;
        if (Index >= 0) and (Index <= High(FBWCombs))
          then DrawComb(OffScreen.Canvas, FBWCombs[Index].Position.X + XOffs, FBWCombs[Index].Position.Y + YOffs, 2 * FCombSize)
          else DrawComb(OffScreen.Canvas, FBWCombs[Index].Position.X + XOffs, FBWCombs[Index].Position.Y + YOffs, FCombSize);
        Pen.Style := psClear;
        Pen.Mode := pmCopy;
        Pen.Width := 1;
      end;

      // center-color trackbar
      XOffs := FSliderRect.Left;
      YOffs := FSliderRect.Top - FColorCombRect.Top;
      Count := FSliderRect.Bottom - FSliderRect.Top - 1;
      dColor := 255 / Count;
      Pen.Style := psSolid;
      // b&w ramp
      for I := 0 to Count do
      begin
        Pen.Color := RGB(Round((Count - I) * dColor),
                         Round((Count - I) * dColor),
                         Round((Count - I) * dColor));
        MoveTo(XOffs, YOffs + I);
        LineTo(XOffs + 10, YOffs + I);
      end;

      // marker
      Inc(XOffs, 11);
      Inc(YOffs, Round(Count * (1 - FCenterIntensity)));
      Brush.Color := clBlack;
      Polygon([Point(XOffs, YOffs), Point(XOffs + 5, YOffs - 3), Point(XOffs + 5, YOffs + 3)]);

      {$ifdef DEBUG}
        Brush.Color := clRed;
        R := FColorCombRect;
        OffsetRect(R, 0, - FColorCombRect.Top);
        FrameRect(R);
        R := FBWCombRect;
        OffsetRect(R, 0, - FColorCombRect.Top);
        FrameRect(R);
        R := FSliderRect;
        OffsetRect(R, 0, - FColorCombRect.Top);
        FrameRect(R);
      {$endif}

      Pen.Style := psClear;
    end;
    // finally put the drawing on the screen
    FCanvas.Draw(0, FColorCombRect.Top, OffScreen);
  finally
    Offscreen.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.WMPaint(var Message: TWMPaint);

var PS: TPaintStruct;
    I: Cardinal;
    R: TRect;
    SeparatorTop: Integer;

begin
  if Message.DC = 0 then FCanvas.Handle := BeginPaint(Handle, PS)
                    else FCanvas.Handle := Message.DC;
  try
    // use system default font for popup text 
    FCanvas.Font.Handle := GetStockObject(DEFAULT_GUI_FONT);
    if FColorCombs = nil then CalculateCombLayout;

    // default area text
    if Length(FDefaultText) > 0 then DrawCell(DefaultCell);

    // Draw colour cells
    for I := 0 to DefaultColorCount - 1 do DrawCell(I);

    if FShowSysColors then
    begin
      SeparatorTop := FRowCount * FBoxSize + FMargin;
      if Length(FDefaultText) > 0 then Inc(SeparatorTop, FDefaultTextRect.Bottom);
      with FCustomTextRect do DrawSeparator(FMargin + FSpacing, SeparatorTop, Width - FMargin - FSpacing);

      for I := 0 to SysColorCount - 1 do DrawCell(I + DefaultColorCount);
    end;

    // Draw custom text
    if Length(FCustomText) > 0 then DrawCell(CustomCell);

    if FSelectedIndex = CustomCell then DrawCombControls;

    // draw raised window edge (ex-window style WS_EX_WINDOWEDGE is supposed to do this,
    // but for some reason doesn't paint it)
    R := ClientRect;
    DrawEdge(FCanvas.Handle, R, EDGE_RAISED, BF_RECT);
  finally
    FCanvas.Font.Handle := 0; // a stock object never needs to be freed
    FCanvas.Handle := 0;
    if Message.DC = 0 then EndPaint(Handle, PS);
  end;
end;

//------------------------------------------------------------------------------

function TColorPopup.SelectionFromPoint(P: TPoint): Integer;

// determines the button at the given position

begin
  Result := NoCell;

  // first check we aren't in text box
  if (Length(FCustomText) > 0) and PtInRect(FCustomTextRect, P) then Result := CustomCell
                                                                else
    if (Length(FDefaultText) > 0) and PtInRect(FDefaultTextRect, P) then Result := DefaultCell
                                                                    else
    begin
      // take into account text box
      if Length(FDefaultText) > 0 then Dec(P.Y, FDefaultTextRect.Bottom - FDefaultTextRect.Top);

      // Get the row and column
      if P.X > FSpacing then
      begin
        Dec(P.X, FSpacing);
        // take the margin into account, 2 * FMargin is too small while 3 * FMargin
        // is correct, but looks a bit strange (the arrow corner is so small, it isn't
        // really recognized by the eye) hence I took 2.5 * FMargin
        Dec(P.Y, 5 * FMargin div 2);
        if (P.X >= 0) and (P.Y >= 0) then
        begin
          // consider system colors
          if FShowSysColors and ((P.Y div FBoxSize) >= FRowCount) then
          begin
            // here we know the point is out of the default color area, so
            // take the separator line between default and system colors into account
            Dec(P.Y, 3 * FMargin);
            // if we now are back in the default area then the point was originally
            // between both areas and we have therefore to reject a hit
            if (P.Y div FBoxSize) < FRowCount then Exit;
          end;
          Result := GetIndex(P.Y div FBoxSize, P.X div FBoxSize);
        end;
      end;
  end;
end;                          

//------------------------------------------------------------------------------

function TColorPopup.HandleSlider(const Message: TWMMouse): Boolean;

// determines whether the mouse position is within the slider area (result is then True
// else False) and acts accordingly

var Shift: TShiftState;
    dY: Integer;
    R: TRect;

begin
  Result := PtInRect(FSliderRect, Point(Message.XPos, Message.YPos)) and (FSelectionMode = smNone) or
            ((Message.XPos >= FSliderRect.Left) and (Message.XPos <= FSliderRect.Right) and (FSelectionMode = smRamp));
  if Result then
  begin
    Shift := KeysToShiftState(Message.Keys);
    if ssLeft in Shift then
    begin
      FSelectionMode := smRamp;
      // left mouse button pressed -> change the intensity of the center color comb
      dY := FSliderRect.Bottom - FSliderRect.Top;
      FCenterIntensity := 1 - (Message.YPos - FSliderRect.Top) / dY;
      if FCenterIntensity < 0 then FCenterIntensity := 0;
      if FCenterIntensity > 1 then FCenterIntensity := 1;
      FCenterColor.Red := DefCenterColor.Red * FCenterIntensity;
      FCenterColor.Green := DefCenterColor.Green * FCenterIntensity;
      FCenterColor.Blue := DefCenterColor.Blue * FCenterIntensity;
      R := FSliderRect;
      Dec(R.Top, 3);
      Inc(R.Bottom, 3);
      Inc(R.Left, 10);
      InvalidateRect(Handle, @R, False);
      FColorCombs := nil;
      InvalidateRect(Handle, @FColorCombRect, False);
      InvalidateRect(Handle, @FCustomColorRect, False);
      UpdateWindow(Handle);
    end;
  end;
end;

//------------------------------------------------------------------------------

function TColorPopup.PtInComb(Comb: TCombEntry; P: TPoint; Scale: Integer): Boolean;

// simplyfied "PointInPolygon" test, we know a comb is "nearly" a circle...

begin
  Result := (Sqr(Comb.Position.X - P.X) + Sqr(Comb.Position.Y - P.Y)) <= (Scale * Scale);
end;

//------------------------------------------------------------------------------

function TColorPopup.FindBWArea(X, Y: Integer): Integer;

// Looks for a comb at position (X, Y) in the black&white area.
// Result is -1 if nothing could be found else the index of the particular comb
// into FBWCombs.

var I: Integer;
    Pt: TPoint;
    Scale: Integer;

begin
  Result := -1;
  Pt := Point(X - FBWCombRect.Left, Y - FBWCombRect.Top);

  for I := 0 to High(FBWCombs) do
  begin
    if (I >=0) and (I <= High(FBWCombs)) then Scale := FCombSize
                                else Scale := FCombSize div 2;
    if PtInComb(FBWCombs[I], Pt, Scale) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TColorPopup.HandleBWArea(const Message: TWMMouse): Boolean;

// determines whether the mouse position is within the B&W comb area (result is then True
// else False) and acts accordingly

var Index: Integer;
    Shift: TShiftState;

begin
  Result := PtInRect(FBWCombRect, Point(Message.XPos, Message.YPos)) and (FSelectionMode in [smNone, smBW]);
  if Result then
  begin
    Shift := KeysToShiftState(Message.Keys);
    if ssLeft in Shift then
    begin
      FSelectionMode := smBW;
      Index := FindBWArea(Message.XPos, Message.YPos);

      if Index > -1 then
      begin
        // remove selection comb if it was previously in color comb
        if FCustomIndex > 0 then InvalidateRect(Handle, @FColorCombRect, False);
        if FCustomIndex <> -(Index + 1) then
        begin
          FCustomIndex := -(Index + 1);
          InvalidateRect(Handle, @FBWCombRect, False);
          InvalidateRect(Handle, @FCustomColorRect, False);
          UpdateWindow(Handle);
        end;
      end
      else Result := False;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TColorPopup.FindColorArea(X, Y: Integer): Integer;

// Looks for a comb at position (X, Y) in the custom color area.
// Result is -1 if nothing could be found else the index of the particular comb
// into FColorCombs.

var I: Integer;
    Pt: TPoint;

begin
  Result := -1;
  Pt := Point(X - (FRadius + FColorCombRect.Left),
              Y - (FRadius + FColorCombRect.Top));

  for I := 0 to High(FColorCombs) do
  begin
    if PtInComb(FColorCombs[I], Pt, FCombSize div 2) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TColorPopup.HandleColorComb(const Message: TWMMouse): Boolean;

// determines whether the mouse position is within the color comb area (result is then True
// else False) and acts accordingly

var Index: Integer;
    Shift: TShiftState;

begin
  Result := PtInRect(FColorCombRect, Point(Message.XPos, Message.YPos)) and (FSelectionMode in [smNone, smColor]);
  if Result then
  begin
    Shift := KeysToShiftState(Message.Keys);
    if ssLeft in Shift then
    begin
      FSelectionMode := smColor;
      Index := FindColorArea(Message.XPos, Message.YPos);
      if Index > -1 then
      begin
        // remove selection comb if it was previously in b&w comb
        if FCustomIndex < 0 then InvalidateRect(Handle, @FBWCombRect, False);
        if FCustomIndex <> (Index + 1) then
        begin
          FCustomIndex := Index + 1;
          InvalidateRect(Handle, @FColorCombRect, False);
          InvalidateRect(Handle, @FCustomColorRect, False);
          UpdateWindow(Handle);
        end;
      end
      else Result := False;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.HandleCustomColors(var Message: TWMMouse);

begin
  if not HandleSlider(Message) then
    if not HandleBWArea(Message) then
      if not HandleColorComb(Message) then
      begin
        // user has clicked somewhere else, so remove last custom selection
        if FCustomIndex > 0 then InvalidateRect(Handle, @FColorCombRect, False)
                            else
          if FCustomIndex < 0 then InvalidateRect(Handle, @FBWCombRect, False);

        InvalidateRect(Handle, @FCustomColorRect, False);
        FCustomIndex := 0;
        UpdateWindow(Handle);
      end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.WMMouseMove(var Message: TWMMouseMove);

var NewSelection: Integer;

begin
  inherited;
  // determine new hover index
  NewSelection := SelectionFromPoint(Point(Message.XPos, Message.YPos));

  if NewSelection <> FHoverIndex then ChangeHoverSelection(NewSelection);
  if (NewSelection = -1) and
     PtInRect(ClientRect, Point(Message.XPos, Message.YPos)) and
     (csLButtonDown in ControlState) then HandleCustomColors(Message);
end;

//------------------------------------------------------------------------------

procedure TColorPopup.WMLButtonDown(var Message: TWMLButtonDown);

begin
  inherited;

  if PtInRect(ClientRect, Point(Message.XPos, Message.YPos)) then
  begin

    if FHoverIndex <> NoCell then
    begin
      InvalidateCell(FHoverIndex);
      UpdateWindow(Handle);
    end;

    if FHoverIndex = -1 then HandleCustomColors(Message);
  end
  else EndSelection(True); // hide popup window if the user has clicked elsewhere
end;

//------------------------------------------------------------------------------

procedure TColorPopup.ShowPopupAligned;

var Pt: TPoint;
    Parent: TColorPickerButton;
    ParentTop: Integer;
    R: TRect;
    H: Integer;

begin
  HandleNeeded;
  if FSelectedIndex = CustomCell then
  begin
    // make room for the custem color picking area
    R := Rect(FWindowRect.Left, FWindowRect.Bottom - 3, FWindowRect.Right, FWindowRect.Bottom);
    H := FBWCombRect.Bottom + 2 * FMargin;
  end
  else
  begin
    // hide the custem color picking area
    R := Rect(FWindowRect.Left, FWindowRect.Bottom - 3, FWindowRect.Right, FWindowRect.Bottom);
    H := FWindowRect.Bottom;
  end;
  // to ensure the window frame is drawn correctly we invalidate the lower bound explicitely
  InvalidateRect(Handle, @R, True);

  // Make sure the window is still entirely visible and aligned.
  // There's no VCL parent window as this popup is a child of the desktop,
  // but we have the owner and get the parent from this.
  Parent := TColorPickerButton(Owner);
  Pt := Parent.Parent.ClientToScreen(Point(Parent.Left - 1, Parent.Top + Parent.Height));
  if (Pt.y + H) > Screen.Height then Pt.y := Screen.Height - H;
  ParentTop := Parent.Parent.ClientToScreen(Point(Parent.Left, Parent.Top)).y;
  if Pt.y  <  ParentTop then Pt.y := ParentTop - H;
  if (Pt.x + Width) > Screen.Width then Pt.x := Screen.Width - Width;
  if Pt.x < 0 then Pt.x := 0;
  SetWindowPos(Handle, HWND_TOPMOST, Pt.X, Pt.Y, FWindowRect.Right, H, SWP_SHOWWINDOW);
end;

//------------------------------------------------------------------------------

procedure TColorPopup.ChangeSelection(NewSelection: Integer);

begin
  if NewSelection <> NoCell then
  begin
    if FSelectedIndex <> NoCell then InvalidateCell(FSelectedIndex);
    FSelectedIndex := NewSelection;
    if FSelectedIndex <> NoCell then InvalidateCell(FSelectedIndex);

    if FSelectedIndex = CustomCell then ShowPopupAligned;
  end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.WMLButtonUp(var Message: TWMLButtonUp);

var NewSelection: Integer;
    LastMode: TSelectionMode;

begin
  inherited;
  // determine new selection index
  NewSelection := SelectionFromPoint(Point(Message.XPos, Message.YPos));
  LastMode := FSelectionMode;
  FSelectionMode := smNone;
  if (NewSelection <> NoCell) or
     ((FSelectedIndex = CustomCell) and (FCustomIndex <> 0)) then
  begin
    ChangeSelection(NewSelection);
    if ((FSelectedIndex = CustomCell) and (LastMode in [smColor, smBW])) or
       (FSelectedIndex <> NoCell) and
       (FSelectedIndex <> CustomCell) then EndSelection(False)
                                      else SetCapture(TColorPickerButton(Owner).FPopupWnd);
  end
  else
    // we need to restore the mouse capturing, else the utility window will loose it
    // (safety feature of Windows?)
    SetCapture(TColorPickerButton(Owner).FPopupWnd);
end;

//------------------------------------------------------------------------------

function TColorPopup.GetIndex(Row, Col: Integer): Integer;

begin
  Result := NoCell;
  if ((Row = CustomCell) or (Col = CustomCell)) and
     (Length(FCustomText) > 0) then Result := CustomCell
                                else
    if ((Row = DefaultCell) or (Col = DefaultCell)) and
        (Length(FDefaultText) > 0) then Result := DefaultCell
                                   else
      if (Col in [0..FColumnCount - 1]) and (Row >= 0) then
      begin

        if Row < FRowCount then
        begin
          Result := Row * FColumnCount + Col;
          // consider not fully filled last row
          if Result >= DefaultColorCount then Result := NoCell;
        end
        else
          if FShowSysColors then
          begin
            Dec(Row, FRowCount);
            if Row < FSysRowCount then
            begin
              Result := Row * FColumnCount + Col;
              // consider not fully filled last row
              if Result >= SysColorCount then Result := NoCell
                                         else Inc(Result, DefaultColorCount);
            end;
          end;
      end;
end;

//------------------------------------------------------------------------------

function TColorPopup.GetRow(Index: Integer): Integer;

begin
  if (Index = CustomCell) and (Length(FCustomText) > 0) then Result := CustomCell
                                                        else
    if (Index = DefaultCell) and (Length(FDefaultText) > 0 ) then Result := DefaultCell
                                                             else Result := Index div FColumnCount;
end;

//------------------------------------------------------------------------------

function TColorPopup.GetColumn(Index: Integer): Integer;

begin
  if (Index = CustomCell) and (Length(FCustomText) > 0) then Result := CustomCell
                                                        else
    if (Index = DefaultCell) and (Length(FDefaultText) > 0 ) then Result := DefaultCell
                                                             else Result := Index mod FColumnCount;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.SelectColor(Color: TColor);

// looks up the given color in our lists and sets the proper indices

var I: Integer;
    C: COLORREF;
    found: Boolean;

begin
  found := False;

  // handle special colors first
  if Color = clNone then FSelectedIndex := NoCell
                    else
    if Color = clDefault then FSelectedIndex := DefaultCell
                         else
    begin
      // if the incoming color is one of the predefined colors (clBtnFace etc.) and
      // system colors are active then start looking in the system color list
      if FShowSysColors and (Color < 0) then
      begin
        for I := 0 to SysColorCount - 1 do
          if TColor(SysColors[I].Color) = Color then
          begin
            FSelectedIndex := I + DefaultColorCount;
            found := True;
            Break;
          end;
      end;                                     

      if not found then
      begin
        C := ColorToRGB(Color);
        for I := 0 to DefaultColorCount - 1 do
          // only Borland knows why the result of ColorToRGB is Longint not COLORREF,
          // in order to make the compiler quiet I need a Longint cast here
          if ColorToRGB(DefaultColors[I].Color) = Longint(C) then
          begin
            FSelectedIndex := I;
            found := True;
            Break;
          end;

        // look in the system colors if not already done yet
        if not found and FShowSysColors and (Color >= 0) then
        begin
          for I := 0 to SysColorCount - 1 do
          begin
            if ColorToRGB(TColor(SysColors[I].Color)) = Longint(C) then
            begin
              FSelectedIndex := I + DefaultColorCount;
              found := True;
              Break;
            end;
          end;
        end;

        if not found then
        begin
          if FColorCombs = nil then CalculateCombLayout;
          FCustomIndex := 0;
          FSelectedIndex := NoCell;
          for I := 0 to High(FBWCombs) do
            if FBWCombs[I].Color = C then
            begin
              FSelectedIndex := CustomCell;
              FCustomIndex := -(I + 1);
              found := True;
              Break;
            end;

          if not found then
            for I := 0 to High(FColorCombs) do
              if FColorCombs[I].Color = C then
              begin
                FSelectedIndex := CustomCell;
                FCustomIndex := I + 1;
                Break;
              end;
        end;
      end;
    end;
end;

//------------------------------------------------------------------------------

function TColorPopup.GetCellRect(Index: Integer; var Rect: TRect): Boolean;

// gets the dimensions of the colour cell given by Index

begin
  Result := False;
  if Index = CustomCell then
  begin
    Rect := FCustomTextRect;
    Result := True;
  end
  else
    if Index = DefaultCell then
    begin
      Rect := FDefaultTextRect;
      Result := True;
    end
    else
      if Index >= 0 then
      begin
        Rect.Left := GetColumn(Index) * FBoxSize + FMargin + FSpacing;
        Rect.Top := GetRow(Index) * FBoxSize + 2 * FMargin;

        // move everything down if we are displaying a default text area
        if Length(FDefaultText) > 0 then Inc(Rect.Top, FDefaultTextRect.Bottom - 2 * FMargin);

        // move everything further down if we consider syscolors
        if Index >= DefaultColorCount then Inc(Rect.Top, 3 * FMargin);

        Rect.Right := Rect.Left + FBoxSize;
        Rect.Bottom := Rect.Top + FBoxSize;

        Result := True;
      end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.AdjustWindow;

// works out an appropriate size and position of this window

var TextSize,
    DefaultSize: TSize;
    DC: HDC;
    WHeight: Integer;

begin
  // If we are showing a custom or default text area, get the font and text size.
  if (Length(FCustomText) > 0) or (Length(FDefaultText) > 0) then
  begin
    DC := GetDC(Handle);
    FCanvas.Handle := DC;
    FCanvas.Font.Handle := GetStockObject(DEFAULT_GUI_FONT);
    try
      // Get the size of the custom text (if there IS custom text)
      TextSize.cx := 0;
      TextSize.cy := 0;
      if Length(FCustomText) > 0 then TextSize := FCanvas.TextExtent(FCustomText);

      // Get the size of the default text (if there IS default text)
      if Length(FDefaultText) > 0 then
      begin
        DefaultSize := FCanvas.TextExtent(FDefaultText);
        if DefaultSize.cx > TextSize.cx then TextSize.cx := DefaultSize.cx;
        if DefaultSize.cy > TextSize.cy then TextSize.cy := DefaultSize.cy;
      end;

      Inc(TextSize.cx, 2 * FMargin);
      Inc(TextSize.cy, 4 * FMargin + 2);

    finally
      FCanvas.Font.Handle := 0;
      FCanvas.Handle := 0;
      ReleaseDC(Handle, DC);
    end;
  end;

  // Get the number of columns and rows
  FColumnCount := 8;
  FRowCount := DefaultColorCount div FColumnCount;
  if (DefaultColorCount mod FColumnCount) <> 0 then Inc(FRowCount);

  FWindowRect := Rect(0, 0,
                      FColumnCount * FBoxSize + 2 * FMargin + 2 * FSpacing,
                      FRowCount * FBoxSize + 4 * FMargin);

  FRadius := Trunc(7 * (FColumnCount * FBoxSize) / 16);
  FCombSize := Round(0.5 + FRadius / (FLevels - 1));

  // if default text, then expand window if necessary, and set text width as
  // window width
  if Length(FDefaultText) > 0 then
  begin
    if TextSize.cx > (FWindowRect.Right - FWindowRect.Left) then FWindowRect.Right := FWindowRect.Left + TextSize.cx;
    TextSize.cx := FWindowRect.Right - FWindowRect.Left - 2 * FMargin;

    // work out the text area
    FDefaultTextRect := Rect(FMargin + FSpacing, 2 * FMargin, FMargin -FSpacing + TextSize.cx, 2 * FMargin + TextSize.cy);
    Inc(FWindowRect.Bottom, FDefaultTextRect.Bottom - FDefaultTextRect.Top + 2 * FMargin);
  end;

  if FShowSysColors then
  begin
    FSysRowCount := SysColorCount div FColumnCount;
    if (SysColorCount mod FColumnCount) <> 0 then Inc(FSysRowCount);
    Inc(FWindowRect.Bottom, FSysRowCount * FBoxSize + 2 * FMargin);
  end;                               
  
  // if custom text, then expand window if necessary, and set text width as
  // window width
  if Length(FCustomText) > 0 then
  begin
    if TextSize.cx > (FWindowRect.Right - FWindowRect.Left) then FWindowRect.Right := FWindowRect.Left + TextSize.cx;
    TextSize.cx := FWindowRect.Right - FWindowRect.Left - 2 * FMargin;

    // work out the text area
    WHeight := FWindowRect.Bottom - FWindowRect.Top;
    FCustomTextRect := Rect(FMargin + FSpacing,
                            WHeight,
                            FMargin - FSpacing + TextSize.cx,
                            WHeight + TextSize.cy);
    // precalculate also the small preview box for custom color selection for fast updates
    FCustomColorRect := Rect(0, 0, FBoxSize, FBoxSize);
    InflateRect(FCustomColorRect, -(FMargin + 1), -(FMargin + 1));
    OffsetRect(FCustomColorRect,
               FCustomTextRect.Right - FBoxSize - FMargin,
               FCustomTextRect.Top + (FCustomTextRect.Bottom - FCustomTextRect.Top - FCustomColorRect.Bottom - FMargin - 1) div 2);

    Inc(FWindowRect.Bottom, FCustomTextRect.Bottom - FCustomTextRect.Top + 2 * FMargin);
  end;

  // work out custom color choice area (color combs) (FWindowRect covers only the always visible part)
  FColorCombRect := Rect(FMargin + FSpacing,
                         FWindowRect.Bottom,
                         FMargin + FSpacing + 2 * FRadius,
                         FWindowRect.Bottom + 2 * FRadius);
  // work out custom color choice area (b&w combs)
  FBWCombRect := Rect(FColorCombRect.Left,
                      FColorCombRect.Bottom - 4,
                      Round(17 * FCombSize * cos(Pi / 6) / 2) + 6 * FCombSize,
                      FColorCombRect.Bottom + 2 * FCombSize);
  // work out slider area
  FSliderRect := Rect(FColorCombRect.Right,
                      FColorCombRect.Top + FCombSize,
                      FColorCombRect.Right + 20,
                      FColorCombRect.Bottom - FCombSize);

  // set the window size
  with FWindowRect do SetBounds(Left, Top, Right - Left, Bottom - Top);
end;

//------------------------------------------------------------------------------

procedure TColorPopup.ChangeHoverSelection(Index: Integer);

begin
  if not FShowSysColors and (Index >= DefaultColorCount) or
     (Index >= (DefaultColorCount + SysColorCount)) then Index := NoCell;

  // remove old hover selection
  InvalidateCell(FHoverIndex);

  FHoverIndex := Index;
  InvalidateCell(FHoverIndex);
  UpdateWindow(Handle);
end;

//------------------------------------------------------------------------------

procedure TColorPopup.EndSelection(Cancel: Boolean);

begin
  with Owner as TColorPickerButton do
  begin
    if not Cancel then
    begin
      if FSelectedIndex > -1 then
        if FSelectedIndex < DefaultColorCount then SelectionColor := TColor(DefaultColors[FSelectedIndex].Color)
                                              else SelectionColor := TColor(SysColors[FSelectedIndex - DefaultColorCount].Color)
                             else
        if FSelectedIndex = CustomCell then
        begin
          if FCustomIndex < 0 then SelectionColor := FBWCombs[-(FCustomIndex + 1)].Color
                              else
            if FCustomIndex > 0 then SelectionColor := FColorCombs[FCustomIndex - 1].Color;
        end
        else DoDefaultEvent;
    end;
    DroppedDown := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.WMKillFocus(var Message: TWMKillFocus);

begin
  inherited;
  (Owner as TColorPickerButton).DroppedDown := False;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.CalculateCombLayout;

// fills arrays with centers and colors for the custom color and black & white combs,
// these arrays are used to quickly draw the combx and do hit tests

  //--------------- local functions -----------------------

  function RGBFromFloat(Color: TRGB): COLORREF;

  begin
    Result := RGB(Round(255 * Color.Red), Round(255 * Color.Green), Round(255 * Color.Blue));
  end;

  //-------------------------------------------------------

  function GrayFromIntensity(Intensity: Byte): COLORREF;

  begin
    Result := RGB(Intensity, Intensity, Intensity);
  end;

  //--------------- end local functions -------------------

var CurrentIndex: Cardinal;
    CurrentColor: TRGB;
    CurrentPos: TFloatPoint;
    CombCount: Cardinal;
    I, J,
    Level: Cardinal;
    Scale: Extended;

    // triangle vars
    Pos1, Pos2: TFloatPoint;
    dPos1, dPos2: TFloatPoint;
    Color1, Color2: TRGB;
    dColor1, dColor2: TRGB;
    dPos: TFloatPoint;
    dColor: TRGB;

begin
  // this ensures the radius and comb size is set correctly
  HandleNeeded;
  if FLevels < 1 then FLevels := 1;
  // To draw perfectly aligned combs we split the final comb into six triangles (sextants)
  // and calculate each separately. The center comb is stored as first entry in the array
  // and will not considered twice (as with the other shared combs too).
  //
  // The way used here for calculation of the layout seems a bit complicated, but works
  // correctly for all cases (even if the comb corners are rotated).

  // initialization
  CurrentIndex := 0;
  CurrentColor := FCenterColor;

  // number of combs can be calculated by:
  // 1 level: 1 comb (the center)
  // 2 levels: 1 comb + 6 combs
  // 3 levels: 1 comb + 1 * 6 combs + 2 * 6 combs
  // n levels: 1 combs + 1 * 6 combs + 2 * 6 combs + .. + (n-1) * 6 combs
  // this equals to 1 + 6 * (1 + 2 + 3 + .. + (n-1)), by using Gauss' famous formula we get:
  // Count = 1 + 6 * (((n-1) * n) / 2)
  // Because there's always an even number involved (either n or n-1) we can use an integer div
  // instead of a float div here...
  CombCount := 1 + 6 * (((FLevels - 1) * FLevels) div 2);
  SetLength(FColorCombs, CombCount);

  // store center values
  FColorCombs[CurrentIndex].Position := Point(0, 0);
  FColorCombs[CurrentIndex].Color := RGBFromFloat(CurrentColor);
  Inc(CurrentIndex);

  // go out off here if there are not further levels to draw
  if FLevels < 2 then Exit;

  // now go for each sextant, the generic corners have been calculated already at creation
  // time for a comb with diameter 1
  //              ------
  //             /\  1 /\
  //            /  \  /  \
  //           / 2  \/  0 \
  //           -----------
  //           \ 3  /\  5 /
  //            \  /  \  /
  //             \/  4 \/
  //              ------

  for I := 0 to 5 do
  begin
    // initialize triangle corner values
    //
    //                center (always at 0,0)
    //                 /\
    //     dPos1      /  \    dPos2
    //     dColor1   /    \   dColor2
    //              / dPos \
    //             /--------\ (span)
    //            /  dColor  \
    //           /____________\
    //    comb corner 1     comb corner 2
    //
    // Pos1, Pos2, Color1, Color2 are running terms for both sides of the triangle
    // incremented by dPos1/2 and dColor1/2.
    // dPos and dColor are used to interpolate a span between the values just mentioned.
    //
    // The small combs are actually oriented with corner 0 at top (i.e. mirrored at y = x,
    // compared with the values in FCombCorners), we can achieve that by simply exchanging
    // X and Y values.

    Scale := 2 * FRadius * cos(Pi / 6);
    Pos1.X := FCombCorners[I].Y * Scale;
    Pos1.Y := FCombCorners[I].X * Scale;
    Color1 := DefColors[I];
    if I = 5 then
    begin
      Pos2.X := FCombCorners[0].Y * Scale;
      Pos2.Y := FCombCorners[0].X * Scale;
      Color2 := DefColors[0];
    end
    else
    begin
      Pos2.X := FCombCorners[I + 1].Y * Scale;
      Pos2.Y := FCombCorners[I + 1].X * Scale;
      Color2 := DefColors[I + 1];
    end;
    dPos1.X := Pos1.X / (FLevels - 1);
    dPos1.Y := Pos1.Y / (FLevels - 1);
    dPos2.X := Pos2.X / (FLevels - 1);
    dPos2.Y := Pos2.Y / (FLevels - 1);

    dColor1.Red := (Color1.Red - FCenterColor.Red) / (FLevels - 1);
    dColor1.Green := (Color1.Green - FCenterColor.Green) / (FLevels - 1);
    dColor1.Blue := (Color1.Blue - FCenterColor.Blue) / (FLevels - 1);
    
    dColor2.Red := (Color2.Red - FCenterColor.Red) / (FLevels - 1);
    dColor2.Green := (Color2.Green - FCenterColor.Green) / (FLevels - 1);
    dColor2.Blue := (Color2.Blue - FCenterColor.Blue) / (FLevels - 1);

    Pos1 := DefCenter;
    Pos2 := DefCenter;
    Color1 := FCenterColor;
    Color2 := FCenterColor;

    // Now that we have finished the initialization for this step we'll go
    // through a loop for each level to calculate the spans.
    // We can ignore level 0 (as this is the center we already have determined) as well
    // as the last step of each span (as this is the start value in the next triangle and will
    // be calculated there). We have, though, take them into the calculation of the running terms. 
    for Level := 0 to FLevels - 1 do
    begin
      if Level > 0 then
      begin
        // initialize span values
        dPos.X := (Pos2.X - Pos1.X) / Level;
        dPos.Y := (Pos2.Y - Pos1.Y) / Level;
        dColor.Red := (Color2.Red - Color1.Red) / Level;
        dColor.Green := (Color2.Green - Color1.Green) / Level;
        dColor.Blue := (Color2.Blue - Color1.Blue) / Level;
        CurrentPos := Pos1;
        CurrentColor := Color1;

        for J := 0 to Level - 1 do
        begin
          // store current values in the array
          FColorCombs[CurrentIndex].Position.X := Round(CurrentPos.X);
          FColorCombs[CurrentIndex].Position.Y := Round(CurrentPos.Y);
          FColorCombs[CurrentIndex].Color := RGBFromFloat(CurrentColor);
          Inc(CurrentIndex);

          // advance in span
          CurrentPos.X := CurrentPos.X + dPos.X;
          CurrentPos.Y := CurrentPos.Y + dPos.Y;

          CurrentColor.Red := CurrentColor.Red + dColor.Red;
          CurrentColor.Green := CurrentColor.Green + dColor.Green;
          CurrentColor.Blue := CurrentColor.Blue + dColor.Blue;
        end;
      end;
      // advance running terms
      Pos1.X := Pos1.X + dPos1.X;
      Pos1.Y := Pos1.Y + dPos1.Y;
      Pos2.X := Pos2.X + dPos2.X;
      Pos2.Y := Pos2.Y + dPos2.Y;

      Color1.Red := Color1.Red + dColor1.Red;
      Color1.Green := Color1.Green + dColor1.Green;
      Color1.Blue := Color1.Blue + dColor1.Blue;

      Color2.Red := Color2.Red + dColor2.Red;
      Color2.Green := Color2.Green + dColor2.Green;
      Color2.Blue := Color2.Blue + dColor2.Blue;
    end;
  end;

  // second step is to build a list for the black & white area
  // 17 entries from pure white to pure black
  // the first and last are implicitely of double comb size
  SetLength(FBWCombs, 17);
  CurrentIndex := 0;
  FBWCombs[CurrentIndex].Color := GrayFromIntensity(255);
  FBWCombs[CurrentIndex].Position := Point(FCombSize, FCombSize);
  Inc(CurrentIndex);

  CurrentPos.X := 3 * FCombSize;
  CurrentPos.Y := 3 * (FCombSize div 4);
  dPos.X := Round(FCombSize * cos(Pi / 6) / 2);
  dPos.Y := Round(FCombSize * (1 + sin(Pi / 6)) / 2);
  for I := 0 to 14 do
  begin
    FBWCombs[CurrentIndex].Color := GrayFromIntensity((16 - CurrentIndex) * 15);
    if Odd(I) then FBWCombs[CurrentIndex].Position := Point(Round(CurrentPos.X + I * dPos.X), Round(CurrentPos.Y + dPos.Y))
              else FBWCombs[CurrentIndex].Position := Point(Round(CurrentPos.X + I * dPos.X), Round(CurrentPos.Y));
    Inc(CurrentIndex);
  end;
  FBWCombs[CurrentIndex].Color := 0;
  FBWCombs[CurrentIndex].Position := Point(Round(CurrentPos.X + 16 * dPos.X + FCombSize), FCombSize);
end;

//-----------------------------------------------------------------------------

procedure TColorPopup.CreateParams(var Params: TCreateParams);

begin
  inherited CreateParams(Params);
  with Params do
  begin
    WndParent := GetDesktopWindow;
    Style := WS_CLIPSIBLINGS or WS_CHILD;
    ExStyle := WS_EX_TOPMOST or WS_EX_TOOLWINDOW;
    WindowClass.Style := CS_DBLCLKS or CS_SAVEBITS;
  end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.CreateWnd;

begin
  inherited;
  AdjustWindow;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.SetSpacing(Value: Integer);

begin
  if Value < 0 then Value := 0;
  if FSpacing <> Value then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.InvalidateCell(Index: Integer);

var R: TRect;

begin
  if GetCellRect(Index, R) then InvalidateRect(Handle, @R, False);
end;

//------------------------------------------------------------------------------

function TColorPopup.GetHint(Cell: Integer): String;

begin
  Result := '';
  if Assigned(TColorPickerButton(Owner).FOnHint) then TColorPickerButton(Owner).FOnHint(Owner, Cell, Result);
end;

//------------------------------------------------------------------------------

procedure TColorPopup.CMHintShow(var Message: TMessage);

// determine hint message (tooltip) and out-of-hint rect

var Index: Integer;
    r, g, b: Byte;
    Colors: TCombArray;

begin
  Colors := nil;
  with TCMHintShow(Message) do
  begin
    if not TColorPickerButton(Owner).ShowHint then Message.Result := 1
                                              else
    begin
      with HintInfo^ do
      begin
        // show that we want a hint
        Result := 0;
        // predefined colors always get their names as tooltip
        if FHoverIndex >= 0 then
        begin
          GetCellRect(FHoverIndex, CursorRect);
          if FHoverIndex < DefaultColorCount then HintStr := DefaultColors[FHoverIndex].Name
                                             else HintStr := SysColors[FHoverIndex - DefaultColorCount].Name;
        end
        else
          // both special cells get their hint either from the application by
          // means of the OnHint event or the hint string of the owner control
          if (FHoverIndex = DefaultCell) or
             (FHoverIndex = CustomCell) then
          begin
            HintStr := GetHint(FHoverIndex);
            if HintStr = '' then HintStr := TColorPickerButton(Owner).Hint
                            else
            begin
              // if the application supplied a hint by event then deflate the cursor rect
              // to the belonging button
              if FHoverIndex = DefaultCell then CursorRect := FDefaultTextRect
                                           else CursorRect := FCustomTextRect;
            end;
          end
          else
          begin
            // well, mouse is not hovering over one of the buttons, now check for
            // the ramp and the custom color areas
            if PtInRect(FSliderRect, Point(CursorPos.X, CursorPos.Y)) then
            begin
              // in case of the intensity slider we show the current intensity
              HintStr := Format('Intensity: %d%%', [Round(100 * FCenterIntensity)]);
              CursorRect := Rect(FSliderRect.Left, CursorPos.Y - 2,
                                 FSliderRect.Right, CursorPos.Y + 2);
              HintPos := ClientToScreen(Point(FSliderRect.Right, CursorPos.Y - 8));
              HideTimeout := 5000;
              CursorRect := Rect(FSliderRect.Left, CursorPos.Y,
                                 FSliderRect.Right, CursorPos.Y);
            end
            else
            begin
              Index := -1;
              if PtInRect(FBWCombRect, Point(CursorPos.X, CursorPos.Y)) then
              begin
                // considering black&white area...
                if csLButtonDown in ControlState then Index := -(FCustomIndex + 1)
                                                 else Index := FindBWArea(CursorPos.X, CursorPos.Y);
                Colors := FBWCombs;
              end
              else
                if PtInRect(FColorCombRect, Point(CursorPos.X, CursorPos.Y)) then
                begin
                  // considering color comb area...
                  if csLButtonDown in ControlState then Index := FCustomIndex - 1
                                                   else Index := FindColorArea(CursorPos.X, CursorPos.Y);
                  Colors := FColorCombs;
                end;

              if (Index > -1) and (Colors <> nil) then
              begin
                with Colors[Index] do
                begin
                  r := GetRValue(Color);
                  g := GetGValue(Color);
                  b := GetBValue(Color);
                end;
                HintStr := Format('red: %d, green: %d, blue: %d', [r, g, b]);
                HideTimeout := 5000;
              end
              else HintStr := GetHint(NoCell);

              // make the hint follow the mouse
              CursorRect := Rect(CursorPos.X, CursorPos.Y,
                                 CursorPos.X, CursorPos.Y);
            end;
          end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TColorPopup.SetSelectedColor(const Value: TColor);

begin
  FCurrentColor := Value;
  SelectColor(Value);
end;

//----------------- TColorPickerButton ------------------------------------------

constructor TColorPickerButton.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  FSelectionColor := clBlack;
  FColorPopup := TColorPopup.Create(Self);
  // park the window somewhere it can't be seen
  FColorPopup.Left := -1000;
  FPopupWnd := AllocateHWnd(PopupWndProc);

//  FGlyph := TButtonGlyph.Create;
//  TButtonGlyph(FGlyph).OnChange := GlyphChanged;
  SetBounds(0, 0, 45, 22);
  FDropDownWidth := 15;
  ControlStyle := [csCaptureMouse, csDoubleClicks];
  ParentFont := True;
  Color := clBtnFace;
  FSpacing := 4;
  FMargin := -1;
  FLayout := blGlyphLeft;
  FTransparent := True;
  FIndicatorBorder := ibFlat;

  Inc(ButtonCount);
end;

//-----------------------------------------------------------------------------

destructor TColorPickerButton.Destroy;

begin
  DeallocateHWnd(FPopupWnd);
  Dec(ButtonCount);
  // the color popup window will automatically be freed since the button is the owner
  // of the popup
//  TButtonGlyph(FGlyph).Free;
  inherited Destroy;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.PopupWndProc(var Msg: TMessage);

var P: TPoint;

begin
  case Msg.Msg of
    WM_MOUSEFIRST..WM_MOUSELAST:
      begin
        with TWMMouse(Msg) do
        begin
          P := SmallPointToPoint(Pos);
          MapWindowPoints(FPopupWnd, FColorPopup.Handle, P, 1);
          Pos := PointToSmallPoint(P);
        end;
        FColorPopup.WindowProc(Msg);
      end;
    CN_KEYDOWN,
    CN_SYSKEYDOWN:
      FColorPopup.WindowProc(Msg);
  else
    with Msg do
      Result := DefWindowProc(FPopupWnd, Msg, wParam, lParam);
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetDropDownArrowColor(Value: TColor);

begin
  if not (FDropDownArrowColor = Value) then;
  begin
    FDropDownArrowColor := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetDropDownWidth(Value: integer);

begin
  if not (FDropDownWidth = Value) then;
  begin
    FDropDownWidth := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.Paint;

const MAX_WIDTH = 5;
      DownStyles: array[Boolean] of Integer = (BDR_RAISEDINNER, BDR_SUNKENOUTER);
      FillStyles: array[Boolean] of Integer = (BF_MIDDLE, 0);

var PaintRect: TRect;
    ExtraRect: TRect;
    DrawFlags: Integer;
    Offset: TPoint;
    LeftPos: Integer;
//    a, B : Integer;
//    c : TPicLocation;
    thmBtn : TThemedButton;
 {$IFDEF RNQ}
    vImgElm : TRnQThemedElementDtls;
 {$ENDIF RNQ}
begin
  if not Enabled then
  begin
    FState := bsDisabled;
    FDragging := False;
  end
  else
    if (FState = bsDisabled) then
    begin
      if FDown and (GroupIndex <> 0) then FState := bsExclusive
                                     else FState := bsUp;
    end;

  Canvas.Font := Self.Font;
  thmBtn := tbPushButtonNormal;
  // Creates a rectangle that represent the button and the drop down area,
  // determines also the position to draw the arrow...
  PaintRect := Rect(0, 0, Width, Height);
  ExtraRect := Rect(Width - FDropDownWidth, 0, Width, Height);
  LeftPos := (Width - FDropDownWidth) + ((FDropDownWidth + MAX_WIDTH) div 2) - MAX_WIDTH - 1;

  // Determines if the button is a flat or normal button... each uses
  // different painting methods
  if not FFlat then
  begin
    DrawFlags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;

    if FState in [bsDown, bsExclusive] then DrawFlags := DrawFlags or DFCS_PUSHED;

    // Check if the mouse is in the drop down zone. If it is we then check
    // the state of the button to determine the drawing sequence
    if FDropDownZone then
    begin
      if FDroppedDown then
      begin
        // paint pressed Drop Down Button
        DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DRAW_BUTTON_UP);
        DrawFrameControl(Canvas.Handle, ExtraRect, DFC_BUTTON, DRAW_BUTTON_DOWN);
      end
      else
      begin
        // paint depressed Drop Down Button
        DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DRAW_BUTTON_UP);
        DrawFrameControl(Canvas.Handle, ExtraRect, DFC_BUTTON, DRAW_BUTTON_UP);
        DrawButtonSeperatorUp(Canvas);
      end;
    end
    else
    begin
      DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DrawFlags);

      // Determine the type of drop down seperator...
      if (FState in [bsDown, bsExclusive]) then DrawButtonSeperatorDown(Canvas)
                                           else DrawButtonSeperatorUp(Canvas);
    end;
  end
  else
  begin
    if (FState in [bsDown, bsExclusive]) or
       (FMouseInControl and (FState <> bsDisabled)) or
       (csDesigning in ComponentState) then
    begin
      // Check if the mouse is in the drop down zone. If it is we then check
      // the state of the button to determine the drawing sequence
      if FDropDownZone then
      begin
        if FDroppedDown then
        begin
          // Paint pressed Drop Down Button
          DrawEdge(Canvas.Handle, PaintRect, DownStyles[False], FillStyles[FTransparent] or BF_RECT);
          DrawEdge(Canvas.Handle, ExtraRect, DownStyles[True], FillStyles[FTransparent] or BF_RECT);
        end
        else
        begin
          // Paint depressed Drop Down Button
          DrawEdge(Canvas.Handle, PaintRect, DownStyles[False], FillStyles[FTransparent] or BF_RECT);
          DrawEdge(Canvas.Handle, ExtraRect, DownStyles[False], FillStyles[FTransparent] or BF_RECT);
          DrawButtonSeperatorUp(Canvas);
        end;
      end
      else
      begin
        DrawEdge(Canvas.Handle, PaintRect, DownStyles[FState in [bsDown, bsExclusive]], FillStyles[FTransparent] or BF_RECT);

        if (FState in [bsDown, bsExclusive]) then DrawButtonSeperatorDown(Canvas)
                                             else DrawButtonSeperatorUp(Canvas);
      end;
    end
    else
      if not FTransparent then
      begin
        Canvas.Brush.Style := bsSolid;
        Canvas.Brush.Color := Color;
        Canvas.FillRect(PaintRect);
      end;
    InflateRect(PaintRect, -1, -1);
  end;


  if (FState in [bsDown, bsExclusive]) and not (FDropDownZone) then
  begin
    if (FState = bsExclusive) and (not FFlat or not FMouseInControl) then
    begin
      Canvas.Brush.Bitmap := AllocPatternBitmap(clBtnFace, clBtnHighlight);
      Canvas.FillRect(PaintRect);
    end;
    Offset.X := 1;
    Offset.Y := 1;
  end
  else
  begin
    Offset.X := 0;
    Offset.Y := 0;
  end;

//  PaintRect := TButtonGlyph(FGlyph).Draw(Canvas, PaintRect, Offset, Caption, FLayout, FMargin,
 {$IFDEF RNQ}
  vImgElm.ThemeToken := theme.token;
  vImgElm.picIdx := -1;
 {$ENDIF RNQ}
  PaintRect := RnQButtonDraw(Canvas.Handle, Font.Color, PaintRect, Offset, Caption, FLayout, FMargin,
                                         FSpacing, thmBtn, FState, FTransparent,
                                         DrawTextBiDiModeFlags(0),
 {$IFDEF RNQ}
                                         vImgElm,
 {$ENDIF RNQ}
                                         FDropDownWidth);

  // draw color indicator
  Canvas.Brush.Color := FSelectionColor;
  Canvas.Pen.Color := clBtnShadow;

  case FIndicatorBorder of
    ibNone:
      Canvas.FillRect(PaintRect);
    ibFlat:
      with PaintRect do
        Canvas.Rectangle(Left, Top, Right, Bottom);
  else
    if FIndicatorBorder = ibSunken then DrawEdge(Canvas.Handle, PaintRect, BDR_SUNKENOUTER, BF_RECT)
                                   else DrawEdge(Canvas.Handle, PaintRect, BDR_RAISEDINNER, BF_RECT);
    InflateRect(PaintRect, -1, -1);
    Canvas.FillRect(PaintRect);
  end;

  // Draws the arrow for the correct state
  if FState = bsDisabled then
  begin
    Canvas.Pen.Style := psClear;
    Canvas.Brush.Color := clBtnShadow;
  end
  else
  begin
    Canvas.Pen.Color := FDropDownArrowColor;
    Canvas.Brush.Color := FDropDownArrowColor;
  end;

  if FDropDownZone and FDroppedDown or (FState = bsDown) and not (FDropDownZone) then
    DrawTriangle(Canvas, (Height div 2) + 1, LeftPos + 1, MAX_WIDTH)
  else
    DrawTriangle(Canvas, (Height div 2), LeftPos, MAX_WIDTH);
end;


//-----------------------------------------------------------------------------

procedure TColorPickerButton.UpdateTracking;

var P: TPoint;

begin
  if FFlat then
  begin
    if Enabled then
    begin
      GetCursorPos(P);
      FMouseInControl := not (FindDragTarget(P, True) = Self);
      if FMouseInControl then Perform(CM_MOUSELEAVE, 0, 0)
                         else Perform(CM_MOUSEENTER, 0, 0);
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.Loaded;
//var State: TButtonState;
begin
  inherited Loaded;
//  if Enabled then State := bsUp
//             else State := bsDisabled;
//  TButtonGlyph(FGlyph).CreateButtonGlyph(State);
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin
  inherited MouseDown(Button, Shift, X, Y);

  if (Button = mbLeft) and Enabled then
  begin
    // Determine if mouse is currently in the drop down section...
    FDropDownZone := (X > Width - FDropDownWidth);

    // If so display the button in the proper state and display the menu
    if FDropDownZone then
    begin
      if not FDroppedDown then
      begin
        Update;
        DroppedDown := True;
      end;

      // Setting this flag to false is very important, we want the dsUp state to
      // be used to display the button properly the next time the mouse moves in
      FDragging := False;
    end
    else
    begin
      if not FDown then
      begin
        FState := bsDown;
        Invalidate;
      end;

      FDragging := True;
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.MouseMove(Shift: TShiftState; X, Y: Integer);

var NewState: TButtonState;

begin
  inherited MouseMove(Shift, X, Y);
  if FDragging then
  begin
    if not FDown then NewState := bsUp
                 else NewState := bsExclusive;
    if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
      if FDown then NewState := bsExclusive
               else NewState := bsDown;
    if NewState <> FState then
    begin
      FState := NewState;
      Invalidate;
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

var DoClick: Boolean;

begin
  inherited MouseUp(Button, Shift, X, Y);
  if FDragging then
  begin
    FDragging := False;
    DoClick := (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight);
    if FGroupIndex = 0 then
    begin
      // Redraw face in case mouse is captured
      FState := bsUp;
      FMouseInControl := False;
      if DoClick and not (FState in [bsExclusive, bsDown]) then Invalidate;
    end
    else
      if DoClick then
      begin
        SetDown(not FDown);
        if FDown then Repaint;
      end
      else
      begin
        if FDown then FState := bsExclusive;
        Repaint;
      end;
    if DoClick then Click;
    UpdateTracking;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.Click;

begin
  inherited Click;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.DoDefaultEvent;
begin
  if Assigned(FOnDefaultSelect) then FOnDefaultSelect(Self);
end;

//-----------------------------------------------------------------------------

function TColorPickerButton.GetPalette: HPALETTE;
begin
//  Result := Glyph.Palette;
  Result := 0;
end;

//-----------------------------------------------------------------------------
{
function TColorPickerButton.GetGlyph: TBitmap;
begin
//  Result := TButtonGlyph(FGlyph).Glyph;
  Result := NIL;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetGlyph(Value: TBitmap);
begin
//  TButtonGlyph(FGlyph).Glyph := Value;
  Invalidate;
end;

//-----------------------------------------------------------------------------

function TColorPickerButton.GetNumGlyphs: TNumGlyphs;
begin
//  Result := TButtonGlyph(FGlyph).NumGlyphs;
  Result := 1;
end;
}
//-----------------------------------------------------------------------------

procedure TColorPickerButton.DrawButtonSeperatorUp(Canvas: TCanvas);

begin
  with Canvas do
  begin
    Pen.Style := psSolid;
    Brush.Style := bsClear;
    Pen.Color := clBtnHighlight;
    Rectangle(Width - DropDownWidth, 1, Width - DropDownWidth + 1, Height - 1);
    Pen.Color := clBtnShadow;
    Rectangle(Width - DropDownWidth - 1, 1, Width - DropDownWidth, Height - 1);
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.DrawButtonSeperatorDown(Canvas: TCanvas);

begin
  with Canvas do
  begin
    Pen.Style := psSolid;
    Brush.Style := bsClear;
    Pen.Color := clBtnHighlight;
    Rectangle(Width - DropDownWidth + 1, 2, Width - DropDownWidth + 2, Height - 2);
    Pen.Color := clBtnShadow;
    Rectangle(Width - DropDownWidth, 2, Width - DropDownWidth + 1, Height - 2);
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.DrawTriangle(Canvas: TCanvas; Top, Left, Width: Integer);
begin
  if Odd(Width) then Inc(Width);
  Canvas.Polygon([Point(Left, Top),
                  Point(Left + Width, Top),
                  Point(Left + Width div 2, Top + Width div 2)]);
end;

//-----------------------------------------------------------------------------
{
procedure TColorPickerButton.SetNumGlyphs(Value: TNumGlyphs);
begin
  if Value < 0 then Value := 1
               else
    if Value > 4 then Value := 4;

  if Value <> TButtonGlyph(FGlyph).NumGlyphs then
  begin
    TButtonGlyph(FGlyph).NumGlyphs := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.GlyphChanged(Sender: TObject);
begin
  Invalidate;
end;
}
//-----------------------------------------------------------------------------

procedure TColorPickerButton.UpdateExclusive;
var
  Msg: TMessage;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    Msg.Msg := CM_BUTTONPRESSED;
    Msg.WParam := FGroupIndex;
    Msg.LParam := Longint(Self);
    Msg.Result := 0;
    Parent.Broadcast(Msg);
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetDown(Value: Boolean);
begin
  if FGroupIndex = 0 then Value := False;
  if Value <> FDown then
  begin
    if FDown and (not FAllowAllUp) then Exit;
    FDown := Value;
    if Value then
    begin
      if FState = bsUp then Invalidate;
      FState := bsExclusive;
    end
    else
    begin
      FState := bsUp;
      Repaint;
    end;
    if Value then UpdateExclusive;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetFlat(Value: Boolean);

begin
  if Value <> FFlat then
  begin
    FFlat := Value;
    if Value then ControlStyle := ControlStyle - [csOpaque]
             else ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetGroupIndex(Value: Integer);

begin
  if FGroupIndex <> Value then
  begin
    FGroupIndex := Value;
    UpdateExclusive;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetLayout(Value: TButtonLayout);

begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetMargin(Value: Integer);

begin
  if (Value <> FMargin) and (Value >= -1) then
  begin
    FMargin := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetSpacing(Value: Integer);

begin
  if Value <> FSpacing then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetAllowAllUp(Value: Boolean);

begin
  if FAllowAllUp <> Value then
  begin
    FAllowAllUp := Value;
    UpdateExclusive;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPopup.WMActivateApp(var Message: TWMActivateApp);

begin
  inherited;
  if not Message.Active then EndSelection(True);
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.WMLButtonDblClk(var Message: TWMLButtonDown);

begin
  inherited;
  if FDown then DblClick;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.CMEnabledChanged(var Message: TMessage);

const NewState: array[Boolean] of TButtonState = (bsDisabled, bsUp);

begin
//  TButtonGlyph(FGlyph).CreateButtonGlyph(NewState[Enabled]);
  UpdateTracking;
  Repaint;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.CMButtonPressed(var Message: TMessage);

var Sender: TColorPickerButton;

begin
  if Message.WParam = FGroupIndex then
  begin
    Sender := TColorPickerButton(Message.LParam);
    if Sender <> Self then
    begin
      if Sender.Down and FDown then
      begin
        FDown := False;
        FState := bsUp;
        Invalidate;
      end;
      FAllowAllUp := Sender.AllowAllUp;
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.CMDialogChar(var Message: TCMDialogChar);

begin
  with Message do
    if IsAccel(CharCode, Caption) and
       Enabled and
       Visible and
      Assigned(Parent) and
      Parent.Showing then
    begin
      Click;
      Result := 1;
    end
    else inherited;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.CMFontChanged(var Message: TMessage);

begin
  Invalidate;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.CMTextChanged(var Message: TMessage);

begin
  Invalidate;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.CMSysColorChange(var Message: TMessage);

begin
{  with TButtonGlyph(FGlyph) do
  begin
    Invalidate;
    CreateButtonGlyph(FState);
  end;}
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.CMMouseEnter(var Message: TMessage);

begin
  inherited;
  if FFlat and not FMouseInControl and Enabled then
  begin
    FMouseInControl := True;
    Repaint;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.CMMouseLeave(var Message: TMessage);

begin
  inherited;
  if FFlat and FMouseInControl and Enabled and not FDragging then
  begin
    FMouseInControl := False; 
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetDroppedDown(const Value: Boolean);

var Allowed: Boolean;

begin
  if FDroppedDown <> Value then
  begin
    Allowed:= True;
    if Assigned(FOnDropChanging) then FOnDropChanging(Self, Allowed);
    if Allowed then
    begin
      FDroppedDown := Value;
      if FDroppedDown then
      begin
        FState := bsDown;
        TColorPopup(FColorPopup).SelectedColor := FSelectionColor;
        TColorPopup(FColorPopup).ShowPopupAligned;
        SetCapture(FPopupWnd);
      end
      else
      begin
        FState := bsUp;
        ReleaseCapture;
        ShowWindow(FColorPopup.Handle, SW_HIDE);
      end;
      if Assigned(FOnDropChanged) then FOnDropChanged(Self);
      Invalidate;
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetSelectionColor(const Value: TColor);

begin
  if FSelectionColor <> Value then
  begin
    FSelectionColor := Value;
    Invalidate;
    if FDroppedDown then TColorPopup(FColorPopup).SelectColor(Value);
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

//-----------------------------------------------------------------------------

function TColorPickerButton.GetCustomText: String;

begin
  Result := TColorPopup(FColorPopup).FCustomText;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetCustomText(const Value: String);

begin
  with TColorPopup(FColorPopup) do
  begin
    if FCustomText <> Value then
    begin
      FCustomText := Value;
      if (FCustomText = '') and (FSelectedIndex = CustomCell) then FSelectedIndex := NoCell;
      AdjustWindow;
      if FDroppedDown then
      begin
        Invalidate;
        ShowPopupAligned;
      end;
    end;
  end;
end;

//-----------------------------------------------------------------------------

function TColorPickerButton.GetDefaultText: String;

begin
  Result := TColorPopup(FColorPopup).FDefaultText;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetDefaultText(const Value: String);

begin
  if TColorPopup(FColorPopup).FDefaultText <> Value then
  begin
    with TColorPopup(FColorPopup) do
    begin
      FDefaultText := Value;
      AdjustWindow;
      if FDroppedDown then
      begin
        Invalidate;
        ShowPopupAligned;
      end;
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetShowSystemColors(const Value: Boolean);

begin
  with TColorPopup(FColorPopup) do
  begin
    if FShowSysColors <> Value then
    begin
      FShowSysColors := Value;
      AdjustWindow;
      if FDroppedDown then
      begin
        Invalidate;
        ShowPopupAligned;
      end;
    end;
  end;
end;

//-----------------------------------------------------------------------------

function TColorPickerButton.GetShowSystemColors: Boolean;

begin
  Result := TColorPopup(FColorPopup).FShowSysColors;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetTransparent(const Value: Boolean);

begin
  if Value <> FTransparent then
  begin
    FTransparent := Value;
    if Value then ControlStyle := ControlStyle - [csOpaque]
             else ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);

  //--------------- local functions -----------------------
{
  procedure CopyImage(ImageList: TCustomImageList; Index: Integer);
  begin
    with Glyph do
    begin
      Width := ImageList.Width;
      Height := ImageList.Height;
      Canvas.Brush.Color := clFuchsia;//! for lack of a better color
      Canvas.FillRect(Rect(0,0, Width, Height));
      ImageList.Draw(Canvas, 0, 0, Index);
    end;
  end;
}
  //--------------- end local functions -------------------

begin
  inherited ActionChange(Sender, CheckDefaults);
{  if Sender is TCustomAction then
    with TCustomAction(Sender) do
    begin
      // Copy image from action's imagelist
      if Glyph.Empty and
         Assigned(ActionList) and
         Assigned(ActionList.Images) and
        (ImageIndex >= 0) and
        (ImageIndex < ActionList.Images.Count) then CopyImage(ActionList.Images, ImageIndex);
    end;}
end;

//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetIndicatorBorder(const Value: TIndicatorBorder);

begin
  if FIndicatorBorder <> Value then
  begin
    FIndicatorBorder := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

function TColorPickerButton.GetPopupSpacing: Integer;

begin
  Result := TColorPopup(FColorPopup).Spacing;
end;

//-----------------------------------------------------------------------------

procedure TColorPickerButton.SetPopupSpacing(const Value: Integer);

begin
  TColorPopup(FColorPopup).Spacing := Value;
end;

//-----------------------------------------------------------------------------






procedure RnQDrawButtonGlyph(DC: HDC; //const GlyphPos: TPoint;
  const PicRect : TGPRect;
  State: TButtonState; Transparent: Boolean;
 {$IFDEF RNQ}
    var ImgElm : TRnQThemedElementDtls;
 {$ENDIF RNQ}
//  ImageName : String;
  const PaintOnGlass : Boolean = false);
var
//  gR : TGPRect;
  PicSize : TSize;
//  Index: Integer;
//  Details: TThemedElementDetails;
//  Button: TThemedButton;
//  R: TRect;
//  PicW, PicH : Integer;
//  MemDC: HDC;
//  PaintBuffer: HPAINTBUFFER;
begin
//  if FOriginal = nil then Exit;
 {$IFDEF RNQ}
  if ImgElm.picName = '' then
    Exit;
  PicSize := Theme.GetPicSize(ImgElm);
  with PicSize do
   begin
     if (cx = 0) or (cy = 0) then Exit;
//     PicW := cx;
//     PicH := cy;
   end;
//  if (FOriginal.Width = 0) or (FOriginal.Height = 0) then Exit;
//  Index := CreateButtonGlyph(State);
  ImgElm.pEnabled := (State <> bsDisabled);

//   gR.TopLeft := TGPPoint(PicRect.TopLeft);
//   gR.Height  := PicRect.Bottom-PicRect.Top - 2;
//   gR.Width   := gR.Height;
//  theme.drawPic(DC, gR, ImgElm);
  theme.drawPic(DC, PicRect, ImgElm);
 {$ENDIF RNQ}
(*
//  with GlyphPos do
  begin
    if ThemeServices.ThemesEnabled then
    begin
{      R.TopLeft := GlyphPos;
      R.Right := R.Left + PicW;
      R.Bottom := R.Top + PicH;
{      case State of
        bsDisabled:
          Button := tbPushButtonDisabled;
        bsDown,
        bsExclusive:
          Button := tbPushButtonPressed;
      else
        // bsUp
        Button := tbPushButtonNormal;
      end;
      Details := ThemeServices.GetElementDetails(Button);}
{      if PaintOnGlass then
      begin
        PaintBuffer := BeginBufferedPaint(DC, R, BPBF_TOPDOWNDIB, nil, MemDC);
        try
//          ThemeServices.DrawIcon(MemDC, Details, R, FGlyphList.Handle, Index);
          theme.drawPic(MemDC, X, Y, ImageName, ThemeToken, picLoc, picIdx, (State <> bsDisabled));
          BufferedPaintMakeOpaque(PaintBuffer, @R);
        finally
          EndBufferedPaint(PaintBuffer, True);
        end;
      end
      else
//      ThemeServices.DrawIcon(Canvas.Handle, Details, R, FGlyphList.Handle, Index);
}
//      gR.TopLeft := GlyphPos;
      gR.TopLeft := TGPPoint(PicRect.TopLeft);
      gR.Height := PicRect.Bottom-PicRect.Top - 2;
      gR.Width :=
        theme.drawPic(DC, gR, ImgElm);
    end
    else
      if Transparent or (State = bsExclusive) then
      begin
       theme.drawPic(DC, GlyphPos, ImgElm);
//        ImageList_DrawEx(FGlyphList.Handle, Index, Canvas.Handle, X, Y, 0, 0,
//          clNone, clNone, ILD_Transparent)
      end
      else
       theme.drawPic(DC, GlyphPos, ImgElm);
//        ImageList_DrawEx(FGlyphList.Handle, Index, Canvas.Handle, X, Y, 0, 0,
//          ColorToRGB(clBtnFace), clNone, ILD_Normal);
  end;*)
end;

procedure RnQDrawButtonText(//Canvas: TCanvas;
            CanvasHnd : HDC; pColor : TColor;
            const Caption: string; thmBtn : TThemedButton;
            TextBounds: TRect; State: TButtonState; BiDiFlags: LongInt;
            PaintOnGlass: Boolean = false);

  procedure DoDrawText(DC: HDC; const Text: string;
    var TextRect: TRect; TextFlags: Cardinal; clr : Integer);
 {$IFDEF DELPHI9_UP}
  var
    Options: TDTTOpts;
//    tb : TThemedButton;
 {$ENDIF DELPHI9_UP}
  begin
//    if FThemesEnabled then
    if ThemeServices.ThemesEnabled then
    begin
 {$IFDEF DELPHI9_UP}
      if PaintOnGlass then
//      if 1=1 then
      begin
        FillChar(Options, SizeOf(Options), 0);
        Options.dwSize := SizeOf(Options);
        Options.dwFlags := DTT_TEXTCOLOR or DTT_COMPOSITED;
//        Options.crText := ColorToRGB(Canvas.Font.Color);
        Options.crText := clr;
  //      with ThemeServices.GetElementDetails(tbPushButtonNormal) do
  //        DrawThemeTextEx(ThemeServices.Theme[teButton], DC, Part, State,
  //          PWideChar(WideString(Text)), Length(Text), TextFlags, @TextRect, Options);
          with ThemeServices.GetElementDetails(thmBtn) do
            DrawThemeTextEx(ThemeServices.Theme[teButton], DC, Part, State,
  //          with ThemeServices.GetElementDetails(twCaptionActive) do
  //            DrawThemeTextEx(ThemeServices.Theme[teWindow], MemDC, Part, State,
  //            with ThemeServices.GetElementDetails(teEditTextNormal) do
  //              DrawThemeTextEx(ThemeServices.Theme[teEdit], Memdc, Part, State,
                  PWideChar(WideString(Text)), Length(Text), TextFlags, @TextRect, Options);
      end
      else
 {$ENDIF DELPHI9_UP}
       begin
        SetTextColor(DC, clr);
        SetBkMode(DC, TRANSPARENT);
        with ThemeServices do
//          DrawText(Canvas.Handle, FThemeDetails, Text, TextRect, TextFlags, 0);
          DrawText(DC, GetElementDetails(thmBtn), Text, TextRect, TextFlags, 0);
       end;
    end
    else
     begin
//       oldMode:=
       SetBKMode(DC, TRANSPARENT);
       SetTextColor(DC, clr);
       Windows.DrawText(DC, PChar(Text), Length(Text), TextRect, TextFlags);
     end;
  end;
var
  clr : Integer;
begin
//  with Canvas do
  begin
//    Brush.Style := bsClear;
    if (State = bsDisabled) and not ThemeServices.ThemesEnabled then
    begin
      OffsetRect(TextBounds, 1, 1);
//      Font.Color := clBtnHighlight;
      clr := ColorToRGB(clBtnHighlight);
//      clr := ColorToRGB(pColor);
//      oldColor :=
//      SetTextColor(CanvasHnd, clr);
      DoDrawText(CanvasHnd, Caption, TextBounds, DT_CENTER or DT_VCENTER or BiDiFlags, clr);
      OffsetRect(TextBounds, -1, -1);
//      Font.Color := clBtnShadow;
      clr := ColorToRGB(clBtnShadow);
//      oldColor :=
//      SetTextColor(CanvasHnd, clr);
      DoDrawText(CanvasHnd, Caption, TextBounds, DT_CENTER or DT_VCENTER or BiDiFlags, clr);
    end else
     begin
//      clr := GetTextColor(CanvasHnd);
      if (State = bsDisabled) then
        clr := ColorToRGB(clGrayText)
       else
        clr := ColorToRGB(pColor);
//      SetTextColor(CanvasHnd, clr);
      DoDrawText(CanvasHnd, Caption, TextBounds, DT_CENTER or DT_VCENTER or BiDiFlags, clr);
     end;
  end;
end;
    
procedure RnQCalcButtonLayout(DC : HDC; const Client: TRect;
  const Offset: TPoint; const Caption: string; Layout: TButtonLayout; Margin,
  Spacing: Integer; //var GlyphPos: TPoint;
  var GlyphRect: TGPRect;
  var TextBounds: TRect;
  BiDiFlags: LongInt;
 {$IFDEF RNQ}
  var ImgElm : TRnQThemedElementDtls;
 {$ENDIF RNQ}
//  ImageName : String;
  const DropDownWidth: Integer = 0);
var
  TextPos: TPoint;
  ClientSize, //GlyphSize,
  TextSize: TPoint;

  TotalSize: TPoint;
begin
  if (BiDiFlags and DT_RIGHT) = DT_RIGHT then
    if Layout = blGlyphLeft then Layout := blGlyphRight
    else 
      if Layout = blGlyphRight then Layout := blGlyphLeft;
  { calculate the item sizes }
  ClientSize := Point(Client.Right - Client.Left - DropDownWidth, Client.Bottom -
    Client.Top);

 {$IFDEF RNQ}
  if ImgElm.picName <> '' then
    begin
      GlyphRect.size := tgpsize(theme.GetPicSize(ImgElm));
      GlyphRect := DestRect(GlyphRect.size, tgpsize(ClientSize));
    end
//     GlyphSize := Point(cx, cy)
   else
 {$ENDIF RNQ}
//    GlyphSize := Point(0, 0);
    GlyphRect.size := tgpsize(Point(0, 0));
//  if FOriginal <> nil then
//    GlyphSize := Point(FOriginal.Width div FNumGlyphs, FOriginal.Height) else
//    GlyphSize := Point(0, 0);

  if Length(Caption) > 0 then
  begin
    TextBounds := Rect(0, 0, Client.Right - Client.Left - DropDownWidth, 0);
    DrawText(DC, PChar(Caption), Length(Caption), TextBounds,
      DT_CALCRECT or BiDiFlags);
    TextSize := Point(TextBounds.Right - TextBounds.Left, TextBounds.Bottom -
      TextBounds.Top);
  end
  else
  begin
    TextBounds := Rect(0, 0, 0, 0);
    TextSize := Point(0,0);
  end;
    
  { If the layout has the glyph on the right or the left, then both the
    text and the glyph are centered vertically.  If the glyph is on the top
    or the bottom, then both the text and the glyph are centered horizontally.}
  if Layout in [blGlyphLeft, blGlyphRight] then
  begin
//    GlyphPos.Y := (ClientSize.Y - GlyphSize.Y + 1) div 2;
    GlyphRect.Y := (ClientSize.Y - GlyphRect.Height + 1) div 2;
    TextPos.Y := (ClientSize.Y - TextSize.Y + 1) div 2;
  end
  else
  begin
//    GlyphPos.X := (ClientSize.X - GlyphSize.X + 1) div 2;
    GlyphRect.X := (ClientSize.X - GlyphRect.Width + 1) div 2;
    TextPos.X := (ClientSize.X - TextSize.X + 1) div 2;
  end;
    
  { if there is no text or no bitmap, then Spacing is irrelevant }
  if (TextSize.X = 0) or (GlyphRect.Width = 0) then
    Spacing := 0;
    
  { adjust Margin and Spacing }
  if Margin = -1 then
  begin
    if Spacing < 0 then
    begin
      TotalSize := Point(GlyphRect.Width + TextSize.X, GlyphRect.Height + TextSize.Y);
      if Layout in [blGlyphLeft, blGlyphRight] then
        Margin := (ClientSize.X - TotalSize.X) div 3
      else
        Margin := (ClientSize.Y - TotalSize.Y) div 3;
      Spacing := Margin;
    end
    else
    begin
      TotalSize := Point(GlyphRect.Width + Spacing + TextSize.X, GlyphRect.Height +
        Spacing + TextSize.Y);
      if Layout in [blGlyphLeft, blGlyphRight] then
        Margin := (ClientSize.X - TotalSize.X + 1) div 2
      else
        Margin := (ClientSize.Y - TotalSize.Y + 1) div 2;
    end;
  end
  else
  begin
    if Spacing < 0 then
    begin
      TotalSize := Point(ClientSize.X - (Margin + GlyphRect.Width), ClientSize.Y -
        (Margin + GlyphRect.Height));
      if Layout in [blGlyphLeft, blGlyphRight] then
        Spacing := (TotalSize.X - TextSize.X) div 2
      else
        Spacing := (TotalSize.Y - TextSize.Y) div 2;
    end;
  end;
    
  case Layout of
    blGlyphLeft:
      begin
//        GlyphPos.X := Margin;
        GlyphRect.X := Margin;
//        TextPos.X := GlyphPos.X + GlyphSize.X + Spacing;
        TextPos.X := GlyphRect.X + GlyphRect.Width + Spacing;
      end;
    blGlyphRight:
      begin
//        GlyphPos.X := ClientSize.X - Margin - GlyphSize.X;
        GlyphRect.X := ClientSize.X - Margin - GlyphRect.Width;
        TextPos.X := GlyphRect.X - Spacing - TextSize.X;
      end;
    blGlyphTop:
      begin
        GlyphRect.Y := Margin;
        TextPos.Y := GlyphRect.Y + GlyphRect.Height + Spacing;
      end;
    blGlyphBottom:
      begin
        GlyphRect.Y := ClientSize.Y - Margin - GlyphRect.Height;
        TextPos.Y := GlyphRect.Y - Spacing - TextSize.Y;
      end;
  end;
    
  { fixup the result variables }
//  with GlyphPos do
  with GlyphRect do
  begin
    Inc(X, Client.Left + Offset.X);
    Inc(Y, Client.Top + Offset.Y);
  end;

  { Themed text is not shifted, but gets a different color. }
  if ThemeServices.ThemesEnabled then
    OffsetRect(TextBounds, TextPos.X + Client.Left, TextPos.Y + Client.Top)
  else
    OffsetRect(TextBounds, TextPos.X + Client.Left + Offset.X, TextPos.Y + Client.Top + Offset.Y);

end;
    
function RnQButtonDrawFull(Canvas: TCanvas; const Client: TRect; //const Offset: TPoint;
      const Caption: string; Layout: TButtonLayout; Margin, Spacing: Integer;
      State: TButtonState; MouseInControl : Boolean; Transparent: Boolean;
      BiDiFlags: Longint;
 {$IFDEF RNQ}
      var ImgElm : TRnQThemedElementDtls;
 {$ENDIF RNQ}
//      ImageName : String;
      const DropDownWidth: Integer=0): TRect;
const
  Enabled = True;
  FFlat   = False;
const
  DownStyles: array[Boolean] of Integer = (BDR_RAISEDINNER, BDR_SUNKENOUTER);
  FillStyles: array[Boolean] of Integer = (BF_MIDDLE, 0);
var
  PaintRect: TRect;
  DrawFlags: Integer;
  Offset: TPoint;
  Button: TThemedButton;
  ToolButton: TThemedToolBar;
  Details: TThemedElementDetails;
begin

  PaintRect := Client;
{  if not Enabled then
  begin
    FState := bsDisabled;
    FDragging := False;
  end
  else
  if State = bsDisabled then
    if FDown and (GroupIndex <> 0) then
      FState := bsExclusive
    else
      FState := bsUp;
  Canvas.Font := Self.Font;
}
  Button := tbPushButtonNormal;
  if ThemeServices.ThemesEnabled then
  begin
//    if FFlat then
//     PerformEraseBackground(Self, Canvas.Handle);

    if not Enabled then
      Button := tbPushButtonDisabled
    else
      if State in [bsDown, bsExclusive] then
        Button := tbPushButtonPressed
      else
        if MouseInControl then
          Button := tbPushButtonHot
        else
          Button := tbPushButtonNormal;

    ToolButton := ttbToolbarDontCare;
    if FFlat then
    begin
      case Button of
        tbPushButtonDisabled:
          Toolbutton := ttbButtonDisabled;
        tbPushButtonPressed:
          Toolbutton := ttbButtonPressed;
        tbPushButtonHot:
          Toolbutton := ttbButtonHot;
        tbPushButtonNormal:
          Toolbutton := ttbButtonNormal;
      end;
    end;

//    PaintRect := ClientRect;
    if ToolButton = ttbToolbarDontCare then
    begin
      Details := ThemeServices.GetElementDetails(Button);
//      StyleServices.DrawElement()
      ThemeServices.DrawElement(Canvas.Handle, Details, PaintRect);
      PaintRect := ThemeServices.ContentRect(Canvas.Handle, Details, PaintRect);
    end
    else
    begin
      Details := ThemeServices.GetElementDetails(ToolButton);
      ThemeServices.DrawElement(Canvas.Handle, Details, PaintRect);
      PaintRect := ThemeServices.ContentRect(Canvas.Handle, Details, PaintRect);
    end;

    if Button = tbPushButtonPressed then
    begin
      // A pressed speed button has a white text. This applies however only to flat buttons.
      if ToolButton <> ttbToolbarDontCare then
        Canvas.Font.Color := clHighlightText;
      Offset := Point(1, 0);
    end
    else
      Offset := Point(0, 0);
//    if ImageName <> '' then
//      theme.drawPic(Canvas, PaintRect.Left, PaintRect.Top, ImageName, FState<>bsDisabled)
//    else
//     TButtonGlyph(FGlyph).Draw(Canvas, PaintRect, Offset, Caption, FLayout, FMargin, FSpacing, FState, Transparent,
//       DrawTextBiDiModeFlags(0));
  end
  else
  begin
//    PaintRect := Rect(0, 0, Width, Height);
    if not FFlat then
    begin
      DrawFlags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
      if State in [bsDown, bsExclusive] then
        DrawFlags := DrawFlags or DFCS_PUSHED;
//      if State  = bsDisabled then
//        DrawFlags := DrawFlags or DFCS_INACTIVE;
      DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DrawFlags);
    end
    else
    begin
      if (State in [bsDown, bsExclusive]) or
        (MouseInControl and (State <> bsDisabled))
//         or(csDesigning in ComponentState)
       then
        DrawEdge(Canvas.Handle, PaintRect, DownStyles[State in [bsDown, bsExclusive]],
          FillStyles[Transparent] or BF_RECT)
      else if not Transparent then
      begin
        Canvas.Brush.Color := clBtnFace;
        Canvas.FillRect(PaintRect);
      end;
      InflateRect(PaintRect, -1, -1);
    end;
    if State in [bsDown, bsExclusive] then
    begin
      if (State = bsExclusive) and (not FFlat or not MouseInControl) then
      begin
        Canvas.Brush.Bitmap := AllocPatternBitmap(clBtnFace, clBtnHighlight);
        Canvas.FillRect(PaintRect);
      end;
      Offset.X := 1;
      Offset.Y := 1;
    end
    else
    begin
      Offset.X := 0;
      Offset.Y := 0;
    end;
  end;

  RnQButtonDraw(Canvas.Handle, Canvas.Font.Color, Client, Offset, Caption, Layout,
                Margin, Spacing, Button, State, Transparent, BiDiFlags,
 {$IFDEF RNQ}
                ImgElm,
 {$ENDIF RNQ}
                DropDownWidth);
end;

function RnQButtonDraw(//Canvas: TCanvas;
  CanvasHnd : HDC; pFontColor : TColor;
  const Client: TRect; const Offset: TPoint;
  const Caption: string; Layout: TButtonLayout; Margin, Spacing: Integer;
  thmBtn : TThemedButton; State: TButtonState; Transparent: Boolean;
  BiDiFlags: LongInt;
 {$IFDEF RNQ}
  var ImgElm : TRnQThemedElementDtls;
 {$ENDIF RNQ}
//  ImageName : String;
  const DropDownWidth: Integer = 0; PaintOnGlass : Boolean = false): TRect;
var
//  GlyphPos: TPoint;
  GlyphRect : TGPRect;
begin
  RnQCalcButtonLayout(CanvasHnd, Client, Offset, Caption, Layout, Margin, Spacing,
    GlyphRect, Result, BiDiFlags,
 {$IFDEF RNQ}
    ImgElm,
 {$ENDIF RNQ}
    DropDownWidth);
  RnQDrawButtonGlyph(CanvasHnd, GlyphRect, State, Transparent,
 {$IFDEF RNQ}
    ImgElm,
 {$ENDIF RNQ}
    PaintOnGlass);
  if Length(Caption) > 0 then
    RnQDrawButtonText(CanvasHnd, pFontColor, Caption, thmBtn, Result, State, BiDiFlags, PaintOnGlass);
// return a rectangle wherein the color indicator can be drawn
  if Caption = '' then
  begin
    Result := Client;
    Dec(Result.Right, DropDownWidth + 2);
    InflateRect(Result, -2, -2);

    // consider glyph if no text is to be painted (else it is already taken into account)
//    if Assigned(FOriginal) and (FOriginal.Width > 0) and (FOriginal.Height > 0) then
 {$IFDEF RNQ}
    if ImgElm.picName <> '' then
     with theme.GetPicSize(ImgElm) do
      if (cx > 0) and (cy > 0) then
      case Layout of
        blGlyphLeft:
          begin
            Result.Left := GlyphRect.X + cx + 4;
            Result.Top := GlyphRect.Y;
            Result.Bottom := GlyphRect.Y + cy;
          end;
        blGlyphRight:
          begin
            Result.Right := GlyphRect.X - 4;
            Result.Top := GlyphRect.Y;
            Result.Bottom := GlyphRect.Y + cy;
          end;
        blGlyphTop:
            Result.Top := GlyphRect.Y + cy + 4;
        blGlyphBottom:
            Result.Bottom := GlyphRect.Y - 4;
      end;
 {$ENDIF RNQ}
  end
  else
  begin
    // consider caption
    Result := Rect(Result.Left, Result.Bottom, Result.Right, Result.Bottom + 6);
    if (Result.Bottom + 2) > Client.Bottom then Result.Bottom := Client.Bottom - 2;
  end;
end;












//----------------- TRnQToolButton ------------------------------------------

constructor TRnQToolButton.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);

  SetBounds(0, 0, 45, 22);
  FDropDownWidth := 15;
  ControlStyle := [csCaptureMouse, csDoubleClicks];
  ParentFont := True;
  Color := clBtnFace;
  FSpacing := 4;
  FMargin := -1;
  FLayout := blGlyphLeft;
  FTransparent := True;
  FIndicatorBorder := ibFlat;

  Inc(ButtonCount);
end;

//-----------------------------------------------------------------------------

destructor TRnQToolButton.Destroy;
begin
  Dec(ButtonCount);
  // the color popup window will automatically be freed since the button is the owner
  // of the popup
//  TButtonGlyph(FGlyph).Free;
  inherited Destroy;
end;

//-----------------------------------------------------------------------------
procedure TRnQToolButton.SetDropDownArrowColor(Value: TColor);

begin
  if not (FDropDownArrowColor = Value) then;
  begin
    FDropDownArrowColor := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetDropDownWidth(Value: integer);
begin
  if not (FDropDownWidth = Value) then;
  begin
    FDropDownWidth := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.Paint;
const
  MAX_WIDTH = 5;
  DownStyles: array[Boolean] of Integer = (BDR_RAISEDINNER, BDR_SUNKENOUTER);
  FillStyles: array[Boolean] of Integer = (BF_MIDDLE, 0);
var
  PaintRect: TRect;
  ExtraRect: TRect;
  DrawFlags: Integer;
  Offset: TPoint;
  LeftPos: Integer;

   Button: TThemedButton;
   ToolButton: TThemedToolBar;
   ToolButton1: TThemedToolBar;
  Details: TThemedElementDetails;
//  cnv : TCanvas;
//  DC : HDC;
begin
  if not Enabled then
   begin
    FState := bsDisabled;
    FDragging := False;
   end
  else
   if (FState = bsDisabled) then
    begin
      if FDown and (GroupIndex <> 0) then
        FState := bsExclusive
       else
        FState := bsUp;
    end;
//  DC := CreateCompatibleDC(Canvas.Handle);
//  cnv := TCanvas.Create;
//  cnv.Handle := DC;

  Canvas.Font := Self.Font;
  Button := tbPushButtonNormal;
 if ThemeServices.ThemesEnabled then
  begin
    PerformEraseBackground(Self, Canvas.Handle);

    begin
      if (FState in [bsDown, bsExclusive]) or
         (FMouseInControl and (FState <> bsDisabled)) or
         (csDesigning in ComponentState) then
       begin
        // Check if the mouse is in the drop down zone. If it is we then check
        // the state of the button to determine the drawing sequence
        if FDropDownZone then
         begin
          if FDroppedDown then
           begin
            // Paint pressed Drop Down Button
            ToolButton := ttbButtonHot;
            ToolButton1 := //ttbDropDownButtonCheckedHot
            ttbSplitButtonDropDownCheckedHot;
           end
          else
           begin
            // Paint depressed Drop Down Button
            ToolButton := ttbButtonHot;
            ToolButton1 := //ttbDropDownButtonHot
            ttbSplitButtonDropDownHot;
           end;
         end
        else
         if (FState in [bsDown, bsExclusive]) then
           begin
            Canvas.Font.Color := clHighlightText;
            ToolButton := ttbButtonPressed;
            ToolButton1 := //ttbDropDownButtonPressed
            ttbSplitButtonDropDownPressed;
//            ToolButton1 := ttbSeparatorPressed;
           end
         else
           begin
            ToolButton := ttbButtonHot;
            ToolButton1 := //ttbDropDownButtonHot
            ttbSplitButtonDropDownHot;
           end;
       end
      else
        if not FTransparent then
         begin
          ToolButton := ttbButtonNormal;
          ToolButton1 := //ttbDropDownButtonNormal
           ttbSplitButtonDropDownNormal;
//             ttbDropDownButtonNormal
//             ttbSplitButtonDropDownHot
         end
        else
         begin
          ToolButton := ttbButtonNormal;
          ToolButton1 := //ttbDropDownButtonNormal
            ttbSplitButtonDropDownNormal;
//             ttbDropDownButtonNormal
//             ttbSplitButtonDropDownHot
         end;
      InflateRect(PaintRect, -1, -1);
    end;

     if not Enabled then
      begin
        ToolButton := ttbButtonDisabled;
        ToolButton1 := ttbSplitButtonDropDownDisabled;
      end;

    if not FFlat then
    begin
      if not Enabled then
        Button := tbPushButtonDisabled
      else
        if FState in [bsDown, bsExclusive] then
          if FDroppedDown then
            Button := tbPushButtonNormal
           else
            Button := tbPushButtonPressed
        else
          if MouseInControl then
            Button := tbPushButtonHot
          else
            Button := tbPushButtonNormal;

      ToolButton := ttbToolbarDontCare;
    end
    else
     Button := tbButtonDontCare;

    if (FState in [bsDown, bsExclusive]) and not (FDropDownZone) then
    begin
      if (FState = bsExclusive) and (not FFlat or not FMouseInControl) then
      begin
        Canvas.Brush.Bitmap := AllocPatternBitmap(clBtnFace, clBtnHighlight);
        Canvas.FillRect(PaintRect);
      end;
      Offset.X := 1;
      Offset.Y := 1;
    end
    else
    begin
      Offset.X := 0;
      Offset.Y := 0;
    end;
    
{    if FFlat then
    begin
      case Button of
        tbPushButtonDisabled:
          Toolbutton := ttbButtonDisabled;
        tbPushButtonPressed:
          Toolbutton := ttbButtonPressed;
        tbPushButtonHot:
          Toolbutton := ttbButtonHot;
        tbPushButtonNormal:
          Toolbutton := ttbButtonNormal;
      end;
    end;
}
{
      if FDropDownZone then
      begin
        if FDroppedDown then
        begin
          // Paint pressed Drop Down Button
          if MouseInControl then
            ToolButton := ttbSplitButtonDropDownCheckedHot
           else
            ToolButton := ttbSplitButtonDropDownChecked;
        end
        else
        begin
          // Paint depressed Drop Down Button
          if MouseInControl then
            ToolButton := ttbSplitButtonDropDownHot
           else
            ToolButton := ttbSplitButtonDropDownNormal;
        end;
      end
      else
      begin
        if (FState in [bsDown, bsExclusive]) then
          ToolButton := ttbSplitButtonPressed
         else
          ToolButton := ttbSplitButtonNormal
      end;

{

}
//    PaintRect := Rect(0, 0, Width - FDropDownWidth, Height);
    PaintRect := ClientRect;
//    PaintRect.Right := PaintRect.Right - FDropDownWidth;
//    PaintRect := Rect(0, 0, Width, Height);
    ExtraRect := ClientRect;
//    PaintRect.Right := PaintRect.Right - FDropDownWidth;
    ExtraRect.Left := ExtraRect.Right - FDropDownWidth;
//    ExtraRect := Rect(Width - FDropDownWidth, 0, Width, Height);
//    LeftPos := (Width - FDropDownWidth) + ((FDropDownWidth + MAX_WIDTH) div 2) - MAX_WIDTH - 1;
//    PaintRect := ClientRect;
    if ToolButton = ttbToolbarDontCare then
    begin
      Details := ThemeServices.GetElementDetails(Button);
      ThemeServices.DrawElement(Canvas.Handle, Details, PaintRect);
      PaintRect := ThemeServices.ContentRect(Canvas.Handle, Details, PaintRect);
      Details := ThemeServices.GetElementDetails(ToolButton1);
      ThemeServices.DrawElement(Canvas.Handle, Details, ExtraRect);
      ExtraRect := ThemeServices.ContentRect(Canvas.Handle, Details, ExtraRect);
    end
    else
    begin
      Details := ThemeServices.GetElementDetails(ToolButton);
      ThemeServices.DrawElement(Canvas.Handle, Details, PaintRect);
      PaintRect := ThemeServices.ContentRect(Canvas.Handle, Details, PaintRect);
      Details := ThemeServices.GetElementDetails(ToolButton1);
      ThemeServices.DrawElement(Canvas.Handle, Details, ExtraRect);
      ExtraRect := ThemeServices.ContentRect(Canvas.Handle, Details, ExtraRect);
    end;
{
    if Button = tbPushButtonPressed then
    begin
      // A pressed speed button has a white text. This applies however only to flat buttons.
      if ToolButton <> ttbToolbarDontCare then
        Canvas.Font.Color := clHighlightText;
      Offset := Point(1, 0);
    end
    else
      Offset := Point(0, 0);
}      
//    if ImageName <> '' then
//      theme.drawPic(Canvas, PaintRect.Left, PaintRect.Top, ImageName, FState<>bsDisabled)
//    else
//     TButtonGlyph(FGlyph).Draw(Canvas, PaintRect, Offset, Caption, FLayout, FMargin, FSpacing, FState, Transparent,
//       DrawTextBiDiModeFlags(0));
    PaintRect := RnQButtonDraw(Canvas.Handle, Canvas.Font.Color, PaintRect, Offset, Caption, FLayout, FMargin,
      FSpacing, Button, FState, Transparent, DrawTextBiDiModeFlags(0),
 {$IFDEF RNQ}
      fImgElm,
 {$ENDIF RNQ}
      FDropDownWidth);
 end
 else
 begin
  // Creates a rectangle that represent the button and the drop down area,
  // determines also the position to draw the arrow...
  PaintRect := Rect(0, 0, Width, Height);
  ExtraRect := Rect(Width - FDropDownWidth, 0, Width, Height);
  LeftPos := (Width - FDropDownWidth) + ((FDropDownWidth + MAX_WIDTH) div 2) - MAX_WIDTH - 1;

  // Determines if the button is a flat or normal button... each uses
  // different painting methods
  if not FFlat then
  begin
    DrawFlags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;

    if FState in [bsDown, bsExclusive] then DrawFlags := DrawFlags or DFCS_PUSHED;

    // Check if the mouse is in the drop down zone. If it is we then check
    // the state of the button to determine the drawing sequence
    if FDropDownZone then
    begin
      if FDroppedDown then
      begin
        // paint pressed Drop Down Button
        DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DRAW_BUTTON_UP);
        DrawFrameControl(Canvas.Handle, ExtraRect, DFC_BUTTON, DRAW_BUTTON_DOWN);
      end
      else
      begin
        // paint depressed Drop Down Button
        DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DRAW_BUTTON_UP);
        DrawFrameControl(Canvas.Handle, ExtraRect, DFC_BUTTON, DRAW_BUTTON_UP);
        DrawButtonSeperatorUp(Canvas);
      end;
    end
    else
    begin
      DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DrawFlags);

      // Determine the type of drop down seperator...
      if (FState in [bsDown, bsExclusive]) then DrawButtonSeperatorDown(Canvas)
                                           else DrawButtonSeperatorUp(Canvas);
    end;
  end
  else
  begin
    if (FState in [bsDown, bsExclusive]) or
       (FMouseInControl and (FState <> bsDisabled)) or
       (csDesigning in ComponentState) then
    begin
      // Check if the mouse is in the drop down zone. If it is we then check
      // the state of the button to determine the drawing sequence
      if FDropDownZone then
      begin
        if FDroppedDown then
        begin
          // Paint pressed Drop Down Button
          DrawEdge(Canvas.Handle, PaintRect, DownStyles[False], FillStyles[FTransparent] or BF_RECT);
          DrawEdge(Canvas.Handle, ExtraRect, DownStyles[True], FillStyles[FTransparent] or BF_RECT);
        end
        else
        begin
          // Paint depressed Drop Down Button
          DrawEdge(Canvas.Handle, PaintRect, DownStyles[False], FillStyles[FTransparent] or BF_RECT);
          DrawEdge(Canvas.Handle, ExtraRect, DownStyles[False], FillStyles[FTransparent] or BF_RECT);
          DrawButtonSeperatorUp(Canvas);
        end;
      end
      else
      begin
        DrawEdge(Canvas.Handle, PaintRect, DownStyles[FState in [bsDown, bsExclusive]], FillStyles[FTransparent] or BF_RECT);

        if (FState in [bsDown, bsExclusive]) then DrawButtonSeperatorDown(Canvas)
                                             else DrawButtonSeperatorUp(Canvas);
      end;
    end
    else
      if not FTransparent then
      begin
        Canvas.Brush.Style := bsSolid;
        Canvas.Brush.Color := Color;
        Canvas.FillRect(PaintRect);
      end;
    InflateRect(PaintRect, -1, -1);
  end;


  if (FState in [bsDown, bsExclusive]) and not (FDropDownZone) then
  begin
    if (FState = bsExclusive) and (not FFlat or not FMouseInControl) then
    begin
      Canvas.Brush.Bitmap := AllocPatternBitmap(clBtnFace, clBtnHighlight);
      Canvas.FillRect(PaintRect);
    end;
    Offset.X := 1;
    Offset.Y := 1;
  end
  else
  begin
    Offset.X := 0;
    Offset.Y := 0;
  end;

//  PaintRect := TButtonGlyph(FGlyph).Draw(Canvas, PaintRect, Offset, Caption, FLayout, FMargin,
  PaintRect := RnQButtonDraw(Canvas.Handle, Canvas.Font.Color, PaintRect, Offset, Caption, FLayout, FMargin,
      FSpacing, Button, FState, Transparent, DrawTextBiDiModeFlags(0),
 {$IFDEF RNQ}
      fImgElm,
 {$ENDIF RNQ}
      FDropDownWidth);

  // Draws the arrow for the correct state
  if FState = bsDisabled then
  begin
    Canvas.Pen.Style := psClear;
    Canvas.Brush.Color := clBtnShadow;
  end
  else
  begin
    Canvas.Pen.Color := FDropDownArrowColor;
    Canvas.Brush.Color := FDropDownArrowColor;
  end;

  if FDropDownZone and FDroppedDown or (FState = bsDown) and not (FDropDownZone) then
    DrawTriangle(Canvas, (Height div 2) + 1, LeftPos + 1, MAX_WIDTH)
  else
    DrawTriangle(Canvas, (Height div 2), LeftPos, MAX_WIDTH);
 end;
end;


//-----------------------------------------------------------------------------

procedure TRnQToolButton.UpdateTracking;
var
  P: TPoint;
begin
  if FFlat then
  begin
    if Enabled then
    begin
      GetCursorPos(P);
      FMouseInControl := not (FindDragTarget(P, True) = Self);
      if FMouseInControl then
        Perform(CM_MOUSELEAVE, 0, 0)
       else
        Perform(CM_MOUSEENTER, 0, 0);
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);

  if (Button = mbLeft) and Enabled then
  begin
    // Determine if mouse is currently in the drop down section...
    FDropDownZone := (X > Width - FDropDownWidth);

    // If so display the button in the proper state and display the menu
    if FDropDownZone then
    begin
      if not FDroppedDown then
      begin
        Update;
        DroppedDown := True;
      end;

      // Setting this flag to false is very important, we want the dsUp state to
      // be used to display the button properly the next time the mouse moves in
      FDragging := False;
    end
    else
    begin
      if not FDown then
      begin
        FState := bsDown;
        Invalidate;
      end;

      FDragging := True;
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewState: TButtonState;
begin
  inherited MouseMove(Shift, X, Y);
  if FDragging then
  begin
    if not FDown then NewState := bsUp
                 else NewState := bsExclusive;
    if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
      if FDown then NewState := bsExclusive
               else NewState := bsDown;
    if NewState <> FState then
    begin
      FState := NewState;
      Invalidate;
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DoClick: Boolean;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FDragging then
  begin
    FDragging := False;
    DoClick := (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight);
    if FGroupIndex = 0 then
    begin
      // Redraw face in case mouse is captured
      FState := bsUp;
      FMouseInControl := False;
      if DoClick and not (FState in [bsExclusive, bsDown]) then Invalidate;
    end
    else
      if DoClick then
      begin
        SetDown(not FDown);
        if FDown then Repaint;
      end
      else
      begin
        if FDown then FState := bsExclusive;
        Repaint;
      end;
    if DoClick then Click;
    UpdateTracking;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.Click;
begin
  inherited Click;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.DoDefaultEvent;
begin
  if Assigned(FOnDefaultSelect) then FOnDefaultSelect(Self);
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.DrawButtonSeperatorUp(Canvas: TCanvas);
begin
  with Canvas do
  begin
    Pen.Style := psSolid;
    Brush.Style := bsClear;
    Pen.Color := clBtnHighlight;
    Rectangle(Width - DropDownWidth, 1, Width - DropDownWidth + 1, Height - 1);
    Pen.Color := clBtnShadow;
    Rectangle(Width - DropDownWidth - 1, 1, Width - DropDownWidth, Height - 1);
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.DrawButtonSeperatorDown(Canvas: TCanvas);

begin
  with Canvas do
  begin
    Pen.Style := psSolid;
    Brush.Style := bsClear;
    Pen.Color := clBtnHighlight;
    Rectangle(Width - DropDownWidth + 1, 2, Width - DropDownWidth + 2, Height - 2);
    Pen.Color := clBtnShadow;
    Rectangle(Width - DropDownWidth, 2, Width - DropDownWidth + 1, Height - 2);
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.DrawTriangle(Canvas: TCanvas; Top, Left, Width: Integer);
begin
  if Odd(Width) then Inc(Width);
  Canvas.Polygon([Point(Left, Top),
                  Point(Left + Width, Top),
                  Point(Left + Width div 2, Top + Width div 2)]);
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.UpdateExclusive;
var
  Msg: TMessage;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    Msg.Msg := CM_BUTTONPRESSED;
    Msg.WParam := FGroupIndex;
    Msg.LParam := Longint(Self);
    Msg.Result := 0;
    Parent.Broadcast(Msg);
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetDown(Value: Boolean);
begin
  if FGroupIndex = 0 then Value := False;
  if Value <> FDown then
  begin
    if FDown and (not FAllowAllUp) then Exit;
    FDown := Value;
    if Value then
    begin
      if FState = bsUp then Invalidate;
      FState := bsExclusive;
    end
    else
    begin
      FState := bsUp;
      Repaint;
    end;
    if Value then UpdateExclusive;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetFlat(Value: Boolean);
begin
  if Value <> FFlat then
  begin
    FFlat := Value;
    if Value then ControlStyle := ControlStyle - [csOpaque]
             else ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetGroupIndex(Value: Integer);
begin
  if FGroupIndex <> Value then
  begin
    FGroupIndex := Value;
    UpdateExclusive;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetLayout(Value: TButtonLayout);
begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetMargin(Value: Integer);
begin
  if (Value <> FMargin) and (Value >= -1) then
  begin
    FMargin := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetSpacing(Value: Integer);
begin
  if Value <> FSpacing then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetAllowAllUp(Value: Boolean);
begin
  if FAllowAllUp <> Value then
  begin
    FAllowAllUp := Value;
    UpdateExclusive;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
begin
 begin
   msg.Result := 1;
   msg.Msg := 0;
 end;
end;


procedure TRnQToolButton.WMLButtonDblClk(var Message: TWMLButtonDown);
begin
  inherited;
  if FDown then DblClick;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.CMEnabledChanged(var Message: TMessage);
//const
//  NewState: array[Boolean] of TButtonState = (bsDisabled, bsUp);
begin
//  TButtonGlyph(FGlyph).CreateButtonGlyph(NewState[Enabled]);
  UpdateTracking;
  Repaint;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.CMButtonPressed(var Message: TMessage);
var
  Sender: TRnQToolButton;
begin
  if Message.WParam = FGroupIndex then
  begin
    Sender := TRnQToolButton(Message.LParam);
    if Sender <> Self then
    begin
      if Sender.Down and FDown then
      begin
        FDown := False;
        FState := bsUp;
        Invalidate;
      end;
      FAllowAllUp := Sender.AllowAllUp;
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, Caption) and
       Enabled and
       Visible and
      Assigned(Parent) and
      Parent.Showing then
    begin
      Click;
      Result := 1;
    end
    else inherited;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.CMFontChanged(var Message: TMessage);
begin
  Invalidate;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.CMSysColorChange(var Message: TMessage);
begin
{  with TButtonGlyph(FGlyph) do
  begin
    Invalidate;
    CreateButtonGlyph(FState);
  end;}
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if FFlat and not FMouseInControl and Enabled then
  begin
    FMouseInControl := True;
    Repaint;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FFlat and FMouseInControl and Enabled and not FDragging then
  begin
    FMouseInControl := False; 
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetDroppedDown(const Value: Boolean);
var
  Allowed: Boolean;
  PopupPoint : TPoint;
begin
  if FDroppedDown <> Value then
  begin
    Allowed:= True;
    if Assigned(FOnDropChanging) then FOnDropChanging(Self, Allowed);
    if Allowed then
    begin
      FDroppedDown := Value;
      if FDroppedDown then
      begin
        FState := bsDown;
        if Assigned(FDropdownMenu) then
         begin
//          PopupPoint.X := Left;
//          PopupPoint.Y := Top+Height;
          PopupPoint.X := 0;
          PopupPoint.Y := Height;
          Invalidate;
          PopupPoint := Self.ClientToScreen(PopupPoint);
//           FDropdownMenu.Popup(FDropdownMenu.);
            FDropdownMenu.Popup(PopupPoint.X, PopupPoint.Y);
          if FFlat and FMouseInControl and Enabled and not FDragging then
          begin
            FMouseInControl := False;
          end;
          FDroppedDown := false;
          FState := bsUp;
         end;
      end
      else
      begin
        FState := bsUp;
        ReleaseCapture;
      end;
      if Assigned(FOnDropChanged) then FOnDropChanged(Self);
      Invalidate;
    end;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetTransparent(const Value: Boolean);

begin
  if Value <> FTransparent then
  begin
    FTransparent := Value;
    if Value then ControlStyle := ControlStyle - [csOpaque]
             else ControlStyle := ControlStyle + [csOpaque];
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------

procedure TRnQToolButton.SetIndicatorBorder(const Value: TIndicatorBorder);

begin
  if FIndicatorBorder <> Value then
  begin
    FIndicatorBorder := Value;
    Invalidate;
  end;
end;

//-----------------------------------------------------------------------------
procedure TRnQToolButton.SetDropdownMenu(Value: TPopupMenu);
begin
  if Value <> FDropdownMenu then
  begin
    FDropdownMenu := Value;
    if Value <> nil then Value.FreeNotification(Self);
  end;
end;

procedure TRnQToolButton.SetImageName(const Value: TPicName);
begin
 {$IFDEF RNQ}
 fImgElm.picName := Value;
 fImgElm.Element := RQteButton;
 fImgElm.picIdx := -1;
 fImgElm.themeToken := -1;
 {$ELSE ~RNQ}
 fImgName := Value;
 {$ENDIF RNQ}
 Invalidate;
end;


//-----------------------------------------------------------------------------


{ TRnQButton }

constructor TRnQButton.Create(AOwner: TComponent);
begin
//  FGlyph := TButtonGlyph.Create;
//  TButtonGlyph(FGlyph).OnChange := GlyphChanged;
  inherited Create(AOwner);
  FCanvas := TCanvas.Create;
//  FStyle := bsAutoDetect;
//  FKind := bkCustom;
  FLayout := blGlyphLeft;
  FSpacing := 4;
  FMargin := -1;
  FTransparent := False;
//  ControlStyle := ControlStyle + [csReflector];
  DoubleBuffered := False;
end;

destructor TRnQButton.Destroy;
begin
  inherited Destroy;
//  TButtonGlyph(FGlyph).Free;
  FCanvas.Free;
end;
    
procedure TRnQButton.CreateHandle;
//var
//  State: TButtonState;
begin
{  if Enabled then
    State := bsUp
  else
    State := bsDisabled;}
  inherited CreateHandle;
end;
    
procedure TRnQButton.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style or BS_OWNERDRAW;
//  ControlStyle := ControlStyle + [ csOpaque ] ;
;
end;
    
procedure TRnQButton.SetButtonStyle(ADefault: Boolean);
begin
  if ADefault <> IsFocused then
  begin
    IsFocused := ADefault;
    Refresh;
  end;
end;
    
{procedure TRnQButton.Click;
var
  Form: TCustomForm;
  Control: TWinControl;
begin
  case FModalResult of
//    mrCancel
    bkClose:
      begin
        Form := GetParentForm(Self);
        if Form <> nil then Form.Close
        else inherited Click;
      end;
    bkHelp:
      begin
        Control := Self;
        while (Control <> nil) and (Control.HelpContext = 0) do
          Control := Control.Parent;
        if Control <> nil then Application.HelpContext(Control.HelpContext)
        else inherited Click;
      end;
    else
      inherited Click;
//  end;
end;    }

procedure TRnQButton.CNMeasureItem(var Message: TWMMeasureItem);
begin
  with Message.MeasureItemStruct^ do
  begin
    itemWidth := Width;
    itemHeight := Height;
  end;
end;

procedure TRnQButton.CNDrawItem(var Message: TWMDrawItem);
var
  SaveIndex: Integer;
begin
//  DrawItem(Message.DrawItemStruct^);

  with Message.DrawItemStruct^ do
  begin
    SaveIndex := SaveDC(hDC);
    FCanvas.Lock;
    try
      FCanvas.Handle := hDC;
      FCanvas.Font := Font;
      FCanvas.Brush := Brush;
//      DrawButton(rcItem, itemState);
      DrawItem(Message.DrawItemStruct^);
    finally
      FCanvas.Handle := 0;
      FCanvas.Unlock;
      RestoreDC(hDC, SaveIndex);
    end;
  end;
  Message.Result := LRESULT(False);
  Message.Msg := 0;
end;

procedure TRnQButton.WMPaint(var Message: TWMPaint);
{
var PS: TPaintStruct;
    I: Cardinal;
    R: TRect;
    SeparatorTop: Integer;
  dis : tagDRAWITEMSTRUCT;}
begin
  Inherited;
{  if Message.DC = 0 then
    FCanvas.Handle := BeginPaint(Handle, PS)
   else
    FCanvas.Handle := Message.DC;
  try
    dis.hDC := FCanvas.Handle;
    dis.rcItem := ClientRect;// PS.rcPaint;

    DrawItem(dis);
    Message.Result := LRESULT(False);
    Message.Msg := 0;
  finally
//    FCanvas.Font.Handle := 0; // a stock object never needs to be freed
    FCanvas.Handle := 0;
    if Message.DC = 0 then
      EndPaint(Handle, PS);
  end;}
    Message.Result := LRESULT(False);
    Message.Msg := 0;
end;

procedure TRnQButton.DrawItem(const DrawItemStruct: TDrawItemStruct);
const
  WordBreakFlag: array[Boolean] of Integer = (0, DT_WORDBREAK);
 {$IFNDEF DELPHI9_UP}
  PaintOnGlass = false;
 {$ENDIF DELPHI9_UP}
var
  IsDown, IsDefault: Boolean;
  State: TButtonState;
  R: TRect;
  Flags: Longint;
  Details: TThemedElementDetails;
  Button: TThemedButton;
  Offset: TPoint;
  LForm: TCustomForm;
//  DC : HDC;
//  cnv : TCanvas;
    MemDC: HDC;
 {$IFDEF DELPHI9_UP}
    PaintOnGlass: Boolean;
    PaintBuffer: HPAINTBUFFER;
 {$ENDIF DELPHI9_UP}
//    h_Font, logfontOld, h_font_old : HFONT;
begin
//  cnv := TCanvas.Create;
//  FCanvas.Handle := DrawItemStruct.hDC;
//  R := ClientRect;
  with DrawItemStruct do
  begin
    R := rcItem;
    FCanvas.Handle := DrawItemStruct.hDC;
    FCanvas.Font := Self.Font;
    IsDown := itemState and ODS_SELECTED <> 0;
    IsDefault := itemState and ODS_FOCUS <> 0;

    if not Enabled then State := bsDisabled
    else if IsDown then State := bsDown
    else State := bsUp;
  end;

  Button := tbPushButtonNormal;
  if ThemeControl(Self) then
//  if ThemeServices.ThemesEnabled then
  begin
 {$IFDEF DELPHI9_UP}
    PaintOnGlass := ThemeServices.ThemesEnabled and DwmCompositionEnabled and
      not (csDesigning in ComponentState);
//    PaintOnGlass := PaintOnGlass and not ParentDoubleBuffered;
    if PaintOnGlass then
    begin
      LForm := GetParentForm(Self);
      PaintOnGlass := (LForm <> nil) and LForm.GlassFrame.FrameExtended and
       LForm.GlassFrame.IntersectsControl(Self);
    end;
 {$ENDIF DELPHI9_UP}

    if not Enabled then
      Button := tbPushButtonDisabled
    else
      if IsDown then
        Button := tbPushButtonPressed
      else
        if FMouseInControl then
          Button := tbPushButtonHot
        else
          if IsFocused or IsDefault then
            Button := tbPushButtonDefaulted
          else
            Button := tbPushButtonNormal;

    Details := ThemeServices.GetElementDetails(Button);
    // Parent background.
//    ThemeServices.DrawParentBackground(Handle, DrawItemStruct.hDC, @Details, True);

 {$IFDEF DELPHI9_UP}
    if PaintOnGlass then
//      FillRect(FCanvas.Handle, ClientRect, GetStockObject(BLACK_BRUSH));
//        PerformEraseBackground(Self, DrawItemStruct.hDC)
//      FillRect(DrawItemStruct.hDC, ClientRect, GetStockObject(BLACK_BRUSH))
    else
 {$ENDIF DELPHI9_UP}
      PerformEraseBackground(Self, DrawItemStruct.hDC);

//          ThemeServices.DrawParentBackground(Handle, DrawItemStruct.hDC, @Details, True)
  //        ThemeServices.DrawParentBackground(Parent.Handle, Canvas.Handle, nil, False)
//      else
//        ThemeServices.DrawParentBackground(Parent.Handle, Canvas.Handle, nil, False)
//        FillRect(FCanvas.Handle, ClientRect, GetStockObject(BLACK_BRUSH));
//        FillRect(DrawItemStruct.hDC, ClientRect, GetStockObject(BLACK_BRUSH));
    // Button shape.
    ;
    try
 {$IFDEF DELPHI9_UP}
    PaintBuffer := 0;
     if PaintOnGlass then
//     if 1=2 then
     begin
      PaintBuffer := BeginBufferedPaint(DrawItemStruct.hDC, R, BPBF_TOPDOWNDIB, nil, MemDC);
//      try
        BufferedPaintClear(PaintBuffer, @R);
        FCanvas.Handle := MemDC;
        FCanvas.Font := Self.Font;
        FillRect(MemDC, DrawItemStruct.rcItem, GetStockObject(BLACK_BRUSH));
     end
     else
 {$ENDIF DELPHI9_UP}
      begin
        MemDC := FCanvas.Handle;
//        PaintBuffer := 0;
      end;
    ThemeServices.DrawElement(MemDC, Details, DrawItemStruct.rcItem);
    R := ThemeServices.ContentRect(MemDC, Details, DrawItemStruct.rcItem);
//    R := DrawItemStruct.rcItem;

    if Button = tbPushButtonPressed then
      Offset := Point(1, 0)
    else
      Offset := Point(0, 0);
//    TButtonGlyph(FGlyph).Draw(FCanvas, R, Offset, Caption, FLayout, FMargin, FSpacing, State, False,
//      DrawTextBiDiModeFlags(0) or WordBreakFlag[WordWrap]);
    RnQButtonDraw(FCanvas.Handle, FCanvas.Font.Color, R, Offset, Caption, FLayout, FMargin,
      FSpacing, Button, State, FTransparent, DrawTextBiDiModeFlags(0),
 {$IFDEF RNQ}
      fImgElm,
 {$ENDIF RNQ}
      0, PaintOnGlass);

    if IsFocused and IsDefault then
    begin
      FCanvas.Pen.Color := clWindowFrame;
      FCanvas.Brush.Color := clBtnFace;
      DrawFocusRect(FCanvas.Handle, R);
    end;

    finally
 {$IFDEF DELPHI9_UP}
      if PaintOnGlass then
       begin
//         FCanvas.Handle := DrawItemStruct.hDC;
         FCanvas.Handle := 0;
//         BufferedPaintMakeOpaque(PaintBuffer, @R);
         EndBufferedPaint(PaintBuffer, True);
//         EndBufferedPaint(PaintBuffer, False);
       end;
 {$ENDIF DELPHI9_UP}
    end;
  end
  else
  begin
    R := ClientRect;

    Flags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
    if IsDown then Flags := Flags or DFCS_PUSHED;
    if DrawItemStruct.itemState and ODS_DISABLED <> 0 then
      Flags := Flags or DFCS_INACTIVE;

    { DrawFrameControl doesn't allow for drawing a button as the
        default button, so it must be done here. }
    if IsFocused or IsDefault then
    begin
      FCanvas.Pen.Color := clWindowFrame;
      FCanvas.Pen.Width := 1;
      FCanvas.Brush.Style := bsClear;
      FCanvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);

      { DrawFrameControl must draw within this border }
      InflateRect(R, -1, -1);
    end;

    { DrawFrameControl does not draw a pressed button correctly }
    if IsDown then
    begin
      FCanvas.Pen.Color := clBtnShadow;
      FCanvas.Pen.Width := 1;
      FCanvas.Brush.Color := clBtnFace;
      FCanvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
      InflateRect(R, -1, -1);
    end
    else
      DrawFrameControl(DrawItemStruct.hDC, R, DFC_BUTTON, Flags);

    if IsFocused then
    begin
      R := ClientRect;
      InflateRect(R, -1, -1);
    end;

    FCanvas.Font := Self.Font;
    if IsDown then
      OffsetRect(R, 1, 1);

    RnQButtonDraw(FCanvas.Handle, FCanvas.Font.Color, R, Point(0,0), Caption, FLayout, FMargin,
      FSpacing, Button, State, FTransparent, DrawTextBiDiModeFlags(0),
 {$IFDEF RNQ}
      fImgElm,
 {$ENDIF RNQ}
      0);
//    TButtonGlyph(FGlyph).Draw(FCanvas, R, Point(0,0), Caption, FLayout, FMargin,
//      FSpacing, State, False, DrawTextBiDiModeFlags(0) or WordBreakFlag[WordWrap]);

    if IsFocused and IsDefault then
    begin
      R := ClientRect;
      InflateRect(R, -4, -4);
      FCanvas.Pen.Color := clWindowFrame;
      FCanvas.Brush.Color := clBtnFace;
      DrawFocusRect(FCanvas.Handle, R);
    end;
  end;

  FCanvas.Handle := 0;
end;
    
procedure TRnQButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TRnQButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;
    
procedure TRnQButton.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  Perform(WM_LBUTTONDOWN, Message.Keys, Longint(Message.Pos));
end;

function TRnQButton.GetPalette: HPALETTE;
begin
  Result := 0;
end;

procedure TRnQButton.SetGlyph(const PicName: TPicName);
begin
//  TButtonGlyph(FGlyph).Glyph := Value as TBitmap;
 {$IFDEF RNQ}
  fImgElm.picName := PicName;
  fImgElm.Element := RQteButton;
  fImgElm.themeToken := -1;
 {$ELSE ~RNQ}
  fImgName := PicName;
 {$ENDIF RNQ}
//  FModifiedGlyph := True;
  GlyphChanged(self);
//  Invalidate;
end;

//function TRnQButton.GetGlyph: String;
//begin
//  Result := FImageName;
//end;

procedure TRnQButton.GlyphChanged(Sender: TObject);
begin
  Invalidate;
end;
    
procedure TRnQButton.SetLayout(Value: TButtonLayout);
begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Invalidate;
  end;
end;
    
procedure TRnQButton.SetSpacing(Value: Integer);
begin
  if FSpacing <> Value then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;

procedure TRnQButton.SetMargin(Value: Integer);
begin
  if (Value <> FMargin) and (Value >= - 1) then
  begin
    FMargin := Value;
    Invalidate;
  end;
end;

procedure TRnQButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if ThemeServices.ThemesEnabled and not FMouseInControl and not (csDesigning in ComponentState) then
  begin
    FMouseInControl := True;
    Repaint;
  end;
end;

procedure TRnQButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if ThemeServices.ThemesEnabled and FMouseInControl then
  begin
    FMouseInControl := False;
    Repaint;
  end;
end;

procedure TRnQButton.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
//var
// cnv : TCanvas;
// ps: tagPAINTSTRUCT;
begin
 begin
//   msg.Result := 1;
   msg.Result := LRESULT(False);
   msg.Msg := 0;
 end;
end;


procedure Register;

begin
  RegisterComponents('RnQ', [TColorPickerButton]);
  RegisterComponents('RnQ', [TRnQSpeedButton]);
  RegisterComponents('RnQ', [TRnQToolButton]);
  RegisterComponents('RnQ', [TRnQButton]);
end;

//-----------------------------------------------------------------------------
end.
