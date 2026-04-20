# --- DETECCIÓN AUTOMÁTICA DE LA RUTA DEL DOMINIO ---
$rutaDominio = (Get-ADDomain).DistinguishedName
 
# --- FUNCIÓN 1: Mostrar información del dominio ---
function Mostrar-InfoDominio {
    Write-Host "`n===== INFORMACIÓN DEL DOMINIO =====" -ForegroundColor Cyan
 
    # Obtiene el nombre del equipo local
    $nombreEquipo = $env:COMPUTERNAME
 
    # Obtiene el nombre del dominio al que pertenece el equipo
    $nombreDominio = (Get-ADDomain).Name
 
    # Cuenta cuántas Unidades Organizativas hay en el dominio
    $numOUs = (Get-ADOrganizationalUnit -Filter *).Count
 
    # Cuenta cuántos grupos hay en el dominio
    $numGrupos = (Get-ADGroup -Filter *).Count
 
    # Cuenta cuántos usuarios hay en el dominio
    $numUsuarios = (Get-ADUser -Filter *).Count
 
    # Muestra toda la información por pantalla
    Write-Host "Equipo:   $nombreEquipo"
    Write-Host "Dominio:  $nombreDominio"
    Write-Host "OUs:      $numOUs"
    Write-Host "Grupos:   $numGrupos"
    Write-Host "Usuarios: $numUsuarios"
}
 
 
# --- FUNCIÓN 2: Crear una nueva Unidad Organizativa ---
function Crear-OU {
    Write-Host "`n===== CREAR UNIDAD ORGANIZATIVA =====" -ForegroundColor Cyan
 
    # Pide al usuario el nombre de la nueva OU.
    $nombreOU = Read-Host "Nombre de la nueva OU"
 
    # Crea la OU directamente en la raíz del dominio usando $rutaDominio
    New-ADOrganizationalUnit -Name $nombreOU -Path $rutaDominio
 
    Write-Host "OU '$nombreOU' creada en $rutaDominio" -ForegroundColor Green
}
 
 
# --- FUNCIÓN 3: Ver miembros de una OU ---
function Ver-MiembrosOU {
    Write-Host "`n===== MIEMBROS DE UNA OU =====" -ForegroundColor Cyan
 
    # Pide el nombre de la OU que se quiere consultar
    $nombreOU = Read-Host "Nombre de la OU"
 
    # Busca la OU dentro del dominio y guarda su ruta completa
    $ou = Get-ADOrganizationalUnit -Filter { Name -eq $nombreOU } -SearchBase $rutaDominio
 
    # Comprueba si la OU existe
    if ($ou -eq $null) {
        Write-Host "No se encontró ninguna OU con ese nombre." -ForegroundColor Red
        return
    }
 
    # Busca todos los usuarios que están dentro de esa OU
    $miembros = Get-ADUser -Filter * -SearchBase $ou.DistinguishedName
 
    # Muestra los miembros encontrados
    if ($miembros.Count -eq 0) {
        Write-Host "La OU está vacía o no tiene usuarios directos."
    } else {
        Write-Host "Usuarios en '$nombreOU':"
        $miembros | Select-Object Name, SamAccountName | Format-Table
    }
}
 
 
# --- FUNCIÓN 4: Crear un nuevo grupo ---
function Crear-Grupo {
    Write-Host "`n===== CREAR NUEVO GRUPO =====" -ForegroundColor Cyan
 
    # Pide el nombre del nuevo grupo
    $nombreGrupo = Read-Host "Nombre del grupo"
 
    # Pide el nombre de la OU donde se creará el grupo 
    $nombreOU = Read-Host "Nombre de la OU donde crear el grupo (Enter para raíz del dominio)"
 
    # Si el usuario no escribe nada, se usa la raíz del dominio
    # Si escribe una OU, se construye la ruta completa automáticamente
    if ($nombreOU -eq "") {
        $ruta = $rutaDominio
    } else {
        $ruta = "OU=$nombreOU,$rutaDominio"
    }
 
    # Crea el grupo como grupo de seguridad global
    New-ADGroup -Name $nombreGrupo -GroupScope Global -GroupCategory Security -Path $ruta
 
    Write-Host "Grupo '$nombreGrupo' creado en $ruta" -ForegroundColor Green
}
 
 
# --- FUNCIÓN 5: Crear un nuevo usuario ---
function Crear-Usuario {
    Write-Host "`n===== CREAR NUEVO USUARIO =====" -ForegroundColor Cyan
 
    # Solicita los datos básicos del nuevo usuario
    $nombre      = Read-Host "Nombre"
    $apellido    = Read-Host "Apellido"
    $loginName   = Read-Host "Nombre de inicio de sesión (SamAccountName)"
    $descripcion = Read-Host "Descripción (opcional, pulsa Enter para omitir)"
    $grupo       = Read-Host "Nombre del grupo al que añadir el usuario"
 
    # Pide el nombre de la OU donde se creará el usuario
    # La ruta completa se construye automáticamente con $rutaDominio
    $nombreOU = Read-Host "Nombre de la OU donde crear el usuario (Enter para raíz del dominio)"
 
    if ($nombreOU -eq "") {
        $ruta = $rutaDominio
    } else {
        $ruta = "OU=$nombreOU,$rutaDominio"
    }
 
    # Pide la contraseña de forma segura (no se muestra en pantalla)
    $password = Read-Host "Contraseña inicial" -AsSecureString
 
    # Crea el usuario con todos los datos introducidos
    # -ChangePasswordAtLogon obliga a cambiar la contraseña en el primer inicio de sesión
    New-ADUser `
        -GivenName $nombre `
        -Surname $apellido `
        -Name "$nombre $apellido" `
        -SamAccountName $loginName `
        -UserPrincipalName "$loginName@$((Get-ADDomain).DNSRoot)" `
        -Description $descripcion `
        -Path $ruta `
        -AccountPassword $password `
        -Enabled $true `
        -ChangePasswordAtLogon $true
 
    # Añade el usuario al grupo indicado
    Add-ADGroupMember -Identity $grupo -Members $loginName
 
    Write-Host "Usuario '$loginName' creado en $ruta y añadido al grupo '$grupo'." -ForegroundColor Green
}
 
 
# --- MENÚ PRINCIPAL ---
 
