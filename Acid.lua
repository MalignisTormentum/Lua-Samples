local module = {}

local hm = game.ServerScriptService.HelperMods
local misc = require(hm:WaitForChild("Misc"))
local stat = require(hm:WaitForChild("Stat"))

local DAMAGE_AMOUNT, DAMAGE_TIME, ROUND_TIME = 10, .2, 30
local ids = {"8312669416", "8312669992", "8312670669", "8312671362"}
local d = game:GetService("Debris")

function module.Run(dt)
	local damount, dtime = DAMAGE_AMOUNT, DAMAGE_TIME
	if dt == 2 then
		DAMAGE_AMOUNT *= 1.1
	elseif dt == 3 then
		DAMAGE_AMOUNT *= 1.2
		DAMAGE_TIME /= 1.5
	end
	
	local ap = Instance.new("Part", game.Workspace.DisasterFolder)
	ap.Name = "Acid"
	ap.Anchored = true
	ap.CanCollide = false
	ap.Material = Enum.Material.Neon
	ap.Transparency = .25
	ap.BrickColor = BrickColor.new("Shamrock")
	ap.Position = Vector3.new(0, -10.01, 0)
	ap.Size = Vector3.new(399.5, 10, 399.5)
	
	local hitp = Instance.new("Part", game.Workspace.DisasterFolder)
	hitp.Anchored = true
	hitp.CanCollide = false
	hitp.Transparency = 1
	hitp.Size = Vector3.new(ap.Size.X, 1, ap.Size.Z)
	
	local as = Instance.new("Sound", game.Workspace.DisasterFolder)
	as.SoundId = "rbxassetid://8312529439"
	as.Volume = .1
	as:Play()
	
	coroutine.wrap(function()
		while hitp ~= nil do
			hitp.Position = ap.Position - Vector3.new(0, ap.Size.Y / 2, 0)
			for i = ap.Position.Y - ap.Size.Y / 2, ap.Position.Y + ap.Size.Y / 2 do
				wait(.1)
				hitp.Position = Vector3.new(0, i, 0)
			end
			if ap.Position.Y < ap.Size.Y / 2 then
				as.Volume += .05
				ap.Position = ap.Position + Vector3.new(0, 1, 0)
			end
		end
	end)()
	
	coroutine.wrap(function()
		local changedParts = {}
		while wait() and ap ~= nil do
			local pt = game.Workspace.MapFolder:GetDescendants()
			local p = pt[math.random(1, #pt)]
			if p:IsA("BasePart") and p.Name ~= "Anchor" and p.Position.Y < ap.Position.Y + ap.Size.Y / 2 + 2 and not table.find(changedParts, p) then
				local m = math.random(1, 5)
				if m <= 2 then
					coroutine.wrap(function()
						p:BreakJoints()
						p.Material = Enum.Material.Neon
						p.BrickColor = BrickColor.new("Shamrock")
						local f
						f = p.Touched:Connect(function(hit)
							if not hit.Parent then return end
							local h = hit.Parent:FindFirstChild("Humanoid")
							local hrp = hit.Parent:FindFirstChild("HumanoidRootPart")
							
							if h and hrp and misc.gpfc(hit.Parent) and h.Health > 0 then
								if not p:FindFirstChild("Sizzle") then
									local s = Instance.new("Sound", p)
									s.SoundId = "rbxassetid://" .. ids[math.random(1, #ids)]
									s.Name = "Sizzle"
									s:Play()
									d:AddItem(s, 1)
								end
								
								local plr = misc.gpfc(hit.Parent)
								if plr and misc.isPlaying(plr) then
									if not h:GetAttribute("isDamaged") then
										h:SetAttribute("isDamaged", true)
										h:TakeDamage(DAMAGE_AMOUNT)
										wait(DAMAGE_TIME)
										h:SetAttribute("isDamaged", false)
									end
								end
								
								h.Died:Connect(function()
									if misc.gpfc(h.Parent) then
										misc.SetPlaying(misc.gpfc(h.Parent), false)
									end
								end)
							end
						end)
						wait(math.random(15, 30))
						f:Disconnect()
						p.Material = Enum.Material.Slate
						p.BrickColor = BrickColor.new("Black")
						wait(math.random(5, 15))
						p:Destroy()
					end)()
				end
				table.insert(changedParts, p)
			end
		end
	end)()
	
	local f
	hitp.Touched:Connect(function(p)
		coroutine.wrap(function()
			if p.Parent then
				local h = p.Parent:FindFirstChild("Humanoid")
				local hrp = p.Parent:FindFirstChild("HumanoidRootPart")

				if h and hrp then
					local plr = misc.gpfc(p.Parent)
					if plr and misc.isPlaying(plr) then
						if not h:GetAttribute("isDamaged") then
							h:SetAttribute("isDamaged", true)
							h:TakeDamage(DAMAGE_AMOUNT)
							wait(DAMAGE_TIME)
							h:SetAttribute("isDamaged", false)
						end

						h.Died:Connect(function()
							if misc.gpfc(h.Parent) then
								misc.SetPlaying(misc.gpfc(h.Parent), false)
							end
						end)
					end
				end
			end
		end)()
	end)
	
	d:AddItem(ap, ROUND_TIME)
	d:AddItem(hitp, ROUND_TIME)
	d:AddItem(as, ROUND_TIME)
	wait(ROUND_TIME)
	
	DAMAGE_AMOUNT = damount
	DAMAGE_TIME = dtime
end

return module