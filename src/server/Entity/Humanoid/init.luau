--Initial variables
local ServerScriptService = game:GetService("ServerScriptService")

local Globals = require(ServerScriptService.Server.Globals)

--Superclass
local Entity = require(ServerScriptService.Server.Entity)

--Humanoid class table initialization
local Humanoid = {} --Header table
Humanoid.__index = Humanoid
setmetatable(Humanoid,Entity) --inherit methods of superclass

local Entities = {} --Container for all constructed Entity objects

--Functions

--Constructor
function Humanoid.new(params: {
    Model: instance
})
    --Create object inheriting superclass properties
    local _Humanoid = Entity.new({
        Model = params.Model
    })
    _Humanoid = setmetatable(_Humanoid,Humanoid)

    return _Humanoid
end

return Humanoid