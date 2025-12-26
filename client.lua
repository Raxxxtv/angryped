ESX = exports["es_extended"]:getSharedObject()

local angryMarker

local function CreateAngryPedMarker()
	if angryMarker then return end

	angryMarker = exports.mg_lib:AddMarker({
		name = "angryPed",
		type = 1,
		pos = vector3(215.32, -810.45, 30.73),
		size = {1.2, 1.2, 1.0},
		color = {255, 0, 0, 180},
		helpNotification = "Drücke ~INPUT_CONTEXT~ um einen Passanten zu provozieren",
		onUse = function()
			TriggerServerEvent("angryped:requestSpawn")
		end,
	})
end


AddEventHandler("mg_lib:reload", function()
	CreateAngryPedMarker()
end)

RegisterNetEvent("angryped:syncPed", function(netId)
    CreateThread(function()
        local npc = NetworkGetEntityFromNetworkId(netId)

        while not DoesEntityExist(npc) do
            Wait(50)
            npc = NetworkGetEntityFromNetworkId(netId)
        end

        while DoesEntityExist(npc) and not IsEntityDead(npc) do
            Wait(300)
        end

        TriggerServerEvent("angryped:pedDied", netId)

		Wait(5000)

        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end)
end)

