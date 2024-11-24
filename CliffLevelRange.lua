-- AddOn that shows a list of guildies within your level range.

CliffLevelRange = CreateFrame("Button","CliffLevelRange",UIParent)
CliffLevelRange.List = CreateFrame("Frame","CLRL",UIParent)


-- Version from .toc file
CLIFFLEVELRANGE_VERSION = GetAddOnMetadata("CliffLevelRange", "Version") -- Grab version from .toc

CliffLevelRange:RegisterEvent("ADDON_LOADED")
CliffLevelRange:RegisterEvent("CHAT_MSG_SYSTEM")
CliffLevelRange:RegisterEvent("GUILD_ROSTER_UPDATE")
CliffLevelRange:RegisterEvent("PLAYER_LEVEL_UP")
CliffLevelRange:RegisterEvent("PLAYER_LOGIN")

-- Colors
local LIGHTRED             				= "|cffff6060"
local LIGHTBLUE          			 	= "|cff00ccff"
local TORQUISEBLUE	 					= "|cff00C78C"
local SPRINGGREEN	  					= "|cff00FF7F"
local GREENYELLOW    					= "|cffADFF2F"
local BLUE                 				= "|cff0000ff"
local PURPLE		    				= "|cffDA70D6"
local GREEN	        					= "|cff00ff00"
local RED             					= "|cffff0000"
local GOLD            					= "|cffffcc00"
local GOLD2								= "|cffFFC125"
local GRAY           	 				= "|cff888888"
local WHITE           					= "|cffffffff"
local SUBWHITE        					= "|cffbbbbbb"
local MAGENTA         					= "|cffff00ff"
local YELLOW          					= "|cffffff00"
local ORANGE		    				= "|cffFF4500"
local CHOCOLATE							= "|cffCD661D"
local CYAN            					= "|cff00ffff"
local IVORY								= "|cff8B8B83"
local LIGHTYELLOW	    				= "|cffFFFFE0"
local SEXGREEN							= "|cff71C671"
local SEXTEAL		    				= "|cff388E8E"
local SEXPINK		    				= "|cffC67171"
local SEXBLUE		    				= "|cff00E5EE"
local SEXHOTPINK	    				= "|cffFF6EB4"

local HUNTER 							= "|cffABD473"
local WARLOCK 							= "|cff9482C9"
local PRIEST 							= "|cffFFFFFF"
local PALADIN 							= "|cffF58CBA"
local MAGE 								= "|cff69CCFF"
local ROGUE 							= "|cffFFF569"
local DRUID 							= "|cffFF7D0A"
local SHAMAN 							= "|cff0070DD"
local WARRIOR 							= "|cffC79C6E"

local COLOREND 							= "|r"

CLIFFLEVELRANGE_VERSION_MSG = LIGHTBLUE..CLIFFLEVELRANGE_VERSION..COLOREND

if not CliffLevelRange_table then
    CliffLevelRange_table = {}
end

CliffLevelRange_settings = CliffLevelRange_settings or {
    ["pos"] = {
		["y"] = 0,
		["x"] = 0,
	},
}

local function print(msg)
	if msg then
		DEFAULT_CHAT_FRAME:AddMessage(DRUID.."Cliff"..YELLOW.."Level"..GREEN.."Range"..COLOREND.." - "..msg)
	end
end

function CliffLevelRange:GetClassColorForName(class)
	if class == "Warrior" then return WARRIOR
	elseif class == "Hunter" then return HUNTER
	elseif class == "Mage" then return MAGE
	elseif class == "Rogue" then return ROGUE
	elseif class == "Warlock" then return WARLOCK
	elseif class == "Druid" then return DRUID
	elseif class == "Shaman" then return SHAMAN
	elseif class == "Priest" then return PRIEST
	elseif class == "Paladin" then return PALADIN
	end
end

function CliffLevelRange:GetLevelColor(level)
	local colorlevel = GREEN..level
		if tonumber(level) < 11 then 
			colorlevel = GRAY
		elseif tonumber(level) >= 11 and tonumber(level) < 21 then
			colorlevel = WHITE
		elseif tonumber(level) >= 21 and tonumber(level) < 31 then
			colorlevel = GREEN
		elseif tonumber(level) >= 31 and tonumber(level) < 41 then
			colorlevel = YELLOW
		elseif tonumber(level) >= 41 and tonumber(level) < 51 then
			colorlevel = ORANGE
		elseif tonumber(level) >= 51 and tonumber(level) < 60 then
			colorlevel = RED
		elseif tonumber(level) > 59 then
			colorlevel = PURPLE
		end
	return colorlevel
