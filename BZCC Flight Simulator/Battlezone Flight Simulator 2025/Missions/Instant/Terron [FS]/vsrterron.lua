--[[
___________.____    .___  ________  ___ ______________   _________.___   _____   ____ ___.____       ________________________ __________ 
\_   _____/|    |   |   |/  _____/ /   |   \__    ___/  /   _____/|   | /     \ |    |   \    |     /  _  \__    ___/\_____  \\______   \
 |    __)  |    |   |   /   \  ___/    ~    \|    |     \_____  \ |   |/  \ /  \|    |   /    |    /  /_\  \|    |    /   |   \|       _/
 |     \   |    |___|   \    \_\  \    Y    /|    |     /        \|   /    Y    \    |  /|    |___/    |    \    |   /    |    \    |   \
 \___  /   |_______ \___|\______  /\___|_  / |____|    /_______  /|___\____|__  /______/ |_______ \____|__  /____|   \_______  /____|_  /
     \/            \/           \/       \/                    \/             \/                 \/       \/                 \/       \/ 

Battlezone Combat Commader: Flight Simulator
Event Scripting: F9bomber
]]--

local Mission = {
	TPS = 0;
	ringCollectionTable;
	isISDF = false;
	isSCION = false;
	isHADEAN = false;
	isFREEFORM = false;
	isNOTFREEFORM = false;
	isRings = false;
	tolerance = 45.0;
	xPos;
	zPos;
	
}
local script_confirm = CalcCRC("script.confirm.agreed");
IFace_CreateCommand("script.confirm.agreed");

local script_retry = CalcCRC("script.confirm.agreed1");
IFace_CreateCommand("script.confirm.agreed1");

local targetDegrees = {-180, -135, -90, -45, 0, 45, 90, 135, 180}
local degreeMapping = {
    [0]    = {"RollBoxRight0Degrees", "RollBoxLeft0Degrees"},
    [45]   = {"RollBoxRight45Degrees", "RollBoxLeft45Degrees"},
    [90]   = {"RollBoxRight90Degrees", "RollBoxLeft90Degrees"},
    [135]  = {"RollBoxRight135Degrees", "RollBoxLeft135Degrees"},
    [180]  = {"RollBoxRight180Degrees", "RollBoxLeft180Degrees"},
    [-45]  = {"RollBoxRightNeg45Degrees", "RollBoxLeftNeg45Degrees"},
    [-90]  = {"RollBoxRightNeg90Degrees", "RollBoxLeftNeg90Degrees"},
    [-135] = {"RollBoxRightNeg135Degrees", "RollBoxLeftNeg135Degrees"},
    [-180] = {"RollBoxRightNeg180Degrees", "RollBoxLeftNeg180Degrees"}
}


player = nil
playerVeloc = SetVector(0, 0, 0)
playerSpeed = 0
formattedSpeed = "---"
playerFront = SetVector(0, 0, 0)
playerFrontDegrees = 0
updateTimer = 1e6
updateInterval = 0.5
displayUpdate = false
sampleSum = 0
velocAverage = 0.0
formattedFrontDegrees = "---"
formattedMoveDegrees = "---"
formattedFacingDir = formattedFrontDegrees .. " ~ " .. "???"

function InitialSetup()
	Mission.TPS = EnableHighTPS()
	AllowRandomTracks(true)
	
	local preloadODF = {
		"ring_big",
		"ring_small",
		"ring_medium",
	}

	for k,v in pairs(preloadODF) do
		PreloadODF(v)
	end
end

function DeleteObject(h)
end

function Start()
	IFace_EnterMenuMode();
	IFace_Exec("sim_menu.cfg")
	IFace_Exec("retry_menu.cfg")
	IFace_Activate("SimMenu")
end

function Update()
	player = GetPlayerHandle()
	menu(player)	
end

function ProcessCommand (crc)
	if crc == script_confirm then
		IFace_Deactivate("RetryMenu")
		IFace_ExitMenuMode();
		IFace_Exec("telemetry.cfg")
		IFace_Exec("scout_logo.cfg")
		OneTimeUiClosed = true
	end
	
	if crc == script_retry then
		IFace_Activate("SimMenu")
		OneTimeUiClosed = false
	end
end

function OutputFormatting(num)
    returnString = string.format("%3.2f", num)
    return returnString
end

