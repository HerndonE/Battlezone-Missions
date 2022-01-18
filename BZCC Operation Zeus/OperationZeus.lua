--[[
░█▀█░█▀█░█▀▀░█▀▄░█▀█░▀█▀░▀█▀░█▀█░█▀█░░░▀▀█░█▀▀░█░█░█▀▀
░█░█░█▀▀░█▀▀░█▀▄░█▀█░░█░░░█░░█░█░█░█░░░▄▀░░█▀▀░█░█░▀▀█
░▀▀▀░▀░░░▀▀▀░▀░▀░▀░▀░░▀░░▀▀▀░▀▀▀░▀░▀░░░▀▀▀░▀▀▀░▀▀▀░▀▀▀

Battlezone Combat Commander: Operation Zues
Event Scripting: Ethan Herndon
Date: 1/16/2021
Description: This mission is to demonstrate dropships deploying ships in a "Normandy" style invasion.
]] --

local Mission = {
   --Integers--
   TPS = 0,
   MissionTimer = 0,
   TurnCounter = 0,
   TurnCounter2 = 0,
   --Handles--
   Recycler,
   enemyRecycler,
   Player,
   Temp,
   Dropship,
   Dropship2,
   Dropship3,
   Dropship4,
   Dropship5,
   gunSpire1,
   gunSpire2,
   gunSpire3,
   dropoff1,
   powerCrystal,
   nav,
   --Booleans--
   NotAroundBool = false,
   attackHumans = false,
   attackagain = false,
   firstObjective = false,
   secondObjective = false,
   thirdObjective = false,
   attackWave = false,
   --Objectives--
   objectiveOne = "destroy the 3 forward enemy gun towers.\n\nOur forces must break enemy stronghold.",
   objectiveTwo = "Retrieve the power crystal back to base for extraction.",
   objectiveThree = "Great job Cpt. Rogers. Humanity owes you a debt of gratitude.",
}

function Save()
   return Mission
end

function Load(...)
   if select("#", ...) > 0 then
      Mission = ...
   end
end

function AddObject(h) --This function is called when an object appears in the game.

end

function DeleteObject(h) --This function is called when an object is deleted in the game.
end

function InitialSetup()
   Mission.TPS = EnableHighTPS()
   AllowRandomTracks(true)
   local preloadODF = {
      "ivrecy",
      "fvrecy",
      "ibrecy",
      "fvrecy",
   }

   for k,v in pairs(preloadODF) do
      PreloadODF(v)
   end
end

function Start() --This function is called upon the first frame
   SetAutoGroupUnits(false)

   Mission.Recycler = GetHandle("Recycler")
   Mission.enemyRecycler = GetHandle("Matriarch")
   Mission.Dropship = GetHandle("ivbomb")
   Mission.Player = GetPlayerHandle(1)
   Mission.gunSpire = GetHandle("fbspir1")
   Mission.dropoff1 = GetHandle("ibnav")

   AddScrap(1, 40)
   AddScrap(6, 40)

   SetAIP("stock_fi1.aip", 6)
   Ally(1, 2)
   Ally(1, 3)
   Ally(1, 4)
   Ally(1, 6)
   Ally(1, 7)
   Ally(2, 3)
   Ally(2, 4)
   Ally(2, 6)
   Ally(2, 7)

   buildStartingUnits()

end

function Update() --This function runs on every frame.
   Mission.TurnCounter = Mission.TurnCounter + 1
   Mission.TurnCounter2 = Mission.TurnCounter2 + 1
   missionCode()
   SurvivalLogic()

end

function buildStartingUnits()
   Mission.gunSpire1 = BuildObject("fbspir1",5, "gt1");
   Mission.gunSpire2 = BuildObject("fbspir1",5, "gt2");
   Mission.gunSpire3 = BuildObject("fbspir1",5, "gt3");
   Mission.Recycler =  BuildObject("ivrecy", 1,"rspawn");
   Mission.dropoff1 =  BuildObject("ibnav", 5,"d1");
   Mission.powerCrystal =  BuildObject("cotran01", 0,"pspawn");
   BuildObject("ibbomb",2, GetPositionNear("spawn1", 0 , 10, 50))
   BuildObject("ibbomb",3, GetPositionNear("spawn2", 0 , 10, 50))
   BuildObject("ibbomb",4, GetPositionNear("spawn3", 0 , 10, 50))
   BuildObject("ibbomb",6, GetPositionNear("spawn4", 0 , 10, 50))
   BuildObject("ibbomb",7, GetPositionNear("spawn5", 0 , 10, 50))
