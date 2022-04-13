ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent(('%s:checkKey'):format(GetCurrentResourceName()), function()
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getGroup() ~= 'user' then
        xPlayer.triggerEvent(('%s:registerKey'):format(GetCurrentResourceName()))
    end
end)

ESX.RegisterCommand('caradmin', 'mod', function (xPlayer)
    xPlayer.triggerEvent(('%s:openMenu'):format(GetCurrentResourceName()), CanUse(xPlayer))
end)

ESX.RegisterServerCallback(('%s:getPlayers'):format(GetCurrentResourceName()), function(src, cb)
    cb(ESX.GetPlayers())
end)

function CanUse(xPlayer)
    if xPlayer.getGroup() ~= 'user' then
        return Config.All
    end
end