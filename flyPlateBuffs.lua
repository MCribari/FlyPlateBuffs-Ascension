local AddonName, fPB = ...
L = fPB.L

local	C_NamePlate_GetNamePlateForUnit, CreateFrame, UnitDebuff, UnitBuff, UnitName, UnitIsUnit, UnitIsPlayer, UnitPlayerControlled, UnitIsEnemy, UnitIsFriend, GetSpellInfo, table_sort, strmatch, format, wipe, pairs, GetTime, math_floor =
		C_NamePlate.GetNamePlateForUnit, CreateFrame, UnitDebuff, UnitBuff, UnitName, UnitIsUnit, UnitIsPlayer, UnitPlayerControlled, UnitIsEnemy, UnitIsFriend, GetSpellInfo, table.sort, strmatch, format, wipe, pairs, GetTime, math.floor

local defaultSpells1, defaultSpells2 = fPB.defaultSpells1, fPB.defaultSpells2

local LSM = LibStub("LibSharedMedia-3.0")
fPB.LSM = LSM
local MSQ, Group

local config = LibStub("AceConfig-3.0")
local dialog = LibStub("AceConfigDialog-3.0")

fPB.db = {}
local db

local fPBMainOptions
local fPBSpellsList
local fPBProfilesOptions

fPB.chatColor = "|cFFFFA500"
fPB.linkColor = "|cff71d5ff"
local chatColor = fPB.chatColor
local linkColor = fPB.linkColor

local cachedSpells = {}
local PlatesBuffs = {}
local ActiveNameplates = {}

-- Lockouts ID's
local activeInterrupts = {}
local interruptDurations = {
    [26679] =  3, -- Deadly Throw
    [15752] = 10, -- Linken's Boomerang Disarm
    [19244] = 5, -- Spell Lock - Rank 1 (Warlock)
    [19647] = 6, -- Spell Lock - Rank 2 (Warlock)
    [8042] = 2, -- Earth Shock (Shaman)
    [8044] = 2,
    [8045] = 2,
    [8046] = 2,
    [10412] = 2,
    [10413] = 2,
    [10414] = 2,
    [25454] = 2,
    [13491] = 5, -- Iron Knuckles
    [19675] = 4, -- Feral Charge (Druid)
    [2139] = 8, -- Counterspell (Mage)
    [1766] = 5, -- Kick (Rogue)
    [1767] = 5,
    [1768] = 5,
    [1769] = 5,
    [38768] = 5,
    [32748] = 3, -- Deadly Throw
    [6554] = 4, -- Pummel
    [6552] = 4,
    [72] = 6, -- Shield Bash
    [1671] = 6,
    [1672] = 6,
    [29704] = 6,
    [22570] = 3, -- Maim
    [29443] = 10, -- Clutch of Foresight
}

-- AOE ID's
local activeOpenSpells = {}
local openSpellsDurations = {
    [26573] = 8,  -- Consecration
    [1543]  = 20, -- Flare
    [31687] = 45, -- Summon water elem
    [34433] = 15, -- Shadowfiend
}

local DefaultSettings = {
	profile = {
		showDebuffs = 2,		-- 1 = all, 2 = mine + spellList, 3 = only spellList, 4 = only mine, 5 = none
		showBuffs = 3,			-- 1 = all, 2 = mine + spellList, 3 = only spellList, 4 = only mine, 5 = none
		hidePermanent = true,
		notHideOnPersonalResource = true,

		showOnPlayers = true,
		showOnPets = true,
		showOnNPC = true,

		showOnEnemy = true,
		showOnFriend = true,
		showOnNeutral = true,

		showOnlyInCombat = false,
		showUnitInCombat = false,

		parentWorldFrame = false,

		baseWidth = 24,
		baseHeight = 24,
		myScale = 0.2,
		cropTexture = true,

		buffAnchorPoint = "BOTTOM",
		plateAnchorPoint = "TOP",

		xInterval = 4,
		yInterval = 12,

		xOffset = 0,
		yOffset = 4,

		buffPerLine = 6,
		numLines = 3,

		showStdCooldown = true,
		showStdSwipe = false,

		showDuration = true,
		showDecimals = true,
		durationPosition = 1, -- 1 - under, 2 - on icon, 3 - above icon
		font = "Friz Quadrata TT", --durationFont
		durationSize = 10,
		colorTransition = true,
		colorSingle = {1.0,1.0,1.0},

		stackPosition = 1,  -- 1 - on icon, 2 - under, 3 - above icon
		stackFont = "Friz Quadrata TT",
		stackSize = 10,
		stackColor = {1.0,1.0,1.0},

		blinkTimeleft = 0.2,

		borderStyle = 1,	-- 1 = \\texture\\border.tga, 2 = Blizzard, 3 = none
		colorizeBorder = true,
		colorTypes = {
			Magic 	= {0.20,0.60,1.00},
			Curse 	= {0.60,0.00,1.00},
			Disease = {0.60,0.40,0},
			Poison 	= {0.00,0.60,0},
			none 	= {0.80,0,   0},
			Buff 	= {0.00,1.00,0},
		},

		disableSort = false,
		sortMode = {
			"my", -- [1]
			"expiration", -- [2]
			"disable", -- [3]
			"disable", -- [4]
		},

		Spells = {},
		ignoredDefaultSpells = {},

		showSpellID = false,
		
		-- lockouts options
		enableInterruptIcons = true,
		enableOpenIcons = false,
	},
}

