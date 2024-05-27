local ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
	   TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	   Citizen.Wait(200)
	end
end)

local Active = false
local test = nil
local test1 = nil
local spam = true

local isDead = false


AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)	



RegisterCommand("medico", function(source, args, raw)

	if isDead and spam then
		ESX.TriggerServerCallback('sasy-npcmedico:docOnline', function(EMSOnline, hasEnoughMoney)

			if EMSOnline <= Config.Doctor and hasEnoughMoney and spam then
				SpawnVehicle(GetEntityCoords(PlayerPedId()))
				TriggerServerEvent('sasy-npcmedico:charge')
				--Notify("Medic is arriving")
				exports["vn-core"]:SendAdvanced({
        message = "Un ambulanza sta arrivando alla tua posizione, resista!",
        title = '~y~Emergency Medical Service',
        subject = 'Segnalazione Ricevuta',
        icon = 'CHAR_CALL911',
    })
			else
				if EMSOnline > Config.Doctor then
					--Notify("There is too many medics online", "error")
					Notify("Non è stato possibile effettuare la chiamata")
				elseif not hasEnoughMoney then
					Notify("Non possiedi abbastanza soldi")
				else
					Notify("Attendi un ambulanza sta già arrivando")
				end	
			end
		end)
	else
		Notify("Puoi chiamare i soccorsi solo se ne necessiti veramente.")
	end
end)



function SpawnVehicle(x, y, z)  
	spam = false
	local vehhash = GetHashKey("ambulance")                                                     
	local loc = GetEntityCoords(PlayerPedId())
	RequestModel(vehhash)
	while not HasModelLoaded(vehhash) do
		Wait(1)
	end
	RequestModel('s_m_m_doctor_01')
	while not HasModelLoaded('s_m_m_doctor_01') do
		Wait(1)
	end
	local spawnRadius = 40                                                    
    local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(loc.x + math.random(-spawnRadius, spawnRadius), loc.y + math.random(-spawnRadius, spawnRadius), loc.z, 0, 3, 0)

	if not DoesEntityExist(vehhash) then
        mechVeh = CreateVehicle(vehhash, spawnPos, spawnHeading, true, false)                        
        ClearAreaOfVehicles(GetEntityCoords(mechVeh), 5000, false, false, false, false, false);  
        SetVehicleOnGroundProperly(mechVeh)
		SetVehicleNumberPlateText(mechVeh, "4WNAP")
		SetEntityAsMissionEntity(mechVeh, true, true)
		SetVehicleEngineOn(mechVeh, true, true, false)
        
        mechPed = CreatePedInsideVehicle(mechVeh, 26, GetHashKey('s_m_m_doctor_01'), -1, true, false)              	
        
        mechBlip = AddBlipForEntity(mechVeh)                                                        	
        SetBlipFlashes(mechBlip, true)  
        SetBlipColour(mechBlip, 5)


		PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", 1)
		Wait(2000)
		TaskVehicleDriveToCoord(mechPed, mechVeh, loc.x, loc.y, loc.z, 20.0, 0, GetEntityModel(mechVeh), 524863, 2.0)
		test = mechVeh
		test1 = mechPed
		Active = true
    end
end

Citizen.CreateThread(function()
    while true do
      Citizen.Wait(200)
        if Active then
            local loc = GetEntityCoords(GetPlayerPed(-1))
			local lc = GetEntityCoords(test)
			local ld = GetEntityCoords(test1)
            local dist = Vdist(loc.x, loc.y, loc.z, lc.x, lc.y, lc.z)
			local dist1 = Vdist(loc.x, loc.y, loc.z, ld.x, ld.y, ld.z)
            if dist <= 10 then
				if Active then
					TaskGoToCoordAnyMeans(test1, loc.x, loc.y, loc.z, 1.0, 0, 0, 786603, 0xbf800000)
				end
				if dist1 <= 1 then 
					Active = false
					ClearPedTasksImmediately(test1)
					DoctorNPC()
				end
            end
        end
    end
end)


function DoctorNPC()
	RequestAnimDict("mini@cpr@char_a@cpr_str")
	while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
		Citizen.Wait(1000)
	end

	TaskPlayAnim(test1, "mini@cpr@char_a@cpr_str","cpr_pumpchest",1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
	--exports['progressBars']:startUI(Config.ReviveTime, "The doctor is giving you medical aid")
	TriggerEvent("mythic_progbar:client:progress", {
        name = "ai_doc",
        duration = Config.ReviveTime,
        label = "Stai ricevendo cure mediche",
        useWhileDead = true,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {},
        prop = {}
    }, function(status)
        if not status then
        ClearPedTasks(test1)
	Citizen.Wait(500)
	TriggerEvent('esx_ambulancejob:revive')
	StopScreenEffect('DeathFailOut')	

	local playerPed = PlayerPedId()
    TabelleReset()
    TriggerServerEvent("sasy-morte:UpdateDeathStatus",false)
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    Coords = GetEntityCoords(playerPed)
    Heading = GetEntityHeading(playerPed)
    
    SetEntityCoords(playerPed, Coords.x, Coords.y, Coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(Coords.x, Coords.y, Coords.z, Heading, true, false)

    TriggerServerEvent('SaltyChat_SetVoiceRange', 3.5)
    ClearPedTasksImmediately(playerPed)
    SetEntityInvincible(playerPed, false)
    ClearPedBloodDamage(playerPed)
    TriggerEvent('esx_status:set', 'hunger', 500000) -- inserisce fame e sete a metà
    TriggerEvent('esx_status:set', 'thirst', 500000) -- inserisce fame e sete a metà
    SetEntityHealth(playerPed, GetPedMaxHealth(playerPed))
    TriggerEvent('esx:onPlayerSpawn')
    DoScreenFadeIn(800)
    if Config.rprogress then
        exports.rprogress:Stop()
    end
	
	--Notify("Your treatment is done, you were charged: "..Config.Price)
	exports["vn-core"]:SendAdvanced({
        message = "Pagamento automatico di ~g~$".. Config.Price .." ~w~effettuato per aver pagato le tue cure mediche.",
        title = '~g~Fleeca Bank',
        subject = 'Pagamento Automatico',
        icon = 'CHAR_BANK_FLEECA',
    })
	RemovePedElegantly(test1)
	DeleteEntity(test)
	spam = true
        end
    end)	
end


function Notify(msg)
    ESX.ShowNotification(msg)
end
