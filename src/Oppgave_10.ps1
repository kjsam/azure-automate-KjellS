[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $UrlKortstokk = "http://nav-deckofcards.herokuapp.com/shuffle"
)

$blackjack = 21
$stopp = 17

function KortstokkPrint {
    param (
        [Parameter()]
        [Object[]]
        $kortstokk
    )
    $ks = ""
    foreach ($kort in $kortstokk) {
        $ks += $kort.suit[0] + $kort.value + ","
    }
    if ($kortstokk.count -gt 0){
        $ks.Substring(0,$ks.Length-1)
    }
    else {
        $null
    }
}

function PoengsumKortstokk {
    [OutputType([int])]
    param (
        [object[]]
        $kortstokk
    )
    [int]$sum = 0
    foreach ($kort in $kortstokk) {
        $sum += switch ($kort.value){
            'J' {10}
            'Q' {10}
            'K' {10}
            'A' {11}
            Default {[int]$kort.value}
        }
    }
    $sum
}
function skrivUtResultat {
    param (
        [string]
        $vinner,        
        [object[]]
        $kortStokkMagnus,
        [object[]]
        $kortStokkMeg        
    )
    Write-Host -ForegroundColor Cyan "Vinner: $vinner"
    Write-Host "Magnus | $(PoengsumKortstokk -kortstokk $kortStokkMagnus) | $(KortstokkPrint -kortstokk $kortStokkMagnus)"    
    Write-Host "Meg    | $(PoengsumKortstokk -kortstokk $kortStokkMeg) | $(KortstokkPrint -kortstokk $kortStokkMeg)"
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

$kortstokk = $response.Content | ConvertFrom-Json

Write-Host "Kortstokk: $(KortstokkPrint($kortstokk))"
Write-Host "Poengsum: $(PoengsumKortstokk $kortstokk)"

$meg = $kortstokk[0..1]
$kortstokk = $kortstokk[2..$kortstokk.count]
$magnus = $kortstokk[0..1]
$kortstokk = $kortstokk[2..$kortstokk.count]

Write-Host "Meg: $(KortstokkPrint($meg))"
Write-Host "Magnus: $(KortstokkPrint($magnus))"
Write-Host "Kortstokk: $(KortstokkPrint($kortstokk))"

If (((PoengsumKortstokk -kortstokk $meg) -eq $blackjack) -and ((PoengsumKortstokk -kortstokk  $magnus) -eq $blackjack)){
    skrivUtResultat -vinner "Draw" -kortStokkMagnus $magnus -kortStokkMeg $meg
}
elseif ((PoengsumKortstokk -kortstokk $meg) -eq $blackjack) {
    skrivUtResultat -vinner "Meg" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}
elseif ((PoengsumKortstokk -kortstokk $magnus) -eq $blackjack) {
    skrivUtResultat -vinner "Magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}

while ((PoengsumKortstokk -kortstokk $meg) -lt $stopp) {
    $meg += $kortstokk[0]
    $kortstokk = $kortstokk[1..$kortstokk.count]
}

$MinPoengSum = PoengsumKortstokk -kortstokk $meg
if (($MinPoengSum) -gt $blackjack) {
    skrivUtResultat -vinner "Magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}

while ((PoengsumKortstokk -kortstokk $magnus) -le ($MinPoengSum)) {
    $magnus += $kortstokk[0]
    $kortstokk = $kortstokk[1..$kortstokk.count]
}

if ((PoengsumKortstokk -kortstokk $magnus) -gt $blackjack) {
    skrivUtResultat -vinner "Meg" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}

skrivUtResultat -vinner "Magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg
