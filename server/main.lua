local QBCore = exports['qb-core']:GetCoreObject()

local HeistStarted = false
local banktruckstarted = false
local turnedInDocs = false
local raidcooldown = Config.RaidCoolDown * 60
local banktruckCooldownTime = Config.BankTruck.cooldown * 60
local ElevatorPassword = nil

local function doorcooldown()
    while true do 
        if raidcooldown <= 0 then
            raidcooldown = Config.RaidCoolDown * 60
                TriggerClientEvent("f-humainelabsraid:client:ClearTimeoutDoors", -1)
                TriggerClientEvent("f-humainelabsraid:client:RaidSafeCooldown", -1)
                HeistStarted = false
                turnedInDocs = false
                break
            else
                raidcooldown = raidcooldown - 1
            Wait(1000)
        end
        Wait(1)
    end
end

local function banktruckcooldown()
    while true do 
        if banktruckCooldownTime <= 0 then
            banktruckCooldownTime = Config.BankTruckCoolDown.cooldown * 60
                banktruckstarted = false
                break
            else
                banktruckCooldownTime = banktruckCooldownTime - 1
            Wait(1000)
        end
        Wait(1)
    end
end

local function generateElevatorPassword()
    if Config.ElevatorPassword.UseRandomNumber then
        return math.random(111111, 999999)
    else
        return Config.ElevatorPassword.PredefinedNumber
    end
end

QBCore.Functions.CreateCallback('getElevatorPassword', function(source, cb)
    cb(ElevatorPassword)
end)

RegisterNetEvent("f-humainelabsraid:server:BankTruckStarted", function()
    local src = source
    if banktruckstarted == true then
        TriggerClientEvent('QBCore:Notify', src, "There is a cooldown to get another bank truck", "error", 5000)
    else
        TriggerClientEvent("f-humainelabsraid:client:spawnbanktruck", src)
        banktruckstarted = true
        banktruckcooldown()
    end
end)

RegisterNetEvent("f-humainelabsraid:server:HeistStarted", function()
    HeistStarted = true
    TriggerClientEvent("f-humainelabsraid:client:SpawnGuards", -1)
    TriggerClientEvent("f-humainelabsraid:client:CanRobSafe", -1)
    doorcooldown()
end)

RegisterNetEvent('f-humainelabsraid:server:removeHackItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(Config.HackItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.HackItem], "remove")
end)

RegisterNetEvent('f-humainelabsraid:server:removeSafeHackItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(Config.SafeHackItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.SafeHackItem], "remove")
end)

RegisterNetEvent('f-humainelabsraid:server:removeDocumentItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem("special_documents", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["special_documents"], "remove")
end)

RegisterNetEvent("f-humainelabsraid:server:BuyElevatorPasswordNote", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.money.crypto >= Config.ElevatorNote.price then
        Player.Functions.RemoveMoney("crypto", Config.ElevatorNote.price, "")
        local info = {label = 'Elevator Password: ' .. ElevatorPassword}
        if Player.Functions.AddItem('stickynote', 1, false, info, 'reason') then
            TriggerClientEvent('qb-inventory:client:ItemBox', src, "stickynote", 'add')
        end
        TriggerClientEvent('QBCore:Notify', src, "This is only valid till next tsunami.", "success", 5000)
    else
        TriggerClientEvent('QBCore:Notify', src, "You dont have enough money in your crypto wallet.", "error", 5000)
    end
end)

RegisterNetEvent("f-humainelabsraid:server:SafeReward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local rareitem = math.random(100)

    if Player then
        if Player.Functions.AddItem("special_documents", 1, false) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["special_documents"], "add", 1)
            TriggerClientEvent('QBCore:Notify', src, "You got special documents?", "primary", 5000)
            TriggerClientEvent("f-humainelabsraid:client:DeliverDocs", src)
        end
        if Config.IfWantRareItem then
            if rareitem <= Config.RareItemChance then
                Player.Functions.AddItem(Config.RareItem, Config.RareItemAmmount, false)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem], "add", Config.RareItemAmmount)
                TriggerClientEvent('QBCore:Notify', src, "You also got a Random item?", "primary", 5000)
            end
        end
    end
end)

RegisterNetEvent("f-humainelabsraid:server:DocumentsReward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local info = {worth = math.random(Config.SafeRewardAmount[1], Config.SafeRewardAmount[2])}
    local cash = math.random(Config.SafeRewardAmount[1], Config.SafeRewardAmount[2])
    local markedbillbagrewardamount = math.random(Config.AmountOfMarkedBillsToGet[1], Config.AmountOfMarkedBillsToGet[2])

    if Player then
        if not turnedInDocs then
            if Config.UseMarkedBills then
                if Player.Functions.AddItem('markedbills', markedbillbagrewardamount, false, info) then
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add", markedbillbagrewardamount)
                end
            else
                if Player.Functions.AddMoney("cash", cash * markedbillbagrewardamount, "Safe Reward Money") then
                    TriggerClientEvent('QBCore:Notify', src, "You got $"..cash * markedbillbagrewardamount.."", "success", 5000)
                end
            end
            turnedInDocs = true
            TriggerEvent("f-humainelabsraid:server:raidend")
        else
            TriggerClientEvent('QBCore:Notify', src, "You already handed in the Special Documents", "error", 5000)
        end
    end
end)

RegisterNetEvent("f-humainelabsraid:server:returnbanktruck", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.AddItem(Config.HackItem, 1, false) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.HackItem], "add", 1)
        TriggerClientEvent('QBCore:Notify', src, "You turned in the truck and they found a "..Config.HackItem.. ".", "primary", 5000)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    ElevatorPassword = generateElevatorPassword()
    print("[SERVER] ELEVATOR PASSWORD: ^2" ..ElevatorPassword.."^7")
end)