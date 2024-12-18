local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('j4-washing:client:startTrashScenario', function()
    local ped = PlayerPedId()

    -- Çöp karıştırma senaryosunu başlat
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)

    -- Progress bar oluşturma
    QBCore.Functions.Progressbar("washing_clothes", "Kirli Çamaşırlar Toplanıyor.", 30000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- İşlem tamamlandığında
        ClearPedTasks(ped) -- Animasyonu durdur
        TriggerServerEvent("j4-washing:server:giveItem") -- Server eventini tetikle
    end, function() -- İşlem iptal edildiğinde
        ClearPedTasks(ped) -- Animasyonu durdur
        TriggerEvent('notifications:sendNotification', '2', "İşlem iptal edildi!", 3000)
    end)
end)

RegisterNetEvent('j4-washing:client:startClothes', function()
    local playerPed = PlayerPedId()
    
    -- Çöp karıştırma senaryosunu başlat
    TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)

    -- 30 saniyelik animasyon süresi
    QBCore.Functions.Progressbar("makineye_doldur", "Çamaşırlar Makineye Dolduruluyor.", 30000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Tamamlandığında
        ClearPedTasks(playerPed) -- Animasyonu durdur
    end)
end)

RegisterNetEvent('j4-washing:client:startkurutma', function()
    local ped = PlayerPedId()

    -- Envanterde item kontrolü ve animasyon başlatma
    QBCore.Functions.TriggerCallback('j4-washing:server:checkCleanClothes', function(hasItem)
        if hasItem then
            -- Temiz çamaşırı envanterden kaldırma
            TriggerServerEvent('j4-washing:server:removeCleanClothes')
            Citizen.Wait(3000)

            -- Animasyonu başlat
            TriggerEvent('animations:client:EmoteCommandStart', {"elmatopla"})

            -- Progress bar oluşturma
            QBCore.Functions.Progressbar("washing_clothes", "Temiz Çamaşırlar Asılıyor...", 30000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- İşlem tamamlandığında
                ClearPedTasks(ped) -- Animasyonu durdur
                TriggerServerEvent("j4-washing:server:kurutItem") -- Kuru çamaşır verme işlemi
            end, function() -- İşlem iptal edildiğinde
                ClearPedTasks(ped) -- Animasyonu durdur
                TriggerEvent('notifications:sendNotification', '2', "İşlem iptal edildi!", 3000)
            end)
        else
            -- Kullanıcıya uyarı mesajı
            TriggerEvent('notifications:sendNotification', '2', "Temiz çamaşır bulunamadı!", 3000)
        end
    end)
end)

RegisterNetEvent("j4-washing:client:al", function()
    TriggerServerEvent("j4-washing:server:addDirtyClothes")
end)

RegisterNetEvent("j4-washing:client:alTemizCamasir", function()
    TriggerServerEvent("j4-washing:server:takeCleanClothes")
end)

RegisterNetEvent('j4-washing:client:startIroning', function()
    local ped = PlayerPedId()

    -- Envanterde kuru çamaşır kontrolü
    QBCore.Functions.TriggerCallback('j4-washing:server:checkDryClothes', function(hasItem)
        if hasItem then
            -- Kuru çamaşır itemini silme
            TriggerServerEvent('j4-washing:server:removeDryClothes')

            -- 2 saniye bekleme
            Wait(2000)

            -- Karakterin eline ütü propu ekleme
            --local ironProp = CreateObject(GetHashKey('prop_iron_01'), 0, 0, 0, true, true, false)
            --AttachEntityToEntity(ironProp, ped, GetPedBoneIndex(ped, 28422), 0.1, 0.0, 0.0, 90.0, 270.0, 180.0, true, true, false, true, 1, true)
 
            -- Ütü yapma animasyonu başlatma
            TriggerEvent('animations:client:EmoteCommandStart', {"ironing"})

            -- Progress bar oluşturma
            QBCore.Functions.Progressbar("ironing_clothes", "Ütü Yapılıyor...", 20000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- İşlem tamamlandığında
                ClearPedTasks(ped) -- Animasyonu durdur
                DeleteObject(ironProp) -- Prop'u sil

                -- Hazır çamaşır verme işlemi
                TriggerServerEvent('j4-washing:server:giveReadyClothes')
            end, function() -- İşlem iptal edildiğinde
                ClearPedTasks(ped) -- Animasyonu durdur
                DeleteObject(ironProp) -- Prop'u sil
                TriggerEvent('notifications:sendNotification', '2', "İşlem iptal edildi!", 3000)
            end)
        else
            -- Kullanıcıya uyarı mesajı
            TriggerEvent('notifications:sendNotification', '2', "Kuru çamaşır bulunamadı!", 3000)
        end
    end)
end)

