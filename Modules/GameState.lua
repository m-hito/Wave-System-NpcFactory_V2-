-- ReplicatedStorage/Modules/GameState.lua
local GameState = {}
GameState.__index = GameState

function GameState.new()
	local self = setmetatable({}, GameState)
	self.state = "LOBBY"  -- "ARENA"
	return self
end

function GameState:SendToLobby(player)
	self.state = "LOBBY"
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root and workspace:FindFirstChild("LobbySpawn") then
		root.CFrame = workspace.LobbySpawn.CFrame + Vector3.new(0, 3, 0)
	end
end

function GameState:SendToArena(player)
	self.state = "ARENA"
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root and workspace:FindFirstChild("ArenaSpawn") then
		root.CFrame = workspace.ArenaSpawn.CFrame + Vector3.new(0, 3, 0)
	end
end

return GameState
