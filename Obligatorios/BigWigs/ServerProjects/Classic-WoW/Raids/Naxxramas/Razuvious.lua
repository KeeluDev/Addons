local bossName = BigWigs.bossmods.naxx.razuvious
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
module.timer.firstShout = {
	min = 25 -2,
	max = 25 +2
}
module.timer.shout = {
	min = 25 -2,
	max = 25 +2
}

module.toggleoptions = {"shout", "shieldwall", "taunt", "bosskill"} -- removed unbalance, doesn't make sense on nefarian

------------------------------
--      Initialization      --
------------------------------

module:RegisterYellEngage(L["trigger_engage1"])
module:RegisterYellEngage(L["trigger_engage2"])
module:RegisterYellEngage(L["trigger_engage3"])

-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "CheckForShout")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "CheckForShout")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "CheckForShout")

	--[[self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "CheckForUnbalance")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "CheckForUnbalance")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "CheckForUnbalance")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "CheckForUnbalance")]]

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "CheckForShieldwall")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", "CheckForShieldwall")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "CheckForShieldwall")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "CheckForShieldwall")
	
	self:CombatlogFilter(L["trigger_taunt"], self.TauntEvent)

	self:ThrottleSync(5, syncName.shout)
	self:ThrottleSync(5, syncName.shieldwall)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
end

-- called after boss is engaged
function module:OnEngage()
	if self.db.profile.shout then
		self:Message(L["msg_engage"], "Attention", nil, "Urgent")
		self:DelayedMessage(timer.firstShout.min - 7, L["msg_shout7"], "Urgent")
		self:DelayedMessage(timer.firstShout.min - 3, L["msg_shout3"], "Urgent")
		self:Bar(L["bar_shout"], timer.firstShout, icon.shout)
	end
	self:ScheduleEvent("bwrazuviousnoshout", self.NoShout, timer.firstShout.max, self)
	
	self:ScheduleRepeatingEvent("bwRazuviousCheckUnderstudyHP", self.UpdateUnderstudyHP, 0.5, self)
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
	self:CancelScheduledEvent("bwrazuviousnoshout")
	self:TriggerEvent("BigWigs_StopHPBar", self, "Understudy")
	self:CancelScheduledEvent("bwRazuviousCheckUnderstudyHP")
end


------------------------------
--      Event Handlers      --
------------------------------
function module:CheckForShieldwall(msg) 
	if string.find(msg, L["trigger_shieldWall"]) then
		self:Sync(syncName.shieldwall)
	end
end

function module:CheckForShout(msg)
	if string.find(msg, L["trigger_shout"]) then
		self:Sync(syncName.shout)
	end
end

--[[function module:CheckForUnbalance(msg)
	if string.find(msg, L["trigger_unbalance"]) then
		self:Sync(syncName.unbalance)
	end
end]]

function module:TauntEvent(msg)
	if string.find(msg, L["trigger_taunt"]) then
		self:Sync(syncName.taunt)
	end
end

------------------------------
-- Utility	Functions   	--
------------------------------
-- you only see disrupting shout if someone gets hit
function module:NoShout()	
	self:CancelScheduledEvent("bwrazuviousnoshout")
	self:ScheduleEvent("bwrazuviousnoshout", self.NoShout, timer.noShout.max, self)
	
	if self.db.profile.shout then
		--self:Message(L["msg_noShout"], "Attention") -- is this message useful?		
		self:Bar(L["bar_shout"], timer.noShout, icon.shout)
		self:DelayedMessage(timer.noShout.min - 7, L["msg_shout7"], "Urgent")
		self:DelayedMessage(timer.noShout.min - 3, L["msg_shout3"], "Urgent")
	end
end

-- workaround for the broken hp display of mind controlled npc's
function module:UpdateUnderstudyHP()
	local health = 0
	local maxHP = 91124
	local razuvious = AceLibrary("Babble-Boss-2.2")["Instructor Razuvious"]
	local understudy = L["misc_understudy"]
	
	--[[local razuvious = "Coyra"
	local maxHP = 100
	local understudy = "Ragged Young Wolf"]]
	
	if UnitName("playertarget") == razuvious and UnitName("playertargettarget") == understudy then
		--if UnitName("playertarget") == "Ragged Timber Wolf" then
		health = UnitHealth("playertargettarget")
	else
		for i=1, GetNumRaidMembers(), 1 do
			if UnitName("Raid" .. i .. "target") == razuvious and UnitName("Raid" .. i .. "targettarget") == understudy then
				health = UnitHealth("Raid" .. i .. "targettarget")
				break
			end
		end
	end
	
	if health > 0 then
		health = health / maxHP * 100
		--BigWigs:DebugMessage(health)
		self:TriggerEvent("BigWigs_StartHPBar", self, "Understudy", 100)
		self:TriggerEvent("BigWigs_SetHPBar", self, "Understudy", 100 - health)
	else
		self:TriggerEvent("BigWigs_StopHPBar", self, "Understudy")
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
	--module:CheckForUnbalance(L["trigger_unbalance"])
	module:CheckForShout(L["trigger_shout"])
	module:CheckForShieldwall(L["trigger_shieldWall"]) 
	module:TauntEvent(L["trigger_taunt"])
	
	module:OnDisengage()
	module:TestDisable()
end

-- visual test
function module:TestVisual()
	--BigWigs:Print(self:ToString() .. " TestVisual not yet implemented")
	
	
	-- /run local m=BigWigs:GetModule("Instructor Razuvious");m:TestVisual()
	local function unbalance()
		--module:CheckForUnbalance("Instructor Razuvious's Unbalancing Strike hits Death Knight Understudy for 10724.")
		module:Sync(syncName.unbalance)
		BigWigs:Print("unbalance")
	end 
	
	local function shout()
		module:CheckForShout("Instructor Razuvious's Disrupting Shout hits Anthem for 1216.")
		BigWigs:Print("shout")
	end
	
	local function deactivate()
		self:DebugMessage("deactivate")
		self:Disable()
		--[[self:DebugMessage("deactivate ")
		if self.phase then
			self:DebugMessage("deactivate module "..self:ToString())
			--BigWigs:ToggleModuleActive(self, false)
			self.core:ToggleModuleActive(self, false)
			self.phase = nil
		end]]
	end
	
	local function taunt()
		module:TauntEvent(L["trigger_taunt"])
		BigWigs:Print("taunt")
	end

	BigWigs:Print("module Test started")

	-- immitate CheckForEngage
	self:SendEngageSync()

	-- sweep after 5s
	self:ScheduleEvent(self:ToString() .. "Test_unbalance", unbalance, 2, self)
	self:ScheduleEvent(self:ToString() .. "Test_shout", shout, 3, self)
	self:ScheduleEvent(self:ToString() .. "Test_taunt", taunt, 5, self)
	self:ScheduleEvent(self:ToString() .. "Test_deactivate", deactivate, 50, self)
end
