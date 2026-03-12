Write-Host "=== CRITICAL SERVICES ==="
$criticalServices = @(
    'wuauserv',      # Windows Update
    'WinDefend',     # Windows Defender
    'Dhcp',          # DHCP Client
    'Dnscache',      # DNS Client
    'EventLog',      # Event Log
    'Schedule',      # Task Scheduler
    'Spooler',       # Print Spooler
    'LanmanWorkstation', # Workstation
    'LanmanServer',  # Server
    'WSearch',       # Windows Search
    'BITS',          # BITS
    'CryptSvc',      # Cryptographic Services
    'DcomLaunch',    # DCOM Launcher
    'RpcSs',         # RPC
    'SamSs',         # SAM
    'Winmgmt',       # WMI
    'W32Time'        # Windows Time
)

foreach ($svc in $criticalServices) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        $startType = (Get-CimInstance Win32_Service -Filter "Name='$svc'" -ErrorAction SilentlyContinue).StartMode
        Write-Host "$($s.Status) | $startType | $svc ($($s.DisplayName))"
    } else {
        Write-Host "NOT FOUND | $svc"
    }
}

Write-Host "=== FAILED/STOPPED AUTO-START SERVICES ==="
Get-CimInstance Win32_Service | Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' } |
    Select-Object Name, DisplayName, State, StartMode | Format-Table -AutoSize

Write-Host "=== EVENT VIEWER ERRORS (7 days) ==="
$startDate = (Get-Date).AddDays(-7)
try {
    Get-WinEvent -FilterHashtable @{LogName='System'; Level=2; StartTime=$startDate} -MaxEvents 20 -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, ProviderName, @{N="Message";E={$_.Message.Substring(0, [math]::Min(200, $_.Message.Length))}} |
        Format-Table -AutoSize -Wrap
} catch {
    Write-Host "No critical system errors in last 7 days."
}

try {
    Get-WinEvent -FilterHashtable @{LogName='Application'; Level=2; StartTime=$startDate} -MaxEvents 10 -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, ProviderName, @{N="Message";E={$_.Message.Substring(0, [math]::Min(200, $_.Message.Length))}} |
        Format-Table -AutoSize -Wrap
} catch {
    Write-Host "No critical application errors in last 7 days."
}
