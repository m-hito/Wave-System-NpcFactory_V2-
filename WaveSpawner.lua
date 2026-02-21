local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local WaveManager = require(replicatedStorage.Modules.WaveManager)
local GameState = require(replicatedStorage.Modules.GameState)
local PlayerData = require(replicatedStorage.Modules.PlayerData)

local waveFolder = workspace:FindFirstChild("WaveFolder")

local remotes = replicatedStorage.Remotes
local tools = serverStorage.Tools
local melee_template = serverStorage.NPC_template.melee_NPC
local ranged_template = serverStorage.NPC_template.ranged_NPC

local updateWaveLabel = remotes.UpdateWaveUi
local waveCleared = remotes.WaveCleared
local gameState = GameState.new()
local playerData = PlayerData.new()

local wave_Config = { maxWaves = 2, npcPerWave = 5 }
local manager = WaveManager.new(wave_Config)

manager.onCycleCompleted = function(timesCleared)
	-- increase each player’s WavesCleared by 1 cycle
	playerData:AddWavesCleared(1)
	print("All players: waves cleared cycles =", timesCleared)
end

local function runMatch()
	-- send everyone to arena
	for _, plr in ipairs(Players:GetPlayers()) do
		gameState:SendToArena(plr)
	end

	-- run waves
	for wave = 1, wave_Config.maxWaves do
		print("Starting wave " .. wave)

		if wave <= 2 then
			manager:spawnWave(melee_template, tools.Katana)
		else
			manager:spawnWave(ranged_template, tools.Katana)
		end

		local waveName = "Wave_" .. wave
		manager:WaitForWaveClear(waveName)
		updateWaveLabel:FireAllClients(wave)
		task.wait(3)
	end

	-- send back to lobby
	for _, plr in ipairs(Players:GetPlayers()) do
		gameState:SendToLobby(plr)
	end
end

-- first run after 5 seconds, then loop
task.delay(5, function()
	while true do
		runMatch()
		
		print("waiting for 10 seconds, just completed 1 cycle")
		waveCleared:FireAllClients()
		
		task.wait(10) -- break between loops
	end
end)
