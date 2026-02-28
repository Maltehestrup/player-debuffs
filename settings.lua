-- settings.lua

-- Check for Ace3
local ace = LibStub("AceAddon-3.0", true)
if not ace then
    return
end

-- Create the settings panel
local function CreateSettingsPanel()
    local AceGUI = LibStub("AceGUI-3.0")
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")

    local options = {
        name = "Player Debuffs",
        handler = PlayerDebuffs,
        type = "group",
        args = {
            scale = {
                type = "range",
                name = "Icon Scale",
                desc = "Adjust the size of the debuff icons.",
                min = 0.5,
                max = 2,
                step = 0.1,
                get = function() return PlayerDebuffsDB.scale end,
                set = function(info, value) PlayerDebuffsDB.scale = value; UpdateDebuffs() end,
            },
            offsetX = {
                type = "range",
                name = "X Offset",
                desc = "Adjust the horizontal position of the debuff frame.",
                min = -200,
                max = 200,
                step = 1,
                get = function() return PlayerDebuffsDB.offsetX end,
                set = function(info, value) PlayerDebuffsDB.offsetX = value; UpdateDebuffs() end,
            },
            offsetY = {
                type = "range",
                name = "Y Offset",
                desc = "Adjust the vertical position of the debuff frame.",
                min = -200,
                max = 200,
                step = 1,
                get = function() return PlayerDebuffsDB.offsetY end,
                set = function(info, value) PlayerDebuffsDB.offsetY = value; UpdateDebuffs() end,
            },
            priority = {
                type = "group",
                name = "Debuff Priority",
                desc = "Set the priority of different debuff types.",
                args = {
                    magic = {
                        type = "range",
                        name = "Magic",
                        min = 1,
                        max = 10,
                        step = 1,
                        get = function() return PlayerDebuffsDB.priority.magic end,
                        set = function(info, value) PlayerDebuffsDB.priority.magic = value; UpdateDebuffs() end,
                    },
                    curse = {
                        type = "range",
                        name = "Curse",
                        min = 1,
                        max = 10,
                        step = 1,
                        get = function() return PlayerDebuffsDB.priority.curse end,
                        set = function(info, value) PlayerDebuffsDB.priority.curse = value; UpdateDebuffs() end,
                    },
                    disease = {
                        type = "range",
                        name = "Disease",
                        min = 1,
                        max = 10,
                        step = 1,
                        get = function() return PlayerDebuffsDB.priority.disease end,
                        set = function(info, value) PlayerDebuffsDB.priority.disease = value; UpdateDebuffs() end,
                    },
                    poison = {
                        type = "range",
                        name = "Poison",
                        min = 1,
                        max = 10,
                        step = 1,
                        get = function() return PlayerDebuffsDB.priority.poison end,
                        set = function(info, value) PlayerDebuffsDB.priority.poison = value; UpdateDebuffs() end,
                    },
                },
            },
            test = {
                type = "execute",
                name = "Test",
                desc = "Show a test of the debuff frame.",
                func = function() ShowTestDebuffs() end,
            },
        },
    }

    -- Register the options
    AceConfig:RegisterOptionsTable("PlayerDebuffs", options)

    -- Create the slash command
    SLASH_PLAYERDEBUFFS1 = "/pd"
    SlashCmdList["PLAYERDEBUFFS"] = function()
        AceConfigDialog:Open("PlayerDebuffs")
    end
end

-- Create the settings panel
CreateSettingsPanel()
