{$I asqlite_def.inc}

unit ASGSQLite3Api;

interface

uses
  SysUtils;

const
  SQLITE_OK         = 0;                // Successful result */
  SQLITE_ERROR      = 1;                // SQL error or missing database */
  SQLITE_INTERNAL   = 2;                // An internal logic error in SQLite */
  SQLITE_PERM       = 3;                // Access permission denied */
  SQLITE_ABORT      = 4;                // Callback routine requested an abort */
  SQLITE_BUSY       = 5;                // The database file is locked */
  SQLITE_LOCKED     = 6;                // A table in the database is locked */
  SQLITE_NOMEM      = 7;                // A malloc() failed */
  SQLITE_READONLY   = 8;                // Attempt to write a readonly database */
  SQLITE_INTERRUPT  = 9;                // Operation terminated by sqlite_interrupt() */
  SQLITE_IOERR      = 10;               // Some kind of disk I/O error occurred */
  SQLITE_CORRUPT    = 11;               // The database disk image is malformed */
  SQLITE_NOTFOUND   = 12;               // (Internal Only) Table or record not found */
  SQLITE_FULL       = 13;               // Insertion failed because database is full */
  SQLITE_CANTOPEN   = 14;               // Unable to open the database file */
  SQLITE_PROTOCOL   = 15;               // Database lock protocol error */
  SQLITE_EMPTY      = 16;               // (Internal Only) Database table is empty */
  SQLITE_SCHEMA     = 17;               // The database schema changed */
  SQLITE_TOOBIG     = 18;               // Too much data for one row of a table */
  SQLITE_CONSTRAINT = 19;               // Abort due to contraint violation */
  SQLITE_MISMATCH   = 20;               // Data type mismatch */
  SQLITE_MISUSE     = 21;               // Library used incorrectly */
  SQLITE_NOLFS      = 22;               // Uses OS features not supported on host */
  SQLITE_AUTH       = 23;               // Authorization denied */
  SQLITE_ROW        = 100;              // sqlite_step() has another row ready */
  SQLITE_DONE       = 101;              // sqlite_step() has finished executing */

  SQLITE_CREATE_INDEX = 1;              // Index Name      Table Name      */
  SQLITE_CREATE_TABLE = 2;              // Table Name      NULL            */
  SQLITE_CREATE_TEMP_INDEX = 3;         // Index Name      Table Name      */
  SQLITE_CREATE_TEMP_TABLE = 4;         // Table Name      NULL            */
  SQLITE_CREATE_TEMP_TRIGGER = 5;       // Trigger Name    Table Name      */
  SQLITE_CREATE_TEMP_VIEW = 6;          // View Name       NULL            */
  SQLITE_CREATE_TRIGGER = 7;            // Trigger Name    Table Name      */
  SQLITE_CREATE_VIEW = 8;               // View Name       NULL            */
  SQLITE_DELETE     = 9;                // Table Name      NULL            */
  SQLITE_DROP_INDEX = 10;               // Index Name      Table Name      */
  SQLITE_DROP_TABLE = 11;               // Table Name      NULL            */
  SQLITE_DROP_TEMP_INDEX = 12;          // Index Name      Table Name      */
  SQLITE_DROP_TEMP_TABLE = 13;          // Table Name      NULL            */
  SQLITE_DROP_TEMP_TRIGGER = 14;        // Trigger Name    Table Name      */
  SQLITE_DROP_TEMP_VIEW = 15;           // View Name       NULL            */
  SQLITE_DROP_TRIGGER = 16;             // Trigger Name    Table Name      */
  SQLITE_DROP_VIEW  = 17;               // View Name       NULL            */
  SQLITE_INSERT     = 18;               // Table Name      NULL            */
  SQLITE_PRAGMA     = 19;               // Pragma Name     1st arg or NULL */
  SQLITE_READ       = 20;               // Table Name      Column Name     */
  SQLITE_SELECT     = 21;               // NULL            NULL            */
  SQLITE_TRANSACTION = 22;              // NULL            NULL            */
  SQLITE_UPDATE     = 23;               // Table Name      Column Name     */
  SQLITE_ATTACH     = 24;               // Filename        NULL            */
  SQLITE_DETACH     = 25;               // Database Name   NULL            */

  SQLITE_DENY       = 1;                // Abort the SQL statement with an error */
  SQLITE_IGNORE     = 2;                // Don't allow access, but don't generate an error */

  SQLITE_STATIC     = pointer(0);
  SQLITE_TRENT      = pointer(-1);

  SQLITE_INTEGER    = 1;
  SQLITE_FLOAT      = 2;
  SQLITE_TEXT       = 3;
  SQLITE_BLOB       = 4;
  SQLITE_NULL       = 5;

