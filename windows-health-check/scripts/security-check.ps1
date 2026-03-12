Write-Host "=== DEFENDER STATUS ==="
$def = Get-MpComputerStatus
Write-Host "AntivirusEnabled: $($def.AntivirusEnabled)"
Write-Host "AntispywareEnabled: $($def.AntispywareEnabled)"
Write-Host "RealTimeProtectionEnabled: $($def.RealTimeProtectionEnabled)"
Write-Host "SignatureLastUpdated: $($def.AntivirusSignatureLastUpdated)"
Write-Host "QuickScanEndTime: $($def.QuickScanEndTime)"
Write-Host "FullScanEndTime: $($def.FullScanEndTime)"
Write-Host "FullScanAge: $($def.FullScanAge) days"

Write-Host "=== FIREWALL ==="
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize

Write-Host "=== PENDING UPDATES ==="
try {
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $results = $searcher.Search("IsInstalled=0")
    Write-Host "$($results.Updates.Count) pending updates"
    for ($i = 0; $i -lt $results.Updates.Count; $i++) {
        Write-Host "  - $($results.Updates.Item($i).Title)"
    }
} catch {
    Write-Host "ERROR checking updates: $_"
}

Write-Host "=== RECENTLY INSTALLED (30 days) ==="
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -and $_.InstallDate } |
    ForEach-Object {
        try {
            $date = [datetime]::ParseExact($_.InstallDate, "yyyyMMdd", $null)
            if ($date -gt (Get-Date).AddDays(-30)) {
                [PSCustomObject]@{
                    Name = $_.DisplayName
                    Version = $_.DisplayVersion
                    InstallDate = $_.InstallDate
                }
            }
        } catch {}
    } | Sort-Object InstallDate -Descending | Format-Table -AutoSize
