--[[
___________.__              .__      _________ __                     .___
\_   _____/|__| ____ _____  |  |    /   _____//  |______    ____    __| _/
 |    __)  |  |/    \\__  \ |  |    \_____  \\   __\__  \  /    \  / __ | 
 |     \   |  |   |  \/ __ \|  |__  /        \|  |  / __ \|   |  \/ /_/ | 
 \___  /   |__|___|  (____  /____/ /_______  /|__| (____  /___|  /\____ | 
     \/            \/     \/               \/           \/     \/      \/ 

Battlezone Lost Missions Campaign | Mission 5: Final Stand

Event Scripting: Ethan Herndon "F9bomber"
Map Design and SFX: SirBramley
Voice Acting: Ken Miller, Nathan Mates, and SirBramley
]]--
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local ai = require("ai_functions");

unitList = {
	function() return Goto(BuildObject("fvarch", 6, GetPositionNear("l1spawn", 0, 10, 50)), "attackrun1") end,
	function() return Goto(BuildObject("fvtank", 6, GetPositionNear("w1spawn", 0, 10, 50)), "attackrun1") end, 
	function() return Goto(BuildObject("fvtank", 6, GetPositionNear("w2spawn", 0, 10, 50)), "attackrun1") end,
	function() return Goto(BuildObject("fvarch", 6, GetPositionNear("l2spawn", 0, 10, 50)), "attackrun2") end,
	function() return Goto(BuildObject("fvtank", 6, GetPositionNear("w3spawn", 0, 10, 50)), "attackrun2") end,
	function() return Goto(BuildObject("fvtank", 6, GetPositionNear("w4spawn", 0, 10, 50)), "attackrun2") end,	 
	function() return Goto(BuildObject("fvtank", 6, GetPositionNear("w1spawn", 0, 10, 50)), "attackrun3") end,
	function() return Goto(BuildObject("fvwalk", 6, GetPositionNear("m1spawn", 0, 10, 50)), "attackrun3") end,
}

local _StartingVehicles = require("_StartingVehicles");

local DoEjectPilot = 0; -- Do 'standard' eject
local DoRespawnSafest = 1; -- Respawn a 'PLAYER' at safest spawnpoint
local DLLHandled = 2; -- DLL handled actions. Do nothing ingame
local DoGameOver = 3; -- Game over, man.

local VEHICLE_SPACING_DISTANCE = 20.0

local PRESNIPE_KILLPILOT = 0;
local PRESNIPE_ONLYBULLETHIT = 1;

local PREPICKUPPOWERUP_DENY = 0;
local PREPICKUPPOWERUP_ALLOW = 1;

local PREGETIN_DENY = 0;
local PREGETIN_ALLOW = 1;

local GameTPS = 20;

local MIN_CPU_SCAVS_AFTER_CLEANUP = 5;
local MAX_CPU_SCAVS = 15;

local MAX_TEAMS = 16;

local SIEGE_DISTANCE = 250.0;

-- How far allies will be from the commander's position
local AllyMinRadiusAway = 30.0;
local AllyMaxRadiusAway = 60.0;

local AIPType0 = 0;
local AIPType1 = 1;
local AIPType2 = 2;
local AIPType3 = 3;
local AIPTypeA = 4;
local AIPTypeL = 5;
local AIPTypeS = 6;
local MAX_AIP_TYPE = 7;

local TEAMRELATIONSHIP_INVALIDHANDLE = 0;
local TEAMRELATIONSHIP_SAMETEAM = 1;
local TEAMRELATIONSHIP_ALLIEDTEAM = 2;
local TEAMRELATIONSHIP_ENEMYTEAM = 3;

local DLL_TEAM_SLOT_RECYCLER = 1;
local DLL_TEAM_SLOT_FACTORY = 2;

-- NETLIST VARS
local NETLIST_MPVehicles = 0;
local NETLIST_StratStarting = 1;
local NETLIST_Recyclers = 2;
local NETLIST_AIPs = 3;
local NETLIST_Animals = 4;
local NETLIST_STCTFGoals = 5;
local NETLIST_IAHumanRecyList = 6;
local NETLIST_IACPURecyclers = 7;
local NETLIST_IAAIPs = 8;

local TAUNTS_GameStart = 0;
local TAUNTS_NewHuman = 1;
local TAUNTS_LeftHuman = 2;
local TAUNTS_HumanShipDestroyed = 3;
local TAUNTS_HumanRecyDestroyed = 4;
local TAUNTS_CPURecyDestroyed = 5;
local TAUNTS_Random = 6;

local AIPTypeExtensions = '0123als';

local CMD_DONE = 0;

local Mission = {
   -- iVars and Timers
   DidInit = false,
   KillLimit = 0,
   TotalGameTime = 0,
   PointsForAIKill = 0,
   KillForAIKill = 0,
   RespawnWithSniper = 0,
   TurretAISkill = 0,
   NonTurretAISkill = 0,
   StartingVehiclesMask = 0,
   IsFriendlyFireOn = 0,
   ElapsedGameTime = 0,
   RemainingGameTime = 0,
   TimeCount = 0,

   -- Handles
   HumanRecycler =  nil,

   -- Ints
   SiegeCounter = 0,
   AssaultCounter = 0,
   TurnCounter = 0,
   FirstAIPSwitchTime = 0,

   -- Tables
   RecyclerHandles = {},
   SpawnedAtTime = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 }, --KM
   TeamIsSetUp = {},
   TeamPos = {},
   NotedRecyclerLocation = {},

   -- Strat Team Variables
   NumHumans = 0,
   StratTeam = 1,
   HumanForce = 0,
   HumanReinforcementTime = 2500;

   -- Booleans
   StartDone = false,
   HumanTeamRace = false,
   CreatingStartingVehicles = false,
   RespawnAtLowAltitude = false,
   GameOver = false,
   HadMultipleFunctioningTeams = false,
   PastAIP0 = false,
   LateGame = false,
   SiegeOn = false,
   setFirstAIP = false,
   AntiAssault = false,

   LastCPUPlan = 0,
   CustomAIPNameBase = nil,

   -- CPU Variables
   CPUHasArmory = false,
   CPUTeamRace = nil,
   CPUTeamNum = 6,
   NumCPUScavs = 0,
   CPUCommBunkerCount = 0,

   CPURecycler = nil,
   CPUScavList = {},

   CPUForce = 0,
   CPUTurretAISkill = 0,
   CPUNonTurretAISkill = 0,
   CPUReinforcementTime = 2000;

   --Mission Variables--
   _Text1 = "OBJECTIVE: Reinforce base positions. Advance against the scion position. Await further orders.";
   _Text2 = "OBJECTIVE: Escort Green Squads constructor to create a forward position.\nProvide additional patrols ahead.";
   _Text3 = "OBJECTIVE: Destroy that structure but do not destroy enemy recycler!";
   _Text4 = "Very good Major Collins.";
   _Text5 = "Go to the evacuation site!";
   _Text6 = "OBJECTIVE Failed: Consider the mission scrubbed.\n\nConstructor is dead.";
   _Text7 = "OBJECTIVE Failed: Consider the mission scrubbed.\n\nHQ is dead.";
	_Text8 = "You disobeyed a direct order. Consider the mission a failure.",
   i = 0;

   ObjectiveZero = false;
   ObjectiveOne = false;
   ObjectiveTwo = false;
   ObjectiveThree = false;
   ObjectiveFour = false;
   notAroundBool = false;
   testBool = false;
   setRumble = false;
   setExplosion = false;

   -- ISDF
   PlayerH;
   navpoint;
   comBunker;

   -- Red Squad
   covell;
   scout1;
   scout2;

   -- Green Squad
   mates;
   tank1;
   tank2;
   cons;
   cons2;

   -- Scions
   Warrior;
   Scout;
   Sentry;
   AlienStructure;
   EnemyRecycler = GetHandle("Matriarch");

   -- Orange Squad
   katherlyn;
   commTower;
   dabombdotcom;
   oRecy;
}

local CheckedSVar3 = false;
local debug = false;

function InitialSetup()
	GameTPS = EnableHighTPS();

	WantBotKillMessages();

	local preloadODF = {
		"ivrecy",
		"fvrecy",
		"ibrecy",
		"fvrecy",
	}

	for k,v in pairs(preloadODF) do
		PreloadODF(v)
	end

	CreateObjectives();
end

function Save()
	return Mission, _StartingVehicles.Save();
end