type
  AsgError = class(Exception);

type
  TSQLite3DbHandle = Pointer;
  TSQLite3StmtHandle = Pointer;

  PUtf8Char = PAnsiChar;

  TSQLite3_Callback = function(UserData: Pointer; ColumnCount: Integer; ColumnValues, ColumnNames: PPointer): Integer; cdecl;
  TSQLiteCollationCallback = function(UserData: Pointer; s1Len: integer; s1: PAnsiChar; s2Len: integer; s2: PAnsiChar) : integer; cdecl;

var
  SQLite3_Open16: function(dbname: PChar; var db: TSQLite3DbHandle): integer; cdecl;
  SQLite3_Close: function(db: TSQLite3DbHandle): integer; cdecl;
  SQLite3_Exec: function(DB: TSQLite3DbHandle; SQLStatement: PAnsiChar; Callback: TSQLite3_Callback;
                         UserDate: Pointer; var ErrMsg: PAnsiChar): Integer; cdecl;
  SQLite3_LibVersion: function(): PAnsiChar; cdecl;
  SQLite3_Errmsg16: function(db: TSQLite3DbHandle): PWideChar; cdecl;
  SQLite3_GetTable: function(db: TSQLite3DbHandle; SQLStatement: PAnsiChar; var ResultPtr: Pointer;
    var RowCount: cardinal; var ColCount: cardinal; var ErrMsg: PAnsiChar): integer; cdecl;
  SQLite3_FreeTable: procedure(Table: PAnsiChar); cdecl;
  SQLite3_FreeMem: procedure(P: PAnsiChar); cdecl;
  SQLite3_Complete16: function(P: PWideChar): boolean; cdecl;
  SQLite3_LastInsertRow: function(db: TSQLite3DbHandle): Int64; cdecl;
  SQLite3_Cancel: procedure(db: TSQLite3DbHandle); cdecl;
  SQLite3_BusyHandler: procedure(db: TSQLite3DbHandle; CallbackPtr: Pointer; Sender: TObject); cdecl;
  SQLite3_BusyTimeout: procedure(db: TSQLite3DbHandle; TimeOut: integer); cdecl;
  SQLite3_Changes: function(db: TSQLite3DbHandle): integer; cdecl;
  SQLite3_Prepare16: function(db: TSQLite3DbHandle; SQLStatement: PWideChar; nBytes: integer;
    var hstatement: TSQLite3StmtHandle; var Tail: PWideChar): integer; cdecl;
  SQLite3_Finalize: function(hstatement: TSQLite3StmtHandle): integer; cdecl;
  SQLite3_Reset: function(hstatement: TSQLite3StmtHandle): integer; cdecl;
  SQLite3_Step: function(hstatement: TSQLite3StmtHandle): integer; cdecl;
  SQLite3_Column_blob: function(hstatement: TSQLite3StmtHandle; iCol: integer): pointer; cdecl;
  SQLite3_Column_bytes: function(hstatement: TSQLite3StmtHandle; iCol: integer): integer; cdecl;
  SQLite3_Column_bytes16: function(hstatement: TSQLite3StmtHandle; iCol: integer): integer; cdecl;
  SQLite3_Column_count: function(hstatement: TSQLite3StmtHandle): integer; cdecl;
  SQLite3_Column_decltype16: function(hstatement: TSQLite3StmtHandle; iCol: integer): PChar; cdecl;
  SQLite3_Column_double: function(hstatement: TSQLite3StmtHandle; iCol: integer): double; cdecl;
  SQLite3_Column_int: function(hstatement: TSQLite3StmtHandle; iCol: integer): integer; cdecl;
  SQLite3_Column_int64: function(hstatement: TSQLite3StmtHandle; iCol: integer): int64; cdecl;
  SQLite3_Column_name16: function(hstatement: TSQLite3StmtHandle; iCol: integer): PWideChar; cdecl;
  SQLite3_Column_text: function(hstatement: TSQLite3StmtHandle; iCol: integer): PAnsiChar; cdecl;
  SQLite3_Column_text16: function(hstatement: TSQLite3StmtHandle; iCol: integer): PWideChar; cdecl;
  SQLite3_Column_type: function(hstatement: TSQLite3StmtHandle; iCol: integer): integer; cdecl;
  SQLite3_Bind_Null: function(hstatement: TSQLite3StmtHandle; iCol: integer): integer; cdecl;
  SQLite3_Bind_Blob: function(hstatement: TSQLite3StmtHandle; iCol: integer; buf: pointer; n: integer; DestroyPtr: Pointer): integer; cdecl;
  SQLite3_Bind_Int: function(hstatement: TSQLite3StmtHandle; iCol: integer; n: integer): integer; cdecl;
  SQLite3_Bind_Double: function(hstatement: TSQLite3StmtHandle; iCol: integer; d: double): integer; cdecl;
  SQLite3_Bind_Text: function(hstatement: TSQLite3StmtHandle; iCol: integer; buf: pointer; n: integer; DestroyPtr: Pointer): integer; cdecl;
  SQLite3_Bind_Value: function(hstatement: TSQLite3StmtHandle; iCol: integer; buf: pointer): integer; cdecl;
  SQLite3_Bind_Text16: function(hstatement: TSQLite3StmtHandle; iCol: integer; buf: pointer; n: integer; DestroyPtr: Pointer): integer; cdecl;
  SQLite3_Bind_Parameter_Count: function(hstatement: TSQLite3StmtHandle): integer; cdecl;
  SQLite3_Bind_Parameter_Name : function(hstatement : TSQLite3StmtHandle; iCol : integer) : PUtf8Char; cdecl;
  SQLite3_create_collation16: function(db: TSQLite3DbHandle; zName : pWideChar; pref16 : integer; data : pointer; cmp : TSQLiteCollationCallback): integer; cdecl;

