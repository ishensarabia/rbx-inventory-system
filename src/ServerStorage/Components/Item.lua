-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
-- Knit 
local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
-- ItemEnum module
local ItemEnum = require(ReplicatedStorage.Source.Enums.ItemsEnum) 

local Item = Component.new({
    Tag = "Item",
})

function Item:Construct()
    self.GUID = HttpService:GenerateGUID(false)
    self.ItemID = self.Instance:GetAttribute("ItemID") or 1
    self.Name = ItemEnum[self.ItemID].Name
    self.Description = ItemEnum[self.ItemID].Description
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
        print(player.Name .. " picked up " .. self.Name)
        Knit.GetService("InventoryService"):AddItem(player, {
            GUID = self.GUID,
            ItemID = self.ItemID,
        })
        self:Stop()
    end)
end

function Item:Stop()
    print("Item stopped")
    self._trove:Remove(self.Instance)
    self._trove:Destroy()
end

return Item