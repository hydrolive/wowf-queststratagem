-- Yards and bearing. Uses HereBeDragons when another addon already loaded it.
-- Otherwise converts map points with C_Map world positions.
-- Positive relative angle is counter-clockwise: the player's left.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Arrow = {}
QS.Arrow = Arrow

local PI2 = math.pi * 2
local result = {
    yards = nil,
    word = nil,
    angle = 0,
    mode = "none",
    pin = nil,
}

local WORDS = {
    { -0.3927, 0.3927, "ahead" },
    { 0.3927, 1.1781, "ahead-left" },
    { 1.1781, 1.9635, "left" },
    { 1.9635, 2.7489, "behind-left" },
    { 2.7489, 3.1416, "behind" },
    { -3.1416, -2.7489, "behind" },
    { -2.7489, -1.9635, "behind-right" },
    { -1.9635, -1.1781, "right" },
    { -1.1781, -0.3927, "ahead-right" },
}

local function Wrap(angle)
    while angle > math.pi do
        angle = angle - PI2
    end
    while angle < -math.pi do
        angle = angle + PI2
    end
    return angle
end

local function Word(relative)
    for i = 1, #WORDS do
        local row = WORDS[i]
        if relative >= row[1] and relative < row[2] then
            return row[3]
        end
    end
    return "ahead"
end

-- Same normalization HereBeDragons uses so the result matches GetPlayerFacing.
local function WorldVector(ox, oy, dx, dy)
    local deltaX = dx - ox
    local deltaY = dy - oy
    local dist = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    local angle = math.atan2(-deltaX, deltaY)
    if angle > 0 then
        angle = PI2 - angle
    else
        angle = -angle
    end
    return angle, dist
end

local function HBD()
    if not LibStub then
        return nil
    end
    local ok, lib = pcall(LibStub, "HereBeDragons-2.0", true)
    if ok then
        return lib
    end
    return nil
end

local function MapPoint(mapID, x, y)
    if not (C_Map and C_Map.GetWorldPosFromMapPos and CreateVector2D) then
        return nil
    end
    local instance, pos = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(x, y))
    if not pos then
        return nil
    end
    local py, px = pos:GetXY()
    return px, py, instance
end

local function PlayerWorld()
    if UnitPosition then
        local y, x, _, instanceID = UnitPosition("player")
        if x and y then
            return x, y, instanceID
        end
    end
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition) then
        return nil
    end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        return nil
    end
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then
        return nil
    end
    local x, y = pos:GetXY()
    if not x or (x == 0 and y == 0) then
        return nil
    end
    return MapPoint(mapID, x, y)
end

local function SameMapVector(mapID, tx, ty)
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition and C_Map.GetMapWorldSize) then
        return nil
    end
    local map = C_Map.GetBestMapForUnit("player")
    if map ~= mapID then
        return nil
    end
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then
        return nil
    end
    local px, py = pos:GetXY()
    if not px then
        return nil
    end
    local width, height = C_Map.GetMapWorldSize(mapID)
    if not width or width == 0 or not height or height == 0 then
        return nil
    end
    local deltaX = -width * (tx - px)
    local deltaY = -height * (ty - py)
    return WorldVector(0, 0, deltaX, deltaY)
end

function Arrow.Measure(step)
    result.yards = nil
    result.word = nil
    result.angle = 0
    result.mode = "none"
    result.pin = step and (step.pin or (step.x and "exact" or nil)) or nil
    if not step or not step.x or not step.y or not step.mapID then
        return result
    end
    local inInstance = IsInInstance and IsInInstance()
    if inInstance then
        result.mode = "instance"
        return result
    end
    local facing = GetPlayerFacing and GetPlayerFacing() or 0
    local angle, dist
    -- A missing map call must not kill the OnUpdate script.
    local ok = pcall(function()
        local lib = HBD()
        if lib then
            local px, py, instance = lib:GetPlayerWorldPosition()
            local tx, ty, tInstance = lib:GetWorldCoordinatesFromZone(step.x, step.y, step.mapID)
            if px and tx and instance and tInstance and instance == tInstance then
                angle, dist = lib:GetWorldVector(instance, px, py, tx, ty)
            end
        end
        if not angle then
            local px, py, instance = PlayerWorld()
            local tx, ty, tInstance = MapPoint(step.mapID, step.x, step.y)
            if px and tx and (not instance or not tInstance or instance == tInstance) then
                angle, dist = WorldVector(px, py, tx, ty)
            end
        end
        if not angle then
            angle, dist = SameMapVector(step.mapID, step.x, step.y)
        end
    end)
    if not ok then
        angle, dist = nil, nil
    end
    if not angle or not dist then
        result.mode = "none"
        return result
    end
    local relative = Wrap(angle - facing)
    result.yards = dist
    result.angle = relative
    result.word = Word(relative)
    result.mode = "ok"
    return result
end

function Arrow.DistanceText(measure, step)
    if measure.mode == "instance" then
        if step and step.boss then
            return "Inside · " .. step.boss
        end
        return "Inside · follow BiS / quest"
    end
    if measure.mode ~= "ok" then
        return "—"
    end
    local yards = measure.yards or 0
    local dist = (yards < 8) and "here" or (math.floor(yards + 0.5) .. " yd")
    local pin = measure.pin or "approx"
    if measure.word then
        return dist .. " · " .. measure.word .. " · " .. pin
    end
    return dist
end
