local module, meteor = {}, {}
meteor.__index = meteor

local hm = game.ServerScriptService.HelperMods
local misc = require(hm:WaitForChild("Misc"))
local stat = require(hm:WaitForChild("Stat"))

local TweenService = game:GetService("TweenService")
local MeteorSound = script.MeteorSound
local ROUND_TIME = 30

local function createSound(m)
	local sp = Instance.new("Part", game.Workspace.DisasterFolder)
	sp.Size = Vector3.new(.1, .1, 1)
	sp.Position = m.Position
	sp.Transparency = 1
	sp.Anchored = true
	sp.CanCollide = false

	local s = MeteorSound:Clone()
	s.Parent = sp 
	s:Play()
	game:GetService("Debris"):AddItem(s, s.TimeLength)
end

function meteor.new()
	local m, debounce, createdSound = script.Meteor:Clone(), false, false
	m.Touched:Connect(function(h)
		if not debounce then
			debounce = true
			if not createdSound then
				createdSound = true
				createSound(m)
			end
			if misc.gpfc(h.Parent) and misc.isPlaying(h.Parent) and misc.getHumanoid(h.Parent) then
				misc.getHumanoid(h.Parent).Health = 0
				misc.SetPlaying(misc.gpfc(h.Parent), false)
			elseif h:FindFirstAncestor("Terrain") or h.Name == "we" then
				misc.createExplosion(m, 5)
				wait(math.random(1, 3))
				m:Destroy()
			end
			debounce = false
		end
	end)
	m.Parent = game.Workspace.DisasterFolder
	return m
end

local function dropMeteor(m)
	local pos = Vector3.new(math.random(-200, 200), 400, math.random(-200, 200))
	m.Position = pos
end

function module.Run(dt)
	local roundGoing = true
	coroutine.wrap(function()
		for i = 1, 30 do
			if roundGoing then
				wait(math.random(1, 2))
				dropMeteor(meteor.new())
			else 
				break
			end
		end
	end)()
	wait(ROUND_TIME)
	roundGoing = false
	misc.cleanUp()
end

return module