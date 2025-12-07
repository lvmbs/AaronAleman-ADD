# ============================================================================
# BLOQUE 1: CONFIGURACIÓN GLOBAL Y VARIABLES
# [ESCRITO MANUALMENTE - Definición de constantes y configuración del entorno]
# ============================================================================

# Configuración de errores
$ErrorActionPreference = "Continue"

# Variables globales de configuración
$SCRIPT_TO_TEST = ".\Jonaaron03.ps1"
$BAJAS_FILE = "C:\bajas_test.txt"
$LOG_DIR = "C:\Logs"
$PROYECTO_DIR = "C:\Users\proyecto"
$TEST_OU = "OU=Programadores,OU=Usuarios_Villa,DC=villaSL,DC=local"

# Variables de calificación
$totalPoints = 0
$maxPoints = 10
$errors = @()
$testResults = @()

# Usuarios de prueba (algunos existirán, otros no)
$testUsers = @(
    @{Nombre="TestUser1"; Apellido1="Prueba"; Apellido2="Uno"; Login="testuser1"; Existe=$true; NumArchivos=3},
    @{Nombre="TestUser2"; Apellido1="Prueba"; Apellido2="Dos"; Login="testuser2"; Existe=$true; NumArchivos=5},
    @{Nombre="TestUser3"; Apellido1="Prueba"; Apellido2="Tres"; Login="testuser3"; Existe=$true; NumArchivos=4},
    @{Nombre="NoExiste"; Apellido1="Usuario"; Apellido2="Falso"; Login="noexiste"; Existe=$false; NumArchivos=0}
)

# ============================================================================
# BLOQUE 2: FUNCIONES AUXILIARES
# [GENERADO POR IA - Modificado para mejorar mensajes y validaciones]
# ============================================================================

