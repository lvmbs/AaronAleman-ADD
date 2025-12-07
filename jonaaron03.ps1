# PARÁMETROS DEL SCRIPT
# [GENERADO POR IA - Sin modificaciones]
param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# ============================================================================
# BLOQUE 1: VALIDACIÓN DE PARÁMETROS
# [GENERADO POR IA - Modificado para mejorar mensajes de error]
# ============================================================================

# Verificar que se pasa exactamente un parámetro
if (-not $FilePath) {
    Write-Host "❌ ERROR: Debe proporcionar un archivo como parámetro" -ForegroundColor Red
    Write-Host ""
    Write-Host "Uso correcto:" -ForegroundColor Yellow
    Write-Host "  .\Jonaaron03.ps <ruta_archivo>" -ForegroundColor Cyan
    Write-Host "  .\Jonaaron03.ps <ruta_archivo> -DryRun" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ejemplo:" -ForegroundColor Yellow
    Write-Host "  .\Jonaaron03.ps C:\bajas.txt" -ForegroundColor Cyan
    exit 1
}

# Verificar que el archivo existe
if (-not (Test-Path $FilePath)) {
    Write-Host "❌ ERROR: El archivo '$FilePath' no existe" -ForegroundColor Red
    Write-Host "Verifique la ruta y vuelva a intentarlo" -ForegroundColor Yellow
    exit 1
}

# Verificar que es un archivo y no un directorio
if (-not (Test-Path $FilePath -PathType Leaf)) {
    Write-Host "❌ ERROR: '$FilePath' no es un archivo válido" -ForegroundColor Red
    Write-Host "La ruta proporcionada corresponde a un directorio" -ForegroundColor Yellow
    exit 1
}

# ============================================================================
# BLOQUE 2: CONFIGURACIÓN DE RUTAS Y LOGS
# [GENERADO POR IA - Sin modificaciones]
# ============================================================================

# Rutas de logs
$logDir = if ($env:SystemRoot) { "$env:SystemRoot\Logs" } else { "C:\Logs" }
$logBajas = Join-Path $logDir "bajas.log"
$logErrores = Join-Path $logDir "bajaserror.log"

# Crear directorio de logs si no existe
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Carpeta base de proyectos
$carpetaProyecto = "C:\Users\proyecto"

# Crear carpeta proyecto si no existe
if (-not (Test-Path $carpetaProyecto)) {
    New-Item -Path $carpetaProyecto -ItemType Directory -Force | Out-Null
}

# ============================================================================
# BLOQUE 3: FUNCIÓN DE REGISTRO EN LOGS
# [ESCRITO MANUALMENTE - Para estandarizar el formato de logs]
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [string]$LogFile,
        [string]$Type = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8
}

# ============================================================================
# BLOQUE 4: FUNCIÓN PARA CAMBIAR PROPIETARIO
# [GENERADO POR IA - Modificado para agregar validaciones]
# ============================================================================

function Set-FolderOwner {
    param(
        [string]$Path,
        [string]$Owner = "BUILTIN\Administradores"
    )
    
    try {
        # Obtener el ACL actual
        $acl = Get-Acl $Path
        
        # Crear el objeto de cuenta de Windows
        $account = New-Object System.Security.Principal.NTAccount($Owner)
        
        # Cambiar el propietario
        $acl.SetOwner($account)
        
        # Aplicar el ACL modificado
        Set-Acl -Path $Path -AclObject $acl
        
        return $true
    }
    catch {
        Write-Host "  ⚠️  Error al cambiar propietario: $_" -ForegroundColor Yellow
        return $false
    }
}

# ============================================================================
# BLOQUE 5: FUNCIÓN PRINCIPAL DE PROCESAMIENTO DE BAJAS
# [GENERADO POR IA - Modificado extensamente para mejorar manejo de errores]
# ============================================================================

