unit MsSpellCheckLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 52393 $
// File generated on 02.01.2017 16:39:22 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Program Files (x86)\Windows Kits\spellcheck.tlb (1)
// LIBID: {4A250E01-61EA-400B-A27D-BF3744BCC9F5}
// LCID: 0
// Helpfile: 
// HelpString: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// Errors:
//   Hint: Parameter 'to' of ISpellChecker.AutoCorrect changed to 'to_'
//   Error creating palette bitmap of (TSpellCheckerFactory) : Server C:\Windows\SysWOW64\MsSpellCheckingFacility.dll contains no icons
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses System.Classes, Vcl.OleServer, Winapi.ActiveX;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  MsSpellCheckLibMajorVersion = 1;
  MsSpellCheckLibMinorVersion = 0;

  LIBID_MsSpellCheckLib: TGUID = '{4A250E01-61EA-400B-A27D-BF3744BCC9F5}';

  IID_ISpellCheckerFactory: TGUID = '{8E018A9D-2415-4677-BF08-794EA61F94BB}';
  IID_IUserDictionariesRegistrar: TGUID = '{AA176B85-0E12-4844-8E1A-EEF1DA77F586}';
  IID_IEnumString: TGUID = '{00000101-0000-0000-C000-000000000046}';
  IID_ISpellChecker: TGUID = '{B6FD0B71-E2BC-4653-8D05-F197E412770B}';
  IID_IEnumSpellingError: TGUID = '{803E3BD4-2828-4410-8290-418D1D73C762}';
  IID_ISpellingError: TGUID = '{B7C82D61-FBE8-4B47-9B27-6C0D2E0DE0A3}';
  IID_ISpellCheckerChangedEventHandler: TGUID = '{0B83A5B0-792F-4EAB-9799-ACF52C5ED08A}';
  IID_IOptionDescription: TGUID = '{432E5F85-35CF-4606-A801-6F70277E1D7A}';
  CLASS_SpellCheckerFactory: TGUID = '{7AB36653-1796-484B-BDFA-E74F1DB7C1DC}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum CORRECTIVE_ACTION
type
  CORRECTIVE_ACTION = TOleEnum;
const
  CORRECTIVE_ACTION_NONE = $00000000;
  CORRECTIVE_ACTION_GET_SUGGESTIONS = $00000001;
  CORRECTIVE_ACTION_REPLACE = $00000002;
  CORRECTIVE_ACTION_DELETE = $00000003;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ISpellCheckerFactory = interface;
  IUserDictionariesRegistrar = interface;
  IEnumString = interface;
  ISpellChecker = interface;
  IEnumSpellingError = interface;
  ISpellingError = interface;
  ISpellCheckerChangedEventHandler = interface;
  IOptionDescription = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  SpellCheckerFactory = ISpellCheckerFactory;


// *********************************************************************//
// Interface: ISpellCheckerFactory
// Flags:     (0)
// GUID:      {8E018A9D-2415-4677-BF08-794EA61F94BB}
// *********************************************************************//
  ISpellCheckerFactory = interface(IUnknown)
    ['{8E018A9D-2415-4677-BF08-794EA61F94BB}']
    function Get_SupportedLanguages(out value: IEnumString): HResult; stdcall;
    function IsSupported(languageTag: PWideChar; out value: Integer): HResult; stdcall;
    function CreateSpellChecker(languageTag: PWideChar; out value: ISpellChecker): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IUserDictionariesRegistrar
// Flags:     (0)
// GUID:      {AA176B85-0E12-4844-8E1A-EEF1DA77F586}
// *********************************************************************//
  IUserDictionariesRegistrar = interface(IUnknown)
    ['{AA176B85-0E12-4844-8E1A-EEF1DA77F586}']
    function RegisterUserDictionary(dictionaryPath: PWideChar; languageTag: PWideChar): HResult; stdcall;
    function UnregisterUserDictionary(dictionaryPath: PWideChar; languageTag: PWideChar): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IEnumString
// Flags:     (0)
// GUID:      {00000101-0000-0000-C000-000000000046}
// *********************************************************************//
  IEnumString = interface(IUnknown)
    ['{00000101-0000-0000-C000-000000000046}']
    function RemoteNext(celt: LongWord; out rgelt: PWideChar; out pceltFetched: LongWord): HResult; stdcall;
    function Skip(celt: LongWord): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumString): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISpellChecker
// Flags:     (0)
// GUID:      {B6FD0B71-E2BC-4653-8D05-F197E412770B}
// *********************************************************************//
  ISpellChecker = interface(IUnknown)
    ['{B6FD0B71-E2BC-4653-8D05-F197E412770B}']
    function Get_languageTag(out value: PWideChar): HResult; stdcall;
    function Check(text: PWideChar; out value: IEnumSpellingError): HResult; stdcall;
    function Suggest(word: PWideChar; out value: IEnumString): HResult; stdcall;
    function Add(word: PWideChar): HResult; stdcall;
    function Ignore(word: PWideChar): HResult; stdcall;
    function AutoCorrect(from: PWideChar; to_: PWideChar): HResult; stdcall;
    function GetOptionValue(optionId: PWideChar; out value: Byte): HResult; stdcall;
    function Get_OptionIds(out value: IEnumString): HResult; stdcall;
    function Get_Id(out value: PWideChar): HResult; stdcall;
    function Get_LocalizedName(out value: PWideChar): HResult; stdcall;
    function add_SpellCheckerChanged(const handler: ISpellCheckerChangedEventHandler; 
                                     out eventCookie: LongWord): HResult; stdcall;
    function remove_SpellCheckerChanged(eventCookie: LongWord): HResult; stdcall;
    function GetOptionDescription(optionId: PWideChar; out value: IOptionDescription): HResult; stdcall;
    function ComprehensiveCheck(text: PWideChar; out value: IEnumSpellingError): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IEnumSpellingError
