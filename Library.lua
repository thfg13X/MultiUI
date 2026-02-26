local multihubx = {}
multihubx.__index = multihubx

local tweenservice = game:GetService("TweenService")
local uis          = game:GetService("UserInputService")
local players      = game:GetService("Players")
local lp           = players.LocalPlayer

local function makecorner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    c.Parent = parent
    return c
end

local function makestroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color     = color     or Color3.fromRGB(210, 25, 25)
    s.Thickness = thickness or 1
    s.Parent    = parent
    return s
end

local function makepad(t, l, r, b, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = parent
    return p
end

-- Colours
local DARK  = Color3.fromRGB(13,  13,  13 )
local DARK2 = Color3.fromRGB(16,  16,  16 )
local DARK3 = Color3.fromRGB(20,  20,  20 )
local DARK4 = Color3.fromRGB(24,  24,  24 )
local DARK5 = Color3.fromRGB(18,  18,  18 )
local GREY1 = Color3.fromRGB(140, 140, 140)
local GREY2 = Color3.fromRGB(195, 195, 195)
local GREY3 = Color3.fromRGB(210, 210, 210)
local GREY4 = Color3.fromRGB(36,  36,  36 )
local GREY5 = Color3.fromRGB(44,  44,  44 )
local GREY6 = Color3.fromRGB(26,  26,  26 )
local GREY7 = Color3.fromRGB(52,  52,  52 )
local WHITE = Color3.fromRGB(255, 255, 255)

function multihubx:createwindow(config)
    config = config or {}
    local title     = config.title     or "multi hub x"
    local subtitle  = config.subtitle  or ""
    local size      = config.size      or UDim2.new(0, 600, 0, 400)
    local togglekey = config.togglekey or Enum.KeyCode.RightShift

    local playergui = lp:WaitForChild("PlayerGui")
    local screengui = Instance.new("ScreenGui")
    screengui.Name           = "multihubx_" .. title:lower():gsub("%s","")
    screengui.ResetOnSpawn   = false
    screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screengui.Parent         = playergui

    local lighting      = game:GetService("Lighting")
    local blureffect    = Instance.new("BlurEffect")
    blureffect.Size     = 0
    blureffect.Enabled  = false
    blureffect.Parent   = lighting
    local blurenabled   = false
    local blurintensity = 20

    local accentcolor    = Color3.fromRGB(210, 25, 25)
    local accentobjs     = {}
    local keybindregistry = {}
    local notifstack     = {}

    local function regaccent(obj, prop)
        table.insert(accentobjs, { obj = obj, prop = prop })
    end

    local function updatetheme(color)
        accentcolor = color
        for _, item in ipairs(accentobjs) do
            tweenservice:Create(item.obj, TweenInfo.new(0.25), { [item.prop] = color }):Play()
        end
    end

    -- ── Notification system ──────────────────────────────────────
    local notifstackframe = Instance.new("Frame")
    notifstackframe.Size = UDim2.new(0, 250, 1, 0)
    notifstackframe.Position = UDim2.new(1, -260, 0, 0)
    notifstackframe.BackgroundTransparency = 1
    notifstackframe.BorderSizePixel = 0
    notifstackframe.ZIndex = 50
    notifstackframe.Parent = screengui

    local function sendnotif(data)
        local ntitle, ntext
        if type(data) == "table" then
            ntitle = data.title or "notice"
            ntext  = data.text  or ""
        else
            ntitle = nil
            ntext  = tostring(data)
        end

        local nfH = ntitle and 56 or 42
        local nf  = Instance.new("Frame")
        nf.Size                 = UDim2.new(1, 0, 0, nfH)
        nf.Position             = UDim2.new(0, 0, 1, -((nfH + 5) * (#notifstack + 1) + 10))
        nf.BackgroundColor3     = DARK2
        nf.BackgroundTransparency = 1
        nf.BorderSizePixel      = 0
        nf.ZIndex               = 51
        nf.Parent               = notifstackframe
        makecorner(UDim.new(0, 8), nf)
        local ns = makestroke(accentcolor, 1, nf)
        regaccent(ns, "Color")

        local accentbar = Instance.new("Frame")
        accentbar.Size            = UDim2.new(0, 3, 1, -10)
        accentbar.Position        = UDim2.new(0, 0, 0, 5)
        accentbar.BackgroundColor3= accentcolor
        accentbar.BorderSizePixel = 0
        accentbar.ZIndex          = 52
        accentbar.Parent          = nf
        makecorner(UDim.new(0, 3), accentbar)
        regaccent(accentbar, "BackgroundColor3")

        local function makenotiftext(ypos, h, txt, col, sz, bold)
            local l = Instance.new("TextLabel")
            l.Size                = UDim2.new(1, -20, 0, h)
            l.Position            = UDim2.new(0, 12, 0, ypos)
            l.BackgroundTransparency = 1
            l.Text                = txt
            l.TextColor3          = col
            l.TextSize            = sz
            l.Font                = bold and Enum.Font.GothamBold or Enum.Font.Gotham
            l.TextXAlignment      = Enum.TextXAlignment.Left
            l.TextWrapped         = true
            l.ZIndex              = 52
            l.Parent              = nf
            return l
        end

        local labels = {}
        if ntitle then
            table.insert(labels, makenotiftext(5,  18, ntitle, accentcolor, 12, true))
            table.insert(labels, makenotiftext(25, 22, ntext,  GREY2,       11, false))
            regaccent(labels[1], "TextColor3")
        else
            table.insert(labels, makenotiftext(3, nfH-8, ntext, GREY3, 11, false))
        end

        table.insert(notifstack, nf)
        tweenservice:Create(nf, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()

        local bar = Instance.new("Frame")
        bar.Size             = UDim2.new(1, 0, 0, 2)
        bar.Position         = UDim2.new(0, 0, 1, -2)
        bar.BackgroundColor3 = accentcolor
        bar.BorderSizePixel  = 0
        bar.ZIndex           = 52
        bar.Parent           = nf
        regaccent(bar, "BackgroundColor3")
        tweenservice:Create(bar, TweenInfo.new(3.5, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()

        task.delay(3.5, function()
            tweenservice:Create(nf, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            for _, l in ipairs(labels) do
                tweenservice:Create(l, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
            end
            task.wait(0.3)
            for i, v in ipairs(notifstack) do if v == nf then table.remove(notifstack, i); break end end
            nf:Destroy()
        end)
    end

    -- ── Confirm popup ────────────────────────────────────────────
    local confirmpopup = Instance.new("Frame")
    confirmpopup.Size             = UDim2.new(0, 310, 0, 165)
    confirmpopup.Position         = UDim2.new(0.5, -155, 0.5, -82)
    confirmpopup.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    confirmpopup.BorderSizePixel  = 0
    confirmpopup.ZIndex           = 100
    confirmpopup.Visible          = false
    confirmpopup.Parent           = screengui
    makecorner(UDim.new(0, 10), confirmpopup)
    local cpstroke = makestroke(accentcolor, 2, confirmpopup)
    regaccent(cpstroke, "Color")

    local cptitle = Instance.new("TextLabel")
    cptitle.Size = UDim2.new(1,-16,0,28); cptitle.Position = UDim2.new(0,8,0,8)
    cptitle.BackgroundTransparency = 1; cptitle.Text = "are you sure?"
    cptitle.TextColor3 = accentcolor; cptitle.TextSize = 14
    cptitle.Font = Enum.Font.GothamBold; cptitle.TextXAlignment = Enum.TextXAlignment.Left
    cptitle.ZIndex = 101; cptitle.Parent = confirmpopup
    regaccent(cptitle, "TextColor3")

    local cpwarn = Instance.new("TextLabel")
    cpwarn.Size = UDim2.new(1,-16,0,60); cpwarn.Position = UDim2.new(0,8,0,38)
    cpwarn.BackgroundTransparency = 1; cpwarn.Text = ""
    cpwarn.TextColor3 = Color3.fromRGB(155,155,155); cpwarn.TextSize = 11
    cpwarn.Font = Enum.Font.Gotham; cpwarn.TextXAlignment = Enum.TextXAlignment.Left
    cpwarn.TextWrapped = true; cpwarn.ZIndex = 101; cpwarn.Parent = confirmpopup

    local cpdiv = Instance.new("Frame")
    cpdiv.Size = UDim2.new(1,-16,0,1); cpdiv.Position = UDim2.new(0,8,0,105)
    cpdiv.BackgroundColor3 = GREY4; cpdiv.BorderSizePixel = 0; cpdiv.ZIndex = 101; cpdiv.Parent = confirmpopup

    local yesbtn = Instance.new("TextButton")
    yesbtn.Size = UDim2.new(0.45,-4,0,32); yesbtn.Position = UDim2.new(0,8,0,116)
    yesbtn.BackgroundColor3 = Color3.fromRGB(140,20,20); yesbtn.Text = "yes"
    yesbtn.TextColor3 = WHITE; yesbtn.TextSize = 12; yesbtn.Font = Enum.Font.GothamBold
    yesbtn.BorderSizePixel = 0; yesbtn.ZIndex = 102; yesbtn.Parent = confirmpopup
    makecorner(UDim.new(0,6), yesbtn)

    local nobtn = Instance.new("TextButton")
    nobtn.Size = UDim2.new(0.45,-4,0,32); nobtn.Position = UDim2.new(0.55,-4,0,116)
    nobtn.BackgroundColor3 = GREY6; nobtn.Text = "no"
    nobtn.TextColor3 = GREY2; nobtn.TextSize = 12; nobtn.Font = Enum.Font.GothamBold
    nobtn.BorderSizePixel = 0; nobtn.ZIndex = 102; nobtn.Parent = confirmpopup
    makecorner(UDim.new(0,6), nobtn)
    makestroke(GREY7, 1, nobtn)

    local pendingyes, pendingrevert = nil, nil
    yesbtn.MouseButton1Click:Connect(function()
        confirmpopup.Visible = false
        if pendingyes then pendingyes() end
        pendingyes = nil; pendingrevert = nil
    end)
    nobtn.MouseButton1Click:Connect(function()
        confirmpopup.Visible = false
        if pendingrevert then pendingrevert() end
        pendingyes = nil; pendingrevert = nil
    end)

    -- ── Main window frame ────────────────────────────────────────
    local mainframe = Instance.new("Frame")
    mainframe.Name                = "mainframe"
    mainframe.Size                = size
    mainframe.Position            = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    mainframe.BackgroundColor3    = DARK
    mainframe.BackgroundTransparency = 0
    mainframe.BorderSizePixel     = 0
    mainframe.ClipsDescendants    = true
    mainframe.Parent              = screengui
    makecorner(UDim.new(0, 12), mainframe)
    local mainstroke = makestroke(accentcolor, 2, mainframe)
    regaccent(mainstroke, "Color")

    local titlebarH = subtitle ~= "" and 48 or 36

    local titlebar = Instance.new("Frame")
    titlebar.Size             = UDim2.new(1, 0, 0, titlebarH)
    titlebar.BackgroundColor3 = DARK5
    titlebar.BorderSizePixel  = 0
    titlebar.ZIndex           = 2
    titlebar.Parent           = mainframe

    local titlelbl = Instance.new("TextLabel")
    titlelbl.Size = UDim2.new(1,-75, 0, subtitle ~= "" and 22 or 36)
    titlelbl.Position = UDim2.new(0, 12, 0, subtitle ~= "" and 5 or 0)
    titlelbl.BackgroundTransparency = 1
    titlelbl.Text = title
    titlelbl.TextColor3 = accentcolor
    titlelbl.TextSize = 14
    titlelbl.Font = Enum.Font.GothamBold
    titlelbl.TextXAlignment = Enum.TextXAlignment.Left
    titlelbl.ZIndex = 2
    titlelbl.Parent = titlebar
    regaccent(titlelbl, "TextColor3")

    if subtitle ~= "" then
        local sublbl = Instance.new("TextLabel")
        sublbl.Size = UDim2.new(1,-75,0,16); sublbl.Position = UDim2.new(0,12,0,28)
        sublbl.BackgroundTransparency = 1; sublbl.Text = subtitle
        sublbl.TextColor3 = Color3.fromRGB(100,100,100); sublbl.TextSize = 11
        sublbl.Font = Enum.Font.Gotham; sublbl.TextXAlignment = Enum.TextXAlignment.Left
        sublbl.ZIndex = 2; sublbl.Parent = titlebar
    end

    local function maketitlebtn(txt, xoff, bg)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 26, 0, 22)
        b.Position = UDim2.new(1, xoff, 0, (titlebarH-22)/2)
        b.BackgroundColor3 = bg; b.Text = txt; b.TextColor3 = WHITE
        b.TextSize = 11; b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0; b.ZIndex = 3; b.Parent = titlebar
        makecorner(UDim.new(0,5), b)
        return b
    end

    local closebtn = maketitlebtn("✕", -30, Color3.fromRGB(160,20,20))
    local minbtn   = maketitlebtn("−", -60, GREY7)

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1,0,0,1); sep.Position = UDim2.new(0,0,0,titlebarH)
    sep.BackgroundColor3 = accentcolor; sep.BorderSizePixel = 0; sep.ZIndex = 2; sep.Parent = mainframe
    regaccent(sep, "BackgroundColor3")

    -- Tab sidebar
    local tabpanel = Instance.new("Frame")
    tabpanel.Size = UDim2.new(0,120,1,-(titlebarH+1))
    tabpanel.Position = UDim2.new(0,0,0,titlebarH+1)
    tabpanel.BackgroundColor3 = DARK2; tabpanel.BorderSizePixel = 0
    tabpanel.ClipsDescendants = true; tabpanel.Parent = mainframe

    local tabdiv = Instance.new("Frame")
    tabdiv.Size = UDim2.new(0,1,1,-(titlebarH+1)); tabdiv.Position = UDim2.new(0,120,0,titlebarH+1)
    tabdiv.BackgroundColor3 = accentcolor; tabdiv.BorderSizePixel = 0; tabdiv.Parent = mainframe
    regaccent(tabdiv, "BackgroundColor3")

    local tablayout = Instance.new("UIListLayout")
    tablayout.SortOrder = Enum.SortOrder.LayoutOrder; tablayout.Padding = UDim.new(0,0); tablayout.Parent = tabpanel

    local contentarea = Instance.new("Frame")
    contentarea.Size = UDim2.new(1,-121,1,-(titlebarH+1))
    contentarea.Position = UDim2.new(0,121,0,titlebarH+1)
    contentarea.BackgroundTransparency = 1; contentarea.BorderSizePixel = 0
    contentarea.ClipsDescendants = true; contentarea.Parent = mainframe

    -- Mini widget (collapsed state)
    local miniwidget = Instance.new("Frame")
    miniwidget.Name = "miniwidget"; miniwidget.Size = UDim2.new(0,54,0,54)
    miniwidget.Position = UDim2.new(0,30,0.5,-27); miniwidget.BackgroundColor3 = DARK
    miniwidget.BorderSizePixel = 0; miniwidget.Visible = false; miniwidget.ZIndex = 20; miniwidget.Parent = screengui
    makecorner(UDim.new(1,0), miniwidget)
    local ministr = makestroke(accentcolor, 2, miniwidget)
    regaccent(ministr, "Color")

    local minilbl = Instance.new("TextLabel")
    minilbl.Size = UDim2.new(1,0,0.6,0); minilbl.Position = UDim2.new(0,0,0.1,0)
    minilbl.BackgroundTransparency = 1; minilbl.Text = "m-x"
    minilbl.TextColor3 = accentcolor; minilbl.TextSize = 12; minilbl.Font = Enum.Font.GothamBold
    minilbl.ZIndex = 21; minilbl.Parent = miniwidget
    regaccent(minilbl, "TextColor3")

    local restorestrip = Instance.new("Frame")
    restorestrip.Size = UDim2.new(0,130,0,30); restorestrip.Position = UDim2.new(0.5,-65,1,-40)
    restorestrip.BackgroundColor3 = DARK2; restorestrip.BorderSizePixel = 0
    restorestrip.Visible = false; restorestrip.ZIndex = 20; restorestrip.Parent = screengui
    makecorner(UDim.new(0,8), restorestrip)
    local restorestroke = makestroke(accentcolor, 1, restorestrip)
    regaccent(restorestroke, "Color")

    local restorebtn = Instance.new("TextButton")
    restorebtn.Size = UDim2.new(1,0,1,0); restorebtn.BackgroundTransparency = 1
    restorebtn.Text = "show ui"; restorebtn.TextColor3 = accentcolor
    restorebtn.TextSize = 11; restorebtn.Font = Enum.Font.GothamBold
    restorebtn.ZIndex = 21; restorebtn.Parent = restorestrip
    regaccent(restorebtn, "TextColor3")

    local rsdragging,rsdragstart,rsstartpos,rshasmoved = false,nil,nil,false
    restorestrip.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            rsdragging=true; rshasmoved=false; rsdragstart=inp.Position; rsstartpos=restorestrip.Position
        end
    end)
    restorestrip.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then rsdragging=false end
    end)

    local minihitbox = Instance.new("TextButton")
    minihitbox.Size = UDim2.new(1,0,1,0); minihitbox.BackgroundTransparency = 1
    minihitbox.Text = ""; minihitbox.ZIndex = 22; minihitbox.Parent = miniwidget

    local minidragging,minidragstart,ministartpos,minihasmoved = false,nil,nil,false
    minihitbox.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            minidragging=true; minihasmoved=false; minidragstart=inp.Position; ministartpos=miniwidget.Position
        end
    end)
    minihitbox.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then minidragging=false end
    end)

    local function collapse()
        mainframe.Visible = false; miniwidget.Visible = true; restorestrip.Visible = true
        if blurenabled then
            tweenservice:Create(blureffect,TweenInfo.new(0.25),{Size=0}):Play()
            task.delay(0.25,function() blureffect.Enabled=false end)
        end
    end
    local function showgui()
        miniwidget.Visible=false; restorestrip.Visible=false; mainframe.Visible=true
        if blurenabled then
            blureffect.Size=0; blureffect.Enabled=true
            tweenservice:Create(blureffect,TweenInfo.new(0.25),{Size=blurintensity}):Play()
        end
    end

    minihitbox.MouseButton1Click:Connect(function() if not minihasmoved then showgui() end end)
    restorebtn.MouseButton1Click:Connect(function() if not rshasmoved then showgui() end end)
    closebtn.MouseButton1Click:Connect(collapse)
    minbtn.MouseButton1Click:Connect(collapse)

    local maindragging,maindragstart,mainstartpos = false,nil,nil
    titlebar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            maindragging=true; maindragstart=inp.Position; mainstartpos=mainframe.Position
        end
    end)
    titlebar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then maindragging=false end
    end)

    local currenttogglekey = togglekey
    local listeningforkey  = false

    uis.InputChanged:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if maindragging and maindragstart then
            local d = inp.Position - maindragstart
            mainframe.Position = UDim2.new(mainstartpos.X.Scale,mainstartpos.X.Offset+d.X,mainstartpos.Y.Scale,mainstartpos.Y.Offset+d.Y)
        end
        if minidragging and minidragstart then
            local d = inp.Position - minidragstart
            if math.abs(d.X)>3 or math.abs(d.Y)>3 then minihasmoved=true end
            miniwidget.Position = UDim2.new(ministartpos.X.Scale,ministartpos.X.Offset+d.X,ministartpos.Y.Scale,ministartpos.Y.Offset+d.Y)
        end
        if rsdragging and rsdragstart then
            local d = inp.Position - rsdragstart
            if math.abs(d.X)>3 or math.abs(d.Y)>3 then rshasmoved=true end
            restorestrip.Position = UDim2.new(rsstartpos.X.Scale,rsstartpos.X.Offset+d.X,rsstartpos.Y.Scale,rsstartpos.Y.Offset+d.Y)
        end
    end)
    uis.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            maindragging=false; minidragging=false; rsdragging=false
            task.delay(0,function() minihasmoved=false; rshasmoved=false end)
        end
    end)
    uis.InputBegan:Connect(function(inp,gpe)
        if listeningforkey and inp.UserInputType==Enum.UserInputType.Keyboard then
            listeningforkey=false; currenttogglekey=inp.KeyCode; return
        end
        if not listeningforkey and inp.KeyCode==currenttogglekey and not gpe then
            if mainframe.Visible then collapse() else showgui() end
        end
    end)

    -- ── Tab system ───────────────────────────────────────────────
    local tablist  = {}
    local pagelist = {}
    local activetab = nil
    local taborder  = 0

    local function selecttab(name)
        if activetab == name then return end
        activetab = name
        for tname, info in pairs(tablist) do
            local active = tname == name
            tweenservice:Create(info.btn,TweenInfo.new(0.12),{TextColor3 = active and WHITE or GREY1}):Play()
            info.indicator.Visible = active
            if active then info.indicator.BackgroundColor3 = accentcolor end
        end
        for pname, page in pairs(pagelist) do
            page.Visible = pname == name
        end
    end

    local window = {}

    function window:addtab(name)
        taborder += 1
        local order = taborder

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,34); btn.BackgroundColor3 = DARK2
        btn.Text = name; btn.TextColor3 = GREY1; btn.TextSize = 12
        btn.Font = Enum.Font.GothamSemibold; btn.BorderSizePixel = 0
        btn.AutoButtonColor = false; btn.LayoutOrder = order; btn.Parent = tabpanel

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0,3,0.55,0); indicator.Position = UDim2.new(0,0,0.225,0)
        indicator.BackgroundColor3 = accentcolor; indicator.BorderSizePixel = 0
        indicator.Visible = false; indicator.ZIndex = 2; indicator.Parent = btn
        makecorner(UDim.new(0,2), indicator)
        regaccent(indicator, "BackgroundColor3")

        tablist[name] = { btn=btn, indicator=indicator }

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1,0,1,0); scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = accentcolor; scroll.CanvasSize = UDim2.new(0,0,0,0)
        scroll.Visible = false; scroll.Parent = contentarea
        pagelist[name] = scroll
        regaccent(scroll, "ScrollBarImageColor3")

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0,5); layout.Parent = scroll
        makepad(8,8,8,8,scroll)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+16)
        end)

        btn.MouseButton1Click:Connect(function() selecttab(name) end)
        if activetab == nil then selecttab(name) end

        local tab = {}
        local page = scroll

        -- ── groupbox (collapsible) ───────────────────────────────
        function tab:addgroupbox(cfg)
            cfg = cfg or {}
            local gtitle = cfg.title or "group"
            local open   = false

            local wrapper = Instance.new("Frame")
            wrapper.Size = UDim2.new(1,0,0,32); wrapper.BackgroundColor3 = DARK2
            wrapper.BorderSizePixel = 0; wrapper.ClipsDescendants = true; wrapper.Parent = page
            makecorner(UDim.new(0,8), wrapper)
            local wstroke = makestroke(accentcolor, 1, wrapper)
            regaccent(wstroke, "Color")

            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1,0,0,32); header.BackgroundColor3 = DARK3
            header.Text = ""; header.BorderSizePixel = 0; header.AutoButtonColor = false
            header.ZIndex = 2; header.Parent = wrapper
            makecorner(UDim.new(0,8), header)

            local headerlbl = Instance.new("TextLabel")
            headerlbl.Size = UDim2.new(1,-38,1,0); headerlbl.Position = UDim2.new(0,12,0,0)
            headerlbl.BackgroundTransparency = 1; headerlbl.Text = gtitle
            headerlbl.TextColor3 = accentcolor; headerlbl.TextSize = 11; headerlbl.Font = Enum.Font.GothamBold
            headerlbl.TextXAlignment = Enum.TextXAlignment.Left; headerlbl.ZIndex = 3; headerlbl.Parent = header
            regaccent(headerlbl, "TextColor3")

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0,20,0,20); arrow.Position = UDim2.new(1,-26,0.5,-10)
            arrow.BackgroundTransparency = 1; arrow.Text = "▶"
            arrow.TextColor3 = accentcolor; arrow.TextSize = 9; arrow.Font = Enum.Font.GothamBold
            arrow.ZIndex = 3; arrow.Parent = header
            regaccent(arrow, "TextColor3")

            local divline = Instance.new("Frame")
            divline.Size = UDim2.new(1,-16,0,1); divline.Position = UDim2.new(0,8,0,32)
            divline.BackgroundColor3 = accentcolor; divline.BorderSizePixel = 0
            divline.Visible = false; divline.ZIndex = 2; divline.Parent = wrapper
            regaccent(divline, "BackgroundColor3")

            local inner = Instance.new("Frame")
            inner.Size = UDim2.new(1,0,0,0); inner.Position = UDim2.new(0,0,0,33)
            inner.BackgroundTransparency = 1; inner.BorderSizePixel = 0
            inner.ClipsDescendants = false; inner.Parent = wrapper

            local innerlayout = Instance.new("UIListLayout")
            innerlayout.SortOrder = Enum.SortOrder.LayoutOrder; innerlayout.Padding = UDim.new(0,4); innerlayout.Parent = inner
            makepad(5,6,6,5,inner)

            local function recalc()
                local h = innerlayout.AbsoluteContentSize.Y + 10
                inner.Size = UDim2.new(1,0,0,h)
                if open then
                    tweenservice:Create(wrapper,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,0,33+h)}):Play()
                end
            end
            innerlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(recalc)

            header.MouseButton1Click:Connect(function()
                open = not open
                divline.Visible = open
                tweenservice:Create(arrow,TweenInfo.new(0.15),{Rotation = open and 90 or 0}):Play()
                if open then
                    local h = innerlayout.AbsoluteContentSize.Y + 10
                    inner.Size = UDim2.new(1,0,0,h)
                    tweenservice:Create(wrapper,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,0,33+h)}):Play()
                else
                    tweenservice:Create(wrapper,TweenInfo.new(0.15,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,0,32)}):Play()
                end
            end)

            local group = {}
            local function withpage(fn)
                local old = page; page = inner; fn(); page = old
            end
            function group:addtoggle(c) local r; withpage(function() r=tab:addtoggle(c) end); return r end
            function group:addslider(c)  withpage(function() tab:addslider(c) end) end
            function group:addbutton(c)  withpage(function() tab:addbutton(c) end) end
            function group:adddropdown(c) local r; withpage(function() r=tab:adddropdown(c) end); return r end
            function group:addkeybind(c) local r; withpage(function() r=tab:addkeybind(c) end); return r end
            function group:addinput(c)   withpage(function() tab:addinput(c) end) end
            function group:addsection(t) withpage(function() tab:addsection(t) end) end
            return group
        end

        -- ── toggle ───────────────────────────────────────────────
        function tab:addtoggle(cfg)
            cfg = cfg or {}
            local txt     = cfg.title    or "toggle"
            local default = cfg.default  or false
            local cb      = cfg.callback

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,32); row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0; row.Parent = page
            makecorner(UDim.new(0,6), row)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-50,1,0); lbl.Position = UDim2.new(0,10,0,0)
            lbl.BackgroundTransparency = 1; lbl.Text = txt
            lbl.TextColor3 = GREY3; lbl.TextSize = 12; lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

            local togbg = Instance.new("Frame")
            togbg.Size = UDim2.new(0,36,0,18); togbg.Position = UDim2.new(1,-44,0.5,-9)
            togbg.BackgroundColor3 = GREY5; togbg.BorderSizePixel = 0; togbg.Parent = row
            makecorner(UDim.new(1,0), togbg)

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0,12,0,12); circle.Position = UDim2.new(0,3,0.5,-6)
            circle.BackgroundColor3 = GREY1; circle.BorderSizePixel = 0; circle.Parent = togbg
            makecorner(UDim.new(1,0), circle)

            local state = default
            local setstate
            setstate = function(v)
                state = v
                tweenservice:Create(circle,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)}):Play()
                tweenservice:Create(togbg,TweenInfo.new(0.12),{BackgroundColor3=v and accentcolor or GREY5}):Play()
                tweenservice:Create(circle,TweenInfo.new(0.12),{BackgroundColor3=v and WHITE or GREY1}):Play()
                if cb then cb(v) end
            end
            setstate(state)

            local clickbtn = Instance.new("TextButton")
            clickbtn.Size = UDim2.new(1,0,1,0); clickbtn.BackgroundTransparency = 1
            clickbtn.Text = ""; clickbtn.Parent = row
            clickbtn.MouseButton1Click:Connect(function() setstate(not state) end)
            return setstate
        end

        -- ── slider ───────────────────────────────────────────────
        function tab:addslider(cfg)
            cfg = cfg or {}
            local txt     = cfg.title    or "slider"
            local default = cfg.default  or 50
            local min     = cfg.min      or 0
            local max     = cfg.max      or 100
            local cb      = cfg.callback

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,46); row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0; row.Parent = page
            makecorner(UDim.new(0,6), row)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-60,0,22); lbl.Position = UDim2.new(0,10,0,2)
            lbl.BackgroundTransparency = 1; lbl.Text = txt
            lbl.TextColor3 = GREY3; lbl.TextSize = 12; lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

            local vallbl = Instance.new("TextLabel")
            vallbl.Size = UDim2.new(0,55,0,22); vallbl.Position = UDim2.new(1,-60,0,2)
            vallbl.BackgroundTransparency = 1; vallbl.Text = tostring(default)
            vallbl.TextColor3 = accentcolor; vallbl.TextSize = 12; vallbl.Font = Enum.Font.GothamBold
            vallbl.TextXAlignment = Enum.TextXAlignment.Right; vallbl.Parent = row
            regaccent(vallbl, "TextColor3")

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1,-20,0,5); track.Position = UDim2.new(0,10,0,32)
            track.BackgroundColor3 = GREY4; track.BorderSizePixel = 0; track.Parent = row
            makecorner(UDim.new(1,0), track)

            local initrel = math.clamp((default-min)/(max-min),0,1)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(initrel,0,1,0); fill.BackgroundColor3 = accentcolor
            fill.BorderSizePixel = 0; fill.Parent = track
            makecorner(UDim.new(1,0), fill)
            regaccent(fill, "BackgroundColor3")

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0,11,0,11); knob.Position = UDim2.new(1,-5,0.5,-5)
            knob.BackgroundColor3 = Color3.fromRGB(230,230,230); knob.BorderSizePixel = 0; knob.Parent = fill
            makecorner(UDim.new(1,0), knob)

            local slideactive = false
            local function updateslider(ix)
                local rel = math.clamp((ix-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                fill.Size = UDim2.new(rel,0,1,0)
                local val = math.floor(min+(max-min)*rel+0.5)
                vallbl.Text = tostring(val)
                if cb then cb(val) end
            end
            track.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then slideactive=true; updateslider(inp.Position.X) end end)
            knob.InputBegan:Connect(function(inp)  if inp.UserInputType==Enum.UserInputType.MouseButton1 then slideactive=true end end)
            uis.InputEnded:Connect(function(inp)   if inp.UserInputType==Enum.UserInputType.MouseButton1 then slideactive=false end end)
            uis.InputChanged:Connect(function(inp) if slideactive and inp.UserInputType==Enum.UserInputType.MouseMovement then updateslider(inp.Position.X) end end)
        end

        -- ── button ───────────────────────────────────────────────
        function tab:addbutton(cfg)
            cfg = cfg or {}
            local txt = cfg.title or "button"
            local cb  = cfg.callback

            local btn2 = Instance.new("TextButton")
            btn2.Size = UDim2.new(1,0,0,30); btn2.BackgroundColor3 = DARK4
            btn2.Text = txt; btn2.TextColor3 = GREY3; btn2.TextSize = 12
            btn2.Font = Enum.Font.GothamSemibold; btn2.BorderSizePixel = 0
            btn2.AutoButtonColor = false; btn2.Parent = page
            makecorner(UDim.new(0,6), btn2)
            local bs = makestroke(accentcolor, 1, btn2)
            regaccent(bs, "Color")

            btn2.MouseButton1Click:Connect(function()
                tweenservice:Create(btn2,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(30,10,10)}):Play()
                task.delay(0.15,function() tweenservice:Create(btn2,TweenInfo.new(0.1),{BackgroundColor3=DARK4}):Play() end)
                if cb then cb() end
            end)
        end

        -- ── input ────────────────────────────────────────────────
        function tab:addinput(cfg)
            cfg = cfg or {}
            local txt  = cfg.title       or "input"
            local ph   = cfg.placeholder or "type here..."
            local cb   = cfg.callback

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,50); row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0; row.Parent = page
            makecorner(UDim.new(0,6), row)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-10,0,18); lbl.Position = UDim2.new(0,10,0,2)
            lbl.BackgroundTransparency = 1; lbl.Text = txt
            lbl.TextColor3 = GREY1; lbl.TextSize = 10; lbl.Font = Enum.Font.GothamSemibold
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1,-16,0,22); box.Position = UDim2.new(0,8,0,22)
            box.BackgroundColor3 = DARK4; box.Text = ""; box.PlaceholderText = ph
            box.PlaceholderColor3 = GREY1; box.TextColor3 = GREY2; box.TextSize = 11
            box.Font = Enum.Font.Gotham; box.BorderSizePixel = 0; box.Parent = row
            makecorner(UDim.new(0,4), box)
            makestroke(GREY7, 1, box)

            box.FocusLost:Connect(function(enter)
                if enter and cb then cb(box.Text) end
            end)
        end

        -- ── dropdown ─────────────────────────────────────────────
        function tab:adddropdown(cfg)
            cfg = cfg or {}
            local txt    = cfg.title    or "dropdown"
            local values = cfg.values   or {}
            local cb     = cfg.callback

            local container = Instance.new("Frame")
            container.Size = UDim2.new(1,0,0,40); container.BackgroundColor3 = DARK3
            container.BorderSizePixel = 0; container.ClipsDescendants = false; container.ZIndex = 5; container.Parent = page
            makecorner(UDim.new(0,6), container)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-10,0,16); lbl.Position = UDim2.new(0,10,0,2)
            lbl.BackgroundTransparency = 1; lbl.Text = txt
            lbl.TextColor3 = GREY1; lbl.TextSize = 10; lbl.Font = Enum.Font.GothamSemibold
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5; lbl.Parent = container

            local dbtn = Instance.new("TextButton")
            dbtn.Size = UDim2.new(1,-16,0,22); dbtn.Position = UDim2.new(0,8,0,18)
            dbtn.BackgroundColor3 = DARK4; dbtn.Text = (values[1] or "none").."  ▾"
            dbtn.TextColor3 = GREY3; dbtn.TextSize = 12; dbtn.Font = Enum.Font.GothamSemibold
            dbtn.BorderSizePixel = 0; dbtn.AutoButtonColor = false; dbtn.ZIndex = 6; dbtn.Parent = container
            makecorner(UDim.new(0,5), dbtn)
            local dbtns = makestroke(accentcolor, 1, dbtn)
            regaccent(dbtns, "Color")

            local ddframe = Instance.new("Frame")
            ddframe.BackgroundColor3 = DARK4; ddframe.BorderSizePixel = 0
            ddframe.ZIndex = 200; ddframe.Visible = false; ddframe.ClipsDescendants = true
            ddframe.Size = UDim2.new(0,0,0,0); ddframe.Position = UDim2.new(0,0,0,0)
            ddframe.Parent = screengui
            makecorner(UDim.new(0,6), ddframe)
            local ddlayout = Instance.new("UIListLayout")
            ddlayout.SortOrder = Enum.SortOrder.LayoutOrder; ddlayout.Parent = ddframe
            local dds = makestroke(accentcolor, 1, ddframe)
            regaccent(dds, "Color")

            local isopen = false; local currentval = values[1] or "none"; local currentvals = values

            local function closeDD()
                isopen=false
                tweenservice:Create(ddframe,TweenInfo.new(0.12),{Size=UDim2.new(0,ddframe.AbsoluteSize.X,0,0)}):Play()
                task.delay(0.12,function() ddframe.Visible=false end)
                dbtn.Text = currentval.."  ▾"
            end

            local function setvalues(vals)
                currentvals=vals
                for _,c in ipairs(ddframe:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                for _,v in ipairs(vals) do
                    local opt = Instance.new("TextButton")
                    opt.Size = UDim2.new(1,0,0,26); opt.BackgroundColor3 = DARK4
                    opt.Text = v; opt.TextColor3 = v==currentval and accentcolor or GREY2
                    opt.TextSize = 12; opt.Font = Enum.Font.Gotham
                    opt.BorderSizePixel = 0; opt.AutoButtonColor = false; opt.ZIndex = 201; opt.Parent = ddframe
                    opt.MouseEnter:Connect(function() if opt.Text~=currentval then opt.BackgroundColor3=GREY6 end end)
                    opt.MouseLeave:Connect(function() opt.BackgroundColor3=DARK4 end)
                    opt.MouseButton1Click:Connect(function()
                        currentval=v; dbtn.Text=v.."  ▾"
                        for _,c2 in ipairs(ddframe:GetChildren()) do
                            if c2:IsA("TextButton") then c2.TextColor3 = c2.Text==currentval and accentcolor or GREY2 end
                        end
                        closeDD(); if cb then cb(v) end
                    end)
                end
            end
            setvalues(values)

            dbtn.MouseButton1Click:Connect(function()
                isopen=not isopen
                if isopen then
                    local ap=dbtn.AbsolutePosition; local as=dbtn.AbsoluteSize
                    local totalH=math.min(#currentvals,8)*26
                    ddframe.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+2)
                    ddframe.Size=UDim2.new(0,as.X,0,0); ddframe.Visible=true
                    tweenservice:Create(ddframe,TweenInfo.new(0.12),{Size=UDim2.new(0,as.X,0,totalH)}):Play()
                    dbtn.Text=currentval.."  ▴"
                else closeDD() end
            end)
            uis.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 and isopen then
                    local mx,my=inp.Position.X,inp.Position.Y
                    local ap=ddframe.AbsolutePosition; local as=ddframe.AbsoluteSize
                    local bap=dbtn.AbsolutePosition; local bas=dbtn.AbsoluteSize
                    if not(mx>=ap.X and mx<=ap.X+as.X and my>=ap.Y and my<=ap.Y+as.Y)
                    and not(mx>=bap.X and mx<=bap.X+bas.X and my>=bap.Y and my<=bap.Y+bas.Y) then closeDD() end
                end
            end)
            return { setvalues=setvalues }
        end

        -- ── keybind ──────────────────────────────────────────────
        function tab:addkeybind(cfg)
            cfg = cfg or {}
            local txt        = cfg.title   or "keybind"
            local defaultkey = cfg.default or "none"
            local cb         = cfg.callback

            local currentkey = defaultkey; local togstate=false; local listening=false
            local togbg,circle

            local function settogtoggle(v)
                togstate=v
                if circle and circle.Parent then
                    tweenservice:Create(circle,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)}):Play()
                    tweenservice:Create(circle,TweenInfo.new(0.12),{BackgroundColor3=v and WHITE or GREY1}):Play()
                end
                if togbg and togbg.Parent then
                    tweenservice:Create(togbg,TweenInfo.new(0.12),{BackgroundColor3=v and accentcolor or GREY5}):Play()
                end
                if cb then cb(v) end
            end

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,32); row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0; row.Parent = page
            makecorner(UDim.new(0,6), row)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-110,1,0); lbl.Position = UDim2.new(0,10,0,0)
            lbl.BackgroundTransparency = 1; lbl.Text = txt
            lbl.TextColor3 = GREY2; lbl.TextSize = 12; lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = row

            togbg = Instance.new("Frame")
            togbg.Size = UDim2.new(0,36,0,18); togbg.Position = UDim2.new(1,-108,0.5,-9)
            togbg.BackgroundColor3 = GREY5; togbg.BorderSizePixel = 0; togbg.Parent = row
            makecorner(UDim.new(1,0), togbg)

            circle = Instance.new("Frame")
            circle.Size = UDim2.new(0,12,0,12); circle.Position = UDim2.new(0,3,0.5,-6)
            circle.BackgroundColor3 = GREY1; circle.BorderSizePixel = 0; circle.Parent = togbg
            makecorner(UDim.new(1,0), circle)

            local kbtn = Instance.new("TextButton")
            kbtn.Size = UDim2.new(0,58,0,20); kbtn.Position = UDim2.new(1,-62,0.5,-10)
            kbtn.BackgroundColor3 = GREY6; kbtn.Text = currentkey=="none" and "[ - ]" or ("["..string.lower(currentkey).."]")
            kbtn.TextColor3 = GREY1; kbtn.TextSize = 10; kbtn.Font = Enum.Font.GothamSemibold
            kbtn.BorderSizePixel = 0; kbtn.Parent = row
            makecorner(UDim.new(0,4), kbtn)
            makestroke(GREY7, 1, kbtn)

            kbtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening=true; kbtn.Text="[ ... ]"; kbtn.TextColor3=accentcolor; kbtn.BackgroundColor3=Color3.fromRGB(20,10,10)
            end)
            kbtn.MouseButton2Click:Connect(function()
                currentkey="none"; kbtn.Text="[ - ]"; kbtn.TextColor3=GREY1; kbtn.BackgroundColor3=GREY6
            end)

            local rowclick = Instance.new("TextButton")
            rowclick.Size = UDim2.new(1,-116,1,0); rowclick.BackgroundTransparency=1; rowclick.Text=""
            rowclick.ZIndex=2; rowclick.Parent=row
            rowclick.MouseButton1Click:Connect(function() if not listening then settogtoggle(not togstate) end end)

            uis.InputBegan:Connect(function(inp,gpe)
                if listening then
                    if inp.UserInputType==Enum.UserInputType.Keyboard then
                        listening=false; currentkey=inp.KeyCode.Name
                        kbtn.Text="["..string.lower(currentkey).."]"; kbtn.TextColor3=GREY1; kbtn.BackgroundColor3=GREY6
                    elseif inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.MouseButton2 then
                        listening=false
                        kbtn.Text=currentkey=="none" and "[ - ]" or ("["..string.lower(currentkey).."]")
                        kbtn.TextColor3=GREY1; kbtn.BackgroundColor3=GREY6
                    end
                    return
                end
                if not gpe and inp.UserInputType==Enum.UserInputType.Keyboard and currentkey~="none" and inp.KeyCode.Name==currentkey then
                    settogtoggle(not togstate)
                end
            end)

            table.insert(keybindregistry,{title=txt,getkey=function() return currentkey end,getstate=function() return togstate end})
            return settogtoggle
        end

        -- ── section label ────────────────────────────────────────
        function tab:addsection(txt)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,0,0,18); lbl.BackgroundTransparency = 1
            lbl.Text = txt; lbl.TextColor3 = accentcolor; lbl.TextSize = 11
            lbl.Font = Enum.Font.GothamBold; lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.BorderSizePixel = 0; lbl.Parent = page
            makepad(0,4,0,0,lbl)
            regaccent(lbl, "TextColor3")
        end

        -- ── color picker ─────────────────────────────────────────
        function tab:addcolorpicker(cfg)
            cfg = cfg or {}
            local txt     = cfg.title    or "color"
            local default = cfg.default  or Color3.new(1,1,1)
            local cb      = cfg.callback
            local h,s,v = Color3.toHSV(default)

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,30); row.BackgroundColor3 = DARK3
            row.BorderSizePixel = 0; row.Parent = page
            makecorner(UDim.new(0,6), row)

            local lbl = Instance.new("TextLabel")
            lbl.Size=UDim2.new(1,-48,1,0); lbl.Position=UDim2.new(0,10,0,0)
            lbl.BackgroundTransparency=1; lbl.Text=txt; lbl.TextColor3=GREY2
            lbl.TextSize=12; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row

            local swatch = Instance.new("TextButton")
            swatch.Size=UDim2.new(0,22,0,22); swatch.Position=UDim2.new(1,-34,0.5,-11)
            swatch.BackgroundColor3=default; swatch.Text=""; swatch.BorderSizePixel=0; swatch.Parent=row
            makecorner(UDim.new(0,4),swatch); makestroke(GREY7,1,swatch)

            local popup = Instance.new("Frame")
            popup.Size=UDim2.new(0,220,0,230); popup.BackgroundColor3=Color3.fromRGB(14,14,14)
            popup.BorderSizePixel=0; popup.ZIndex=200; popup.Visible=false; popup.Parent=screengui
            makecorner(UDim.new(0,8),popup)
            local pstroke=makestroke(accentcolor,1,popup); regaccent(pstroke,"Color")

            local ptitle=Instance.new("TextLabel")
            ptitle.Size=UDim2.new(1,-8,0,22); ptitle.Position=UDim2.new(0,8,0,4)
            ptitle.BackgroundTransparency=1; ptitle.Text=txt; ptitle.TextColor3=GREY2
            ptitle.TextSize=11; ptitle.Font=Enum.Font.GothamBold
            ptitle.TextXAlignment=Enum.TextXAlignment.Left; ptitle.ZIndex=201; ptitle.Parent=popup

            local pclosebtn=Instance.new("TextButton")
            pclosebtn.Size=UDim2.new(0,18,0,18); pclosebtn.Position=UDim2.new(1,-22,0,4)
            pclosebtn.BackgroundColor3=Color3.fromRGB(60,10,10); pclosebtn.Text="✕"
            pclosebtn.TextColor3=WHITE; pclosebtn.TextSize=9; pclosebtn.Font=Enum.Font.GothamBold
            pclosebtn.BorderSizePixel=0; pclosebtn.ZIndex=202; pclosebtn.Parent=popup
            makecorner(UDim.new(0,4),pclosebtn)
            pclosebtn.MouseButton1Click:Connect(function() popup.Visible=false end)

            local canvas=Instance.new("ImageLabel")
            canvas.Size=UDim2.new(0,180,0,130); canvas.Position=UDim2.new(0,10,0,30)
            canvas.BackgroundColor3=Color3.new(1,0,0); canvas.Image="rbxassetid://4155801252"
            canvas.ZIndex=201; canvas.Parent=popup; makecorner(UDim.new(0,4),canvas)

            local huebar=Instance.new("ImageLabel")
            huebar.Size=UDim2.new(0,180,0,12); huebar.Position=UDim2.new(0,10,0,166)
            huebar.Image="rbxassetid://698052001"; huebar.ZIndex=201; huebar.Parent=popup
            makecorner(UDim.new(0,3),huebar)

            local brightbar=Instance.new("Frame")
            brightbar.Size=UDim2.new(0,180,0,12); brightbar.Position=UDim2.new(0,10,0,182)
            brightbar.BackgroundColor3=Color3.new(1,1,1); brightbar.ZIndex=201; brightbar.Parent=popup
            makecorner(UDim.new(0,3),brightbar)
            local bg2=Instance.new("UIGradient")
            bg2.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}
            bg2.Rotation=0; bg2.Parent=brightbar

            local cursor=Instance.new("Frame")
            cursor.Size=UDim2.new(0,10,0,10); cursor.AnchorPoint=Vector2.new(0.5,0.5)
            cursor.BackgroundColor3=WHITE; cursor.BorderSizePixel=0; cursor.ZIndex=203; cursor.Parent=canvas
            makecorner(UDim.new(1,0),cursor); makestroke(DARK,1,cursor)

            local huecursor=Instance.new("Frame")
            huecursor.Size=UDim2.new(0,4,1,2); huecursor.AnchorPoint=Vector2.new(0.5,0.5)
            huecursor.Position=UDim2.new(0,0,0.5,0); huecursor.BackgroundColor3=WHITE
            huecursor.BorderSizePixel=0; huecursor.ZIndex=203; huecursor.Parent=huebar
            makecorner(UDim.new(0,2),huecursor); makestroke(DARK,1,huecursor)

            local brightcursor=Instance.new("Frame")
            brightcursor.Size=UDim2.new(0,4,1,2); brightcursor.AnchorPoint=Vector2.new(0.5,0.5)
            brightcursor.Position=UDim2.new(1,0,0.5,0); brightcursor.BackgroundColor3=WHITE
            brightcursor.BorderSizePixel=0; brightcursor.ZIndex=203; brightcursor.Parent=brightbar
            makecorner(UDim.new(0,2),brightcursor); makestroke(DARK,1,brightcursor)

            local hexrow=Instance.new("Frame")
            hexrow.Size=UDim2.new(0,180,0,22); hexrow.Position=UDim2.new(0,10,0,198)
            hexrow.BackgroundTransparency=1; hexrow.ZIndex=201; hexrow.Parent=popup

            local hexprefix=Instance.new("TextLabel")
            hexprefix.Size=UDim2.new(0,16,1,0); hexprefix.BackgroundTransparency=1; hexprefix.Text="#"
            hexprefix.TextColor3=GREY1; hexprefix.TextSize=11; hexprefix.Font=Enum.Font.GothamBold
            hexprefix.ZIndex=202; hexprefix.Parent=hexrow

            local hexbox=Instance.new("TextBox")
            hexbox.Size=UDim2.new(0,90,1,0); hexbox.Position=UDim2.new(0,16,0,0)
            hexbox.BackgroundColor3=DARK2; hexbox.Text="FFFFFF"; hexbox.TextColor3=GREY2
            hexbox.TextSize=11; hexbox.Font=Enum.Font.GothamSemibold
            hexbox.BorderSizePixel=0; hexbox.ZIndex=202; hexbox.Parent=hexrow
            makestroke(GREY7,1,hexbox); makecorner(UDim.new(0,4),hexbox)

            local resultprev=Instance.new("Frame")
            resultprev.Size=UDim2.new(0,60,0,20); resultprev.Position=UDim2.new(0,116,0,1)
            resultprev.BackgroundColor3=default; resultprev.BorderSizePixel=0
            resultprev.ZIndex=202; resultprev.Parent=hexrow
            makecorner(UDim.new(0,4),resultprev); makestroke(GREY7,1,resultprev)

            local function c3hex(c)
                return string.format("%02X%02X%02X",math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5))
            end
            local function hexc3(hex)
                hex=hex:gsub("#",""):sub(1,6); if #hex<6 then return nil end
                local r=tonumber(hex:sub(1,2),16); local g=tonumber(hex:sub(3,4),16); local b=tonumber(hex:sub(5,6),16)
                if not r or not g or not b then return nil end; return Color3.fromRGB(r,g,b)
            end

            local function applycolor()
                local col=Color3.fromHSV(h,s,v)
                swatch.BackgroundColor3=col; resultprev.BackgroundColor3=col
                canvas.BackgroundColor3=Color3.fromHSV(h,1,1)
                brightbar.BackgroundColor3=Color3.fromHSV(h,s,1)
                hexbox.Text=c3hex(col)
                cursor.Position=UDim2.new(s,0,1-v,0)
                huecursor.Position=UDim2.new(h,0,0.5,0)
                brightcursor.Position=UDim2.new(v,0,0.5,0)
                if cb then cb(col) end
            end

            swatch.MouseButton1Click:Connect(function()
                if popup.Visible then popup.Visible=false; return end
                local ap=swatch.AbsolutePosition; local vp=workspace.CurrentCamera.ViewportSize
                local px=math.clamp(ap.X-10,0,vp.X-225); local py=math.clamp(ap.Y+28,0,vp.Y-235)
                popup.Position=UDim2.new(0,px,0,py); popup.Visible=true; applycolor()
            end)

            local dragmode=nil
            canvas.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragmode="sv"; local rel=uis:GetMouseLocation()-canvas.AbsolutePosition; s=math.clamp(rel.X/canvas.AbsoluteSize.X,0,1); v=1-math.clamp(rel.Y/canvas.AbsoluteSize.Y,0,1); applycolor() end end)
            huebar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragmode="hue"; local rel=uis:GetMouseLocation()-huebar.AbsolutePosition; h=math.clamp(rel.X/huebar.AbsoluteSize.X,0,1); applycolor() end end)
            brightbar.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragmode="bright"; local rel=uis:GetMouseLocation()-brightbar.AbsolutePosition; v=math.clamp(rel.X/brightbar.AbsoluteSize.X,0,1); applycolor() end end)
            uis.InputChanged:Connect(function(inp)
                if inp.UserInputType~=Enum.UserInputType.MouseMovement or not dragmode or not popup.Visible then return end
                local mp=uis:GetMouseLocation()
                if dragmode=="sv" then local rel=mp-canvas.AbsolutePosition; s=math.clamp(rel.X/canvas.AbsoluteSize.X,0,1); v=1-math.clamp(rel.Y/canvas.AbsoluteSize.Y,0,1); applycolor()
                elseif dragmode=="hue" then local rel=mp-huebar.AbsolutePosition; h=math.clamp(rel.X/huebar.AbsoluteSize.X,0,1); applycolor()
                elseif dragmode=="bright" then local rel=mp-brightbar.AbsolutePosition; v=math.clamp(rel.X/brightbar.AbsoluteSize.X,0,1); applycolor() end
            end)
            uis.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragmode=nil end end)
            hexbox.FocusLost:Connect(function() local c=hexc3(hexbox.Text); if c then h,s,v=Color3.toHSV(c); applycolor() end end)
            applycolor()
        end

        -- ── Settings helpers ──────────────────────────────────────
        function tab:addthemepicker()
            self:addsection("accent color")
            self:addcolorpicker({
                title   = "accent color",
                default = accentcolor,
                callback = function(col)
                    updatetheme(col)
                    yesbtn.BackgroundColor3 = col
                end,
            })
        end

        function tab:addblurslider()
            self:addsection("background blur")
            local row = Instance.new("Frame")
            row.Size=UDim2.new(1,0,0,30); row.BackgroundColor3=DARK3; row.BorderSizePixel=0; row.Parent=page
            makecorner(UDim.new(0,6),row)

            local togtitle=Instance.new("TextLabel")
            togtitle.Size=UDim2.new(1,-50,1,0); togtitle.Position=UDim2.new(0,10,0,0)
            togtitle.BackgroundTransparency=1; togtitle.Text="enable blur"
            togtitle.TextColor3=GREY3; togtitle.TextSize=12; togtitle.Font=Enum.Font.Gotham
            togtitle.TextXAlignment=Enum.TextXAlignment.Left; togtitle.Parent=row

            local togbg2=Instance.new("Frame")
            togbg2.Size=UDim2.new(0,36,0,18); togbg2.Position=UDim2.new(1,-44,0.5,-9)
            togbg2.BackgroundColor3=GREY5; togbg2.BorderSizePixel=0; togbg2.Parent=row
            makecorner(UDim.new(1,0),togbg2)
            local circle2=Instance.new("Frame")
            circle2.Size=UDim2.new(0,12,0,12); circle2.Position=UDim2.new(0,3,0.5,-6)
            circle2.BackgroundColor3=GREY1; circle2.BorderSizePixel=0; circle2.Parent=togbg2
            makecorner(UDim.new(1,0),circle2)

            local function setblurtog(val)
                blurenabled=val
                tweenservice:Create(circle2,TweenInfo.new(0.12),{Position=val and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)}):Play()
                tweenservice:Create(togbg2,TweenInfo.new(0.12),{BackgroundColor3=val and accentcolor or GREY5}):Play()
                tweenservice:Create(circle2,TweenInfo.new(0.12),{BackgroundColor3=val and WHITE or GREY1}):Play()
                if val and mainframe.Visible then blureffect.Size=0; blureffect.Enabled=true; tweenservice:Create(blureffect,TweenInfo.new(0.25),{Size=blurintensity}):Play()
                else tweenservice:Create(blureffect,TweenInfo.new(0.25),{Size=0}):Play(); task.delay(0.25,function() blureffect.Enabled=false end) end
            end
            local cb2=Instance.new("TextButton"); cb2.Size=UDim2.new(1,0,1,0); cb2.BackgroundTransparency=1; cb2.Text=""; cb2.Parent=row
            cb2.MouseButton1Click:Connect(function() setblurtog(not blurenabled) end)

            local lbl2=Instance.new("TextLabel"); lbl2.Size=UDim2.new(1,0,0,18); lbl2.BackgroundTransparency=1
            lbl2.Text="blur intensity: 20"; lbl2.TextColor3=GREY1; lbl2.TextSize=11; lbl2.Font=Enum.Font.Gotham
            lbl2.TextXAlignment=Enum.TextXAlignment.Left; lbl2.BorderSizePixel=0; lbl2.Parent=page
            makepad(0,4,0,0,lbl2)

            local track2=Instance.new("Frame"); track2.Size=UDim2.new(1,-8,0,5); track2.BackgroundColor3=GREY4; track2.BorderSizePixel=0; track2.Parent=page
            makecorner(UDim.new(1,0),track2)
            local fill2=Instance.new("Frame"); fill2.Size=UDim2.new(0.36,0,1,0); fill2.BackgroundColor3=accentcolor; fill2.BorderSizePixel=0; fill2.Parent=track2
            makecorner(UDim.new(1,0),fill2); regaccent(fill2,"BackgroundColor3")
            local knob2=Instance.new("Frame"); knob2.Size=UDim2.new(0,11,0,11); knob2.Position=UDim2.new(1,-5,0.5,-5)
            knob2.BackgroundColor3=Color3.fromRGB(230,230,230); knob2.BorderSizePixel=0; knob2.Parent=fill2
            makecorner(UDim.new(1,0),knob2)

            local bluractive=false
            local function updateblur(ix)
                local rel=math.clamp((ix-track2.AbsolutePosition.X)/track2.AbsoluteSize.X,0,1)
                fill2.Size=UDim2.new(rel,0,1,0); blurintensity=math.floor(rel*56+0.5)
                lbl2.Text="blur intensity: "..blurintensity
                if blurenabled and mainframe.Visible then blureffect.Size=blurintensity end
            end
            track2.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then bluractive=true; updateblur(inp.Position.X) end end)
            knob2.InputBegan:Connect(function(inp)  if inp.UserInputType==Enum.UserInputType.MouseButton1 then bluractive=true end end)
            uis.InputEnded:Connect(function(inp)    if inp.UserInputType==Enum.UserInputType.MouseButton1 then bluractive=false end end)
            uis.InputChanged:Connect(function(inp)  if bluractive and inp.UserInputType==Enum.UserInputType.MouseMovement then updateblur(inp.Position.X) end end)
        end

        function tab:addtransparencyslider()
            self:addsection("transparency")
            local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,18); lbl.BackgroundTransparency=1
            lbl.Text="transparency: 0%"; lbl.TextColor3=GREY1; lbl.TextSize=11; lbl.Font=Enum.Font.Gotham
            lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.BorderSizePixel=0; lbl.Parent=page
            makepad(0,4,0,0,lbl)

            local track=Instance.new("Frame"); track.Size=UDim2.new(1,-8,0,5); track.BackgroundColor3=GREY4; track.BorderSizePixel=0; track.Parent=page
            makecorner(UDim.new(1,0),track)
            local fill=Instance.new("Frame"); fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=accentcolor; fill.BorderSizePixel=0; fill.Parent=track
            makecorner(UDim.new(1,0),fill); regaccent(fill,"BackgroundColor3")
            local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,11,0,11); knob.Position=UDim2.new(1,-5,0.5,-5)
            knob.BackgroundColor3=Color3.fromRGB(230,230,230); knob.BorderSizePixel=0; knob.Parent=fill
            makecorner(UDim.new(1,0),knob)

            local transactive=false
            local function updatetrans(ix)
                local rel=math.clamp((ix-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                fill.Size=UDim2.new(rel,0,1,0); lbl.Text="transparency: "..math.floor(rel*100).."%"
                mainframe.BackgroundTransparency=rel*0.88
            end
            track.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then transactive=true; updatetrans(inp.Position.X) end end)
            knob.InputBegan:Connect(function(inp)  if inp.UserInputType==Enum.UserInputType.MouseButton1 then transactive=true end end)
            uis.InputEnded:Connect(function(inp)   if inp.UserInputType==Enum.UserInputType.MouseButton1 then transactive=false end end)
            uis.InputChanged:Connect(function(inp) if transactive and inp.UserInputType==Enum.UserInputType.MouseMovement then updatetrans(inp.Position.X) end end)
        end

        function tab:addkeybindlist()
            self:addsection("registered keybinds")
            local lc=Instance.new("Frame"); lc.Size=UDim2.new(1,0,0,28)
            lc.BackgroundColor3=DARK3; lc.BorderSizePixel=0; lc.ClipsDescendants=true; lc.Parent=page
            makecorner(UDim.new(0,6),lc)
            local ll=Instance.new("UIListLayout"); ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,2); ll.Parent=lc
            makepad(4,8,8,4,lc)

            local function rebuild()
                for _,c in ipairs(lc:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                local shown=0
                for _,entry in ipairs(keybindregistry) do
                    shown+=1; local isactive=entry.getstate()
                    local r2=Instance.new("Frame"); r2.Size=UDim2.new(1,0,0,24); r2.BackgroundTransparency=1; r2.BorderSizePixel=0; r2.Parent=lc
                    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(0,0,0.5,-3)
                    dot.BackgroundColor3=isactive and accentcolor or GREY5; dot.BorderSizePixel=0; dot.Parent=r2
                    makecorner(UDim.new(1,0),dot)
                    local kl=Instance.new("TextLabel"); kl.Size=UDim2.new(0,72,1,0); kl.Position=UDim2.new(0,12,0,0)
                    kl.BackgroundTransparency=1; kl.Text="["..string.lower(entry.getkey()).."]"
                    kl.TextColor3=isactive and accentcolor or GREY2; kl.TextSize=10; kl.Font=Enum.Font.GothamSemibold; kl.Parent=r2
                    local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(1,-88,1,0); tl.Position=UDim2.new(0,88,0,0)
                    tl.BackgroundTransparency=1; tl.Text=entry.title; tl.TextColor3=isactive and GREY3 or GREY1
                    tl.TextSize=10; tl.Font=Enum.Font.Gotham; tl.TextXAlignment=Enum.TextXAlignment.Left
                    tl.TextTruncate=Enum.TextTruncate.AtEnd; tl.Parent=r2
                end
                ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    lc.Size=UDim2.new(1,0,0,ll.AbsoluteContentSize.Y+8)
                end)
                if shown==0 then lc.Size=UDim2.new(1,0,0,28)
                    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,-16,1,0); nl.Position=UDim2.new(0,8,0,0)
                    nl.BackgroundTransparency=1; nl.Text="no keybinds registered"; nl.TextColor3=GREY7
                    nl.TextSize=10; nl.Font=Enum.Font.Gotham; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=lc
                else lc.Size=UDim2.new(1,0,0,shown*26+8) end
            end
            rebuild()
            task.spawn(function() while screengui.Parent do task.wait(0.5); rebuild() end end)
        end

        function tab:addkeybindsetting(cfg)
            cfg = cfg or {}
            local txt = cfg.title or "toggle ui key"
            self:addsection(txt)
            local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,30)
            row.BackgroundColor3=DARK3; row.BorderSizePixel=0; row.Parent=page
            makecorner(UDim.new(0,6),row)

            local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,-100,1,0); lbl.Position=UDim2.new(0,10,0,0)
            lbl.BackgroundTransparency=1; lbl.Text="press to rebind"; lbl.TextColor3=GREY2
            lbl.TextSize=12; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row

            local kbtn=Instance.new("TextButton"); kbtn.Size=UDim2.new(0,88,0,22); kbtn.Position=UDim2.new(1,-94,0.5,-11)
            kbtn.BackgroundColor3=GREY6; kbtn.Text="[ "..string.lower(currenttogglekey.Name).." ]"
            kbtn.TextColor3=GREY2; kbtn.TextSize=11; kbtn.Font=Enum.Font.GothamSemibold
            kbtn.BorderSizePixel=0; kbtn.Parent=row
            makecorner(UDim.new(0,4),kbtn); makestroke(GREY7,1,kbtn)

            kbtn.MouseButton1Click:Connect(function()
                listeningforkey=true; kbtn.Text="[ ... ]"; kbtn.TextColor3=accentcolor
            end)
            uis.InputBegan:Connect(function(inp)
                if listeningforkey and inp.UserInputType==Enum.UserInputType.Keyboard then
                    listeningforkey=false; currenttogglekey=inp.KeyCode
                    kbtn.Text="[ "..string.lower(inp.KeyCode.Name).." ]"; kbtn.TextColor3=GREY2
                end
            end)
        end

        return tab
    end

    function window:notify(msg) sendnotif(msg) end
    function window:selecttab(name) selecttab(name) end
    return window
end

return multihubx