function TASQLite3DB_LoadLibs(DriverDLL: string; var DLLHandle: THandle): boolean;

implementation

uses
  StrUtils,
  Windows,
  ASGSQLite3Dbg;

function systemNoCaseCompare(UserData: Pointer; s1Len : integer; s1 : PWideChar; s2Len : integer; s2 : PWideChar) : integer; cdecl;
begin
  result := CompareText(s1, s2);
end;

function systemCompare(UserData: Pointer; s1Len : integer; s1 : PWideChar; s2Len : integer; s2 : PWideChar) : integer; cdecl;
begin
  result := CompareStr(s1, s2);
end;

// GPA - Static Link Start
{$IFDEF SQLite_Static}
//SZ
// Delete this
{
Var
 __HandlerPtr:Pointer;
}

// Starting from 3.5.1, instead of C modules Memory Manager,can be used independent one
// (Borland's, FastMM4, etc, which is used in customers main project) with staticaly     // linked C modules
// SZ - Please enable static version of SQLite you prefer

//SZ {$I \SZUtils\SQLite_OBJs_3_5_1.inc}
{$I \SZUtils\SQLite_OBJs_3_5_9.inc}

  function  _sqlite3_open(dbname: PAnsiChar; var db: pointer): integer; cdecl; external;
  function  _sqlite3_close(db: pointer): integer; cdecl; external;
  function  _sqlite3_exec(DB: Pointer; SQLStatement: PAnsiChar; Callback: TSQLite3_Callback;
                          UserDate: Pointer; var ErrMsg: PAnsiChar): Integer; cdecl; external;
  function  _sqlite3_libversion: PAnsiChar; cdecl; external;
  function  _sqlite3_errmsg(db: pointer): PAnsiChar; cdecl; external;
  function  _sqlite3_get_table(db: Pointer; SQLStatement: PAnsiChar; var ResultPtr: Pointer;
                              var RowCount: cardinal; var ColCount: cardinal; var ErrMsg: PAnsiChar): integer; cdecl; external;
  procedure _sqlite3_free_table(Table: PAnsiChar); cdecl; external;
  procedure _sqlite3_free(P: PAnsiChar); cdecl; external;
  function  _sqlite3_complete(P: PAnsiChar): boolean; cdecl; external;
  function  _sqlite3_last_insert_rowid(db: Pointer): integer; cdecl; external;
  procedure _sqlite3_interrupt(db: Pointer); cdecl; external;
  procedure _sqlite3_busy_handler(db: Pointer; CallbackPtr: Pointer; Sender: TObject); cdecl; external;
  procedure _sqlite3_busy_timeout(db: Pointer; TimeOut: integer); cdecl; external;
  function  _sqlite3_changes(db: Pointer): integer; cdecl; external;
  function  _sqlite3_prepare(db: Pointer; SQLStatement: PAnsiChar; nBytes: integer;
                             var hstatement: pointer; var Tail: PAnsiChar): integer; cdecl; external;
  function  _sqlite3_finalize(hstatement: pointer): integer; cdecl; external;
  function  _sqlite3_reset(hstatement: pointer): integer; cdecl; external;
  function  _sqlite3_step(hstatement: pointer): integer; cdecl; external;
  function  _sqlite3_column_blob(hstatement: pointer; iCol: integer): pointer; cdecl; external;
  function  _sqlite3_column_bytes(hstatement: pointer; iCol: integer): integer; cdecl; external;
  function  _sqlite3_column_bytes16(hstatement: pointer; iCol: integer): integer; cdecl; external;
  function  _sqlite3_column_count(hstatement: pointer): integer; cdecl; external;
  function  _sqlite3_column_decltype(hstatement: pointer; iCol: integer): PAnsiChar; cdecl; external;
  function  _sqlite3_column_double(hstatement: pointer; iCol: integer): double; cdecl; external;
  function  _sqlite3_column_int(hstatement: pointer; iCol: integer): integer; cdecl; external;
  function  _sqlite3_column_int64(hstatement: pointer; iCol: integer): int64; cdecl; external;
  function  _sqlite3_column_name(hstatement: pointer; iCol: integer): PAnsiChar; cdecl; external;
  function  _sqlite3_column_text(hstatement: pointer; iCol: integer): PAnsiChar; cdecl; external;
  function  _sqlite3_column_type(hstatement: pointer; iCol: integer): integer; cdecl; external;
  function  _sqlite3_Bind_Null(hstatement: pointer; iCol: integer): integer; cdecl; external;
  function  _sqlite3_Bind_Blob(hstatement: pointer; iCol: integer; buf: PAnsiChar; n: integer; DestroyPtr: Pointer): integer; cdecl; external;
  function  _sqlite3_Bind_Int(hstatement: pointer; iCol: integer; n: integer): integer; cdecl; external;
  function  _sqlite3_Bind_Double(hstatement: pointer; iCol: integer; d: double): integer; cdecl; external;
  function  _sqlite3_Bind_Text(hstatement: pointer; iCol: integer; buf: pointer; n: integer; DestroyPtr: Pointer): integer; cdecl; external;
  function  _sqlite3_Bind_Value(hstatement: pointer; iCol: integer; buf: pointer): integer; cdecl; external;
  function  _sqlite3_Bind_Text16(hstatement: pointer; iCol: integer; buf: pointer; n: integer; DestroyPtr: Pointer): integer; cdecl; external;
  function  _sqlite3_Bind_Parameter_Count(hstatement: pointer): integer; cdecl; external;
  function  _sqlite3_Bind_Parameter_Name(hstatement : pointer; iCol : integer) : PAnsiChar; cdecl; external;
