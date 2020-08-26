Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

Copy-Item -Path "/tmp/nomad-*" -Destination "C:\nomad.d\"
Restart-Service "Nomad"
