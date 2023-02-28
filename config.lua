Config = {}

Config.Debug = false

Config.RestrictedChannels = {1, 10} --  Range [1-10]
Config.ChannelsAccess = {
    ['police'] = {1, 5}, --  Range [1-5]
}

Config.DefaultRadioFilter = {
    ["freq_low"] = 100.0,
    ["freq_hi"] = 5000.0,
    ["rm_mod_freq"] = 300.0,
    ["rm_mix"] = 0.1,
    ["fudge"] = 4.0,
    ["o_freq_lo"] = 300.0,
    ["o_freq_hi"] = 5000.0,
}