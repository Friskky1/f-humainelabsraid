local QBCore = exports['qb-core']:GetCoreObject()

local SewerDoorOpen = false
local elevatordoorsopen = false
local HackItem = Config.HackItem
local doorHacked = false
local keypad = {}
local elevatordoors = {1878909644, 1709395619}

CreateThread(function()
    while true do
        Wait(1000)
        -- First Door
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local SewerDoorObject = Config.SewerDoor.Object
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

        -- Elevator Doors
        for _, ElevatorDoorsHash in ipairs(elevatordoors) do
            local ElevatorDoorDist = #(pos - vector3(3540.31, 3673.48, 20.99))
            local door = GetClosestObjectOfType(GetEntityCoords(ped), 5.0, ElevatorDoorsHash, false, false, false)
            if DoesEntityExist(door) then
                if ElevatorDoorDist < 50 then
                    if elevatordoorsopen == true then
                        FreezeEntityPosition(door, false)
                    else
                        FreezeEntityPosition(door, true) -- Prevent the door from moving
                    end
                end
            end
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
                        TriggerServerEvent("f-humainelabsraid:server:removeHackItem")
                        if success then
                            QBCore.Functions.Notify("You passed the hack the door will now open soon", "success", 5000)
                            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                            TriggerServerEvent("f-humainelabsraid:server:removeHackItem")
                            Wait(5000)
                            AddExplosion(Config.SewerDoor.coords.xyz, 2, 500, true, false, 5)
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

RegisterNetEvent("f-humainelabsraid:client:ElevatorKeypadHack", function()
    QBCore.Functions.TriggerCallback('getElevatorPassword', function(result)
        local input = exports['ps-ui']:Input({
            {
                id = '1',
                label = 'Enter a Number',
                type = "number",
                icon = "fas fa-hashtag"
            }
        })
        if input then
            local numberInput = tonumber(input[1].value)
            if numberInput == result then
                QBCore.Functions.Notify("Password Accepted", "success", 5000)
                elevatordoorsopen = true
            else
                QBCore.Functions.Notify("Wrong Password", "error", 5000)
            end
        else
            QBCore.Functions.Notify("No input received or input canceled", "error", 5000)
        end
    end, 'getElevatorPassword')
end)

RegisterNetEvent("f-humainelabsraid:client:ClearTimeoutDoors", function()
    SewerDoorOpen = false
    doorHacked = false
    elevatordoorsopen = false
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
    -- keypad
    local keypadmodel = "prop_ld_keypad_01b"
    RequestModel(keypadmodel) while not HasModelLoaded(keypadmodel) do Wait(10) end
    keypad = CreateObject(keypadmodel, 3537.48, 3673.45, 21.2, true, false, false)
    SetEntityHeading(keypad, 348.61)
    FreezeEntityPosition(keypad, true)
    exports['qb-target']:AddBoxZone("keypad", vector3(3537.48, 3673.45, 21.2), 0.3, 0.3, {
        name = "keypad",
        heading = 355.0,
        debugPoly = false,
        minZ = 21.2,
        maxZ = 21.5,
    }, {
        options = {
            {
                type = "client",
                event = "f-humainelabsraid:client:ElevatorKeypadHack",
                icon = "fas fa-user-secret",
                label = "Hack",
            },
        },
        distance = 2.5
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    DeleteEntity(keypad)
end)