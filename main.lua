local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variables
local trackedParts = {}
local wallEnabled = false
local npcHitboxEnabled = false
local npcEspEnabled = false -- Renamed from showHitbox
local wallConnections = {}
local guiVisible = true
local isUnloaded = false
local originalSizes = {}
local npcCache = {}

-- ============= Improved Notification System (Stacking + Sound) =============

local notifications = {}
local screenGui -- forward declare, created below

local function playNotifySound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9118828567" -- Soft ping sound, can change to any ID
    sound.Volume = 1
    sound.Parent = SoundService
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

local function updateNotificationPositions()
    for i, notif in ipairs(notifications) do
        notif.Position = UDim2.new(0, 10, 1, -70 - ((i-1) * 36))
    end
end

local function notify(msg)
    if not screenGui then return end
    local notif = Instance.new("TextLabel", screenGui)
    notif.Size = UDim2.new(0, 200, 0, 32)
    notif.Position = UDim2.new(0, 10, 1, -70)
    notif.BackgroundColor3 = Color3.new(0, 0, 0)
    notif.BackgroundTransparency = 0.25
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 18
    notif.Text = msg
    notif.ZIndex = 999
    notif.AnchorPoint = Vector2.new(0,1)
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    notif.Visible = true

    table.insert(notifications, 1, notif)
    updateNotificationPositions()
    playNotifySound()

    spawn(function()
        wait(2)
        for i=1,10 do
            notif.TextTransparency = notif.TextTransparency + 0.1
            notif.BackgroundTransparency = notif.BackgroundTransparency + 0.075
            wait(0.05)
        end
        notif:Destroy()
        for i, n in ipairs(notifications) do
            if n == notif then
                table.remove(notifications, i)
                break
            end
        end
        updateNotificationPositions()
    end)
end

-- ============= END Notification System =============

-- Destroy all ESP boxes
local function destroyAllBoxes()
    for part in pairs(trackedParts) do
        if part and part.Parent then
            local wallBox = part:FindFirstChild("Wall_Box")
            if wallBox then wallBox:Destroy() end
        end
    end
    trackedParts = {}
end

-- Reset the size of all Roots
local function resetRootSizes()
    for model, originalSize in pairs(originalSizes) do
        if model and model.Parent and model:FindFirstChild("UpperTorso") then
            model.Root.Size = originalSize
            model.Root.Transparency = 1
        end
    end
    originalSizes = {}
end

-- Create a box for a specific part
local function createBoxForPart(part)
    if isUnloaded or not part or not part.Parent then return end
    if part:FindFirstChild("Wall_Box") then return end

    task.wait(0.5)

    if not part or not part.Parent or part:FindFirstChild("Wall_Box") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "Wall_Box"
    box.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
    box.Adornee = part
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.3
    box.Parent = part

    trackedParts[part] = true
end

-- Improved NPC detection including machete-wielding NPCs
local function isNPC(model)
    if model:IsA("Model") and model.Name == "Male" then
        for _, child in ipairs(model:GetChildren()) do
            if child.Name:sub(1, 3) == "AI_" or child:FindFirstChild("Machete") then
                return true
            end
        end
    end
    return false
end

-- Create ESP for all NPC heads
local function createBoxesForAllNPCs()
    for npc in pairs(npcCache) do
        if npc and npc.Parent then
            local head = npc:FindFirstChild("Head")
            if head then createBoxForPart(head) end
        end
    end
end

-- Register existing NPCs
local function registerExistingNPCs()
    local descendants = workspace:GetDescendants()
    for i = 1, #descendants do
        local npc = descendants[i]
        if isNPC(npc) then
            npcCache[npc] = true
            local head = npc:FindFirstChild("Head")
            if head then trackedParts[head] = true end
        end
    end
end

-- =========== PERSISTENT FULLBRIGHT SECTION =============
-- Save original Lighting settings for restoring
local originalLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top,
}

local fullBrightEnabled = false
local fullBrightConnection -- stores the RenderStepped connection

local function applyFullBright()
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.Brightness = 10
    Lighting.OutdoorAmbient = Color3.new(1,1,1)
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.GlobalShadows = false
    Lighting.ColorShift_Bottom = Color3.new(0,0,0)
    Lighting.ColorShift_Top = Color3.new(0,0,0)
end

local function restoreLighting()
    for k,v in pairs(originalLighting) do
        Lighting[k] = v
    end
end
-- =========== END FULLBRIGHT SECTION ================

