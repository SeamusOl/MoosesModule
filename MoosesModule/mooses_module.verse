
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }

mooses_module<public> := module:

    utils<public> := module:
        player_counter<public> := class:
            var PlayerMap<private> : [agent]logic = map{}
        
            # Returns the number of players being counted
            GetCount<public>()<transacts>:int=
                var Count : int = 0
                for(Agent->IsInZone : PlayerMap):
                    if(IsInZone?):
                        set Count += 1
                Print("Count : {Count}")
                return Count
        
            # Returns an array of all the players being counted
            GetPlayers<public>()<transacts>:[]agent=
                var PlayersInZone : []agent = array{}
                for(Agent->IsInZone : PlayerMap):
                    if(IsInZone?):
                        set PlayersInZone += array{Agent}
                PlayersInZone
        
            # Registers the Agent to be counted
            Register<public>(Agent : agent):void=
                if(set PlayerMap[Agent] = true):
                    Print("Registered")
        
            # Unregisters the Agent to be not counted
            Unregister<public>(Agent : agent):void=
                if(set PlayerMap[Agent] = false):
                    Print("Unregistered")
        
            # Unregisters all agents to be not counted
            UnregisterAll<public>():void=
                set PlayerMap = map{}
        
            # Fails if Agent is not being counted
            IsRegistered<public>(Agent : agent)<decides><transacts>:void=
                var MaybeAgent : ?agent = false
                if(PlayerMap[Agent]?):
                    set MaybeAgent = option{Agent}
                MaybeAgent?
        
        teleport_to_random := class(creative_device):

            <#
                If you don't want the players to be able to go back into the teleporters
                they are teleported to. Set the group to None on all the teleporters, you 
                should additionally hide the rift and vfx if the player can't use them.
            #>
        
            @editable
            Teleporters : []teleporter_device = array{}
        
            @editable
            TeleportTrigger : trigger_device = trigger_device{}
        
            OnBegin<override>()<suspends>:void=
                TeleportTrigger.TriggeredEvent.Subscribe(OnTriggered)
        
            OnTriggered(MaybeAgent : ?agent):void=
                if(Agent := MaybeAgent?):
                    TeleportToRandomTeleporter(Agent)
        
            # When called, teleports the Agent to a random teleporter within the Teleporters array
            TeleportToRandomTeleporter(Agent : agent):void=
                RandIndex := GetRandomInt(0, Teleporters.Length-1)
                if(Teleporter := Teleporters[RandIndex]):
                    Teleporter.Teleport(Agent)

    # Time module for using time and date
    time<public> := module:

        # Time and date class
        time_and_date<public> := class:
            Year<public> : int
            Month<public> : int
            Day<public> : int
            Hour<public> : int
            Minute<public> : int
            Second<public> : int
            # Used for comparison
            EpochSeconds<public> : float

            Print<public>():void=
                Print("{Year}, {Month}, {Day}\n{Hour}:{Minute}:{Second}")

            GreaterThan<public>(TimeAndDate : time_and_date)<transacts><decides>:void=
                EpochSeconds > TimeAndDate.EpochSeconds


        # Makes a new time_and_date object from parameters
        MakeTimeAndDate<public>(Year : int, Month : int, Day : int, Hour : int, Minute : int, Second : int, EpochSeconds : float)<transacts>:time_and_date=
            time_and_date:
                Year := Year
                Month := Month
                Day := Day
                Hour := Hour
                Minute := Minute
                Second := Second
                EpochSeconds := EpochSeconds

        # Returns if the given Year is a leap year or not
        IsLeapYear<public>(Year : int)<transacts>:logic=
            if((Mod[Year, 4] = 0 and Mod[Year, 100] <> 0) or (Mod[Year, 400] = 0)):
                return true
            false

        # Returns the seconds in a year depending on if it's a leap year or not
        GetSecondsInYear<public>(Year : int)<transacts>:float=
            if(IsLeapYear(Year)?):
                return 31622400.0
            return 31536000.0

        # Returns OldSeconds % ModNum
        GetModSecondsSinceEpoch(OldSeconds : float, ModNum : float)<transacts>:float=
            if:
                IntEpochSeconds := Int[OldSeconds]
                IntModNum := Int[ModNum]
                NewSecondsSinceEpoch := Mod[IntEpochSeconds, IntModNum] * 1.0
            then:
                return NewSecondsSinceEpoch
            0.0

        # Array of all the days in a month in a non leap year
        DaysInMonth : []int = array{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

        # Returns the Int version of Seconds / Divisor
        MakeTimeUnit(Seconds : float, Divisor : float)<transacts>:int=
            if(Unit := Int[Seconds / Divisor]):
                return Unit
            0

        # Makes a time_and_date object from the given Seconds
        MakeTimeAndDateFromSeconds<public>(EpochSeconds : float)<transacts>:time_and_date=
            SecondsInMinute := 60.0
            SecondsInHour := SecondsInMinute * 60.0
            SecondsInDay := SecondsInHour * 24.0

            # Calculate years
            var Year : int = 1970
            var SecondsSinceEpoch : float = EpochSeconds
            loop:
                SecondsInYear := GetSecondsInYear(Year)
                if(SecondsSinceEpoch >= SecondsInYear):
                    set SecondsSinceEpoch -= SecondsInYear
                    set Year += 1
                else:
                    break

            # Calculate months
            var Month : int = 1
            loop:
                if(var Days : int = DaysInMonth[Month-1]):
                    if(Month = 2 and IsLeapYear(Year)):
                        set Days = 29
                    SecondsForMonth := Days * SecondsInDay
                    if(SecondsSinceEpoch >= SecondsForMonth):
                        set SecondsSinceEpoch -= SecondsForMonth
                        set Month += 1
                    else:
                        break
                else:
                    break

            # Calculate days
            Day := MakeTimeUnit(SecondsSinceEpoch, SecondsInDay) + 1
            set SecondsSinceEpoch = GetModSecondsSinceEpoch(SecondsSinceEpoch, SecondsInDay)

            # Calculate hours
            Hour := MakeTimeUnit(SecondsSinceEpoch, SecondsInHour)
            set SecondsSinceEpoch = GetModSecondsSinceEpoch(SecondsSinceEpoch, SecondsInHour)
            
            # Calculate minutes
            Minute := MakeTimeUnit(SecondsSinceEpoch, SecondsInMinute)
            set SecondsSinceEpoch = GetModSecondsSinceEpoch(SecondsSinceEpoch, SecondsInMinute)
            
            # Remaining seconds
            var Second : int = 0
            if(NewSeconds := Int[SecondsSinceEpoch]):
                set Second = NewSeconds

            time_and_date:
                Year := Year
                Month := Month
                Day := Day
                Hour := Hour
                Minute := Minute
                Second := Second
                EpochSeconds := EpochSeconds

        # Gets a time_and_date object for the current date and time
        GetTimeAndDate<public>()<transacts>:time_and_date=
            Seconds := GetSecondsSinceEpoch()
            MakeTimeAndDateFromSeconds(Seconds)