do --add default spells
for i=1, #defaultSpells1 do
	local spellID = defaultSpells1[i]
	local name = GetSpellInfo(spellID)
	if name then
		DefaultSettings.profile.Spells[spellID] = {
			name = name,
			spellID = spellID,
			scale = 1,
			durationSize = 30,
			show = 1,
			stackSize = 18,
		}
	end
end

for i=1, #defaultSpells2 do
	local spellID = defaultSpells2[i]
	local name = GetSpellInfo(spellID)
	if name then
		DefaultSettings.profile.Spells[spellID] = {
			name = name,
			spellID = spellID,
			scale = 1,
			durationSize = 14,
			show = 1,
			stackSize = 14,
		}
	end
end

end

--timeIntervals
local minute, hour, day = 60, 3600, 86400
local aboutMinute, aboutHour, aboutDay = 59.5, 60 * 59.5, 3600 * 23.5

local function round(x) return floor(x + 0.5) end

local function FormatTime(seconds)
	if seconds < 1 and db.showDecimals then
		return "%.1f", seconds
	elseif seconds < aboutMinute then
		local seconds = round(seconds)
		return seconds ~= 0 and seconds or ""
	elseif seconds < aboutHour then
		return "%dm", round(seconds/minute)
	elseif seconds < aboutDay then
		return "%dh", round(seconds/hour)
	else
		return "%dd", round(seconds/day)
	end
end

local function GetColorByTime(current, max)
    if max == 0 then max = 1 end
    local timeLeft = current
    local red, green, blue = 1, 1, 1

    if timeLeft <= 1 then
        red = 1
        green = timeLeft
        blue = timeLeft
    end

    return red, green, blue
end


local function SortFunc(a,b)
	local i = 1
	while db.sortMode[i] do
		local mode, rev = db.sortMode[i],db.sortMode[i+0.5]
		if mode ~= "disable" and a[mode] ~= b[mode] then
			if mode == "my" and not rev then
				return (a.my and 1 or 0) > (b.my and 1 or 0)
			elseif mode == "my" and rev then
				return (a.my and 1 or 0) < (b.my and 1 or 0)
			elseif mode == "expiration" and not rev then
				return (a.expiration > 0 and a.expiration or 5000000) < (b.expiration > 0 and b.expiration or 5000000)
			elseif mode == "expiration" and rev then
				return (a.expiration > 0 and a.expiration or 5000000) > (b.expiration > 0 and b.expiration or 5000000)
			elseif (mode == "type" or mode == "scale") and not rev then
				return a[mode] > b[mode]
			else
				return a[mode] < b[mode]
			end
		end
		i = i+1
	end
end

