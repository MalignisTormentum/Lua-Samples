local Character, CurrentCamera = game.Players.LocalPlayer.Character, game.Workspace.CurrentCamera
local HRP, Humanoid, Neck = Character:WaitForChild("HumanoidRootPart"), Character:WaitForChild("Humanoid"), nil
local TS, RS, HeadMovement = game:GetService("TweenService"), game:GetService("RunService"), game.ReplicatedStorage:WaitForChild("HeadMovement")

repeat
	wait()
	Neck = Character:FindFirstChild("Neck", true)
until
Neck ~= nil

local Ang, CF, ASin, YOffset, Pi = CFrame.Angles, CFrame.new, math.asin, Neck.C0.Y, math.pi

local function wait(TimeToWait)
	local Sum = 0
	while Sum < TimeToWait do
		Sum += RS.Heartbeat:Wait()
	end
end

RS.RenderStepped:Connect(function()
	local Direction = HRP.CFrame:ToObjectSpace(CurrentCamera.CFrame).LookVector
		
	if Neck and Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R6 then
			Neck.C0 = CF(0, YOffset, 0) * Ang(3 * Pi / 2, 0, Pi) * Ang(0, 0, -ASin(Direction.X)) * Ang(-ASin(Direction.Y), 0, 0)
		else
			Neck.C0 = CF(0, YOffset, 0) * Ang(0, -ASin(Direction.X), 0) * Ang(ASin(Direction.Y), 0, 0)
		end
	end
end)

HeadMovement.OnClientEvent:Connect(function(Player, NewC0)
	local TheirNeck = Player.Character:FindFirstChild("Neck", true)
	
	if TheirNeck then
		TS:Create(TheirNeck, TweenInfo.new(.5, Enum.EasingStyle.Linear), {C0 = NewC0}):Play()
	end
end)

Humanoid.Died:Connect(function()
	for i = 1, 5 do
		wait(.5)
		CurrentCamera.CameraSubject = Humanoid
		CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end)

while true do
	wait(1)
	HeadMovement:FireServer(Neck.C0)
end