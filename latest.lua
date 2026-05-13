local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ===== CONFIG SYSTEM SETUP =====
local configFolder = "silentheart"
local configFolderPath = configFolder
local activeConfigFile = configFolder .. "/active_config.txt"

-- Create folder if it doesn't exist
if not isfolder(configFolderPath) then
    makefolder(configFolderPath)
end

-- Function to get all config files
local function getConfigList()
    local configs = {}
    if isfolder(configFolderPath) then
        local files = listfiles(configFolderPath)
        for _, file in ipairs(files) do
            local fileName = file:match("([^/]+)$")
            if fileName ~= "active_config.txt" and fileName:match("%.json$") then
                table.insert(configs, fileName:gsub("%.json$", ""))
            end
        end
    end
    return configs
end

-- Function to get active config
local function getActiveConfig()
    if isfile(activeConfigFile) then
        return readfile(activeConfigFile):gsub("\n", "")
    end
    return nil
end

-- Function to set active config
local function setActiveConfig(configName)
    writefile(activeConfigFile, configName)
end

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
    PlaceholderColor = Color3.fromRGB(150, 100, 100)
})

local CombatTab = Window:CreateTab("Combat", 0)
local ProgressionTab = Window:CreateTab("Progression", 0)
local MiscTab = Window:CreateTab("Misc", 0)
local ConfigTab = Window:CreateTab("Config", 0)

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
            end
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
local selectedSkills = {"Strike"}
local availableSkills = {"Strike"}
local skillCooldowns = {}
local currentEnergy = 0

local weapons = {"Dagger", "Spear", "Sword", "Fist", "Staff","Hammer","Axe"}

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
    CurrentOption = {"Dagger"},
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
    CurrentOption = {"Strike"},
    MultipleOptions = true,
    Flag = "SkillSelector",
    Callback = function(Options)
        selectedSkills = Options
        if #selectedSkills == 0 then
            selectedSkills = {"Strike"}
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
            LevelUp = levelUpScreen
        })
    end,
})

-- ==== MISC TAB ====

MiscTab:CreateLabel("Server Management")

MiscTab:CreateButton({
    Name = "Random Server Hop",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")

        local function RandomServerHop()
            local PlaceId = game.PlaceId
            local JobId = game.JobId
            -- API URL to get public servers
            local ApiUrl = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"

            local Success, Result = pcall(function()
                return game:HttpGet(ApiUrl)
            end)

            if Success then
                local Decoded = HttpService:JSONDecode(Result)
                if Decoded and Decoded.data and #Decoded.data > 0 then
                    -- Get a random server from the list
                    local randomServer = Decoded.data[math.random(1, #Decoded.data)]
                    
                    -- Make sure it's not full and not your current server
                    if randomServer.playing < randomServer.maxPlayers and randomServer.id ~= JobId then
                        print("Found random server! Teleporting to: " .. randomServer.id)
                        TeleportService:TeleportToPlaceInstance(PlaceId, randomServer.id, Players.LocalPlayer)
                        return
                    else
                        print("Random server was full or current server, trying another...")
                        RandomServerHop()
                    end
                end
            else
                warn("Failed to fetch server list: " .. tostring(Result))
            end
        end

        -- Run the function
        RandomServerHop()
    end,
})

MiscTab:CreateButton({
    Name = "Small Server Hop",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")

        local function SmallServerHop()
            local PlaceId = game.PlaceId
            local JobId = game.JobId
            -- API URL to get public servers, sorted by ascending player count (smallest first)
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
                            print("Found small server! Teleporting to: " .. server.id .. " (" .. server.playing .. "/" .. server.maxPlayers .. ")")
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
        SmallServerHop()
    end,
})

MiscTab:CreateDivider()

MiscTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function ()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()    
    end,
})

-- ===== CONFIG TAB =====

ConfigTab:CreateLabel("Configuration Management")

local configNameInput = ConfigTab:CreateInput({
    Name = "Config Name",
    PlaceholderText = "Enter config name...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Value)
        -- This will be used when saving
    end,
})

