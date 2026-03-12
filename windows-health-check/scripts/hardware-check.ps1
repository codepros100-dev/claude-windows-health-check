Write-Host "=== DEVICE MANAGER STATUS ==="
Get-PnpDevice | Where-Object { $_.Status -ne 'OK' -and $_.Status -ne 'Unknown' } |
    Select-Object Status, Class, FriendlyName, InstanceId |
    Format-Table -AutoSize

Write-Host "=== PROBLEM DEVICES (non-OK, non-disconnected) ==="
Get-PnpDevice | Where-Object { $_.Status -notin @('OK', 'Unknown') } |
    Select-Object Status, Class, FriendlyName |
    Format-Table -AutoSize

Write-Host "=== UNKNOWN/ERROR USB DEVICES ==="
Get-PnpDevice -Class USB -ErrorAction SilentlyContinue |
    Where-Object { $_.Status -ne 'OK' } |
    Select-Object Status, FriendlyName, InstanceId |
    Format-Table -AutoSize

Write-Host "=== GPU ==="
Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, DriverDate, Status, AdapterRAM | Format-Table -AutoSize

Write-Host "=== AUDIO ==="
Get-PnpDevice -Class AudioEndpoint -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'OK' } |
    Select-Object FriendlyName, Status | Format-Table -AutoSize
Get-PnpDevice -Class MEDIA -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'OK' } |
    Select-Object FriendlyName, Status | Format-Table -AutoSize

Write-Host "=== NETWORK DRIVERS ==="
Get-NetAdapter | Select-Object Name, InterfaceDescription, DriverVersion, Status | Format-Table -AutoSize

Write-Host "=== BATTERY HEALTH ==="
$batt = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
if ($batt) {
    Write-Host "Name: $($batt.Name)"
    Write-Host "Status: $($batt.Status)"
    Write-Host "Charge: $($batt.EstimatedChargeRemaining)%"
    Write-Host "RunTime: $($batt.EstimatedRunTime) minutes"
    # Try battery report
    try {
        $reportPath = "$env:TEMP\battery-report.xml"
        powercfg /batteryreport /xml /output $reportPath 2>$null
        if (Test-Path $reportPath) {
            [xml]$report = Get-Content $reportPath
            $designCap = $report.BatteryReport.Batteries.Battery.DesignCapacity
            $fullChargeCap = $report.BatteryReport.Batteries.Battery.FullChargeCapacity
            if ($designCap -and $fullChargeCap) {
                $health = [math]::Round(([int]$fullChargeCap / [int]$designCap) * 100, 1)
                Write-Host "DesignCapacity: $designCap mWh"
                Write-Host "FullChargeCapacity: $fullChargeCap mWh"
                Write-Host "BatteryHealth: $health%"
            }
            Remove-Item $reportPath -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "Battery report unavailable"
    }
} else {
    Write-Host "No battery detected (Desktop PC)"
}

Write-Host "=== DISK SMART ==="
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus, @{N="Size_GB";E={[math]::Round($_.Size/1GB,2)}} | Format-Table -AutoSize

Write-Host "=== DISCONNECTED DEVICE COUNT ==="
$disconnected = (Get-PnpDevice | Where-Object { $_.Status -eq 'Unknown' }).Count
Write-Host "$disconnected disconnected/ghost devices"
