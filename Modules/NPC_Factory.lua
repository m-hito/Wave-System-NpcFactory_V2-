local collectionService = game:GetService("CollectionService") 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local MovementModule = require(ReplicatedStorage.Modules.Movement)

local Components = {} 

function Components.new(health, speed, patrolRange)
	return { 
		health = health or 100, 
		maxHealth = health or 100, 
		speed = speed or 16, 
		patrolRange = patrolRange or 10 
	}
end

local MovementSystem = {}

function MovementSystem.new(humanoid, targetPos)
	local self = MovementModule.new(humanoid, targetPos, {})

	return self 
end

local NPCfactory = {} 

--print("stuff -------------------------------------------------------------------------------")
local NPC_TYPES = {
	melee = {
		id = "melee", 
		components = Components.new(150, 34, 25),
		modelName = "melee_NPC",
		speed = 34, 
		radius = 25
	},
	ranged = {
		id = "ranged",
		components = Components.new(100, 15, 40),
		modelName = "ranged_NPC",
		speed = 12,
		radius = 40
	}
}

local NPC_Counter = 0

function NPCfactory.new(id, NpcTypeKey, humanoid, model, spawnPos)
	local self = setmetatable({}, NPCfactory) 
	self.id = id 
	self.NpcCounter = 0 
	self.NpcType = NpcTypeKey 

	local npcConfig = NPC_TYPES[NpcTypeKey]
	if not npcConfig then
		warn("Unknown NPC type: ", NpcTypeKey)
		return
	end

	-- ONE block only - config handles ALL types
	local componentHash = npcConfig.components 
	self.components = componentHash
	self.health = componentHash.health 
	self.walkSpeed = componentHash.speed
	self.patrolRange = componentHash.patrolRange 
	self.Humanoid = humanoid
	
	humanoid.WalkSpeed = self.walkSpeed
	self.Position = CFrame.new(1, 1, 1) * spawnPos
	
	--print(self.Position, spawnPos)
	self.model = model
	self.MovementSystem = MovementSystem.new(humanoid, self.Position, {
		Npc_Type = NpcTypeKey,
		speed = self.walkSpeed,
		radius = self.patrolRange},
		spawnPos)
		
	self.NpcCounter += 1
	
	NPC_Counter += 1
	print(NPC_Counter)

	return self 
end

function NPCfactory:GiveTool(npc, tool)
	local Tool = tool:Clone()
	Tool.Parent = workspace
	Tool.Name = tool.Name
	
	--print(Tool.Name)
	
	npc.Humanoid:EquipTool(Tool)
	--print("gave tool")

end

function NPCfactory.spawner(template, id, NpcType, tool, spawnPos: CFrame, waveNpc)
	local waveRoot = workspace:FindFirstChild("WaveFolder")
	if not waveRoot then
		waveRoot = Instance.new("Folder")
		waveRoot.Name = "WaveFolder"
		waveRoot.Parent = workspace
	end

	local waveFolderName = "Wave_" .. waveNpc

	local model = template:Clone()
	local humanoid = model:FindFirstChild("Humanoid")
	local hrp = model:FindFirstChild("HumanoidRootPart")
	local npcData = NPCfactory.new(id, NpcType, humanoid, model, spawnPos)
	print(npcData)
	local movement = MovementModule.new(humanoid, spawnPos, npcData.components)
	
	hrp.CFrame = spawnPos

	if tool then
		NPCfactory:GiveTool(model, tool)
	end
	
	task.spawn(function()
		print(npcData, "npc data")
		while npcData.model:FindFirstChild("Humanoid") do
			
			npcData.MovementSystem:ChasingNpc()
			task.wait(0.5)
		end
	end)
	
	npcData.model = model
	collectionService:AddTag(model, NpcType)
	model:SetAttribute("ID", id)
	
	local npcWave = waveNpc
	--print(npcWave)
	model.Parent = waveRoot:FindFirstChild(waveFolderName)
	
	return npcData

end

--function NPCfactory:movement()

--end

return NPCfactory
