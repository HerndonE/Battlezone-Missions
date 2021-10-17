--[[
  ___ ___        .__       .___                __   
 /   |   \  ____ |  |    __| _/   ____  __ ___/  |_ 
/    ~    \/  _ \|  |   / __ |   /  _ \|  |  \   __\
\    Y    (  <_> )  |__/ /_/ |  (  <_> )  |  /|  |  
 \___|_  / \____/|____/\____ |   \____/|____/ |__|  
       \/                   \/                      

Battlezone Lost Missions Campaign | Mission 1: Hold Out

Event Scripting: Ethan Herndon "F9bomber"
Voice Acting: SirBramley and Tasia Valenza (Commander Shabayev)

]]--

local Mission = {
   --Integers--
   TPS = 0,
   MissionTimer = 0,
   TurnCounter = 0,

   hour = 1200; --3600
   _text1 = "OBJECTIVE: You and or your crew MUST hold out for until Major Manson arrives! - ISDF Human Resources \n\nGreen Squad will periodically help your situation.";
   _Text7 = "You disobeyed a direct order. Consider the mission a failure.";

   --Squad Units--
   Zdarko;
   Masiker;
   minion1;
   minion2;
   minion3;
   minion4;
   Collins;
   Shabayev;
   
   --Scions--
   EnemyRecycler = GetHandle("Matriarch");

   missionSucceed = false;
   notAroundBool = false;

}

function Save()
   return Mission
end

function Load(...)
   if select("#", ...) > 0 then
      Mission = ...
   end
end

function AddObject(h)
 if (IsOdf(h, "fvrecy")) then
   Mission.EnemyRecycler = h
end

if (IsOdf(h, "fbrecy")) then
   Mission.EnemyRecycler = h
   
end
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

   AddScrap(1, 40)
   AddScrap(6, 40)
   SetAIP("stock_fi1.aip", 6)

   print("Hold Out mission by F9bomber");
   print("Special thanks to SirBramley and Tasia Valenza (Commander Shabayev) for voice acting");

   StartCockpitTimer(Mission.hour, 420,  300) --StartCockpitTimer(Mission.hour, 900,  300)
   AddObjective( Mission._text1, "yellow", 15.0);

   --------------------------------------------------------
   ------------Colors Done by Ethan Herndon-----1/13/20----
   --------------------------------------------------------

   --[[Blue Squad]]--
   --SetTeamColor(0, SetVector(77, 210, 255));
   SetTeamColor(2, SetVector(77, 210, 255));
   --[[Orange Squad]]--
   SetTeamColor(1, SetVector(230, 92, 0));
   SetTeamColor(14, SetVector(230, 92, 0));
   --[[Green Squad]]--
   SetTeamColor(15, SetVector(0, 153, 0));
   --[[Gray Enemy Color]]--
   --SetTeamColor(6, SetVector(128, 128, 128));

   --------------------------------------------------------
   Ally(0, 1)
   Ally(1, 2)
   Ally(1, 14)
   Ally(1, 15)
   Ally(2, 15)
   Ally(2, 14)
   Ally(14, 15)

   local SpawnScavUnits = 6
   local SpawnConsUnits = 1
   for i = 1, SpawnScavUnits  do
      local spawnScavs = BuildObject("fvscav",6, "RecyclerEnemy");
   end

   for i = 1, SpawnConsUnits  do
      local spawnScavs = BuildObject("fvcons",6, "RecyclerEnemy");
   end

   Mission.Zdarko=BuildObject("ivtank",2,"Zdarko_start");
   SetObjectiveName(Mission.Zdarko, "Sgt. Zdarko");
   Mission.minion1=BuildObject("ivscout",2,"Zdarko_escort1");
   SetObjectiveName(Mission.minion1, "Cpt. Herndon");
   Follow(Mission.minion1,Mission.Zdarko);
   Mission.minion2=BuildObject("ivscout",2,"Zdarko_escort2");
   SetObjectiveName(Mission.minion2, "Pvt. J O'Neill");
   Follow(Mission.minion2,Mission.Zdarko);

   Mission.Masiker=BuildObject("ivtank",2,"Masiker_start");
   SetObjectiveName(Mission.Masiker, "Sgt. Masiker");
   Mission.minion3=BuildObject("ivscout",2,"Masiker_escort1");
   SetObjectiveName(Mission.minion3, "Cpt. Bramley");
   Follow(Mission.minion3,Mission.Masiker);
   Mission.minion4=BuildObject("ivtank",2,"Masiker_escort2");
   SetObjectiveName(Mission.minion4, "Lt. Durango");
   Follow(Mission.minion4,Mission.Masiker);

   Mission.Collins=BuildObject("ivtank",14,"Collins_start");
   SetObjectiveName(Mission.Collins, "Mjr. Collins");
   SetObjectiveOn(Mission.Collins)

   Mission.Shabayev=BuildObject("ivtank",14,"spawnNav");
   SetObjectiveName(Mission.Shabayev, "Cmdr. Shabayev");
   SetObjectiveOn(Mission.Shabayev)