function menu(player)	
	if not OneTimeUiClosed then
		FreeCamera()
	else
		if checkFreeForm() == true then
			FreeCamera()
		else
			FreeFinish()
			telemetry(player)
			playerRoll()
			checkShipSelection(player)	
			checkPlayerShip(player)
			-- barrierCheck(player, Mission.ringCollectionTable) -- This function works but will need to be expanded for proper use cases	
			-- SetVelocity(player, SetVector(0, 0, 0)) -- To lock player in one position
		end
	end
		
end

function playerRoll()	
	IFace_Activate("RollBoxLeft")
	IFace_Activate("RollBoxRight")
	
	playerMatrix = GetTransform(GetPlayerHandle());
	front = playerMatrix.front;
	up = playerMatrix.up;
	right = playerMatrix.right;
	worldUp = SetVector(0, 1, 0);  

	if not IsNullVector(front) and not IsNullVector(up) and not IsNullVector(right) then
		rollRadians = math.atan2(DotProduct(right, worldUp), DotProduct(up, worldUp));
		rollDegrees = math.floor(rollRadians * (180 / 3.14159265));
		--ClearObjectives()
		--AddObjective("Turn: " ..GetLockstepTurn() .. " Degree: " .. rollDegrees, "white", 10)
	else
		print("Error: Invalid matrix vectors (got a null vector)");
	end
	
	for _, deg in ipairs(targetDegrees) do
		if isDegreeInRange(rollDegrees, deg) then
			handleDegreeActivation(deg)
			break
		end
	end
end


function isDegreeInRange(deg, range)

	--AddObjective("Deg: " .. deg .. " Range: " .. range .. " Tolerance: " .. Mission.tolerance, "white", 10)

    return math.abs(deg - range) < Mission.tolerance / 2 -- 1/2 tolerance.
end

function handleDegreeActivation(deg)
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


function checkShipSelection(player)
	if not Mission.isISDF and GetVarItemInt("options.instant.int0") == 0 then
		print("Player has selected ISDF Scout")
		local originalPlayerShip = GetPlayerHandle();
		SetAsUser(BuildObject("ivscout_vsr", 1, player), 1);
		RemoveObject(originalPlayerShip);    
		Mission.isISDF = true;
	end 
	
	if not Mission.isSCION and GetVarItemInt("options.instant.int0") == 1 then
		print("Player has selected SCION Scout")
		local originalPlayerShip = GetPlayerHandle();
		SetAsUser(BuildObject("fvscout_vsr", 1, player), 1);
		RemoveObject(originalPlayerShip);    
		Mission.isSCION = true;
	end 
	
	if not Mission.isHADEAN and GetVarItemInt("options.instant.int0") == 2 then
		print("Player has selected HADEAN Scout")
		local originalPlayerShip = GetPlayerHandle();
		SetAsUser(BuildObject("evscout_vsr", 1, player), 1);
		RemoveObject(originalPlayerShip);    
		Mission.isHADEAN = true;
	end 
end

function checkFreeForm()	
	if not Mission.isNOTFREEFORM and GetVarItemInt("options.instant.int1") == 0 then -- If the player selects YES in free form but Yes to Ring Size
		print("Player has selected 'YES' to Free Form | Value: " .. GetVarItemInt("options.instant.int1"))
		local int2 = GetVarItemInt("options.instant.int2")
		if not Mission.isRings and (int2 >= 1 and int2 <= 4) then
			print("Player has selected 'YES' to Hover Course | Value: " .. int2)
			IFace_Deactivate("SimMenu")
			IFace_Activate("RetryMenu")
			Mission.isFREEFORM = true
			return Mission.isFREEFORM
		else
			Mission.isNOTFREEFORM = true
		end
	end
	
	if not Mission.isNOTFREEFORM and GetVarItemInt("options.instant.int1") == 1 then -- If the player selects NO in free form but Yes to Ring Size
		print("Player has selected 'NO' to Free Form | Value: " .. GetVarItemInt("options.instant.int1"))
		local int2 = GetVarItemInt("options.instant.int2")
		if not Mission.isRings and (int2 == 0 or (int2 >= 1 and int2 <= 4)) then
			print("Player has selected 'YES' to Hover Course | Value: " .. int2)			
			Mission.ringCollectionTable = spawnRings(int2)
			Mission.isNOTFREEFORM = true
		end
	end
end

