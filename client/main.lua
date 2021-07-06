function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(1)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local occasionVehicles = {}
local inRange
local vehiclesSpawned = false
local isConfirming = false

Citizen.CreateThread(function()
    while true do
        inRange = false
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local price = nil
        if QBCore ~= nil then
            for _,slot in pairs(Config.OccasionSlots) do
                local dist = #(pos - vector3(slot["x"], slot["y"], slot["z"]))

                if dist <= 40 then
                    inRange = true
                    if not vehiclesSpawned then
                        vehiclesSpawned = true

                        QBCore.Functions.TriggerCallback('qb-occasions:server:getVehicles', function(vehicles)
                            occasionVehicles = vehicles
                            despawnOccasionsVehicles()
                            spawnOccasionsVehicles(vehicles)
                        end)
                    end
                end
            end

            local sellBackDist = #(pos - Config.SellVehicleBack)
            
            if sellBackDist <= 13.0 and IsPedInAnyVehicle(ped) then 
                DrawMarker(2, Config.SellVehicleBack.x, Config.SellVehicleBack.y, Config.SellVehicleBack.z + 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.6, 255, 0, 0, 155, false, false, false, true, false, false, false)
                if sellBackDist <= 3.5 and IsPedInAnyVehicle(ped) then
                    local price 
                    local sellVehData = {}
                    sellVehData.plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(ped))
                    sellVehData.model = GetEntityModel(GetVehiclePedIsIn(ped))
                        for k, v in pairs(QBCore.Shared.Vehicles) do
                            if tonumber(v["hash"]) == sellVehData.model then
                                sellVehData.price = tonumber(v["price"])
                            end
                        end
                    DrawText3Ds(Config.SellVehicleBack.x, Config.SellVehicleBack.y, Config.SellVehicleBack.z, '[~g~E~w~] - Sell Vehicle To Dealer For ~g~$'..math.floor(sellVehData.price / 2))
                    if IsControlJustPressed(0, 38) then
                        QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned)
                            if owned then
                                TriggerServerEvent('qb-occasions:server:sellVehicleBack', sellVehData)
                                QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(ped))
                            else
                                QBCore.Functions.Notify('This is not your vehicle..', 'error', 3500)
                            end
                        end, sellVehData.plate)
                    end
                end
            end
            
            if inRange then
                for i = 1, #Config.OccasionSlots, 1 do
                    local vehPos = GetEntityCoords(Config.OccasionSlots[i]["occasionid"])
                    local dstCheck = #(pos - vehPos)

                    if dstCheck <= 2 then
                        if not IsPedInAnyVehicle(ped) then
                            if not isConfirming then
                                DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.45, '[~g~E~w~] - View Vehicle Contract')
                                DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.25, QBCore.Shared.Vehicles[Config.OccasionSlots[i]["model"]]["name"]..', Price: ~g~$'..Config.OccasionSlots[i]["price"])
                                if Config.OccasionSlots[i]["owner"] == QBCore.Functions.GetPlayerData().citizenid then
                                    DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.05, '[~r~G~w~] - Cancel Vehicle Sale')
                                    if IsControlJustPressed(0, 47) then
                                        isConfirming = true
                                    end
                                end
                                if IsControlJustPressed(0, 38) then
                                    currentVehicle = i
                                    
                                    QBCore.Functions.TriggerCallback('qb-occasions:server:getSellerInformation', function(info)
                                        if info ~= nil then 
                                            info.charinfo = json.decode(info.charinfo)
                                        else
                                            info = {}
                                            info.charinfo = {
                                                firstname = "not",
                                                lastname = "known",
                                                account = "Account not known..",
                                                phone = "telephone number not known.."
                                            }
                                        end
                                        
                                        openBuyContract(info, Config.OccasionSlots[currentVehicle])
                                    end, Config.OccasionSlots[currentVehicle]["owner"])
                                end
                            else
                                DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.45, 'Are you sure you no longer want to sell your vehicle?')
                                DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.25, '[~g~7~w~] - Yes | [~r~8~w~] - No')
                                if IsDisabledControlJustPressed(0, 161) then
                                    isConfirming = false
                                    currentVehicle = i
                                    TriggerServerEvent("qb-occasions:server:ReturnVehicle", Config.OccasionSlots[i])
                                end
                                if IsDisabledControlJustPressed(0, 162) then
                                    isConfirming = false
                                end
                            end
                        end
                    end
                end

                local sellDist = #(pos - Config.SellVehicle)

                if sellDist <= 13.0 and IsPedInAnyVehicle(ped) then 
                    DrawMarker(2, Config.SellVehicle.x, Config.SellVehicle.y, Config.SellVehicle.z + 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.6, 255, 0, 0, 155, false, false, false, true, false, false, false)
                    if sellDist <= 3.5 and IsPedInAnyVehicle(ped) then
                        DrawText3Ds(Config.SellVehicle.x, Config.SellVehicle.y, Config.SellVehicle.z, '[~g~E~w~] - Place Vehicle For Sale By Owner')
                        if IsControlJustPressed(0, 38) then
                            local VehiclePlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(ped))
                            QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned)
                                if owned then
                                    openSellContract(true)
                                else
                                    QBCore.Functions.Notify('This is not your vehicle..', 'error', 3500)
                                end
                            end, VehiclePlate)
                        end
                    end
                end
            end

            if not inRange then
                if vehiclesSpawned then
                    vehiclesSpawned = false
                    despawnOccasionsVehicles()
                end
                Citizen.Wait(1000)
            end
        end

        Citizen.Wait(3)
    end
