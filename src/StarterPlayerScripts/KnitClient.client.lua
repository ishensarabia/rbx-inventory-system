local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Knit = require(ReplicatedStorage.Packages.Knit)


for _, controller in (StarterPlayerScripts:GetDescendants()) do
    if controller:IsA("ModuleScript") and controller.Name:match(".+Controller$") then
        require(controller)
    end
end


Knit.Start():andThen(function()
    -- print("Knit client started")
end):catch(warn)