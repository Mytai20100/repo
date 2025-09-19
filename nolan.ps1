# Nolan.ps1
# MU hehee 
# Enhanced Hacker-Style Console UI
#Power by mytai
# Run as Administrator

#Requires -RunAsAdministrator

# ========== CONFIGURATION MATRIX ==========
$script:SystemConfig = @{
    GroupIdentifier = "NETGUARD_STEALTH_OPS"
    Version = "3.0.1337"
    Codename = "PHANTOM_PROTOCOL"
}

$script:AllowedConnections = @(
    @{ID="WEB_HTTP"; Protocol="TCP"; Port="80"; Description="HTTP Traffic"},
    @{ID="WEB_HTTPS"; Protocol="TCP"; Port="443"; Description="HTTPS Secure"},
    @{ID="DNS_RESOLVE_TCP"; Protocol="TCP"; Port="53"; Description="DNS Resolution TCP"},
    @{ID="DNS_RESOLVE_UDP"; Protocol="UDP"; Port="53"; Description="DNS Resolution UDP"},
    @{ID="TIME_SYNC"; Protocol="UDP"; Port="123"; Description="Network Time Protocol"},
    @{ID="ROBLOX_MAIN"; Protocol="TCP"; Port="443"; Description="Roblox Main Channel"},
    @{ID="ROBLOX_CHAT"; Protocol="TCP"; Port="5222"; Description="Roblox Chat System"},
    @{ID="ROBLOX_GAME_UDP"; Protocol="UDP"; Port="49152-65535"; Description="Roblox Game Data"},
    @{ID="MINECRAFT_SERVER"; Protocol="TCP"; Port="25565"; Description="Minecraft Server"},
    @{ID="MINECRAFT_QUERY"; Protocol="UDP"; Port="25565"; Description="Minecraft Query"},
    @{ID="STEAM_CLIENT"; Protocol="TCP"; Port="27015-27030"; Description="Steam Gaming"},
    @{ID="DISCORD_VOICE"; Protocol="UDP"; Port="50000-65535"; Description="Discord Voice Chat"}
)

$script:BlockedRanges = @(
    "192.168.0.0/16",
    "10.0.0.0/8", 
    "172.16.0.0/12",
    "169.254.0.0/16"
)

# ========== STEALTH UTILITIES ==========
function Assert-AdminPrivileges {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Invoke-StealthWrite "ACCESS DENIED: Administrator privileges required" "Red"
        Invoke-StealthWrite "Recommendation: Execute PowerShell as Administrator" "Yellow"
        Invoke-HackerPause
        exit 1337
    }
}

function Invoke-StealthWrite {
    param($Message, $Color = 'Green', [switch]$NoNewline, [switch]$TypeWriter)
    
    if ($TypeWriter) {
        foreach ($char in $Message.ToCharArray()) {
            Write-Host $char -ForegroundColor $Color -NoNewline
            Start-Sleep -Milliseconds (Get-Random -Minimum 20 -Maximum 80)
        }
        if (-not $NoNewline) { Write-Host "" }
    } else {
        try { 
            if ($NoNewline) {
                Write-Host $Message -ForegroundColor $Color -NoNewline 
            } else {
                Write-Host $Message -ForegroundColor $Color 
            }
        } catch { 
            Write-Output $Message 
        }
    }
}

