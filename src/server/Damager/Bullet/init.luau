--Initial variables
local ServerScriptService = game:GetService("ServerScriptService")
local Globals = require(ServerScriptService.Server.Globals)

--Superclass
local Damager = require(ServerScriptService.Server.Damager)

--Bullet class table initialization
local Bullet = {} --Header table
Bullet.__index = Bullet
setmetatable(Bullet,Damager) --inherit methods of Damager superclass

Bullet.Bullets = {} --Container for all bullet objects

--Base class
function BulletBase()
    local _BulletBase
    _BulletBase = {
        Lifespan = 3;
        Position = Vector3.new(0,0,0); --vector3s for future z-axis support if i ever get around to it, i guess for now just keep y=0 in both Position and Direction, maybe i'll make separate VerticalPosition and VerticalAcceleration things in future
        Direction = Vector3.new(0,0,0); --keep y of Direction = 0 at all times, future zaxis movement will be handled via a separate variable if i get around to it
    }
    return _BulletBase
end

--Constructor
function Bullet.new()
    local _Bullet = Damager.new()
    for _Index,_Value in pairs(BulletBase()) do
        _Bullet.Index = _Value
    end
    _Bullet = setmetatable(_Bullet,Bullet)

    return _Bullet
end

--Disposer already inherited from Damager, woo

return Bullet