# Aternity event generation

## Planteamiento

### Plantilla de generación de eventos

Plantilla de generación de eventos

```
try
{
    # Set new environment for Action Extensions Methods
    Add-Type -Path $env:ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
 
    # Add any PowerShell business logic and check whether to raise a health event
    # TODO: Replace this with any customized PowerShell behavior
    [bool]$raiseHealthEvent = $false
 
    # Check whether a custom health event should be created by the Agent
    if ($raiseHealthEvent -eq $true)
    {
       # Use the ActionExtensionsMethods in order to set the event attributes (note – only SetEventOccurred is mandatory)
       [ActionExtensionsMethods.PowershellPluginMethods]::SetEventOccurred()
       [ActionExtensionsMethods.PowershellPluginMethods]::SetComponent("Name")
    }
    Else
    {
        # Just do nothing since the service status isn’t stopped
    }
}
catch
{
    [ActionExtensionsMethods.PowershellPluginMethods]::SetFailed($_.Exception.Message)
}
```

### Ejemplo de generación de eventos Aternity

Ejemplo para detectar si el servicio CCMEXEC está parado.

```
try
{
    # Set new environment for Action Extensions Methods
    Add-Type -Path $env:ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

    # Get the CCMEXEC windows service status
    $service = Get-Service -Name 'ccmexec' -ErrorAction SilentlyContinue

    # Create and send a custom health event when this service is stopped
    if ($service.Status -eq 'Stopped')
    {
        [ActionExtensionsMethods.PowershellPluginMethods]::SetComponent($service.DisplayName +" (" +  $service.Name + ")")
        [ActionExtensionsMethods.PowershellPluginMethods]::SetDetails("Service not running")
        [ActionExtensionsMethods.PowershellPluginMethods]::SetEventOccurred()
    }
    Else
    {
        # Just do nothing since the service status isn’t stopped
    }
}
catch
{
    [ActionExtensionsMethods.PowershellPluginMethods]::SetFailed($_.Exception.Message)
}
```
### Requisitos

Al cliente le interesa obtener dos cosas:

- Generar un evento cuando el consumo de CPU del sistema llegue a un porcentaje
- Generar un evento cuando un proceso de Windows consuma un determinado porcentaje.

# Solución

## Generar un evento cuando el consumo de CPU del sistema llegue a un porcentaje

Este sencillo snippet de código permite ver el consumo de CPU. 
Se han comparado los datos obtenidos con la carga que genera **cpustres**, disponible junto al código.

```
PS C:\...> $Exchserver
pcnx415

PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
16
PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
13
PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
31
PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
71
PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
57
PS C:\...>
PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
34
PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
93
PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
65
PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
76
PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
15
PS C:\...>  (Get-WmiObject -ComputerName $Exchserver -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
7
```

Para la máquina local no es necesario usar el argumento **-ComputerName**.

```
PS C:...>  (Get-WmiObject -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
100
```
### Propuesta para generar un evento cuando el consumo de CPU del sistema llegue a un porcentaje

Este código puede insertarse en un bucle infinito con un sleep (segundos) marcando el ritmo. 
El conjunto se puede empaquetar como un servicio como se indica para la lectura de logs.

```
try
{
	# Configura el porcentaje
	$porcentajeUmbral= 75

	# Set new environment for Action Extensions Methods
	Add-Type -Path $env:ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

	# Lee la actividad de CPU
	$porcentajeActividad = (Get-WmiObject -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average

	# Toma la decisión (-ge "greater or equal" ha llegado a)
	[bool]$raiseHealthEvent = ($porcentajeActividad -ge $porcentajeUmbral  )

	# Check whether a custom health event should be created by the Agent
	if ($raiseHealthEvent -eq $true)
	{
		# Use the ActionExtensionsMethods in order to set the event attributes (note – only SetEventOccurred is mandatory)
		[ActionExtensionsMethods.PowershellPluginMethods]::SetEventOccurred()
		[ActionExtensionsMethods.PowershellPluginMethods]::SetComponent("Name")
	}
	Else
	{
		# Nada que hacer, la CPU anda descansada.
	}
}
catch
{
    [ActionExtensionsMethods.PowershellPluginMethods]::SetFailed($_.Exception.Message)
}
```




## Generar un evento cuando un proceso de Windows consuma un determinado porcentaje.

Obtener el valor de CPU de un proceso "de task manager" desde Powershell no parece la más clara de las tareas. 
El cálculo siguiente es una buena aproximación para un nombre de proceso conocido 
y que tenga una única aparición en la lista de `Get-Process`.

Se ha validado que con 1, 2, 3 y 4 hilos a toda máquina midiese 25%, 50%, 75% y 100% de CPU 
si bien Task Manager daba valores algo mayores a los primeros y 99% al último.

Integrar la medida en la plantilla usando `$prod_percentage_cpu` en el comparador de umbral no tiene más complicación.
```
$cpu_cores = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors
$prod_percentage_cpu = [Math]::Round(((Get-Counter ("\proceso(CPUSTRES64)\% de tiempo de procesador")).CounterSamples.CookedValue) / $cpu_cores)
```

Para probar ejemplos hay que tener en cuenta que el código disponible en Internet 
usa mayoritariamente nombres de contadores de sistema en inglés, mientras que las máquinas locales que usemos pueden tenerlos en castellano.
Estas son las equivalencias encontradas.

- `\Process(xxx)\ID Process` -> `\proceso(xxx)\id. de proceso`
- `\Process(xxx)\% Processor Time` -> `\proceso(xxx)\% de tiempo de procesador`

Un caso avanzado puede ser cuando varios procesos tengan un mismo nombre y puede que nos interese arrancar dando un pid.
Un ejemplo clásico, un servidor Weblogic con varios procesos *java*.
Este ejemplo se puede usar dando `$proc_pid` como argumento. En su defecto, `$proc_pid` está tomando el PID del primer proceso *java* de la lista de procesos.
```
# To get the PID of the process (this will give you the first occurrance if multiple matches)
$proc_pid = (get-process "java").Id[0]

# To match the CPU usage to for example Process Explorer you need to divide by the number of cores
$cpu_cores = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors

# This is to find the exact counter path, as you might have multiple processes with the same name
$proc_path = ((Get-Counter "\Process(*)\ID Process").CounterSamples | ? {$_.RawValue -eq $proc_pid}).Path

# We now get the CPU percentage
$prod_percentage_cpu = [Math]::Round(((Get-Counter ($proc_path -replace "\\id process$","\% Processor Time")).CounterSamples.CookedValue) / $cpu_cores)

# Las dos últimas instrucciones con los nombres de contador en castellano.
$proc_path = ((Get-Counter "\proceso(*)\id. de proceso").CounterSamples| ? {$_.CookedValue -eq $proc_pid}).Path
$prod_percentage_cpu = [Math]::Round(((Get-Counter ($proc_path -replace "\\id. de proceso$","\% de tiempo de procesador")).CounterSamples.CookedValue) / $cpu_cores)
```



