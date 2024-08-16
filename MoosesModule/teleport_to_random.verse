
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }

<#
    If you don't want the players to be able to go back into the teleporters
    they are teleported to. Set the group to None on all the teleporters, you 
    should additionally hide the rift and vfx if the player can't use them.
#>

teleport_to_random := class(creative_device):

    @editable
    Teleporters : []teleporter_device = array{}

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
