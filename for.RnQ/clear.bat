@FOR /r %%R IN (*.~*) DO @IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.identcache) DO @IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.bak) DO @IF EXIST %%R (del /s /q "%%R")
@FOR /r %%R IN (*.stat) DO @IF EXIST %%R (del /s /q "%%R")
@IF EXIST "*.dcu" del *.dcu
@IF EXIST "*.ppu" del *.ppu
@IF EXIST "*.o" del *.o
@IF EXIST "AES\*.dcu" del AES\*.dcu
@IF EXIST "Bass\*.dcu" del Bass\*.dcu
@IF EXIST "Flash\*.dcu" del Flash\*.dcu
@IF EXIST "NativeJpg\Source\*.dcu" del NativeJpg\Source\*.dcu
@IF EXIST VTV\Source\*.dcu del VTV\Source\*.dcu
@IF EXIST VTV\Source\*.bak del VTV\Source\*.bak
@IF EXIST xml\*.dcu del xml\*.dcu
@IF EXIST RSA\*.dcu del RSA\*.dcu
@IF EXIST "xml\__history\*" del /q xml\__history\*
@IF EXIST "VTV\Source\__history\*" del /q VTV\Source\__history\*
@IF EXIST Zip\*.dcu @del Zip\*.dcu
@IF EXIST "Zip\__history\*" del /q Zip\__history\*
@IF EXIST .\Units\*.dcu @del .\Units\*.dcu
@IF EXIST "__history\*" rd /q /s __history\
@IF EXIST "RTL\*.dcu" del RTL\*.dcu
@IF EXIST "RTL\*.ppu" del RTL\*.ppu
@IF EXIST "RTL\*.o" del RTL\*.o
@IF EXIST "RTL\*.a" del RTL\*.a
@IF EXIST "RTL\__history" rd /s /q RTL\__history
