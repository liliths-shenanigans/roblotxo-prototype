--module containing function data for ManagedVisual objects

local ManagedVisualBehaviors = {}

--debug behavior
ManagedVisualBehaviors.DebugTest = {}
function ManagedVisualBehaviors.DebugTest:Update()
    print(self.TimeElapsed)
    self.Model.CFrame = CFrame.new(0,0,10)*CFrame.Angles(0,self.TimeElapsed*(math.pi/0.25),0)
end

return ManagedVisualBehaviors