function Load(MissionData, StartingVehicleData)
	GameTPS = EnableHighTPS();
	SetAutoGroupUnits(false);

	WantBotKillMessages();

	Mission = MissionData;

	_StartingVehicles.Load(StartingVehicleData);

	CreateObjectives();
end

function CreateObjectives()
   ClearObjectives();
   --AddObjective("mpobjective_st.otf", "WHITE", -1.0);
end

function AddObject(h, IsStartingVehicles)

	local ODFName = GetCfg(h);
	local ObjClass = GetClassLabel(h);

	local fRandomNum = GetRandomFloat(1.0);

	if (IsOdf(h, "fvrecy")) then
		Mission.EnemyRecycler = h
	end

	if (IsOdf(h, "fbrecy")) then
		Mission.EnemyRecycler = h
	end

   if (Mission.TurnCounter < 2) then
      if (GetTeamNum(h) == 1) then
         local HumanRecyRace = IsRecyclerODF(h);

         if (HumanRecyRace ~= 0) then
            Mission.HumanTeamRace = HumanRecyRace;
            Mission.HumanRecycler = h;
         end

         local ShellRace = GetVarItemInt("network.session.ivar13");

         if (ShellRace > 0) then
            --[[ if  (ShellRace == 102) then
            ShellRace = 'f';

         elseif  (ShellRace == 101) then
            ShellRace = 'e';

         else
            ShellRace = 'i';
            --]]
            ShellRace = 'f';
            --end

            Mission.CPUTeamRace = ShellRace;
         else
            local h = GetObjectByTeamSlot(Mission.CPUTeamNum, DLL_TEAM_SLOT_RECYCLER);

            if (IsAround(h)) then
               local cpuRace = IsRecyclerODF(h);

               if (cpuRace ~= 0) then
                  Mission.CPUTeamRace = cpuRace;
               end
            else
               Mission.CPUTeamRace = "i";
            end
         end
      end
   end

   local IsTurret = (ObjClass == "CLASS_TURRETTANK");
   local IsCommBunker = (ObjClass == "CLASS_COMMBUNKER" or ObjClass == "CLASS_COMMTOWER");

   if (IsCommBunker) then
      Mission.CPUCommBunkerCount = Mission.CPUCommBunkerCount + 1;
   end

   if (GetTeamNum(h) ~= Mission.CPUTeamNum) then
      local UseTurretSkill = Mission.TurretAISkill
      local UseNonTurretSkill = Mission.NonTurretAISkill;

      if (IsTurret) then
         SetSkill(h, UseTurretSkill);
      else
         SetSkill(h, UseNonTurretSkill);
      end
   end

   if (Mission.RecyclerHandles ~= nil) then
      local isRecyclerVehicle = (ObjClass == "CLASS_RECYCLERVEHICLE");

      if (isRecyclerVehicle) then
         local Team = GetTeamNum(h);

         if (Mission.RecyclerHandles[Team] == 0) then
            Mission.RecyclerHandles[Team] = h;
         end
      end
   end

   if (GetTeamNum(h) == Mission.CPUTeamNum) then
      local UseTurretSkill = Mission.CPUTurretAISkill;
      local UseNonTurretSkill = Mission.CPUNonTurretAISkill;

      if (IsStartingVehicles) then
         if (UseTurretSkill > 0) then
            UseTurretSkill = UseTurretSkill - 1;
         end

         if (UseNonTurretSkill > 0) then
            UseNonTurretSkill = UseNonTurretSkill - 1;
         end
      end

      if ((ObjClass == "CLASS_SCAVENGER") or (ObjClass == "CLASS_SCAVENGERH")) then
         AddCPUScav(h);
      end

      if (ObjClass == "CLASS_ARMORY") then
         Mission.CPUHasArmory = true;
      end

      if (Mission.CPUHasArmory) then
         if (ODFName == "ivtank") then
            GiveWeapon(h, "gspstab_c");
         end

         if (ODFName == "fvtank") then
            GiveWeapon(h, "garc_c");
         end

         if (string.sub(ODFName, 1, 2) == "fv") then
            if (fRandomNum < 0.3) then
               GiveWeapon(h, "gshield");
            elseif (fRandomNum < 0.6) then
               GiveWeapon(h, "gabsorb");
            elseif (fRandomNum < 0.9) then
               GiveWeapon(h, "gdeflect");
            end
         end
      end
   else
      if (GetTeamNum(h) == Mission.StratTeam) then
         if (ObjClass == "CLASS_RECYCLER") then
            if (not Mission.PastAIP0) then
               Mission.PastAIP0 = true;

               local stratchoice = Mission.TurnCounter % 2;

               if (stratchoice == 0) then
                  SetCPUAIPlan(AIPType1);
               elseif (stratchoice == 1) then
                  SetCPUAIPlan(AIPType2);
               elseif (stratchoice == 2) then
                  SetCPUAIPlan(AIPType3);
               end
            end
         else
            if ((ObjClass == "CLASS_ASSAULTTANK") or (ObjClass == "CLASS_WALKER")) then
               Mission.AssaultCounter = Mission.AssaultCounter + 1;
            end
         end
      end

      if ((not Mission.PastAIP0) and (Mission.FirstAIPSwitchTime > 0) and (Mission.TurnCounter > Mission.FirstAIPSwitchTime)) then
         Mission.PastAIP0 = true;
         local stratchoice = Mission.TurnCounter % 2;

         if (stratchoice % 2 == 0) then
            SetCPUAIPlan(AIPType1);
         elseif (stratchoice %2 == 1) then
            SetCPUAIPlan(AIPType2);
         elseif (stratchoice %2 == 2) then
            SetCPUAIPlan(AIPType3);
         end
      end
   end
end

function DeleteObject(h)
   local ObjClass = GetClassLabel(h);

   if (GetTeamNum(h) == Mission.StratTeam) then
      if ((ObjClass == "CLASS_ASSAULTTANK") or (ObjClass == "CLASS_WALKER")) then
         Mission.AssaultCounter = Mission.AssaultCounter - 1;

         if (Mission.AssaultCounter < 0) then
            Mission.AssaultCounter = 0;
         end
      end
   else
      local IsCommBunker = (ObjClass == "CLASS_COMMBUNKER" or ObjClass == "CLASS_COMMTOWER");

      if (IsCommBunker) then
         Mission.CPUCommBunkerCount = Mission.CPUCommBunkerCount - 1;
      end

      if (ObjClass == "CLASS_ARMORY") then
         Mission.CPUHasArmory = false;
      end
   end
end

