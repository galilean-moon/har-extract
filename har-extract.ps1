param([string]$File)

if (-not $File -or -not (Test-Path $File)) {
    Write-Host "`nUsage: .\script.ps1 [FILE]"
    Write-Host "This program accepts a .har file and outputs extracted redirects, IPs, and NS hostnames.`n"
    exit 1
}

$har = Get-Content $File | ConvertFrom-Json

Write-Host "`n~=~=~=~ Extracting for domains(): ~=~=~=~"
$har.log.pages | Where-Object { $_.title } | ForEach-Object { $_.title }

Write-Host "`n~=~=~=~ Redirects, IPs and NS hostnames: ~=~=~=~"
$domains = $har.log.entries |
    Where-Object { $_.response.redirectURL -ne "" } |
    ForEach-Object { $_.response.redirectURL -replace "https?://", "" -replace "/.*", "" -replace "^www\.", "" } |
    Sort-Object -Unique

$apexes = @{}
$seen = @{}

foreach ($line in $domains) {
    Write-Host $line
    Write-Host "www.$line"
    $apexes[$line] = 1
}

$har.log.entries |
    Where-Object { $_.serverIPAddress } |
    ForEach-Object { $_.serverIPAddress } |
    Sort-Object -Unique

foreach ($apex in $apexes.Keys) {
    Write-Host "`n  $apex"
    Resolve-DnsName -Name $apex -Type NS | Where-Object { $_.Type -eq "NS" } | ForEach-Object { $_.NameHost.Trim() } | Sort-Object
}
