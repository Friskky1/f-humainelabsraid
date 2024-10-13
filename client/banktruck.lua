local QBCore = exports['qb-core']:GetCoreObject()

local truckspawned = false
local banktruck = nil
local banktruckblip = nil
local driver = nil
local passenger = nil
local deleteped = nil
local deletepedblip = nil

local function banktrukblip()
    local TruckBlip = AddBlipForEntity(banktruck)
	SetBlipSprite(TruckBlip, 67)
	SetBlipColour(TruckBlip, 1)
	SetBlipFlashes(TruckBlip, true)
	SetBlipScale(TruckBlip, 0.8)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Bank Truck')
	EndTextCommandSetBlipName(TruckBlip)
	SetVehicleDirtLevel(vehicle, 0.0)
    banktruckblip = TruckBlip
end

local function SpawnBankTruck()
    local truckspawnloc = Config.BankTruck.spawn
    local vehicle = "stockade"

    SetNewWaypoint(truckspawnloc.x, truckspawnloc.y)
	ClearAreaOfVehicles(truckspawnloc.x, truckspawnloc.y, truckspawnloc.z, 15.0, false, false, false, false, false)
    
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
		SetVehicleNumberPlateText(veh, "BANK-"..tostring(math.random(1, 99)))
		SetEntityHeading(veh, truckspawnloc.w)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
		exports[Config.BankTruck.fuel]:SetFuel(veh, 100.0)
        banktruck = veh
	end, truckspawnloc, true)

    truckspawned = true
	SetEntityAsMissionEntity(banktruck)	
    banktrukblip()

    RequestModel("s_m_m_security_01") while not HasModelLoaded("s_m_m_security_01") do Wait(10)	end
	RequestModel("s_m_m_armoured_01") while not HasModelLoaded("s_m_m_armoured_01") do Wait(10) end

	driver = CreatePed(26, "s_m_m_security_01", truckspawnloc.x, truckspawnloc.y, truckspawnloc.z, truckspawnloc.h, true, true)
	passenger = CreatePed(26, "s_m_m_armoured_01", truckspawnloc.x, truckspawnloc.y, truckspawnloc.z, truckspawnloc.h, true, true)
	SetPedIntoVehicle(driver, banktruck, -1)
	SetPedIntoVehicle(passenger, banktruck, 0)
    TaskVehicleDriveWander(driver, banktruck, 40.0, 447)
    SetDriveTaskDrivingStyle(driver, 786603)

    

    local ReturnPedBlip = AddBlipForEntity(deleteped)
	SetBlipSprite(ReturnPedBlip, 280)
	SetBlipColour(ReturnPedBlip, 0)
	SetBlipScale(ReturnPedBlip, 0.8)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Bank Truck Deliver Point')
	EndTextCommandSetBlipName(ReturnPedBlip)
    deletepedblip = ReturnPedBlip
end 

local function CleanUp()
    SetEntityAsNoLongerNeeded(driver)
    SetEntityAsNoLongerNeeded(passenger)
end

local function banktrukblip()
    local TruckBlip = AddBlipForEntity(banktruck)
	SetBlipSprite(TruckBlip, 67)
	SetBlipColour(TruckBlip, 1)
	SetBlipFlashes(TruckBlip, true)
    SetBlipFlashInterval(TruckBlip, 1000)
	SetBlipScale(TruckBlip, 0.8)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Bank Truck')
	EndTextCommandSetBlipName(TruckBlip)
    banktruckblip = TruckBlip
end

local function returnbanktruck()
    TriggerServerEvent("f-humainelabsraid:server:returnbanktruck")
    DeleteEntity(driver)
    DeleteEntity(passenger)
    RemoveBlip(deletepedblip)
end

RegisterNetEvent("f-humainelabsraid:client:spawnbanktruck", function()
    SpawnBankTruck()
end)

RegisterNetEvent("f-humainelabsraid:client:deletebanktruck", function()
    local ped = PlayerPedId()
    local veh = banktruck
    if truckspawned == true then
        if veh ~= 0 then
            SetEntityAsMissionEntity(veh, true, true)
            DeleteVehicle(veh)
        else
            local pcoords = GetEntityCoords(ped)
            local vehicles = banktruck
            for k, v in pairs(vehicles) do
                if #(pcoords - GetEntityCoords(banktruck)) <= 5.0 then
                    SetEntityAsMissionEntity(v, true, true)
                    DeleteVehicle(v)
                end
            end
        end
        returnbanktruck()
    else
        QBCore.Functions.Notify("There is no bank truck to turn in.", "error", 5000)
    end
    truckspawned = false
end)

CreateThread(function()
    -- Delete Vehicle ped
    local delvehped = Config.BankTruck.deleteped
    RequestModel(delvehped)
    while not HasModelLoaded(delvehped) do 
        Wait(10) 
    end
    local vehp = CreatePed(0, delvehped, Config.BankTruck.deletepedloc.x, Config.BankTruck.deletepedloc.y, Config.BankTruck.deletepedloc.z-1.0, Config.BankTruck.deletepedloc.w, false, false)
    TaskStartScenarioInPlace(vehp, 'WORLD_HUMAN_CLIPBOARD', -1, true)
    FreezeEntityPosition(vehp, true)
    SetEntityInvincible(vehp, true)
    SetBlockingOfNonTemporaryEvents(vehp, true)
    -- Target
    exports['qb-target']:AddTargetEntity(vehp, {
        options = {
            {
                type = "client",
                event = "f-humainelabsraid:client:deletebanktruck",
                icon = 'fas fa-capsules',
                label = 'Turn in Bank Truck',
            }
        },
        distance = 5.0
    })
    deleteped = vehp
end)

CreateThread(function()
    -- Start Bank Truck
    local startbanktruckped = Config.BankTruck.startped
    RequestModel(startbanktruckped)
    while not HasModelLoaded(startbanktruckped) do 
        Wait(10) 
    end
    local bankped = CreatePed(0, startbanktruckped, Config.BankTruck.startpedloc.x, Config.BankTruck.startpedloc.y, Config.BankTruck.startpedloc.z-1.0, Config.BankTruck.startpedloc.w, false, false)
    TaskStartScenarioInPlace(bankped, 'WORLD_HUMAN_CLIPBOARD', -1, true)
    FreezeEntityPosition(bankped, true)
    SetEntityInvincible(bankped, true)
    SetBlockingOfNonTemporaryEvents(bankped, true)
    -- Target
    exports['qb-target']:AddTargetEntity(bankped, {
        options = {
            {
                type = "server",
                event = "f-humainelabsraid:server:BankTruckStarted",
                icon = 'fas fa-capsules',
                label = 'Find a Bank Truck',
            }
        },
        distance = 2.0
    })
end)


AddEventHandler('playerDropped', function()
    if truckspawned then
        SetEntityAsNoLongerNeeded(banktruck)
        RemoveBlip(banktruckblip)
        CleanUp()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if truckspawned then
        DeleteVehicle(banktruck)
        RemoveBlip(banktruckblip)
        CleanUp()
    end
end)