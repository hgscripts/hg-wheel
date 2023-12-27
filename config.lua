------------                                        ------------
------------ THIS SCRIPT IS CREATED BY HLIB LGHOULA ------------
------------                                        ------------

Config = {}
Config.Framework = "newqb" -- "newesx" || "oldesx" || "newqb" || "oldqb" 
Config.WheelItem = "wheel" -- wheel item
Config.RequiredItem = "torque_wrench" -- or false for no required item
Config.WheelDistance = 1.0 -- max distance between closest wheel and player
Config.CreateWheelProp = true -- enable wheel prop
Config.WheelDuration = math.random(5000, 10000) -- wheel removal duration in ms

Config.Notification = function(message, type) -- You can change here events for notifications
    if Config.Framework == "newesx" or Config.Framework == "oldesx" then
        TriggerEvent("esx:showNotification", message)
    elseif Config.Framework == "newqb" or Config.Framework == "oldqb"  then
        TriggerEvent('QBCore:Notify', message, type, 1500)
    elseif Config.Framework == "custom" then
        -- put your notification event here
        -- or use gta default
        SetNotificationTextEntry("STRING")
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
end

Config.Minigame = function() -- minigame, used this https://github.com/Project-Sloth/ps-ui
    local won
    exports['ps-ui']:Circle(function(success)
        won = success
    end, 5, 10)
    return won
end

-- notifications
Config.notif1 = "You already have a tyre in hand"
Config.notif2 = "Wheel Removed"
Config.notif3 = "Failed!"
Config.notif4 = "No wheel nearby!"
Config.notif5 = "No vehicles nearby!"
