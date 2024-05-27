local Tasti = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local CL_Morte = {
    premorto = false,
    morto = false,
    secondi = Config.BleedOut,
    puoFarla = true,
}

function TabelleReset()
    CL_Morte = {
        premorto = false,
        morto = false,
        secondi = Config.BleedOut,
        puoFarla = true,
    }
end

AddEventHandler('esx:onPlayerDeath', function(data)
    if not CL_Morte.premorto then
        PreAnimation()
    else
        MorteVera()
    end
end)

local RequestanimDict = function (animazione)
    if not HasAnimDictLoaded(animazione) then
		RequestAnimDict(animazione)
		while not HasAnimDictLoaded(animazione) do
			Wait(1)
		end
	end
end

RegisterNetEvent('sasy_item')
AddEventHandler('sasy_item', function(n)
    local p = PlayerPedId()
    if n == 'bandage' then
        ESX.Streaming.RequestAnimDict("missheistdockssetup1clipboard@idle_a", function()
            TaskPlayAnim(p,"missheistdockssetup1clipboard@idle_a",'idle_a', 8.0, -8.0, -1, 0, 0, false, false, false)
            Wait(3000)
            TriggerServerEvent('sasy-morte:setHeal', 25)
            ClearPedTasks(p)
        end)
    end
end)

exports('getPreDeath',function()
    return CL_Morte.premorto
end)

exports('getDeath',function()
    return CL_Morte.morto
end)

RegisterNetEvent("sasy-morte:setHeal")
AddEventHandler("sasy-morte:setHeal", function(data)
    ESX.SetPlayerData('dead', false)
    if tonumber(data) then
        local ped = PlayerPedId()
        local a = GetEntityHealth(ped)
        local b = 0
        if a + tonumber(data) > GetEntityMaxHealth(ped) then
            b = GetEntityMaxHealth(ped) 
        else
            b = a + tonumber(data)
        end
        SetEntityHealth(ped,b)    
    end
end)

