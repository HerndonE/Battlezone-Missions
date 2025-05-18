--[[
___________.____    .___  ________  ___ ______________   _________.___   _____   ____ ___.____       ________________________ __________
\_   _____/|    |   |   |/  _____/ /   |   \__    ___/  /   _____/|   | /     \ |    |   \    |     /  _  \__    ___/\_____  \\______   \
 |    __)  |    |   |   /   \  ___/    ~    \|    |     \_____  \ |   |/  \ /  \|    |   /    |    /  /_\  \|    |    /   |   \|       _/
 |     \   |    |___|   \    \_\  \    Y    /|    |     /        \|   /    Y    \    |  /|    |___/    |    \    |   /    |    \    |   \
 \___  /   |_______ \___|\______  /\___|_  / |____|    /_______  /|___\____|__  /______/ |_______ \____|__  /____|   \_______  /____|_  /
     \/            \/           \/       \/                    \/             \/                 \/       \/                 \/       \/

Battlezone Combat Commander: Flight Simulator
Event Scripting: F9bomber
]] --

local mrs = require("map_ring_spawn");

local Mission = {
	TPS = 0;
	RingCollectionTable = {};
	isISDF = false;
	isSCION = false;
	isHADEAN = false;
	isFREEFORM = false;
	isNOTFREEFORM = false;
	isRings = false;
	Tolerance = 45.0;
	xPos = 0;
	zPos = 0;
	Player = nil;
	PlayerVeloc = 0;
	PlayerSpeed = 0;
	PlayerFront = 0;
	PlayerFrontDegrees = 0;
	CompassList = { "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW", "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S*" };
	CompassDir = {};
	OneTimeUiClosed = false;
}

local script_confirm = CalcCRC("script.confirm.agreed");
IFace_CreateCommand("script.confirm.agreed");

local script_retry = CalcCRC("script.confirm.agreed1");
IFace_CreateCommand("script.confirm.agreed1");

local targetDegrees = { -180, -135, -90, -45, 0, 45, 90, 135, 180 }
local degreeMapping = {
	[0]    = { "RollBoxRight0Degrees", "RollBoxLeft0Degrees" },
	[45]   = { "RollBoxRight45Degrees", "RollBoxLeft45Degrees" },
	[90]   = { "RollBoxRight90Degrees", "RollBoxLeft90Degrees" },
	[135]  = { "RollBoxRight135Degrees", "RollBoxLeft135Degrees" },
	[180]  = { "RollBoxRight180Degrees", "RollBoxLeft180Degrees" },
	[-45]  = { "RollBoxRightNeg45Degrees", "RollBoxLeftNeg45Degrees" },
	[-90]  = { "RollBoxRightNeg90Degrees", "RollBoxLeftNeg90Degrees" },
	[-135] = { "RollBoxRightNeg135Degrees", "RollBoxLeftNeg135Degrees" },
	[-180] = { "RollBoxRightNeg180Degrees", "RollBoxLeftNeg180Degrees" }
}

local formattedSpeed = "---";
local updateTimer = 1e6;
local updateInterval = 0.5;
local displayUpdate = false;
local formattedFrontDegrees = "---";
local formattedMoveDegrees = "---";
local formattedFacingDir = formattedFrontDegrees .. " ~ " .. "???";

function InitialSetup()
	Mission.TPS = EnableHighTPS();
	AllowRandomTracks(true);

	local preloadODF = {
		"ring_big",
		"ring_small",
		"ring_medium",
	}

	for k, v in pairs(preloadODF) do
		PreloadODF(v);
	end
end

function Start()
	for i = -8, 8 do
		local j = i + 9;
		Mission.CompassDir[i] = Mission.CompassList[j];
	end

	IFace_Exec("telemetry.cfg");
	IFace_Exec("scout_logo.cfg");
	IFace_Exec("sim_menu.cfg");
	IFace_Exec("retry_menu.cfg");
	IFace_Activate("SimMenu");
end

function Update()
	Mission.Player = GetPlayerHandle(1);
	Menu();
end

function ProcessCommand(crc)
	if (crc == script_confirm) then
		IFace_Deactivate("RetryMenu")
		Mission.OneTimeUiClosed = true
	elseif (crc == script_retry) then
		IFace_Activate("SimMenu")
		Mission.OneTimeUiClosed = false
	end
end

function PreGetIn(CurWorld, PilotHandle, EmptyCraftHandle)
	-- Make sure we are lockstep first.
	if (CurWorld ~= 0) then return 1 end;

	-- Check that the pilot is the player.
	if (IsPlayer(PilotHandle) == false) then return 1 end;

	-- Grab the faction of the empty handle.
	local craftRace = GetRace(EmptyCraftHandle);

	-- Activate UI based on the race for the player.
	if (craftRace == 'i') then
		IFace_Activate("scoutISDF");
	elseif (craftRace == 'f') then
		IFace_Activate("scoutSCION");
	elseif (craftRace == 'e') then
		IFace_Activate("scoutHADEAN");
	end

	-- Return the expected result to PreGetIn to avoid console errors.
	return 1 -- Allow Pilot Entry (PREGETIN_ALLOW)
