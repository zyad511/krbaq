local DEFAULT_BG_URL = "https://cdn.discordapp.com/attachments/1393885394738610176/1514650458986385459/content.png?ex=6a2c23aa&is=6a2ad22a&hm=062fc9c0e0428b58d3f3248fb45e191ecde57dfb5f3eda50cf26e90f807ecd86&"
local env = getgenv and getgenv() or _G
if type(env.KRB_Unload) == "function" then
    pcall(env.KRB_Unload)
    task.wait(0.5) 
end
env.KRB_Running = true
env.KRB_Binds = {}
env.KRB_CurrentMenuKey = Enum.KeyCode.LeftControl

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "KRB Hub",
        Text = "Loading interface... Please wait.",
        Duration = 5
    })
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local successFluent, Fluent = pcall(function() return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))() end)
local successSave, SaveManager = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))() end)
local successInterface, InterfaceManager = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))() end)

if not successFluent or not Fluent then
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "ERROR", Text = "Failed to download interface. Enable VPN!", Duration = 10 })
    return
end

local HUDGui = Instance.new("ScreenGui")
HUDGui.Name = "KRBHub_HUD"
HUDGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() HUDGui.Parent = game:GetService("CoreGui") end)
env.KRB_HUD = HUDGui

local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local Watermark = Instance.new("TextLabel")
Watermark.Name = "Watermark"
Watermark.Size = UDim2.new(0, 200, 0, 25)
Watermark.Position = UDim2.new(0, 10, 0, 10)
Watermark.BackgroundColor3 = Color3.fromRGB(120, 0, 60)
Watermark.BackgroundTransparency = 0.5 
Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 14
Watermark.Text = "KRB Hub"
Watermark.Active = true
Watermark.Parent = HUDGui

local wCorner = Instance.new("UICorner")
wCorner.CornerRadius = UDim.new(0, 6)
wCorner.Parent = Watermark

local wStroke = Instance.new("UIStroke")
wStroke.Color = Color3.fromRGB(255, 80, 150)
wStroke.Parent = Watermark
MakeDraggable(Watermark)

local currentFPS = 0
local frames = 0
RunService.RenderStepped:Connect(function() frames = frames + 1 end)

task.spawn(function()
    while env.KRB_Running do
        currentFPS = frames
        frames = 0
        task.wait(1)
    end
end)

task.spawn(function()
    while env.KRB_Running do
        task.wait(0.5)
        local timeStr = os.date("%H:%M:%S")
        local ping = "0"
        pcall(function() ping = tostring(math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())) end)
        Watermark.Text = string.format(" KRB Hub | %s | FPS: %d | Ping: %sms ", timeStr, currentFPS, ping)
        Watermark.Size = UDim2.new(0, Watermark.TextBounds.X + 20, 0, 25)
    end
end)

local KeybindsHUD = Instance.new("Frame")
KeybindsHUD.Size = UDim2.new(0, 150, 0, 25)
KeybindsHUD.Position = UDim2.new(0, 10, 0, 45)
KeybindsHUD.BackgroundColor3 = Color3.fromRGB(120, 0, 60)
KeybindsHUD.BackgroundTransparency = 0.5 
KeybindsHUD.Active = true
KeybindsHUD.Parent = HUDGui

local kbCorner = Instance.new("UICorner")
kbCorner.CornerRadius = UDim.new(0, 6)
kbCorner.Parent = KeybindsHUD

local kbStroke = Instance.new("UIStroke")
kbStroke.Color = Color3.fromRGB(255, 80, 150)
kbStroke.Parent = KeybindsHUD
MakeDraggable(KeybindsHUD)

local KbTitle = Instance.new("TextLabel")
KbTitle.Size = UDim2.new(1, 0, 0, 25)
KbTitle.BackgroundTransparency = 1
KbTitle.Text = " Keybinds "
KbTitle.TextColor3 = Color3.fromRGB(255, 150, 200)
KbTitle.Font = Enum.Font.GothamBold
KbTitle.TextSize = 14
KbTitle.Parent = KeybindsHUD

local KbList = Instance.new("Frame")
KbList.Position = UDim2.new(0, 0, 0, 25)
KbList.Size = UDim2.new(1, 0, 1, -25)
KbList.BackgroundTransparency = 1
KbList.Parent = KeybindsHUD

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = KbList

local IslandWrapper = Instance.new("Frame")
IslandWrapper.Name = "DynamicIslandWrapper"
IslandWrapper.Size = UDim2.new(0, 200, 0, 35)
IslandWrapper.Position = UDim2.new(0.5, -100, 0, 10)
IslandWrapper.BackgroundTransparency = 1
IslandWrapper.Active = true
IslandWrapper.Parent = HUDGui

local function DragAndClickIsland(gui)
    local dragging, dragStart, startPos
    local hasDragged = false
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasDragged = false
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                hasDragged = true
                gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    gui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if not hasDragged then
                if type(env.KRB_ToggleMenu) == "function" then
                    env.KRB_ToggleMenu()
                end
            end
        end
    end)
end
DragAndClickIsland(IslandWrapper)

local IslandFrame = Instance.new("Frame")
IslandFrame.Name = "DynamicIsland"
IslandFrame.Size = UDim2.new(0, 100, 0, 30)
IslandFrame.Position = UDim2.new(0.5, -50, 0.5, -15)
IslandFrame.BackgroundColor3 = Color3.fromRGB(120, 0, 60)
IslandFrame.BackgroundTransparency = 0.2
IslandFrame.ClipsDescendants = true
IslandFrame.Parent = IslandWrapper

local IslandCorner = Instance.new("UICorner")
IslandCorner.CornerRadius = UDim.new(1, 0)
IslandCorner.Parent = IslandFrame

local isStroke = Instance.new("UIStroke")
isStroke.Color = Color3.fromRGB(255, 80, 150)
isStroke.Parent = IslandFrame

local IslandIcon = Instance.new("ImageLabel")
IslandIcon.Size = UDim2.new(0, 20, 0, 20)
IslandIcon.Position = UDim2.new(0, 10, 0.5, -10)
IslandIcon.BackgroundTransparency = 1
IslandIcon.Image = "rbxassetid://11422143468" 
IslandIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
IslandIcon.Parent = IslandFrame

local IslandText = Instance.new("TextLabel")
IslandText.Size = UDim2.new(1, -40, 1, 0)
IslandText.Position = UDim2.new(0, 35, 0, 0)
IslandText.BackgroundTransparency = 1
IslandText.TextColor3 = Color3.fromRGB(255, 255, 255)
IslandText.Font = Enum.Font.GothamMedium
IslandText.TextSize = 14
IslandText.Text = ""
IslandText.TextXAlignment = Enum.TextXAlignment.Left
IslandText.TextTransparency = 1
IslandText.Parent = IslandFrame

local islandQueue = {}
local isIslandAnimating = false
local isScriptFullyLoaded = false
task.delay(3, function() isScriptFullyLoaded = true end)

