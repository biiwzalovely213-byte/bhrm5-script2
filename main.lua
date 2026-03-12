local Players = game:GetService("Players") 
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local trackedParts = {}
local wallEnabled = false
local npcHitboxEnabled = false
local npcEspEnabled = false
local wallConnections = {}
local guiVisible = true
local isUnloaded = false
local originalSizes = {}
local npcCache = {}

local notifications = {}
local screenGui

local function playNotifySound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9118828567"
    sound.Volume = 1
    sound.Parent = SoundService
    sound:Play()
    game:GetService("Debris"):AddItem(sound,2)
end

local function updateNotificationPositions()
    for i,notif in ipairs(notifications) do
        notif.Position = UDim2.new(0,10,1,-70-((i-1)*36))
    end
end

local function notify(msg)
    if not screenGui then return end

    local notif = Instance.new("TextLabel",screenGui)
    notif.Size = UDim2.new(0,200,0,32)
    notif.Position = UDim2.new(0,10,1,-70)
    notif.BackgroundColor3 = Color3.new(0,0,0)
    notif.BackgroundTransparency = 0.25
    notif.TextColor3 = Color3.new(1,1,1)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 18
    notif.Text = msg
    notif.ZIndex = 999
    notif.AnchorPoint = Vector2.new(0,1)

    Instance.new("UICorner",notif).CornerRadius = UDim.new(0,8)

    table.insert(notifications,1,notif)
    updateNotificationPositions()
    playNotifySound()

    spawn(function()
        wait(2)
        for i=1,10 do
            notif.TextTransparency += 0.1
            notif.BackgroundTransparency += 0.075
            wait(0.05)
        end
        notif:Destroy()

        for i,n in ipairs(notifications) do
            if n==notif then
                table.remove(notifications,i)
                break
            end
        end

        updateNotificationPositions()
    end)
end

local function destroyAllBoxes()
    for part in pairs(trackedParts) do
        if part and part.Parent then
            local wallBox = part:FindFirstChild("Wall_Box")
            if wallBox then wallBox:Destroy() end
        end
    end
    trackedParts = {}
end

local function resetRootSizes()
    for model,size in pairs(originalSizes) do
        if model and model.Parent and model:FindFirstChild("UpperTorso") then
            model.Root.Size = size
            model.Root.Transparency = 1
        end
    end
    originalSizes = {}
end

local function createBoxForPart(part)

    if isUnloaded or not part or not part.Parent then return end
    if part:FindFirstChild("Wall_Box") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "Wall_Box"
    box.Size = part.Size + Vector3.new(0.1,0.1,0.1)
    box.Adornee = part
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = Color3.fromRGB(255,0,0)
    box.Transparency = 0.3
    box.Parent = part

    trackedParts[part] = true

end

local function isNPC(model)

    if model:IsA("Model") and model.Name == "Male" then
        for _,child in ipairs(model:GetChildren()) do
            if child.Name:sub(1,3)=="AI_" or child:FindFirstChild("Machete") then
                return true
            end
        end
    end

    return false

end

local function registerExistingNPCs()

    for _,npc in ipairs(workspace:GetDescendants()) do

        if isNPC(npc) then

            npcCache[npc] = true

            local head = npc:FindFirstChild("Head")

            if head then
                trackedParts[head] = true
            end

        end

    end

end

local originalLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
}

local fullBrightEnabled = false
local fullBrightConnection

local function applyFullBright()

    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.Brightness = 10
    Lighting.OutdoorAmbient = Color3.new(1,1,1)
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.GlobalShadows = false

end

local function restoreLighting()

    for k,v in pairs(originalLighting) do
        Lighting[k] = v
    end

end

screenGui = Instance.new("ScreenGui",localPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "OperatorTools_GUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame",screenGui)
mainFrame.Position = UDim2.new(0,10,0,10)
mainFrame.Size = UDim2.new(0,200,0,268)
mainFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
mainFrame.BorderSizePixel = 0

Instance.new("UICorner",mainFrame).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel",mainFrame)
title.Text = "BHRM5 Operator Tools"
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local buttonContainer = Instance.new("Frame",mainFrame)
buttonContainer.Position = UDim2.new(0,0,0,40)
buttonContainer.Size = UDim2.new(1,0,1,-60)
buttonContainer.BackgroundTransparency = 1

local uiList = Instance.new("UIListLayout",buttonContainer)
uiList.Padding = UDim.new(0,8)

local function createButton(text,color,parent)

    local btn = Instance.new("TextButton",parent)
    btn.Size = UDim2.new(1,-20,0,30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true

    Instance.new("UICorner",btn)

    return btn

end

local toggleBtn = createButton("Wall OFF",Color3.fromRGB(40,40,40),buttonContainer)

toggleBtn.MouseButton1Click:Connect(function()

    wallEnabled = not wallEnabled

    toggleBtn.Text = wallEnabled and "Wall ON" or "Wall OFF"

    if wallEnabled then

        for npc in pairs(npcCache) do

            local head = npc:FindFirstChild("Head")

            if head then
                createBoxForPart(head)
            end

        end

        notify("Wall ESP Enabled!")

    else

        destroyAllBoxes()
        notify("Wall ESP Disabled.")

    end

end)

registerExistingNPCs()

local spawnConn = workspace.DescendantAdded:Connect(function(obj)

    if isUnloaded then return end

    if isNPC(obj) then

        task.wait(0.5)

        npcCache[obj] = true

        local head = obj:FindFirstChild("Head")

        if head then

            trackedParts[head] = true

            if wallEnabled then
                createBoxForPart(head)
            end

        end

    end

end)

table.insert(wallConnections,spawnConn)

local renderConn = RunService.RenderStepped:Connect(function()

    if not wallEnabled then return end

    local origin = camera.CFrame.Position

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {localPlayer.Character}

    for part in pairs(trackedParts) do

        if part and part.Parent then

            local wallBox = part:FindFirstChild("Wall_Box")

            if wallBox then

                rayParams.FilterDescendantsInstances[2] = part

                local result = workspace:Raycast(origin,part.Position-origin,rayParams)

                local visible = not result or result.Instance:IsDescendantOf(part.Parent)

                wallBox.Color3 = visible and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

            end

        end

    end

end)

table.insert(wallConnections,renderConn)
