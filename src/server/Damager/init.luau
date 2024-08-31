--Initial variables
local ServerScriptService = game:GetService("ServerScriptService")
local UUIDGenerator = require(ServerScriptService.Server.UUIDGenerator)
local Globals = require(ServerScriptService.Server.Globals)

local DamagerUUIDGenerator = UUIDGenerator.new("DamagerUUIDGenerator")

--Damager class table initialization
local Damager = {} --Header table
Damager.__index = Damager 

Damager.Damagers = {} --Container for all constructed Damager objects

--Base class
local function DamagerBase()
    local self
    self = {
        Damage = 0;
        BypassInvulnerability = false;
        Owner = nil; --entity class
        UUID = DamagerUUIDGenerator:CreateUUID();
        --Event values that are only accessed internally
        _HitTarget = Instance.new("BindableEvent")
    }
    --Actual bindable event that scripts can listen to
    self.HitTarget = self.Event;
    return self
end

--Functions
function Damager:AttemptDamageEntity(entity: {
    Invulnerable: boolean;
    Targetable: boolean;
    TakeDamage: any; --function
})
    local _ReturnState = false --false if not able to do damage, true otherwise
    if entity.Targetable then
        if entity.Invulnerable == false or self.BypassInvulnerability == true then
            _ReturnState = true
            self._HitTarget:Fire()
            if self.OnHit then
                self:OnHit()
            end
            entity:TakeDamage(self.Damage)
        end
    end
    return _ReturnState
end

--Constructor
function Damager.new()
    local self = DamagerBase()
    self = setmetatable(self,Damager)

    Damager.Damagers[self.UUID] = self

    return self
end

--Disposer
function Damager:Dispose()
    DamagerUUIDGenerator:DisposeUUID(self.UUID)
    Damager.Damagers[self.UUID] = nil
end

return Damager