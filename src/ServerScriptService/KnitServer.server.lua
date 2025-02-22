-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
-- Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Initialize services & components
for _, service in (ServerStorage.Source.Services:GetDescendants()) do
	if service:IsA("ModuleScript") and service.Name:match(".+Service$") then
		require(service)
	end
end

for _, component in (ServerStorage.Source.Components:GetDescendants()) do
	if component:IsA("ModuleScript") then
		require(component)
	end
end

Knit.Start():andThen(function() end):catch(warn)
