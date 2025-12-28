-- CursiveTestFramework.lua
-- In-game testing framework for Cursive DoT tracking addon
-- Usage: /cursivetest help

CursiveTest = CursiveTest or {}

-- ============================================
-- Test 1: Trinket Duration Test
-- ============================================
function CursiveTest:TestTrinketDuration()
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[CursiveTest]|r Eye of Dormant Corruption Test")
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    
    local testCases = {
        {spell = "Corruption", baseDuration = 18, trinketBonus = 3, expected = 21},
        {spell = "Shadow Word: Pain", baseDuration = 24, trinketBonus = 3, expected = 27},
    }
    
    for _, test in ipairs(testCases) do
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  |cFFFFFF00%s:|r", test.spell))
        DEFAULT_CHAT_FRAME:AddMessage(string.format("    Base Duration: %d sec", test.baseDuration))
        DEFAULT_CHAT_FRAME:AddMessage(string.format("    With Trinket: %d sec expected", test.expected))
    end
    
    -- Check if trinket is equipped
    local hasTrinket = false
    for slot = 13, 14 do
        local link = GetInventoryItemLink("player", slot)
        if link then
            local _, _, itemId = string.find(link, "item:(%d+)")
            if itemId and tonumber(itemId) == 55111 then
                hasTrinket = true
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00Trinket EQUIPPED in slot " .. slot .. "|r")
            end
        end
    end
    
    if not hasTrinket then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Trinket NOT equipped|r")
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600IMPORTANT:|r If DoT disappears at 3 sec instead of 0, the bug is present!")
end

-- ============================================
-- Test 2: Base Duration Verification
-- ============================================
function CursiveTest:TestBaseDurations()
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[CursiveTest]|r Base Duration Verification")
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    
    local expectedBase = {
        -- Warlock
        {name = "Corruption", expected = 18, class = "Warlock"},
        {name = "Curse of Agony", expected = 24, class = "Warlock"},
        {name = "Siphon Life", expected = 30, class = "Warlock"},
        {name = "Dark Harvest", expected = 8, class = "Warlock"},
        -- Priest
        {name = "Shadow Word: Pain", expected = 24, class = "Priest"},
        -- Druid
        {name = "Rip (5 CP)", expected = 18, class = "Druid"},
        {name = "Rake", expected = 9, class = "Druid"},
    }
    
    DEFAULT_CHAT_FRAME:AddMessage("Expected Base Durations (without modifiers):")
    DEFAULT_CHAT_FRAME:AddMessage("")
    
    local currentClass = "None"
    for _, spell in ipairs(expectedBase) do
        if spell.class ~= currentClass then
            currentClass = spell.class
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFFFFFF00[%s]|r", currentClass))
        end
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  %s: %d sec", spell.name, spell.expected))
    end
end

-- ============================================
-- Test 3: Rip Combo Point Duration Test
-- ============================================
function CursiveTest:TestRipDuration()
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[CursiveTest]|r Rip Duration Test (Turtle WoW)")
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    
    local expectedDurations = {
        [1] = 10,
        [2] = 12,
        [3] = 14,
        [4] = 16,
        [5] = 18,
    }
    
    DEFAULT_CHAT_FRAME:AddMessage("Rip Duration per Combo Point:")
    DEFAULT_CHAT_FRAME:AddMessage("Formula: Duration = 8 + (CP * 2)")
    DEFAULT_CHAT_FRAME:AddMessage("")
    
    for cp = 1, 5 do
        local calculated = 8 + (cp * 2)
        local expected = expectedDurations[cp]
        local status = (calculated == expected) and "|cFF00FF00OK|r" or "|cFFFF0000ERROR|r"
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  %d CP: %d sec expected, %d sec calculated [%s]", 
            cp, expected, calculated, status))
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("")
    local currentCP = GetComboPoints("player", "target") or 0
    DEFAULT_CHAT_FRAME:AddMessage("Current Combo Points: " .. currentCP)