function Write-TestHeader {
    param([string]$Message)
    Write-Host "`n" -NoNewline
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Write-TestResult {
    param(
        [int]$TestNumber,
        [string]$TestName,
        [bool]$Passed,
        [string]$Expected = "",
        [string]$Actual = ""
    )
    
    $result = @{
        Number = $TestNumber
        Name = $TestName
        Passed = $Passed
        Expected = $Expected
        Actual = $Actual
    }
    
    $script:testResults += $result
    
    if ($Passed) {
        Write-Host "✓ PRUEBA $TestNumber`: $TestName" -ForegroundColor Green
        Write-Host "  Resultado: APROBADA (+1 punto)" -ForegroundColor Green
        $script:totalPoints++
    } else {
        Write-Host "✗ PRUEBA $TestNumber`: $TestName" -ForegroundColor Red
        Write-Host "  Resultado: FALLIDA (0 puntos)" -ForegroundColor Red
        if ($Expected) {
            Write-Host "  Esperado: $Expected" -ForegroundColor Yellow
            Write-Host "  Obtenido: $Actual" -ForegroundColor Yellow
        }
        
        $script:errors += @{
            Test = $TestNumber
            Name = $TestName
            Expected = $Expected
            Actual = $Actual
        }
    }
}

function Test-ADUserExists {
    param([string]$Login)
    try {
        $null = Get-ADUser -Identity $Login -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# ============================================================================
# BLOQUE 3: LIMPIEZA DEL ENTORNO PREVIO
# [GENERADO POR IA - Sin modificaciones]
# ============================================================================

function Clear-TestEnvironment {
    Write-TestHeader "LIMPIANDO ENTORNO PREVIO"
    
    # Eliminar usuarios de prueba si existen
    foreach ($user in $testUsers) {
        if ($user.Existe) {
            try {
                if (Test-ADUserExists -Login $user.Login) {
                    Remove-ADUser -Identity $user.Login -Confirm:$false -ErrorAction SilentlyContinue
                    Write-Host "  ✓ Usuario eliminado: $($user.Login)" -ForegroundColor Gray
                }
            } catch {
                Write-Host "  ! No se pudo eliminar: $($user.Login)" -ForegroundColor Yellow
            }
        }
    }
    
    # Eliminar directorios de usuarios
    foreach ($user in $testUsers) {
        $userDir = "C:\Users\$($user.Login)"
        if (Test-Path $userDir) {
            try {
                Remove-Item -Path $userDir -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "  ✓ Directorio eliminado: $userDir" -ForegroundColor Gray
            } catch {
                Write-Host "  ! No se pudo eliminar directorio: $userDir" -ForegroundColor Yellow
            }
        }
    }
    
    # Limpiar carpeta proyecto
    if (Test-Path $PROYECTO_DIR) {
        Get-ChildItem -Path $PROYECTO_DIR -Directory | ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Host "  ✓ Carpeta proyecto limpiada" -ForegroundColor Gray
    }
    
    # Eliminar logs anteriores
    if (Test-Path "$LOG_DIR\bajas.log") {
        Remove-Item "$LOG_DIR\bajas.log" -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "$LOG_DIR\bajaserror.log") {
        Remove-Item "$LOG_DIR\bajaserror.log" -Force -ErrorAction SilentlyContinue
    }
    
    # Eliminar archivo de bajas de prueba
    if (Test-Path $BAJAS_FILE) {
        Remove-Item $BAJAS_FILE -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "`n  ✓ Entorno limpiado correctamente" -ForegroundColor Green
}

# ============================================================================
# BLOQUE 4: PREPARACIÓN DEL ENTORNO DE PRUEBAS
# [GENERADO POR IA - Modificado para agregar más validaciones y estructura]
# ============================================================================

function Setup-TestEnvironment {
    Write-TestHeader "PREPARANDO ENTORNO DE PRUEBAS"
    
    # Importar módulo AD
    try {
        Import-Module ActiveDirectory -ErrorAction Stop
        Write-Host "  ✓ Módulo Active Directory cargado" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ ERROR: No se pudo cargar Active Directory" -ForegroundColor Red
        exit 1
    }
    
    # Verificar que existe la OU de pruebas
    try {
        $null = Get-ADOrganizationalUnit -Identity $TEST_OU -ErrorAction Stop
        Write-Host "  ✓ OU de pruebas encontrada: $TEST_OU" -ForegroundColor Green
    } catch {
        Write-Host "  ! Creando OU de pruebas..." -ForegroundColor Yellow
        # Intentar crear la estructura de OUs
        try {
            $domain = (Get-ADDomain).DistinguishedName
            New-ADOrganizationalUnit -Name "Usuarios_Villa" -Path $domain -ErrorAction SilentlyContinue
            New-ADOrganizationalUnit -Name "Programadores" -Path "OU=Usuarios_Villa,$domain" -ErrorAction SilentlyContinue
            Write-Host "  ✓ OUs creadas" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ ERROR: No se pudo crear la estructura de OUs" -ForegroundColor Red
            exit 1
        }
    }
    
    # Crear carpetas base
    if (-not (Test-Path $PROYECTO_DIR)) {
        New-Item -Path $PROYECTO_DIR -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path $LOG_DIR)) {
        New-Item -Path $LOG_DIR -ItemType Directory -Force | Out-Null
    }
    
    Write-Host "`n  Creando usuarios de prueba..." -ForegroundColor Cyan
    
    # Crear usuarios de prueba
    foreach ($user in $testUsers) {
        if ($user.Existe) {
            $login = $user.Login
            $nombreCompleto = "$($user.Nombre) $($user.Apellido1) $($user.Apellido2)"
            
            try {
                # Crear usuario en AD
                $password = ConvertTo-SecureString "Test123!" -AsPlainText -Force
                New-ADUser `
                    -Name $nombreCompleto `
                    -GivenName $user.Nombre `
                    -Surname "$($user.Apellido1) $($user.Apellido2)" `
                    -SamAccountName $login `
                    -UserPrincipalName "$login@villaSL.local" `
                    -AccountPassword $password `
                    -Enabled $true `
                    -Path $TEST_OU `
                    -ErrorAction Stop
                
                Write-Host "    ✓ Usuario creado: $login" -ForegroundColor Green
                
                # Crear directorio personal
                $userDir = "C:\Users\$login"
                New-Item -Path $userDir -ItemType Directory -Force | Out-Null
                
                # Crear carpeta trabajo
                $trabajoDir = "$userDir\trabajo"
                New-Item -Path $trabajoDir -ItemType Directory -Force | Out-Null
                
                # Crear archivos de prueba
                for ($i = 1; $i -le $user.NumArchivos; $i++) {
                    $fileName = "archivo_$i.txt"
                    $filePath = "$trabajoDir\$fileName"
                    $content = "Contenido de prueba del archivo $i`nUsuario: $login`nFecha: $(Get-Date)"
                    Set-Content -Path $filePath -Value $content -Force
                }
                
                Write-Host "      → Directorio personal creado con $($user.NumArchivos) archivos" -ForegroundColor Gray
                
            } catch {
                Write-Host "    ✗ Error al crear usuario $login`: $_" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "`n  ✓ Entorno de pruebas preparado" -ForegroundColor Green
}

# ============================================================================
# BLOQUE 5: CREACIÓN DEL ARCHIVO DE BAJAS
# [GENERADO POR IA - Sin modificaciones]
# ============================================================================

function Create-BajasFile {
    Write-TestHeader "CREANDO ARCHIVO DE BAJAS DE PRUEBA"
    
    $content = ""
    foreach ($user in $testUsers) {
        $line = "$($user.Nombre):$($user.Apellido1):$($user.Apellido2):$($user.Login)"
        $content += $line + "`n"
    }
    
    Set-Content -Path $BAJAS_FILE -Value $content.TrimEnd() -Encoding UTF8
    
    Write-Host "  ✓ Archivo creado: $BAJAS_FILE" -ForegroundColor Green
    Write-Host "`n  Contenido:" -ForegroundColor Cyan
    Get-Content $BAJAS_FILE | ForEach-Object {
        Write-Host "    $_" -ForegroundColor Gray
    }
}

# ============================================================================
# BLOQUE 6: EJECUCIÓN DE PRUEBAS
# [GENERADO POR IA - Modificado extensamente para agregar más verificaciones]
# ============================================================================

function Run-AllTests {
    Write-TestHeader "EJECUTANDO BATERÍA DE PRUEBAS"
    
    # ========================================================================
    # PRUEBA 1: Validación de parámetros
    # ========================================================================
    Write-Host "`n[1/10] Validación de parámetros de entrada..." -ForegroundColor Cyan
    try {
        $output = & powershell.exe -File $SCRIPT_TO_TEST 2>&1
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -ne 0 -or $output -match "ERROR.*parámetro") {
            Write-TestResult -TestNumber 1 -TestName "Validación de parámetros" -Passed $true
        } else {
            Write-TestResult -TestNumber 1 -TestName "Validación de parámetros" -Passed $false `
                -Expected "El script debe rechazar ejecución sin parámetros" `
                -Actual "El script no validó los parámetros correctamente"
        }
    } catch {
        Write-TestResult -TestNumber 1 -TestName "Validación de parámetros" -Passed $false `
            -Expected "El script debe ejecutarse y validar parámetros" `
            -Actual "Error al ejecutar el script: $_"
    }
    
    # ========================================================================
    # Ejecutar el script con el archivo de bajas
    # ========================================================================
    Write-Host "`n  Ejecutando script Jonaaron03.ps con archivo de bajas..." -ForegroundColor Yellow
    try {
        & powershell.exe -File $SCRIPT_TO_TEST -FilePath $BAJAS_FILE 2>&1 | Out-Null
        Write-Host "  ✓ Script ejecutado" -ForegroundColor Green
        Start-Sleep -Seconds 2  # Esperar a que se completen operaciones de AD
    } catch {
        Write-Host "  ✗ Error al ejecutar script: $_" -ForegroundColor Red
    }
    
    # ========================================================================
    # PRUEBA 2: Usuario existente procesado correctamente
    # ========================================================================
    Write-Host "`n[2/10] Verificando procesamiento de usuario existente..." -ForegroundColor Cyan
    $testUser = $testUsers | Where-Object { $_.Login -eq "testuser1" } | Select-Object -First 1
    $userExists = Test-ADUserExists -Login $testUser.Login
    
    if (-not $userExists) {
        Write-TestResult -TestNumber 2 -TestName "Procesamiento de usuario existente" -Passed $true
    } else {
        Write-TestResult -TestNumber 2 -TestName "Procesamiento de usuario existente" -Passed $false `
            -Expected "El usuario testuser1 debe ser eliminado de AD" `
            -Actual "El usuario testuser1 todavía existe en AD"
    }
    
    # ========================================================================
    # PRUEBA 3: Usuario inexistente registrado en log de errores
    # ========================================================================
    Write-Host "`n[3/10] Verificando manejo de usuario inexistente..." -ForegroundColor Cyan
    $errorLogPath = "$LOG_DIR\bajaserror.log"
    
    if (Test-Path $errorLogPath) {
        $errorLogContent = Get-Content $errorLogPath -Raw
        if ($errorLogContent -match "noexiste") {
            Write-TestResult -TestNumber 3 -TestName "Manejo de usuario inexistente" -Passed $true
        } else {
            Write-TestResult -TestNumber 3 -TestName "Manejo de usuario inexistente" -Passed $false `
                -Expected "Log de errores debe contener entrada para 'noexiste'" `
                -Actual "Log de errores no contiene entrada para usuario inexistente"
        }
    } else {
        Write-TestResult -TestNumber 3 -TestName "Manejo de usuario inexistente" -Passed $false `
            -Expected "Debe existir archivo bajaserror.log" `
            -Actual "Archivo bajaserror.log no fue creado"
    }
    
    # ========================================================================
    # PRUEBA 4: Carpetas destino creadas correctamente
    # ========================================================================
    Write-Host "`n[4/10] Verificando creación de carpetas destino..." -ForegroundColor Cyan
    $foldersCreated = 0
    $expectedFolders = ($testUsers | Where-Object { $_.Existe }).Count
    
    foreach ($user in $testUsers) {
        if ($user.Existe) {
            $destFolder = "$PROYECTO_DIR\$($user.Login)"
            if (Test-Path $destFolder) {
                $foldersCreated++
            }
        }
    }
    
    if ($foldersCreated -eq $expectedFolders) {
        Write-TestResult -TestNumber 4 -TestName "Creación de carpetas destino" -Passed $true
    } else {
        Write-TestResult -TestNumber 4 -TestName "Creación de carpetas destino" -Passed $false `
            -Expected "Se deben crear $expectedFolders carpetas en C:\Users\proyecto" `
            -Actual "Solo se crearon $foldersCreated carpetas"
    }
    
    # ========================================================================
    # PRUEBA 5: Archivos movidos correctamente
    # ========================================================================
    Write-Host "`n[5/10] Verificando movimiento de archivos..." -ForegroundColor Cyan
    $testUser = $testUsers | Where-Object { $_.Login -eq "testuser2" } | Select-Object -First 1
    $destFolder = "$PROYECTO_DIR\$($testUser.Login)"
    
    if (Test-Path $destFolder) {
        $filesInDest = (Get-ChildItem -Path $destFolder -File).Count
        $sourceFolder = "C:\Users\$($testUser.Login)\trabajo"
        $filesInSource = if (Test-Path $sourceFolder) { (Get-ChildItem -Path $sourceFolder -File).Count } else { 0 }
        
        if ($filesInDest -eq $testUser.NumArchivos -and $filesInSource -eq 0) {
            Write-TestResult -TestNumber 5 -TestName "Movimiento de archivos" -Passed $true
        } else {
            Write-TestResult -TestNumber 5 -TestName "Movimiento de archivos" -Passed $false `
                -Expected "Debe mover $($testUser.NumArchivos) archivos y la carpeta origen debe quedar vacía" `
                -Actual "Archivos en destino: $filesInDest, archivos en origen: $filesInSource"
        }
    } else {
        Write-TestResult -TestNumber 5 -TestName "Movimiento de archivos" -Passed $false `
            -Expected "Debe existir la carpeta destino" `
            -Actual "No existe la carpeta destino"
    }
    
    # ========================================================================
    # PRUEBA 6: Conteo correcto de archivos en log
    # ========================================================================
    Write-Host "`n[6/10] Verificando conteo de archivos en log..." -ForegroundColor Cyan
    $bajasLogPath = "$LOG_DIR\bajas.log"
    
    if (Test-Path $bajasLogPath) {
        $logContent = Get-Content $bajasLogPath -Raw
        $testUser = $testUsers | Where-Object { $_.Login -eq "testuser2" } | Select-Object -First 1
        
        # Buscar la sección del usuario en el log
        if ($logContent -match "Login\s*:\s*$($testUser.Login)") {
            # Buscar el total de archivos reportado
            if ($logContent -match "Total de archivos:\s*(\d+)") {
                $reportedCount = [int]$matches[1]
                if ($reportedCount -eq $testUser.NumArchivos) {
                    Write-TestResult -TestNumber 6 -TestName "Conteo correcto de archivos" -Passed $true
                } else {
                    Write-TestResult -TestNumber 6 -TestName "Conteo correcto de archivos" -Passed $false `
                        -Expected "El log debe reportar $($testUser.NumArchivos) archivos" `
                        -Actual "El log reporta $reportedCount archivos"
                }
            } else {
                Write-TestResult -TestNumber 6 -TestName "Conteo correcto de archivos" -Passed $false `
                    -Expected "El log debe contener 'Total de archivos: N'" `
                    -Actual "No se encontró el total de archivos en el log"
            }
        } else {
            Write-TestResult -TestNumber 6 -TestName "Conteo correcto de archivos" -Passed $false `
                -Expected "El log debe contener entrada para $($testUser.Login)" `
                -Actual "No se encontró entrada para el usuario en el log"
        }
    } else {
        Write-TestResult -TestNumber 6 -TestName "Conteo correcto de archivos" -Passed $false `
            -Expected "Debe existir archivo bajas.log" `
            -Actual "Archivo bajas.log no fue creado"
    }
    
    # ========================================================================
    # PRUEBA 7: Cambio de propietario a Administrador
    # ========================================================================
    Write-Host "`n[7/10] Verificando cambio de propietario..." -ForegroundColor Cyan
    $testUser = $testUsers | Where-Object { $_.Login -eq "testuser1" } | Select-Object -First 1
    $destFolder = "$PROYECTO_DIR\$($testUser.Login)"
    
    if (Test-Path $destFolder) {
        try {
            $acl = Get-Acl $destFolder
            $owner = $acl.Owner
            
            # El propietario debe ser Administrador o Administradores (depende del idioma del SO)
            if ($owner -match "Administr") {
                Write-TestResult -TestNumber 7 -TestName "Cambio de propietario" -Passed $true
            } else {
                Write-TestResult -TestNumber 7 -TestName "Cambio de propietario" -Passed $false `
                    -Expected "El propietario debe ser Administrador/Administradores" `
                    -Actual "El propietario actual es: $owner"
            }
        } catch {
            Write-TestResult -TestNumber 7 -TestName "Cambio de propietario" -Passed $false `
                -Expected "Debe poder leer el propietario de la carpeta" `
                -Actual "Error al leer ACL: $_"
        }
    } else {
        Write-TestResult -TestNumber 7 -TestName "Cambio de propietario" -Passed $false `
            -Expected "Debe existir la carpeta destino" `
            -Actual "No existe la carpeta destino para verificar propietario"
    }
    
    # ========================================================================
    # PRUEBA 8: Registro correcto en bajas.log
    # ========================================================================
    Write-Host "`n[8/10] Verificando formato de bajas.log..." -ForegroundColor Cyan
    $bajasLogPath = "$LOG_DIR\bajas.log"
    
    if (Test-Path $bajasLogPath) {
        $logContent = Get-Content $bajasLogPath -Raw
        
        # Verificar que contiene los elementos requeridos
        $hasDate = $logContent -match "\d{4}-\d{2}-\d{2}"
        $hasLogin = $logContent -match "Login\s*:"
        $hasCarpeta = $logContent -match "Carpeta Destino\s*:"
        $hasListado = $logContent -match "\d+\.\s+\w+"
        $hasTotal = $logContent -match "Total de archivos:"
        
        if ($hasDate -and $hasLogin -and $hasCarpeta -and $hasListado -and $hasTotal) {
            Write-TestResult -TestNumber 8 -TestName "Formato correcto de bajas.log" -Passed $true
        } else {
            $missing = @()
            if (-not $hasDate) { $missing += "fecha" }
            if (-not $hasLogin) { $missing += "login" }
            if (-not $hasCarpeta) { $missing += "carpeta destino" }
            if (-not $hasListado) { $missing += "listado numerado" }
            if (-not $hasTotal) { $missing += "total de archivos" }
            
            Write-TestResult -TestNumber 8 -TestName "Formato correcto de bajas.log" -Passed $false `
                -Expected "El log debe contener: fecha, login, carpeta destino, listado numerado, total" `
                -Actual "Faltan elementos en el log: $($missing -join ', ')"
        }
    } else {
        Write-TestResult -TestNumber 8 -TestName "Formato correcto de bajas.log" -Passed $false `
            -Expected "Debe existir archivo bajas.log" `
            -Actual "Archivo bajas.log no fue creado"
    }
    
    # ========================================================================
    # PRUEBA 9: Usuarios eliminados de Active Directory
    # ========================================================================
    Write-Host "`n[9/10] Verificando eliminación de usuarios de AD..." -ForegroundColor Cyan
    $deletedCount = 0
    $expectedDeleted = ($testUsers | Where-Object { $_.Existe }).Count
    
    foreach ($user in $testUsers) {
        if ($user.Existe) {
            if (-not (Test-ADUserExists -Login $user.Login)) {
                $deletedCount++
            }
        }
    }
    
    if ($deletedCount -eq $expectedDeleted) {
        Write-TestResult -TestNumber 9 -TestName "Eliminación de usuarios de AD" -Passed $true
    } else {
        Write-TestResult -TestNumber 9 -TestName "Eliminación de usuarios de AD" -Passed $false `
            -Expected "Se deben eliminar $expectedDeleted usuarios de AD" `
            -Actual "Solo se eliminaron $deletedCount usuarios"
    }
    
    # ========================================================================
    # PRUEBA 10: Directorios personales eliminados
    # ========================================================================
    Write-Host "`n[10/10] Verificando eliminación de directorios personales..." -ForegroundColor Cyan
    $deletedDirs = 0
    $expectedDeletedDirs = ($testUsers | Where-Object { $_.Existe }).Count
    
    foreach ($user in $testUsers) {
        if ($user.Existe) {
            $userDir = "C:\Users\$($user.Login)"
            if (-not (Test-Path $userDir)) {
                $deletedDirs++
            }
        }
    }
    
    if ($deletedDirs -eq $expectedDeletedDirs) {
        Write-TestResult -TestNumber 10 -TestName "Eliminación de directorios personales" -Passed $true
    } else {
        Write-TestResult -TestNumber 10 -TestName "Eliminación de directorios personales" -Passed $false `
            -Expected "Se deben eliminar $expectedDeletedDirs directorios personales" `
            -Actual "Solo se eliminaron $deletedDirs directorios"
    }
}

# ============================================================================
# BLOQUE 7: GENERACIÓN DE INFORME FINAL
# [ESCRITO MANUALMENTE - Para formatear el informe de resultados]
# ============================================================================

function Show-FinalReport {
    Write-TestHeader "INFORME FINAL DE CALIFICACIÓN"
    
    $percentage = ($totalPoints / $maxPoints) * 100
    
    Write-Host "`n"
    Write-Host "  ╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║                  PUNTUACIÓN OBTENIDA                     ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "           NOTA FINAL: $totalPoints / $maxPoints puntos" -ForegroundColor $(if ($totalPoints -ge 5) { "Green" } else { "Red" })
    Write-Host "           PORCENTAJE: $percentage%" -ForegroundColor $(if ($percentage -ge 50) { "Green" } else { "Red" })
    Write-Host ""
    
    # Mostrar resumen de pruebas
    Write-Host "  ┌──────────────────────────────────────────────────────────┐" -ForegroundColor Gray
    Write-Host "  │ RESUMEN DE PRUEBAS                                       │" -ForegroundColor Gray
    Write-Host "  └──────────────────────────────────────────────────────────┘" -ForegroundColor Gray
    Write-Host ""
    
    foreach ($result in $testResults) {
        $status = if ($result.Passed) { "✓ APROBADA" } else { "✗ FALLIDA" }
        $color = if ($result.Passed) { "Green" } else { "Red" }
        Write-Host "  [$($result.Number)] $($result.Name)" -NoNewline
        Write-Host " ... $status" -ForegroundColor $color
    }
    
    # Mostrar errores detallados si los hay
    if ($errors.Count -gt 0) {
        Write-Host ""
        Write-Host "  ┌──────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
        Write-Host "  │ ERRORES DETECTADOS                                       │" -ForegroundColor Yellow
        Write-Host "  └──────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
        Write-Host ""
        
        foreach ($error in $errors) {
            Write-Host "  ERROR EN PRUEBA $($error.Test): $($error.Name)" -ForegroundColor Red
            Write-Host "    → Esperado: $($error.Expected)" -ForegroundColor Yellow
            Write-Host "    → Obtenido: $($error.Actual)" -ForegroundColor Yellow
            Write-Host ""
        }
    } else {
        Write-Host ""
        Write-Host "  ¡FELICIDADES! Todas las pruebas fueron aprobadas. ✓" -ForegroundColor Green
        Write-Host ""
    }
    
    # Calificación cualitativa
    Write-Host "  ┌──────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │ CALIFICACIÓN CUALITATIVA                                 │" -ForegroundColor Cyan
    Write-Host "  └──────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
    
    if ($totalPoints -ge 9) {
        Write-Host "  Calificación: SOBRESALIENTE" -ForegroundColor Green
        Write-Host "  El script funciona excelentemente en todos los aspectos." -ForegroundColor Green
    } elseif ($totalPoints -ge 7) {
        Write-Host "  Calificación: NOTABLE" -ForegroundColor Green
        Write-Host "  El script funciona correctamente con fallos menores." -ForegroundColor Green
    } elseif ($totalPoints -ge 5) {
        Write-Host "  Calificación: APROBADO" -ForegroundColor Yellow
        Write-Host "  El script cumple funcionalidad básica pero necesita mejoras." -ForegroundColor Yellow
    } else {
        Write-Host "  Calificación: SUSPENSO" -ForegroundColor Red
        Write-Host "  El script requiere correcciones significativas." -ForegroundColor Red
    }
    
    Write-Host ""
}

# ============================================================================
# BLOQUE 8: PROGRAMA PRINCIPAL
# [GENERADO POR IA - Modificado para mejorar flujo de ejecución]
# ============================================================================

# Banner inicial
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                               ║" -ForegroundColor Cyan
Write-Host "║         SISTEMA DE CALIFICACIÓN AUTOMÁTICA                    ║" -ForegroundColor Cyan
Write-Host "║         Script: Jonaaron04.ps                                 ║" -ForegroundColor Cyan
Write-Host "║         Evalúa: Jonaaron03.ps1 (Sistema de Bajas)            ║" -ForegroundColor Cyan
Write-Host "║                                                               ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Verificar que existe el script a evaluar
if (-not (Test-Path $SCRIPT_TO_TEST)) {
    Write-Host "❌ ERROR: No se encuentra el script $SCRIPT_TO_TEST" -ForegroundColor Red
    Write-Host "   Asegúrese de que Jonaaron03.ps1 está en el mismo directorio" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Script a evaluar encontrado: $SCRIPT_TO_TEST" -ForegroundColor Green
Write-Host ""

# Confirmar inicio
Write-Host "Este script va a:" -ForegroundColor Yellow
Write-Host "  1. Limpiar cualquier entorno de prueba previo" -ForegroundColor White
Write-Host "  2. Crear usuarios de prueba en Active Directory" -ForegroundColor White
Write-Host "  3. Ejecutar el script Jonaaron03.ps" -ForegroundColor White
Write-Host "  4. Realizar 10 pruebas de verificación" -ForegroundColor White
Write-Host "  5. Generar un informe de calificación" -ForegroundColor White
Write-Host "  6. Limpiar el entorno de pruebas" -ForegroundColor White
Write-Host ""

$continue = Read-Host "¿Desea continuar? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Operación cancelada por el usuario" -ForegroundColor Yellow
    exit 0
}

# Ejecutar el proceso de calificación
try {
    Clear-TestEnvironment
    Setup-TestEnvironment
    Create-BajasFile
    Run-AllTests
    Show-FinalReport
    
    # Limpieza final
    Write-TestHeader "LIMPIEZA FINAL"
    Write-Host "  Limpiando entorno de pruebas..." -ForegroundColor Cyan
    Clear-TestEnvironment
    Write-Host "  ✓ Limpieza completada" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "❌ ERROR CRÍTICO durante la ejecución:" -ForegroundColor Red
    Write-Host "   $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " Evaluación completada" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""