end

function missionCode() --

if((Mission.TurnCounter2 == (SecondsToTurns(2))))then
ClearObjectives();
AddObjective("Establish a base of operations.", "white", 15.0);
AudioMessage("h1.wav");
end
if((Mission.TurnCounter2 == (SecondsToTurns(60))))then
AudioMessage("Condor_pilot_line.wav");
end


   if ((Mission.NotAroundBool == false )and (Mission.TurnCounter == (SecondsToTurns(5)))) then --Build invasion fleet.
      Mission.Dropship= BuildObject("ivbomb",2, GetPositionNear("spawn1", 0 , 10, 50))
      Mission.Dropship2= BuildObject("ivbomb",3, GetPositionNear("spawn2", 0 , 10, 50))
      Mission.Dropship3= BuildObject("ivbomb",4, GetPositionNear("spawn3", 0 , 10, 50))
      Mission.Dropship4= BuildObject("ivbomb",6, GetPositionNear("spawn4", 0 , 10, 50))
      Mission.Dropship5= BuildObject("ivbomb",7, GetPositionNear("spawn5", 0 , 10, 50))
      SetLabel(Mission.Dropship, "ship");
      SetLabel(Mission.Dropship2, "ship1");
      SetLabel(Mission.Dropship3, "ship2");
      SetLabel(Mission.Dropship4, "ship3");
      SetLabel(Mission.Dropship5, "ship4");
      SetLabel(Mission.gunSpire1,"fbspir1");
      SetLabel(Mission.gunSpire2,"fbspir2");
      SetLabel(Mission.gunSpire3,"fbspir3");
      print("bomber made")
      print(GetCurrentCommand(Mission.Dropship))
      print(GetCurrentCommand(Mission.Dropship2))
      print(GetCurrentCommand(Mission.Dropship3))
      print(GetCurrentCommand(Mission.Dropship4))
      print(GetCurrentCommand(Mission.Dropship5))
   end
   
   local ship1
   local ship2
   local ship3
   local ship4
   local ship5
   ship1 = Mission.Dropship;
   ship1 = GetHandle("ship")

   ship2 = Mission.Dropship2;
   ship2 = GetHandle("ship1")

   ship3 = Mission.Dropship3;
   ship3 = GetHandle("ship2")

   ship4 = Mission.Dropship4;
   ship4 = GetHandle("ship3")

   ship5 = Mission.Dropship5;
   ship5 = GetHandle("ship4")
   local gt = Mission.gunSpire1;
   gt = GetHandle("fbspir1")

   local gt = Mission.gunSpire2;
   gt1 = GetHandle("fbspir2")

   local gt = Mission.gunSpire3;
   gt2 = GetHandle("fbspir3")
   
   if((Mission.NotAroundBool == false )and (Mission.TurnCounter == (SecondsToTurns(30)))) then --Invasion fleet attacks AA GT's.
      Attack(ship1,gt, 1)
      Attack(ship2,gt1, 1)
      Attack(ship3,gt, 1)
      Attack(ship4,gt1, 1)
      Attack(ship5,gt2, 1)
      print(ship1)
      print(gt)
      print("break")
      print(GetCurrentCommand(ship1))
      print(GetCurrentCommand(ship2))
      print(GetCurrentCommand(ship3))
      print(GetCurrentCommand(ship4))
      print(GetCurrentCommand(ship5))
   end

   if((Mission.NotAroundBool == false )and (Mission.TurnCounter == (SecondsToTurns(300)))) then --Destroy fleet after 2 minutes.
      RemoveObject(Mission.ship1);
      RemoveObject(Mission.ship2);
      RemoveObject(Mission.ship3);
      RemoveObject(Mission.ship4);
      RemoveObject(Mission.ship5);
   end



   if( (Mission.TurnCounter > (SecondsToTurns(6))) and not IsAlive(ship1) and not IsAlive(ship2) and not IsAlive(ship3) and not IsAlive(ship4) and not IsAlive(ship5))then --If fleet failed, present objective, reset fleet attack.
      Mission.TurnCounter = 0;
      if(Mission.firstObjective == false)then
         ClearObjectives();
         AddObjective(Mission.objectiveOne, "yellow", 15.0);
         SetObjectiveOn(Mission.gunSpire1)
         SetObjectiveOn(Mission.gunSpire2)
         SetObjectiveOn(Mission.gunSpire3)
		 AudioMessage("h2.wav");
      end
   end

   SetLabel(Mission.powerCrystal, "powerC");
   local powC = Mission.powerCrystal;
   powC = GetHandle("powerC")

   if((Mission.secondObjective == false)and(Mission.TurnCounter > (SecondsToTurns(6))) and not IsAlive(gt) and not IsAlive(gt1) and not IsAlive(gt2))then --If AA GT's destroyed, present objective.
      ClearObjectives();
	  SetObjectiveOff(Mission.gunSpire1)
      SetObjectiveOff(Mission.gunSpire2)
      SetObjectiveOff(Mission.gunSpire3)
      AddObjective(Mission.objectiveTwo, "yellow", 15.0);
      SetObjectiveOn(Mission.powerCrystal)
      Mission.nav = BuildObject("ibnav",1, GetPositionNear("pnav", 0 , 10, 50))
      SetObjectiveName(Mission.nav, "extraction point");
      SetObjectiveOn(Mission.nav)
	  AudioMessage("h3.wav");
      Mission.secondObjective = true;
      Mission.attackHumans = true;
      Mission.attackWave = true;
   end

   if(Mission.secondObjective == true and Mission.thirdObjective == false)then --If power crystal is secured, inform player mission is successful. 

      if((GetDistance(Mission.powerCrystal,"pnav") < 80.0))then
         SetObjectiveOff(Mission.nav)
         ClearObjectives();
         AddObjective(Mission.objectiveThree, "green", 15.0);
		 AudioMessage("h4.wav");
         Mission.thirdObjective = true;
      end

      if((GetDistance(Mission.powerCrystal,"pnav") < 800.0))then
         Mission.attackWave = false;
      end


   end

