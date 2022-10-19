local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("rst-starterpack:server:claimStarterpack")
AddEventHandler("rst-starterpack:server:claimStarterpack", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    for k, v in pairs(Config.Items) do
        Player.Functions.AddItem(v.itemName, v.qty)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[v.itemName], "add")
    end

    GiveVehicle(src, Config.Vehicle)
end)


function GiveVehicle(source, vehicle)
    local src = source
    local vehicle = vehicle
    local pData = QBCore.Functions.GetPlayer(src)
    local cid = pData.PlayerData.citizenid
    local plate = GeneratePlate()

    MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        pData.PlayerData.license,
        cid,
        vehicle,
        GetHashKey(vehicle),
        '{}',
        plate,
        1,
        Config.DefaultGarage
    })
    TriggerClientEvent('QBCore:Notify', src, 'Congratulations on your Starterpack Vehicle Please Check on your Phone Garages!', 'success')
    pData.Functions.SetMetaData("starterpack", true)
end

function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

QBCore.Commands.Add("setstarterpack", "Set Starterpack METADATA", {{name = "citizen_id", help = "CITIZEN ID, Check on DATABASE"}, {name = 'status', help = 'true or false'}}, false, function(source, args)
	local src = source
	if args[1] then
		local Player = QBCore.Functions.GetPlayerByCitizenId(args[1])
		if Player then
            if args[2] then
                local status = nil
                if args[2] == 'true' then
                    status = true
                else
                    status = false
                end

                Player.Functions.SetMetaData("starterpack", status)
                TriggerClientEvent('QBCore:Notify', src, "Starterpack Metadata Has Been Set", "primary")
            else
                TriggerClientEvent('QBCore:Notify', src, "Please Provide Status true or false", "error")
            end
		else
			-- TriggerClientEvent('QBCore:Notify', src, "Citizen Is not Online Right Now/Not Exist, Trying To Update in Database", "primary")
            local result = MySQL.Sync.fetchScalar('SELECT metadata FROM players WHERE citizenid = ?', {args[1]})
            if result then
                local status = nil
                
                if args[2] then
                    if args[2] == 'true' then
                        status = true
                    else
                        status = false
                    end

                    local metadata = json.decode(result)
                    print("metadata", metadata['starterpack'])
    
                    metadata['starterpack'] = status
                    
                    print("metadata after", metadata['starterpack'])
                    MySQL.Async.execute('UPDATE players SET metadata = ? WHERE citizenid = ?', { json.encode(metadata), args[1] })
                    TriggerClientEvent('QBCore:Notify', src, "Starterpack Metadata Has Been Set", "primary")
                else
                    TriggerClientEvent('QBCore:Notify', src, "Please Provide Status true or false", "error")
                end
            else
                TriggerClientEvent('QBCore:Notify', src, "Citizen ID Not Found", "error")
            end
		end
	else
        TriggerClientEvent('QBCore:Notify', src, "Please Provide Citizen ID", "error")
	end
end, "admin")

QBCore.Commands.Add("checkstarterpack", "Check Starterpack METADATA", {{name = "citizen_id", help = "CITIZEN ID, Check on DATABASE"}}, false, function(source, args)
	local src = source
	if args[1] then
		local Player = QBCore.Functions.GetPlayerByCitizenId(args[1])
		if Player then
            local status = nil
            if Player.PlayerData.metadata['starterpack'] then
                status = 'true'
            else
                status = 'false'
            end
            TriggerClientEvent('QBCore:Notify', src, "Starterpack Claim Status for " .. Player.PlayerData.name .. " is " .. status, "primary")
		else
            -- TriggerClientEvent('QBCore:Notify', src, "Citizen Is not Online Right Now/Not Exist, Trying To Search in Database", "primary")
            local result = MySQL.Sync.fetchScalar('SELECT metadata FROM players WHERE citizenid = ?', {args[1]})
            if result then
                local status = nil
                
                local metadata = json.decode(result)
                if metadata['starterpack'] then
                    status = 'true'
                else
                    status = 'false'
                end
                TriggerClientEvent('QBCore:Notify', src, "Starterpack Claim Status is " .. status, "primary")
            else
                TriggerClientEvent('QBCore:Notify', src, "Citizen ID Not Found", "error")
            end
		end
	else
        TriggerClientEvent('QBCore:Notify', src, "Please Provide Citizen ID", "error")
	end
end, "admin")