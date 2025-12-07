# ========================================
# PARÁMETROS DEL SCRIPT
# ========================================
# [GENERADO POR IA - ESTRUCTURA BASE]
param(
    [Parameter(Mandatory=$false)]
    [string]$Accion,
    
    [Parameter(Mandatory=$false)]
    [string]$Parametro2,
    
    [Parameter(Mandatory=$false)]
    [string]$Parametro3,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# [ESCRITO MANUALMENTE]
# Variable global para controlar el modo DryRun en todas las funciones
$ModoSimulacion = $DryRun

# ========================================
# FUNCIÓN: Mostrar-Ayuda
# ========================================
# [MODIFICADO MANUALMENTE - Personalizado con ejemplos y formato]
function Mostrar-Ayuda {
    Write-Host "`n=====================================" -ForegroundColor Cyan
    Write-Host "  SCRIPT DE ADMINISTRACIÓN ADD" -ForegroundColor Cyan
    Write-Host "  jonaaron02.ps1" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    
    Write-Host "`nDebe añadir parámetros para usar este script.`n" -ForegroundColor Yellow
    
    Write-Host "ACCIONES DISPONIBLES:" -ForegroundColor Green
    
    Write-Host "`n[1] -G : Crear un grupo" -ForegroundColor White
    Write-Host "     Parámetro 2: Ámbito (Global, Universal, DomainLocal)"
    Write-Host "     Parámetro 3: Tipo (Security, Distribution)"
    Write-Host "     Ejemplo: .\jonaaron02.ps1 -Accion G -Parametro2 Global -Parametro3 Security"
    
    Write-Host "`n[2] -U : Crear un usuario" -ForegroundColor White
    Write-Host "     Parámetro 2: Nombre del usuario"
    Write-Host "     Parámetro 3: Unidad Organizativa (Distinguished Name)"
    Write-Host "     Ejemplo: .\jonaaron02.ps1 -Accion U -Parametro2 jperez -Parametro3 'OU=Usuarios,DC=empresa,DC=local'"
    
    Write-Host "`n[3] -M : Modificar usuario (contraseña y estado)" -ForegroundColor White
    Write-Host "     Parámetro 2: Nueva contraseña"
    Write-Host "     Parámetro 3: Estado (Habilitar / Deshabilitar)"
    Write-Host "     Ejemplo: .\jonaaron02.ps1 -Accion M -Parametro2 'P@ssw0rd123' -Parametro3 Habilitar"
    
    Write-Host "`n[4] -AG : Asignar usuario a grupo" -ForegroundColor White
    Write-Host "     Parámetro 2: Nombre del usuario"
    Write-Host "     Parámetro 3: Nombre del grupo"
    Write-Host "     Ejemplo: .\jonaaron02.ps1 -Accion AG -Parametro2 jperez -Parametro3 'Ventas'"
    
    Write-Host "`n[5] -LIST : Listar objetos del dominio" -ForegroundColor White
    Write-Host "     Parámetro 2: Tipo (Usuarios / Grupos / Ambos)"
    Write-Host "     Parámetro 3: Filtro por UO (opcional)"
    Write-Host "     Ejemplo: .\jonaaron02.ps1 -Accion LIST -Parametro2 Usuarios"
    Write-Host "     Ejemplo: .\jonaaron02.ps1 -Accion LIST -Parametro2 Ambos -Parametro3 'OU=Ventas,DC=empresa,DC=local'"
    
    Write-Host "`n[MODO SIMULACIÓN] --dry-run" -ForegroundColor Magenta
    Write-Host "     Muestra las acciones sin ejecutarlas realmente"
    Write-Host "     Ejemplo: .\jonaaron02.ps1 -Accion G -Parametro2 Global -Parametro3 Security -dryrun"
    
    Write-Host "`n=====================================" -ForegroundColor Cyan
    Write-Host ""
}

# ========================================
# FUNCIÓN: Escribir-Log
# ========================================
# [MODIFICADO MANUALMENTE - Añadidos colores personalizados]
function Escribir-Log {
    param(
        [string]$Mensaje,
        [string]$Tipo = "Info"  # Puede ser: Info, Exito, Error, Advertencia, Simulacion
    )
    
    # Seleccionar color según el tipo de mensaje
    switch ($Tipo) {
        "Info"        { $Color = "White" }
        "Exito"       { $Color = "Green" }
        "Error"       { $Color = "Red" }
        "Advertencia" { $Color = "Yellow" }
        "Simulacion"  { $Color = "Magenta" }
        default       { $Color = "White" }
    }
    
    # Si estamos en modo simulación, añadir prefijo [SIMULACIÓN]
    if ($ModoSimulacion -and $Tipo -ne "Simulacion") {
        Write-Host "[SIMULACIÓN] $Mensaje" -ForegroundColor $Color
    }
    else {
        Write-Host $Mensaje -ForegroundColor $Color
    }
}

# ========================================
# FUNCIÓN: Generar-ContrasenaAleatoria
# ========================================
# [GENERADO POR IA - COMPLETO]
function Generar-ContrasenaAleatoria {
    # Definimos los diferentes conjuntos de caracteres
    $Mayusculas = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $Minusculas = "abcdefghijklmnopqrstuvwxyz"
    $Numeros = "0123456789"
    $Especiales = "!@#$%^&*"
    
    # Combinamos todos los caracteres posibles
    $TodosCaracteres = $Mayusculas + $Minusculas + $Numeros + $Especiales
    
    # Inicializamos la contraseña vacía
    $Contrasena = ""
    
    # Aseguramos que tenga al menos un carácter de cada tipo
    # Esto garantiza que cumpla los requisitos de complejidad
    $Contrasena += $Mayusculas[(Get-Random -Maximum $Mayusculas.Length)]
    $Contrasena += $Minusculas[(Get-Random -Maximum $Minusculas.Length)]
    $Contrasena += $Numeros[(Get-Random -Maximum $Numeros.Length)]
    $Contrasena += $Especiales[(Get-Random -Maximum $Especiales.Length)]
    
    # Completamos los 8 caracteres restantes (total 12)
    for ($i = 0; $i -lt 8; $i++) {
        $Contrasena += $TodosCaracteres[(Get-Random -Maximum $TodosCaracteres.Length)]
    }
    
    # Mezclamos todos los caracteres para que no estén en orden predecible
    $ContrasenaArray = $Contrasena.ToCharArray()
    $ContrasenaMezclada = ($ContrasenaArray | Get-Random -Count $ContrasenaArray.Length) -join ''
    
    return $ContrasenaMezclada
}

# ========================================
# FUNCIÓN: Validar-ComplejidadContrasena
# ========================================
# [GENERADO POR IA - COMPLETO]
function Validar-ComplejidadContrasena {
    param(
        [string]$Contrasena
    )
    
    # Verificamos cada requisito usando expresiones regulares
    # -cmatch es case-sensitive, -match no lo es
    $TieneMayuscula = $Contrasena -cmatch '[A-Z]'
    $TieneMinuscula = $Contrasena -cmatch '[a-z]'
    $TieneNumero = $Contrasena -cmatch '[0-9]'
    $TieneEspecial = $Contrasena -match '[!@#$%^&*()_+\-=\[\]{};:,.<>?]'
    $LongitudCorrecta = $Contrasena.Length -ge 8
    
    # Array para almacenar los mensajes de error
    $Errores = @()
    
    # Añadimos mensajes específicos para cada requisito no cumplido
    if (-not $TieneMayuscula) {
        $Errores += "- Debe contener al menos una letra MAYÚSCULA"
    }
    if (-not $TieneMinuscula) {
        $Errores += "- Debe contener al menos una letra minúscula"
    }
    if (-not $TieneNumero) {
        $Errores += "- Debe contener al menos un número"
    }
    if (-not $TieneEspecial) {
        $Errores += "- Debe contener al menos un carácter especial (!@#$%^&*...)"
    }
    if (-not $LongitudCorrecta) {
        $Errores += "- Debe tener al menos 8 caracteres de longitud"
    }
    
    # Devolvemos un hashtable con el resultado de la validación
    return @{
        EsValida = ($Errores.Count -eq 0)
        Errores = $Errores
    }
}

# ========================================
# FUNCIÓN: Verificar-Existencia
# ========================================
# [GENERADO POR IA - COMPLETO]
function Verificar-Existencia {
    param(
        [string]$TipoObjeto,
        [string]$NombreObjeto
    )
    
    try {
        if ($TipoObjeto -eq "Usuario") {
            Get-ADUser -Identity $NombreObjeto -ErrorAction Stop | Out-Null
            return $true
        }
        elseif ($TipoObjeto -eq "Grupo") {
            Get-ADGroup -Identity $NombreObjeto -ErrorAction Stop | Out-Null
            return $true
        }
        else {
            return $false
        }
    }
    catch {
        return $false
    }
}

# ========================================
# FUNCIÓN: Crear-Grupo (-G)
# ========================================
# [GENERADO POR IA - Validaciones] + [MODIFICADO MANUALMENTE - Mensajes y lógica dry-run]
function Crear-Grupo {
    param(
        [string]$Ambito,
        [string]$TipoGrupo
    )
    
    Escribir-Log "`n=== CREAR GRUPO ===" "Info"
    
    # Validar que el ámbito sea correcto
    $AmbitosValidos = @("Global", "Universal", "DomainLocal")
    if ($Ambito -notin $AmbitosValidos) {
        Escribir-Log "ERROR: El ámbito '$Ambito' no es válido." "Error"
        Escribir-Log "Ámbitos válidos: Global, Universal, DomainLocal" "Advertencia"
        return
    }
    
    # Validar que el tipo sea correcto
    $TiposValidos = @("Security", "Distribution")
    if ($TipoGrupo -notin $TiposValidos) {
        Escribir-Log "ERROR: El tipo '$TipoGrupo' no es válido." "Error"
        Escribir-Log "Tipos válidos: Security, Distribution" "Advertencia"
        return
    }
    
    # Solicitar el nombre del grupo
    $NombreGrupo = Read-Host "Ingrese el nombre del nuevo grupo"
    
    if ([string]::IsNullOrWhiteSpace($NombreGrupo)) {
        Escribir-Log "ERROR: El nombre del grupo no puede estar vacío." "Error"
        return
    }
    
    # Verificar si el grupo ya existe
    try {
        $GrupoExistente = Get-ADGroup -Identity $NombreGrupo -ErrorAction Stop
        Escribir-Log "El grupo '$NombreGrupo' ya existe en el sistema." "Advertencia"
        return
    }
    catch {
        # El grupo no existe, podemos continuar
        Escribir-Log "El grupo '$NombreGrupo' no existe. Procediendo con la creación..." "Info"
    }
    
    # Crear el grupo o simular la creación
    if ($ModoSimulacion) {
        Escribir-Log "Se crearía el grupo con los siguientes parámetros:" "Simulacion"
        Escribir-Log "  - Nombre: $NombreGrupo" "Simulacion"
        Escribir-Log "  - Ámbito: $Ambito" "Simulacion"
        Escribir-Log "  - Tipo: $TipoGrupo" "Simulacion"
    }
    else {
        try {
            New-ADGroup -Name $NombreGrupo -GroupScope $Ambito -GroupCategory $TipoGrupo
            Escribir-Log "✓ Grupo '$NombreGrupo' creado exitosamente." "Exito"
            Escribir-Log "  - Ámbito: $Ambito" "Exito"
            Escribir-Log "  - Tipo: $TipoGrupo" "Exito"
        }
        catch {
            Escribir-Log "ERROR al crear el grupo: $($_.Exception.Message)" "Error"
        }
    }
}

# ========================================
# FUNCIÓN: Crear-Usuario (-U)
# ========================================
# [GENERADO POR IA - Estructura base] + [MODIFICADO MANUALMENTE - Validaciones UO]
function Crear-Usuario {
    param(
        [string]$NombreUsuario,
        [string]$UnidadOrganizativa
    )
    
    Escribir-Log "`n=== CREAR USUARIO ===" "Info"
    
    # Validar que se hayan proporcionado los parámetros
    if ([string]::IsNullOrWhiteSpace($NombreUsuario)) {
        Escribir-Log "ERROR: Debe proporcionar un nombre de usuario." "Error"
        return
    }
    
    if ([string]::IsNullOrWhiteSpace($UnidadOrganizativa)) {
        Escribir-Log "ERROR: Debe proporcionar una Unidad Organizativa." "Error"
        return
    }
    
    # Verificar que la UO existe
    try {
        Get-ADOrganizationalUnit -Identity $UnidadOrganizativa -ErrorAction Stop | Out-Null
        Escribir-Log "Unidad Organizativa válida: $UnidadOrganizativa" "Info"
    }
    catch {
        Escribir-Log "ERROR: La Unidad Organizativa '$UnidadOrganizativa' no existe." "Error"
        return
    }
    
    # Verificar si el usuario ya existe
    try {
        $UsuarioExistente = Get-ADUser -Identity $NombreUsuario -ErrorAction Stop
        Escribir-Log "El usuario '$NombreUsuario' ya existe en el sistema." "Advertencia"
        return
    }
    catch {
        # El usuario no existe, podemos continuar
        Escribir-Log "El usuario '$NombreUsuario' no existe. Procediendo con la creación..." "Info"
    }
    
    # Generar contraseña aleatoria
    $ContrasenaAleatoria = Generar-ContrasenaAleatoria
    $ContrasenaSegura = ConvertTo-SecureString -String $ContrasenaAleatoria -AsPlainText -Force
    
    # Crear el usuario o simular la creación
    if ($ModoSimulacion) {
        Escribir-Log "Se crearía el usuario con los siguientes parámetros:" "Simulacion"
        Escribir-Log "  - Nombre: $NombreUsuario" "Simulacion"
        Escribir-Log "  - UO: $UnidadOrganizativa" "Simulacion"
        Escribir-Log "  - Contraseña: [GENERADA ALEATORIAMENTE]" "Simulacion"
        Escribir-Log "  - Estado: Habilitado" "Simulacion"
    }
    else {
        try {
            New-ADUser -Name $NombreUsuario `
                       -SamAccountName $NombreUsuario `
                       -UserPrincipalName "$NombreUsuario@$((Get-ADDomain).DNSRoot)" `
                       -Path $UnidadOrganizativa `
                       -AccountPassword $ContrasenaSegura `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true
            
            Escribir-Log "✓ Usuario '$NombreUsuario' creado exitosamente." "Exito"
            Escribir-Log "  - Ubicación: $UnidadOrganizativa" "Exito"
            Escribir-Log "  - Contraseña temporal: $ContrasenaAleatoria" "Advertencia"
            Escribir-Log "  - El usuario deberá cambiar la contraseña en el primer inicio de sesión." "Info"
        }
        catch {
            Escribir-Log "ERROR al crear el usuario: $($_.Exception.Message)" "Error"
        }
    }
}

# ========================================
# FUNCIÓN: Modificar-Usuario (-M)
# ========================================
# [GENERADO POR IA - Estructura try-catch] + [MODIFICADO MANUALMENTE - Lógica estados]
function Modificar-Usuario {
    param(
        [string]$NuevaContrasena,
        [string]$EstadoCuenta
    )
    
    Escribir-Log "`n=== MODIFICAR USUARIO ===" "Info"
    
    # Validar parámetros
    if ([string]::IsNullOrWhiteSpace($NuevaContrasena)) {
        Escribir-Log "ERROR: Debe proporcionar una contraseña." "Error"
        return
    }
    
    if ([string]::IsNullOrWhiteSpace($EstadoCuenta)) {
        Escribir-Log "ERROR: Debe especificar el estado (Habilitar/Deshabilitar)." "Error"
        return
    }
    
    # Validar el estado proporcionado
    if ($EstadoCuenta -notin @("Habilitar", "Deshabilitar")) {
        Escribir-Log "ERROR: El estado debe ser 'Habilitar' o 'Deshabilitar'." "Error"
        return
    }
    
    # Solicitar el nombre del usuario a modificar
    $NombreUsuario = Read-Host "Ingrese el nombre del usuario a modificar"
    
    if ([string]::IsNullOrWhiteSpace($NombreUsuario)) {
        Escribir-Log "ERROR: El nombre del usuario no puede estar vacío." "Error"
        return
    }
    
    # Verificar que el usuario existe
    try {
        $Usuario = Get-ADUser -Identity $NombreUsuario -ErrorAction Stop
        Escribir-Log "Usuario encontrado: $NombreUsuario" "Info"
    }
    catch {
        Escribir-Log "ERROR: El usuario '$NombreUsuario' no existe." "Error"
        return
    }
    
    # Validar complejidad de la contraseña
    $Validacion = Validar-ComplejidadContrasena -Contrasena $NuevaContrasena
    
    if (-not $Validacion.EsValida) {
        Escribir-Log "ERROR: La contraseña no cumple los requisitos de complejidad." "Error"
        foreach ($Error in $Validacion.Errores) {
            Escribir-Log "  $Error" "Error"
        }
        return
    }
    
    Escribir-Log "✓ La contraseña cumple todos los requisitos de complejidad." "Exito"
    
    # Modificar o simular la modificación
    if ($ModoSimulacion) {
        Escribir-Log "Se realizarían las siguientes modificaciones:" "Simulacion"
        Escribir-Log "  - Usuario: $NombreUsuario" "Simulacion"
        Escribir-Log "  - Nueva contraseña: [VÁLIDA]" "Simulacion"
        Escribir-Log "  - Estado de cuenta: $EstadoCuenta" "Simulacion"
    }
    else {
        try {
            # Cambiar la contraseña
            $ContrasenaSegura = ConvertTo-SecureString -String $NuevaContrasena -AsPlainText -Force
            Set-ADAccountPassword -Identity $NombreUsuario -Reset -NewPassword $ContrasenaSegura
            Escribir-Log "✓ Contraseña modificada exitosamente." "Exito"
            
            # Cambiar el estado de la cuenta
            if ($EstadoCuenta -eq "Habilitar") {
                Enable-ADAccount -Identity $NombreUsuario
                Escribir-Log "✓ Cuenta habilitada." "Exito"
            }
            else {
                Disable-ADAccount -Identity $NombreUsuario
                Escribir-Log "✓ Cuenta deshabilitada." "Exito"
            }
        }
        catch {
            Escribir-Log "ERROR al modificar el usuario: $($_.Exception.Message)" "Error"
        }
    }
}

# ========================================
# FUNCIÓN: Asignar-GrupoUsuario (-AG)
# ========================================
# [GENERADO POR IA - Estructura] + [MODIFICADO MANUALMENTE - Integración Verificar-Existencia]
function Asignar-GrupoUsuario {
    param(
        [string]$NombreUsuario,
        [string]$NombreGrupo
    )
    
    Escribir-Log "`n=== ASIGNAR USUARIO A GRUPO ===" "Info"
    
    # Validar parámetros
    if ([string]::IsNullOrWhiteSpace($NombreUsuario)) {
        Escribir-Log "ERROR: Debe proporcionar un nombre de usuario." "Error"
        return
    }
    
    if ([string]::IsNullOrWhiteSpace($NombreGrupo)) {
        Escribir-Log "ERROR: Debe proporcionar un nombre de grupo." "Error"
        return
    }
    
    # Verificar que el usuario existe
    if (-not (Verificar-Existencia -TipoObjeto "Usuario" -NombreObjeto $NombreUsuario)) {
        Escribir-Log "ERROR: El usuario '$NombreUsuario' no existe." "Error"
        return
    }
    
    Escribir-Log "✓ Usuario '$NombreUsuario' encontrado." "Exito"
    
    # Verificar que el grupo existe
    if (-not (Verificar-Existencia -TipoObjeto "Grupo" -NombreObjeto $NombreGrupo)) {
        Escribir-Log "ERROR: El grupo '$NombreGrupo' no existe." "Error"
        return
    }
    
    Escribir-Log "✓ Grupo '$NombreGrupo' encontrado." "Exito"
    
    # Asignar o simular la asignación
    if ($ModoSimulacion) {
        Escribir-Log "Se asignaría el usuario '$NombreUsuario' al grupo '$NombreGrupo'." "Simulacion"
    }
    else {
        try {
            Add-ADGroupMember -Identity $NombreGrupo -Members $NombreUsuario
            Escribir-Log "✓ Usuario '$NombreUsuario' asignado exitosamente al grupo '$NombreGrupo'." "Exito"
        }
        catch {
            Escribir-Log "ERROR al asignar usuario al grupo: $($_.Exception.Message)" "Error"
        }
    }
}

# ========================================
# FUNCIÓN: Listar-Objetos (-LIST)
# ========================================
# [GENERADO POR IA - Estructura de filtros] + [MODIFICADO MANUALMENTE - Formato de salida]
function Listar-Objetos {
    param(
        [string]$TipoListado,
        [string]$FiltroUO
    )
    
    Escribir-Log "`n=== LISTAR OBJETOS ===" "Info"
    
    # Validar el tipo de listado
    if ($TipoListado -notin @("Usuarios", "Grupos", "Ambos")) {
        Escribir-Log "ERROR: El tipo debe ser 'Usuarios', 'Grupos' o 'Ambos'." "Error"
        return
    }
    
    # Preparar parámetros de búsqueda
    $ParametrosBusqueda = @{}
    
    if (-not [string]::IsNullOrWhiteSpace($FiltroUO)) {
        # Verificar que la UO existe
        try {
            Get-ADOrganizationalUnit -Identity $FiltroUO -ErrorAction Stop | Out-Null
            $ParametrosBusqueda['SearchBase'] = $FiltroUO
            Escribir-Log "Filtrando por UO: $FiltroUO" "Info"
        }
        catch {
            Escribir-Log "ERROR: La Unidad Organizativa '$FiltroUO' no existe." "Error"
            return
        }
    }
    
    # Listar según el tipo solicitado
    if ($TipoListado -eq "Usuarios" -or $TipoListado -eq "Ambos") {
        Write-Host "`n--- USUARIOS ---" -ForegroundColor Cyan
        try {
            $Usuarios = Get-ADUser -Filter * @ParametrosBusqueda -Properties Name, SamAccountName, Enabled |
                        Select-Object Name, SamAccountName, Enabled |
                        Sort-Object Name
            
            if ($Usuarios.Count -gt 0) {
                $Usuarios | Format-Table -AutoSize
                Escribir-Log "Total de usuarios encontrados: $($Usuarios.Count)" "Info"
            }
            else {
                Escribir-Log "No se encontraron usuarios." "Advertencia"
            }
        }
        catch {
            Escribir-Log "ERROR al listar usuarios: $($_.Exception.Message)" "Error"
        }
    }
    
    if ($TipoListado -eq "Grupos" -or $TipoListado -eq "Ambos") {
        Write-Host "`n--- GRUPOS ---" -ForegroundColor Cyan
        try {
            $Grupos = Get-ADGroup -Filter * @ParametrosBusqueda -Properties Name, GroupScope, GroupCategory |
                      Select-Object Name, GroupScope, GroupCategory |
                      Sort-Object Name
            
            if ($Grupos.Count -gt 0) {
                $Grupos | Format-Table -AutoSize
                Escribir-Log "Total de grupos encontrados: $($Grupos.Count)" "Info"
            }
            else {
                Escribir-Log "No se encontraron grupos." "Advertencia"
            }
        }
        catch {
            Escribir-Log "ERROR al listar grupos: $($_.Exception.Message)" "Error"
        }
    }
}

# ========================================
# FLUJO PRINCIPAL DEL PROGRAMA
# ========================================
# [MODIFICADO MANUALMENTE - Reorganizado para mejor legibilidad]

# Verificar modo DryRun
if ($DryRun) {
    Escribir-Log "`n========================================" "Simulacion"
    Escribir-Log "   MODO SIMULACIÓN ACTIVADO" "Simulacion"
    Escribir-Log "   No se realizarán cambios reales"
    Escribir-Log "========================================`n" "Simulacion"
}

# Switch principal según acción
switch ($Accion) {
    "" {
        # Sin acción: Mostrar ayuda
        Mostrar-Ayuda
    }
    
    "G" {
        # Llamar a Crear-Grupo con Parametro2 y Parametro3
        Crear-Grupo -Ambito $Parametro2 -TipoGrupo $Parametro3
    }
    
    "U" {
        # Llamar a Crear-Usuario con Parametro2 y Parametro3
        Crear-Usuario -NombreUsuario $Parametro2 -UnidadOrganizativa $Parametro3
    }
    
    "M" {
        # Llamar a Modificar-Usuario con Parametro2 y Parametro3
        Modificar-Usuario -NuevaContrasena $Parametro2 -EstadoCuenta $Parametro3
    }
    
    "AG" {
        # Llamar a Asignar-GrupoUsuario con Parametro2 y Parametro3
        Asignar-GrupoUsuario -NombreUsuario $Parametro2 -NombreGrupo $Parametro3
    }
    
    "LIST" {
        # Llamar a Listar-Objetos con Parametro2 y Parametro3
        Listar-Objetos -TipoListado $Parametro2 -FiltroUO $Parametro3
    }
    
    default {
        # Acción no reconocida: Mostrar ayuda
        Escribir-Log "`nACCIÓN NO RECONOCIDA: '$Accion'" "Error"
        Mostrar-Ayuda
    }
}

# Fin del script
Write-Host ""
