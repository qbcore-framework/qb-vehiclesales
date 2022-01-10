local QBCore = exports['qb-core']:GetCoreObject()
local occasionVehicles = {}
local inRange
local vehiclesSpawned = false
local isConfirming = false

-- Functions

local function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
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

local function spawnOccasionsVehicles(vehicles)
    local oSlot = Config.OccasionSlots

    if vehicles ~= nil then
        for i = 1, #vehicles, 1 do
            local model = GetHashKey(vehicles[i].model)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end

            oSlot[i]["occasionid"] = CreateVehicle(model, oSlot[i].loc.x, oSlot[i].loc.y, oSlot[i].loc.z, false, false)

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
            SetEntityHeading(oSlot[i]["occasionid"], oSlot[i].h)
            SetVehicleDoorsLocked(oSlot[i]["occasionid"], 3)

            SetVehicleNumberPlateText(oSlot[i]["occasionid"], vehicles[i].occasionid)
            FreezeEntityPosition(oSlot[i]["occasionid"],true)
        end
    end
end

local function despawnOccasionsVehicles()
    local oSlot = Config.OccasionSlots
    for i = 1, #Config.OccasionSlots, 1 do
        local loc = Config.OccasionSlots[i].loc
        local oldVehicle = GetClosestVehicle(loc.x, loc.y, loc.z, 1.3, 0, 70)
        if oldVehicle ~= 0 then
            QBCore.Functions.DeleteVehicle(oldVehicle)
        end
    end
end

local function openSellContract(bool)
    local pData = QBCore.Functions.GetPlayerData()

    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "sellVehicle",
        bizName = Config.BusinessName,
        sellerData = {
            firstname = pData.charinfo.firstname,
            lastname = pData.charinfo.lastname,
            account = pData.charinfo.account,
            phone = pData.charinfo.phone
        },
        plate = QBCore.Functions.GetPlate(GetVehiclePedIsUsing(PlayerPedId()))
    })
end

local function openBuyContract(sellerData, vehicleData)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "buyVehicle",
        bizName = Config.BusinessName,
        sellerData = {
            firstname = sellerData.charinfo.firstname,
            lastname = sellerData.charinfo.lastname,
            account = sellerData.charinfo.account,
            phone = sellerData.charinfo.phone
        },
        vehicleData = {
            desc = vehicleData.desc,
            price = vehicleData.price
        },
        plate = vehicleData.plate
    })
end

local function SellToDealer(sellVehData, vehicleHash)
    CreateThread(function()
        local keepGoing = true
        while keepGoing do
            DisableControlAction(0, 38, true)

            local coords = GetEntityCoords(vehicleHash)
            DrawText3Ds(coords.x, coords.y, coords.z + 1.6, Lang:t('info.confirm_cancel'))

            if IsDisabledControlJustPressed(0, 246) then
                TriggerServerEvent('qb-occasions:server:sellVehicleBack', sellVehData)
                QBCore.Functions.DeleteVehicle(vehicleHash)

                keepGoing = false
            end

            if IsDisabledControlJustPressed(0, 306) then
                keepGoing = false
            end

            if #(Config.SellVehicleBack - coords) > 3 then
                keepGoing = false
            end

            Wait(0)
        end

    end)
end

local function sellVehicleWait(price)
    DoScreenFadeOut(250)
    Wait(250)
    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
    Wait(1500)
    DoScreenFadeIn(250)
    QBCore.Functions.Notify(Lang:t('success.car_up_for_sale', { value = price }), 'success')
    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
end

local function SellData(data,model)
    QBCore.Functions.TriggerCallback("qb-vehiclesales:server:CheckModelName",function(DataReturning)
        local vehicleData = {}
        vehicleData.ent = GetVehiclePedIsUsing(PlayerPedId())
        vehicleData.model = DataReturning
        vehicleData.plate = model
        vehicleData.mods = QBCore.Functions.GetVehicleProperties(vehicleData.ent)
        vehicleData.desc = data.desc
        TriggerServerEvent('qb-occasions:server:sellVehicle', data.price, vehicleData)
        sellVehicleWait(data.price)
    end, model)
end

-- NUI Callbacks

