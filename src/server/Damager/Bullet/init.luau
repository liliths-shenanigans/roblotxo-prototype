--Initial variables
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Globals = require(ServerScriptService.Server.Globals)

local TimeScaleService = require(ReplicatedStorage.Shared.TimeScaleService)
local LastTick = TimeScaleService.ScaledTick

--Superclass
local Damager = require(ServerScriptService.Server.Damager)

--Bullet class table initialization
local Bullet = {} --Header table
Bullet.__index = Bullet
setmetatable(Bullet,Damager) --inherit methods of Damager superclass

Bullet.Bullets = {} --Container for all bullet objects

--Base class
function BulletBase()
    local self
    self = {
        FiredTick = TimeScaleService.ScaledTick;
        TimeElapsed = 0;
        Lifespan = 3;
        InitialCFrame = CFrame.new(); --initial CFrame of when the bullet is fired for ref point with calculations
        Direction = CFrame.new(0,0,-1); --CFrame direction of the bullet
        CurrentCFrame = CFrame.new(); --current CFrame of the bullet for blockcasting purposes
        --Position = Vector3.new(0,0,0); --vector3s for future z-axis support if i ever get around to it, i guess for now just keep y=0 in both Position and Direction, maybe i'll make separate VerticalPosition and VerticalAcceleration things in future
        --Direction = Vector3.new(0,0,0); --keep y of Direction = 0 at all times, future zaxis movement will be handled via a separate variable if i get around to it
        Parryable = true;
        CanHit = true;
        --UpdateFunction = nil; --overwritten by subclasses of Bullet
        --OnParry = nil; --function that is called when bullet is parried
        --OnLifespanExpire = nil; --function that is called when the bullet expires
        --Event values that are only accessed internally
        _LifespanExpired = Instance.new("BindableEvent");
        _Parried = Instance.new("BindableEvent")
    }
    --Actual bindable event that scripts can listen to
    self.LifespanExpired = self._LifespanExpired.Event;
    self.Parried = self._Parried.Event;
    return self
end

--Functions

function Bullet:Parry()
    if self.Parryable == true then
        self._OnParried:Fire()
        if self.OnParry then
            self:OnParry()
        end
    end
end

--Constructor
function Bullet.new(params: {})
    local self = Damager.new()
    for _Index,_Value in pairs(BulletBase()) do
        self[_Index] = _Value
    end
    if params then
        for _Index,_Value in pairs(params) do
            self[_Index] = _Value
        end
    end
    
    Bullet.Bullets[self.UUID] = self
    return setmetatable(self,Bullet)
end

--Disposer
function Bullet:Dispose()
    Bullet.Bullets[self.UUID] = nil
    Damager.Dispose(self)
end

--Internal use
local function UpdateBullets()
    local _dt = TimeScaleService.ScaledTick - LastTick
    LastTick = TimeScaleService.ScaledTick
    if LastTick == -1 then --TimeScaleService has not initialized yet, somehow
        return
    end
    for i,self in pairs(Bullet.Bullets) do
        self.TimeElapsed += _dt
        if self.TimeElapsed >= self.Lifespan then
            self._LifespanExpired:Fire()
            if self.OnLifespanExpire then
                self:OnLifespanExpire()
            else
                self:Dispose()
            end
        elseif self.Update then
            self:Update(_dt)
        else --should not happen, ever; only happens if Bullet object is missing Update function
            error(":Update() is missing for Bullet object!",2)
        end
    end
end

RunService.Stepped:Connect(UpdateBullets)

return Bullet