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

assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local M = {

}

function M.SpawnRingsFromOffset(mapBZNName)

	local mapsOptions = {
		{"vsrterron.bzn", 50}, -- Map name, xOffset for player
		{"vsroverlook.bzn", -50},
		{"FS-MPIDark Halls.bzn", 50},
		{"FS-MPIGlacier.bzn", 50},
		{"FS-MPIGround One.bzn", 50},
		{"FS-MPILake Side.bzn", 50},
		{"FS-MPIMolten Field.bzn", -50},
		{"FS-MPIOasis.bzn", -45},
		{"FS-SHound.bzn", 42},
		{"FS-Money_Pit.bzn", -50},
		{"FS-MPIGround Bravo.bzn", 50},
		{"FS-MPIAN.bzn", 50},
		{"FS-MPIWild Lands.bzn", 47},
	}

	local mapOffset = 0
	for _, option in ipairs(mapsOptions) do
		if option[1] == mapBZNName then
			mapOffset = option[2] -- depending on the map, will need to account ring spawn otherwise they can spawn in the hills
			break
		end
	end	
	return mapOffset
end

return M