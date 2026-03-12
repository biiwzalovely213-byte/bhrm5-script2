local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local wallEnabled = false
local npcHitboxEnabled = false
local npcEspEnabled = false
local fullBrightEnabled = false

local NPCs = {}
local Boxes = {}

local function isNPC(model)
	if not model:IsA("Model") then return false end
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum then return false end
	if Players:GetPlayerFromCharacter(model) then return false end
	return true
end

local function getHead(model)
	return model:FindFirstChild("Head")
end

local function getRoot(model)
	return model:FindFirstChild("HumanoidRootPart")
end

local function createESP(npc)
	local head = getHead(npc)
	if not head then return end
	if head:FindFirstChild("NPC_ESP") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "NPC_ESP"
	box.Adornee = head
	box.Size = Vector3.new(1.5,1.5,1.5)
	box.AlwaysOnTop = true
	box.Transparency = 0.25
	box.ZIndex = 5
	box.Color3 = Color3.fromRGB(255,0,0)
	box.Parent = head

	Boxes[npc] = box
end

local function removeESP()
	for _,npc in pairs(NPCs) do
		local head = getHead(npc)
		if head then
			local esp = head:FindFirstChild("NPC_ESP")
			if esp then esp:Destroy() end
		end
	end
end

local function setHitbox(enable)
	for _,npc in pairs(NPCs) do
		if npc and npc.Parent and isNPC(npc) then
			local root = getRoot(npc)
			if root then
				if enable then
					root.Size = Vector3.new(6,6,6)
					root.Transparency = 0.5
					root.Color = Color3.fromRGB(255,0,0)
					root.Material = Enum.Material.Neon
				else
					root.Size = Vector3.new(2,2,1)
					root.Transparency = 1
					root.Material = Enum.Material.Plastic
				end
			end
		end
	end
end

local function canSee(target)
	local origin = camera.CFrame.Position
	local direction = target.Position - origin

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

local function addNPC(v)
	if isNPC(v) then
		table.insert(NPCs,v)
	end
end

for _,v in pairs(workspace:GetDescendants()) do
	addNPC(v)
end

workspace.DescendantAdded:Connect(function(v)
	addNPC(v)
end)

RunService.RenderStepped:Connect(function()

	for _,npc in pairs(NPCs) do
		if npc and npc.Parent and isNPC(npc) then
			local head = getHead(npc)
			local box = head and head:FindFirstChild("NPC_ESP")

			if npcEspEnabled then
				if not box then
					createESP(npc)
				end

				if head then
					box = head:FindFirstChild("NPC_ESP")
					if box then
						if canSee(head) then
							box.Color3 = Color3.fromRGB(0,255,0)
						else
							box.Color3 = Color3.fromRGB(255,0,0)
						end
					end
				end
			end
		end
	end

	if not npcEspEnabled then
		removeESP()
	end

end)

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Parent = screenGui
main.Size = UDim2.new(0,200,0,260)
main.Position = UDim2.new(0,10,0,10)
main.BackgroundColor3 = Color3.fromRGB(10,10,10)
main.BorderSizePixel = 0

local title = Instance.new("TextLabel")
title.Parent = main
title.Size = UDim2.new(1,0,0,30)
title.Text = "BHRM5 Operator Tools"
title.BackgroundColor3 = Color3.fromRGB(20,20,20)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.BorderSizePixel = 0

local layout = Instance.new("UIListLayout")
layout.Parent = main
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

title.LayoutOrder = 0

local function makeButton(text,color,order)
	local b = Instance.new("TextButton")
	b.Parent = main
	b.Size = UDim2.new(1,-10,0,35)
	b.Position = UDim2.new(0,5,0,0)
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.Text = text
	b.LayoutOrder = order
	return b
end

local fullBrightBtn = makeButton("Full Bright: OFF",Color3.fromRGB(60,60,120),1)
local wallBtn = makeButton("Wall OFF",Color3.fromRGB(70,70,70),2)
local hitboxBtn = makeButton("NPC HITBOX: OFF",Color3.fromRGB(120,40,40),3)
local espBtn = makeButton("NPC ESP OFF",Color3.fromRGB(40,120,40),4)
local unloadBtn = makeButton("Unload",Color3.fromRGB(150,0,0),5)

local credit = Instance.new("TextLabel")
credit.Parent = main
credit.Size = UDim2.new(1,0,0,20)
credit.BackgroundTransparency = 1
credit.Text = "Credit: Ben = Katro"
credit.TextColor3 = Color3.new(1,1,1)
credit.Font = Enum.Font.Gotham
credit.TextSize = 14
credit.LayoutOrder = 6

fullBrightBtn.MouseButton1Click:Connect(function()
	fullBrightEnabled = not fullBrightEnabled
	if fullBrightEnabled then
		fullBrightBtn.Text = "Full Bright: ON"
		Lighting.Ambient = Color3.new(1,1,1)
		Lighting.Brightness = 10
		Lighting.FogEnd = 100000
	else
		fullBrightBtn.Text = "Full Bright: OFF"
		Lighting.Ambient = Color3.new(0.5,0.5,0.5)
		Lighting.Brightness = 2
	end
end)

wallBtn.MouseButton1Click:Connect(function()
	wallEnabled = not wallEnabled
	if wallEnabled then
		wallBtn.Text = "Wall ON"
	else
		wallBtn.Text = "Wall OFF"
	end
end)

hitboxBtn.MouseButton1Click:Connect(function()
	npcHitboxEnabled = not npcHitboxEnabled
	if npcHitboxEnabled then
		hitboxBtn.Text = "NPC HITBOX: ON"
	else
		hitboxBtn.Text = "NPC HITBOX: OFF"
	end
	setHitbox(npcHitboxEnabled)
end)

espBtn.MouseButton1Click:Connect(function()
	npcEspEnabled = not npcEspEnabled
	if npcEspEnabled then
		espBtn.Text = "NPC ESP ON"
	else
		espBtn.Text = "NPC ESP OFF"
	end
end)

unloadBtn.MouseButton1Click:Connect(function()
	removeESP()
	setHitbox(false)
	screenGui:Destroy()
end)
