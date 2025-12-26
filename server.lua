ESX = exports["es_extended"]:getSharedObject()

local spawnedPeds = {}
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
        cooldown[source] = false
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(npc)
    spawnedPeds[netId] = {
        alive = true,
        rewarded = false
    }

    GiveWeaponToPed(npc, `WEAPON_UNARMED`, 1, false, true)
    TaskCombatPed(npc, GetPlayerPed(src), 0, 16)

    TriggerClientEvent("angryped:syncPed", src, netId)
end)

RegisterNetEvent("angryped:pedDied", function(netId)
    local src = source
    local pedData = spawnedPeds[netId]

    if not pedData then return end
    if not pedData.alive then return end
    cooldown[source] = false

    pedData.alive = false

    if not pedData.rewarded then
        pedData.rewarded = true
        RewardPlayer(src)
    end

    spawnedPeds[netId] = nil
end)