ConfigTab:CreateButton({
    Name = "Save Config",
    Callback = function()
        local configName = configNameInput.Value
        if configName == "" or configName == nil then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a config name!",
                Duration = 3,
                Image = 4483345998,
            })
            return
        end

        -- Create config data table
        local configData = {
            weaponQTE = weaponQTEOn,
            selectedWeapon = selectedWeapon,
            dodge = dodgeOn,
            autoBlock = autoBlockOn,
            autoAttack = autoAttackOn,
            selectedSkills = selectedSkills,
        }

        -- Save to file
        local filePath = configFolderPath .. "/" .. configName .. ".json"
        writefile(filePath, game:GetService("HttpService"):JSONEncode(configData))
        
        -- Set as active config
        setActiveConfig(configName)
        
        -- Update dropdown
        updateConfigDropdown()

        Rayfield:Notify({
            Title = "Success",
            Content = "Config '" .. configName .. "' saved!",
            Duration = 3,
            Image = 4483345998,
        })
    end,
})

ConfigTab:CreateButton({
    Name = "Delete Config",
    Callback = function()
        local configName = configNameInput.Value
        if configName == "" or configName == nil then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please enter a config name!",
                Duration = 3,
                Image = 4483345998,
            })
            return
        end

        local filePath = configFolderPath .. "/" .. configName .. ".json"
        if isfile(filePath) then
            delfile(filePath)
            Rayfield:Notify({
                Title = "Success",
                Content = "Config '" .. configName .. "' deleted!",
                Duration = 3,
                Image = 4483345998,
            })
            updateConfigDropdown()
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Config not found!",
                Duration = 3,
                Image = 4483345998,
            })
        end
    end,
})

ConfigTab:CreateDivider()

ConfigTab:CreateLabel("Select & Load Config")

-- Config dropdown
local configDropdown = ConfigTab:CreateDropdown({
    Name = "Available Configs",
    Options = getConfigList(),
    CurrentOption = {getActiveConfig() or "None"},
    MultipleOptions = false,
    Flag = "ConfigDropdown",
    Callback = function(Options)
        -- Will be called when config is selected
    end,
})

-- Function to update dropdown options
function updateConfigDropdown()
    configDropdown:Refresh(getConfigList())
end

ConfigTab:CreateButton({
    Name = "Load Selected Config",
    Callback = function()
        local selectedConfig = configDropdown.Value[1]
        if selectedConfig == nil or selectedConfig == "None" then
            Rayfield:Notify({
                Title = "Error",
                Content = "Please select a config to load!",
                Duration = 3,
                Image = 4483345998,
            })
            return
        end

        local filePath = configFolderPath .. "/" .. selectedConfig .. ".json"
        if isfile(filePath) then
            local fileContent = readfile(filePath)
            local configData = game:GetService("HttpService"):JSONDecode(fileContent)

            -- Load config values
            weaponQTEOn = configData.weaponQTE or false
            selectedWeapon = configData.selectedWeapon or "Dagger"
            dodgeOn = configData.dodge or false
            autoBlockOn = configData.autoBlock or false
            autoAttackOn = configData.autoAttack or false
            selectedSkills = configData.selectedSkills or {"Strike"}

            -- Update UI
            WeaponQTEToggle:Set(weaponQTEOn)
            WeaponDropdown:Set(selectedWeapon)
            DodgeToggle:Set(dodgeOn)
            AutoBlockToggle:Set(autoBlockOn)
            AutoAttackToggle:Set(autoAttackOn)
            SkillSelector:Set(selectedSkills)

            -- Set as active config
            setActiveConfig(selectedConfig)

            Rayfield:Notify({
                Title = "Success",
                Content = "Config '" .. selectedConfig .. "' loaded!",
                Duration = 3,
                Image = 4483345998,
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Config file not found!",
                Duration = 3,
                Image = 4483345998,
            })
        end
    end,
})

