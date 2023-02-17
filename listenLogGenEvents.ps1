# TO-DO Usage

# -------------------------------------------------------------------------------------------------------------------
# Configurar

# Nota: Las definiciones de `$paramLog` y `$paramSource` deben coincidir en `installFullEquip.ps1` y `listenLogGenEvents.ps1`.

# Situación del fichero de log monitorizado
$logFile = "log\generated.log" 

# Event log de Windows a escribir. Si no existe, el script la creará.
$paramLog = "AppVideoLog"

# Source de los eventos en el event log. Si no existe, el script la creará.
$paramSource = "AppVideoSrc"

# Para ver los eventos en una vista personalizada
# - Ejecutar este script y garantizar que aparece "Existe la fuente de eventos..." o "Creando la fuente de eventos...", idealmente que inserte algún evento.
# - Abrir el visor de eventos (eventvwr.msc)
# - Click derecho a "Vistas personalizadas", opción "Crear vista personalizada".
# - Seleccionar (o) Por origen.
# - En el desplegable "Orígenes del evento" seleccionar $paramSource
# - En el desplegable "Registro de eventos" se seleccionará automáticamente $paramLog
# - Si es necesario, añadir otros criterios de filtro.
# - Ok. Dar un nombre y descripción y aceptar.

# N.B. Para limpiar pruebas, ejecutar en este orden y con las variables informadas
# Remove-EventLog -Source  $paramSource
# Remove-EventLog -LogName $paramLog

# Define los eventos que se pueden obtener del log
# - mark: Texto que se espera encontrar en una línea del fichero de log.
# - eventCode: Código de evento de Windows que se genera.
# - eventType: Tipo de evento ('Warning', 'Error', 'Information'...)
# - category: Número de categoría del evento
$events =@(
	[pscustomobject]@{mark="TRIVIUM:";   eventCode=2001;eventType='Warning';category=3},
	[pscustomobject]@{mark="QUADRIVIUM:";eventCode=2002;eventType='Error';  category=4}
)

# Definir la conversión de linea del fichero de log en mensaje del event log
function logLine2eventMessage{
	Param(
		[String]$LogLine,  # La linea completa del fichero de log
		[String]$EventMark # La marca de evento que se ha encontrado en la linea del fichero de log
	)
	# Ejemplo: Devuelve como mensaje lo que viene detrás de la marca de evento en la linea del fichero de log
	return $LogLine.Substring( $LogLine.indexOf($EventMark) + $EventMark.Length ).Trim()
}

# /Configurar
# -------------------------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------------------------
# Saludo y mostrar los parámetros con que se va a trabajar
Write-Output "Textos a buscar en los logs, y el id de evento que se asociará a cada uno de ellos"
Foreach ($event in $events) { 
	Write-Output ($event.mark + " -> " + $event.eventCode + " [" + $event.eventType + "]")
}

# Preferencias de tratamiento de error
$ErrorActionPreference = "Stop"

# -------------------------------------------------------------------------------------------------------------------
# Verifica la existencia de la fuente y el log y los crea si es necesario
# Ref: http://msdn.microsoft.com/en-us/library/system.diagnostics.eventlog.exists(v=vs.110).aspx
# Ref: http://msdn.microsoft.com/en-us/library/system.diagnostics.eventlog.sourceexists(v=vs.110).aspx
# Si no hay log evita ya buscar el source
$newEventLog = -not ( [System.Diagnostics.EventLog]::Exists($paramLog) )
$newEventLog = $newEventLog -or (-not [System.Diagnostics.EventLog]::SourceExists($paramSource))
if ( $newEventLog ) {
	try {
		# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-eventlog?view=powershell-5.1
		# Crea source o log y source con una misma sintaxis
		Write-Output "Creando la fuente de eventos $paramSource en el event log $paramLog"
		New-EventLog `
			-LogName $paramLog `
			-Source $paramSource 
			# -CategoryResourceFile ver https://www.eventsentry.com/blog/2010/11/creating-your-very-own-event-m.html
	} catch {
		$_.Exception
		Write-Output "No se puede crear la fuente de eventos $paramSource en el log $paramLog"
		exit(1)
	}
} else {
	Write-Output "Existe la fuente de eventos $paramSource en el log $paramLog"
}

# -------------------------------------------------------------------------------------------------------------------
# Lectura en vivo del log

# Get-Content Lee el contenido del log -Wait esperando a cambios en este y -Last tomando las nuevas líneas.
Get-Content $logFile -Wait -Last 0 |
# Ejemplo de como encajar un filtro, $_ es el contenido de la linea
# Where-Object { $_ -match '0 -' } |
	ForEach-Object {
	
		# Itera las definiciones de evento 
		Foreach ($event in $events) { 

			# Si la línea encaja
			if ( $_ -match $event.mark  ) {

				# Extraer el mensaje del evento de la linea de log al gusto
				$eventMessage = logLine2eventMessage `
					-LogLine   $_ `
					-EventMark $event.mark

				# Friendly reminder
				Write-Output ("Log:   $_")
				Write-Output ("Event: " + $event.eventCode + " [" + $event.eventType + "] " + $eventMessage)
				
				# Insercion del evento https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/write-eventlog?view=powershell-5.1
				Write-EventLog `
					-LogName   $paramLog `
					-Source    $paramSource `
					-EventID   $event.eventCode `
					-EntryType $event.eventType `
					-Category  $event.category `
					-Message   $eventMessage 
				# -RawData permite añadir por ejemplo un JSON, http://www.integrationtrench.com/Adding-Structured-Data-to-Event-Log-Items/ 
				# Para que el evento tenga un keyword diferene de "Clásic": https://stackoverflow.com/questions/13365060/windows-events-anybody-know-how-to-specify-the-keywords-value
				
				# Para transformar los números de categoría del event viewer en mensajes
				# TO-DO, know more https://learn.microsoft.com/en-us/windows/win32/eventlog/message-files
			}
		}
	}
