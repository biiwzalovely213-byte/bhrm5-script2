local Players = game:GetService("Players")

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
	box.Size = Vector3.new(0.6,0.6,0.6)
	box.AlwaysOnTop = true
	box.Transparency = 0.2
	box.Color3 = Color3.new(1,0,0)
	box.Parent = head

end


local function checkNPC(model)

	if not model:IsA("Model") then return end
	if isPlayer(model) then return end

	local hum = model:FindFirstChildOfClass("Humanoid")
	local head = model:FindFirstChild("Head")

	if hum and head then
		createBox(head)
	end

end


for _,v in pairs(workspace:GetChildren()) do
	checkNPC(v)
end


workspace.ChildAdded:Connect(function(v)
	task.wait(0.2)
	checkNPC(v)
end)
