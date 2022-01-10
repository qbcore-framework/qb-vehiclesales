local Translations = {
    error = {
        not_your_vehicle = 'This is not your vehicle..',
        vehicle_does_not_exist = 'Vehicle does not exist',
        not_enough_money = 'You dont have enough money',
        finish_payments = 'You must finish paying off this vehicle, Before you can sell it..',
        no_space_on_lot = 'There is not space for your car on the lot!'
    },
    success = {
        sold_car_for_price = 'You have sold your car for $%{value}',
        car_up_for_sale = 'Your car has been put up for sale! Price - $%{value}',
        vehicle_bought = 'Vehicle Bought'
    },
    info = {
        confirm_cancel = '~g~Y~w~ - Confirm / ~r~N~w~ - Cancel ~g~',
        vehicle_returned = 'You vehicle is returned',
        used_vehicle_lot = 'Used Vehicle Lot',
        sell_vehicle_to_dealer = '[~g~E~w~] - Sell Vehicle To Dealer For ~g~$%{value}',
        view_contract = '[~g~E~w~] - View Vehicle Contract',
        cancel_sale = '[~r~G~w~] - Cancel Vehicle Sale',
        model_price = '%{value}, Price: ~g~$%{value2}',
        are_you_sure = 'Are you sure you no longer want to sell your vehicle?',
        yes_no = '[~g~7~w~] - Yes | [~r~8~w~] - No',
        place_vehicle_for_sale = '[~g~E~w~] - Place Vehicle For Sale By Owner'
    },
    charinfo = {
        firstname = 'not',
        lastname = 'known',
        account = 'Account not known..',
        phone = 'telephone number not known..'
    },
    mail = {
        sender = 'Larrys RV Sales',
        subject = 'You have sold a vehicle!',
        message = 'You made $%{value} from the sale of your %{value2}.'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
