-- The current step becomes one map pin. The Blizzard waypoint is used when
-- this client allows it on that map. TomTom is only the fallback, and it
-- does not take over the arrow. A step with no coordinates clears the pin
-- this addon placed.

QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Pin = {}
QS.Pin = Pin

local lastKey
local nativeSet = false
local tomUID

local function ClearTom()
    if tomUID and TomTom and TomTom.RemoveWaypoint then
        pcall(function()
            TomTom:RemoveWaypoint(tomUID)
        end)
    end
    tomUID = nil
end

function Pin.Clear()
    if nativeSet and C_Map and C_Map.ClearUserWaypoint then
        pcall(C_Map.ClearUserWaypoint)
    end
    nativeSet = false
    ClearTom()
    lastKey = nil
end

local function Native(step)
    if not (C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates) then
        return false
    end
    if C_Map.CanSetUserWaypointOnMap and not C_Map.CanSetUserWaypointOnMap(step.mapID) then
        return false
    end
    local point = UiMapPoint.CreateFromCoordinates(step.mapID, step.x, step.y)
    C_Map.SetUserWaypoint(point)
    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end
    nativeSet = true
    ClearTom()
    return true
end

local function Tom(step)
    if not (TomTom and TomTom.AddWaypoint) then
        return false
    end
    ClearTom()
    local title = step.title or "Stratagem"
    local ok, uid = pcall(function()
        return TomTom:AddWaypoint(step.mapID, step.x, step.y, {
            title = title,
            from = "Stratagem",
            persistent = false,
            minimap = true,
            world = true,
            crazy = false,
        })
    end)
    if ok then
        tomUID = uid
        return true
    end
    return false
end

function Pin.Sync(step)
    if not step or not step.mapID or not step.x or not step.y then
        Pin.Clear()
        return
    end
    local key = tostring(step.mapID) .. ":" .. string.format("%.4f", step.x) .. ":" .. string.format("%.4f", step.y)
    if key == lastKey then
        return
    end
    local ok, placed = pcall(Native, step)
    if not ok or not placed then
        if nativeSet and C_Map and C_Map.ClearUserWaypoint then
            pcall(C_Map.ClearUserWaypoint)
        end
        nativeSet = false
        local tomOk, tomPlaced = pcall(Tom, step)
        placed = tomOk and tomPlaced
    end
    if placed then
        lastKey = key
    else
        lastKey = nil
    end
end
