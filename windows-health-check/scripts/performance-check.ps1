Write-Host "=== TEMP FOLDER SIZES ==="
$userTemp = (Get-ChildItem $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
Write-Host "UserTemp_GB: $([math]::Round($userTemp/1GB,2))"

$winTemp = (Get-ChildItem "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
Write-Host "WindowsTemp_GB: $([math]::Round($winTemp/1GB,2))"

$wuCache = (Get-ChildItem "C:\Windows\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
Write-Host "WUCache_GB: $([math]::Round($wuCache/1GB,2))"

Write-Host "=== LARGE USER FOLDERS ==="
$userProfile = [Environment]::GetFolderPath("UserProfile")
Get-ChildItem $userProfile -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    if ($size -gt 1GB) {
        Write-Host "$([math]::Round($size/1GB,2)) GB - $($_.FullName)"
    }
} | Sort-Object

Write-Host "=== TOP PROCESSES BY CPU ==="
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, @{N="CPU_Sec";E={[math]::Round($_.CPU,1)}}, @{N="RAM_MB";E={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -AutoSize

Write-Host "=== TOP PROCESSES BY RAM ==="
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 Name, @{N="RAM_MB";E={[math]::Round($_.WorkingSet64/1MB,1)}}, @{N="CPU_Sec";E={[math]::Round($_.CPU,1)}} | Format-Table -AutoSize
