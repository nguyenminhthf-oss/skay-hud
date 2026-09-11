-- Skay HUD Auto Farm Level Script for Blox Fruits
-- Version 1.0
-- This script automates leveling and farming in Blox Fruits

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:WaitForChild("Humanoid")

-- Configuration
local Config = {
    AutoFarm = true,
    TargetLevel = 100,
    NearestEnemyRange = 100,
    AttackCooldown = 0.5,
    HealthThreshold = 0.3, -- Flee when health is below 30%
    UseAbilities = true,
    AbilityCooldown = 3,
}

-- Variables
local LastAttackTime = 0
local LastAbilityTime = 0
local CurrentTarget = nil
local IsAttacking = false

-- Function to get nearest enemy
local function GetNearestEnemy()
    local nearestEnemy = nil
    local nearestDistance = Config.NearestEnemyRange
    
    local EnemiesFolder = workspace:FindFirstChild("Enemies")
    if not EnemiesFolder then
        return nil
    end
    
    for _, enemy in pairs(EnemiesFolder:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
            local distance = (enemy.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance and enemy.Humanoid.Health > 0 then
                nearestDistance = distance
                nearestEnemy = enemy
            end
        end
    end
    
    return nearestEnemy
end

-- Function to move towards enemy
local function MoveTowards(targetPosition)
    local UserInputService = game:GetService("UserInputService")
    local direction = (targetPosition - Character.HumanoidRootPart.Position).Unit
    
    Character.Humanoid:MoveTo(targetPosition)
end

-- Function to attack enemy
local function AttackEnemy(enemy)
    if not enemy or enemy.Humanoid.Health <= 0 then
        return false
    end
    
    local currentTime = tick()
    
    if currentTime - LastAttackTime >= Config.AttackCooldown then
        -- Move towards enemy
        MoveTowards(enemy.HumanoidRootPart.Position)
        
        -- Perform attack (simulate M1 click)
        local UserInputService = game:GetService("UserInputService")
        game:GetService("VirtualUser"):ClickButton1(Vector2.new(0, 0))
        
        LastAttackTime = currentTime
        return true
    end
    
    return false
end

-- Function to use abilities
local function UseAbility()
    local currentTime = tick()
    
    if Config.UseAbilities and currentTime - LastAbilityTime >= Config.AbilityCooldown then
        -- Press Z for ability (adjust key as needed)
        game:GetService("VirtualUser"):ClickButton1(Vector2.new(0, 0))
        LastAbilityTime = currentTime
        return true
    end
    
    return false
end

-- Function to check if should flee
local function ShouldFlee()
    local healthPercent = Humanoid.Health / Humanoid.MaxHealth
    return healthPercent < Config.HealthThreshold
end

-- Main farming loop
local function FarmLoop()
    if not Config.AutoFarm then
        return
    end
    
    -- Update character reference
    if not Character or Character.Parent == nil then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        Humanoid = Character:WaitForChild("Humanoid")
        return
    end
    
    -- Check if player is alive
    if Humanoid.Health <= 0 then
        return
    end
    
    -- Check if should flee
    if ShouldFlee() then
        print("Health low! Fleeing...")
        Character.Humanoid:MoveTo(Character.HumanoidRootPart.Position + Vector3.new(50, 0, 50))
        wait(2)
        return
    end
    
    -- Get nearest enemy
    CurrentTarget = GetNearestEnemy()
    
    if CurrentTarget and CurrentTarget.Parent then
        -- Move towards and attack enemy
        AttackEnemy(CurrentTarget)
        UseAbility()
    else
        -- If no enemy found, move to farming location
        print("No enemy found, moving to farming area...")
    end
end

-- Function to display HUD
local function CreateHUD()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkayHUD"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Name = "StatusLabel"
    TextLabel.Size = UDim2.new(0, 300, 0, 100)
    TextLabel.Position = UDim2.new(0, 10, 0, 10)
    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BackgroundTransparency = 0.5
    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Parent = ScreenGui
    
    -- Update HUD every frame
    RunService.RenderStepped:Connect(function()
        local levelInfo = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Level")
        local level = levelInfo and levelInfo.Value or "Unknown"
        local health = math.floor(Humanoid.Health)
        local maxHealth = math.floor(Humanoid.MaxHealth)
        
        TextLabel.Text = string.format(
            "Skay HUD Auto Farm\n" ..
            "Level: %s\n" ..
            "Health: %d/%d\n" ..
            "Status: %s",
            level,
            health,
            maxHealth,
            Config.AutoFarm and "Farming" or "Idle"
        )
    end)
end

-- Event connections
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    print("Character respawned, resuming farm...")
end)

-- Main execution
print("Skay HUD Auto Farm Script loaded!")
print("Starting auto farm for Blox Fruits...")

CreateHUD()

-- Main loop
while true do
    FarmLoop()
    wait(0.1)
end
