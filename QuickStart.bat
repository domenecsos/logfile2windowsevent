start "Log Generator" powershell -ExecutionPolicy Bypass -NoProfile -File .\generaLog.ps1
start "Event Gen Log Listener" powershell -ExecutionPolicy Bypass -NoProfile -File .\listenLogGenEvents.ps1