local function DrawOnPlate(frame)

	if not (#frame.fPBiconsFrame.iconsFrame > 0) then return end

	local maxWidth = 0
	local sumHeight = 0

	local buffIcon = frame.fPBiconsFrame.iconsFrame

	local breaked = false
	for l = 1, db.numLines do
		if breaked then break end

		local lineWidth = 0
		local lineHeight = 0

		for k = 1, db.buffPerLine do

			local i = db.buffPerLine*(l-1)+k
			if not buffIcon[i] or not buffIcon[i]:IsShown() then breaked = true; break end
			buffIcon[i]:ClearAllPoints()
			if l == 1 and k == 1 then
				buffIcon[i]:SetPoint("BOTTOMLEFT", frame.fPBiconsFrame, "BOTTOMLEFT", 0, 0)
			elseif k == 1 then
				buffIcon[i]:SetPoint("BOTTOMLEFT", buffIcon[i-db.buffPerLine], "TOPLEFT", 0, db.yInterval)
			else
				buffIcon[i]:SetPoint("BOTTOMLEFT", buffIcon[i-1], "BOTTOMRIGHT", db.xInterval, 0)
			end

			lineWidth = lineWidth + buffIcon[i].width + db.xInterval
			lineHeight = (buffIcon[i].height > lineHeight) and buffIcon[i].height or lineHeight
		end
		maxWidth = max(maxWidth, lineWidth)
		sumHeight = sumHeight + lineHeight + db.yInterval
	end
	if #PlatesBuffs[frame] > db.numLines * db.buffPerLine then
		for i = db.numLines * db.buffPerLine + 1, #PlatesBuffs[frame] do
			buffIcon[i]:Hide()
		end
	end
	frame.fPBiconsFrame:SetWidth(maxWidth-db.xInterval)
	frame.fPBiconsFrame:SetHeight(sumHeight - db.yInterval)
	frame.fPBiconsFrame:ClearAllPoints()
	frame.fPBiconsFrame:SetPoint(db.buffAnchorPoint,frame,db.plateAnchorPoint,db.xOffset,db.yOffset)
	if MSQ then
		Group:ReSkin()
	end
end

local function AddBuff(frame, type, icon, stack, debufftype, duration, expiration, my, id, scale, durationSize, stackSize)
	if not PlatesBuffs[frame] then PlatesBuffs[frame] = {} end
	PlatesBuffs[frame][#PlatesBuffs[frame] + 1] = {
		type = type,
		icon = icon,
		stack = stack,
		debufftype = debufftype,
		duration = duration,
		expiration = expiration,
		scale = (my and db.myScale + 1 or 1) * (scale or 1),
		durationSize = durationSize,
		stackSize = stackSize,
		id = id,
		my = my, -- sorting
	}
end

local function FilterBuffs(isAlly, frame, type, name, icon, stack, debufftype, duration, expiration, caster, spellID, id)
	if type == "HARMFUL" and db.showDebuffs == 5 then return end
	if type == "HELPFUL" and db.showBuffs == 5 then return end

	local Spells = db.Spells
	local listedSpell
	local my = caster == "player"
	local cachedID = cachedSpells[name]

	if Spells[spellID] and not db.ignoredDefaultSpells[spellID] then
		listedSpell = Spells[spellID]
	elseif cachedID then
		if cachedID == "noid" then
			listedSpell = Spells[name]
		else
			listedSpell = Spells[cachedID]
		end
	end

	if not listedSpell then
		if db.hidePermanent and duration == 0 then
			return
		end
		if (type == "HARMFUL" and (db.showDebuffs == 1 or ((db.showDebuffs == 2 or db.showDebuffs == 4) and my)))
		or (type == "HELPFUL"   and (db.showBuffs   == 1 or ((db.showBuffs   == 2 or db.showBuffs   == 4) and my))) then
			AddBuff(frame, type, icon, stack, debufftype, duration, expiration, my, id)
			return
		else
			return
		end
	else
		if (type == "HARMFUL" and (db.showDebuffs == 4 and not my))
		or (type == "HELPFUL" and (db.showBuffs == 4 and not my)) then
			return
		end
		if(listedSpell.show == 1)
		or(listedSpell.show == 2 and my)
		or(listedSpell.show == 4 and isAlly)
		or(listedSpell.show == 5 and not isAlly) then
			AddBuff(frame, type, icon, stack, debufftype, duration, expiration, my, id, listedSpell.scale, listedSpell.durationSize, listedSpell.stackSize)
			return
		end
	end
end

local function ScanUnitBuffs(nameplateID, frame)

	if PlatesBuffs[frame] then
		wipe(PlatesBuffs[frame])
	end
	local isAlly = UnitIsFriend(nameplateID,"player")
	local id = 1
	while UnitDebuff(nameplateID,id) do
		local name, rank, icon, stack, debufftype, duration, expiration, caster, _, _, spellID = UnitDebuff(nameplateID, id)
		FilterBuffs(isAlly, frame, "HARMFUL", name, icon, stack, debufftype, duration, expiration, caster, spellID, id)
		id = id + 1
	end

	id = 1
	while UnitBuff(nameplateID,id) do
		local name, rank, icon, stack, debufftype, duration, expiration, caster, _, _, spellID = UnitBuff(nameplateID, id)
		FilterBuffs(isAlly, frame, "HELPFUL", name, icon, stack, debufftype, duration, expiration, caster, spellID, id)
		id = id + 1
	end
	
	-- Show active interrupt
	if db.enableInterruptIcons then
		local guid = UnitGUID(nameplateID)
		if guid and activeInterrupts[guid] then
			local intData = activeInterrupts[guid]
			local remaining = intData.expiration - GetTime()
			if remaining > 0 then
				AddBuff(
					frame,
					"HARMFUL",
					intData.icon,
					1,
					nil,
					intData.duration,
					intData.expiration,
					intData.isMine,
					intData.spellID
				)
			else
				activeInterrupts[guid] = nil
			end
		end
	end
	
	-- Show active AOE
	if db.enableOpenIcons then
		local guid = UnitGUID(nameplateID)
		if guid and activeOpenSpells[guid] then
			local data = activeOpenSpells[guid]
			local remaining = data.expiration - GetTime()
			if remaining > 0 then
				AddBuff(
					frame,
					"HARMFUL",
					data.icon,
					1,
					nil,
					data.duration,
					data.expiration,
					data.isMine,
					data.spellID
				)
			else
				activeOpenSpells[guid] = nil
			end
		end
	end
	-- ====================================================
end

local function FilterUnits(nameplateID)

	if db.showOnlyInCombat and not UnitAffectingCombat("player") then return true end
	if db.showUnitInCombat and not UnitAffectingCombat(nameplateID) then return true end

	if UnitIsUnit(nameplateID,"player") then return true end
	if UnitIsPlayer(nameplateID) and not db.showOnPlayers then return true end
	if UnitPlayerControlled(nameplateID) and not UnitIsPlayer(nameplateID) and not db.showOnPets then return true end
	if not UnitPlayerControlled(nameplateID) and not UnitIsPlayer(nameplateID) and not db.showOnNPC then return true end
	if UnitIsEnemy(nameplateID,"player") and not db.showOnEnemy then return true end
	if UnitIsFriend(nameplateID,"player") and not db.showOnFriend then return true end
	if not UnitIsFriend(nameplateID,"player") and not UnitIsEnemy(nameplateID,"player") and not db.showOnNeutral then return true end

	return false
end

local total = 0
local function iconOnUpdate(self, elapsed)
	total = total + elapsed
	if total > 0 then
		total = 0
		if self.expiration and self.expiration > 0 then
			local timeLeft = self.expiration - GetTime()
			if timeLeft < 0 then
				local frame = self:GetParent():GetParent()
				if frame and frame.namePlateUnitToken then
					self:Hide()
					UpdateUnitAuras(frame.namePlateUnitToken)
				end
				return
			end
			if db.showDuration then
				self.durationtext:SetFormattedText(FormatTime(timeLeft))
				if db.colorTransition then
					self.durationtext:SetTextColor(GetColorByTime(timeLeft,self.duration))
				end
				if db.durationPosition == 1 or db.durationPosition == 3 then
					self.durationBg:SetWidth(self.durationtext:GetStringWidth())
					self.durationBg:SetHeight(self.durationtext:GetStringHeight())
				end
			end
			if (timeLeft / (self.duration + 0.01) ) < db.blinkTimeleft and timeLeft < 60 then
				local f = GetTime() % 1
				if f > 0.5 then
					f = 1 - f
				end
				self:SetAlpha(math.min(math.max(f * 3, 0), 1))
			end
		end
	end
end
local function GetTexCoordFromSize(frame,size,size2)
	local arg = size/size2
	local abj
	if arg > 1 then
		abj = 1/size*((size-size2)/2)

		frame:SetTexCoord(0 ,1,(0+abj),(1-abj))
	elseif arg < 1 then
		abj = 1/size2*((size2-size)/2)

		frame:SetTexCoord((0+abj),(1-abj),0,1)
	else
		frame:SetTexCoord(0, 1, 0, 1)
	end
end
local function UpdateBuffIcon(self)

	self:SetAlpha(1)
	self.stacktext:Hide()
	self.border:Hide()
	self.cooldown:Hide()
	self.durationtext:Hide()
	self.durationBg:Hide()
	self.stackBg:Hide()

	self:SetWidth(self.width)
	self:SetHeight(self.height)

	self.texture:SetTexture(self.icon)
	if db.cropTexture then
		GetTexCoordFromSize(self.texture,self.width,self.height)
	else
		self.texture:SetTexCoord(0, 1, 0, 1)
	end

	if db.borderStyle ~= 3 then
		local color
		if self.type == "HELPFUL" then
			color = db.colorTypes.Buff
		else
			if db.colorizeBorder then
				color = self.debufftype and db.colorTypes[self.debufftype] or db.colorTypes.none
			else
				color = db.colorTypes.none
			end
		end
		self.border:SetVertexColor(color[1], color[2], color[3])
		self.border:Show()
	end

	if db.showDuration and self.expiration > 0 then
		if db.durationPosition == 1 or db.durationPosition == 3 then
			self.durationtext:SetFont(fPB.font, (self.durationSize or db.durationSize), "NORMAL")
			self.durationBg:Show()
		else
			self.durationtext:SetFont(fPB.font, (self.durationSize or db.durationSize), "OUTLINE")
		end
		self.durationtext:Show()
	end
	if self.stack > 1 then
		self.stacktext:SetText(tostring(self.stack))
		if db.stackPosition == 2 or db.stackPosition == 3 then
			self.stacktext:SetFont(fPB.stackFont, (self.stackSize or db.stackSize), "NORMAL")
			self.stackBg:SetWidth(self.stacktext:GetStringWidth())
			self.stackBg:SetHeight(self.stacktext:GetStringHeight())
			self.stackBg:Show()
		else
			self.stacktext:SetFont(fPB.stackFont, (self.stackSize or db.stackSize), "OUTLINE")
		end
		self.stacktext:Show()
	end
end
local function UpdateBuffIconOptions(self)
	self.texture:SetAllPoints(self)

	self.border:SetAllPoints(self)
	if db.borderStyle == 1 then
		self.border:SetTexture("Interface\\Addons\\flyPlateBuffs\\texture\\border.tga")
		self.border:SetTexCoord(0.08,0.08, 0.08,0.92, 0.92,0.08, 0.92,0.92)
	elseif db.borderStyle == 2 then
		self.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
		self.border:SetTexCoord(0.296875,0.5703125,0,0.515625)
	end

	if db.showDuration then
		self.durationtext:ClearAllPoints()
		self.durationBg:ClearAllPoints()
		if db.durationPosition == 1 then
			self.durationtext:SetFont(fPB.font, (self.durationSize or db.durationSize), "NORMAL")
			self.durationtext:SetPoint("TOP", self, "BOTTOM", 0, -1)
			self.durationBg:SetPoint("CENTER", self.durationtext)
		elseif db.durationPosition == 3 then
			self.durationtext:SetFont(fPB.font, (self.durationSize or db.durationSize), "NORMAL")
			self.durationtext:SetPoint("BOTTOM", self, "TOP", 0, 1)
			self.durationBg:SetPoint("CENTER", self.durationtext)
		else
			self.durationtext:SetFont(fPB.font, (self.durationSize or db.durationSize), "OUTLINE")
			self.durationtext:SetPoint("CENTER", self, "CENTER", 0, 0)
		end
		if not colorTransition then
			self.durationtext:SetTextColor(db.colorSingle[1],db.colorSingle[2],db.colorSingle[3],1)
		end
	end

	self.stacktext:ClearAllPoints()
	self.stackBg:ClearAllPoints()
	self.stacktext:SetTextColor(db.stackColor[1],db.stackColor[2],db.stackColor[3],1)
	if db.stackPosition == 1 then
		self.stacktext:SetFont(fPB.stackFont, (self.stackSize or db.stackSize), "OUTLINE")
		self.stacktext:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 3)
	elseif db.stackPosition == 2 then
		self.stacktext:SetFont(fPB.stackFont, (self.stackSize or db.stackSize), "NORMAL")
		self.stacktext:SetPoint("TOP", self, "BOTTOM", 0, -1)
		self.stackBg:SetPoint("CENTER", self.stacktext)
	else
		self.stacktext:SetFont(fPB.stackFont, (self.stackSize or db.stackSize), "NORMAL")
		self.stacktext:SetPoint("BOTTOM", self, "TOP", 0, 1)
		self.stackBg:SetPoint("CENTER", self.stacktext)
	end

	self:EnableMouse(false)

