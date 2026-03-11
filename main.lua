local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 250
local NPCs = {}

local function isNPC(model)
	if not model:IsA("Model") then return false end
	if not model:FindFirstChildOfClass("Humanoid") then return false end
	if Players:GetPlayerFromCharacter(model) then return false end
	return true
end

local function getHead(model)
	return model:FindFirstChild("Head")
end

local function createBox(npc)

	local head = getHead(npc)
	if not head then return end

	if head:FindFirstChild("NPC_BOX") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "NPC_BOX"
	box.Adornee = head
	box.Size = Vector3.new(1.8,1.8,1.8)
	box.AlwaysOnTop = true
	box.Transparency = 0.25
	box.ZIndex = 5
	box.Parent = head

end

local function addNPC(model)

	if isNPC(model) and not NPCs[model] then
		NPCs[model] = true
		createBox(model)
	end

end

-- scan models only
for _,v in ipairs(workspace:GetChildren()) do
	addNPC(v)
end

workspace.ChildAdded:Connect(addNPC)

while task.wait(0.15) do

	local char = player.Character
	if not char then continue end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then continue end

	for npc,_ in pairs(NPCs) do

		if not npc.Parent then
			NPCs[npc] = nil
			continue
		end

		local head = npc:FindFirstChild("Head")
		if not head then continue end

		local box = head:FindFirstChild("NPC_BOX")
		if not box then continue end

		local distance = (head.Position - root.Position).Magnitude

		box.Visible = distance <= MAX_DISTANCE

	end

end
