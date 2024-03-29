Config = {}
Config.MinimumStress = 50 -- Minimum Stress Level For Screen Shaking

Config.UpdateInterval = 10 -- Min Update Food and Water

-- Stress
Config.Intensity = {
    [1] = {min = 50, max = 60,  intensity = 0.12},
    [2] = {min = 60, max = 70,  intensity = 0.17},
    [3] = {min = 70, max = 80,  intensity = 0.22},
    [4] = {min = 80, max = 90,  intensity = 0.28},
    [5] = {min = 90, max = 100, intensity = 0.32}
}

Config.EffectInterval = {
    [1] = {min = 50, max = 60,  timeout = math.random(50000, 60000)},
    [2] = {min = 60, max = 70,  timeout = math.random(40000, 50000)},
    [3] = {min = 70, max = 80,  timeout = math.random(30000, 40000)},
    [4] = {min = 80, max = 90,  timeout = math.random(20000, 30000)},
    [5] = {min = 90, max = 100, timeout = math.random(15000, 20000)}
}
