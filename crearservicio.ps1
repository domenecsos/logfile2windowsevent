$NombreServicio = 'AAAR'
$RutaPowershell = 'C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe'
$Argumentos= '-ExecutionPolicy Unrestricted -File C:\Scripts\listenLogGenEvents.ps1'
nssm install $NombreServicio $RutaPowershell $Argumentos