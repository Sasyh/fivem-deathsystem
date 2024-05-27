Config = {
    RemoveItemAfterRespawn = false,  -- Rimuovi gli oggetti dopo il respawn in ospedale
    AmbulanceJob = 'ambulance', -- ambulanza predefinita!
    EventLoaded = 'esx:playerLoaded', 
    JobName = "ambulance", 
    RespawnCoords = vec3(296.426392, -581.274719, 43.147217),
    RemoveItemAfterRespawn = false,  -- Rimuovi gli oggetti dopo il respawn in ospedale

    BleedOut = 180, -- Secondi
    KnockTime = 40, -- Secondi
    ReviveTime = 10, -- Secondi
    CallAmbulanceWait = 1, -- Minuti

    -- Barra di progresso
    rprogress = true, -- se falso usa testo 3D
    rprogressRGB = "rgba(255, 255, 255, 1.0)",

    -- Avviso di emergenza
    GcPhone = false,
    GksPhone = false,
    QuasarPhone = true, 

    -- Auto-rianimazione (con oggetto)
    UseSyringe = true, -- se attivato potrai usare la siringa quando sei a terra per rianimarti
    SyringeKey = 'G', -- tasto per autorizzarti quando sei atterrato, cliccando il tasto inserito confermi...
    TimeSyringe = 10,

    -- Comandi
    ReviveAllCommand = 'reviveall',
    ReviveCommand = 'revive',
    Permission = {
        'admin',
        'superadmin',
        'mod',
        'streamer'
    },

    -- Oggetti
    BandageItemName = "bandage",
    SyringeItemName = "siringa",
    RessItemName = 'medikit',

    -- Assegnazione tasti
    ChiamaSoccorsiKey = 'G', 
    RespawnKey = 'E',
    AmbulanceMenuKey = 'F6',
}

Lang = {
    ["start_call"]                          = "Hai chiamato i soccorsi. Potrai rifarlo fra "..Config.CallAmbulanceWait.." minuti.",
    ["press_Call_and_respawn_temp1"]        = "Premi ~g~["..Config.ChiamaSoccorsiKey.."]~w~ per chiamare i soccorsi,  \nPotrai respawnare tra %s secondi",
    ["press_E_to_respawn"]                  = "Premi ~r~["..Config.RespawnKey.."]~w~ per Respawnare",
    ["no_player_nearby"]                    = "Nessun player vicino",
    ["only_death"]                          = "Puoi usarlo solo da morto",
    ["text_knock"]                          = "Sei a terra",
    ['you_have_call']                       = "Hai già chiamato i soccorsi, aspetta 5 minuti per fare un altra chiamata",
    ['revive_player']                       = "[~b~E~s~] Rianima",
    ['reviving']                            = 'Rianimando',
    ['you_need_item']                       = 'Non hai '..Config.RessItemName,
    ['use_syringe']                         = '[~b~E~s~] per usare la siringa',
    ['using_syringe']                       = 'Usando siringa'
}

Config.Doctor = 0 -- Numero minimo di EMS per lavorare
Config.Price = 2000
Config.ReviveTime = 20000  -- in millisecondi