function Start()
   --_StartingVehicles.Start();

   print("Final stand mission by F9bomber");
   print("Special thanks to Biometalical for making the map");
   print("Special thanks to Ken Miller, Nathan Mates, and SirBramley for voice acting");
   print("File: mpinstant.lua converted by AI_Unit");

   local mapTrnFile = GetMapTRNFilename();
   Mission.RespawnAtLowAltitude = GetODFBool(mapTrnFile, "DLL", "RespawnAtLowAltitude", false);

   Mission.DidInit = true;
   Mission.KillLimit = GetVarItemInt("network.session.ivar0");
   Mission.TotalGameTime = GetVarItemInt("network.session.ivar1");
   Mission.StartingVehiclesMask = GetVarItemInt("network.session.ivar7");
   Mission.PointsForAIKill = GetVarItemInt("network.session.ivar14");
   Mission.KillForAIKill = GetVarItemInt("network.session.ivar15");
   Mission.RespawnWithSniper = GetVarItemInt("network.session.ivar16");
   Mission.IsFriendlyFireOn = GetVarItemInt("network.session.ivar32");

   -- MPI Stuff:
   Mission.HumanForce = GetVarItemInt("network.session.ivar23");
   Mission.CPUForce = GetVarItemInt("network.session.ivar24");

   Mission.TurretAISkill = GetVarItemInt("network.session.ivar17");
   if (Mission.TurretAISkill < 0) then
      Mission.TurretAISkill = 0;
   elseif (Mission.TurretAISkill > 3) then
      Mission.TurretAISkill = 3;
   end

   Mission.NonTurretAISkill = GetVarItemInt("network.session.ivar18");
   if (Mission.NonTurretAISkill < 0) then
      Mission.NonTurretAISkill = 0;
   elseif (Mission.NonTurretAISkill > 3) then
      Mission.NonTurretAISkill = 3;
   end

   Mission.CPUTurretAISkill = GetVarItemInt("network.session.ivar21");
   if (Mission.CPUTurretAISkill < 0) then
      Mission.CPUTurretAISkill = 0;
   elseif (Mission.CPUTurretAISkill > 3) then
      Mission.CPUTurretAISkill = 3;
   end

   Mission.CPUNonTurretAISkill = GetVarItemInt("network.session.ivar22");
   if (Mission.CPUNonTurretAISkill < 0) then
      Mission.CPUNonTurretAISkill = 0;
   elseif (Mission.CPUNonTurretAISkill > 3) then
      Mission.CPUNonTurretAISkill = 3;
   end

   Mission.FirstAIPSwitchTime = GetVarItemInt("network.session.ivar26");
   if (Mission.FirstAIPSwitchTime == 0) then
      Mission.FirstAIPSwitchTime = 180;
   elseif (Mission.FirstAIPSwitchTime > 0) then
      Mission.FirstAIPSwitchTime = GameTPS;
   end

   Mission.NumHumans = CountPlayers();

   -- Handle the players.
   local PlayerEntryH = GetPlayerHandle();
   if (IsAround(PlayerEntryH)) then
      RemoveObject(PlayerEntryH);
   end

   if ((ImServer()) or (not IsNetworkOn())) then
      Mission.ElapsedGameTime = 0;

      if (Mission.RemainingGameTime == 0) then
         Mission.RemainingGameTime = Mission.TotalGameTime * 60 * GameTPS;
      end
   end

   local LocalTeamNum = GetLocalPlayerTeamNumber();
   --local PlayerH = SetupPlayer(LocalTeamNum);
   --SetAsUser(PlayerH, LocalTeamNum);
   --AddPilotByHandle(PlayerH);

   Mission.PlayerH = SetupPlayer(LocalTeamNum);
   SetAsUser(Mission.PlayerH, LocalTeamNum);
   AddPilotByHandle(Mission.PlayerH);

   print(Mission.PlayerH);

   CreateObjectives();

   DoTaunt(TAUNTS_GameStart);

	if (debug) then
		Ally(Mission.StratTeam, Mission.CPUTeamNum);
		Ally(Mission.CPUTeamNum, Mission.StratTeam);
	end

	-- Orange Squad
	SetTeamColor(13, SetVector(230, 92, 0))

	-- Red Squad
	SetTeamColor(15, SetVector(171, 0, 0))

	-- Green Squad
	SetTeamColor(14, SetVector(0, 153, 0))
	SetTeamColor(12, SetVector(0, 153, 0))

	-- Gray Enemy Color
	SetTeamColor(6, SetVector(128, 128, 128));

	-- Blue Squad
	SetTeamColor(1, SetVector(77, 210, 255));
	SetTeamColor(2, SetVector(77, 210, 255));
	SetTeamColor(3, SetVector(77, 210, 255));
	SetTeamColor(4, SetVector(77, 210, 255));

	Ally(1, 14)
	Ally(2, 14)
	Ally(3, 14)
	Ally(4, 14)
	Ally(1, 15)
	Ally(2, 15)
	Ally(3, 15)
	Ally(4, 15)
	Ally(1, 13)
	Ally(2, 13)
	Ally(3, 13)
	Ally(4, 13)
	Ally(14, 15)
	Ally(13, 15)
	Ally(13, 14)
	Ally(1, 12)
	Ally(2, 12)
	Ally(3, 12)
	Ally(4, 12)
	Ally(14, 12)
	Ally(13, 12)
	Ally(15, 12)

    -- Spawn Local Units
	Mission.covell = BuildObject("ivtank", 15, "cspawn")
    SetObjectiveName(Mission.covell, "Cmdr. Covell")
    Mission.mates = BuildObject("ivtank", 14, "mspawn")
    SetObjectiveName(Mission.mates, "Sgt. Mates")
    Mission.katherlyn = BuildObject("ivtank", 13, "kspawn")
    SetObjectiveName(Mission.katherlyn, "Lt. Katherlyn")
    Mission.commTower = BuildObject("ibcommand_kp", 13, "comspawn")
    SetObjectiveName(Mission.commTower, "HQ")
    SetObjectiveOn(Mission.commTower)
    Mission.AlienStructure = BuildObject("ibtele", 6, "alien")
    SetObjectiveName(Mission.AlienStructure, "Key Alien Structure")
    SetObjectiveOn(Mission.AlienStructure)
    Mission.tank1 = BuildObject("ivtank", 14, "upatrol1")
    Mission.tank2 = BuildObject("ivtank", 14, "upatrol2")
    Mission.scout1 = BuildObject("ivscout", 15, "upatrol3")
    Mission.scout2 = BuildObject("ivscout", 15, "upatrol4")
    Mission.oRecy = BuildObject("ibrecy", 13, "orecyspawn")

    SetAIP("stock_if1.aip", 13)
    SetAIP("stock_if1.aip", 14)
    SetAIP("stock_if1.aip", 15)

	ai.buildUnitsAtStart("fvscav", 6, "RecyclerEnemy", 6);
	ai.buildUnitsAtStart("fvcons", 6, "RecyclerEnemy", 1);
end

function Update()

   -- Increment this once per tick
   Mission.TurnCounter = Mission.TurnCounter + 1;
   DoGenericStrategy(Mission.TeamIsSetUp, Mission.RecyclerHandles);

   ExecuteCheckIfGameOver();
   UpdateGameTime();

   if ((Mission.TurnCounter % (10 * GameTPS)) == 0) then
      for i = 1, MAX_TEAMS do
         local h = GetPlayerHandle(i);

         if (IsAround(h)) then
            local Grp = WhichTeamGroup(i);

            if (Grp ~= 0) then
               Damage(h, 9999);
               AddToMessagesBox("MPI is limited to 5 humans! No joining the CPU team!");
            end
         end
      end
   end

   -- Call your custom method here
   SurvivalLogic(); -- Ethan Herndon
   objectiveSetup(); -- Ethan Herndon
   GreenSquadSetup(); -- Ethan Herndon
   createForwardPosition(); -- Ethan Herndon
   failConditions(); -- Ethan Herndon

end

function objectiveSetup()
	if ((Mission.ObjectiveZero == false) and Mission.TurnCounter == SecondsToTurns(3)) then -- 5 Seconds
		print("Player is in phase 1 on Final Stand Mission")
		AudioMessage("FS_finalstand_harper_1a.wav")
		AddObjective(Mission._Text1, "yellow", 15.0)
		Patrol(Mission.covell, "cpatrol", 1)
		Patrol(Mission.mates, "mpatrol", 1)
		Patrol(Mission.katherlyn, "kpatrol", 1)
		Patrol(Mission.tank1, "upatrol", 1)
		Patrol(Mission.tank2, "upatrol", 1)
		Patrol(Mission.scout1, "upatrol", 1)
		Patrol(Mission.scout2, "upatrol", 1)
		Mission.ObjectiveZero = true
	end

	if ((Mission.ObjectiveOne == false) and Mission.TurnCounter == SecondsToTurns(900)) then
		print("Player is in phase 2 on Final Stand Mission")
		AudioMessage("FS_Line4.wav")
		ClearObjectives()
		AddObjective(Mission._Text2, "yellow", 15.0)
		Mission.navpoint = BuildObject("ibnav", 1, "comnav")
		SetObjectiveName(Mission.navpoint, "Forward Position")
		SetObjectiveOn(Mission.navpoint)
		Mission.ObjectiveOne = true
	end

	if ((Mission.ObjectiveThree == false) and (not IsAlive(Mission.AlienStructure))) then -- Key alien structure
		print("Player is in phase 4 on Final Stand Mission")
		ClearObjectives()
		AddObjective(Mission._Text4, "green", 15.0)
		AudioMessage("FS_finalstand_harper_4c.wav")
		Mission.ObjectiveThree = true
	end

	if ((Mission.ObjectiveThree == true) and (Mission.ObjectiveFour == false) and (not IsAlive(Mission.AlienStructure))) then -- Key alien structure
		print("Player is in last phase on Final Stand Mission")
		ClearObjectives()
		Mission.dabombdotcom = BuildObject("dabomb", 1, "kspawn")
		SetObjectiveName(Mission.dabombdotcom, "The Bomb")
		SetObjectiveOn(Mission.dabombdotcom)
		Mission.navpoint = BuildObject("ibnav", 1, "hold3")
		SetObjectiveName(Mission.navpoint, "Evac Site")
		SetObjectiveOn(Mission.navpoint)
		AddObjective(Mission._Text5, "yellow", 15.0)
		AudioMessage("FS_010.wav")

		rumbleTime = GetTime() + 25.0
		explosionTime = GetTime() + 29.35
		Mission.setExplosion = true
		Mission.setRumble = true

		SucceedMission(GetTime() + 30, "final.des")
		Mission.ObjectiveFour = true
	end

	if Mission.setRumble == true and Mission.TurnCounter == SecondsToTurns(rumbleTime) then
		StartEarthQuake(30.0)
		Mission.setRumble = false
	end

	if Mission.setExplosion == true and Mission.TurnCounter == SecondsToTurns(rumbleTime) then
		SetColorFade(1, 0.1, "white")
		Mission.setRumble = false
	end
