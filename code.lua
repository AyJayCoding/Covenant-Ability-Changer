-- This file is loaded from "Covenant-Ability-Changer.toc"
do
	-- Setting up arrays: [Warrior = 1, Paladin = 2, Hunter = 3, Rogue = 4, Priest = 5, DeathKnight = 6, Shaman = 7, Mage = 8, Warlock = 9, Monk = 10, Druid = 11, Demon Hunter = 12]

	local kyrianAbilities = {307865, 304971, 308491, 323547, 325013, 312202, 324386, 307443, 312321, 310454, 326434, 306830};
	local venthyrAbilities = {317349, 316958, 324149, 323654, 323673, 311648, 320674, 314793, 321792, 326860, 323546, 317009};
	local nightFaeAbilities = {325886, 328620, 328231, 328305, 327661, 324128, 328923, 314791, 325640, 327104, 323764, 323639};
	local necrolordAbilities = {324143, 328204, 325028, 328547, 324724, 315443, 326059, 324220, 325289, 325216, 325727, 329554};

	-- Setting up array: [Kyrian = 1, Venthyr = 2, NightFae = 3, Necrolord = 4]
	local signatureAbilities = {324739, 300728, 310143, 324631};
	
	-- Setting up item ID for Phial of Serenity
	local phialItemID = 177278;
	
	-- Setting up item ID for The Mad Duke's Tea
	local dukesTeaItemID = 187603;
	
	-- Setting up spell for construct ability
	local constructAbility = 347013;
	local constructAbilityZoneID = 41;
	local zoneAbilityFrameHooked = false;
	local constructAbilityFound = false;
	local otherActiveZoneAbilityFound = false;
	
	-- Setting up string for console output
	local CACADDON_CHAT_TITLE = "|CFF9482C9Covenant Ability Changer:|r "

	local playerCovenant = 0;
	local classIndex = 0;
	
	local classsAbilityMacroName = "CACclassAbi";
	local signatureAbilityMAacroName = "CACsignatureAbi";
	local signatureAbilityOnActionbar = false;
	local signatureAbilitySlotOnActionbar = 0;
	
-- Setting up MapID for Shadowlands Continent
--	local shadowlandsContinentID = 1550;

	-- Setting up function for detecting continent
--	local function getContinent()
--		local mapID = C_Map.GetBestMapForUnit("player")
--		if(mapID) then
--			local info = C_Map.GetMapInfo(mapID)
--			if(info) then
--				while(info['mapType'] and info['mapType'] > 2) do
--					info = C_Map.GetMapInfo(info['parentMapID'])
--				end
--				if(info['mapType'] == 2) then
--					return info['mapID']
--				end
--			end
--		end
--	end

--			print(string.format("%sZone change detected ..."..C_Map.GetMapInfo(getContinent()).name,CACADDON_CHAT_TITLE));

	-- Function for checking if construct ability has been acquired/updated/removed
	function CAC_constructAbilitySpellCheck()
		-- Indicate that zone abilities are not present
		constructAbilityFound = false;
		otherActiveZoneAbilityFound = false;
		-- Get list of zone specific abilities (construt ability is categorized under zone abilities)
		local zoneAbilities=C_ZoneAbility.GetActiveAbilities();

		-- Go through list of zone abilities
		for i,ability in ipairs(zoneAbilities) do
--				print("zoneAbilityID: "..ability.zoneAbilityID.." | uiPriority: "..ability.uiPriority.." | spellID: "..ability.spellID.." | textureKit: "..ability.textureKit.." | tutorialText: "..ability.tutorialText);
			-- Check if construct ability is present
			if ability.zoneAbilityID ==  constructAbilityZoneID then
				-- Indicate that ability is present
				constructAbilityFound = true;
				-- Check if zone ability frame has already been modified with a hook
				if zoneAbilityFrameHooked == false then
					-- If hook did not exist then create it
						-- 1. Attach hook to update of zone ability frame
						-- 2. If construct ability is present then make sure zone ability frame remains hidden (no need for it on screen as it is included as part of the button macro)
						-- 3. If construct ability is not present there is no need to hide the frame and is let to normal behavior based on zone
						-- 4. If hook was not done the zone ability frame would toggle with the button macro (if button macro shows it then frame is hidden, but if button macro does not show it then frame is shown) 
					ZoneAbilityFrame:HookScript("OnUpdate", function(self,...)
						if constructAbilityFound == true and signatureAbilityOnActionbar == true and otherActiveZoneAbilityFound == false then
							self:Hide();
						end
					end)
					-- Idicate tha hook has been attached to zone ability frame (it remains until client reload)
					zoneAbilityFrameHooked = true;
				end
			else 
				otherActiveZoneAbilityFound = true;
			end
		end
		if otherActiveZoneAbilityFound == true then
			ZoneAbilityFrame:Show();
		end
