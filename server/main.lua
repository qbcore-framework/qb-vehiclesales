QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

-- Code

QBCore.Functions.CreateCallback('qb-occasions:server:getVehicles', function(source, cb)
    QBCore.Functions.ExecuteSql(false, nil, 'SELECT * FROM `occasion_vehicles`', function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback("qb-occasions:server:getSellerInformation", function(source, cb, citizenid)
    local src = source

    exports['ghmattimysql']:execute('SELECT * FROM players WHERE citizenid = @citizenid', {['@citizenid'] = citizenid}, function(result)
        if result[1] ~= nil then
            cb(result[1])
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('qb-occasions:server:ReturnVehicle')
AddEventHandler('qb-occasions:server:ReturnVehicle', function(vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    QBCore.Functions.ExecuteSql(false, {['a'] = vehicleData['plate'], ['b'] = vehicleData["oid"]}, "SELECT * FROM `occasion_vehicles` WHERE `plate` = @a AND `occasionid` = @b", function(result)
        if result[1] ~= nil then 
            if result[1].seller == Player.PlayerData.citizenid then
                QBCore.Functions.ExecuteSql(false, {['a'] = Player.PlayerData.steam, ['b'] = Player.PlayerData.citizenid, ['c'] = vehicleData["model"], ['d'] = GetHashKey(vehicleData["model"]), ['e'] = vehicleData["mods"], ['f'] = vehicleData["plate"]}, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `hash`, `mods`, `plate`, `state`) VALUES (@a, @b, @c, @d, @e, @f, '0')")
                QBCore.Functions.ExecuteSql(false, nil, "DELETE FROM `occasion_vehicles` WHERE `occasionid` = '"..vehicleData["oid"].."' and `plate` = '"..vehicleData['plate'].."'")
                TriggerClientEvent("qb-occasions:client:ReturnOwnedVehicle", src, result[1])
                TriggerClientEvent('qb-occasion:client:refreshVehicles', -1)
            else
                TriggerClientEvent('QBCore:Notify', src, 'This is not your vehicle', 'error', 3500)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Vehicle does not exist', 'error', 3500)
        end
    end)
end)

RegisterServerEvent('qb-occasions:server:sellVehicle')
AddEventHandler('qb-occasions:server:sellVehicle', function(vehiclePrice, vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    QBCore.Functions.ExecuteSql(true, {['a'] = vehicleData.plate, ['b'] = vehicleData.model}, "DELETE FROM `player_vehicles` WHERE `plate` = @a AND `vehicle` = @b")
    QBCore.Functions.ExecuteSql(
        true, 
        {
            ['a'] = Player.PlayerData.citizenid,
            ['b'] = vehiclePrice,
            ['c'] = vehicleData.desc,
            ['d'] = vehicleData.plate,
            ['e'] = vehicleData.model,
            ['f'] = json.encode(vehicleData.mods),
            ['g'] = generateOID()
        }, 
        "INSERT INTO `occasion_vehicles` (`seller`, `price`, `description`, `plate`, `model`, `mods`, `occasionid`) VALUES (@a, @b, @c, @d, @e, @f, @g)")
    
    TriggerEvent("qb-log:server:sendLog", Player.PlayerData.citizenid, "vehiclesold", {model=vehicleData.model, vehiclePrice=vehiclePrice})
    TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "Vehicle for Sale", "red", "**"..GetPlayerName(src) .. "** has a " .. vehicleData.model .. " priced at "..vehiclePrice)

    TriggerClientEvent('qb-occasion:client:refreshVehicles', -1)
end)

RegisterServerEvent('qb-occasions:server:sellVehicleBack')
AddEventHandler('qb-occasions:server:sellVehicleBack', function(vData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local price = math.floor(vData.price / 2)
    local plate = vData.plate
   
    Player.Functions.AddMoney('bank', price)
    TriggerClientEvent('QBCore:Notify', src, 'You have sold your car for $'..price, 'success', 5500)
    QBCore.Functions.ExecuteSql(true, {['a'] = plate, ['b'] = cid}, "DELETE FROM `player_vehicles` WHERE `plate` = @a AND `citizenid` = @b")
end)

RegisterServerEvent('qb-occasions:server:buyVehicle')
AddEventHandler('qb-occasions:server:buyVehicle', function(vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    QBCore.Functions.ExecuteSql(false, {['a'] = vehicleData['plate'], ['b'] = vehicleData["oid"]}, "SELECT * FROM `occasion_vehicles` WHERE `plate` = @a AND `occasionid` = @b", function(result)
        if result[1] ~= nil and next(result[1]) ~= nil then
            if Player.PlayerData.money.bank >= result[1].price then
                local SellerCitizenId = result[1].seller
                local SellerData = QBCore.Functions.GetPlayerByCitizenId(SellerCitizenId)
                -- New price calculation minus tax
                local NewPrice = math.ceil((result[1].price / 100) * 77)

                Player.Functions.RemoveMoney('bank', result[1].price)

                -- Insert vehicle for buyer
                QBCore.Functions.ExecuteSql(false, {['a'] = Player.PlayerData.steam, ['b'] = Player.PlayerData.citizenid, ['c'] = result[1].model, ['d'] = GetHashKey(result[1].model), ['e'] = result[1].mods, ['f'] = result[1].plate}, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `hash`, `mods`, `plate`, `state`) VALUES (@a, @b, @c, @d, @e, @f, '0')")
                
                -- Handle money transfer
                if SellerData ~= nil then
                    -- Add money for online
                    SellerData.Functions.AddMoney('bank', NewPrice)
                else
                    -- Add money for offline
                    QBCore.Functions.ExecuteSql(true, {['a'] = SellerCitizenId}, "SELECT * FROM `players` WHERE `citizenid` = @a", function(BuyerData)
                        if BuyerData[1] ~= nil then
                            local BuyerMoney = json.decode(BuyerData[1].money)
                            BuyerMoney.bank = BuyerMoney.bank + NewPrice
                            QBCore.Functions.ExecuteSql(false, {['a'] = json.encode(BuyerMoney), ['b'] = SellerCitizenId}, "UPDATE `players` SET `money` = @a WHERE `citizenid` = @b")
                        end
                    end)
                end

                TriggerEvent("qb-log:server:sendLog", Player.PlayerData.citizenid, "vehiclebought", {model = result[1].model, from = SellerCitizenId, moneyType = "cash", vehiclePrice = result[1].price, plate = result[1].plate})
                TriggerEvent("qb-log:server:CreateLog", "vehicleshop", "bought", "green", "**"..GetPlayerName(src) .. "** has bought for "..result[1].price .. " (" .. result[1].plate .. ") from **"..SellerCitizenId.."**")
                TriggerClientEvent("qb-occasions:client:BuyFinished", src, result[1])
                TriggerClientEvent('qb-occasion:client:refreshVehicles', -1)
            
                -- Delete vehicle from Occasion
                QBCore.Functions.ExecuteSql(false, {['a'] = result[1].plate, ['b'] = result[1].occasionid}, "DELETE FROM `occasion_vehicles` WHERE `plate` = @a and `occasionid` = @b")

                -- Send selling mail to seller
                TriggerEvent('qb-phone:server:sendNewMailToOffline', SellerCitizenId, {
                    sender = "Mosleys Occasions",
                    subject = "You have sold a vehicle!",
                    message = "The "..QBCore.Shared.Vehicles[result[1].model].name.." has sold for $"..result[1].price.."!"
                })
            else
                TriggerClientEvent('QBCore:Notify', src, 'You dont have enough money', 'error', 3500)
            end
        end
    end)
end)

function generateOID()
    local num = math.random(1, 10)..math.random(111, 999)

    return "OC"..num
end

function round(number)
    return number - (number % 1)
end

function escapeSqli(str)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return str:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end