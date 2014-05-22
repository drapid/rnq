unit ShockwaveList;

interface

uses
  SysUtils, Classes, Controls, OleCtrls, ShockwaveFlashObjects_TLB,
  ShockwaveEx, Messages, ActiveX, Dialogs, Graphics;

type

TMoviesLayout=(mlSingle, mlMatrixLR, mlMatrixTB, mlDiagonal);

TShockwaveFlashList=Class;

TSWFChildren=Class(TShockwaveFlashEx)
  private
    fHost: TShockwaveFlashList;
  public
    constructor Create(AOwner: TComponent; AHost:TShockwaveFlashList); virtual;
  protected
    procedure WndProc(var Message:TMessage); override;
  published
    property Host: TShockwaveFlashList read fHost write fHost;
end;

TSWFItem=Class(TCollectionItem)
  private
    fSWF: TSWFChildren;
    fSWFName: string;
    procedure SetFileName(const Value: TFileName);
    function GetFileName: TFileName;
    procedure SetName(const Value: TComponentName);
    function GetName: TComponentName;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property FileName: TFileName read GetFileName write SetFileName;
    property SWF: TSWFChildren read fSWF write fSWF;
    property Name: TComponentName read GetName write SetName stored False;
end;

TSWFCollection=Class(TCollection)
  private
    fSWFList: TShockwaveFlashList;
    function GetItem(Index: Integer): TSWFItem;
    procedure SetItem(Index: Integer; const Value: TSWFItem);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(SWFList: TShockwaveFlashList);
    function Add: TSWFItem;
    procedure Delete(Index: Integer);
    property Items[Index: Integer]: TSWFItem read GetItem write SetItem; default;
end;

TShockwaveFlashList = class(TWinControl)
  private
    fItems: TSWFCollection;
    fItemIndex: integer;
    Host: TComponent;
    fCurentMovie: TShockwaveFlashEx;
    fLockMouseClick: boolean;
    fQuality: Integer;
    fScaleMode: Integer;
    fAlignMode: Integer;
    fBackgroundColor: TColor;
    fMenu: boolean;
    fMoviesLayout: TMoviesLayout;
    fMovieWidthToHeight: integer;
    fCountForLayout: integer;
    fKeepMoviesSize: boolean;
    fMoviesWidth: integer;
    fMoviesHeight: integer;
    fPlaying: boolean;
    fGleam: integer;
    procedure SetItems(const Value: TSWFCollection);
    procedure SetItem(const Value: integer);
    procedure SetLockMouseClick(const Value: boolean);
    procedure SetQuality(const Value: Integer);
    procedure SetScaleMode(const Value: Integer);
    procedure SetAlignMode(const Value: Integer);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetMenu(const Value: boolean);
    procedure SetMoviesLayout(const Value: TMoviesLayout);
    procedure SetMovieWidthToHeight(const Value: integer);
    procedure SetCountForLayout(const Value: integer);
    procedure SetKeepMoviesSize(const Value: boolean);
    procedure SetMoviesHeight(const Value: integer);
    procedure SetMoviesWidth(const Value: integer);
    procedure SetPlaying(const Value: boolean);
    procedure SetGleam(const Value: integer);
  protected
    procedure LoadFromItems;
    procedure WndProc(var Message:TMessage); override;
    function TColorToSWFColor(Value: TColor): integer;
    function MessageSwfNeed(SWF:TSWFChildren; Value: TMessage): boolean; virtual;
  public
    property CurentMovie: TShockwaveFlashEx read fCurentMovie default nil;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetZoomRect(left: Integer; top: Integer; right: Integer; bottom: Integer);
    procedure Zoom(factor: SYSINT);
    procedure Pan(x: Integer; y: Integer; mode: SYSINT);
    procedure Play;
    procedure Stop;
    procedure Back;
    procedure Forward;
    procedure Rewind;
    procedure StopPlay;
    procedure GotoFrame(FrameNum: Integer);
    function CurrentFrame: Integer;
    procedure LoadMovie(layer: SYSINT; const url: WideString);
    procedure RefreshMoviesLayout;
  published
    property Align;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property Items: TSWFCollection read fItems write SetItems;
    property ItemIndex: integer read fItemIndex write SetItem default 0;
    property LockMouseClick: boolean read fLockMouseClick write SetLockMouseClick stored false;
    property Quality: Integer read fQuality write SetQuality default 0;
    property Playing: boolean read fPlaying write SetPlaying stored true;
    property ScaleMode: Integer read fScaleMode write SetScaleMode default 0;
    property AlignMode: Integer read fAlignMode write SetAlignMode default 0;
    property BackgroundColor: TColor read fBackgroundColor write SetBackgroundColor default clWhite;
    property Menu: boolean read fMenu write SetMenu stored false;
    property MoviesLayout: TMoviesLayout read fMoviesLayout write SetMoviesLayout default mlSingle;
    property MovieWidthToHeight: integer read fMovieWidthToHeight write SetMovieWidthToHeight default 100;
    property CountForLayout: integer read fCountForLayout write SetCountForLayout default 0;
    property KeepMoviesSize: boolean read fKeepMoviesSize write SetKeepMoviesSize stored false;
    property MoviesWidth: integer read fMoviesWidth write SetMoviesWidth default 48;
    property MoviesHeight: integer read fMoviesHeight write SetMoviesHeight default 48;
    property Gleam: integer read fGleam write SetGleam default 0;    