end

function Update() --This function runs on every frame.
   Mission.TurnCounter = Mission.TurnCounter + 1;


	if(Mission.TurnCounter > SecondsToTurns(5))then -- Destroyed Enemy Recycler
	if((Mission.notAroundBool == false) and not IsAlive(Mission.EnemyRecycler))then
		ClearObjectives();
         print("The player destroyed enemy recycler");
         AudioMessage("failmessage.wav");
         AddObjective(Mission._Text7, "red", 15.0);
         FailMission(GetTime() + 5.0)
         Mission.notAroundBool = true;
	end
	end

   if(Mission.TurnCounter == SecondsToTurns(1200))then --3600 secs
      local blah3 = BuildObject("ivdrop_land",2,"landpoint");
      SetAngle(blah3, 90)
      StartEmitter(blah3, 1)
      StartEmitter(blah3, 2)
      SetAnimation(blah3, "land", 1)
   end

   local blah4;
   if (Mission.TurnCounter == SecondsToTurns(1214)) then --- 3614 secs

      local AttackUnits = 1
      for i = 1, AttackUnits  do
         local foo = GetHandle("unnamed_ivdrop_land")
         RemoveObject(foo)
         --print("1214 sec marker ");
      end
      blah4 = BuildObject("ivdrop",0,"spawnpoint");
      SetAngle(blah4, 90)
      SetAnimation(blah4, "deploy", 1)
      SetObjectiveOn(blah4)
      StartSoundEffect("dropdoor.wav", blah4)
   end

   if (Mission.TurnCounter == SecondsToTurns(1213.5)) then --- 3613.5 secs --1213.5
      print("Player(s) is at the last phase of Hold Out Mission");
      local nav = BuildObject("ibnav",1,"spawnNav");
      SetObjectiveName(nav, "Meet Up");
      SetObjectiveOn(nav)
      local blah5 = BuildObject("ivtank_m",2,"spawnpoint");
      SetObjectiveOn(blah5)
      Goto(blah5,"spawnNav");
      AudioMessage("m_CatchUpHereProceed.wav");
      --print("1213.5 sec marker ");
      Mission.missionSucceed = true;
      SucceedMission(GetTime() + 18.0, "holdingon.des")
   end

   if (Mission.TurnCounter == SecondsToTurns(1215)) then --- 3615 secs
      blah4 = GetHandle("unnamed_ivdrop")
      SetObjectiveOff(blah4)
      SetAnimation(blah4,"takeoff",1);
   end

   -- Call your custom method here
   SurvivalLogic(); -- Ethan Herndon
   GreenSquadSetup(); -- Ethan Herndon
   GreenSquadDeployment(); -- Ethan Herndon


