-- [[ DELTA BLOX FRUITS: FIXED GOAT EDITION ]] --

local Settings = {
    AutoFarm = false,
    AutoStats = false,
    ChestFarm = false,
    SafeMode = true,
    Weapon = "Combat", 
    Enemy = "Bandit",  
    Distance = 3 -- LOWERED HEIGHT (Fixes "too high" issue)
}

-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaUltimateHub"
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 420)
Main.Position = UDim2.new(0.5, -125, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "ULTIMATE GOAT HUB"
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
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

-- 1. FIXED AUTO FARM & ATTACK
CreateToggle("Auto-Farm & Punch", UDim2.new(0.05, 0, 0.15, 0), "AutoFarm")

spawn(function()
    while task.wait() do
        if Settings.AutoFarm then
            pcall(function()
                local Character = LocalPlayer.Character
                local Root = Character.HumanoidRootPart
                
                -- Auto Equip
                local tool = LocalPlayer.Backpack:FindFirstChild(Settings.Weapon) or Character:FindFirstChild(Settings.Weapon)
                if tool and not Character:FindFirstChild(Settings.Weapon) then 
                    Character.Humanoid:EquipTool(tool) 
                end
                
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == Settings.Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        -- BRING MOBS & POSITION
                        v.HumanoidRootPart.CanCollide = false
                        v.HumanoidRootPart.CFrame = Root.CFrame
                        Root.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, Settings.Distance, 0)
                        
                        -- FIXED AUTO HIT (Using Remote Events)
                        -- This bypasses VirtualUser and hits more consistently
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Attack", v.HumanoidRootPart)
                    end
                end
            end)
        end
    end
end)

-- [Other features: Stats, Chests, etc. remain the same as before]
CreateToggle("Auto-Stats (Melee)", UDim2.new(0.05, 0, 0.28, 0), "AutoStats")
spawn(function()
    while wait(1) do
        if Settings.AutoStats then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", "Melee", 1)
        end
    end
end)

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

local HopBtn = CreateButton = Instance.new("TextButton")
HopBtn.Size = UDim2.new(0.9, 0, 0, 35)
HopBtn.Position = UDim2.new(0.05, 0, 0.54, 0)
HopBtn.Text = "Server Hop"
HopBtn.Parent = Main
HopBtn.MouseButton1Click:Connect(function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
    for _, s in pairs(servers) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
        end
    end
end)
