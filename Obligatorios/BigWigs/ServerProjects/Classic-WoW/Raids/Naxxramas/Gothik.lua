local bossName = BigWigs.bossmods.naxx.gothik
local serverProjectName = "Classic-WoW"
if not BigWigs:IsServerRegisteredForServerProject(serverProjectName) or not BigWigs:IsBossSupportedByServerProject(bossName, serverProjectName) then
	return
end


--BigWigs:Print("classic-wow " .. bossName)

------------------------------
-- Variables     			--
------------------------------

local module = BigWigs:GetModule(AceLibrary("Babble-Boss-2.2")[bossName])
local L = BigWigs.i18n[bossName]
local timer = module.timer
local icon = module.icon
local syncName = module.syncName

-- module variables
module.revision = 20014 -- To be overridden by the module!

-- override timers if necessary
--timer.berserk = 300


------------------------------
--      Initialization      --
------------------------------

module:RegisterYellEngage(L["trigger_engage1"])
module:RegisterYellEngage(L["trigger_engage2"])

-- called after module is enabled
function module:OnEnable()	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end

-- called after module is enabled and after each wipe
function module:OnSetup()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	
	module.wave = 0
	module.numTrainees = 0
	module.numDeathknights = 0
	module.numRiders = 0
end

-- called after boss is engaged
function module:OnEngage()
	if self.db.profile.room then
		self:Message(L["msg_engage"], "Important")
		self:Bar(L["bar_inRoom"], timer.inroom, icon.inroom)
		self:DelayedMessage(timer.inroom - 3 * 60, L["msg_inRoom3m"], "Attention")
		self:DelayedMessage(timer.inroom - 90, L["msg_inRoom90"], "Attention")
		self:DelayedMessage(timer.inroom - 60, L["msg_inRoom60"], "Urgent")
		self:DelayedMessage(timer.inroom - 30, L["msg_inRoom30"], "Important")
		self:DelayedMessage(timer.inroom - 10, L["msg_inRoom10"], "Important")
	end

	if self.db.profile.add then
		timer.trainee = timer.firstTrainee
		timer.deathknight = timer.firstDeathknight
		timer.rider = timer.firstRider
	
		self:Trainee()
		self:DeathKnight()
		self:Rider()
		
		timer.trainee = timer.traineeInterval
		timer.deathknight = timer.deathknightInterval
		timer.rider = timer.riderInterval
	end
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
	self:CancelScheduledEvent("bwgothiktrawarn")
	self:CancelScheduledEvent("bwgothikdkwarn")
	self:CancelScheduledEvent("bwgothikriderwarn")
	self:CancelScheduledEvent("bwgothiktrarepop")
	self:CancelScheduledEvent("bwgothikdkrepop")
	self:CancelScheduledEvent("bwgothikriderrepop")
end


------------------------------
--      Event Handlers      --
------------------------------
function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_inRoom"] then
		if self.db.profile.room then 
			self:Message(L["msg_inRoom"], "Important") 
		end
		self:StopRoom()
	elseif string.find(msg, L["trigger_victory"]) then
		self:SendBossDeathSync()
	end
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	BigWigs:CheckForBossDeath(msg, self)
	
	if self.db.profile.adddeath and msg == string.format(UNITDIESOTHER, L["misc_riderName"]) then
		self:Message(L["msg_riderDeath"], "Important")
	elseif self.db.profile.adddeath and msg == string.format(UNITDIESOTHER, L["misc_deathKnightName"]) then
		self:Message(L["msg_deathKnightDeath"], "Important")
	end
end


----------------------------------
-- Module Test Function    		--
----------------------------------

-- automated test
function module:TestModule()
	module:OnEnable()
	module:OnSetup()
	module:OnEngage()

	module:TestModuleCore()

	-- check event handlers
	module:CHAT_MSG_MONSTER_YELL(L["trigger_inRoom"])
	module:CHAT_MSG_MONSTER_YELL(L["trigger_victory"])
	module:CHAT_MSG_COMBAT_HOSTILE_DEATH(string.format(UNITDIESOTHER, L["misc_riderName"]))
	module:CHAT_MSG_COMBAT_HOSTILE_DEATH(string.format(UNITDIESOTHER, L["misc_deathKnightName"]))
	
	module:OnDisengage()
	module:TestDisable()
end

-- visual test
function module:TestVisual()
	-- /run local m=BigWigs:GetModule("Gothik the Harvester");m:TestVisual()
    
    --[[local function fever()
        module:DiseaseEvent(L["trigger_decrepitFever"])
    end
    local function toPlatform()
        module:TeleportEvent(L["trigger_toPlatform"])
    end
    local function toFloor()
        module:TeleportEvent(L["trigger_toFloor"])
    end]]

    local function deactivate()
        BigWigs:Print("deactivate")
        self:Disable()
    end
    
     
    
    local time = 0
    
    -- immitate CheckForEngage
    self:SendEngageSync()
    
    BigWigs:Print("module Test started")   
    
    -- fever after 9s
    --[[time = time + timer.firstDisease
    BigWigs:Print(" fever after " .. time)
    self:ScheduleEvent(self:ToString().."Test_fever", fever, time, self)
    
    -- fever after 30s
    time = time + timer.disease
    BigWigs:Print(" fever after " .. time)
    self:ScheduleEvent(self:ToString().."Test_fever2", fever, time, self)
    
    -- fever after 51s
    time = time + timer.disease
    BigWigs:Print(" fever after " .. time)
    self:ScheduleEvent(self:ToString().."Test_fever3", fever, time, self)
    
    -- fever after 72s
    time = time + timer.disease
    BigWigs:Print(" fever after " .. time)
    self:ScheduleEvent(self:ToString().."Test_fever4", fever, time, self)
    
    
    -- toPlatform after 90s
    time = timer.toPlatform
    BigWigs:Print(" to platform after " .. time)
    self:ScheduleEvent(self:ToString().."Test_toPlatform", toPlatform, time, self)
    
    -- toFloor after 135s
    time = time + timer.toFloor
    BigWigs:Print(" to floor after " .. time)
    self:ScheduleEvent(self:ToString().."Test_toFloor", toFloor, time, self)]]
    
    
    -- reset after 50s
    time = time + 100
    BigWigs:Print(" deactivate after " .. time)
    self:ScheduleEvent(self:ToString().."Test_deactivate", deactivate, time, self)
end