end

-- ============================================
-- Test 4: Rake Bleed Immunity Test
-- ============================================
function CursiveTest:TestRakeImmunity()
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[CursiveTest]|r Rake Bleed Immunity Test")
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    
    local immuneTypes = {"Elemental", "Undead", "Mechanical"}
    
    DEFAULT_CHAT_FRAME:AddMessage("Bleed-immune Creature Types:")
    for _, ctype in ipairs(immuneTypes) do
        DEFAULT_CHAT_FRAME:AddMessage("  - " .. ctype)
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("")
    
    if UnitExists("target") then
        local targetType = UnitCreatureType("target") or "Unknown"
        local targetName = UnitName("target") or "No Target"
        DEFAULT_CHAT_FRAME:AddMessage(string.format("Current Target: |cFFFFFF00%s|r", targetName))
        DEFAULT_CHAT_FRAME:AddMessage(string.format("Creature Type: |cFFFFFF00%s|r", targetType))
        
        local isImmune = (targetType == "Elemental" or targetType == "Undead" or targetType == "Mechanical")
        if isImmune then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Bleed-Immune: YES - Rake bleed should NOT be tracked|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00Bleed-Immune: NO - Rake bleed can be tracked|r")
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600No target selected.|r")
    end
end

-- ============================================
-- Test 5: Current DoT Status
-- ============================================
function CursiveTest:TestCurrentDoTs()
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[CursiveTest]|r Current DoT Status")
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    
    if not Cursive or not Cursive.curses or not Cursive.curses.guids then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Cursive not loaded or no active DoTs|r")
        return
    end
    
    local hasDoTs = false
    for guid, curseData in pairs(Cursive.curses.guids) do
        for curseName, data in pairs(curseData) do
            hasDoTs = true
            local remaining = Cursive.curses:TimeRemaining(data)
            DEFAULT_CHAT_FRAME:AddMessage(string.format("  |cFFFFFF00%s|r on %s: %.1f sec remaining", 
                curseName, guid, remaining))
        end
    end
    
    if not hasDoTs then
        DEFAULT_CHAT_FRAME:AddMessage("No active DoTs being tracked.")
    end
end

-- ============================================
-- Debug: Talent Info
-- ============================================
function CursiveTest:DebugTalents()
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[CursiveTest]|r Talent Debug (Affliction Tree)")
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    
    for i = 1, 25 do
        local name, _, _, _, points = GetTalentInfo(1, i)
        if name then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("  [%d] %s: %d points", i, name, points or 0))
        end
    end
end

-- ============================================
-- Debug: Exact Duration Values
-- ============================================
function CursiveTest:DebugDuration()
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[CursiveTest]|r Exact Duration Debug")
    DEFAULT_CHAT_FRAME:AddMessage("===========================================")
    
    if not Cursive or not Cursive.curses then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000Cursive not loaded|r")
        return
    end
    
    -- Get tracked spell IDs for current class
    local trackedSpells = Cursive.curses.trackedCurseIds
    if not trackedSpells then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000No tracked spells found|r")
        return
    end
    
    -- Key spells to check (Warlock Affliction)
    local spellsToCheck = {
        {id = 25311, name = "Corruption R7", base = 18},
        {id = 11713, name = "Curse of Agony R6", base = 24},
        {id = 18881, name = "Siphon Life R4", base = 30},
        {id = 52552, name = "Dark Harvest R3", base = 8},
    }
    
    DEFAULT_CHAT_FRAME:AddMessage("")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Spell Durations (Base vs Calculated):|r")
    DEFAULT_CHAT_FRAME:AddMessage("")
    
    for _, spell in ipairs(spellsToCheck) do
        if trackedSpells[spell.id] then
            local calculatedDuration = Cursive.curses:GetCurseDuration(spell.id)
            local storedDuration = trackedSpells[spell.id].duration
            local diff = spell.base - calculatedDuration
            local diffPercent = (diff / spell.base) * 100
            
            DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFFFFFF00%s:|r", spell.name))
            DEFAULT_CHAT_FRAME:AddMessage(string.format("  Base Duration:       %.2f sec", spell.base))
            DEFAULT_CHAT_FRAME:AddMessage(string.format("  Stored Duration:     %.2f sec", storedDuration))
            DEFAULT_CHAT_FRAME:AddMessage(string.format("  Calculated Duration: |cFF00FF00%.2f sec|r", calculatedDuration))
            DEFAULT_CHAT_FRAME:AddMessage(string.format("  Reduction:           %.2f sec (%.1f%%)", diff, diffPercent))
            DEFAULT_CHAT_FRAME:AddMessage("")
        end
    end
    
    -- Show Rapid Deterioration status
    local _, _, _, _, rdPoints = GetTalentInfo(1, 14)
    if rdPoints and rdPoints > 0 then
        local expectedReduction = rdPoints == 1 and 3 or 6
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFFFF6600Rapid Deterioration:|r %d/2 points = %d%% reduction expected", rdPoints, expectedReduction))
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600Rapid Deterioration:|r 0/2 points (no reduction)")
    end
