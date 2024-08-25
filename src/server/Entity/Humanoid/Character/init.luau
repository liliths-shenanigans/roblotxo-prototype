--Initial variables
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ServerScriptService.Server.Globals)
local Remotes = ReplicatedStorage.Shared.Remotes

local InitializeCharacterRemote = Remotes.InitializeCharacter

--Superclass
local Humanoid = require(ServerScriptService.Server.Entity.Humanoid)

--[[
Characters are Humanoids that are controlled by players. Ergo they inherit all methods of Humanoid but with additional
methods for player control input.
]]

--Class table initialization
local Character = {} --Header table
Character.__index = Character
setmetatable(Character,Humanoid) --inherit methods of superclass

local Characters = {} --container for all characters

--Functions

--Constructor
function Character.new(params:{
    Player: Player
})
    local _Player = params.Player
    _Player:LoadCharacter()
    
    local self = Humanoid.new({
        Model = _Player.Character
    })
    self.Player = _Player
    self = setmetatable(self,Character)
    InitializeCharacterRemote:FireClient(self.Player, self)

    return self
end

return Character