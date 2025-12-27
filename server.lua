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
    local ped = GetPlayerPed(src)

    local coords = GetEntityCoords(ped)

    local npc = CreatePed(4, Config.pedModel, coords.x, coords.y, coords.z, 0.0, true, true)
    if not npc then
        cooldown[source] = nil
        return
    end

    Entity(npc).state:set("owner", src, true)
	Entity(npc).state:set("ped", true, true)
	Entity(npc).state:set("rewarded", false, true)

    GiveWeaponToPed(npc, `WEAPON_UNARMED`, 1, false, true)
    TaskCombatPed(npc, ped, 0, 16)
end)

RegisterNetEvent("angryped:validateKill", function(netId)
    local npc = NetworkGetEntityFromNetworkId(netId)
    local pedData = Entity(npc).state
    local owner = pedData.owner
    if owner ~= source then return end
    cooldown[owner] = nil

    if not pedData.rewarded then
        pedData.rewarded = true
        RewardPlayer(owner)
    end
end)

AddEventHandler('esx:playerDropped', function (playerId)
    cooldown[playerId] = nil
end)