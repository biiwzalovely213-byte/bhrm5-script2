local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MAX_DISTANCE = 250

local function createBox(head)

	if head:FindFirstChild("NPC_BOX") then
		return head.NPC_BOX
	end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "NPC_BOX"
	box.Adornee = head
	box.Size = Vector3.new(0.45,0.45,0.45)
	box.AlwaysOnTop = true
	box.Transparency = 0.25
	box.Parent = head

	return box
end


local function canSee(part)

	local origin = Camera.CFrame.Position
	local direction = part.Position - origin

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {
		LocalPlayer.Character,
		part.Parent
	}

	local result = workspace:Raycast(origin,direction,params)

	return result == nil
end


RunService.Heartbeat:Connect(function()

	local char = LocalPlayer.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _,model in pairs(workspace:GetChildren()) do

		if model:IsA("Model") then

			local hum = model:FindFirstChildOfClass("Humanoid")

			if hum then

				local player = Players:GetPlayerFromCharacter(model)

				if not player then

					local head = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")

					if head then

						local dist = (head.Position - root.Position).Magnitude

						local box = createBox(head)

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

	end

end)
