--initial variables
local RunService = game:GetService("RunService")
local GetServerTickRemote = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("GetServerTick")
local StartTick = time()

--service initialization
local TimeScaleService = {} --header

TimeScaleService.ScaledTick = -1
local TickOffset = 0 --for client synchronization
local LocalScaledTick = -1 --for client synchronization

TimeScaleService.GlobalTimeScale = 1 --affects non-players only
TimeScaleService.LocalTimeScale = 1 --affects players only
--[[
i keep confusing myself, so here's some documentation for me!!!
GlobalTimeScale exists to slow down everything around the player. "Global" is a bit of a misnomer because in reality,
it's more like everything is slowing down relative to the player i.e. the player is going at Super Speed relative to
their surroundings. On the other hand, LocalTimeScale is an additional multiplier to that timescale for how the player
percieves their surroundings, which effectively is an ADDITIONAL MULTIPLIER stacked on top of GlobalTimeScale for
everything AROUND the player whereas the player itself ONLY experiences LocalTimeScale's effects.

For instance, if we had GlobalTimeScale = 0.3, LocalTimeScale = 0.8, enemies and bullets and what not would be moving
at (0.3*0.8) = 24% of their original speed, whereas the player's movement, camera, et cetera would be moving at 0.8 = 80%
of their original speed.

This means that ScaledTick (i.e. the value that basically well, everything in the game relies on for updating their
movement, positions, whatever) relies on the PRODUCT of GlobalTimeScale and LocalTimeScale.

tl;dr GlobalTimeScale on its own is useless use GlobalTimeScale*LocalTimeScale for everything that isn't the player and
only LocalTimeScale for the player
]]

TimeScaleService.TimeScaleModifiers = {} --container for timescale modifier objects

local _ModifiersUpdatedReference = script.ModifiersUpdated

TimeScaleService.ModifiersUpdated = _ModifiersUpdatedReference.Event
--functions
function TimeScaleService.CreateModifier(id: string, coefficient: number,isLocal: boolean)
    if TimeScaleService.TimeScaleModifiers[id] then
        error("TimeScaleModifier with id "..id.." already exists",2)
        return false
    else
        TimeScaleService.TimeScaleModifiers[id] = {
            Coefficient = coefficient,
            isLocal = isLocal
        }
        _ModifiersUpdatedReference:Fire()
    end
end

function TimeScaleService.DisposeModifier(id)
    if TimeScaleService.TimeScaleModifiers[id] then
        TimeScaleService.TimeScaleModifiers[id] = nil
        _ModifiersUpdatedReference:Fire()
    else
        error("TimeScaleModifier with id "..id.." does not exist during attempted disposal")
    end
end

function TimeScaleService.UpdateTimeScale()
    local _GlobalTimeScale = 1
    local _LocalTimeScale = 1
    for _id,_Data: {coefficient: number,isLocal: boolean} in pairs(TimeScaleService.TimeScaleModifiers) do
        if _Data.isLocal then
            _LocalTimeScale = _LocalTimeScale*_Data.Coefficient
        else
            _GlobalTimeScale = _GlobalTimeScale*_Data.Coefficient
        end
    end

    TimeScaleService.GlobalTimeScale = _GlobalTimeScale
    TimeScaleService.LocalTimeScale = _LocalTimeScale

    return _GlobalTimeScale,_LocalTimeScale
end

--only runs if on client, tick synchronization
if RunService:IsClient() then
    local function GetServerClientTickOffset()
        local _ServerTick = GetServerTickRemote:InvokeServer()
        --local _Ping = game.Players.LocalPlayer:GetNetworkPing()/2
        --_ServerTick += _Ping
        return TimeScaleService.ScaledTick-_ServerTick
    end

    local InitFrameNumber = 5
    local Frame = 0

    local ValuesToKeep = 10
    local RecordedValues = {}

    RunService.RenderStepped:Connect(function()
        Frame += 1
        if Frame == InitFrameNumber then
            Frame = 0
            local _Offset = GetServerClientTickOffset()
            table.insert(RecordedValues,_Offset)
            RecordedValues[11] = nil
            _Offset = 0
            for i,_Value in pairs(RecordedValues) do
                _Offset += _Value
            end
            _Offset /= #RecordedValues
            TickOffset = _Offset
            --print(TickOffset)
        end
    end)
end

--internal functions
local function UpdateScaledTick(time: number,step: number)
    if LocalScaledTick == -1 then --Makes it so the scaled tick starts counting when the RunService connection actually happens. Not necessary just for my sanity lol
        LocalScaledTick = 0
    end

    local _ScaledStep = step*TimeScaleService.GlobalTimeScale*TimeScaleService.LocalTimeScale
    
    LocalScaledTick += _ScaledStep
    if RunService:IsServer() then
        TimeScaleService.ScaledTick = LocalScaledTick
    else
        TimeScaleService.ScaledTick = LocalScaledTick-TickOffset
    end
end

local function GetServerTick(player)
    if RunService:IsServer() then
        return TimeScaleService.ScaledTick
    end
end

if RunService:IsServer() then
    GetServerTickRemote.OnServerInvoke = GetServerTick
end
TimeScaleService.ModifiersUpdated:Connect(TimeScaleService.UpdateTimeScale)

--timescale loop
RunService.Stepped:Connect(UpdateScaledTick)

return TimeScaleService
