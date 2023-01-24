# Aternity event generation

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

Aquí muestran un ejemplo para detectar si el servicio CCMEXEC está parado.

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
Al cliente le interesa obtener dos cosas:

- Generar un evento cuando el consumo de CPU del sistema llegue a un porcentaje
- Generar un evento cuando un proceso de Windows consuma un determinado porcentaje.