local ADDON_NAME = "AutoLoot"
local ADDON_VERSION = "1.0"
local ADDON_AUTHOR = "Tom Cumbow"
TFC_AUTOLOOT_LOADED = true

local lpc = LibPixelControl
local Press = LibPixelControl.SetIndOnFor

local LastTarget
local LastAction

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

local function OnEventInteractableTargetChanged()
	local action, target, blocked, mysteryParm, additionalInfo = GetGameCameraInteractableActionInfo()
	-- d(action)
	-- d(interactableName)
	-- d(blocked)
	-- d(mysteryParm)
	-- d(additionalInfo)

	if blocked or additionalInfo==2 or IsMounted() or (action==LastAction and target==LastTarget) then
		return
	end

	LastAction = action
	LastTarget = target

	if 	(
			(action=="Search" and target~="Book Stack" and target~="Bookshelf")
			or action=="Disarm"
			or action=="Destroy"
			or action=="Cut"
			or action=="Mine"
			or action=="Collect"
			or action=="Loot"
			or (action=="Take" and not (target=="Spoiled Food" or target=="Greatsword" or target=="Sword" or target=="Axe" or target=="Bow" or target=="Shield" or target=="Staff" or target=="Sabatons" or target=="Jerkin" or target=="Dagger" or target=="Cuirass" or target=="Pauldron" or target=="Helm" or target=="Gauntlets" or target=="Guards" or target=="Boots" or target=="Shoes" or target=="Jack"))
			or (action=="Use" and (target=="Chest" or target=="Treasure Chest" or target=="Giant Clam" or target=="Skyshard"))
		) and not InventoryFull()
	then
		Press(lpc.VK_E,50)
	end
end

local function OnAddonLoaded(event, name)
	if name == ADDON_NAME then
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, event)
		ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", OnEventInteractableTargetChanged)
		ZO_PreHookHandler(RETICLE.interact, "OnHide", OnEventInteractableTargetChanged)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_STEALTH_STATE_CHANGED, OnEventStealthChange)
		PreventStealing()
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
