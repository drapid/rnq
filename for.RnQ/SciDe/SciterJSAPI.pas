unit SciterJSAPI;

interface

uses
  Windows, Classes, SysUtils, TypInfo, ActiveX, RTTI, Variants;

const
  SIH_REPLACE_CONTENT      = 0;
  SIH_INSERT_AT_START      = 1;
  SIH_APPEND_AFTER_LAST    = 2;
  SOH_REPLACE              = 3;
  SOH_INSERT_BEFORE        = 4;
  SOH_INSERT_AFTER         = 5;

const
  HV_OK_TRUE               = -1;
  HV_OK                    = 0;
  HV_BAD_PARAMETER         = 1;
  HV_INCOMPATIBLE_TYPE     = 2;

const
  SC_LOAD_DATA             = $1;
  SC_DATA_LOADED           = $2;
  SC_DOCUMENT_COMPLETE     = $3 deprecated;
  SC_ATTACH_BEHAVIOR       = $4;
  SC_ENGINE_DESTROYED      = $5;
  SC_POSTED_NOTIFICATION   = $6;

const
  LOAD_OK     : UINT       = 0;
  LOAD_DISCARD: UINT       = 1;
  LOAD_DELAYED: UINT       = 2;
  LOAD_MYSELF : UINT       = 3;