env.DynamicIslandNotify = function(text)
    if not isScriptFullyLoaded then return end 
    table.insert(islandQueue, text)
    if not isIslandAnimating then
        task.spawn(function()
            isIslandAnimating = true
            while #islandQueue > 0 do
                local msg = table.remove(islandQueue, 1)
                IslandText.Text = msg
                TweenService:Create(IslandFrame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
                TweenService:Create(IslandText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
                task.wait(2.5)
                TweenService:Create(IslandText, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
                local collapse = TweenService:Create(IslandFrame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0.5, -50, 0.5, -15)})
                collapse:Play()
                collapse.Completed:Wait()
                task.wait(0.2)
            end
            isIslandAnimating = false
        end)
    end
end

local BindScreen = Instance.new("Frame")
BindScreen.Size = UDim2.new(0, 250, 0, 140) 
BindScreen.AnchorPoint = Vector2.new(0.5, 0.5)
BindScreen.Position = UDim2.new(0.5, 0, 0.5, 0)
BindScreen.BackgroundColor3 = Color3.fromRGB(60, 0, 30)
BindScreen.BackgroundTransparency = 0.1
BindScreen.Visible = false
BindScreen.ZIndex = 9999
BindScreen.Parent = HUDGui

local bsCorner = Instance.new("UICorner")
bsCorner.CornerRadius = UDim.new(0, 16) 
bsCorner.Parent = BindScreen

local bsStroke = Instance.new("UIStroke")
bsStroke.Color = Color3.fromRGB(255, 80, 150)
bsStroke.Thickness = 2
bsStroke.Parent = BindScreen

local BindTitle = Instance.new("TextLabel")
BindTitle.Size = UDim2.new(1, 0, 0, 40)
BindTitle.Position = UDim2.new(0, 0, 0, 10)
BindTitle.BackgroundTransparency = 1
BindTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTitle.Font = Enum.Font.GothamBold
BindTitle.TextSize = 16
BindTitle.Text = "BIND MANAGER"
BindTitle.Parent = BindScreen

local BindDesc = Instance.new("TextLabel")
BindDesc.Size = UDim2.new(1, 0, 0, 30)
BindDesc.Position = UDim2.new(0, 0, 0, 45)
BindDesc.BackgroundTransparency = 1
BindDesc.TextColor3 = Color3.fromRGB(255, 150, 200)
BindDesc.Font = Enum.Font.GothamMedium
BindDesc.TextSize = 14
BindDesc.Text = "Waiting for input..."
BindDesc.Parent = BindScreen

local UnbindBtn = Instance.new("TextButton")
UnbindBtn.Size = UDim2.new(0, 120, 0, 30)
UnbindBtn.Position = UDim2.new(0.5, -60, 1, -40)
UnbindBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
UnbindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnbindBtn.Font = Enum.Font.GothamBold
UnbindBtn.TextSize = 12
UnbindBtn.Text = "UNBIND"
UnbindBtn.Parent = BindScreen

local ubCorner = Instance.new("UICorner")
ubCorner.CornerRadius = UDim.new(0, 8)
ubCorner.Parent = UnbindBtn

local isBinding = false
local currentBindToggle = nil

local function CloseBindMenu()
    isBinding = false
    local uiScale = BindScreen:FindFirstChild("BindScale")
    if uiScale then
        local tw = TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
        tw:Play()
        task.delay(0.25, function() BindScreen.Visible = false end)
    else
        BindScreen.Visible = false
    end
end

local function OpenBindMenu(name, toggleObj)
    currentBindToggle = toggleObj
    BindTitle.Text = string.upper(name)
    BindDesc.Text = "Waiting for input..."
    local uiScale = BindScreen:FindFirstChild("BindScale")
    if not uiScale then uiScale = Instance.new("UIScale", BindScreen) uiScale.Name = "BindScale" end
    BindScreen.Visible = true
    uiScale.Scale = 0
    TweenService:Create(uiScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    isBinding = true
end

UnbindBtn.MouseButton1Click:Connect(function()
    if currentBindToggle then
        for k, v in pairs(env.KRB_Binds) do
            if v == currentBindToggle then env.KRB_Binds[k] = nil end
        end
    end
    CloseBindMenu()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == env.KRB_CurrentMenuKey then
        if type(env.KRB_ToggleMenu) == "function" then
            env.KRB_ToggleMenu()
        end
    end
    if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Escape then
            CloseBindMenu()
            return
        end
        for k, v in pairs(env.KRB_Binds) do
            if v == currentBindToggle then env.KRB_Binds[k] = nil end
        end
        env.KRB_Binds[input.KeyCode] = currentBindToggle
        BindDesc.Text = "Bound to: " .. input.KeyCode.Name
        task.wait(0.3)
        CloseBindMenu()
    elseif not gp and input.UserInputType == Enum.UserInputType.Keyboard then
        local toggle = env.KRB_Binds[input.KeyCode]
        if toggle then toggle:SetValue(not toggle.Value) end
    end
end)

local Window = Fluent:CreateWindow({
    Title = "KRB Hub",
    SubTitle = "Free Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.Unknown
})
env.KRB_Window = Window

task.spawn(function()
    while env.KRB_Running do
        task.wait(0.05)
        if env.KRB_Window and env.KRB_Window.MinimizeKey and env.KRB_Window.MinimizeKey ~= Enum.KeyCode.Unknown then
            env.KRB_CurrentMenuKey = env.KRB_Window.MinimizeKey
            env.KRB_Window.MinimizeKey = Enum.KeyCode.Unknown
        end
    end
end)

task.spawn(function()
    local coreGui = game:GetService("CoreGui")
    local windowFrame = nil
    for i = 1, 50 do
        for _, obj in ipairs(coreGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text == "Free Edition" then
                local p = obj.Parent
                while p and not p:IsA("ScreenGui") do
                    if p:IsA("Frame") and p.Size.X.Offset > 300 then windowFrame = p break end
                    p = p.Parent
                end
            end
        end
        if windowFrame then break end
        task.wait(0.1)
    end
    if windowFrame then
        local uiScale = windowFrame:FindFirstChild("KRBHub_UIScale")
        if not uiScale then
            uiScale = Instance.new("UIScale")
            uiScale.Name = "KRBHub_UIScale"
            uiScale.Parent = windowFrame
        end
        local krbHubIsAnimating = false
        windowFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if not env.KRB_Running then return end
            if krbHubIsAnimating then return end
            if not windowFrame.Visible and not windowFrame:GetAttribute("KRB_Hidden") then
                windowFrame.Visible = true
                if type(env.KRB_ToggleMenu) == "function" then env.KRB_ToggleMenu() end
            elseif windowFrame.Visible and windowFrame:GetAttribute("KRB_Hidden") then
                windowFrame.Visible = false
                if type(env.KRB_ToggleMenu) == "function" then env.KRB_ToggleMenu() end
            end
        end)
        env.KRB_AnimGuard = function(val) krbHubIsAnimating = val end
        
        task.spawn(function()
            task.wait(1)
            for _, btn in ipairs(windowFrame:GetDescendants()) do
                if btn:IsA("ImageButton") then
                    local isTopRight = (btn.AbsolutePosition.Y - windowFrame.AbsolutePosition.Y) < 50 and ((windowFrame.AbsolutePosition.X + windowFrame.AbsoluteSize.X) - btn.AbsolutePosition.X) < 100
                    if isTopRight then
                        local intercept = Instance.new("TextButton")
                        intercept.Size = UDim2.new(1, 4, 1, 4)
                        intercept.Position = UDim2.new(0, -2, 0, -2)
                        intercept.BackgroundTransparency = 1
                        intercept.Text = ""
                        intercept.ZIndex = 99999
                        intercept.Active = true
                        intercept.Modal = false
                        intercept.Parent = btn
                        intercept.MouseButton1Click:Connect(function()
                            if type(env.KRB_ToggleMenu) == "function" then env.KRB_ToggleMenu() end
                        end)
                    end
                end
            end
        end)

        local isAnimating = false
        env.KRB_ToggleMenu = function()
            if isAnimating then return end
            isAnimating = true
            if env.KRB_AnimGuard then env.KRB_AnimGuard(true) end
            local isHidden = windowFrame:GetAttribute("KRB_Hidden")
            if not isHidden then
                windowFrame:SetAttribute("KRB_Hidden", true)
                if env.DynamicIslandNotify then env.DynamicIslandNotify("Menu Hidden") end
                if windowFrame.AnchorPoint == Vector2.new(0, 0) then
                    local p = windowFrame.Position
                    local sX, sY = windowFrame.AbsoluteSize.X, windowFrame.AbsoluteSize.Y
                    windowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                    windowFrame.Position = UDim2.new(p.X.Scale, p.X.Offset + sX/2, p.Y.Scale, p.Y.Offset + sY/2)
                end
                windowFrame.Visible = true
                local tw = TweenService:Create(uiScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
                tw:Play()
                task.delay(0.35, function() 
                    windowFrame.Visible = false 
                    isAnimating = false
                    if env.KRB_AnimGuard then env.KRB_AnimGuard(false) end
                end)
            else
                windowFrame:SetAttribute("KRB_Hidden", false)
                if env.DynamicIslandNotify then env.DynamicIslandNotify("Menu Opened") end
                if windowFrame.AnchorPoint == Vector2.new(0, 0) then
                    local p = windowFrame.Position
                    local sX, sY = windowFrame.AbsoluteSize.X, windowFrame.AbsoluteSize.Y
                    windowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                    windowFrame.Position = UDim2.new(p.X.Scale, p.X.Offset + sX/2, p.Y.Scale, p.Y.Offset + sY/2)
                end
                uiScale.Scale = 0
                windowFrame.Visible = true
                local tw = TweenService:Create(uiScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
                tw:Play()
                task.delay(0.45, function() 
                    if windowFrame.AnchorPoint == Vector2.new(0.5, 0.5) then
                        local p = windowFrame.Position
                        local sX, sY = windowFrame.AbsoluteSize.X, windowFrame.AbsoluteSize.Y
                        windowFrame.AnchorPoint = Vector2.new(0, 0)
                        windowFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - sX/2, p.Y.Scale, p.Y.Offset - sY/2)
                    end
                    isAnimating = false
                    if env.KRB_AnimGuard then env.KRB_AnimGuard(false) end
                end)
            end
        end

        if not windowFrame:GetAttribute("KRB_ResizeInjected") then
            windowFrame:SetAttribute("KRB_ResizeInjected", true)
            local t = 8
            local edges = {
                Top =        { pos = UDim2.new(0, 0, 0, -t/2),      size = UDim2.new(1, 0, 0, t),       L=false, R=false, T=true, B=false },
                Bottom =     { pos = UDim2.new(0, 0, 1, -t/2),      size = UDim2.new(1, 0, 0, t),       L=false, R=false, T=false, B=true },
                Left =       { pos = UDim2.new(0, -t/2, 0, 0),      size = UDim2.new(0, t, 1, 0),       L=true, R=false, T=false, B=false },
                Right =      { pos = UDim2.new(1, -t/2, 0, 0),      size = UDim2.new(0, t, 1, 0),       L=false, R=true, T=false, B=false },
                TopLeft =    { pos = UDim2.new(0, -t/2, 0, -t/2),   size = UDim2.new(0, t, 0, t),       L=true, R=false, T=true, B=false },
                TopRight =   { pos = UDim2.new(1, -t/2, 0, -t/2),   size = UDim2.new(0, t, 0, t),       L=false, R=true, T=true, B=false },
                BottomLeft = { pos = UDim2.new(0, -t/2, 1, -t/2),   size = UDim2.new(0, t, 0, t),       L=true, R=false, T=false, B=true },
                BottomRight ={ pos = UDim2.new(1, -t/2, 1, -t/2),   size = UDim2.new(0, t, 0, t),       L=false, R=true, T=false, B=true },
            }
            for name, data in pairs(edges) do
                local edge = Instance.new("TextButton")
                edge.Name = "KRBHub_Resize_" .. name
                edge.Size = data.size
                edge.Position = data.pos
                edge.BackgroundTransparency = 1
                edge.Text = ""
                edge.ZIndex = 99999
                edge.Parent = windowFrame
                
                local dragging, dragStart, startSize, startPos
                edge.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startSize = windowFrame.AbsoluteSize
                        startPos = windowFrame.Position
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        local newX = startSize.X
                        local newY = startSize.Y
                        local posX = startPos.X.Offset
                        local posY = startPos.Y.Offset
                        if data.L then
                            newX = math.max(400, startSize.X - delta.X)
                            posX = startPos.X.Offset + (startSize.X - newX)
                        elseif data.R then
                            newX = math.max(400, startSize.X + delta.X)
                        end
                        if data.T then
                            newY = math.max(300, startSize.Y - delta.Y)
                            posY = startPos.Y.Offset + (startSize.Y - newY)
                        elseif data.B then
                            newY = math.max(300, startSize.Y + delta.Y)
                        end
                        windowFrame.Size = UDim2.fromOffset(newX, newY)
                        windowFrame.Position = UDim2.new(startPos.X.Scale, posX, startPos.Y.Scale, posY)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
            end
        end
    end
end)

local Tabs = {
    Discord = Window:AddTab({ Title = "Discord", Icon = "message-circle" }),
    Main = Window:AddTab({ Title = "Main", Icon = "swords" }),
    Auto = Window:AddTab({ Title = "Auto", Icon = "bot" }),
    ESP = Window:AddTab({ Title = "Zombie ESP", Icon = "eye" }),
    LocalPlayer = Window:AddTab({ Title = "Local Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
local Options = Fluent.Options

Tabs.Discord:AddButton({
    Title = "Join Discord Server",
    Description = "Copy the Discord invite link to your clipboard",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/yourlinkhere") end)
        Fluent:Notify({Title = "Copied!", Content = "Discord invite copied to clipboard.", Duration = 3})
    end
})

local t_KillAura = Tabs.Main:AddToggle("KillAura", {Title = "Rage Kill Aura", Default = false})
local s_KillDistance = Tabs.Main:AddSlider("KillDistance", {Title = "Aura Range", Default = 250, Min = 10, Max = 550, Rounding = 0})

local t_AutoShard = Tabs.Auto:AddToggle("AutoShard", {Title = "Vacuum Shards", Default = false})
local t_AutoSpin = Tabs.Auto:AddToggle("AutoSpin", {Title = "Auto Galactic Spin", Default = false})
local t_AutoUpgrade = Tabs.Auto:AddToggle("AutoUpgrade", {Title = "Auto Weapon Upgrade", Default = false})
local t_AutoHealthUpgrade = Tabs.Auto:AddToggle("AutoHealthUpgrade", {Title = "Auto Health Upgrade", Default = false})
local t_AutoEquip = Tabs.Auto:AddToggle("AutoEquip", {Title = "Auto Equip", Default = false})
local t_AutoExecute = Tabs.Auto:AddToggle("AutoExecute", {Title = "Auto Execute", Default = false, Description = "Auto-run KRB Hub on game join (5s delay)"})

t_AutoExecute:OnChanged(function()
    if env.DynamicIslandNotify then env.DynamicIslandNotify("Auto Execute: " .. (Options.AutoExecute.Value and "ON" or "OFF")) end
    pcall(function()
        if not writefile or not readfile or not isfile then return end
        if not isfolder("KRBHub") then makefolder("KRBHub") end
        local loaderCode = [[
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
if not LP then Players:GetPropertyChangedSignal("LocalPlayer"):Wait() LP = Players.LocalPlayer end
if not LP.Character then LP.CharacterAdded:Wait() end
task.wait(5)
pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="KRB Hub",Text="Auto-loading...",Duration=3}) end)
local ok, e = pcall(function()
    if isfile("KRBHub/krbhubnew.lua") then
        loadstring(readfile("KRBHub/krbhubnew.lua"))()
    elseif isfile("krbhubnew.lua") then
        loadstring(readfile("krbhubnew.lua"))()
    end
end)
if not ok then pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="KRB Hub ERROR",Text=tostring(e),Duration=10}) end) end
]]
        if Options.AutoExecute.Value then
            if not isfolder("autoexec") then makefolder("autoexec") end
            writefile("autoexec/krbhub_loader.lua", loaderCode)
            Fluent:Notify({
                Title = "Auto Execute",
                Content = "Loader saved to autoexec/krbhub_loader.lua\nMake sure your main script is saved as KRBHub/krbhubnew.lua in executor workspace!",
                Duration = 6
            })
        else
            if isfile("autoexec/krbhub_loader.lua") then
                delfile("autoexec/krbhub_loader.lua")
            end
            Fluent:Notify({
                Title = "Auto Execute",
                Content = "Loader removed from autoexec.",
                Duration = 3
            })
        end
    end)
end)

