local module = {}
local PlayersPlaying = {}

function module.InitMap()
	for _, v in pairs(game.Workspace.MapFolder:GetDescendants()) do
		if v:IsA("Model") or v:IsA("BasePart") then
			v:MakeJoints()
		end
		
		if v:IsA("BasePart") and v.Name ~= "Anchor" then
			v.Anchored = false
		end
	end
end

function module.SetPlaying(p, v) 
	if v then
		table.insert(PlayersPlaying, p.UserId)
	else
		table.remove(PlayersPlaying, table.find(PlayersPlaying, p.UserId))
	end
end

function module.SetAllPlaying(v)
	if v then
		for _, x in pairs(game.Players:GetPlayers()) do
			table.insert(PlayersPlaying, x.UserId)
		end
	else
		for _, x in pairs(PlayersPlaying) do
			x = nil
		end
	end
end

function module.isPlaying(p)
	if p == nil then return false end
	if p:IsA("Player") then
		return table.find(PlayersPlaying, p.UserId) ~= nil
	elseif p:IsA("Model") then
		if game.Players:GetPlayerFromCharacter(p) then
			return table.find(PlayersPlaying, game.Players:GetPlayerFromCharacter(p).UserId) ~= nil
		end
	elseif typeof(p) == "string" then
		if game.Players:FindFirstChild(p) then
			return table.find(PlayersPlaying, game.Players[p].UserId) ~= nil
		end
	else
		return false
	end
end

function module.gpfc(c)
	return game.Players:GetPlayerFromCharacter(c)
end

function module.getHumanoid(p)
	local h = p:FindFirstChild("Humanoid")
	if not h and p.Parent then
		h = p.Parent:FindFirstChild("Humanoid")
	end
	return h
end

function module.getCharacter(n)
	local p = game.Players:FindFirstChild(n)
	if p and p.Character then
		return p.Character
	end
	return nil
end

function module.getHRP(p)
	local h = p:FindFirstChild("HumanoidRootPart")
	if not h and p.Parent then
		h = p.Parent:FindFirstChild("HumanoidRootPart")
	end
	return h
end

function module.getTorso(p)
	local rType = module.getHumanoid(p).RigType
	if rType.RigType == Enum.RigType.R15 then
		return p.Parent:FindFirstChild("UpperTorso")
	else
		return p.Parent:FindFirstChild("Torso")
	end
end

function module.createExplosion(p, RANGE)
	local region = Region3.new(
		Vector3.new(p.Position.X - p.Size.X / 2 - RANGE, p.Position.Y - p.Size.Y / 2 - RANGE, p.Position.Z - p.Size.Z / 2 - RANGE),
		Vector3.new(p.Position.X + p.Size.X / 2 + RANGE, p.Position.Y + p.Size.Y / 2 + RANGE, p.Position.Z + p.Position.Z + RANGE)
	)
	local ps = game.Workspace:FindPartsInRegion3(region)
	for _, v in pairs(ps) do
		if module.getHRP(v.Parent) and module.getHumanoid(v.Parent) and module.gpfc(v.Parent) then
			module.getHumanoid(v.Parent).Health = 0
			module.SetPlaying(module.gpfc(v.Parent), false)
		end
	end
end

function module.cleanUp()
	for _, v in pairs(game.Workspace.DisasterFolder:GetChildren()) do
		v:Destroy()
	end
end

return module