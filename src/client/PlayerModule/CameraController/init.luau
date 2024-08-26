--Initial variables
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

local TimeScaleService = require(ReplicatedStorage.Shared:WaitForChild("TimeScaleService"))

local InitializeCharacterRemote = Remotes:WaitForChild("InitializeCharacter")

local MAX_AIMLEAN_OFFSET = 10 --studs, default value and can dynamically change
local CAMERA_HEIGHT = 30 --studs

local BASE_LERP_FRACTION = 1/10

local MAX_AIMLEAN_SCREEN_FRACTION = 0.6 --0.6 = at 60% of the way to the edge of your screen, aimlean is at max offset

--CameraController class table initialization
local CameraController = {}
CameraController.__index = CameraController

--Base class
local function CameraControllerBase()
    local _CameraControllerBase
    _CameraControllerBase = {
        Camera = workspace.CurrentCamera;
        Character = nil; --Character OBJECT as defined by Entity/Humanoid/Character!!! Is a TABLE
        HumanoidRootPart = nil;
        PrimaryOffset = Vector3.new(); --Offset that determines height of camera and aim lean
        SecondaryOffset = Vector3.new(); --Offset for recoil and effects
        GoalCFrame = CFrame.new(); --Goal CFrame for tweening
        GoalHumanoidRootPartCFrame = CFrame.new(); --Goal CFrame for tweening but for the root part
        UpdateCamera = true; --camera will not update when this is false
        MaxAimLeanOffset = MAX_AIMLEAN_OFFSET;
        Height = CAMERA_HEIGHT;
    }
    return _CameraControllerBase
end

--Functions
function CameraController:OnCurrentCameraChanged() --Fires both whenever workspace.CurrentCamera is changed OR when CameraController is instantiated for the first time
    self.Camera = workspace.CurrentCamera
    self.Camera.CameraType = Enum.CameraType.Scriptable
    print(self.Camera.CameraType)
end

function CameraController:OnCharacterCreated(characterObject)
    self.Character = characterObject
    self.HumanoidRootPart = characterObject.Model:WaitForChild("HumanoidRootPart")
    self:OnCurrentCameraChanged()
end

function CameraController:Update(deltaTime: number)
    local _MouseLocation = UserInputService:GetMouseLocation()
    local _CenterOffsetPreAdjust = (Vector2.new(_MouseLocation.X,self.Camera.ViewportSize.Y-_MouseLocation.Y) - (self.Camera.ViewportSize*0.5))/(self.Camera.ViewportSize*MAX_AIMLEAN_SCREEN_FRACTION*0.5)
    print(_CenterOffsetPreAdjust)
    local _Angle = math.atan(_CenterOffsetPreAdjust.Y/_CenterOffsetPreAdjust.X)
    if _CenterOffsetPreAdjust.X < 0 then
        _Angle = _Angle - math.pi
    end
    local _MaxClampX = math.abs(math.cos(_Angle))
    local _MaxClampY = math.abs(math.sin(_Angle))
    local _CenterOffset = Vector2.new(math.clamp(_CenterOffsetPreAdjust.X,-_MaxClampX,_MaxClampX),math.clamp(_CenterOffsetPreAdjust.Y,-_MaxClampY,_MaxClampY))
    --local _OffsetMagnitude = self.MaxAimLeanOffset*math.sqrt(_CenterOffset.X^2 + _CenterOffset.Y^2)
    local _OffsetVector = Vector3.new(_CenterOffset.X*self.MaxAimLeanOffset,0,-_CenterOffset.Y*self.MaxAimLeanOffset)
    --print(_OffsetVector)

    if self.HumanoidRootPart then
        self.GoalCFrame = CFrame.new(self.HumanoidRootPart.Position+_OffsetVector+Vector3.new(0,self.Height,0))*CFrame.Angles(-math.pi/2,0,0)
        local _LerpedCF = self.Camera.CFrame:Lerp(self.GoalCFrame,BASE_LERP_FRACTION*TimeScaleService.LocalTimeScale)
        self.Camera.CFrame = _LerpedCF

        local _MouseLocationWorldSpace = self.Camera:ViewportPointToRay(_MouseLocation.X,_MouseLocation.Y,self.Camera.CFrame.Y).Origin
        self.GoalHumanoidRootPartCFrame = CFrame.new(self.HumanoidRootPart.Position,Vector3.new(_MouseLocationWorldSpace.X,self.HumanoidRootPart.CFrame.Y,_MouseLocationWorldSpace.Z))
        local _LerpedHumanoidRootPartCFrame = self.HumanoidRootPart.CFrame:Lerp(self.GoalHumanoidRootPartCFrame,BASE_LERP_FRACTION*TimeScaleService.LocalTimeScale)
        self.HumanoidRootPart.CFrame = _LerpedHumanoidRootPartCFrame
    end
end

--Constructor
function CameraController.new()
    local self = setmetatable(CameraControllerBase(),CameraController)
    self:OnCurrentCameraChanged()

    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() --don't need to garbage collect since these only exist on the client and is part of a singleton, lol
        self:OnCurrentCameraChanged()
    end)

    InitializeCharacterRemote.OnClientEvent:connect(function(characterObject)
        self:OnCharacterCreated(characterObject)
    end)

    RunService:BindToRenderStep("After default camera", 201, function(deltaTime)
        self:Update(deltaTime)
    end)

    return self
end

return CameraController.new()