end
local function iconOnHide(self)
	self.stacktext:Hide()
	self.border:Hide()
	self.cooldown:Hide()
	self.durationtext:Hide()
	self.durationBg:Hide()
	self.stackBg:Hide()
end
local function CreateBuffIcon(frame,i)
	frame.fPBiconsFrame.iconsFrame[i] = CreateFrame("Button")
	frame.fPBiconsFrame.iconsFrame[i]:SetParent(frame.fPBiconsFrame)
	local buffIcon = frame.fPBiconsFrame.iconsFrame[i]

	buffIcon.texture = buffIcon:CreateTexture(nil, "BACKGROUND")

	buffIcon.border = buffIcon:CreateTexture(nil,"BORDER")

	buffIcon.cooldown = CreateFrame("Cooldown", nil, buffIcon, "CooldownFrameTemplate")
	buffIcon.cooldown:SetReverse(true)
	buffIcon.cooldown:SetDrawEdge(false)

	buffIcon.durationtext = buffIcon:CreateFontString(nil, "ARTWORK")

	buffIcon.durationBg = buffIcon:CreateTexture(nil,"BORDER")
	buffIcon.durationBg:SetVertexColor(0,0,0,.75)

	buffIcon.stacktext = buffIcon:CreateFontString(nil, "ARTWORK")

	buffIcon.stackBg = buffIcon:CreateTexture(nil,"BORDER")
	buffIcon.stackBg:SetVertexColor(0,0,0,.75)

	UpdateBuffIconOptions(buffIcon)

	buffIcon.stacktext:Hide()
	buffIcon.border:Hide()
	buffIcon.cooldown:Hide()
	buffIcon.durationtext:Hide()
	buffIcon.durationBg:Hide()
	buffIcon.stackBg:Hide()

	buffIcon:SetScript("OnHide", iconOnHide)
	buffIcon:SetScript("OnUpdate", iconOnUpdate)

	if MSQ then
		Group:AddButton(buffIcon,{
			Icon = buffIcon.texture,
			Cooldown = buffIcon.cooldown,
			Normal = buffIcon.border,
			Count = false,
			Duration = false,
			FloatingBG = false,
			Flash = false,
			Pushed = false,
			Disabled = false,
			Checked = false,
			Border = false,
			AutoCastable = false,
			Highlight = false,
			HotKey = false,
			Name = false,
			AutoCast = false,
		})
	end