function spawnRings(selectionChoice)

	local ringTypes = {
		[1] = "ring_small",
		[2] = "ring_medium",
		[3] = "ring_big"
	}

	local selectedRingType = ringTypes[selectionChoice] or "ring_small" -- fallback to "ring_small" if invalid

	player = GetPosition(GetPlayerHandle());
	ringCollection = {}
	xSpace = 0
	amplitude = 80
	frequency = 0.5       
	groundClearance = 10
	local waveChoice = math.random(1, 2) -- 1 = sine, 2 = cosine
	
	for i = 2, 20 do
		xSpace = xSpace + 50
		Mission.xPos = player.x + xSpace
		Mission.zPos = player.z
		
		local probe = BuildObject("dummy", 0, SetVector(Mission.xPos, 130, Mission.zPos))
		local probePos = GetPosition(probe)
		RemoveObject(probe)

		local terrainY = probePos.y

		local yOffset
		if waveChoice == 1 then -- Choose sine or cosine based on waveChoice
			yOffset = math.sin(i * frequency) * amplitude
		else
			yOffset = math.cos(i * frequency) * amplitude
		end

		local finalY = terrainY + yOffset + groundClearance
		local spawnRingLocation = SetVector(Mission.xPos, finalY, Mission.zPos)
		local ring = BuildObject(selectedRingType, 0, spawnRingLocation)
		SetAngle(ring, 90)

		ringCollection[i] = ring
	end
	
	return ringCollection	
end

function barrierCheck(player, ringTable)
	for i = 2, #ringTable do
		local handle = ringTable[i]
		if (GetDistance(player, handle) < 5.0) then
			handle = SetTeamColor(i, SetVector(0, 153, 0))
		end
	end
end

function checkPlayerShip(player)
	if IsOdf(player, "ivscout") or IsOdf(player, "ivscout_vsr") then
		IFace_Activate("scoutISDF")
	else
		IFace_Deactivate("scoutISDF")
	end
	
	if IsOdf(player, "fvscout") or IsOdf(player, "fvscout_vsr") then
		IFace_Activate("scoutSCION")
	else
		IFace_Deactivate("scoutSCION")
	end
	
	if IsOdf(player, "evscout") or IsOdf(player, "evscout_vsr") then
		IFace_Activate("scoutHADEAN")
	else
		IFace_Deactivate("scoutHADEAN")
	end
end

function telemetry(player)
	
    if updateTimer == 1e6 and not displayUpdate then
        updateTimer = GetTime() + updateInterval
    end

    if GetTime() > updateTimer and not displayUpdate then
        updateTimer = GetTime() + updateInterval
        displayUpdate = true
    end

    if displayUpdate then
        playerVelocRaw = GetVelocity(player)
        playerVeloc = SetVector(playerVelocRaw.x, 0, playerVelocRaw.z)
        playerSpeed = Length(playerVeloc)

        if playerSpeed < 0.1 then
            formattedSpeed = "000.00"
        else
            formattedSpeed = OutputFormatting(playerSpeed)
        end

        playerFront = GetFront(player)
        playerFrontDegrees = FrontToDegrees(playerFront)
        formattedFrontDegrees = OutputFormatting(playerFrontDegrees)
        compassFrontStr = CompassHeading(playerFrontDegrees)

        formattedFacingDir = formattedFrontDegrees .. " ~ " .. compassFrontStr

        playerMoveDir = math.atan2(playerVeloc.z, playerVeloc.x)
        playerMoveDegrees = playerMoveDir * (180 / math.pi)
        if playerMoveDegrees < 0 then
            -- make full 360 degree circle where 0 is at "E"
            playerMoveDegrees = 360 + playerMoveDegrees
        end

        if playerMoveDegrees > 90 and playerMoveDegrees < 270 then
            playerMoveDegrees = (-1 * playerMoveDegrees) + 90
        elseif playerMoveDegrees > 0 and playerMoveDegrees < 90 then
            playerMoveDegrees = 90 - playerMoveDegrees
        elseif playerMoveDegrees > 270 and playerMoveDegrees < 360 then
            playerMoveDegrees = 450 - playerMoveDegrees
        end
        formattedMoveDegrees = OutputFormatting(playerMoveDegrees)
        compassMoveStr = CompassHeading(playerMoveDegrees)
        
		playerPos = GetPosition(GetPlayerHandle());
		alt = playerPos.y - TerrainFindFloor(playerPos);
		showSpeedCFG(formattedSpeed)
		showaltCFG(alt)
		showPlayerHeading(alt, formattedFrontDegrees, compassFrontStr)
    end
end

function uiDivider(content)
   return content
end

