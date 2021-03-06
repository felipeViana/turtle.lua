local Vector2 = require "vector"
originx, originy = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2

_TURTLEIMAGE = "turtle.png"

local turtle = {}
turtle.__index = turtle

local loadSprite = function (name)
    local fileLoc = "sprites/" .. name
    local f = io.open(fileLoc)
    if f then
        f:close()
        return love.graphics.newImage(fileLoc)
    end
end

local function Node(x, y)
    return {
        _pos = Vector2(x, y) ,
        _distance = 0 ,
        _angle = 0 ,
        _color = nil ,
        _speed = 0 ,
        _distance = 0
    }
end

local function new(x, y, speed, color, name, ondrawfinish)
    _x, _y = x or love.graphics.getWidth() / 2, y or love.graphics.getHeight() / 2
    pos = Vector2(_x, _y) 
    return setmetatable(
    {
        _name = name or "sweet_turtle" ,
        _pos = pos ,
        _currentPos = pos ,
        _sprite = loadSprite(_TURTLEIMAGE) ,
        _speed = 10 ,
        _pensize = 1 ,
        _nodes = {} ,
        _color = {1, 1, 1} ,
        _turtlecolor = {1, 1, 1} ,
        _ratio = 0 ,
        _angle = 0 ,
        _drawAngle = 0 ,
        _currentDistance = 0 ,
        _totalDistance = 0 ,
        _dt = 0 ,
        _playing = true ,
        _nodeIndex = -1 ,
        _lastNodeDrawPos = nil ,
        _finalized = false ,
        _ondrawfinish = ondrawfinish

    }, turtle), self
end

function turtle:_createNode(x, y)
    local node = Node(x, y)
    node._speed = self._speed
    node._color = self._color
    node._angle = self._angle
    return node
end

function turtle:ondrawfinish(ondrawfinish) self._ondrawfinish = ondrawfinish end

