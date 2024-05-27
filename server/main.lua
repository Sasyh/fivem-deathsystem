Citizen.CreateThread(function()
    if Config.rprogress then
        if GetResourceState('rprogress') == 'missing' then
            print("^8[Sasy Death] ^0source 'rprogress' not found, disable option from config")
        end
    end
    print("^8[Sasy Death] ^0Developed by Sasy#7543")  
end)

ESX = exports.es_extended:getSharedObject()

local Morto = {}

AddEventHandler(Config.EventLoaded,function (src,xPlayer)
    local pp = ESX.GetPlayerFromId(src)
    local identifier = pp.identifier
    if Morto[identifier] == nil then
        MySQL.Async.fetchAll('SELECT is_dead FROM users WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(result)
            if result[1].is_dead ~= nil then
                if result[1] ~= nil and result[1].is_dead == 1 then
                    Morto[identifier] = true
                elseif result[1] ~= nil and result[1].is_dead == 2 then
                    Morto[identifier] = 'knock'
                else
                    Morto[identifier] = false
                end
            end
            Wait(3500)
            TriggerClientEvent("sasy-morte:updatedeath2",src,Morto[identifier])
        end)
    else
        Wait(3500)
        TriggerClientEvent("sasy-morte:updatedeath2",src,Morto[identifier])        
    end
end)

RegisterServerEvent('sasy-morte:removeItem',function(antic)
    local xPlayer = ESX.GetPlayerFromId(source)
    if antic == 'SasyMorteAC1234' then
        if xPlayer ~= nil then
            for i=1, #xPlayer.inventory, 1 do
                exports['ox_inventory']:ClearInventory(xPlayer.inventory[i])
                if xPlayer.inventory[i].count > 0 then
                    xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
                end
            end
            if xPlayer.getMoney() > 0 then
                xPlayer.removeMoney(xPlayer.getMoney())
            end
            MySQL.update('UPDATE users SET is_dead = @is_dead WHERE identifier = @ide', {['@is_dead'] = 0, ['@ide'] = xPlayer.identifier})
        end
    end
end)

ESX.RegisterUsableItem(Config.BandageItemName, function(source)
    local _source  = source
    local xPlayer  = ESX.GetPlayerFromId(_source)
    TriggerClientEvent("sasy_item", source, 'bandage')
    xPlayer.removeInventoryItem(Config.BandageItemName, 1)
end)

RegisterServerEvent('sasy-morte:UpdateDeathStatus',function(stato)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    Morto[xPlayer.identifier] = stato
end)

RegisterServerEvent("sasy-morte:setHeal")
AddEventHandler("sasy-morte:setHeal",function (data,target)
    local src = source
    if target == nil or target == 0 then target = src end
    if type(data) == 'table' then
        if data.removeitem then
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer.getInventoryItem(data.name) and xPlayer.getInventoryItem(data.name).count > 0 then
                xPlayer.removeInventoryItem(data.name, 1)
                TriggerClientEvent("sasy-morte:updatedeath", target, true)
            else
                xPlayer.showNotification("Non hai un/a"..xPlayer.getInventoryItem(data.name).label)
            end 
        end
        if not data.revive then
            TriggerClientEvent("sasy-morte:setHeal",target,data.health)
        else
            TriggerClientEvent("sasy-morte:updatedeath",target,true)
        end
    elseif type(data) == 'boolean' or type(data) == 'number' then
        TriggerClientEvent("sasy-morte:updatedeath", target, data)
    end
end)
 
RegisterCommand(Config.ReviveAllCommand, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'superadmin' or xPlayer.getGroup() == 'admin' then
        for _, playerId in ipairs(ESX.GetPlayers()) do
            TriggerClientEvent("sasy-morte:updatedeath",playerId,true)
        end 
    end
end)

RegisterCommand(Config.ReviveCommand, function(src, args)
    if src == 0 or src == nil then
        TriggerClientEvent("sasy-morte:updatedeath",tonumber(args[1]),true)
    else
        local xPlayer = ESX.GetPlayerFromId(src)
        for k,v in pairs(Config.Permission) do
            if v == xPlayer.getGroup() then
                if #args > 0 and tonumber(args[1]) then
                    TriggerClientEvent("sasy-morte:updatedeath",tonumber(args[1]),true)
                else 
                    TriggerClientEvent("sasy-morte:updatedeath",src,true)
                end
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
	local src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    if identifier ~= nil then
        if Morto[identifier] == nil then
            Morto[identifier] = false
            MySQL.update('UPDATE users SET is_dead = @is_dead WHERE identifier = @ide', {['@ide'] = identifier, ['@is_dead'] = 0})
        else
            if Morto[identifier] == true then
                MySQL.update('UPDATE users SET is_dead = @is_dead WHERE identifier = @ide', {['@ide'] = identifier, ['@is_dead'] = 1})
            elseif Morto[identifier] == 'knock' then
                MySQL.update('UPDATE users SET is_dead = @is_dead WHERE identifier = @ide', {['@ide'] = identifier, ['@is_dead'] = 2})
            elseif Morto[identifier] == false then
                MySQL.update('UPDATE users SET is_dead = @is_dead WHERE identifier = @ide', {['@ide'] = identifier, ['@is_dead'] = 0})
            end
        end
    end
end)

RegisterNetEvent('sasy-morte:rimuovi',function(item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        if xPlayer.getInventoryItem(item).count > 0 then
            xPlayer.removeInventoryItem(item, 1)
        end
    end
end)