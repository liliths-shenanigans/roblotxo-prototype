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
    local _DamagerBase
    _DamagerBase = {
        Damage = 0;
        BypassInvulnerability = false;
        UUID = DamagerUUIDGenerator:CreateUUID();
    }
    return _DamagerBase
end

--Functions
function Damager:DealDamageToEntity(entity: {
    Invulnerable: boolean;
    Targetable: boolean;
    TakeDamage: any; --function
})
    local _ReturnState = false --false if not able to do damage, true otherwise
    if entity.Targetable then
        if entity.Invulnerable == false or self.BypassInvulnerability == true then
            _ReturnState = true

            entity:TakeDamage(self.Damage)
        end
    end
end

--Constructor
function Damager.new()
    local _Damager = DamagerBase()
    _Damager = setmetatable(_Damager,Damager)

    Damager.Damagers[_Damager.UUID] = _Damager

    return _Damager
end

--Disposer
function Damager:Dispose()
    DamagerUUIDGenerator:DisposeUUID(self.UUID)
    Damager.Damagers[self.UUID] = nil
end

return Damager