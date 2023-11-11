local QBCore = exports['qb-core']:GetCoreObject()

local HeistStarted = false
local turnedInDocs = false
local raidcooldown = Config.RaidCoolDown * 60

local function cooldown()
    while true do 
        if raidcooldown <= 0 then
            raidcooldown = Config.RaidCoolDown * 60
                TriggerClientEvent("f-humainelabsraid:client:ClearTimeoutDoors", -1)
                TriggerClientEvent("f-humainelabsraid:client:RaidSafeCooldown", -1)
                break
            else
                raidcooldown = raidcooldown - 1
            Wait(1000)
        end
        Wait(1)
    end
end

RegisterNetEvent("f-humainelabsraid:server:HeistStarted", function()
    HeistStarted = true
    TriggerClientEvent("f-humainelabsraid:client:SpawnGuards", -1)
    TriggerClientEvent("f-humainelabsraid:client:CanRobSafe", -1)
    cooldown()
end)

RegisterNetEvent('f-humainelabsraid:server:removeHackItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem(Config.HackItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.HackItem], "remove")
end)

RegisterNetEvent('f-humainelabsraid:server:removeDocumentItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem("special_documents", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["special_documents"], "remove")
end)

RegisterNetEvent("f-humainelabsraid:server:SafeReward", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local rareitem = math.random(100)

    if Player then
        if Player.Functions.AddItem("special_documents", 1, false) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["special_documents"], "add", 1)
            TriggerClientEvent('QBCore:Notify', src, "You got special documents?", "primary", 5000)
            TriggerClientEvent("f-humainelabsraid:client:DeliverDocs", -1)
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
        else
            TriggerClientEvent('QBCore:Notify', src, "You already handed in the Special Documents", "error", 5000)
        end
    end
end)