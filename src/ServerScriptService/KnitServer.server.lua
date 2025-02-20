-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
-- Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Initialize services
for _, service in (ServerStorage.Source.Services:GetDescendants()) do
    if service:IsA("ModuleScript") and service.Name:match(".+Service$") then
        require(service)
    end
end

Knit.Start():andThen(function()
    -- print("Knit server started")
end):catch(warn)