end

function CliffLevelRange:GetLevelDiffColor(playerLevel)
    local myLevel = UnitLevel("player")
    
    local levelDifference = playerLevel - myLevel
    
    if levelDifference == -5 or levelDifference == -4 then
        return GRAY
    elseif levelDifference == -3 or levelDifference == -2 then
        return WHITE
    elseif levelDifference == -1 or levelDifference == 0 or levelDifference == 1 then
        return GREEN
    elseif levelDifference == 2 then
        return YELLOW
    elseif levelDifference == 3 or levelDifference == 4 then
        return ORANGE
    elseif levelDifference == 5 then
        return RED
    end
    
    return RED
end

function CliffLevelRange.List:Gui()
    CliffLevelRange.List.Drag = {}
    
    function CliffLevelRange.List.Drag:StartMoving()
        if IsAltKeyDown() then
            this:StartMoving()
        end
    end

    function CliffLevelRange.List.Drag:StopMovingOrSizing()
        this:StopMovingOrSizing()
        local point, _, _, x, y = this:GetPoint()
        CliffLevelRange_settings.pos = { x = x, y = y }
    end

    local backdrop = {
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        tile="false",
        tileSize="16",
        edgeSize="18",
        insets={ left="5", right="5", top="5", bottom="5" }
    }

    self:SetFrameStrata("BACKGROUND")
    self:SetWidth(330)
    self:SetHeight(200)
    self:SetPoint('TOP', 0, -50)
    self:SetMovable(1)
    self:EnableMouse(1)
    self:RegisterForDrag("LeftButton")
    self:SetBackdrop(backdrop)
    self:SetBackdropColor(0, 0, 0, 1)
    self:SetScale(CliffLevelRange_settings["scale"])
    self:SetScript("OnDragStart", CliffLevelRange.List.Drag.StartMoving)
    self:SetScript("OnDragStop", CliffLevelRange.List.Drag.StopMovingOrSizing)

    self.title = CliffLevelRange.List:CreateFontString(nil, "OVERLAY")
    self.title:SetPoint("TOP", 0, -10)
    self.title:SetFont("Fonts\\FRIZQT__.TTF", 15)
    self.title:SetTextColor(255, 255, 0, 1)
    self.title:SetShadowOffset(2, -2)

    self.total = CliffLevelRange.List:CreateFontString(nil, "OVERLAY")
    self.total:SetPoint("TOPRIGHT", -10, -10)
    self.total:SetFont("Fonts\\FRIZQT__.TTF", 15)
    self.total:SetTextColor(255, 255, 0, 1)
    self.total:SetShadowOffset(2, -2)
    
    local minLevel = math.max(UnitLevel("player") - 5, 1)
    local maxLevel = math.min(UnitLevel("player") + 5, 59)
    local mylvlrange = minLevel .. " - " .. maxLevel
    self.title:SetText(DRUID.."Cliff"..COLOREND.."Level"..GREEN.."Range"..COLOREND..": ("..mylvlrange..")")

    -- scrollframe
    self.ScrollFrame = CreateFrame("ScrollFrame","GuildRangeScrollFrame",self,"UIPanelScrollFrameTemplate")
    self.ScrollFrame:SetPoint("TOPLEFT",self,"TOPLEFT",8, -30)
    self.ScrollFrame:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT", -8, 8)
    self.ScrollFrame:SetFrameStrata("HIGH")

    self.child = CreateFrame("Frame","MyScrollChild",self.ScrollFrame)
    self.child:SetWidth(299)
    self.child:SetHeight(160)

    self.ScrollFrame:SetScrollChild(self.child)

    self.ScrollFrame.ScrollBar = getglobal( "GuildRangeScrollFrameScrollBar" );
    self.ScrollFrame.ScrollBar:ClearAllPoints()
    self.ScrollFrame.ScrollBar:SetPoint("TOPRIGHT", self.ScrollFrame, "TOPRIGHT", 2, -13)
    self.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", self.ScrollFrame, "BOTTOMRIGHT", -2, 15)

    CliffLevelRange.List:Hide()
end

