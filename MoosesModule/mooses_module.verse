using { /Verse.org/Simulation }

mooses_module<public> := module:

    player_counter<public> := class:
        var PlayerMap<private> : [agent]logic = map{}
    
        GetCount<public>()<transacts>:int=
            var Count : int = 0
            for(Agent->IsInZone : PlayerMap):
                if(IsInZone?):
                    set Count += 1
            Print("Count : {Count}")
            return Count
    
        GetPlayers<public>()<transacts>:[]agent=
            var PlayersInZone : []agent = array{}
            for(Agent->IsInZone : PlayerMap):
                if(IsInZone?):
                    set PlayersInZone += array{Agent}
            PlayersInZone
    
        Register<public>(Agent : agent):void=
            if(set PlayerMap[Agent] = true):
                Print("Registered")
    
        Unregister<public>(Agent : agent):void=
            if(set PlayerMap[Agent] = false):
                Print("Unregistered")
    
        UnregisterAll<public>():void=
            set PlayerMap = map{}
    
        IsRegistered<public>(Agent : agent)<decides><transacts>:void=
            var MaybeAgent : ?agent = false
            if(PlayerMap[Agent]?):
                set MaybeAgent = option{Agent}
            MaybeAgent?
