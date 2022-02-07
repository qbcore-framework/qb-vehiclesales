local Translations = {
    error = {
        not_your_vehicle = 'Das ist nicht dein Fahrzeug..',
        vehicle_does_not_exist = 'Dieses Fahrzeug existiert nicht',
        not_enough_money = 'Du hast nicht genug Geld',
        finish_payments = 'Du musst das Fahrzeug fertig abbezahlen bevor du es verkaufen kannst..',
        no_space_on_lot = 'Es gibt keinen Platz für Ihr Auto auf dem Parkplatz!'
    },
    success = {
        sold_car_for_price = 'Du hast dein Auto verkauft für $%{value}',
        car_up_for_sale = 'Dein Auto ist zum Verkauf angeboten worden! Preis - $%{value}',
        vehicle_bought = 'Fahrzeug gekauft'
    },
    info = {
        confirm_cancel = '~g~Y~w~ - Bestätigen / ~r~N~w~ - Abbrechen ~g~',
        vehicle_returned = 'Dein Fahrzeug wird zurückgegeben',
        used_vehicle_lot = 'Parkplatz benutzt',
        sell_vehicle_to_dealer = '[~g~E~w~] - Fahrzeug an Händler verkaufen für ~g~$%{value}',
        view_contract = '[~g~E~w~] - Fahrzeugvertrag ansehen',
        cancel_sale = '[~r~G~w~] - Fahrzeugverkauf stornieren',
        model_price = '%{value}, Preis: ~g~$%{value2}',
        are_you_sure = 'Bist du dir sicher, dass du dein Fahrzeug nicht mehr verkaufen willst?',
        yes_no = '[~g~7~w~] - Ja | [~r~8~w~] - Nein',
        place_vehicle_for_sale = '[~g~E~w~] - Fahrzeug vom Eigentümer zum Verkauf anbieten'
    },
    charinfo = {
        firstname = 'not',
        lastname = 'known',
        account = 'Account not known..',
        phone = 'telephone number not known..'
    },
    mail = {
        sender = 'Larrys RV Sales',
        subject = 'Sie haben ein Fahrzeug verkauft!',
        message = 'Du hast $%{value} aus dem Verkauf vom %{value2}.'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
