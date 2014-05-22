@IF EXIST "*.~*" del *.~*
@IF EXIST "*.dcu" del *.dcu
@IF EXIST "*.ddp" del *.ddp
@IF EXIST "*.ppu" del *.ppu
@IF EXIST "*.o" del *.o
@IF EXIST "*.bak" del *.bak
@IF EXIST "*.identcache " del *.identcache 
@IF EXIST ".\Units\*.dcu" del .\Units\*.dcu
@IF EXIST "Prefs\__history\*" del /q Prefs\__history\*
@IF EXIST "Prefs\*.bak" del /q Prefs\*.bak
@IF EXIST "Prefs\*.dcu" del /q Prefs\*.dcu
@IF EXIST "__history\*" del /q __history\*
@IF EXIST "ICQ\__history\*" del /q ICQ\__history\*
@IF EXIST "ICQ\*.bak" del /q ICQ\*.bak
@IF EXIST "ICQ\*.dcu" del /q ICQ\*.dcu
@IF EXIST "MRA\__history\*" del /q MRA\__history\*
@IF EXIST "xmpp\__history\*" del /q xmpp\__history\*
@exit