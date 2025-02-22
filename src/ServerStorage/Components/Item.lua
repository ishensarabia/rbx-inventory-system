-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
-- Knit
local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
-- ItemEnum module
local ItemsEnum = require(ReplicatedStorage.Source.Enums.ItemsEnum)

local Item = Component.new({
	Tag = "Item",
})

function Item:Construct()
	assert(self.Instance:IsA("Model"), "Item component must be a model")
	assert(self.Instance.PrimaryPart, "Item model must have a primary part")
	assert(self.Instance:GetAttribute("ItemID"), "Item model must have an ItemID attribute")

	self.ItemID = self.Instance:GetAttribute("ItemID")
	assert(ItemsEnum[self.ItemID], string.format("ItemID %d does not exist in ItemsEnum", self.ItemID))

	self.GUID = HttpService:GenerateGUID(false)
	self.Name = ItemsEnum[self.ItemID].Name
	self.Description = ItemsEnum[self.ItemID].Description
	self._trove = Trove.new()
	self._trove:Add(self.Instance)
end

function Item:Start()
	-- Create proximity prompt to pick up item
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Parent = self.Instance.PrimaryPart
	proximityPrompt.ActionText = "Pick up"
	proximityPrompt.ObjectText = self.Name
	proximityPrompt.Triggered:Connect(function(player)
		Knit.GetService("InventoryService"):AddItem(player, {
			GUID = self.GUID,
			ItemID = self.ItemID,
		})
		self:Stop()
	end)
end

function Item:Stop()
	self._trove:Remove(self.Instance)
	self._trove:Destroy()
end

return Item
