LKMMVectis = LibStub("AceAddon-3.0"):NewAddon("LKMMVectis", "AceConsole-3.0", "AceEvent-3.0")

local options = {
    name = "LKMMVectis",
    handler = LKMMVectis,
    type = "group",
    args = {
        range = {
            type = "select",
            name = "距离设置",
            desc = "设置范围内存在非自身小队终极菌体携带者警告的判断范围",
			values = {[5] = "5码",[8] = "8码",[10] = "10码",[11] = "11码",[13] = "13码"},
            get = "GetRange",
            set = "SetRange",
        },
        enableDebuffVoice = {
            type = "toggle",
            name = "启用跑DEBUFF语音提示",
            desc = "勾选以启用跑DEBUFF的语音提示",
            get = "IsEnableDebuffVoice",
            set = "EnableDebuffVoice",
			width  = "full",
        },
        enableDistanceVoice = {
            type = "toggle",
            name = "启用距离过近语音提示",
            desc = "开启语音警告设定范围内存在非自身小队终极菌体携带者",
            get = "IsEnableDistanceVoice",
            set = "EnableDistanceVoice",
			width  = "full",
        },
		
    },
}

local log_args = {}
local all_raider = {}
local group_star = {}
local group_dabing = {}
local group_diamond = {}
local group_triangle = {}
local playerName = UnitName("player")
local debuff_player = {}
local allocated_players = {}
local debuff_player_count = 1
local dmg_count = 0

local defaults = {
    profile = {
        range = 5,
        enableDebuffVoice = true,
        enableDistanceVoice = true,
    },
}

function is_include_in_group(value, tab)
    for k,v in ipairs(tab) do
      if v.name == value then
          return true
      end
    end
    return false
end

function delayedIcon(destName, num)
	SetRaidTargetIcon(destName, num)
end

function do_mark()
	local star = false
	local dabing = false
	local diamond = false
	local triangle = false
	local debuffPlayerName
	for i = 1, 4 do
		local debuffPlayerName = debuff_player[i]

		if (is_include_in_group(debuffPlayerName, group_star) and not star) then 
			C_Timer.After(0.6, delayedIcon(debuffPlayerName, 1))
			table.remove (debuff_player [i])
			star = true
			allocated_players[1] = debuffPlayerName
		elseif (is_include_in_group(debuffPlayerName, group_dabing) and not dabing) then 
			C_Timer.After(0.6, delayedIcon(debuffPlayerName, 2))
			table.remove (debuff_player [i])
			dabing = true
			allocated_players[2] = debuffPlayerName
		elseif (is_include_in_group(debuffPlayerName, group_diamond) and not diamond) then 
			C_Timer.After(0.6, delayedIcon(debuffPlayerName, 3))
			table.remove (debuff_player [i])
			diamond = true
			allocated_players[3] = debuffPlayerName
		elseif (is_include_in_group(debuffPlayerName, group_triangle) and not triangle) then 
			C_Timer.After(0.6, delayedIcon(debuffPlayerName, 4))
			table.remove (debuff_player [i])
			triangle = true
			allocated_players[4] = debuffPlayerName
		end
	end
		
	if (not (star and dabing and diamond and triangle)) then
		for i = 1, #debuff_player do
			debuffPlayerName = debuff_player[i]
			if (not star) then
				C_Timer.After(0.6, delayedIcon(debuffPlayerName, 1))
				table.remove (debuff_player [i])
				star = true
				allocated_players[1] = debuffPlayerName
			elseif (not dabing) then
				C_Timer.After(0.6, delayedIcon(debuffPlayerName, 2))
				table.remove (debuff_player [i])
				dabing = true
				allocated_players[2] = debuffPlayerName
			elseif (not diamond) then
				C_Timer.After(0.6, delayedIcon(debuffPlayerName, 3))
				table.remove (debuff_player [i])
				diamond = true
				allocated_players[3] = debuffPlayerName
			elseif (not triangle) then
				C_Timer.After(0.6, delayedIcon(debuffPlayerName, 4))
				table.remove (debuff_player [i])
				triangle = true
				allocated_players[4] = debuffPlayerName
			end
		end
	end
	
	for i = 1, 4 do
		debuffPlayerName = allocated_players[i]
		if ((debuffPlayerName == playerName) and self.db.profile.enableDebuffVoice) then
			PlaySoundFile("Interface\\AddOns\\LKMMVectis\\voice\\"..i..".ogg", "Master")
		end
	end
end

