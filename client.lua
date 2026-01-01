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

CreateThread(function()
    CreateAngryPedMarker()
end)

AddStateBagChangeHandler("ped", nil, function(bagName, key, value)
    if value ~= true then return end
    local npc = GetEntityFromStateBagName(bagName)

    CreateThread(function()
        local timeout = 0

        while not NetworkHasControlOfEntity(npc) and timeout < 10 do
            Wait(50)
            timeout = timeout + 1
            NetworkRequestControlOfEntity(npc)
        end

        local coords = GetEntityCoords(npc)
        SetEntityCoordsNoOffset(npc, coords.x, coords.y + 5, coords.z, false, false, false)

        while not IsEntityDead(npc) do
            Wait(300)
        end
        if not DoesEntityExist(npc) then return end
        local netId = NetworkGetNetworkIdFromEntity(npc)
        TriggerServerEvent("angryped:validateKill", netId)
    end)

end)