end)

function spawnOccasionsVehicles(vehicles)
    local oSlot = Config.OccasionSlots

    if vehicles ~= nil then
        for i = 1, #vehicles, 1 do
            local model = GetHashKey(vehicles[i].model)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end
            
            oSlot[i]["occasionid"] = CreateVehicle(model, oSlot[i]["x"], oSlot[i]["y"], oSlot[i]["z"], false, false)

            oSlot[i]["price"] = vehicles[i].price
            oSlot[i]["owner"] = vehicles[i].seller
            oSlot[i]["model"] = vehicles[i].model
            oSlot[i]["plate"] = vehicles[i].plate
            oSlot[i]["oid"]   = vehicles[i].occasionid
            oSlot[i]["desc"]  = vehicles[i].description
            oSlot[i]["mods"]  = vehicles[i].mods

            QBCore.Functions.SetVehicleProperties(oSlot[i]["occasionid"], json.decode(oSlot[i]["mods"]))

            SetModelAsNoLongerNeeded(model)
            SetVehicleOnGroundProperly(oSlot[i]["occasionid"])
            SetEntityInvincible(oSlot[i]["occasionid"],true)
            SetEntityHeading(oSlot[i]["occasionid"], oSlot[i]["h"])
            SetVehicleDoorsLocked(oSlot[i]["occasionid"], 3)

            SetVehicleNumberPlateText(oSlot[i]["occasionid"], vehicles[i].occasionid)
            FreezeEntityPosition(oSlot[i]["occasionid"],true)
        end
    end
end

function despawnOccasionsVehicles()
    local oSlot = Config.OccasionSlots
    for i = 1, #Config.OccasionSlots, 1 do
        local oldVehicle = GetClosestVehicle(Config.OccasionSlots[i]["x"], Config.OccasionSlots[i]["y"], Config.OccasionSlots[i]["z"], 1.3, 0, 70)
        if oldVehicle ~= 0 then
            QBCore.Functions.DeleteVehicle(oldVehicle)
        end
    end
end

function openSellContract(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "sellVehicle",
        pData = QBCore.Functions.GetPlayerData(),
        plate = GetVehicleNumberPlateText(GetVehiclePedIsUsing(PlayerPedId()))
    })
end

function openBuyContract(sellerData, vehicleData)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "buyVehicle",
        sellerData = sellerData,
        vehicleData = vehicleData
    })
end

RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('error', function(data)
    QBCore.Functions.Notify(data.message, 'error')
end)

RegisterNUICallback('buyVehicle', function()
    local vehData = Config.OccasionSlots[currentVehicle]
    TriggerServerEvent('qb-occasions:server:buyVehicle', vehData)
end)

