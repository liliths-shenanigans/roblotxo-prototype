--[[
TODO: Add occlusion culling
]]

--Initial variables
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

local TimeScaleService = require(ReplicatedStorage.Shared:WaitForChild("TimeScaleService"))
local ManagedVisualBehaviors = require(ReplicatedStorage.Shared:WaitForChild("ManagedVisualBehaviors"))
local LastTick = TimeScaleService.ScaledTick

local CreateManagedVisualRemote = Remotes:WaitForChild("CreateManagedVisual")
local UpdateManagedVisualBehaviorRemote = Remotes:WaitForChild("UpdateManagedVisualBehavior")

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
    Speed: number?;
    ForceStopUpdate: boolean?;
    ManagedVisualBehavior: string; --index in ManagedVisualBehaviors to pull Update and OnLifespanExpire from
    --Update: ((self: any) -> nil);
    --OnLifespanExpire: ((self: any) -> nil)?;
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
    LastTick = TimeScaleService.ScaledTick
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
    self.FiredTick = TimeScaleService.ScaledTick
    --self.TimeElapsed = TimeScaleService.ScaledTick - self.FiredTick
    if not ManagedVisualBehaviors[self.ManagedVisualBehavior] then
        error("Behaviors missing when attempting to create ManagedVisual",2)
    elseif not self.Model then
        error("Model is missing when attempting to create ManagedVisual",2)
    else
        self.Update = ManagedVisualBehaviors[self.ManagedVisualBehavior].Update
        self.OnLifespanExpire = ManagedVisualBehaviors[self.ManagedVisualBehavior].OnLifespanExpire
        ManagedVisual.ManagedVisuals[self.UUID] = self
    end
    return self
end

--Dispose
function ManagedVisual:Dispose()
    self.Model:Destroy()
    ManagedVisual.ManagedVisuals[self.UUID] = nil
end

--internal functions
local function OnUpdateManagedVisualBehaviorRemoteFire(uuid,tochange)
    local self = ManagedVisual.ManagedVisuals[uuid]
    if self then
        self:UpdateBehavior(tochange)
    end
end

RunService:BindToRenderStep("Update ManagedVisuals",99,UpdateAllManagedVisuals)
CreateManagedVisualRemote.OnClientEvent:Connect(ManagedVisual.new)
UpdateManagedVisualBehaviorRemote.OnClientEvent:Connect(OnUpdateManagedVisualBehaviorRemoteFire)

return ManagedVisual