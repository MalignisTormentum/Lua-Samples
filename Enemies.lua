local module = {}

local hm = game.ServerScriptService.HelperMods
local misc = require(hm:WaitForChild("Misc"))
local stat = require(hm:WaitForChild("Stat"))

local pfs= game:GetService("PathfindingService")
local damageTable = {["Tiny Noob"] = 5, ["Noob"] = 10, ["Picnic"] = 10}
local ROUND_TIME = 30

local dTable = {}
local function debounce(n) return table.find(dTable, n) ~= nil end
local function addDebounce(n) table.insert(dTable, n) end
local function removeDebounce(n) table.remove(dTable, table.find(dTable, n)) end

local function initDamage(m)
	for _, v in pairs(m:GetChildren()) do
		if v:IsA("BasePart") then
			v.Touched:Connect(function(t)
				coroutine.wrap(function()
					if misc.gpfc(t.Parent) and not debounce(t.Parent.Name) and 
						misc.getHumanoid(t) and misc.getHumanoid(m).Health > 0 and 
						misc.isPlaying(misc.gpfc(t.Parent)) then
						
						if misc.getHumanoid(t.Parent) then
							misc.getHumanoid(t.Parent).Died:Connect(function()
								if misc.gpfc(t.Parent) then
									misc.SetPlaying(misc.gpfc(t.Parent), false)
								end
							end)
						end
						addDebounce(t.Parent.Name)
						if damageTable[m.Name] then
							misc.getHumanoid(t):TakeDamage(damageTable[m.Name])
						else
							misc.getHumanoid(t):TakeDamage(damageTable["Picnic"])
						end
						wait(.5)
						if misc.getCharacter(t.Parent.Name) then
							removeDebounce(t.Parent.Name)
						end
					end
				end)()
			end)
		end
	end
end

local function initJump(m)
	coroutine.wrap(function()
		while misc.getHumanoid(m) do
			if misc.getHumanoid(m) then
				misc.getHumanoid(m).Jump = true
			end
			wait(math.random(1, 3))
		end
	end)()
end

local function initFollow(m)
	coroutine.wrap(function()
		while m ~= nil and wait(1) do
			local nearestPlayer = {nil, 999999}
			for _, p in pairs(game.Players:GetPlayers()) do
				if p.Character and misc.getHRP(p.Character) and misc.getHRP(m) and misc.isPlaying(p) then
					local mag = (misc.getHRP(p.Character).Position - misc.getHRP(m).position).Magnitude
					if mag < nearestPlayer[2] then
						nearestPlayer = {misc.getHRP(p.Character), mag}
					end
				end
			end

			if nearestPlayer[1] then
				local path = pfs:FindPathAsync(misc.getHRP(m).Position, nearestPlayer[1].Position)
				if misc.getHumanoid(m) then
					misc.getHumanoid(m):MoveTo(misc.getHRP(nearestPlayer[1]).Position)
				end
			end
		end
	end)()
end

local function initCleanup(m)
	misc.getHumanoid(m).Died:Connect(function()
		if misc.getHRP(m) then
			if string.find(m.Name, "Noob") then
				local s = Instance.new("Sound", misc.getHRP(m))
				s.SoundId = "rbxasset://sounds/uuhhh.mp3"
				if m.Name == "Tiny Noob" then
					s.PlaybackSpeed *= 2
				end
				s:Play()
			end
		end
		game:GetService("Debris"):AddItem(m, 3)
	end)
end

function module.Run(dt)
	local t = {}
	for _, v in pairs(script:GetChildren()) do table.insert(t, v.Name) end
	local name = t[math.random(1, #t)]
	local d = damageTable[name]
	if dt == 2 then
		damageTable[name] *= 1.2
	elseif dt == 3 then
		damageTable[name] *= 1.5
	end
	
	if name == "Picnic" then
		for _, v in pairs(script.Picnic:GetChildren())  do
			local c = v:Clone()
			c.Parent = game.Workspace.DisasterFolder
			if c:IsA("Model") then
				initDamage(c)
				initJump(c)
				initFollow(c)
				initCleanup(c)
			end
		end
	end
	
	for i = 1, ROUND_TIME do
		wait(1)
		if name ~= "Picnic" then
			local e = script[name]:Clone()
			e.Parent = game.Workspace.DisasterFolder
			misc.getHRP(e).CFrame = game.Workspace.DSpawns[math.random(0, #game.Workspace.DSpawns:GetChildren() - 1)].CFrame + Vector3.new(0, 1, 0)
			initDamage(e)
			initJump(e)
			initFollow(e)
			initCleanup(e)
		end
	end
	for _, v in pairs(game.Workspace.DisasterFolder:GetChildren()) do
		v:Destroy()
	end
	damageTable[name] = d
end

return module