local t_Fly = Tabs.LocalPlayer:AddToggle("Fly", {Title = "Server Fly", Default = false})
local t_SafeArea = Tabs.LocalPlayer:AddToggle("SafeArea", {Title = "True Safe Area", Default = false})
local s_SafeHeight = Tabs.LocalPlayer:AddSlider("SafeAreaHeight", {Title = "Safe Area Height", Default = 20, Min = 10, Max = 150, Rounding = 0})
Tabs.LocalPlayer:AddSlider("WalkSpeed", {Title = "Walk Speed", Default = 16, Min = 16, Max = 150, Rounding = 0})
Tabs.LocalPlayer:AddSlider("JumpPower", {Title = "Jump Power", Default = 50, Min = 50, Max = 200, Rounding = 0})
Tabs.LocalPlayer:AddSlider("FlySpeed", {Title = "Fly Speed", Default = 50, Min = 10, Max = 200, Rounding = 0})
local fbToggle = Tabs.LocalPlayer:AddToggle("Fullbright", {Title = "Fullbright (Max Vision)", Default = false})

local espToggle = Tabs.ESP:AddToggle("ZombieEsp", {Title = "Zombie Highlight", Default = false})
Tabs.ESP:AddColorpicker("EspFillColor", { Title = "Fill Color", Default = Color3.fromRGB(255, 0, 0) })
Tabs.ESP:AddColorpicker("EspOutlineColor", { Title = "Outline Color", Default = Color3.fromRGB(255, 255, 255) })
Tabs.ESP:AddSlider("EspFillTransparency", { Title = "Fill Transparency", Default = 40, Min = 0, Max = 100, Rounding = 0 })
Tabs.ESP:AddSlider("EspOutlineTransparency", { Title = "Outline Transparency", Default = 0, Min = 0, Max = 100, Rounding = 0 })
Tabs.ESP:AddToggle("EspFilled", { Title = "Filled Highlight", Default = true })
Tabs.ESP:AddToggle("EspAlwaysOnTop", { Title = "Always On Top (Through Walls)", Default = true })
Tabs.ESP:AddToggle("EspShowHP", { Title = "Show HP Bar", Default = false })
Tabs.ESP:AddToggle("EspShowDistance", { Title = "Show Distance", Default = false })
Tabs.ESP:AddSlider("EspMaxDistance", { Title = "Max Render Distance", Default = 1000, Min = 50, Max = 5000, Rounding = 0 })
Tabs.ESP:AddSlider("EspInfoScale", { Title = "Info Display Size", Default = 100, Min = 50, Max = 200, Rounding = 0 })