end

function GreenSquadSetup()
	if (Mission.TurnCounter == SecondsToTurns(1)) then
		Mission.cons = BuildObject("ivcons", 12, "con1")
		Mission.cons2 = BuildObject("ivcons", 12, "con2")
		SetLabel(Mission.cons, "GreenSquadCons")
		Goto(Mission.cons, "con1build")
		SetLabel(Mission.cons2, "GreenSquadCons1")
		Goto(Mission.cons2, "con2build")
	end

	if (Mission.TurnCounter == SecondsToTurns(30)) then
		local cons = Mission.cons
		local cons2 = Mission.cons2
		cons = GetHandle("GreenSquadCons")
		cons2 = GetHandle("GreenSquadCons1")
		if (cons ~= nil) then
			Build(cons, "ibgtoww2", 1)
			Build(cons2, "ibgtoww2", 1)
		end
	end

	if (Mission.TurnCounter == SecondsToTurns(35)) then
		local cons = Mission.cons
		local cons2 = Mission.cons2
		cons = GetHandle("GreenSquadCons")
		cons2 = GetHandle("GreenSquadCons1")
		if (cons ~= nil) then
			Dropoff(cons, "con1build")
			Dropoff(cons2, "con2build")
		end
	end

	if (Mission.TurnCounter == SecondsToTurns(60)) then
		local cons = Mission.cons
		local cons2 = Mission.cons2
		cons = GetHandle("GreenSquadCons")
		cons2 = GetHandle("GreenSquadCons1")
		if (cons ~= nil) then
			Goto(cons, "mspawn")
			Goto(cons2, "mspawn")
		end
	end
end

function createForwardPosition()
	if (Mission.TurnCounter == SecondsToTurns(900)) then
		BuildObject("ivturr", 14, "fodder1")
		BuildObject("ivturr", 14, "fodder6")
		local FodderUnits = 3
		for i = 1, FodderUnits do
			BuildObject("ivtank", 14, "fodder1")
			BuildObject("ivtank", 14, "fodder2")
			BuildObject("ivtank", 14, "fodder3")
			BuildObject("ivscout", 14, "fodder4")
			BuildObject("ivscout", 14, "fodder5")
		end

		local cons = Mission.cons
		cons = GetHandle("GreenSquadCons")
		SetObjectiveOn(cons)
		Goto(cons, "comnav")
	end
	
	--(GetDistance(Mission.HumanRecycler,"nav1") < 100.0))
	--if (Mission.TurnCounter == SecondsToTurns(1320)) then --1320 secs
	if (GetDistance(Mission.cons, "comnav") == 10.0) then
		local cons = Mission.cons
		cons = GetHandle("GreenSquadCons")
		if (cons ~= nil) then
			Build(cons, "ibgtoww2", 1)
		end
	end

	--if (Mission.TurnCounter == SecondsToTurns(1380)) then --- 1380 secs
	if (GetDistance(Mission.cons, "comnav") <= 5.0) then
		local cons = Mission.cons
		cons = GetHandle("GreenSquadCons")

		if (Mission.testBool == false) then
			AudioMessage("FS_finalstand_harper_3a.wav")
			print("Player is in phase 3 on Final Stand Mission")
			Mission.testBool = true
		end

		if (cons ~= nil) then
			Dropoff(cons, "comnav")
			ClearObjectives()
			SetObjectiveOff(Mission.navpoint)
			SetObjectiveOff(Mission.commTower)
			AddObjective(Mission._Text3, "green", 15.0)
			SetObjectiveOff(cons)
			Mission.ObjectiveTwo = true -- Stops attacking humans
		end
	end
end

function failConditions()
    if ((Mission.TurnCounter > SecondsToTurns(100)) and (Mission.TurnCounter <= SecondsToTurns(1000))) then -- 1000
        Mission.cons = GetHandle("GreenSquadCons")		
		ai.checkMissionObjectStatus(ai, Mission.cons, "Constructor is Died", "failmessage.wav", Mission._Text6, "cons.des", 15.0);
    end
	
    if ((Mission.TurnCounter > SecondsToTurns(5)) and (Mission.TurnCounter <= SecondsToTurns(900))) then -- 900
		ai.checkMissionObjectStatus(ai, Mission.commTower, "HQ is Dead", "failmessage.wav", Mission._Text7, "hq.des", 15.0);
    end

    if (Mission.TurnCounter > SecondsToTurns(5)) then -- Destroyed Enemy Recycler
        ai.checkMissionObjectStatus(ai, Mission.EnemyRecycler, "The player destroyed enemy recycler", "failmessage.wav", Mission._Text8, "", 5.0);
    end
end

function SurvivalLogic()
	if (Mission.ObjectiveTwo == false) then -- 2 minutes
		ai.spawnObjectsAtRepeatTimeWithOrder(Mission.TurnCounter, 120, 1, unitList, 1, 6);
    end

    if (Mission.ObjectiveTwo == false) and (math.fmod(Mission.TurnCounter, SecondsToTurns(300)) == 0) then --- 5 minutes
		ai.spawnObjectsAtRepeatTimeWithOrder(Mission.TurnCounter, 300, 1, unitList, 7, 8);
    end
    --[[ --With stock units given, it makes it difficult to combat the scion gunship
   if (Mission.ObjectiveTwo == false) and (math.fmod(Mission.TurnCounter, SecondsToTurns(300)) == 0) then --- 5 minutes

      local AttackUnits = 1 --attackrun4
      for i = 1, AttackUnits  do
         Goto(BuildObject("fvgship_gh",6, "gshipspawn"), "attackrun4");
         print("5 min marker");
      end
   end
   ]]--
end

function AddPlayer(id, Team, IsNewPlayer)
   if (IsNewPlayer) then
      local PlayerH = SetupPlayer(Team);
      SetAsUser(PlayerH, Team);
      AddPilotByHandle(PlayerH);

      DoTaunt(TAUNTS_NewHuman);
   end

   return true;
end

function DeletePlayer(id)
   DoTaunt(TAUNTS_LeftHuman);
end

function PlayerEjected(DeadObjectHandle)
   local deadObjectTeam = GetTeamNum(DeadObjectHandle);
   if (deadObjectTeam == 0) then
      return DLLHandled;
   end

   if (IsPlayer(DeadObjectHandle)) then
      AddScore(DeadObjectHandle, -GetActualScrapCost(DeadObjectHandle));
   end

   return DoEjectPilot;
end

function ObjectKilled(DeadObjectHandle, KillersHandle)
   local isDeadAI = not IsPlayer(DeadObjectHandle);
   local isDeadPerson = IsPerson(DeadObjectHandle);

   if (GetCurWorld() ~= 0) then
      return DoEjectPilot;
   end

   local deadObjectTeam = GetTeamNum(DeadObjectHandle);
   if (deadObjectTeam == 0) then
      return DoEjectPilot;
   end

   return DeadObject(DeadObjectHandle, KillersHandle, isDeadPerson, isDeadAI);
end

function ObjectSniped(DeadObjectHandle, KillersHandle)
   local isDeadAI = not IsPlayer(DeadObjectHandle);

   if (GetCurWorld() ~= 0) then
      return DLLHandled;
   end

   return DeadObject(DeadObjectHandle, KillersHandle, true, isDeadAI);
end

function PreSnipe(curWorld, shooterHandle, victimHandle, ordnanceTeam, pOrdnanceODF)
   if (not Mission.IsFriendlyFireOn) then
      local relationship = GetTeamRelationship(shooterHandle, victimHandle);

      if (relationship == TEAMRELATIONSHIP_ALLIEDTEAM) then
         if (IsPlayer(victimHandle) or (GetTeamNum(victimHandle) ~= 0)) then
            return PRESNIPE_ONLYBULLETHIT;
         end
      end

      SetPerceivedTeam(victimHandle, 0);
   end

   return PRESNIPE_KILLPILOT;
