ESX = exports["es_extended"]:getSharedObject()

local cooldown = {}

local function GetPlayer(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return nil end
	return xPlayer
end

local function RewardPlayer(source)
    local xPlayer = GetPlayer(source)

    local reward = math.random(150, 300)
    xPlayer.addMoney(reward)

    TriggerClientEvent("esx:showNotification", source,
        ("Du hast ~g~%s$~s~ erhalten."):format(reward)
    )
end

RegisterNetEvent("angryped:requestSpawn", function()
    if cooldown[source] then return end
    cooldown[source] = true
    local src = source
    local xPlayer = GetPlayer(src)

    local coords = GetEntityCoords(GetPlayerPed(src))

    local npc = CreatePed(4, Config.pedModel, coords.x + 2.0, coords.y, coords.z, 0.0, true, true)
    if not npc then
        cooldown[source] = nil
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(npc)

    Entity(npc).state:set("ped_owner", src, true)
	Entity(npc).state:set("ped_alive", true, true)
	Entity(npc).state:set("ped_rewarded", false, true)

    GiveWeaponToPed(npc, `WEAPON_UNARMED`, 1, false, true)
    TaskCombatPed(npc, GetPlayerPed(src), 0, 16)

    TriggerClientEvent("angryped:syncPed", src, netId)
end)

AddStateBagChangeHandler("ped_alive", nil, function(bagName, key, value)
    if value ~= false then return end
    local npc = GetEntityFromStateBagName(bagName)
    local pedData = Entity(npc).state
    if not pedData then return end
    local owner = pedData.ped_owner
    cooldown[owner] = nil

    if not pedData.ped_rewarded then
        pedData.ped_rewarded = true
        RewardPlayer(owner)
    end
end)

AddEventHandler('esx:playerDropped', function (playerId)
    cooldown[playerId] = false
end)