local toggleMap = {
    ["Rage Kill Aura"] = t_KillAura,
    ["Vacuum Shards"] = t_AutoShard,
    ["Auto Galactic Spin"] = t_AutoSpin,
    ["Auto Weapon Upgrade"] = t_AutoUpgrade,
    ["Auto Health Upgrade"] = t_AutoHealthUpgrade,
    ["Auto Equip"] = t_AutoEquip,
    ["Auto Execute"] = t_AutoExecute,
    ["Server Fly"] = t_Fly,
    ["True Safe Area"] = t_SafeArea,
    ["Fullbright (Max Vision)"] = fbToggle,
    ["Zombie Highlight"] = espToggle
}

task.spawn(function()
    while env.KRB_Running do
        task.wait(2)
        pcall(function()
            for _, obj in ipairs(game:GetService("CoreGui"):GetDescendants()) do
                if obj:IsA("TextLabel") and toggleMap[obj.Text] then
                    if not obj:GetAttribute("HookedRMB") then
                        obj:SetAttribute("HookedRMB", true)
                        local parent = obj.Parent
                        if parent then
                            parent.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                                    OpenBindMenu(obj.Text, toggleMap[obj.Text])
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while env.KRB_Running do
        task.wait(0.5)
        for _, v in ipairs(KbList:GetChildren()) do
            if v:IsA("TextLabel") then v:Destroy() end
        end
        local modules = {
            {"Kill Aura", Options.KillAura and Options.KillAura.Value},
            {"Vacuum", Options.AutoShard and Options.AutoShard.Value},
            {"Auto Spin", Options.AutoSpin and Options.AutoSpin.Value},
            {"Fly", Options.Fly and Options.Fly.Value},
            {"Safe Area", Options.SafeArea and Options.SafeArea.Value},
            {"Fullbright", Options.Fullbright and Options.Fullbright.Value},
            {"Zombie ESP", Options.ZombieEsp and Options.ZombieEsp.Value}
        }
        local ySize = 25
        for _, mod in ipairs(modules) do
            if mod[2] then
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -10, 0, 20)
                lbl.Position = UDim2.new(0, 5, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.fromRGB(255, 200, 230)
                lbl.TextStrokeTransparency = 0.8
                lbl.Font = Enum.Font.GothamSemibold
                lbl.TextSize = 13
                lbl.Text = "[ON] " .. mod[1]
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = KbList
                ySize = ySize + 22
            end
        end
        if ySize == 25 then
            KeybindsHUD.Size = UDim2.new(0, 150, 0, 0)
            KeybindsHUD.BackgroundTransparency = 1
            kbStroke.Transparency = 1
            KbTitle.TextTransparency = 1
        else
            KeybindsHUD.Size = UDim2.new(0, 150, 0, ySize + 5)
            KeybindsHUD.BackgroundTransparency = 0.5
            kbStroke.Transparency = 0
            KbTitle.TextTransparency = 0
        end
    end
end)

t_KillAura:OnChanged(function() if env.DynamicIslandNotify then env.DynamicIslandNotify("Kill Aura: " .. (Options.KillAura.Value and "ON" or "OFF")) end end)
t_AutoShard:OnChanged(function() if env.DynamicIslandNotify then env.DynamicIslandNotify("Vacuum: " .. (Options.AutoShard.Value and "ON" or "OFF")) end end)
t_AutoSpin:OnChanged(function() if env.DynamicIslandNotify then env.DynamicIslandNotify("Auto Spin: " .. (Options.AutoSpin.Value and "ON" or "OFF")) end end)
t_Fly:OnChanged(function() if env.DynamicIslandNotify then env.DynamicIslandNotify("Fly: " .. (Options.Fly.Value and "ON" or "OFF")) end end)
t_SafeArea:OnChanged(function() if env.DynamicIslandNotify then env.DynamicIslandNotify("Safe Area: " .. (Options.SafeArea.Value and "ON" or "OFF")) end end)
fbToggle:OnChanged(function() if env.DynamicIslandNotify then env.DynamicIslandNotify("Fullbright: " .. (Options.Fullbright.Value and "ON" or "OFF")) end end)
espToggle:OnChanged(function() if env.DynamicIslandNotify then env.DynamicIslandNotify("Zombie ESP: " .. (Options.ZombieEsp.Value and "ON" or "OFF")) end end)

local fpsBoostToggle = Tabs.Settings:AddToggle("FPSBoost", {Title = "FPS Boost (Remove Textures)", Default = false})
local originalMaterials = {}
fpsBoostToggle:OnChanged(function(val)
    if env.DynamicIslandNotify then env.DynamicIslandNotify("FPS Boost: " .. (val and "ON" or "OFF")) end
    if val then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                if not originalMaterials[obj] then originalMaterials[obj] = {obj.Material, obj.Color} end
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            end
        end
        Lighting.GlobalShadows = false
    else
        for obj, data in pairs(originalMaterials) do
            if obj and obj.Parent then obj.Material = data[1] obj.Color = data[2] end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("Texture") or obj:IsA("Decal")) and obj.Transparency == 1 then obj.Transparency = 0 end
        end
        Lighting.GlobalShadows = true
    end
end)