function turtle:forward(d)
    local pos = self._pos
    if next(self._nodes) ~= nil then
        pos = self._nodes[#self._nodes]._pos
    end
    pos = addScalarWithAngle(pos, d, self._angle)
    self._nodes[#self._nodes+1] = self:_createNode(pos.x, pos.y)

    self:_calculateTotalDistance()
    return self
end

function turtle:undo(c)
    c = c or 1

    for i = #self._nodes, math.max(0, #self._nodes - c), -1 do
        table.remove(self._nodes, i)
    end

    self._nodeIndex = math.min(#self._nodes, self._nodeIndex)
    self:_calculateTotalDistance()
    return self
end

function turtle:_calculateTotalDistance()
    local dist = 0
    local lastPos = self._pos
    for i = 1, #self._nodes, 1 do
        local node = self._nodes[i]
        local vd = node._pos:distance(lastPos)

        node._distance = vd
        dist = dist + vd

        lastPos = node._pos
    end
    self._totalDistance = dist
end

function turtle:clear()
    self._currentPos = self._currentPos
    self._currentDistance = 0
    self._playing = false
    self._nodeIndex = -1
    self._lastNodeDrawPos = nil
    self._dt = 0
    self._finalized = false
end

function turtle:reset()
    self._currentPos = self._pos
    self._currentDistance = 0
    self._playing = false
    self._nodeIndex = -1
    self._lastNodeDrawPos = nil
    self._dt = 0
    self._finalized = false
end

function turtle:name(...)
    local nargs = select("#", ...)
    if nargs ~= 0 then 
        self._name = select("1", ...)
    end
    return self._name
end

function turtle:rt(deg)
    return self:right(deg)
end

function turtle:right(deg)
    self._angle = self._angle + math.rad(deg)
    return self
end

function turtle:lt(deg)
    return self:left(deg)
end

function turtle:left(deg)
    self._angle = self._angle - math.rad(deg)
    return self
end

function turtle:xcor()
    return self._currentPos.x 
end

function turtle:ycor()
    return self._currentPos.y 
end

function turtle:setx(x)
    self._currentPos.x = x
    return self
end

function turtle:sety(y)
    self._currentPos.y = y
    return self
end

function turtle:position(...)
    local nargs = select("#", ...)
    if nargs == 2 then
        local x, y = select("1", ...), select("2", ...)
        self._currentPos.x, self._currentPos.y = x, y
        print(x, y)
    end 
    return self,self._currentPos.x, self._currentPos.y
end

function turtle:go(x, y) return self:go_to() end

function turtle:setposition(x, y) return self:go_to() end

function turtle:setpos(x, y) return self:go_to() end

function turtle:go_to(x, y)
    self._currentPos.x, self._currentPos.y = x, y
    return self
end

function turtle:seth(deg) return self:setheading(deg) end

function turtle:heading()
    return self._angle
end

function turtle:setheading(deg)
    self._angle = math.rad(deg)
    return self
end

function turtle:distance(x, y) 
    local dx, dy = x - self.x, y - self.y
    return sqrt(dx * dx + dy * dy)
end

function turtle:home()
    self:go_to(originx, originy)
    return self
end

function turtle:isdown()
    return self._drawing
end

function turtle:pd() return self:pendown() end

function turtle:down() return self:pendown() end

function turtle:pendown()
    self._drawing = true
    return self 
end

function turtle:pu() return self:penup() end

function turtle:up() return self:penup() end

function turtle:penup()
    self._drawing = false
    return self 
end

function turtle:pensize(...) 
    local nargs = select("#", ...)
    if nargs ~= 0 then 
        self._pensize = select("1", ...)
        return self
    end
    return self._pensize
end

function isvisible()
    return self._drawing
end 

function st() return self:showturtle() end

function showturtle()
    self._drawing = true
    return self
end

function ht() return self:hideturtle() end

function hideturtle()
    self._drawing = false
    return self
end

function turtle:play() 
    self._playing = true 
end     

function turtle:pause() 
    self._playing = false 
end   

function turtle:toggle() 
    self._playing = not self._playing 
    return self
end

function turtle:tl() return self:heading(-90) end       -- Turn left
function turtle:tr() return self:heading(90) end        -- Turn right

function turtle:back(d) return self:forward(-d) end   
function turtle:bd(d) return self:forward(-d) end   

function turtle:backward(d) 
    return self:forward(-d)
end    -- backward

function turtle:fd(d) return self:forward(d) end  

function turtle:speed(speed)                     
    self._speed = speed
    return self
end

function turtle:tc(...)
    return self:turtlecolor(...)
end

function turtle:turtlecolor(...)
    local c = self._turtlecolor
    local nargs = select("#", ...)
    if nargs < 1 then
        return self._turtlecolor()
    elseif nargs == 3 then
        c = {...}
    elseif nargs == 1 then 
        c = ... 
    end
    self._turtlecolor = c
    print(self._turtlecolor[1], self._turtlecolor[2], self._turtlecolor[3])
    return self
end

function turtle:color(...)                          -- Set color
    local c = self._color
    local nargs = select("#", ...)
    if nargs < 1 then
        return self._turtlecolor()
    elseif nargs == 3 then
        c = {...}
    elseif nargs == 1 then 
        c = ... 
    end
    self._color = c
    return self
end

function turtle:_drawPath()
    local lastPos = self._pos
    for i = 1, self._nodeIndex, 1 do
        local node = self._nodes[i]
        love.graphics.setColor(node._color)
        if i == self._nodeIndex then
            love.graphics.line(lastPos.x, lastPos.y, self._lastNodeDrawPos.x, self._lastNodeDrawPos.y)
            break
        else
            love.graphics.line(lastPos.x, lastPos.y, node._pos.x, node._pos.y)
        end
        lastPos = node._pos
    end
end

function turtle:draw()
    local dt = love.timer.getDelta()
    self:update(dt)
    self:_drawPath()
    love.graphics.setLineWidth(self._pensize)
    love.graphics.setColor({1,1,1})
    if self._sprite then
        love.graphics.setColor(self._turtlecolor)
        love.graphics.draw(self._sprite, self._currentPos.x, self._currentPos.y, self._drawAngle, 1, 1, 8, 8)
    end
end

function turtle:update(dt)
    if next(self._nodes) == nil then return end
    if self._finalized or not self._playing then return end

    local lastPos = self._pos
    local node = self._nodes[math.max(self._nodeIndex, 1)]
    local speed = node._speed
    local angle = node._angle

    self._dt = self._dt + dt * speed * 500

    local ratio = math.min(1.0, math.max(0.0, self._dt / self._totalDistance))
    local reachDistance = self._totalDistance * ratio

    for i = 1, #self._nodes, 1 do
        local node = self._nodes[i]
        local diff = reachDistance - node._distance

        if diff < 0 then
            self._nodeIndex = i
            self._lastNodeDrawPos = lerp(lastPos, node._pos, reachDistance / node._distance)
            self._currentPos = self._lastNodeDrawPos
            break
        end

        reachDistance = diff
        lastPos = node._pos
        self._currentPos = lastPos
    end

    self._drawAngle = angle

    if ratio == 1.0 and not self._finalized then
        self._nodeIndex = #self._nodes
        self._lastNodeDrawPos = self._nodes[self._nodeIndex]._pos
        self._finalized = true
        if self._ondrawfinish ~= nil then self._ondrawfinish() end
    end
end

function turtle:print()
    for _, value in ipairs(self._path.nodes) do
        print(value)
    end
end

return setmetatable({new = new},
{__call = function(_, ...) return new(...) end})