--		print(string.format("%sConstruct ability spell check ...",CACADDON_CHAT_TITLE));
	end
	

	-- Function for checking if signature ability is present on the action bar
	function CAC_checkSignatureAbilityOnAllActionbars()
		local slot = 0;
--		print(string.format("%sChecking all action buttons...",CACADDON_CHAT_TITLE));
		for slot = 1, 120 do
			-- Check if slot has an action
			if HasAction(slot) then
				-- Check if it is a macro
				local actionType, id = GetActionInfo(slot)
				if actionType == "macro" then
					-- Acquire the name a the macro
					macroName = GetMacroInfo(id)
--					print(string.format("%sFound a macro in slot "..slot.."..."..macroName,CACADDON_CHAT_TITLE));
					-- In case of signature ability then set the indicator for it
					if macroName == signatureAbilityMAacroName then
--						print(string.format("%sSaving information for slot "..slot.."..."..macroName,CACADDON_CHAT_TITLE));
						signatureAbilityOnActionbar = true;
						signatureAbilitySlotOnActionbar = slot;
						return;
					end
				end
			end
		end
--		print(string.format("%sDid not find signature ability macro...",CACADDON_CHAT_TITLE));
		signatureAbilityOnActionbar = false;
	end

	-- Function for checking if signature ability was added to/removed from a certain slot on the action bar
	function CAC_checkSignatureAbilityOnActionbar(slot)
		local signatureAbilityRemovedFromBar = false;
		
		-- If the slot is changed where signature ability was before then assume it has been removed
--		print(string.format("%sChecking for macro in slot "..slot.."...",CACADDON_CHAT_TITLE));
		if signatureAbilityOnActionbar == true and slot == signatureAbilitySlotOnActionbar then
--			print(string.format("%sResetting old information...",CACADDON_CHAT_TITLE));
			signatureAbilityOnActionbar = false;
			signatureAbilitySlotOnActionbar = 0;
			signatureAbilityRemovedFromBar = true;
		end
		-- Check if slot has an action
		if HasAction(slot) then
			-- Check if it is a macro
			local actionType, id = GetActionInfo(slot)
			if actionType == "macro" then
				-- Acquire the name a the macro
				macroName = GetMacroInfo(id)
--				print(string.format("%sFound a macro in slot "..slot.."..."..macroName,CACADDON_CHAT_TITLE));
				-- In case of signature ability then set the indicator for it
				if macroName == signatureAbilityMAacroName then