-- Makineye hedef belirleme (target kullanımı)
exports['qb-target']:AddTargetModel(2076733045, { -- Wending Machine hash kodu
    options = {
        {
            type = "server",
            event = "j4-washing:server:putClothes", -- Server-side event
            icon = "fas fa-tshirt",
            label = "Çamaşırları Ver",
        },
        {
            type = "server",
            event = "j4-washing:server:getCleanClothes", -- Server-side event
            icon = "fas fa-tshirt",
            label = "Temiz Çamaşırları Al",
        }
    },
    distance = 2.5
})

exports['qb-target']:AddBoxZone("kirlicamasirzone", vector3(1765.31, 2612.55, 50.55), 2.45, 6.35, {
	name = "kirlicamasirzone",
	heading = 20.0,
	debugPoly = false,
	minZ = 45.77834,
	maxZ = 55.87834,
}, {
	options = {
        {
            type = "server",
            event = "j4-washing:server:addDirtyClothes", -- Server-side event
            icon = "fas fa-tshirt",
            label = "Kirli Çamaşırları Al",
        },
	},
	distance = 2.5
})

exports['qb-target']:AddBoxZone("camasirlarias", vector3(1776.42, 2614.53, 50.55), 2.45, 3.35, {
	name = "camasirlarias",
	heading = 20.0,
	debugPoly = false,
	minZ = 45.77834,
	maxZ = 55.87834,
}, {
	options = {
        {
            type = "client",
            event = "j4-washing:client:startkurutma", -- Server-side event
            icon = "fas fa-tshirt",
            label = "Temiz Çamaşırları As",
        },
	},
	distance = 2.5
})

exports['qb-target']:AddTargetModel(913235136, { -- Hashli model
    options = {
        {
            type = "client",
            event = "j4-washing:client:startIroning", -- Ütü yapma event'i
            icon = "fas fa-tshirt",
            label = "Ütü Yap",
        }
    },
    distance = 2.0
})

RegisterCommand('testprop', function()
    local ped = PlayerPedId()
    local prop = CreateObject(GetHashKey("prop_iron_01"), 0, 0, 0, true, true, false)

    AttachEntityToEntity(
        prop, 
        ped, 
        GetPedBoneIndex(ped, 28422), -- El kemiği
        0.1, 0.0, 0.0, -- X, Y, Z pozisyonları (burayı dene)
        90.0, 270.0, 180.0, -- Rotasyon açıları (burayı da dene)
        true, true, false, true, 1, true
    )

    -- Prop'u silmek için: /removeprop
    TriggerEvent('chat:addMessage', { 
        args = { '^2Test: ', 'Prop başarıyla eklendi. Ayarları düzenle!' } 
    })
end)

RegisterCommand('removeprop', function()
    local ped = PlayerPedId()
    DeleteEntity(GetClosestObjectOfType(GetEntityCoords(ped), 5.0, GetHashKey("prop_iron_01"), false, false, false))
    TriggerEvent('chat:addMessage', { args = { '^1Prop: ', 'Silindi.' } })
end)




