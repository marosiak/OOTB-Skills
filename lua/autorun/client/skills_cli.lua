if CLIENT then
    include("skillsConfig.lua")
    include("skillsShared.lua")
    local BlurMaterial = Material("pp/blurscreen")
    local function DrawBlur(panel, amount)
        local x, y = panel:LocalToScreen(0, 0)
        local scrW, scrH = ScrW(), ScrH()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(BlurMaterial)
        for i = 1, 15 do
            BlurMaterial:SetFloat("$blur", (i / 15) * (amount or 6))
            BlurMaterial:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
        end
    end
    -- if SkillsFrame then SkillsFrame:Remove() end 
    local SkillsFrame = vgui.Create( "DFrame" )
    SkillsFrame:SetPos( 5, 5 )
    SkillsFrame:SetSize( 650, 550 ) 
    SkillsFrame:SetTitle( "Name window" )
    SkillsFrame:SetVisible( true )
    SkillsFrame:SetDraggable( false )
    SkillsFrame:ShowCloseButton( true ) 
    SkillsFrame:SetDeleteOnClose(false)
    SkillsFrame:Center()
    SkillsFrame:MakePopup()

    SkillsFrame.DScrollPanel = vgui.Create( "DScrollPanel", SkillsFrame )
    SkillsFrame.DScrollPanel:SetSize( 620, 450 ) 
    SkillsFrame.DScrollPanel:SetPos( (620/2)-(600/2), 50 )

    SkillsFrame.layout = vgui.Create( "DListLayout", SkillsFrame.DScrollPanel )
    SkillsFrame.layout:SetSize( 600, 50 ) 
    for i = 1, 10 do
        local Delegate = vgui.Create("DPanel") 
        Delegate:SetSize(20,100) 
        Delegate.Name = "Keypad Cracking"
        Delegate.ExpBase = 100 -- the exp base from config lvl 1 -> lvl 2
        Delegate.Multiplier = 1.5 
        Delegate.Level = math.random(1,15)
        Delegate.ExpForNextLevel = Delegate.ExpBase*(Delegate.Level*Delegate.Multiplier) 
        Delegate.Exp = math.random(0,Delegate.ExpForNextLevel)
        Delegate.Progress = math.Round(Delegate.Exp/Delegate.ExpForNextLevel,3) 
        function Delegate:Paint(w,h)
            draw.RoundedBox(0, 0, 0+35, w, 36, Color(	41, 54, 67))
            draw.RoundedBox(0, 0, 0+35, w*self.Progress, 36, Color(34, 48, 62))
            draw.DrawText(Delegate.Exp.."/"..Delegate.ExpForNextLevel.." ("..(Delegate.Progress*100).."%)", "expFont", w/2, 12+35, Color(255,255,255,255), TEXT_ALIGN_CENTER)
            draw.DrawText(Delegate.Name.." Level "..Delegate.Level, "skillNameFont", 0,0, Color(255,255,255,255), TEXT_ALIGN_LEFT)
        end
        SkillsFrame.layout:Add( Delegate )
    end

    local function loadData(table)
        SkillsFrame.layout:Clear() 
        for i, v in pairs(table) do  
            local Delegate = vgui.Create("DPanel")  
            Delegate:SetSize(20,100) 
            function Delegate:Paint(w,h)
                draw.RoundedBox(0, 0, 0+35, w, 36, Color(	41, 54, 67))
                draw.RoundedBox(0, 0, 0+35, w*v.progress, 36, Color(34, 48, 62))
                draw.DrawText(v.exp.."/"..v.expForNextLevel.." ("..(v.progress*100).."%)", "expFont", w/2, 12+35, Color(255,255,255,255), TEXT_ALIGN_CENTER)
                draw.DrawText(v.name.." Level "..v.level, "skillNameFont", 0,0, Color(255,255,255,255), TEXT_ALIGN_LEFT)
            end
            SkillsFrame.layout:Add( Delegate )
        end
    end 
    net.Receive( "refreshSkills", function( len, ply ) loadData(net.ReadTable()) end) 


    function SkillsFrame:Paint(w,h)
        DrawBlur(self,15)
        draw.RoundedBox( 0, 0, 0, w, h, Color( 44, 62, 80, 210 ) )
        draw.RoundedBox( 0, 0, 0, w, 25, Color(52, 73, 94) )
    end

    local lastTime = 0 
    local function openSkills()  
        if CurTime() > lastTime+0.2 then 
            if input.IsKeyDown(SkillsConfig.General.openBind ) then   
                if SkillsFrame:IsVisible() then
                    SkillsFrame:Close()
                    gui.EnableScreenClicker(false) 
                else
                    net.Start("loadSkills")
                    net.SendToServer()
                    SkillsFrame:SetVisible(true)
                    SkillsFrame:MakePopup()
                    gui.EnableScreenClicker(true)  
                end
                lastTime = CurTime()  
            end
        end 
    end 
    hook.Add("Think","skills_open",openSkills) 
end