Tabs.Settings:AddToggle("WebhookEnabled", {Title = "Discord Webhook", Default = false})
Tabs.Settings:AddSlider("WebhookDelay", {Title = "Webhook Delay (s)", Default = 120, Min = 10, Max = 600, Rounding = 0})
Tabs.Settings:AddInput("WebhookURL", {Title = "Webhook URL", Default = "", Placeholder = "Paste Discord Webhook here..."})
Tabs.Settings:AddButton({
    Title = "Unload Script",
    Description = "Completely remove the UI and stop all functions",
    Callback = function()
        if type(env.KRB_Unload) == "function" then
            env.KRB_Unload()
            env.KRB_Unload = nil
        end
    end
})

local function LoadBackgroundImage(url)
    if url == "" then return end
    task.spawn(function()
        pcall(function()
            local getAsset = getcustomasset or getsynasset
            if not getAsset then return end
            if not isfolder("KRBHub") then makefolder("KRBHub") end
            local assetUrl = nil
            local downloadSuccess = false
            if url ~= "" then
                local ok, imgData = pcall(function() return game:HttpGet(url) end)
                if ok and imgData and #imgData > 100 then
                    pcall(function() writefile("KRBHub/custom_bg.png", imgData) end)
                    downloadSuccess = true
                end
            end
            if isfile and isfile("KRBHub/custom_bg.png") then
                assetUrl = getAsset("KRBHub/custom_bg.png")
            end
            if not assetUrl then return end
            
            local coreGui = game:GetService("CoreGui")
            local windowFrame = nil
            for i = 1, 50 do
                for _, obj in ipairs(coreGui:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Text == "Free Edition" then
                        local p = obj.Parent
                        while p and not p:IsA("ScreenGui") do
                            if p:IsA("Frame") and p.Size.X.Offset > 300 then windowFrame = p end
                            p = p.Parent
                        end
                        if windowFrame then break end
                    end
                end
                if windowFrame then break end
                task.wait(0.1)
            end
            if windowFrame then
                local bg = windowFrame:FindFirstChild("KRBHubCustomDiscordBg")
                if not bg then
                    bg = Instance.new("ImageLabel")
                    bg.Name = "KRBHubCustomDiscordBg"
                    bg.Size = UDim2.new(1, 0, 1, 0)
                    bg.Position = UDim2.new(0, 0, 0, 0)
                    bg.BackgroundTransparency = 1
                    bg.ScaleType = Enum.ScaleType.Crop
                    bg.ZIndex = -100 
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 8)
                    corner.Parent = bg
                    bg.Parent = windowFrame
                end
                bg.Image = assetUrl
                bg.ImageColor3 = Color3.fromRGB(255, 255, 255)
                bg.ImageTransparency = 0
                bg:SetAttribute("KRB_ProtectedBg", true)
            end
        end)
    end)
end

Tabs.Settings:AddInput("DiscordBgURL", {
    Title = "Discord Background Image URL",
    Default = DEFAULT_BG_URL,
    Placeholder = "https://cdn.discordapp.com/...",
    Numeric = false,
    Finished = true,
    Callback = function(Value) LoadBackgroundImage(Value) end
})
LoadBackgroundImage(DEFAULT_BG_URL)

local Stats = { CurrentWave = 0, EarnedCrystals = 0 }
local ActiveZombies = {}
local FlyVelocity, FlyGyro
local lastWebhookTime = 0
local highlights = {}
local Connections = {} 

local originalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}
local settingLighting = false
local lightingConn = Lighting.Changed:Connect(function()
    if not env.KRB_Running then return end
    if Options.Fullbright and Options.Fullbright.Value and not settingLighting then
        settingLighting = true
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Atmosphere") or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") then
                if obj.Enabled then
                    obj:SetAttribute("KRB_WasEnabled", true)
                    obj.Enabled = false
                end
            end
        end
        settingLighting = false
    end
