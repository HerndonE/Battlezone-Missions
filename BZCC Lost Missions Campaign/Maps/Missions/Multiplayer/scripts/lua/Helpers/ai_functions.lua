assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local M = {
	notAroundBool = false;
	attacker;
}

function M.spawnObjectAtTimeWithOrder(MissionTimeObject, setTimeInSeconds, spawnObject, teamNumber, startingPath, finalPath)
	if (MissionTimeObject == SecondsToTurns(setTimeInSeconds)) then
		Goto(BuildObject(spawnObject, teamNumber, startingPath), finalPath);
   end
   
end

function M.spawnObjectsAtTimeWithOrder(MissionTimeObject, setTimeInSeconds, numberOfObjects, objectsToSpawn, startIndex, endIndex)
	if (MissionTimeObject == SecondsToTurns(setTimeInSeconds)) then
		local AttackUnits = numberOfObjects
		for i = startIndex, endIndex do
			for j = 1, AttackUnits  do
				objectsToSpawn[i]()
			end
		end
	end
end

function M.spawnObjectsAtRepeatTimeWithOrder(MissionTimeObject, setTimeInSeconds, numberOfObjects, objectsToSpawn, startIndex, endIndex)
	if (math.fmod(MissionTimeObject, SecondsToTurns(setTimeInSeconds)) == 0) then
		local AttackUnits = numberOfObjects
		for i = startIndex, endIndex do
			if objectsToSpawn[i] then
				 for j = 1, AttackUnits do
					objectsToSpawn[i]()
				 end
			end
		end
	end
end

function M.buildUnitsAtStart(unit, teamNumber, spawnPoint, numberOfUnits) 
	for i = 1, numberOfUnits  do
	  local spawnObject = BuildObject(unit, teamNumber, spawnPoint);
	end
end

function M.buildUnits(unit, teamNumber, spawnPoint, numberOfUnits) 
	for i = 1, numberOfUnits  do
	  local spawnObject = BuildObject(unit, teamNumber, spawnPoint);
	end
end

function M.checkMissionObjectStatus(aiTable, missionObject, consoleMessage, audioFile, chatMessage, debriefMessage, timeToMenu)
	if (aiTable.notAroundBool == false and not IsAlive(missionObject)) then
		ClearObjectives();
		print(consoleMessage);
		AudioMessage(audioFile);
		AddObjective(chatMessage, "red", 15.0);
		FailMission(GetTime() + timeToMenu, debriefMessage)
		aiTable.notAroundBool = true;
	end
end

function M.spawnHighlightAttackerObjects(objectsToSpawn, numberOfObjects, objectToAttack, startIndex, endIndex)
	local AttackUnits = numberOfObjects
	for i = startIndex, endIndex do
		if objectsToSpawn[i] then
			for j = 1, AttackUnits do
				M.attacker = objectsToSpawn[i]()
				SetObjectiveOn(M.attacker)
				Attack(M.attacker, objectToAttack, 1);
			end
		end
	end
end

function M.spawnAttackerbjects(objectsToSpawn, numberOfObjects, objectToAttack, startIndex, endIndex)
	local AttackUnits = numberOfObjects
	for i = startIndex, endIndex do
		if objectsToSpawn[i] then
			for j = 1, AttackUnits do
				M.attacker = objectsToSpawn[i]()
				Attack(M.attacker, objectToAttack, 1);
			end
		end
	end
end

function M.helloWorld()
	print("hello Ethan");
end

return M