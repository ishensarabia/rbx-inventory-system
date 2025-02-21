local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local InventoryController = Knit.CreateController({
	Name = "InventoryController",
	InventoryChanged = Signal.new(),
})

function InventoryController:KnitStart()

    local function observeInventoryItems(inventoryItems: table)
        print("Inventory changed: ", inventoryItems )
        self.InventoryChanged:Fire(inventoryItems)
    end

	local InventoryService = Knit.GetService("InventoryService")
	InventoryService:GetPlayerInventory():andThen(observeInventoryItems)
end

function InventoryController:KnitInit() end

return InventoryController