end

local function UpdateUnitAuras(nameplateID,updateOptions)
	if not nameplateID then return end
	
	local frame = C_NamePlate_GetNamePlateForUnit(nameplateID)
	if not frame then return end

	if FilterUnits(nameplateID) then
		if frame.fPBiconsFrame then
			frame.fPBiconsFrame:Hide()
		end
		return
	end

	ScanUnitBuffs(nameplateID, frame)
	if not PlatesBuffs[frame] then
		if frame.fPBiconsFrame then
			frame.fPBiconsFrame:Hide()
		end
		return
	end
	if not db.disableSort then
		table_sort(PlatesBuffs[frame],SortFunc)
	end

	if not frame.fPBiconsFrame then
		frame.fPBiconsFrame = CreateFrame("Frame")
		local parent = db.parentWorldFrame and WorldFrame
		if not parent then
			parent = frame
		end
		frame.fPBiconsFrame:SetParent(parent)
	end
	if not frame.fPBiconsFrame.iconsFrame then
		frame.fPBiconsFrame.iconsFrame = {}
	end



	for i = 1, #PlatesBuffs[frame] do
		if not frame.fPBiconsFrame.iconsFrame[i] then
			CreateBuffIcon(frame,i)
		end

		local buff = PlatesBuffs[frame][i]
		local buffIcon = frame.fPBiconsFrame.iconsFrame[i]
		buffIcon.type = buff.type
		buffIcon.icon = buff.icon
		buffIcon.stack = buff.stack
		buffIcon.debufftype = buff.debufftype
		buffIcon.duration = buff.duration
		buffIcon.expiration = buff.expiration
		buffIcon.id = buff.id
		buffIcon.durationSize = buff.durationSize
		buffIcon.stackSize = buff.stackSize
		buffIcon.width = db.baseWidth * buff.scale
		buffIcon.height = db.baseHeight * buff.scale
		if updateOptions then
			UpdateBuffIconOptions(buffIcon)
		end
		UpdateBuffIcon(buffIcon)
		buffIcon:Show()
	end
	frame.fPBiconsFrame:Show()

	if #frame.fPBiconsFrame.iconsFrame > #PlatesBuffs[frame] then
		for i = #PlatesBuffs[frame]+1, #frame.fPBiconsFrame.iconsFrame do
			if frame.fPBiconsFrame.iconsFrame[i] then
				frame.fPBiconsFrame.iconsFrame[i]:Hide()
			end
		end
	end

	DrawOnPlate(frame)
