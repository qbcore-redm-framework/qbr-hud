exports['qbr-core']:AddCommand('cash', 'Check Cash Balance', {}, false, function(source, args)
    local Player = exports['qbr-core']:GetPlayer(source)
    local cashamount = Player.PlayerData.money.cash
	TriggerClientEvent('hud:client:ShowAccounts', source, 'cash', cashamount)
end)

exports['qbr-core']:AddCommand('bank', 'Check Bank Balance', {}, false, function(source, args)
    local Player = exports['qbr-core']:GetPlayer(source)
    local bankamount = Player.PlayerData.money.bank
	TriggerClientEvent('hud:client:ShowAccounts', source, 'bank', bankamount)
end)

RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local Player = exports['qbr-core']:GetPlayer(src)
    if Player and Player.PlayerData.job.name ~= 'police' then
        if Player.PlayerData.metadata['stress'] == nil then
            Player.PlayerData.metadata['stress'] = 0
        end
        local newStress = Player.PlayerData.metadata['stress'] + amount
        if newStress <= 0 then newStress = 0 end
        if newStress > 100 then
            newStress = 100
        end
        Player.Functions.SetMetaData('stress', newStress)
        TriggerClientEvent('hud:client:UpdateStress', src, newStress)
        TriggerClientEvent('QBCore:Notify', src, 9, Lang:t("info.getstress"), 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
	end
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local src = source
    local Player = exports['qbr-core']:GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.metadata['stress'] == nil then
        Player.PlayerData.metadata['stress'] = 0
    end
    local newStress = Player.PlayerData.metadata['stress'] - amount
    if newStress <= 0 then newStress = 0 end
    if newStress > 100 then
        newStress = 100
    end
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('QBCore:Notify', src, 9, Lang:t("info.relaxing"), 5000, 0, 'hud_textures', 'check', 'COLOR_WHITE')
end)