end

function PreGetIn(curWorld, pilotHandle, emptyCraftHandle)
   local relationship = GetTeamRelationship(pilotHandle, emptyCraftHandle);

   if ((relationship == TEAMRELATIONSHIP_ALLIEDTEAM) and (not IsPlayer(pilotHandle))) then
      SetTeamNum(pilotHandle, GetTeamNum(emptyCraftHandle));
   end

   return PREGETIN_ALLOW;
end

function GetInitialPlayerPilotODF(Race)
   local TempODFName = nil;

   if (Mission.RespawnWithSniper) then
      TempODFName = Race .. "spilo";
   else
      TempODFName = Race .. "suser_m";
   end

   return TempODFName;
end

function GetInitialRecyclerODF(Race)
   local TempODFName = nil;

   local pContents = GetCheckedNetworkSvar(5, NETLIST_Recyclers);

   if ((pContents ~= nil) and (pContents ~= "")) then
      TempODFName = Race .. string.sub(pContents, 2);
   else
      TempODFName = Race .. "vrecy_m";
   end

   return TempODFName;
end

function SetupTeam(Team)
   if ((Team < 1) or (Team >= MAX_TEAMS)) then
      return;
   end

   if (Mission.TeamIsSetUp[Team]) then
      return;
   end

   local TeamRace = GetRaceOfTeam(Team);

   if (IsTeamplayOn()) then
      SetMPTeamRace(WhichTeamGroup(Team), TeamRace);
   end

   local spawnpointPosition = GetRandomSpawnpoint(Team);

   Mission.TeamPos[Team] = spawnpointPosition;

   if (GetObjectByTeamSlot(Team, DLL_TEAM_SLOT_RECYCLER) == nil) then
      spawnpointPosition = GetPositionNear(spawnpointPosition, VEHICLE_SPACING_DISTANCE, 2 * VEHICLE_SPACING_DISTANCE);
      --local VehicleH = BuildObject(GetInitialRecyclerODF(TeamRace), Team, spawnpointPosition);
	  local VehicleH = BuildObject("ivrecy_m", Team, spawnpointPosition);
      SetRandomHeadingAngle(VehicleH);
      Mission.RecyclerHandles[Team] = VehicleH;
      SetGroup(VehicleH, 0);
   end

   spawnpointPosition = Mission.TeamPos[Team];

   Mission.CreatingStartingVehicles = true;
   _StartingVehicles.CreateVehicles(Team, TeamRace, Mission.StartingVehiclesMask, spawnpointPosition);
   Mission.CreatingStartingVehicles = false;

   SetScrap(Team, 40);

   if (IsTeamplayOn()) then
      for i = GetFirstAlliedTeam(Team), GetLastAlliedTeam(Team) do
         if (i ~= Team) then
            local pos = GetPositionNear(spawnpointPosition, AllyMinRadiusAway, AllyMaxRadiusAway);

            Mission.TeamPos[i] = pos;
         end
      end
   end

   Mission.TeamIsSetUp[Team] = true;
end

function SetupPlayer(Team)
   local PlayerH = nil;
   local spawnpointPosition = SetVector(0,0,0);

   if ((Team < 0) or (Team >= MAX_TEAMS)) then
      return nil;
   end

   Mission.SpawnedAtTime[Team] = Mission.ElapsedGameTime;

   local TeamBlock = WhichTeamGroup(Team);

   if ((not IsTeamplayOn()) or (TeamBlock < 0)) then
      SetupTeam(Team);

      spawnpointPosition = Mission.TeamPos[Team];
      spawnpointPosition.y = TerrainFindFloor(spawnpointPosition.x, spawnpointPosition.z) + 2.5;
   else
      SetupTeam(GetCommanderTeam(Team));

      spawnpointPosition = Mission.TeamPos[Team];
      spawnpointPosition.y = TerrainFindFloor(spawnpointPosition.x, spawnpointPosition.z) + 2.5;
   end

   --PlayerEntryH = BuildObject(GetPlayerODF(Team), Team, spawnpointPosition);
   PlayerEntryH = BuildObject("ivtank", Team, spawnpointPosition);

   local TempODFName = nil;
   TempODFName = GetRaceOfTeam(Team) .. "spilo";
   --SetPilotClass(PlayerEntryH, TempODFName);
   SetPilotClass(PlayerEntryH, "ispilo");
   SetRandomHeadingAngle(PlayerEntryH);

   if (Team == 0) then
      MakeInert(PlayerH);
   end

   return PlayerEntryH;
end

function UpdateGameTime()
   Mission.ElapsedGameTime = Mission.ElapsedGameTime + 1;

   if (Mission.RemainingGameTime > 0) then
      Mission.RemainingGameTime = Mission.RemainingGameTime + 1;

      if ((Mission.RemainingGameTime % Mission.GameTPS) == 0) then
         local Seconds = Mission.RemainingGameTime / GameTPS;
         local Minutes = Seconds / 60;
         local Hours = Minutes / 60;

         Seconds = Seconds % 60;
         Minutes = Minutes % 60;

         if (Hours ~= 0) then
            TempMsgString = TranslateString("mission", ("Time Left %d:%02d:%02d\n"):format(Hours, Minutes, Seconds));
         else
            TempMsgString = TranslateString("mission", ("Time Left %d:%02d\n"):format(Minutes, Seconds));
         end

         SetTimerBox(TempMsgString);

         if (Hours == 0) then
            if ((Seconds == 0) and ((Minutes <= 10) or ((Minutes % 5) == 0 ))) then
               AddToMessagesBox(TempMsgString);
            else
               if ((Minutes == 0) and ((Seconds % 5) == 0)) then
                  AddToMessagesBox(TempMsgString);
               end
            end
         end
      end

      if (Mission.RemainingGameTime == 0) then
         NoteGameoverByTimelimit();
         DoGameover(10.0);
      end
   else
      if ((Mission.ElapsedGameTime % GameTPS) == 0) then
         local Seconds = Mission.ElapsedGameTime / GameTPS;
         local Minutes = Seconds / 60;
         local Hours = Minutes / 60;

         Seconds = Seconds % 60;
         Minutes = Minutes % 60;

         if (Hours ~= 0) then
            TempMsgString = TranslateString("mission", ("Mission Time %d:%02d:%02d\n"):format(Hours, Minutes, Seconds));
         else
            TempMsgString = TranslateString("mission", ("Mission Time %d:%02d\n"):format(Minutes, Seconds));
         end

         SetTimerBox(TempMsgString);
      end
   end
end

