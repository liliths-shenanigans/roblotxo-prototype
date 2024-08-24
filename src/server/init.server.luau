local UUIDGenerator = require(script.UUIDGenerator)

local TestGen = UUIDGenerator.new("Test")
for i = 1,10 do
    TestGen:CreateUUID()
end
for _UUID,v in pairs(TestGen.UUIDS) do
    print(_UUID)
end