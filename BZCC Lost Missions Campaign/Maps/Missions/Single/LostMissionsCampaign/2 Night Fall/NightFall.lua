--[[
 _______  .__       .__     __    ___________      .__  .__   
 \      \ |__| ____ |  |___/  |_  \_   _____/____  |  | |  |  
 /   |   \|  |/ ___\|  |  \   __\  |    __) \__  \ |  | |  |  
/    |    \  / /_/  >   Y  \  |    |     \   / __ \|  |_|  |__
\____|__  /__\___  /|___|  /__|    \___  /  (____  /____/____/
        \/  /_____/      \/            \/        \/           

Battlezone Lost Missions Campaign | Mission 3: Night Fall

Event Scripting: Ethan Herndon "F9bomber"
Map Design and SFX: SirBramley
Voice Acting: Ken Miller, Nathan Mates, FireRock, and SirBramley
]]--

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local ai = require("ai_functions");

local unitList = {
	function() return Goto(BuildObject("fvscout",6, GetPositionNear("spawn1", 0 , 10, 50)), "spawn1a") end,
	function() return Goto(BuildObject("fvtank",6, GetPositionNear("spawn1.1", 0 , 10, 50)), "spawn1b") end,
	function() return Goto(BuildObject("fvarch",6, GetPositionNear("spawn1.2", 0 , 10, 50)), "spawn1c") end,
}