-- GUI Setup
screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "OperatorTools_GUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.Size = UDim2.new(0, 200, 0, 268)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = guiVisible
mainFrame.AnchorPoint = Vector2.new(0, 0)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", mainFrame)
title.Text = "BHRM5 Operator Tools"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.BorderSizePixel = 0
Instance.new("UICorner", title)

local buttonContainer = Instance.new("Frame", mainFrame)
buttonContainer.Position = UDim2.new(0, 0, 0, 40)
buttonContainer.Size = UDim2.new(1, 0, 1, -60)
buttonContainer.BackgroundTransparency = 1

local uiList = Instance.new("UIListLayout", buttonContainer)
uiList.Padding = UDim.new(0, 8)
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Top

-- Credit Label
local creditLabel = Instance.new("TextLabel", mainFrame)
creditLabel.Text = "Credit: Ben = Katro"
creditLabel.Size = UDim2.new(1, 0, 0, 20)
creditLabel.Position = UDim2.new(0, 0, 1, -20)
creditLabel.BackgroundTransparency = 1
creditLabel.TextColor3 = Color3.new(1, 1, 1)
creditLabel.Font = Enum.Font.Gotham
creditLabel.TextSize = 14
creditLabel.TextXAlignment = Enum.TextXAlignment.Center

