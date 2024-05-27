# EXPORTS
RegisterCommand("test",function()
    if exports['sasy-death']:getPreDeath() then return end -- Il player se è knockato non farà utilizzare il comando
    if exports['sasy-death']:getDeath() then return end -- Il player se è morto non farà utilizzare il comando

    -- codice
end)

# OX INVENTORY FIX
Modificare le linee qui sotto riportate (riga 31 circa, ox_inventory/client.lua) con quelle nuove

``` OLD LINES
local function canOpenInventory()
	return PlayerData.loaded
	and not invBusy
	and not PlayerData.dead
	and invOpen ~= nil
	and (not currentWeapon or currentWeapon.timer == 0)
	and not IsPedCuffed(cache.ped)
	and not IsPauseMenuActive()
	and not IsPedFatallyInjured(cache.ped)
end
```

``` NEW LINES
    local function canOpenInventory()
    return PlayerData.loaded
    and not invBusy
    and not exports['sasy-death']:getPreDeath()
    and not exports['sasy-death']:getDeath()
	and not exports['sasy-death']:getRianimando() -- se è in fase di rianimazione (quindi esegue la rianimazione) non può aprire l'inv
    and invOpen ~= nil
    and (not currentWeapon or currentWeapon.timer == 0)
    and not IsPedCuffed(cache.ped)
    and not IsPauseMenuActive()
    and not IsPedFatallyInjured(cache.ped)
end
```