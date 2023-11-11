local QBCore = exports['qb-core']:GetCoreObject()
local labsecurity = {}

RegisterNetEvent("f-humainelabsraid:client:SpawnGuards", function()
    SpawnGuardsLab()
end)

function SpawnGuardsLab()
    local Player = PlayerPedId()
    local randomgun = Config.LabGuardWeapon[math.random(1, #Config.LabGuardWeapon)]

    SetPedRelationshipGroupHash(Player, 'PLAYER')
    AddRelationshipGroup('labpatrol')

    for k, v in pairs(Config.LabSecurity) do
        QBCore.Functions.LoadModel(v['model'])
        labsecurity[k] = CreatePed(26, GetHashKey(v['model']), v['coords'], v['heading'], true, true)
        SetPedRandomComponentVariation(labsecurity[k], 0)
        SetPedRandomProps(labsecurity[k])
        SetEntityAsMissionEntity(labsecurity[k])
        SetEntityVisible(labsecurity[k], true)
        SetPedRelationshipGroupHash(labsecurity[k], 'labpatrol')
        SetPedArmour(labsecurity[k], 100)   
        SetPedCanSwitchWeapon(labsecurity[k], true)
        SetPedFleeAttributes(labsecurity[k], 0, false)
        GiveWeaponToPed(labsecurity[k], randomgun, 999, false, false)
        TaskGoToEntity(labsecurity[k], Player, -1, 1.0, 10.0, 1073741824.0, 0)
        SetPedAccuracy(labsecurity[k], Config.LabGuardAccuracy)
        local random = math.random(1, 2)
        if random == 2 then
            TaskGuardCurrentPosition(labsecurity[k], 10.0, 10.0, 1)
        end
    end

    SetRelationshipBetweenGroups(0, 'labpatrol', 'labpatrol')
    SetRelationshipBetweenGroups(5, 'labpatrol', 'PLAYER')
    SetRelationshipBetweenGroups(5, 'PLAYER', 'labpatrol')
end

function DeletePeds()
    for i = 1, #labsecurity do
        DeleteEntity(labsecurity[i])
    end
end

RegisterNetEvent("f-humainelabsraid:client:DeleteSpawnedPeds", function()
    DeletePeds()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    DeletePeds()
end)