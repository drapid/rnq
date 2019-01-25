unit RnQImageGrid;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Classes, SysUtils, Messages, Controls, Graphics, Forms, StdCtrls, Types,
  Grids, RTLConsts, Math, Themes;

const
  DefCellSpacing = 5;
  DefCellWidth = 96;
  DefCellHeight = 60;
  DefColWidth = DefCellWidth + DefCellSpacing;
  DefRowHeight = DefCellHeight + DefCellSpacing;
  DefInCellMargin = 3;
  MinThumbSize = 4;
  MinCellSize = 8;

type
  PImageGridItem = ^TImageGridItem;
  TImageGridItem = record
    FFileName: TFileName;
    FObject: TObject;
    FImage: TGraphic;
    FThumb: TGraphic;
  end;

  PImageGridItemList = ^TImageGridItemList;
  TImageGridItemList = array[0..MaxInt div 64] of TImageGridItem;

{ TImageGridItems
  The managing object for holding filename-thumbnail or image-thumbnail
  combinations in an array of TImageGridItem elements. When an item's image
  changes, the item's thumb is freed. When an item's filename changes, then
  the item's thumb is freed only if the item's image is unassigned. }

  TImageGridItems = class(TStrings)
  private
    FCapacity: Integer;
    FChanged: Boolean;
    FCount: Integer;
    FList: PImageGridItemList;
    FOnChanged: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    FOwnsObjects: Boolean;
    FSorted: Boolean;
    procedure ExchangeItems(Index1, Index2: NativeInt);
    function GetImage(Index: Integer): TGraphic;
    function GetThumb(Index: Integer): TGraphic;
    procedure Grow;
    procedure InsertItem(Index: Integer; const S: String; AObject: TObject;
      AImage: TGraphic; AThumb: TGraphic);
    procedure PutImage(Index: Integer; AImage: TGraphic);
    procedure PutThumb(Index: Integer; AThumb: TGraphic);
    procedure QuickSort(L, R: Integer);
    procedure SetSorted(Value: Boolean);
  protected
    function CompareStrings(const S1, S2: String): Integer; override;
    procedure Changed; virtual;
    procedure Changing; virtual;
    function Get(Index: Integer): String; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: String); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure PutThumbSilently(Index: Integer; AThumb: TGraphic); virtual;
    procedure SetCapacity(Value: Integer); override;
    procedure SetUpdateState(Updating: Boolean); override;
  public
    function Add(const S: String): Integer; override;
    function AddImage(const S: String; AImage: TGraphic): Integer; virtual;
    function AddItem(const S: String; AObject: TObject; AImage: TGraphic;
      AThumb: TGraphic): Integer; virtual;
    function AddObject(const S: String; AObject: TObject): Integer; override;
    function AddThumb(const S: String; AThumb: TGraphic): Integer; virtual;
    procedure AddStrings(Strings: TStrings); override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear; override;
    procedure ClearThumbs; virtual;
    procedure Delete(Index: Integer); override;
    destructor Destroy; override;
    procedure Exchange(Index1, Index2: Integer); override;
    function IndexOf(const S: String): Integer; override;
    procedure Insert(Index: Integer; const S: String); override;
    procedure InsertObject(Index: Integer; const S: String;
      AObject: TObject); override;
    function Find(const S: String; var Index: Integer): Boolean;
    procedure Sort; virtual;
    property FileNames[Index: Integer]: String read Get write Put;
    property Images[Index: Integer]: TGraphic read GetImage write PutImage;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
    property Sorted: Boolean read FSorted write SetSorted;
    property Thumbs[Index: Integer]: TGraphic read GetThumb write PutThumb;
  end;

{ TBorderControl
  A control with a system drawn border following the current theme, and an
  additional margin as implemented by TWinControl.BorderWidth. }

  TBorderControl = class(TCustomControl)
  private
    FBorderStyle: TBorderStyle;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure WMNCPaint(var Message: TWMNCPaint); message WM_NCPAINT;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function TotalBorderWidth: Integer; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle
      default bsSingle;
    property BorderWidth;
  end;

{ TAnimRowScroller
  A scroll box with a vertical scroll bar and vertically stacked items with a
  fixed row height. Scrolling with the scroll bar is animated alike Windows'
  own default list box control. Scrolling is also possible by dragging the
  content with the left mouse button. }

  TAnimRowScroller = class(TBorderControl)
  private
    FAutoHideScrollBar: Boolean;
    FDragScroll: Boolean;
    FDragScrolling: Boolean;
    FDragSpeed: Single;
    FDragStartPos: Integer;
    FPrevScrollPos: Integer;
    FPrevTick: Cardinal;
    FRow: Integer;
    FRowCount: Integer;
    FRowHeight: Integer;
    FScrollingPos: Integer;
    FScrollPos: Integer;
    FWheelScrollLines: Integer;
    procedure Drag;
    function IsWheelScrollLinesStored: Boolean;
    procedure Scroll;
    procedure SetAutoHideScrollBar(Value: Boolean);
    procedure SetRow(Value: Integer);
    procedure SetRowCount(Value: Integer);
    procedure SetScrollPos(Value: Integer; Animate, Snap: Boolean);
    procedure UpdateScrollBar;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
  protected
    procedure CreateWnd; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer); override;
    procedure Resize; override;
    procedure SetRowHeight(Value: Integer); virtual;
    procedure WndProc(var Message: TMessage); override;
    property AutoHideScrollBar: Boolean read FAutoHideScrollBar
      write SetAutoHideScrollBar default True;
    property Row: Integer read FRow write SetRow default -1;
    property RowCount: Integer read FRowCount write SetRowCount;
    property RowHeight: Integer read FRowHeight write SetRowHeight
      default DefRowHeight;
    property DragScroll: Boolean read FDragScroll write FDragScroll
      default True;
    property DragScrolling: Boolean read FDragScrolling;
    property ScrollingPos: Integer read FScrollingPos;
    property WheelScrollLines: Integer read FWheelScrollLines
      write FWheelScrollLines stored IsWheelScrollLinesStored;
  public
    constructor Create(AOwner: TComponent); override;
    procedure MouseWheelHandler(var Message: TMessage); override;
    function Scrolling: Boolean;
  end;