end

function SurvivalLogic()

   if (Mission.attackHumans == false) and (math.fmod(Mission.TurnCounter, SecondsToTurns(60)) == 0) then --Enemy Waves

      local AttackUnits = 1
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvarch",5, GetPositionNear("attack1", 0 , 10, 50)), "attackrun1");
         Goto(BuildObject("fvtank",5, GetPositionNear("attack1", 0 , 10, 50)), "attackrun1");
         Goto(BuildObject("fvtank",5, GetPositionNear("attack1", 0 , 10, 50)), "attackrun1");
         print("Enemy spawned to attack at 1 min marker");
      end

      local AttackUnits = 1
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvarch",5, GetPositionNear("attack2", 0 , 10, 50)), "attackrun2");
         Goto(BuildObject("fvtank",5, GetPositionNear("attack2", 0 , 10, 50)), "attackrun2");
         Goto(BuildObject("fvtank",5, GetPositionNear("attack2", 0 , 10, 50)), "attackrun2");
         print("Enemy spawned to attack at 1 minute marker");
      end

   end


   if (Mission.attackWave == true) and (math.fmod(Mission.TurnCounter, SecondsToTurns(60)) == 0) then --Friendly Waves 

      local AttackUnits = 1
      for i = 1, AttackUnits  do
         Goto(BuildObject("ivtank",2, GetPositionNear("t1spawn", 0 , 10, 50)), "t1");
         Goto(BuildObject("ivscout",2, GetPositionNear("t2spawn", 0 , 9, 50)), "t1");
         Goto(BuildObject("ivscout",2, GetPositionNear("t3spawn", 0 , 12, 50)), "t1");
         print("Friendly spawned to attack at 1 min marker");
      end

      local AttackUnits = 1
      for i = 1, AttackUnits  do
         Goto(BuildObject("ivtank",2, GetPositionNear("t4spawn", 0 , 10, 50)), "t2");
         Goto(BuildObject("ivtank",2, GetPositionNear("t5spawn", 0 , 12, 50)), "t2");
         Goto(BuildObject("ivtank",2, GetPositionNear("t6spawn", 0 , 8, 50)), "t2");
         print("Friendly spawned to attack at 1 minute marker");
      end

   end


end

