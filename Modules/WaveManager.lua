local replicatedStorage = game:GetService("ReplicatedStorage")
local NPC_factory = require(replicatedStorage.Modules.NPCFactory)
local waveFolder = workspace:FindFirstChild("WaveFolder")

local remotes = replicatedStorage.Remotes
local updateUi = remotes.UpdateWaveUi

local Wave_Manager = {}
Wave_Manager.__index = Wave_Manager

function Wave_Manager.new(config: {})
	local self = setmetatable({}, Wave_Manager)
	
	self.maxWaves = config.maxWaves or 5
	self.npcPerWave = config.npcPerWave or 10
	self.currentWave = 0
	self.waveManage = {}

	function self:BuffWave(multiplier, waveName)
		local waveManager = self.waveManage

		if not waveManager[waveName] then return end

		for _, npc in ipairs(waveManager[waveName]) do
			local hum = npc:FindFirstChild("Humanoid")
			if hum then
				hum.MaxHealth *= multiplier
				hum.Health = hum.MaxHealth
				hum.WalkSpeed *= multiplier
			end

		end

	end

	
	function self:IsCleared(waveName)
		local wave = waveFolder:FindFirstChild(waveName)
		local npcList = wave:GetChildren()
		
		if not wave then return true end 
		
		for id, npc in pairs(npcList) do
			if npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
				print("wave still running")
				return false
			end
			print("wave cleared")
			return true
		end
		
	end
	
	function self:spawnWave(npc_template, weapon)
		self.currentWave += 1
		updateUi:FireAllClients(self.currentWave)
		
		if self.currentWave > self.maxWaves then return end

		local waveName = "Wave_" .. self.currentWave
		local waveFolderInstance = Instance.new("Folder")
		waveFolderInstance.Name = waveName
		waveFolderInstance.Parent = waveFolder

		local npc_tags = npc_template:GetTags()
		self.waveManage[waveName] = {}

		for i = 1, self.npcPerWave do
			local npc = NPC_factory.spawner(
				npc_template, 
				i, 
				npc_tags[1], 
				weapon, 
				CFrame.new(math.random(-10, 10) + i*5, 10, math.random(-10, 10)), 
				self.currentWave
			)
			
			table.insert(self.waveManage[waveName], npc.model)  -- Store the actual MODEL

		end

		print(self.waveManage)
		if self.currentWave > 2 then
			self:BuffWave(1.5 * self.currentWave, waveName)
		end

	end
	
	return self
end


return Wave_Manager
