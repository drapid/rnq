unit aesr;

(*************************************************************************

 DESCRIPTION   :  Cryptographic pseudo random number generator based on
                  AES CTR mode with 128 bit key

 REQUIREMENTS  :  TP5-7, D1-D7/D9-D10/D12, FPC, VP, WDOSX

 EXTERNAL DATA :  ---

 MEMORY USAGE  :  ---

 DISPLAY MODE  :  ---

 REFERENCES    :  [1] http://csrc.nist.gov/publications/nistpubs/800-38a/sp800-38a.pdf

 REMARKS       :  1. The RECOMMENDED init procedure is aesr_inita, this
                     covers the full 128+128 bits key/IV range
                  2. aesr_init uses only max 32 independent seed bits    !!!!
                  3. aesr_init0 may use even less than 32 bits           !!!!
                     (depends on compiler initialisation of randseed)    !!!!

 Version  Date      Author      Modification
 -------  --------  -------     ------------------------------------------
 0.10     05.08.05  W.Ehrhardt  Initial version based on Taus88 layout
 0.11     22.06.08  we          Make IncMSBFull work with FPC -dDebug
 0.12     05.11.08  we          aesr_dword function
 0.13     14.06.12  we          Fix bug in _read for trailing max 3 bytes
**************************************************************************)