ConfigTab:CreateButton({
    Name = "Auto Load Active Config",
    Callback = function()
        local activeConfig = getActiveConfig()
        if activeConfig and activeConfig ~= "" then
            local filePath = configFolderPath .. "/" .. activeConfig .. ".json"
            if isfile(filePath) then
                local fileContent = readfile(filePath)
                local configData = game:GetService("HttpService"):JSONDecode(fileContent)

                -- Load config values
                weaponQTEOn = configData.weaponQTE or false
                selectedWeapon = configData.selectedWeapon or "Dagger"
                dodgeOn = configData.dodge or false
                autoBlockOn = configData.autoBlock or false
                autoAttackOn = configData.autoAttack or false
                selectedSkills = configData.selectedSkills or {"Strike"}

                -- Update UI
                WeaponQTEToggle:Set(weaponQTEOn)
                WeaponDropdown:Set(selectedWeapon)
                DodgeToggle:Set(dodgeOn)
                AutoBlockToggle:Set(autoBlockOn)
                AutoAttackToggle:Set(autoAttackOn)
                SkillSelector:Set(selectedSkills)

                -- Update dropdown to show active config
                configDropdown:Set(activeConfig)

                Rayfield:Notify({
                    Title = "Success",
                    Content = "Active config '" .. activeConfig .. "' loaded!",
                    Duration = 3,
                    Image = 4483345998,
                })
            end
        else
            Rayfield:Notify({
                Title = "Info",
                Content = "No active config set yet!",
                Duration = 3,
                Image = 4483345998,
            })
        end
    end,
})

-- ===== SCRIPT PERSISTENCE (THE RIGHT WAY) =====
local queueteleport = queue_on_teleport or (syn and syn.queue_on_teleport)
local scriptUrl = "https://raw.githubusercontent.com/RakimuAzad/Silentheart-Hub/main/latest.lua"

local function persist()
    if queueteleport then
        queueteleport([[
            repeat task.wait() until game:IsLoaded()
            loadstring(game:HttpGet(']] .. scriptUrl .. [[?t=]] .. os.time() .. [['))()
        ]])
    end
end

-- Hook into teleportation using metatable
local TeleportService = game:GetService("TeleportService")
local mt = getrawmetatable(TeleportService)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if self == TeleportService and (method == "Teleport" or method == "TeleportToPlaceInstance" or method == "TeleportPartyAsync") then
        persist()
    end
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- CAPTURE SKILLS FROM UPDATESKILLS EVENT
game.ReplicatedStorage.Remotes.Information.UpdateSkills.OnClientEvent:Connect(function(skillList)
    availableSkills = {"Strike"}
    
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
            local infoRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5):WaitForChild("Information", 5):WaitForChild("RemoteFunction", 5)
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
                infoRemote:FireServer({true, true}, "DodgeMinigame")
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
                infoRemote:FireServer({true, false}, "DodgeMinigame")
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
                            ["Attacking"] = enemies[1]
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

-- ===== AUTO-LOAD ACTIVE CONFIG ON STARTUP =====
task.spawn(function()
    task.wait(1) -- Give the UI time to fully load
    local activeConfig = getActiveConfig()
    if activeConfig and activeConfig ~= "" then
        local filePath = configFolderPath .. "/" .. activeConfig .. ".json"
        if isfile(filePath) then
            local fileContent = readfile(filePath)
            local configData = game:GetService("HttpService"):JSONDecode(fileContent)

            -- Load config values
            weaponQTEOn = configData.weaponQTE or false
            selectedWeapon = configData.selectedWeapon or "Dagger"
            dodgeOn = configData.dodge or false
            autoBlockOn = configData.autoBlock or false
            autoAttackOn = configData.autoAttack or false
            selectedSkills = configData.selectedSkills or {"Strike"}

            -- Update UI
            WeaponQTEToggle:Set(weaponQTEOn)
            WeaponDropdown:Set(selectedWeapon)
            DodgeToggle:Set(dodgeOn)
            AutoBlockToggle:Set(autoBlockOn)
            AutoAttackToggle:Set(autoAttackOn)
            SkillSelector:Set(selectedSkills)

            -- Update dropdown to show active config
            configDropdown:Set(activeConfig)

            print("Auto-loaded config: " .. activeConfig)
        end
    end
end)
