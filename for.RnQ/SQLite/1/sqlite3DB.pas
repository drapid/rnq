//
//	Class wrapper for SQLite 3 functions.
//
unit sqlite3;

interface

uses
	SysUtils, sqlite3dll;

type

	TSqliteQueryResults = class;
	
	TSqliteDatabase = class
	private
		Fhandle: pointer;
		Fstmt: pointer;
		Fparam: integer;
		procedure RaiseError(const sql: string);
		procedure FinalizeSQL;

	public
		constructor Open(const FileName: string);
		destructor Destroy; override;
		procedure ExecSQL(const sql: string);
		procedure BeginTransaction;
		procedure Commit;
		procedure Rollback;
		function Like(const field, pattern: string; simulate: boolean): string;
		function Query(const sql: string): TSqliteQueryResults;
		procedure CompileSQL(const sql: string);
		procedure SetParam(value: int64); overload;
		procedure SetParam(value: string); overload;
		procedure SetParam(value: currency); overload;
		procedure SetParam(blob: pchar; size: integer); overload;
		procedure RunSQL;
		function GetLastInsertRowID: int64;
	end;

	TSqliteQueryResults = class
	private
		Fdb: TSqliteDatabase;
		Fstmt: pointer;
		Feof: boolean;

	public
		constructor Create(db: TSqliteDatabase; const sql: string);
		destructor Destroy; override;
		procedure Next;
		function Eof: boolean;
		function FieldAsString(i: integer): string;
		function FieldAsInteger(i: integer): int64;
		function FieldAsDouble(i: integer): double;
		function FieldAsBlob(i: integer): pchar;
		function FieldSize(i: integer): integer;
	end;

	ESqliteException = class(Exception)
	end;


implementation

constructor TSqliteDatabase.Open(const FileName: string);
begin
	if sqlite3_open(PChar(FileName), Fhandle) <> 0 then
		raise ESqliteException.CreateFmt(
			'Failed to open database "%s"', [FileName]);

	ExecSQL('pragma synchronous = off');
	ExecSQL('pragma temp_store = memory');
end;

destructor TSqliteDatabase.Destroy;
begin
	FinalizeSQL;
	sqlite3_close(Fhandle);
end;

procedure TSqliteDatabase.ExecSQL(const sql: string);
begin
	CompileSQL(sql);
	RunSQL;
end;

procedure TSqliteDatabase.BeginTransaction;
begin
	ExecSQL('begin');
end;

procedure TSqliteDatabase.Commit;
begin
	ExecSQL('commit');
end;

procedure TSqliteDatabase.Rollback;
begin
	ExecSQL('rollback');
end;

procedure TSqliteDatabase.CompileSQL(const sql: string);
var
	IgnoreNextStmt: Pchar;
begin
	FinalizeSQL;
	if sqlite3_prepare(Fhandle, PChar(sql), -1, Fstmt, IgnoreNextStmt) <> 0
		then RaiseError(sql);
	Fparam := 1;
end;

procedure TSqliteDatabase.RunSQL;
begin
	sqlite3_step(Fstmt);
end;

procedure TSqliteDatabase.FinalizeSQL;
begin
	if Assigned(Fstmt) then
		sqlite3_finalize(Fstmt);
	Fstmt := nil;
end;

procedure TSqliteDatabase.SetParam(value: int64);
begin
	sqlite3_bind_int64(Fstmt, Fparam, value);
	Inc(Fparam);
end;

procedure TSqliteDatabase.SetParam(value: string);
begin
	sqlite3_bind_text(Fstmt, Fparam, Pchar(value), Length(value), nil);
	Inc(Fparam);
end;

procedure TSqliteDatabase.SetParam(value: currency);
begin
	sqlite3_bind_double(Fstmt, Fparam, value);
	Inc(Fparam);
end;

//	Caller must not free the blob while accessing the query.
//
procedure TSqliteDatabase.SetParam(Blob: PChar; size: integer);
begin
	sqlite3_bind_blob(Fstmt, Fparam, Blob, Size, nil);
	Inc(Fparam);
end;

procedure TSqliteDatabase.RaiseError(const sql: string);
var
	errmsg: string;
begin
	errmsg := sqlite3_errmsg(Fhandle);
	if sql <> '' then
		errmsg := Format('Error: %s%s%s', [errmsg, #13#10#13#10, sql]);
	raise ESqliteException.Create(errmsg)
end;

//	LIKE operator isn't indexed, so simulate = true for faster result.
//
function TSqliteDatabase.Like(const field, pattern: string; simulate: boolean): string;
begin
	if simulate
		then result := Format('%s between ''%s'' and ''%sz''', [field, pattern, pattern])
		else result := Format('%s like ''%s%%''', [field, pattern]);
end;

function TSqliteDatabase.GetLastInsertRowID: int64;
begin
	result := sqlite3_last_insert_rowid(Fhandle);
end;

//	Caller must free the returned object.
//
function TSqliteDatabase.Query(const sql: string): TSqliteQueryResults;
begin
	result := TSqliteQueryResults.Create(self, sql);
end;


//	Query result access functions.
//
constructor TSqliteQueryResults.Create(db: TSqliteDatabase; const sql: string);
var
	IgnoreNextStmt: Pchar;
begin
	inherited Create;
	Fdb := db;
	if sqlite3_prepare(Fdb.Fhandle, PChar(sql), -1, Fstmt, IgnoreNextStmt) <> 0
		then Fdb.RaiseError(sql);
	Next;
end;

destructor TSqliteQueryResults.Destroy;
begin
	sqlite3_finalize(Fstmt);
	inherited Destroy;
end;

procedure TSqliteQueryResults.Next;
begin
	Feof := sqlite3_step(Fstmt) = SQLITE_DONE;
end;

function TSqliteQueryResults.Eof: boolean;
begin
	result := Feof;
end;

function TSqliteQueryResults.FieldAsInteger(i: integer): int64;
begin
	result := sqlite3_column_int64(Fstmt, i);
end;

function TSqliteQueryResults.FieldAsDouble(i: integer): double;
begin
	result := sqlite3_column_double(Fstmt, i)
end;

function TSqliteQueryResults.FieldAsString(i: integer): string;
var
	size: integer;
begin
	size := FieldSize(i);
	SetLength(result, size);
	System.Move(sqlite3_column_text(Fstmt, i)^, PChar(result)^, size);
end;

//	Use FieldSize() to get the size of the blob.
//
function TSqliteQueryResults.FieldAsBlob(i: integer): pchar;
begin
	result := sqlite3_column_blob(Fstmt, i);
end;

function TSqliteQueryResults.FieldSize(i: integer): integer;
begin
	result := sqlite3_column_bytes(Fstmt, i);
end;

end.

