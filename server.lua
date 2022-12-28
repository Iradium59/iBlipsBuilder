ESX, players, items = nil, {}, {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('iBlipsBuilder:getPlayerGroup', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local group = xPlayer.getGroup()
    cb(group)
end)


ESX.RegisterServerCallback('iBlipsBuilder:getAllBlips', function(source, cb)
	local allBlips = {}
	MySQL.Async.fetchAll("SELECT * FROM blipsbuilder", {}, function(data)
        for i = 1, #data, 1 do
			table.insert(allBlips, {
                id = data[i].id,
				label = data[i].label,
				coord = data[i].coord,
				type = data[i].type,
                color = data[i].color,
			})
        end
        cb(allBlips)
    end)
end)

RegisterServerEvent('iBlipsBuilder:addBlips')
AddEventHandler('iBlipsBuilder:addBlips', function(iBlips)
    local _src = source
    MySQL.Async.execute('INSERT INTO blipsbuilder (label, coord, type, color) VALUES (@label, @coord, @type, @color)',{
        ['@label'] = iBlips.label,
        ['@coord'] = json.encode(iBlips.coord),
        ['@type'] = iBlips.type,
        ['@color'] = iBlips.color
    })
    TriggerClientEvent('esx:showNotification', _src, "Vous avez créé un blips !")
end)

RegisterServerEvent('iBlipsBuilder:updateBlips')
AddEventHandler('iBlipsBuilder:updateBlips', function(blipsSelect)
    local _src = source
    MySQL.Async.execute('UPDATE blipsbuilder SET label = @label, coord = @coord, type = @type, color = @color WHERE id = @id', {
        ['@label'] = blipsSelect.label,
        ['@coord'] = json.encode(blipsSelect.coord),
        ['@type'] = blipsSelect.type,
        ['@color'] = blipsSelect.color,
        ['@id'] = blipsSelect.id
    })
    TriggerClientEvent('esx:showNotification', _src, "Vous avez modifié un blips !")
end)


RegisterServerEvent('iBlipsBuilder:removeBlips')
AddEventHandler('iBlipsBuilder:removeBlips', function(id)
    local _src = source
    MySQL.Async.execute('DELETE FROM blipsbuilder WHERE id = @id', {
        ['@id'] = id
    })
    TriggerClientEvent('esx:showNotification', _src, "Vous avez supprimé un blips !")
end)