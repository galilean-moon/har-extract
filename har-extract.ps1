param([string]$File)

if (-not $File -or -not (Test-Path $File)) {
    Write-Host "`nUsage: .\script.ps1 [FILE]"
    Write-Host "This program accepts a .har file and outputs extracted IPs and redirects.`n"
    exit 1
}

$har = Get-Content $File | ConvertFrom-Json

Write-Host "`n~=~=~=~ Extracting redirects and URL for domains(): ~=~=~=~"
$har.log.pages | Where-Object { $_.title } | ForEach-Object { $_.title }

Write-Host "`~=~=~=~ Redirects, IPs and NS hostnames: ~=~=~=~"
$domains = $har.log.entries |
    Where-Object { $_.response.redirectURL -ne "" } |
    ForEach-Object { $_.response.redirectURL -replace "https?://", "" -replace "/.*", "" } |
    Sort-Object -Unique

$apexes = @{}
foreach ($line in $domains) {
    if ($line -match "^www\.") {
        Write-Host $line
        $apex = $line -replace "^www\.", ""
        Write-Host $apex
    } else {
        Write-Host $line
        Write-Host "www.$line"
        $apex = $line
    }
    $apexes[$apex] = 1
}

$har.log.entries |
    Where-Object { $_.serverIPAddress } |
    ForEach-Object { $_.serverIPAddress } |
    Sort-Object -Unique

foreach ($apex in $apexes.Keys) {
    Write-Host "`n  $apex"
    Resolve-DnsName -Name $apex -Type NS | Where-Object { $_.NameHost } | ForEach-Object { $_.NameHost } | Sort-Object
}
