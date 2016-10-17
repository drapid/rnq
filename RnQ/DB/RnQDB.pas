{
This file is part of R&Q2.
Under same license
}
unit RnQDB;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, classes, sysutils, graphics, //icqv9,
//  DISQLite3Database,
//  DISQLite3Api,
  ASGSQLite3Api,
  RnQDialogs;

function  initRnQdb : Boolean;
procedure CloseRnQdb;
procedure SetDBPass(pass: String);

type
//  sqlite3_ptr = TSQLite3DB;
//  sqlite3_stmt_ptr = TSQLHandle;
//  sqlite3_stmt_ptr = TSQLite3Statement;
  sqlite3_ptr = TSQLite3DbHandle;
  sqlite3_stmt_ptr = TSQLite3StmtHandle;


  function  ExecSQL(db: sqlite3_ptr; const sql: AnsiString): Boolean;
  function  sqlite3_column_raw(hstatement: sqlite3_stmt_ptr; iCol: integer): RawByteString;

var
//  MineDB : TDISQLite3Database;
//  MineDB : TSQLiteDB;
  SQLiteDLL_handle: THandle;
  protoDB: sqlite3_ptr;
  histDB: sqlite3_ptr;
  avtDB: sqlite3_ptr;

implementation

uses
  DateUtils,
  RDUtils, RnQBinUtils, RDGlobal, RQUtil, RnQLangs,
 {$IFDEF DB_ENABLED}
//  RnQ2SQL,
//   SQLite3Commons, SynCommons,
 {$ENDIF DB_ENABLED}
  utilLib, events,
//  RnQFileUtil,
//  flap
  globalLib;

const
  Max_Event_ID = 1000000;

var
  DBPss : String;

//function ExecSQL(db: Pointer; const sql: String): Boolean;
//function ExecSQL(db: Pointer; const sql: AnsiString): Boolean;
function ExecSQL(db: sqlite3_ptr; const sql: AnsiString): Boolean;
var
// ss : UTF8String;
 sa: RawByteString;
 PF: PAnsiChar;
 err: PAnsiChar;
 errMsg: AnsiString;
 res: Integer;
begin
//  ss :=  sql;
  sa := StrToUTF8(sql);
// PF := PAnsiChar(AnsiToUtf8(TheStatement))
  PF := PAnsiChar(sa);
  err := NIL;
  Result := True;
//  if SQLite3_Exec(db, PF, NIL, NIL, @err) <> SQLITE_OK then
  res := SQLite3_Exec(db, PUTF8Char(PF), NIL, NIL, PUTF8Char(err));
  if res <> SQLITE_OK then
   begin
//    msgDlq
     if err <> NIL then
       errMsg := StrPas(err)
      else
       errMsg := '';
//     sqlite3_free(err);
     Result := False;
   end;
end;

function sqlite3_column_raw(hstatement: sqlite3_stmt_ptr; iCol: integer): RawByteString;
var
  Res: RawByteString;
  p: Pointer;
  i: Integer;
begin
   P := sqlite3_column_blob(hstatement, iCol);
   if p <> NIL then
     i := sqlite3_column_bytes(hstatement, iCol)
    else
     i := 0;
   if (i > 0) then
     begin
//              SetString(l, P, i);
        SetLength(Res, i);
        CopyMemory(pointer(Res), p, i);
       Result := res;
     end
    else
     Result := '';
end;

function CheckDBPass(db: sqlite3_ptr; ps: String): Boolean;
var
  FPss: RawByteString;
  ii: Integer;
  sa: RawByteString;
  err: PAnsiChar;
begin
  Result := True;
  FPss := StrToUTF8(Ps);
//  if sqlite3_key(db, Pointer(FPss), Length(FPss)) <> SQLITE_OK then
  if 0 <> SQLITE_OK then
   begin
     Result := False;
   end;
//  if not ExecSQL(MineDB, 'PRAGMA journal_mode = MEMORY') then
//  if not ExecSQL(MineDB, 'PRAGMA synchronous = NORMAL') then
//  if not ExecSQL(MineDB, 'SELECT 1 from history limit 1') then
//  sa := 'SELECT 1 from history limit 1';
  sa := 'SELECT 1 from sqlite_master limit 1';
//  ii := SQLite3_Exec(db, PAnsiChar(sa), NIL, NIL, @err);
  ii := SQLite3_Exec(db, PUTF8Char(sa), NIL, NIL, err);
  if ii <> SQLITE_OK then
    begin
//     sqlite3_free(err);
    end;
  if ii = SQLITE_NOTADB then
    Result := False;
end;

function initRnQdb: Boolean;
var
//  tmp: TSQLiteTable;
//  db: sqlite3;
//  DBName: AnsiString;
  DBName: String;
  DB: AnsiString;
//  FPss: RawByteString;
  isCancel: Boolean;
begin
 {$IFDEF PREF_IN_DB}
  DBName := AccPath + protoDBFile;
//  sqlite3_check(sqlite3_open(PAnsiChar(DBName), @DB), DB);
//  Result := False;
//	if sqlite3_open16(PWideChar(DBName), MineDB) <> 0 then
  db := StrToUTF8(DBName);
//	if sqlite3_open(PAnsiChar(DB), @MineDB) <> SQLITE_OK then
	if sqlite3_open(PUTF8Char(DB), protoDB) <> SQLITE_OK then
//	if SQLite3_Open16(PWideChar(DB), protoDB) <> SQLITE_OK then
   begin
