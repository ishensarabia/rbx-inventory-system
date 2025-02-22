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
	hoverLabel.Position = UDim2.fromScale(0, 0.5)
	hoverLabel.Visible = false
	hoverLabel.Parent = itemFrame

	itemFrame.MouseEnter:Connect(function()
		hoverLabel.Visible = true
	end)

	itemFrame.MouseLeave:Connect(function()
		hoverLabel.Visible = false
	end)
end

local function updateItemFrames(inventoryItems: table)
    -- Mark all existing items as not updated
    for guid, _ in pairs(existingItems) do
        existingItems[guid] = false
        -- Mark the frame for potential removal
        local itemFrame = InventoryScrollingFrame:FindFirstChild(guid)
        if itemFrame then
            itemFrame:SetAttribute("ToRemove", true)
        end
        -- Mark the frame for potential removal
    end

    for _, item: table in inventoryItems do
        local itemFrame = InventoryScrollingFrame:FindFirstChild(item.GUID)
        if not itemFrame then
            -- Create new item frame
            itemFrame = Instance.new("Frame")
            itemFrame.Name = item.GUID
            itemFrame.Size = UDim2.fromScale(0.2, 0.2)
            itemFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			itemFrame.BackgroundTransparency = 1
            itemFrame.BorderSizePixel = 0
            itemFrame.Parent = InventoryScrollingFrame

            local itemImage = Instance.new("ImageLabel")
            itemImage.Size = UDim2.fromScale(0.8, 0.8)
            itemImage.Position = UDim2.fromScale(0.1, 0.1)
            itemImage.Image = ItemsEnum[item.ItemID].Image
            itemImage.ScaleType = Enum.ScaleType.Fit
            itemImage.Parent = itemFrame

            local itemNameLabel = Instance.new("TextLabel")
            itemNameLabel.Size = UDim2.fromScale(1, 0.2)
            itemNameLabel.Position = UDim2.fromScale(0, 0.8)
            itemNameLabel.Text = ItemsEnum[item.ItemID].Name
            itemNameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
            itemNameLabel.TextScaled = true
            itemNameLabel.Parent = itemFrame

            -- Create x button to remove item from inventory
            local removeButton = Instance.new("TextButton")
            removeButton.Parent = itemFrame
            removeButton.Size = UDim2.fromScale(0.2, 0.2)
            removeButton.Position = UDim2.fromScale(0.8, 0)
            removeButton.Text = "X"
            removeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            removeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

            removeButton.Activated:Connect(function()
                local InventoryService = Knit.GetService("InventoryService")
                InventoryService:RemoveItem(item)
            end)

            createHoverLabel(itemFrame, ItemsEnum[item.ItemID].Description)
        end

        -- Mark the item as updated
        existingItems[item.GUID] = true
        itemFrame:SetAttribute("ToRemove", false)
    end

    -- Remove frames that are no longer in the inventory
    for _, itemFrame in ipairs(InventoryScrollingFrame:GetChildren()) do
        if itemFrame:IsA("Frame") and itemFrame:GetAttribute("ToRemove") then
            itemFrame:Destroy()
        end
    end
end

function InventoryController:KnitStart()
    InventoryGui.Enabled = false

    local function observeInventoryItems(inventoryItems: table)
        -- Update item frames based on the current inventory
        updateItemFrames(inventoryItems)

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
        true,
        Enum.ContextActionPriority.High.Value,
        Enum.KeyCode.I,
        Enum.KeyCode.ButtonY
    )
	-- Set the position of the inventory toggle action (mobile) and icon
	ContextActionService:SetPosition(INVENTORY_TOGGLE_ACTION_NAME, UDim2.fromScale(0.8, 0.2))
	ContextActionService:SetImage(INVENTORY_TOGGLE_ACTION_NAME, "rbxassetid://87408344164007")
end

function InventoryController:KnitInit() end

return InventoryController
