
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }

teleport_to_random := class(creative_device):

    @editable
    Teleporters : []teleporter_device = teleporter_device{}

    @editable
    TeleportTrigger : trigger_device = trigger_device{}

    OnBegin<override>()<suspends>:void=
        TeleportTrigger.TriggeredEvent.Subscribe(OnTriggered)

    OnTriggered(MaybeAgent : ?agent):void=
        if(Agent := MaybeAgent?):
            TeleportToRandomTeleporter(Agent)

    TeleportToRandomTeleporter(Agent : agent):void=
        RandIndex := GetRandomInt(0, Teleporters.Length-1)
        if(Teleporter := Teleporters[RandIndex]):
            Teleporter.Teleport(Agent)
