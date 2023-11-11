local QBCore = exports['qb-core']:GetCoreObject()

local hasHandedDocs = false

local function deliverblip()
	DeliverBlip = AddBlipForCoord(Config.DeliverDocPed.coords.x, Config.DeliverDocPed.coords.y, Config.DeliverDocPed.coords.z)
	SetBlipSprite(DeliverBlip, 66)
	SetBlipScale(DeliverBlip, 0.8)
	SetBlipDisplay(DeliverBlip, 2)
	SetBlipColour(DeliverBlip, 0)
	SetBlipRoute(DeliverBlip, true)
    SetBlipAsShortRange(DeliverBlip, true)
    AddTextEntry('DeliverBlip', "Security Worker")
    BeginTextCommandSetBlipName('DeliverBlip')
    EndTextCommandSetBlipName(DeliverBlip)
end


local function RemoveDeliverBlip()
    RemoveBlip(DeliverBlip)
end

local function DeliverPed()
    local DP = Config.DeliverDocPed.model
	RequestModel(DP)
	while not HasModelLoaded(DP) do 
		Wait(10)
	end
	dropoffped = CreatePed(0, DP, Config.DeliverDocPed.coords.xy, Config.DeliverDocPed.coords.z - 1.0, Config.DeliverDocPed.coords.w, false, false)
	FreezeEntityPosition(dropoffped, true)
	SetEntityInvincible(dropoffped, true)
	SetBlockingOfNonTemporaryEvents(dropoffped, true)

    exports['qb-target']:AddTargetEntity(dropoffped, {
		options = {
			{
				type = "client",
				event = "f-humainelabsraid:client:HasSpecialDocs",
				icon = 'fas fa-capsules',
				label = 'Deliver the Special Documents',
			}
		},
		distance = 1.5
	})
end

local function RemoveDeliverPed()
	FreezeEntityPosition(dropoffped, false)
	SetPedKeepTask(dropoffped, false)
	TaskSetBlockingOfNonTemporaryEvents(dropoffped, false)
	ClearPedTasks(dropoffped)
	TaskWanderStandard(dropoffped, 10.0, 10)
	SetPedAsNoLongerNeeded(dropoffped)
	RemoveDeliverBlip()
	Wait(20000)
	DeletePed(dropoffped)
end

RegisterNetEvent("f-humainelabsraid:client:DeliverDocs", function()
    deliverblip()
    DeliverPed()
end)

local function DeleteBP()
	RemoveDeliverBlip()
    RemoveDeliverPed()
	hasHandedDocs = false
end

RegisterNetEvent("f-humainelabsraid:client:HasSpecialDocs", function()
	local ped = PlayerPedId()
	local SpecialDocs = QBCore.Functions.HasItem("special_documents")

	if not SpecialDocs then return QBCore.Functions.Notify("You dont have the Documents", "error", 5000) end
	if hasHandedDocs then return QBCore.Functions.Notify("You already handed in the Special Documents", "error", 5000) end

	if #(GetEntityCoords(ped) - GetEntityCoords(dropoffped)) < 5.0 then
		hasHandedDocs = true
		TaskTurnPedToFaceEntity(dropoffped, ped, 1.0)
		TaskTurnPedToFaceEntity(ped, dropoffped, 1.0)

		Wait(1500)
		RequestAnimDict("mp_safehouselost@")
		while not HasAnimDictLoaded("mp_safehouselost@") do Wait(10) end
		TaskPlayAnim(ped, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
		Wait(3500)
		TaskPlayAnim(dropoffped, "mp_safehouselost@", "package_dropoff", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
		Wait(3500)
		TriggerServerEvent("f-humainelabsraid:server:removeDocumentItem")
		TriggerServerEvent("f-humainelabsraid:server:DocumentsReward")
		Wait(1500)
		DeleteBP()
	end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
	DeleteBP()
end)