end

function GreenSquadSetup()
   if (Mission.TurnCounter == SecondsToTurns(1)) then
      print("Player(s) is at phase 1 of Hold Out Mission");
      Patrol(Mission.Collins, "cpatrol", 1)
      Patrol(Mission.Shabayev, "cpatrol", 1)
      local cons = BuildObject("ivcons",15, "spawnpoint");
      SetLabel(cons, "GreenSquadCons");
      Goto(cons,"buildFact");
      Goto(BuildObject("ivturr",15, "spawnpoint"), "turret1Deploy");
      Goto(BuildObject("ivturr",15, "spawnpoint"), "turret2Deploy");
      Goto(BuildObject("ivturr",15, "spawnpoint"), "turret3Deploy");
   end

   if(Mission.TurnCounter == SecondsToTurns(2))then
      AudioMessage("shabeyevCameo_fix1.wav");
   end

   if (Mission.TurnCounter == SecondsToTurns(25)) then --- 20 secs
      local cons = GetHandle("GreenSquadCons")
      if (cons ~= nil) then
         --print("G Handle ");
         Build(cons,"ibpgen_gs",1)
         --print("build ");
      end
   end
   if (Mission.TurnCounter == SecondsToTurns(35)) then --- 35 secs
      local cons = GetHandle("GreenSquadCons")
      if (cons ~= nil) then
         Dropoff(cons,"buildFact");
      end
   end

   if (Mission.TurnCounter == SecondsToTurns(48)) then
      local cons = GetHandle("GreenSquadCons")
      if (cons ~= nil) then
         Goto(cons,"bunker");
      end
   end

   if (Mission.TurnCounter == SecondsToTurns(50)) then
      local cons = GetHandle("GreenSquadCons")
      if (cons ~= nil) then
         --print("G Handle ");
         Build(cons,"ibcbun_gs",1)
         --print("build ");
      end
   end

   if (Mission.TurnCounter == SecondsToTurns(60)) then
      local cons = GetHandle("GreenSquadCons")
      if (cons ~= nil) then
         Dropoff(cons,"bunker");
      end
   end

   if (Mission.TurnCounter == SecondsToTurns(110)) then
      local cons = GetHandle("GreenSquadCons")
      if (cons ~= nil) then
         Goto(cons,"guntower");
      end
   end

   if (Mission.TurnCounter == SecondsToTurns(115)) then
      local cons = GetHandle("GreenSquadCons")
      if (cons ~= nil) then
         Build(cons,"ibgtow_gs",1)
      end
   end

   if (Mission.TurnCounter == SecondsToTurns(117)) then
      local cons = GetHandle("GreenSquadCons")
      if (cons ~= nil) then
         Dropoff(cons,"guntower");
      end

   end



end

