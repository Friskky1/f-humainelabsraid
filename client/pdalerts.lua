local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("f-humainelabsraid:client:alertcops", function()
	if Config.PDAlerts == "ps" then

		exports['ps-dispatch']:SuspiciousActivity() -- Project-SLoth qb-dispatch

	elseif Config.PDAlerts == "qb" then

		TriggerServerEvent('police:server:policeAlert', 'Humaine Labs Raid') -- Regular qbcore

	elseif Config.PDAlerts == "cd" then -- Code Design dispatch

		local data = exports['cd_dispatch']:GetPlayerInfo()
		TriggerServerEvent('cd_dispatch:AddNotification', {
			job_table = {'police'}, 
			coords = data.coords,
			title = '10-68 - Armed Robbery',
			message = 'Armed Robbery at Humaine Labs'..data.street, 
			flash = 0,
			unique_id = data.unique_id,
			sound = 1,
			blip = {
				sprite = 501, 
				scale = 1.0, 
				colour = 1,
				flashes = true, 
				text = '10-68 - Humaine Labs Raid',
				time = 5,
				radius = 0,
			}
		})

	elseif Config.PDAlerts == "custom" then -- Custom dispatch PD alert code

		-- Put your dispatch alert code here
		
	else

		print("Please change your Config.PDAlerts to match one of the dispatches scripts.")

	end
end)