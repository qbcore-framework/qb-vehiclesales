local Translations = {
    error = {
        not_your_vehicle = 'Dette er ikke dit køretøj..',
        vehicle_does_not_exist = 'Køretøjet eksistere ikke',
        not_enough_money = 'Du har ikke penge nok',
        finish_payments = 'Du skal have afbetalt alt for køretøjet, før du kan sælge den..',
        no_space_on_lot = 'Der er ingen plads til dit køretøj på pladsen!',
        not_in_veh = 'Du er ikke i et køretøj!',
        not_for_sale = 'Dette køretøj er IKKE til salg!',
    },
    menu = {
        view_contract = 'Vis kontrakt',
        view_contract_int = '[E] Vis kontrakt',
        sell_vehicle = 'Sælg køretøj',
        sell_vehicle_help = 'Sælg køretøj til en borger!',
        sell_back = 'Sælg bilen tilbage!',
        sell_back_help = 'Sælg din bil direkte tilbage til en nedsat pris!',
        interaction = '[E] Sælg køretøj',
    },
    success = {
        sold_car_for_price = 'Du har solgt dit køretøj for $%{value}',
        car_up_for_sale = 'Dit køretøj er blevet sat til salg! Pris - $%{value}',
        vehicle_bought = 'Køretøj købt',
    },
    info = {
        confirm_cancel = '~g~Y~w~ - Bekræft / ~r~N~w~ - Afbrudt ~g~',
        vehicle_returned = 'Dit køretøj er blevet retuneret',
        used_vehicle_lot = 'Brugtvogns forhandler',
        sell_vehicle_to_dealer = '[~g~E~w~] - Sælg bil til forhandler til ~g~$%{value}',
        view_contract = '[~g~E~w~] - Vis køretøjs kontrakt',
        cancel_sale = '[~r~G~w~] - Afbryd salg af køretøj',
        model_price = '%{value}, Pris: ~g~$%{value2}',
        are_you_sure = 'Er du sikke rpå at du ikke længere vil sælge dit køretøj?',
        yes_no = '[~g~7~w~] - Ja | [~r~8~w~] - Nej',
        place_vehicle_for_sale = '[~g~E~w~] - Placer køretøj til salg fra ejeren',
    },
    charinfo = {
        firstname = 'ikke',
        lastname = 'kendt',
        account = 'Konto findes ikke..',
        phone = 'mobilnummer eksistere ikke..',
    },
    mail = {
        sender = 'Larrys Brugtvogn',
        subject = 'Du har solgt et køretøj!',
        message = 'Du tjente $%{value} på et salg, på et køretøj til %{value2}.',
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
