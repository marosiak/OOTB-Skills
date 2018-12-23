AddCSLuaFile()
AddCSLuaFile("skills_cli.lua")
AddCSLuaFile("skillsConfig.lua")
AddCSLuaFile("skillsShared.lua")
include("skillsConfig.lua")
include("skillsShared.lua")  
util.AddNetworkString( "loadSkills" ) -- srv
util.AddNetworkString( "refreshSkills" ) -- cli

local function saveSkillsTable(ply, tab)
    if not file.Exists( SkillsConfig.General.dataFolder.."/".."TEST"..".dat", "DATA" ) then file.CreateDir(SkillsConfig.General.dataFolder)  end
    table.SortByMember(tab, "name", true)
    file.Write(SkillsConfig.General.dataFolder.."/".."TEST"..".dat",util.TableToJSON(tab, true))
end

local function loadSkillsTable(ply)
    local tab
    if file.Exists( SkillsConfig.General.dataFolder.."/".."TEST"..".dat", "DATA" ) then
        tab = util.JSONToTable(file.Read( SkillsConfig.General.dataFolder.."/".."TEST"..".dat", "DATA" ))
        for i, v in pairs(tab) do  
            if v.level == nil then v.level = 1 end
            if v.exp == nil then v.exp = 0 end
            if v.level > 1 then
                v.expForNextLevel =  v.expBase*((v.level-1)*v.multiplier) 
            else
                v.expForNextLevel = v.expBase
            end
            v.progress = math.Round(v.exp/v.expForNextLevel,3)  
        end
    else
        file.CreateDir(SkillsConfig.General.dataFolder) 
        tab = SkillsConfig.Skills
        for i, v in pairs(tab) do  
            v.level = 1
            if v.level > 1 then
                v.expForNextLevel =  v.expBase*((v.level-1)*v.multiplier) 
            else
                v.expForNextLevel = v.expBase 
            end
            v.exp = 0
            v.progress = math.Round(v.exp/v.expForNextLevel,3)  
        end
        table.SortByMember(tab, "name", true)
        saveSkillsTable(ply, tab)
    end
    table.Merge(tab, SkillsConfig.Skills)
    

    local forceSave = false
    for i, v in pairs(tab) do 
        if SkillsConfig.Skills[i] == nil then 
            print("Skill: "..i.." Nie istnieje")
            tab[i] = nil
            forceSave = true
        end 
    end
    if forceSave then saveSkillsTable(ply, tab) end

    table.SortByMember(tab, "name", true)
    return tab
end
 
net.Receive( "loadSkills", function( len, ply ) 

        -- [test 1]
        -- 100 - tyle maam expa
        -- 105 - tyle potrzeba do drugiego levela
        -- 30 - tyle chce dodać
        -- powinno zwiększyć level, i dodać 25 expa
        -- print("[TEST]")
        -- print((100+30)%(105)) -- zwraca 25
        -- [Działa]

        -- =============================
        -- [test 2 live]
        -- "exp":28.0,"progress":0.56,"expForNextLevel":37.5
        --  ply:AddSkillExp("Lockpicking", 18.5)
        -- po dodaniu 18.5, powinno wbić lvl 2 i zostać 9 expa
        -- [Działa]


        ply:AddSkillExp("Keypad Cracking", 1)
    net.Start("refreshSkills")
    net.WriteTable(loadSkillsTable(ply))
    net.Send(ply)
end ) 

local plyMeta = FindMetaTable( "Player" )         
function plyMeta:AddSkillExp(skillName, exp)
    exp = exp*SkillsConfig.General.levelingScale
    local tab = loadSkillsTable(self)
    local target
    if tab[skillName] ~= nil then 
        target = tab[skillName]
    else
        for i, v in pairs(tab) do 
            if v.name == skillName then target = v end
        end
    end
    if target.exp+exp < target.expForNextLevel then
        target.exp = target.exp+exp
    else  
        local cache = ((target.exp+exp)%(target.expForNextLevel))
        target.level = target.level+1
        target.exp = cache
    end
    saveSkillsTable(self, tab)
end

function plyMeta:AddSkillProgress(skillName, progress) -- progress == 50 will give 50%
    local tab = loadSkillsTable(self)
    local target
    if tab[skillName] ~= nil then 
        target = tab[skillName]
    else
        for i, v in pairs(tab) do 
            if v.name == skillName then target = v end
        end
    end
    if target ~= nil then 
        local c = (target.exp+((progress/100)*target.expForNextLevel))
        if c >= target.expForNextLevel then 
            target.level = target.level+1
            target.exp = 0
        else
            target.exp = c
        end
    end
    saveSkillsTable(self, tab) 
end