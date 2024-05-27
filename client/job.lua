RegisterNetEvent('azionilavorativeambulance', function()
	AmbulanceF6Open()
end)

RegisterKeyMapping("ambulancef6", "Open Ambulance Menu", 'keyboard', Config.AmbulanceMenuKey)

RegisterCommand('ambulancef6',function(source,args)
	if ESX.GetPlayerData().job.name == Config.AmbulanceJob then
		AmbulanceF6Open()
	end
end)
local IsBusy = false
local rianimando = false
function AmbulanceF6Open()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'samu', {
		title = 'titolo',
		align = 'top-right',
		elements = {
			{label = "Rianima", value = 'reviveplayer'},
			{label = "Cura ferita lieve", value = 'small'},
			{label = "Cura ferita grave", value = 'big'},
			{label = "Rilascia certificato medico", value = 'cet'},
		}
	}, function(data, menu)
		if IsBusy then return end

		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

		if data.current.value == 'reviveplayer' then
			IsBusy = true
			if not rianimando then
				ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
					if quantity > 0 then									
						local closestPlayerPed = GetPlayerPed(closestPlayer)
						playerheading = GetEntityHeading(GetPlayerPed(-1))
						playerlocation = GetEntityForwardVector(PlayerPedId())
						playerCoords = GetEntityCoords(GetPlayerPed(-1))
						if not exports.sasy-death:getDeath() then
							local playerPed = PlayerPedId()
							rianimando = true 
							ESX.ShowNotification("Rianimazione in corso...")									
							FreezeEntityPosition(closestPlayerPed, true)
							Citizen.Wait(700)
							TriggerServerEvent('sasy:animazionemedico',GetPlayerServerId(closestPlayer), playerheading, playerCoords, playerlocation)
							Citizen.Wait(60000)
							FreezeEntityPosition(closestPlayerPed, false)
							TriggerServerEvent("sasy-morte:setHeal", {revive = true, removeitem = true, name = Config.RessItemName},  GetPlayerServerId(closestPlayer))
							rianimando = false
						else
							ESX.ShowNotification("Il player non è incosciente.")
						end
					else
						ESX.ShowNotification("Ti serve un medikit per rianimare una persona.")
					end
					IsBusy = false
				end, Config.RessItemName)	
			else
				ESX.ShowNotification('Stai già rianimando')
			end						
		elseif data.current.value == 'small' then
			ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
				if quantity > 0 then
					TriggerEvent("nfesx_targeting:beginTargeting", function(plyId)
							local playerPed = PlayerPedId()							
							IsBusy = true
							ESX.ShowNotification("Cura in corso...")
							TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
							Citizen.Wait(10000)
							ClearPedTasks(playerPed)
							TriggerServerEvent('sasy-morte:setHeal', {revive = false, health = 100, removeitem = true, name = Config.BandageItemName}, plyId)
							ESX.ShowNotification("Cura completata")
							IsBusy = false
					end, 2)	
				else
					ESX.ShowNotification("Ti serve una benda per curare.")
				end
			end, Config.BandageItemName)

		elseif data.current.value == 'big' then
			ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
				if quantity > 0 then
					TriggerEvent("nfesx_targeting:beginTargeting", function(plyId)
						local playerPed = PlayerPedId()
						IsBusy = true
						ESX.ShowNotification("Cura in corso...")
						TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
						Citizen.Wait(10000)
						ClearPedTasks(playerPed)
						TriggerServerEvent('sasy-morte:setHeal', {revive = false, health = 200, removeitem = true, name = Config.RessItemName}, plyId)
						ESX.ShowNotification("Cura completata")
						IsBusy = false
					end, 2)
				else
					ESX.ShowNotification("Ti serve un medikit per curare.")
				end
			end, Config.RessItemName)
		elseif data.current.value == 'cet' then
			TriggerEvent("nfesx_targeting:beginTargeting", function(plyId)
				TriggerServerEvent("_rilascia_cert", plyId)
			end, 2)
		end

	end, function(data, menu)
		menu.close()
	end)
end

CreateThread(function ()
	print('--------------------Developed by Sasy Scripts-------------------\n---------------- https://discord.gg/XZYsDdFd2R  ---------------\n---------------------------------------------------------------\n')
end)

function sasy_refreshvisible()
	SetEntityVisible(GetPlayerPed(-1), false)
	Wait(250)
	SetEntityVisible(GetPlayerPed(-1), true)
