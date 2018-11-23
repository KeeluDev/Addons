local bossName = BigWigs.bossmods.naxx.grobbulus
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
module.revision = 20015 -- To be overridden by the module!

-- override timers if necessary
--timer.berserk = 300


------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()
	self:CombatlogFilter(L["trigger_inject"], self.InjectEvent)
	self:CombatlogFilter(L["trigger_cloud"], self.CloudEvent)
	self:CombatlogFilter(L["trigger_slimeSpray"], self.SlimeSprayEvent, true)
	self:CombatlogFilter(L["trigger_slimeSpray2"], self.SlimeSprayEvent, true)
	
	self:CombatlogFilter(L["trigger_bombardSlime"], self.BombardSlimeEvent, true) -- slime trash respawn
	
	self:ThrottleSync(2, syncName.inject)
	self:ThrottleSync(5, syncName.cloud)
	self:ThrottleSync(15, syncName.bombardSlime)
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
	
	self:RemoveBar(L["bar_bombardSlime"]) -- trash respawn
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

function module:BombardSlimeEvent(msg)
	if BigWigs:IsModuleActive(BigWigs.bossmods.naxx.livingmonstrosity) or 
		BigWigs:IsModuleActive(BigWigs.bossmods.naxx.patchwerk) or 
		BigWigs:IsModuleActive(BigWigs.bossmods.naxx.stitchedGiant) then
		
		return
	else
		if string.find(msg, L["trigger_bombardSlime"]) then
			self:Sync(syncName.bombardSlime)
		end
	end
end

----------------------------------
-- Module Test Function    		--
----------------------------------

-- /run BigWigs:GetModule("Grobbulus"):TestModule()

-- automated test
function module:TestModule()
	module:OnEnable()
	module:OnSetup()
	module:OnEngage()

	module:TestModuleCore()

	-- check event handlers
	module:CloudEvent(L["trigger_cloud"])
	module:InjectEvent(L["trigger_inject"])
	module:InjectEvent(string.format(L["trigger_inject"], L["misc_you"], L["misc_are"]))
	module:SlimeSprayEvent(L["trigger_slimeSpray"])
	
	module:OnDisengage()
	module:TestDisable()
end

-- visual test
function module:TestVisual()
	BigWigs:Print(self:ToString() .. " TestVisual not yet implemented")
end
