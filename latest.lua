local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Silentheart Hub",
	LoadingTitle = "Talking to Dreadstar...",
	LoadingSubtitle = "Stay safe.",
	ConfigurationSaving = {
		Enabled = false,
	},
	IntroEnabled = true,
	IntroAnimation = "Default",
	Icon = 0,
})

Window.ModifyTheme({
	TextColor = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(51, 16, 16),
	Topbar = Color3.fromRGB(30, 5, 5),
	Shadow = Color3.fromRGB(0, 0, 0),
	NotificationBackground = Color3.fromRGB(25, 5, 5),
	NotificationActionsBackground = Color3.fromRGB(200, 0, 0),
	TabBackground = Color3.fromRGB(40, 10, 10),
	TabStroke = Color3.fromRGB(100, 0, 0),
	TabBackgroundSelected = Color3.fromRGB(160, 0, 0),
	TabTextColor = Color3.fromRGB(240, 240, 240),
	SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
	ElementBackground = Color3.fromRGB(25, 10, 10),
	ElementBackgroundHover = Color3.fromRGB(45, 15, 15),
	SecondaryElementBackground = Color3.fromRGB(20, 5, 5),
	ElementStroke = Color3.fromRGB(80, 10, 10),
	SecondaryElementStroke = Color3.fromRGB(60, 5, 5),
	SliderBackground = Color3.fromRGB(100, 0, 0),
	SliderProgress = Color3.fromRGB(180, 0, 0),
	SliderStroke = Color3.fromRGB(220, 0, 0),
	ToggleBackground = Color3.fromRGB(35, 10, 10),
	ToggleEnabled = Color3.fromRGB(180, 0, 0),
	ToggleDisabled = Color3.fromRGB(60, 20, 20),
	ToggleEnabledStroke = Color3.fromRGB(220, 0, 0),
	ToggleDisabledStroke = Color3.fromRGB(80, 30, 30),
	ToggleEnabledOuterStroke = Color3.fromRGB(150, 0, 0),
	ToggleDisabledOuterStroke = Color3.fromRGB(40, 10, 10),
	DropdownSelected = Color3.fromRGB(70, 10, 10),
	DropdownUnselected = Color3.fromRGB(30, 5, 5),
	InputBackground = Color3.fromRGB(30, 10, 10),
	InputStroke = Color3.fromRGB(100, 20, 20),
	PlaceholderColor = Color3.fromRGB(150, 100, 100),
})

local CombatTab = Window:CreateTab("Combat", 0)
local ProgressionTab = Window:CreateTab("Progression", 0)
local MiscTab = Window:CreateTab("Misc", 0)

Rayfield:Notify({
	Title = "Connection Established",
	Content = "The spirit of Ryu watches over you.",
	Duration = 5,
	Image = 4483345998,
	Actions = {
		Ignore = {
			Name = "Acknowledge",
			Callback = function()
				print("Silentheart active.")
			end,
		},
	},
})

local Player = game.Players.LocalPlayer
local Constants = require(game.ReplicatedStorage.Constants)

local weaponQTEOn = false
local dodgeOn = false
local autoBlockOn = false
local selectedWeapon = "Dagger"
local autoAttackOn = false
local selectedSkills = { "Strike" }
local availableSkills = { "Strike" }
local skillCooldowns = {}
local currentEnergy = 0

local weapons = { "Dagger", "Spear", "Sword", "Fist", "Staff", "Hammer", "Axe" }

-- Weapon QTE Toggle
local WeaponQTEToggle = CombatTab:CreateToggle({
	Name = "Weapon QTE",
	CurrentValue = false,
	Flag = "WeaponQTEToggle",
	Callback = function(Value)
		weaponQTEOn = Value
	end,
})

-- Weapon Selection Dropdown
local WeaponDropdown = CombatTab:CreateDropdown({
	Name = "Select Weapon",
	Options = weapons,
	CurrentOption = { "Dagger" },
	MultipleOptions = false,
	Flag = "WeaponDropdown",
	Callback = function(Options)
		selectedWeapon = Options[1]
	end,
})

