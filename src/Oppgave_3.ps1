$Url = "http://nav-deckofcards.herokuapp.com/shuffle"

Clear-Host
$response = Invoke-WebRequest -Uri $Url
$cards = $response.Content | ConvertFrom-Json

