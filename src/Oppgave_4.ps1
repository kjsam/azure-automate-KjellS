[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $UrlKortstokk = "http://nav-deckofcards.herokuapp.com/shuffle"
)

Clear-Host
$ErrorActionPreference = 'Stop'

try {
    $response = Invoke-WebRequest -Uri $UrlKortstokk
}
catch {
    Write-Warning "Kunne ikke hente kortstokk fra URL: $UrlKortstokk"
    Exit 1
}

$cards = $response.Content | ConvertFrom-Json

$kortstokk = ""
foreach ($card in $cards) {
    $kortstokk += $card.suit[0] + $card.value + ","
}

Write-Host "Kortstokk: $kortstokk.Substring(0,$kortstokk.Length-1)"

