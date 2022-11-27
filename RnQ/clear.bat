@FOR /r %%R IN (*.~*) DO @IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.identcache) DO @IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.ddp) DO @IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.ppu) DO @IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.bak) DO @IF EXIST %%R (del /s /q "%%R")

@IF EXIST "*.dcu" del *.dcu
@IF EXIST "*.o" del *.o
@IF EXIST ".\Units\*.dcu" del .\Units\*.dcu
@IF EXIST ".\Units\*.res" del .\Units\*.res
@IF EXIST "Prefs\__history\*" rd /q Prefs\__history\
@IF EXIST "Prefs\*.dcu" del /q Prefs\*.dcu
@IF EXIST "__history\*" rd /q /s __history\
@IF EXIST "ICQ\__history\*" rd /q ICQ\__history\
@IF EXIST "ICQ\*.dcu" del /q ICQ\*.dcu
@IF EXIST "MRA\__history\*" rd /q MRA\__history\
@IF EXIST "xmpp\__history\*" rd /q xmpp\__history\
@IF EXIST "WIM\__history\*" rd /q WIM\__history\
@IF EXIST "WIM\*.dcu" del /q WIM\*.dcu
@IF EXIST "TLG\__history\*" rd /q ICQ\__history\
@IF EXIST "TLG\*.dcu" del /q ICQ\*.dcu
@exit