function ExecuteCheckIfGameOver()
   if ((Mission.GameOver) or (Mission.ElapsedGameTime < GameTPS)) then
      return;
   end

   local NumFunctioningTeams = 0;
   local TeamIsFunctioning = {};

   for i = 1, MAX_TEAMS - 1 do
      if (Mission.TeamIsSetUp[i]) then
         local functioning = false;
            local TempH = Mission.RecyclerHandles[i];

            if (not IsAround(TempH)) then
               TempH = GetObjectByTeamSlot(i, DLL_TEAM_SLOT_RECYCLER);
            end

            if ((TempH == nil) or (not IsAlive(TempH))) then
               Mission.RecyclerHandles[i] = nil;
            else
               functioning = true;
               end

               local RecyH = nil;

               if (IsAround(TempH)) then
                  RecyH = TempH;
               else
                  RecyH = GetObjectByTeamSlot(i, DLL_TEAM_SLOT_RECYCLER);
               end

               if (not IsAround(RecyH)) then
                  RecyH = GetObjectByTeamSlot(i, DLL_TEAM_SLOT_FACTORY);
               end

               if (RecyH ~= nil) then
                  functioning = true;
                  end

                  TeamIsFunctioning[i] = functioning;

                  if ((not Mission.NotedRecyclerLocation[i]) or (not bit32.band(Mission.ElapsedGameTime, 0xFF))) then
                     if (RecyH ~= nil) then
                        Mission.NotedRecyclerLocation[i] = true;

                        local RecyPos = GetPosition(RecyH);
                        Mission.TeamPos[i] = RecyPos;

                        if (IsTeamplayOn()) then
                           for jj = GetFirstAlliedTeam(i), GetLastAlliedTeam(i) do
                              Mission.TeamPos[jj] = RecyPos;
                           end
                        end
                     end
                  end
               end
            end

            for i = 1, MAX_TEAMS - 1 do
               if (IsTeamplayOn()) then
                  if (TeamIsFunctioning[i]) then
                     NumFunctioningTeams = NumFunctioningTeams + 1;
                  end
               end
            end

            if (NumFunctioningTeams > 1) then
               Mission.HadMultipleFunctioningTeams = true;
               return;
            end

            if ((NumFunctioningTeams == 0) and (Mission.ElapsedGameTime > (5 * GameTPS))) then
               NoteGameoverByNoBases();
               DoGameover(10.0);
               Mission.GameOver = true;
            else
               if ((Mission.HadMultipleFunctioningTeams) and (NumFunctioningTeams == 1)) then
                  if (IsTeamplayOn()) then
                     local WinningTeamgroup = -1;

                     for i = 1, MAX_TEAMS - 1 do
                        if (TeamIsFunctioning[i]) then
                           if (WinningTeamgroup == -1) then
                              if (i == Mission.StratTeam) then
                                 DoTaunt(TAUNTS_CPURecyDestroyed);
                              elseif (i == Mission.CPUTeamNum) then
                                 DoTaunt(TAUNTS_HumanRecyDestroyed);
                              end

                              WinningTeamgroup = WhichTeamGroup(i);
                              NoteGameoverByLastTeamWithBase(WinningTeamgroup);
                           end
                        end
                     end

                     for i = 1, MAX_TEAMS -1 do
                        if (WhichTeamGroup(i) == WinningTeamgroup) then
                           AddScore(GetPlayerHandle(i), 100);
                        end
                     end
                  else
                     NoteGameoverByLastTeamWithBase(GetPlayerHandle(1));

                     for i = 1, MAX_TEAMS - 1 do
                        if (TeamIsFunctioning[i]) then
                           NoteGameoverByLastTeamWithBase(GetPlayerHandle(i));
                           AddScore(GetPlayerHandle(i), 100);
                        end
                     end
                  end

                  DoGameover(10.0);
                  Mission.GameOver = true;
               end
            end
         end

         function RespawnPilot(DeadObjectHandle, Team)
            local spawnpointPosition = SetVector(0,0,0);

            if ((Team < 1) and (Team >= MAX_TEAMS)) then
               spawnpointPosition = GetSafestspawnpoint();
            else
               spawnpointPosition = Mission.TeamPos[Team];
               Mission.SpawnedAtTime[Team] = Mission.ElapsedGameTime;
            end

            local OldPos = GetPosition2(DeadObjectHandle);

            local respawnHeight = 200.0;

            if ((math.abs(OldPos.x) > 0.01) and (math.abs(OldPos.z) > 0.01)) then
               local dx = OldPos.x - spawnpointPosition.x;
               local dz = OldPos.z - spawnpointPosition.z;
               local distanceAway = math.sqrt((dx * dx) + (dz * dz));

               if (distanceAway < 100.0) then
                  respawnHeight = 35.0;
               else
                  local numAllies = CountAlliedPlayers(Team);
                  respawnHeight = 30.0 + (math.sqrt(distanceAway) * 1.25);

                  local minRespawnHeight = 40.0;
                  local maxRespawnHeight = 72.0 + (15.0 * numAllies);

                  if (respawnHeight < minRespawnHeight) then
                     respawnHeight = minRespawnHeight;
                  elseif (respawnHeight > maxRespawnHeight) then
                     respawnHeight = maxRespawnHeight;
                  end
               end
            end

            if (Mission.RespawnAtLowAltitude) then
               respawnHeight = 2.0;
            end

            spawnpointPosition.x = spawnpointPosition.x + (GetRandomFloat(1.0) - 0.5) * (2.0 * 32.0);
            spawnpointPosition.z = spawnpointPosition.z + (GetRandomFloat(1.0) - 0.5) * (2.0 * 32.0);

            local curFloor = TerrainFindFloor(spawnpointPosition.x, spawnpointPosition.z) + 2.5;
            if (spawnpointPosition.y < curFloor) then
               spawnpointPosition.y = curFloor;
            end

            spawnpointPosition.y = spawnpointPosition.y + respawnHeight;
            spawnpointPosition.y = spawnpointPosition.y + GetRandomFloat(1.0);

            --local NewPerson = BuildObject(GetInitialPlayerPilotODF(GetRaceOfTeam(Team)), Team, spawnpointPosition);
			local NewPerson = BuildObject("ispilo", Team, spawnpointPosition);
            SetAsUser(NewPerson, Team);
            AddPilotByHandle(NewPerson);
            SetRandomHeadingAngle(NewPerson);

            if (Team == 0) then
               MakeInert(NewPerson);
            end

            return DLLHandled;
         end

         function DeadObject(DeadObjectHandle, KillersHandle, isDeadPerson, isDeadAI)
            local deadObjectTeam = GetTeamNum(DeadObjectHandle);

            local deadObjectIsPlayer = IsPlayer(DeadObjectHandle);
            local killerObjectIsPlayer = IsPlayer(KillersHandle);

            local relationship = GetTeamRelationship(DeadObjectHandle, KillersHandle);

            local deadObjectScrapCost = GetActualScrapCost(DeadObjectHandle);

            if (deadObjectTeam ~= 0) then
               if (deadObjectIsPlayer) then
                  AddScore(DeadObjectHandle, -deadObjectScrapCost);

                  if (isDeadPerson) then
                     AddDeaths(DeadObjectHandle, 1);
                  end
               else
                  if (Mission.KillForAIKill) then
                     AddDeaths(DeadObjectHandle, 1);
                  end

                  if (Mission.PointsForAIKill) then
                     AddScore(DeadObjectHandle, -deadObjectScrapCost);
                  end
               end

               if (killerObjectIsPlayer) then
                  if ((relationship == TEAMRELATIONSHIP_SAMETEAM) or (relationship == TEAMRELATIONSHIP_ALLIEDTEAM)) then
                     AddKills(KillersHandle, -1);
                     AddScore(KillersHandle, -deadObjectScrapCost);
                  else
                     AddKills(KillersHandle, 1);
                     AddScore(KillersHandle, deadObjectScrapCost);
                  end
               else
                  if ((relationship == TEAMRELATIONSHIP_SAMETEAM) or (relationship == TEAMRELATIONSHIP_ALLIEDTEAM)) then
                     if (Mission.KillForAIKill) then
                        AddKills(KillersHandle, -1);
                     end

                     if (Mission.PointsForAIKill) then
                        AddScore(KillersHandle, -deadObjectScrapCost);
                     end
                  else
                     if (Mission.KillForAIKill) then
                        AddKills(KillersHandle, 1);
                     end

                     if (Mission.PointsForAIKill) then
                        AddScore(KillersHandle, deadObjectScrapCost);
                     end
                  end
               end

               local spawnKillTime = 15 * GameTPS
               local isSpawnKill = (DeadObjectHandle ~= KillersHandle) and
               (not isDeadAI) and
               (deadObjectTeam > 0) and (deadObjectTeam < MAX_TEAMS) and
               (Mission.SpawnedAtTime[deadObjectTeam] > 0 and (Mission.SpawnedAtTime[deadObjectTeam] > 0)) and
               ((Mission.ElapsedGameTime - Mission.SpawnedAtTime[deadObjectTeam]) < spawnKillTime);


               if (isSpawnKill) then
                  TempMsgString = TranslateString("mission", "Spawn kill by %s on %s\n"):format(GetPlayerName(KillersHandle), GetPlayerName(DeadObjectHandle));
                  AddToMessagesBox(TempMsgString);
                  AddScore(KillersHandle, -500);
               end

               if ((Mission.KillLimit) > 0) and (GetKills(KillersHandle) >= Mission.KillLimit) then
                  NoteGameoverByKillLimit(KillersHandle);
                  DoGameover(10.0);
               end
            else
               return DoEjectPilot;
            end

            if (isDeadAI) then
               if (isDeadPerson) then
                  return DLLHandled;
               else
                  return DoEjectPilot;
               end
            else
               if (isDeadPerson) then
                  return RespawnPilot(DeadObjectHandle, deadObjectTeam);
               else
                  return DoEjectPilot;
               end
            end
         end

         function AddCPUScav(scavHandle)
            if (Mission.NumCPUScavs < MAX_CPU_SCAVS) then
               Mission.CPUScavList[Mission.NumCPUScavs + Mission.NumCPUScavs + 1] = scavHandle;
            end

            if (Mission.NumCPUScavs < MAX_CPU_SCAVS) then
               return;
            end

            DoTaunt(TAUNTS_Random);

            local newScavList = {};
            local newScavListCount = 0;

            for i = 1, Mission.NumCPUScavs do
               local keepIt = false;

               local checkScav = Mission.CPUScavList[i];

               if (IsAround(checkScav) and (GetTeaNum(checkScav) == Mission.CPUTeamNum)) then
                  local ObjClass = GetClassLabel(checkScav);
                  keepIt = (ObjClass == "CLASS_SCAVENGER") or (ObjClass == "CLASS_SCAVENGERH");
               end

               keepIt = (checkScav == scavHandle);

               if (keepIt) then
                  newScavList[newScavListCount + newScavListCount + 1] = checkScav;
               end
            end

            Mission.NumCPUScavs = newScavListCount;

            while (Mission.NumCPUScavs > MIN_CPU_SCAVS_AFTER_CLEANUP) do
               local i = Mission.NumCPUScavs - 1;

               while ((i > 0) and (Mission.CPUScavList[i] == scavHandle)) do
                  i = i - 1;
               end

               if (Mission.CPUScavList[i] == scavHandle) then
                  break;
               end

               SetNoScrapFlagByHandle(Mission.CPUScavList[i]);
               SelfDamage(Mission.CPUScavList[i], 9999);

               Mission.NumCPUScavs = Mission.NumCPUScavs - 1;
               Mission.CPUScavList[Mission.NumCPUScavs] = nil;
            end
         end

         function DoGenericStrategy(TeamIsSetUp, RecyclerHandles)
            Mission.TimeCount = Mission.TimeCount + 1;

            if ((not Mission.StartDone) and Mission.HumanTeamRace) then

               Mission.StartDone = true;

               -- TODO: Add Extra Vehicles
               SetupExtraVehicles();

               Mission.CPURecycler = GetObjectByTeamSlot(Mission.CPUTeamNum, DLL_TEAM_SLOT_RECYCLER)
               if (not IsAround(Mission.CPURecycler)) then
                  local startRecyODF = nil;
                  local pContents = GetCheckedNetworkSvar(12, NETLIST_Recyclers);

                  if ((pContents ~= nil) and (pContents ~= "")) then
                     startRecyODF = pContents;
                  else
                     startRecyODF = Mission.CPUTeamRace .. "vrecycpu"; --No RecyclerEnemy
                  end

                  Mission.CPURecycler = BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, startRecyODF, "vrecy", "RecyclerEnemy");
               end

               Mission.RecyclerHandles[Mission.CPUTeamNum] = Mission.CPURecycler;
               Mission.TeamIsSetUp[Mission.CPUTeamNum] = true;

               BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "vturr", "vturr", "turretEnemy1");
               BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "vturr", "vturr", "turretEnemy2");

               if (Mission.CPUForce > 0) then
                  BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "bspir", "vturr", "gtow2");
                  BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "bspir", "vturr", "gtow3");
                  BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "vsent", "vscout", "SentryEnemy1");
                  BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "vsent", "vscout", "SentryEnemy2");
               end

               if (Mission.CPUForce > 1) then
                  BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "bspir", "vturr", "gtow4");
                  BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "bspir", "vturr", "gtow5");
                  BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "vtank", "vtank", "tankEnemy1");
                  BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "vtank", "vtank", "tankEnemy2");
                  BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "vtank", "vtank", "tankEnemy3");
                  BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "vsent", "vscout", "SentryEnemy3");
               end

               BuildStartingVehicle(Mission.CPUTeamNum, Mission.CPUTeamRace, "vscav", "vscav", "ScavengerEnemy");

               if (not Mission.PastAIP0) then
                  SetCPUAIPlan(AIPType0);
               end

               SetScrap(Mission.CPUTeamNum, 40);
               SetScrap(Mission.StratTeam, 40);
            end

            -- This could be enhanced to add some dropship code that'll drop units for the CPU Team via a dropship. - AI_Unit
            if ((Mission.TimeCount % Mission.CPUReinforcementTime) == 0) then
               if (Mission.CPUForce > 1) then
                  AddScrap(Mission.CPUTeamNum, 10);
               end
            end

            -- Count the Human Players every 10 seconds.
            if ((Mission.TimeCount % (10 * GameTPS)) == 0) then
               Mission.NumHumans = CountPlayers();
            end

            -- Avoid divide by zero if we set compforce to 3.
            local CompForceSkew = Mission.CPUForce * GameTPS;

            if (CompForceSkew >= (3 * GameTPS)) then
               CompForceSkew = (3 * GameTPS) - 2;
            end

            if ((Mission.TimeCount % ((3 * GameTPS) - CompForceSkew)) == 0) then
               AddScrap(Mission.CPUTeamNum, 1);
            end

            if (Mission.TimeCount % (GameTPS - Mission.NumHumans + 1) == 0) then
               AddScrap(Mission.CPUTeamNum, 1);
            end

            if ((Mission.HumanForce > 0) and (Mission.TimeCount % ((10 * GameTPS) - (Mission.HumanForce * 20)) == 0)) then
               AddScrap(Mission.StratTeam, 1);
            end

            if (Mission.TimeCount % Mission.HumanReinforcementTime == 0) then
               BuildObject("apammo", 0, "ammo1");
               BuildObject("apammo", 0, "ammo2");
               BuildObject("apammo", 0, "ammo3");
               BuildObject("aprepa", 0, "repair1");
               BuildObject("aprepa", 0, "repair2");
               BuildObject("aprepa", 0, "repair3");
            end

            local closestEnemy = 0;
            local closestEnemyDist = 10,00000000; -- Originally 1e30f, changed. AI_Unit

            local RecyH = GetObjectByTeamSlot(Mission.CPUTeamNum, DLL_TEAM_SLOT_RECYCLER);
            if (IsAround(RecyH)) then
               closestEnemy = GetNearestEnemy(RecyH, true, true, SIEGE_DISTANCE);
            end

            if (closestEnemy ~= 0) then
               closestEnemyDist = GetDistance(closestEnemy, RecyH);
            else
               closestEnemy = 0;
               local FactoryH = GetObjectByTeamSlot(Mission.CPUTeamNum, DLL_TEAM_SLOT_FACTORY);

               if (IsAround(FactoryH)) then
                  closestEnemy = GetNearestEnemy(FactoryH, true, true, SIEGE_DISTANCE);
               end

               if (closestEnemy ~= 0) then
                  closestEnemyDist = GetDistance(closestEnemy, FactoryH);
               end
            end

            if (not Mission.SiegeOn) then
               if (closestEnemy) then
                  Mission.SiegeCounter = Mission.SiegeCounter + 1;
               else
                  Mission.SiegeCounter = 0;
               end

               local SiegeTime = 45 * GameTPS;
               if (Mission.SiegeCounter > SiegeTime) then
                  Mission.SiegeOn = true;
                  SetCPUAIPlan(AIPTypeS);
               end
            else
               if (closestEnemy == 0) then
                  SetCPUAIPlan(AIPTypeL);

                  if (Mission.LastCPUPlan == AIPTypeL) then
                     Mission.SiegeOn = false;
                     Mission.SiegeCounter = 0;
                  end
               end
            end

            if ((not Mission.LateGame) and (not Mission.SiegeOn) and (not Mission.AntiAssault) and (Mission.AssaultCounter > 2)) then
               Mission.AntiAssault = true;
               SetCPUAIPlan(AIPTypeA);
            else
               if ((Mission.AntiAssault) and (Mission.AssaultCounter < 3)) then
                  Mission.AntiAssault = false;
                  SetCPUAIPlan(AIPTypeL);
               end
            end
         end

         function BuildStartingVehicle(Team, Race, ODF1, ODF2, Where, Group)
            if (Group == nil) then
               Group = 0;
            end

            local TempODF = Race .. ODF1;
            if (not DoesODFExist(TempODF)) then
               TempODF = Race .. ODF2;
            end

            local h = BuildObject(TempODF, Team, Where);

            if ((IsAround(h)) and (Group >= 0)) then
               SetGroup(h, Group);
            end

            return h;
         end

         --[[ Added an AIP helper function to accept all aip types - Ken Miller and Ethan Herndon 9/29/19 ]]--

         function SelectCPUAIPlan(Type)
            local typeExtension = string.sub(AIPTypeExtensions, Type + 1, Type + 1);
            local AIPFile
            local difficultyTable = { [0] = "stock_", [1] = "easy", [2] = "standard", [3] = "difficult", [4] = "extreme", [5] = "insane" }
            local difficultyVar = GetVarItemInt("network.session.ivar120")
            local difficultyPrefix = difficultyTable[difficultyVar]
            local customName = nil;

            -- if there's a custom name base, check that first
            if Mission.CustomAIPNameBase then
               -- try custom + specific
               AIPFile = Mission.CustomAIPNameBase .. Mission.CPUTeamRace .. Mission.HumanTeamRace .. typeExtension .. ".aip"
               if DoesFileExist(AIPFile) then
                  print("selected custom specific aip: " .. AIPFile);
                  return AIPFile;
               else
                  print("no custom specific aip: " .. AIPFile);
               end

               -- try custom + general
               AIPFile = Mission.CustomAIPNameBase .. Mission.CPUTeamRace .. "_" .. typeExtension .. ".aip"
               if DoesFileExist(AIPFile) then
                  print("selected custom general aip: " .. AIPFile);
                  return AIPFile
               else
                  print("no custom general aip: " .. AIPFile);
               end
            end


            if difficultyPrefix ~= nil then
               -- try specific
               AIPFile = difficultyPrefix .. Mission.CPUTeamRace .. Mission.HumanTeamRace .. typeExtension .. ".aip";
               if DoesFileExist(AIPFile) then
                  print("selected " .. difficultyPrefix .. " specific aip: " .. AIPFile);
                  return AIPFile
               else
                  print("no " .. difficultyPrefix .. " specific aip: " .. AIPFile);
               end

               -- try general
               AIPFile = difficultyPrefix .. Mission.CPUTeamRace .. "_" .. typeExtension .. ".aip"
               if DoesFileExist(AIPFile) then
                  print("selected " .. difficultyPrefix .. " general aip: " .. AIPFile);
                  return AIPFile
               else
                  print("no " .. difficultyPrefix .. " general aip: " .. AIPFile);
               end
            end


            if GetVarItemStr("network.session.svar121") then
               customName = GetVarItemStr("network.session.svar121");

               -- try custom + specific
               AIPFile =  customName .. Mission.CPUTeamRace .. Mission.HumanTeamRace .. typeExtension .. ".aip";
               if DoesFileExist(AIPFile) then
                  print("selected custom specific aip: " .. AIPFile);
                  return AIPFile
               else
                  print("no custom specific aip: " .. AIPFile);
               end

               -- try custom + general
               AIPFile =  customName .. Mission.CPUTeamRace .. "_" .. typeExtension .. ".aip"
               if DoesFileExist(AIPFile) then
                  print("selected custom general aip: " .. AIPFile);
                  return AIPFile
               else
                  print("no custom general aip: " .. AIPFile);
               end

            end

         end

         function SetCPUAIPlan(Type)
            if (not CheckedSVar3) then
               CheckedSVar3 = true;
               local pContents = GetCheckedNetworkSvar(3, NETLIST_AIPs);

               if ((pContents == nil) or (pContents == "")) then
                  Mission.CustomAIPNameBase = nil;
               else
                  Mission.CustomAIPNameBase = pContents;
               end
            end

            if ((Type < 0) or (Type >= MAX_AIP_TYPE)) then
               Type = AIPType3;
            end

            if (((Type > AIPType3) and (Mission.CPUCommBunkerCount == 0)) and (Mission.LastCPUPlan <= AIPType3)) then
               return;
            end

            local AIPFile = SelectCPUAIPlan(Type); --Initialization of AIP helper function
            if AIPFile then
               SetAIP(AIPFile, Mission.CPUTeamNum);
            end

            Mission.LastCPUPlan = Type;

            if (not Mission.setFirstAIP) then
               DoTaunt(TAUNTS_Random);
               Mission.setFirstAIP = true;
            end
         end

         function SetupExtraVehicles()
            local pathNames = GetAiPaths();
            local pathCount = #pathNames;

            local CPUTeamRace = Mission.CPUTeamRace;
            local HumanTeamRace = Mission.HumanTeamRace;
            local length;

            Mission.NumCPUScavs = 0;

            for i = 1, pathCount do
               local Label = pathNames[i];

               if (string.sub(Label, 1, 3) == "mpi") then
                  local MaxODFLength = 64;
                  local ODF1;
                  local ODF2;

                  local Underscore = string.find(Label, "_");

                  if (Underscore == nil) then
                     return;
                  end

                  local Underscore2 = string.find(Underscore+1, "_");

                  if (Underscore2 == nil) then
                     ODF1 = Underscore + 1;
                  else
                     length = (Underscore2 - Underscore) - 1;

                     if (length > (string.len(ODF2) -1)) then
                        length = (string.len(ODF2) - 1);
                     end

                     ODF1 = Underscore + 1;
                     ODF2 = Underscore2 + 1;
                  end

                  length = string.len(ODF1);
                  if ((length > 0) and (ODF1[length - 1] == '_')) then
                     ODF1[length -1] = '\0';
                  end

                  length = string.len(ODF2);
                  if ((length > 0) and (ODF2[length -1] == '_')) then
                     ODF2[length -1] = '\0';
                  end

                  if (string.sub(Label, 1, 4) == "mpic") then
                     if (string.sub(ODF1, 1, 1) == CPUTeamRace) then
                        BuildObject(ODF1, Mission.CPUTeamNum, Label);
                     elseif (string.sub(ODF2, 1, 1) == CPUTeamRace) then
                        BuildObject(ODF2, Mission.CPUTeamNum, Label);
                     end
                  elseif (string.sub(Label, 1, 4) == "mpiC") then
                     if (string.sub(ODF1, 1, 1) ~= nil) then
                        string.gsub(ODF1, string.sub(ODF1, 1, 1), CPUTeamRace);
                        BuildObject(ODF1, Mission.CPUTeamNum, Label);
                     elseif (string.sub(ODF2, 1, 1) ~= nil) then
                        string.gsub(ODF2, string.sub(ODF2, 1, 1), CPUTeamRace);
                        BuildObject(ODF2, Mission.CPUTeamNum, Label);
                     end
                  elseif (string.sub(Label, 1, 4) == "mpih") then
                     local h;

                     if (string.sub(ODF1, 1, 1) == HumanTeamRace) then
                        h = BuildObject(ODF1, Mission.StratTeam, Label);
                        SetBestGroup(h);
                     elseif (string.sub(ODF2, 1, 1) == HumanTeamRace) then
                        h = BuildObject(ODF2, Mission.StratTeam, Label);
                        SetBestGroup(h);
                     end
                  elseif (string.sub(Label, 1, 4) == "mpiH") then
                     if (string.sub(ODF1, 1, 1) ~= nil) then
                        string.gsub(ODF1, string.sub(ODF1, 1, 1), HumanTeamRace);
                        h = BuildObject(ODF1, Mission.CPUTeamNum, Label);
                        SetBestGroup(h);
                     elseif (string.sub(ODF2, 1, 1) ~= nil) then
                        string.gsub(ODF2, string.sub(ODF2, 1, 1), HumanTeamRace);
                        h = BuildObject(ODF2, Mission.CPUTeamNum, Label);
                        SetBestGroup(h);
                     end
                  end
               end
            end
         end

         function IsRecyclerODF(h)
            if (not IsAround(h)) then
               return 0;
            end

            local ObjClass = GetClassLabel(h);

            if (ObjClass == "CLASS_RECYCLERVEHICLE" or ObjClass == "CLASS_RECYCLER") then
               return string.sub(GetOdf(h), 1, 1);
            end

            return 0;
         end

         function GetCheckedNetworkSvar(svar, listType)
            local svarStr = string.format("network.session.svar%d", svar);
            local pContents = GetVarItemStr(svarStr);

            if (pContents == nil) then
               return nil;
            end

            local count = GetNetworkListCount(listType);

            for i = 1, count do
               local pItem = GetNetworkListItem(listType, i);

               if (pContents == pItem) then
                  return pContents;
               end
            end

            return nil;
         end

         function CountAlliedPlayers(team)
            local count = 0;

            for i = 1, MAX_TEAMS do
               if (IsTeamAllied(i, team)) then
                  local h = GetPlayerHandle(i);
                  if (IsAround(h)) then
                     count = count + 1;
                  end
               end
            end

            return count;
         end