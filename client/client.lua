------------                                        ------------
------------ THIS SCRIPT IS CREATED BY HLIB LGHOULA ------------
------------                                        ------------

frameworkObject = nil

Citizen.CreateThread(function()
    frameworkObject = GetFramework()
end)

local haswheel = false

function hasitem(itemname)
    local hastheitem = false
    if Config.Framework == "newesx" or Config.Framework == "oldesx" then --esx
        frameworkObject.TriggerServerCallback("hg-wheel:server:hasitemesx", function(hasitem)
            hastheitem = hasitem
        end, itemname)     
    elseif Config.Framework == "newqb" or Config.Framework == "oldqb" then --qb
        hastheitem = frameworkObject.Functions.HasItem(itemname)
    end
    Wait(500)
    return hastheitem
end

function stealwheel()
    local hasitem = hasitem(Config.WheelItem)
    if not hasitem then
        removeClosestWheel()
    else
        Config.Notification(Config.notif1, "error")	
    end
end

RegisterNetEvent('hg-wheel:client:stealwheel')
AddEventHandler('hg-wheel:client:stealwheel', function()
    stealwheel()
end)


function getclosestvehicle()
    if Config.Framework == "newesx" or Config.Framework == "oldesx" then --esx
        return frameworkObject.Game.GetClosestVehicle()
    else --qb
        return frameworkObject.Functions.GetClosestVehicle()
    end
end

function startstealing(closestVehicle, closestWheelIndex)
    if Config.Framework == "newesx" or Config.Framework == "oldesx" then --esx
        exports["esx_progressbar"]:Progressbar("Stealing Wheel", Config.WheelDuration,{
            FreezePlayer = true, 
            animation ={
                type = "anim",
                dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", 
                lib ="machinic_loop_mechandplayer"
            },
            onFinish = function()
                Config.Notification(Config.notif2, "success")
                takeoffwheel(closestVehicle, closestWheelIndex)
                if Config.RequiredItem then
                TriggerServerEvent("hg-wheel:server:removeitem", Config.RequiredItem) -- remove item
                end
                TriggerServerEvent("hg-wheel:server:giveitem", Config.WheelItem) -- give wheel
                if Config.CreateWheelProp then
                    haswheel = true
                    takewheel()	
                end
        end})
    else --qb
        frameworkObject.Functions.Progressbar("repair_vehicle", "Stealing Wheel", Config.WheelDuration, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 01,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            Config.Notification(Config.notif2, "success")
            takeoffwheel(closestVehicle, closestWheelIndex)
            if Config.RequiredItem then
            TriggerServerEvent("hg-wheel:server:removeitem", Config.RequiredItem) -- remove item
            end
            TriggerServerEvent("hg-wheel:server:giveitem", Config.WheelItem) -- give wheel
            if Config.CreateWheelProp then
                haswheel = true
                takewheel()	
            end
        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            Config.Notification(Config.notif3, "error")								
        end)
    end
end

-- Function to remove the closest wheel
function removeClosestWheel()
    local closestVehicle = getclosestvehicle()
    if closestVehicle then
        local playerCoords = GetEntityCoords(PlayerPedId(), false)
        local wheelIndices = {0, 1, 2, 3}
        local closestWheelIndex = -1
        local closestDistance = Config.WheelDistance -- max close distance
        local playerPed = PlayerPedId()
        for _, wheelIndex in ipairs(wheelIndices) do
            local wheelBoneNames = {"wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"}
            local wheelBone = wheelBoneNames[wheelIndex + 1] -- Adjust the index
            local wheelBoneIndex = GetEntityBoneIndexByName(closestVehicle, wheelBone)
            if wheelBoneIndex ~= -1 then
                local wheelCoords = GetWorldPositionOfEntityBone(closestVehicle, wheelBoneIndex)
                local distance = #(wheelCoords - playerCoords)
                if distance < closestDistance then
                    closestDistance = distance
                    closestWheelIndex = wheelIndex
                end
            end
        end
        if closestWheelIndex ~= -1 then
                if Config.Minigame() then
                    startstealing(closestVehicle, closestWheelIndex)
                else
                    Config.Notification(Config.notif3, "error")
                end
        else
            Config.Notification(Config.notif4, "error")
        end
    else
        Config.Notification(Config.notif5, "error")
    end
end


-- take off the wheel 
function takeoffwheel(closestVehicle, closestWheelIndex)
    BreakOffVehicleWheel(closestVehicle, closestWheelIndex, true, true, true, false)
    ApplyForceToEntity(closestVehicle, 0, 0, 100.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, true, true, true, true)
    -- i put this to apply physics to the vehicle
end

-- animation for holding the wheel
function holdwheel()
    local playerPed = PlayerPedId()
    if not IsEntityPlayingAnim(playerPed, "anim@heists@box_carry@", "idle", 3) then
        local animDict = "anim@heists@box_carry@"
        local animName = "idle"
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(500)
        end
        TaskPlayAnim(playerPed, animDict, animName, 8.0, 1.0, -1, 49, 0, false, false, false)
    end
end

-- fix wheel in player hand as long as he has the item
function takewheel()
    local playerPed = PlayerPedId()
    local wheelModel = "prop_wheel_01"
    local wheelProp = CreateObject(GetHashKey(wheelModel), 0.0, 0.0, 0.0, true, true, true)
    AttachEntityToEntity(wheelProp, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    Wait(500)
    while haswheel do
        holdwheel()
        haswheel = hasitem(Config.WheelItem)
        Wait(500)   
        if not haswheel then
            ClearPedTasks(playerPed)
            DeleteEntity(wheelProp)
        end    
    end 
end


-- exports
exports('StealWheel', function()
    stealwheel()
end)



