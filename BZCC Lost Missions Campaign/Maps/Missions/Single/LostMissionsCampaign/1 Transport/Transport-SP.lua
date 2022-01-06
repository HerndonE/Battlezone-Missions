--[[
___________                                                  __   
\__    ___/___________    ____   ____________   ____________/  |_ 
  |    |  \_  __ \__  \  /    \ /  ___/\____ \ /  _ \_  __ \   __\
  |    |   |  | \// __ \|   |  \\___ \ |  |_> >  <_> )  | \/|  |  
  |____|   |__|  (____  /___|  /____  >|   __/ \____/|__|   |__|  
                      \/     \/     \/ |__|                       

Battlezone Lost Missions Campaign | Mission 2: Transport

Event Scripting: Ethan Herndon "F9bomber"
Map Design and SFX: SirBramley
Voice Acting: PredaHunter, Ken Miller, SirBramley, Shock, and Firefly

]]--

local Mission = {
   --Integers--
   TPS = 0,
   MissionTimer = 0,
   TurnCounter = 0,
   
--Mission Variables--
   _Text1 = "OBJECTIVE: Escort your forces to the 'landing area'. ";
   _Text2 = "OBJECTIVE: Setup a base and await further instruction.";
   _Text3 = "Incoming Transmission...";
   _Text4 = "OBJECTIVE: Goto and protect Red Squad, their support is vital!\n\nEnsure the team leaders survive.";
   _Text5 = "OBJECTIVE: Heal Red Squad and await their assessment.";
   _Text6 = "OBJECTIVE: Escort Red Squad to the buffer zone.";
   _Text7 = "OBJECTIVE: Escort Red Squad Transport back to base!";
   --_Text8 = "OBJECTIVE: Await further instructions. Ensure the transport survives!";
   _Text9 = "OBJECTIVE: Escort Red Squad Transport to the dropship";
   _Text10 = "Congratulations Commander!";
   --_Text11 = "Mission Failed! Consider the objective scrubbed";
   _Text12 = "Mission Failed! Consider the objective scrubbed.\n\nCpt. Higgs has died.";
   _Text13 = "Mission Failed! Consider the objective scrubbed.\n\nLt. Miller has died.";
   _Text14 = "Mission Failed! Consider the objective scrubbed.\n\nTransport has died.";
   _Text15 = "You disobeyed a direct order. Consider the mission a failure.";
   hour = 3600;
   ObjectiveOne = false;
   ObjectiveTwo = false;
   ObjectiveThree = false;
   ObjectiveFour = false;
   ObjectiveFive = false;
   ObjectiveSix = false;
   ObjectiveSeven = false;
   AttackBool = false;
   AttackBool2 = false;
   testBool = false;
   testBool1 = false;
   testBool2 = false;
   testBool3 = false;

   notAroundBool = false;
   checkTrans = false;

   HumanMinion1;
   HumanMinion2;
   nav1;
   nav2;
   nav7;
   nav8;
   BioNav1;
   BioNav2;
   BioNav3;
   cons;
   PlayerH = GetPlayerHandle();
   DropShip;
   HumanRecycler = GetHandle("Recycler");

   --Red Squad Variables--
   redTurretLeader;
   redTurret1;
   redTurret2;
   redTurret3;
   redTurret4;
   redTurret5;
   redTankLeader;
   redTankMinion1;
   redTankMinion2;
   transport;
   redLeader;
   minion1;
   minion2;
   
   --Scions--
   EnemyRecycler = GetHandle("Matriarch");
   ---------------------

  
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
 
   if (IsOdf(h, "ivrecy")) then
   Mission.Recycler = h
   AddScrap(1, 40)
end

if (IsOdf(h, "ibrecy")) then
   Mission.Recycler = h
   
end

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
	
AddScrap(1, 40)
AddScrap(6, 40) 

end

function Start() --This function is called upon the first frame
SetAutoGroupUnits(false)

   print("Transport mission by F9bomber");
   print("Special thanks to SirBramley for making the map");
   print("Special thanks to PredaHunter, Ken Miller, SirBramley, Shock, and Firefly for voice acting");
  
   --print(ImServer());

	AddScrap(1, 40)
	AddScrap(6, 40)
	SetAIP("stock_fi1.aip", 6)

   --------------------------------------------------------
   ------------Colors Done by Ethan Herndon-----3/20/20----
   --Coronavirus
   --------------------------------------------------------

   --[[Orange Squad]]--
   SetTeamColor(1, SetVector(230, 92, 0));
   SetTeamColor(2, SetVector(230, 92, 0));
  
   --[[Red Squad]]--
   SetTeamColor(15, SetVector(171, 0, 0));

   --[[Gray Enemy Color]]--
   SetTeamColor(6, SetVector(128, 128, 128));

   --------------------------------------------------------
   Ally(1, 15)
   Ally(1, 2)
   Ally(2, 15)

   Mission.HumanRecycler=BuildObject("ivrecy",1,"rec");
  --print("recycler is " .. tostring(Mission.HumanRecycler));
   --print("my handle is " .. tostring(Mission.PlayerH));
   
   Mission.HumanMinion1=BuildObject("ivtank",2,"herndon_spawn");
   SetObjectiveName(Mission.HumanMinion1, "Cpt. Herndon");
   Mission.HumanMinion2=BuildObject("ivtank",2,"bramley_spawn");
   SetObjectiveName(Mission.HumanMinion2, "Lt. Bramley");
   SetObjectiveOn(Mission.HumanMinion1)
   SetObjectiveOn(Mission.HumanMinion2)

   local SpawnScavUnits = 6
   local SpawnConsUnits = 1
   for i = 1, SpawnScavUnits  do
      local spawnScavs = BuildObject("fvscav",6, "RecyclerEnemy");
   end

   for i = 1, SpawnConsUnits  do
      local spawnScavs = BuildObject("fvcons",6, "RecyclerEnemy");
   end


   
  
end

function Update() --This function runs on every frame.
Mission.TurnCounter = Mission.TurnCounter + 1;

   -- Call your custom method here
   SurvivalLogic(); -- Ethan Herndon
   TransportMissionSetup(); -- Ethan Herndon
   TransportArrival(); -- Ethan Herndon
   TransportDeparture(); -- Ethan Herndon
   RedSquadArrival(); -- Ethan Herndon
   RedSquadDeployment(); -- Ethan Herndon
   FailConditions(); -- Ethan Herndon

end

function TransportMissionSetup()

   if(Mission.TurnCounter == SecondsToTurns(1))then
      --print("play audio 1");
      AudioMessage("audio1.wav");
   end

   if (Mission.TurnCounter == SecondsToTurns(30)) then --- 30 secs
   
	  --print(ImServer());
   
      Mission.nav1=BuildObject("ibnav",1,"nav1");
      SetObjectiveName(Mission.nav1, "Landing area");
      SetObjectiveOn(Mission.nav1)
      AddObjective(Mission._Text1, "yellow", 15.0);
      --print("play audio 2");
      AudioMessage("audio2.wav");
	  
	    SetLabel(Mission.HumanRecycler, "HumanRec");
      SetObjectiveName(Mission.HumanRecycler, "Surviving Recycler");
      SetObjectiveOn(Mission.HumanRecycler)
	--print("recycler is " .. tostring(Mission.HumanRecycler));
   

      if(Mission.testBool == false)then
         Follow(Mission.HumanMinion1,Mission.HumanRecycler);
         Follow(Mission.HumanMinion2,Mission.HumanMinion1);
         SetObjectiveOff(Mission.HumanMinion1)
         SetObjectiveOff(Mission.HumanMinion2)

         local AttackUnits = 1
         for i = 1, AttackUnits  do
            Goto(BuildObject("fvscout",6, "spawn1"), "spawn1a");
            Goto(BuildObject("fvscout",6, "spawn1.1"), "spawn1b");
            --print("10 sec marker ");
         end

         Mission.testBool = true;
      end

   end


   if ((Mission.ObjectiveOne == false) and (GetDistance(Mission.HumanRecycler,"nav1") < 100.0)) then

      ClearObjectives();
      AddObjective(Mission._Text2, "yellow", 15.0);
      --print("play audio 3");
      AudioMessage("audio3.wav");
      --print( Mission.HumanRecycler);
      SetObjectiveOff(Mission.nav1)
      Defend2(Mission.HumnanMinion1, Mission.HumanRecycler, 1)
      Defend2(Mission.HumanMinion2, Mission.HumanRecycler, 1)

      Mission.BioNav1=BuildObject("ibnav",1,"nav3");
      SetObjectiveName(Mission.BioNav1, "Biometal Pool 1");

      Mission.BioNav2=BuildObject("ibnav",1,"nav4");
      SetObjectiveName(Mission.BioNav2, "Biometal Pool 2");

      Mission.BioNav3=BuildObject("ibnav",1,"nav5");
      SetObjectiveName(Mission.BioNav3, "Biometal Pool 3");

      Mission.ObjectiveOne = true;
      --print("Player is in base location");
      print("Player(s) is at phase 1 of Transport Mission");
   end

   if (Mission.TurnCounter == SecondsToTurns(900)) then --- 15 minutes 900
      Mission.nav2=BuildObject("ibnav",1,"nav6");
      SetObjectiveName(Mission.nav2, "Red Squad location");
      SetObjectiveOn(Mission.nav2)
      ClearObjectives();
      AddObjective(Mission._Text3, "white", 15.0);
      --print("play audio 4");
      AudioMessage("audio4.wav");

      Mission.redTurretLeader = BuildObject("ivturr",15,"redTurretLeader");
      SetObjectiveName(Mission.redTurretLeader, "Lt. Miller");
      SetObjectiveOn(Mission.redTurretLeader)
      Mission.redTurret1 = BuildObject("ivturr",15,"redTurret1");
      Mission.redTurret2 = BuildObject("ivturr",15,"redTurret2");
      Mission.redTurret3 = BuildObject("ivturr",15,"redTurret3");
      Mission.redTurret4 = BuildObject("ivturr",15,"redTurret4");
      Mission.redTurret5 = BuildObject("ivturr",15,"redTurret5");
      Mission.redTankLeader = BuildObject("ivtank_h",15,"redTankLeader");
      SetObjectiveName(Mission.redTankLeader, "Cpt. Higgs");
	  SetObjectiveOn(Mission.redTankLeader);
      Mission.redTankMinion1 = BuildObject("ivscout",15,"redMinion1");
      SetObjectiveName(Mission.redTankMinion1, "Lt. Panko");
      Mission.redTankMinion2 = BuildObject("ivscout",15,"redMinion2");
      SetObjectiveName(Mission.redTankMinion2, "Lt. MacFarland");

      print("Player(s) is at phase 2 of Transport Mission");

   end

   if (Mission.TurnCounter == SecondsToTurns(930)) then --- 15 minutes 30 seconds
      ClearObjectives();
      AddObjective(Mission._Text4, "yellow", 15.0);
   end

end

function RedSquadArrival()

   if(Mission.testBool2 == false)then
      Defend2(Mission.HumnanMinion1, Mission.redTurretLeader, 1)
      Defend2(Mission.HumnanMinion2, Mission.redTurretLeader, 1)
      testBool2 = true;
   end
--[[
	local hostPlayer;
	if(ImServer()) then
	hostPlayer = GetPlayerHandle(Mission.PlayerH)
	end
]]--
	Mission.PlayerH = GetPlayerHandle();
   if ((Mission.ObjectiveTwo == false) and (GetDistance(Mission.PlayerH,"nav6") <= 100.0)) then
   --if ((Mission.ObjectiveTwo == false) and (GetDistance(hostPlayer,"nav6") <= 100.0)) then

      Mission.ObjectiveTwo = true;
      ClearObjectives();
      print("Player(s) is at phase 3 of Transport Mission");
      Defend2(Mission.redTankLeader, Mission.redTurretLeader, 1)
      Defend2(Mission.redTankMinion1, Mission.redTurret1, 1)
      Defend2(Mission.redTankMinion2, Mission.redTurret2, 1)
      Goto(Mission.redTurretLeader,"nav1");
      Goto(Mission.redTurret1,"nav1");
      Goto(Mission.redTurret2,"nav1");
      Goto(Mission.redTurret3,"nav1");
      Goto(Mission.redTurret4,"nav1");
      Goto(Mission.redTurret5,"nav1");



   end


   if ((Mission.ObjectiveThree == false) and (GetDistance(Mission.redTurretLeader,"nav1") < 100.0)) then
      Mission.ObjectiveThree = true;
      ClearObjectives();
      AddObjective(Mission._Text5, "yellow", 15.0);
      SetObjectiveOff(Mission.nav2)
      --print("play audio 5");
      AudioMessage("audio5.wav");
   end

end

function RedSquadDeployment()

   if(Mission.TurnCounter == (SecondsToTurns(960) + SecondsToTurns(400)))then --600 old
      --print("26 minutes has past");
      --print ("play audio 6");
      AudioMessage("audio6.wav");
      ClearObjectives();
      AddObjective(Mission._Text6, "yellow", 15.0);

      Mission.nav7 = BuildObject("ibnav",1,"nav7");
      SetObjectiveName(Mission.nav7, "Deployment Zone");
      SetObjectiveOn(Mission.nav7)

      Defend2(Mission.HumanMinion1, Mission.HumanRecycler, 1)
      Defend2(Mission.HumanMinion2, Mission.HumanRecycler, 1)
      Goto(Mission.redTurretLeader,"nav7");
      Goto(Mission.redTurret1,"nav7");
      Goto(Mission.redTurret2,"nav7");
      Goto(Mission.redTurret3,"nav7");
      Goto(Mission.redTurret4,"nav7");
      Goto(Mission.redTurret5,"nav7");

   end


   if ((Mission.ObjectiveFour == false) and (GetDistance(Mission.redTurretLeader,"nav7") < 100.0))then

      --print ("play audio 7");
      AudioMessage("audio7.wav");
      ClearObjectives();
      SetObjectiveOff(Mission.nav7)
      --SetObjectiveOff(Mission.redTurretLeader) -- Commented out 1.5.22 EH
      Goto(Mission.redTurretLeader,"redleaderd");
      Goto(Mission.redTurret1,"redturr1d");
      Goto(Mission.redTurret2,"redturr2d");
      Goto(Mission.redTurret3,"redturr3d");
      Goto(Mission.redTurret4,"redturr4d");
      Goto(Mission.redTurret5,"redturr5d");

      if(Mission.AttackBool == false)then
         Mission.ObjectiveFour = true;
         Mission.AttackBool = true;
      end
   end

   if((Mission.AttackBool == true) and math.fmod(Mission.TurnCounter, SecondsToTurns(120)) == 0) then
      local AttackUnits = 1
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvscout",6, GetPositionNear("spawnA", 0 , 10, 50)), "spawnaa");
         Goto(BuildObject("fvscout",6, GetPositionNear("spawnB", 0 , 10, 50)), "spawnbb");
         Goto(BuildObject("fvarch",6, GetPositionNear("spawnC", 0 , 10, 50)), "spawncc");
         Goto(BuildObject("fvsent",6, GetPositionNear("spawnD", 0 , 10, 50)), "spawndd");
      end

   end


end

function TransportArrival()

   if(Mission.TurnCounter == (SecondsToTurns(1800)))then --30 -- old 2220 37 minutes
      --print ("play audio 8");
      AudioMessage("audio8.wav");
      print("Player(s) is at phase 4 of Transport Mission");
      ClearObjectives();
      AddObjective(Mission._Text7, "yellow", 15.0);
      Mission.transport=BuildObject("ivstas1",15,"Transport_start");--ivstas1
      SetObjectiveName(Mission.transport, "Transport");
      SetObjectiveOn(Mission.transport)
      --Follow(Mission.redLeader,Mission.transport);

      Mission.redLeader=BuildObject("ivtank_c",15,"Wilmot_start");
      SetObjectiveName(Mission.redLeader, "Comdr. Covell");
      SetObjectiveOn(Mission.redLeader)
      Mission.minion1=BuildObject("ivscout",15,"Wilmot_escort1");
      SetObjectiveName(Mission.minion1, "Lt. Holland");
      Follow(Mission.minion1,Mission.redLeader);
      Mission.minion2=BuildObject("ivscout",15,"Wilmot_escort2");
      SetObjectiveName(Mission.minion2, "Lt. Wilmot");
      Follow(Mission.minion2,Mission.minion1);
      Follow(Mission.redLeader,Mission.transport);

   end

--[[
	local hostPlayer;
	if(ImServer()) then
	hostPlayer = GetPlayerHandle(Mission.PlayerH)
	end
]]--

	Mission.PlayerH = GetPlayerHandle();
   if ((Mission.ObjectiveFive == false) and (GetDistance(Mission.PlayerH,"Transport_start") < 80.0)) then
   --if ((Mission.ObjectiveFive == false) and (GetDistance(hostPlayer,"Transport_start") < 80.0)) then
      --print ("play audio 9");
      AudioMessage("audio9.wav");
      Mission.ObjectiveFive = true;
      SetObjectiveOff(Mission.redLeader)
      Goto(Mission.transport, "transportPath");

      if(Mission.AttackBool2 == false) then
         Mission.AttackBool2 = true;
      end
   end

   if((Mission.AttackBool2 == true) and math.fmod(Mission.TurnCounter, SecondsToTurns(120)) == 0) then
      local AttackUnits = 1
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvtank",6, GetPositionNear("spawnt1", 0 , 10, 50)), Mission.transport);
         Goto(BuildObject("fvtank",6, GetPositionNear("spawnt2", 0 , 10, 50)), Mission.transport);
         Goto(BuildObject("fvtank",6, GetPositionNear("spawnt3", 0 , 10, 50)), Mission.transport);

      end

   end

   if ((Mission.ObjectiveSix == false) and (GetDistance(Mission.transport,"nav1") < 80.0)) then
      --print ("play audio 10");
      AudioMessage("audio10.wav");
      Mission.ObjectiveSix = true;
      ClearObjectives();
      AddObjective(Mission._Text9, "yellow", 15.0);
      --print ("play audio 11");
      AudioMessage("audio11.wav");
      --ClearObjectives();
      --AddObjective(Mission._Text9, "green", 15.0);

      Mission.nav8 = BuildObject("ibnav",1,"dustoff");
      SetObjectiveName(Mission.nav8, "Dust Off Site");
      SetObjectiveOn(Mission.nav8)

      Mission.DropShip = BuildObject("ivdrop",15,"spawnpoint");
      SetAngle(Mission.DropShip , -90)
      SetAnimation(Mission.DropShip , "deploy", 1)
      SetObjectiveOn(Mission.DropShip )
      StartSoundEffect("dropdoor.wav", Mission.DropShip )
      Mission.DropShip  = GetHandle("unnamed_ivdrop")

   end
end

function TransportDeparture()

   if ((Mission.ObjectiveSeven == false) and (GetDistance(Mission.redLeader,Mission.DropShip) < 50.0)) then
      --print ("play audio 12");
      AudioMessage("audio12.wav");
      if (IsAround(Mission.transport)) then
         RemoveObject(Mission.transport);
      end
      Goto(Mission.redLeader,Mission.nav8);
      Mission.DropShip  = GetHandle("unnamed_ivdrop")
      SetObjectiveOff(Mission.DropShip )
      SetAnimation(Mission.DropShip ,"takeoff",1);
      ClearObjectives();
      AddObjective(Mission._Text10, "green", 15.0);
      SetObjectiveOff(Mission.nav8)
      SucceedMission(GetTime() + 15.0, "transp.des")
      print("Player(s) has completed the mission");
      Mission.ObjectiveSeven = true;
      Mission.checkTrans = true;
   end
end

function FailConditions()

   --Check if Captain Higgs and or Lt Miller is gone
   if((Mission.TurnCounter > SecondsToTurns(900)) and (Mission.TurnCounter <= (SecondsToTurns(2220))))then
      if ((Mission.notAroundBool == false) and not IsAlive(Mission.redTankLeader))then --Captain Higgs
         ClearObjectives();
         print("Captain Higgs is Dead");
         AudioMessage("failmessage.wav");
         AddObjective(Mission._Text12, "red", 15.0);
         FailMission(GetTime() + 15.0, "higgs.des")
         Mission.notAroundBool = true;
      end

      if ((Mission.notAroundBool == false) and not IsAlive(Mission.redTurretLeader))then --Lt. Miller
         ClearObjectives();
         print("Lt. Miller is Dead");
         AudioMessage("failmessage.wav");
         AddObjective(Mission._Text13, "red", 15.0);
         FailMission(GetTime() + 15.0, "miller.des")
         Mission.notAroundBool = true;
      end
   end

   --Check of the transport is gone
   if((Mission.checkTrans == false )and (Mission.TurnCounter > (SecondsToTurns(2220))))then
      if ((Mission.notAroundBool == false) and not IsAlive(Mission.transport))then --Transport
         ClearObjectives();
         print("Transport is Dead");
         AudioMessage("failmessage.wav");
         AddObjective(Mission._Text14, "red", 15.0);
         FailMission(GetTime() + 15.0, "transpo.des")
         Mission.notAroundBool = true;
      end
   end
   
   if(Mission.TurnCounter > SecondsToTurns(5))then -- Destroyed Enemy Recycler
	if((Mission.notAroundBool == false) and not IsAlive(Mission.EnemyRecycler))then
		ClearObjectives();
         print("The player destroyed enemy recycler");
         AudioMessage("failmessage.wav");
         AddObjective(Mission._Text15, "red", 15.0);
         FailMission(GetTime() + 5.0)
         Mission.notAroundBool = true;
	end
	end

end

function SurvivalLogic()

   if (math.fmod(Mission.TurnCounter, SecondsToTurns(120)) == 0) then --- 2 minutes

      local AttackUnits = 2
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvscout",6, GetPositionNear("spawn1", 0 , 10, 50)), "spawn1a");
         Goto(BuildObject("fvtank",6, GetPositionNear("spawn1.1", 0 , 10, 50)), "spawn1b");
         --print("Enemy spawned to attack at  2 minute marker");
      end
   end
end