local Mission = {
   --Integers--
   TPS = 0,
   MissionTimer = 0,
   TurnCounter = 0,
  
   --Mission Variables--
   _Text1 = "OBJECTIVE: Escort Recycler to Red Squads position.";
   _Text2 = "OBJECTIVE: Debrief with Red Squad. Establish a stronghold!";
   _Text3 = "Defend the base while Red Squad triangulates Green Squads Position.";
   _Text4 = "Meet with Red Squad.";
   _Text5 = "OBJECTIVE: Save Green Squad and return them to base.";
   _Text6 = "OBJECTIVE: Escort the constructors. They must survive!";
   _Text7 = "";
   _Text8 = "OBJECTIVE: Destroy that building at all costs!";
   _Text9 = "Congratulations! Await for dropships and leave your base";
   _Text10 = "Cpt. Higgs and Cmdr. Covell will gather information to find Green Squad. \n\nStandby for now";
   _Text11 = "Mission Failed! Consider the objective scrubbed";
   _Text12 = "Mission Failed! Consider the objective scrubbed.\n\nCpt. Higgs has died.";
   _Text13 = "Mission Failed! Consider the objective scrubbed.\n\nCmdr. Covell has died.";
   _Text14 = "Mission Failed! Consider the objective scrubbed.\n\nTransmitter has died.";
   _Text15 = "Mission Failed! Consider the objective scrubbed.\n\nConstructor has died.";
      
   ObjectiveZero = false;
   ObjectiveOne = false;
   ObjectiveTwo = false;
   ObjectiveThree = false;
   ObjectiveFour = false;
   ObjectiveFive = false;
   ObjectiveSix = false;
   ObjectiveSeven = false;
   ObjectiveEight = false;
   ObjectiveNine = false;
   ObjectiveTen = false;
   ObjectiveEleven = false;
   clearOne = false;
   clearTwo = false;
   attackGreenSquad = false;
   counter = false;
   counter2 = false;
   counter3 = false;
   audiobool = false;
   notAroundBool = false;
   checkConStatus = false;

   SurvivalWaveTime30 = 0;
   SurvivalWaveTime33 = 0;
   i = 0;

   -- ISDF
   PlayerH = GetPlayerHandle();
   HumanRecycler = GetHandle("Recycler");
   nav1;
   nav2;
   nav3;
   nav4;
   nav5;

   -- Scions
   RelaySpecial;
   Mine1;
   Mine2;
   EnemyRecycler = GetHandle("Matriarch");

   -- Red Squad
   Higgs;
   Covell;
   Transmitter;
 
   --Green Squad--
   Mates;
   Cons1;
   Cons2;
   greenTank1;
   greenTank2;
   greenTurret;
   greenScout;
   greenPower;
   greenGun1;
   greenGun2;
   greenExtractor;  
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

function DeleteObject(h) -- This function is called when an object is deleted in the game.
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

function Start() -- This function is called upon the first frame
	SetAutoGroupUnits(false)

	AddScrap(1, 40)
	AddScrap(6, 40)
	SetAIP("stock_fi1.aip", 6)

	print("Nigh Fall mission by F9bomber");
	print("Special thanks to SirBramley for making the map");
	print("Special thanks to Ken Miller, Nathan Mates, FireRock, and SirBramley for voice acting");

	-- Orange Squad 
	SetTeamColor(1, SetVector(230, 92, 0));

	-- Red Squad 
	SetTeamColor(15, SetVector(171, 0, 0));

	-- Green Squad
	SetTeamColor(14, SetVector(0, 153, 0));

	Ally(1, 14)
	Ally(1, 15)
	Ally(14, 15)

	Mission.HumanRecycler = BuildObject("ivrecy", 1, "rec");

	-- Spawn Local Red Squad Units
	Mission.Higgs = BuildObject("ivtank_h", 15, "higgs_spawn");
	SetObjectiveName(Mission.Higgs, "Cpt. Higgs");
	Mission.Covell = BuildObject("ivtank_c", 15, "covell_spawn");
	SetObjectiveName(Mission.Covell, "Cmdr. Covell");
	Mission.Transmitter = BuildObject("bbtran00", 15, "transmitter_spawn");
	SetObjectiveName(Mission.transmitter, "transmitter");
	
	ai.buildUnitsAtStart("ivtank", 15, "tank1_spawn", 1);
	ai.buildUnitsAtStart("ivtank", 15, "tank2_spawn", 1);
	ai.buildUnitsAtStart("ivtank", 15, "tank3_spawn", 1);	
	ai.buildUnitsAtStart("ivscout", 15, "scout2_spawn", 1);
	ai.buildUnitsAtStart("ivscout", 15, "scout3_spawn", 1);
	ai.buildUnitsAtStart("ivturr", 15, "turret1_spawn", 1);
	ai.buildUnitsAtStart("ivturr", 15, "turret2_spawn", 1);
	ai.buildUnitsAtStart("ivturr", 15, "turret3_spawn", 1);
	ai.buildUnitsAtStart("ivmisl", 15, "ivmisl1_spawn", 1);
	ai.buildUnitsAtStart("ivmisl", 15, "ivmisl2_spawn", 1);
	
	ai.buildUnitsAtStart("fvscav", 6, "RecyclerEnemy", 6);
	ai.buildUnitsAtStart("fvcons", 6, "RecyclerEnemy", 1);

	AudioMessage("FIX_NF_001_MajCollins.wav");
end

function Update() -- This function runs on every frame.
   Mission.TurnCounter = Mission.TurnCounter + 1

   -- Call your custom method here
   SurvivalLogic(); -- Ethan Herndon
   RecyclerSetup(); -- Ethan Herndon
   BaseSetup(); -- Ethan Herndon
   GreenSquadRescue(); -- Ethan Herndon
   TransmitterProblem(); -- Ethan Herndon
   AttackScionSpecial(); -- Ethan Herndon
   TransmitterSuccess(); -- Ethan Herndon
   FailConditions(); -- Ethan Herndon
end

function RecyclerSetup()
   if ((Mission.ObjectiveZero == false) and Mission.TurnCounter == SecondsToTurns(15)) then -- 15 Seconds
      print("Player is in phase 1 on Night Fall Mission");
	  ClearObjectives();
	  AudioMessage("FIX_NF_002_MajCollins.wav");
      Mission.nav1 = BuildObject("ibnav", 1, "nav1");
      SetObjectiveName(Mission.nav1, "ISDF base");
      SetObjectiveOn(Mission.nav1)
      AddObjective(Mission._Text1, "yellow", 15.0);
      Mission.ObjectiveZero = true;
   end
end

function BaseSetup()
	if ((Mission.ObjectiveOne == false) and (GetDistance(Mission.HumanRecycler, "nav1") < 200.0)) then
		print("Player is in phase 2 on Night Fall Mission");
		ClearObjectives();
		AudioMessage("FIX_NF_003.wav");
		AddObjective(Mission._Text2, "yellow", 15.0);
		SetObjectiveOff(Mission.nav1)
		SetObjectiveOn(Mission.Higgs)
		SetObjectiveOn(Mission.Covell)

		Patrol(Mission.Higgs, "aipatrol", 1);
		Patrol(Mission.Covell, "aipatrol", 1);

		-- Spawn Local Enemy Units
		ai.buildUnits("fvtank", 6, "warrior1_spawn", 1);
		ai.buildUnits("fvtank", 6, "warrior2_spawn", 1);
		ai.buildUnits("fvtank", 6, "warrior3_spawn", 1);	
		ai.buildUnits("fvscout", 6, "scout1_spawn", 1);
		ai.buildUnits("fvsent", 6, "sent1_spawn", 1);
	
		Mission.ObjectiveOne = true;
	end

	if (IsOdf(Mission.HumanRecycler, "ibrecy")) and Mission.TurnCounter <= (SecondsToTurns(600)) then
		if (GetHealth(Mission.Higgs) < 0.7) then 
			AddHealth(Mission.Higgs, 100);
		end

		if (GetHealth(Mission.Covell) < 0.7) then
			AddHealth(Mission.Covell, 100);
		end
	end
end

function GreenSquadRescue()
	if (Mission.TurnCounter == (SecondsToTurns(600))) then -- 10 minutes 900 600
		print("Player is in phase 3 on Night Fall Mission");
		AudioMessage("R_NFPhase4higgs3.wav");
		ClearObjectives();
		AddObjective(Mission._Text3, "yellow", 15.0);
		Goto(Mission.Higgs, "higgsPath", 1);
		Goto(Mission.Covell, "covellPath", 1);
		Mission.Mine1 = BuildObject("proxmine", 6, "mine1spawn");
		Mission.Mine2 = BuildObject("proxmine", 6, "mine2spawn");
	end

	if ((GetDistance(Mission.Covell,"mine1spawn") < 20.0)) then
		Mission.clearOne = true;
	end

	if ((GetDistance(Mission.Higgs,"mine2spawn") < 20.0)) then
		Mission.clearTwo = true;
	end

	if ((Mission.clearTwo == true) and (Mission.clearOne == true) and ((GetDistance(Mission.Covell,"nav2") < 400.0)) and ((GetDistance(Mission.Higgs,"nav2") < 400.0))) then
		ClearObjectives();
		Mission.nav2=BuildObject("ibnav", 1, "nav2");
		SetObjectiveName(Mission.nav2, "Meetup Point");
		SetObjectiveOn(Mission.nav2)
		AddObjective(Mission._Text4, "yellow", 15.0);
		Mission.clearOne = false;
		Mission.clearTwo = false;
	end
	
	Mission.PlayerH = GetPlayerHandle();
	if ((Mission.ObjectiveThree == false) and ((GetDistance(Mission.Covell, "nav2") < 40.0)) and ((GetDistance(Mission.Covell, "nav2") < 40.0)) and ((GetDistance(Mission.PlayerH, "nav2") < 40.0))) then
	--if((Mission.ObjectiveThree == false) and((GetDistance(Mission.Covell,"nav2") < 40.0))and ((GetDistance(Mission.Covell,"nav2") < 40.0)) and ((GetDistance(hostPlayer,"nav2") < 40.0)))then
		ClearObjectives();
		AddObjective(Mission._Text10, "white", 15.0);
		SetObjectiveOff(Mission.nav2)
		Mission.ObjectiveThree = true;
	end

	if (Mission.TurnCounter == (SecondsToTurns(1020))) then -- 17 minutes 1500 1200 1020
		AudioMessage("R_NFPhase5higgs4.wav");
		SetObjectiveOff(Mission.nav2)
		ClearObjectives();
		AddObjective(Mission._Text5, "yellow", 15.0);
		SetObjectiveOff(Mission.Higgs)
		SetObjectiveOff(Mission.Covell)

		-- Spawn Local Green Squad Units
		Mission.Mates = BuildObject("ivtank_mates", 14, "mates_spawn");
		SetObjectiveName(Mission.Mates, "Sgt. Mates");
		SetObjectiveOn(Mission.Mates)
		Mission.Cons1 = BuildObject("ivcons", 14, "cons1_spawn"); 
		Mission.Cons2 = BuildObject("ivcons", 14, "cons2_spawn"); 
		Mission.greenTank1 = BuildObject("ivtank", 14, "gtank1_spawn");
		Mission.greenTank2 = BuildObject("ivtank", 14, "gtank2_spawn");
		Mission.greenTurret = BuildObject("ivturr", 14, "greenTurret_spawn");
		Mission.greenScout = BuildObject("ivscout", 14, "greenScout_spawn");
		Mission.greenPower = BuildObject("ibpgen", 14, "oower_spawn");
		Mission.greenGun1 = BuildObject("ibgtow", 14, "greenGun1_spawn");
		Mission.greenGun2 = BuildObject("ibgtow", 14, "greenGun2_spawn");
		Mission.greenExtractor = BuildObject("ibscup", 14, "greenPool_spawn");

		Mission.ObjectiveFour = true;
		attackGreenSquad = true;
		Mission.checkConStatus = true;
	end

    Mission.PlayerH = GetPlayerHandle();
	if ((Mission.ObjectiveFive == false) and (GetDistance(Mission.PlayerH,Mission.Mates) <= 150.0)) then
		--if((Mission.ObjectiveFive == false) and (GetDistance(hostPlayer,Mission.Mates) <= 150.0))then
		AddObjective(Mission._Text5, "yellow", 15.0);
		ClearObjectives();
		AddObjective(Mission._Text6, "yellow", 15.0);
		AudioMessage("R_Line1.wav");
		Goto(Mission.Cons1, "consPath", 1);
		Goto(Mission.Cons2, "consPath", 1);
		Defend2(Mission.greenTank1, Mission.Cons2, 1);
		Defend2(Mission.greenTank2, Mission.Cons2, 1);
		Goto(Mission.greenTurret, "consPath", 1);
		Goto(Mission.greenScout, "consPath", 1);
		Defend2(Mission.Mates, Mission.Cons1, 1);
		SetObjectiveOff(Mission.Mates)
		SetObjectiveOn(Mission.Cons1)
		SetObjectiveOn(Mission.Cons2)
		Mission.ObjectiveFive = true;
	end
end


function TransmitterProblem()
	if ((Mission.ObjectiveSeven == false)and(GetDistance(Mission.Cons1, "nav1") <= 500.0) and (GetDistance(Mission.Cons2, "nav1") <= 500.0)) then -- and(GetDistance(Mission.Cons1,"gbnav1") < 300.0))
		AudioMessage("R_NFPhase7higgs6.wav");
		print("Player is in phase 5 on Night Fall Mission");
		Mission.ObjectiveSeven = true;
	end

	if (((Mission.ObjectiveEight and Mission.audiobool) == false) and (GetDistance(Mission.Cons1,"nav1") < 250.0))then
		Mission.audiobool = true;

		if (Mission.counter == false) and (Mission.TurnCounter >= SecondsToTurns(2)) then -- iterates every 2 seconds
			Mission.TurnCounter = 0;
			Mission.i = Mission.i + 1;
				if(Mission.i >= 42)then --58
					Mission._Text7 = "Establishing Connection: Failed";
					Mission.counter = true;
					Mission.counter2 = true;
					Mission.i = 0;
				else
					Mission._Text7 = "Establishing Connection: " .. Mission.i .. "%";
				end
			ClearObjectives();
			AddObjective(Mission._Text7, "white", 15.0);
		end

		if (Mission.counter2 == true) and (Mission.TurnCounter >= SecondsToTurns(2)) then -- iterates every 3 seconds
			Mission.TurnCounter = 0;
			Mission.i = Mission.i + 1;
			--print("i = " .. Mission.i);
			if (Mission.i >= 70)then
				Mission._Text7 = "Establishing Connection: Failed";
				Mission.counter2 = false;
				Mission.ObjectiveNine = true;
				Mission.i = 0;
				Mission.ObjectiveEight = true;
				--print("OBJ 9: " .. Mission.ObjectiveNine)
			else
				Mission._Text7 = "Establishing Connection: " .. Mission.i .. "%";
			end
			ClearObjectives();
			AddObjective(Mission._Text7, "white", 15.0);
		end
		--[[
		Mission._Text7 = "Establishing Connection: " .. Mission.i .. "%";
		if(Mission.counter == false)then
		 if (Mission.SurvivalWaveTime30 >= SecondsToTurns(2)) then --- iterates every 2 seconds
			Mission.SurvivalWaveTime30 = 0;
			Mission.i = Mission.i + 1;
			print("i = " .. Mission.i);
			if(Mission.i >= 8)then
			   ClearObjectives();
			   Mission._Text7 = "Establishing Connection: Failed";
			   AddObjective(Mission._Text7, "white", 15.0)
			   Mission.counter = true;
			end
			ClearObjectives();
			AddObjective(Mission._Text7, "white", 15.0);
		 end
		end
		]]--
	end

	if (Mission.ObjectiveNine == true) then
		ai.buildUnits("fvtank", 6, "warriorSL_spawn", 1);
		ai.buildUnits("fvscout", 6, "scoutSL_spawn", 1);
		ai.buildUnits("fvsent", 6, "sentrySL_spawn", 1);
		ai.buildUnits("fvarch", 6, "lancerSL_spawn", 1);
		ai.buildUnits("fvatank", 6, "titanSL_spawn", 1);
		ai.buildUnits("fvturr", 6, "gaurdianSL_spawn", 1);
		ai.buildUnits("fbspir", 6, "gunSL_spawn", 1);
		Mission.RelaySpecial = BuildObject("fbover", 6,"specialSL_spawn");
		SetObjectiveOn(Mission.RelaySpecial)
		AudioMessage("R_NFPhase8higgs7.wav");
		ClearObjectives();
		AddObjective(Mission._Text8, "yellow", 15.0);
		Mission.ObjectiveNine = false;
		Mission.ObjectiveTen = true;
	end