end

function OutputFormatting(num)
	return string.format("%3.2f", num);
end

function Menu()
	if (Mission.OneTimeUiClosed == false) then
		FreeCamera()
	else
		if (CheckFreeForm() == true) then
			FreeCamera()
		else
			FreeFinish()
			Telemetry()
			PlayerRoll()
			CheckShipSelection()
			checkPlayerShip()
			-- barrierCheck(player, Mission.ringCollectionTable) -- This function works but will need to be expanded for proper use cases	
			-- SetVelocity(player, SetVector(0, 0, 0)) -- To lock player in one position
		end
	end
end

function PlayerRoll()
	IFace_Activate("RollBoxLeft")
	IFace_Activate("RollBoxRight")

	local playerMatrix = GetTransform(Mission.Player);
	local worldUp = SetVector(0, 1, 0);
	local rollRadians, rollDegrees;

	if (IsNullVector(playerMatrix.front) == false and IsNullVector(playerMatrix.up) == false and IsNullVector(playerMatrix.right) == false) then
		rollRadians = math.atan2(DotProduct(playerMatrix.right, worldUp), DotProduct(playerMatrix.up, worldUp));
		rollDegrees = math.floor(rollRadians * (180 / 3.14159265));
	else
		print("Error: Invalid matrix vectors (got a null vector)");
	end

	for _, deg in ipairs(targetDegrees) do
		if (IsDegreeInRange(rollDegrees, deg)) then
			HandleDegreeActivation(deg);
			break;
		end
	end
end

function IsDegreeInRange(deg, range)
	return math.abs(deg - range) < Mission.Tolerance / 2 -- 1/2 tolerance.
end

function HandleDegreeActivation(deg)
	-- Deactivate all previously activated boxes (to ensure only one is active at a time)
	for _, elements in pairs(degreeMapping) do
		IFace_Deactivate(elements[1])
		IFace_Deactivate(elements[2])
	end

	-- If the degree is valid, activate the corresponding UI elements
	if degreeMapping[deg] then
		IFace_Activate(degreeMapping[deg][1])
		IFace_Activate(degreeMapping[deg][2])
	end
end

function CheckShipSelection()
	local int0 = GetVarItemInt("options.instant.int0");

	if (Mission.isISDF == false and int0 == 0) then
		print("Player has selected ISDF Scout")
		local originalPlayerShip = Mission.Player;
		SetAsUser(BuildObject("ivscout_vsr", 1, originalPlayerShip), 1);
		RemoveObject(originalPlayerShip);
		Mission.isISDF = true;
	elseif (Mission.isSCION == false and int0 == 1) then
		print("Player has selected SCION Scout")
		local originalPlayerShip = Mission.Player;
		SetAsUser(BuildObject("fvscout_vsr", 1, originalPlayerShip), 1);
		RemoveObject(originalPlayerShip);
		Mission.isSCION = true;
	elseif (Mission.isHADEAN == false and int0 == 2) then
		print("Player has selected HADEAN Scout")
		local originalPlayerShip = Mission.Player;
		SetAsUser(BuildObject("evscout_vsr", 1, originalPlayerShip), 1);
		RemoveObject(originalPlayerShip);
		Mission.isHADEAN = true;
	end
end

function CheckFreeForm()
	local int1 = GetVarItemInt("options.instant.int1");

	-- If the player selects YES in free form but Yes to Ring Size
	if (Mission.isNOTFREEFORM == false) then
		local int2 = GetVarItemInt("options.instant.int2");

		if (int1 == 0) then
			print("Player has selected 'YES' to Free Form | Value: " .. int1);

			if (Mission.isRings == false and (int2 >= 1 and int2 <= 4)) then
				print("Player has selected 'YES' to Hover Course | Value: " .. int2);
				IFace_Deactivate("SimMenu");
				IFace_Activate("RetryMenu");
				Mission.isFREEFORM = true
			else
				Mission.isNOTFREEFORM = true;
			end
		else
			print("Player has selected 'NO' to Free Form | Value: " .. int1);
			if (Mission.isRings == false and (int2 == 0 or (int2 >= 1 and int2 <= 4))) then
				print("Player has selected 'YES' to Hover Course | Value: " .. int2);
				print("Player is on: " .. GetMissionFilename())
				Mission.RingCollectionTable = SpawnRings(int2, mrs.SpawnRingsFromOffset(GetMissionFilename()));
				Mission.isNOTFREEFORM = true;
			end
		end
	end
