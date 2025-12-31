-- [[ DELTA BLOX FRUITS: THE GOAT EDITION V4 ]] --

local Settings = {
    AutoFarm = false,
    AutoStats = false,
    ChestFarm = false,
    SafeMode = true,
    FastAttack = true,
    Weapon = "Combat", 
    Enemy = "Bandit",  
    QuestNPC = "Bandit Quest Giver", -- Name of the NPC to get quest from
    QuestName = "BanditQuest1",      -- Internal name of the quest
    QuestLevel = 1,                 -- Quest level requirement
    Distance = 2.5     
}

-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaUltimateHub"
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 480)
Main.Position = UDim2.new(0.5, -125, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "ULTIMATE GOAT HUB V4"
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

-- Helper: Create Toggle Buttons
local function CreateToggle(text, pos, varName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = Main
    
    btn.MouseButton1Click:Connect(function()
        Settings[varName] = not Settings[varName]
        btn.Text = text .. (Settings[varName] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[varName] and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(45, 45, 45)
    end)
    return btn
end

-- 1. AUTO QUEST + FARM LOGIC
CreateToggle("Auto-Quest & Farm", UDim2.new(0.05, 0, 0.12, 0), "AutoFarm")

spawn(function()
    while task.wait() do
        if Settings.AutoFarm then
            pcall(function()
                local Character = LocalPlayer.Character
                local Root = Character.HumanoidRootPart
                
                -- Check if we have a quest
                local hasQuest = LocalPlayer.PlayerGui.Main.Quest.Visible
                
                if not hasQuest then
                    -- Go get the quest
                    local npc = workspace.NPCs:FindFirstChild(Settings.QuestNPC)
                    if npc then
                        Root.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.5)
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", Settings.QuestName, Settings.QuestLevel)
                    end
                else
                    -- We have a quest, go kill the enemies
                    -- Auto Equip Logic
                    local tool = LocalPlayer.Backpack:FindFirstChild(Settings.Weapon) or Character:FindFirstChild(Settings.Weapon)
                    if tool and not Character:FindFirstChild(Settings.Weapon) then 
                        Character.Humanoid:EquipTool(tool) 
                    end
                    
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == Settings.Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            -- Bring Mobs & Position
                            v.HumanoidRootPart.CanCollide = false
                            v.HumanoidRootPart.CFrame = Root.CFrame
                            Root.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0)
                            
                            -- Attack
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", v.HumanoidRootPart)
                            if Settings.FastAttack then
                                task.spawn(function()
                                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", v.HumanoidRootPart)
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- [PREVIOUS FEATURES INCLUDED BELOW]
CreateToggle("Auto-Stats (Melee)", UDim2.new(0.05, 0, 0.22, 0), "AutoStats")
spawn(function()
    while task.wait(1) do
        if Settings.AutoStats then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Melee", 1)
        end
    end
end)

CreateToggle("Chest Farm", UDim2.new(0.05, 0, 0.32, 0), "ChestFarm")
spawn(function()
    while task.wait(0.5) do
        if Settings.ChestFarm then
            for _, v in pairs(workspace:GetChildren()) do
                if v.Name:find("Chest") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                    task.wait(0.2)
                end
            end
        end
    end
end)

local HopBtn = Instance.new("TextButton")
HopBtn.Size = UDim2.new(0.9, 0, 0, 35)
HopBtn.Position = UDim2.new(0.05, 0, 0.42, 0)
HopBtn.Text = "Server Hop"
HopBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 150)
HopBtn.Parent = Main
HopBtn.MouseButton1Click:Connect(function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
    for _, s in pairs(servers) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
        end
    end
end)

CreateToggle("Safe Mode", UDim2.new(0.05, 0, 0.52, 0), "SafeMode")
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function()
        if Settings.SafeMode then Main.Visible = false; task.wait(8); Main.Visible = true end
    end)
end)

LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0.9, 0, 0, 35)
Close.Position = UDim2.new(0.05, 0, 0.88, 0)
Close.Text = "UNLOAD SCRIPT"
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.Parent = Main
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
