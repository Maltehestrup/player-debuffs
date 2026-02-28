-- core.lua

-- Check for Ace3
local ace = LibStub("AceAddon-3.0", true)
if not ace then
    print("|cffff0000Player Debuffs:|r This addon requires the Ace3 library. Please install it to use this addon.")
    return
end

-- Initialize the database
if not PlayerDebuffsDB then
    PlayerDebuffsDB = {
        scale = 1,
        priority = {
            magic = 1,
            curse = 1,
            disease = 1,
            poison = 1,
        },
        offsetX = 0,
        offsetY = -10,
    }
end

-- Create the main frame
local frame = CreateFrame("Frame", "PlayerDebuffsFrame", UIParent)
frame:SetSize(200, 30)
frame:SetPoint("TOP", PlayerFrame, "BOTTOM", PlayerDebuffsDB.offsetX, PlayerDebuffsDB.offsetY)

-- Create a table to hold the debuff icons
local debuffIcons = {}
local isTesting = false

-- Function to update the debuffs
function UpdateDebuffs(testDebuffs)
    -- Clear the existing debuff icons
    for i, icon in ipairs(debuffIcons) do
        icon:Hide()
    end

    frame:SetPoint("TOP", PlayerFrame, "BOTTOM", PlayerDebuffsDB.offsetX, PlayerDebuffsDB.offsetY)

    local debuffs
    if testDebuffs then
        debuffs = testDebuffs
    else
        -- Get the player's debuffs
        debuffs = {}
        local i = 1
        while true do
            local name, rank, icon, count, debuffType, duration, timeLeft, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowPersonal, nameplateShowAll = UnitAura("player", i, "HARMFUL")
            if not name then
                break
            end
            print("Found debuff:", name, "type:", debuffType) -- Debugging print
            debuffType = debuffType or "none"
            table.insert(debuffs, {
                name = name,
                icon = icon,
                count = count,
                debuffType = debuffType,
                priority = PlayerDebuffsDB.priority[debuffType] or 10
            })
            i = i + 1
        end
    end

    -- Sort the debuffs by priority
    table.sort(debuffs, function(a, b)
        return a.priority < b.priority
    end)

    -- Create and update the debuff icons
    for i, debuff in ipairs(debuffs) do
        -- Create a new icon if needed
        if not debuffIcons[i] then
            debuffIcons[i] = CreateFrame("Frame", "PlayerDebuffsIcon" .. i, frame)
            debuffIcons[i].texture = debuffIcons[i]:CreateTexture(nil, "BACKGROUND")
            debuffIcons[i].texture:SetAllPoints()
            debuffIcons[i].count = debuffIcons[i]:CreateFontString(nil, "OVERLAY")
            debuffIcons[i].count:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
            debuffIcons[i].count:SetPoint("BOTTOMRIGHT", 2, -2)
        end

        -- Update the icon's texture, count, and position
        debuffIcons[i].texture:SetTexture(debuff.icon)
        debuffIcons[i].count:SetText(debuff.count > 1 and debuff.count or "")
        debuffIcons[i]:SetSize(30 * PlayerDebuffsDB.scale, 30 * PlayerDebuffsDB.scale)
        debuffIcons[i]:SetPoint("LEFT", (i - 1) * (35 * PlayerDebuffsDB.scale), 0)
        debuffIcons[i]:Show()
    end
end

function ShowTestDebuffs()
    if isTesting then
        isTesting = false
        UpdateDebuffs()
    else
        isTesting = true
        local testDebuffs = {
            { name = "Magic Debuff", icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain", count = 1, debuffType = "Magic", priority = PlayerDebuffsDB.priority.magic or 1 },
            { name = "Curse Debuff", icon = "Interface\\Icons\\Spell_Shadow_CurseOfTounges", count = 1, debuffType = "Curse", priority = PlayerDebuffsDB.priority.curse or 1 },
            { name = "Disease Debuff", icon = "Interface\\Icons\\Spell_Shadow_CreepingPlague", count = 1, debuffType = "Disease", priority = PlayerDebuffsDB.priority.disease or 1 },
            { name = "Poison Debuff", icon = "Interface\\Icons\\Spell_Nature_Poison", count = 1, debuffType = "Poison", priority = PlayerDebuffsDB.priority.poison or 1 },
        }
        UpdateDebuffs(testDebuffs)
    end
end

-- Register for events
frame:RegisterEvent("PLAYER_AURAS_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_AURAS_CHANGED" then
        UpdateDebuffs()
    end
end)

-- Initial update
UpdateDebuffs()
