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
]] --

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

local Mission = {
    --Integers--
    TPS = 0,
    MissionTimer = 0,
    TurnCounter = 0,
    --Mission Variables--
    _Text1 = "OBJECTIVE: Reinforce base positions. Advance against the scion position. Await further orders.",
    _Text2 = "OBJECTIVE: Escort Green Squads constructor to create a forward position.\nProvide additional patrols ahead.",
    _Text3 = "OBJECTIVE: Destroy that structure but do not destroy enemy recycler!",
    _Text4 = "Very good Major Collins.",
    _Text5 = "Go to the evacuation site!",
    _Text6 = "OBJECTIVE Failed: Consider the mission scrubbed.\n\nConstructor is dead.",
    _Text7 = "OBJECTIVE Failed: Consider the mission scrubbed.\n\nHQ is dead.",
    _Text8 = "You disobeyed a direct order. Consider the mission a failure.",
    SurvivalWaveTime30 = 0,
    SurvivalWaveTime33 = 0,
    i = 0,
    ObjectiveZero = false,
    ObjectiveOne = false,
    ObjectiveTwo = false,
    ObjectiveThree = false,
    ObjectiveFour = false,
    notAroundBool = false,
    testBool = false,
    setRumble = false,
    setExplosion = false,
    
	-- ISDF
    PlayerH = GetPlayerHandle(),
    HumanRecycler = GetHandle("Recycler"),
    navpoint,
    comBunker,

    -- Red Squad
    covell,
    scout1,
    scout2,

    -- Green Squad
    mates,
    tank1,
    tank2,
    cons,
    cons2,

    -- Scions
    Warrior,
    Scout,
    Sentry,
    AlienStructure,
    EnemyRecycler = GetHandle("Matriarch"),

    -- Orange Squad
    katherlyn,
    commTower,
    dabombdotcom,
    oRecy
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
		"fvrecy"
	}

	for k, v in pairs(preloadODF) do
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

    print("Final stand mission by F9bomber")
    print("Special thanks to Biometalical for making the map")
    print("Special thanks to Ken Miller, Nathan Mates, and SirBramley for voice acting")

    Mission.HumanRecycler = BuildObject("ivrecy", 1, "rec")
   
    -- Orange Squad
	SetTeamColor(13, SetVector(230, 92, 0))

    -- Red Squad
	SetTeamColor(15, SetVector(171, 0, 0))

    -- Green Squad
	SetTeamColor(14, SetVector(0, 153, 0))
    SetTeamColor(12, SetVector(0, 153, 0))

    -- Blue Squad
	SetTeamColor(1, SetVector(77, 210, 255))

    Ally(1, 14)
    Ally(1, 15)
    Ally(1, 13)
    Ally(14, 15)
    Ally(13, 15)
    Ally(13, 14)
    Ally(1, 12)
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

function Update() --This function runs on every frame.
	Mission.TurnCounter = Mission.TurnCounter + 1

	SurvivalLogic() -- Ethan Herndon
	objectiveSetup() -- Ethan Herndon
	GreenSquadSetup() -- Ethan Herndon
	createForwardPosition() -- Ethan Herndon
	failConditions() -- Ethan Herndon
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

		SucceedMission(GetTime() + 29.5, "final.des")
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
