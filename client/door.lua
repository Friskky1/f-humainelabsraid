local QBCore = exports['qb-core']:GetCoreObject()

local SewerDoorOpen = false
local HackItem = Config.HackItem
local doorHacked = false

CreateThread(function()
    local SewerDoorObject = Config.SewerDoor.Object
    while true do
        Wait(1000)

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local HumaineDoorDist = #(pos - Config.SewerDoor.coords)
        if HumaineDoorDist < 50 then
            if SewerDoorObject == Config.SewerDoor.Object then
                SewerDoorObject = GetClosestObjectOfType(Config.SewerDoor.coords.x, Config.SewerDoor.coords.y, Config.SewerDoor.coords.z, 5.0, Config.SewerDoor.Object, false, false, false)
            end
            if SewerDoorObject ~= 0 then
                if SewerDoorOpen then
                    FreezeEntityPosition(SewerDoorObject, false)
                else
                    SetEntityHeading(SewerDoorObject, Config.SewerDoor.Closed)
                    FreezeEntityPosition(SewerDoorObject, true)
                end
            end
        else
            SewerDoorObject = Config.SewerDoor.Object
        end
    end
end)

RegisterNetEvent("f-humainelabsraid:client:SewerDoorHack", function()
    local hasItem = QBCore.Functions.HasItem(HackItem)

    if hasItem then
        if not doorHacked then
            QBCore.Functions.Progressbar('HackDoorProgressBar', 'Starting Hack', 3000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
                }, {
                    animDict = "anim@gangops@facility@servers@",
                    anim = "hotwire",
                    flags = 16,
                }, {}, {}, function() -- Success
                    exports['ps-ui']:Scrambler(function(success)
                        if success then
                            QBCore.Functions.Notify("You passed the hack the door will now open soon", "success", 5000)
                            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                            TriggerServerEvent("f-humainelabsraid:server:removeHackItem")
                            Wait(5000)
                            SewerDoorOpen = true
                            doorHacked = true
                            TriggerServerEvent("f-humainelabsraid:server:HeistStarted")
                            TriggerEvent("f-humainelabsraid:client:alertcops")
                        else
                            QBCore.Functions.Notify("You failed the hack", "error", 5000)
                            TriggerServerEvent("f-humainelabsraid:server:removeHackItem")
                        end
                    end, Config.SewerDoorHack.Hack, Config.SewerDoorHack.Time, 0)
                end, function() -- Cancel

            end)
        else
            QBCore.Functions.Notify("The door has already been Hacked", "error", 5000)
        end
    else
        QBCore.Functions.Notify("You dont have the requied tools to hack the door", "error", 5000)
    end
end)

RegisterNetEvent("f-humainelabsraid:client:ClearTimeoutDoors", function()
    SewerDoorOpen = false
    doorHacked = false
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("SewerDoorBreach", vector3(3525.28, 3702.78, 20.99), 1.0, 1.5, {
        name = "SewerDoorBreach",
        heading = 355.0,
        debugPoly = false,
        minZ = 20.0,
        maxZ = 22.5,
    }, {
        options = {
            {
                type = "client",
                event = "f-humainelabsraid:client:SewerDoorHack",
                icon = "fas fa-user-secret",
                label = "Hack",
            },
        },
        distance = 2.5
    })
end)