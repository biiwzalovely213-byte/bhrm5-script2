local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local MAX_DISTANCE = 250

local function isPlayer(model)
	for _,p in pairs(Players:GetPlayers()) do
		if p.Character == model then
			return true
		end
	end
	return false
end

local function createBox(head)

	if head:FindFirstChild("NPC_BOX") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "NPC_BOX"
	box.Adornee = head
	box.Size = Vector3.new(0.5,0.5,0.5)
	box.AlwaysOnTop = true
	box.Transparency = 0.25
	box.Color3 = Color3.new(1,0,0)
	box.Parent = head

end


local function scanNPC()

	local char = LocalPlayer.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _,model in pairs(Workspace:GetDescendants()) do

		if model:IsA("Model") and not isPlayer(model) then

			local hum = model:FindFirstChildOfClass("Humanoid")
			local head = model:FindFirstChild("Head")

			if hum and head then

				local dist = (head.Position - root.Position).Magnitude

				if dist <= MAX_DISTANCE then
					createBox(head)
				end

			end

		end

	end

end


while true do
	scanNPC()
	task.wait(3)
end
