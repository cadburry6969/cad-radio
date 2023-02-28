local QBCore = exports["qb-core"]:GetCoreObject()
local canUseRadio = true

local function notify(msg, type)
    TriggerEvent("QBCore:Notify", msg, type)
end

---#JOIN/LEAVE/VOLUME
local function leaveRadio()
    TriggerServerEvent("radio:removeFromList", LocalPlayer.state.radioChannel)
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    notify("Left Radio", 'success')
end

local function joinRadio(channel)
    if not canUseRadio then notify('Cannot use radio', 'error') return end
    channel = tonumber(channel)
    if channel == nil or channel == 0 then leaveRadio() return end
    exports["pma-voice"]:setRadioChannel(channel)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
    TriggerServerEvent("radio:addToList", channel)
    notify('Joined ' ..channel.. ' MHz', 'success')
end

AddEventHandler('gameEventTriggered', function(event, data)
    if event == "CEventNetworkEntityDamage" then
        local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
        if not IsEntityAPed(victim) then return end
        if victimDied and NetworkGetPlayerIndexFromPed(victim) == PlayerId() and IsEntityDead(PlayerPedId()) then
            leaveRadio()
        end
    end
end)

exports("CanUse", function(_bool)
    canUseRadio = _bool
    if not canUseRadio then
        leaveRadio()
    end
end)

local function getList(channel)
    local p = promise.new()
    QBCore.Functions.TriggerCallback('radio:getRadioList', function(result)
        p:resolve(result)
    end, channel)
    local list = Citizen.Await(p)
    return list
end

local function hasPermission(channel)
    local curjob = QBCore.Functions.GetPlayerData().job.name
    for job, data in pairs(Config.ChannelsAccess) do
        if curjob == job then
            if channel >= data[1] and channel <= data[2] then
                return true
            end
        end
    end
    return false
end

local function isRestricted(channel)
    local channels = Config.RestrictedChannels
    if channel >= channels[1] and channel <= channels[2] then
        return true
    end
    return false
end

if Config.Debug then
    RegisterCommand("radio", function (source, args)
        local rchannel = tonumber(args[1])
        if rchannel ~= nil then
            if rchannel ~= LocalPlayer.state.radioChannel then
                if isRestricted(rchannel) then
                    if hasPermission(rchannel) then
                        joinRadio(rchannel)
                    else
                        notify("you cant join restricted channel", "error")
                    end
                else
                    joinRadio(rchannel)
                end
            else
                notify('same channel', 'error')
            end
        else
            notify('invalid channel', 'error')
        end
    end, false)
    RegisterCommand("getlist", function (source, args)
        local channel = tonumber(args[1])
        print(json.encode(getList(channel)))
    end, false)
end

RegisterNUICallback('joinRadio', function(data, cb)
    local rchannel = tonumber(data.channel)
    if rchannel ~= nil then
        if rchannel ~= LocalPlayer.state.radioChannel then
            if isRestricted(rchannel) then
                if hasPermission(rchannel) then
                    joinRadio(rchannel)
                else
                    notify("you cant join restricted channel", 'error')
                end
            else
                joinRadio(rchannel)
            end
        else
            notify('same channel', 'error')
        end
    else
        notify('invalid channel', 'error')
    end
    cb("ok")
end)

RegisterNUICallback('leaveRadio', function(_, cb)
    leaveRadio()
    cb("ok")
end)

RegisterNUICallback('escape', function(_, cb)
    SendNUIMessage({enable=false, type="show"})
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback('getMembers', function(_, cb)
    local channel = LocalPlayer.state.radioChannel
    local list = getList(channel)
    SendNUIMessage({type="update", list=list})
    cb("ok")
end)

RegisterNUICallback("volumeUp", function(_, cb)
    local radioVolume = exports["pma-voice"]:getRadioVolume()
    radioVolume = radioVolume*100
    if radioVolume < 95 then
        radioVolume = radioVolume + 5
        exports["pma-voice"]:setRadioVolume(radioVolume)
        notify('Current Volume: '..radioVolume)
    else
        notify('max high limit reached', 'error')
    end
    cb('ok')
end)

RegisterNUICallback("volumeDown", function(_, cb)
    local radioVolume = exports["pma-voice"]:getRadioVolume()
    radioVolume = radioVolume*100
    if radioVolume > 5 then
        radioVolume = radioVolume - 5
        exports["pma-voice"]:setRadioVolume(radioVolume)
        notify('Current Volume: '..radioVolume)
    else
        notify('max low limit reached', 'error')
    end
    cb('ok')
end)

RegisterNetEvent("radio:openRadio", function()
    SendNUIMessage({enable=true, type="show"})
    SetNuiFocus(true, true)
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.radioChannel ~= 0 then
            if not QBCore.Functions.HasItem("radio", 1) then
                leaveRadio()
            end
        end
        Wait(5000)
    end
end)

---#RADIO EFFECT DEFAULTS
local radioEffectId = CreateAudioSubmix('Radio')
SetAudioSubmixEffectRadioFx(radioEffectId, 0)
SetAudioSubmixEffectParamInt(radioEffectId, 0, GetHashKey('default'), 1)
for filter, value in pairs(Config.DefaultRadioFilter) do
    SetAudioSubmixEffectParamFloat(radioEffectId, 0, filter, value)
end
SetAudioSubmixOutputVolumes(
    radioEffectId,
    0,
    1.0 --[[ frontLeftVolume ]],
    0.25 --[[ frontRightVolume ]],
    0.0 --[[ rearLeftVolume ]],
    0.0 --[[ rearRightVolume ]],
    1.0 --[[ channel5Volume ]],
    1.0 --[[ channel6Volume ]]
)
AddAudioSubmixOutput(radioEffectId, 0)
exports["pma-voice"]:setEffectSubmix("radio", radioEffectId)