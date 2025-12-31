-- [[ DELTA BLOX FRUITS ALL-IN-ONE ]] --

local Library = {
    Farm = false,
    Stats = false,
    Chest = false,
    SafeMode = true,
    Weapon = "Combat", -- CHANGE THIS TO YOUR WEAPON NAME
    Enemy = "Bandit"    -- CHANGE THIS TO YOUR QUEST ENEMY
}

-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaHub"
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 380)
Main.Position = UDim2.new(0.5, -125, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "DELTA ULTIMATE HUB"
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Parent = Main

-- Helper: Create Buttons
local function CreateButton(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = Main
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 1. Auto Farm Logic
local FarmBtn = CreateButton("Auto-Farm: OFF", UDim2.new(0.05, 0, 0.15, 0), function()
    Library.Farm = not Library.Farm
end)

spawn(function()
    while wait() do
        if Library.Farm then
            pcall(function()
                local enemy = workspace.Enemies:FindFirstChild(Library.Enemy)
                if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    -- Auto Equip
                    local tool = LocalPlayer.Backpack:FindFirstChild(Library.Weapon)
                    if tool then LocalPlayer.Character.Humanoid:EquipTool(tool) end
                    
                    -- Teleport and Attack
                    LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                end
            end)
        end
    end
end)

-- 2. Auto Stats
CreateButton("Add Stats: Melee", UDim2.new(0.05, 0, 0.3, 0), function()
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", "Melee", 1)
end)

-- 3. Chest Farm
CreateButton("Chest Farm", UDim2.new(0.05, 0, 0.45, 0), function()
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name:find("Chest") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
            wait(0.5)
        end
    end
end)

-- 4. Server Hopper
CreateButton("Server Hop", UDim2.new(0.05, 0, 0.6, 0), function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
    for _, s in pairs(servers) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
            break
        end
    end
end)

-- 5. Safe Mode / Anti-AFK
local AntiAFK = CreateButton("Safe Mode: ON", UDim2.new(0.05, 0, 0.75, 0), function()
    Library.SafeMode = not Library.SafeMode
end)

LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

print("Delta Hub Loaded!")
