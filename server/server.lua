local QBCore = exports['qb-core']:GetCoreObject()


RegisterNetEvent("j4-washing:server:addDirtyClothes", function()

end)
RegisterNetEvent("j4-washing:server:giveItem", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local itemName = 'kirlicamasir'
        local amount = 1

       
        Player.Functions.AddItem(itemName, amount)

       
        TriggerClientEvent('notifications:sendNotification', src, '1', 
            'Başarıyla '..amount..' '..itemName..'(s) aldınız!', 5000)
    else
       
        TriggerClientEvent('notifications:sendNotification', src, '2', 
            'Item alma işlemi başarısız oldu!', 3000)
    end
end)



RegisterNetEvent("j4-washing:server:addDirtyClothes", function()
    local src = source
    TriggerClientEvent('j4-washing:client:startTrashScenario', src)
end)


local washingTimers = {} 


RegisterNetEvent('j4-washing:server:putClothes', function(machineEntity)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)


    if Player and Player.Functions.GetItemByName('kirlicamasir') then

        TriggerClientEvent('j4-washing:client:startClothes', src)


        if Player.Functions.RemoveItem('kirlicamasir', 1) then
            Citizen.Wait(3000)
            washingTimers[src] = true

            TriggerClientEvent('notifications:sendNotification', src, '3', "Çamaşırlar yıkanıyor...", 3000)


            SetTimeout(60000, function()
                if washingTimers[src] then
                    washingTimers[src] = false
                    TriggerClientEvent('j4-washing:client:notifyCleanReady', src, machineEntity)
                    TriggerClientEvent('notifications:sendNotification', src, '1', "Çamaşırlar yıkandı, makineden alabilirsiniz.", 5000)
                end
            end)
        end
    else
        TriggerClientEvent('notifications:sendNotification', src, '2', "Envanterinizde yeterli kirli çamaşır yok!", 3000)
    end
end)



RegisterNetEvent('j4-washing:server:getCleanClothes', function(machineEntity)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if washingTimers[src] == false then 
        washingTimers[src] = nil

        Player.Functions.AddItem('temizcamasir', 1) 
        
        TriggerClientEvent('notifications:sendNotification', src, '1', "Temiz çamaşırları aldınız!", 3000)
    else
        TriggerClientEvent('notifications:sendNotification', src, '2', "Henüz çamaşırlar yıkanmadı ya da makineye bir şey koymadınız!", 3000)
    end
end)
RegisterNetEvent('j4-washing:server:removeCleanClothes', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveItem('temizcamasir', 1) then
        TriggerClientEvent('QBCore:Notify', src, "Temiz çamaşır envanterden alındı.", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Temiz çamaşır bulunamadı!", "error")
    end
end)

QBCore.Functions.CreateCallback('j4-washing:server:checkCleanClothes', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local hasItem = Player.Functions.GetItemByName('temizcamasir')
    cb(hasItem ~= nil) 
end)


RegisterNetEvent('j4-washing:server:removeCleanClothes', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveItem('temizcamasir', 1) then
        TriggerClientEvent('QBCore:Notify', src, "Temiz çamaşır alındı.", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Temiz çamaşır bulunamadı!", "error")
    end
end)


RegisterNetEvent('j4-washing:server:kurutItem', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.AddItem('kuru_camasir', 1)
    TriggerClientEvent('QBCore:Notify', src, "Kuru çamaşır alındı.", "success")
end)


QBCore.Functions.CreateCallback('j4-washing:server:checkDryClothes', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local hasItem = Player.Functions.GetItemByName('kuru_camasir')


    cb(hasItem ~= nil and hasItem.amount > 0)
end)


RegisterNetEvent('j4-washing:server:removeDryClothes', function()
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.RemoveItem('kuru_camasir', 1)
end)

RegisterNetEvent('j4-washing:server:giveReadyClothes', function()
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.AddItem('bitti_camasir', 1)
end)