function GreenSquadDeployment()
   ------------------------------------------------------------------------
   --[[Green Squad Deployment]]--

   -------
   --Wave 1
   -------
   if (Mission.TurnCounter == SecondsToTurns(120)) then --- 2 minute
      local green1 = BuildObject("ivdrop_land",15,"landpoint");
      SetAngle(green1, 90)
      StartEmitter(green1, 1)
      StartEmitter(green1, 2)
      SetAnimation(green1, "land", 1)
      --print("Green Squad has landed at 2 minutes");
   end

   local green2;
   local greenLeader;
   local greenWing1;
   local greenWing2;

   if (Mission.TurnCounter == SecondsToTurns(134)) then

      local AttackUnits = 1
      for i = 1, AttackUnits  do
         local foo = GetHandle("unnamed_ivdrop_land")
         RemoveObject(foo)

      end
      green2 = BuildObject("ivdrop",0,"spawnpoint");
      SetAngle(green2, 90)
      SetAnimation(green2, "deploy", 1)
      StartSoundEffect("dropdoor.wav", green2)

   end

   if (Mission.TurnCounter == SecondsToTurns(133.25)) then

      Goto(BuildObject("ivtank",15, "greenpath"), "RecyclerEnemy");

   end
   if (Mission.TurnCounter == SecondsToTurns(133.50)) then

      Goto(BuildObject("ivtank",15, "greenpath"), "RecyclerEnemy");

   end
   if (Mission.TurnCounter == SecondsToTurns(133.75)) then

      Goto(BuildObject("ivtank",15, "greenpath"), "RecyclerEnemy");

   end

   if (Mission.TurnCounter == SecondsToTurns(150)) then
      green2 = GetHandle("unnamed_ivdrop")
      SetObjectiveOff(green2)
      SetAnimation(green2,"takeoff",1);
   end

   if (Mission.TurnCounter == SecondsToTurns(160)) then
      green2 = GetHandle("unnamed_ivdrop")
      RemoveObject(green2)
   end

   -------
   --Wave 2
   -------
   if (Mission.TurnCounter == SecondsToTurns(420)) then --- 7 minute
      local green1 = BuildObject("ivdrop_land",15,"landpoint");
      SetAngle(green1, 90)
      StartEmitter(green1, 1)
      StartEmitter(green1, 2)
      SetAnimation(green1, "land", 1)
      --print("Green Squad has landed at 7 minutes");
   end

   if (Mission.TurnCounter == SecondsToTurns(434)) then

      local AttackUnits = 1
      for i = 1, AttackUnits  do
         local foo = GetHandle("unnamed_ivdrop_land")
         RemoveObject(foo)

      end
      green2 = BuildObject("ivdrop",0,"spawnpoint");
      SetAngle(green2, 90)
      SetAnimation(green2, "deploy", 1)
      StartSoundEffect("dropdoor.wav", green2)
   end

   if (Mission.TurnCounter == SecondsToTurns(433.25)) then

      Goto(BuildObject("ivtank",15, "greenpath"), "RecyclerEnemy");

   end

   if (Mission.TurnCounter == SecondsToTurns(433.50)) then

      Goto(BuildObject("ivmisl",15, "greenpath"), "RecyclerEnemy");

   end

   if (Mission.TurnCounter == SecondsToTurns(433.75)) then

      Goto(BuildObject("ivscout",15, "greenpath"), "RecyclerEnemy");

   end

   if (Mission.TurnCounter == SecondsToTurns(450)) then
      green2 = GetHandle("unnamed_ivdrop")
      SetObjectiveOff(green2)
      SetAnimation(green2,"takeoff",1);
   end

   if (Mission.TurnCounter == SecondsToTurns(460)) then
      green2 = GetHandle("unnamed_ivdrop")
      RemoveObject(green2)
   end
   -------
   --Wave 3
   -------
   if (Mission.TurnCounter == SecondsToTurns(660)) then --- 11 minute
      print("Player(s) is at phase 2 of Hold Out Mission");
      local green1 = BuildObject("ivdrop_land",15,"landpoint");
      SetAngle(green1, 90)
      StartEmitter(green1, 1)
      StartEmitter(green1, 2)
      SetAnimation(green1, "land", 1)
      --print("Green Squad has landed at 11 minutes");
   end

   if (Mission.TurnCounter == SecondsToTurns(674)) then

      local AttackUnits = 1
      for i = 1, AttackUnits  do
         local foo = GetHandle("unnamed_ivdrop_land")
         RemoveObject(foo)

      end
      green2 = BuildObject("ivdrop",0,"spawnpoint");
      SetAngle(green2, 90)
      SetAnimation(green2, "deploy", 1)
      StartSoundEffect("dropdoor.wav", green2)
   end

   if (Mission.TurnCounter == SecondsToTurns(673.25)) then

      Goto(BuildObject("ivtank",15, "greenpath"), "RecyclerEnemy");

   end

   if (Mission.TurnCounter == SecondsToTurns(673.50)) then

      Goto(BuildObject("ivscout",15, "greenpath"), "RecyclerEnemy");

   end

   if (Mission.TurnCounter == SecondsToTurns(673.75)) then

      Goto(BuildObject("ivscout",15, "greenpath"), "RecyclerEnemy");

   end

   if (Mission.TurnCounter == SecondsToTurns(690)) then
      green2 = GetHandle("unnamed_ivdrop")
      SetObjectiveOff(green2)
      SetAnimation(green2,"takeoff",1);
   end

   if (Mission.TurnCounter == SecondsToTurns(700)) then
      green2 = GetHandle("unnamed_ivdrop")
      RemoveObject(green2)
   end

   if (Mission.TurnCounter == SecondsToTurns(2820)) then
      AudioMessage("isdf1027.wav");
   end

