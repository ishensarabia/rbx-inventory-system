-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Profile store
local ProfileStore = require(ServerStorage.Source.Services.Data.ProfileStore)

-- The PROFILE_TEMPLATE table is what new profile (new players) "Profile.Data" will default to:
local PROFILE_TEMPLATE = {
	Items = {},
}

local PlayerStore = ProfileStore.New("PlayerStore", PROFILE_TEMPLATE)
local Profiles: { [player]: typeof(PlayerStore:StartSessionAsync()) } = {}

local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {},
})

local function PlayerAdded(player: Player)
	-- Start a profile session for this player's data:
	local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	-- Handling new profile session or failure to start it:

	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

		profile.OnSessionEnd:Connect(function()
			Profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			Profiles[player] = profile
			print(`Profile loaded for {player.DisplayName}!`)
		else
			-- The player has left before the profile session started
			profile:EndSession()
		end
	else
		-- This condition should only happen when the Roblox server is shutting down
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

function DataService:KnitInit() end

function DataService:KnitStart()
	print("DataService started")
	-- In case Players have joined the server earlier than this script ran:
	for _, player in Players:GetPlayers() do
		task.spawn(PlayerAdded, player)
	end

	Players.PlayerAdded:Connect(PlayerAdded)

	Players.PlayerRemoving:Connect(function(player)
		local profile = Profiles[player]
		if profile ~= nil then
			profile:EndSession()
		end
	end)
end

--[=[
	@function DataService:GetData
	@param player Player
	@return table
	@tag Server
	@description Returns the player's data.
]=]
function DataService:GetData(player: Player)
	return Profiles[player].Data
end

--[=[
	@function DataService:UpdateProfileKeyValue
	@param player Player
	@param key string
	@param value any
	@tag Server
	@description Updates the player data key value from the profile.
	@example DataService:SaveData(player, "Coins", 100)
]=]
function DataService:UpdateProfileKeyValue(player: Player, key: string, value: any)
	local profile = Profiles[player]
	profile.Data[key] = value
end

return DataService
