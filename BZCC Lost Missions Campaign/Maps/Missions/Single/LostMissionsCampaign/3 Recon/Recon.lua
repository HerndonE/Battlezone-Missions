--[[
__________                            
\______   \ ____   ____  ____   ____  
 |       _// __ \_/ ___\/  _ \ /    \ 
 |    |   \  ___/\  \__(  <_> )   |  \
 |____|_  /\___  >\___  >____/|___|  /
        \/     \/     \/           \/ 

Battlezone Lost Missions Campaign | Mission 4: Recon

Event Scripting: Ethan Herndon "F9bomber"
Map Design and SFX: SirBramley
Voice Acting: Ken Miller, Nathan Mates, and SirBramley

]]--


local Mission = {
   --Integers--
   TPS = 0,
   MissionTimer = 0,
   TurnCounter = 0,
   
   --Mission Variables--
   _Text1 = "OBJECTIVE: Escort the transport. It must survive!\n\nDo not deploy recycler.";
   _Text2 = "Scion presence confirmed. Protect that transport!";
   _Text3 = "Keep your eyes open, this area is getting hot.";
   _Text4 = "The Scions heavy presences confirms that this planet is where they are gathering morphing resources.";
   _Text5 = "Green Squad will cover your position. Ensure the transport makes it back to landing zone.";
   _Text6 = "Congratulations! Hang tight will Blue, Red, and Green Squad will come for base deployment";
   _Text7 = "You disobeyed a direct order. Consider the mission a failure.";
   _Text8 = "Mission Failed! Consider the objective scrubbed.\n\nTransport has died.";


   SurvivalWaveTime30 = 0;
   SurvivalWaveTime33 = 0;
   i = 0;

   ObjectiveZero = false;
   ObjectiveOne = false;
   ObjectiveTwo = false;
   ObjectiveThree = false;
   ObjectiveFour = false;
   ObjectiveFive = false;
   ObjectiveSix = false;
   ObjectiveSeven = false;
   ObjectiveEight = false;
   notAroundBool = false;

   --ISDF--
   PlayerH = GetPlayerHandle();
   rec ="ibrecy";
   HumanRecycler = GetHandle("Recycler");
   --------

   --Red Squad--
   transport;
   covell;
   turret;
   -------------

   --Green Squad--
   mates;
   gTank;
   gScout;
   gScout1;
   ---------------

   --Scions--
   Warrior;
   Scout;
   Sentry;
   AlienStructure;
   ---------------

   --Blue Squad--

   ---------------

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
end

function DeleteObject(h) --This function is called when an object is deleted in the game.
end

function InitialSetup()
Mission.TPS = EnableHighTPS()
AllowRandomTracks(true)
	local preloadODF = {
		"ivrecy",
	}

	for k,v in pairs(preloadODF) do
		PreloadODF(v)
	end
	
AddScrap(1, 40)
AddScrap(6, 40) 
end

function Start() --This function is called upon the first frame
SetAutoGroupUnits(false)

AddScrap(1, 40)
AddScrap(6, 40)
SetAIP("stock_fi1.aip", 6)

   print("Recon mission by F9bomber");
   print("Special thanks to SirBramley for making the map");
   print("Special thanks to Ken Miller, Nathan Mates, and SirBramley for voice acting");


   --------------------------------------------------------
   ------------Colors Done by Ethan Herndon-----1/10/21----
   --Coronavirus
   --------------------------------------------------------

   --[[Orange Squad]]--
   SetTeamColor(1, SetVector(230, 92, 0));

   --[[Red Squad]]--
   SetTeamColor(15, SetVector(171, 0, 0));

   --[[Green Squad]]--
   SetTeamColor(14, SetVector(0, 153, 0));

   --[[Gray Enemy Color]]--
   SetTeamColor(6, SetVector(128, 128, 128));

   --------------------------------------------------------
   Ally(1, 14)
   Ally(1, 15)
   Ally(14, 15)

   Mission.HumanRecycler=BuildObject("ivrecy",1,"rec");
   --print("recycler is " .. tostring(Mission.HumanRecycler));
   --print("my handle is " .. tostring(Mission.PlayerH));

   --[[Spawn Local Units]]--
   Mission.transport=BuildObject("ivstasM3",15,"tspawn");
   SetObjectiveName(Mission.transport, "Sonar Surveyor Vessel");
   Mission.covell=BuildObject("ivtank",15,"cspawn");
   SetObjectiveName(Mission.covell, "Cmdr. Covell");
   Mission.mates=BuildObject("ivtank",14,"mspawn");
   SetObjectiveName(Mission.mates, "Sgt. Mates");
   Mission.turret=BuildObject("ivturr",15,"t1spawn");
   Mission.turret=BuildObject("ivturr",15,"t2spawn");



end

function Update() --This function runs on every frame.
Mission.TurnCounter = Mission.TurnCounter + 1

 -- Call your custom method here
   SurvivalLogic(); -- Ethan Herndon
   objectiveSetup(); -- Ethan Herndon

end

function objectiveSetup()

   if((Mission.ObjectiveZero == false) and Mission.TurnCounter == SecondsToTurns(3))then --5 Seconds
      print("Player is in phase 1 on Recon Mission");
      --print("play audio 1");
	  AudioMessage("RC_001.wav");
      SetObjectiveOn(Mission.transport)
      AddObjective(Mission._Text1, "yellow", 15.0);
      Follow(Mission.covell,Mission.transport);
      Follow(Mission.mates,Mission.covell);
      Goto(Mission.transport, "troute");
      Mission.ObjectiveZero = true;
   end

   if((Mission.TurnCounter > SecondsToTurns(5)) )then
      if ((Mission.notAroundBool == false) and  not IsAlive(Mission.transport))then -- Transport
         ClearObjectives();
         print("Transport is Dead");
         AudioMessage("failmessage.wav");
         AddObjective(Mission._Text8, "red", 15.0);
         FailMission(GetTime() + 15.0, "transpo.des") -- Does not load this message
         Mission.notAroundBool = true;
      end

      if ((Mission.notAroundBool == false) and IsBuilding(Mission.HumanRecycler))then -- Deployed Recycler
         ClearObjectives();
         print("The player deployed the recycler");
         AudioMessage("failmessage.wav");
         AddObjective(Mission._Text7, "red", 15.0);
         FailMission(GetTime() + 15.0, "recycler.des")
         Mission.notAroundBool = true;
      end


   end


end

function SurvivalLogic()

   if((Mission.ObjectiveOne == false) and GetDistance(Mission.transport,"check1") < 80.0)then
      ClearObjectives();
      --print("play audio 2");
	  AudioMessage("RC_001_MajCollins.wav");
      print("Player is in phase 2 on Recon Mission");
      Mission.Warrior=BuildObject("fvtank",6,"attack1_0");
      Mission.Scout=BuildObject("fvscout",6,"attack1_1");
      Mission.Sentry=BuildObject("fvsent",6,"attack1_2");
      SetObjectiveOn(Mission.Warrior)
      SetObjectiveOn(Mission.Scout)
      SetObjectiveOn(Mission.Sentry)
      Attack(Mission.Warrior, Mission.transport,1);
      Attack(Mission.Scout, Mission.transport,1);
      Attack(Mission.Sentry, Mission.transport,1);
      AddObjective(Mission._Text2, "white", 15.0);
      Mission.ObjectiveOne = true;
   end

   if((Mission.ObjectiveTwo == false) and GetDistance(Mission.transport,"check2") < 100.0)then
      ClearObjectives();
      --print("play audio 3");
      print("Player is in phase 3 on Recon Mission");
	  Mission.Warrior=BuildObject("fvtank",6,"attack1_0");
      Mission.Scout=BuildObject("fvscout",6,"attack1_1");
      Mission.Sentry=BuildObject("fvsent",6,"attack1_2");
      SetObjectiveOn(Mission.Warrior)
      SetObjectiveOn(Mission.Scout)
      SetObjectiveOn(Mission.Sentry)
      Attack(Mission.Warrior, Mission.transport,1);
      Attack(Mission.Scout, Mission.transport,1);
      Attack(Mission.Sentry, Mission.transport,1);
      Mission.ObjectiveTwo = true;
   end

   if((Mission.ObjectiveThree == false) and GetDistance(Mission.transport,"check3") < 80.0)then
      ClearObjectives();
      --print("play audio 4");
	  AudioMessage("R_recon_harper_3.wav");
      print("Player is in phase 4 on Recon Mission");
      Mission.Warrior=BuildObject("fvtank",6,"attack2_0");
      Mission.Scout=BuildObject("fvscout",6,"attack2_1");
      Mission.Sentry=BuildObject("fvsent",6,"attack2_2");
      SetObjectiveOn(Mission.Warrior)
      SetObjectiveOn(Mission.Scout)
      SetObjectiveOn(Mission.Sentry)
      Attack(Mission.Warrior, Mission.transport,1);
      Attack(Mission.Scout, Mission.transport,1);
      Attack(Mission.Sentry, Mission.transport,1);
      AddObjective(Mission._Text3, "white", 15.0);
      Mission.ObjectiveThree = true;
   end


   if((Mission.ObjectiveFour == false) and GetDistance(Mission.transport,"check4") < 30.0)then
      ClearObjectives();
      --print("play audio 5");
      print("Player is in phase 5 on Recon Mission");
	  AudioMessage("R_recon_harper_4.wav");
	  Mission.Warrior=BuildObject("fvtank",6,"attack2_0");
      Mission.Scout=BuildObject("fvscout",6,"attack2_1");
      Mission.Sentry=BuildObject("fvsent",6,"attack2_2");
      Attack(Mission.Warrior, Mission.transport,1);
      Attack(Mission.Scout, Mission.transport,1);
      Attack(Mission.Sentry, Mission.transport,1);
      Mission.AlienStructure=BuildObject("ibtele",6,"alien");
      SetObjectiveName(Mission.AlienStructure, "Key Alien Structure");
      SetObjectiveOn(Mission.AlienStructure)
      AddObjective(Mission._Text4, "white", 15.0);
      Mission.ObjectiveFour = true;
   end


   if((Mission.ObjectiveFive == false) and GetDistance(Mission.transport,"check5") < 60.0)then
      ClearObjectives();
      --print("play audio 6");
	  AudioMessage("R_Line3.wav")
      print("Player is in phase 6 on Recon Mission");
      SetObjectiveOff(Mission.AlienStructure)
      Mission.gScout=BuildObject("ivscout",14,"gsspawn1");
      SetObjectiveName(Mission.gScout, "Lt. Bramley");
      Mission.gScout1=BuildObject("ivscout",14,"gsspawn2");
      SetObjectiveName(Mission.gScout1, "Cpt. Herndon");
      Mission.gTank=BuildObject("ivtank",14,"gtspawn");
      SetObjectiveName(Mission.gTank, "Cmdr. Durango");
      Goto(Mission.gScout, "ghold");
      Goto(Mission.gScout1, "ghold");
      Goto(Mission.gTank, "ghold");
      Mission.Warrior=BuildObject("fvtank",6,"attack3_0");
      Mission.Scout=BuildObject("fvscout",6,"attack3_1");
      Mission.Sentry=BuildObject("fvsent",6,"attack3_2");
      SetObjectiveOn(Mission.Warrior)
      SetObjectiveOn(Mission.Scout)
      SetObjectiveOn(Mission.Sentry)
      Attack(Mission.Warrior, Mission.transport,1);
      Attack(Mission.Scout, Mission.transport,1);
      Attack(Mission.Sentry, Mission.transport,1);
      AddObjective(Mission._Text5, "white", 15.0);
      Mission.ObjectiveFive = true;
   end


   if((Mission.ObjectiveSix == false) and GetDistance(Mission.transport,"check6") < 60.0)then
      ClearObjectives();
      print("Player is in phase 7 on Recon Mission");
      Mission.Warrior=BuildObject("fvtank",6,"attack4_0");
      Mission.Warrior=BuildObject("fvtank",6,"attack1_0");
      Mission.Scout=BuildObject("fvscout",6,"attack1_1");
      Mission.Sentry=BuildObject("fvsent",6,"attack1_2");
      Attack(Mission.Warrior, Mission.transport,1);
      Attack(Mission.Scout, Mission.transport,1);
      Attack(Mission.Sentry, Mission.transport,1);
      Attack(Mission.Warrior, Mission.transport,1);
      Mission.ObjectiveSix = true;
   end

   if((Mission.ObjectiveSeven == false) and GetDistance(Mission.transport,"check7") < 30.0)then
      ClearObjectives();
      print("Player is in phase 8 on Recon Mission");
      Mission.Warrior=BuildObject("fvtank",6,"attack1_0");
      Mission.Warrior=BuildObject("fvtank",6,"attack1_0");
      Mission.Scout=BuildObject("fvscout",6,"attack1_1");
	  Mission.Sentry=BuildObject("fvsent",6,"attack1_2");
      Attack(Mission.Warrior, Mission.transport,1);
      Attack(Mission.Scout, Mission.transport,1);
      Attack(Mission.Sentry, Mission.transport,1);
      Attack(Mission.Warrior, Mission.transport,1);
      Mission.ObjectiveSeven = true;
   end

   if((Mission.ObjectiveEight == false) and GetDistance(Mission.transport,"check8") < 30.0)then
      ClearObjectives();
      print("Player is in last phase on Recon Mission");
	  AudioMessage("R_recon_harper_6.wav");
      AddObjective(Mission._Text6, "green", 15.0);
      SucceedMission(GetTime() + 10.0, "Reco.des")
      Mission.ObjectiveEight = true;
   end

end
