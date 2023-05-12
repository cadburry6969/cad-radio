local QBCore = exports["qb-core"]:GetCoreObject()

local RadioList = {}

RegisterNetEvent('radio:addToList', function(radio)
    local source = source
    if not radio then return end
    local Player = QBCore.Functions.GetPlayer(source)
    local name = tostring(Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname)
    if RadioList[radio] == nil then RadioList[radio] = {} end
    RadioList[radio][#RadioList[radio]+1] = name
end)

RegisterNetEvent('radio:removeFromList', function(radio)
    local source = source
    if not radio then return end
    if RadioList[radio] == nil then return end
    local Player = QBCore.Functions.GetPlayer(source)
    local name = tostring(Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname)
    for i=1, #RadioList[radio] do
        if name == RadioList[radio][i] then
            table.remove(RadioList[radio], i)
        end
    end
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    local source = src
    local Player = QBCore.Functions.GetPlayer(source)
    local name = tostring(Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname)
    local radioChannel = Player(source).state.radioChannel
    if radioChannel then
        for pos, pname in pairs(RadioList[radioChannel]) do
            if pname == name then
                table.remove(RadioList[radioChannel], pos)
                break
            end
        end
    else
        for channel in pairs(RadioList) do
            for pos, pname in pairs(RadioList[channel]) do
                if pname == name then
                    table.remove(RadioList[channel], pos)
                    break
                end
            end
        end
    end
end)

QBCore.Functions.CreateCallback('radio:getRadioList', function(source, cb, radio)
    if RadioList[radio] then
        cb(RadioList[radio])
    else
        cb(false)
    end
end)

QBCore.Functions.CreateUseableItem("radio", function(source)
    TriggerClientEvent('radio:openRadio', source)
end)