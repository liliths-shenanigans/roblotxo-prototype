local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ManagedVisualRemote = ReplicatedStorage.Shared.Remotes.CreateManagedVisual

local TimeScaleService = require(ReplicatedStorage.Shared.TimeScaleService)
local Character = require(ServerScriptService.Server.Entity.Humanoid.Character)

Players.PlayerAdded:Connect(function(player)
    Character.new({Player = player})
    local _NewVisual = {
        UUID = "test";
        Model = workspace.ifeelsigma;
        FiredTick = TimeScaleService.ScaledTick;
        TimeElapsed = 0;
        Lifespan = math.huge;
        ManagedVisualBehavior = "DebugTest";
    }
    ManagedVisualRemote:FireClient(player,_NewVisual)
end)