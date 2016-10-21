{
Copyright (C) 2002-2004  Massimo Melina (www.rejetto.com)

This file is part of &RQ.

    &RQ is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    &RQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with &RQ; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
unit incapsulate;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  sysutils, RDGlobal;

type
  Tincapsulate=class
    str: RawByteString;
    int: integer;
    dt: TdateTime;
    bool: boolean;
    obj: Tobject;
    what: set of (I_str, I_int, I_dt, I_bool, I_obj);
    constructor aString(const s_: RawByteString);
    constructor anInt(i_: integer);
    constructor aDatetime(dt_: Tdatetime);
    function  toString: RawByteString; Reintroduce;
    constructor fromString(s: RawByteString); Reintroduce;
   end; // incapsulate

implementation

uses
  RDutils, RnQBinUtils;

constructor Tincapsulate.aString(const s_: RawByteString);
begin
  inherited;
  what := [I_str];
  str := s_;
end;

constructor Tincapsulate.anInt(i_:integer);
begin
  inherited;
  what := [I_int];
  int := i_;
end;

constructor Tincapsulate.aDatetime(dt_:Tdatetime);
begin
  inherited;
  what := [I_dt];
  dt := dt_;
end;

constructor Tincapsulate.fromString(s: RawByteString);
begin
  inherited;
  what := [];
  while s > '' do
   case s[1] of
    'S':
      begin
        include(what, I_str);
        setLength(str, integer((@s[2])^));
        move(s[6], str[1], length(str));
        delete(s, 1, 5+length(str));
      end;
    'I':
      begin
        include(what, I_int);
        int := integer((@s[2])^);
        delete(s, 1, 5);
      end;
    'D':
      begin
        include(what, I_dt);
        dt := Tdatetime((@s[2])^);
        delete(s, 1, 9);
      end;
    else raise Exception.create('invalid data'); // should never reach this
   end;
end; // fromString

function Tincapsulate.toString: RawByteString;
begin
  result := '';
  if I_str in what then
    result := result+'S'+int2str(length(str))+str;
  if I_int in what then
    result := result+'I'+int2str(int);
  if I_dt in what then
    result := result+'D'+dt2str(int);
end; // toString

end.
