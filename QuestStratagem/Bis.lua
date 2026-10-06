QuestStratagem = QuestStratagem or {}
local QS = QuestStratagem
local Bis = {}
QS.Bis = Bis

local function Add(list, row, reward)
    list[#list + 1] = {
        slot = row.slot,
        name = row.name,
        how = row.how,
        where = row.where,
        itemID = row.itemID,
        reward = reward and true or false,
        bis = not reward,
    }
end

function Bis.Annotate(route, identity)
    route.bisRows = {}
    local class = identity.class
    local spec = QS.Config.ActiveSpec()
    local tableFor = QS.Registry.bis[class]
    local bands = tableFor and tableFor[spec]
    local show = QS.char.bisCallouts
    for i = 1, #route.steps do
        local rows = {}
        local step = route.steps[i]
        if show then
            if step.rewardChoice and step.rewardChoice[spec] then
                Add(rows, step.rewardChoice[spec], true)
            end
            if step.bis and step.bis[spec] then
                Add(rows, step.bis[spec], false)
            end
            if step.demoBis then
                Add(rows, step.demoBis, false)
            end
            if bands then
                for _, band in pairs(bands) do
                    for n = 1, #band do
                        local item = band[n]
                        local hit = false
                        if step.questID and item.questID and item.questID == step.questID then
                            hit = true
                        end
                        if step.dungeon and step.dungeon.id and item.dungeon == step.dungeon.id then
                            hit = true
                        end
                        if hit then
                            Add(rows, item, item.how == "reward")
                        end
                    end
                end
            end
        end
        route.bisRows[i] = rows
    end
end

function Bis.PlayerHas(itemID)
    if not itemID or itemID == 0 then
        return false
    end
    if GetItemCount and GetItemCount(itemID) > 0 then
        return true
    end
    if GetInventoryItemID then
        for slot = 1, 19 do
            if GetInventoryItemID("player", slot) == itemID then
                return true
            end
        end
    end
    return false
end

function Bis.Line(row)
    local prefix = row.bis and "BiS " or ""
    local slot = row.slot and (row.slot .. ": ") or ""
    if row.reward or row.how == "reward" then
        return prefix .. slot .. row.name .. " — choose this reward"
    end
    if row.how == "drop" then
        return prefix .. slot .. row.name .. " — drop, " .. (row.where or "this dungeon")
    end
    if row.how == "crafted" then
        return prefix .. slot .. row.name .. " — crafted, not this quest"
    end
    return prefix .. slot .. row.name
end
