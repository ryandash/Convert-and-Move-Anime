@echo off
For /r "D:\Anime" %%f IN (*.ass) do (
	ren "%%f" "%%~nf.utf8.ass"
	"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "Get-Content -Path '%%~dpnf.utf8.ass' -Encoding UTF8 | Set-Content -Path '%%f' -Encoding utf8"
	del "%%~dpnf.utf8.ass"
)