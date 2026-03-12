Write-Host "=== NETWORK ADAPTERS ==="
Get-NetAdapter | Select-Object Name, Status, LinkSpeed, InterfaceDescription, MacAddress | Format-Table -AutoSize

Write-Host "=== DNS SETTINGS ==="
Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object { $_.ServerAddresses } | Select-Object InterfaceAlias, ServerAddresses | Format-Table -AutoSize

Write-Host "=== CONNECTIVITY TEST ==="
$ping1 = Test-Connection 8.8.8.8 -Count 1 -Quiet
Write-Host "Ping 8.8.8.8: $(if($ping1){'Success'}else{'FAILED'})"
$ping2 = Test-Connection google.com -Count 1 -Quiet
Write-Host "Ping google.com: $(if($ping2){'Success'}else{'FAILED'})"

Write-Host "=== IP CONFIGURATION ==="
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -ne "127.0.0.1" } | Select-Object InterfaceAlias, IPAddress, PrefixLength | Format-Table -AutoSize

Write-Host "=== ACTIVE CONNECTIONS ==="
Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess |
    ForEach-Object {
        $procName = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName
        [PSCustomObject]@{
            LocalAddr = $_.LocalAddress
            LocalPort = $_.LocalPort
            RemoteAddr = $_.RemoteAddress
            RemotePort = $_.RemotePort
            Process = $procName
        }
    } | Format-Table -AutoSize

Write-Host "=== LISTENING PORTS ==="
$listening = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue
Write-Host "$($listening.Count) listening ports"