end

function SurvivalLogic()

   if (GetHealth(Mission.Collins) < 0.7) then
      AddHealth(Mission.Collins, 100);
   end

   if (GetHealth(Mission.Shabayev) < 0.7) then
      AddHealth(Mission.Shabayev, 100);
   end

   if (Mission.TurnCounter == SecondsToTurns(10)) then --- 10 secs
      SetObjectiveOff(Mission.Collins)
      SetObjectiveOff(Mission.Shabayev)
      local AttackUnits = 1
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvscout",6, GetPositionNear("spawn1", 0 , 10, 50)), "spawn1a");
         Goto(BuildObject("fvscout",6, GetPositionNear("spawn1.1", 0 , 10, 50)), "spawn1b");
         AudioMessage("isdf0614.wav");
         --print("Enemy spawned to attack at 10 minute marker.");
      end

   end

   if (Mission.TurnCounter == SecondsToTurns(15)) then --- 15 secs
      AudioMessage("b_WeMustHoldThisPosition.wav");
   end

   if (math.fmod(Mission.TurnCounter, SecondsToTurns(120)) == 0) then --- 2 minutes

      local AttackUnits = 2
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvscout",6, GetPositionNear("spawn1", 0 , 10, 50)), "spawn1a");
         Goto(BuildObject("fvtank",6, GetPositionNear("spawn1.1", 0 , 10, 50)), "spawn1b");
         Goto(BuildObject("fvtank",6, GetPositionNear("spawnT", 0 , 10, 50)), "spawnT.1");
         --print("Enemy spawned to attack at 2 minute marker.");
      end
   end

   if (Mission.TurnCounter == SecondsToTurns(180)) then --- 3 minutes
      local AttackUnits = 3
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvscout",6, GetPositionNear("spawn2", 0 , 10, 50)), "spawn2a");
         Goto(BuildObject("fvtank",6, GetPositionNear("spawn2.1", 0 , 10, 50)), "spawn2b");
         --print("Enemy spawned to attack at 3 minute marker.");
      end
   end

   if (math.fmod(Mission.TurnCounter, SecondsToTurns(180)) == 0) then --- 3 minutes
      local AttackUnits = 5
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvscout",6, GetPositionNear("spawn3", 0 , 10, 50)), "spawn3a");
         Goto(BuildObject("fvtank",6, GetPositionNear("spawn3.1", 0 , 10, 50)), "spawn3b");
         --print("Enemy spawned to attack at 3 minute marker.");
      end
   end

   ------------------------------------------------------------------------
   if (Mission.TurnCounter == SecondsToTurns(600)) then --- 10 minutes
      local AttackUnits = 2
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvscout",6, GetPositionNear("spawn4", 0 , 10, 50)), "spawn4a");
         Goto(BuildObject("fvatank",6, GetPositionNear("spawn4", 0 , 10, 50)), "spawn4a");
         Goto(BuildObject("fvtank",6, GetPositionNear("spawn4.1", 0 , 10, 50)), "spawn4b");
         --print("Enemy spawned to attack at 10 minute marker.");
      end
   end

end