function Show-PhantomLogo {
    Clear-Host
    $windowWidth = try { (Get-Host).UI.RawUI.WindowSize.Width } catch { 120 }
    
   $logoLines = @(
    "",
    "   ##     ##  #######  #######   ######   ##   ##  #####   #####   ##### ",
    "   ###    ##  ##          ##    ##        ##   ## ##   ##  ##   ## ##   ##",
    "   ## ##  ##  #####       ##    ##   ###  ##   ## #######  #####   ##   ##",
    "   ##  ## ##  ##          ##    ##    ##  ##   ## ##   ##  ##   ## ##   ##",
    "   ##   ####  #######     ##     ######    #####  ##   ##  ##   ## ##### ",
    "",
    "                       ######   ######   ######  ",
    "                       ##   ##  ##   ## ##    ## ",
    "                       ######   ######  ##    ## ",
    "                       ##       ##   ## ##    ## ",
    "                       ##       ##   ##  ######  ",
    "              Power by servernotdie              "
)

    
    foreach ($line in $logoLines) {
        if ($line.Trim() -ne "") {
            $padding = [math]::Max(0, [int](($windowWidth - $line.Length) / 2))
            Write-Host (" " * $padding) -NoNewline
        }
        Invoke-StealthWrite $line 'Cyan'
    }
    
    $subtitle = "======= PHANTOM PROTOCOL v$($script:SystemConfig.Version) ======="
    $subtitlePadding = [math]::Max(0, [int](($windowWidth - $subtitle.Length) / 2))
    Write-Host (" " * $subtitlePadding) -NoNewline
    Invoke-StealthWrite $subtitle 'DarkCyan'
    
    $description = "< Advanced Network Stealth Operations >"
    $descPadding = [math]::Max(0, [int](($windowWidth - $description.Length) / 2))
    Write-Host (" " * $descPadding) -NoNewline
    Invoke-StealthWrite $description 'Green'
    
    $separator = "=" * [math]::Min($windowWidth - 10, 80)
    $sepPadding = [math]::Max(0, [int](($windowWidth - $separator.Length) / 2))
    Write-Host (" " * $sepPadding) -NoNewline
    Write-Host $separator -ForegroundColor DarkGray
    Write-Host ""
}

function Show-OperationalInterface {
    Show-PhantomLogo
    
    $windowWidth = try { (Get-Host).UI.RawUI.WindowSize.Width } catch { 120 }
    $currentStatus = Get-NetworkStatus
    $protectionLevel = Get-ProtectionLevel
    
    # Status Box - Centered
    $statusBox = @(
        "+======================================================+",
        "|                   SYSTEM STATUS                      |",
        "+======================================================+",
        "|  Network State: $($currentStatus.PadRight(32)) |",
        "|  Protection Level: $($protectionLevel.PadRight(29)) |",
        "+======================================================+"
    )
    
    foreach ($line in $statusBox) {
        $padding = [math]::Max(0, [int](($windowWidth - $line.Length) / 2))
        Write-Host (" " * $padding) -NoNewline
        if ($line.Contains("Network State")) {
            Invoke-StealthWrite $line 'Cyan'
        } elseif ($line.Contains("Protection Level")) {
            Invoke-StealthWrite $line 'Green'
        } else {
            Invoke-StealthWrite $line 'Gray'
        }
    }
    Write-Host ""
    
    # Operations Menu - Centered
    $menuBox = @(
        "+======================================================+",
        "|                AVAILABLE OPERATIONS                  |",
        "+======================================================+",
        "|                                                      |",
        "|  [1] * ENGAGE PHANTOM MODE                           |",
        "|      +-- Block LAN/School + Allow Gaming             |",
        "|                                                      |",
        "|  [2] # DISENGAGE PROTOCOLS                           |",
        "|      +-- Restore Normal Network Access               |",
        "|                                                      |",
        "|  [3] ! EMERGENCY PURGE                               |",
        "|      +-- Force Clean All Configurations              |",
        "|                                                      |",
        "|  [4] @ SYSTEM DIAGNOSTICS                            |",
        "|      +-- Network Analysis & Status Report            |",
        "|                                                      |",
        "|  [5] & LAN NETWORK SCANNER                           |",
        "|      +-- Discover Connected Devices                  |",
        "|                                                      |",
        "|  [0] X TERMINATE SESSION                             |",
        "|                                                      |",
        "+======================================================+"
    )
    
    foreach ($line in $menuBox) {
        $padding = [math]::Max(0, [int](($windowWidth - $line.Length) / 2))
        Write-Host (" " * $padding) -NoNewline
        
        if ($line.Contains("[1]")) {
            Invoke-StealthWrite $line 'Red'
        } elseif ($line.Contains("[2]")) {
            Invoke-StealthWrite $line 'Yellow'
        } elseif ($line.Contains("[3]")) {
            Invoke-StealthWrite $line 'Magenta'
        } elseif ($line.Contains("[4]")) {
            Invoke-StealthWrite $line 'Blue'
        } elseif ($line.Contains("[5]")) {
            Invoke-StealthWrite $line 'Cyan'
        } elseif ($line.Contains("[0]")) {
            Invoke-StealthWrite $line 'DarkRed'
        } elseif ($line.Contains("+--")) {
            Invoke-StealthWrite $line 'DarkGray'
        } else {
            Invoke-StealthWrite $line 'Gray'
        }
    }
    Write-Host ""
}

