# logfile2windowsevent
Scan a live log file and generate windows events when a log file line contains a certain text.

# Objetivo

Esta utilidad monitoriza un **fichero vivo de log de aplicación**, 
y si en una nueva línea encuentra un patrón determinado de texto 
generará un **evento** en un **log de Windows** del **registro de eventos Windows**.

# Definiciones

- **Fichero vivo de log de aplicación**:
	- El fichero de texto plano donde una aplicación anota su actividad generando una nueva línea descriptiva de cada acción significativa que realice o resultado inesperado que obtenga.
	- Este fichero está abierto y bloqueado por la aplicación mientras esta ejecute, permitiendo sólo la lectura.
- **Registro de eventos Windows**:
	- Cada ocurrencia de un evento (acción, error de un programa o de un servicio, inicio de sesión, etc.) se recoge en los registros de Windows. Estos son el equivalente de los logs para el sistema operativo. Así, la información contenida permite resolver problemas en Windows y también en otros programas instalados en el equipo.
	- Internamente se organiza en diversos **logs de Windows** dentro de cada uno de los cuales los eventos se pueden asociar a diversos **orígenes** y **Categorías**
- **Log de Windows**
	- Primer nivel de clasificación lógica de los **eventos ** en el **registro de eventos Windows**.
- **Origen de eventos**
	- Atributo de un **evento** en el **registro de eventos Windows** que constituye el segundo nivel de clasificación de eventos. Se asocia a una aplicación, módulo de software, etc.
	- Dentro de un **log de Windows** se puede definir al menos una origen.
	- En inglés, *source*.
- **Categoría de eventos**
	- Atributo de un **evento** en el **registro de eventos Windows** que permite clasificar eventos si se usa. 
	- Para definir categorías de eventos es necesario crear un *category message file*, compilarlo a fichero de recursos con una primera herramienta de desarrollo, y transformar este fichero de recursos en una DLL con una segunda herramienta de desarrollo.
	- Este script de monitorización de ficheros de log y generación de eventos usa solo las herramientas de Windows por defecto (PowerShell) y de momento no entra al uso de categorías en aras de la simplicidad de uso.
- **Visor de eventos de Windows**:
	- Aplicación de sistema de Windows que permite ver los diversos eventos en el registro.
- **Evento** 
	- Entrada lógica del **registro de eventos de Windows**.
	- Clasificado dentro de un **log de Windows** y un **origen de eventos**
	- Muestra estos atributos en el visor de eventos para un **log** y opcionalmente **origen** dados:
		- **Nivel** Gravedad del evento: Informativo, advertencia, error...
		- **Fecha y hora** Momento en que sucedió.
		- **Origen** Aplicación, módulo que causó el evento.
		- **Id. del evento** Identificador único del tipo de evento.
		- **Categoría**	Clasificación arbitraria del evento. Sin el uso de ficheros descriptivos de categorías compilados en DLL, los eventos insertados por este script mostrarán un número como categoría.