end)
table.insert(Connections, lightingConn)

fbToggle:OnChanged(function()
    if not Options.Fullbright.Value then
        settingLighting = true
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:GetAttribute("KRB_WasEnabled") then
                obj.Enabled = true
                obj:SetAttribute("KRB_WasEnabled", nil)
            end
        end
        settingLighting = false
    end
end)

local function getCurrentWeapon()
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then return tool.Name end
    end
    return "Pistol"
end

local espBillboards = {}
local function applyHighlight(zombieObj)
    if not Options.ZombieEsp.Value or not zombieObj then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and Options.EspMaxDistance then
        local zombieRoot = zombieObj:FindFirstChild("HumanoidRootPart") or zombieObj:FindFirstChildWhichIsA("BasePart")
        if zombieRoot and (zombieRoot.Position - root.Position).Magnitude > Options.EspMaxDistance.Value then
            return
        end
    end
    if not highlights[zombieObj] and not zombieObj:FindFirstChild("Zombie_ESP_Highlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "Zombie_ESP_Highlight"
        hl.Adornee = zombieObj
        hl.Parent = zombieObj
        highlights[zombieObj] = hl
    end
    local hl = highlights[zombieObj] or zombieObj:FindFirstChild("Zombie_ESP_Highlight")
    if hl then
        hl.FillColor = Options.EspFillColor and Options.EspFillColor.Value or Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Options.EspOutlineColor and Options.EspOutlineColor.Value or Color3.fromRGB(255, 255, 255)
        local isFilled = Options.EspFilled and Options.EspFilled.Value
        if isFilled == nil then isFilled = true end
        hl.FillTransparency = isFilled and (Options.EspFillTransparency and (Options.EspFillTransparency.Value / 100) or 0.4) or 1
        hl.OutlineTransparency = Options.EspOutlineTransparency and (Options.EspOutlineTransparency.Value / 100) or 0
        local alwaysOnTop = Options.EspAlwaysOnTop and Options.EspAlwaysOnTop.Value
        if alwaysOnTop == nil then alwaysOnTop = true end
        hl.DepthMode = alwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    end
end

local function createOrUpdateESPInfo(zombieObj)
    if not zombieObj or not zombieObj.Parent then return end
    local showHP = Options.EspShowHP and Options.EspShowHP.Value
    local showDist = Options.EspShowDistance and Options.EspShowDistance.Value
    if not showHP and not showDist then
        local existing = espBillboards[zombieObj]
        if existing and existing.Parent then existing:Destroy() end
        espBillboards[zombieObj] = nil
        return
    end
    local zombieRoot = zombieObj:FindFirstChild("HumanoidRootPart") or zombieObj:FindFirstChild("Head") or zombieObj:FindFirstChildWhichIsA("BasePart")
    if not zombieRoot then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local dist = (zombieRoot.Position - root.Position).Magnitude
    if Options.EspMaxDistance and dist > Options.EspMaxDistance.Value then
        local existing = espBillboards[zombieObj]
        if existing and existing.Parent then existing:Destroy() end
        espBillboards[zombieObj] = nil
        return
    end
    local scaleFactor = Options.EspInfoScale and (Options.EspInfoScale.Value / 100) or 1
    local bb = espBillboards[zombieObj]
    if not bb or not bb.Parent then
        bb = Instance.new("BillboardGui")
        bb.Name = "KRBHub_ESPInfo"
        bb.Size = UDim2.new(0, math.floor(120 * scaleFactor), 0, math.floor(50 * scaleFactor))
        bb.StudsOffset = Vector3.new(0, 4, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = zombieRoot
        bb.Parent = zombieObj
        espBillboards[zombieObj] = bb
        
        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = bb
        
        local hpBg = Instance.new("Frame")
        hpBg.Name = "HPBarBg"
        hpBg.Size = UDim2.new(0.9, 0, 0, math.floor(6 * scaleFactor))
        hpBg.Position = UDim2.new(0.05, 0, 0, 0)
        hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        hpBg.BackgroundTransparency = 0.3
        hpBg.BorderSizePixel = 0
        hpBg.Parent = container
        
        local hpBgCorner = Instance.new("UICorner")
        hpBgCorner.CornerRadius = UDim.new(0, 3)
        hpBgCorner.Parent = hpBg
        
        local hpFill = Instance.new("Frame")
        hpFill.Name = "HPBarFill"
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        hpFill.BorderSizePixel = 0
        hpFill.Parent = hpBg
        
        local hpFillCorner = Instance.new("UICorner")
        hpFillCorner.CornerRadius = UDim.new(0, 3)
        hpFillCorner.Parent = hpFill
        
        local hpText = Instance.new("TextLabel")
        hpText.Name = "HPText"
        hpText.Size = UDim2.new(1, 0, 0, math.floor(14 * scaleFactor))
        hpText.Position = UDim2.new(0, 0, 0, math.floor(8 * scaleFactor))
        hpText.BackgroundTransparency = 1
        hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
        hpText.TextStrokeTransparency = 0.3
        hpText.Font = Enum.Font.GothamBold
        hpText.TextSize = math.floor(11 * scaleFactor)
        hpText.Text = ""
        hpText.Parent = container
        
        local distText = Instance.new("TextLabel")
        distText.Name = "DistText"
        distText.Size = UDim2.new(1, 0, 0, math.floor(14 * scaleFactor))
        distText.Position = UDim2.new(0, 0, 0, math.floor(22 * scaleFactor))
        distText.BackgroundTransparency = 1
        distText.TextColor3 = Color3.fromRGB(200, 200, 255)
        distText.TextStrokeTransparency = 0.3
        distText.Font = Enum.Font.GothamMedium
        distText.TextSize = math.floor(10 * scaleFactor)
        distText.Text = ""
        distText.Parent = container
    end
    bb.Size = UDim2.new(0, math.floor(120 * scaleFactor), 0, math.floor(50 * scaleFactor))
    local container = bb:FindFirstChild("Container")
    if not container then return end
    local hpBg = container:FindFirstChild("HPBarBg")
    local hpText = container:FindFirstChild("HPText")
    if hpBg then hpBg.Visible = showHP end
    if hpText then hpText.Visible = showHP end
    if showHP then
        local humanoid = zombieObj:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local hpFill = hpBg and hpBg:FindFirstChild("HPBarFill")
            if hpFill then
                hpFill.Size = UDim2.new(healthPct, 0, 1, 0)
                if healthPct > 0.5 then
                    local t = (healthPct - 0.5) * 2
                    hpFill.BackgroundColor3 = Color3.fromRGB(math.floor(255 * (1 - t)), 255, math.floor(100 * t))
                else
                    local t = healthPct * 2
                    hpFill.BackgroundColor3 = Color3.fromRGB(255, math.floor(255 * t), 0)
                end
            end
            if hpText then hpText.Text = string.format("HP: %d / %d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth)) end
        else
            if hpText then hpText.Text = "HP: ???" end
        end
    end
    local distText = container:FindFirstChild("DistText")
    if distText then distText.Visible = showDist end
    if showDist and distText then distText.Text = string.format("%.0f studs", dist) end
end

local function clearESP()
    for obj, hl in pairs(highlights) do
        if hl and hl.Parent then hl:Destroy() end
        highlights[obj] = nil
    end
    for obj, bb in pairs(espBillboards) do
        if bb and bb.Parent then bb:Destroy() end
        espBillboards[obj] = nil
    end
end
espToggle:OnChanged(function() if not Options.ZombieEsp.Value then clearESP() end end)

task.spawn(function()
    while env.KRB_Running do
        task.wait(2)
        local folder = Workspace:FindFirstChild("Zombies_Local")
        if folder and not folder:GetAttribute("KRB_Hooked") then
            folder:SetAttribute("KRB_Hooked", true)
            local connection = folder.ChildAdded:Connect(function(child)
                if Options.ZombieEsp.Value then task.wait(0.1) applyHighlight(child) end
            end)
            table.insert(Connections, connection)
        end
    end
end)

task.spawn(function()
    while env.KRB_Running do
        task.wait(1)
        if Options.ZombieEsp.Value then
            local folder = Workspace:FindFirstChild("Zombies_Local")
            if folder then for _, zombie in ipairs(folder:GetChildren()) do applyHighlight(zombie) end end
        else clearESP() end
    end
end)

task.spawn(function()
    while env.KRB_Running do
        task.wait(0.25)
        if Options.ZombieEsp and Options.ZombieEsp.Value then
            local showHP = Options.EspShowHP and Options.EspShowHP.Value
            local showDist = Options.EspShowDistance and Options.EspShowDistance.Value
            if showHP or showDist then
                local folder = Workspace:FindFirstChild("Zombies_Local")
                if folder then
                    for _, zombie in ipairs(folder:GetChildren()) do
                        pcall(function() createOrUpdateESPInfo(zombie) end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    local ZombieSyncRemote = ReplicatedStorage:WaitForChild("ZombieRemotes", 60)
    ZombieSyncRemote = ZombieSyncRemote and ZombieSyncRemote:WaitForChild("ZombieSync", 5)
    if ZombieSyncRemote then
        local conn
        conn = ZombieSyncRemote.OnClientEvent:Connect(function(data)
            if not env.KRB_Running then return end
            if type(data) == "table" then
                local currentIds = {}
                for _, zombieData in pairs(data) do
                    if type(zombieData) == "table" and zombieData[1] and zombieData[2] and zombieData[3] and zombieData[4] then
                        local id = zombieData[1]
                        ActiveZombies[id] = Vector3.new(zombieData[2], zombieData[3], zombieData[4])
                        currentIds[id] = true
                    end
                end
                for id in pairs(ActiveZombies) do
                    if not currentIds[id] then ActiveZombies[id] = nil end
                end
            end
        end)
        table.insert(Connections, conn)
    end
end)

local function sendDiscordWebhook()
    local whUrl = Options.WebhookURL.Value
    if not Options.WebhookEnabled.Value or whUrl == "" or not whUrl:find("http") then return end
    local currentTime = os.time()
    if (currentTime - lastWebhookTime) < Options.WebhookDelay.Value then return end
    local proxyUrl = whUrl:gsub("discord%.com", "webhook.lewisakura.moe")
    local data = {
        ["embeds"] = {{
            ["title"] = "Farm Report (KRB Hub)",
            ["color"] = 16738740,
            ["fields"] = {
                {["name"] = "Player", ["value"] = LocalPlayer.Name, ["inline"] = true},
                {["name"] = "Current Wave", ["value"] = tostring(Stats.CurrentWave), ["inline"] = true},
                {["name"] = "Earned Crystals", ["value"] = tostring(Stats.EarnedCrystals), ["inline"] = false}
            },
            ["footer"] = {["text"] = "KRB Hub | Free Edition"},
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    pcall(function()
        local request = (syn and syn.request) or (http and http.request) or http_request or request
        if request then
            request({Url = proxyUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)})
        else
            HttpService:PostAsync(proxyUrl, HttpService:JSONEncode(data))
        end
        lastWebhookTime = currentTime
    end)
end

task.spawn(function()
    local WaveRemote = ReplicatedStorage:WaitForChild("WaveRemotes", 60)
    WaveRemote = WaveRemote and WaveRemote:WaitForChild("WaveUpdate", 5)
    if WaveRemote then
        local conn
        conn = WaveRemote.OnClientEvent:Connect(function(...)
            local args = {...}
            if args[1] and type(args[1]) == "number" then
                Stats.CurrentWave = args[1]
                sendDiscordWebhook()
            end
        end)
        table.insert(Connections, conn)
    end
end)

task.spawn(function()
    local EventRemotes = ReplicatedStorage:WaitForChild("EventRemotes", 60)
    local GalacticRequestSpin = EventRemotes and EventRemotes:WaitForChild("GalacticRequestSpin", 5)
    if GalacticRequestSpin then
        while env.KRB_Running do
            task.wait(0.05) 
            if Options.AutoSpin and Options.AutoSpin.Value then
                task.spawn(function() pcall(function() GalacticRequestSpin:InvokeServer() end) end)
            end
        end
    end
end)

task.spawn(function()
    local ShardCollectRemote = ReplicatedStorage:WaitForChild("EventRemotes", 60)
    ShardCollectRemote = ShardCollectRemote and ShardCollectRemote:WaitForChild("GalacticShardCollect", 5)
    if ShardCollectRemote and not env.KRB_Hooked then
        env.KRB_Hooked = true
        pcall(function()
            local oldFireServer
            oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
                if not checkcaller() then
                    local method = getnamecallmethod()
                    if self == ShardCollectRemote and method == "FireServer" and env.KRB_Running then
                        Stats.EarnedCrystals = Stats.EarnedCrystals + 1
                    end
                end
                return oldFireServer(self, ...)
            end)
        end)
    end
    while env.KRB_Running do
        task.wait(0.1)
        if Options.AutoShard.Value then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local voidShardsFolder = workspace:FindFirstChild("VoidShards")
                if voidShardsFolder then
                    for _, shardPart in ipairs(voidShardsFolder:GetChildren()) do
                        pcall(function()
                            local collectTime = shardPart:GetAttribute("KRB_CollectedTime")
                            local now = os.clock()
                            if collectTime and (now - collectTime) < 1 then return end
                            shardPart:SetAttribute("KRB_CollectedTime", now)
                            if shardPart:IsA("BasePart") then
                                shardPart.CanCollide = false
                                shardPart.Massless = true
                                shardPart.CFrame = root.CFrame
                            elseif shardPart:IsA("Model") then
                                for _, p in ipairs(shardPart:GetDescendants()) do
                                    if p:IsA("BasePart") then p.CanCollide = false p.Massless = true end
                                end
                                shardPart:PivotTo(root.CFrame)
                            end
                            if firetouchinterest then
                                local touchPart = shardPart:IsA("BasePart") and shardPart or shardPart:FindFirstChildWhichIsA("BasePart", true)
                                if touchPart then
                                    firetouchinterest(root, touchPart, 0)
                                    task.wait(0.01)
                                    firetouchinterest(root, touchPart, 1)
                                end
                            end
                            if ShardCollectRemote then
                                local sId = shardPart:GetAttribute("ShardID") or shardPart:GetAttribute("Id")
                                if sId then ShardCollectRemote:FireServer(sId) else ShardCollectRemote:FireServer(shardPart) end
                            end
                        end)
                    end
                end
            end
        end
    end
end)

-- [قناة الـ Kill Aura المعدلة بالكامل - فائقة السرعة والاستجابة الفورية]
task.spawn(function()
    local GunHitRemote = ReplicatedStorage:WaitForChild("GunRemotes", 60)
    GunHitRemote = GunHitRemote and GunHitRemote:WaitForChild("GunHit", 5)
    if GunHitRemote then
        while env.KRB_Running do
            RunService.Heartbeat:Wait() -- فريم بيرفكت لتنفيذ فوري بدون أي تأخير زمني
            if Options.KillAura and Options.KillAura.Value then
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local currentWeapon = getCurrentWeapon()
                    local myCurrentPos = root.Position
                    local killDistance = Options.KillDistance.Value
                    
                    for zId, zPos in pairs(ActiveZombies) do
                        if (zPos - myCurrentPos).Magnitude <= killDistance then
                            pcall(function()
                                -- إطلاق 3 ضربات متتالية بنفس الوقت لكل زومبي لضمان التبخير الفوري
                                GunHitRemote:FireServer(currentWeapon, zId, zPos)
                                GunHitRemote:FireServer(currentWeapon, zId, zPos)
                                GunHitRemote:FireServer(currentWeapon, zId, zPos)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while env.KRB_Running do
        task.wait(0.3)
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if Options.AutoEquip.Value and char and backpack then
            local currentTool = char:FindFirstChildOfClass("Tool")
            if not currentTool then
                local highestWeapon = nil
                for _, t in ipairs(backpack:GetChildren()) do
                    if t:IsA("Tool") then highestWeapon = t end
                end
                if highestWeapon then pcall(function() highestWeapon.Parent = char end) end
            end
        end
    end
end)

task.spawn(function()
    local UpgradeRemotes = ReplicatedStorage:WaitForChild("UpgradeRemotes", 60)
    local PurchaseWeaponUpgrade = UpgradeRemotes and UpgradeRemotes:WaitForChild("PurchaseWeaponUpgrade", 5)
    local PurchaseHealthUpgrade = UpgradeRemotes and UpgradeRemotes:WaitForChild("PurchaseHealthUpgrade", 5)
    while env.KRB_Running do
        task.wait(0.3)
        if Options.AutoUpgrade.Value and PurchaseWeaponUpgrade then pcall(function() PurchaseWeaponUpgrade:FireServer() end) end
        if Options.AutoHealthUpgrade.Value and PurchaseHealthUpgrade then pcall(function() PurchaseHealthUpgrade:FireServer() end) end
    end
end)

local physicsConn = RunService.RenderStepped:Connect(function()
    if not env.KRB_Running then return end
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    if humanoid and not Options.Fly.Value then
        humanoid.WalkSpeed = Options.WalkSpeed.Value
        humanoid.JumpPower = Options.JumpPower.Value
        humanoid.UseJumpPower = true
    end
    if Options.SafeArea.Value and root and not Options.Fly.Value then
        if not env.KRB_SafePlatform then
            local plat = Instance.new("Part")
            plat.Name = "KRBHub_SafePlatform"
            plat.Size = Vector3.new(15, 1, 15) 
            plat.Anchored = true
            plat.CanCollide = true
            plat.Color = Color3.fromRGB(180, 40, 100) 
            plat.Material = Enum.Material.SmoothPlastic
            plat.Transparency = 0.85
            plat.Parent = workspace
            env.KRB_SafePlatform = plat
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {char, plat}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local rayResult = workspace:Raycast(root.Position, Vector3.new(0, -5000, 0), rayParams)
            env.KRB_SafeBaseY = rayResult and rayResult.Position.Y or 0
            local h = env.KRB_SafeBaseY + (Options.SafeAreaHeight and Options.SafeAreaHeight.Value or 20)
            plat.Position = Vector3.new(root.Position.X, h, root.Position.Z)
            root.CFrame = CFrame.new(root.Position.X, h + 3, root.Position.Z)
        end
        local h = env.KRB_SafeBaseY + (Options.SafeAreaHeight and Options.SafeAreaHeight.Value or 20)
        env.KRB_SafePlatform.CFrame = CFrame.new(root.Position.X, h, root.Position.Z)
        if root.Position.Y < h - 5 then root.CFrame = CFrame.new(root.Position.X, h + 3, root.Position.Z) end
    else
        if env.KRB_SafePlatform then env.KRB_SafePlatform:Destroy() env.KRB_SafePlatform = nil env.KRB_SafeBaseY = nil end
    end
    if Options.Fly.Value and root and camera then
        if not FlyVelocity or FlyVelocity.Parent ~= root then
            if FlyVelocity then FlyVelocity:Destroy() end
            if FlyGyro then FlyGyro:Destroy() end
            FlyVelocity = Instance.new("BodyVelocity")
            FlyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyVelocity.Parent = root
            FlyGyro = Instance.new("BodyGyro")
            FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            FlyGyro.Parent = root
        end
        FlyGyro.CFrame = camera.CFrame
        local moveDirection = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0,1,0) end
        if moveDirection.Magnitude > 0 then FlyVelocity.Velocity = moveDirection.Unit * Options.FlySpeed.Value else FlyVelocity.Velocity = Vector3.new(0,0,0) end
    else
        if FlyVelocity then FlyVelocity:Destroy() FlyVelocity = nil end
        if FlyGyro then FlyGyro:Destroy() FlyGyro = nil end
    end
end)
table.insert(Connections, physicsConn)

env.KRB_Unload = function()
    env.KRB_Running = false
    if env.KRB_Window then pcall(function() env.KRB_Window:Destroy() end) env.KRB_Window = nil end
    if env.KRB_HUD then pcall(function() env.KRB_HUD:Destroy() end) env.KRB_HUD = nil end
    if originalLighting then
        settingLighting = true
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        settingLighting = false
    end
    for _, obj in pairs(originalMaterials) do if obj and obj.Parent then obj.Material = obj[1] obj.Color = obj[2] end end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Connections)
    if env.KRB_SafePlatform then pcall(function() env.KRB_SafePlatform:Destroy() end) env.KRB_SafePlatform = nil end
    if FlyVelocity then pcall(function() FlyVelocity:Destroy() end) end
    if FlyGyro then pcall(function() FlyGyro:Destroy() end) end
end

if successSave and SaveManager and successInterface and InterfaceManager then
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({"DiscordBgURL"})
    InterfaceManager:SetFolder("KRBHub")
    SaveManager:SetFolder("KRBHub/configs")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)
    Window:SelectTab(2)
    SaveManager:LoadAutoloadConfig()
end
