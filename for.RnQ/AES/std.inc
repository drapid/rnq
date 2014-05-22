(*************************************************************************

 DESCRIPTION     :  Standard definitions and options

 REQUIREMENTS    :  TP5-7, D1-D7/D9-D12, FPC, VP, (TPW1.0/1.5,BCB3/4)

 Version  Date      Author      Modification
 -------  --------  -------     ------------------------------------------
 1.00     05.10.03  W.Ehrhardt  Initial version
 1.01     05.10.03  we          X_OPT, removed TP4
 1.02     30.10.03  we          WINCRT
 1.03     09.12.03  we          {$R+,S+} {$ifdef debug}
 1.04     26.12.03  we          VP: {&Optimise+,SmartLink+,Speed+} ifndef debug
 1.05     28.12.03  we          DELPHI = Delphi32 (no Delphi 1!)
 1.06     12.04.04  we          Delphi 7
 1.07     26.09.04  we          Record starting values of important options
 1.08     10.10.04  we          RESULT for Result pseudo variable
 1.09     02.01.05  we          BIT16: default $F-
 1.10     26.02.05  we          StrictLong
 1.11     05.05.05  we          D9 aka Delphi 2005
 1.12     22.05.05  we          StrictLong for FPC 2.0
 1.13     27.05.05  we          {$goto on} for FPC
 1.14     27.05.05  we          moved {$goto on} to default settings
 1.15     29.05.05  we          HAS_INT64, HAS_MSG, _STD_INC_
 1.16     06.08.05  we          J_OPT, N_OPT, HAS_INLINE
 1.17     17.08.05  we          HAS_ASSERT
 1.18     08.11.05  we          APPCONS, partial TMT,TPW15 support
 1.19     20.11.05  we          Default option {$B-}
 1.20     08.01.06  we          ABSTRACT/DEFAULT
 1.21     08.02.06  we          Fix Scanhelp quirk
 1.22     11.02.06  we          VER5X
 1.23     15.04.06  we          HAS_XTYPES
 1.24     08.05.06  we          D10 aka Delphi 2006
 1.25     25.05.06  we          Define RESULT if FPC_OBJFPC is defined
 1.26     08.09.06  we          Define RESULT/DEFAULT if FPC_DELPHI is defined
 1.27     14.11.06  we          HAS_ASSERT for FPC VER1 and VER2
 1.28     28.11.06  we          HAS_UNSAFE, $warn SYMBOL_../UNSAFE_.. OFF
 1.29     25.05.07  we          D11 aka Delphi 2007, FPC2.1.4
 1.30     23.06.07  we          FPC_ProcVar: Helper for procedure variables
 1.31     18.09.07  we          HAS_INLINE for FPC VER2
 1.32     04.10.07  we          FPC Intel ASMmode only if CPUI386 is defined
 1.33     22.11.07  we          Record value of $X option, undef RESULT if $X-
 1.34     19.05.08  we          HAS_UINT64
 1.35     21.06.08  we          V7PLUS, HAS_UINT64 for FPC VER2_2
 1.36     07.09.08  we          HAS_CARD32
 1.37     21.11.08  we          D12 aka D2009
 1.38     19.02.09  we          TPW 1.0 adjustments
 1.39     05.07.09  we          D12Plus
 1.40     17.10.09  we          BASM (BASM16 or Bit32)
 1.41     21.10.09  we          HAS_OVERLOAD
 1.42     07.04.10  we          HAS_DENORM_LIT (Denormalized extended literals, e.g. -1.23e-4942)
 1.43     20.06.10  we          D14 (VER210)

**************************************************************************)


(*-------------------------------------------------------------------------
 (C) Copyright 2002-2010 Wolfgang Ehrhardt

 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising from
 the use of this software.

 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software in
    a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------*)

{$ifndef _STD_INC_}

{$define _STD_INC_}      {include STD.INC only once}