function CliffLevelRange.UpdateScrollFrame()
    local existingButtons = {}

    for _, child in ipairs({CliffLevelRange.List.child:GetChildren()}) do
        existingButtons[child.name] = child
    end

    local yOffset = 0

    for _, playerData in ipairs(CliffLevelRange_table) do
        local name = playerData.name
        local class = playerData.class
        local level = playerData.level
        local zone = playerData.zone

        local existingButton = existingButtons[name]

        if existingButton then
            local currentLevel = existingButton.level
            local currentZone = existingButton.zone
            existingButton:SetPoint("TOP", 0, -yOffset)

            if currentLevel ~= level or currentZone ~= zone then
                existingButton.charText:SetText(CliffLevelRange:GetClassColorForName(class)..name)
                existingButton.zoneText:SetText(LIGHTYELLOW.."Level "..CliffLevelRange:GetLevelDiffColor(level)..level..COLOREND.."\n"..LIGHTYELLOW..zone)
                existingButton.level = level
                existingButton.zone = zone
            end

            yOffset = yOffset + 32

            existingButtons[name] = nil
        else
            local memberButton = CreateFrame("Button", nil, CliffLevelRange.List.child)
            memberButton:SetWidth(CliffLevelRange.List:GetWidth() - 35)
            memberButton:SetHeight(32)
            memberButton:SetPoint("TOP", 0, -yOffset)
            memberButton:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
            memberButton.name = name
            memberButton.level = level
            memberButton.zone = zone

            memberButton:SetScript("OnEnter", function()
                GameTooltip:SetOwner(memberButton, "ANCHOR_CURSOR")
                GameTooltip:SetText(CliffLevelRange:GetClassColorForName(class)..name..COLOREND.." (lvl "..CliffLevelRange:GetLevelDiffColor(level)..level..COLOREND..") is currently in "..LIGHTYELLOW..zone)
                GameTooltip:AddLine("Left-click to whisper.", 255,71,9,2)
                GameTooltip:AddLine("Shift-click to invite to group.", 0.99, 0.99, 0.59,1)
                GameTooltip:Show()
            end)

            memberButton:SetScript("OnLeave", function() 
                GameTooltip:Hide()
            end)

            memberButton:SetScript("OnClick", function()
                if IsShiftKeyDown() then
                    InviteByName(name)
                else
                    ChatFrame_OpenChat("/w "..name .." ", DEFAULT_CHAT_FRAME)
                end
            end)

            local charText = memberButton:CreateFontString(nil, "OVERLAY")
            charText:SetPoint("LEFT", 0, 0)
            charText:SetFont("Fonts\\FRIZQT__.TTF", 12)
            charText:SetTextColor(1, 1, 1, 1)
            charText:SetShadowOffset(2, -2)
            memberButton.charText = charText

            local zoneText = memberButton:CreateFontString(nil, "OVERLAY")
            zoneText:SetPoint("RIGHT", 0, 0)
            zoneText:SetFont("Fonts\\FRIZQT__.TTF", 12)
            zoneText:SetTextColor(1, 1, 1, 1)
            zoneText:SetShadowOffset(2, -2)
            zoneText:SetJustifyH("RIGHT")
            memberButton.zoneText = zoneText 

            memberButton.charText:SetText(CliffLevelRange:GetClassColorForName(class)..name)
            memberButton.zoneText:SetText(LIGHTYELLOW.."Level "..CliffLevelRange:GetLevelDiffColor(level)..level..COLOREND.."\n"..LIGHTYELLOW..zone)

            memberButton:Show()

            yOffset = yOffset + memberButton:GetHeight() + 5
            
        end
    end

    for name, button in pairs(existingButtons) do
        button:Hide()
        button:ClearAllPoints()
        button:SetParent(nil)
    end

    CliffLevelRange.List.ScrollFrame:SetScrollChild(CliffLevelRange.List.child)
end

function CliffLevelRange.UpdateMemberCount()
    local memberCount = 0
    for _, playerData in ipairs(CliffLevelRange_table) do
        memberCount = memberCount + 1
    end

    CliffLevelRange.List.total:SetText("["..GREEN..memberCount..COLOREND.."]")
    CliffLevelRange.List.child:SetHeight(memberCount * 32)
end

