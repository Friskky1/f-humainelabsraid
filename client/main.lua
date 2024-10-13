local QBCore = exports['qb-core']:GetCoreObject()

local isHeistStarted = false
local SafeProp = {}
local isSafehacked = false

local function CanRobSafe()
    if isHeistStarted == true then 
        local SafeModel = "prop_ld_int_safe_01"
        RequestModel(SafeModel) while not HasModelLoaded(SafeModel) do Wait(10) end

        for k, v in pairs(Config.SafeLocations) do
            local Safe = CreateObject(SafeModel, Config.SafeLocations[k].coords.xy, Config.SafeLocations[k].coords.z - 1, true, false, false)
            SetEntityHeading(Safe, Config.SafeLocations[k].heading)
            FreezeEntityPosition(Safe, true)

            SafeProp[k] = {
                Obj = Safe
            }
        end

        exports['qb-target']:AddBoxZone("HumaineSafeHack", vector3(3560.48, 3667.7, 28.0), 0.9, 1.2, {
            name = "HumaineSafeHack",
            heading = 0.0,
            debugPoly = false,
            minZ = 27.0,
            maxZ = 28.5,
        }, {
            options = {
                {
                    type = "client",
                    event = "f-humainelabsraid:client:SafeHack",
                    icon = "fas fa-user-secret",
                    label = "Hack",
                },
            },
            distance = 2.5
        })
    end
end

local function DeleteSafe()
    for k,v in pairs(SafeProp) do
        NetworkRequestControlOfEntity(SafeProp[k].Obj)
        DeleteObject(SafeProp[k].Obj)
        SafeProp[k] = nil
    end
    isSafehacked = false
    exports['qb-target']:RemoveZone("HumaineSafeHack")
end

RegisterNetEvent("f-humainelabsraid:client:CanRobSafe", function()
    isHeistStarted = true
    CanRobSafe()
end)

RegisterNetEvent("f-humainelabsraid:client:SafeHack", function()
    local HasItem = QBCore.Functions.HasItem(Config.SafeHackItem)

    if not isSafehacked then
        if HasItem then
            QBCore.Functions.Progressbar('SafeHack', 'Hacking Into The Safe', 3000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
                }, {
                    animDict = "anim@gangops@facility@servers@",
                    anim = "hotwire",
                    flags = 16,
                }, {}, {}, function() -- Success
                    exports['ps-ui']:Thermite(function(success)
                        if success then
                            TriggerServerEvent("f-humainelabsraid:server:removeSafeHackItem")
                            QBCore.Functions.Notify("You succeded the hack!", "success", 5000)
                            Wait(500)
                            TriggerServerEvent("f-humainelabsraid:server:SafeReward")
                            isSafehacked = true
                            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                        else
                            TriggerServerEvent("f-humainelabsraid:server:removeSafeHackItem")
                            QBCore.Functions.Notify("You failed the hack", "error", 5000)
                        end
                    end, Config.SafeHack.Time, Config.SafeHack.Gridsize, Config.SafeHack.IncorrectBlocks)
                end, function() -- Cancel
                
            end)
        else
            QBCore.Functions.Notify("You do not have the safe hack item", "error", 5000)
        end
    else
        QBCore.Functions.Notify("The Safe has already been hacked", "error", 5000)
    end
end)

RegisterNetEvent("f-humainelabsraid:client:RaidSafeCooldown", function()
    isHeistStarted = false
    isSafehacked = false
    DeleteSafe()
end)


AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    DeleteSafe()
end)