{.$undef BIT16}          {16 Bit code, Pascal / D1}
{.$undef BIT32}          {32 Bit code}
{.$undef DELPHI}         {Delphi2+ and BCB++}
{.$undef G_OPT}          {G+ option support}
{.$undef D4PLUS}         {Delphi 4 or higher}
{.$undef BASM16}         {16 Bit BASM}
{.$undef LoadArgs}       {Register params}
{.$undef WINCRT}         {Use WinCRT for console}
{.$undef RESULT}         {Result pseudo variable}
{.$undef StrictLong}     {Warning for longint const with MS bit}
{.$undef HAS_INT64}      { int64 integer type available}
{.$undef HAS_UINT64}     {uint64 integer type available}
{.$undef HAS_CARD32}     {Has 32 bit cardinal}
{.$undef HAS_MSG}        {Has message directive}
{.$undef HAS_INLINE}     {Has inline procs/funcs (D9)}
{.$undef ABSTRACT}       {Has abstract methods}
{.$undef DEFAULT}        {Support default parameters}
{.$undef VER5X}          {TP5 or TP55}
{.$undef HAS_XTYPES}     {Xtra types in system: pByte, pLongint etc}
{.$undef HAS_UNSAFE}     {UNSAFE warnings}
{.$undef APPCONS}        {Needs "Apptype console" for console application}
{.$undef FPC_ProcVar}    {FPC handling of @ and proc variables}
{.$undef D12PLUS}        {Delphi 12 or higher}
{.$undef HAS_OVERLOAD}   {Overloading of procedures and functions}
{.$undef HAS_DENORM_LIT} {Denormalized (extended) literals, e.g. -1.23e-4942}

{$define CONST}     {const in proc declaration}
{$define Q_OPT}     {Q- option support}
{$define X_OPT}     {X+ option support}
{$define N_OPT}     {N+ option support}
{$define BASM}      {BASM16 or BIT32}
{$define V7PLUS}    {TP7 or higher}


{$ifdef VER10}        {TPW 1.0}
  {$define BIT16}
  {$define BASM16}
  {$define WINCRT}
  {$define G_OPT}
  {$undef  CONST}
  {$undef  Q_OPT}
  {$undef  V7PLUS}
{$endif}

{$ifdef VER15}        {TPW 1.5}
  {$define BIT16}
  {$define BASM16}
  {$define WINCRT}
  {$define G_OPT}
  {$undef  CONST}
  {$undef  Q_OPT}
  {$undef  V7PLUS}
{$endif}

{$ifdef VER50 }
  {$define BIT16}
  {$define VER5X}
  {$undef  BASM}
  {$undef  CONST}
  {$undef  Q_OPT}
  {$undef  X_OPT}
  {$undef  V7PLUS}
{$endif}

{$ifdef VER55 }
  {$define BIT16}
  {$define VER5X}
  {$undef  BASM}
  {$undef  CONST}
  {$undef  Q_OPT}
  {$undef  X_OPT}
  {$undef  V7PLUS}
{$endif}

{$ifdef VER60 }
  {$define BIT16}
  {$undef  CONST}
  {$undef  Q_OPT}
  {$define G_OPT}
  {$define BASM16}
  {$undef  V7PLUS}
{$endif}

{$ifdef VER70 }
  {$define BIT16}
  {$define G_OPT}
  {$define BASM16}
{$endif}

{$ifdef VER80}
  {.$define DELPHI}   {D1} {*we V1.05}
  {$define BIT16 }
  {$define G_OPT }
  {$define BASM16}
  {$define WINCRT}
  {$define RESULT}
{$endif}

{$ifdef VER90 }
  {$define DELPHI}  {D2}
{$endif}

{$ifdef VER93 }
  {$define DELPHI}  {BCB++1}
{$endif}

{$ifdef VER100}
  {$define DELPHI}  {D3}
  {$define HAS_ASSERT}
{$endif}

{$ifdef VER110}
  {$define DELPHI}  {BCB3}
{$endif}

