-- Skay HUD - Advanced Auto Farm Script for Blox Fruits
-- Version 3.0
-- This script includes advanced farming features similar to Quantum HUD

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Configuration
local Config = {
    -- Farm Settings
    AutoFarm = true,
    FarmType = "NPC", -- NPC or Player
    AttackCooldown = 0.1,
    UseSkills = true,
    SkillCooldown = 1,
    AutoDodge = true,
    DodgeDistance = 50,
    
    -- Health Settings
    FleeHealth = 0.3,
    FleeDistance = 100,
    
    -- Target Settings
    SearchRange = 150,
    PreferBoss = false,
    MaxLevel = 500,
}

-- Game Services
local RemoteConnection = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")

-- Variables
local LastAttackTime = 0
local LastSkillTime = 0
local CurrentTarget = nil
local MenuOpen = false
local FarmActive = true

-- Function to get all NPCs
local function GetAllNPCs()
    local NPCs = {}
    local EnemiesFolder = workspace:FindFirstChild("Enemies")
    
    if not EnemiesFolder then return NPCs end
    
    for _, npc in pairs(EnemiesFolder:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
            local humanoid = npc.Humanoid
            local rootPart = npc.HumanoidRootPart
            
            if humanoid.Health > 0 then
                table.insert(NPCs, {
                    Object = npc,
                    Distance = (rootPart.Position - RootPart.Position).Magnitude,
                    Health = humanoid.Health,
                    MaxHealth = humanoid.MaxHealth,
                })
            end
        end
    end
    
    return NPCs
end

-- Function to get nearest NPC
local function GetNearestNPC()
    local NPCs = GetAllNPCs()
    
    if #NPCs == 0 then return nil end
    
    table.sort(NPCs, function(a, b)
        return a.Distance < b.Distance
    end)
    
    local nearest = NPCs[1]
    
    if nearest.Distance <= Config.SearchRange then
        return nearest.Object
    end
    
    return nil
end

-- Function to attack NPC
local function AttackNPC(target)
    if not target or not target:FindFirstChild("Humanoid") then
        return false
    end
    
    local humanoid = target.Humanoid
    if humanoid.Health <= 0 then
        return false
    end
    
    local currentTime = tick()
    
    if currentTime - LastAttackTime >= Config.AttackCooldown then
        -- Move to target
        local targetPos = target:FindFirstChild("HumanoidRootPart").Position
        Character.Humanoid:MoveTo(targetPos)
        
        -- Attack (M1)
        game:GetService("VirtualUser"):ClickButton1(Vector2.new(0, 0))
        
        LastAttackTime = currentTime
        return true
    end
    
    return false
end

-- Function to use skill
local function UseSkill()
    local currentTime = tick()
    
    if not Config.UseSkills then return end
    
    if currentTime - LastSkillTime >= Config.SkillCooldown then
        -- Send skill input (Z key)
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:ClickButton1(Vector2.new(0, 0))
        LastSkillTime = currentTime
    end
end

-- Function to auto dodge
local function AutoDodge()
    if not Config.AutoDodge then return end
    
    -- Get nearby enemies
    local NPCs = GetAllNPCs()
    
    if #NPCs > 0 then
        local nearestNPC = NPCs[1]
        local npcPos = nearestNPC.Object:FindFirstChild("HumanoidRootPart").Position
        local distance = (npcPos - RootPart.Position).Magnitude
        
        if distance < Config.DodgeDistance then
            -- Dodge away
            local dodgeDirection = (RootPart.Position - npcPos).Unit
            local dodgePos = RootPart.Position + (dodgeDirection * Config.DodgeDistance)
            
            Character.Humanoid:MoveTo(dodgePos)
        end
    end
end

-- Main farming loop
local function FarmLoop()
    if not FarmActive then return end
    
    -- Update character
    if not Character or Character.Parent == nil then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        Humanoid = Character:WaitForChild("Humanoid")
        RootPart = Character:WaitForChild("HumanoidRootPart")
        return
    end
    
    -- Check if alive
    if Humanoid.Health <= 0 then
        return
    end
    
    -- Get health percentage
    local healthPercent = Humanoid.Health / Humanoid.MaxHealth
    
    -- Flee if health too low
    if healthPercent < Config.FleeHealth then
        local fleeDir = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
        Character.Humanoid:MoveTo(RootPart.Position + (fleeDir * Config.FleeDistance))
        return
    end
    
    -- Get nearest NPC
    CurrentTarget = GetNearestNPC()
    
    if CurrentTarget then
        AttackNPC(CurrentTarget)
        UseSkill()
        AutoDodge()
    end
end

-- Function to create advanced HUD
local function CreateAdvancedHUD()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Remove old GUI if exists
    if PlayerGui:FindFirstChild("SkayHUD") then
        PlayerGui:FindFirstChild("SkayHUD"):Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkayHUD"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui
    
    -- Main Panel
    local MainPanel = Instance.new("Frame")
    MainPanel.Name = "MainPanel"
    MainPanel.Size = UDim2.new(0, 400, 0, 280)
    MainPanel.Position = UDim2.new(0, 20, 0, 20)
    MainPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainPanel.BorderSizePixel = 0
    MainPanel.Parent = ScreenGui
    
    -- Add border effect
    local BorderCorner = Instance.new("UICorner")
    BorderCorner.CornerRadius = UDim.new(0, 10)
    BorderCorner.Parent = MainPanel
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Header.BorderSizePixel = 0
    Header.Parent = MainPanel
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "⚡ SKAY HUD v3.0"
    TitleLabel.Parent = Header
    
    -- Status Display
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Size = UDim2.new(1, -20, 0, 100)
    StatusFrame.Position = UDim2.new(0, 10, 0, 60)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Parent = MainPanel
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -10, 1, -10)
    StatusLabel.Position = UDim2.new(0, 5, 0, 5)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.Parent = StatusFrame
    
    -- Controls Panel
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Name = "ControlsFrame"
    ControlsFrame.Size = UDim2.new(1, -20, 0, 110)
    ControlsFrame.Position = UDim2.new(0, 10, 0, 170)
    ControlsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    ControlsFrame.BorderSizePixel = 0
    ControlsFrame.Parent = MainPanel
    
    local ControlsCorner = Instance.new("UICorner")
    ControlsCorner.CornerRadius = UDim.new(0, 8)
    ControlsCorner.Parent = ControlsFrame
    
    -- Toggle Farm Button
    local ToggleFarmBtn = Instance.new("TextButton")
    ToggleFarmBtn.Name = "ToggleFarmBtn"
    ToggleFarmBtn.Size = UDim2.new(0.5, -5, 0, 30)
    ToggleFarmBtn.Position = UDim2.new(0, 5, 0, 5)
    ToggleFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    ToggleFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleFarmBtn.TextSize = 12
    ToggleFarmBtn.Font = Enum.Font.GothamBold
    ToggleFarmBtn.Text = "▶ START FARM"
    ToggleFarmBtn.Parent = ControlsFrame
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.CornerRadius = UDim.new(0, 6)
    ToggleBtnCorner.Parent = ToggleFarmBtn
    
    -- Skills Toggle Button
    local ToggleSkillsBtn = Instance.new("TextButton")
    ToggleSkillsBtn.Name = "ToggleSkillsBtn"
    ToggleSkillsBtn.Size = UDim2.new(0.5, -5, 0, 30)
    ToggleSkillsBtn.Position = UDim2.new(0.5, 5, 0, 5)
    ToggleSkillsBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    ToggleSkillsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleSkillsBtn.TextSize = 12
    ToggleSkillsBtn.Font = Enum.Font.GothamBold
    ToggleSkillsBtn.Text = "✓ SKILLS ON"
    ToggleSkillsBtn.Parent = ControlsFrame
    
    local SkillsBtnCorner = Instance.new("UICorner")
    SkillsBtnCorner.CornerRadius = UDim.new(0, 6)
    SkillsBtnCorner.Parent = ToggleSkillsBtn
    
    -- Dodge Toggle Button
    local ToggleDodgeBtn = Instance.new("TextButton")
    ToggleDodgeBtn.Name = "ToggleDodgeBtn"
    ToggleDodgeBtn.Size = UDim2.new(0.5, -5, 0, 30)
    ToggleDodgeBtn.Position = UDim2.new(0, 5, 0, 40)
    ToggleDodgeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 100)
    ToggleDodgeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleDodgeBtn.TextSize = 12
    ToggleDodgeBtn.Font = Enum.Font.GothamBold
    ToggleDodgeBtn.Text = "✓ AUTO DODGE"
    ToggleDodgeBtn.Parent = ControlsFrame
    
    local DodgeBtnCorner = Instance.new("UICorner")
    DodgeBtnCorner.CornerRadius = UDim.new(0, 6)
    DodgeBtnCorner.Parent = ToggleDodgeBtn
    
    -- Speed Slider Button
    local SpeedBtn = Instance.new("TextButton")
    SpeedBtn.Name = "SpeedBtn"
    SpeedBtn.Size = UDim2.new(0.5, -5, 0, 30)
    SpeedBtn.Position = UDim2.new(0.5, 5, 0, 40)
    SpeedBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedBtn.TextSize = 12
    SpeedBtn.Font = Enum.Font.GothamBold
    SpeedBtn.Text = "⚙ SPEED: 0.1s"
    SpeedBtn.Parent = ControlsFrame
    
    local SpeedBtnCorner = Instance.new("UICorner")
    SpeedBtnCorner.CornerRadius = UDim.new(0, 6)
    SpeedBtnCorner.Parent = SpeedBtn
    
    -- Button Events
    ToggleFarmBtn.MouseButton1Click:Connect(function()
        FarmActive = not FarmActive
        ToggleFarmBtn.Text = FarmActive and "⏸ STOP FARM" or "▶ START FARM"
        ToggleFarmBtn.BackgroundColor3 = FarmActive and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    end)
    
    ToggleSkillsBtn.MouseButton1Click:Connect(function()
        Config.UseSkills = not Config.UseSkills
        ToggleSkillsBtn.Text = Config.UseSkills and "✓ SKILLS ON" or "✗ SKILLS OFF"
    end)
    
    ToggleDodgeBtn.MouseButton1Click:Connect(function()
        Config.AutoDodge = not Config.AutoDodge
        ToggleDodgeBtn.Text = Config.AutoDodge and "✓ AUTO DODGE" or "✗ NO DODGE"
    end)
    
    SpeedBtn.MouseButton1Click:Connect(function()
        if Config.AttackCooldown == 0.1 then
            Config.AttackCooldown = 0.3
            SpeedBtn.Text = "⚙ SPEED: 0.3s"
        elseif Config.AttackCooldown == 0.3 then
            Config.AttackCooldown = 0.5
            SpeedBtn.Text = "⚙ SPEED: 0.5s"
        else
            Config.AttackCooldown = 0.1
            SpeedBtn.Text = "⚙ SPEED: 0.1s"
        end
    end)
    
    -- Update HUD
    RunService.RenderStepped:Connect(function()
        local levelInfo = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Level")
        local level = levelInfo and levelInfo.Value or 0
        local health = math.floor(Humanoid.Health)
        local maxHealth = math.floor(Humanoid.MaxHealth)
        local npcCount = #GetAllNPCs()
        
        StatusLabel.Text = string.format(
            "📊 LEVEL: %d\n" ..
            "❤ HEALTH: %d/%d (%.1f%%)\n" ..
            "🎯 TARGET: %s\n" ..
            "👾 NPCs: %d\n" ..
            "⚡ STATUS: %s",
            level,
            health,
            maxHealth,
            (health / maxHealth) * 100,
            CurrentTarget and CurrentTarget.Name or "None",
            npcCount,
            FarmActive and "🟢 FARMING" or "🔴 IDLE"
        )
    end)
end

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        FarmActive = not FarmActive
    elseif input.KeyCode == Enum.KeyCode.E then
        Config.UseSkills = not Config.UseSkills
    end
end)

-- Character respawn
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    print("[Skay HUD] Character respawned!")
end)

-- Main execution
print("═══════════════════════════════════════")
print("    ⚡ SKAY HUD v3.0 LOADED ⚡")
print("═══════════════════════════════════════")
print("Hotkeys:")
print("  F - Toggle Farm")
print("  E - Toggle Skills")
print("  M - Menu (Click Buttons)")
print("═══════════════════════════════════════")

CreateAdvancedHUD()

-- Main farming loop
while true do
    FarmLoop()
    wait(0.05)
end
