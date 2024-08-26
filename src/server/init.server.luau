local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local TimeScaleService = require(ReplicatedStorage.Shared.TimeScaleService)
local Character = require(ServerScriptService.Server.Entity.Humanoid.Character)

Players.PlayerAdded:Connect(function(player)
    Character.new({Player = player})
end)