Config = {} or Config

Config.SewerDoorHack = {
    Hack = "alphanumeric", -- (alphabet, numeric, alphanumeric, greek, braille, runes)
    Time = 20, -- To finish the hack before auto fail (Seconds)
}
Config.HackItem = "electronickit"

Config.SafeLocations = { -- You can add more safes to rob
    [1] = { 
        coords = vector3(3560.48, 3667.7, 28.12), 
        heading = 169.66
    }
}

Config.SafeHack = {
    Time = 15, -- Seconds
    Gridsize = 5, -- Gridsize (5, 6, 7, 8, 9, 10)
    IncorrectBlocks = 3 -- The amount of max blocks to get wrong before you fail
}

Config.UseMarkedBills = true -- If you use marked bills then the price of each marked bill will be worth the amount set in Config.SafeRewardAmount if false then it will give you the reward amount in cash
Config.AmountOfMarkedBillsToGet = {1, 4} -- amount of marked bill bags to get upon reward
Config.SafeRewardAmount = {10000, 17500}

Config.IfWantRareItem = true -- If you want to toggle the chance to get a rare item
Config.RareItemChance = math.random(1, 2) -- % chance to get the rare item
Config.RareItemAmmount = 1
Config.RareItem = 'security_card_02'

Config.RaidCoolDown = 90 -- (Minutes) Till it can be hit again

Config.DeliverDocPed = {
    model = "s_m_m_security_01", -- Model of the Special Documents hand in ped
    coords = vector4(569.4, -3126.81, 18.77, 355.4) -- Coords of the Special Documents hand in ped
}

Config.LabGuardAccuracy = 3 -- out of 100% how accurate guards are (dont recommend going above 5 or else they have aimbot)
Config.LabGuardWeapon = { -- this must be the weapon hash not just the weapon item name --this randomises between different guns everytime the guards are spawned
    'WEAPON_PISTOL',
    'WEAPON_COMBATPDW',
}

Config.LabSecurity = {
    { coords = vector3(3532.46, 3649.46, 27.52), heading = 63.5, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3537.36, 3645.83, 28.13), heading = 46.35, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3546.64, 3642.28, 28.12), heading = 96.74, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3550.22, 3654.24, 28.12), heading = 156.29, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3554.83, 3661.73, 28.12), heading = 21.64, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3557.54, 3674.59, 28.12), heading = 104.25, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3564.64, 3682.23, 28.12), heading = 48.35, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3594.74, 3686.06, 27.62), heading = 124.5, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3593.82, 3712.27, 29.69), heading = 139.73, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3608.93, 3729.39, 29.69), heading = 323.56, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3618.91, 3722.51, 29.69), heading = 85.71, model = 's_m_m_fiboffice_02'},
    { coords = vector3(3596.07, 3703.44, 29.69), heading = 344.89, model = 's_m_m_fiboffice_02'},
}

Config.PDAlerts = "qb" -- qb, ps, cd or custom (Configure to your dispatch system)





















Config.SewerDoor = { -- Dont Touch Unless you know what your doing (Needed for the initial Hack)
    Object = 19193616,
    Open = 249.78,
    Closed = 169.96,
    coords = vector3(3526.02, 3702.24, 21.34),
}