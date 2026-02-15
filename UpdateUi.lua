-- StarterGui/ScreenGui/UpdateUi.lua (localscript)

local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage:WaitForChild('Remotes')

local updateWaveLabel = remotes.UpdateWaveUi
local waveUi = script.Parent
local waveFrame = waveUi.Wave
local waveText = waveFrame.WaveLabel

wait(2)
print("running update ui")
updateWaveLabel.OnClientEvent:Connect(function(wave)
	print("inside client event")
	waveText.Text = "Wave: "..wave
end)
print('after client eevent')
