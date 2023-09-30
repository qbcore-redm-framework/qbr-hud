local speed = 0.0
local stress = 0
local hunger = 100
local thirst = 100
local cashAmount = 0
local bankAmount = 0
local pid = PlayerId()
local isLoggedIn = false
local sid = GetPlayerServerId(pid)
local QBConfig = exports["qbr-core"]:GetConfig()
----------------------------------------------------------------------------
---- FUNCTIONS
----------------------------------------------------------------------------

local function GetShakeIntensity(stresslevel)
    local retval = 0.05
    for k, v in pairs(Config.Intensity['shake']) do
        if stresslevel >= v.min and stresslevel <= v.max then
            retval = v.intensity
            break
        end
    end
    return retval
end

local function GetEffectInterval(stresslevel)
    local retval = 60000
    for k, v in pairs(Config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            retval = v.timeout
            break
        end
    end
    return retval
end

----------------------------------------------------------------------------
---- EVENTS & HANDLERS
----------------------------------------------------------------------------

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(sid), function(_, _, value)
    isLoggedIn = value
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst) -- Triggered in qbr-core
    hunger, thirst = newHunger, newThirst
end)

RegisterNetEvent('hud:client:UpdateThirst', function(newThirst) -- Triggered in qbr-core
    thirst = newThirst
end)

RegisterNetEvent('hud:client:UpdateStress', function(newStress) -- Add this event with adding stress elsewhere
    stress = newStress
end)

-- Money HUD

RegisterNetEvent('hud:client:ShowAccounts', function(type, amount)
    if type == 'cash' then
        SendNUIMessage({action = 'show', type = 'cash', cash = amount})
    else
        SendNUIMessage({action = 'show', type = 'bank', bank = amount})
    end
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isMinus)
    exports['qbr-core']:GetPlayerData(function(PlayerData)
        cashAmount = PlayerData.money['cash']
        bankAmount = PlayerData.money['bank']
    end)
    SendNUIMessage({
        action = 'update',
        cash = cashAmount,
        bank = bankAmount,
        amount = amount,
        minus = isMinus,
        type = type,
    })
end)

----------------------------------------------------------------------------
---- THREADS
----------------------------------------------------------------------------

-- Player HUD
CreateThread(function()
    while true do
        Wait(500)
        if isLoggedIn then
            local show = true
            local player = PlayerPedId()
            if IsPauseMenuActive() then
                show = false
            end
            if QBConfig.Hud.HidePlayersCore then -- ICON_STAMINA, ICON_DEADEYE, ICON_HEALTH disabled. Then we can add custom stamina and health icon status
                SendNUIMessage({
                    action = 'hudtick',
                    show = show,
                    health = GetEntityHealth(player) / 3, -- health in red dead is 300 so dividing by 3 makes it 100 here
                    armor = Citizen.InvokeNative(0x2CE311A7, player),
                    thirst = thirst,
                    hunger = hunger,
                    stress = stress,
                    voice = Citizen.InvokeNative(0x33EEF97F, pid)
                })
            else
                SendNUIMessage({
                    action = 'hudtick',
                    show = show,
                    armor = Citizen.InvokeNative(0x2CE311A7, player),
                    thirst = thirst,
                    hunger = hunger,
                    stress = stress,
                    voice = Citizen.InvokeNative(0x33EEF97F, pid)
                })
            end
        else
            SendNUIMessage({action = 'hudtick', show = false})
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1)
        if IsPedOnMount(PlayerPedId()) or IsPedOnVehicle(PlayerPedId()) then
            if Config.MounttMinimap then
                if Config.MountCompass then
                    SetMinimapType(3)
                else
                    SetMinimapType(1)
                end
            else
                SetMinimapType(0)
            end
        else
            if not Config.OnFootMinimap then
              SetMinimapType(0)
              Wait(2000)
            else
                if Config.OnFootCompass then
                    SetMinimapType(3)
                else
                    SetMinimapType(1)
                end
            end
        end
    end
end)

-- Stress Gain

CreateThread(function() -- Speeding
    while true do
        if isLoggedIn then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                speed = GetEntitySpeed(GetVehiclePedIsIn(ped, false)) * 2.237 --mph
                if speed >= Config.MinimumSpeed then
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                end
            end
        end
        Wait(20000)
    end
end)

CreateThread(function() -- Shooting
    while true do
        if isLoggedIn then
            if IsPedShooting(PlayerPedId()) then
                if math.random() < Config.StressChance then
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                end
            end
        end
        Wait(6)
    end
end)

-- Stress Screen Effects

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local interval = GetEffectInterval(stress)
        if stress >= 100 then
            local ShakeIntensity = GetShakeIntensity(stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = (FallRepeat * 1750)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 500, 3000, 500)

            if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                SetPedToRagdollWithFall(ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end

            Wait(500)
            for i = 1, FallRepeat, 1 do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
                SetFlash(0, 0, 200, 750, 200)
            end
        elseif stress >= Config.MinimumStress then
            local ShakeIntensity = GetShakeIntensity(stress)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 500, 2500, 500)
        end
        Wait(interval)
    end
end)
