local TEST_MODE = false
local D = game.ServerScriptService.Disasters
local ranDisasters, disasterNames = {}, {} -- Handle modules.

local hm = game.ServerScriptService.HelperMods
local misc = require(hm:WaitForChild("Misc"))
local stat = require(hm:WaitForChild("Stat"))

local INTERMISSION_TIME = 15

local damageTable = {}
script.WeaponDamage.Event:Connect(function(plr, amount)
	if not damageTable[plr.Name] then damageTable[plr.Name] = 0 end
	damageTable[plr.Name] += amount
end)

local function updateStats()
	for _, v in pairs(game.Players:GetPlayers()) do
		if misc.isPlaying(v) then
			local baseEXP = 100
			if stat.GetMultiplier(v) then baseEXP *= stat.GetMultiplier(v) end
			if damageTable[v.Name] then
				baseEXP += math.ceil(damageTable[v.Name] / 10)
				damageTable[v.Name] = nil
			end
			local money = baseEXP
			stat.SetPlayerData(v, 1, stat.GetPlayerData(v, 1) + baseEXP)
			stat.SetPlayerData(v, 2, stat.GetPlayerData(v, 2) + money)
			v.leaderstats.Level.Value = stat.FormulateLevel(stat.GetPlayerData(v, 1))
			v.leaderstats.Coins.Value = stat.GetPlayerData(v, 2)
			
			game.ReplicatedStorage.Results:FireClient(v, baseEXP, stat.GetMultiplier(v))
		end
	end
end

local function hasRunDisaster(Name)
	return table.find(ranDisasters, Name) ~= nil
end

for _, v in pairs(D:GetChildren()) do
	if v:IsA("ModuleScript") then
		table.insert(disasterNames, v.Name)
	end
end

coroutine.wrap(function()
	game.Players.PlayerAdded:Connect(function(p)
		misc.SetPlaying(p, true)
		stat.RetrieveStats(p)
		p.CharacterAdded:Connect(function(c)
			local h = c:WaitForChild("Humanoid")
			h.Died:Connect(function()
				misc.SetPlaying(p, false)
			end)
		end)
	end)
	
	game.Players.PlayerRemoving:Connect(function(p)
		misc.SetPlaying(p, false)
		stat.StoreStats(p)
		if damageTable[p.Name] then damageTable[p.Name] = nil end
	end)
end)()

while true and wait() do
	wait(INTERMISSION_TIME)

	misc.SetAllPlaying(true)
	misc.InitMap()
	
	if TEST_MODE then
		for _, v in pairs(game.ServerScriptService.TestDisasters:GetChildren()) do
			x = require(v)
			x.Run()
			updateStats()
		end
	else
		local n = math.random(1, #disasterNames) -- Run random disaster.
		local chosen = disasterNames[n]
		if not hasRunDisaster(chosen) then
			chosen = require(D[chosen])
			chosen.Run()
			updateStats()
		else
			D[chosen].Run()
			updateStats()
		end
	end
	
	misc.SetAllPlaying(false)
end