{ TCustomImageGrid
  The base class of an image grid. It shows images from left to right, then
  from top to bottom. The number of columns is determined by the width of the
  control, possibly resulting in a vertical scroll bar. The coord size is set
  by ColWidth and RowHeight, being the sum of CellWidth resp. CellHeight plus
  CellSpacing. Each cell shows a thumb of the corresponding image. The control
  automatically starts a thumbs generating background thread when an image's
  graphic, filename or its cell size is changed. Before every such change, any
  previously created thread is terminated. Combine multiple changes by calling
  Items.BeginUpdate/Items.EndUpdate to prevent the thread from being recreated
  repeatedly. }

  TCustomImageGrid = class;

  TPath = type String;

  TDrawCellEvent = procedure(Sender: TCustomImageGrid; Index, ACol,
    ARow: Integer; R: TRect) of object;

  TImageEvent = procedure(Sender: TCustomImageGrid; Index: Integer) of object;

  TMeasureThumbEvent = procedure(Sender: TCustomImageGrid; Index: Integer;
    var AThumbWidth, AThumbHeight: Integer) of object;

  TCustomImageGrid = class(TAnimRowScroller)
  private
    FCellAlignment: TAlignment;
    FCellLayout: TTextLayout;
    FCellSpacing: Integer;
    FColCount: Integer;
    FColWidth: Integer;
    FInCellMargin: Integer;
    FDefaultDrawing: Boolean;
    FDesignPreview: Boolean;
    FFileFormats: TStrings;
    FFolder: TPath;
    FItemIndex: Integer;
    FItems: TImageGridItems;
    FMarkerColor: TColor;
    FMarkerStyle: TPenStyle;
    FOnClickCell: TImageEvent;
    FOnDrawCell: TDrawCellEvent;
    FOnMeasureThumb: TMeasureThumbEvent;
    FOnProgress: TImageEvent;
    FOnUnresolved: TImageEvent;
    FProportional: Boolean;
    FRetainUnresolvedItems: Boolean;
    FStretch: Boolean;
    procedure DeleteUnresolvedItems;
    procedure FileFormatsChanged(Sender: TObject);
    function GetCellHeight: Integer;
    function GetCellWidth: Integer;
    function GetCount: Integer;
    function GetFileNames: TStrings;
    function GetImage(Index: Integer): TGraphic;
    function GetRowCount: Integer;
    function GetSorted: Boolean;
    function GetThumb(Index: Integer): TGraphic;
    function IsFileNamesStored: Boolean;
    procedure ItemsChanged(Sender: TObject);
    procedure Rearrange;
    procedure SetCellAlignment(Value: TAlignment);
    procedure SetCellHeight(Value: Integer);
    procedure SetCellLayout(Value: TTextLayout);
    procedure SetCellSpacing(Value: Integer);
    procedure SetCellWidth(Value: Integer);
    procedure SetColWidth(Value: Integer);
    procedure SetDefaultDrawing(Value: Boolean);
    procedure SetDesignPreview(Value: Boolean);
    procedure SetFileFormats(Value: TStrings);
    procedure SetFileNames(Value: TStrings);
    procedure SetFolder(Value: TPath);
    procedure SetImage(Index: Integer; Value: TGraphic);
    procedure SetItemIndex(Value: Integer);
    procedure SetItems(Value: TImageGridItems);
    procedure SetMarkerColor(Value: TColor);
    procedure SetMarkerStyle(Value: TPenStyle);
    procedure SetProportional(Value: Boolean);
    procedure SetRetainUnresolvedItems(Value: Boolean);
    procedure SetSorted(Value: Boolean);
    procedure SetStretch(Value: Boolean);
    procedure SetThumb(Index: Integer; Value: TGraphic);
//    procedure ThumbsUpdated(Sender: TObject);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure CMMouseLeave(var msg: TMessage); message CM_MOUSELEAVE;
  protected
    procedure DoProgress(Index: Integer); virtual;
    procedure ChangeScale(M, D: Integer); override;
    procedure DoClickCell(Index: Integer); virtual;
    procedure DoDrawCell(Index, ACol, ARow: Integer; R: TRect); virtual;
    procedure DoMeasureThumb(Index: Integer; var AThumbWidth,
      AThumbHeight: Integer); virtual;
    procedure InvalidateItem(Index: Integer);
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure SetRowHeight(Value: Integer); override;
    property CellAlignment: TAlignment read FCellAlignment
      write SetCellAlignment default taCenter;
    property CellHeight: Integer read GetCellHeight write SetCellHeight
      default DefCellHeight;
    property CellLayout: TTextLayout read FCellLayout write SetCellLayout
      default tlCenter;
    property CellSpacing: Integer read FCellSpacing write SetCellSpacing
      default DefCellSpacing;
    property CellWidth: Integer read GetCellWidth write SetCellWidth
      default DefCellWidth;
    property InCellMargin: Integer read FInCellMargin write FInCellMargin
      default DefInCellMargin;
    property ColCount: Integer read FColCount;
    property ColWidth: Integer read FColWidth write SetColWidth
      default DefColWidth;
    property Count: Integer read GetCount;
    property DefaultDrawing: Boolean read FDefaultDrawing
      write SetDefaultDrawing default True;
    property DesignPreview: Boolean read FDesignPreview write SetDesignPreview
      default False;
    property FileFormats: TStrings read FFileFormats write SetFileFormats;
    property FileNames: TStrings read GetFileNames write SetFileNames
      stored IsFileNamesStored;
    property Folder: TPath read FFolder write SetFolder;
    property Images[Index: Integer]: TGraphic read GetImage write SetImage;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property Items: TImageGridItems read FItems write SetItems;
    property MarkerColor: TColor read FMarkerColor write SetMarkerColor
      default clGray;
    property MarkerStyle: TPenStyle read FMarkerStyle write SetMarkerStyle
      default psDash;
    property OnClickCell: TImageEvent read FOnClickCell write FOnClickCell;
    property OnDrawCell: TDrawCellEvent read FOnDrawCell write FOnDrawCell;
    property OnMeasureThumb: TMeasureThumbEvent read FOnMeasureThumb
      write FOnMeasureThumb;
    property OnProgress: TImageEvent read FOnProgress write FOnProgress;
    property OnUnresolved: TImageEvent read FOnUnresolved write FOnUnresolved;
    property Proportional: Boolean read FProportional write SetProportional
      default True;
    property RetainUnresolvedItems: Boolean read FRetainUnresolvedItems
      write SetRetainUnresolvedItems default False;
    property RowCount: Integer read GetRowCount;
    property Sorted: Boolean read GetSorted write SetSorted default False;
    property Stretch: Boolean read FStretch write SetStretch default False;
    property Thumbs[Index: Integer]: TGraphic read GetThumb write SetThumb;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CellRect(Index: Integer): TRect;
    function CoordFromIndex(Index: Integer): TGridCoord;
    procedure Clear; virtual;
    function MouseToIndex(X, Y: Integer): Integer;
    procedure ScrollInView(Index: Integer);
    procedure SetCellSize(ACellWidth, ACellHeight: Integer);
    procedure SetCoordSize(AColWidth, ARowHeight: Integer);
    property ParentBackground default False;
  public
    property TabStop default True;
  end;

  TAwImageGrid = class(TCustomImageGrid)
  public
    property ColCount;
    property Count;
    property Images;
    property Items;
    property RowCount;
    property Thumbs;
  published
    property Align;
    property Anchors;
    property AutoHideScrollBar;
    property BorderStyle;
    property BorderWidth;
    property CellAlignment;
    property CellHeight;
    property CellLayout;
    property CellSpacing;
    property CellWidth;
    property InCellMargin;
    property ClientHeight;
    property ClientWidth;
    property Color;
    property ColWidth;
    property Constraints;
    property Ctl3D;
    property DefaultDrawing;
    property DesignPreview;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DragScroll;
    property Enabled;
    property FileFormats;
    property FileNames;
    property Folder;
    property ItemIndex;
    property MarkerColor;
    property MarkerStyle;
    property OnCanResize;
    property OnClick;
    property OnClickCell;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDblClick;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawCell;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureThumb;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnProgress;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property OnUnresolved;
    property ParentBackground;
    property RetainUnresolvedItems;
    property RowHeight;
    property ParentColor;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property Proportional;
    property ShowHint;
    property Sorted;
    property Stretch;
    property TabOrder;
    property TabStop;
    property Visible;
    property WheelScrollLines;
  end;

implementation
  uses
    RDGlobal, RDUtils;

function StrCmpLogicalW(const sz1, sz2: WideString): Integer; stdcall;
  external 'Shlwapi.dll';

procedure GetImageExtensions(List: TStrings);
var
  Temp: TStringList;
  S: String;
