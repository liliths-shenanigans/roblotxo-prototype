--Initial variables
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Globals = require(ServerScriptService.Server.Globals)

local TimeScaleService = require(ReplicatedStorage.Shared.TimeScaleService)

local ManagedVisualBehaviorIndex = "LinearBullet"

local Models = ReplicatedStorage.Assets.Models
local BaseRectangleBulletModel = Models.RectangleBullet:Clone()

local Remotes = ReplicatedStorage.Shared.Remotes
local CreateManagedVisualRemote = Remotes.CreateManagedVisual
local UpdateManagedVisualBehaviorRemote = Remotes.UpdateManagedVisualBehavior

local BulletModelFolder = workspace:FindFirstChild("BulletModels") or Instance.new("Folder",workspace)
BulletModelFolder.Name = "BulletModels"

--Superclass
local Bullet = require(ServerScriptService.Server.Damager.Bullet)

--Class table initialization
local LinearBullet = {}
LinearBullet.__index = LinearBullet
LinearBullet = setmetatable(LinearBullet,Bullet) --inherit superclass methods

LinearBullet.LinearBullets = {} --container for all LinearBullet objects

--Base class
function LinearBulletBase()
    local self
    self = {
        Model = BaseRectangleBulletModel:Clone();
        Speed = 20; --studs per second
        Size = Vector3.new(1,1,2);
    }
    self.Model.Parent = BulletModelFolder
    return self
end
--Internal functions
function DEBUGTRACER(cf)
    local _d = Instance.new("Part",workspace)
    _d.Anchored = true
    _d.CanQuery = false
    _d.CanCollide = false
    _d.Size = Vector3.new(2,2,.1)
    _d.Material = "Neon"
    _d.CFrame = cf
    task.spawn(function()
        wait(0.2)
        _d:Destroy()
    end)
end

--Functions
function LinearBullet:InitializeModel()
    self.Model.Size = self.Size
    self.Model.Interior.Size = self.Size-Vector3.new(0.2,0.2,0.2)
    self.Model.Color3 = Color3.new(1,0,0) --set with coloring code later
end

function LinearBullet:ConstructManagedVisualInfo()
    local _ToSend = {}
    _ToSend.UUID = self.UUID
    _ToSend.FiredTick = self.FiredTick
    _ToSend.TimeElapsed = self.TimeElapsed
    _ToSend.Lifespan = self.Lifespan
    _ToSend.InitialCFrame = self.InitialCFrame
    _ToSend.Direction = self.Direction
    _ToSend.Speed = self.Speed
    _ToSend.Model = self.Model
    _ToSend.ManagedVisualBehavior = ManagedVisualBehaviorIndex

    return _ToSend
end

function LinearBullet:Update(_dt)
    local _dtTotal = TimeScaleService.ScaledTick - self.FiredTick
    local _dCF0 = CFrame.new(0,0,-self.Speed*_dtTotal)
    local _dCF = self.Direction*_dCF0
    local _FinalCF = self.InitialCFrame*_dCF
    --DEBUGTRACER(_FinalCF)
    local _ChangedCF = _FinalCF*(self.CurrentCFrame:Inverse())
    --todo: make Caster class that handles blockcasting for me while still being aware of players and stuff
    --temporary code between here
    local _raycastResult = workspace:Blockcast(self.CurrentCFrame,self.Size,(_FinalCF*(self.CurrentCFrame:Inverse())).Position)
    if _raycastResult then
		--[[ Print all properties of the RaycastResult if it exists
		print(`Block intersected with: {_raycastResult.Instance:GetFullName()}`)
		print(`Intersection position: {_raycastResult.Position}`)
		print(`Distance between block's initial position and result: {_raycastResult.Distance}`)
		print(`The normal vector of the intersected face: {_raycastResult.Normal}`)
		print(`Material hit: {_raycastResult.Material.Name}`)
        ]]
        DEBUGTRACER(CFrame.new(_raycastResult.Position))
        UpdateManagedVisualBehaviorRemote:FireAllClients(self.UUID,{ForceStopUpdate = true})
        self:Dispose()
	else
		--print("Nothing was hit")
	end
    --and here
    self.CurrentCFrame = _FinalCF
end

--Constructor
function LinearBullet.new(params: {})
    local self = Bullet.new()
    self = setmetatable(self,LinearBullet)
    for _Index,_Value in pairs(LinearBulletBase()) do
        self[_Index] = _Value
    end
    if params then
        for _Index,_Value in pairs(params) do
            self[_Index] = _Value
        end
    end
    
    self:InitializeModel()
    CreateManagedVisualRemote:FireAllClients(self:ConstructManagedVisualInfo())

    LinearBullet.LinearBullets[self.UUID] = self
    return self
end

--Disposal function
function LinearBullet:Dispose()
    LinearBullet.LinearBullets[self.UUID] = nil
    Bullet.Dispose(self)
end

return LinearBullet