end

function fPB.UpdateAllNameplates(updateOptions)
	for unitToken, _ in pairs(ActiveNameplates) do
		if unitToken then
			UpdateUnitAuras(unitToken, updateOptions)
		end
	end
end
local UpdateAllNameplates = fPB.UpdateAllNameplates

local function Nameplate_Added(...)
	local nameplateID = ...
	if not nameplateID then return end
	
	ActiveNameplates[nameplateID] = true
	
	local frame = C_NamePlate_GetNamePlateForUnit(nameplateID)
	if frame and frame.BuffFrame then
		if db.notHideOnPersonalResource and UnitIsUnit(nameplateID,"player") then
			frame.BuffFrame:SetAlpha(1)
		else
			frame.BuffFrame:SetAlpha(0)
		end
	end

	UpdateUnitAuras(nameplateID)
end
local function Nameplate_Removed(...)
	local nameplateID = ...
	if not nameplateID then return end
	
	ActiveNameplates[nameplateID] = nil
	
	local frame = C_NamePlate_GetNamePlateForUnit(nameplateID)

	if frame and frame.fPBiconsFrame then
		frame.fPBiconsFrame:Hide()
	end
	if frame and PlatesBuffs[frame] then
		PlatesBuffs[frame] = nil
	end
	
	local guid = UnitGUID(nameplateID)
	if guid then
		activeInterrupts[guid] = nil
		activeOpenSpells[guid] = nil
	end
	-- ================================================================
end

local function FixSpells()
	for spell,s in pairs(db.Spells) do
		if not s.name then
			local name
			local spellID = tonumber(spell) and tonumber(spell) or spell.spellID
			if spellID then
				name = GetSpellInfo(spellID)
			else
				name = tostring(spell)
			end
			db.Spells[spell].name = name
		end
	end
end
function fPB.CacheSpells()
	cachedSpells = {}
	for spell,s in pairs(db.Spells) do
		if not s.checkID and not db.ignoredDefaultSpells[spell] and s.name then
			if s.spellID then
				cachedSpells[s.name] = s.spellID
			else
				cachedSpells[s.name] = "noid"
			end
		end
	end
end
local CacheSpells = fPB.CacheSpells