end

-- ============================================
-- Slash Commands (updated)
-- ============================================
SLASH_CURSIVETEST1 = "/cursivetest"
SLASH_CURSIVETEST2 = "/ctest"

SlashCmdList["CURSIVETEST"] = function(msg)
    msg = string.lower(msg or "")
    
    if msg == "" or msg == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("===========================================")
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[CursiveTest]|r Available Tests:")
        DEFAULT_CHAT_FRAME:AddMessage("===========================================")
        DEFAULT_CHAT_FRAME:AddMessage("  /cursivetest all      - Run all tests")
        DEFAULT_CHAT_FRAME:AddMessage("  /cursivetest trinket  - Trinket Duration Test")
        DEFAULT_CHAT_FRAME:AddMessage("  /cursivetest base     - Base Duration Check")
        DEFAULT_CHAT_FRAME:AddMessage("  /cursivetest rip      - Rip Combo Point Test")
        DEFAULT_CHAT_FRAME:AddMessage("  /cursivetest rake     - Rake Immunity Test")
        DEFAULT_CHAT_FRAME:AddMessage("  /cursivetest dots     - Current DoT Status")
        DEFAULT_CHAT_FRAME:AddMessage("  /cursivetest talents  - Debug Talent Info")
        DEFAULT_CHAT_FRAME:AddMessage("  |cFF00FF00/cursivetest duration|r - |cFFFFFF00Exact duration values|r")
        DEFAULT_CHAT_FRAME:AddMessage("")
    elseif msg == "all" then
        CursiveTest:TestTrinketDuration()
        DEFAULT_CHAT_FRAME:AddMessage("")
        CursiveTest:TestBaseDurations()
        DEFAULT_CHAT_FRAME:AddMessage("")
        CursiveTest:TestRipDuration()
        DEFAULT_CHAT_FRAME:AddMessage("")
        CursiveTest:TestRakeImmunity()
    elseif msg == "trinket" then
        CursiveTest:TestTrinketDuration()
    elseif msg == "base" then
        CursiveTest:TestBaseDurations()
    elseif msg == "rip" then
        CursiveTest:TestRipDuration()
    elseif msg == "rake" then
        CursiveTest:TestRakeImmunity()
    elseif msg == "dots" then
        CursiveTest:TestCurrentDoTs()
    elseif msg == "talents" then
        CursiveTest:DebugTalents()
    elseif msg == "duration" then
        CursiveTest:DebugDuration()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[CursiveTest]|r Unknown test. Use /cursivetest help")
    end
end

DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[CursiveTest]|r Framework loaded. Use /cursivetest help")