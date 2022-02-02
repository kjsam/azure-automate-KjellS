[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $UrlKortstokk = "http://nav-deckofcards.herokuapp.com/shuffle"
)

function KortstokkPrint {
    param (
        [Parameter()]
        [Object[]]
        $cards
    )
    $kortstokk = ""
    foreach ($card in $cards) {
        $kortstokk += $card.suit[0] + $card.value + ","
    }
    $kortstokk.Substring(0,$kortstokk.Length-1)
}

function PoengsumKortstokk {
    [OutputType([int])]
    param (
        [object[]]
        $cards
    )
    $sum = 0
    foreach ($card in $cards) {
        $sum += switch ($card.value){
            'J' {10}
            'Q' {10}
            'K' {10}
            'A' {11}
            Default {$card.value}
        }
    }
    $sum
}

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

Write-Host "Kortstokk: $(KortstokkPrint($cards))"
Write-Host "Poengsum: $(PoengsumKortstokk $cards)"

$meg = $cards[0..1]
$cards = $cards[2..$cards.Length]
$magnus = $cards[0..1]
$cards = $cards[2..$cards.Length]

Write-Host "Meg: $(KortstokkPrint($meg))"
Write-Host "Magnus: $(KortstokkPrint($magnus))"
Write-Host "Kortstokk: $(KortstokkPrint($cards))"