function fPB.AddNewSpell(spell)
	local defaultSpell
	if db.ignoredDefaultSpells[spell] then
		db.ignoredDefaultSpells[spell] = nil
		defaultSpell = true
	end
	local spellID = tonumber(spell)
	if db.Spells[spell] and not defaultSpell then
		if spellID then
			DEFAULT_CHAT_FRAME:AddMessage(chatColor..L["Spell with this ID is already in the list. Its name is "]..linkColor.."|Hspell:"..spellID.."|h["..GetSpellInfo(spellID).."]|h|r")
			return
		else
			DEFAULT_CHAT_FRAME:AddMessage(spell..chatColor..L[" already in the list."].."|r")
			return
		end
	end
	local name = GetSpellInfo(spellID)
	if spellID and name then
		if not db.Spells[spellID] then
			db.Spells[spellID] = {
				show = 1,
				name = name,
				spellID = spellID,
				scale = 1,
				stackSize = db.stackSize,
				durationSize = db.durationSize,
			}
		end
	else
		db.Spells[spell] = {
			show = 1,
			name = spell,
			scale = 1,
			stackSize = db.stackSize,
			durationSize = db.durationSize,
		}
	end

	CacheSpells()
	fPB.BuildSpellList()
	UpdateAllNameplates(true)
end
function fPB.RemoveSpell(spell)
	if DefaultSettings.profile.Spells[spell] then
		db.ignoredDefaultSpells[spell] = true
	end
	db.Spells[spell] = nil
	CacheSpells()
	fPB.BuildSpellList()
	UpdateAllNameplates(true)
end
function fPB.ChangeSpellID(oldID, newID)
	if db.Spells[newID] then
		DEFAULT_CHAT_FRAME:AddMessage(chatColor..L["Spell with this ID is already in the list. Its name is "]..linkColor.."|Hspell:"..newID.."|h["..GetSpellInfo(newID).."]|h|r")
		return
	end
	db.Spells[newID] = {}
	for k,v in pairs(db.Spells[oldID]) do
		db.Spells[newID][k] = v
		db.Spells[newID].spellID = newID
	end
	fPB.RemoveSpell(oldID)
	DEFAULT_CHAT_FRAME:AddMessage(GetSpellInfo(newID)..chatColor..L[" ID changed "].."|r"..(tonumber(oldID) or "nil")..chatColor.." -> |r"..newID)
	UpdateAllNameplates(true)
	fPB.BuildSpellList()
end

local function ConvertDBto2()
	local temp
	for _,p in pairs(flyPlateBuffsDB.profiles) do
		if p.Spells then
			temp = {}
			for n,s in pairs(p.Spells) do
				local spellID = s.spellID
				if not spellID then
					for i=1, #defaultSpells1 do
						if n == GetSpellInfo(defaultSpells1[i]) then
							spellID = defaultSpells1[i]
							break
						end
					end
				end
				if not spellID then
					for i=1, #defaultSpells2 do
						if n == GetSpellInfo(defaultSpells2[i]) then
							spellID = defaultSpells2[i]
							break
						end
					end
				end
				local spell = spellID and spellID or n
				if spell then
					temp[spell] = {}
					for k,v in pairs(s) do
						temp[spell][k] = v
					end
					temp[spell].name = GetSpellInfo(spellID) and GetSpellInfo(spellID) or n
				end
			end
			p.Spells = temp
			temp = nil
		end
		if p.ignoredDefaultSpells then
			temp = {}
			for n,v in pairs(p.ignoredDefaultSpells) do
				local spellID
				for i=1, #defaultSpells1 do
					if n == GetSpellInfo(defaultSpells1[i]) then
						spellID = defaultSpells1[i]
						break
					end
				end
				if not spellID then
					for i=1, #defaultSpells2 do
						if n == GetSpellInfo(defaultSpells2[i]) then
							spellID = defaultSpells2[i]
							break
						end
					end
				end
				if spellID then
					temp[spellID] = true
				end
			end
			p.ignoredDefaultSpells = temp
			temp = nil
		end
	end
	flyPlateBuffsDB.version = 2
end
function fPB.OnProfileChanged()
	db = fPB.db.profile
	fPB.OptionsOnEnable()
	UpdateAllNameplates(true)