function Get-NetworkStatus {
    try {
        $profiles = Get-NetFirewallProfile -ErrorAction Stop
        $blockedProfiles = $profiles | Where-Object { $_.DefaultOutboundAction -eq 'Block' }
        
        if ($blockedProfiles) {
            return "PHANTOM ACTIVE"
        } else {
            return "NORMAL OPERATIONS"
        }
    } catch {
        return "STATUS UNKNOWN"
    }
}

function Get-ProtectionLevel {
    try {
        $rules = Get-NetFirewallRule -Group $script:SystemConfig.GroupIdentifier -ErrorAction SilentlyContinue
        $ruleCount = ($rules | Measure-Object).Count
        if ($ruleCount -gt 0) {
            return "STEALTH ($ruleCount rules)"
        } else {
            return "STANDARD"
        }
    } catch {
        return "UNMONITORED"
    }
}

function Invoke-HackerProgress {
    param(
        [string]$OperationName = "EXECUTING",
        [int]$DurationMs = 1200,
        [string[]]$StatusMessages = @("Initializing...", "Processing...", "Finalizing...")
    )
    
    $windowWidth = try { (Get-Host).UI.RawUI.WindowSize.Width } catch { 120 }
    $totalSteps = 30
    $stepDuration = [int]($DurationMs / $totalSteps)
    
    for ($step = 0; $step -le $totalSteps; $step++) {
        $percentage = [int](($step / $totalSteps) * 100)
        $progressFilled = [int](($step / $totalSteps) * 50)
        $progressBar = ('#' * $progressFilled).PadRight(50, '.')
        $currentStatus = $StatusMessages[$step % $StatusMessages.Length]
        
        $progressLine = "$OperationName [$progressBar] $percentage% - $currentStatus"
        $padding = [math]::Max(0, [int](($windowWidth - $progressLine.Length) / 2))
        
        Write-Host -NoNewline ("`r" + (" " * $windowWidth) + "`r")
        Write-Host (" " * $padding) -NoNewline
        Write-Host -NoNewline "$OperationName [" -ForegroundColor Yellow
        Write-Host -NoNewline ('#' * $progressFilled) -ForegroundColor Green
        Write-Host -NoNewline ('.' * (50 - $progressFilled)) -ForegroundColor DarkGray
        Write-Host -NoNewline "] $percentage% - " -ForegroundColor Yellow
        Write-Host -NoNewline $currentStatus -ForegroundColor Cyan
        
        Start-Sleep -Milliseconds $stepDuration
    }
    Write-Host "`n"
}