//  Count: Cardinal;
//  Size: Cardinal;
//  Decoders: array of TImageCodecInfo;
//  I: Integer;
begin
  Temp := TStringList.Create;
  try
    Temp.Duplicates := dupIgnore;
    Temp.Sorted := True;
//    s := getSupPicExts;
    s := '*.png;*.gif;*.jpg;*.jpeg';
{    S := GraphicFileMask(TGraphic);
    if GetImageDecodersSize(Count, Size) =  Ok then
    begin
      SetLength(Decoders, Size div SizeOf(TImageCodecInfo));
      if GetImageDecoders(Count, Size, @Decoders[0]) = Ok then
        for I := 0 to Count - 1 do
          S := S + ';' + LowerCase(Decoders[I].FilenameExtension);
    end;}
    ExtractStrings([';'], ['*', '.'], PChar(S), Temp);
    List.AddStrings(Temp);
  finally
    Temp.Free;
  end;
end;

{ TImageGridItems }

function TImageGridItems.Add(const S: String): Integer;
begin
  Result := AddItem(S, nil, nil, nil);
end;

function TImageGridItems.AddImage(const S: String; AImage: TGraphic): Integer;
begin
  Result := AddItem(S, nil, AImage, nil);
end;

function TImageGridItems.AddItem(const S: String; AObject: TObject;
  AImage: TGraphic; AThumb: TGraphic): Integer;
begin
  if FSorted then
    Find(S, Result)
  else
    Result := FCount;
  InsertItem(Result, S, AObject, AImage, AThumb);
end;

function TImageGridItems.AddObject(const S: String; AObject: TObject): Integer;
begin
  Result := AddItem(S, AObject, nil, nil);
end;

procedure TImageGridItems.AddStrings(Strings: TStrings);
var
  I: Integer;
  Item: TImageGridItem;
begin
  if Strings is TImageGridItems then
  begin
    BeginUpdate;
    try
      for I := 0 to Strings.Count - 1 do
      begin
        Item := TImageGridItems(Strings).FList^[I];
        AddItem(Item.FFileName, Item.FObject, Item.FImage, Item.FThumb);
      end;
    finally
      EndUpdate;
    end;
  end
  else
    inherited AddStrings(Strings);
end;

function TImageGridItems.AddThumb(const S: String; AThumb: TGraphic): Integer;
begin
  Result := AddItem(S, nil, nil, AThumb);
end;

procedure TImageGridItems.Assign(Source: TPersistent);
begin
  if Source is TImageGridItems then
  begin
    BeginUpdate;
    try
      FSorted := TImageGridItems(Source).FSorted;
      FOnChanged := TImageGridItems(Source).FOnChanged;
      inherited Assign(Source);
      Changed;
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TImageGridItems.Changed;
begin
  FChanged := True;
  if (UpdateCount = 0) and Assigned(FOnChanged) then
  begin
    FOnChanged(Self);
    FChanged := False;
  end;
end;

procedure TImageGridItems.Changing;
begin
  if (UpdateCount = 0) and Assigned(FOnChanging) then
    FOnChanging(Self);
end;

procedure TImageGridItems.Clear;
var
  I: Integer;
begin
  if FCount <> 0 then
  begin
    Changing;
    for I := 0 to FCount - 1 do
      FList^[I].FThumb.Free;
    if FOwnsObjects then
      for I := 0 to FCount - 1 do
        FList^[I].FObject.Free;
    Finalize(FList^[0], FCount);
    FCount := 0;
    SetCapacity(0);
    Changed;
  end;
end;

procedure TImageGridItems.ClearThumbs;
var
  I: Integer;
begin
  BeginUpdate;
  for I := 0 to FCount - 1 do
    FreeAndNil(FList^[I].FThumb);
  EndUpdate;
end;

function TImageGridItems.CompareStrings(const S1, S2: String): Integer;
begin
  Result := StrCmpLogicalW(S1, S2);
end;

procedure TImageGridItems.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  Changing;
  FList^[Index].FThumb.Free;
  if FOwnsObjects then
    FList^[Index].FObject.Free;
  Finalize(FList^[Index]);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(TImageGridItem));
  Changed;
end;

destructor TImageGridItems.Destroy;
begin
  FOnChanged := nil;
  FOnChanging := nil;
  Clear;
  inherited Destroy;
end;

procedure TImageGridItems.Exchange(Index1, Index2: Integer);
begin
  if (Index1 < 0) or (Index1 >= FCount) then
    Error(@SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then
    Error(@SListIndexError, Index2);
  Changing;
  ExchangeItems(Index1, Index2);
  Changed;
end;

procedure TImageGridItems.ExchangeItems(Index1, Index2: NativeInt);
var
  Temp: NativeInt;
  Item1: PImageGridItem;
  Item2: PImageGridItem;
begin
  Item1 := @FList^[Index1];
  Item2 := @FList^[Index2];
  Temp := NativeInt(Item1^.FFileName);
  NativeInt(Item1^.FFileName) := NativeInt(Item2^.FFileName);
  NativeInt(Item2^.FFileName) := Temp;
  Temp := NativeInt(Item1^.FObject);
  NativeInt(Item1^.FObject) := NativeInt(Item2^.FObject);
  NativeInt(Item2^.FObject) := Temp;
  Temp := NativeInt(Item1^.FThumb);
  NativeInt(Item1^.FThumb) := NativeInt(Item2^.FThumb);
  NativeInt(Item2^.FThumb) := Temp;
end;

function TImageGridItems.Find(const S: String; var Index: Integer): Boolean;
var
  L: Integer;
  H: Integer;
  I: Integer;
  C: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := CompareStrings(FList^[I].FFileName, S);
    if C < 0 then
      L := I + 1
    else
    begin
      H := I - 1;
      if C = 0 then
        Result := True;
    end;
  end;
  Index := L;
end;

function TImageGridItems.Get(Index: Integer): String;
begin
  if (Index < 0) or (Index >= FCount) then
    Result := '' // Error(@SListgeIndexError, Index);
  else
    Result := FList^[Index].FFileName;
end;

function TImageGridItems.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TImageGridItems.GetCount: Integer;
begin
  Result := FCount;
end;

function TImageGridItems.GetImage(Index: Integer): TGraphic;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  Result := FList^[Index].FImage;
end;

function TImageGridItems.GetObject(Index: Integer): TObject;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  Result := FList^[Index].FObject;
end;

function TImageGridItems.GetThumb(Index: Integer): TGraphic;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  Result := FList^[Index].FThumb;
end;

procedure TImageGridItems.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else if FCapacity > 8 then
    Delta := 16
  else
    Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TImageGridItems.IndexOf(const S: String): Integer;
begin
  if not FSorted then
    Result := inherited IndexOf(S)
  else
    if not Find(S, Result) then
      Result := -1;
end;

procedure TImageGridItems.Insert(Index: Integer; const S: String);
begin
  InsertObject(Index, S, nil);
end;

procedure TImageGridItems.InsertItem(Index: Integer; const S: String;
  AObject: TObject; AImage: TGraphic; AThumb: TGraphic);
begin
  Changing;
  if FCount = FCapacity then
    Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(TImageGridItem));
  Pointer(FList^[Index].FFileName) := nil;
  FList^[Index].FFileName := S;
  FList^[Index].FObject := AObject;
  FList^[Index].FImage := AImage;
  FList^[Index].FThumb := AThumb;
  Inc(FCount);
  Changed;
end;

procedure TImageGridItems.InsertObject(Index: Integer; const S: String;
  AObject: TObject);
begin
  if FSorted then
    Error(@SSortedListError, 0);
  if (Index < 0) or (Index > FCount) then
    Error(@SListIndexError, Index);
  InsertItem(Index, S, AObject, nil, nil);
end;

procedure TImageGridItems.Put(Index: Integer; const S: String);
begin
  if FSorted then
    Error(@SSortedListError, 0);
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  if FList^[Index].FFileName <> S then
  begin
    Changing;
    if FList^[Index].FImage = nil then
      FreeAndNil(FList^[Index].FThumb);
    FList^[Index].FFileName := S;
    Changed;
  end;
end;

procedure TImageGridItems.PutImage(Index: Integer; AImage: TGraphic);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  if Flist^[Index].FImage <> AImage then
  begin
    Changing;
    FList^[Index].FImage := AImage;
    FreeAndNil(FList^[Index].FThumb);
    Changed;
  end;
end;

procedure TImageGridItems.PutObject(Index: Integer; AObject: TObject);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  if FList^[Index].FObject <> AObject then
  begin
    Changing;
    FList^[Index].FObject := AObject;
    Changed;
  end;
end;

procedure TImageGridItems.PutThumb(Index: Integer; AThumb: TGraphic);
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  if FList^[Index].FThumb <> AThumb then
  begin
    Changing;
    FList^[Index].FThumb := AThumb;
    Changed;
  end;
end;

procedure TImageGridItems.PutThumbSilently(Index: Integer; AThumb: TGraphic);
begin
  if (Index >= 0) and (Index < FCount) then
    FList^[Index].FThumb := AThumb;
end;

procedure TImageGridItems.QuickSort(L, R: Integer);
var
  I: Integer;
  J: Integer;
  P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while CompareStrings(FList^[I].FFileName, FList^[P].FFileName) < 0 do
        Inc(I);
      while CompareStrings(FList^[J].FFileName, FList^[P].FFileName) > 0 do
        Dec(J);
      if I <= J then
      begin
        ExchangeItems(I, J);
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(L, J);
    L := I;
  until I >= R;
end;

procedure TImageGridItems.SetCapacity(Value: Integer);
begin
  if FCapacity <> Value then
  begin
    ReallocMem(FList, Value * SizeOf(TImageGridItem));
    FCapacity := Value;
  end;
end;

procedure TImageGridItems.SetSorted(Value: Boolean);
begin
  if FSorted <> Value then
  begin
    if Value then
      Sort;
    FSorted := Value;
  end;
end;

procedure TImageGridItems.SetUpdateState(Updating: Boolean);
begin
  if Updating then
    Changing
  else if FChanged then
    Changed;
end;

procedure TImageGridItems.Sort;
begin
  if not FSorted and (FCount > 1) then
  begin
    Changing;
    QuickSort(0, FCount - 1);
    Changed;
  end;
end;

{ TBorderControl }

procedure TBorderControl.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then
    RecreateWnd;
  inherited;
end;

constructor TBorderControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if NewStyleControls then
    ControlStyle := [csNeedsBorderPaint]
  else
    ControlStyle := [csNeedsBorderPaint, csFramed];
  FBorderStyle := bsSingle;
end;

procedure TBorderControl.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  Params.WindowClass.style :=
    Params.WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
  begin
    Params.Style := Params.Style and not WS_BORDER;
    Params.ExStyle := Params.ExStyle or WS_EX_CLIENTEDGE;
  end
  else
    Params.Style := Params.Style or BorderStyles[FBorderStyle];
end;

procedure TBorderControl.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    if FBorderStyle = bsSingle then
      ControlStyle := ControlStyle + [csNeedsBorderPaint]
    else
      ControlStyle := ControlStyle - [csNeedsBorderPaint];
    RecreateWnd;
  end;
end;

function TBorderControl.TotalBorderWidth: Integer;
begin
  if GetWindowLong(Handle, GWL_STYLE) and WS_VSCROLL <> 0 then
    Result := (Width - ClientWidth - GetSystemMetrics(SM_CXVSCROLL)) div 2
  else
    Result := (Width - ClientWidth) div 2;
end;

procedure TBorderControl.WMNCPaint(var Message: TWMNCPaint);
{$IF CompilerVersion < 18.5} {D2007}
var
  DC: HDC;
  TotalBorderWidth: Integer;
{$IFEND}
begin
{$IF CompilerVersion < 18.5}
  DC := GetWindowDC(Handle);
  try
    TotalBorderWidth := Self.TotalBorderWidth;
    if GetWindowLong(Handle, GWL_STYLE) and WS_HSCROLL <> 0 then
      FillRect(DC, Rect(0, Height - TotalBorderWidth, Width, Height),
        Brush.Handle);
    if GetWindowLong(Handle, GWL_STYLE) and WS_VSCROLL <> 0 then
      FillRect(DC, Rect(Width - TotalBorderWidth, 0, Width, Height),
        Brush.Handle);
  finally
    ReleaseDC(Handle, DC);
  end;
{$IFEND}
  inherited;
end;

{ TAnimRowScroller }

const
  ScrollTimerId = 123;
  DragTimerId = 234;
  ScrollTimerInterval = 15;
  DragTimerInterval = 15;

constructor TAnimRowScroller.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoHideScrollbar := True;
  FRow := -1;
  FRowHeight := DefRowHeight;
  FDragScroll := True;
  FWheelScrollLines := Mouse.WheelScrollLines;
end;

procedure TAnimRowScroller.CreateWnd;
begin
  inherited CreateWnd;
  UpdateScrollBar;
end;

function TAnimRowScroller.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
var
  I: Integer;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  if not Result then
  begin
    for I := 0 to FWheelScrollLines - 1 do
      if WheelDelta < 0 then
        Perform(WM_VSCROLL, MakeLong(SB_LINEDOWN, 0), 0)
      else
        Perform(WM_VSCROLL, MakeLong(SB_LINEUP, 0), 0);
    Result := True;
  end;
end;

procedure TAnimRowScroller.Drag;
var
  Delay: Cardinal;
begin
  Delay := GetTickCount - FPrevTick;
  if FDragScrolling then
  begin
    if Delay = 0 then
      Delay := 1;
    FDragSpeed := (FScrollingPos - FPrevScrollPos) / Delay;
  end
  else
  begin
    if Abs(FDragSpeed) < 0.005 then
    begin
      KillTimer(Handle, DragTimerId);
    end
    else
    begin
      SetScrollPos(FPrevScrollPos + Round(Delay * FDragSpeed), False, False);
      FDragSpeed := 0.83 * FDragSpeed;
    end;
  end;
  FPrevScrollPos := FScrollingPos;
  FPrevTick := GetTickCount;
end;

function TAnimRowScroller.IsWheelScrollLinesStored: Boolean;
begin
  Result := FWheelScrollLines <> Mouse.WheelScrollLines;
end;

procedure TAnimRowScroller.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if FDragScroll then
    FDragStartPos := Y + FScrollingPos;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TAnimRowScroller.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FDragScroll and (not FDragScrolling) and (ssLeft in Shift) and
    (Abs(Y - FDragStartPos) > Mouse.DragThreshold) then
  begin
    FPrevScrollPos := FScrollingPos;
    FDragScrolling := True;
    SetTimer(Handle, DragTimerId, DragTimerInterval, nil);
  end;

  if FDragScrolling then
    SetScrollPos(FDragStartPos - Y, False, False);

  if not (Scrolling) then Invalidate;
  inherited MouseMove(Shift, X, Y);
