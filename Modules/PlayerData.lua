local Players = game:GetService("Players")

local PlayerData = {}
PlayerData.__index = PlayerData

local function createFolderFor(player)
	local folder = Instance.new("Folder")
	folder.Name = "PlayerInfo"
	folder.Parent = player

	local levels = Instance.new("IntValue")
	levels.Name = "Levels"
	levels.Value = 1
	levels.Parent = folder

	local wavesCleared = Instance.new("IntValue")
	wavesCleared.Name = "WavesCleared"
	wavesCleared.Value = 0
	wavesCleared.Parent = folder

	return folder
end

function PlayerData.new()
	local self = setmetatable({}, PlayerData)

	self.folders = {}

	Players.PlayerAdded:Connect(function(player)
		self.folders[player] = createFolderFor(player)
		print("Added folder for", player.Name, self.folders)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.folders[player] = nil
	end)

	return self
end

function PlayerData:AddWavesCleared(amount)
	print("AddWavesCleared called. Folders:", self.folders)
	for plr, folder in pairs(self.folders) do
		print("Updating", plr.Name)
		local waves = folder:FindFirstChild("WavesCleared")
		if waves then
			waves.Value += amount
		end
	end
end

return PlayerData
