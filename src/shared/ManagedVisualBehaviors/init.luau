--module containing function data for ManagedVisual objects
local TimeScaleService = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TimeScaleService"))

local ManagedVisualBehaviors = {}

--debug behavior
ManagedVisualBehaviors.DebugTest = {}
function ManagedVisualBehaviors.DebugTest:Update()
    print(self.TimeElapsed)
    self.Model.CFrame = CFrame.new(0,0,10)*CFrame.Angles(0,self.TimeElapsed*(math.pi/0.25),0)
end

ManagedVisualBehaviors.LinearBullet = {}
function ManagedVisualBehaviors.LinearBullet:Update()
    local _dtTotal = TimeScaleService.ScaledTick - self.FiredTick
    local _dCF0 = CFrame.new(0,0,-self.Speed*_dtTotal)
    local _NuCF = self.InitialCFrame * (self.Direction*_dCF0)
    self.Model.CFrame = _NuCF
    self.Model.Interior.CFrame = _NuCF
end

return ManagedVisualBehaviors