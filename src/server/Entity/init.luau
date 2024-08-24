--Initial variables
local ServerScriptService = game:GetService("ServerScriptService")
local UUIDGenerator = require(ServerScriptService.Server.UUIDGenerator)
local Globals = require(ServerScriptService.Server.Globals)

local EntityUUIDGenerator = UUIDGenerator.new("EntityUUIDGenerator")

--Entity class table initialization
local Entity = {} --Header table
Entity.__index = Entity 

local Entities = {} --Container for all constructed Entity objects

--Base class
local EntityBase = function()
    return {
        Model = nil; --Does not exist by default! Assign during construction
        MaxHealth = Globals.DEFAULT_MAXHEALTH;
        Health = Globals.DEFAULT_MAXHEALTH;
        UUID = EntityUUIDGenerator:CreateUUID();
    }
end

--Constructor
function Entity.new(params:{
    Model: instance
})
    local _Entity = setmetatable(EntityBase(),Entity)
    _Entity.Model = params.Model

    Entities[_Entity.UUID] = _Entity
    
    return _Entity
end

--Disposer
function Entity:Dispose()
    EntityUUIDGenerator:DisposeUUID(self.UUID)
    Entities[self.UUID] = nil
end