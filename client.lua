-- spawn game 2711.17, 4146.91, 43.79
-- spawn bots = 2707.20, 4164.96, 42.90
-- NEW
-- spawn game 1563.8, 3571.01, 33.89

function initScript()
    isDisplayActive = false
    isHealActive = false
    idMarker = nil
    posMarker = {
        [1] = vector3(1575.28, 3592.56, 35.36),
        [2] = vector3(1535.85, 3571.93, 35.36),
        [3] = vector3(1561.98, 3595.39, 38.73),
        [4] = vector3(1597.91, 3603.08, 35.42),
        [5] = vector3(1594.02, 3563.07, 35.36),
        [6] = vector3(1583.76, 3624.64, 38.73)
    }
    colorMark = {}

    for i = 1, #posMarker do
        -- colorMark[i] = vector3(0, 255, 0)
        displayItems(1, i)
    end

    SetMaxWantedLevel(0)
    
    displayHealth()
    displayOverHead()
    healPack()
    print("Initialisation du script OK")
end

function tpjeux()
    local ped = PlayerPedId()
    local dest = vector3(1563.8, 3571.01, 33.89)
    SetEntityCoords(ped, dest, false, false, false, false)
end


function sendNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(true, false)
end

function givePistolPlayer()
    local ped = PlayerPedId()
    local weapon = "WEAPON_ASSAULTRIFLE"
    local weaponHash = GetHashKey(weapon)
    GiveWeaponToPed(ped, weaponHash, 150, false, true)
    --SetEntityMaxHealth(ped, 300)
    SetPedMaxHealth(ped, 300)
    SetEntityHealth(ped, 300) --Min : 100 / Max : 150
    SetPedArmour(ped, 100)
end

function givePistolBots()
    local weapon = "WEAPON_ASSAULTRIFLE"
    local weaponHash = GetHashKey(weapon)
    for i = 1, #bot do
        GiveWeaponToPed(bot[i], weaponHash, 500, false, true)
    end
end

function engageCombat()
    for i = 1, #bot do
        TaskCombatPed(bot[i], bot[i + 1], 0, 16)
    end
    TaskCombatPed(bot[#bot], bot[1], 0, 16)
end

function deleteBots()
    for i = 1, #bot do
        DeletePed(bot[i])
    end
end

function spawnBots()
    local ped = PlayerPedId()
    local direction = GetEntityHeading(ped)

    local pedName = "mp_f_stripperlite"
    local pedHash = GetHashKey(pedName)

    local posBot = {
       [1] = vector3(1573.38, 3599.94, 35.37),
       [2] = vector3(1594.56, 3575.59, 35.38),
       [3] = vector3(1571.43, 3616.68, 38.73),
       [4] = vector3(1557.02, 3599.21, 38.78),
       [5] = vector3(1510.21, 3566.60, 38.73),
       [6] = vector3(1537.64, 3589.48, 42.12),
       [7] = vector3(1607.48, 3569.13, 42.12),
       [8] = vector3(1570.37, 3555.29, 35.39)
    }

    bot = {}

    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(100)
    end

    for i = 1, #posBot do
        bot[i] = CreatePed(5, pedHash, posBot[i], direction, false, false)
    end

    Citizen.Wait(50)
    for i = 1, #bot do
        Citizen.Wait(1)
        SetPedMaxHealth(bot[i], 300)
        SetEntityHealth(bot[i], 300)
    end
    displayOverHeadBots()

end

function displayHealth()
local ped = PlayerPedId()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1)
            local playerHealth = GetEntityHealth(ped)
            local maxPlayerHealth = GetEntityMaxHealth(ped)
            local playerShield = GetPedArmour(ped)
            SetTextColour(255, 255, 255, 255)
            SetTextFont(4)
            SetTextScale(0.6, 0.6)
            SetTextWrap(0.0, 1.0)
            SetTextCentre(false)
            SetTextDropshadow(2, 2, 0, 0, 0)
            SetTextEdge(1, 0, 0, 0, 205)
            SetTextEntry("STRING")
            AddTextComponentString("~g~"..playerHealth.."/"..maxPlayerHealth.." HP  ~b~"..playerShield.." Shield")
            DrawText(0.46, 0.96)
        end
    end)
end