end

function SpawnRings(selectionChoice, xIncrement)
	local ringTypes = {
		[1] = "ring_small",
		[2] = "ring_medium",
		[3] = "ring_big"
	}

	local selectedRingType = ringTypes[selectionChoice] or "ring_small" -- fallback to "ring_small" if invalid

	local playerPos = GetPosition(Mission.Player)
	local ringCollection = {}
	local xSpace = 0
	local amplitude = 80
	local frequency = 0.5
	local groundClearance = 20
	local waveChoice = math.random(1, 3) -- 1 = sine, 2 = cosine, 3 = tangent
	
	for i = 2, 20 do
		xSpace = xSpace + xIncrement
		Mission.xPos = playerPos.x + xSpace
		Mission.zPos = playerPos.z
		
		local probe = BuildObject("dummy", 0, SetVector(Mission.xPos, TerrainFindFloor(playerPos) + 130, Mission.zPos))
		local probePos = GetPosition(probe)
		RemoveObject(probe)

		local terrainY = probePos.y
		local yOffset

		if waveChoice == 1 then
			yOffset = math.sin(i * frequency) * amplitude
		elseif waveChoice == 2 then
			yOffset = math.cos(i * frequency) * amplitude
		else
			local tanVal = math.tan(i * frequency)
			tanVal = math.max(math.min(tanVal, 1), -1) -- Clamp between -1 and 1
			yOffset = tanVal * amplitude
		end

		local finalY = terrainY + yOffset + groundClearance
		local spawnRingLocation = SetVector(Mission.xPos, finalY, Mission.zPos)
		local ring = BuildObject(selectedRingType, 0, spawnRingLocation)
		SetAngle(ring, 90)

		ringCollection[i] = ring
	end

	return ringCollection

end

function BarrierCheck(player, ringTable)
	for i = 2, #ringTable do
		local handle = ringTable[i];
		if (GetDistance(player, handle) < 5.0) then
			handle = SetTeamColor(i, SetVector(0, 153, 0))
		end
	end
end

function checkPlayerShip()
	if IsOdf(Mission.Player, "ivscout") or IsOdf(Mission.Player, "ivscout_vsr") then
		IFace_Activate("scoutISDF")
	else
		IFace_Deactivate("scoutISDF")
	end
	
	if IsOdf(Mission.Player, "fvscout") or IsOdf(Mission.Player, "fvscout_vsr") then
		IFace_Activate("scoutSCION")
	else
		IFace_Deactivate("scoutSCION")
	end
	
	if IsOdf(Mission.Player, "evscout") or IsOdf(Mission.Player, "evscout_vsr") then
		IFace_Activate("scoutHADEAN")
	else
		IFace_Deactivate("scoutHADEAN")
	end
end

function Telemetry()
	local playerVelocRaw = GetVelocity(Mission.Player);
	Mission.PlayerVeloc = SetVector(playerVelocRaw.x, 0, playerVelocRaw.z)
	Mission.PlayerSpeed = Length(Mission.PlayerVeloc)

	if (Mission.PlayerSpeed < 0.1) then
		formattedSpeed = "000.00";
	else
		formattedSpeed = OutputFormatting(Mission.PlayerSpeed);
	end

	Mission.PlayerFront = GetFront(Mission.Player)
	Mission.PlayerFrontDegrees = FrontToDegrees(Mission.PlayerFront)
	formattedFrontDegrees = OutputFormatting(Mission.PlayerFrontDegrees)
	local compassFrontStr = CompassHeading(Mission.PlayerFrontDegrees)

	formattedFacingDir = formattedFrontDegrees .. " ~ " .. compassFrontStr

	local playerMoveDir = math.atan2(Mission.PlayerVeloc.z, Mission.PlayerVeloc.x);
	local playerMoveDegrees = playerMoveDir * (180 / math.pi);

	if (playerMoveDegrees < 0) then
		-- make full 360 degree circle where 0 is at "E"
		playerMoveDegrees = 360 + playerMoveDegrees;
	end

	if (playerMoveDegrees > 90 and playerMoveDegrees < 270) then
		playerMoveDegrees = (-1 * playerMoveDegrees) + 90
	elseif (playerMoveDegrees > 0 and playerMoveDegrees < 90) then
		playerMoveDegrees = 90 - playerMoveDegrees
	elseif (playerMoveDegrees > 270 and playerMoveDegrees < 360) then
		playerMoveDegrees = 450 - playerMoveDegrees
	end

	formattedMoveDegrees = OutputFormatting(playerMoveDegrees)
	local compassMoveStr = CompassHeading(playerMoveDegrees)

	local playerPos = GetPosition(Mission.Player);
	local alt = playerPos.y - TerrainFindFloor(playerPos);

	ShowSpeedCFG(formattedSpeed)
	ShowAltCFG(alt)
	ShowPlayerHeading(formattedFrontDegrees, compassFrontStr)
