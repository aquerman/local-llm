@echo off
rem Double-click launcher for start-server.ps1.
rem Copy this file anywhere (e.g. the Desktop); it always runs the script from the repo.
rem -ExecutionPolicy Bypass means it works even if RemoteSigned was never set.
rem "pause" keeps the window open after the server exits so errors stay readable.
title llama-server
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\aquerman\Documents\GitHub\local-llm\scripts\start-server.ps1" %*
pause
