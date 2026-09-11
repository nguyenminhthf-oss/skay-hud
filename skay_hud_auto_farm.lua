-- Skay HUD Auto Farm Level Script for Blox Fruits
-- Version 2.0 with Attack Cooldown Menu
-- This script automates leveling and farming in Blox Fruits

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
local MenuOpen = false

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

-- Function to update attack cooldown
local function UpdateAttackCooldown(value)
    Config.AttackCooldown = value
    print("Attack Cooldown updated to: " .. value .. " seconds")
end

-- Function to create HUD with Menu
local function CreateHUD()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkayHUD"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Status Label
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Name = "StatusLabel"
    TextLabel.Size = UDim2.new(0, 350, 0, 120)
    TextLabel.Position = UDim2.new(0, 10, 0, 10)
    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BackgroundTransparency = 0.5
    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Parent = ScreenGui
    
    -- Menu Toggle Button
    local MenuButton = Instance.new("TextButton")
    MenuButton.Name = "MenuButton"
    MenuButton.Size = UDim2.new(0, 100, 0, 30)
    MenuButton.Position = UDim2.new(0, 10, 0, 135)
    MenuButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MenuButton.TextSize = 12
    MenuButton.Font = Enum.Font.GothamBold
    MenuButton.Text = "☰ Menu"
    MenuButton.Parent = ScreenGui
    
    -- Menu Frame
    local MenuFrame = Instance.new("Frame")
    MenuFrame.Name = "MenuFrame"
    MenuFrame.Size = UDim2.new(0, 300, 0, 200)
    MenuFrame.Position = UDim2.new(0, 10, 0, 170)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MenuFrame.BackgroundTransparency = 0.3
    MenuFrame.Visible = false
    MenuFrame.Parent = ScreenGui
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚙️ Attack Cooldown Menu"
    Title.Parent = MenuFrame
    
    -- Attack Cooldown Label
    local AttackLabel = Instance.new("TextLabel")
    AttackLabel.Name = "AttackLabel"
    AttackLabel.Size = UDim2.new(1, -20, 0, 25)
    AttackLabel.Position = UDim2.new(0, 10, 0, 40)
    AttackLabel.BackgroundTransparency = 1
    AttackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    AttackLabel.TextSize = 12
    AttackLabel.Font = Enum.Font.Gotham
    AttackLabel.Text = "Attack Cooldown: 0.5s"
    AttackLabel.Parent = MenuFrame
    
    -- Slider
    local Slider = Instance.new("Frame")
    Slider.Name = "Slider"
    Slider.Size = UDim2.new(1, -20, 0, 20)
    Slider.Position = UDim2.new(0, 10, 0, 70)
    Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Slider.Parent = MenuFrame
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "SliderButton"
    SliderButton.Size = UDim2.new(0, 20, 1, 0)
    SliderButton.Position = UDim2.new(0.8, 0, 0, 0)
    SliderButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    SliderButton.Text = ""
    SliderButton.Parent = Slider
    
    -- Quick buttons
    local Button01 = Instance.new("TextButton")
    Button01.Name = "Button01"
    Button01.Size = UDim2.new(0, 60, 0, 25)
    Button01.Position = UDim2.new(0, 10, 0, 100)
    Button01.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button01.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button01.TextSize = 11
    Button01.Font = Enum.Font.Gotham
    Button01.Text = "0.1s"
    Button01.Parent = MenuFrame
    
    local Button03 = Instance.new("TextButton")
    Button03.Name = "Button03"
    Button03.Size = UDim2.new(0, 60, 0, 25)
    Button03.Position = UDim2.new(0, 80, 0, 100)
    Button03.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button03.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button03.TextSize = 11
    Button03.Font = Enum.Font.Gotham
    Button03.Text = "0.3s"
    Button03.Parent = MenuFrame
    
    local Button05 = Instance.new("TextButton")
    Button05.Name = "Button05"
    Button05.Size = UDim2.new(0, 60, 0, 25)
    Button05.Position = UDim2.new(0, 150, 0, 100)
    Button05.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button05.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button05.TextSize = 11
    Button05.Font = Enum.Font.Gotham
    Button05.Text = "0.5s"
    Button05.Parent = MenuFrame
    
    local ToggleFarmButton = Instance.new("TextButton")
    ToggleFarmButton.Name = "ToggleFarmButton"
    ToggleFarmButton.Size = UDim2.new(1, -20, 0, 30)
    ToggleFarmButton.Position = UDim2.new(0, 10, 0, 135)
    ToggleFarmButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    ToggleFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleFarmButton.TextSize = 12
    ToggleFarmButton.Font = Enum.Font.GothamBold
    ToggleFarmButton.Text = "Farm: ON"
    ToggleFarmButton.Parent = MenuFrame
    
    -- Button Events
    MenuButton.MouseButton1Click:Connect(function()
        MenuOpen = not MenuOpen
        MenuFrame.Visible = MenuOpen
    end)
    
    Button01.MouseButton1Click:Connect(function()
        UpdateAttackCooldown(0.1)
        AttackLabel.Text = "Attack Cooldown: 0.1s"
        SliderButton.Position = UDim2.new(0, 0, 0, 0)
    end)
    
    Button03.MouseButton1Click:Connect(function()
        UpdateAttackCooldown(0.3)
        AttackLabel.Text = "Attack Cooldown: 0.3s"
        SliderButton.Position = UDim2.new(0.4, 0, 0, 0)
    end)
    
    Button05.MouseButton1Click:Connect(function()
        UpdateAttackCooldown(0.5)
        AttackLabel.Text = "Attack Cooldown: 0.5s"
        SliderButton.Position = UDim2.new(0.8, 0, 0, 0)
    end)
    
    ToggleFarmButton.MouseButton1Click:Connect(function()
        Config.AutoFarm = not Config.AutoFarm
        ToggleFarmButton.Text = Config.AutoFarm and "Farm: ON" or "Farm: OFF"
        ToggleFarmButton.BackgroundColor3 = Config.AutoFarm and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)
    
    -- Slider drag functionality
    local dragging = false
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.InputBegan:Connect(function(input, gameProcessed)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = LocalPlayer:GetMouse()
            local sliderPos = (mouse.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X
            sliderPos = math.clamp(sliderPos, 0, 1)
            
            local cooldown = 0.5 - (sliderPos * 0.4) -- 0.1 to 0.5
            cooldown = math.floor(cooldown * 10) / 10 -- Round to 1 decimal
            
            UpdateAttackCooldown(cooldown)
            AttackLabel.Text = "Attack Cooldown: " .. string.format("%.1f", cooldown) .. "s"
            SliderButton.Position = UDim2.new(sliderPos, -10, 0, 0)
        end
    end)
    
    -- Update HUD every frame
    RunService.RenderStepped:Connect(function()
        local levelInfo = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Level")
        local level = levelInfo and levelInfo.Value or "Unknown"
        local health = math.floor(Humanoid.Health)
        local maxHealth = math.floor(Humanoid.MaxHealth)
        
        TextLabel.Text = string.format(
            "Skay HUD Auto Farm v2.0\n" ..
            "Level: %s\n" ..
            "Health: %d/%d\n" ..
            "Attack CD: %.1fs\n" ..
            "Status: %s",
            level,
            health,
            maxHealth,
            Config.AttackCooldown,
            Config.AutoFarm and "🟢 Farming" or "🔴 Idle"
        )
    end)
end

-- Event connections
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    print("Character respawned, resuming farm...")
end)

-- Hotkey to toggle menu (Press M)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        MenuOpen = not MenuOpen
        local gui = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("SkayHUD")
        if gui then
            gui:FindFirstChild("MenuFrame").Visible = MenuOpen
        end
    end
end)

-- Main execution
print("Skay HUD Auto Farm Script v2.0 loaded!")
print("Press M to open menu or click the ☰ Menu button")
print("Starting auto farm for Blox Fruits...")

CreateHUD()

-- Main loop
while true do
    FarmLoop()
    wait(0.1)
end