end
local function Initialize()
	if flyPlateBuffsDB and (not flyPlateBuffsDB.version or flyPlateBuffsDB.version < 2) then
		ConvertDBto2()
	end

	fPB.db = LibStub("AceDB-3.0"):New("flyPlateBuffsDB", DefaultSettings, true)
	fPB.db.RegisterCallback(fPB, "OnProfileChanged", "OnProfileChanged")
	fPB.db.RegisterCallback(fPB, "OnProfileCopied", "OnProfileChanged")
	fPB.db.RegisterCallback(fPB, "OnProfileReset", "OnProfileChanged")

	db = fPB.db.profile
	fPB.font = fPB.LSM:Fetch("font", db.font)
	fPB.stackFont = fPB.LSM:Fetch("font", db.stackFont)
	FixSpells()
	CacheSpells()

	config:RegisterOptionsTable(AddonName, fPB.MainOptionTable)
	fPBMainOptions = dialog:AddToBlizOptions(AddonName, AddonName)

	config:RegisterOptionsTable(AddonName.." Spells", fPB.SpellsTable)
	fPBSpellsList = dialog:AddToBlizOptions(AddonName.." Spells", L["Specific spells"], AddonName)

	config:RegisterOptionsTable(AddonName.." Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(fPB.db))
	fPBProfilesOptions = dialog:AddToBlizOptions(AddonName.." Profiles", L["Profiles"], AddonName)

	SLASH_FLYPLATEBUFFS1, SLASH_FLYPLATEBUFFS2 = "/fpb", "/pb"
	function SlashCmdList.FLYPLATEBUFFS(msg, editBox)
		InterfaceOptionsFrame_OpenToCategory(fPBMainOptions)
		InterfaceOptionsFrame_OpenToCategory(fPBSpellsList)
		InterfaceOptionsFrame_OpenToCategory(fPBMainOptions)
	end
end

function fPB.RegisterCombat()
	fPB.Events:RegisterEvent("PLAYER_REGEN_DISABLED")
	fPB.Events:RegisterEvent("PLAYER_REGEN_ENABLED")
end
function fPB.UnregisterCombat()
	fPB.Events:UnregisterEvent("PLAYER_REGEN_DISABLED")
	fPB.Events:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

fPB.Events = CreateFrame("Frame")
fPB.Events:RegisterEvent("ADDON_LOADED")
fPB.Events:RegisterEvent("PLAYER_LOGIN")
-- ====== NUEVO: Registrar COMBAT_LOG para interrupciones ======
fPB.Events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
-- =============================================================

fPB.Events:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" and (...) == AddonName then
		Initialize()
	elseif event == "PLAYER_LOGIN" then
		fPB.OptionsOnEnable()
		if db.showSpellID then fPB.ShowSpellID() end
		MSQ = LibStub("Masque", true)
		if MSQ then
			Group = MSQ:Group(AddonName)
			MSQ:Register(AddonName, function(addon, group, skinId, gloss, backdrop, colors, disabled)
				if disabled then
					UpdateAllNameplates(true)
				end
			end)
		end

		fPB.Events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
		fPB.Events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

		if db.showOnlyInCombat then
			fPB.RegisterCombat()
		else
			fPB.Events:RegisterEvent("UNIT_AURA")
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		fPB.Events:RegisterEvent("UNIT_AURA")
		UpdateAllNameplates()
	elseif event == "PLAYER_REGEN_ENABLED" then
		fPB.Events:UnregisterEvent("UNIT_AURA")
		UpdateAllNameplates()
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
		
		-- Detect
		if db.enableInterruptIcons and subevent == "SPELL_INTERRUPT" then
			local spellID, spellName, spellSchool, extraSpellID, extraSpellName = select(12, CombatLogGetCurrentEventInfo())
			
			local duration = interruptDurations[spellID] or 4
			local now = GetTime()
			local icon = select(3, GetSpellInfo(spellID)) or "Interface\\Icons\\INV_Misc_QuestionMark"
			
			activeInterrupts[destGUID] = {
				spellID = spellID,
				icon = icon,
				start = now,
				expiration = now + duration,
				duration = duration,
				isMine = (sourceGUID == UnitGUID("player")),
			}
			
			-- Update nameplates
			for unitToken, _ in pairs(ActiveNameplates) do
				if unitToken and UnitGUID(unitToken) == destGUID then
					UpdateUnitAuras(unitToken)
					break
				end
			end
		end
		
		-- Aoe detect
		if db.enableOpenIcons and subevent == "SPELL_CAST_SUCCESS" then
			local spellID, spellName, spellSchool = select(12, CombatLogGetCurrentEventInfo())
			
			if openSpellsDurations[spellID] then
				local duration = openSpellsDurations[spellID]
				local now = GetTime()
				local icon = select(3, GetSpellInfo(spellID)) or "Interface\\Icons\\INV_Misc_QuestionMark"
				
				activeOpenSpells[sourceGUID] = {
					spellID = spellID,
					icon = icon,
					start = now,
					expiration = now + duration,
					duration = duration,
					isMine = (sourceGUID == UnitGUID("player")),
				}
				
				-- Update
				for unitToken, _ in pairs(ActiveNameplates) do
					if unitToken and UnitGUID(unitToken) == sourceGUID then
						UpdateUnitAuras(unitToken)
						break
					end
				end
			end
		end
	-- ===================================================
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		Nameplate_Added(...)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		Nameplate_Removed(...)
	elseif event == "UNIT_AURA" then
		local unitID = ...
		if unitID and type(unitID) == "string" and strmatch(unitID, "nameplate%d+") then
			UpdateUnitAuras(unitID)
		end
	end
end)