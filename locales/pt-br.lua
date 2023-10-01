local Translations = {
    error = {
        not_your_vehicle = 'Este não é o seu veículo..',
        vehicle_does_not_exist = 'Veículo não existe',
        not_enough_money = 'Você não tem dinheiro suficiente',
        finish_payments = 'Você deve terminar de pagar este veículo antes de poder vendê-lo..',
        no_space_on_lot = 'Não há espaço para o seu carro no lote!',
        not_in_veh = 'Você não está em um veículo!',
        not_for_sale = 'Este veículo NÃO está à venda!',
    },
    menu = {
        view_contract = 'Ver Contrato',
        view_contract_int = '[E] Ver Contrato',
        sell_vehicle = 'Vender Veículo',
        sell_vehicle_help = 'Venda veículo para seus concidadãos!',
        sell_back = 'Vender carro de volta!',
        sell_back_help = 'Venda seu carro de volta diretamente por um preço reduzido!',
        interaction = '[E] Vender Veículo',
    },
    success = {
        sold_car_for_price = 'Você vendeu seu carro por $%{value}',
        car_up_for_sale = 'Seu carro foi colocado à venda! Preço - $%{value}',
        vehicle_bought = 'Veículo Comprado',
    },
    info = {
        confirm_cancel = '~g~Y~w~ - Confirmar / ~r~N~w~ - Cancelar ~g~',
        vehicle_returned = 'Seu veículo foi devolvido',
        used_vehicle_lot = 'Lote de Carros Usados',
        sell_vehicle_to_dealer = '[~g~E~w~] - Vender Veículo Para Revendedor Por ~g~$%{value}',
        view_contract = '[~g~E~w~] - Ver Contrato do Veículo',
        cancel_sale = '[~r~G~w~] - Cancelar Venda do Veículo',
        model_price = '%{value}, Preço: ~g~$%{value2}',
        are_you_sure = 'Você tem certeza de que não deseja mais vender seu veículo?',
        yes_no = '[~g~7~w~] - Sim | [~r~8~w~] - Não',
        place_vehicle_for_sale = '[~g~E~w~] - Colocar Veículo À Venda Por Proprietário',
    },
    charinfo = {
        firstname = 'não',
        lastname = 'conhecido',
        account = 'Conta não conhecida..',
        phone = 'número de telefone não conhecido..',
    },
    mail = {
        sender = 'Larrys RV Sales',
        subject = 'Você vendeu um veículo!',
        message = 'Você ganhou $%{value} com a venda do seu %{value2}.',
    }
}

if GetConvar('qb_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end