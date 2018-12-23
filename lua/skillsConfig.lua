SkillsConfig = {
    General = {
            openBind = KEY_F2,
            dataFolder = "skills_data",
            levelingScale = 1,  -- This is important, you may change it to 1.15, then you'll lvl up 15% faster, it's usefull for xmas events
                                -- In case you'll feel people are getting exp too quickly, you can make 0.5 or something
        },
    Skills = {
        KeypadCracking = {
            name = "Keypad Cracking",
            maxLevel = 10,
            expBase = 100, -- It defines the exp needed to get from 1 lvl -> 2 lvl, then for next levels it's higher and higher
            multiplier = 1.4, -- Defines how hard it's going to be to get higher levels comparing to low level
        },
        Lockpicking = {
            name = "Lockpicking",
            maxLevel = 10,
            expBase = 15,
            multiplier = 2.5,
        },
    },
} 