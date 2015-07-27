@FOR /r %%R IN (*.~*) DO IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.identcache) DO IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.ddp) DO IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.ppu) DO IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.bak) DO IF EXIST %%R (del /s /q "%%R")

@IF EXIST "*.dcu" del *.dcu
@IF EXIST "*.o" del *.o
@IF EXIST ".\Units\*.dcu" del .\Units\*.dcu
@IF EXIST "Prefs\__history\*" del /q Prefs\__history\*
@IF EXIST "Prefs\*.dcu" del /q Prefs\*.dcu
@IF EXIST "__history\*" del /q __history\*
@IF EXIST "ICQ\__history\*" del /q ICQ\__history\*
@IF EXIST "ICQ\*.dcu" del /q ICQ\*.dcu
@IF EXIST "MRA\__history\*" del /q MRA\__history\*
@IF EXIST "xmpp\__history\*" del /q xmpp\__history\*
@exit