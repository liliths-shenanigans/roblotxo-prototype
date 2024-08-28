--[[
Requires & initializes CameraController and ControlsController singletons
Also requires & initializes ManagedVisual class
This module itself is called by its parent script.
todo:
• Make CameraModule under this
    • CameraModule should have primary position above the player
        • PrimaryOffset for camera "lean" in player's crosshair direction, in style of Synthetik and ETG
        • SecondaryOffset for "recoil" in style of Synthetik
        • tl;dr CameraPosition = Player.Position+ArbitraryHeight+PrimaryOffset+SecondaryOffset
    • Camera should smoothly tween to the desired position with tween speed lowered with math.abs(LocalTimeScale)
        • math.abs() to prevent weird happenings with negative TimeScale if that happens, lol
• Make ControlModule
    • For now use default ControlModule but eventually supersede existing roblox ControlModule with custom fork
        • Support for dynamic keybinds (e.g. active item from spacebar to F or something, idk)
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local PlayerModule = {}
PlayerModule.CameraController = require(script.CameraController)
PlayerModule.ManagedVisual = require(script.ManagedVisual)

return PlayerModule