local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPC = {}

NPC.__index = NPC

function NPC.new(humanoid, targetPos: Vector3, config: {}, spawnPos)
	local self = {}
	
	self.spawnPos = spawnPos
	self.humanoid = humanoid
	self.char = humanoid.Parent
	self.currPos = humanoid.Parent:GetPivot().Position
	self.targetPos = targetPos
	self.radius = config.radius or 50
	self.speed = config.speed or 10
	self.state = "idle"
	self.type = config.Npc_Type

	self.lastTimeCheck = 0
	self.checkInterval = 0.5

	self.humanoid.Died:Connect(function(player)
		if self.humanoid.Health > 0 then return end
		
		self:Died(player, self.type)

	end)
	

	function self:Move()
		local targetPos = self.targetPos
		local humanoid = self.humanoid
		self.state = "moving"
		--print(self.state.."Move() function executed")

		--humanoid.WalkSpeed = self.speed

		humanoid:MoveTo(targetPos)

	end

	function self:ReturnBack(spawnPos)
		--if self.state == "idle" then return end

		local targetPos = spawnPos
		if not targetPos then print(targetPos) return end
		local humanoid = self.humanoid
		self.state = "returning"
		--print(self.state.."ReturnBack() function executed")

		--humanoid.WalkSpeed = self.speed
		humanoid:MoveTo(targetPos)
	end

	function self:ChasingNpc()
		if not self.humanoid or self.humanoid.Health <= 0 then
			--print(self.humanoid)
			return
		end

		--print("chasng Npc")
		local targetPos = self.currPos
		local humanoid = self.humanoid
		self.currPos = humanoid.Parent:GetPivot().Position
		
		--print(self.speed, humanoid.Parent.Name)
		
		local nearestPlayer = self:FindNearestPlayer()

		if nearestPlayer then
			--self.state = "chasing"
			--print(self.state.." Found nearest player..chasing "..nearestPlayer.Name)
			
			targetPos = nearestPlayer:GetPivot().Position
			
			if not targetPos then return end
			
			humanoid:MoveTo(targetPos)
		else
			--self:ReturnBack(targetPos) -- uncomment this to make npc return to their spawn pos 

			self.state = "idle"

			--print(self.state)
			--print(self.state.." lost track of player return to orignal patrol point ")
		end

	end

	function self:FindNearestPlayer()
		if not self.humanoid.Parent then print("Humanoid not found: ", self.humanoid.Parent.Name) end 

		local players = game.Players:GetPlayers()
		local nearestPlayer = nil
		local shortestDistance = self.radius

		if not players then return end 
		for _, player in ipairs(players) do
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				if player.Character and player.Character.Humanoid.Health > 0 then
					local playerPos = player.Character.HumanoidRootPart.Position
					local distance = (playerPos - self.currPos).Magnitude
					--print(distance, self.humanoid.Parent.Name, self.radius)

					if distance <= self.radius and distance <= shortestDistance then
						shortestDistance = distance
						nearestPlayer = player.Character
						

					end
		
				end
				

			end
		end

		return nearestPlayer

	end

	function self:PatrolPoint()
		-- add ur own logic if u want to work further

	end

	function self:Died(killerPlayer, npcType)
		print("Npc died " )
		
		game.Debris:AddItem(self.humanoid.Parent, 4)
	end

	
	setmetatable(self, NPC)

	return self
end

return NPC
