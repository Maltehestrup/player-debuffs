-- core.lua

-- Check for Ace3
local ace = LibStub("AceAddon-3.0", true)
if not ace then
    print("|cffff0000Player Debuffs:|r This addon requires the Ace3 library. Please install it to use this addon.")
    return
end

-- Initialize the database
if not PlayerDebuffsDB then PlayerDebuffsDB = {} end
if not PlayerDebuffsDB.scale then PlayerDebuffsDB.scale = 1 end
if not PlayerDebuffsDB.priority then PlayerDebuffsDB.priority = {} end
if not PlayerDebuffsDB.priority.magic then PlayerDebuffsDB.priority.magic = 1 end
if not PlayerDebuffsDB.priority.curse then PlayerDebuffsDB.priority.curse = 1 end
if not PlayerDebuffsDB.priority.disease then PlayerDebuffsDB.priority.disease = 1 end
if not PlayerDebuffsDB.priority.poison then PlayerDebuffsDB.priority.poison = 1 end
if not PlayerDebuffsDB.offsetX then PlayerDebuffsDB.offsetX = 0 end
if not PlayerDebuffsDB.offsetY then PlayerDebuffsDB.offsetY = -10 end
if not PlayerDebuffsDB.maxDebuffsPerRow then PlayerDebuffsDB.maxDebuffsPerRow = 5 end

-- Create the main frame
local frame = CreateFrame("Frame", "PlayerDebuffsFrame", UIParent)
frame:SetSize(200, 30)
frame:SetPoint("TOP", PlayerFrame, "BOTTOM", PlayerDebuffsDB.offsetX, PlayerDebuffsDB.offsetY)

-- Create a table to hold the debuff icons
local debuffIcons = {}
local isTesting = false

-- Function to update the debuffs
function UpdateDebuffs()
    -- Clear the existing debuff icons
    for i, icon in ipairs(debuffIcons) do
        icon:Hide()
    end

    frame:SetPoint("TOP", PlayerFrame, "BOTTOM", PlayerDebuffsDB.offsetX, PlayerDebuffsDB.offsetY)

    local debuffs = {}
    if isTesting then
        debuffs = {
            { name = "Magic Debuff", icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain", count = 1, debuffType = "Magic", duration = 10, expirationTime = GetTime() + 10, priority = tonumber(PlayerDebuffsDB.priority.magic) or 1 },
            { name = "Curse Debuff", icon = "Interface\\Icons\\Spell_Shadow_CurseOfTounges", count = 1, debuffType = "Curse", duration = 15, expirationTime = GetTime() + 15, priority = tonumber(PlayerDebuffsDB.priority.curse) or 1 },
            { name = "Disease Debuff", icon = "Interface\\Icons\\Spell_Shadow_CreepingPlague", count = 1, debuffType = "Disease", duration = 20, expirationTime = GetTime() + 20, priority = tonumber(PlayerDebuffsDB.priority.disease) or 1 },
            { name = "Poison Debuff", icon = "Interface\\Icons\\Spell_Nature_Poison", count = 1, debuffType = "Poison", duration = 25, expirationTime = GetTime() + 25, priority = tonumber(PlayerDebuffsDB.priority.poison) or 1 },
            { name = "Magic Debuff", icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain", count = 1, debuffType = "Magic", duration = 10, expirationTime = GetTime() + 10, priority = tonumber(PlayerDebuffsDB.priority.magic) or 1 },
            { name = "Curse Debuff", icon = "Interface\\Icons\\Spell_Shadow_CurseOfTounges", count = 1, debuffType = "Curse", duration = 15, expirationTime = GetTime() + 15, priority = tonumber(PlayerDebuffsDB.priority.curse) or 1 },
            { name = "Disease Debuff", icon = "Interface\\Icons\\Spell_Shadow_CreepingPlague", count = 1, debuffType = "Disease", duration = 20, expirationTime = GetTime() + 20, priority = tonumber(PlayerDebuffsDB.priority.disease) or 1 },
            { name = "Poison Debuff", icon = "Interface\\Icons\\Spell_Nature_Poison", count = 1, debuffType = "Poison", duration = 25, expirationTime = GetTime() + 25, priority = tonumber(PlayerDebuffsDB.priority.poison) or 1 },
        }
    else
        -- Get the player's debuffs
        local i = 1
        while true do
            local name, icon, count, debuffType, duration, expirationTime = UnitDebuff("player", i)
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
                duration = duration,
                expirationTime = expirationTime,
                priority = tonumber(PlayerDebuffsDB.priority[debuffType]) or 10
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
            debuffIcons[i].count:SetPoint("BOTTOMRIGHT", 2, -2)

            debuffIcons[i].cooldown = CreateFrame("Cooldown", "PlayerDebuffsCooldown" .. i, debuffIcons[i], "CooldownFrameTemplate")
            debuffIcons[i].cooldown:SetAllPoints()
            debuffIcons[i].duration = _G[debuffIcons[i].cooldown:GetName() .. "Duration"]
        end

        -- Update the icon's texture, count, and position
        local col = (i - 1) % PlayerDebuffsDB.maxDebuffsPerRow
        local row = math.floor((i - 1) / PlayerDebuffsDB.maxDebuffsPerRow)
        debuffIcons[i].texture:SetTexture(debuff.icon)
        debuffIcons[i].count:SetFont(STANDARD_TEXT_FONT, 12 * PlayerDebuffsDB.scale, "OUTLINE")
        debuffIcons[i].count:SetText(debuff.count > 1 and debuff.count or "")
        debuffIcons[i]:SetSize(30 * PlayerDebuffsDB.scale, 30 * PlayerDebuffsDB.scale)
        debuffIcons[i]:SetPoint("TOPLEFT", col * (35 * PlayerDebuffsDB.scale), row * (-35 * PlayerDebuffsDB.scale))

        if debuff.duration and debuff.expirationTime and debuff.duration > 0 then
            debuffIcons[i].cooldown:SetCooldown(debuff.expirationTime - debuff.duration, debuff.duration)
            debuffIcons[i].cooldown:Show()
            debuffIcons[i].duration:SetFont(STANDARD_TEXT_FONT, 12 * PlayerDebuffsDB.scale, "OUTLINE")
            debuffIcons[i].duration:Show()
        else
            debuffIcons[i].cooldown:Hide()
            debuffIcons[i].duration:Hide()
        end

        debuffIcons[i]:Show()
    end
end

function ShowTestDebuffs()
    isTesting = not isTesting
    UpdateDebuffs()
end

function PlayerDebuffs_IsTesting()
    return isTesting
end

-- Register for events
frame:RegisterEvent("UNIT_AURA")
frame:SetScript("OnEvent", function(self, event, unit, ...)
    if unit == "player" and not isTesting then
        UpdateDebuffs()
    end
end)

-- Initial update
UpdateDebuffs()