{$ifdef VER120}
  {$define DELPHI}  {D4}
  {$define D4PLUS}
{$endif}

{$ifdef VER125}
  {$define DELPHI}  {BCB4}
  {$define D4PLUS}
{$endif}

{$ifdef VER130}
  {$define DELPHI}  {D5}
  {$define D4PLUS}
{$endif}

{$ifdef VER140}
  {$define DELPHI}  {D6}
  {$define D4PLUS}
{$endif}

{$ifdef VER150}
  {$define DELPHI}  {D7}
  {$define D4PLUS}
  {$define HAS_UNSAFE}
  {$define HAS_UINT64}
{$endif}

{$ifdef VER170}
  {$define DELPHI}  {D9}
  {$define D4PLUS}
  {$define HAS_INLINE}
  {$define HAS_UNSAFE}
  {$define HAS_UINT64}
{$endif}

{$ifdef VER180}
  {$define DELPHI}  {D10, D11 ifdef VER185}
  {$define D4PLUS}
  {$define HAS_INLINE}
  {$define HAS_UNSAFE}
  {$define HAS_UINT64}
{$endif}

{$ifdef VER200}
  {$define DELPHI}  {D12}
  {$define D4PLUS}
  {$define D12PLUS}
  {$define HAS_INLINE}
  {$define HAS_UNSAFE}
  {$define HAS_UINT64}
{$endif}

{$ifdef VER210}
  {$define DELPHI}  {D14}
  {$define D4PLUS}
  {$define D12PLUS}
  {$define HAS_INLINE}
  {$define HAS_UNSAFE}
  {$define HAS_UINT64}
{$endif}

{$ifdef VER220}
  {$define DELPHI}  {DXE}
  {$define D4PLUS}
  {$define D12PLUS}
  {$define HAS_INLINE}
  {$define HAS_UNSAFE}
  {$define HAS_UINT64}
{$endif}

{$if CompilerVersion >= 21} // By Rapid D
  {$define DELPHI}  {DXE?}
  {$define D4PLUS}
  {$define D12PLUS}
  {$define HAS_INLINE}
  {$define HAS_UNSAFE}
  {$define HAS_UINT64}
{$ifend}


{$ifdef CONDITIONALEXPRESSIONS}  {D6+}
  {$ifndef D4PLUS}
    {$define D4PLUS}
  {$endif}
  {$define HAS_MSG}
  {$define HAS_XTYPES}
{$endif}

{$ifdef VER70}
  {$ifdef windows}
    {$define WINCRT}
  {$endif}
{$endif}

{$ifdef VirtualPascal}
  {$define G_OPT}
  {$define RESULT}
  {$define LoadArgs}
{$endif}

{$ifdef WIN32}
  {$define J_OPT}
{$endif}

{$ifdef FPC}
  {$define FPC_ProcVar}
  {$define ABSTRACT}
  {$define HAS_XTYPES}
  {$define HAS_OVERLOAD}
  {$undef N_OPT}
  {$ifdef VER1}
    {$undef  J_OPT}
    {$define HAS_INT64}
    {$define HAS_CARD32}
    {$define HAS_MSG}
    {$define HAS_ASSERT}
    {$ifndef VER1_0}
      {FPC 1.9.x}
      {$define StrictLong}
    {$else}
      {$define LoadArgs}
    {$endif}
  {$endif}
  {$ifdef VER2}
    {$define HAS_ASSERT}
    {$define HAS_INT64}
    {$define HAS_CARD32}
    {$define HAS_MSG}
    {$define HAS_INLINE}   {Remember to use -Si}
    {$define StrictLong}
    {$ifdef FPC_OBJFPC}
      {$define DEFAULT}
    {$endif}
    {$ifdef FPC_DELPHI}
      {$define DEFAULT}
    {$endif}
    {$ifdef VER2_2}
      {$define HAS_UINT64}
      {$define HAS_DENORM_LIT}
    {$endif}
  {$endif}
  {Note: Mode detection does not work for -Sxxx and version < 2.0.2}
  {$ifdef FPC_OBJFPC}
    {$define RESULT}
  {$endif}
  {$ifdef FPC_DELPHI}
    {$define RESULT}
    {$undef FPC_ProcVar}
  {$endif}
  {$ifdef FPC_TP}
    {$undef FPC_ProcVar}
  {$endif}
  {$ifdef FPC_GPC}
    {$undef FPC_ProcVar}
  {$endif}
{$endif}

