------------------------------
-- Variables     			--
------------------------------

local bossName = BigWigs.bossmods.naxx.razuvious
local module = BigWigs:GetModule(AceLibrary("Babble-Boss-2.2")[bossName])
local L = BigWigs.i18n[bossName]
--local understudy = AceLibrary("Babble-Boss-2.2")["Deathknight Understudy"]
local understudy = L["misc_understudy"]


-- module variables
module.revision = 20017 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
module.wipemobs = {understudy} -- adds which will be considered in CheckForEngage
module.toggleoptions = {"shout", "unbalance", "shieldwall", "taunt", "bosskill"}


-- locals
module.timer = {
	firstShout = {
		min = 25 -2,
		max = 25 +2
	},
	shout = {
		min = 25 -2,
		max = 25 +2
	},
	noShout = {
		min = 25 -2 -2,
		max = 25 -2 +2
	},
	noShoutDelay = 5,
	unbalance = 30,
	shieldwall = 20,
	taunt = 5,
}
local timer = module.timer

module.icon = {
	shout = "Ability_Warrior_WarCry",
	unbalance = "Ability_Warrior_DecisiveStrike",
	shieldwall = "Ability_Warrior_ShieldWall",
	taunt = "Spell_Nature_Reincarnation"
}
local icon = module.icon

module.syncName = {
	shout = "RazuviousShout",
	shieldwall = "RazuviousShieldwall",
	unbalance = "RazuviousUnbalance",
	taunt = "RazuviousTaunt",
}
local syncName = module.syncName


------------------------------
--      Synchronization	    --
------------------------------
function module:BigWigs_RecvSync(sync, rest, nick)
    if sync == syncName.shout then
		self:Shout()
	elseif sync == syncName.shieldwall then
		self:Shieldwall()
	elseif sync == syncName.unbalance then
		self:Unbalance()
	elseif sync == syncName.taunt then
		self:Taunt()
	end
end


------------------------------
-- Sync Handlers	    	--
------------------------------
function module:Shout()
	self:CancelScheduledEvent("bwrazuviousnoshout")
	self:ScheduleEvent("bwrazuviousnoshout", self.NoShout, timer.shout.max, self)		
	
	if self.db.profile.shout then
		self:Message(L["msg_shoutNow"], "Attention", nil, "Alarm")
		self:DelayedMessage(timer.shout.min - 7, L["msg_shout7"], "Urgent")
		self:DelayedMessage(timer.shout.min - 3, L["msg_shout3"], "Urgent")
		self:Bar(L["bar_shout"], timer.shout, icon.shout)
	end
end

function module:Shieldwall()
	if self.db.profile.shieldwall then
		self:Bar(L["bar_shieldWall"], timer.shieldwall, icon.shieldwall)
	end
end

function module:Unbalance()
	if self.db.profile.unbalance then
		self:Message(L["msg_unbalanceNow"], "Urgent")
		self:DelayedMessage(timer.unbalance - 5, L["msg_unbalanceSoon"], "Urgent")
		self:Bar(L["bar_unbalance"], timer.unbalance, icon.unbalance)
	end
end

function module:Taunt()
	if self.db.profile.taunt then
		self:Message(L["msg_taunt"], "Attention", nil, "Alert")
		self:Bar(L["bar_taunt"], timer.taunt, icon.taunt)
	end
end

----------------------------------
-- Module Test Function    		--
----------------------------------

-- automated test
function module:TestModuleCore()
	-- check core functions	
	module:NoShout()	
	module:Unbalance()
	module:Shieldwall()
	module:Shout()
	module:Taunt()
	
	module:BigWigs_RecvSync(syncName.shout)
	module:BigWigs_RecvSync(syncName.shieldwall)
	module:BigWigs_RecvSync(syncName.unbalance)
end
