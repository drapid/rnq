Simple SQLite3 class wrapper for Delphi.

sqlite3.pas - a simple class wrapper for sqlite3
sqlite3dll.pas - Pascal interface to the C functions in sqlite3.dll
sqlite3.dll - dynamic link library from www.sqlite.org

How to use in Delphi 7. . .

uses sqlite3;
.
.
.
var db: TSqliteDatabase;
.
.
.
db := TSqliteDatabase.Open('my.db');

//  to fetch records from a query
//
with db.Query('select f1,f2 from tbl where f1>0') do begin
  while not Eof do begin
    writeln(FieldAsInt(0), FieldAsString(1));
    Next;
  end;
  Free;
end;

//   to execute a command without fetching the results
//
db.ExecSQL('delete from tbl where f1=0');

//   to execute a command w/ parameters
//
db.CompileSQL('insert into tbl(f1,f2) values(?,?)');
db.SetParam(123);
db.SetParam('abc');
db.RunSQL;

//   when you're done
//
db.Free;
