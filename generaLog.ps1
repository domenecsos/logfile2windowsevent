# --------------------------------------------------
# Generador de mensajes de log en un fichero abierto
# --------------------------------------------------
# Ejecutar con 
# start powershell generaLog.ps1
# Si no, al salir con Ctrl-C el fichero queda bloqueado
# por la sesión de Powershell que lo empezó a ejecutar
# --------------------------------------------------

# Para poner textos en los mensajes
$trivium = @(
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
	"Aliquam elementum consequat arcu, vitae gravida diam porta ac.",
	"Phasellus est erat, ornare nec dolor at, porta laoreet erat.",
	"Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
	"Etiam tincidunt arcu in purus sollicitudin vehicula.",
	"Suspendisse ut libero vel risus vestibulum accumsan.",
	"Suspendisse potenti.",
	"Vestibulum laoreet libero ut lacus cursus scelerisque in ut justo.",
	"Duis ac volutpat ligula.",
	"Duis iaculis, lectus at ullamcorper accumsan, arcu elit pharetra orci, a finibus augue nibh aliquam arcu.",
	"Praesent eros orci, accumsan placerat cursus at, tempus vitae nulla.",
	"Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Duis laoreet at eros aliquet dictum.",
	"Proin scelerisque viverra elit, eu luctus elit vulputate mollis.",
	"Sed nec quam at est lacinia hendrerit.",
	"Nullam in ullamcorper dui.",
	"Duis mattis dolor a dolor feugiat semper.",
	"Proin mollis porttitor hendrerit.",
	"Sed id tempor risus.",
	"Proin facilisis sed metus porttitor scelerisque.",
	"Pellentesque porta gravida lorem non pellentesque.",
	"Nulla malesuada arcu non bibendum viverra.",
	"Suspendisse pellentesque lorem turpis, vel ullamcorper purus faucibus quis."
);
$quadrivium = @(
	"Aenean fringilla non ligula a rutrum.",
	"In sit amet lectus arcu.",
	"Nulla consequat at mi nec iaculis.",
	"Fusce accumsan ipsum metus, a efficitur nisl maximus at.",
	"Quisque fringilla tempor nulla.",
	"Cras luctus sem at nisl ornare sollicitudin.",
	"Vestibulum aliquet ipsum et mi dignissim interdum.",
	"Sed felis augue, tempus eget fermentum ut, venenatis sed lacus.",
	"Quisque faucibus odio erat, sed laoreet dolor porttitor a.",
	"Mauris dignissim, urna sed interdum consectetur, tellus nulla consectetur nisi, vel cursus mi odio eget enim.",
	"Fusce eu lorem quis dolor interdum semper quis in justo.",
	"Donec auctor ultrices mauris.",
	"Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Suspendisse vitae dignissim turpis.",
	"Curabitur lacus diam, ullamcorper nec suscipit a, auctor vitae ante.",
	"Sed vel ipsum non orci tristique maximus.",
	"Ut et tincidunt urna.",
	"Quisque imperdiet erat mauris, vitae pretium lorem efficitur scelerisque.",
	"Morbi sem erat, consequat eu dignissim vel, porta et sem.",
	"Nullam viverra pulvinar libero in pretium.",
	"Phasellus at est ac mauris aliquet gravida.",
	"Curabitur id dapibus eros.",
	"Etiam maximus auctor massa, id maximus mi mattis et.",
	"Nunc eget mi lorem.",
	"Sed egestas id nibh dapibus feugiat.",
	"Aenean eget luctus velit, at tempor odio.",
	"Etiam pellentesque dapibus elit, id pharetra sem.",
	"Aliquam quis orci placerat, rutrum dolor consectetur, auctor ante.",
	"Praesent tempus, ex at tristique sollicitudin, turpis turpis ultricies nisi, venenatis consectetur leo augue et lacus.",
	"Nam congue elementum nisi, id hendrerit velit volutpat eu.",
	"Cras consectetur lacinia leo nec porttitor.",
	"Integer pellentesque nulla ac posuere varius.",
	"Sed non augue condimentum, varius nisi at, laoreet orci.",
	"Fusce bibendum urna eu odio hendrerit, quis cursus neque sagittis."
);

# Tiempo entre mensajes de log
$sleepTime=2

# Fichero de transcripcion (log)
$logFile = "log\\generated.log"
Start-Transcript -append $logFile

# Lazo de generación de mensajes de log
for ($i=0; $true; $i++) {
	$now = Get-Date
	
	$msg="Doin' stuff'n'shit"
	if ( ($i%3) -eq 0 ) {
		$msg= $trivium[ $i % $trivium.Count ]
		$msg= "TRIVIUM: $msg"
	}
	if ( ($i%4) -eq 0 ) {
		$msg= $quadrivium[ $i % $quadrivium.Count ]
		$msg= "QUADRIVIUM: $msg"
	}
	
	Write-Output "$now - $i - $msg"
	sleep $sleepTime
}

# Por si alguna vez salimos sin Ctrl-C
Stop-Transcript $logFile
