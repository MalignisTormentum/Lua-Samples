local module = {}
local misc = require(game.ServerScriptService.HelperMods:WaitForChild("Misc"))
local ts = game:GetService("TweenService")

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist
params.FilterDescendantsInstances = {game.Workspace.DisasterFolder}

local ROUND_TIME, DAMAGE, RANGE = 30, 20, 5

local function gpfc(c)
	return game.Players:GetPlayerFromCharacter(c)
end

local function Damage(t, hp)
	t.Touched:Connect(function(hit)
		if not hit.Parent then return end
		local h = hit.Parent:FindFirstChild("Humanoid")
		if h and misc.isPlaying(hit.Parent) and (t:FindFirstChild("tForce") or t.Name == "Tornado") then
			h:TakeDamage(hp)
			
			h.Died:Connect(function()
				misc.SetPlaying(gpfc(h.Parent), false)
			end)
		end
	end)
end

local function FlingParts(t)
	while wait() and t ~= nil do
		local region = Region3.new(
			Vector3.new(t.Position.X - t.Size.X / 2 - RANGE, t.Position.Y - t.Size.Y / 2 - RANGE, t.Position.Z - t.Size.Z / 2 - RANGE),
			Vector3.new(t.Position.X + t.Size.X / 2 + RANGE, t.Position.Y + t.Size.Y / 2 + RANGE, t.Position.Z + t.Position.Z + RANGE)
		)
		local ps = game.Workspace:FindPartsInRegion3(region)
		for _, v in pairs(ps) do
			if v:IsA("BasePart") and v:FindFirstAncestor("MapFolder") and not v:FindFirstChild("tForce") then
				v:BreakJoints()
				v.Anchored = false
				
				local m = math.random(1, 3)
				if m < 2 then
					Damage(v, DAMAGE)
					
					local bp = Instance.new("BodyPosition", v)
					bp.MaxForce = Vector3.new(4000 * v:GetMass(), 4000 * v:GetMass(), 4000 * v:GetMass())
					bp.Name = "tForce"

					local bv = Instance.new("BodyAngularVelocity", v)
					bv.MaxTorque = Vector3.new(4000 * v:GetMass(), 4000 * v:GetMass(), 4000 * v:GetMass())
					bv.AngularVelocity = Vector3.new(math.random(1, 60), math.random(1, 60), math.random(1, 60))
					bv.Name = "tRotation"

					game:GetService("Debris"):AddItem(bp, math.random(3, 5))
					game:GetService("Debris"):AddItem(bv, math.random(3, 5))
					
					coroutine.wrap(function()
						local h = 0
						repeat wait()
							bp.Position = (CFrame.new(t.Position - Vector3.new(0, t.Size.Y / 2, 0)) * CFrame.Angles(0, math.pi * 2 * ((tick() / math.random(3, 5)) % 1), 0) * CFrame.new(t.Size.X / 2 + h / 50, h, 0)).Position
							h += t.Size.Y / 100 * 0.3
						until h == h * t.Size.Y
						bp:remove()
					end)()
				else
					v:Destroy()
				end
			end
		end
	end
end

function module.Run()
	local t = script.Tornado:Clone()
	t.Parent = game.Workspace.DisasterFolder
	t.Sound:Play()
	
	local y = t.Position.Y
	local tw = ts:Create(t, TweenInfo.new(ROUND_TIME, Enum.EasingStyle.Linear), {Position = Vector3.new(-400, y, math.random(-250, 250))})
	tw:Play()
	
	coroutine.wrap(function()
		while game:GetService("RunService").Heartbeat:Wait() and t do
			t.Orientation += Vector3.new(0, 1, 0)
		end
	end)()
	
	Damage(t, 10000)
	
	coroutine.wrap(function()
		FlingParts(t)
	end)()
	
	repeat wait()
		local r = game.Workspace:Raycast(t.Position, t.Position - Vector3.new(0, 200, 0), params)
		if r and r.Instance then
			t.Attachment.Lightning.Enabled = true
		else
			t.Attachment.Lightning.Enabled = false
		end
	until 
	tw.PlaybackState == Enum.PlaybackState.Completed or not t
	t:Destroy()
end

return module