end

function UiDivider(content)
	return content;
end

function ShowSpeedCFG(mySpeed)
	IFace_ClearListBox("SpeedBox");
	local speed = math.ceil(mySpeed)

	-- flip speed negative if we're going in reverse.
	if (DotProduct(GetVelocity(Mission.Player), GetFront(Mission.Player)) < 0) then
		speed = -speed;
	end

	ShowSpeed("   SPD", 9)

	if (speed % 2 == 0) then -- alternate based on even/odd value, simulates scrolling.
		ShowSpeed("--- " .. speed + 4, 9)
		UiDivider(ShowSpeed("-- " .. speed + 3, 12))
		ShowSpeed("--- " .. speed + 2, 9)
		UiDivider(ShowSpeed("-- " .. speed + 1, 12))
		ShowSpeed(">  " .. speed, 9)
		UiDivider(ShowSpeed("-- " .. speed - 1, 12))
		ShowSpeed("--- " .. speed - 2, 9)
		UiDivider(ShowSpeed("-- " .. speed - 3, 12))
		ShowSpeed("--- " .. speed - 4, 9)
	else
		UiDivider(ShowSpeed("-- " .. speed + 4, 12))
		ShowSpeed("--- " .. speed + 3, 9)
		UiDivider(ShowSpeed("-- " .. speed + 2, 12))
		ShowSpeed("--- " .. speed + 1, 9)
		ShowSpeed(">  " .. speed, 12)
		ShowSpeed("--- " .. speed - 1, 9)
		UiDivider(ShowSpeed("-- " .. speed - 2, 12))
		ShowSpeed("--- " .. speed - 3, 9)
		UiDivider(ShowSpeed("-- " .. speed - 4, 12))
	end

	IFace_Activate("SpeedBox")
end

function ShowSpeed(num1, totalWidth)
	local str1 = tostring(num1)
	local padding = totalWidth - #str1
	return IFace_AddTextItem("SpeedBox", str1 .. string.rep(" ", padding));
end

function ShowAltCFG(myAltitude)
	IFace_ClearListBox("AltBox"); -- clear the listbox

	local altitude = math.ceil(myAltitude)
	ShowAlt("ALT   ", 9)

	if (altitude % 2 == 0) then -- alternate readout based on even/odd values, simulates scrolling.
		ShowAlt(altitude + 4 .. " ---", 9)
		UiDivider(ShowAlt(altitude + 3 .." --", 12))
		ShowAlt(altitude + 2 .. " ---", 9)
		UiDivider(ShowAlt(altitude + 1 .. " --", 12))
		ShowAlt(altitude .. "  <", 9)
		UiDivider(ShowAlt(altitude + 1 .. " --", 12))
		ShowAlt(altitude - 2 .. " ---", 9)
		UiDivider(ShowAlt(altitude + 3 .. " --", 12))
		ShowAlt(altitude - 4 .. " ---", 9)
	else
		UiDivider(ShowAlt(altitude + 4 .. " --", 12))
		ShowAlt(altitude + 3 .. " ---", 9)
		UiDivider(ShowAlt(altitude + 2 .. " --", 12))
		ShowAlt(altitude + 1 .. " ---", 9)
		ShowAlt(altitude .. "  <", 12)
		ShowAlt(altitude - 1 .. " ---", 9)
		UiDivider(ShowAlt(altitude - 2 .. " --", 12))
		ShowAlt(altitude - 3 .. " ---", 9)
		UiDivider(ShowAlt(altitude - 4 .. " --", 12))
	end

	IFace_Activate("AltBox");
end

function ShowAlt(num1, totalWidth)
	local str1 = tostring(num1)
	local padding = totalWidth - #str1
	return IFace_AddTextItem("AltBox", string.rep(" ", padding) .. str1);
end

function ShowPlayerHeading(playerFrontDegrees, playerCompassFrontStr)
	ShowHeading(math.ceil(playerFrontDegrees), 7);
	UiDivider(ShowHeading("V", 7));
	ShowHeading(playerCompassFrontStr, 7);

	IFace_Activate("playerHeadingBox");
end

function ShowHeading(num1, totalWidth)
	local str1 = tostring(num1)
	local padding = totalWidth - #str1
	return IFace_AddTextItem("playerHeadingBox", string.rep(" ", padding) .. str1);
end

function CompassHeading(degrees)
	local smallestSoFar, smallestIndex;
	for i = -8, 8 do
		if not smallestSoFar or (math.abs(degrees - (i * 22.5)) < smallestSoFar) then
			smallestSoFar = math.abs(degrees - (i * 22.5));
			smallestIndex = i;
		end
	end
	return (Mission.CompassDir[smallestIndex]);
end