function New-StealthRule {
    param($RuleIdentifier, $Protocol, $Port, $Description)
    
    try {
        $fullRuleName = "$RuleIdentifier [$($script:SystemConfig.GroupIdentifier)]"
        
        # Remove existing rule to prevent conflicts
        $existingRule = Get-NetFirewallRule -DisplayName $fullRuleName -ErrorAction SilentlyContinue
        if ($existingRule) { 
            $existingRule | Remove-NetFirewallRule -ErrorAction SilentlyContinue 
        }
        
        New-NetFirewallRule `
            -DisplayName $fullRuleName `
            -Direction Outbound `
            -Action Allow `
            -Protocol $Protocol `
            -RemotePort $Port `
            -Profile Any `
            -Group $script:SystemConfig.GroupIdentifier `
            -Description $Description `
            -ErrorAction Stop | Out-Null
        
        return $true
    } catch {
        return $false
    }
}

function New-BlockRule {
    param($RangeCIDR)
    
    try {
        $ruleName = "BLOCK_LAN_$($RangeCIDR.Replace('/', '_').Replace('.', '_')) [$($script:SystemConfig.GroupIdentifier)]"
        
        $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        if ($existingRule) {
            $existingRule | Remove-NetFirewallRule -ErrorAction SilentlyContinue
        }
        
        New-NetFirewallRule `
            -DisplayName $ruleName `
            -Direction Outbound `
            -Action Block `
            -RemoteAddress $RangeCIDR `
            -Profile Any `
            -Group $script:SystemConfig.GroupIdentifier `
            -Description "Block LAN/School Network Range: $RangeCIDR" `
            -ErrorAction Stop | Out-Null
        
        return $true
    } catch {
        return $false
    }
}

# ========== CORE OPERATIONS ==========
function Invoke-PhantomEngagement {
    Invoke-StealthWrite "`n+-- ENGAGING PHANTOM PROTOCOL --------------+" 'Red'
    Invoke-StealthWrite "| Initializing stealth network operations... |" 'Yellow'
    Invoke-StealthWrite "+--------------------------------------------+" 'Red'
    
    Invoke-HackerProgress -OperationName "PHANTOM_INIT" -DurationMs 800 -StatusMessages @("Scanning network topology...", "Configuring stealth rules...", "Applying restrictions...")
    
    # Set outbound blocking on all profiles
    foreach ($profile in @("Domain", "Private", "Public")) {
        try {
            Set-NetFirewallProfile -Profile $profile -DefaultOutboundAction Block -ErrorAction Stop
            Invoke-StealthWrite "[+] Profile ${profile} - Outbound traffic BLOCKED" 'Green'
        } catch {
            Invoke-StealthWrite "[-] Profile ${profile} - Configuration failed: $($_.Exception.Message)" 'Red'
        }
    }
    
    # Create LAN blocking rules
    $lanBlocked = 0
    foreach ($range in $script:BlockedRanges) {
        if (New-BlockRule -RangeCIDR $range) {
            $lanBlocked++
            Invoke-StealthWrite "[+] LAN Range ${range} - BLOCKED" 'Red'
        } else {
            Invoke-StealthWrite "[-] LAN Range ${range} - Block failed" 'Yellow'
        }
    }
    
    # Create allowed connection rules
    $allowRulesCreated = 0
    $allowRulesFailed = 0
    
    foreach ($connection in $script:AllowedConnections) {
        $success = New-StealthRule -RuleIdentifier $connection.ID -Protocol $connection.Protocol -Port $connection.Port -Description $connection.Description
        if ($success) {
            $allowRulesCreated++
            Invoke-StealthWrite "[+] $($connection.ID) - $($connection.Description)" 'Green'
        } else {
            $allowRulesFailed++
            Invoke-StealthWrite "[-] $($connection.ID) - Rule creation failed" 'Yellow'
        }
    }
    
    Write-Host ""
    Invoke-StealthWrite "+-- PHANTOM PROTOCOL STATUS ----------------+" 'Cyan'
    Invoke-StealthWrite "| LAN Ranges Blocked: $lanBlocked                     |" 'Red'
    Invoke-StealthWrite "| Allowed Rules Created: $allowRulesCreated              |" 'Green'
    Invoke-StealthWrite "| Failed Rules: $allowRulesFailed                        |" 'Yellow'
    Invoke-StealthWrite "|                                            |" 'Cyan'
    Invoke-StealthWrite "| STATUS: PHANTOM MODE ACTIVE                |" 'Red'
    Invoke-StealthWrite "+--------------------------------------------+" 'Cyan'
    
    Invoke-HackerPause
}

function Invoke-PhantomDisengagement {
    Invoke-StealthWrite "`n+-- DISENGAGING PHANTOM PROTOCOL -----------+" 'Yellow'
    Invoke-StealthWrite "| Restoring standard network operations...   |" 'Green'
    Invoke-StealthWrite "+--------------------------------------------+" 'Yellow'
    
    Invoke-HackerProgress -OperationName "PHANTOM_DISENGAGE" -DurationMs 600 -StatusMessages @("Removing restrictions...", "Restoring access...", "Cleaning up...")
    
    # Restore outbound allow on all profiles
    foreach ($profile in @("Domain", "Private", "Public")) {
        try {
            Set-NetFirewallProfile -Profile $profile -DefaultOutboundAction Allow -ErrorAction Stop
            Invoke-StealthWrite "[+] Profile ${profile} - Outbound traffic ALLOWED" 'Green'
        } catch {
            Invoke-StealthWrite "[-] Profile ${profile} - Restoration failed: $($_.Exception.Message)" 'Red'
        }
    }
    
    # Remove all phantom rules
    try {
        $phantomRules = Get-NetFirewallRule -Group $script:SystemConfig.GroupIdentifier -ErrorAction SilentlyContinue
        if ($phantomRules) {
            $ruleCount = ($phantomRules | Measure-Object).Count
            $phantomRules | Remove-NetFirewallRule -ErrorAction SilentlyContinue
            Invoke-StealthWrite "[+] Removed $ruleCount phantom protocol rules" 'Green'
        } else {
            Invoke-StealthWrite "[i] No phantom rules found to remove" 'Yellow'
        }
    } catch {
        Invoke-StealthWrite "[-] Rule cleanup error: $($_.Exception.Message)" 'Red'
    }
    
    Invoke-StealthWrite "`n[+] PHANTOM PROTOCOL DISENGAGED - Normal network access restored" 'Green'
    Invoke-HackerPause
}

function Invoke-EmergencyPurge {
    Invoke-StealthWrite "`n+-- EMERGENCY PURGE PROTOCOL ---------------+" 'Magenta'
    Invoke-StealthWrite "| WARNING: This will force-clean all rules   |" 'Red'
    Invoke-StealthWrite "+--------------------------------------------+" 'Magenta'
    
    $confirmation = Read-Host " Type 'PURGE_CONFIRMED' to proceed with emergency cleanup"
    if ($confirmation -ne "PURGE_CONFIRMED") {
        Invoke-StealthWrite "[!] Emergency purge cancelled - Confirmation failed" 'Yellow'
        Invoke-HackerPause
        return
    }
    
    Invoke-HackerProgress -OperationName "EMERGENCY_PURGE" -DurationMs 900 -StatusMessages @("Force cleaning...", "Purging remnants...", "System restoration...")
    
    # Restore all profiles
    Invoke-PhantomDisengagement
    
    # Force remove any leftover rules containing our group identifier
    try {
        $allRules = Get-NetFirewallRule -ErrorAction SilentlyContinue | Where-Object { 
            $_.DisplayName -like "*$($script:SystemConfig.GroupIdentifier)*" 
        }
        if ($allRules) {
            $leftoverCount = ($allRules | Measure-Object).Count
            $allRules | Remove-NetFirewallRule -ErrorAction SilentlyContinue
            Invoke-StealthWrite "[+] Force removed $leftoverCount leftover rules" 'Red'
        } else {
            Invoke-StealthWrite "[i] No leftover rules detected" 'Green'
        }
    } catch {
        Invoke-StealthWrite "[-] Emergency purge error: $($_.Exception.Message)" 'Red'
    }
    
    Invoke-StealthWrite "`n[+] EMERGENCY PURGE COMPLETED - System restored to default state" 'Green'
    Invoke-HackerPause
}

function Invoke-SystemDiagnostics {
    Invoke-StealthWrite "`n+-- SYSTEM DIAGNOSTICS ---------------------+" 'Blue'
    Invoke-StealthWrite "| Analyzing network configuration...         |" 'Cyan'
    Invoke-StealthWrite "+--------------------------------------------+" 'Blue'
    
    Invoke-HackerProgress -OperationName "DIAGNOSTICS" -DurationMs 700 -StatusMessages @("Scanning profiles...", "Analyzing rules...", "Generating report...")
    
    # Profile analysis
    Write-Host ""
    Invoke-StealthWrite "=== FIREWALL PROFILE STATUS ===" 'Yellow'
    try {
        $profiles = Get-NetFirewallProfile -ErrorAction Stop
        foreach ($profile in $profiles) {
            $status = if ($profile.DefaultOutboundAction -eq 'Block') { "RESTRICTED" } else { "OPEN" }
            $color = if ($profile.DefaultOutboundAction -eq 'Block') { "Red" } else { "Green" }
            Invoke-StealthWrite "Profile $($profile.Name) - $status" $color
        }
    } catch {
        Invoke-StealthWrite "Profile analysis failed: $($_.Exception.Message)" 'Red'
    }
    
    # Rule analysis
    Write-Host ""
    Invoke-StealthWrite "=== PHANTOM PROTOCOL RULES ===" 'Yellow'
    try {
        $phantomRules = Get-NetFirewallRule -Group $script:SystemConfig.GroupIdentifier -ErrorAction SilentlyContinue
        if ($phantomRules) {
            $ruleCount = ($phantomRules | Measure-Object).Count
            Invoke-StealthWrite "Active phantom rules: $ruleCount" 'Cyan'
            
            $phantomRules | ForEach-Object {
                $action = if ($_.Action -eq 'Block') { "BLOCK" } else { "ALLOW" }
                $color = if ($_.Action -eq 'Block') { "Red" } else { "Green" }
                Invoke-StealthWrite "  +-- $($_.DisplayName) - $action" $color
            }
        } else {
            Invoke-StealthWrite "No active phantom rules found" 'Yellow'
        }
    } catch {
        Invoke-StealthWrite "Rule analysis failed: $($_.Exception.Message)" 'Red'
    }
    
    # Network interface info
    Write-Host ""
    Invoke-StealthWrite "=== NETWORK INTERFACES ===" 'Yellow'
    try {
        $adapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' }
        foreach ($adapter in $adapters) {
            Invoke-StealthWrite "Interface: $($adapter.Name) - $($adapter.LinkSpeed)" 'Green'
        }
    } catch {
        Invoke-StealthWrite "Interface analysis failed: $($_.Exception.Message)" 'Red'
    }
    
    Write-Host ""
    Invoke-HackerPause
}

function Invoke-LANScanner {
    $windowWidth = try { (Get-Host).UI.RawUI.WindowSize.Width } catch { 120 }
    
    Invoke-StealthWrite "`n+======================================================+" 'Blue'
    Invoke-StealthWrite "|                LAN NETWORK SCANNER                  |" 'Blue'
    Invoke-StealthWrite "| Scanning for connected devices in local network...  |" 'Cyan'
    Invoke-StealthWrite "+======================================================+" 'Blue'
    
    Invoke-HackerProgress -OperationName "LAN_SCANNER" -DurationMs 1500 -StatusMessages @("Detecting network interfaces...", "Scanning IP ranges...", "Resolving hostnames...", "Gathering device info...")
    
    $discoveredDevices = @()
    
    try {
        # Get local network adapter info
        $localAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Virtual -eq $false } | Select-Object -First 1
        $localIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $localAdapter.InterfaceIndex -PrefixOrigin Dhcp,Manual -ErrorAction SilentlyContinue).IPAddress
        
        if (-not $localIP) {
            $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -match '^192\.168\.|^10\.|^172\.' } | Select-Object -First 1).IPAddress
        }
        
        if ($localIP) {
            $networkBase = ($localIP -split '\.')[0..2] -join '.'
            $scanRange = "$networkBase.1-254"
            
            Invoke-StealthWrite "`n>> Scanning network range: $networkBase.0/24" 'Green'
            Invoke-StealthWrite ">> Your IP: $localIP`n" 'Yellow'
            
            # Fast ping scan
            $jobs = @()
            1..254 | ForEach-Object {
                $ip = "$networkBase.$_"
                $jobs += Start-Job -ScriptBlock {
                    param($targetIP)
                    $ping = Test-Connection -ComputerName $targetIP -Count 1 -Quiet -TimeoutSeconds 1
                    if ($ping) {
                        try {
                            $hostname = [System.Net.Dns]::GetHostEntry($targetIP).HostName
                        } catch {
                            $hostname = "Unknown"
                        }
                        return @{IP = $targetIP; Hostname = $hostname; Status = "Online"}
                    }
                } -ArgumentList $ip
            }
            
            # Wait for jobs and collect results
            $timeout = 10
            $startTime = Get-Date
            while ($jobs.Count -gt 0 -and ((Get-Date) - $startTime).TotalSeconds -lt $timeout) {
                $completedJobs = $jobs | Where-Object { $_.State -eq 'Completed' }
                foreach ($job in $completedJobs) {
                    $result = Receive-Job $job
                    if ($result) {
                        $discoveredDevices += $result
                    }
                    Remove-Job $job
                    $jobs = $jobs | Where-Object { $_.Id -ne $job.Id }
                }
                Start-Sleep -Milliseconds 100
            }
            
            # Cleanup remaining jobs
            $jobs | ForEach-Object { Stop-Job $_ -ErrorAction SilentlyContinue; Remove-Job $_ -ErrorAction SilentlyContinue }
            
        } else {
            Invoke-StealthWrite "ERROR: Could not determine local network range" 'Red'
            return
        }
        
    } catch {
        Invoke-StealthWrite "ERROR: Network scanning failed: $($_.Exception.Message)" 'Red'
        return
    }
    
    # Display results
    Write-Host ""
    if ($discoveredDevices.Count -gt 0) {
        Invoke-StealthWrite "+================================================================+" 'Green'
        Invoke-StealthWrite "|                        DISCOVERED DEVICES                     |" 'Green'
        Invoke-StealthWrite "+================================================================+" 'Green'
        
        $discoveredDevices = $discoveredDevices | Sort-Object { [System.Version]($_.IP -replace '(\d+)', { $args[0].Value.PadLeft(3, '0') }) }
        
        foreach ($device in $discoveredDevices) {
            $ipFormatted = $device.IP.PadRight(15)
            $hostnameFormatted = $device.Hostname.PadRight(30)
            $status = if ($device.IP -eq $localIP) { "YOU" } else { "ONLINE" }
            $statusColor = if ($device.IP -eq $localIP) { "Yellow" } else { "Green" }
            
            Write-Host "| " -NoNewline -ForegroundColor Green
            Write-Host "$ipFormatted" -NoNewline -ForegroundColor Cyan
            Write-Host " | " -NoNewline -ForegroundColor Green
            Write-Host "$hostnameFormatted" -NoNewline -ForegroundColor White
            Write-Host " | " -NoNewline -ForegroundColor Green
            Write-Host "$status".PadRight(8) -NoNewline -ForegroundColor $statusColor
            Write-Host " |" -ForegroundColor Green
        }
        
        Invoke-StealthWrite "+================================================================+" 'Green'
        Invoke-StealthWrite "`n>> Total devices found: $($discoveredDevices.Count)" 'Cyan'
        
        # Device type analysis
        $routerIPs = $discoveredDevices | Where-Object { $_.IP -match '\.1$|\.254$' }
        $workstations = $discoveredDevices | Where-Object { $_.Hostname -match 'DESKTOP|PC|LAPTOP' }
        
        if ($routerIPs) {
            Invoke-StealthWrite ">> Potential routers/gateways: $($routerIPs.Count)" 'Yellow'
        }
        if ($workstations) {
            Invoke-StealthWrite ">> Workstations detected: $($workstations.Count)" 'Blue'
        }
        
    } else {
        Invoke-StealthWrite "+======================================================+" 'Yellow'
        Invoke-StealthWrite "|                  NO DEVICES FOUND                   |" 'Yellow'
        Invoke-StealthWrite "|        Network may be isolated or filtered          |" 'Yellow'
        Invoke-StealthWrite "+======================================================+" 'Yellow'
    }
    
    Write-Host ""
    Invoke-HackerPause
}

