local tool = script.Parent
local remoteEvent = tool:WaitForChild("AttackEvent")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Settings
local DAMAGE = 20
local RANGE = 15
local COOLDOWN = 0.8

-- Create a table to track cooldowns on the server (Prevents Cheating)
local lastAttack = {}

remoteEvent.OnServerEvent:Connect(function(player)
    -- 1. Server-side Cooldown Check
    local currentTime = tick()
    if lastAttack[player.UserId] and (currentTime - lastAttack[player.UserId] < COOLDOWN) then
        return -- Too fast!
    end
    lastAttack[player.UserId] = currentTime

    local character = player.Character
    if not character then return end
    
    -- 2. Visual Effect (VFX)
    -- Assumes you have a part named "SlashEffect" in ReplicatedStorage
    local effectPart = ReplicatedStorage:FindFirstChild("SlashEffect")
    if effectPart then
        local vfx = effectPart:Clone()
        vfx.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        vfx.Parent = workspace
        vfx.ParticleEmitter:Emit(15)
        game.Debris:AddItem(vfx, 1) -- Auto-delete after 1 second
    end

    -- 3. Damage & Distance Check
    -- We look for enemies near where the player is looking
    local hitDetected = false
    for _, obj in pairs(workspace:GetChildren()) do
        local enemyHumanoid = obj:FindFirstChild("Humanoid")
        local enemyRoot = obj:FindFirstChild("HumanoidRootPart")
        
        if enemyHumanoid and enemyRoot and obj.Name ~= player.Name then
            local distance = (character.HumanoidRootPart.Position - enemyRoot.Position).Magnitude
            if distance <= RANGE then
                enemyHumanoid:TakeDamage(DAMAGE)
                hitDetected = true
            end
        end
    end
end)

