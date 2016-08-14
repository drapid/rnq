//
//	Interface to the library functions in 'sqlite3.dll'.
//
unit sqlite3dll;

interface

const
	SQLITE_DONE = 101;

type
	TPCharArray = array [0..(MaxLongint div sizeOf(PChar))-1] of PChar;
	PPCharArray = ^TPCharArray;

function  sqlite3_open(filename: pchar; var db: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_close(db: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_exec(db: pointer; sql: pchar; callback: pointer; userdata: pchar; var errmsg: pchar): integer; cdecl; external 'sqlite3.dll';
procedure sqlite3_free(ptr: pchar); cdecl; external 'sqlite3.dll';
function  sqlite3_prepare(db: pointer; sql: pchar; nBytes: integer; var stmt: pointer; var ztail: pchar): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_step(stmt: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_finalize(stmt: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_errmsg(db: pointer): pchar; cdecl; external 'sqlite3.dll';
function  sqlite3_errcode(db: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_get_table(db: pointer; sql: pchar; var result: PPCharArray; var RowCount: Cardinal; var ColCount: Cardinal; var errmsg: pchar): integer; cdecl; external 'sqlite3.dll';
procedure sqlite3_free_table(table: PPCharArray); cdecl; external 'sqlite3.dll';
function  sqlite3_last_insert_rowid(db: pointer): int64; cdecl; external 'sqlite3.dll';
procedure sqlite3_interrupt(db: pointer); cdecl; external 'sqlite3.dll';

function  sqlite3_column_count(stmt: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_column_name(stmt: pointer; ColNum: integer): pchar; cdecl; external 'sqlite3.dll';
function  sqlite3_column_type(stmt: pointer; col: integer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_column_bytes(stmt: pointer; col: integer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_column_blob(stmt: pointer; col: integer): pointer; cdecl; external 'sqlite3.dll';
function  sqlite3_column_double(stmt: pointer; col: integer): double; cdecl; external 'sqlite3.dll';
function  sqlite3_column_int(stmt: pointer; col: integer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_column_int64(stmt: pointer; col: integer): Int64; cdecl; external 'sqlite3.dll';
function  sqlite3_column_text(stmt: pointer; col: integer): pchar; cdecl; external 'sqlite3.dll';
function  sqlite3_bind_blob(stmt: pointer; param: integer; blob: pointer; size: integer; freeproc: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_bind_text(stmt: pointer; param: integer; text: PChar; size: integer; freeproc: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_bind_int64(stmt: pointer; param: integer; value: int64): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_bind_double(stmt: pointer; param: integer; value: double): integer; cdecl; external 'sqlite3.dll';

implementation

end.

