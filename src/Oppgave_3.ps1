$Url = "http://nav-deckofcards.herokuapp.com/shuffle"

Clear-Host
$response = Invoke-WebRequest -Uri $Url
$cards = $response.Content | ConvertFrom-Json

$kortstokk = ""
foreach ($card in $cards) {
    $kortstokk += $card.suit[0] + $card.value + ","
}

Write-Host "Kortstokk: $kortstokk.Substring(0,$kortstokk.Length-1)"