end;

procedure TAnimRowScroller.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FDragScrolling := False;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TAnimRowScroller.MouseWheelHandler(var Message: TMessage);
var
  Form: TCustomForm;
begin
  Message.Result := Perform(CM_MOUSEWHEEL, Message.WParam, Message.LParam);
  if Message.Result = 0 then
  begin
    Form := GetParentForm(Self);
    if Form <> nil then
      Form.MouseWheelHandler(Message);
  end;
end;

procedure TAnimRowScroller.Resize;
begin
  UpdateScrollBar;
  inherited Resize;
end;

procedure TAnimRowScroller.Scroll;
var
  Diff: Integer;
  Delta: Integer;
begin
  Diff := FScrollingPos - FScrollPos;
  if Diff <> 0 then
  begin
    if Abs(Diff) > 3 then
      Delta := Diff div 4
    else if Abs(Diff) > 1 then
      Delta := Diff div 2
    else
      Delta := Diff;
    ScrollWindow(Handle, 0, Delta, nil, nil);
    Dec(FScrollingPos, Delta);
  end
    else
  KillTimer(Handle, ScrollTimerId);
end;

function TAnimRowScroller.Scrolling: Boolean;
begin
  Result := (FScrollingPos <> FScrollPos) or FDragScrolling;
end;

procedure TAnimRowScroller.SetAutoHideScrollBar(Value: Boolean);
begin
  if FAutoHideScrollBar <> Value then
  begin
    FAutoHideScrollBar := Value;
    UpdateScrollBar;
  end;
end;

procedure TAnimRowScroller.SetRow(Value: Integer);
begin
  if FRow <> Value then
  begin
    FRow := Max(-1, Min(Value, FRowCount - 1));
    UpdateScrollBar;
    Invalidate;
  end;
end;

procedure TAnimRowScroller.SetRowCount(Value: Integer);
begin
  if FRowCount <> Value then
  begin
    FRowCount := Max(0, Value);
    UpdateScrollBar;
    Invalidate;
  end;
end;

procedure TAnimRowScroller.SetRowHeight(Value: Integer);
begin
  if FRowHeight <> Value then
  begin
    FRowHeight := Max(MinCellSize, Value);
    UpdateScrollBar;
    Invalidate;
  end;
end;

procedure TAnimRowScroller.SetScrollPos(Value: Integer; Animate,
  Snap: Boolean);
var
  PageHeight: Integer;
  AlreadyScrolling: Boolean;
begin
  if FScrollPos <> Value then
  begin
    PageHeight := (ClientHeight div FRowHeight) * FRowHeight;
    Value := Max(0, Min(Value, FRowCount * FRowHeight - PageHeight));
    if Snap then
      Value := (Value div FRowHeight) * FRowHeight;
    Windows.SetScrollPos(Handle, SB_VERT, Value, True);
    if Animate then
    begin
      AlreadyScrolling := Scrolling;
      FScrollPos := Value;
      if not AlreadyScrolling then
        SetTimer(Handle, ScrollTimerId, ScrollTimerInterval, nil);
    end
    else
    begin
      ScrollWindow(Handle, 0, FScrollPos - Value, nil, nil);
      FScrollPos := Value;
      FScrollingPos := FScrollPos;
    end;
  end;
end;

procedure TAnimRowScroller.UpdateScrollBar;
var
  PageHeight: Integer;
  Info: TScrollInfo;
  RowPos: Integer;
begin
  if HandleAllocated then
  begin
    PageHeight := (ClientHeight div FRowHeight) * FRowHeight;
    Info.cbSize := SizeOf(TScrollInfo);
    Info.fMask := SIF_ALL;
    Info.nMin := 0;
    Info.nMax := FRowCount * FRowHeight;
    Info.nPage := PageHeight;
    Info.nPos := Max(0, Min(FScrollPos, Info.nMax - PageHeight));
    if FRow >= 0 then
    begin
      RowPos := FRow * FRowHeight;
      if RowPos < Info.nPos then
        Info.nPos := RowPos
      else if RowPos > (Info.nPos + PageHeight - FRowHeight) then
        Info.nPos := RowPos - PageHeight + FRowHeight;
    end;

    if Info.nMax <= PageHeight then
    begin
      FScrollPos := 0;
      FScrollingPos := 0;
      if FAutoHideScrollBar then
        ShowScrollBar(Handle, SB_VERT, False)
      else
      begin
        ShowScrollBar(Handle, SB_VERT, True);
        EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_BOTH);
      end;
    end
    else
    begin
      FScrollPos := Info.nPos;
      FScrollingPos := Info.nPos;
      ShowScrollBar(Handle, SB_VERT, True);
      if Enabled then
      begin
        EnableScrollBar(Handle, SB_VERT, ESB_ENABLE_BOTH);
        SetScrollInfo(Handle, SB_VERT, Info, True);
      end
        else
      EnableScrollBar(Handle, SB_VERT, ESB_DISABLE_BOTH);
    end;
  end;
end;

procedure TAnimRowScroller.WMVScroll(var Message: TWMVScroll);

  function RealScrollPos: Integer;
  var
    Info: TScrollInfo;
  begin
    Info.cbSize := SizeOf(TScrollInfo);
    Info.fMask := SIF_TRACKPOS;
    Result := Message.Pos;
    if GetScrollInfo(Handle, SB_VERT, Info) then
      Result := Info.nTrackPos;
  end;

var
  PageHeight: Integer;
begin
  PageHeight := (ClientHeight div FRowHeight) * FRowHeight;
  case Message.ScrollCode of
    SB_LINEUP:
      SetScrollPos(FScrollPos - FRowHeight, True, True);
    SB_LINEDOWN:
      SetScrollPos(FScrollPos + FRowHeight, True, True);
    SB_PAGEUP:
      SetScrollPos(FScrollPos - PageHeight, True, True);
    SB_PAGEDOWN:
      SetScrollPos(FScrollPos + PageHeight, True, True);
    SB_THUMBPOSITION:
      SetScrollPos(RealScrollPos, True, False);
    SB_THUMBTRACK:
      SetScrollPos(RealScrollPos, False, False);
    SB_TOP:
      SetScrollPos(0, False, True);
    SB_BOTTOM:
      SetScrollPos(FRowCount * FRowHeight, False, False);
  end;
  inherited;
end;

procedure TAnimRowScroller.WndProc(var Message: TMessage);
begin
  if (Message.Msg <> WM_TIMER) then
    inherited WndProc(Message)
  else if TWMTimer(Message).TimerID = ScrollTimerId then
    Scroll
  else if TWMTimer(Message).TimerID = DragTimerId then
    Drag;
end;

{ TCustomImageGrid }

function TCustomImageGrid.CellRect(Index: Integer): TRect;
var
  Coord: TGridCoord;
begin
  Coord := CoordFromIndex(Index);
  Result := Bounds(Coord.X * FColWidth, Coord.Y * RowHeight, CellWidth,
    CellHeight);
  Dec(Result.Top, ScrollingPos);
  Dec(Result.Bottom, ScrollingPos);
end;

procedure TCustomImageGrid.ChangeScale(M, D: Integer);
begin
  inherited ChangeScale(M, D);
  BorderWidth := MulDiv(BorderWidth, M, D);
  FCellSpacing := MulDiv(FCellSpacing, M, D);
  SetCoordSize(MulDiv(FColWidth, M, D), MulDiv(RowHeight, M, D));
end;