end;

procedure Register;

implementation


Uses Types;

procedure Register;
begin
  RegisterComponents('ActiveX', [TShockwaveFlashList]);
end;


{ TSWFItem }

constructor TSWFItem.Create(Collection: TCollection);
begin
  inherited;
end;

destructor TSWFItem.Destroy;
begin
  if (fSWF<>nil) and (csDesigning in fSWF.ComponentState) Then fSWF.Free;
  inherited;
end;

function TSWFItem.GetFileName: TFileName;
begin
  if fSWF<>nil Then Result:=fSWF.Movie Else Result:='';
end;

function TSWFItem.GetName: TComponentName;
begin
  if fSWF<>nil Then Result:=fSWF.Name Else Result:='';
end;

procedure TSWFItem.SetFileName(const Value: TFileName);
begin
  if fSWF<>nil Then
    begin
      fSWF.EmbedMovie:=false;
      fSWF.Movie:=Value;
      fSWF.EmbedMovie:=true;
    end;
end;

procedure TSWFItem.SetName(const Value: TComponentName);
begin
  fSWFName:=Value;
  if fSWF<>nil Then fSWF.Name:=fSWFName;
end;

{ TSWFCollection }

function TSWFCollection.Add: TSWFItem;
begin
  Result := TSWFItem(inherited Add);
end;

constructor TSWFCollection.Create(SWFList: TShockwaveFlashList);
begin
  inherited Create(TSWFItem);
  fSWFList:=SWFList;
end;

procedure TSWFCollection.Delete(Index: Integer);
begin
  inherited Delete(Index);
end;

function TSWFCollection.GetItem(Index: Integer): TSWFItem;
begin
  Result := TSWFItem(inherited GetItem(Index));
end;

function TSWFCollection.GetOwner: TPersistent;
begin
  Result := fSWFList;
end;

