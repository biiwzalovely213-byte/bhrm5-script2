local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 250
local Targets = {}

local function getHead(model)
    return model:FindFirstChild("Head")
end

local function isPlayer(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function isNPC(model)

    if not model:IsA("Model") then return false end

    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    if isPlayer(model) then
        return false
    end

    return true
end


local function createBox(target,isPlayerChar)

    local head = getHead(target)
    if not head then return end

    if head:FindFirstChild("ESP_BOX") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_BOX"
    box.Adornee = head
    box.Size = Vector3.new(1.2,1.2,1.2)
    box.AlwaysOnTop = true
    box.Transparency = 0.25
    box.ZIndex = 5

    if isPlayerChar then
        box.Color3 = Color3.fromRGB(0,170,255) -- ฟ้า
    else
        box.Color3 = Color3.fromRGB(255,0,0) -- แดง
    end

    box.Parent = head

end


local function canSee(target)

    local origin = camera.CFrame.Position
    local direction = (target.Position - origin)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin,direction,params)

    if result and result.Instance then
        if result.Instance:IsDescendantOf(target.Parent) then
            return true
        end
        return false
    end

    return true

end


local function addTarget(v)

    if isNPC(v) then

        table.insert(Targets,{model=v,type="NPC"})
        createBox(v,false)

    elseif isPlayer(v) and v ~= player.Character then

        table.insert(Targets,{model=v,type="PLAYER"})
        createBox(v,true)

    end

end


for _,v in pairs(workspace:GetDescendants()) do
    addTarget(v)
end


workspace.DescendantAdded:Connect(function(v)
    addTarget(v)
end)


RunService.RenderStepped:Connect(function()

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _,data in pairs(Targets) do

        local model = data.model

        if model and model.Parent then

            local head = getHead(model)
            local box = head and head:FindFirstChild("ESP_BOX")

            if head and box then

                local distance = (head.Position - root.Position).Magnitude

                if distance <= MAX_DISTANCE then

                    box.Visible = true

                    if data.type == "PLAYER" then
                        box.Color3 = Color3.fromRGB(0,170,255) -- ฟ้า
                    else
                        box.Color3 = Color3.fromRGB(255,0,0) -- แดง
                    end

                else

                    box.Visible = false

                end

            end

        end

    end

end)
