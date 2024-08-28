--[[
TODO: Add occlusion culling
]]

--Initial variables
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

local TimeScaleService = require(ReplicatedStorage.Shared:WaitForChild("TimeScaleService"))
local LastTick = TimeScaleService.ScaledTick

local CreateManagedVisualRemote = Remotes:WaitForChild("CreateManagedVisual")

--Class table initialization
local ManagedVisual = {}
ManagedVisual.__index = ManagedVisual

ManagedVisual.ManagedVisuals = {}

--Type definition of base class
type ManagedVisualClass = {
    UUID: string;
    Model: instance;
    FiredTick: number;
    TimeElapsed: number;
    Lifespan: number;
    ForceStopUpdate: boolean?;
    Update: ((self: any) -> nil);
    OnLifespanExpire: ((self: any) -> nil)?;
}

--Functions
function ManagedVisual:UpdateBehavior(toUpdate: {})
    for _Index,_Value in pairs(toUpdate) do
        self[_Index] = _Value
    end
end

--Internal use only
local function GetModelCenter(model: Instance) --Model can be BasePart, HandleAdornment, or you know... Model
    if model["CFrame"] then
        return model.CFrame.Position
    elseif model["GetBoundingBox"] then
        return model:GetBoundingBox().Position
    end
    error("No center could be found for model "..tostring(model).." of class "..model.ClassName,2)
end

local function UpdateAllManagedVisuals()
    local _dt = TimeScaleService.ScaledTick - LastTick
    for i,self in pairs(ManagedVisual.ManagedVisuals) do
        self.TimeElapsed += _dt
        if self.ForceStopUpdate == true then
            self:Dispose()
        elseif self.TimeElapsed >= self.Lifespan then
            if self.OnLifespanExpire then
                self:OnLifespanExpire()
            end
            self:Dispose()
        else
            self:Update()
        end
    end
end

--Constructor
function ManagedVisual.new(toManage: ManagedVisualClass)
    local self: ManagedVisualClass = setmetatable(toManage,ManagedVisual)
    self.ForceStopUpdate = false
    self.TimeElapsed = TimeScaleService.ScaledTick - self.FiredTick
    if not self.Update then
        error("Update function missing when attempting to create ManagedVisual",2)
    else
        ManagedVisual.ManagedVisuals[self.UUID] = self
    end
    return self
end

--Dispose
function ManagedVisual:Dispose()
    self.Model:Destroy()
    ManagedVisual.ManagedVisuals[self.UUID] = nil
end

RunService:BindToRenderStep("Update ManagedVisuals",99,UpdateAllManagedVisuals)

return ManagedVisual