function Process-UserBaja {
    param(
        [string]$Nombre,
        [string]$Apellido1,
        [string]$Apellido2,
        [string]$Login,
        [bool]$DryRunMode
    )
    
    $nombreCompleto = "$Nombre $Apellido1 $Apellido2"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "👤 Procesando: $nombreCompleto ($Login)" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    # Verificar que el usuario existe en AD
    try {
        $usuario = Get-ADUser -Identity $Login -ErrorAction Stop
        Write-Host "✓ Usuario encontrado en Active Directory" -ForegroundColor Green
    }
    catch {
        $errorMsg = "$timestamp-$Login-$nombreCompleto-Usuario no existe en Active Directory"
        Write-Log -Message $errorMsg -LogFile $logErrores -Type "ERROR"
        Write-Host "❌ Usuario NO existe en Active Directory" -ForegroundColor Red
        return $false
    }
    
    # MODO DRY-RUN: Solo mostrar acciones sin ejecutar
    if ($DryRunMode) {
        Write-Host "`n🔍 MODO SIMULACIÓN (-dryrun) - No se ejecutarán cambios" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Se realizarían las siguientes acciones:" -ForegroundColor Cyan
        Write-Host "  1. Crear carpeta: $carpetaProyecto\$Login" -ForegroundColor White
        Write-Host "  2. Mover archivos desde: C:\Users\$Login\trabajo" -ForegroundColor White
        Write-Host "  3. Cambiar propietario a: Administrador" -ForegroundColor White
        Write-Host "  4. Registrar operación en: $logBajas" -ForegroundColor White
        Write-Host "  5. Eliminar usuario: $Login" -ForegroundColor White
        Write-Host "  6. Eliminar directorio: C:\Users\$Login" -ForegroundColor White
        Write-Host ""
        return $true
    }
    
    # Crear carpeta destino
    $carpetaDestino = Join-Path $carpetaProyecto $Login
    try {
        if (-not (Test-Path $carpetaDestino)) {
            New-Item -Path $carpetaDestino -ItemType Directory -Force | Out-Null
            Write-Host "✓ Carpeta destino creada: $carpetaDestino" -ForegroundColor Green
        } else {
            Write-Host "✓ Carpeta destino ya existe: $carpetaDestino" -ForegroundColor Green
        }
    }
    catch {
        $errorMsg = "$timestamp-$Login-$nombreCompleto-Error al crear carpeta destino: $_"
        Write-Log -Message $errorMsg -LogFile $logErrores -Type "ERROR"
        Write-Host "❌ Error al crear carpeta destino" -ForegroundColor Red
        return $false
    }
    
    # Verificar carpeta trabajo
    $carpetaTrabajo = "C:\Users\$Login\trabajo"
    if (-not (Test-Path $carpetaTrabajo)) {
        $errorMsg = "$timestamp-$Login-$nombreCompleto-No existe carpeta trabajo"
        Write-Log -Message $errorMsg -LogFile $logErrores -Type "WARNING"
        Write-Host "⚠️  No existe la carpeta trabajo: $carpetaTrabajo" -ForegroundColor Yellow
        Write-Host "  Continuando con la eliminación del usuario..." -ForegroundColor Yellow
    }
    else {
        # Mover archivos
        try {
            $archivos = Get-ChildItem -Path $carpetaTrabajo -File
            $archivosList = @()
            $contador = 0
            
            Write-Host ""
            Write-Host "📁 Moviendo archivos..." -ForegroundColor Cyan
            
            foreach ($archivo in $archivos) {
                $destino = Join-Path $carpetaDestino $archivo.Name
                Move-Item -Path $archivo.FullName -Destination $destino -Force
                $contador++
                $archivosList += "  $contador. $($archivo.Name)"
                Write-Host "  ➜ $($archivo.Name)" -ForegroundColor Gray
            }
            
            Write-Host "✓ Total de archivos movidos: $contador" -ForegroundColor Green
            
            # Cambiar propietario
            Write-Host ""
            Write-Host "🔐 Cambiando propietario..." -ForegroundColor Cyan
            $ownerChanged = Set-FolderOwner -Path $carpetaDestino
            if ($ownerChanged) {
                Write-Host "✓ Propietario cambiado a Administrador" -ForegroundColor Green
            }
            
            # Registrar en bajas.log
            $logEntry = @"

═══════════════════════════════════════════════════════════════
BAJA DE USUARIO PROCESADA EXITOSAMENTE
═══════════════════════════════════════════════════════════════
Fecha y Hora    : $timestamp
Login           : $Login
Nombre Completo : $nombreCompleto
Carpeta Destino : $carpetaDestino

Archivos Movidos:
$($archivosList -join "`n")

Total de archivos: $contador
═══════════════════════════════════════════════════════════════

"@
            Add-Content -Path $logBajas -Value $logEntry -Encoding UTF8
            Write-Host "✓ Registro agregado a bajas.log" -ForegroundColor Green
        }
        catch {
            $errorMsg = "$timestamp-$Login-$nombreCompleto-Error al mover archivos: $_"
            Write-Log -Message $errorMsg -LogFile $logErrores -Type "ERROR"
            Write-Host "❌ Error al mover archivos" -ForegroundColor Red
        }
    }
    
    # Eliminar usuario de AD
    try {
        Write-Host ""
        Write-Host "🗑️  Eliminando usuario del sistema..." -ForegroundColor Cyan
        Remove-ADUser -Identity $Login -Confirm:$false -ErrorAction Stop
        Write-Host "✓ Usuario eliminado de Active Directory" -ForegroundColor Green
    }
    catch {
        $errorMsg = "$timestamp-$Login-$nombreCompleto-Error al eliminar usuario de AD: $_"
        Write-Log -Message $errorMsg -LogFile $logErrores -Type "ERROR"
        Write-Host "❌ Error al eliminar usuario de AD" -ForegroundColor Red
        return $false
    }
    
    # Eliminar directorio personal
    $directorioPersonal = "C:\Users\$Login"
    if (Test-Path $directorioPersonal) {
        try {
            Remove-Item -Path $directorioPersonal -Recurse -Force -ErrorAction Stop
            Write-Host "✓ Directorio personal eliminado" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠️  No se pudo eliminar completamente el directorio personal" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "✅ Baja completada exitosamente" -ForegroundColor Green
    return $true
}

# ============================================================================
# BLOQUE 6: PROGRAMA PRINCIPAL
# [GENERADO POR IA]
# ============================================================================

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          SCRIPT DE BAJAS DE USUARIOS - JONAARON03         ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "⚠️  MODO SIMULACIÓN ACTIVADO (-dryrun)" -ForegroundColor Yellow
    Write-Host "   No se realizarán cambios en el sistema" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "📄 Archivo de bajas: $FilePath" -ForegroundColor White
Write-Host "📁 Carpeta proyecto: $carpetaProyecto" -ForegroundColor White
Write-Host "📋 Log de bajas: $logBajas" -ForegroundColor White
Write-Host "📋 Log de errores: $logErrores" -ForegroundColor White
Write-Host ""

# Importar módulo de Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "✓ Módulo Active Directory cargado" -ForegroundColor Green
}
catch {
    Write-Host "❌ ERROR: No se pudo cargar el módulo Active Directory" -ForegroundColor Red
    Write-Host "Asegúrese de ejecutar el script en un controlador de dominio" -ForegroundColor Yellow
    exit 1
}

# Contadores
$totalProcesados = 0
$exitosos = 0
$errores = 0

# Leer archivo y procesar línea por línea
Write-Host ""
Write-Host "🔄 Iniciando procesamiento de bajas..." -ForegroundColor Cyan
Write-Host ""

$lineas = Get-Content $FilePath -Encoding UTF8

foreach ($linea in $lineas) {
    # Ignorar líneas vacías
    if ([string]::IsNullOrWhiteSpace($linea)) {
        continue
    }
    
    $totalProcesados++
    
    # Separar campos
    $campos = $linea.Split(':')
    
    # Validar formato
    if ($campos.Count -ne 4) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $errorMsg = "$timestamp-DESCONOCIDO-$linea-Formato incorrecto (debe ser nombre:apellido1:apellido2:login)"
        Write-Log -Message $errorMsg -LogFile $logErrores -Type "ERROR"
        Write-Host "❌ Línea con formato incorrecto: $linea" -ForegroundColor Red
        $errores++
        continue
    }
    
    # Procesar baja
    $resultado = Process-UserBaja -Nombre $campos[0] -Apellido1 $campos[1] -Apellido2 $campos[2] -Login $campos[3] -DryRunMode $DryRun
    
    if ($resultado) {
        $exitosos++
    } else {
        $errores++
    }
}

# Resumen final
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    RESUMEN DE EJECUCIÓN                   ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Total procesados : $totalProcesados" -ForegroundColor White
Write-Host "Exitosos         : $exitosos" -ForegroundColor Green
Write-Host "Errores          : $errores" -ForegroundColor $(if ($errores -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($DryRun) {
    Write-Host "ℹ️  Este fue un modo de simulación. No se realizaron cambios." -ForegroundColor Cyan
} else {
    Write-Host "✓ Proceso completado. Revise los logs para más detalles." -ForegroundColor Green
}

Write-Host ""
