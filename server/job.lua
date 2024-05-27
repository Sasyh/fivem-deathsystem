ESX.RegisterServerCallback('esx_ambulancejob:getItemAmount', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local quantity = xPlayer.getInventoryItem(item).count
	cb(quantity)
end)

RegisterServerEvent('sasy:animazionemedico')
AddEventHandler('sasy:animazionemedico', function(targetid, playerheading, playerCoords,  playerlocation)
	_source = source
    TriggerClientEvent('anim:ferito', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('anim:medico', _source)
end)

RegisterNetEvent('sasy_rilascia_cert', function(t)
	exports.ox_inventory:AddItem(t, 'certificato', 1, nil, nil, function(success, reason)
        if not success then
            return
        end
    end)
    local doc = exports.ox_inventory:Search(t, 1, 'certificato', nil)
    local xT = ESX.GetPlayerFromId(t)
    for k, v in pairs(doc) do
        doc = v
    end
    doc.metadata.type = xT.getName()
    exports.ox_inventory:SetMetadata(t, doc.slot, doc.metadata)	 
end)