{$ifdef __TMT__}
  {$undef N_OPT}
  {$define RESULT}
  {$define HAS_INT64}
  {$define LoadArgs}
  {$ifdef __WIN32__}
    {$define WIN32}
  {$endif}
{$endif}

{$ifndef BIT16}
  {$define BIT32}
{$endif}



{$ifdef Delphi}
  {$define RESULT}
  {$define ABSTRACT}
  {$define HAS_DENORM_LIT}
{$endif}

{$ifdef D4Plus}
  {$define HAS_INT64}
  {$define HAS_CARD32}
  {$define StrictLong}
  {$define HAS_ASSERT}
  {$define DEFAULT}
  {$define HAS_OVERLOAD}
{$endif}

{$ifdef WIN32}
  {$ifndef VirtualPascal}
    {$define APPCONS}
  {$endif}
{$endif}


{-- Default options --}

{$ifndef FPC}
  {$B-} {short-circuit boolean expression evaluation, FPC has always B-!}
{$endif}

{$ifdef FPC}
  {$ifdef CPUI386}
    {$ASMmode intel}
  {$endif}
  {$goto on}
{$endif}

{$ifdef VirtualPascal}
  {$ifndef debug}
    {&Optimise+,SmartLink+,Speed+}
  {$endif}
{$endif}

{$ifdef G_OPT}
  {$G+}
{$endif}

{$ifdef Q_OPT}
  {Most Crypto and CRC/Hash units need Q-, define Q+ locally if needed}
  {$Q-}
{$endif}

{$ifdef debug}
  {$R+,S+}  {Note: D9+ needs $R- for StrictLong setting!}
{$else}
  {$R-,S-}
{$endif}

{$ifdef BIT16}
  {$F-}
{$endif}

{-- Record the starting values of important local options --}
{$ifopt A+} {$define Align_on}           {$endif}
{$ifopt B+} {$define BoolEval_on}        {$endif}
{$ifopt D+} {$define DebugInfo_on}       {$endif}
{$ifopt I+} {$define IOChecks_on}        {$endif}
{$ifopt R+} {$define RangeChecks_on}     {$endif}
{$ifopt V+} {$define VarStringChecks_on} {$endif}


{$ifdef Q_OPT}
{$ifopt P+} {$define OpenStrings_on}     {$endif}
{$ifopt Q+} {$define OverflowChecks_on}  {$endif}
{$endif}

{-- Note that X option is GLOBAL --}
{$ifdef X_OPT}
{$ifopt X+} {$define ExtendedSyntax_on}  {$endif}
{$ifopt X-} {$undef  RESULT}             {$endif}
{$endif}

{$ifdef CONDITIONALEXPRESSIONS}
  {$warn SYMBOL_PLATFORM OFF}
  {$warn SYMBOL_DEPRECATED OFF}
  {$warn SYMBOL_LIBRARY OFF}
  {$warn UNIT_DEPRECATED OFF}
  {$warn UNIT_LIBRARY OFF}
  {$warn UNIT_PLATFORM OFF}
  {$ifdef HAS_UNSAFE}
    {$warn UNSAFE_TYPE OFF}
    {$warn UNSAFE_CODE OFF}
    {$warn UNSAFE_CAST OFF}
  {$endif}
{$endif}

{$else}

  {$ifdef HAS_MSG}
    {$message 'std.inc included more than once'}
  {$endif}

{$endif}