function displayOverHeadBots()
    for i = 1, #bot do
        local botTag = CreateFakeMpGamerTag(bot[i], "Bot "..i)
        SetMpGamerTagVisibility(botTag, 2, 1)
        SetMpGamerTagAlpha(botTag, 2, 255)
        SetMpGamerTagColour(botTag, 0, 6)
    end
end


function displayOverHead()
    local ped = PlayerPedId()
    local IdJoueur = PlayerId()
    local pseudo = GetPlayerName(IdJoueur)
    local playerTag = CreateFakeMpGamerTag(ped, pseudo, pointedClanTag, isRockstarClan, clanTag, clanFlag)
    SetMpGamerTagVisibility(playerTag, 2, 1)
    SetMpGamerTagAlpha(playerTag, 2, 255)
    --SetMpGamerTagHealthBarColour(playerTag, 18)
end

function displayItems(colorChoice, idMarker)
    local dirMark = vector3(0.0, 0.0, 0.0)
    local rotMark = vector3(0.0, 0.0, 0.0)
    local scaleMark = vector3(1.0, 1.0, 1.0) 
    local alphaMark = 192

    local ped = PlayerPedId()
    local direction = GetEntityHeading(ped)

    local possibleColor = {
        [1] = vector3(0, 255, 0), -- Vert
        [2] = vector3(255, 0, 0) -- Rouge
    }


    if colorChoice == 1 then
        colorMark[idMarker] = possibleColor[1]
    elseif colorChoice == 2 then
        colorMark[idMarker] = possibleColor[2]
    end

    if isDisplayActive == false then
        isDisplayActive = true
        local nbMarker = nil
        for nbMarker = 1, #posMarker do
            print("Affichage marker : ", nbMarker)
            Citizen.CreateThread(function() 
                while isDisplayActive do
                    Citizen.Wait(1)
                    DrawMarker(20, posMarker[nbMarker], dirMark, rotMark, scaleMark, colorMark[nbMarker], alphaMark, false, true, 2, nil, nil, false)
                end
            end)
        end
    end
end

function healPack()
    local ped = PlayerPedId()
    posHeal = posMarker
    if isHealActive == false then
        isHealActive = true
        local nbHeal = nil
        for nbHeal = 1, #posHeal do
           print("Détection heal : ", nbHeal)
           Citizen.CreateThread(function()
                local interval = 1000
                local idHeal = nbHeal
                while true do
                    Citizen.Wait(interval)
                    local posJoueur = GetEntityCoords(ped, false)
                    distPlayerHeal = GetDistanceBetweenCoords(posJoueur, posHeal[idHeal], true)
                    displayItems(1, idHeal)
                    if distPlayerHeal < 5 then
                        interval = 10
                        if distPlayerHeal < 1 then
                            displayItems(2, idHeal)
                            print("Heal OK")
                            local playerHealthNow = GetEntityHealth(ped)
                            local playerHealthNow = playerHealthNow + 50
                            SetEntityHealth(ped, playerHealthNow) --Min : 100 / Max : 150
                            Citizen.Wait(15000)
                        end
                    else
                        interval = 1000
                    end
                end
            end)
        end
    end
end


RegisterCommand("tpgame", function(source, args, rawcommand)
    tpjeux()
    sendNotification("Téléportation au jeu ~g~OK")
end, false)

RegisterCommand("arme", function(source, args, rawcommand)
    givePistolPlayer()
    sendNotification("Give arme & 100% shield ~g~OK")
end, false)

RegisterCommand("bot", function(source, args, rawcommand)
    spawnBots()
    givePistolBots()
    sendNotification("Spawn bots & give arme bots ~g~OK")
end, false)

RegisterCommand("debut", function(source, args, rawcommand)
    sendNotification("Début du combat dans ~g~3 SEC")
    Citizen.Wait(3000)
    engageCombat()
end, false)

RegisterCommand("fin", function(source, args, rawcommand)
    deleteBots()
    sendNotification("Fin & Delete bots ~g~OK")
end, false)

RegisterCommand("dega", function(source, args, rawcommand)
    local joueur = PlayerPedId()
    SetEntityHealth(joueur, 100) 
end, false)

--[[
Citizen.CreateThread(function()
    
end)
]]

initScript()