function showSpeedCFG(mySpeed)
		IFace_ClearListBox("SpeedBox")
		local speed = math.ceil(mySpeed)
		
		-- flip speed negative if we're going in reverse.
		if (DotProduct(GetVelocity(player), GetFront(player)) < 0) then
			speed = -speed;
		end
		
		local legendTelem = showSpeed("   SPD", 9)
		
		if (speed % 2 == 0) then -- alternate based on even/odd value, simulates scrolling.
			local topTelem2 = showSpeed("--- " .. speed + 4, 9)
			uiDivider(showSpeed("-- ", 12))
			local topTelem = showSpeed("--- " .. speed + 2, 9)
			uiDivider(showSpeed("-- ", 12))
			local midTelem = showSpeed(">  " .. speed, 9)
			uiDivider(showSpeed("-- ", 12))
			local bottomTelem = showSpeed("--- " .. speed - 2, 9)
			uiDivider(showSpeed("-- ", 12))
			local bottomTelem2 = showSpeed("--- " .. speed - 4, 9)
		else
			uiDivider(showSpeed("-- ", 12))
			local topTelem = showSpeed("--- " .. speed + 3, 9)
			uiDivider(showSpeed("-- ", 12))
			local topTelem = showSpeed("--- " .. speed + 1, 9)
			local midTelem = showSpeed(">  ", 12)
			local bottomTelem = showSpeed("--- " .. speed - 1, 9)
			uiDivider(showSpeed("-- ", 12))
			local bottomTelem = showSpeed("--- " .. speed - 3, 9)
			uiDivider(showSpeed("-- ", 12))
		end
	
		IFace_Activate("SpeedBox")
end

function showSpeed(num1, totalWidth)
    local str1 = tostring(num1)
    local padding = totalWidth - #str1
	return IFace_AddTextItem("SpeedBox", str1 .. string.rep(" ", padding));
end

function showaltCFG(myAltitude)
		IFace_ClearListBox("AltBox"); -- clear the listbox
		local altitude = math.ceil(myAltitude)
		local legendTelem = showAlt("ALT   ", 9)
		
		if (altitude % 2 == 0) then -- alternate readout based on even/odd values, simulates scrolling.
			local topTelem2 = showAlt(altitude + 4 .. " ---", 9)
			uiDivider(showAlt(" --", 12))
			local topTelem = showAlt(altitude + 2 .. " ---", 9)
			uiDivider(showAlt(" --", 12))
			local midTelem = showAlt(altitude .. "  <", 9)
			uiDivider(showAlt(" --", 12))
			local bottomTelem = showAlt(altitude - 2 .. " ---", 9)
			uiDivider(showAlt(" --", 12))
			local bottomTelem2 = showAlt(altitude - 4 .. " ---", 9)
		else
			uiDivider(showAlt(" --", 12))
			local topTelem2 = showAlt(altitude + 3 .. " ---", 9)
			uiDivider(showAlt(" --", 12))
			local topTelem = showAlt(altitude + 1 .. " ---", 9)
			local midTelem = showAlt("  <", 12)
			local bottomTelem = showAlt(altitude - 1 .. " ---", 9)
			uiDivider(showAlt(" --", 12))
			local bottomTelem2 = showAlt(altitude - 3 .. " ---", 9)
			uiDivider(showAlt(" --", 12))
		end	
		
		IFace_Activate("AltBox")
end

function showAlt(num1, totalWidth)
    local str1 = tostring(num1)
    local padding = totalWidth - #str1
	return IFace_AddTextItem("AltBox", string.rep(" ", padding) .. str1);
end

function showPlayerHeading(altitude, playerFrontDegrees, playerCompassFrontStr)
	local playerHeadingDegress = showHeading(math.ceil(playerFrontDegrees), 7);
	uiDivider(showHeading("V", 7))
	local topTelem = showHeading(playerCompassFrontStr, 7)
	IFace_Activate("playerHeadingBox")
end

function showHeading(num1, totalWidth)
    local str1 = tostring(num1)
    local padding = totalWidth - #str1
	return IFace_AddTextItem("playerHeadingBox", string.rep(" ", padding) .. str1);
end

compassList = {"S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW", "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S*"}
compassDir = {}
for i = -8, 8 do
    j = i + 9
    compassDir[i] = compassList[j]
end

function CompassHeading(degrees)
    local smallestSoFar, smallestIndex
    for i = -8, 8 do
        if not smallestSoFar or (math.abs(degrees - (i * 22.5)) < smallestSoFar) then
            smallestSoFar = math.abs(degrees - (i * 22.5))
            smallestIndex = i
        end
    end
    return (compassDir[smallestIndex])
end