procedure TCustomImageGrid.Clear;
begin
  FItems.Clear;
end;

procedure TCustomImageGrid.CMEnter(var Message: TCMEnter);
begin
  inherited;
end;

procedure TCustomImageGrid.CMExit(var Message: TCMExit);
begin
  inherited;
end;

procedure TCustomImageGrid.CMMouseLeave(var msg: TMessage);
begin
  Invalidate;
end;

function TCustomImageGrid.CoordFromIndex(Index: Integer): TGridCoord;
begin
  Result.X := Index mod FColCount;
  Result.Y := Index div FColCount;
end;

constructor TCustomImageGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csCaptureMouse, csClickEvents, csOpaque,
    csDoubleClicks];
  Width := 218;
  Height := 134;
  TabStop := True;
  FCellAlignment := taCenter;
  FCellLayout := tlCenter;
  FCellSpacing := DefCellSpacing;
  FColCount := 1;
  FColWidth := DefColWidth;
  FDefaultDrawing := True;
  FItemIndex := -1;
  FMarkerColor := clGray;
  FMarkerStyle := psDash;
  FProportional := True;
  FFileFormats := TStringList.Create;
  if csDesigning in ComponentState then
    GetImageExtensions(FFileFormats);
  TStringList(FFileFormats).OnChange := FileFormatsChanged;
  FItems := TImageGridItems.Create;
  FItems.OnChanged := ItemsChanged;
end;

procedure TCustomImageGrid.DeleteUnresolvedItems;
var
  I: Integer;
  PrevCount: Integer;
begin
  PrevCount := Count;
  FItems.BeginUpdate;
  try
    for I := Count - 1 downto 0 do
      if FItems.Thumbs[I] = nil then
        FItems.Delete(I);
  finally
    FItems.EndUpdate;
  end;
  if Count <> PrevCount then
    Rearrange;
end;

destructor TCustomImageGrid.Destroy;
begin
  FItems.OnChanged := nil;
  FItems.OnChanging := nil;
  TStringList(FFileFormats).OnChange := nil;
  FItems.Free;
  FFileFormats.Free;
  inherited Destroy;
end;

procedure TCustomImageGrid.DoClickCell(Index: Integer);
begin
  ItemIndex := Index;
  if Assigned(FOnClickCell) then
    FOnClickCell(Self, Index);
end;

procedure TCustomImageGrid.DoDrawCell(Index, ACol, ARow: Integer;
  R: TRect);
begin
  if Assigned(FOnDrawCell) then
    FOnDrawCell(Self, Index, ACol, ARow, R);
end;

procedure TCustomImageGrid.DoMeasureThumb(Index: Integer; var AThumbWidth,
  AThumbHeight: Integer);
begin
  AThumbWidth := CellWidth;
  AThumbHeight := CellHeight;
  if Assigned(FOnMeasureThumb) then
  begin
    FOnMeasureThumb(Self, Index, AThumbWidth, AThumbHeight);
    AThumbWidth := Max(MinThumbSize, Min(AThumbWidth, CellWidth));
    AThumbHeight := Max(MinThumbSize, Min(AThumbHeight, CellHeight));
  end;
end;

procedure TCustomImageGrid.DoProgress(Index: Integer);
begin
  InvalidateItem(Index);
  if FItems.Thumbs[Index] = nil then
    if Assigned(FOnUnresolved) then
      FOnUnresolved(Self, Index);
  if Assigned(FOnProgress) then
    FOnProgress(Self, Index);
end;

procedure TCustomImageGrid.FileFormatsChanged(Sender: TObject);
var
  SaveFolder: TPath;
  I: Integer;
  Ext: String;
begin
  SaveFolder := FFolder;
  FItems.BeginUpdate;
  try
    for I := Count - 1 downto 0 do
    begin
      Ext := ExtractFileExt(FItems.FileNames[I]);
      Delete(Ext, 1, 1);
      if FFileFormats.IndexOf(Ext) = -1 then
        FItems.Delete(I);
    end;
  finally
    FItems.EndUpdate;
    FFolder := SaveFolder;
  end;
end;

function TCustomImageGrid.GetCellHeight: Integer;
begin
  Result := RowHeight - FCellSpacing;
end;

function TCustomImageGrid.GetCellWidth: Integer;
begin
  Result := FColWidth - FCellSpacing;
end;

function TCustomImageGrid.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TCustomImageGrid.GetFileNames: TStrings;
begin
  Result := FItems;
end;

function TCustomImageGrid.GetImage(Index: Integer): TGraphic;
begin
  Result := FItems.Images[Index];
end;

function TCustomImageGrid.GetRowCount: Integer;
begin
  Result := inherited RowCount;
end;

function TCustomImageGrid.GetSorted: Boolean;
begin
  Result := FItems.Sorted;
end;

function TCustomImageGrid.GetThumb(Index: Integer): TGraphic;
begin
  Result := FItems.Thumbs[Index];
end;

procedure TCustomImageGrid.InvalidateItem(Index: Integer);
var
  Coord: TGridCoord;
  R: TRect;
begin
  Coord := CoordFromIndex(Index);
  R := Bounds(Coord.X * FColWidth, Coord.Y * RowHeight - ScrollingPos,
    FColWidth, RowHeight);
  InvalidateRect(Handle, @R, False);
end;

function TCustomImageGrid.IsFileNamesStored: Boolean;
begin
  Result := FFolder = '';
end;

procedure TCustomImageGrid.ItemsChanged(Sender: TObject);
begin
  if (FItemIndex = -1) and (Count > 0) then
    FItemIndex := 0;
  FFolder := '';
  Rearrange;
end;

procedure TCustomImageGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP:
      ItemIndex := FItemIndex - FColCount;
    VK_DOWN:
      ItemIndex := FItemIndex + FColCount;
    VK_LEFT:
      ItemIndex := FItemIndex - 1;
    VK_RIGHT:
      ItemIndex := FItemIndex + 1;
    VK_PRIOR:
      ItemIndex := FItemIndex - (FColCount * (ClientHeight div FRowHeight));
    VK_NEXT:
      ItemIndex := FItemIndex + (FColCount * (ClientHeight div FRowHeight));
    VK_HOME:
      ItemIndex := 0;
    VK_END:
      ItemIndex := FItems.Count - 1;
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TCustomImageGrid.Loaded;
begin
  inherited Loaded;
  Rearrange;
end;

procedure TCustomImageGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if not (csDesigning in ComponentState) and CanFocus then
    SetFocus;
  inherited MouseDown(Button, Shift, X, Y);
end;

function TCustomImageGrid.MouseToIndex(X, Y: Integer): Integer;
var
  Col: Integer;
  Row: Integer;
begin
  if PtInRect(ClientRect, Point(X, Y)) then
  begin
    Inc(Y, ScrollingPos);
    Col := X div FColWidth;
    Row := Y div RowHeight;
    if (X < Col * FColWidth + CellWidth) and
        (Y < Row * RowHeight + CellHeight) and
        (Row * FColCount + Col < Count) then
      Result := Row * FColCount + Col
    else
      Result := -1;
  end
  else
    Result := -1;
end;