// Flags:     (0)
// GUID:      {803E3BD4-2828-4410-8290-418D1D73C762}
// *********************************************************************//
  IEnumSpellingError = interface(IUnknown)
    ['{803E3BD4-2828-4410-8290-418D1D73C762}']
    function Next(out value: ISpellingError): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISpellingError
// Flags:     (0)
// GUID:      {B7C82D61-FBE8-4B47-9B27-6C0D2E0DE0A3}
// *********************************************************************//
  ISpellingError = interface(IUnknown)
    ['{B7C82D61-FBE8-4B47-9B27-6C0D2E0DE0A3}']
    function Get_StartIndex(out value: LongWord): HResult; stdcall;
    function Get_Length(out value: LongWord): HResult; stdcall;
    function Get_CorrectiveAction(out value: CORRECTIVE_ACTION): HResult; stdcall;
    function Get_Replacement(out value: PWideChar): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ISpellCheckerChangedEventHandler
// Flags:     (0)
// GUID:      {0B83A5B0-792F-4EAB-9799-ACF52C5ED08A}
// *********************************************************************//
  ISpellCheckerChangedEventHandler = interface(IUnknown)
    ['{0B83A5B0-792F-4EAB-9799-ACF52C5ED08A}']
    function Invoke(const sender: ISpellChecker): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IOptionDescription
// Flags:     (0)
// GUID:      {432E5F85-35CF-4606-A801-6F70277E1D7A}
// *********************************************************************//
  IOptionDescription = interface(IUnknown)
    ['{432E5F85-35CF-4606-A801-6F70277E1D7A}']
    function Get_Id(out value: PWideChar): HResult; stdcall;
    function Get_Heading(out value: PWideChar): HResult; stdcall;
    function Get_Description(out value: PWideChar): HResult; stdcall;
    function Get_Labels(out value: IEnumString): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoSpellCheckerFactory provides a Create and CreateRemote method to          
// create instances of the default interface ISpellCheckerFactory exposed by              
// the CoClass SpellCheckerFactory. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSpellCheckerFactory = class
    class function Create: ISpellCheckerFactory;
    class function CreateRemote(const MachineName: string): ISpellCheckerFactory;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSpellCheckerFactory
// Help String      : 
// Default Interface: ISpellCheckerFactory
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TSpellCheckerFactory = class(TOleServer)
  private
    FIntf: ISpellCheckerFactory;
    function GetDefaultInterface: ISpellCheckerFactory;
  protected
    procedure InitServerData; override;
    function Get_SupportedLanguages(out value: IEnumString): HResult;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISpellCheckerFactory);
    procedure Disconnect; override;
    function IsSupported(languageTag: PWideChar; out value: Integer): HResult;
    function CreateSpellChecker(languageTag: PWideChar; out value: ISpellChecker): HResult;
    property DefaultInterface: ISpellCheckerFactory read GetDefaultInterface;
  published
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses System.Win.ComObj;

class function CoSpellCheckerFactory.Create: ISpellCheckerFactory;
begin
  Result := CreateComObject(CLASS_SpellCheckerFactory) as ISpellCheckerFactory;
end;

class function CoSpellCheckerFactory.CreateRemote(const MachineName: string): ISpellCheckerFactory;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SpellCheckerFactory) as ISpellCheckerFactory;
end;

procedure TSpellCheckerFactory.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{7AB36653-1796-484B-BDFA-E74F1DB7C1DC}';
    IntfIID:   '{8E018A9D-2415-4677-BF08-794EA61F94BB}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSpellCheckerFactory.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as ISpellCheckerFactory;
  end;
end;

procedure TSpellCheckerFactory.ConnectTo(svrIntf: ISpellCheckerFactory);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TSpellCheckerFactory.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TSpellCheckerFactory.GetDefaultInterface: ISpellCheckerFactory;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TSpellCheckerFactory.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TSpellCheckerFactory.Destroy;
begin
  inherited Destroy;
end;

function TSpellCheckerFactory.Get_SupportedLanguages(out value: IEnumString): HResult;
begin
  Result := DefaultInterface.Get_SupportedLanguages(value);
end;

function TSpellCheckerFactory.IsSupported(languageTag: PWideChar; out value: Integer): HResult;
begin
  Result := DefaultInterface.IsSupported(languageTag, value);
end;

function TSpellCheckerFactory.CreateSpellChecker(languageTag: PWideChar; out value: ISpellChecker): HResult;
begin
  Result := DefaultInterface.CreateSpellChecker(languageTag, value);
end;

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TSpellCheckerFactory]);
end;

end.