//  function  _sqlite3_create_collation(db: Pointer; zName : PAnsiChar; pref16 : integer; data : pointer; cmp : TCompareFunc): integer; cdecl; external;
  function _sqlite3_column_text16(hstatement: pointer; iCol: integer): PWideAnsiChar; cdecl; external;

{$ENDIF}
// GPA - Static Link End

function TASQLite3DB_LoadLibs(DriverDLL: string; var DLLHandle: THandle): boolean;
begin
  try
    DebugEnter('TASQLite3DB.LoadLibs');
    if not(CharInSet(DecimalSeparator, ['.',','])) then
       DecimalSeparator := '.';

    Debug('loading sqlite lib');
{$IFNDEF SQLite_Static}
    Debug(DriverDLL);
    Result := false;
    DLLHandle := LoadLibrary(pWideChar(DriverDLL));
    if DLLHandle <> 0 then
    begin
      @SQLite3_Open16 := GetProcAddress(DLLHandle, 'sqlite3_open16');
      @SQLite3_Close := GetProcAddress(DLLHandle, 'sqlite3_close');
      @SQLite3_Exec := GetProcAddress(DLLHandle, 'sqlite3_exec');
      @SQLite3_LibVersion := GetProcAddress(DLLHandle, 'sqlite3_libversion');
      @SQLite3_errmsg16 := GetProcAddress(DLLHandle, 'sqlite3_errmsg16');
      @SQLite3_GetTable := GetProcAddress(DLLHandle, 'sqlite3_get_table');
      @SQLite3_FreeTable := GetProcAddress(DLLHandle, 'sqlite3_free_table');
      @SQLite3_FreeMem := GetProcAddress(DLLHandle, 'sqlite3_free');
      @SQLite3_Complete16 := GetProcAddress(DLLHandle, 'sqlite3_complete16');
      @SQLite3_LastInsertRow := GetProcAddress(DLLHandle, 'sqlite3_last_insert_rowid');
      @SQLite3_Cancel := GetProcAddress(DLLHandle, 'sqlite3_interrupt');
      @SQLite3_BusyTimeout := GetProcAddress(DLLHandle, 'sqlite3_busy_timeout');
      @SQLite3_BusyHandler := GetProcAddress(DLLHandle, 'sqlite3_busy_handler');
      @SQLite3_Changes := GetProcAddress(DLLHandle, 'sqlite3_changes');
      @SQLite3_Prepare16 := GetProcAddress(DLLHandle, 'sqlite3_prepare16');
      @SQLite3_Finalize := GetProcAddress(DLLHandle, 'sqlite3_finalize');
      @SQLite3_Reset := GetProcAddress(DLLHandle, 'sqlite3_reset');
      @SQLite3_Step := GetProcAddress(DLLHandle, 'sqlite3_step');
      @SQLite3_Column_blob := GetProcAddress(DLLHandle, 'sqlite3_column_blob');
      @SQLite3_Column_bytes := GetProcAddress(DLLHandle, 'sqlite3_column_bytes');
      @SQLite3_Column_bytes16 := GetProcAddress(DLLHandle, 'sqlite3_column_bytes16');
      @SQLite3_Column_count := GetProcAddress(DLLHandle, 'sqlite3_column_count');
      @SQLite3_Column_decltype16 := GetProcAddress(DLLHandle, 'sqlite3_column_decltype16');
      @SQLite3_Column_double := GetProcAddress(DLLHandle, 'sqlite3_column_double');
      @SQLite3_Column_int := GetProcAddress(DLLHandle, 'sqlite3_column_int');
      @SQLite3_Column_int64 := GetProcAddress(DLLHandle, 'sqlite3_column_int64');
      @SQLite3_Column_name16 := GetProcAddress(DLLHandle, 'sqlite3_column_name16');
      @SQLite3_Column_text := GetProcAddress(DLLHandle, 'sqlite3_column_text');
      @SQLite3_Column_text16 := GetProcAddress(DLLHandle, 'sqlite3_column_text16');
      @SQLite3_Column_type := GetProcAddress(DLLHandle, 'sqlite3_column_type');
      @SQLite3_Bind_Blob := GetProcAddress(DLLHandle, 'sqlite3_bind_blob');
      @SQLite3_Bind_Double:= GetProcAddress(DLLHandle, 'sqlite3_bind_double');
      @SQLite3_Bind_Null := GetProcAddress(DLLHandle, 'sqlite3_bind_null');
      @SQLite3_Bind_Value := GetProcAddress(DLLHandle, 'sqlite3_bind_value');
      @SQLite3_Bind_Int := GetProcAddress(DLLHandle, 'sqlite3_bind_int');
      @SQLite3_Bind_Text := GetProcAddress(DLLHandle, 'sqlite3_bind_text');
      @SQLite3_Bind_Text16 := GetProcAddress(DLLHandle, 'sqlite3_bind_text16');
      @SQLite3_Bind_Parameter_Count := GetProcAddress(DLLHandle, 'sqlite3_bind_parameter_count');
      @SQLite3_Bind_Parameter_Name := GetProcAddress(DLLHandle, 'sqlite3_bind_parameter_name');
      @SQLite3_create_collation16 := GetProcAddress(DLLHandle, 'sqlite3_create_collation16');

      if not Assigned(@SQLite3_Open16) then raise AsgError.Create('DLL::SQlite3Open16 not found')
      else if not Assigned(@SQLite3_Close) then AsgError.Create('DLL::SQlite3Close not found')
      else if not Assigned(@SQLite3_Exec) then AsgError.Create('DLL::SQlite3Exe not found')
      else if not Assigned(@SQLite3_LibVersion) then AsgError.Create('DLL::SQliteLibversion not found')
      else if not Assigned(@SQLite3_Errmsg16) then AsgError.Create('DLL::SQlite3ErrorStringnot found')
      else if not Assigned(@SQLite3_GetTable) then AsgError.Create('DLL::SQlite3GetTable not found')
      else if not Assigned(@SQLite3_FreeTable) then AsgError.Create('DLL::SQlite3FreeTable not found')
      else if not Assigned(@SQLite3_FreeMem) then AsgError.Create('DLL::SQlite3FreeMem not found')
      else if not Assigned(@SQLite3_Complete16) then AsgError.Create('DLL::SQlite3Complete not found')
      else if not Assigned(@SQLite3_LastInsertRow) then AsgError.Create('DLL::SQlite3LastInsertRow not found')
      else if not Assigned(@SQLite3_Cancel) then AsgError.Create('DLL::SQlite3Cancel not found')
      else if not Assigned(@SQLite3_BusyTimeout) then AsgError.Create('DLL::SQlite3Busytimeout not found')
      else if not Assigned(@SQLite3_BusyHandler) then AsgError.Create('DLL::SQlite3BusyHandler not found')
      else if not Assigned(@SQLite3_Changes) then AsgError.Create('DLL::SQlite3Changes not found')
      else if not Assigned(@SQLite3_Prepare16) then AsgError.Create('DLL::SQlite3Prepare not found')
      else if not Assigned(@SQLite3_Finalize) then AsgError.Create('DLL::SQlite3Finalize not found')
      else if not Assigned(@SQLite3_Reset) then AsgError.Create('DLL::SQlite3Reset not found')
      else if not Assigned(@SQLite3_Step) then AsgError.Create('DLL::SQlite3Step not found')
      else if not Assigned(@SQLite3_Column_blob) then AsgError.Create('DLL::SQlite3ColumnBlob not found')
      else if not Assigned(@SQLite3_Column_bytes) then AsgError.Create('DLL::SQlite3ColumnBytes not found')
      else if not Assigned(@SQLite3_Column_bytes16) then AsgError.Create('DLL::SQlite3ColumnBytes16 not found')
      else if not Assigned(@SQLite3_Column_Count) then AsgError.Create('DLL::SQlite3ColumnCount not found')
      else if not Assigned(@SQLite3_Column_decltype16) then AsgError.Create('DLL::SQlite3ColumnDeclType not found')
      else if not Assigned(@SQLite3_Column_double) then AsgError.Create('DLL::SQlite3ColumnDouble not found')
      else if not Assigned(@SQLite3_Column_int) then AsgError.Create('DLL::SQlite3ColumnInt not found')
      else if not Assigned(@SQLite3_Column_int64) then AsgError.Create('DLL::SQlite3ColumnInt64 not found')
      else if not Assigned(@SQLite3_Column_name16) then AsgError.Create('DLL::SQlite3ColumnName not found')
      else if not Assigned(@SQLite3_Column_text) then AsgError.Create('DLL::SQlite3ColumnText not found')
      else if not Assigned(@SQLite3_Column_text16) then AsgError.Create('DLL::SQlite3ColumnText16 not found')
      else if not Assigned(@SQLite3_Column_type) then AsgError.Create('DLL::SQlite3COlumnTypenot found')
      else if not Assigned(@SQLite3_Bind_blob) then AsgError.Create('DLL::SQlite3BindBlob not found')
      else if not Assigned(@SQLite3_Bind_Value) then AsgError.Create('DLL::SQlite3BindValue not found')
      else if not Assigned(@SQLite3_Bind_int) then AsgError.Create('DLL::SQlite3BindInt not found')
      else if not Assigned(@SQLite3_Bind_double) then AsgError.Create('DLL::SQlite3BindDouble not found')
      else if not Assigned(@SQLite3_Bind_null) then AsgError.Create('DLL::SQlite3BindNull not found')
      else if not Assigned(@SQLite3_Bind_text) then AsgError.Create('DLL::SQlite3BindText not found')
      else if not Assigned(@SQLite3_Bind_Text16) then AsgError.Create('DLL::SQlite3BindText16 not found')
      else if not Assigned(@SQLite3_Bind_Parameter_Count) then AsgError.Create('DLL::SQlite3BindParameterCount not found')
      else if not Assigned(@SQLite3_Bind_Parameter_Name) then AsgError.Create('DLL::SQlite3BindParameterName not found')
      else if not Assigned(@SQLite3_create_collation16) then AsgError.Create('DLL::SQlite3CreateCollation not found');
      Result := true;
    end;
    {$ELSE}
      DllHandle := 1;
      @SQLite3_Open := @_sqlite3_open;
      @SQLite3_Close := @_sqlite3_close;
      @SQLite3_Exec := @_sqlite3_exec;
      @SQLite3_LibVersion := @_sqlite3_libversion;
      @SQLite3_ErrorString := @_sqlite3_errmsg;
      @SQLite3_GetTable := @_sqlite3_get_table;
      @SQLite3_FreeTable := @_sqlite3_free_table;
      @SQLite3_FreeMem := @_sqlite3_free;
      @SQLite3_Complete := @_sqlite3_complete;
      @SQLite3_LastInsertRow := @_sqlite3_last_insert_rowid;
      @SQLite3_Cancel := @_sqlite3_interrupt;
      @SQLite3_BusyTimeout := @_sqlite3_busy_timeout;
      @SQLite3_BusyHandler := @_sqlite3_busy_handler;
      @SQLite3_Changes := @_sqlite3_changes;
      @SQLite3_Prepare := @_sqlite3_prepare;
      @SQLite3_Finalize := @_sqlite3_finalize;
      @SQLite3_Reset := @_sqlite3_reset;
      @SQLite3_Step := @_sqlite3_step;
      @SQLite3_Column_blob := @_sqlite3_column_blob;
      @SQLite3_Column_bytes := @_sqlite3_column_bytes;
      @SQLite3_Column_bytes16 := @_sqlite3_column_bytes16;
      @SQLite3_Column_count := @_sqlite3_column_count;
      @SQLite3_Column_decltype := @_sqlite3_column_decltype;
      @SQLite3_Column_double := @_sqlite3_column_double;
      @SQLite3_Column_int := @_sqlite3_column_int;
      @SQLite3_Column_int64 := @_sqlite3_column_int64;
      @SQLite3_Column_name := @_sqlite3_column_name;
      @SQLite3_Column_text := @_sqlite3_column_text;
      @SQLite3_Column_type := @_sqlite3_column_type;
      @SQLite3_Bind_Blob := @_sqlite3_bind_blob;
      @SQLite3_create_collation := @_sqlite3_create_collation;
      @SQLite3_Column_text16 := @_SQLite3_Column_text16;
      @SQLite3_Bind_Text16 := @_SQLite3_Bind_Text16;
      @sqlite3_bind_parameter_count := @_sqlite3_bind_parameter_count;
      @SQLite3_Bind_Parameter_Name:=@_SQLite3_Bind_Parameter_Name;
      @SQLite3_Bind_Double:=@_SQLite3_Bind_Double;
      @SQLite3_Bind_Null :=@_SQLite3_Bind_Null;
      @SQLite3_Bind_Value :=@_SQLite3_Bind_Value;
      @SQLite3_Bind_Int :=@_SQLite3_Bind_Int;
      @SQLite3_Bind_Text :=@_SQLite3_Bind_Text;
      Result := true;
    {$ENDIF}
  finally
    DebugLeave('TASQLite3DB.LoadLibs');
  end;
end;

end.