(*-------------------------------------------------------------------------
 (C) Copyright 2005-2012 Wolfgang Ehrhardt

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


interface

{$i std.inc}

{$ifdef BIT16}
  {$N+}
{$endif}

uses
  BTypes, aes_type;

type
  aesr_sarr = array[0..7] of longint;  {Seed array: key/IV}

  aesr_ctx  = record
                cc: TAESContext;  {aes cipher context}
                nr: longint;      {next random result}
                ib: integer;      {index into buffer }
              end;

procedure aesr_inita(var ctx: aesr_ctx; {$ifdef CONST} const {$else} var {$endif} SArr: aesr_sarr);
  {-Init all context variables with separate seeds}

procedure aesr_init(var ctx: aesr_ctx; seed: longint);
  {-Init context from seed}

procedure aesr_init0(var ctx: aesr_ctx);
  {-Init context from randseed}

procedure aesr_next(var ctx: aesr_ctx);
  {-Next step of PRNG}

procedure aesr_read(var ctx: aesr_ctx; dest: pointer; len: longint);
  {-Read len bytes from the PRNG to dest}

function  aesr_long(var ctx: aesr_ctx): longint;
  {-Next random positive longint}

function  aesr_dword(var ctx: aesr_ctx): {$ifdef HAS_CARD32}cardinal{$else}longint{$endif};
  {-Next 32 bit random dword (cardinal or longint)}

function  aesr_word(var ctx: aesr_ctx): word;
  {-Next random word}

function  aesr_double(var ctx: aesr_ctx): double;
  {-Next random double [0..1) with 32 bit precision}

function  aesr_double53(var ctx: aesr_ctx): double;
  {-Next random double in [0..1) with 53 bit precision}

function  aesr_selftest: boolean;
  {-Simple self-test of PRNG}


implementation


uses aes_base, aes_encr;


{---------------------------------------------------------------------------}
procedure AES_IncMSBFull(var CTR: TAESBlock);
  {-Increment CTR[15]..CTR[0]}
var
  j: integer;
begin
  for j:=15 downto 0 do begin
    if CTR[j]=$FF then CTR[j] := 0
    else begin
      inc(CTR[j]);
      exit;
    end;
  end;
end;


{---------------------------------------------------------------------------}
procedure aesr_next(var ctx: aesr_ctx);
  {-Next step of PRNG}
begin
  with ctx do begin
    if ib>3 then begin
      {if buf exceeded generate new by encryping CTR into buf}
      AES_Encrypt(ctx.cc, ctx.cc.IV, ctx.cc.buf);
      {increment CTR}
      AES_IncMSBFull(ctx.cc.IV);
      {reset buf index}
      ib := 0;
    end;
    nr := TWA4(cc.buf)[ib];
    inc(ib);
  end;
end;


{---------------------------------------------------------------------------}
procedure aesr_inita(var ctx: aesr_ctx; {$ifdef CONST} const {$else} var {$endif} SArr: aesr_sarr);
  {-Init all context variables with separate seeds}
begin
  {AES_Init_Encr should never fail here! Feel free to return error code.}
  if AES_Init_Encr(SArr, 128, ctx.cc)<>0 then halt;
  ctx.cc.IV := PAESBlock(@SArr[4])^;
  ctx.ib := 4;
end;


{---------------------------------------------------------------------------}
procedure aesr_init(var ctx: aesr_ctx; seed: longint);
  {-Init context from seed}
const
  M=69069;
  A=1;
var
  SArr: aesr_sarr;
  i: integer;
begin
  SArr[0] := seed;
  {Use simple LCG for next seeds}
  for i:=1 to 7 do SArr[i] := M*SArr[i-1] + A;
  aesr_inita(ctx,SArr);
end;


{---------------------------------------------------------------------------}
procedure aesr_init0(var ctx: aesr_ctx);
  {-Init context from randseed}
begin
  aesr_init(ctx, randseed);
end;


{---------------------------------------------------------------------------}
function aesr_long(var ctx: aesr_ctx): longint;
  {-Next random positive longint}
begin
  aesr_next(ctx);
  {make positive, highest bit=0}
  aesr_long := ctx.nr shr 1;
end;


{---------------------------------------------------------------------------}
function aesr_dword(var ctx: aesr_ctx): {$ifdef HAS_CARD32}cardinal{$else}longint{$endif};
  {-Next 32 bit random dword (cardinal or longint)}
begin
  aesr_next(ctx);
  {$ifdef HAS_CARD32}
    aesr_dword := cardinal(ctx.nr);
  {$else}
    aesr_dword := ctx.nr;
  {$endif}
end;


{---------------------------------------------------------------------------}
function aesr_word(var ctx: aesr_ctx): word;
  {-Next random word}
type
  TwoWords = packed record
               L,H: word
             end;
begin
  aesr_next(ctx);
  aesr_word := TwoWords(ctx.nr).H;
end;


{---------------------------------------------------------------------------}
function aesr_double(var ctx: aesr_ctx): double;
  {-Next random double [0..1) with 32 bit precision}
begin
  aesr_next(ctx);
  aesr_double := (ctx.nr + 2147483648.0) / 4294967296.0;
end;


{---------------------------------------------------------------------------}
function aesr_double53(var ctx: aesr_ctx): double;
  {-Next random double in [0..1) with 53 bit precision}
var
  hb,lb: longint;
begin
  aesr_next(ctx);
  hb := ctx.nr shr 5;
  aesr_next(ctx);
  lb := ctx.nr shr 6;
  aesr_double53 := (hb*67108864.0+lb)/9007199254740992.0;
end;


{---------------------------------------------------------------------------}
procedure aesr_read(var ctx: aesr_ctx; dest: pointer; len: longint);
  {-Read len bytes from the PRNG to dest}
type
  plong = ^longint;
begin
  while len>3 do begin
    aesr_next(ctx);
    plong(dest)^ := ctx.nr;
    inc(Ptr2Inc(dest),4);
    dec(len, 4);
  end;
  if len>0 then begin
    aesr_next(ctx);
    move(ctx.nr, dest^, len and 3);
  end;
end;


{---------------------------------------------------------------------------}
function aesr_selftest: boolean;
  {-Simple self-test of PRNG}
var
  ctx: aesr_ctx;
  i: integer;
{Data from [1]: F.5.1 CTR-AES128.Encrypt}
const
   keyiv : array[0..31] of byte = ($2b,$7e,$15,$16,$28,$ae,$d2,$a6,
                                   $ab,$f7,$15,$88,$09,$cf,$4f,$3c,
                                   $f0,$f1,$f2,$f3,$f4,$f5,$f6,$f7,
                                   $f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff);

{ plain  : array[0..63] of byte = ($6b,$c1,$be,$e2,$2e,$40,$9f,$96,
                                   $e9,$3d,$7e,$11,$73,$93,$17,$2a,
                                   $ae,$2d,$8a,$57,$1e,$03,$ac,$9c,
                                   $9e,$b7,$6f,$ac,$45,$af,$8e,$51,
                                   $30,$c8,$1c,$46,$a3,$5c,$e4,$11,
                                   $e5,$fb,$c1,$19,$1a,$0a,$52,$ef,
                                   $f6,$9f,$24,$45,$df,$4f,$9b,$17,
                                   $ad,$2b,$41,$7b,$e6,$6c,$37,$10);

     ct1 : array[0..63] of byte = ($87,$4d,$61,$91,$b6,$20,$e3,$26,
                                   $1b,$ef,$68,$64,$99,$0d,$b6,$ce,
                                   $98,$06,$f6,$6b,$79,$70,$fd,$ff,
                                   $86,$17,$18,$7b,$b9,$ff,$fd,$ff,
                                   $5a,$e4,$df,$3e,$db,$d5,$d3,$5e,
                                   $5b,$4f,$09,$02,$0d,$b0,$3e,$ab,
                                   $1e,$03,$1d,$da,$2f,$be,$03,$d1,
                                   $79,$21,$70,$a0,$f3,$00,$9c,$ee);}
{last four bytes of plain xor ct1 as longint}
const
  xorlast = longint($10376ce6) xor longint($ee9c00f3);
begin
  aesr_inita(ctx,aesr_sarr(keyiv));
  {Get 16 x 32 Bits}
  for i:=1 to 16 do aesr_next(ctx);
  aesr_selftest := ctx.nr=xorlast;
end;

end.
