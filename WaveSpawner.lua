local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")

local WaveManager = require(replicatedStorage.Modules.WaveManager)
local waveFolder = workspace:FindFirstChild("WaveFolder")

local remotes = replicatedStorage.Remotes
local tools = serverStorage.Tools
local melee_template = serverStorage.NPC_template.melee_NPC
local updateWaveLabel = remotes.UpdateWaveUi

local wave_Config = {
	maxWaves = 5,
	npcsPerWave = 5,
}

local manager = WaveManager.new(wave_Config)

for wave = 1, wave_Config.maxWaves do
	
	print("Starting wave " .. wave)
	manager:spawnWave(melee_template, tools.Katana)
	task.spawn(function()
		wait(4)
		updateWaveLabel:FireAllClients(wave)
	
	end)
	task.wait(5)
end
