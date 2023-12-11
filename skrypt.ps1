function Nalesniki-Restaurant {
    [CmdletBinding()]
    Param()

    Begin {
        # Write-Output "Witaj w Restauracji Naleśników!"
    }

    DynamicParam {
        $parameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $parameterAttribute.Mandatory = $true

        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($parameterAttribute)

        # parametr dynamiczny Name, zeby caly czas zwracac sie do klienta, uzywajac imie, ktore on podal 
        $parameter = New-Object System.Management.Automation.RuntimeDefinedParameter("customerName", [string], $attributeCollection)
        $parameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $parameters.Add("customerName", $parameter)

        # wiek potrzebien dla znizki (8% dla ludzi od 0-17 lat oraz 10% dla pelneletnich studentow)
        # jest to kolejny parametr dynamiczny
        $parameter = New-Object System.Management.Automation.RuntimeDefinedParameter("customerAge", [int], $attributeCollection)
        $parameters.Add("customerAge", $parameter)

        return $parameters
    }

    Process {
        # na poczatku mamy pusta tablice zamowien
        $allOrders = @()

        Pobieranie danych od klienta
        $customerName = $PSCmdlet.MyInvocation.BoundParameters["customerName"]
        if (-not $customerName) {
            $customerName = Read-Host "Dzień dobry! Jak masz na imię?"
        }

        $customerAge = $PSCmdlet.MyInvocation.BoundParameters["customerAge"]
        if (-not $customerAge) {
            $customerAge = Read-Host "Ile masz lat, $customerName?"
        }

        Write-Output ""
        Write-Output "Witaj, $customerName! ($customerAge lat) Miło Cię widzieć w Restauracji Naleśników."

        $discount = 0
        if ($customerAge -lt 18 -or ((Read-Host "Czy jesteś studentem? (T/N)").ToUpper() -eq 'T')) {
            $discount = if ($customerAge -lt 18) { 8 } else { 10 }
        }

        $subtotal = 0
        $selectedItems = @()

        # Wyswietlenie menu
        Write-Output ""
        Write-Output "------------------------------------------------------------" 
        Write-Output "Menu Restauracji Naleśników:"
        Write-Output "1. Oreo Pancake - 20 zł"
        Write-Output "2. Pancake z frytkami z McDonald's - 24 zł"
        Write-Output "3. Pancake z Kinder Bueno - 18 zł"
        Write-Output "4. Klasyczne amerykańskie Pancakes z maple syrop - 25 zł"
        Write-Output "------------------------------------------------------------" 

        # interakcja z klietnem, wybor dan z menu
        do {
            $selectedItem = Read-Host "Wybierz numer dania z menu (1-4), wpisz 'Doppingi' lub 'Napoje', lub 'Zakoncz', aby zakończyć zamawianie."

            switch ($selectedItem) {
                'Doppingi' {
                    $dopping = Read-Host "Wybierz dopingu (Czekolada / Bita Śmietanka / Biała Czekolada) lub wpisz 'Zakoncz', aby zakończyć wybieranie doppingsów."
                    if ($dopping -eq 'Zakoncz') {
                        break
                    }

                    $doppingQuantity = Read-Host "Podaj ilość doppingsów:"
                    # Dodanie doppingsa do zamówienia
                    1..$doppingQuantity | ForEach-Object {
                        $selectedItems += @{
                            Dopping = @{
                                Name = $dopping
                                Price = 2
                            }
                        }
                        $subtotal += $selectedItems[-1].Dopping.Price
                    }
                }
                'Napoje' {
                    $drink = Read-Host "Wybierz napój (Cola / Chocolate Milkshake / Fanta) lub wpisz 'Zakoncz', aby zakończyć wybieranie napojów."
                    if ($drink -eq 'Zakoncz') {
                        break
                    }

                    $drinkQuantity = Read-Host "Podaj ilość napojów:"
                    # Dodanie napoju do zamówienia
                    1..$drinkQuantity | ForEach-Object {
                        $selectedItems += @{
                            Drink = @{
                                Name = $drink
                                Price = switch ($drink) {
                                    'Cola' { 4 }
                                    'Chocolate Milkshake' { 15 }
                                    'Fanta' { 3 }
                                }
                            }
                        }
                        $subtotal += $selectedItems[-1].Drink.Price
                    }
                }
                'Zakoncz' {
                    if ($selectedItems.Count -eq 0) {
                        Write-Output "Nie dokonano zamówienia. Do zobaczenia!"
                        return
                    } else {
                        break
                    }
                }
                default {
                    if ($selectedItem -ge 1 -and $selectedItem -le 4) {
                        # Dodanie dania do zamówienia
                        $selectedItems += @{
                            Name = switch ($selectedItem) {
                                1 { "Oreo Pancake" }
                                2 { "Pancake z frytkami z McDonald's" }
                                3 { "Pancake z Kinder Bueno" }
                                4 { "Klasyczne amerykańskie Pancakes z maple syrop" }
                            }
                            Price = switch ($selectedItem) {
                                1 { 20 }
                                2 { 24 }
                                3 { 18 }
                                4 { 25 }
                            }
                        }
                        $subtotal += $selectedItems[-1].Price
                    } else {
                        Write-Output "Nieprawidłowy wybór. Spróbuj ponownie."
                    }
                }
            }
        } while ($selectedItem -ne 'Zakoncz')

        # Wyświetlanie informacji w kolejności
        Write-Output ""
        Write-Output "------------------------------------------------------------"
        Write-Output "                      Rachunek:           "
        foreach ($item in $selectedItems) {
            if ($item.Name) {
                Write-Output "$($item.Name) - $($item.Price) zł"
            }
            if ($item.Dopping) {
                Write-Output "->Doping: $($item.Dopping.Name) - $($item.Dopping.Price) zł"
            }
            if ($item.Drink) {
                Write-Output "->Napój: $($item.Drink.Name) - $($item.Drink.Price) zł"
            }
        }

        # Cena bez zniżek
        $subtotalWithoutDiscount = $subtotal

        # Zniżki
        if ($discount -ne 0) {
            $discountAmount = ($subtotal * $discount) / 100
            $subtotal -= $discountAmount
            # Write-Output "Zniżka $discount%: -$($discountAmount) zł"
        }

        # Napiwki
        Write-Output ""
        $tipPercentage = Read-Host "Podaj procent napiwków, jaki chcesz zostawić (wpisz 0, jeśli nie chcesz dawać napiwków):"
        $tipAmount = [math]::Round(($subtotal * $tipPercentage / 100), 2)
        $totalAmount = $subtotal + $tipAmount
        Write-Output ""

        # informacja o rachunku
        Write-Host "------------------------------------------------------------" 
        Write-Output "Cena bez zniżek: $($subtotalWithoutDiscount) zł"
        Write-Output "Zniżka student/dziecko ($discount%): -$($discountAmount) zł"
        Write-Output "Całkowita suma przed napiwkami: $($subtotal) zł"
        Write-Output "Wybrana ilość napiwków ($tipPercentage%): +$($tipAmount) zł"
        Write-Host "Końcowa suma: $($totalAmount) zł" -ForegroundColor Green

        # Metoda płatności
        do {
            $paymentMethod = Read-Host "Wybierz metodę płatności (Karta / Gotówka):"
            if ($paymentMethod -eq 'Gotówka') {
                do {
                    $paidAmount = Read-Host "Podaj sumę, jaką płacisz: "
                    $change = $paidAmount - $totalAmount
                    if ($change -gt $0) {
                        Write-Host "Opłata zakończona sukcesem. Reszta do wydania: $($change) zł." -ForegroundColor Green
                        $paid = $true
                    } elseif ($change -eq $0) {
                        Write-Host "Opłata zakończona sukcesem. Dziękujemy, $customerName! Życzymy smacznego!" -ForegroundColor Green
                        $paid = $true
                    } elseif ($change -lt $0) {
                        Write-Host "Podana suma jest niewystarczająca. Brakuje: $($totalAmount - $paidAmount) zł. Podaj poprawną kwotę." -ForegroundColor Green
                    }
                } while (-not $paid)
            } elseif ($paymentMethod -eq 'Karta') {
                Write-Output "Opłata zakończona sukcesem."
                $paid = $true
            } else {
                Write-Output "Nieprawidłowa metoda płatności. Spróbuj ponownie."
            }
        } while (-not $paid)

        Write-Output "Dziękujemy, $customerName! Życzymy smacznego!"
        Write-Output "------------------------------------------------------------"

        # Pytanie o ocenę restauracji
        $rating = Read-Host "Oceń naszą restaurację od 0 do 5 (0 - bardzo źle, 5 - doskonale):"
        if ($rating -ge 0 -and $rating -le 4) {
            $feedback = Read-Host "Co możemy poprawić?" 
            Write-Output "Bardzo nam Przykro. Dziękujemy za informację. Postaramy się to poprawić."
        } elseif ($rating -eq 5) {
            Write-Output "Dziękujemy bardzo za doskonałą ocenę! Cieszymy się, że jesteś zadowolony z naszej restauracji."
        } else {
            Write-Output "Ocena jest poza zakresem. Prosimy o ocenę od 0 do 5."
        }
    }

    End {
        Write-Output "------------------------------------------------------------" 
        Write-Output "Do zobaczenia!"
    }
}

# Wywołanie funkcji przez konsolę:
Nalesniki-Restaurant
