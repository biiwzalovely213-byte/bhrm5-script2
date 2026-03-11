local Players = game:GetService("Players")

local function createBox(part)

	if part:FindFirstChild("NPC_BOX") then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "NPC_BOX"
	box.Adornee = part
	box.Size = Vector3.new(0.5,0.5,0.5)
	box.AlwaysOnTop = true
	box.Color3 = Color3.fromRGB(255,0,0)
	box.Transparency = 0.25
	box.Parent = part

end


while true do

	for _,v in pairs(workspace:GetDescendants()) do

		if v:IsA("Model") then

			local hum = v:FindFirstChildOfClass("Humanoid")

			if hum then

				local player = Players:GetPlayerFromCharacter(v)

				if not player then

					local head = v:FindFirstChild("Head") or v:FindFirstChild("HumanoidRootPart")

					if head then
						createBox(head)
					end

				end

			end

		end

	end

	task.wait(3)

end
