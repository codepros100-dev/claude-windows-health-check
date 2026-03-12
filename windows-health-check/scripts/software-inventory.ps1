Write-Host "=== INSTALLED SOFTWARE ==="
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object DisplayName |
    Format-Table -AutoSize

Write-Host "=== STARTUP PROGRAMS ==="
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location | Format-Table -AutoSize

Write-Host "=== WINGET UPGRADES AVAILABLE ==="
try {
    $upgrades = winget upgrade --accept-source-agreements 2>&1
    $upgrades | ForEach-Object { Write-Host $_ }
} catch {
    Write-Host "winget not available or error: $_"
}

Write-Host "=== DUPLICATE REGISTRY ENTRIES ==="
$all = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName } |
    Select-Object DisplayName, DisplayVersion
$dupes = $all | Group-Object DisplayName | Where-Object { $_.Count -gt 1 }
if ($dupes) {
    Write-Host "Found duplicate entries:"
    $dupes | ForEach-Object { Write-Host "  $($_.Name) (x$($_.Count))" }
} else {
    Write-Host "No duplicate entries found."
}