PreAnimation = function ()
    CL_Morte.premorto = true
    local indietro = false
    ESX.SetPlayerData('dead', true)
    RequestanimDict('missarmenian2')
    RequestanimDict('move_injured_ground')
    RequestanimDict('random@dealgonewrong')
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local Ncoords = {x = (math.floor((coords.x * 10^1) + 0.5) / (10^1)),y = (math.floor((coords.y * 10^1) + 0.5) / (10^1)),z = (math.floor((coords.z * 10^1) + 0.5) / (10^1)), h = (math.floor((heading * 10^1) + 0.5) / (10^1))}
    local stoppato = false
    ClearPedTasks(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedTasksImmediately(ped)
    SetEntityCoordsNoOffset(ped, Ncoords.x, Ncoords.y, Ncoords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(Ncoords.x, Ncoords.y, Ncoords.z, Ncoords.h, false, false)
    DoScreenFadeOut(300)
    Wait(350)
    DoScreenFadeIn(300)
    TaskPlayAnim(ped, 'random@dealgonewrong', 'idle_a', 8.0, -8.0, -1, 0, 0, 0, 0, 0)
    TriggerServerEvent("sasy-morte:UpdateDeathStatus", 'knock')
    -- 
    Citizen.CreateThread(function()
        while CL_Morte.premorto do
            DisableAllControlActions(0)
            DisableAllControlActions(1)
            DisableAllControlActions(28)
            EnableControlAction(1, 1, true)
            EnableControlAction(1, 2, true)
            EnableControlAction(0, 6, true)
            EnableControlAction(0, 5, true)
            EnableControlAction(0, 33, true)
            EnableControlAction(0, 32, true)
            EnableControlAction(0, Tasti[Config.SyringeKey], true)
            -- 
            if IsControlPressed(0, 32) then
                if not IsEntityPlayingAnim(ped, 'move_injured_ground', 'sidel_loop', 3)  then
                    TaskPlayAnim(ped, 'move_injured_ground', 'sidel_loop', 1.0, -8.0, -1, 1, 0, 0, 0, 0)
                end
            else 
                if not indietro then 
                    if not IsEntityPlayingAnim(ped, 'random@dealgonewrong', 'idle_a', 3) then
                        TaskPlayAnim(ped, 'random@dealgonewrong', 'idle_a', 2.0, -8.0, -1, 0, 0, 0, 0, 0)
                    end
                end
            end 
            camRot = Citizen.InvokeNative( 0x837765A25378F0BB, 0, Citizen.ResultAsVector() )
            SetEntityHeading(ped, camRot.z)
            if IsControlPressed(0, 33) then
                indietro = true
                if not IsEntityPlayingAnim(ped, 'move_injured_ground', 'back_loop', 3)  then
                    TaskPlayAnim(ped, 'move_injured_ground', 'back_loop', 3.5, -8.0, -1, 1, 0, 0, 0, 0)
                end
            else
                indietro = false
            end
            if not Config.rprogress then
                ESX.Game.Utils.DrawText3D(GetEntityCoords(ped) + vector3(0,0, 0.7), Lang['text_knock'], 1)
            end
            if Config.UseSyringe then
                local siringaq = exports.ox_inventory:Search('count', Config.SyringeItemName)
                if siringaq > 0 then 
                    ESX.Game.Utils.DrawText3D(GetEntityCoords(ped) + vector3(0,0, 0.4), Lang['use_syringe'], 1)
                if IsControlJustPressed(0, Tasti[Config.SyringeKey]) then
                    exports['rprogress']:Stop()
                    ExecuteCommand('me '..Lang['using_syringe'])
                    exports.rprogress:Custom({
                        Async = true,
                        x = 0.5,          
                        y = 0.5,          
                        From = 0,         
                        To = 100,         
                        Duration = Config.TimeSyringe * 1000,
                        Label = Lang['using_syringe'],
                        Color = Config.rprogressRGB,
                        BGColor = "rgba(0, 0, 0, 0.4)",
                        onComplete = function()
                            ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(q)
                                if q > 0 then
                                    TabelleReset()
                                    TriggerEvent("sasy-morte:updatedeath", true)
                                    TriggerServerEvent("sasy-morte:rimuovi", Config.SyringeItemName)
                                end
                            end, Config.SyringeItemName)
                        end
                    })
                end
                end
            end
            Wait(0)
        end
    end)
    if Config.rprogress then
        --[[exports.rprogress:Custom({
            Async = true,
            x = 0.5,          
            y = 0.5,          
            From = 0,         
            To = 100,         
            Duration = Config.KnockTime * 1000,
            Label = Lang['text_knock'],
            Color = Config.rprogressRGB,
            BGColor = "rgba(0, 0, 0, 0.4)",
            onComplete = function()
                MorteVera()
            end
        })]]

        exports.rprogress:Custom({
            Async = true,
            x = 0.5,          
            y = 0.5 , 
            Duration = Config.KnockTime * 1000,
            Label = Lang['text_knock'],
            Radius = 45,            -- Radius of the dial
            Stroke = 8,            -- Thickness of the progress dial
            ShowTimer = true,       -- Shows the timer countdown within the radial dial
            ShowProgress = false,   -- Shows the progress % within the radial dial 
            Color = "rgba(215, 9, 0, 1.0)",
            onComplete = function()
                MorteVera()
            end

        })
    end
end

function MorteVera()
    if CL_Morte.premorto then
        CL_Morte.premorto = false
        CL_Morte.morto = true
        --
        exports.rprogress:Stop()
        local playerPed = PlayerPedId()
        NetworkResurrectLocalPlayer(GetEntityCoords(playerPed), GetEntityHeading(playerPed), false, false)
        Citizen.Wait(200)
        SetEntityHealth(playerPed, GetPedMaxHealth(playerPed))
        ClearPedTasks(playerPed)
        SetEntityInvincible(playerPed, true)
        -- SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
        TriggerServerEvent("sasy-morte:UpdateDeathStatus", true)
        Morte_Timer()

        Citizen.CreateThread(function()
            while CL_Morte.morto do
                if not IsEntityPlayingAnim(playerPed, 'dead', 'dead_a', 3) then
                    ESX.Streaming.RequestAnimDict('dead', function()
                        TaskPlayAnim(playerPed, 'dead', 'dead_a', 1.0, 0.5, -1, 33, 0, 0, 0, 0)
                    end)
                end
                Citizen.Wait(1000)
            end
        end)

        Citizen.CreateThread(function()
            while CL_Morte.morto do
                Wait(5)
                DisableAllControlActions(0)
                DisableAllControlActions(1)
                DisableAllControlActions(28)
                EnableControlAction(1, 1, true)
                EnableControlAction(1, 2, true)
                EnableControlAction(0, 6, true)
                EnableControlAction(0, 5, true)
                EnableControlAction(0, Tasti[Config.ChiamaSoccorsiKey], true)
                EnableControlAction(0, Tasti[Config.RespawnKey], true)
                -- 
                if CL_Morte.secondi > 0 then
                    ESX.Game.Utils.DrawText3D(GetEntityCoords(PlayerPedId()) + vector(0,0,0.4), Lang['press_Call_and_respawn_temp1']:format(CL_Morte.secondi), 1)
                    if IsControlJustPressed(0, Tasti[Config.ChiamaSoccorsiKey]) then
                        FaiCallAiMedici()
                    end
                else
                    ESX.Game.Utils.DrawText3D(GetEntityCoords(PlayerPedId()) + vector(0,0,0.4), Lang['press_E_to_respawn'], 1)
                    if IsControlJustPressed(0, Tasti[Config.RespawnKey]) then
                        TriggerEvent("sasy-morte:updatedeath", false)
                    end
                end
            end
        end)
    end
end

function Morte_Timer()
    Citizen.CreateThread(function()
        while CL_Morte.morto do
            if CL_Morte.secondi > 0 then
                CL_Morte.secondi = CL_Morte.secondi - 1
            end
            Wait(1000)
        end
    end)
end

function FaiCallAiMedici()
    if CL_Morte.puoFarla then
        StartCall()
        Citizen.CreateThread(function()
            CL_Morte.puoFarla = false
            Wait(Config.CallAmbulanceWait*1000*60)
            CL_Morte.puoFarla = true 
        end)
    else
        ESX.ShowNotification(Lang['start_call'])
    end
end

RegisterNetEvent('sasy-morte:updatedeath',function(morte)
    if morte then
        Revive()
    else
        Respawn()
        if Config.RemoveItemAfterRespawn then
            TriggerServerEvent("sasy-morte:removeItem", 'SasyMorteAC1234')
        end
    end
end)

RegisterNetEvent('sasy-morte:updatedeath2',function(morte)
    if morte == true then
        Respawn()
        if Config.RemoveItemAfterRespawn then
            TriggerServerEvent("sasy-morte:removeItem", 'SasyMorteAC1234')
        end
    elseif morte == 'knock' then
        PreAnimation()
    end
end)

Respawn = function ()
    local ped = PlayerPedId()
    TriggerServerEvent("sasy-morte:UpdateDeathStatus",false)
    DoScreenFadeOut(300)
    TabelleReset()
    while not IsScreenFadedOut() do
        Wait(0)
    end
    TriggerEvent('esx_status:set', 'hunger', 500000)
    TriggerEvent('esx_status:set', 'thirst', 500000)
    TriggerEvent('esx:onPlayerSpawn')
    NetworkResurrectLocalPlayer(Config.RespawnCoords, true, true, false)
    ClearPedTasksImmediately(playerPed)
    SetPlayerInvincible(ped, false)
    ClearPedBloodDamage(ped)
    DoScreenFadeIn(300)
end

Revive = function (data)
    -- 
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
end

if Config.CanReviveKnockedPlayer then
    Citizen.CreateThread(function()
        while true do
            local o = 1000
            local ped = PlayerPedId()
            local pl, dist = ESX.Game.GetClosestPlayer()
            if pl ~= -1 and dist <= 5.0 and not IsEntityPlayingAnim(GetPlayerPed(-1), "dead", "dead_a", 1) and IsEntityPlayingAnim(GetPlayerPed(pl), "random@dealgonewrong", "idle_a", 1) then
                o = 5
                ESX.Game.Utils.DrawText3D(GetEntityCoords(GetPlayerPed(pl)) + vector3(0.0, 0.0, 0.5), Lang['revive_player'], 1)
                if IsControlJustPressed(0, Tasti[Config.RespawnKey]) then
                    ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
                        if quantity > 0 then
                            exports.rprogress:Custom({
                                Async = true,
                                canCancel = false,
                                cancelKey = 178,
                                x = 0.5,
                                y = 0.5,
                                From = 0,
                                To = 100,
                                Duration = Config.ReviveTime * 1000,
                                Label = Lang['reviving'],
                                Color = Config.rprogressRGB,
                                BGColor = "rgba(0, 0, 0, 0.4)",
                                Animation = {
                                    animationDictionary = "mini@cpr@char_a@cpr_str",
                                    animationName = "cpr_pumpchest",
                                },
                                DisableControls = {
                                    Mouse = false,
                                    Player = true,
                                    Vehicle = true
                                },
                                onComplete = function()
                                    TriggerServerEvent("sasy-morte:setHeal", {revive = true, removeitem = true, name = Config.RessItemName},  GetPlayerServerId(pl))
                                end
                            })
                        else
                            ESX.ShowNotification(Lang['you_need_item'])
                        end
                    end, Config.RessItemName)
                end
            end
            Citizen.Wait(o)
        end
    end)
end