-- Dodge Minigame Toggle
local DodgeToggle = CombatTab:CreateToggle({
	Name = "Dodge Minigame",
	CurrentValue = false,
	Flag = "DodgeToggle",
	Callback = function(Value)
		dodgeOn = Value
	end,
})

-- Auto Block Toggle
local AutoBlockToggle = CombatTab:CreateToggle({
	Name = "Auto Block",
	CurrentValue = false,
	Flag = "AutoBlockToggle",
	Callback = function(Value)
		autoBlockOn = Value
	end,
})

CombatTab:CreateDivider()

-- Auto Attack Toggle
local AutoAttackToggle = CombatTab:CreateToggle({
	Name = "Auto Attack",
	CurrentValue = false,
	Flag = "AutoAttackToggle",
	Callback = function(Value)
		autoAttackOn = Value
	end,
})

-- Skill Selection Multi-Select Dropdown
local SkillSelector = CombatTab:CreateDropdown({
	Name = "Auto Attack Skills",
	Options = availableSkills,
	CurrentOption = { "Strike" },
	MultipleOptions = true,
	Flag = "SkillSelector",
	Callback = function(Options)
		selectedSkills = Options
		if #selectedSkills == 0 then
			selectedSkills = { "Strike" }
		end
	end,
})

local SkillLabel = CombatTab:CreateLabel("Selected Skills: Strike")
local EnergyLabel = CombatTab:CreateLabel("Current Energy: 0")

-- ===== PROGRESSION TAB =====
ProgressionTab:CreateButton({
	Name = "Open Level Up Screen",
	Callback = function()
		local guiFunctions = require(game.ReplicatedStorage.guiFunctions)
		local levelUpScreen = Player:WaitForChild("PlayerGui"):WaitForChild("LevelUp")
		local mainElements = Player.PlayerGui:WaitForChild("HUD")

		guiFunctions.showlevelup({
			mainelems = mainElements,
			LevelUp = levelUpScreen,
		})
	end,
})

-- ==== MISC TAB ====

MiscTab:CreateLabel("Server Management")

MiscTab:CreateButton({
	Name = "Server Hop",
	Callback = function()
		local HttpService = game:GetService("HttpService")
		local TeleportService = game:GetService("TeleportService")
		local Players = game:GetService("Players")

		local function ServerHop()
			local PlaceId = game.PlaceId
			local JobId = game.JobId
			-- API URL to get public servers, sorted by ascending player count
			local ApiUrl = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

			local Success, Result = pcall(function()
				return game:HttpGet(ApiUrl)
			end)

			if Success then
				local Decoded = HttpService:JSONDecode(Result)
				if Decoded and Decoded.data then
					for _, server in ipairs(Decoded.data) do
						-- Check if server is not full and is not your current server
						if server.playing < server.maxPlayers and server.id ~= JobId then
							print("Found server! Teleporting to: " .. server.id)
							TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Players.LocalPlayer)
							return
						end
					end
				end
			else
				warn("Failed to fetch server list: " .. tostring(Result))
			end
		end

		-- Run the function
		ServerHop()
	end,
})

MiscTab:CreateDivider()

MiscTab:CreateButton({
	Name = "Infinite Yield",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end,
})

-- ===== SCRIPT PERSISTENCE =====
-- This code ensures the script reloads on server/place changes
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = game.Players.LocalPlayer

-- Store the script URL
local scriptUrl = "https://raw.githubusercontent.com/RakimuAzad/Silentheart-Hub/main/latest.lua"

-- Function to reload the script after teleport
local function PersistScript()
	TeleportService.LocalPlayerTeleportedSignal:Connect(function(placeId, character)
		-- Give it a moment for the game to load
		task.wait(2)

		-- Reload the script
		loadstring(game:HttpGet(scriptUrl))()
	end)
end

-- Alternative method: Using RunService to detect place changes
local RunService = game:GetService("RunService")
local currentPlaceId = game.PlaceId

game:GetService("RunService").Heartbeat:Connect(function()
	if game.PlaceId ~= currentPlaceId then
		currentPlaceId = game.PlaceId

		-- Wait for the place to fully load
		task.wait(3)

		-- Reload the script
		loadstring(game:HttpGet(scriptUrl))()
	end
end)