local function createButton(text, color, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    Instance.new("UICorner", btn)
    return btn
end

-- FULLBRIGHT BUTTON (Now fully persistent)
local fullBrightBtn = createButton("Full Bright: OFF", Color3.fromRGB(40, 40, 80), buttonContainer)
fullBrightBtn.MouseButton1Click:Connect(function()
    fullBrightEnabled = not fullBrightEnabled
    if fullBrightEnabled then
        if fullBrightConnection then fullBrightConnection:Disconnect() end
        fullBrightConnection = RunService.RenderStepped:Connect(applyFullBright)
        fullBrightBtn.Text = "Full Bright: ON"
        notify("FullBright Enabled!")
    else
        if fullBrightConnection then
            fullBrightConnection:Disconnect()
            fullBrightConnection = nil
        end
        restoreLighting()
        fullBrightBtn.Text = "Full Bright: OFF"
        notify("FullBright Disabled.")
    end
end)

-- WALL ESP
local toggleBtn = createButton("Wall OFF", Color3.fromRGB(40, 40, 40), buttonContainer)
toggleBtn.MouseButton1Click:Connect(function()
    wallEnabled = not wallEnabled
    toggleBtn.Text = wallEnabled and "Wall ON" or "Wall OFF"
    if wallEnabled then
        createBoxesForAllNPCs()
        notify("Wall ESP Enabled!")
    else
        destroyAllBoxes()
        notify("Wall ESP Disabled.")
    end
end)

-- NPC HITBOX EXPANSION
local function processNPCHitbox()
    for npc in pairs(npcCache) do
        if npc and npc.Parent and npc:FindFirstChild("UpperTorso") then
            local root = npc.Root
            if not originalSizes[npc] then
                originalSizes[npc] = root.Size
            end
            root.Size = Vector3.new(15, 15, 15)
            root.Transparency = npcEspEnabled and 0.85 or 1
        end
    end
end

local npcHitboxBtn = createButton("NPC HITBOX: OFF", Color3.fromRGB(80, 20, 20), buttonContainer)
npcHitboxBtn.Font = Enum.Font.GothamBold
npcHitboxBtn.MouseButton1Click:Connect(function()
    npcHitboxEnabled = not npcHitboxEnabled
    npcHitboxBtn.Text = npcHitboxEnabled and "NPC HITBOX: ON" or "NPC HITBOX: OFF"
    if not npcHitboxEnabled then 
        resetRootSizes()
        notify("NPC Hitbox Disabled.")
    else
        notify("NPC Hitbox Enabled!")
    end
end)

-- NPC ESP BUTTON (replaces Show Hitbox)
local npcEspBtn = createButton("NPC ESP OFF", Color3.fromRGB(40, 80, 40), buttonContainer)
npcEspBtn.MouseButton1Click:Connect(function()
    npcEspEnabled = not npcEspEnabled
    npcEspBtn.Text = npcEspEnabled and "NPC ESP ON" or "NPC ESP OFF"
    for model in pairs(originalSizes) do
        if model and model.Parent and model:FindFirstChild("UpperTorso") then
            model.Root.Transparency = npcEspEnabled and 0.85 or 1
        end
    end
    if npcEspEnabled then
        notify("NPC ESP Enabled!")
    else
        notify("NPC ESP Disabled.")
    end
end)

local unloadBtn = createButton("Unload", Color3.fromRGB(100, 0, 0), buttonContainer)
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.MouseButton1Click:Connect(function()
    isUnloaded = true
    destroyAllBoxes()
    resetRootSizes()
    if fullBrightConnection then
        fullBrightConnection:Disconnect()
        fullBrightConnection = nil
    end
    restoreLighting()
    notify("Cheat Unloaded.")
    screenGui:Destroy()
    for i = 1, #wallConnections do
        local conn = wallConnections[i]
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    if showGuiBtn then showGuiBtn:Destroy() end
end)

registerExistingNPCs()

local childConn = workspace.ChildAdded:Connect(function(child)
    if isUnloaded then return end
    if isNPC(child) then
        task.wait(0.5)
        npcCache[child] = true
        local head = child:FindFirstChild("Head")
        if head then 
            trackedParts[head] = true
            if wallEnabled then
                createBoxForPart(head)
            end
        end
        local root = child:FindFirstChild("UpperTorso")
        if root and not npcHitboxEnabled then
            root.Size = Vector3.new(1, 1, 1)
        end
    end
end)
table.insert(wallConnections, childConn)

local lastWallUpdate = 0
local wallUpdateInterval = 0.15
local lastHitboxUpdate = 0
local hitboxUpdateInterval = 0.1

local renderConn = RunService.RenderStepped:Connect(function(deltaTime)
    if isUnloaded then return end
    
    lastWallUpdate = lastWallUpdate + deltaTime
    if wallEnabled and lastWallUpdate >= wallUpdateInterval then
        lastWallUpdate = 0
        local origin = camera.CFrame.Position
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {localPlayer.Character}
        
        for part in pairs(trackedParts) do

                if (part.Position - origin).Magnitude > 350 then
    continue
end
            if part and part.Parent then
                local wallBox = part:FindFirstChild("Wall_Box")
                if wallBox then
                    rayParams.FilterDescendantsInstances[2] = part
                    local result = workspace:Raycast(origin, part.Position - origin, rayParams)
                    local isVisible = not result or result.Instance:IsDescendantOf(part.Parent)
                    wallBox.Color3 = isVisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end

    lastHitboxUpdate = lastHitboxUpdate + deltaTime
    if npcHitboxEnabled and lastHitboxUpdate >= hitboxUpdateInterval then
        lastHitboxUpdate = 0
        processNPCHitbox()
    end
end)
table.insert(wallConnections, renderConn)

-- =================== Menu Show/Hide with Outline Button =====================
local showGuiBtn

local function createShowGuiBtn()
    if showGuiBtn then showGuiBtn:Destroy() end
    showGuiBtn = Instance.new("ImageButton", screenGui)
    showGuiBtn.Name = "ShowGuiBtn"
    showGuiBtn.Size = UDim2.new(0, 38, 0, 38)
    showGuiBtn.Position = UDim2.new(0, 10, 1, -55)
    showGuiBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    showGuiBtn.BackgroundTransparency = 0.25
    showGuiBtn.Image = "rbxassetid://7733714924" -- Circle icon, can change!
    showGuiBtn.ImageTransparency = 0
    showGuiBtn.ZIndex = 1000
    showGuiBtn.Visible = true
    Instance.new("UICorner", showGuiBtn).CornerRadius = UDim.new(1, 0)
    showGuiBtn.MouseButton1Click:Connect(function()
        guiVisible = true
        mainFrame.Visible = true
        showGuiBtn.Visible = false
        notify("Menu Shown.")
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or isUnloaded then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
        if not guiVisible then
            createShowGuiBtn()
            showGuiBtn.Visible = true
            notify("Menu Hidden. Click the round button to show.")
        else
            if showGuiBtn then showGuiBtn.Visible = false end
            notify("Menu Shown.")
        end
    end
end)

-- ================= DRAGGABLE GUI FEATURE ==================
do
    local dragging, dragInput, dragStart, startPos

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)
end
-- ===== NPC SPAWN DETECTOR (USE ORIGINAL isNPC) =====

workspace.DescendantAdded:Connect(function(child)

    if isUnloaded then return end

    if isNPC(child) then

        task.wait(0.5)

        npcCache[child] = true

        local head = child:FindFirstChild("Head")

        if head then
            trackedParts[head] = true

            if wallEnabled then
                createBoxForPart(head)
            end
        end

    end

end)

-- ===== END NPC SPAWN DETECTOR =====

RunService.Stepped:Connect(function()

    for npc in pairs(npcCache) do
        if not npc or not npc.Parent then
            npcCache[npc] = nil
        end
    end

end)
