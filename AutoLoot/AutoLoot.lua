local ADDON_NAME = "AutoLoot"
local ADDON_VERSION = "1.0"
local ADDON_AUTHOR = "Tom Cumbow"
TFC_AUTOLOOT_LOADED = true

local lpc = LibPixelControl
local Press = LibPixelControl.SetIndOnFor

local function ActiveCompanionName()
	return ZO_CachedStrFormat("<<C:1>>",GetCompanionName(GetActiveCompanionDefId()))
end

local function MirriIsHere()
	return ActiveCompanionName()=="Mirri Elendis"
end

local function BastionIsHere()
	return ActiveCompanionName()=="Bastian Hallix"
end

local function InventoryFull()
	if GetNumBagUsedSlots(BAG_BACKPACK) == GetBagSize(BAG_BACKPACK) then
		return true
	else
		return false
	end
end

local function PreventStealing()
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_PREVENT_STEALING_PLACED, 1)
end
local function AllowStealing()
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_PREVENT_STEALING_PLACED, 0)
end
local function OnEventStealthChange(_,_,stealthState)
	if stealthState > 0 then
		AllowStealing()
	else
		PreventStealing()
	end
end

local function LootNow()
	Press(lpc.VK_E,50)
end

local function OnEventInteractableTargetChanged()
	local action, target, blocked, mysteryParm, additionalInfo = GetGameCameraInteractableActionInfo()
	-- d(action)
	-- d(interactableName)
	-- d(blocked)
	-- d(mysteryParm)
	-- d(additionalInfo)

	if blocked or additionalInfo==2 or IsMounted() or InventoryFull() then
		return
	end

	if 	(
			(action=="Search" and target~="Book Stack" and target~="Bookshelf" and target~="Heavy Sack")
		)
	then
		if IsPlayerMoving() then
			zo_callLater(LootNow,100)
		else
			LootNow()
		end
	elseif 	(
			action=="Disarm"
			or action=="Destroy"
			or action=="Cut"
			or action=="Mine"
			or action=="Collect"
			or action=="Loot"
			or (action=="Take" and not (target=="Doshia's Journal" or target=="Spoiled Food" or target=="Greatsword" or target=="Sword" or target=="Axe" or target=="Bow" or target=="Shield" or target=="Staff" or target=="Sabatons" or target=="Jerkin" or target=="Dagger" or target=="Cuirass" or target=="Pauldron" or target=="Helm" or target=="Gauntlets" or target=="Guards" or target=="Boots" or target=="Shoes" or target=="Jack" or (MirriIsHere() and (target=="Butterfly" or target=="Torchbug"))))
			--or (action=="Use" and (target=="Chest" or target=="Treasure Chest" or target=="Giant Clam" or target=="Skyshard"))
		)
	then
		LootNow()
	end

end

local function OnAddonLoaded(event, name)
	if name == ADDON_NAME then
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, event)
		ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", OnEventInteractableTargetChanged)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_STEALTH_STATE_CHANGED, OnEventStealthChange)
		PreventStealing()
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