type

  SCDOM_RESULT =
  (
    SCDOM_OK                = 0,
    SCDOM_INVALID_HWND      = 1,
    SCDOM_INVALID_HANDLE    = 2,
    SCDOM_PASSIVE_HANDLE    = 3,
    SCDOM_INVALID_PARAMETER = 4,
    SCDOM_OPERATION_FAILED  = 5,
    SCDOM_OK_NOT_HANDLED    = -1,
    SCDOM_DUMMY             = MAXINT
  );

  REQUEST_RESULT =
  (
    REQUEST_OK               = 0,
    REQUEST_BAD_PARAM        = 1, // bad parameter
    REQUEST_FAILURE          = 2, // operation failed, e.g. index out of bounds
    REQUEST_NOTSUPPORTED     = 3, // the platform does not support requested feature
    REQUEST_PANIC            = -1 // e.g. not enough memory
  );

  REQUEST_RQ_TYPE =
  (
    RRT_GET                  = 1,
    RRT_POST                 = 2,
    RRT_PUT                  = 3,
    RRT_DELETE               = 4,
    RRT_FORCE_DWORD          = $FFFFFFFF
  );

  PREQUEST_STATE = ^REQUEST_STATE;
  REQUEST_STATE =
  (
    RS_PENDING               = 0,
    RS_SUCCESS               = 1, // completed successfully
    RS_FAILURE               = 2, // completed with failure
    RS_FORCE_DWORD           = $FFFFFFFF
  );

  HWINDOW = HWND;

  HREQUEST = Pointer;

  HELEMENT = Pointer;

  HNODE = Pointer;

  HSARCHIVE = Pointer;

  LPVOID   = Pointer;

  UINT_PTR = UINT;

  LPCSTR_RECEIVER = procedure(str: PAnsiChar; str_length: UINT; param: Pointer); stdcall;
  PLPCSTR_RECEIVER = ^LPCSTR_RECEIVER;

  LPCWSTR_RECEIVER = procedure(str: PWideChar; str_length: UINT; param: Pointer); stdcall;
  PLPCWSTR_RECEIVER = ^LPCWSTR_RECEIVER;

  LPCBYTE_RECEIVER = procedure(bytes: PByte; num_bytes: UINT; param: Pointer); stdcall;
  PLPCBYTE_RECEIVER = ^LPCBYTE_RECEIVER;

  SCITER_CALLBACK_NOTIFICATION = record
    code: UINT;
    hwnd: HWINDOW;
  end;
  LPSCITER_CALLBACK_NOTIFICATION = ^SCITER_CALLBACK_NOTIFICATION;

  SciterHostCallback = function(pns: LPSCITER_CALLBACK_NOTIFICATION; callbackParam: Pointer): UINT; stdcall;
  LPSciterHostCallback = ^SciterHostCallback;


  ElementEventProc = function(tag: Pointer; he: HELEMENT; evtg: UINT; prms: Pointer): BOOL; stdcall;
  LPELEMENT_EVENT_PROC = ^ElementEventProc;


  PSciterResourceType = ^SciterResourceType;
  SciterResourceType { NB: UINT }  =
  (
    RT_DATA_HTML   = 0,
    RT_DATA_IMAGE  = 1,
    RT_DATA_STYLE  = 2,
    RT_DATA_CURSOR = 3,
    RT_DATA_SCRIPT = 4,
    RT_DATA_RAW    = 5,
    RT_DATA_FONT,
    RT_DATA_SOUND,
    RT_DATA_FORCE_DWORD = MAXINT
  );

  SciterGFXLayer =
  (
    GFX_LAYER_GDI = 1, GFX_LAYER_CG = 1, (*Mac OS*) GFX_LAYER_CAIRO = 1, (*GTK*)
    GFX_LAYER_WARP = 2,
    GFX_LAYER_D2D = 3,
    GFX_LAYER_SKIA_RASTER = 4,
    GFX_LAYER_SKIA_OPENGL = 5,
    GFX_LAYER_SKIA_VULKAN = 6,
    GFX_LAYER_SKIA_METAL = 7, // OSX
    GFX_LAYER_SKIA_DX12 = 8,
    GFX_LAYER_SKIA_GPU = 9, // Best GPU layer for the platform:
                            // Windows: DX12 -> VULKAN -> OPENGL -> RASTER
                            // OSX: METAL -> [VULKAN] -> OPENGL -> RASTER
                            // Linux: VULKAN -> OPENGL -> RASTER
    GFX_LAYER_AUTO = $FFFF
  );

  SciterRuntimeFeatures =
  (
    ALLOW_FILE_IO = 1,
    ALLOW_SOCKET_IO = 2,
    ALLOW_EVAL = 4,
    ALLOW_SYSINFO = 8
  );

  SCITER_RT_OPTIONS { NB: UINT_PTR } = (
   SCITER_SMOOTH_SCROLL = 1,      // value:TRUE - enable, value:FALSE - disable, enabled by default
   SCITER_CONNECTION_TIMEOUT = 2, // value: milliseconds, connection timeout of http client
   SCITER_HTTPS_ERROR = 3,        // value: 0 - drop connection, 1 - use builtin dialog, 2 - accept connection silently
   SCITER_FONT_SMOOTHING = 4,     // value: 0 - system default, 1 - no smoothing, 2 - std smoothing, 3 - clear type
   SCITER_TRANSPARENT_WINDOW = 6, // Windows Aero support, value:
                                  // 0 - normal drawing,
                                  // 1 - window has transparent background after calls DwmExtendFrameIntoClientArea() or DwmEnableBlurBehindWindow().
   SCITER_SET_GPU_BLACKLIST  = 7, // hWnd = NULL,
                                  // value = LPCBYTE, json - GPU black list, see: gpu-blacklist.json resource.
   SCITER_SET_SCRIPT_RUNTIME_FEATURES = 8, // value - combination of SCRIPT_RUNTIME_FEATURES flags.
   SCITER_SET_GFX_LAYER = 9,      // hWnd = NULL, value - GFX_LAYER
   SCITER_SET_DEBUG_MODE = 10,    // hWnd, value - TRUE/FALSE
   SCITER_SET_UX_THEMING = 11,    // hWnd = NULL, value - BOOL, TRUE - the engine will use "unisex" theme that is common for all platforms.
                                  // That UX theme is not using OS primitives for rendering input elements. Use it if you want exactly
                                  // the same (modulo fonts) look-n-feel on all platforms.
   SCITER_ALPHA_WINDOW  = 12,     // hWnd, value - TRUE/FALSE - window uses per pixel alpha (e.g. WS_EX_LAYERED/UpdateLayeredWindow() window)
   SCITER_SET_INIT_SCRIPT = 13,   // hWnd - N/A , value LPCSTR - UTF-8 encoded script source to be loaded into each view before any other script execution.
                                  //                             The engine copies this string inside the call.
   SCITER_SET_MAIN_WINDOW = 14,   //  hWnd, value - TRUE/FALSE - window is main, will destroy all other dependent windows on close
   SCITER_SET_MAX_HTTP_DATA_LENGTH = 15, // hWnd - N/A , value - max request length in megabytes (1024*1024 bytes)
   SCITER_SET_PX_AS_DIP = 16,     // value 1 - 1px in CSS is treated as 1dip, value 0 - default behavior - 1px is a physical pixel
   SCITER_ENABLE_UIAUTOMATION = 17, // hWnd - N/A , TRUE/FALSE, enables UIAutomation support.
   SCITER_USE_INTERNAL_HTTP_CLIENT = 18, // hWnd - N/A , TRUE - use internal HTTP client
                                         //              FALSE - use system HTTP client (on platforms that has it: Win,Mac,Lin)
   SCITER_EXTENDED_TOUCHPAD_SUPPORT = 19, // hWnd - N/A , TRUE/FALSE, enables/disables extended touchpad support, TRUE by default

   SCITER_RT_OPTIONS_DUMMY = MAXINT
  );

  SCN_LOAD_DATA = record
             code: UINT;
             hwnd: HWINDOW;
              uri: LPCWSTR;
          outData: PBYTE;
      outDataSize: UINT;
         dataType: SciterResourceType;
        requestId: Pointer;
        principal: HELEMENT;
        initiator: HELEMENT;
  end;
  LPSCN_LOAD_DATA = ^SCN_LOAD_DATA;


  SCN_DATA_LOADED = record
            code: UINT;
            hwnd: HWINDOW;
             uri: LPCWSTR;
            data: PByte;
        dataSize: UINT;
        dataType: SciterResourceType;
          status: UINT;
  end;
  LPSCN_DATA_LOADED = ^SCN_DATA_LOADED;


  SCN_ATTACH_BEHAVIOR = record
            code: UINT;
            hwnd: HWINDOW;
         element: HELEMENT;
    behaviorName: PAnsiChar;
     elementProc: LPELEMENT_EVENT_PROC;
      elementTag: LPVOID
  end;
  LPSCN_ATTACH_BEHAVIOR = ^SCN_ATTACH_BEHAVIOR;


  SCN_ENGINE_DESTROYED = record
    code: UINT;
    hwnd: HWINDOW
  end;
  LPSCN_ENGINE_DESTROYED = ^SCN_ENGINE_DESTROYED;


  SCN_POSTED_NOTIFICATION = record
       code: UINT;
       hwnd: HWINDOW;
     wparam: UINT_PTR;
     lparam: UINT_PTR;
    lreturn: UINT_PTR;
  end;
  LPSCN_POSTED_NOTIFICATION = ^SCN_POSTED_NOTIFICATION;

  TProcPointer = procedure; stdcall;

  DEBUG_OUTPUT_PROC = procedure(param: Pointer; subsystem: UINT; severity: UINT; text: PWideChar; text_length: UINT); stdcall;
  PDEBUG_OUTPUT_PROC = ^DEBUG_OUTPUT_PROC;

  SciterElementCallback = function(he: HELEMENT; Param: Pointer): BOOL; stdcall;
  PSciterElementCallback = ^SciterElementCallback;

  VALUE_STRING_CVT_TYPE =
  (
    CVT_SIMPLE,
    CVT_JSON_LITERAL,
    CVT_JSON_MAP,
    CVT_XJSON_LITERAL,
    VALUE_STRING_CVT_TYPE_DUMMY = MAXINT
  );

  TSciterValueType =
  (
    T_UNDEFINED,
    T_NULL,
    T_BOOL,
    T_INT,
    T_FLOAT,
    T_STRING,
    T_DATE,
    T_CURRENCY,
    T_LENGTH,
    T_ARRAY,
    T_MAP,
    T_FUNCTION,
    T_BYTES,
    T_OBJECT,
    T_DOM_OBJECT,
    T_RESOURCE,
    T_RANGE,
    T_DURATION,
    T_ANGLE,
    T_COLOR,
    T_ASSET = 21,
    T_DUMMY = MAXINT
  );

  TSciterValueUnitTypeInt =
  (
    UT_INT_INT = 0,
    UT_INT_EM = 1,
    UT_INT_EX = 2,
    UT_INT_PR = 3,
    UT_INT_SP = 4,
    UT_INT_RESERVED1 = 5,
    UT_INT_RESERVED2 = 6,
    UT_INT_PX = 7,
    UT_INT_IN = 8,
    UT_INT_CM = 9,
    UT_INT_MM = 10,
    UT_INT_PT = 11,
    UT_INT_PC = 12,
    UT_INT_DIP = 13,
    UT_INT_RESERVED3 = 14,
    UT_INT_COLOR = 15,
    UT_INT_URL   = 16,
    UT_INT_DUMMY = MAXINT
  );

  TSciterValueUnitTypeObject =
  (
    UT_OBJECT_ARRAY,
    UT_OBJECT_OBJECT,
    UT_OBJECT_CLASS,
    UT_OBJECT_NATIVE,
    UT_OBJECT_FUNCTION,
    UT_OBJECT_ERROR,
    UT_OBJECT_DUMMY = MAXINT
  );

  TSciterValueUnitTypeString =
  (
    UT_STRING_STRING = 0,
    UT_STRING_ERROR  = 1,
    UT_STRING_SECURE = 2,
    UT_STRING_SYMBOL = $ffff,
    UT_STRING_DUMMY = MAXINT
  );

  EVENT_GROUPS =
  (
    HANDLE_INITIALIZATION        = $0000, // attached/detached
    HANDLE_MOUSE                 = $0001,
    HANDLE_KEY                   = $0002,
    HANDLE_FOCUS                 = $0004, // focus events, if this flag is set it also means that element it attached to is focusable
    HANDLE_SCROLL                = $0008,
    HANDLE_TIMER                 = $0010,
    HANDLE_SIZE                  = $0020,
    HANDLE_DRAW                  = $0040, // drawing request (event)
    HANDLE_DATA_ARRIVED          = $0080,
    HANDLE_BEHAVIOR_EVENT        = $0100, // logical, synthetic events: BUTTON_CLICK, HYPERLINK_CLICK, etc., a.k.a. notifications from intrinsic behaviors
    HANDLE_METHOD_CALL           = $0200,
    HANDLE_SCRIPTING_METHOD_CALL = $0400,
    HANDLE_STYLE_CHANGE          = $0800,
    HANDLE_EXCHANGE              = $1000, // system drag-n-drop
    HANDLE_GESTURE               = $2000, // touch input events
    HANDLE_ATTRIBUTE_CHANGE      = $4000,
    HANDLE_SOM                   = $8000,
    HANDLE_ALL                   = $FFFF,
    SUBSCRIPTIONS_REQUEST        = -1,
    EVENT_GROUPS_DUMMY           = MAXINT
  );

  ELEMENT_STATE_BITS =
  (
    STATE_LINK             = $00000001,
    STATE_HOVER            = $00000002,
    STATE_ACTIVE           = $00000004,
    STATE_FOCUS            = $00000008,
    STATE_VISITED          = $00000010,
    STATE_CURRENT          = $00000020,
    STATE_CHECKED          = $00000040,
    STATE_DISABLED         = $00000080,
    STATE_READONLY         = $00000100,
    STATE_EXPANDED         = $00000200,
    STATE_COLLAPSED        = $00000400,
    STATE_INCOMPLETE       = $00000800,
    STATE_ANIMATING        = $00001000,
    STATE_FOCUSABLE        = $00002000,
    STATE_ANCHOR           = $00004000,
    STATE_SYNTHETIC        = $00008000,
    STATE_OWNS_POPUP       = $00010000,
    STATE_TABFOCUS         = $00020000,
    STATE_EMPTY            = $00040000,
    STATE_BUSY             = $00080000,
    STATE_DRAG_OVER        = $00100000,
    STATE_DROP_TARGET      = $00200000,
    STATE_MOVING           = $00400000,
    STATE_COPYING          = $00800000,
    STATE_DRAG_SOURCE      = $01000000,
    STATE_DROP_MARKER      = $02000000,
    STATE_PRESSED          = $04000000,
    STATE_POPUP            = $08000000,
    STATE_IS_LTR           = $10000000,
    STATE_IS_RTL           = $20000000,
    ELEMENT_STATE_BITS_DUMMY = MAXINT
  );

  ELEMENT_AREAS =
  (
    ROOT_RELATIVE      = $1,
    SELF_RELATIVE      = $2,
    CONTAINER_RELATIVE = $3,
    VIEW_RELATIVE      = $4,
    CONTENT_BOX        = $0,
    PADDING_BOX        = $10,
    BORDER_BOX         = $20,
    MARGIN_BOX         = $30,
    BACK_IMAGE_AREA    = $40,
    FORE_IMAGE_AREA    = $50,
    SCROLLABLE_AREA    = $60,
    ELEMENT_AREAS_DUMMY = MAXINT
  );

  TSciterValue = record
    t: UINT;
    u: UINT;
    d: UInt64;
  end;
  PSciterValue = ^TSciterValue;

  TSciterValueArray = array[0..$FFFF] of TSciterValue;
  PSciterValueArray = ^TSciterValueArray;

  BEHAVIOR_METHOD_IDENTIFIERS =
  (
    DO_CLICK = 0,

    IS_EMPTY      = $FC,       // p - IS_EMPTY_PARAMS // set VALUE_PARAMS::is_empty (false/true) reflects :empty state of the element.
    GET_VALUE     = $FD,       // p - VALUE_PARAMS
    SET_VALUE     = $FE,       // p - VALUE_PARAMS

    FIRST_APPLICATION_METHOD_ID = $100,
    BEHAVIOR_METHOD_IDENTIFIERS_DUMMY = MAXINT
  );

  METHOD_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
  end;
  PMETHOD_PARAMS = ^METHOD_PARAMS;

  TEXT_VALUE_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    text: PWideChar;
    length: UINT;
  end;
  PTEXT_VALUE_PARAMS = ^TEXT_VALUE_PARAMS;

  VALUE_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    val: TSciterValue;
  end;
  PVALUE_PARAMS = ^VALUE_PARAMS;

  TEXT_EDIT_SELECTION_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    selection_start: UINT;
    selection_end: UINT;
  end;
  PTEXT_EDIT_SELECTION_PARAMS = ^TEXT_EDIT_SELECTION_PARAMS;

  TEXT_EDIT_REPLACE_SELECTION_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    text: PWideChar;
    text_length: UINT;
  end;
  PTEXT_EDIT_REPLACE_SELECTION_PARAMS = ^TEXT_EDIT_REPLACE_SELECTION_PARAMS;

  TEXT_EDIT_CHAR_POS_AT_XY_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    x: Integer; // in
    y: Integer; // in
    char_pos: Integer; // out
    he: HELEMENT; // out
    he_pos: Integer; // out
  end;
  PTEXT_EDIT_CHAR_POS_AT_XY_PARAMS = ^TEXT_EDIT_CHAR_POS_AT_XY_PARAMS;

  IS_EMPTY_PARAMS = record
    methodID: BEHAVIOR_METHOD_IDENTIFIERS;
    is_empty: UINT;
  end;
  PIS_EMPTY_PARAMS = ^IS_EMPTY_PARAMS;

  REQUEST_PARAM = record
    name: PWideChar;
    value: PWideChar;
  end;
  PREQUEST_PARAM = ^REQUEST_PARAM;

  BEHAVIOR_EVENTS =
  (
    BEHAVIOR_EVENTS_ALL = -1, // doesn't exist in sciter api

    BUTTON_CLICK = 0,              // click on button
    BUTTON_PRESS = 1,              // mouse down or key down in button
    BUTTON_STATE_CHANGED = 2,      // checkbox/radio/slider changed its state/value
    EDIT_VALUE_CHANGING = 3,       // before text change
    EDIT_VALUE_CHANGED = 4,        // after text change
    SELECT_SELECTION_CHANGED = 5,  // selection in <select> changed
    SELECT_VALUE_CHANGED = 6,      // value of <select> changed

    POPUP_REQUEST   = 7,           // request to show popup just received, here DOM of popup element can be modifed.
    POPUP_READY     = 8,           // popup element has been measured and ready to be shown on screen, here you can use functions like ScrollToView.
    POPUP_DISMISSED = 9,           // popup element is closed, here DOM of popup element can be modifed again - e.g. some items can be removed to free memory.

    MENU_ITEM_ACTIVE = $0A,        // menu item activated by mouse hover or by keyboard,
    MENU_ITEM_CLICK = $0B,         // menu item click,
                                   //   BEHAVIOR_EVENT_PARAMS structure layout
                                   //   BEHAVIOR_EVENT_PARAMS.cmd - MENU_ITEM_CLICK/MENU_ITEM_ACTIVE
                                   //   BEHAVIOR_EVENT_PARAMS.heTarget - owner(anchor) of the menu
                                   //   BEHAVIOR_EVENT_PARAMS.he - the menu item, presumably <li> element
                                   //   BEHAVIOR_EVENT_PARAMS.reason - BY_MOUSE_CLICK | BY_KEY_CLICK


    CONTEXT_MENU_REQUEST = $10,    // "right-click", BEHAVIOR_EVENT_PARAMS::he is current popup menu HELEMENT being processed or NULL.
                                   // application can provide its own HELEMENT here (if it is NULL) or modify current menu element.

    VISUAL_STATUS_CHANGED = $11,   // sent to the element being shown or hidden
    DISABLED_STATUS_CHANGED = $12, // broadcast notification, sent to all elements of some container that got new value of :disabled state

    POPUP_DISMISSING = $13,        // popup is about to be closed

    CONTENT_CHANGED = $15,         // content has been changed, is posted to the element that gets content changed,  reason is combination of CONTENT_CHANGE_BITS.
                                   // target == NULL means the window got new document and this event is dispatched only to the window.

    CLICK = $16,                   // generic click
    CHANGE = $17,                  // generic change

    HYPERLINK_CLICK = $80,         // hyperlink click

    ELEMENT_COLLAPSED = $90,       // element was collapsed, so far only behavior:tabs is sending these two to the panels
    ELEMENT_EXPANDED = $91,        // element was expanded,

    ACTIVATE_CHILD = $92,          // activate (select) child,
                                   // used for example by accesskeys behaviors to send activation request, e.g. tab on behavior:tabs.

    UI_STATE_CHANGED = $95,        // ui state changed, observers shall update their visual states.
                                   // is sent for example by behavior:richtext when caret position/selection has changed.

    FORM_SUBMIT = $96,             // behavior:form detected submission event. BEHAVIOR_EVENT_PARAMS::data field contains data to be posted.
                                   // BEHAVIOR_EVENT_PARAMS::data is of type T_MAP in this case key/value pairs of data that is about
                                   // to be submitted. You can modify the data or discard submission by returning true from the handler.
    FORM_RESET  = $97,             // behavior:form detected reset event (from button type=reset). BEHAVIOR_EVENT_PARAMS::data field contains data to be reset.
                                   // BEHAVIOR_EVENT_PARAMS::data is of type T_MAP in this case key/value pairs of data that is about
                                   // to be rest. You can modify the data or discard reset by returning true from the handler.

    DOCUMENT_COMPLETE = $98,       // document in behavior:frame or root document is complete.

    HISTORY_PUSH = $99,            // requests to behavior:history (commands)
    HISTORY_DROP = $9A,
    HISTORY_PRIOR = $9B,
    HISTORY_NEXT = $9C,
    HISTORY_STATE_CHANGED = $9D,   // behavior:history notification - history stack has changed

    CLOSE_POPUP = $9E,             // close popup request,
    REQUEST_TOOLTIP = $9F,         // request tooltip, evt.source <- is the tooltip element.

    ANIMATION         = $A0,       // animation started (reason=1) or ended(reason=0) on the element.
    TRANSITION        = $A1,       // transition started (reason=1) or ended(reason=0) on the element.
    SWIPE             = $B0,       // swipe gesture detected, reason=4,8,2,6 - swipe direction, only from behavior:swipe-touch

    DOCUMENT_CREATED  = $C0,       // document created, script namespace initialized. target -> the document
    DOCUMENT_CLOSE_REQUEST = $C1,  // document is about to be closed, to cancel closing do: evt.data = sciter::value("cancel");
    DOCUMENT_CLOSE    = $C2,       // last notification before document removal from the DOM
    DOCUMENT_READY    = $C3,       // document has got DOM structure, styles and behaviors of DOM elements. Script loading run is complete at this moment.
    DOCUMENT_PARSED   = $C4,       // document just finished parsing - has got DOM structure. This event is generated before DOCUMENT_READY
    //DOCUMENT_RELOAD = $C5,       // request to reload the document
    DOCUMENT_CLOSING  = $C6,       // view::notify_close
    CONTAINER_CLOSE_REQUEST = $C7, // window of host document is processing DOCUMENT_CLOSE_REQUEST
    CONTAINER_CLOSING = $C8,       // window of host document is processing DOCUMENT_CLOSING

    VIDEO_INITIALIZED = $D1,       // <video> "ready" notification
    VIDEO_STARTED     = $D2,       // <video> playback started notification
    VIDEO_STOPPED     = $D3,       // <video> playback stoped/paused notification
    VIDEO_BIND_RQ     = $D4,       // <video> request for frame source binding,
                                   //   If you want to provide your own video frames source for the given target <video> element do the following:
                                   //   1. Handle and consume this VIDEO_BIND_RQ request
                                   //   2. You will receive second VIDEO_BIND_RQ request/event for the same <video> element
                                   //      but this time with the 'reason' field set to an instance of sciter::video_destination interface.
                                   //   3. add_ref() it and store it for example in worker thread producing video frames.
                                   //   4. call sciter::video_destination::start_streaming(...) providing needed parameters
                                   //      call sciter::video_destination::render_frame(...) as soon as they are available
                                   //      call sciter::video_destination::stop_streaming() to stop the rendering (a.k.a. end of movie reached)

    VIDEO_FRAME_REQUEST = $D8,     // animation step, a.k.a. animation frame

    PAGINATION_STARTS  = $E0,      // behavior:pager starts pagination
    PAGINATION_PAGE    = $E1,      // behavior:pager paginated page no, reason -> page no
    PAGINATION_ENDS    = $E2,      // behavior:pager end pagination, reason -> total pages

    CUSTOM             = $F0,      // event with custom name

    FIRST_APPLICATION_EVENT_CODE = $100,
    // all custom event codes shall be greater
    // than this number. All codes below this will be used
    // solely by application - Sciter will not intrepret it
    // and will do just dispatching.
    // To send event notifications with these codes use
    // SciterSend/PostEvent API.

    BEHAVIOR_EVENTS_DUMMY = MAXINT // doesn't exist in sciter api, used for sizeof(uint) alignment
  );

  CLICK_REASON =
  (
    BY_MOUSE_CLICK,
    BY_KEY_CLICK,
    SYNTHESIZED,
    BY_MOUSE_ON_ICON,
    EVENT_REASON_DUMMY = MAXINT
  );

  EDIT_CHANGED_REASON =
  (
    BY_INS_CHAR,
    BY_INS_CHARS,
    BY_DEL_CHAR,
    BY_DEL_CHARS,
    BY_UNDO_REDO,
    EDIT_CHANGED_REASON_DUMMY = MAXINT
  );

  BEHAVIOR_EVENT_PARAMS = record
         cmd: BEHAVIOR_EVENTS;
    heTarget: HELEMENT;
          he: HELEMENT;
      reason: UINT_PTR;
        data: TSciterValue;
        name: LPCWSTR;
  end;
  PBEHAVIOR_EVENT_PARAMS = ^BEHAVIOR_EVENT_PARAMS;

  GESTURE_CMD =
  (
    GESTURE_START = 0,
    GESTURE_MOVE  = 1,
    GESTURE_END   = 2,

    // logical events
    GESTURE_PAN,    // The pan gesture.
    GESTURE_ZOOM,   // The zoom gesture.
    GESTURE_ROTATE, // The rotation gesture.
    GESTURE_TAP1,   // The tap gesture, a.k.a. click
    GESTURE_TAP2,   // The two-finger tap gesture, a.k.a. right-click
    GESTURE_DOUBLE_TAP,
    GESTURE_CMD_DUMMY = MAXINT
  );

  GESTURE_STATE =
  (
    GESTURE_STATE_BEGIN   = 1,
    GESTURE_STATE_INERTIA = 2,
    GESTURE_STATE_END     = 4,
    GESTURE_STATE_DUMMY   = MAXINT
  );

  GESTURE_TYPE_FLAGS =
  (
    GESTURE_FLAG_ZOOM               = $0001,
    GESTURE_FLAG_ROTATE             = $0002,
    GESTURE_FLAG_PAN_VERTICAL       = $0004,
    GESTURE_FLAG_PAN_HORIZONTAL     = $0008,
    GESTURE_FLAG_TAP1               = $0010,
    GESTURE_FLAG_TAP2               = $0020,

    GESTURE_FLAG_PAN_WITH_GUTTER    = $4000,
    GESTURE_FLAG_PAN_WITH_INERTIA   = $8000,
    GESTURE_FLAGS_ALL               = $FFFF,

    GESTURE_TYPE_FLAGS_DUMMY = MAXINT
  );

  GESTURE_PARAMS = record
         cmd  : GESTURE_CMD;
      target  : HELEMENT;
         pos  : TPoint;
     pos_view : TPoint;
  end;
  PGESTURE_PARAMS = ^GESTURE_PARAMS;

  REQUEST_TYPE =
  (
    GET_ASYNC,  // async GET
    POST_ASYNC, // async POST
    GET_SYNC,   // synchronous GET
    POST_SYNC,   // synchronous POST
    REQUEST_TYPE_DUMMY = MAXINT
  );

  OUTPUT_SEVERITY =
  (
    OS_INFO,
    OS_WARNING,
    OS_ERROR,
    OUTPUT_SEVERITY_DUMMY = MAXINT
  );

  SCITER_CREATE_WINDOW_FLAGS =
  (
    SW_CHILD      =   1 shl 0, // child window only, if this flag is set all other flags ignored
    SW_TITLEBAR   =   1 shl 1, // toplevel window, has titlebar
    SW_RESIZEABLE =   1 shl 2, // has resizeable frame
    SW_TOOL       =   1 shl 3, // is tool window
    SW_CONTROLS   =   1 shl 4, // has minimize / maximize buttons
    SW_GLASSY     =   1 shl 5, // glassy window - supports "Acrylic" on Windows and "Vibrant" on MacOS.
    SW_ALPHA      =   1 shl 6, // transparent window ( e.g. WS_EX_LAYERED on Windows )
    SW_MAIN       =   1 shl 7, // main window of the app, will terminate the app on close
    SW_POPUP      =   1 shl 8, // the window is created as topmost window.
    SW_ENABLE_DEBUG = 1 shl 9, // make this window inspector ready
    SW_OWNS_VM      = 1 shl 10 // it has its own script VM
  );

  SciterWindowDelegate = function(hwnd: HWINDOW; msg: UINT; wParam: WPARAM; lParam: LPARAM; pParam: LPVOID; var pbHANDLED: BOOL): LRESULT; stdcall;
  PSciterWindowDelegate = ^SciterWindowDelegate;

  ISciterRAPI = record
    // a.k.a AddRef()
    RequestUse: function(rq: HREQUEST): REQUEST_RESULT; stdcall;
    // a.k.a Release()
    RequestUnUse: function(rq: HREQUEST): REQUEST_RESULT; stdcall;
    // get requested URL
    RequestUrl: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get real, content URL (after possible redirection)
    RequestContentUrl: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get requested data type
    RequestGetRequestType: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get requested data type
    RequestGetRequestedDataType: function(rq: HREQUEST; var pData: SciterResourceType): REQUEST_RESULT; stdcall;
    // get received data type, string, mime type
    RequestGetReceivedDataType: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get number of request parameters passed
    RequestGetNumberOfParameters: function(rq: HREQUEST; var pData: UINT): REQUEST_RESULT; stdcall;
    // get nth request parameter name
    RequestGetNthParameterName: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get nth request parameter value
    RequestGetNthParameterValue: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get request times , ended - started = milliseconds to get the requst
    RequestGetTimes: function(rq: HREQUEST; var pStarted: UINT; var pEnded: UINT): REQUEST_RESULT; stdcall;
    // get number of request headers
    RequestGetNumberOfRqHeaders: function(rq: HREQUEST; var pNumber: UINT): REQUEST_RESULT; stdcall;
    // get nth request header name
    RequestGetNthRqHeaderName: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get nth request header value
    RequestGetNthRqHeaderValue: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get number of response headers
    RequestGetNumberOfRspHeaders: function(rq: HREQUEST; var pNumber: UINT): REQUEST_RESULT; stdcall;
    // get nth response header name
    RequestGetNthRspHeaderName: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get nth response header value
    RequestGetNthRspHeaderValue: function(rq: HREQUEST; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get completion status (CompletionStatus - http response code : 200, 404, etc.)
    RequestGetCompletionStatus: function(rq: HREQUEST; var pState: REQUEST_STATE; var pCompletionStatus: UINT): REQUEST_RESULT; stdcall;
    // get proxy host
    RequestGetProxyHost: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get proxy port
    RequestGetProxyPort: function(rq: HREQUEST; var pPort: UINT): REQUEST_RESULT; stdcall;
    // mark reequest as complete with status and data
    RequestSetSucceeded: function(rq: HREQUEST; status: UINT; dataOrNull: PByte; dataLength: UINT): REQUEST_RESULT; stdcall;
    // mark reequest as complete with failure and optional data
    RequestSetFailed: function(rq: HREQUEST; status: UINT; dataOrNull: PByte; dataLength: UINT): REQUEST_RESULT; stdcall;
    // append received data chunk
    RequestAppendDataChunk: function(rq: HREQUEST; data: PByte; dataLength: UINT): REQUEST_RESULT; stdcall;
    // set request header (single item)
    RequestSetRqHeader: function(rq: HREQUEST; name: PWideChar; value: PWideChar): REQUEST_RESULT; stdcall;
    // set respone header (single item)
    RequestSetRspHeader: function(rq: HREQUEST; name: PWideChar; value: PWideChar): REQUEST_RESULT; stdcall;
    // set received data type, string, mime type
    RequestSetReceivedDataType: function(rq: HREQUEST; rqType: PAnsiChar): REQUEST_RESULT; stdcall;
    // set received data encoding, string
    RequestSetReceivedDataEncoding: function(rq: HREQUEST; encoding: PAnsiChar): REQUEST_RESULT; stdcall;
    // get received (so far) data
    RequestGetData: function(rq: HREQUEST; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
  end;

  PSciterRApi = ^ISciterRAPI;
  SciterRApiFunc = function: PSciterRApi; stdcall;
  PSciterRApiFunc = ^SciterRApiFunc;

  ISciterAPI = record
    Version: UINT;
    SciterClassName: function: LPCWSTR; stdcall;
    SciterVersion: function(major: BOOL): UINT; stdcall;
    SciterDataReady: function(hwnd: HWINDOW; uri: PWideChar; data: PByte; dataLength: UINT): BOOL; stdcall;
    SciterDataReadyAsync: function(hwnd: HWINDOW; uri: PWideChar; data: PByte; dataLength: UINT; requestId: LPVOID): BOOL; stdcall;
    SciterProc: function(hwnd: HWINDOW; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
    SciterProcND: function(hwnd: HWINDOW; msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHANDLED: BOOL): LRESULT; stdcall;
    SciterLoadFile: function(hWndSciter: HWINDOW; filename:LPCWSTR): BOOL; stdcall;
    SciterLoadHtml: function(hWndSciter: HWINDOW; html: PByte; htmlSize: UINT; baseUrl: PWideChar): BOOL; stdcall;
    SciterSetCallback: procedure(hWndSciter: HWINDOW; cb: LPSciterHostCallback; cbParam: Pointer); stdcall;
    SciterSetMasterCSS: function(utf8: PAnsiChar; numBytes: UINT): BOOL; stdcall;
    SciterAppendMasterCSS: function(utf8: PAnsiChar; numBytes: UINT): BOOL; stdcall;
    SciterSetCSS: function(hWndSciter: HWindow; utf8: PAnsiChar; numBytes: UINT; baseUrl: PWideChar; mediaType: PWideChar): BOOL; stdcall;
    SciterSetMediaType: function(hWndSciter: HWINDOW; mediaTYpe: PWideChar): BOOL; stdcall;
    SciterSetMediaVars: function(hWndSciter: HWINDOW; const mediaVars: PSciterValue): BOOL; stdcall;
    SciterGetMinWidth: function(hwnd: HWINDOW): UINT; stdcall;
    SciterGetMinHeight: function(hwnd: HWINDOW; width: UINT): UINT; stdcall;
    SciterCall: function(hWnd: HWINDOW; functionName: PAnsiChar; argc: UINT; const argv: PSciterValue; var retval: TSciterValue): BOOL; stdcall;
    SciterEval: function(hwnd: HWINDOW; script: PWideChar; scriptLength: UINT; var retval: TSciterValue): BOOL; stdcall;
    SciterUpdateWindow: procedure(hwnd: HWINDOW); stdcall;
    SciterTranslateMessage: function(var lpMsg: TMsg): BOOL; stdcall;
    SciterSetOption: function(hwnd: HWINDOW; option: SCITER_RT_OPTIONS; value: UINT_PTR): BOOL; stdcall;
    SciterGetPPI: procedure(hWndSciter: HWINDOW; var px: UINT; var py: UINT); stdcall;
    SciterGetViewExpando: function(hwnd: HWINDOW; var pval: TSciterValue): BOOL; stdcall;
    SciterRenderD2D: TProcPointer;
    SciterD2DFactory: TProcPointer;
    SciterDWFactory: TProcPointer;
    SciterGraphicsCaps: function(var pcaps: UINT): BOOL; stdcall;
    SciterSetHomeURL: function(hWndSciter: HWINDOW; baseUrl: PWideChar): BOOL; stdcall;
    SciterCreateNSView: TProcPointer;
    SciterCreateWidget: TProcPointer;
    SciterCreateWindow: function(creationFlags: SCITER_CREATE_WINDOW_FLAGS; var frame: TRect; delegate: PSciterWindowDelegate; delegateParam: LPVOID; parent: HWINDOW): HWINDOW; stdcall;
    SciterSetupDebugOutput: procedure(hwndOrNull: HWINDOW; param: Pointer; pfOutput: PDEBUG_OUTPUT_PROC); stdcall;

//|
//| DOM Element API
//|

    Sciter_UseElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    Sciter_UnuseElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetRootElement: function(hwnd: HWINDOW; var Handle: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetFocusElement: function(hwnd: HWINDOW; var Handle: HELEMENT): SCDOM_RESULT; stdcall;
    SciterFindElement: function(hwnd: HWINDOW; Point: TPoint; var Handle: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetChildrenCount: function(he: HELEMENT; var count: UINT): SCDOM_RESULT; stdcall;
    SciterGetNthChild: function(he: HELEMENT; index: UINT; var retval: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetParentElement: function(he: HELEMENT; var p_parent_he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementHtmlCB: function(he: HELEMENT; Outer: BOOL; Callback: PLPCBYTE_RECEIVER; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterGetElementTextCB: function(he: HELEMENT; callback: PLPCWSTR_RECEIVER; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetElementText: function(he: HELEMENT; Value: PWideChar; Len: UINT): SCDOM_RESULT; stdcall;
    SciterGetAttributeCount: function(he: HELEMENT; var Count: UINT): SCDOM_RESULT; stdcall;
    SciterGetNthAttributeNameCB: function(he: HELEMENT; n: UINT; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): SCDOM_RESULT; stdcall;
    SciterGetNthAttributeValueCB: function(he: HELEMENT; n: UINT; rcv: PLPCWSTR_RECEIVER; rcv_param: LPVOID): SCDOM_RESULT; stdcall;
    SciterGetAttributeByNameCB: function(he: HELEMENT; name: PAnsiChar; rcv: PLPCWSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetAttributeByName: function(he: HELEMENT; name: PAnsiChar; value: PWideChar): SCDOM_RESULT; stdcall;
    SciterClearAttributes: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementIndex: function(he: HELEMENT; var p_index: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementType: function(he: HELEMENT; var s: LPCSTR): SCDOM_RESULT; stdcall;
    SciterGetElementTypeCB: function(he: HELEMENT; rcv: PLPCSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterGetStyleAttributeCB: function(he: HELEMENT; name: PAnsiChar; rcv: PLPCWSTR_RECEIVER; rcv_param: Pointer): SCDOM_RESULT; stdcall;
    SciterSetStyleAttribute: function(he: HELEMENT; name: PAnsiChar; value: PWideChar): SCDOM_RESULT; stdcall;
    SciterGetElementLocation: function(he: HELEMENT; var p_location: TRect; areas: ELEMENT_AREAS): SCDOM_RESULT; stdcall;
    SciterScrollToView: function(he: HELEMENT; SciterScrollFlags: UINT): SCDOM_RESULT; stdcall;
    SciterUpdateElement: function(he: HELEMENT; andForceRender: BOOL): SCDOM_RESULT; stdcall;
    SciterRefreshElementArea: function(he: HELEMENT; rc: TRect): SCDOM_RESULT; stdcall;
    SciterSetCapture: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterReleaseCapture: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementHwnd: function(he: HELEMENT; var p_hwnd: HWINDOW; rootWindow: BOOL): SCDOM_RESULT; stdcall;
    SciterCombineURL: function(he: HELEMENT; szUrlBuffer: PWideChar; UrlBufferSize: UINT): SCDOM_RESULT; stdcall;
    SciterSelectElements: function(he: HELEMENT; CSS_selectors: PAnsiChar; Callback: PSciterElementCallback; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSelectElementsW: function(he: HELEMENT; CSS_selectors: PWideChar; Callback: PSciterElementCallback; Param: Pointer): SCDOM_RESULT; stdcall;
    SciterSelectParent: function(he: HELEMENT; selector: PAnsiChar; depth: UINT; var heFound: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSelectParentW: function(he: HELEMENT; selector: PWideChar; depth: UINT; var heFound: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSetElementHtml: function(he: HELEMENT; html: PByte; htmlLength: UINT; where: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementUID: function(he: HELEMENT; var puid: UINT): SCDOM_RESULT; stdcall;
    SciterGetElementByUID: function(hwnd: HWINDOW; uid: UINT; var phe: HELEMENT): SCDOM_RESULT; stdcall;
    SciterShowPopup: function(popup: HELEMENT; Anchor: HELEMENT; placement: UINT): SCDOM_RESULT; stdcall;
    SciterShowPopupAt: function(Popup: HELEMENT; pos: TPoint; animate: BOOL): SCDOM_RESULT; stdcall;
    SciterHidePopup: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterGetElementState: function(he: HELEMENT; var pstateBits: UINT): SCDOM_RESULT; stdcall;
    SciterSetElementState: function(he: HELEMENT; stateBitsToSet: UINT; stateBitsToClear: UINT; updateView: BOOL): SCDOM_RESULT; stdcall;
    SciterCreateElement: function(const tagname: PAnsiChar; const textOrNull: PWideChar; var phe: HELEMENT): SCDOM_RESULT; stdcall;
    SciterCloneElement: function(he: HELEMENT; var phe: HELEMENT): SCDOM_RESULT; stdcall;
    SciterInsertElement: function(he: HELEMENT; hparent: HELEMENT; index: UINT): SCDOM_RESULT; stdcall;
    SciterDetachElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterDeleteElement: function(he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSetTimer: function(he: HELEMENT; milliseconds: UINT; var timer_id: UINT): SCDOM_RESULT; stdcall;
    SciterDetachEventHandler: function(he: HELEMENT; pep: LPELEMENT_EVENT_PROC; tag: Pointer): SCDOM_RESULT; stdcall;
    SciterAttachEventHandler: function(he: HELEMENT; pep: LPELEMENT_EVENT_PROC; tag: Pointer): SCDOM_RESULT; stdcall;
    SciterWindowAttachEventHandler: function(hwndLayout: HWINDOW; pep: LPELEMENT_EVENT_PROC; tag: LPVOID; subscription: UINT): SCDOM_RESULT; stdcall;
    SciterWindowDetachEventHandler: function(hwndLayout: HWINDOW; pep: LPELEMENT_EVENT_PROC; tag: LPVOID): SCDOM_RESULT; stdcall;
    SciterSendEvent: function(he: HELEMENT; appEventCode: UINT; heSource: HELEMENT; reason: PUINT; var handled: BOOL): SCDOM_RESULT; stdcall;
    SciterPostEvent: function(he: HELEMENT; appEventCode: UINT; heSource: HELEMENT; reason: PUINT): SCDOM_RESULT; stdcall;
    SciterCallBehaviorMethod: function(he: HELEMENT; params: PMETHOD_PARAMS): SCDOM_RESULT; stdcall;
    SciterRequestElementData: function(he: HELEMENT; url: PWideChar; dataType: UINT; initiator: HELEMENT): SCDOM_RESULT; stdcall;
    SciterHttpRequest: function(he: HELEMENT; url: PWideChar; dataType: UINT;
      requestType: REQUEST_TYPE; requestParams: PREQUEST_PARAM;
      nParams: UINT): SCDOM_RESULT; stdcall;
    SciterGetScrollInfo: function(he: HELEMENT; var scrollPos: TPoint; var viewRect:TRect; var contentSize: TSize): SCDOM_RESULT; stdcall;
    SciterSetScrollPos: function(he: HELEMENT; scrollPos: TPoint; smooth: BOOL): SCDOM_RESULT; stdcall;
    SciterGetElementIntrinsicWidths: function(he: HELEMENT; var pMinWidth: integer; var pMaxWidth: integer): SCDOM_RESULT; stdcall;
    SciterGetElementIntrinsicHeight: function(he: HELEMENT; forWidth: Integer; var pHeight: integer): SCDOM_RESULT; stdcall;
    SciterIsElementVisible: function(he: HELEMENT; var pVisible: BOOL): SCDOM_RESULT; stdcall;
    SciterIsElementEnabled: function(he: HELEMENT; var pEnabled: BOOL): SCDOM_RESULT; stdcall;
    SciterSortElements: TProcPointer;
    SciterSwapElements: function(he1: HELEMENT; he2: HELEMENT): SCDOM_RESULT; stdcall;
    SciterTraverseUIEvent: function(evt: UINT; eventCtlStruct: LPVOID ; var bOutProcessed: BOOL): SCDOM_RESULT; stdcall;
    SciterCallScriptingMethod: function(he: HELEMENT; name: PAnsiChar; const argv: PSciterValue; argc: UINT; var retval: TSciterValue): SCDOM_RESULT; stdcall;
    SciterCallScriptingFunction: function(he: HELEMENT; name: PAnsiChar; const argv: PSciterValue; argc: UINT; var retval: TSciterValue): SCDOM_RESULT; stdcall;
    SciterEvalElementScript: function(he: HELEMENT; script: PWideChar; scriptLength: UINT; var retval: TSciterValueType): SCDOM_RESULT; stdcall;
    SciterAttachHwndToElement: function(he: HELEMENT; hwnd: HWINDOW): SCDOM_RESULT; stdcall;
    SciterControlGetType: TProcPointer;
    SciterGetValue: function(he: HELEMENT; Value: PSciterValue): SCDOM_RESULT; stdcall;  
    SciterSetValue: function(he: HELEMENT; Value: PSciterValue): SCDOM_RESULT; stdcall;
    SciterGetExpando: TProcPointer;
    SciterGetObject: TProcPointer;
    SciterGetElementNamespace: TProcPointer;
    SciterGetHighlightedElement: function(h: HWINDOW; var he: HELEMENT): SCDOM_RESULT; stdcall;
    SciterSetHighlightedElement: function(h: HWINDOW; he: HELEMENT): SCDOM_RESULT; stdcall;

    SciterNodeAddRef: TProcPointer;
    SciterNodeRelease: TProcPointer;
    SciterNodeCastFromElement: TProcPointer;
    SciterNodeCastToElement: TProcPointer;
    SciterNodeFirstChild: TProcPointer;
    SciterNodeLastChild: TProcPointer;
    SciterNodeNextSibling: TProcPointer;
    SciterNodePrevSibling: TProcPointer;
    SciterNodeParent: TProcPointer;
    SciterNodeNthChild: TProcPointer;
    SciterNodeChildrenCount: TProcPointer;
    SciterNodeType: TProcPointer;
    SciterNodeGetText: TProcPointer;
    SciterNodeSetText: TProcPointer;
    SciterNodeInsert: TProcPointer;
    SciterNodeRemove: TProcPointer;
    SciterCreateTextNode: TProcPointer;
    SciterCreateCommentNode: TProcPointer;

    ValueInit: function(Value: PSciterValue): UINT; stdcall;
    ValueClear: function(Value: PSciterValue): UINT; stdcall;
    ValueCompare: function(Value1: PSciterValue; Value2: PSciterValue): UINT; stdcall;
    ValueCopy: function(dst: PSciterValue; src: PSciterValue): UINT; stdcall;
    ValueIsolate: function(Value: PSciterValue): UINT; stdcall;
    ValueType: function(Value: PSciterValue; var pType: TSciterValueType; var pUnits: UINT): UINT; stdcall;
    ValueStringData: function(Value: PSciterValue; var Chars: PWideChar; var NumChars: UINT): UINT; stdcall;
    ValueStringDataSet: function(Value: PSciterValue; Chars: PWideChar; NumChars: UINT; Units: UINT): UINT; stdcall;
    ValueIntData: function(Value: PSciterValue; var pData: Integer): UINT; stdcall;
    ValueIntDataSet:function(Value: PSciterValue; data: Integer; iType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueInt64Data: function(Value: PSciterValue; var pData: Int64): UINT; stdcall;
    ValueInt64DataSet: function(Value: PSciterValue; data: Int64; iType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueFloatData: function(Value: PSciterValue; var pData: double): UINT; stdcall;
    ValueFloatDataSet: function(Value: PSciterValue; data: double; iType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueBinaryData: function(Value: PSciterValue; var bytes: PByte; var pnBytes: UINT): UINT; stdcall;
    ValueBinaryDataSet: function(Value: PSciterValue; bytes: PByte; nBytes: UINT; pType: TSciterValueType; units: UINT): UINT; stdcall;
    ValueElementsCount: function(Value: PSciterValue; var pData: UINT): UINT; stdcall;
    ValueNthElementValue: function(Value: PSciterValue; n: Integer; var retval: TSciterValue): UINT; stdcall;
    ValueNthElementValueSet: function(pval: PSciterValue; n: Integer; pval_to_set: PSciterValue): UINT; stdcall;
    ValueNthElementKey: function(Value: PSciterValue; n: Integer; var retval: TSciterValue): UINT; stdcall;
    ValueEnumElements: function(Value: PSciterValue; penum, param: Pointer): UINT; stdcall;
    ValueSetValueToKey: function(Value: PSciterValue; const pKey: PSciterValue; const pValToSet: PSciterValue): UINT; stdcall;
    ValueGetValueOfKey: function(Value: PSciterValue; const pKey: PSciterValue; var retval: TSciterValue): UINT; stdcall;
    ValueToString: function(Value: PSciterValue; How: VALUE_STRING_CVT_TYPE): UINT; stdcall;
    ValueFromString: function(Value: PSciterValue; str: PWideChar; strLength: UINT; how: VALUE_STRING_CVT_TYPE): UINT; stdcall;
    ValueInvoke: function(Value: PSciterValue; this: PSciterValue; argc: UINT; const agrv: PSciterValue; var retval: TSciterValue; url: LPCWSTR): UINT; stdcall;
    ValueNativeFunctorSet: function(Value: PSciterValue; pinvoke, prelease, tag: Pointer): UINT; stdcall;
    ValueIsNativeFunctor: TProcPointer;

    reserved1: TProcPointer;
    reserved2: TProcPointer;
    reserved3: TProcPointer;
    reserved4: TProcPointer;

    SciterOpenArchive: function(archiveData: PByte; archiveDataLength: UINT): HSARCHIVE; stdcall;
    SciterGetArchiveItem: procedure(harc: HSARCHIVE; path: PWideChar; var pdata: PByte; var pdataLength: UINT); stdcall;
    SciterCloseArchive: procedure(harc: HSARCHIVE); stdcall;

    SciterFireEvent: function(var evt: BEHAVIOR_EVENT_PARAMS; post: BOOL; var handled: BOOL): SCDOM_RESULT; stdcall;

    SciterGetCallbackParam: TProcPointer;
    SciterPostCallback: TProcPointer;

    GetSciterGraphicsAPI: TProcPointer;
    GetSciterRequestAPI: SciterRApiFunc;

    SciterCreateOnDirectXWindow: function(hwnd: HWINDOW; var pSwapChain: IUnknown): BOOL; stdcall; // IDXGISwapChain
    SciterRenderOnDirectXWindow: function(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT; frontLayer: BOOL): BOOL; stdcall;
    SciterRenderOnDirectXTexture: function(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT; var surface: IUnknown): BOOL; stdcall; // IDXGISurface

    SciterProcX: function(hwnd: HWINDOW; pMsg: Pointer): BOOL; stdcall;

    SciterAtomValue: function(name: PAnsiChar): UINT64; stdcall;
    SciterAtomNameCB: function(atomv: UINT64; rcv: PLPCSTR_RECEIVER; rcv_param: LPVOID): BOOL; stdcall;
    SciterSetGlobalAsset: function(pass: Pointer): BOOL; stdcall;

    SciterGetElementAsset: function(el: HELEMENT; nameAtom: UINT64; var ppass: Pointer): SCDOM_RESULT; stdcall;

    SciterSetVariable: function(hwndOrNull: HWINDOW; path: LPCWSTR; pvalToSet: PSciterValue): UINT; stdcall;
    SciterGetVariable: function(hwndOrNull: HWINDOW; path: LPCWSTR; pvalToGet: PSciterValue): UINT; stdcall;

    SciterElementUnwrap: function(pval: PSciterValue; var ppElement: HELEMENT): UINT; stdcall;
    SciterElementWrap: function(pval: PSciterValue; pElement: HELEMENT): UINT; stdcall;

    SciterNodeUnwrap: function(pval: PSciterValue; var ppNode: HNODE): UINT; stdcall;
    SciterNodeWrap: function(pval: PSciterValue; pNode: HNODE): UINT; stdcall;
//    SBOOL   SCFN(SciterReleaseGlobalAsset)(som_asset_t* pass);
//    INT_PTR SCFN(SciterExec)(UINT appCmd /**/, UINT_PTR p1, UINT_PTR p2);
//    INT_PTR SCFN(SciterWindowExec)(HWINDOW hwnd, UINT windowCmd /**/, UINT_PTR p1, UINT_PTR p2);
  end;

  PSciterApi = ^ISciterAPI;
  SciterApiFunc = function: PSciterApi; stdcall;
  PSciterApiFunc = ^SciterApiFunc;

  INITIALIZATION_EVENTS =
  (
    BEHAVIOR_DETACH = 0,
    BEHAVIOR_ATTACH = 1,
    INITIALIZATION_EVENTS_DUMMY = MAXINT
  );


  INITIALIZATION_PARAMS = record
    cmd: INITIALIZATION_EVENTS;
  end;
  PINITIALIZATION_PARAMS = ^INITIALIZATION_PARAMS;


  KEYBOARD_STATES =
  (
    CONTROL_KEY_PRESSED     = $01,
    SHIFT_KEY_PRESSED       = $02,
    ALT_KEY_PRESSED         = $04,
    RIGHT_SHIFT_KEY_PRESSED = $08,
    CMD_KEY_PRESSED         = $10,
    KEYBOARD_STATES_DUMMY = MAXINT
  );


  CURSOR_TYPE =
  (
    CURSOR_ARROW,
    CURSOR_IBEAM,
    CURSOR_WAIT,
    CURSOR_CROSS,
    CURSOR_UPARROW,
    CURSOR_SIZENWSE,
    CURSOR_SIZENESW,
    CURSOR_SIZEWE,
    CURSOR_SIZENS,
    CURSOR_SIZEALL,
    CURSOR_NO,
    CURSOR_APPSTARTING,
    CURSOR_HELP,
    CURSOR_HAND,
    CURSOR_DRAG_MOVE,
    CURSOR_DRAG_COPY,
    CURSOR_OTHER,
    CURSOR_TYPE_DUMMY = MAXINT
  );


  MOUSE_EVENTS =
  (
    MOUSE_EVENTS_ALL = -1,      // doesn't exist in sciter api, used to define null event
    MOUSE_ENTER  = 0,
    MOUSE_LEAVE  = 1,
    MOUSE_MOVE   = 2,
    MOUSE_UP     = 3,
    MOUSE_DOWN   = 4,
    MOUSE_DCLICK = 5,
    MOUSE_WHEEL  = 6,
    MOUSE_TICK   = 7,
    MOUSE_IDLE   = 8,
    DROP         = 9,  // obsolete
    DRAG_ENTER   = 10, // obsolete
    DRAG_LEAVE   = 11, // obsolete
    DRAG_REQUEST = 12, // obsolete
    MOUSE_TCLICK = $0F,
    MOUSE_DRAG_REQUEST = $FE,
    MOUSE_CLICK  = $FF,
    DRAGGING     = $100, // obsolete
    MOUSE_HIT_TEST = $FFE, // sent to element, allows to handle elements with non-trivial shapes
    MOUSE_EVENTS_DUMMY = MAXINT // doesn't exist in sciter api, used for sizeof(uint) alignment
  );


  MOUSE_BUTTONS =
  (
    MAIN_MOUSE_BUTTON    = 1,
    PROP_MOUSE_BUTTON    = 2,
    MIDDLE_MOUSE_BUTTON  = 4,
    MOUSE_BUTTONS_DUMMY  = MAXINT
  );


  MOUSE_PARAMS = record
             cmd: MOUSE_EVENTS;
          target: HELEMENT;
             pos: TPoint;
        pos_view: TPoint;
    button_state: MOUSE_BUTTONS;
       alt_state: KEYBOARD_STATES;
     cursor_type: CURSOR_TYPE;
      is_on_icon: BOOL;
        dragging: HELEMENT;
   dragging_mode: UINT;
  end;
  PMOUSE_PARAMS = ^MOUSE_PARAMS;


  KEY_EVENTS =
  (
    KEY_EVENTS_ALL = -1,      // doesn't exist in sciter api, used to define null event
    KEY_DOWN = 0,
    KEY_UP,
    KEY_CHAR,
    KEY_EVENTS_DUMMY = MAXINT // doesn't exist in sciter api, used for sizeof(uint) alignment
  );

  KEY_PARAMS = record
          cmd: KEY_EVENTS;
       target: HELEMENT;
     key_code: UINT;
    alt_state: KEYBOARD_STATES;
  end;
  PKEY_PARAMS = ^KEY_PARAMS;


  FOCUS_EVENTS =
  (
    FOCUS_OUT     = 0, // container lost focus from any element inside it, target is an element that lost focus
    FOCUS_IN      = 1, // container got focus on element inside it, target is an element that got focus
    FOCUS_GOT     = 2, // target element got focus
    FOCUS_LOST    = 3, // target element lost focus
    FOCUS_REQUEST = 4, // bubbling event/request, gets sent on child-parent chain to accept/reject focus to be set on the child (target)
    FOCUS_ADVANCE_REQUEST = 5, // bubbling event/request, gets sent on child-parent chain to advance focus
    FOCUS_EVENTS_DUMMY = MAXINT
  );

  FOCUS_CMD_TYPE =
  (
    FOCUS_RQ_NEXT,
    FOCUS_RQ_PREV,
    FOCUS_RQ_HOME,
    FOCUS_RQ_END,
    FOCUS_RQ_LEFT,
    FOCUS_RQ_RIGHT,
    FOCUS_RQ_UP,
    FOCUS_RQ_DOWN,  // all these - by key
    FOCUS_RQ_FIRST, // these two - by_code
    FOCUS_RQ_LAST,
    FOCUS_RQ_END_REACHED = $8000
  );


  FOCUS_PARAMS = record
               cmd: FOCUS_EVENTS;
            target: HELEMENT;
             cause: FOCUS_CMD_TYPE;
            cancel: BOOL;
  end;
  PFOCUS_PARAMS = ^FOCUS_PARAMS;


  DATA_ARRIVED_PARAMS = record
    initiator: HELEMENT;
         data: PByte;
     dataSize: UINT;
     dataType: UINT;
       status: UINT;
          uri: PWideChar;
  end;
  PDATA_ARRIVED_PARAMS = ^DATA_ARRIVED_PARAMS;

  ATTRIBUTE_CHANGE_PARAMS = record
           he: HELEMENT;
         name: PAnsiChar; // attribute name
        value: PWideChar; // new attribute value, NULL if attribute was deleted
  end;
  PATTRIBUTE_CHANGE_PARAMS = ^ATTRIBUTE_CHANGE_PARAMS;


  DRAW_EVENTS =
  (
      DRAW_BACKGROUND = 0,
      DRAW_CONTENT = 1,
      DRAW_FOREGROUND = 2,
      DRAW_OUTLINE = 3,
      DRAW_EVENTS_DUMMY = MAXINT
  );

  DRAW_PARAMS = record
    cmd: DRAW_EVENTS;
    hdc: HDC;
    area: TRect;
    reserved: UINT;
  end;
  PDRAW_PARAMS=^DRAW_PARAMS;


  TIMER_PARAMS = record
    timerId: UINT_PTR;
  end;
  PTIMER_PARAMS = ^TIMER_PARAMS;


  SCRIPTING_METHOD_PARAMS = record
    name: PAnsiChar;
    argv: PSciterValue; // SCITER_VALUE*
    argc: UINT;
    rv: TSciterValue;
  end;
  PSCRIPTING_METHOD_PARAMS = ^SCRIPTING_METHOD_PARAMS;

  SCROLL_EVENTS =
  (
    SCROLL_HOME,
    SCROLL_END,
    SCROLL_STEP_PLUS,
    SCROLL_STEP_MINUS,
    SCROLL_PAGE_PLUS,
    SCROLL_PAGE_MINUS,
    SCROLL_POS,
    SCROLL_SLIDER_RELEASED,
    SCROLL_CORNER_PRESSED,
    SCROLL_CORNER_RELEASED,
    SCROLL_SLIDER_PRESSED,
    SCROLL_ANIMATION_START,
    SCROLL_ANIMATION_END,
    SCROLL_EVENTS_DUMMY = MAXINT
  );

  SCROLL_SOURCE =
  (
    SCROLL_SOURCE_UNKNOWN,
    SCROLL_SOURCE_KEYBOARD,  // SCROLL_PARAMS::reason <- keyCode
    SCROLL_SOURCE_SCROLLBAR, // SCROLL_PARAMS::reason <- SCROLLBAR_PART
    SCROLL_SOURCE_ANIMATOR,
    SCROLL_SOURCE_WHEEL
  );

  SCROLLBAR_PART =
  (
    SCROLLBAR_BASE,
    SCROLLBAR_PLUS,
    SCROLLBAR_MINUS,
    SCROLLBAR_SLIDER,
    SCROLLBAR_PAGE_MINUS,
    SCROLLBAR_PAGE_PLUS,
    SCROLLBAR_CORNER
  );

  SCROLL_PARAMS = record
    cmd: SCROLL_EVENTS;
    target: HELEMENT;
    pos: integer;
    vertical: BOOL;
    source: SCROLL_SOURCE;
    reason: UINT; // key or scrollbar part
  end;
  PSCROLL_PARAMS = ^SCROLL_PARAMS;

  { Inspector }
  TSciterInspector = procedure(root: HELEMENT; papi: PSciterApi); stdcall;
  TSciterWindowInspector = procedure(hwndSciter: HWINDOW; papi: PSciterApi); stdcall;

  { Exceptions }
  ESciterException = class(Exception)
  end;

  ESciterNullPointerException = class(ESciterException)
  public
    constructor Create;
  end;

  ESciterCallException = class(ESciterException)
  public
    constructor Create(const MethodName: String);
  end;

  ESciterNotImplementedException = class(ESciterException)
  end;

  TRecordData = class(TPersistent)
  public
    RecObj: Pointer;
    RecType: Pointer;
  end;

  TRecordVarData = packed record
    VType: TVarType;
    Reserved1, Reserved2, Reserved3: Word;
    RecObj: Pointer;
    RecType: Pointer;
  end;

  TRecordVariantType = class(TCustomVariantType)
  public
    procedure Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean); override;
    procedure Clear(var V: TVarData); override;
    function IsClear(const V: TVarData): Boolean; override;
  end;

  TSymbolData = record
  public
    Symbol: String;
  end;

  TSymbolVarData = packed record
    VType: TVarType;
    Reserved1, Reserved2, Reserved3: Word;
    VSymbol: TSymbolData;
    Reserved4: NativeInt;
  end;

  TSymbolVariantType = class(TCustomVariantType)
  public
    procedure Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean); override;
    procedure Clear(var V: TVarData); override;
    function IsClear(const V: TVarData): Boolean; override;
  end;

  TDispatchKind = (dkMethod, dkProperty, dkSubComponent);

  TDispatchInfo = record
    Instance: TObject;
    case Kind: TDispatchKind of
      dkMethod:
        (MethodInfo: ShortString);
      dkProperty:
        (PropInfo: ShortString);
      dkSubComponent:
        (Index: Integer);
  end;

  type
    PVariantArray = ^TVariantArray;
    TVariantArray = array [0 .. 65535] of Variant;
    PIntegerArray = ^TIntegerArray;
    TIntegerArray = array [0 .. 65535] of Integer;

  IScriptFunction = interface
    ['{35A4060B-209F-43CD-B235-0CD64E2A2241}']
    function IsValueEqual(sv: PSciterValue): Boolean;
  end;

  TScriptFunction = class(TInterfacedObject, IDispatch, IScriptFunction)
  private
    FSciterValue: TSciterValue;
    FNameDispIDList: TStringList;
  protected
    function IsValueEqual(sv: PSciterValue): Boolean;
    function AllocNameDispID(szName: string): TDispID;
    { IDispatch }
    function GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount: Integer; LocaleID: Integer; DispIDs: Pointer): HRESULT; virtual; stdcall;
    function GetTypeInfo(Index: Integer; LocaleID: Integer; out TypeInfo): HRESULT; stdcall;
    function GetTypeInfoCount(out Count: Integer): HRESULT; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params; VarResult: Pointer; ExcepInfo: Pointer; ArgErr: Pointer): HRESULT; virtual; stdcall;
  public
    constructor Create(sv: TSciterValue);
    destructor Destroy; override;
  end;

{ Conversion functions. Mnemonics are: T - tiscript_value, S - TSciterValue, V - VARIANT }
function S2V(Value: PSciterValue; var OutValue: Variant; FuncName: String = 'unknown'): UINT;
function V2S(const Value: Variant; SciterValue: PSciterValue): UINT;
function API: PSciterApi;
function RAPI: PSciterRApi;
function SciterVarType(value: PSciterValue): TSciterValueType;
function SciterVarToString(value: PSciterValue): WideString;
function GetNativeObjectJson(const Value: PSciterValue): WideString;
function CallScriptFunction(Element: HELEMENT; const FuncName: AnsiString; Params: TArray<Variant>): SCDOM_RESULT; overload;
function CallScriptFunction(Element: HELEMENT; const FuncName: AnsiString; Params: TArray<Variant>; var RetVal: TSciterValue): SCDOM_RESULT; overload;
function CallScriptMethod(Element: HELEMENT; const FuncName: AnsiString; Params: TArray<Variant>): SCDOM_RESULT; overload;
function CallScriptMethod(Element: HELEMENT; const FuncName: AnsiString; Params: TArray<Variant>; var RetVal: TSciterValue): SCDOM_RESULT; overload;

var
  SCITER_DLL_DIR: String = '';
  SCITER_DLL_FILENAME: String = 'sciter.dll';
  SCITER_DLL_SKIP_FREE: Boolean = False;
  varRecordEx: Word = 0;
  varSymbol: Word = 0;
  HSCITER: HMODULE;

implementation

var
  FAPI: PSciterApi;
  FRAPI: PSciterRApi;
  RecordVariantType: TRecordVariantType;
  SymbolVariantType: TSymbolVariantType;

{ TRecordVariantType }

procedure TRecordVariantType.Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean);
begin
  if Indirect and VarDataIsByRef(Source) then
     VarDataCopyNoInd(Dest, Source)
  else
  with TRecordVarData(Dest) do
  begin
    VType := VarType;
    RecObj := TRecordVarData(Source).RecObj;
    RecType := TRecordVarData(Source).RecType;
  end;
end;

procedure TRecordVariantType.Clear(var V: TVarData);
begin
  V.VType := varEmpty;
  TRecordVarData(V).RecObj := nil;
  TRecordVarData(V).RecType := nil;
end;

function TRecordVariantType.IsClear(const V: TVarData): Boolean;
begin
  Result := not Assigned(TRecordVarData(V).RecObj);
end;

{ TSymbolVariantType }

procedure TSymbolVariantType.Copy(var Dest: TVarData; const Source: TVarData; const Indirect: Boolean);
begin
  if Indirect and VarDataIsByRef(Source) then
     VarDataCopyNoInd(Dest, Source)
  else
  with TSymbolVarData(Dest) do
  begin
    VType := VarType;
    VSymbol.Symbol := TSymbolVarData(Source).VSymbol.Symbol;
  end;
end;

procedure TSymbolVariantType.Clear(var V: TVarData);
begin
  V.VType := varEmpty;
  TSymbolVarData(V).VSymbol.Symbol := '';
end;

function TSymbolVariantType.IsClear(const V: TVarData): Boolean;
begin
  Result := TSymbolVarData(V).VSymbol.Symbol = '';
end;

function GetNativeObjectJson(const Value: PSciterValue): WideString;
var
  pWStr: PWideChar;
  iNum: UINT;
  pType: TSciterValueType;
  pUnits: UINT;
begin
  pUnits := 0;
  API.ValueType(Value, pType, pUnits);
  if (pType = T_NULL) or (pType = T_UNDEFINED) then
  begin
    Result := '';
    Exit;
  end;
  
  API.ValueToString(Value, CVT_XJSON_LITERAL);
  API.ValueStringData(Value, pWStr, iNum);
  Result := WideString(pWstr);
end;

function CallScriptFunction(Element: HELEMENT; const FuncName: AnsiString; Params: TArray<Variant>): SCDOM_RESULT;
var
  RetVal: TSciterValue;
begin
  API.ValueInit(@RetVal);
  Result := CallScriptFunction(Element, FuncName, Params, RetVal);
  API.ValueClear(@RetVal);
end;

function CallScriptFunction(Element: HELEMENT; const FuncName: AnsiString; Params: TArray<Variant>; var RetVal: TSciterValue): SCDOM_RESULT;
var
  SParams: TArray<TSciterValue>;
  I: Integer;
begin
  SetLength(SParams, Length(Params));
  for I := Low(Params) to High(Params) do
  begin
    API.ValueInit(@SParams[I]);
    V2S(Params[I], @SParams[I]);
  end;

  try
    Result := API.SciterCallScriptingFunction(Element, PAnsiChar(FuncName), @SParams[0], Length(SParams), RetVal);
    if not (Result = SCDOM_OK) then
      OutputDebugString(PChar('Call failed: ' + FuncName + ', ' + IntToStr(Integer(Result))));
  except
    OutputDebugString(PChar('Call failed: ' + FuncName));
  end;

  for I := Low(SParams) to High(SParams) do
    API.ValueClear(@SParams[I]);
end;

function CallScriptMethod(Element: HELEMENT; const FuncName: AnsiString; Params: TArray<Variant>): SCDOM_RESULT;
var
  RetVal: TSciterValue;
begin
  API.ValueInit(@RetVal);
  Result := CallScriptMethod(Element, FuncName, Params, RetVal);
  API.ValueClear(@RetVal);
end;

function CallScriptMethod(Element: HELEMENT; const FuncName: AnsiString; Params: TArray<Variant>; var RetVal: TSciterValue): SCDOM_RESULT;
var
  SParams: TArray<TSciterValue>;
  I: Integer;
begin
  SetLength(SParams, Length(Params));
  for I := Low(Params) to High(Params) do
  begin
    API.ValueInit(@SParams[I]);
    V2S(Params[I], @SParams[I]);
  end;

  try
    Result := API.SciterCallScriptingMethod(Element, PAnsiChar(FuncName), @SParams[0], Length(SParams), RetVal);
    if not (Result = SCDOM_OK) then
      OutputDebugString(PChar('Call failed: ' + FuncName + ', ' + IntToStr(Integer(Result))));
  except
    OutputDebugString(PChar('Call failed: ' + FuncName));
  end;

  for I := Low(SParams) to High(SParams) do
    API.ValueClear(@SParams[I]);
end;

function SciterVarType(value: PSciterValue): TSciterValueType;
var
  pUnits: UINT;
begin
  API.ValueType(value, Result, pUnits);
end;

function SciterVarToString(value: PSciterValue): WideString;
var
  pType: TSciterValueType;
  pUnits: UINT;
  pCh: PWideChar;
  iNum: UINT;
begin
  Result := '';
  API.ValueType(value, pType, pUnits);
  if (pType = T_STRING) then
  begin
    API.ValueStringData(value, pCh, iNum);
    Result := WideString(pCh);
  end;
end;

function API: PSciterApi;
var
  pFuncPtr: SciterApiFunc;
begin
  if FAPI = nil then
  begin
    HSCITER := LoadLibrary(PWideChar(SCITER_DLL_DIR + SCITER_DLL_FILENAME));
    if HSCITER = 0 then
      raise ESciterException.Create('Failed to load Sciter DLL.');

    pFuncPtr := GetProcAddress(HSCITER, 'SciterAPI');
    if pFuncPtr = nil then
      raise ESciterException.Create('Failed to get pointer to SciterAPI function.');

    FAPI := pFuncPtr();
  end;
  Result := FAPI;
end;

function RAPI: PSciterRApi;
begin
  if FRAPI = nil then
    FRAPI := API.GetSciterRequestAPI();
  Result := FRAPI;
end;

{ SciterValue to Variant conversion }
function S2V(Value: PSciterValue; var OutValue: Variant; FuncName: String = 'unknown'): UINT;
var
  pType: TSciterValueType;
  pUnits: UINT;
  pWStr: PWideChar;
  iNum: UINT;
  sWStr: WideString;
  iResult: Integer;
  dResult: Double;
  i64Result: Int64;
  ft: TFileTime;
  pbResult: PByte;
  pResult: Pointer;
  cResult: Currency;
  st: SYSTEMTIME;
  //pDispValue: IDispatch;
  arrSize: UINT;
  sArrItem: TSciterValue;
  oArrItem: Variant;
  j: Integer;
begin
  if API.ValueType(Value, pType, pUnits) <> HV_OK then
    raise ESciterException.Create('Unknown Sciter value type.');
  case pType of
    T_ARRAY:
      begin
        API.ValueElementsCount(Value, arrSize);
        OutValue := VarArrayCreate([0, arrSize - 1], varVariant);
        for j := 0 to arrSize - 1 do
        begin
          oArrItem := Unassigned;
          API.ValueInit(@sArrItem);
          API.ValueNthElementValue(Value, j, sArrItem);
          S2V(@sArrItem, oArrItem);
          API.ValueClear(@sArrItem);
          VarArrayPut(Variant(OutValue), oArrItem, [j]);
        end;
        Result := HV_OK;
      end;
    T_BOOL:
      begin
        Result := API.ValueIntData(Value, iResult);
        if Result = HV_OK then
          OutValue := iResult <> 0
        else
          OutValue := False;
      end;
    T_BYTES:
      begin
        raise ESciterNotImplementedException.Create('Cannot convert T_BYTES to Variant (not implemented).');
      end;
    T_CURRENCY:
      begin
        // TODO: ?
        Result := API.ValueInt64Data(Value, i64Result);
        cResult := PCurrency(@i64Result)^;
        OutValue := cResult;
      end;
    T_DATE:
      begin
        Result := API.ValueInt64Data(Value, i64Result);
        ft := TFileTime(i64Result);
        FileTimeToSystemTime(ft, st);
        SystemTimeToVariantTime(st, dResult);
        OutValue := TDateTime(dResult);
      end;
    T_DOM_OBJECT:
      begin
        raise ESciterNotImplementedException.Create('Cannot convert T_DOM_OBJECT to Variant (not implemented).');
      end;
    T_FLOAT:
      begin
        Result := API.ValueFloatData(Value, dResult);
        OutValue := dResult;
      end;
    T_STRING:
      begin
        Result := API.ValueStringData(Value, pWStr, iNum);
        sWStr := WideString(pWStr);
        OutValue := sWStr;
        if pUnits = UINT(UT_STRING_ERROR) then
          MessageBox(0, PChar(Format('Script error: %s', [sWStr])), PChar('Sciter'), MB_OK);
          //raise ESciterCallException.CreateFmt('Script error in %s: %s', [FuncName + '()', sWStr]);
      end;
    T_MAP:
      begin
        OutValue := GetNativeObjectJson(Value);
        Result := HV_OK;
      end;
    T_FUNCTION:
      begin
        raise ESciterNotImplementedException.Create('Cannot convert T_FUNCTION to Variant (not implemented).');
      end;
    T_INT:
      begin
        Result := API.ValueIntData(Value, iResult);
        OutValue := iResult;
      end;
    T_LENGTH:
      begin
        raise ESciterNotImplementedException.Create('Cannot convert T_LENGTH to Variant (not implemented).');
      end;
    T_NULL:
      begin
        OutValue := Null;
        Result := HV_OK;
      end;
    T_RESOURCE:
    begin
      pResult := 0;
      API.SciterElementUnwrap(Value, pResult);
      OutValue := NativeInt(pResult);
    end;
    T_OBJECT:
      // TODO: returns Variant if Object wraps IDispatch, JSON otherwise
      begin
        pbResult := nil;
        Result := API.ValueBinaryData(Value, pbResult, iNum);
        if Result = HV_OK then
        begin
          if pbResult <> nil then
          begin
//            pDispValue := IDispatch(Pointer(pbResult));
//            try
//              pDispValue._AddRef;
//              pDispValue._Release;
//              OutValue := OleVariant(pDispValue);
//            except
//              // not an IDispatch, probably native tiscript object
//              OutValue := GetNativeObjectJson(Value);
              OutValue := NativeInt(pbResult);
              Result := HV_OK;
//            end;
          end else
            OutValue := Unassigned;
        end
          else
        begin
          // TODO: isolate all unit types
          case TSciterValueUnitTypeObject(pUnits) of
            UT_OBJECT_ARRAY, UT_OBJECT_OBJECT, UT_OBJECT_ERROR:
              begin
                API.ValueIsolate(Value);
                Result := S2V(Value, OutValue);
                Exit;
              end;
            UT_OBJECT_FUNCTION:
              begin
                OutValue := TScriptFunction.Create(Value^) as IDispatch;
                Result := HV_OK;
                Exit;
              end;
          end;

          OutValue := GetNativeObjectJson(Value);
          Result := HV_OK;
        end;
      end;
    T_UNDEFINED:
      begin
        OutValue := Unassigned;
        Result := HV_OK;
      end;
    else
      begin
        raise ESciterNotImplementedException.CreateFmt('Conversion from Sciter type %d to Variant is not implemented.', [Integer(pType)]);
      end;
  end;
end;

{ Variant to SciterValue conversion }
function V2S(const Value: Variant; SciterValue: PSciterValue): UINT;
var
  sWStr: WideString;
  i64: Int64;
  c32: Cardinal;
  d: Double;
  date: TDateTime;
  st: SYSTEMTIME;
  ft: FILETIME;

  procedure ProcessRecord(sval: PSciterValue; rectype, recobj: Pointer);

    procedure ProcessValue(rval: TValue; var val: TSciterValue);
    var
      j: Integer;
      bytes: TBytes;
      elem: TSciterValue;
      aval: TValue;
    begin
      if rval.Kind = tkInteger then
        API.ValueIntDataSet(@val, rval.AsInteger, T_INT, 0)
      else if rval.Kind = tkEnumeration then
      begin
        if GetTypeName(rval.TypeInfo) = 'Boolean' then
        begin
          if rval.AsOrdinal = 1 then
            API.ValueIntDataSet(@val, 1, T_BOOL, 0)
          else
            API.ValueIntDataSet(@val, 0, T_BOOL, 0)
        end else
          API.ValueIntDataSet(@val, rval.AsOrdinal, T_INT, 0)
      end
      else if (rval.Kind = tkString) or (rval.Kind = tkWString) or (rval.Kind = tkUString) or (rval.Kind = tkLString) then
        API.ValueStringDataSet(@val, PWideChar(rval.AsString), Length(rval.AsString), 0)
      else if rval.Kind = tkFloat then
      begin
        date := TDateTime(rval.AsExtended);
        d := Double(date);
        VariantTimeToSystemTime(d, st);
        SystemTimeToFileTime(st, ft);
        i64 := Int64(ft);
        Result := API.ValueInt64DataSet(@val, i64, T_DATE, UINT(True));
      end else if (rval.Kind = tkArray) or (rval.Kind = tkDynArray) then
      begin
        if GetTypeName(rval.TypeInfo) = 'TArray<System.Byte>' then
        begin
          bytes := rval.AsType<TBytes>;
          API.ValueBinaryDataSet(@val, PByte(bytes), Length(bytes), T_BYTES, 0);
        end else
        for j := 0 to rval.GetArrayLength - 1 do
        begin
          API.ValueInit(@elem);
          aval := rval.GetArrayElement(j);
          ProcessValue(aval, elem);
          API.ValueNthElementValueSet(@val, j, @elem);
          API.ValueClear(@elem);
        end;
      end else if rval.Kind = tkRecord then
        ProcessRecord(@val, rval.TypeInfo, rval.GetReferenceToRawData)
      else if rval.Kind = tkVariant then
        V2S(rval.AsVariant, @val)
      else
        raise ESciterNotImplementedException.CreateFmt('Cannot convert record field of type %d to Sciter value.', [Integer(rval.Kind)]);
    end;

  var
    i: Integer;
    valfields: TArray<TRttiField>;
    rval: TValue;
    key, val: TSciterValue;
  begin
    valfields := TRTTIContext.Create.GetType(rectype).GetFields;
    for i := Low(valfields) to High(valfields) do
    begin
      API.ValueInit(@key);
      API.ValueInit(@val);
      API.ValueStringDataSet(@key, PWideChar(valfields[i].Name), Length(valfields[i].Name), UINT(UT_STRING_SYMBOL));
      rval := valfields[i].GetValue(recobj);
      ProcessValue(rval, val);
      Result := API.ValueSetValueToKey(sval, @key, @val);
      API.ValueClear(@key);
      API.ValueClear(@val);
    end;
  end;

var
  pDisp: IDispatch;
  cCur: Currency;
  vt: Word;
  i: Integer;
  oArrItem: Variant;
  sArrItem: TSciterValue;
begin
  vt := VarType(Value);
  if (vt and varArray) = varArray then
  begin
    if (vt and varByte) = varByte then
      Result := API.ValueBinaryDataSet(SciterValue, PByte(TBytes(Value)), Length(TBytes(Value)), T_BYTES, 0)
    else
    for i := VarArrayLowBound(Value, 1) to VarArrayHighBound(Value, 1) do
    begin
      oArrItem := VarArrayGet(Value, [i]);
      API.ValueInit(@sArrItem);
      V2S(oArrItem, @sArrItem);
      API.ValueNthElementValueSet(SciterValue, i, @sArrItem);
    end;
    Result := 0;
    Exit;
  end;

  case vt of
    varEmpty:
      Result := 0;
    varNull:
      Result := 0;
    varString,
    varUString,
    varOleStr:
      begin
        sWStr := Value;
        Result := API.ValueStringDataSet(SciterValue, PWideChar(sWStr), Length(sWStr), 0);
      end;
    varBoolean:
      begin
        if Value then
          Result := API.ValueIntDataSet(SciterValue, 1, T_BOOL, 0)
        else
          Result := API.ValueIntDataSet(SciterValue, 0, T_BOOL, 0);
      end;
    varByte,
    varSmallInt,
    varShortInt,
    varInteger,
    varWord:
      Result := API.ValueIntDataSet(SciterValue, Integer(Value), T_INT, 0);
    varUInt32:
      begin
        c32 := Value;
        Result := API.ValueIntDataSet(SciterValue, c32, T_INT, 0);
      end;
    varInt64:
      Result := API.ValueIntDataSet(SciterValue, Value, T_INT, 0);
    varSingle,
    varDouble:
      Result := API.ValueFloatDataSet(SciterValue, Double(Value), T_FLOAT, 0);
    varCurrency:
      begin
        cCur := Value;
        i64 := PInt64(@cCur)^;
        Result := API.ValueInt64DataSet(SciterValue, i64, T_CURRENCY, 0);
      end;
    varDate:
      begin
        date := TDateTime(Value);
        d := Double(date);
        VariantTimeToSystemTime(d, st);
        SystemTimeToFileTime(st, ft);
        i64 := Int64(ft);
        Result := API.ValueInt64DataSet(SciterValue, i64, T_DATE, 0);
      end;
    varDispatch:
      begin
        pDisp := IDispatch(Value);
        //pDisp._AddRef;
        Result := API.ValueBinaryDataSet(SciterValue, PByte(pDisp), 1, T_OBJECT, 0);
      end;
    else if vt = varSymbol then
      begin
        sWStr := TSymbolVarData(Value).VSymbol.Symbol;
        Result := API.ValueStringDataSet(SciterValue, PWideChar(sWStr), Length(sWStr), UINT(UT_STRING_SYMBOL))
      end
    else if vt = varRecordEx then
      ProcessRecord(SciterValue, TRecordVarData(Value).RecType, TRecordVarData(Value).RecObj)
    else
      raise ESciterNotImplementedException.CreateFmt('Cannot convert VARIANT of type %d to Sciter value.', [vt]);
  end;
end;
{ ESciterNullPointerException }

constructor ESciterNullPointerException.Create;
begin
  inherited Create('The argument cannot be null.');
end;

{ ESciterCallException }

constructor ESciterCallException.Create(const MethodName: String);
begin
  inherited CreateFmt('Method "%s" call failed.', [MethodName]);
end;


{ TScriptFunction }

const
  OfDispParamIDOffset = 200;

function TScriptFunction.AllocNameDispID(szName: string): TDispID;
begin
  Result := FNameDispIDList.IndexOf(szName);
  if Result = -1 then
  begin
    FNameDispIDList.Add(szName);
    Result := FNameDispIDList.Count - 1;
  end;
  Inc(Result, OfDispParamIDOffset);
end;

procedure WideCharToShortString(P: PWideChar; var S: ShortString);
begin
//  S[0] := AnsiChar(UnicodeToUtf8(@S[1], 255, P, Cardinal(-1)) - 1);
  S := string(P);
end;

constructor TScriptFunction.Create(sv: TSciterValue);
begin
  inherited Create();
  API.ValueInit(@FSciterValue);
  API.ValueCopy(@FSciterValue, @sv);
  FNameDispIDList := TStringList.Create;
end;

destructor TScriptFunction.Destroy;
begin
  API.ValueClear(@FSciterValue);
  FNameDispIDList.Free;
  inherited;
end;

function TScriptFunction.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: Integer; DispIDs: Pointer): HRESULT;
type
  PNames = ^TNames;
  TNames = array [0 .. 100] of POleStr;
  PDispIDs = ^TDispIDs;
  TDispIDs = array [0 .. 100] of Cardinal;
var
  Name: ShortString;
  aDispInfo: TDispatchInfo;
  I: Integer;
begin
  Result := S_OK;
  WideCharToShortString(PNames(Names)^[0], Name); // get name
  FillChar(DispIDs^, SizeOf(PDispIDs(DispIDs^)[0]) * NameCount, $FF);

  aDispInfo.Instance := nil;
  aDispInfo.Kind := dkProperty;
  aDispInfo.PropInfo := Name;

  if SameText(Name, 'Call') then
  begin
    aDispInfo.Kind := dkMethod;
    PDispIDs(DispIDs)^[0] := 201; // call the function
  end;

  if SameText(Name, 'Equal') then
  begin
    aDispInfo.Kind := dkMethod;
    PDispIDs(DispIDs)^[0] := 202; // whether they are equal
  end;

  // we fill ids of params which may used in find proc
  for I := 1 to NameCount - 1 do
  begin
    WideCharToShortString(PNames(Names)^[I], Name);
    PDispIDs(DispIDs)^[I] := AllocNameDispID(Name);
  end;
end;

function TScriptFunction.GetTypeInfo(Index, LocaleID: Integer;
  out TypeInfo): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TScriptFunction.GetTypeInfoCount(out Count: Integer): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TScriptFunction.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
var
  Parms: PDispParams;
  TempRet: Variant;
  ret: TSciterValue;
  pt: TSciterValueType;
  scParams: TArray<TSciterValue>;
  I: Integer;
  scResult: Cardinal;
  isf: IScriptFunction;
  dummy: UINT;

  function _IsSciterFunction(v: Variant): Boolean;
  begin
    Result := (not VarIsEmpty(v)) and (FindVarData(v)^.VType = varDispatch);
  end;

  function _VarToDisp(v: Variant): IDispatch;
  var
    Dispatch: Pointer;
  begin
    if FindVarData(v)^.VType = varDispatch then
      Dispatch := FindVarData(v)^.VDispatch
    else if FindVarData(v)^.VType = (varDispatch or varByRef) then
      Dispatch := Pointer(FindVarData(v)^.VPointer^);
    Result := IDispatch(Dispatch);
  end;

begin
  Result := S_OK;

  Parms := @Params;
  try
    if VarResult = nil then
      VarResult := @TempRet;

    case DispID of
      201:
        begin      // call method
          try
            if (API.ValueType(@FSciterValue, pt, dummy) <> 0) or (pt <> T_OBJECT) then
            begin
              Result := E_FAIL;
              Exit;
            end;
          except
            Result := E_FAIL;
          end;
          SetLength(scParams, Parms.cArgs);
          for I := 0 to Parms.cArgs-1 do
          begin
            API.ValueInit(@scParams[I]);
            try
              V2S(PVariantArray(Parms.rgvarg)^[Parms.cArgs - 1 - I], @scParams[I]);
            except end;
          end;

          POleVariant(VarResult)^ := 1;
          if Parms.cArgs = 0 then
            scResult := API.ValueInvoke(@FSciterValue, @FSciterValue, 0, nil, ret, nil)
          else
            scResult := API.ValueInvoke(@FSciterValue, @FSciterValue, Parms.cArgs, @scParams[0], ret, nil);
          if scResult <> HV_OK then
            POleVariant(VarResult)^ := 0;
          for I := 0 to Parms.cArgs-1 do
          begin
            API.ValueClear(@scParams[I]);
          end;

          API.ValueClear(@ret);
        end;
      202:
        begin
          // equal method, unfinished
          if Parms.cArgs <> 1 then
            Result := DISP_E_BADPARAMCOUNT
          else
          begin
            if (_IsSciterFunction(PVariantArray(Parms.rgvarg)^[0]) and Supports(_VarToDisp(PVariantArray(Parms.rgvarg)^[0]), IScriptFunction, isf)) then
            begin
              // need to return the result
              isf.IsValueEqual(@FSciterValue);
            end;
          end;
        end
      else
        Result := DISP_E_MEMBERNOTFOUND;
    end;
  except
    if ExcepInfo <> nil then
    begin
      FillChar(ExcepInfo^, SizeOf(TExcepInfo), 0);
      with TExcepInfo(ExcepInfo^) do
      begin
        bstrSource := StringToOleStr(ClassName);
        if ExceptObject is Exception then
          bstrDescription := StringToOleStr(Exception(ExceptObject).Message);
        scode := E_FAIL;
      end;
    end;
    Result := DISP_E_EXCEPTION;
  end;
end;

function TScriptFunction.IsValueEqual(sv: PSciterValue): Boolean;
begin
  Result := API.ValueCompare(sv, @FSciterValue) = HV_OK_TRUE;
end;

initialization
  HSCITER := 0;
  RecordVariantType := TRecordVariantType.Create;
  varRecordEx := RecordVariantType.VarType;
  SymbolVariantType := TSymbolVariantType.Create;
  varSymbol := SymbolVariantType.VarType;

finalization
  FreeAndNil(RecordVariantType);
  FreeAndNil(SymbolVariantType);
  if (HSCITER <> 0) and not SCITER_DLL_SKIP_FREE then
    FreeLibrary(HSCITER);

end.