end

function AttackScionSpecial()
	-- Check of the Scion building is gone
	if (Mission.ObjectiveTen == true) then
		if (not IsAlive(Mission.RelaySpecial)) then -- Scion Antenna
		 print("Player is in phase 6 on Night Fall Mission");
		 ClearObjectives();
		 Mission.ObjectiveEleven = true;
		 AudioMessage("R_NFPhase9higgs8.wav");
		 Mission.ObjectiveTen = false;
		end
	end
end

function TransmitterSuccess()
	if (Mission.ObjectiveEleven == true) then
		if (Mission.counter3 == false) and (Mission.TurnCounter >= SecondsToTurns(4)) then -- iterates every 4 seconds
			Mission.TurnCounter = 0;
			Mission.i = Mission.i + 1;
			Mission._Text7 = "Establishing Connection: " .. Mission.i .. "%";
			ClearObjectives();
			AddObjective(Mission._Text7, "white", 15.0);
			if (Mission.i >= 99) then --99
				Mission._Text7 = "Establishing Connection: Success \n";
				Mission.counter3 = true;
				ClearObjectives();
				AddObjective(Mission._Text7 .. Mission._Text9, "green", 15.0);
				print("Player(s) is in that last phase of Night Fall Mission");
				AudioMessage("NF_010.wav");
				SucceedMission(GetTime() + 15.0, "night.des")
				Mission.ObjectiveEleven = false
			end
		end
	end
