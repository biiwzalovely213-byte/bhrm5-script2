local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MAX_DISTANCE = 250

local function isPlayer(model)
	for _,p in pairs(Players:GetPlayers()) do
		if p.Character == model then
			return true
		end
	end
	return false
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

	return result == nil
end

local function createBox(head)

	if head:FindFirstChild("NPC_BOX") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "NPC_BOX"
	box.Adornee = head
	box.Size = Vector3.new(0.7,0.7,0.7)
	box.AlwaysOnTop = true
	box.Transparency = 0.2
	box.ZIndex = 10
	box.Parent = head

end


RunService.Heartbeat:Connect(function()

	local char = LocalPlayer.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _,model in pairs(workspace:GetChildren()) do

		if model:IsA("Model") and not isPlayer(model) then

			local hum = model:FindFirstChildOfClass("Humanoid")
			local head = model:FindFirstChild("Head")

			if hum and head then

				createBox(head)

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

	end

end)