procedure TCustomImageGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (not DragScrolling) and (Button = mbLeft) then
    DoClickCell(MouseToIndex(X, Y));
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TCustomImageGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Index, Col, Row, Y2: Integer;
begin
  if PtInRect(ClientRect, Point(X, Y)) then
  begin
    Y2 := Y + ScrollingPos;
    Col := X div FColWidth;
    if Col > FColCount - 1 then
      Index := -1
    else
    begin
      Row := Y2 div RowHeight;
      if (X < Col * FColWidth + CellWidth) and
         (Y2 < Row * RowHeight + CellHeight) and
         (Row * FColCount + Col < Count) then
        Index := Row * FColCount + Col
      else
        Index := -1;
    end;
  end
    else
  Index := -1;

  if (index >= 0) then
    FItemIndex := index;

  inherited MouseMove(Shift, X, Y);
end;

procedure TCustomImageGrid.Paint;
var
//  DrawParentBackGround: Boolean;
//  MouseOverThumb: Boolean;
//  MouseOverStickers: Boolean;
  UpdateCoords: TGridRect;
  Offset: TPoint;
  R: TRect;
  Col: Integer;
  Row: Integer;
  Index: Integer;
//  TempThumb: TRnQBitmap;
  Thumb: TGraphic;
  pic: TGraphic;
  Pt: TPoint;
  r2: TRect;
  DestR: TGPRect;
  w, h: Integer;
  ppi: Integer;
//  ThumbWidth: Integer;
//  ThumbHeight: Integer;
begin
//  DrawParentBackGround := ParentBackground and (Parent <> nil) and StyleServices.Enabled;
  ppi := GetParentCurrentDpi;
  Canvas.Brush.Color := Color;
  Canvas.Brush.Style := bsSolid;
  if FMarkerStyle = psClear then
  begin
    Canvas.Pen.Color := Color;
    Canvas.Pen.Style := psSolid;
  end
  else
  begin
    Canvas.Pen.Color := FMarkerColor;
    Canvas.Pen.Style := FMarkerStyle;
  end;

  Canvas.FillRect(Canvas.ClipRect);

  UpdateCoords.Left := Canvas.ClipRect.Left div FColWidth;
  UpdateCoords.Top := (ScrollingPos + Canvas.ClipRect.Top) div RowHeight;
  UpdateCoords.Right := Min(Canvas.ClipRect.Right div FColWidth, FColCount - 1);
  UpdateCoords.Bottom := Min((ScrollingPos + Canvas.ClipRect.Bottom) div RowHeight, RowCount - 1);
  Offset := Point(0, 0);
  R.Left := UpdateCoords.Left * FColWidth;
  R.Right := R.Left + FColWidth - FCellSpacing;
  for Col := UpdateCoords.Left to UpdateCoords.Right do
  begin
    R.Top := UpdateCoords.Top * RowHeight - ScrollingPos;
    R.Bottom := R.Top + RowHeight - FCellSpacing;
    for Row := UpdateCoords.Top to UpdateCoords.Bottom do
    begin
      Index := Row * FColCount + Col;
      if Index >= Count then
        Break;
      if FDefaultDrawing then
      begin
        Thumb := Thumbs[Index];
        if Thumb = nil then
          begin
            pic := Images[Index];
            if Assigned(pic) then
              begin
                if Focused and (not Scrolling) and (FItemIndex = Index) then
                  begin
                    if (GetAsyncKeyState(VK_LBUTTON) <> 0) then
                      Canvas.Brush.Color := $00DEDEDE
                    else
                      Canvas.Brush.Color := $00E3E3E3;

                    Canvas.Brush.Style := bsSolid;
                    Canvas.RoundRect(R.Left + 2, R.Top + 2, R.Right - 2, R.Bottom - 2, 10, 10);
                    Canvas.Brush.Color := Color;
                  end;
                begin
                  r2.Left := R.Left + InCellMargin;
                  r2.Top := R.Top + InCellMargin;
                  r2.Right := R.Right - InCellMargin;
                  r2.Bottom := R.Bottom - InCellMargin;
                  SetStretchBltMode(Canvas.Handle, HALFTONE);
                  Canvas.StretchDraw(r2, pic);
                end;

              end
             else
              Canvas.Rectangle(R)
          end
        else
        begin
//          ThumbWidth := Min(Thumb.Width, CellWidth);
//          ThumbHeight := Min(Thumb.Height, CellHeight);

          (*
          TempThumb := TRnQBitmap.Create;
          TempThumb.f32Alpha := True;
          TempThumb.fFormat := PA_FORMAT_PNG;
          TempThumb.fBmp := TBitmap.Create;
          TempThumb.fBmp.Assign(Thumb);
          TempThumb.fBmp.AlphaFormat := afPremultiplied;
          TempThumb.fBmp.PixelFormat := pf32bit;
          ResampleSticker(TempThumb.fBmp, ThumbHeight - 15, ThumbWidth - 15);
          TempThumb.fHeight := TempThumb.fBmp.Height;
          TempThumb.fWidth := TempThumb.fBmp.Width;

          case FCellAlignment of
            taCenter:
              Offset.X := (R.Right - R.Left - TempThumb.fBmp.Width) div 2;
            taRightJustify:
              Offset.X := R.Right - R.Left - TempThumb.fBmp.Width;
          end;

          case FCellLayout of
            tlCenter:
              Offset.Y := (R.Bottom - R.Top - TempThumb.fBmp.Height) div 2;
            tlBottom:
              Offset.Y := R.Bottom - R.Top - TempThumb.fBmp.Height;
          end;
         *)
          //MouseOverThumb := Types.PtInRect(R, ScreenToClient(Mouse.CursorPos));
          if Focused and (not Scrolling) and (FItemIndex = Index) then
          begin
            if (GetAsyncKeyState(VK_LBUTTON) <> 0) then
              Canvas.Brush.Color := $00DEDEDE
            else
              Canvas.Brush.Color := $00E3E3E3;

            Canvas.Brush.Style := bsSolid;
            Canvas.RoundRect(R.Left + 2, R.Top + 2, R.Right - 2, R.Bottom - 2, 10, 10);
            Canvas.Brush.Color := Color;
          end;
          (*
          DrawRbmp(Canvas.Handle, TempThumb, R.Left + Offset.X, R.Top + Offset.Y);
          TempThumb.Free;
          *)
          begin
              w := R.Right - R.Left - InCellMargin-InCellMargin;
              h := R.Bottom - R.Top - InCellMargin-InCellMargin;
              r2.Left := R.Left + InCellMargin;
              r2.Top := R.Top + InCellMargin;
              if (w <> (Thumb.Width))
                 or (h <> (Thumb.Height)) then
               begin
                if not Stretch then
                  begin
                   GetBrushOrgEx(Canvas.Handle, pt);
                   SetStretchBltMode(Canvas.Handle, HALFTONE);
                   SetBrushOrgEx(Canvas.Handle, pt.x, pt.y, @pt);
                   Canvas.Draw(r2.Left, r2.Top, Thumb);
                  end
                 else
                  begin
                   DestR := DestRect(thumb.Width, thumb.Height, w, h, True);
                   r2.Left := R.Left + InCellMargin + DestR.X;
                   r2.Top := R.Top + InCellMargin + DestR.Y;
                   r2.Right := r2.Left + DestR.Width;
                   r2.Bottom := r2.Top + DestR.Height;
                   SetStretchBltMode(Canvas.Handle, HALFTONE);
                   Canvas.StretchDraw(R2, Thumb);
                  end;
               end
              else
                Canvas.Draw(r2.Left, r2.Top, Thumb);
          end;
