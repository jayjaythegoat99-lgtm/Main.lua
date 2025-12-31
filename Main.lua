-- [[ DELTA BLOX FRUITS: THE GOAT EDITION V9.2 - UI FORCE ]] --

local Settings = {
    AutoFarm = false,
    AutoStats = false,
    ChestFarm = false,
    AutoClicker = false,
    ClickPos = Vector2.new(0, 0),
    Weapon = "Combat", 
    Enemy = "Bandit",
    QuestNPC = "Bandit Quest Giver",
    QuestName = "BanditQuest1",
    QuestLevel = 1,
    Distance = 2.8,
    ClickJitter = 4
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Destroy old UI if it exists
if game.CoreGui:FindFirstChild("DeltaV9_Fixed") then
    game.CoreGui.DeltaV9_Fixed:Destroy()
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaV9_Fixed"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- --- 1. THE MAIN MENU FRAME ---
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 250, 0, 520)
Main.Position = UDim2.new(0.5, -125, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(0, 255, 150)
Main.Active = true
Main.Draggable = true
Main.Visible = true -- FORCE VISIBLE
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ULTIMATE HUB V9.2"
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Main

-- --- 2. THE TOGGLE BUTTON (Small green button) ---
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 5, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.Text = "D"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- --- 3. HELPER FUNCTION FOR TOGGLES ---
local function AddToggle(text, yPos, settingName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = Main
    
    btn.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        btn.Text = text .. (Settings[settingName] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(50, 50, 50)
    end)
end

-- Adding Features
AddToggle("Auto-Farm & Quest", 50, "AutoFarm")
AddToggle("Auto-Stats (Melee)", 95, "AutoStats")
AddToggle("Chest Farm", 140, "ChestFarm")

-- Server Hop Button
local HopBtn = Instance.new("TextButton")
HopBtn.Size = UDim2.new(0.9, 0, 0, 35)
HopBtn.Position = UDim2.new(0.05, 0, 0, 185)
HopBtn.Text = "Server Hop"
HopBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBtn.Parent = Main
HopBtn.MouseButton1Click:Connect(function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
    for _, s in pairs(servers) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
            break
        end
    end
end)

-- --- 4. AUTO CLICKER SECTION ---
local SetPosBtn = Instance.new("TextButton")
SetPosBtn.Size = UDim2.new(0.9, 0, 0, 35)
SetPosBtn.Position = UDim2.new(0.05, 0, 0, 250)
SetPosBtn.Text = "Set Click Position"
SetPosBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
SetPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetPosBtn.Parent = Main

SetPosBtn.MouseButton1Click:Connect(function()
    SetPosBtn.Text = "CLICK ANYWHERE..."
    local con; con = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Settings.ClickPos = Vector2.new(input.Position.X, input.Position.Y)
            SetPosBtn.Text = "POS SET!"
            con:Disconnect()
        end
    end)
end)

AddToggle("Auto Clicker (0.01)", 295, "AutoClicker")

-- --- 5. LOGIC LOOPS ---

-- Clicker Loop
spawn(function()
    while task.wait(0.01) do
        if Settings.AutoClicker then
            pcall(function()
                local rx = Settings.ClickPos.X + math.random(-Settings.ClickJitter, Settings.ClickJitter)
                local ry = Settings.ClickPos.Y + math.random(-Settings.ClickJitter, Settings.ClickJitter)
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(rx, ry))
            end)
        end
    end
end)

-- Farm Loop
spawn(function()
    while task.wait() do
        if Settings.AutoFarm then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char.HumanoidRootPart
                if not LocalPlayer.PlayerGui.Main.Quest.Visible then
                    local npc = workspace.NPCs:FindFirstChild(Settings.QuestNPC)
                    if npc then
                        root.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.5)
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", Settings.QuestName, Settings.QuestLevel)
                    end
                else
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == Settings.Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            root.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0)
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("Attack", v.HumanoidRootPart)
                            break
                        end
                    end
                end
            end)
        end
    end
end)

-- Stat Loop
spawn(function()
    while task.wait(1) do
        if Settings.AutoStats then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Melee", 1)
        end
    end
end)

-- Delete Button
local Del = Instance.new("TextButton")
Del.Size = UDim2.new(0.9, 0, 0, 35)
Del.Position = UDim2.new(0.05, 0, 0, 470)
Del.Text = "DELETE HUB"
Del.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Del.TextColor3 = Color3.fromRGB(255, 255, 255)
Del.Parent = Main
Del.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