end

function FailConditions()
	if ((Mission.TurnCounter > SecondsToTurns(10))) then
		ai.checkMissionObjectStatus(ai, Mission.Higgs, "Captain Higgs is Dead", "failmessage.wav", Mission._Text12, "higgs.des", 15.0);
		ai.checkMissionObjectStatus(ai, Mission.Covell, "Cmdr. Covell is Died", "failmessage.wav", Mission._Text13, "covell.des", 15.0);
		ai.checkMissionObjectStatus(ai, Mission.Transmitter, "Transmitter is Died", "failmessage.wav", Mission._Text14, "transm.des", 15.0);
	end

	if (Mission.checkConStatus == true) then
		ai.checkMissionObjectStatus(ai, Mission.Cons1, "Constructor 1 is Died", "failmessage.wav", Mission._Text15, "cons.des", 15.0);
		ai.checkMissionObjectStatus(ai, Mission.Cons2, "Constructor 2 is Died", "failmessage.wav", Mission._Text15, "cons.des", 15.0);
	end

	if (Mission.TurnCounter > SecondsToTurns(5)) then
		ai.checkMissionObjectStatus(ai, Mission.EnemyRecycler, "The player destroyed enemy recycler", "failmessage.wav", Mission._Text11, "", 5.0);
	end
end

function SurvivalLogic()
	if (GetHealth(Mission.EnemyRecycler) < 0.7) then
		AddHealth(Mission.EnemyRecycler, 100);
	end

	ai.spawnObjectsAtRepeatTimeWithOrder(Mission.TurnCounter, 120, 2, unitList, 1, 2);
	ai.spawnObjectsAtRepeatTimeWithOrder(Mission.TurnCounter, 120, 1, unitList, 3, 3);

	if((attackGreenSquad == true) and (math.fmod(Mission.TurnCounter, SecondsToTurns(120)) == 0)) then
		local AttackUnits = 2
		for i = 1, AttackUnits  do
		 Goto(BuildObject("fvtank",6, GetPositionNear("spawn2", 0 , 10, 50)), "spawn2a");
		 Goto(BuildObject("fvtank",6, GetPositionNear("spawn2.1", 0 , 10, 50)), "spawn2b");
		end
	end
end



