------------                                        ------------
------------ THIS SCRIPT IS CREATED BY HLIB LGHOULA ------------
------------                                        ------------

frameworkObject = GetFramework()

function removeitem(src, itemname)
    if Config.Framework == "newesx" or Config.Framework == "oldesx" then --esx
        local xPlayer = frameworkObject.GetPlayerFromId(src)
        xPlayer.removeInventoryItem(itemname, 1)
    else --qb
        local Player = frameworkObject.Functions.GetPlayer(src)
        Player.Functions.RemoveItem(itemname, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, frameworkObject.Shared.Items[itemname], "remove")
    end
end

function giveitem(src, itemname)
    if Config.Framework == "newesx" or Config.Framework == "oldesx" then --esx
        local xPlayer = frameworkObject.GetPlayerFromId(src)
        xPlayer.addInventoryItem(itemname, 1)
    else --qb
        local Player = frameworkObject.Functions.GetPlayer(src)
        Player.Functions.AddItem(itemname, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, frameworkObject.Shared.Items[itemname], 'add') 
    end
end

RegisterNetEvent('hg-wheel:server:giveitem')
AddEventHandler('hg-wheel:server:giveitem', function(itemname)
    local src = source
    giveitem(src, itemname)
end)

RegisterNetEvent('hg-wheel:server:removeitem')
AddEventHandler('hg-wheel:server:removeitem', function(itemname)
    local src = source
    removeitem(src, itemname)
end)

if Config.Framework == "newesx" or Config.Framework == "oldesx" then --esx
    frameworkObject.RegisterUsableItem(Config.RequiredItem, function(source)
        TriggerClientEvent("hg-wheel:client:stealwheel", source)
    end)
    frameworkObject.RegisterServerCallback('hg-wheel:server:hasitemesx', function(source, cb, itemName)
        local xPlayer = frameworkObject.GetPlayerFromId(source)
        cb(xPlayer.getInventoryItem(itemName).count > 0)
    end)
else --qb
    frameworkObject.Functions.CreateUseableItem(Config.RequiredItem, function(source)
        TriggerClientEvent("hg-wheel:client:stealwheel", source)    
    end)
end