RegisterNUICallback('sellVehicle', function(data, cb)
    local plate = QBCore.Functions.GetPlate(GetVehiclePedIsUsing(PlayerPedId())) --Getting the plate and sending to the function
    SellData(data,plate)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('buyVehicle', function(data, cb)
    local vehData = Config.OccasionSlots[currentVehicle]
    TriggerServerEvent('qb-occasions:server:buyVehicle', vehData)
    cb('ok')
end)

-- Events

RegisterNetEvent('qb-occasions:client:BuyFinished', function(vehdata)
    local vehmods = json.decode(vehdata.mods)

    DoScreenFadeOut(250)
    Wait(500)
    QBCore.Functions.SpawnVehicle(vehdata.model, function(veh)
        SetVehicleNumberPlateText(veh, vehdata.plate)
        SetEntityHeading(veh, Config.BuyVehicle.w)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetVehicleFuelLevel(veh, 100)
        QBCore.Functions.Notify(Lang:t('success.vehicle_bought'), "success", 2500)
        TriggerEvent("vehiclekeys:client:SetOwner", vehdata.plate)
        SetVehicleEngineOn(veh, true, true)
        Wait(500)
        QBCore.Functions.SetVehicleProperties(veh, vehmods)
    end, Config.BuyVehicle, true)
    Wait(500)
    DoScreenFadeIn(250)
    currentVehicle = nil
end)

RegisterNetEvent('qb-occasions:client:ReturnOwnedVehicle', function(vehdata)
    local vehmods = json.decode(vehdata.mods)
    DoScreenFadeOut(250)
    Wait(500)
    QBCore.Functions.SpawnVehicle(vehdata.model, function(veh)
        SetVehicleNumberPlateText(veh, vehdata.plate)
        SetEntityHeading(veh, Config.BuyVehicle.w)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetVehicleFuelLevel(veh, 100)
        QBCore.Functions.Notify(Lang:t('info.vehicle_returned'))
        TriggerEvent("vehiclekeys:client:SetOwner", vehdata.plate)
        SetVehicleEngineOn(veh, true, true)
        Wait(500)
        QBCore.Functions.SetVehicleProperties(veh, vehmods)
    end, Config.BuyVehicle, true)
    Wait(500)
    DoScreenFadeIn(250)
    currentVehicle = nil
end)

RegisterNetEvent('qb-occasion:client:refreshVehicles', function()
    if inRange then
        QBCore.Functions.TriggerCallback('qb-occasions:server:getVehicles', function(vehicles)
            occasionVehicles = vehicles
            despawnOccasionsVehicles()
            spawnOccasionsVehicles(vehicles)
        end)
    end
end)

-- Threads

CreateThread(function()
    local OccasionBlip = AddBlipForCoord(Config.SellVehicle.x, Config.SellVehicle.y, Config.SellVehicle.z)
    SetBlipSprite (OccasionBlip, 326)
    SetBlipDisplay(OccasionBlip, 4)
    SetBlipScale  (OccasionBlip, 0.75)
    SetBlipAsShortRange(OccasionBlip, true)
    SetBlipColour(OccasionBlip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Lang:t('info.used_vehicle_lot'))
    EndTextCommandSetBlipName(OccasionBlip)
end)

CreateThread(function()
    while true do
        inRange = false
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        if QBCore ~= nil then
            for _,slot in pairs(Config.OccasionSlots) do
                local dist = #(pos - slot.loc)

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
                    sellVehData.plate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(ped))
                    sellVehData.model = GetEntityModel(GetVehiclePedIsIn(ped))
                        for k, v in pairs(QBCore.Shared.Vehicles) do
                            if tonumber(v["hash"]) == sellVehData.model then
                                sellVehData.price = tonumber(v["price"])
                            end
                        end
                    DrawText3Ds(Config.SellVehicleBack.x, Config.SellVehicleBack.y, Config.SellVehicleBack.z, Lang:t('info.sell_vehicle_to_dealer', { value = math.floor(sellVehData.price / 2) }))
                    if IsControlJustPressed(0, 38) then
                        QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned, balance)
                            if owned then
                                if balance < 1 then
                                    SellToDealer(sellVehData, GetVehiclePedIsIn(ped))
                                else
                                    QBCore.Functions.Notify(Lang:t('error.finish_payments'), 'error', 3500)
                                end
                            else
                                QBCore.Functions.Notify(Lang:t('error.not_your_vehicle'), 'error', 3500)
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
                                DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.45, Lang:t('info.view_contract'))
                                DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.25, Lang:t('info.model_price', { value = QBCore.Shared.Vehicles[Config.OccasionSlots[i]["model"]]["name"], value2 = Config.OccasionSlots[i]["price"] }))
                                if Config.OccasionSlots[i]["owner"] == QBCore.Functions.GetPlayerData().citizenid then
                                    DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.05, Lang:t('info.cancel_sale'))
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
                                                firstname = Lang:t('charinfo.firstname'),
                                                lastname = Lang:t('charinfo.lastname'),
                                                account = Lang:t('charinfo.account'),
                                                phone = Lang:t('charinfo.phone')
                                            }
                                        end

                                        openBuyContract(info, Config.OccasionSlots[currentVehicle])
                                    end, Config.OccasionSlots[currentVehicle]["owner"])
                                end
                            else
                                DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.45, Lang:t('info.are_you_sure'))
                                DrawText3Ds(vehPos.x, vehPos.y, vehPos.z + 1.25, Lang:t('info.yes_no'))
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
                        DrawText3Ds(Config.SellVehicle.x, Config.SellVehicle.y, Config.SellVehicle.z, Lang:t('info.place_vehicle_for_sale'))
                        if IsControlJustPressed(0, 38) then
                            local VehiclePlate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(ped))
                            QBCore.Functions.TriggerCallback('qb-garage:server:checkVehicleOwner', function(owned, balance)
                                if owned then
                                    if balance < 1 then 
                                        QBCore.Functions.TriggerCallback('qb-occasions:server:getVehicles', function(vehicles)
                                            if vehicles == nil or #vehicles < #Config.OccasionSlots then
                                                openSellContract(true)
                                            else
                                                QBCore.Functions.Notify(Lang:t('error.no_space_on_lot'), 'error', 3500)
                                            end
                                    end)
                                    else
                                        QBCore.Functions.Notify(Lang:t('error.finish_payments'), 'error', 3500)
                                    end
                                else
                                    QBCore.Functions.Notify(Lang:t('error.not_your_vehicle'), 'error', 3500)
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
                Wait(1000)
            end
        end
        Wait(3)
    end
end)
