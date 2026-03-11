local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function isPlayer(model)
	for _,p in pairs(Players:GetPlayers()) do
		if p.Character == model then
			return true
		end
	end
	return false
end

local function createBox(part)

	if part:FindFirstChild("NPC_BOX") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "NPC_BOX"
	box.Adornee = part
	box.Size = Vector3.new(0.6,0.6,0.6)
	box.AlwaysOnTop = true
	box.Color3 = Color3.fromRGB(255,0,0)
	box.Transparency = 0.3
	box.Parent = part

end


while true do

	for _,v in pairs(workspace:GetDescendants()) do

		if v:IsA("Model") and not isPlayer(v) then

			local hum = v:FindFirstChildOfClass("Humanoid")

			if hum then

				local part = v:FindFirstChild("Head") or v:FindFirstChild("HumanoidRootPart")

				if part then
					createBox(part)
				end

			end

		end

	end

	task.wait(4)

end
