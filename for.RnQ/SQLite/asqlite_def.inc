{

Aducom Software SQLite components
Copyright (C) 2003-2006 by Aducom Software
Albert Drent
a.drent@aducom.com
for questions please register on the forum on www.aducom.com/sqlite
}

{$IFDEF VER125}{C4}{$B-}{$X+}{$T-}{$H+}{$ENDIF}
{$IFDEF VER110}{C3}{$B-}{$X+}{$T-}{$H+}{$ENDIF}
{$IFDEF VER93}{C1}{$B-}{$X+}{$T-}{$H+}{$ENDIF}

 {$if CompilerVersion >= 23}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_D4PLUS}
  {$DEFINE ASQLite_D5PLUS}
  {$DEFINE ASQLite_D6PLUS}
  {$DEFINE ASQLite_D7PLUS}
  {$DEFINE ASQLite_D2005PLUS}
  {$DEFINE ASQLite_D2006PLUS}
  {$DEFINE ASQLite_D2007PLUS}
  {$DEFINE ASQLite_D2009PLUS}
  {$DEFINE ASQLite_D2010PLUS}
  {DELPHI10}
  {$B-}{$X+}{$T-}{$H+}
  {$DEFINE ASQLite_DYNARRAY}
 {$IFEND }

{$IFDEF VER210}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_D4PLUS}
  {$DEFINE ASQLite_D5PLUS}
  {$DEFINE ASQLite_D6PLUS}
  {$DEFINE ASQLite_D7PLUS}
  {$DEFINE ASQLite_D2005PLUS}
  {$DEFINE ASQLite_D2006PLUS}
  {$DEFINE ASQLite_D2007PLUS}
  {$DEFINE ASQLite_D2009PLUS}
  {$DEFINE ASQLite_D2010PLUS}
  {DELPHI10}
  {$B-}{$X+}{$T-}{$H+}
  {$DEFINE ASQLite_DYNARRAY}
{$ENDIF}
{$IFDEF VER200}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_D4PLUS}
  {$DEFINE ASQLite_D5PLUS}
  {$DEFINE ASQLite_D6PLUS}
  {$DEFINE ASQLite_D7PLUS}
  {$DEFINE ASQLite_D2005PLUS}
  {$DEFINE ASQLite_D2006PLUS}
  {$DEFINE ASQLite_D2007PLUS}
  {$DEFINE ASQLite_D2009PLUS}
  {DELPHI10}
  {$B-}{$X+}{$T-}{$H+}
  {$DEFINE ASQLite_DYNARRAY}
{$ENDIF}
{$IFDEF VER190}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_D4PLUS}
  {$DEFINE ASQLite_D5PLUS}
  {$DEFINE ASQLite_D6PLUS}
  {$DEFINE ASQLite_D7PLUS}
  {$DEFINE ASQLite_D2005PLUS}
  {$DEFINE ASQLite_D2006PLUS}
  {$DEFINE ASQLite_D2007PLUS}
  {DELPHI10}
  {$B-}{$X+}{$T-}{$H+}
  {$DEFINE ASQLite_DYNARRAY}
{$ENDIF}
{$IFDEF VER180}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_D4PLUS}
  {$DEFINE ASQLite_D5PLUS}
  {$DEFINE ASQLite_D6PLUS}
  {$DEFINE ASQLite_D7PLUS}
  {$DEFINE ASQLite_D2005PLUS}
  {$DEFINE ASQLite_D2006PLUS}
  {DELPHI10}
  {$B-}{$X+}{$T-}{$H+}
  {$DEFINE ASQLite_DYNARRAY}
{$ENDIF}
{$IFDEF VER170}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_D4PLUS}
  {$DEFINE ASQLite_D5PLUS}
  {$DEFINE ASQLite_D6PLUS}
  {$DEFINE ASQLite_D7PLUS}
  {$DEFINE ASQLite_D2005PLUS}
  {DELPHI9}
  {$B-}{$X+}{$T-}{$H+}
  {$DEFINE ASQLite_DYNARRAY}
{$ENDIF}
{$IFDEF VER150}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_D4PLUS}
  {$DEFINE ASQLite_D5PLUS}
  {$DEFINE ASQLite_D6PLUS}
  {$DEFINE ASQLite_D7PLUS}
  {DELPHI7}
  {$B-}{$X+}{$T-}{$H+}                                   
  {$DEFINE ASQLite_DYNARRAY}
{$ENDIF}
{$IFDEF VER140}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_D4PLUS}
  {$DEFINE ASQLite_D5PLUS}
  {$DEFINE ASQLite_D6PLUS}
  {DELPHI6}
  {$B-}{$X+}{$T-}{$H+}
  {$DEFINE ASQLite_DYNARRAY}
{$ENDIF}
{$IFDEF VER130}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_D4PLUS}
  {$DEFINE ASQLite_D5PLUS}
  {DELPHI5}
  {$DEFINE ASQLite_DYNARRAY}
  {$B-}{$X+}{$T-}{$H+}
{$ENDIF}
{$IFDEF VER120}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_D4PLUS}
  {DELPHI4}
  {$DEFINE ASQLite_DYNARRAY}
  {$B-}{$X+}{$T-}{$H+}
{$ENDIF}
{$IFDEF VER100}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_D3PLUS}
  {$DEFINE ASQLite_NOINT64}
  {DELPHI3}
  {$B-}{$X+}{$T-}{$H+}
{$ENDIF}
{$IFDEF VER90}
  {$DEFINE ASQLite_D2PLUS}
  {$DEFINE ASQLite_NOINT64}
  {$DEFINE ASQLite_NOWIDESTRING}
  {DELPHI2}
  {$B-}{$X+}{$T-}{$H+}
{$ENDIF}

{$IFDEF LINUX}{KYLIX}{$DEFINE CLX}{$ENDIF}
{$IFDEF FPC}{$H+}{$MODE DELPHI}{$ENDIF}
{$IFDEF ASQLite_D4PLUS}{$DEFINE ASQLite_HAVEVARIANT}{$ENDIF}
{$R-}{$Q-}

{$IFDEF CLX}
{$DEFINE ASQLite_NOIDISPATCH} // not implemented
{$ENDIF}


// To enable debugging remove the dot. Do NOT forget to re-insert before
// deploying to production since this feature will slow down this component
// significantly
{.$DEFINE DEBUG_ENABLED } // Enables Debug information
 {.$DEFINE DEBUG_VERY_LOUD}
 {.$DEFINE DEBUG_LOUD}


// Disable this for ignoring IProvider interface (for D4)
{$DEFINE IPROVIDER}


// enable this if you want to link the SQLite library statically. (No need for dll)
// DON'T FORGET TO APPLY CORRECT OBJ VERSION IN THIS SOURCE ON LINE {$L 'OBJ\SQLite<<somerversion>>.obj'}
{.$DEFINE SQLite_Static}
