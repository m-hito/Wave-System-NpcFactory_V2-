local collectionService = game:GetService("CollectionService") 
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

function NPCfactory.new(id, NpcType, humanoid, model, targetPos) -- we have built the constructor 
	local self = setmetatable({}, NPCfactory) 
	self.id = id 
	self.NpcCounter = 0 
	if NpcType == "melee" then 
		local componentHash = Components.new(150, 12, 10) 
		self.health = componentHash.health 
		self.walkSpeed = componentHash.speed
		self.patrolRange = componentHash.patrolRange 
		self.NpcType = "melee" 
		self.Humanoid = humanoid
		self.model = model
		self.MovementSystem = MovementSystem.new(humanoid, Vector3.new(-100, 0, 0), {Npc_Type = NpcType})
		self.NpcCounter += 1
	end 

	if NpcType == "ranged" then 
		local componentHash = Components.new(100, 25, 32) 
		self.health = componentHash.health 
		self.walkSpeed = componentHash.speed 
		self.patrolRange = componentHash.patrolRange 
		self.NpcType = "ranged" 
		self.Humanoid = humanoid
		self.model = model
		self.MovementSystem = MovementSystem.new(humanoid, Vector3.new(-100, 0, 0), {Npc_Type = NpcType})
		self.NpcCounter += 1
	end
	

	print(self.NpcCounter)
	return self 

end -- add behaviours 

function NPCfactory:GiveTool(npc, tool)
	local Tool = tool:Clone()
	Tool.Parent = workspace
	Tool.Name = tool.Name
	
	print(Tool.Name)
	
	npc.Humanoid:EquipTool(Tool)
	print("gave tool")

end

function NPCfactory.spawner(template, id, NpcType, tool, spawnPos: CFrame, waveNpc)
	local waveRoot = workspace:FindFirstChild("WaveFolder")
	if not waveRoot then
		waveRoot = Instance.new("Folder")
		waveRoot.Name = "WaveFolder"
		waveRoot.Parent = workspace
	end

	local waveFolderName = "Wave_" .. waveNpc

	--print("template passed:", template, id, NpcType)
	--print("Tool passed:", tool, id)

	local model = template:Clone()
	local humanoid = model:FindFirstChild("Humanoid")
	local hrp = model:FindFirstChild("HumanoidRootPart")
	local npcData = NPCfactory.new(id, NpcType, humanoid, model, Vector3.new(0, 0, 0))
	
	hrp.CFrame = spawnPos

	if tool then
		NPCfactory:GiveTool(model, tool)
	end

	npcData.model = model
	collectionService:AddTag(model, NpcType)
	model:SetAttribute("ID", id)
	
	local npcWave = waveNpc
	print(npcWave)
	model.Parent = waveRoot:FindFirstChild(waveFolderName)
	
	return npcData

end

function NPCfactory:attack(target)

end

--function NPCfactory:movement()

--end

return NPCfactory
