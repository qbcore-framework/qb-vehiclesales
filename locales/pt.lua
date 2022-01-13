local Translations = {
    error = {
        not_your_vehicle = 'Este veículo não te pertence..',
        vehicle_does_not_exist = 'O veículo não existe',
        not_enough_money = 'Não tens dinheiro suficiente',
        finish_payments = 'Precisas de acabar de pagar este veículo, antes de o poderes vender..',
        no_space_on_lot = 'Não existe espaço para o teu veículo!'
    },
    success = {
        sold_car_for_price = 'Vendeste o teu veículo por %{value}€',
        car_up_for_sale = 'Colocaste o teu veículo à venda! Preço - %{value}€',
        vehicle_bought = 'Veículo Comprado'
    },
    info = {
        confirm_cancel = '~g~Y~w~ - Confirmar / ~r~N~w~ - Cancelar ~g~',
        vehicle_returned = 'O teu veículo foi devolvido',
        used_vehicle_lot = 'Parque De Veículos Usados',
        sell_vehicle_to_dealer = '[~g~E~w~] - Vender Veículo Ao Dealer Por ~g~%{value}€',
        view_contract = '[~g~E~w~] - Ver Contrato De Venda',
        cancel_sale = '[~r~G~w~] - Cancelar Venda De Veículo',
        model_price = '%{value}, Preço: ~g~%{value2}€',
        are_you_sure = 'Tens a certeza que queres remover o teu veículo da venda de usados?',
        yes_no = '[~g~7~w~] - Sim | [~r~8~w~] - Não',
        place_vehicle_for_sale = '[~g~E~w~] - Colocar Veículo à Venda Nos Usados'
    },
    charinfo = {
        firstname = 'Não',
        lastname = 'Indicado',
        account = 'Conta Desconhecida..',
        phone = 'Telemóvel Desconhecido..'
    },
    mail = {
        sender = 'Larrys RV Sales',
        subject = 'Vendeste um veículo!',
        message = 'Ganhaste %{value}€ com a venda do veículo %{value2}.'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
