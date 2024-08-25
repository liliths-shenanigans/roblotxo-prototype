--initial variables
local RunService = game:GetService("RunService")
local StartTick = time()

--service initialization
local TimeScaleService = {} --header

TimeScaleService.ScaledTick = nil

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

--internal functions
local function UpdateScaledTick(time: number,step: number)
    if not TimeScaleService.ScaledTick then --Makes it so the scaled tick starts counting when the RunService connection actually happens. Not necessary just for my sanity lol
        TimeScaleService.ScaledTick = 0
    end

    local _ScaledStep = step*TimeScaleService.GlobalTimeScale*TimeScaleService.LocalTimeScale
    
    TimeScaleService.ScaledTick = TimeScaleService.ScaledTick+_ScaledStep
end

TimeScaleService.ModifiersUpdated:Connect(TimeScaleService.UpdateTimeScale)

--timescale loop
RunService.Stepped:Connect(UpdateScaledTick)

return TimeScaleService
