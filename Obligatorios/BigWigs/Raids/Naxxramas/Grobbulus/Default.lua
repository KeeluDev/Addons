local bossName = BigWigs.bossmods.naxx.grobbulus
if BigWigs:IsBossSupportedByAnyServerProject(bossName) then
	return
end
-- no implementation found => use default implementation
--BigWigs:Print("default " .. bossName)


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
	self:CombatlogFilter(L["trigger_inject"], self.InjectEvent)
	self:CombatlogFilter(L["trigger_cloud"], self.CloudEvent)
	self:CombatlogFilter(L["trigger_slimeSpray"], self.CloudEvent)
	self:CombatlogFilter(L["trigger_slimeSpray2"], self.SlimeSprayEvent, true)
	
	self:ThrottleSync(3, syncName.inject)
	self:ThrottleSync(5, syncName.cloud)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
end

-- called after boss is engaged
function module:OnEngage()
	if self.db.profile.enrage then
		self:Message(L["msg_engage"], "Attention")
		self:Bar(L["bar_enrage"], timer.enrage, icon.enrage)
		self:DelayedMessage(timer.enrage - 10 * 60, L["msg_enrage10m"], "Attention")
		self:DelayedMessage(timer.enrage - 5 * 60, L["msg_enrage5m"], "Urgent")
		self:DelayedMessage(timer.enrage - 1 * 60, L["msg_enrage1m"], "Important")
		self:DelayedMessage(timer.enrage - 30, L["msg_enrage30"], "Important")
		self:DelayedMessage(timer.enrage - 10, L["msg_enrage10"], "Important")
	end
	
	if self.db.profile.slimespray then
		self:Bar(L["bar_slimeSpray"], timer.firstSlimeSpray, icon.slimeSpray)
	end
end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end


------------------------------
--      Event Handlers      --
------------------------------
function module:CloudEvent(msg)
	if string.find(msg, L["trigger_cloud"]) then
		self:Sync(syncName.cloud)
	end
end

function module:InjectEvent(msg)
	local _, _, eplayer, etype = string.find(msg, L["trigger_inject"])
	if eplayer and etype then
		if eplayer == L["misc_you"] and etype == L["misc_are"] then
			eplayer = UnitName("player")
		end
		self:Sync(syncName.inject .. " " .. eplayer)
	end
end

function module:SlimeSprayEvent(msg)
	if string.find(msg, L["trigger_slimeSpray"]) or string.find(msg, L["trigger_slimeSpray2"]) then
		self:Sync(syncName.slimeSpray)
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
	module:CloudEvent(L["trigger_cloud"])
	module:InjectEvent(L["trigger_inject"])
	
	module:OnDisengage()
	module:TestDisable()
end

-- visual test
function module:TestVisual()
	BigWigs:Print(self:ToString() .. " TestVisual not yet implemented")
end
