@echo off
rem Double-click launcher for start-server.ps1.
rem The Desktop "Start Server" entry is a shortcut to this file; %~dp0 is this file's folder, so it
rem always runs the script from the repo.
rem -ExecutionPolicy Bypass means it works even if RemoteSigned was never set.
rem "pause" keeps the window open after the server exits so errors stay readable.
title llama-server
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-server.ps1" %*
pause
