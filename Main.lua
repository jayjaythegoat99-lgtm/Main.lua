-- [[ DELTA BLOX FRUITS: THE GOAT EDITION V9.1 - FIXED ]] --

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

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaV9_Fixed"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- --- 1. FIXED OPEN/CLOSE TOGGLE BUTTON ---
local OpenCloseBtn = Instance.new("TextButton")
OpenCloseBtn.Size = UDim2.new(0, 50, 0, 50)
OpenCloseBtn.Position = UDim2.new(0, 10, 0.5, -25)
OpenCloseBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
OpenCloseBtn.Text = "D"
OpenCloseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenCloseBtn.Font = Enum.Font.GothamBold
OpenCloseBtn.TextSize = 25
OpenCloseBtn.Parent = ScreenGui
OpenCloseBtn.Draggable = true 

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 25)
UICornerBtn.Parent = OpenCloseBtn

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 560)
Main.Position = UDim2.new(0.5, -125, 0.5, -280)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Visible = true 
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = Main

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 150)
UIStroke.Parent = Main

-- Toggle Function for the 'D' Button
OpenCloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "ULTIMATE HUB V9.1"
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

-- Helper: Create Toggles
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

-- --- 2. GAMEPLAY FEATURES ---
CreateToggle("Auto-Quest & Farm", UDim2.new(0.05, 0, 0.1, 0), "AutoFarm")
CreateToggle("Auto-Stats (Melee)", UDim2.new(0.05, 0, 0.18, 0), "AutoStats")
CreateToggle("Chest Farm", UDim2.new(0.05, 0, 0.26, 0), "ChestFarm")

-- Server Hopper
local HopBtn = Instance.new("TextButton")
HopBtn.Size = UDim2.new(0.9, 0, 0, 35)
HopBtn.Position = UDim2.new(0.05, 0, 0.34, 0)
HopBtn.Text = "Server Hop"
HopBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 150)
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBtn.Parent = Main
HopBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
        for _, s in pairs(servers) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
    end)
end)

-- --- 3. ULTRA FAST AUTO-CLICKER ---
local SetPosBtn = Instance.new("TextButton")
SetPosBtn.Size = UDim2.new(0.9, 0, 0, 35)
SetPosBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
SetPosBtn.Text = "Set Click Position"
SetPosBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 180)
SetPosBtn.Parent = Main

SetPosBtn.MouseButton1Click:Connect(function()
    SetPosBtn.Text = "CLICK TARGET NOW..."
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Settings.ClickPos = Vector2.new(input.Position.X, input.Position.Y)
            SetPosBtn.Text = "POS LOCKED"
            connection:Disconnect()
        end
    end)
end)

CreateToggle("Auto Clicker (0.01)", UDim2.new(0.05, 0, 0.63, 0), "AutoClicker")

-- --- 4. BACKGROUND LOOPS ---
-- Clicker Loop
spawn(function()
    while true do
        task.wait(0.01)
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

-- Stats Loop
spawn(function()
    while task.wait(1) do
        if Settings.AutoStats then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Melee", 1)
        end
    end
end)

-- Unload
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0.9, 0, 0, 35)
Close.Position = UDim2.new(0.05, 0, 0.92, 0)
Close.Text = "DELETE HUB"
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Parent = Main
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
