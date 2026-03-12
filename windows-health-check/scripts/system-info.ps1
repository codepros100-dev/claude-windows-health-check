Write-Host "=== SYSTEM INFO ==="
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$cs = Get-CimInstance Win32_ComputerSystem
$batt = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue

Write-Host "OS: $($os.Caption)"
Write-Host "Version: $($os.Version)"
Write-Host "Build: $($os.BuildNumber)"
Write-Host "Architecture: $($os.OSArchitecture)"
Write-Host "CPU: $($cpu.Name)"
Write-Host "Cores: $($cpu.NumberOfCores)"
Write-Host "LogicalProcessors: $($cpu.NumberOfLogicalProcessors)"
Write-Host "BaseClockMHz: $($cpu.MaxClockSpeed)"
Write-Host "TotalRAM_GB: $([math]::Round($cs.TotalPhysicalMemory/1GB,2))"
$usedRAM = $cs.TotalPhysicalMemory - ($os.FreePhysicalMemory * 1024)
Write-Host "UsedRAM_GB: $([math]::Round($usedRAM/1GB,2))"
Write-Host "FreeRAM_GB: $([math]::Round(($os.FreePhysicalMemory * 1024)/1GB,2))"
Write-Host "RAMPercent: $([math]::Round(($usedRAM / $cs.TotalPhysicalMemory) * 100,1))"
Write-Host "DiskTotal_GB: $([math]::Round($disk.Size/1GB,2))"
Write-Host "DiskUsed_GB: $([math]::Round(($disk.Size - $disk.FreeSpace)/1GB,2))"
Write-Host "DiskFree_GB: $([math]::Round($disk.FreeSpace/1GB,2))"
Write-Host "DiskUsedPercent: $([math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100,1))"
Write-Host "LastBoot: $($os.LastBootUpTime)"
$uptime = (Get-Date) - $os.LastBootUpTime
Write-Host "Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
Write-Host "Manufacturer: $($cs.Manufacturer)"
Write-Host "Model: $($cs.Model)"

if ($batt) {
    Write-Host "BatteryStatus: $($batt.EstimatedChargeRemaining)%"
    Write-Host "BatteryName: $($batt.Name)"
} else {
    Write-Host "BatteryStatus: N/A (Desktop)"
}

Write-Host "=== DISK HEALTH ==="
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus, @{N="Size_GB";E={[math]::Round($_.Size/1GB,2)}} | Format-Table -AutoSize

Write-Host "=== ALL DRIVES ==="
Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, VolumeName, @{N="Size_GB";E={[math]::Round($_.Size/1GB,2)}}, @{N="Free_GB";E={[math]::Round($_.FreeSpace/1GB,2)}}, DriveType | Format-Table -AutoSize

Write-Host "=== ACTIVATION ==="
try {
    $lic = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -and $_.Name -like "*Windows*" }
    $status = switch ($lic.LicenseStatus) { 0{"Unlicensed"} 1{"Licensed/Activated"} 2{"OOBGrace"} 3{"OOTGrace"} 4{"NonGenuineGrace"} 5{"Notification"} 6{"ExtendedGrace"} }
    Write-Host "Activation: $status"
} catch {
    Write-Host "Activation: Could not determine (may need elevation)"
}
