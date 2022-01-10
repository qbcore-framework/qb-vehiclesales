local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function generateOID()
    local num = math.random(1, 10) .. math.random(111, 999)

    return "OC" .. num
end

local function escapeSqli(str)
    local replacements = {
        ['"'] = '\\"',
        ["'"] = "\\'"
    }
    return str:gsub("['\"]", replacements) -- or string.gsub( source, "['\"]", replacements )
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-occasions:server:getVehicles', function(source, cb)
    local result = MySQL.Sync.fetchAll('SELECT * FROM occasion_vehicles', {})
    if result[1] ~= nil then
        cb(result)
    else
        cb(nil)
    end
end)

QBCore.Functions.CreateCallback("qb-occasions:server:getSellerInformation", function(source, cb, citizenid)
    MySQL.Async.fetchAll('SELECT * FROM players WHERE citizenid = ?', {citizenid}, function(result)
        if result[1] ~= nil then
            cb(result[1])
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback("qb-vehiclesales:server:CheckModelName", function(source, cb, plate)
    if plate then
        local ReturnData = MySQL.Sync.fetchScalar("SELECT vehicle FROM player_vehicles WHERE plate = ?", {plate})
        cb(ReturnData)
    end
end)

-- Events

RegisterNetEvent('qb-occasions:server:ReturnVehicle', function(vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.Sync.fetchAll('SELECT * FROM occasion_vehicles WHERE plate = ? AND occasionid = ?',
        {vehicleData['plate'], vehicleData["oid"]})
    if result[1] ~= nil then
        if result[1].seller == Player.PlayerData.citizenid then
            MySQL.Async.insert(
                'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
                {Player.PlayerData.license, Player.PlayerData.citizenid, vehicleData["model"],
                 GetHashKey(vehicleData["model"]), vehicleData["mods"], vehicleData["plate"], 0})
            MySQL.Async.execute('DELETE FROM occasion_vehicles WHERE occasionid = ? AND plate = ?',
                {vehicleData["oid"], vehicleData['plate']})
            TriggerClientEvent("qb-occasions:client:ReturnOwnedVehicle", src, result[1])
            TriggerClientEvent('qb-occasion:client:refreshVehicles', -1)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_your_vehicle'), 'error', 3500)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.vehicle_does_not_exist'), 'error', 3500)
    end
end)

RegisterNetEvent('qb-occasions:server:sellVehicle', function(vehiclePrice, vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    MySQL.Async.execute('DELETE FROM player_vehicles WHERE plate = ? AND vehicle = ?',{vehicleData.plate, vehicleData.model})
    MySQL.Async.insert('INSERT INTO occasion_vehicles (seller, price, description, plate, model, mods, occasionid) VALUES (?, ?, ?, ?, ?, ?, ?)',{Player.PlayerData.citizenid, vehiclePrice, escapeSqli(vehicleData.desc), vehicleData.plate, vehicleData.model,json.encode(vehicleData.mods), generateOID()})
    TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "Vehicle for Sale", "red","**" .. GetPlayerName(src) .. "** has a " .. vehicleData.model .. " priced at " .. vehiclePrice)
    TriggerClientEvent('qb-occasion:client:refreshVehicles', -1)
end)

RegisterNetEvent('qb-occasions:server:sellVehicleBack', function(vData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local price = math.floor(vData.price / 2)
    local plate = vData.plate
    Player.Functions.AddMoney('bank', price)
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.sold_car_for_price', { value = price }), 'success', 5500)
    MySQL.Async.execute('DELETE FROM player_vehicles WHERE plate = ?', {plate})
end)

RegisterNetEvent('qb-occasions:server:buyVehicle', function(vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.Sync.fetchAll('SELECT * FROM occasion_vehicles WHERE plate = ? AND occasionid = ?',{vehicleData['plate'], vehicleData["oid"]})
    if result[1] ~= nil and next(result[1]) ~= nil then
        if Player.PlayerData.money.bank >= result[1].price then
            local SellerCitizenId = result[1].seller
            local SellerData = QBCore.Functions.GetPlayerByCitizenId(SellerCitizenId)
            local NewPrice = math.ceil((result[1].price / 100) * 77)
            Player.Functions.RemoveMoney('bank', result[1].price)
            MySQL.Async.insert(
                'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                    Player.PlayerData.license,
                    Player.PlayerData.citizenid, result[1]["model"],
                    GetHashKey(result[1]["model"]),
                    result[1]["mods"],
                    result[1]["plate"],
                    0
                })
            if SellerData ~= nil then
                SellerData.Functions.AddMoney('bank', NewPrice)
            else
                local BuyerData = MySQL.Sync.fetchAll('SELECT * FROM players WHERE citizenid = ?',{SellerCitizenId})
                if BuyerData[1] ~= nil then
                    local BuyerMoney = json.decode(BuyerData[1].money)
                    BuyerMoney.bank = BuyerMoney.bank + NewPrice
                    MySQL.Async.execute('UPDATE players SET money = ? WHERE citizenid = ?', {json.encode(BuyerMoney), SellerCitizenId})
                end
            end
            TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "bought", "green", "**" .. GetPlayerName(src) .. "** has bought for " .. result[1].price .. " (" .. result[1].plate ..") from **" .. SellerCitizenId .. "**")
            TriggerClientEvent("qb-occasions:client:BuyFinished", src, result[1])
            TriggerClientEvent('qb-occasion:client:refreshVehicles', -1)
            MySQL.Async.execute('DELETE FROM occasion_vehicles WHERE plate = ? AND occasionid = ?',{result[1].plate, result[1].occasionid})
            TriggerEvent('qb-phone:server:sendNewMailToOffline', SellerCitizenId, {
                sender = Lang:t('mail.sender'),
                subject = Lang:t('mail.subject'),
                message = Lang:t('mail.message', { value = NewPrice, value2 = QBCore.Shared.Vehicles[result[1].model].name})
            })
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_enough_money'), 'error', 3500)
        end
    end
end)
