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
	self.waveAlive = {}      -- tracks remaining NPCs per wave
	self.waveClearedCallbacks = {}  -- optional: for external code to wait
	self.numberOfWaveCleared = 0
	
	function self:BuffWave(multiplier, waveName)
		local waveManager = self.waveManage

		if not waveManager[waveName] then return end

		for _, npc in ipairs(waveManager[waveName]) do
			local hum = npc:FindFirstChild("Humanoid")
			if hum then
				hum.MaxHealth *= multiplier
				hum.Health = hum.MaxHealth
				--hum.WalkSpeed *= multiplier * 0.5
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
		end
		
		print("wave cleared")
		return true
		
	end
	
	function self:WaitForWaveClear(waveName)
		if not self.waveAlive[waveName] or self.waveAlive[waveName] <= 0 then
			return
		end

		local done = false
		self.waveClearedCallbacks[waveName] = function()
			done = true
		end

		while not done do
			task.wait(0.5)
		end
	end
	
	function self:spawnWave(npc_template, weapon)
		self.currentWave += 1
		self.npcPerWave += 5
		
		updateUi:FireAllClients(self.currentWave)
		
		if self.currentWave > self.maxWaves then
			print(self.currentWave)  
			self.npcPerWave = config.npcPerWave
			self.currentWave = 1
			self.waveManage = {}
			self.waveAlive = {}
			self.waveClearedCallbacks = {}
			self.numberOfWaveCleared += 1
			print("resetting waves for "..self.numberOfWaveCleared.." time")
			updateUi:FireAllClients(self.currentWave)
			-- clear all waves
			local waves = waveFolder:GetChildren()
			
			-- NEW HOOK:
			if self.onCycleCompleted then
				self.onCycleCompleted(self.numberOfWaveCleared)
			end
			
			for _, wave in ipairs(waves) do
				wave:Destroy()
			end
			
			task.wait(2)
		end
		
		local waveName = "Wave_" .. self.currentWave
		
		if waveFolder:FindFirstChild(waveName) then
			waveFolder:FindFirstChild(waveName):Destroy()
			
		end
		
		local waveFolderInstance = Instance.new("Folder")
		waveFolderInstance.Name = waveName
		waveFolderInstance.Parent = waveFolder

		local npc_tags = npc_template:GetTags()
		local npc_type = npc_tags[1]
		self.waveManage[waveName] = {}
		self.waveAlive[waveName] = 0

		for i = 1, self.npcPerWave do
			local spawnCframe = CFrame.new(math.random(-10, 10) + i*5, 10, math.random(-10, 10))
			local spawnPos = Vector3.new(math.random(-10, 10) + i*5, 10, math.random(-10, 10))

			local npc = NPC_factory.spawner(
				npc_template, 
				i, 
				npc_type, 
				weapon, 
				spawnCframe, 
				self.currentWave,
				spawnPos
			)

			local model = npc.model
			local humanoid = model:FindFirstChild("Humanoid")
			table.insert(self.waveManage[waveName], model)
			self.waveAlive[waveName] += 1
			
			print(self.waveManage)
			-- HERE: track deaths
			humanoid.Died:Connect(function()
				self.waveAlive[waveName] -= 1
				print(self.waveAlive, self.waveClearedCallbacks)
				if self.waveAlive[waveName] <= 0 then
					print("Wave", waveName, "cleared")
					if self.waveClearedCallbacks[waveName] then
						self.waveClearedCallbacks[waveName]() -- wake up waiter
						
					end
				end
			end)
		end

		if self.currentWave > 2 then
			self:BuffWave(1.5 * self.currentWave, waveName)
		end
	end

	
	return self
end


return Wave_Manager
