local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")

local tools = serverStorage.Tools
local NPC_Factory = require(replicatedStorage.Modules.NPCFactory)
local Movement = require(replicatedStorage.Modules.Movement)
local waveFolder = workspace.WaveFolder

local katana = tools.Katana
local npc_Templates = serverStorage.NPC_template
local melee_Template = npc_Templates.melee_NPC
local ranged_Template = npc_Templates.ranged_NPC

local melee = melee_Template:Clone()
local melee_Humanoid = melee:FindFirstChild("Humanoid")

local melee_Tags = melee_Template:GetTags()
local ranged_Tags = ranged_Template:GetTags()

local waveManage = {
	
}

local function buffWave(waveName, multiplier)
	if not waveManage[waveName] then return end
	
	for _, npc in ipairs(waveManage[waveName]) do
		local hum = npc:FindFirstChild("Humanoid")
		if hum then
			hum.MaxHealth *= multiplier
			hum.Health = hum.MaxHealth
			hum.WalkSpeed *= multiplier
		end
	end
end

local function isWaveCleared(waveName)
	if not waveManage[waveName] then return end
	
	for _, npc in ipairs(waveManage[waveName]) do
		if npc and npc.Parent then
			local hum = npc:FindFirstChild("Humanoid")
			if hum and hum.Health > 0 then
				return false
			end
		end
	end
	return true
end


function waveManager()

	for waveLevel = 1, 5  do

		
		local wave = Instance.new("Folder")
		wave.Name = "Wave_"..waveLevel
		wave.Parent = waveFolder
		
		waveManage[wave.Name] = {}
		
		if waveLevel > 1 then
			if not isWaveCleared() then
				return
			end

		end
		
		local NumberNpc = 10
		for npcNumber = 1, NumberNpc  do

			local npc = NPC_Factory.spawner(melee_Template, npcNumber, melee_Tags[1], katana, CFrame.new(1, 1, 1), waveLevel)
			local waveNpc = wave:GetChildren()
			waveManage[wave.Name][npcNumber] = waveNpc[npcNumber]
			
		end
		
		
		if waveLevel > 2  then
			buffWave(wave.Name, 1.5 * waveLevel)
		end
	end
	print(waveManage)
end

--waveManager() 
local taskManager = coroutine.create(waveManager)
coroutine.resume(taskManager)