-- CAPTURE SKILLS FROM UPDATESKILLS EVENT
game.ReplicatedStorage.Remotes.Information.UpdateSkills.OnClientEvent:Connect(function(skillList)
	availableSkills = { "Strike" }

	for _, skill in pairs(skillList) do
		if skill ~= "Summon" and not table.find(availableSkills, skill) then
			table.insert(availableSkills, skill)
		end
	end

	SkillSelector:Refresh(availableSkills)
	SkillLabel:Set("Selected Skills: " .. table.concat(selectedSkills, ", "))
end)

-- TRACK SKILL COOLDOWNS
game.ReplicatedStorage.Remotes.Information.UpdateSkillCDs.OnClientEvent:Connect(function(cooldowns, playerStatus)
	skillCooldowns = cooldowns or {}
end)

-- Real-time energy tracking with rapid updates
task.spawn(function()
	while true do
		local character = Player.Character
		if character then
			local statusFolder = character:FindFirstChild("Status")
			if statusFolder then
				local energyValue = statusFolder:FindFirstChild("Energy")
				if energyValue then
					currentEnergy = energyValue.Value
					EnergyLabel:Set("Current Energy: " .. currentEnergy)
				end
			end
		end
		task.wait(0.1) -- Update every 0.1 seconds for fast response
	end
end)

-- Get skill cost from Constants
local function getSkillCost(skillName)
	if Constants.Skills and Constants.Skills[skillName] then
		return Constants.Skills[skillName].Cost or 0
	end
	return 0
end

-- Get available skills that can be used (have energy and no cooldown)
local function getUsableSkills()
	local usable = {}

	for _, skill in pairs(selectedSkills) do
		local cost = getSkillCost(skill)
		local cd = skillCooldowns[skill] or 0

		-- Check if we have enough energy and skill is off cooldown
		if currentEnergy >= cost and cd <= 0 then
			table.insert(usable, skill)
		end
	end

	return usable
end

-- Coroutine for Weapon QTE
coroutine.wrap(function()
	while true do
		if weaponQTEOn then
			local remoteName = selectedWeapon .. "QTE"
			local infoRemote = game:GetService("ReplicatedStorage")
				:WaitForChild("Remotes", 5)
				:WaitForChild("Information", 5)
				:WaitForChild("RemoteFunction", 5)
			if infoRemote then
				infoRemote:FireServer(true, remoteName)
			end
		end
		task.wait(1.5)
	end
end)()

-- Coroutine for Dodge Minigame
coroutine.wrap(function()
	while true do
		if dodgeOn then
			local infoRemote = game:GetService("ReplicatedStorage").Remotes.Information.RemoteFunction
			if infoRemote then
				infoRemote:FireServer({ true, true }, "DodgeMinigame")
			end
		end
		task.wait(0.001)
	end
end)()

-- Coroutine for Auto Block
coroutine.wrap(function()
	while true do
		if autoBlockOn then
			local infoRemote = game:GetService("ReplicatedStorage").Remotes.Information.RemoteFunction
			if infoRemote then
				infoRemote:FireServer({ true, false }, "DodgeMinigame")
			end
		end
		task.wait(0.001)
	end
end)()

-- Coroutine for Auto Attack with smart skill selection
coroutine.wrap(function()
	while true do
		if autoAttackOn then
			local character = Player.Character
			if character and character:FindFirstChild("FightInProgress") then
				local fightId = character.FightInProgress.Value
				local attackRemote = game.ReplicatedStorage:WaitForChild("PlayerTurnInput", 5)
				local getEnemies = game.ReplicatedStorage.Remotes.Data.GetOtherTeam

				local success, enemies = pcall(function()
					return getEnemies:InvokeServer(fightId)
				end)

				if success and enemies and #enemies > 0 and attackRemote then
					-- Get usable skills
					local usableSkills = getUsableSkills()

					if #usableSkills > 0 then
						-- Use a random usable skill
						local skillToUse = usableSkills[math.random(1, #usableSkills)]
						attackRemote:InvokeServer("Attack", skillToUse, {
							["Attacking"] = enemies[1],
						})
					else
						-- No usable skills, guard instead
						attackRemote:InvokeServer("Guard", false)
					end
				end
			end
		end
		task.wait(1)
	end
end)()