--					print(string.format("%sSaving information for slot "..slot.."..."..macroName,CACADDON_CHAT_TITLE));
					signatureAbilityOnActionbar = true;
					signatureAbilitySlotOnActionbar = slot;
					signatureAbilityRemovedFromBar = false;
					return;
				end
			end
		end
		
		if signatureAbilityRemovedFromBar == true and (constructAbilityFound == true or otherActiveZoneAbilityFound == true) then
			ZoneAbilityFrame:Show()
		end
	end

	function CAC_getSpellNames()
		if playerCovenant == 1 then
			-- Kyrian 
			classAbilityName = GetSpellInfo(kyrianAbilities[classIndex]);
			-- fall back on connect sometimes GetSpellInfo fail
			if classAbilityName == nil then
				classAbilityName = "";
			end	
			classAbilityNameTooltip = classAbilityName;
			classAbilityMacroStr = classAbilityName;
			signatureAbilityName = GetSpellInfo(signatureAbilities[playerCovenant]);
			-- fall back on connect sometimes GetSpellInfo fail
			if signatureAbilityName == nil then
				signatureAbilityNameTooltip = "";
				signatureAbilityMacroStr = "";
			else
				-- Adding alt-modifier for using Phial of Serenity
				signatureAbilityNameTooltip = "[nomod:alt] "..signatureAbilityName.."; [mod:alt]item:"..phialItemID;
				signatureAbilityMacroStr = "[nomod:alt] "..signatureAbilityName.."\n/use [mod:alt]item:"..phialItemID;
			end	
		elseif playerCovenant == 2 then
			-- Venthyr
			classAbilityName = GetSpellInfo(venthyrAbilities[classIndex]);
			-- fall back on connect sometimes GetSpellInfo fail
			if classAbilityName == nil then
				classAbilityName = "";
			end	
			classAbilityNameTooltip = classAbilityName;
			classAbilityMacroStr = classAbilityName;
			signatureAbilityName = GetSpellInfo(signatureAbilities[playerCovenant]);
			-- fall back on connect sometimes GetSpellInfo fail
			if signatureAbilityName == nil then
				signatureAbilityNameTooltip = "";
				signatureAbilityMacroStr = "";
			else
				-- Adding alt-modifier for Door of Shadows
				signatureAbilityNameTooltip = "[nomod:ctrl] "..signatureAbilityName.."; [mod:ctrl]item:"..dukesTeaItemID;
				signatureAbilityMacroStr = "[@cursor,mod:alt,nomod:ctrl] "..signatureAbilityName.."; [nomod:ctrl] "..signatureAbilityName.."\n/use [mod:ctrl]item:"..dukesTeaItemID;
			end	
		elseif playerCovenant == 3 then
			-- NightFae
			classAbilityName = GetSpellInfo(nightFaeAbilities[classIndex]);
			-- fall back on connect sometimes GetSpellInfo fail
			if classAbilityName == nil then
				classAbilityName = "";
			end	
			classAbilityNameTooltip = classAbilityName;
			-- Making wild spirits cast at cursor for hunters when alt modifier is pressed
			if classIndex == 3 then
				classAbilityMacroStr = "[@cursor,mod:alt] "..classAbilityName .. "; ".. classAbilityName;
			else
				classAbilityMacroStr = classAbilityName;			
			end
			signatureAbilityName = GetSpellInfo(signatureAbilities[playerCovenant]);
			-- fall back on connect sometimes GetSpellInfo fail
			if signatureAbilityName == nil then
				signatureAbilityName = "";
			end	
			signatureAbilityNameTooltip = signatureAbilityName;
			signatureAbilityMacroStr = signatureAbilityName;
		elseif playerCovenant == 4 then
			-- Necrolord
			classAbilityName = GetSpellInfo(necrolordAbilities[classIndex]);
			-- fall back on connect sometimes GetSpellInfo fail
			if classAbilityName == nil then
				classAbilityName = "";
			end	
			classAbilityNameTooltip = classAbilityName;
			-- Making Unholy Nova self cast for priest when no valid target selected
			if classIndex == 5 then
				classAbilityMacroStr = "[@target,help,exists] [@player] "..classAbilityName;		
			else
				classAbilityMacroStr = classAbilityName;
			end
			signatureAbilityName = GetSpellInfo(signatureAbilities[playerCovenant]);
			-- fall back on connect sometimes GetSpellInfo fail
			if signatureAbilityName == nil then
				signatureAbilityName = "";
			end	
			constructAbilityName = GetSpellInfo(constructAbility);
			if constructAbilityName == nil then
				constructAbilityName = "";
			end	
			signatureAbilityNameTooltip = "[nomod:alt] "..signatureAbilityName.."; [mod:alt]"..constructAbilityName;
			signatureAbilityMacroStr = "[nomod:alt] "..signatureAbilityName.."; [mod:alt]"..constructAbilityName;
		else
			signatureAbilityNameTooltip = "";
			signatureAbilityMacroStr = "";
			classAbilityNameTooltip = "";
			classAbilityMacroStr = "";
		end

		return classAbilityNameTooltip, classAbilityMacroStr, signatureAbilityNameTooltip, signatureAbilityMacroStr;
	end

	local CovenantAbilityMacroIcon = CreateFrame("Frame");
	-- Update on login to get class and covenant
	CovenantAbilityMacroIcon:RegisterEvent("PLAYER_LOGIN");
	-- Update on covenant change to get new covenant
	CovenantAbilityMacroIcon:RegisterEvent("COVENANT_CHOSEN");
	-- Update if spell has changed (used to detect if construct ability is acquired/changed)
	CovenantAbilityMacroIcon:RegisterEvent("SPELLS_CHANGED");
	-- Update if spell is added to/removed from action bar
	CovenantAbilityMacroIcon:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	
	CovenantAbilityMacroIcon:SetScript("OnEvent",function(self,event,slot,...)
--		print(string.format("%sEvent detected ..."..event,CACADDON_CHAT_TITLE));

		-- Check single action buttons
		if event == "ACTIONBAR_SLOT_CHANGED" then 
			CAC_checkSignatureAbilityOnActionbar(slot);
		else		
			if event == "PLAYER_LOGIN" or event == "COVENANT_CHOSEN" then
				-- Update upon login to get class and covenant
				if event=="PLAYER_LOGIN" then
					_, _, classIndex = UnitClass("player");
					playerCovenant = C_Covenants.GetActiveCovenantID();
					CAC_checkSignatureAbilityOnAllActionbars();
					-- Only register for checking individual buttons after player has logged in and full scan has been made
					CovenantAbilityMacroIcon:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
				end

				-- Update to get new covenant
				if event=="COVENANT_CHOSEN" then
					playerCovenant = C_Covenants.GetActiveCovenantID();
				end

				-- Get content of the macro strings used for the macro 
				local classAbility, classAbilityStr, signatureAbility, signatureAbilityStr = CAC_getSpellNames();
				local macroStrSig, macroStrCls;

				if InCombatLockdown() == true then
					print(string.format("%sCannot update covenant macros due to combat lockdown...",CACADDON_CHAT_TITLE));
				else
					--print(string.format("%sChecking covenant macros...",CACADDON_CHAT_TITLE));

					-- Find out how many macros already exist
					local numMacros = GetNumMacros();
					-- Setup flags for determining if the covenant/signature ability macros already exist
					local foundClassMacro = false;
					local foundSignatureMacro = false;

					-- Try to find existing covenant/signature ability macros
					for i=1, numMacros do
						local name = GetMacroInfo(i)
						if name == classsAbilityMacroName then
							-- Macro for class ability found
							foundClassMacro = true;
						elseif name == signatureAbilityMAacroName then
							-- Macro for signature ability found
							foundSignatureMacro = true;
						end		
					end
			
					-- Setup macro strings for class ability
					macroStrCls = "#showtooltip "..classAbility.."\n/cast "..classAbilityStr;
					-- If macro already exist then only update it
					if foundClassMacro == true then
						EditMacro(classsAbilityMacroName, classsAbilityMacroName, nil, macroStrCls, 1, nil);
					else -- Otherwise try to create new macro 
						print(string.format("%sExisitng macro for class ability not found. Creating new one...",CACADDON_CHAT_TITLE));
						-- Make sure the user has not reached cap on number of macros
						if GetNumMacros() < MAX_ACCOUNT_MACROS then
							-- Create the macro
							CreateMacro(classsAbilityMacroName, "INV_MISC_QUESTIONMARK", macroStrCls, nil);
						else
							print(string.format("%sCould not create macro for class ability. Macro limit reached.",CACADDON_CHAT_TITLE));
						end
					end

					-- Setup macro strings for signature ability
					macroStrSig = "#showtooltip "..signatureAbility.."\n/cast "..signatureAbilityStr;
					-- If macro already exist then only update it
					if foundSignatureMacro == true then
						EditMacro(signatureAbilityMAacroName, signatureAbilityMAacroName, nil, macroStrSig, 1, nil);
					else -- Otherwise try to create new macro
						print(string.format("%sExisitng macro for signature ability not found. Creating new one...",CACADDON_CHAT_TITLE));
						-- Make sure the user has not reached cap on number of macros
						if GetNumMacros() < MAX_ACCOUNT_MACROS then
							-- Create the macro
							CreateMacro(signatureAbilityMAacroName, "INV_MISC_QUESTIONMARK", macroStrSig, nil);
						else
							print(string.format("%sCould not create macro for signature ability. Macro limit reached.",CACADDON_CHAT_TITLE));
						end
					end
				end
			end
			-- Make sure to check if construct ability has been acquired/updated/removed
			CAC_constructAbilitySpellCheck();
		end
	end)
end
