local module = {}

local ServerDataTable, PlayerMultipliers = {}, {}
local ds = game:GetService("DataStoreService")
local dat = ds:GetDataStore("PlayerData")

function module.SetMultiplier(plr, amount)
	PlayerMultipliers[plr.UserId] = amount
end

function module.GetMultiplier(plr)
	return PlayerMultipliers[plr.UserId]
end

function module.FormulateLevel(e)
	local l, d = 1, e
	while d > (l + 1) * 200 do
		l += 1
		d -= l * 200
	end
	return l
end

function module.RetrieveStats(plr)
	local plrKey = "plr_" .. plr.UserId
	
	for i = 1, 5 do
		local s, d = pcall(function()
			return dat:GetAsync(plrKey)
		end)
		if s then
			if d ~= nil then
				ServerDataTable[plrKey] = d
			else
				ServerDataTable[plrKey] = {0, 0}
			end
				
			local ls = Instance.new("Folder", plr)
			ls.Name = "leaderstats"
			
			local level = Instance.new("NumberValue", ls)
			level.Name = "Level"
			local money = Instance.new("NumberValue", ls)
			money.Name = "Coins"
			
			level.Value = module.FormulateLevel(ServerDataTable[plrKey][1])
			money.Value = ServerDataTable[plrKey][2]
			
			return
		else
			wait(1)
			continue
		end
	end
end

function module.StoreStats(plr)
	local plrKey = "plr_" .. plr.UserId
	local plrData = {ServerDataTable["plr_" .. plr.UserId][1], ServerDataTable["plr_" .. plr.UserId][2]}
	
	for i = 1, 5 do
		local s, d = pcall(function()
			dat:SetAsync(plrKey, plrData)
		end)	
		if s then
			ServerDataTable[plrKey] = nil
			break
		else
			wait(1)
			continue
		end
	end
end

function module.GetPlayerData(plr, t)
	return ServerDataTable["plr_" .. plr.UserId][t]
end

function module.SetPlayerData(plr, t, amount)
	ServerDataTable["plr_" .. plr.UserId][t] = amount
end

return module