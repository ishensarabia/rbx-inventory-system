-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
-- Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

local InventoryService = Knit.CreateService({
	Name = "InventoryService",
	Client = {
		InventoryChanged = Knit.CreateSignal(),
	},
})

export type Item = {
    Name: string,
    Description: string,
}

--[=[
    @param player: Player
    @return table
    @example
    local playerData = InventoryService:GetPlayerInventory(Players.Sci_Punk)
    @description
    Fetches the player's inventory data from the data store service.
]=]
function InventoryService:GetPlayerInventory(player: Player)
	local playerData = self._DataStoreService:GetData(player)
	return playerData.Items
end

function InventoryService.Client:GetPlayerInventory(player: Player)
	return self.Server:GetPlayerInventory(player)
end

function InventoryService:AddItem(player: Player, item: Item)
	local playerData = self._DataStoreService:GetData(player)
	table.insert(playerData.Items, item)
	self._DataStoreService:UpdateProfileKeyValue(player, "Items", playerData.Items)
	self.Client.InventoryChanged:Fire(player, playerData.Items)
end

function InventoryService:KnitStart()
	
end

function InventoryService:KnitInit()
	self._DataStoreService = Knit.GetService("DataService")
end

return InventoryService