//		raise ESqliteException.CreateFmt(
//			'Failed to open database "%s"', [FileName]);
    ProtoDB := NIL;
    Exit(False);
   end;
//  sqlite3_extended_result_codes(MineDB, 1);
//  sqlite3_extended_result_codes(MineDB, -1);  For DISQLite
//  DBPss := '123';
  isCancel := CheckDBPass(protoDB, DBPss);
  Result := True;
  while not isCancel do
      begin
//        pPass := '';
        if enterPwdDlg(DBPss, getTranslation('History password') + ' (' + '' + ')', 32, True) then
           if CheckDBPass(protoDB, DBPss) then
             begin
  //             resAccPass := newAccPass;
               Result   := True;
               isCancel := True;
             end
            else
             begin
//              pPass := '';
              Result := False;
              msgDlg('Wrong password', True, mtWarning)
             end
         else
          begin
            Result := False;
            isCancel := True;
            msgDlg('Please enter password', True, mtWarning);
          end;
      end;
  if not Result then
    exit;
	ExecSQL(protoDB, 'commit');
	ExecSQL(protoDB, 'PRAGMA synchronous = off');
//  ExecSQL(MineDB, 'PRAGMA synchronous = NORMAL');
  ExecSQL(protoDB, 'PRAGMA journal_mode = MEMORY');
	ExecSQL(protoDB, 'PRAGMA temp_store = memory');
  ExecSQL(protoDB, 'PRAGMA locking_mode = EXCLUSIVE');

  Result := True;

 {$ENDIF PREF_IN_DB}

  db := StrToUTF8(AccPath + historyDBFile);
//	if sqlite3_open(PAnsiChar(DB), @MineDB) <> SQLITE_OK then
	if sqlite3_open(PUTF8Char(DB), histDB) <> SQLITE_OK then
//	if SQLite3_Open16(PWideChar(DB), histDB) <> SQLITE_OK then
   begin
//		raise ESqliteException.CreateFmt(
//			'Failed to open database "%s"', [FileName]);
    histDB := NIL;
    Exit(False);
   end;
	ExecSQL(histDB, 'commit');
	ExecSQL(histDB, 'PRAGMA synchronous = off');
//  ExecSQL(MineDB, 'PRAGMA synchronous = NORMAL');
//  ExecSQL(histDB, 'PRAGMA journal_mode = MEMORY');
	ExecSQL(histDB, 'PRAGMA temp_store = memory');
  ExecSQL(histDB, 'PRAGMA locking_mode = EXCLUSIVE');

 {$IFDEF AVT_IN_DB}
//  ExecSQL(MineDB, 'ATTACH DATABASE "'+Account.ProtoPath+ 'RnQAvatars.db3" as RAVT;');

    DBName := AccPath + AVT_DB_File;
    db := StrToUTF8(DBName);
//    avtDB := NIL;
    avtDB := 0;
//    if sqlite3_open(PAnsiChar(DB), @avtDB) <> SQLITE_OK then
    if sqlite3_open(PUTF8Char(DB), avtDB) <> SQLITE_OK then
//    if SQLite3_Open16(PWideChar(DB), avtDB) <> SQLITE_OK then
     begin
//      avtDB := NIl;
      avtDB := 0;
      Exit;
     end;
//    sqlite3_extended_result_codes(avtDB, -1);  For DISQLite
  //  DBPss := '123';
//    avtDBPss := dbPss;
    isCancel := CheckDBPass(avtDB, '');
    if not isCancel then
      isCancel := CheckDBPass(avtDB, DBPss);
    if not isCancel then
      begin
       SQLite3_Close(avtDB);
//       avtDB := NIL;
       avtDB := 0;
       msgDlg('Could not load base of avatars', True, mtWarning);
      end
     else
      begin
        ExecSQL(avtDB, 'PRAGMA synchronous = off');
//        ExecSQL(avtDB, 'PRAGMA journal_mode = MEMORY');
        ExecSQL(avtDB, 'PRAGMA temp_store = memory');
        ExecSQL(avtDB, 'PRAGMA locking_mode = EXCLUSIVE');
      end;
 {$ENDIF AVT_IN_DB}
end;


procedure CloseRnQdb;
begin
//  MineDB.Close;
//  MineDB.Free;
  SQLite3_Close(protoDB);
  SQLite3_Close(histDB);
  if avtDB <> NIL then
//  if avtDB <> 0 then
    SQLite3_Close(avtDB);
  DBPss := '';
end;

procedure SetDBPass(pass: String);
//var
//  ss: RawByteString;
begin
{  if DBPss <> pass then
   begin
     ss := StrToUTF8(pass);
     if sqlite3_rekey(MineDB, Pointer(ss), Length(ss)) = SQLITE_OK then
       DBPss := pass;
   end;}
// ChangeSQLEncryptTablePassWord(
// CreateSQLEncryptTable(
end;

procedure BackupBase;
//http://sqlite.org/c3ref/backup_finish.html
begin
{
    Backup = sqlite3_backup_init(Dst, 'main', Src, 'main');
    if Backup = nil then
      Abort;
    try
        repeat
            case sqlite3_backup_step(Backup, SOME_PAGE_COUNT) of
                SQLITE_DONE: break;
                SQLITE_OK, SQLITE_BUSY, SQLITE_LOCKED: continue;
                else
                 Abort;
            end;
            Write('Осталось ', sqlite3_backup_remaining(Backup) * 100 div sqlite3_backup_pagecount(Backup), '%');
            Sleep(SOME_TIME);
        until false;
    finally
        sqlite3_backup_finish(Backup)
    end;
}
end;

end.