function Invoke-HackerPause {
    Write-Host ""
    $windowWidth = try { (Get-Host).UI.RawUI.WindowSize.Width } catch { 120 }
    $message = "[Press any key to continue...]"
    $padding = [math]::Max(0, [int](($windowWidth - $message.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Invoke-StealthWrite $message 'DarkGray'
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ========== MAIN EXECUTION LOOP ==========
function Start-PhantomProtocol {
    Assert-AdminPrivileges
    
    # Register graceful exit handler
    $null = Register-EngineEvent PowerShell.Exiting -Action { 
        Write-Host "`nPhantom Protocol terminated..." -ForegroundColor DarkCyan 
    }
    
    do {
        Show-OperationalInterface
        $userChoice = Read-Host " Select operation [1/2/3/4/5/0]"
        
        switch ($userChoice.Trim()) {
            "1" { Invoke-PhantomEngagement }
            "2" { Invoke-PhantomDisengagement }
            "3" { Invoke-EmergencyPurge }
            "4" { Invoke-SystemDiagnostics }
            "5" { Invoke-LANScanner }
            "0" { 
                Invoke-StealthWrite "`nTerminating Phantom Protocol..." 'DarkCyan'
                Start-Sleep -Milliseconds 500
                break 
            }
            default { 
                Invoke-StealthWrite "`n[!] Invalid operation code. Please select a valid option." 'Red'
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
    
    # Cleanup
    Unregister-Event -SourceIdentifier PowerShell.Exiting -ErrorAction SilentlyContinue
    Invoke-StealthWrite "Session terminated. Stay stealthy." 'DarkGreen'
}

# ========== INITIALIZE ==========
Start-PhantomProtocol