do {
    # Limpia la pantalla y muestra el menú
    # También muestra el dominio detectado para que el usuario sepa con qué dominio trabaja
    Clear-Host
    Write-Host "============================================" -ForegroundColor Yellow
    Write-Host "     GESTIÓN DE DOMINIO - MENÚ PRINCIPAL   " -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Yellow
    Write-Host "  Dominio: $rutaDominio" -ForegroundColor DarkCyan
    Write-Host "============================================" -ForegroundColor Yellow
    Write-Host "  1. Información del dominio"
    Write-Host "  2. Crear Unidad Organizativa"
    Write-Host "  3. Ver miembros de una OU"
    Write-Host "  4. Crear grupo"
    Write-Host "  5. Crear usuario"
    Write-Host "  0. Salir"
    Write-Host "============================================" -ForegroundColor Yellow
 
    # Lee la opción elegida por el usuario
    $opcion = Read-Host "Selecciona una opción"
 
    # Ejecuta la función correspondiente según la opción
    switch ($opcion) {
        "1" { Mostrar-InfoDominio }
        "2" { Crear-OU }
        "3" { Ver-MiembrosOU }
        "4" { Crear-Grupo }
        "5" { Crear-Usuario }
        "0" { Write-Host "Saliendo del script. Hasta luego." -ForegroundColor Cyan }
        default { Write-Host "Opción no válida. Inténtalo de nuevo." -ForegroundColor Red }
    }
 
    # Si no es la opción 0, pausa para que el usuario pueda leer el resultado
    if ($opcion -ne "0") {
        Write-Host "`nPulsa Enter para volver al menú..."
        Read-Host
    }
 
# El bucle se repite mientras la opción no sea "0"
} while ($opcion -ne "0")
