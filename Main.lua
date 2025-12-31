-- [[ DELTA BLOX FRUITS: THE GOAT EDITION ]] --

local Settings = {
    AutoFarm = false,
    AutoStats = false,
    ChestFarm = false,
    SafeMode = true,
    Weapon = "Combat", -- Change to your weapon/fruit name
    Enemy = "Bandit",  -- Change to your current quest mob
    Distance = 5       -- Height above enemies (God Mode)
}

-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaUltimateHub"
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 420)
Main.Position = UDim2.new(0.5, -125, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "ULTIMATE GOAT HUB"
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

-- Helper: Create Toggle Buttons
local function CreateToggle(text, pos, varName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = Main
    
    btn.MouseButton1Click:Connect(function()
        Settings[varName] = not Settings[varName]
        btn.Text = text .. (Settings[varName] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[varName] and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(50, 50, 50)
    end)
    return btn
end

-- 1. AUTO FARM & PUNCH & BRING MOBS
CreateToggle("Auto-Farm & Punch", UDim2.new(0.05, 0, 0.15, 0), "AutoFarm")

spawn(function()
    while wait() do
        if Settings.AutoFarm then
            pcall(function()
                local Character = LocalPlayer.Character
                local Root = Character.HumanoidRootPart
                
                -- Equip Weapon
                local tool = LocalPlayer.Backpack:FindFirstChild(Settings.Weapon)
                if tool then Character.Humanoid:EquipTool(tool) end
                
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == Settings.Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        -- BRING MOBS: Pull enemy to you
                        v.HumanoidRootPart.CFrame = Root.CFrame
                        v.HumanoidRootPart.CanCollide = false
                        
                        -- GOD MODE POSITION: Stay above them
                        Root.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0)
                        
                        -- AUTO PUNCH
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(0,0))
                    end
                end
            end)
        end
    end
end)

-- 2. AUTO STATS (Melee)
CreateToggle("Auto-Stats (Melee)", UDim2.new(0.05, 0, 0.28, 0), "AutoStats")
spawn(function()
    while wait(1) do
        if Settings.AutoStats then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", "Melee", 1)
        end
    end
end)

-- 3. CHEST COLLECTOR
CreateToggle("Chest Farm", UDim2.new(0.05, 0, 0.41, 0), "ChestFarm")
spawn(function()
    while wait(0.5) do
        if Settings.ChestFarm then
            for _, v in pairs(workspace:GetChildren()) do
                if v.Name:find("Chest") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                    wait(0.2)
                end
            end
        end
    end
end)

-- 4. SERVER HOPPER
local HopBtn = Instance.new("TextButton")
HopBtn.Size = UDim2.new(0.9, 0, 0, 35)
HopBtn.Position = UDim2.new(0.05, 0, 0.54, 0)
HopBtn.Text = "Server Hop"
HopBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBtn.Parent = Main
HopBtn.MouseButton1Click:Connect(function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
    for _, s in pairs(servers) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
        end
    end
end)

-- 5. SAFE MODE & ANTI-AFK
local SafeBtn = CreateToggle("Safe Mode", UDim2.new(0.05, 0, 0.67, 0), "SafeMode")
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function()
        if Settings.SafeMode then
            Main.Visible = false
            wait(10)
            Main.Visible = true
        end
    end)
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- 6. CLOSE BUTTON
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0.9, 0, 0, 35)
Close.Position = UDim2.new(0.05, 0, 0.85, 0)
Close.Text = "CLOSE GUI"
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Parent = Main
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

print("ULTIMATE GOAT HUB LOADED")
