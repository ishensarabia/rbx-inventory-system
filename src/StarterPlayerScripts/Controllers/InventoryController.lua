-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Enums
local ItemsEnum = require(ReplicatedStorage.Source.Enums.ItemsEnum)

-- Constants
local INVENTORY_TOGGLE_ACTION_NAME = "ToggleInventory"

-- Gui
local InventoryGui: ScreenGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("InventoryGui")
local InventoryScrollingFrame: ScrollingFrame = InventoryGui.CanvasGroup.ScrollingFrame

local InventoryController = Knit.CreateController({
	Name = "InventoryController",
	InventoryChanged = Signal.new(),
})

local existingItems = {}

local function createHoverLabel(itemFrame, description)
	local hoverLabel = Instance.new("TextLabel")
	hoverLabel.Size = UDim2.fromScale(1, 0.2)
	hoverLabel.Position = UDim2.fromScale(0, 0.8)
	hoverLabel.Text = description
	hoverLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	hoverLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	hoverLabel.TextScaled = true
	hoverLabel.Position = UDim2.fromScale(0, 0)
	hoverLabel.Visible = false
	hoverLabel.Parent = itemFrame

	itemFrame.MouseEnter:Connect(function()
		hoverLabel.Visible = true
	end)

	itemFrame.MouseLeave:Connect(function()
		hoverLabel.Visible = false
	end)
end

local function createItemFrames(inventoryItems: table)
	for _, item: table in inventoryItems do
		if not existingItems[item.GUID] then
			local itemFrame = Instance.new("Frame")
			itemFrame.Size = UDim2.fromScale(0.2, 0.2)
			itemFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			itemFrame.BorderSizePixel = 0
			itemFrame.Parent = InventoryScrollingFrame

			local itemImage = Instance.new("ImageLabel")
			itemImage.Size = UDim2.fromScale(0.8, 0.8)
			itemImage.Position = UDim2.fromScale(0.1, 0.1)
			itemImage.Image = "rbxassetid://0"
			itemImage.Parent = itemFrame

			local itemNameLabel = Instance.new("TextLabel")
			itemNameLabel.Size = UDim2.fromScale(1, 0.2)
			itemNameLabel.Position = UDim2.fromScale(0, 0.8)
			itemNameLabel.Text = ItemsEnum[item.ItemID].Name
			itemNameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
			itemNameLabel.TextScaled = true
			itemNameLabel.Parent = itemFrame

			createHoverLabel(itemFrame, ItemsEnum[item.ItemID].Description)

			existingItems[item.GUID] = true
		end
	end
end

function InventoryController:KnitStart()
	InventoryGui.Enabled = false

	local function observeInventoryItems(inventoryItems: table)
		-- Create a frame for each item in the inventory with an image and text label for the item name
		createItemFrames(inventoryItems)

		self.InventoryChanged:Fire(inventoryItems)
	end

	local InventoryService = Knit.GetService("InventoryService")
	InventoryService:GetPlayerInventory():andThen(observeInventoryItems)
	InventoryService.InventoryChanged:Connect(observeInventoryItems)

	ContextActionService:BindActionAtPriority(
		INVENTORY_TOGGLE_ACTION_NAME,
		function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
			if inputState == Enum.UserInputState.Begin and actionName == INVENTORY_TOGGLE_ACTION_NAME then
				InventoryGui.Enabled = not InventoryGui.Enabled
			end
		end,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.I,
		Enum.KeyCode.ButtonY
	)
end

function InventoryController:KnitInit() end

return InventoryController
