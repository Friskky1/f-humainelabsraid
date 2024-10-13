local QBCore = exports['qb-core']:GetCoreObject()

local ped = nil

CreateThread(function()
    local cryptoguy = Config.ElevatorNote.pedmodel
    RequestModel(cryptoguy)
    while not HasModelLoaded(cryptoguy) do 
        Wait(10) 
    end
    ped = CreatePed(0, cryptoguy, Config.ElevatorNote.pedlocation.xyzw, false, false)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_MOBILE', -1, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                type = "server",
                event = "f-humainelabsraid:server:BuyElevatorPasswordNote",
                icon = 'fas fa-capsules',
                label = 'Buy Elevator Note in Crypto $'..Config.ElevatorNote.price,
            }
        },
        distance = 2.0
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    DeleteEntity(ped)
end)