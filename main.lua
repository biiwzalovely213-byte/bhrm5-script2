local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MAX_DISTANCE = 250

local function isPlayerCharacter(model)
	for _,p in pairs(Players:GetPlayers()) do
		if p.Character == model then
			return true
		end
	end
	return false
end

local function isNPC(model)
	if not model:IsA("Model") then return false end
	if isPlayerCharacter(model) then return false end
	if not model:FindFirstChildOfClass("Humanoid") then return false end
	if not model:FindFirstChild("Head") then return false end
	return true
end

local function createBox(head)

	if head:FindFirstChild("NPC_BOX") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "NPC_BOX"
	box.Adornee = head
	box.Size = Vector3.new(0.8,0.8,0.8)
	box.AlwaysOnTop = true
	box.Transparency = 0.2
	box.ZIndex = 10
	box.Parent = head

end


local function canSee(head)

	local origin = Camera.CFrame.Position
	local direction = head.Position - origin

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {
		LocalPlayer.Character,
		head.Parent
	}

	local result = workspace:Raycast(origin,direction,params)

	if result then
		return false
	end

	return true
end


local NPCs = {}

local function scan()

	NPCs = {}

	for _,v in pairs(workspace:GetDescendants()) do

		if isNPC(v) then

			local head = v:FindFirstChild("Head")

			if head then
				createBox(head)
				table.insert(NPCs,head)
			end

		end

	end

end

scan()

workspace.DescendantAdded:Connect(function()
	task.wait(2)
	scan()
end)


RunService.RenderStepped:Connect(function()

	local char = LocalPlayer.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _,head in pairs(NPCs) do

		if head and head.Parent then

			local box = head:FindFirstChild("NPC_BOX")

			if box then

				local dist = (head.Position - root.Position).Magnitude

				if dist <= MAX_DISTANCE then

					box.Visible = true

					if canSee(head) then
						box.Color3 = Color3.new(0,1,0)
					else
						box.Color3 = Color3.new(1,0,0)
					end

				else

					box.Visible = false

				end

			end

		end

	end

end)
