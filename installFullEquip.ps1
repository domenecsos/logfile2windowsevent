# -------------------------------------------------------------------------------------------------------------------
# Configurar

# Nota: New-EventLog : Sólo los primeros ocho caracteres de un nombre de registro personalizado son significativos.

# Nota: Las definiciones de `$paramLog` y `$paramSource` deben coincidir en `installFullEquip.ps1` y `listenLogGenEvents.ps1`.

# Event log de Windows a escribir. Si no existe, el script la creará.
$paramLog = "AppVideoLog"

# Source de los eventos en el event log. Si no existe, el script la creará.
$paramSource = "AppVideoSrc"

# Configura situacion en sistema de ficheros de custom view del Visor de Eventos
$viewName = "Aplicacion de video"
$viewDescription = "Vista personalizada de los eventos de la aplicacion de video"
$subdir = "AppVideo"
$fichero = "AppVideoCustomView.xml"

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
		Write-Output "Creada la fuente de eventos $paramSource en el event log $paramLog"
	} catch {
		$_.Exception
		Write-Output "No se puede crear la fuente de eventos $paramSource en el log $paramLog"
		exit(1)
	}
} else {
	Write-Output "Existe la fuente de eventos $paramSource en el log $paramLog"
}

# -------------------------------------------------------------------------------------------------------------------
# Creacion de la vista custom en un directorio

# Plantilla de definicion de vistas personalizadas
$xmlTemplate = @"
<ViewerConfig>
  <QueryConfig>
    <QueryParams>
         <Simple>
            <Channel>$paramLog</Channel>
            <RelativeTimeInfo>0</RelativeTimeInfo>
            <Source>$paramSource</Source>
            <BySource>True</BySource>
         </Simple>
    </QueryParams>
    <QueryNode>
         <Name LanguageNeutralValue="$viewName">$viewName</Name>
         <Description>$viewDescription</Description>
         <QueryList>
            <Query Id="0" Path="$paramLog">
               <Select Path="$paramLog">*[System[Provider[@Name='$paramSource']]]</Select>
            </Query>
         </QueryList>
    </QueryNode>
  </QueryConfig>
</ViewerConfig>
"@

# Raiz de los ficheros de vistas personalizadas
$templateStoragePath = Join-Path $env:ProgramData 'Microsoft\Event Viewer\Views'

# Creacion del directorio para la vista personalizada
$fulldir = Join-Path $templateStoragePath $subdir
if ( -not (Test-Path "$fulldir") ) {
	mkdir -p "$fulldir"
	Write-Output "Creado $fulldir"
} else {
	Write-Output "Ya existe $fulldir"
} 

# Creacion del fichero de la vista personalizada
$outputPath = Join-Path $fulldir $fichero
$xmlTemplate | Out-File -FilePath $outputPath -Force
Write-Output "XML escrito en $outputPath"

# TODO recomendado: Crear el listener como servicio aqui y ya estará ready to run a cada boot de la maquina