function get_range(uId)
	local range 
	if IsItemInRange(37727, uId) then range = 5--Ruby Acorn
	elseif IsItemInRange(63427, uId) then range = 8--Worgsaw
	elseif CheckInteractDistance(uId, 3) then range = 10
	elseif CheckInteractDistance(uId, 2) then range = 11
	elseif IsItemInRange(32321, uId) then range = 13--reports 12 but actual range tested is 13
	elseif IsItemInRange(6450, uId) then range = 18--Bandages. (despite popular sites saying it's 15 yards, it's actually 18 yards verified by UnitDistanceSquared
	elseif IsItemInRange(21519, uId) then range = 22--Item says 20, returns true until 22.
	elseif CheckInteractDistance(uId, 1) then range = 30
	elseif UnitInRange(uId) then range = 43
	elseif IsItemInRange(116139, uId)  then range = 50
	elseif IsItemInRange(32825, uId) then range = 60
	elseif IsItemInRange(35278, uId) then range = 80
	else range = 1000 end--Just so it has a numeric value, even if it's unknown to protect from nil errors
	return range
end

function check_distance()
	--print("开始距离检测")
	--print("playerName", playerName)
	--print("是否在大饼组", is_include_in_group(playerName, group_dabing))
	--if(#allocated_players == 4) then
	if (true) then
		local star_dist
		local dabing_dist
		local diamond_dist
		local triangle_dist
		local saved_range = tonumber(LKMMVectis.db.profile.range)
		--分别计算与4个标记位置
		--star_dist = get_range(allocated_players[1])
		--dabing_dist = get_range(allocated_players[2])
		--diamond_dist = get_range(allocated_players[3])
		--triangle_dist = get_range(allocated_players[4])
		star_dist = 999
		dabing_dist = get_range("Emiyamomoko")
		--print("设定距离", saved_range)
		--print("距离大饼", dabing_dist)
		diamond_dist = 999
		triangle_dist = 999
		--print("是否小于设定距离", dabing_dist < saved_range)
		--警告
		if (LKMMVectis.db.profile.enableDistanceVoice) then 
			if ((star_dist < saved_range) and (not is_include_in_group(playerName, group_star))) then
				print("远离星星")
				PlaySoundFile("Interface\\AddOns\\LKMMVectis\\voice\\star.ogg", "Master")
			elseif ((dabing_dist < saved_range) and (not is_include_in_group(playerName, group_dabing))) then
				print("远离大饼")
				PlaySoundFile("Interface\\AddOns\\LKMMVectis\\voice\\dabing.ogg", "Master")
			elseif ((diamond_dist < saved_range) and (not is_include_in_group(playerName, group_diamond))) then
				print("远离菱形")
				PlaySoundFile("Interface\\AddOns\\LKMMVectis\\voice\\diamond.ogg", "Master")
			elseif ((triangle_dist < saved_range) and (not is_include_in_group(playerName, group_triangle))) then
				print("远离三角")
				PlaySoundFile("Interface\\AddOns\\LKMMVectis\\voice\\triangle.ogg", "Master")
			end
		end
	end
end

--插件初始化
function LKMMVectis:OnInitialize()
    -- Called when the addon is loaded
    self.db = LibStub("AceDB-3.0"):New("LKMMVectisDB", defaults, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("LKMMVectis", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("LKMMVectis", "LKMMVectis")
end

function LKMMVectis:OnEnable()
	self:Print("LKMMVectis已启用")
	self:RegisterEvent("ENCOUNTER_START")
	self:RegisterEvent("ENCOUNTER_END")
    -- Called when the addon is enabled
end

function LKMMVectis:OnDisable()
    -- Called when the addon is disabled
end

function LKMMVectis:ENCOUNTER_START(encounterID, encounterName, difficultyID)
	--if (encounterID == 2134 and difficultyID == 16)
	if (true) then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		member = {}
		group_star = {}
		group_dabing = {}
		group_diamond = {}
		group_triangle = {}
		local member = {}
		for i = 1, 20 do
			member = {}
			name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
			member.name = name
			member.rank = rank
			member.subgroup = subgroup
			member.level = level
			member.class = class
			member.fileName = fileName
			member.zone = zone
			member.online = online
			member.isDead = isDead
			member.role = UnitGroupRolesAssigned(name)
			member.isML = isML
			table.insert (all_raider, member)
			if (member.subgroup == 1) then
				table.insert (group_star, member)	
			elseif (member.subgroup == 2) then
				table.insert (group_dabing, member)
			elseif (member.subgroup == 3) then
				table.insert (group_diamond, member)
			else 
				table.insert (group_triangle, member)
			end
		end
	end
end

function LKMMVectis:ENCOUNTER_END()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	group_star = {}
	group_dabing = {}
	group_diamond = {}
	group_triangle = {}
	debuff_player = {}
	debuff_player_count = 1
	
end


function LKMMVectis:COMBAT_LOG_EVENT_UNFILTERED()
	timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, extraArg1, extraArg2, extraArg3, extraArg4, extraArg5, extraArg6, extraArg7, extraArg8, extraArg9, extraArg10 = CombatLogGetCurrentEventInfo()
	log_args.timestamp=timestamp
	log_args.event=event
	log_args.hideCaster=hideCaster
	log_args.sourceGUID=sourceGUID
	log_args.sourceName=sourceName
	log_args.sourceFlags=sourceFlags
	log_args.sourceRaidFlags=sourceRaidFlags
	log_args.destGUID=destGUID
	log_args.destName=destName
	log_args.destFlags=destFlags
	log_args.destRaidFlags=destRaidFlags
	log_args.spellId=extraArg1
	log_args.spellName=extraArg2
	if (event == "SPELL_AURA_APPLIED" and extraArg2 == "终极菌体")  then
		debuff_player[debuff_player_count] = destName
		if (debuff_player_count==4) then
			do_mark()
			debuff_player_count=1
			debuff_player = {}
			allocated_players = {}
		end
		debuff_player_count = debuff_player_count + 1
	--elseif (event == "SPELL_DAMAGE" and extraArg2 == "终极菌体" and dmg_count == 4) then
	elseif (event == "SPELL_DAMAGE") then
		check_distance()
		dmg_count = 0
	elseif (event == "SPELL_DAMAGE" and extraArg2 == "终极菌体" and dmg_count < 4) then
		dmg_count = dmg_count + 1
	end
end

--set get functions
function LKMMVectis:GetRange(info)
    return self.db.profile.range
end

function LKMMVectis:SetRange(info, newValue)
    self.db.profile.range = newValue
end

function LKMMVectis:IsEnableDebuffVoice(info)
    return self.db.profile.enableDebuffVoice
end

function LKMMVectis:EnableDebuffVoice(info, value)
    self.db.profile.enableDebuffVoice = value
end

function LKMMVectis:IsEnableDistanceVoice(info)
    return self.db.profile.enableDistanceVoice
end

function LKMMVectis:EnableDistanceVoice(info, value)
    self.db.profile.enableDistanceVoice = value
end