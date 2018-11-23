local bossName = BigWigs.bossmods.other.lethon
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

-- called after module is enabled
function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
end

-- called after module is enabled and after each wipe
function module:OnSetup()
	module.announceTime = 0
end

-- called after boss is engaged
function module:OnEngage()
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end


------------------------------
--      Event Handlers      --
------------------------------
function module:Event(msg)
	-- only announce every 3 seconds
	if module.announceTime + 3 < GetTime() then
		module.announceTime = GetTime()
		
		if string.find(msg, L["trigger_noxiousBreath"]) then
			if self.db.profile.noxious then 
				self:Message(L["msg_noxiousBreathNow"], "Important")
				self:DelayedMessage(timer.noxiousBreath - 5, L["msg_noxiousBreathSoon"], "Important", true, "Alert")
				self:Bar(L["bar_noxiousBreath"], timer.noxiousBreath, icon.noxiousBreath)	
			end
		end
	end
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L["trigger_engage"] then
		if self.db.profile.noxious then
			self:Message(L["msg_engage"], "Important")
			self:DelayedMessage(timer.firstNoxiousBreath - 5, L["msg_noxiousBreathSoon"], "Important", true, "Alert")
			self:Bar(L["bar_noxiousBreath"], timer.firstNoxiousBreath, icon.noxiousBreath)
		end
	elseif string.find(msg, L["trigger_shadows"]) then
		self:Message(L["msg_shadows"], "Important")
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
	module:Event(L["trigger_noxiousBreath"])
	module:CHAT_MSG_MONSTER_YELL(L["trigger_engage"])
	module:CHAT_MSG_MONSTER_YELL(L["trigger_shadows"])
	
	module:OnDisengage()
	module:TestDisable()
end

-- visual test
function module:TestVisual()
	BigWigs:Print(self:ToString() .. " TestVisual not yet implemented")
end
