Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

$RunningAsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (!$RunningAsAdmin) {
  Write-Error "Must be executed in Administrator level shell."
  exit 1
}

Copy-Item -Path "/tmp/consul-*" -Destination "C:\consul.d\"

# idempotently enable as a service
New-Service `
  -Name "Consul" `
  -BinaryPathName "C:\opt\consul.exe agent -config C:\opt\consul.d" `
  -StartupType "Automatic" `
  -ErrorAction Ignore

Restart-Service "Consul"
