::Script kompileret af RUFR@ssi.dk

TASKKILL /F /IM ONENOTE.EXE
C:
cd C:\Users\%USERNAME%\AppData\Local\Microsoft\OneNote\15.0
DEL OneNoteOfflineCache.onecache /F
timeout /t 5 /nobreak
start onenote