local guildMemberNames = {}
function IsWithinRange()
    local numGuildMembers = GetNumGuildMembers()
    local currentGuildMembers = {}

    for i = 1, numGuildMembers do
        local name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(i)

        if name ~= UnitName("player") then
            currentGuildMembers[name] = true
            if online then
                if level >= UnitLevel("player") - 5 and level <= UnitLevel("player") + 5 then
                    CliffLevelRange:AddToTable(name, class, level, zone)
                else
                    CliffLevelRange:RemoveFromTable(name)
                end
            else
                CliffLevelRange:RemoveFromTable(name)
            end
        end
    end

    for name, _ in pairs(guildMemberNames) do
        if not currentGuildMembers[name] then
            CliffLevelRange:RemoveFromTable(name)
        end
    end

    guildMemberNames = currentGuildMembers
end

function CliffLevelRange:RemoveFromTable(name)

    for index, playerData in ipairs(CliffLevelRange_table) do
        if playerData.name == name  then
            table.remove(CliffLevelRange_table, index)
            CliffLevelRange.UpdateMemberCount()
            CliffLevelRange.UpdateScrollFrame()
            return
        end
    end
end

function CliffLevelRange:AddToTable(name, class, level, zone)
    local playerExists = false

    for _, playerData in ipairs(CliffLevelRange_table) do
        if playerData.name == name and playerData.class == class then
            playerExists = true

            playerData.level = level
            playerData.zone = zone
            break
        end
    end

    if not playerExists then
        table.insert(CliffLevelRange_table, {name = name, class = class, level = level, zone = zone})
    end

    CliffLevelRange.UpdateScrollFrame()
    table.sort(CliffLevelRange_table, function(a, b) return a.level > b.level end)
    CliffLevelRange.UpdateMemberCount()
end

function CliffLevelRange:system(msg)
    if string.find(msg,"has come online") then

        IsWithinRange()
        return

    elseif string.find(msg,"has gone offline") then

        IsWithinRange()
        return
    end
end

function CliffLevelRange_Default()
    if CliffLevelRange_settings and CliffLevelRange_settings.pos then
        local position = CliffLevelRange_settings.pos
        CliffLevelRange.List:SetPoint("TOPLEFT", UIParent, "TOPLEFT", position.x, position.y)
    end

    if CliffLevelRange_settings["scale"] == nil then
		CliffLevelRange_settings["scale"] = 1
	end
end

CliffLevelRange:SetScript("OnUpdate", CliffLevelRange.Update)
 
-- onEvent function
function CliffLevelRange:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "CliffLevelRange" then
		print("Loaded!")
		print("Version: "..CLIFFLEVELRANGE_VERSION_MSG)
        print("Hold "..YELLOW.."'Alt'"..COLOREND.." to move List.")

    elseif event == "CHAT_MSG_SYSTEM" then
        CliffLevelRange:system(arg1)

    elseif event == "GUILD_ROSTER_UPDATE" then
        IsWithinRange()

    elseif event == "PLAYER_LOGIN" then
        CliffLevelRange_Default()
        CliffLevelRange.List:Gui()

    elseif event == "PLAYER_LEVEL_UP" then
        local minLevel = math.max(UnitLevel("player") - 5, 1)
        local maxLevel = math.min(UnitLevel("player") + 5, 59)
        local mylvlrange = minLevel .. " - " .. maxLevel
        CliffLevelRange.List.title:SetText(DRUID.."Cliff"..COLOREND.."Level"..GREEN.."Range"..COLOREND..": ("..mylvlrange..")")
    end
end

CliffLevelRange:SetScript("OnEvent", CliffLevelRange.OnEvent)

function CliffLevelRange.slash(arg1)
	if arg1 == nil or arg1 == "" then
        print("Version: "..CLIFFLEVELRANGE_VERSION_MSG)
        print("Hold "..YELLOW.."'Alt'"..COLOREND.." to move List.")
        print("'/clr "..GREEN.."show"..COLOREND.."' - View your level ranged guildmates.")
        print("'/clr "..LIGHTBLUE.."scale"..COLOREND.."' - Scale the list.")
    elseif arg1 == "show" then
        if CliffLevelRange.List:IsVisible() then
            CliffLevelRange.List:Hide()
        else
            CliffLevelRange.List:Show()
        end
    elseif string.sub(arg1, 1, 5) == "scale" then
        local size = string.sub(arg1, 7)
        CliffLevelRange_settings["scale"] = size
		CliffLevelRange.List:SetScale(CliffLevelRange_settings["scale"])
    else
        print("Unknown command. Use '/clr' for help.")
    end
end

SlashCmdList["CLIFFLEVELRANGE_SLASH"] = CliffLevelRange.slash
SLASH_CLIFFLEVELRANGE_SLASH1 = "/clr"