//          SetStretchBltMode(Canvas.Handle, HALFTONE);
//          Canvas.StretchDraw(R, Thumb);
//          DrawRbmp(Canvas.Handle, Thumb, MakeRect(R));
        end;
      end
      else if csDesigning in ComponentState then
        Canvas.FillRect(R);
      DoDrawCell(Index, Col, Row, R);
      Inc(R.Top, RowHeight);
      Inc(R.Bottom, RowHeight);
    end;
    Inc(R.Left, FColWidth);
    Inc(R.Right, FColWidth);
  end;
end;

procedure TCustomImageGrid.Rearrange;
var
  NewClientWidth: Integer;
  NewRowCount: Integer;
begin
  if HandleAllocated then
  begin
    NewClientWidth := Width - 2 * TotalBorderWidth;
    if not AutoHideScrollBar then
      Dec(NewClientWidth, GetSystemMetrics(SM_CXVSCROLL));
    FColCount := Max(1, (NewClientWidth + FCellSpacing) div FColWidth);
    NewRowCount := Ceil(Count / FColCount);
    if AutoHideScrollBar and
      (NewRowCount * RowHeight > Height - 2 * TotalBorderWidth) then
    begin
      Dec(NewClientWidth, GetSystemMetrics(SM_CXVSCROLL));
      FColCount := Max(1, (NewClientWidth + FCellSpacing) div FColWidth);
      NewRowCount := Ceil(Count / FColCount);
    end;
    inherited RowCount := NewRowCount;
    Invalidate;
  end;
end;

procedure TCustomImageGrid.Resize;
begin
  Rearrange;
  inherited Resize;
end;

procedure TCustomImageGrid.ScrollInView(Index: Integer);
begin
  Row := CoordFromIndex(Index).Y;
end;

procedure TCustomImageGrid.SetCellAlignment(Value: TAlignment);
begin
  if FCellAlignment <> Value then
  begin
    FCellAlignment := Value;
    Invalidate;
  end;
end;

procedure TCustomImageGrid.SetCellHeight(Value: Integer);
begin
  SetCellSize(CellWidth, Value);
end;

procedure TCustomImageGrid.SetCellLayout(Value: TTextLayout);
begin
  if FCellLayout <> Value then
  begin
    FCellLayout := Value;
    Invalidate;
  end;
end;

procedure TCustomImageGrid.SetCellSize(ACellWidth, ACellHeight: Integer);
begin
  if (CellWidth <> ACellWidth) or (CellHeight <> ACellHeight) then
    SetCoordSize(ACellWidth + FCellSpacing, ACellHeight + FCellSpacing);
end;

procedure TCustomImageGrid.SetCellSpacing(Value: Integer);
var
  Diff: Integer;
begin
  Value := Max(0, Value);
  if FCellSpacing <> Value then
  begin
    Diff := Value - FCellSpacing;
    FCellSpacing := Value;
    SetCoordSize(FColWidth + Diff, RowHeight + Diff);
  end;
end;

procedure TCustomImageGrid.SetCellWidth(Value: Integer);
begin
  SetCellSize(Value, CellHeight);
end;

procedure TCustomImageGrid.SetColWidth(Value: Integer);
begin
  SetCoordSize(Value, RowHeight);
end;

procedure TCustomImageGrid.SetCoordSize(AColWidth, ARowHeight: Integer);
begin
  if (FColWidth <> AColWidth) or (RowHeight <> ARowHeight) then
  begin
    FColWidth := Max(MinCellSize + FCellSpacing, AColWidth);
    ARowHeight := Max(MinCellSize + FCellSpacing, ARowHeight);
    inherited SetRowHeight(ARowHeight);
    Rearrange;
  end;
end;

procedure TCustomImageGrid.SetDefaultDrawing(Value: Boolean);
begin
  if FDefaultDrawing <> Value then
  begin
    FDefaultDrawing := Value;
    Invalidate;
  end;
end;

procedure TCustomImageGrid.SetDesignPreview(Value: Boolean);
begin
  if FDesignPreview <> Value then
  begin
    FDesignPreview := Value;
    if csDesigning in ComponentState then
      if not FDesignPreview then
      begin
        FItems.ClearThumbs;
        Invalidate;
      end;
  end;
end;

procedure TCustomImageGrid.SetFileFormats(Value: TStrings);
begin
  FFileFormats.Assign(Value);
end;

procedure TCustomImageGrid.SetFileNames(Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TCustomImageGrid.SetFolder(Value: TPath);
const
  FileAttributes = FILE_ATTRIBUTE_NORMAL or FILE_ATTRIBUTE_ARCHIVE or
    FILE_ATTRIBUTE_READONLY;
var
  SearchRec: TSearchRec;
  I: Integer;
  Path: TPath;
begin
  if Value <> '' then
    Value := IncludeTrailingPathDelimiter(Value);
  if FFolder <> Value then
  begin
    FItems.BeginUpdate;
    try
      Clear;
      for I := 0 to FFileFormats.Count - 1 do
      begin
        Path := Value + '*.' + FFileFormats[I];
        if FindFirst(Path, FileAttributes, SearchRec) = 0 then
        try
          repeat
            FItems.Add(Value + SearchRec.Name);
          until FindNext(SearchRec) <> 0;
        finally
          FindClose(SearchRec);
        end;
      end;
    finally
      FItems.EndUpdate;
      FFolder := Value;
    end;
  end;
end;

procedure TCustomImageGrid.SetImage(Index: Integer; Value: TGraphic);
begin
  FItems.Images[Index] := Value;
end;

procedure TCustomImageGrid.SetItemIndex(Value: Integer);
begin
  if Count = 0 then
    Value := -1
  else
    Value := Max(0, Min(Value, Count - 1));
  if FItemIndex <> Value then
  begin
    FItemIndex := Value;
    ScrollInView(FItemIndex);
    Invalidate;
  end;
end;

procedure TCustomImageGrid.SetItems(Value: TImageGridItems);
begin
  FItems.Assign(Value);
end;

procedure TCustomImageGrid.SetMarkerColor(Value: TColor);
begin
  if FMarkerColor <> Value then
  begin
    FMarkerColor := Value;
    Invalidate;
  end;
end;

procedure TCustomImageGrid.SetMarkerStyle(Value: TPenStyle);
begin
  if FMarkerStyle <> Value then
  begin
    FMarkerStyle := Value;
    Invalidate;
  end;
end;

procedure TCustomImageGrid.SetProportional(Value: Boolean);
begin
  if FProportional <> Value then
  begin
    FProportional := Value;
    if FProportional then
      FItems.ClearThumbs;
  end;
end;

procedure TCustomImageGrid.SetRetainUnresolvedItems(Value: Boolean);
begin
  if FRetainUnresolvedItems <> Value then
  begin
    FRetainUnresolvedItems := Value;
    if not FRetainUnresolvedItems then
      DeleteUnresolvedItems;
  end;
end;

procedure TCustomImageGrid.SetRowHeight(Value: Integer);
begin
  SetCoordSize(FColWidth, Value);
end;

procedure TCustomImageGrid.SetSorted(Value: Boolean);
begin
  FItems.Sorted := Value;
end;

procedure TCustomImageGrid.SetStretch(Value: Boolean);
begin
  if FStretch <> Value then
    FStretch := Value;
end;

procedure TCustomImageGrid.SetThumb(Index: Integer; Value: TGraphic);
begin
  FItems.Thumbs[Index] := Value;
end;

{
procedure TCustomImageGrid.ThumbsUpdated(Sender: TObject);
begin
  if not FRetainUnresolvedItems then
    DeleteUnresolvedItems;
end;
}
procedure TCustomImageGrid.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TCustomImageGrid.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTARROWS;
end;

end.

