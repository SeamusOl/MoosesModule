using { /Verse.org/Simulation }

mooses_module<public> := module:

    player_counter<public> := class:
        var PlayerMap<private> : [agent]logic = map{}

        GetCount<public>():int=
            var Count : int = 0
            for(Agent->IsInZone : PlayerMap):
                if(IsInZone?):
                    set Count += 1
            return Count

        GetPlayersInZone<public>():[]agent=
            var PlayersInZone : []agent = array{}
            for(Agent->IsInZone : PlayerMap):
                if(IsInZone?):
                    set PlayersInZone += array{Agent}
            PlayersInZone

        Register<public>(Agent : agent):void=
            if(set PlayerMap[Agent] = true){}

        Unregister<public>(Agent : agent):void=
            if(set PlayerMap[Agent] = false){}

        UnregisterAll<public>():void=
            set PlayerMap = map{}