end

RegisterNetEvent('anim:ferito')
AddEventHandler('anim:ferito', function(playerheading, playercoords, playerlocation)
    local coords = GetEntityCoords(playerPed)
	playerPed = GetPlayerPed(-1)
    loadanimdict('mini@cpr@char_b@cpr_str')
    loadanimdict('mini@cpr@char_b@cpr_def')
	sasy_refreshvisible()
	TriggerEvent('animrevive:loopfalse')
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', false) 
	SetEntityInvincible(playerPed, false)
	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
	SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) 
	local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)
	SetEntityCoords(GetPlayerPed(-1), x, y, z-0.50)
	SetEntityHeading(GetPlayerPed(-1), playerheading - 270.0) 

   	TaskPlayAnim(playerPed, 'mini@cpr@char_b@cpr_def',  'cpr_intro', 8.0, 8.0, -1, 0, 0, false, false, false)
   	Citizen.Wait(15900)
	for i=1, 15, 1 do
	    Citizen.Wait(900)
	    TaskPlayAnim(playerPed, 'mini@cpr@char_b@cpr_str', 'cpr_pumpchest', 8.0, 8.0, -1, 0, 0, false, false, false)
	end	
      TaskPlayAnim(playerPed, 'mini@cpr@char_b@cpr_str', 'cpr_success', 8.0, 8.0, 30590, 0, 0, false, false, false)	
end) 

RegisterNetEvent('anim:medico')
AddEventHandler('anim:medico', function()
    playerPed = GetPlayerPed(-1)
	loadanimdict('mini@cpr@char_a@cpr_def')
	loadanimdict('mini@cpr@char_a@cpr_str')
    TaskPlayAnim(playerPed, 'mini@cpr@char_a@cpr_def', 'cpr_intro', 8.0, 8.0, -1, 0, 0, false, false, false)                      	
    Citizen.Wait(15900)
	for i=1, 15, 1 do
		Citizen.Wait(900)
		TaskPlayAnim(playerPed, 'mini@cpr@char_a@cpr_str','cpr_pumpchest', 8.0, 8.0, -1, 0, 0, false, false, false)
	end
	TaskPlayAnim(playerPed,'mini@cpr@char_a@cpr_str', 'cpr_success', 8.0, 8.0, 30590, 0, 0, false, false, false)
end) 

function loadanimdict(dictname)
	if not HasAnimDictLoaded(dictname) then
		RequestAnimDict(dictname) 
		while not HasAnimDictLoaded(dictname) do 
			Citizen.Wait(1)
		end
	end
end

StartCall = function ()
    ESX.UI.Menu.Open(
		'dialog', GetCurrentResourceName(), 'sasy_chiamamedici',
		{
		  title = 'Richiesta soccorso'
		},
		function(data, menu)
            ESX.ShowNotification(Lang["start_call"])
            if Config.GksPhone then
                local myPos = GetEntityCoords(PlayerPedId())
                local GPS = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
                ESX.TriggerServerCallback('gksphone:namenumber', function(Races)
                    local name = Races[2].firstname .. ' ' .. Races[2].lastname
                    TriggerServerEvent('gksphone:gkcs:jbmessage', name, Races[1].phone_number, data.value, '', GPS, Config.JobName)
                end)
            end
            if Config.QuasarPhone then
                    local playerPed = PlayerPedId()
                    local coords = GetEntityCoords(playerPed)
                    local message = "Richiesta Soccorso" -- The message that will be received.
                    local alert = {
                        message = message,
                        -- img = "img url", -- You can add image here (OPTIONAL).
                        location = coords,
                    }
                  
                    TriggerServerEvent('qs-smartphone:server:sendJobAlert', alert, Config.JobName) -- "Your ambulance job"
                    TriggerServerEvent('qs-smartphone:server:AddNotifies', {
                        head = "Richiesta Soccorso", -- Message name.
                        msg = message,
                        app = 'business'
                    })
            end
            if Config.GcPhone then
                TriggerEvent('esx_addons_gcphone:call', {
                    coords = GetEntityCoords(GetPlayerPed(-1)),
                    job = Config.JobName,
                    message = data.value,
                    display = "911"
                })
            end

            menu.close()
		end,
	function(data, menu)
		menu.close()
	end)
end

exports('getRianimando',function()
	return rianimando
end)

