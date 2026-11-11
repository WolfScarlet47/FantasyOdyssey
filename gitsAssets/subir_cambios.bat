@echo off
cd /d "%~dp0.."
echo --- Guardando cambios en Fantasy Odyssey ---
git add .
set /p mensaje="Escribe el mensaje para el commit: "
git commit -m "%mensaje%"
git push origin main
echo.
echo --- ¡Proceso completado! ---
pause