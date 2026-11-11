@echo off
cd /d "%~dp0.."
echo --- Descargando cambios de GitHub (Pull) ---
git pull origin main
echo.
echo --- Repositorio actualizado ---
pause