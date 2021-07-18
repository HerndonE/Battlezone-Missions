--[[
___________.__                _____                         .____                   ________                         
\__    ___/|  |__   ____     /     \   ____   ____   ____   |    |    __ _______    \______ \   ____   _____   ____  
  |    |   |  |  \_/ __ \   /  \ /  \ /  _ \ /  _ \ /    \  |    |   |  |  \__  \    |    |  \_/ __ \ /     \ /  _ \ 
  |    |   |   Y  \  ___/  /    Y    (  <_> |  <_> )   |  \ |    |___|  |  // __ \_  |    `   \  ___/|  Y Y  (  <_> )
  |____|   |___|  /\___  > \____|__  /\____/ \____/|___|  / |_______ \____/(____  / /_______  /\___  >__|_|  /\____/ 
                \/     \/          \/                   \/          \/          \/          \/     \/      \/        

Battlezone Combat Commander Single Player Lua Demo
Event Scripting: Ethan Herndon
Date: 7/11/2021
Description: This script is to help modders start their own lua based missions.
References:
1. https://steamcommunity.com/sharedfiles/filedetails/?id=1488402495
2. https://www.lua.org/docs.html

]] --

local Mission = {
   --Integers--
   TPS = 0,
   MissionTimer = 0,
   TurnCounter = 0,
   --Handles--
   Recycler,
   enemyRecycler,
   Player,
   Temp,
   --Booleans--
   recyclerPresent = false,
   recyclerDeployed = false,
   recyclerIsAlive = false,
   enemyRecyclerDeployed = false,
   enemyRecyclerIsAlive = false,
   NotAroundBool = false,
   --Objectives--
   objectiveOne = "Welcome to the Moon!\n\nEstablish a base.",
   objectiveTwo = "Destroy the enemy and enemy base.",
   objectiveThree = "Congratulations! You are now promoted to lieutenant!",
   objectiveFour = "Mission Failed! Restart your training Private."
}

function Save()
   return Mission
end

function Load(...)
   if select("#", ...) > 0 then
      Mission = ...
   end
end

function AddObject(h) --This function is called when an object appears in the game. --
   --[[ This condition checks the player has deployed its
   recycler. In addtion, a warrior spawning and attacking
   the players recycler. ]] 
   if (IsOdf(h, "ibrecy")) then
      ClearObjectives()
      AddObjective(Mission.objectiveTwo, "white", 10.0)
      Mission.Temp = BuildObject("fvtank", 6, "spawn1") --Spawn Warrior.
      SetObjectiveName(Mission.Temp, "Scion Warrior") --Give Warrior a name.
      SetObjectiveOn(Mission.Temp) --Display on screen.
      Attack(Mission.Temp, h, 1) --Attack player recycler.
      Mission.Recycler = h
      Mission.recyclerDeployed = true
      Mission.recyclerIsAlive = true
   end
   --

   --[[ Once the scions has deployed its recycler, its
   highlights its location on the player screen. ]] 
   if (IsOdf(h, "fbrecy")) then
      SetObjectiveName(h, "Scion Recycler")
      SetObjectiveOn(h)
      Mission.enemyRecycler = h
      Mission.enemyRecyclerDeployed = true
      Mission.enemyRecyclerIsAlive = true
   end
   --

   --[[ Highlights players recycler so they know where it is. ]] 
   if (IsOdf(h, "ivrecy")) then
   SetObjectiveName(h, "ISDF Recycler")
   SetObjectiveOn(h)
   Mission.Recycler = h
   Mission.recyclerPresent = true
end
end

function DeleteObject(h) --This function is called when an object is deleted in the game.
end

function InitialSetup()
Mission.TPS = EnableHighTPS()
AllowRandomTracks(true)
end

function Start() --This function is called upon the first frame
SetAutoGroupUnits(false)

Mission.Recycler = GetHandle("Recycler")
Mission.enemyRecycler = GetHandle("Matriarch")
Mission.Player = GetPlayerHandle(1)

AddScrap(1, 40)
AddScrap(6, 40)

AddObjective(Mission.objectiveOne, "white", 5.0)

SetAIP("stock_fi1.aip", 6)
end

function Update() --This function runs on every frame.
Mission.TurnCounter = Mission.TurnCounter + 1

missionCode() --Calling our missionCode function in Update.
end

function missionCode() --
--[[ This condition checks the player has destroyed the enemy recycler and enables the win condition. ]] 
if ((Mission.enemyRecyclerIsAlive == true) and (Mission.NotAroundBool == false) and not IsBuilding(Mission.enemyRecycler))
then -- Destroyed Enemy Recycler.
   ClearObjectives()
   AddObjective(Mission.objectiveThree, "green", 15.0)
   SucceedMission(GetTime() + 5.0, "hound.des")
   Mission.NotAroundBool = true
end
--

--[[ This condition checks the enemy has destroyed the player recycler and enables the fail condition.]] 
if ((Mission.recyclerIsAlive == true) and (Mission.NotAroundBool == false) and not IsBuilding(Mission.Recycler))
then -- Destroyed Recycler.
   ClearObjectives()
   AddObjective(Mission.objectiveFour, "red", 15.0)
   SucceedMission(GetTime() + 5.0, "hound.des")
   Mission.NotAroundBool = true
end
end
