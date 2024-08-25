--Initial variables
local ServerScriptService = game:GetService("ServerScriptService")
local UUIDGenerator = require(ServerScriptService.Server.UUIDGenerator)
local Globals = require(ServerScriptService.Server.Globals)

local EntityUUIDGenerator = UUIDGenerator.new("EntityUUIDGenerator")

--Entity class table initialization
local Entity = {} --Header table
Entity.__index = Entity 

Entity.Entities = {} --Container for all constructed Entity objects

--Base class
local function EntityBase()
    local _EntityBase
    _EntityBase = {
        Model = nil; --Does not exist by default! Assign during construction
        MaxHealth = Globals.DEFAULT_MAXHEALTH;
        Health = Globals.DEFAULT_MAXHEALTH;
        Invulnerable = false;
        Targetable = true;
        UUID = EntityUUIDGenerator:CreateUUID();
        --Event values that are only accessed internally
        _Died = Instance.new("BindableEvent");
    }
    --Actual bindable event that scripts can listen to
    _EntityBase.Died = _EntityBase._Died.Event;
    return _EntityBase
end

--Functions
function Entity:UpdateHealth(value: number)
    local _NewHealth = math.clamp(self.Health+value,0,self.MaxHealth)
    if _NewHealth == 0 then
        _Died:Fire()
    end
    self.Health = _NewHealth
end

function Entity:TakeDamage(value: number) --update this with logic for dodge frames and whatever later
    if self.Targetable == true then
        self:UpdateHealth(value)
    end
end
--Constructor
function Entity.new(params:{
    Model: instance
})
    local self = setmetatable(EntityBase(),Entity)
    self.Model = params.Model

    Entity.Entities[self.UUID] = self
    
    return self
end

--Disposer
function Entity:Dispose()
    EntityUUIDGenerator:DisposeUUID(self.UUID)
    Entity.Entities[self.UUID] = nil
end

return Entity