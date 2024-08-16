
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

            <#If you don't want the players to be able to go back into the teleporters
            they are teleported to. Set the group to None on all the teleporters, you 
            should additionally hide the rift and vfx if the player can't use them.#>

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
        time_and_date<public> := struct<concrete>:
            Year<public> : int = 0
            Month<public> : int = 0
            Day<public> : int = 0
            Hour<public> : int = 0
            Minute<public> : int = 0
            Second<public> : int = 0
            # Used for comparison
            @editable
            EpochSeconds<public> : float = 0.0

        # Returns the hours minutes and seconds in string format
        (T : time_and_date).FormatToString<public>():string=
            T.EpochSeconds.FormatTime(?Digits := 3)

        # Prints the time and date
        (Time : time_and_date).Print<public>():void=
            T  := MakeTimeAndDateFromSeconds(Time.EpochSeconds)
            Print("{T.Year}, {T.Month}, {T.Day}\n{T.Hour}:{T.Minute}:{T.Second}")

        # Fails if T is less than TimeAndDate
        (T : time_and_date).GreaterThan<public>(TimeAndDate : time_and_date)<transacts><decides>:void=
            T.EpochSeconds > TimeAndDate.EpochSeconds

        # Returns a new time_and_date object which indicates time since OldTime to NewTime
        (NewTime : time_and_date).TimeSince<public>(OldTime : time_and_date)<transacts>:time_and_date=
            EpochSeconds := NewTime.EpochSeconds - OldTime.EpochSeconds
            MakeTimeAndDateFromSeconds(EpochSeconds, ?StartingYear := 0, ?StartingMonth := 0, ?StartingDay := 0)

        # Formats time in HH:MM:SS format, Digits indicates whether to show hours, minutes, seconds
        (Time : float).FormatTime<public>(?Digits : int = 3):string=
            if:
                Hours := Int[Time / 3600.0]
                var Minutes : int = Int[(Mod[Int[Time], 3600] * 1.0) / 60.0]
                var Seconds : int = Mod[Int[Time], 60]
            then:
                if(Digits = 2, NewMinutes := Int[Time / 60.0]):
                    set Minutes = NewMinutes
                if(Digits = 1, NewSeconds := Int[Time]):
                    set Seconds = NewSeconds
                var StringHours : string = "{Hours}"
                var StringMinutes : string = "{Minutes}"
                var StringSeconds : string = "{Seconds}"
                if(Hours < 10):
                    set StringHours = "0"+StringHours
                if(Minutes < 10):
                    set StringMinutes = "0"+StringMinutes
                if(Seconds < 10):
                    set StringSeconds = "0"+StringSeconds
                case(Digits):
                    3=>
                        return "{StringHours}:{StringMinutes}:{StringSeconds}"
                    2=>
                        return "{StringMinutes}:{StringSeconds}"
                    1=>
                        return "{StringSeconds}"
                    _=>
            "0:00"

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

        # Returns the Int version zof Seconds / Divisor
        MakeTimeUnit(Seconds : float, Divisor : float)<transacts>:int=
            if(Unit := Int[Seconds / Divisor]):
                return Unit
            0

        # Makes a time_and_date object from the given Seconds
        MakeTimeAndDateFromSeconds<public>(EpochSeconds : float, ?StartingYear : int = 1970, ?StartingMonth : int = 1, ?StartingDay : int = 1)<transacts>:time_and_date=
            SecondsInMinute := 60.0
            SecondsInHour := SecondsInMinute * 60.0
            SecondsInDay := SecondsInHour * 24.0

            # Calculate years
            var Year : int = StartingYear
            var SecondsSinceEpoch : float = EpochSeconds
            loop:
                SecondsInYear := GetSecondsInYear(Year)
                if(SecondsSinceEpoch >= SecondsInYear):
                    set SecondsSinceEpoch -= SecondsInYear
                    set Year += 1
                else:
                    break

            # Calculate months
            var Month : int = StartingMonth
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
            Day := MakeTimeUnit(SecondsSinceEpoch, SecondsInDay) + StartingDay
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

