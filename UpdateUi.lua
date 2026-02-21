local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage:WaitForChild('Remotes')

local updateWaveLabel = remotes.UpdateWaveUi
local waveCleared = remotes.WaveCleared
local waveUi = script.Parent
local waveFrame = waveUi.Wave
local waveText = waveFrame.WaveLabel

wait(2)
print("running update ui")

waveCleared.OnClientEvent:Connect(function()
	waveText.Text = "Wave Cleared, starting next wave"
	
end)

updateWaveLabel.OnClientEvent:Connect(function(wave)
	print("inside client event")
	waveText.Text = "Wave: "..wave
end)
print('after client eevent')