procedure TSWFCollection.SetItem(Index: Integer; const Value: TSWFItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TSWFCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  fSWFList.Invalidate;
  fSWFList.LoadFromItems;
end;

{ TShockwaveFlashList }

procedure TShockwaveFlashList.Back;
begin
  if fCurentMovie<>nil Then fCurentMovie.Back;
end;

constructor TShockwaveFlashList.Create(AOwner: TComponent);
begin
  Host:=AOwner;
  inherited Create(AOwner);
  RegisterClass(TSWFChildren);
  Width:=192;
  Height:=192;
  fItems:=TSWFCollection.Create(self);
  fBackgroundColor:=clWhite;
  fMoviesWidth:=48;
  fMoviesHeight:=48;
  fPlaying:=true;
end;

function TShockwaveFlashList.CurrentFrame: Integer;
begin
  if fCurentMovie<>nil Then Result:=fCurentMovie.CurrentFrame Else Result:=-1;
end;

destructor TShockwaveFlashList.Destroy;
begin
  fItems.Free;
  inherited;
end;

procedure TShockwaveFlashList.Forward;
begin
  if fCurentMovie<>nil Then fCurentMovie.Forward;
end;

procedure TShockwaveFlashList.GotoFrame(FrameNum: Integer);
begin
  if fCurentMovie<>nil Then fCurentMovie.GotoFrame(FrameNum);
end;

procedure TShockwaveFlashList.LoadFromItems;
Var i: integer;
    SWF: TSWFChildren;
    p: pointer;
begin
if (csLoading in ComponentState) Then exit;
if (fItems<>nil) Then
  for i:=0 to fItems.Count-1 do
    begin
      p:=self.FindComponent(fItems.Items[i].fSWFName);
      if (fItems.Items[i].fSWF=nil) and (p<>nil) Then fItems.Items[i].fSWF:=p;
      if fItems.Items[i].fSWF=nil Then
        begin
          fItems.Items[i].fSWF:=TSWFChildren.Create(Host,self);
          SWF:=fItems.Items[i].fSWF;
          SWF.Parent:=self;
          SWF.Align:=alClient;
          SWF.CreateWnd;
          if i>0 Then SWF.Visible:=false Else SWF.Visible:=true;
          SWF.Quality:=Quality;
          SWF.ScaleMode:=ScaleMode;
          SWF.AlignMode:=AlignMode;
          SWF.Menu:=Menu;
          SWF.BackgroundColor:=TColorToSWFColor(fBackgroundColor);
          fItems.Items[i].fSWFName:=SWF.Name;
        end;
    end;
  RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.LoadMovie(layer: SYSINT; const url: WideString);
begin
  if fCurentMovie<>nil Then fCurentMovie.LoadMovie(layer,url);
end;

function TShockwaveFlashList.MessageSwfNeed(SWF:TSWFChildren; Value: TMessage): boolean;
begin
  Result:=false;
  Case Value.Msg of
    CM_MOUSELEAVE,
    WM_LBUTTONDOWN,
    WM_LBUTTONUP,
    WM_RBUTTONDOWN,
    WM_RBUTTONUP,
    WM_MOUSEMOVE,
    WM_MBUTTONDOWN,
    WM_MBUTTONUP: Result:=true;
  end;
end;

procedure TShockwaveFlashList.Pan(x, y: Integer; mode: SYSINT);
begin
  if fCurentMovie<>nil Then fCurentMovie.Pan(x,y,mode);
end;

procedure TShockwaveFlashList.Play;
begin
  if fCurentMovie<>nil Then fCurentMovie.Play;
end;

procedure TShockwaveFlashList.RefreshMoviesLayout;
Var i: integer;
    Kw,Kh,W,H,n,Col,Row: integer;
begin
  if (csLoading in ComponentState) Then exit;
  if fItems.Count=0 Then exit;
  for i:=0 to fItems.Count-1 do
    begin
      fItems.Items[i].SWF.Visible:=false;
      fItems.Items[i].SWF.CreateWnd;
    end;
  if fMovieWidthToHeight<=0 Then fMovieWidthToHeight:=100;
  if (fCountForLayout=0) or (fCountForLayout>fItems.Count) Then n:=fItems.Count-fItemIndex
    Else n:=fCountForLayout;
  Case fMoviesLayout of
    mlSingle:
      begin
        if fItems.Items[ItemIndex].SWF=nil Then exit;
        With fItems.Items[ItemIndex].SWF do
          begin
            Align:=alNone;
            SetBounds(fGleam,fGleam,self.Width-2*fGleam,self.Height-2*fGleam);
            Visible:=true;
            CreateWnd;
          end;
      end;
    mlMatrixLR, mlMatrixTB:
      begin
        if fKeepMoviesSize Then
          begin
            W:=fMoviesWidth;
            H:=fMoviesHeight;
          end
         Else
          begin
            H:=Trunc(Sqrt(Width*Height*100/(fMovieWidthToHeight*n)));
            W:=Trunc(H*fMovieWidthToHeight/100);
          end;
        Kw:=Trunc((Width-fGleam)/(W+fGleam));
        Kh:=Trunc((Height-fGleam)/(H+fGleam));
        if not fKeepMoviesSize Then
          begin
            if Kw*Kh<n Then Inc(Kw);
            if Kw*Kh<n Then Inc(Kh);
            H:=Trunc((Height-fGleam*(Kh+1))/Kh);
            W:=Trunc((Width-fGleam*(Kw+1))/Kw);
            if W>=Round(H*fMovieWidthToHeight/100) Then W:=Round(H*fMovieWidthToHeight/100)
                                                   Else H:=Round(W*100/fMovieWidthToHeight);
          end;
        Col:=1;
        Row:=1;
        i:=fItemIndex;
        While i<=fItemIndex+n-1 do
          begin
            if Items.Items[i].SWF<>nil Then With Items.Items[i].SWF do
              begin
                Align:=alNone;
                SetBounds(W*(Col-1)+fGleam*Col,H*(Row-1)+fGleam*Row,W,H);
                Visible:=true;
                CreateWnd;
              end;
            if fMoviesLayout=mlMatrixLR Then
              begin
                Inc(Col);
                if Col>Kw Then begin Col:=1; Inc(Row) end;
              end;
            if fMoviesLayout=mlMatrixTB Then
              begin
                Inc(Row);
                if Row>Kh Then begin Row:=1; Inc(Col) end;
              end;
            Inc(i);
          end;
      end;
    mlDiagonal:
      begin
        if fKeepMoviesSize Then
          begin
            W:=fMoviesWidth;
            H:=fMoviesHeight;
          end
         Else
          begin
            W:=Trunc((Width-fGleam*(n+1))/n);
            H:=Trunc((Height-fGleam*(n+1))/n);
            if (W*100/fMovieWidthToHeight)<H Then H:=Round(W*100/fMovieWidthToHeight)
              Else W:=Round(H*fMovieWidthToHeight/100);
          end;
        i:=0;
        While i<=n-1 do
          begin
            if Items.Items[i].SWF<>nil Then With Items.Items[i+fItemIndex].SWF do
              begin
                Align:=alNone;
                SetBounds(W*i+fGleam*(i+1),H*i+fGleam*(i+1),W,H);
                Visible:=true;
                CreateWnd;
                Inc(i);
              end;
          end;
      end;
  end; {Case}
end;

procedure TShockwaveFlashList.Rewind;
begin
  if fCurentMovie<>nil Then fCurentMovie.Rewind;
end;

procedure TShockwaveFlashList.SetAlignMode(const Value: Integer);
Var i: integer;
begin
  fAlignMode:=Value;
  for i:=0 to fItems.Count-1 do
    if fItems[i].fSWF<>nil Then fItems[i].fSWF.AlignMode:=Value;
end;

procedure TShockwaveFlashList.SetBackgroundColor(const Value: TColor);
Var i: integer;
begin
  fBackgroundColor:=Value;
  for i:=0 to fItems.Count-1 do
    if fItems[i].fSWF<>nil Then fItems[i].fSWF.BackgroundColor:=TColorToSWFColor(Value);
end;

procedure TShockwaveFlashList.SetCountForLayout(const Value: integer);
begin
  fCountForLayout:=Value;
  RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.SetGleam(const Value: integer);
begin
  fGleam:=Value;
  RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.SetItem(const Value: integer);
begin
  if Value>fItems.Count-1 Then exit;
  fItemIndex:=Value;
  fCurentMovie:=fItems.Items[Value].fSWF;
  RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.SetItems(const Value: TSWFCollection);
begin
  fItems.Assign(Value);
  RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.SetKeepMoviesSize(const Value: boolean);
begin
  fKeepMoviesSize:=Value;
  RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.SetLockMouseClick(const Value: boolean);
Var i: integer;
begin
  fLockMouseClick:=Value;
  for i:=0 to fItems.Count-1 do
    if fItems.Items[i].fSWF<>nil Then fItems.Items[i].fSWF.LockMouseClick:=Value;
end;

procedure TShockwaveFlashList.SetMenu(const Value: boolean);
Var i: integer;
begin
  fMenu:=Value;
  for i:=0 to fItems.Count-1 do
    if fItems[i].fSWF<>nil Then fItems[i].fSWF.Menu:=Value;
end;

procedure TShockwaveFlashList.SetMoviesHeight(const Value: integer);
begin
  fMoviesHeight:=Value;
  if fKeepMoviesSize Then RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.SetMoviesLayout(const Value: TMoviesLayout);
begin
  fMoviesLayout:=Value;
  RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.SetMoviesWidth(const Value: integer);
begin
  fMoviesWidth:=Value;
  if fKeepMoviesSize Then RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.SetMovieWidthToHeight(const Value: integer);
begin
  fMovieWidthToHeight:=Value;
  RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.SetPlaying(const Value: boolean);
Var i: integer;
begin
  fPlaying := Value;
  for i:=0 to fItems.Count-1 do
    if fItems[i].fSWF<>nil Then fItems[i].fSWF.Playing:=Value;
end;

procedure TShockwaveFlashList.SetQuality(const Value: Integer);
Var i: integer;
begin
  fQuality:=Value;
  for i:=0 to fItems.Count-1 do
    if fItems[i].fSWF<>nil Then fItems[i].fSWF.Quality:=Value;
end;

procedure TShockwaveFlashList.SetScaleMode(const Value: Integer);
Var i: integer;
begin
  fScaleMode:=Value;
  for i:=0 to fItems.Count-1 do
    if fItems[i].fSWF<>nil Then fItems[i].fSWF.ScaleMode:=Value;
end;

procedure TShockwaveFlashList.SetZoomRect(left, top, right, bottom: Integer);
begin
  if fCurentMovie<>nil Then fCurentMovie.SetZoomRect(left,top,right,bottom);
end;

procedure TShockwaveFlashList.Stop;
begin
  if fCurentMovie<>nil Then fCurentMovie.Stop;
end;

procedure TShockwaveFlashList.StopPlay;
begin
  if fCurentMovie<>nil Then fCurentMovie.StopPlay;
end;

function TShockwaveFlashList.TColorToSWFColor(Value: TColor): integer;
Var R,G,B: byte;
begin
  B:=Trunc(Value/sqr(256));
  G:=Trunc((Value-B*sqr(256))/256);
  R:=Trunc(Value-B*sqr(256)-G*256);
  Result:=R shl 16 + G shl 8 + B;
end;

procedure TShockwaveFlashList.WndProc(var Message: TMessage);
begin
  inherited;
  if Message.Msg=WM_SIZE Then RefreshMoviesLayout;
end;

procedure TShockwaveFlashList.Zoom(factor: SYSINT);
begin
  if fCurentMovie<>nil Then fCurentMovie.Zoom(factor);
end;

{ TSWFChildren }

constructor TSWFChildren.Create(AOwner: TComponent; AHost:TShockwaveFlashList);
Var i: integer;
    p: pointer;
    s: string;
    AParent: TWinControl;
begin
  Host:=AHost;
  i:=1;
  Repeat
    s:=self.ClassName+IntToStr(i);
    p:=nil;
    AParent:=Host;
    While (p=nil) and (AParent<>nil) do
      begin
        p:=AParent.FindComponent(s);
        AParent:=AParent.Parent;
      end;
    Inc(i);
  Until p=nil;
  self.Name:=s;
  inherited Create(AOwner);
end;

procedure TSWFChildren.WndProc(var Message: TMessage);
Var oldX,oldY: integer;
begin
  if Host<>nil Then
    begin
      if Host.MessageSwfNeed(self,Message) Then
        begin
          oldX:=TSmallPoint(Message.LParam).x;
          oldY:=TSmallPoint(Message.LParam).y;
          TSmallPoint(Message.LParam).x:=oldX+Left;
          TSmallPoint(Message.LParam).y:=oldY+Top;
          Host.WndProc(Message);
          TSmallPoint(Message.LParam).x:=oldX;
          TSmallPoint(Message.LParam).y:=oldY;
        end;
      if (csDesigning in ComponentState) and (Host.MessageSwfNeed(self,Message)) Then
        begin
          Message.Result:=0;
          exit;
        end;
    end;
  inherited WndProc(Message);
end;


end.