DoScreenFadeIn(250)

RegisterNetEvent('qb-occasions:client:BuyFinished')
AddEventHandler('qb-occasions:client:BuyFinished', function(vehdata)
    local vehmods = json.decode(vehdata.mods)

    DoScreenFadeOut(250)
    Citizen.Wait(500)
    QBCore.Functions.SpawnVehicle(vehdata.model, function(veh)
        SetVehicleNumberPlateText(veh, vehdata.plate)
        SetEntityHeading(veh, Config.BuyVehicle.h)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetVehicleFuelLevel(veh, 100)
        QBCore.Functions.Notify("Vehicle Bought", "success", 2500)
        TriggerEvent("vehiclekeys:client:SetOwner", vehdata.plate)
        SetVehicleEngineOn(veh, true, true)
        Citizen.Wait(500)
        QBCore.Functions.SetVehicleProperties(veh, vehmods)
    end, Config.BuyVehicle, true)
    Citizen.Wait(500)
    DoScreenFadeIn(250)
    currentVehicle = nil
end)

RegisterNetEvent('qb-occasions:client:ReturnOwnedVehicle')
AddEventHandler('qb-occasions:client:ReturnOwnedVehicle', function(vehdata)
    local vehmods = json.decode(vehdata.mods)
    DoScreenFadeOut(250)
    Citizen.Wait(500)
    QBCore.Functions.SpawnVehicle(vehdata.model, function(veh)
        SetVehicleNumberPlateText(veh, vehdata.plate)
        SetEntityHeading(veh, Config.BuyVehicle.h)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetVehicleFuelLevel(veh, 100)
        QBCore.Functions.Notify("You vehicle is returned")
        TriggerEvent("vehiclekeys:client:SetOwner", vehdata.plate)
        SetVehicleEngineOn(veh, true, true)
        Citizen.Wait(500)
        QBCore.Functions.SetVehicleProperties(veh, vehmods)
    end, Config.BuyVehicle, true)
    Citizen.Wait(500)
    DoScreenFadeIn(250)
    currentVehicle = nil
end)

RegisterNUICallback('sellVehicle', function(data)
    local vehicleData = {}
    local PlayerData = QBCore.Functions.GetPlayerData()
    vehicleData.ent = GetVehiclePedIsUsing(PlayerPedId())
    vehicleData.model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicleData.ent)):lower()
    vehicleData.plate = GetVehicleNumberPlateText(GetVehiclePedIsUsing(PlayerPedId()))
    vehicleData.mods = QBCore.Functions.GetVehicleProperties(vehicleData.ent)
    vehicleData.desc = data.desc

    TriggerServerEvent('qb-occasions:server:sellVehicle', data.price, vehicleData)
    sellVehicleWait(data.price)
end)

function sellVehicleWait(price)
    DoScreenFadeOut(250)
    Citizen.Wait(250)
    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
    Citizen.Wait(1500)
    DoScreenFadeIn(250)
    QBCore.Functions.Notify('Your car has been put up for sale! Price - $'..price, 'success')
    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
end

RegisterNetEvent('qb-occasion:client:refreshVehicles')
AddEventHandler('qb-occasion:client:refreshVehicles', function()
    if inRange then
        QBCore.Functions.TriggerCallback('qb-occasions:server:getVehicles', function(vehicles)
            occasionVehicles = vehicles
            despawnOccasionsVehicles()
            spawnOccasionsVehicles(vehicles)
        end)
    end
end)

Citizen.CreateThread(function()
    OccasionBlip = AddBlipForCoord(Config.SellVehicle["x"], Config.SellVehicle["y"], Config.SellVehicle["z"])

    SetBlipSprite (OccasionBlip, 326)
    SetBlipDisplay(OccasionBlip, 4)
    SetBlipScale  (OccasionBlip, 0.75)
    SetBlipAsShortRange(OccasionBlip, true)
    SetBlipColour(OccasionBlip, 3)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Used Vehicle Lot")
    EndTextCommandSetBlipName(OccasionBlip)
end)