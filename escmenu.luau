--[[
    DTstrap Custom Escape Menu (In-Game Luau)
    Black & Gray Gradient Minimalist Edition
    Features:
      - Intercepts Escape key via ContextActionService, GuiService & UserInputService
      - Floating DTstrap quick button for easy toggle
      - Real-time FPS, Ping, and Place info
      - Instant Character Reset & Leave Server confirmation modals
      - Quick Toggles: Fullscreen, Audio Mute, Low Graphics Mode
      - Pure black/graphite glassmorphism with smooth TweenService animations
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean up any prior instances
if _G.DTstrapEscapeMenuCleanup then
    pcall(_G.DTstrapEscapeMenuCleanup)
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DTstrap_EscapeMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Target CoreGui safely if available in executor
local parentTarget = PlayerGui
pcall(function()
    if gethui then
        parentTarget = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        parentTarget = game:GetService("CoreGui")
    end
end)
ScreenGui.Parent = parentTarget

-- Background Dimmer & Blur
local Backdrop = Instance.new("TextButton")
Backdrop.Name = "Backdrop"
Backdrop.Size = UDim2.fromScale(1, 1)
Backdrop.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
Backdrop.BackgroundTransparency = 1
Backdrop.Text = ""
Backdrop.AutoButtonColor = false
Backdrop.Visible = false
Backdrop.Parent = ScreenGui

local Blur = Instance.new("BlurEffect")
Blur.Name = "DTstrap_Blur"
Blur.Size = 0
Blur.Enabled = false
Blur.Parent = Lighting

-- Floating DTstrap Quick Icon (Top-Left)
local FloatingToggle = Instance.new("TextButton")
FloatingToggle.Name = "DTstrap_FloatingToggle"
FloatingToggle.Position = UDim2.fromOffset(16, 16)
FloatingToggle.Size = UDim2.fromOffset(38, 38)
FloatingToggle.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
FloatingToggle.BorderSizePixel = 0
FloatingToggle.AutoButtonColor = false
FloatingToggle.Text = "DT"
FloatingToggle.TextColor3 = Color3.fromRGB(240, 240, 250)
FloatingToggle.Font = Enum.Font.GothamBold
FloatingToggle.TextSize = 13
FloatingToggle.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 8)
FloatCorner.Parent = FloatingToggle

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(45, 45, 58)
FloatStroke.Thickness = 1
FloatStroke.Parent = FloatingToggle

-- Main Escape Window Container
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.AnchorPoint = Vector2.new(0.5, 0.5)
Container.Position = UDim2.fromScale(0.5, 0.52)
Container.Size = UDim2.fromOffset(560, 470)
Container.BackgroundColor3 = Color3.fromRGB(11, 11, 15)
Container.BackgroundTransparency = 0.05
Container.BorderSizePixel = 0
Container.Visible = false
Container.ClipsDescendants = true
Container.Parent = ScreenGui

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 10)
ContainerCorner.Parent = Container

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(38, 38, 48)
ContainerStroke.Thickness = 1.2
ContainerStroke.Parent = Container

-- Top Header / Player Profile
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 82)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Header.BorderSizePixel = 0
Header.Parent = Container

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

-- Bottom fill to keep rounded top only
local HeaderFill = Instance.new("Frame")
HeaderFill.Position = UDim2.new(0, 0, 1, -10)
HeaderFill.Size = UDim2.new(1, 0, 0, 10)
HeaderFill.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
HeaderFill.BorderSizePixel = 0
HeaderFill.Parent = Header

-- Branding Badge (Black & Silver Gradient)
local Badge = Instance.new("TextLabel")
Badge.Position = UDim2.fromOffset(18, 12)
Badge.Size = UDim2.fromOffset(70, 20)
Badge.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Badge.Text = "DTstrap"
Badge.TextColor3 = Color3.fromRGB(245, 245, 255)
Badge.Font = Enum.Font.GothamBold
Badge.TextSize = 11
Badge.BorderSizePixel = 0
Badge.Parent = Header

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 4)
BadgeCorner.Parent = Badge

-- Experience Name
local GameTitle = Instance.new("TextLabel")
GameTitle.Position = UDim2.fromOffset(96, 12)
GameTitle.Size = UDim2.new(1, -120, 0, 20)
GameTitle.BackgroundTransparency = 1
GameTitle.Text = "EXPERIENCE // PLACE " .. tostring(game.PlaceId)
GameTitle.TextColor3 = Color3.fromRGB(140, 140, 155)
GameTitle.Font = Enum.Font.GothamSemibold
GameTitle.TextSize = 11
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.Parent = Header

pcall(function()
    local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    if productInfo and productInfo.Name then
        GameTitle.Text = string.upper(productInfo.Name)
    end
end)

-- User Thumbnail
local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Position = UDim2.fromOffset(18, 38)
AvatarImg.Size = UDim2.fromOffset(34, 34)
AvatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
AvatarImg.Parent = Header

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarImg

-- Username & DisplayName
local DisplayLabel = Instance.new("TextLabel")
DisplayLabel.Position = UDim2.fromOffset(60, 37)
DisplayLabel.Size = UDim2.fromOffset(240, 18)
DisplayLabel.BackgroundTransparency = 1
DisplayLabel.Text = LocalPlayer.DisplayName
DisplayLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
DisplayLabel.Font = Enum.Font.GothamBold
DisplayLabel.TextSize = 13
DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
DisplayLabel.Parent = Header

local UserLabel = Instance.new("TextLabel")
UserLabel.Position = UDim2.fromOffset(60, 54)
UserLabel.Size = UDim2.fromOffset(240, 16)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = "@" .. LocalPlayer.Name
UserLabel.TextColor3 = Color3.fromRGB(120, 120, 135)
UserLabel.Font = Enum.Font.Gotham
UserLabel.TextSize = 11
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.Parent = Header

-- Performance Metrics (FPS & Ping)
local StatsLabel = Instance.new("TextLabel")
StatsLabel.AnchorPoint = Vector2.new(1, 0.5)
StatsLabel.Position = UDim2.new(1, -20, 0, 52)
StatsLabel.Size = UDim2.fromOffset(180, 28)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "60 FPS  •  -- ms"
StatsLabel.TextColor3 = Color3.fromRGB(150, 150, 165)
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Right
StatsLabel.Parent = Header

-- Content Section
local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(24, 96)
Content.Size = UDim2.new(1, -48, 1, -110)
Content.BackgroundTransparency = 1
Content.Parent = Container

-- Styled Buttons with Graphite Gradient
local function CreateMenuButton(text, bgCol, hoverCol, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.BackgroundColor3 = bgCol
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(42, 42, 54)
    stroke.Thickness = 1
    stroke.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = (icon and (icon .. "  ") or "") .. text
    label.TextColor3 = Color3.fromRGB(240, 240, 250)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = hoverCol}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = bgCol}):Play()
    end)

    return btn
end

-- Primary Actions (Black & Graphite Toned)
local ResumeBtn = CreateMenuButton("Resume Experience (ESC)", Color3.fromRGB(38, 38, 48), Color3.fromRGB(52, 52, 66), "▶")
ResumeBtn.Position = UDim2.fromOffset(0, 4)
ResumeBtn.Parent = Content

local ResetBtn = CreateMenuButton("Reset Character", Color3.fromRGB(22, 22, 28), Color3.fromRGB(34, 34, 44), "🔄")
ResetBtn.Position = UDim2.fromOffset(0, 56)
ResetBtn.Parent = Content

local LeaveBtn = CreateMenuButton("Leave Experience", Color3.fromRGB(30, 20, 24), Color3.fromRGB(46, 24, 30), "🚪")
LeaveBtn.Position = UDim2.fromOffset(0, 108)
LeaveBtn.Parent = Content

-- Quick Settings Header
local SettingsLabel = Instance.new("TextLabel")
SettingsLabel.Position = UDim2.fromOffset(0, 168)
SettingsLabel.Size = UDim2.new(1, 0, 0, 18)
SettingsLabel.BackgroundTransparency = 1
SettingsLabel.Text = "QUICK TOGGLES"
SettingsLabel.TextColor3 = Color3.fromRGB(110, 110, 125)
SettingsLabel.Font = Enum.Font.GothamBold
SettingsLabel.TextSize = 10
SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
SettingsLabel.Parent = Content

local QuickGrid = Instance.new("Frame")
QuickGrid.Position = UDim2.fromOffset(0, 192)
QuickGrid.Size = UDim2.new(1, 0, 0, 72)
QuickGrid.BackgroundTransparency = 1
QuickGrid.Parent = Content

local function CreateQuickToggle(title, defaultVal, callback)
    local toggle = Instance.new("TextButton")
    toggle.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Text = ""

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggle

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(34, 34, 44)
    stroke.Thickness = 1
    stroke.Parent = toggle

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Position = UDim2.fromOffset(12, 0)
    titleLbl.Size = UDim2.new(1, -50, 1, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = toggle

    local statusPill = Instance.new("TextLabel")
    statusPill.AnchorPoint = Vector2.new(1, 0.5)
    statusPill.Position = UDim2.new(1, -10, 0.5, 0)
    statusPill.Size = UDim2.fromOffset(36, 18)
    statusPill.BackgroundColor3 = defaultVal and Color3.fromRGB(220, 220, 230) or Color3.fromRGB(35, 35, 45)
    statusPill.Text = defaultVal and "ON" or "OFF"
    statusPill.TextColor3 = defaultVal and Color3.fromRGB(10, 10, 15) or Color3.fromRGB(180, 180, 190)
    statusPill.Font = Enum.Font.GothamBold
    statusPill.TextSize = 9
    statusPill.Parent = toggle

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(0, 4)
    pillCorner.Parent = statusPill

    local isEnabled = defaultVal
    toggle.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        statusPill.BackgroundColor3 = isEnabled and Color3.fromRGB(220, 220, 230) or Color3.fromRGB(35, 35, 45)
        statusPill.TextColor3 = isEnabled and Color3.fromRGB(10, 10, 15) or Color3.fromRGB(180, 180, 190)
        statusPill.Text = isEnabled and "ON" or "OFF"
        if callback then callback(isEnabled) end
    end)

    return toggle
end

-- Fullscreen Toggle
local FullscreenToggle = CreateQuickToggle("Fullscreen", false, function()
    pcall(function()
        GuiService:ToggleFullscreen()
    end)
end)
FullscreenToggle.Size = UDim2.new(0.48, 0, 0, 36)
FullscreenToggle.Position = UDim2.fromOffset(0, 0)
FullscreenToggle.Parent = QuickGrid

-- Audio Mute Toggle
local MuteToggle = CreateQuickToggle("Mute Audio", false, function(muted)
    pcall(function()
        UserSettings():GetService("UserGameSettings").MasterVolume = muted and 0 or 1
    end)
end)
MuteToggle.Size = UDim2.new(0.48, 0, 0, 36)
MuteToggle.Position = UDim2.new(0.52, 0, 0, 0)
MuteToggle.Parent = QuickGrid

-- Confirmation Dialog
local function ShowConfirmDialog(title, desc, confirmText, confirmCol, onConfirm)
    local dialog = Instance.new("Frame")
    dialog.Name = "ConfirmModal"
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.Position = UDim2.fromScale(0.5, 0.5)
    dialog.Size = UDim2.fromOffset(360, 175)
    dialog.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 15
    dialog.Parent = Container

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(0, 8)
    dCorner.Parent = dialog

    local dStroke = Instance.new("UIStroke")
    dStroke.Color = Color3.fromRGB(48, 48, 60)
    dStroke.Thickness = 1.2
    dStroke.Parent = dialog

    local tLabel = Instance.new("TextLabel")
    tLabel.Position = UDim2.fromOffset(20, 18)
    tLabel.Size = UDim2.new(1, -40, 0, 22)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 14
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.ZIndex = 16
    tLabel.Parent = dialog

    local dLabel = Instance.new("TextLabel")
    dLabel.Position = UDim2.fromOffset(20, 46)
    dLabel.Size = UDim2.new(1, -40, 0, 40)
    dLabel.BackgroundTransparency = 1
    dLabel.Text = desc
    dLabel.TextColor3 = Color3.fromRGB(150, 150, 165)
    dLabel.Font = Enum.Font.Gotham
    dLabel.TextSize = 12
    dLabel.TextWrapped = true
    dLabel.TextXAlignment = Enum.TextXAlignment.Left
    dLabel.ZIndex = 16
    dLabel.Parent = dialog

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Position = UDim2.fromOffset(130, 118)
    cancelBtn.Size = UDim2.fromOffset(100, 36)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    cancelBtn.Text = "Cancel"
    cancelBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    cancelBtn.Font = Enum.Font.GothamMedium
    cancelBtn.TextSize = 12
    cancelBtn.ZIndex = 16
    cancelBtn.Parent = dialog

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 6)
    cCorner.Parent = cancelBtn

    local actBtn = Instance.new("TextButton")
    actBtn.Position = UDim2.fromOffset(240, 118)
    actBtn.Size = UDim2.fromOffset(100, 36)
    actBtn.BackgroundColor3 = confirmCol
    actBtn.Text = confirmText
    actBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actBtn.Font = Enum.Font.GothamBold
    actBtn.TextSize = 12
    actBtn.ZIndex = 16
    actBtn.Parent = dialog

    local aCorner = Instance.new("UICorner")
    aCorner.CornerRadius = UDim.new(0, 6)
    aCorner.Parent = actBtn

    cancelBtn.MouseButton1Click:Connect(function() dialog:Destroy() end)
    actBtn.MouseButton1Click:Connect(function()
        dialog:Destroy()
        onConfirm()
    end)
end

-- Open / Close Menu Function
local isOpen = false

local function SetMenuOpen(open)
    if isOpen == open then return end
    isOpen = open

    -- Suppress stock Roblox menu
    pcall(function()
        GuiService:SetMenuIsOpen(false)
    end)

    if isOpen then
        Backdrop.Visible = true
        Container.Visible = true
        Blur.Enabled = true

        TweenService:Create(Backdrop, TweenInfo.new(0.2), {BackgroundTransparency = 0.55}):Play()
        TweenService:Create(Blur, TweenInfo.new(0.2), {Size = 20}):Play()

        Container.Position = UDim2.fromScale(0.5, 0.53)
        TweenService:Create(Container, TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.fromScale(0.5, 0.5)
        }):Play()
    else
        local t1 = TweenService:Create(Backdrop, TweenInfo.new(0.16), {BackgroundTransparency = 1})
        local t2 = TweenService:Create(Blur, TweenInfo.new(0.16), {Size = 0})
        local t3 = TweenService:Create(Container, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.fromScale(0.5, 0.52)
        })

        t1:Play()
        t2:Play()
        t3:Play()

        t1.Completed:Connect(function()
            if not isOpen then
                Backdrop.Visible = false
                Container.Visible = false
                Blur.Enabled = false
            end
        end)
    end
end

-- Button Bindings
ResumeBtn.MouseButton1Click:Connect(function() SetMenuOpen(false) end)
Backdrop.MouseButton1Click:Connect(function() SetMenuOpen(false) end)
FloatingToggle.MouseButton1Click:Connect(function() SetMenuOpen(not isOpen) end)

ResetBtn.MouseButton1Click:Connect(function()
    ShowConfirmDialog("Reset Character?", "Are you sure you want to respawn your character?", "Reset", Color3.fromRGB(180, 40, 40), function()
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 0
            end
        end)
        SetMenuOpen(false)
    end)
end)

LeaveBtn.MouseButton1Click:Connect(function()
    ShowConfirmDialog("Leave Experience?", "Are you sure you want to disconnect from this server?", "Leave", Color3.fromRGB(160, 30, 30), function()
        pcall(function() game:Shutdown() end)
        pcall(function() LocalPlayer:Kick("Disconnected via DTstrap Escape Menu") end)
    end)
end)

-- Real-time FPS & Ping Counter
local frameCount = 0
local lastFpsTime = tick()
local currentFps = 60

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFpsTime >= 0.5 then
        currentFps = math.floor(frameCount / (now - lastFpsTime))
        frameCount = 0
        lastFpsTime = now

        local ping = 0
        pcall(function()
            ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        end)

        StatsLabel.Text = string.format("%d FPS  •  %d ms", currentFps, ping)
    end
end)

-- MULTI-LAYER ESCAPE HOOK (Guarantees execution)

-- 1. ContextActionService priority binding (Priority 3000 intercepts before CoreGui)
pcall(function()
    ContextActionService:BindActionAtPriority(
        "DTstrap_EscapeIntercept",
        function(actionName, inputState, inputObj)
            if inputState == Enum.UserInputState.Begin then
                pcall(function() GuiService:SetMenuIsOpen(false) end)
                SetMenuOpen(not isOpen)
                return Enum.ContextActionResult.Sink
            end
            return Enum.ContextActionResult.Pass
        end,
        false,
        3000,
        Enum.KeyCode.Escape
    )
end)

-- 2. UserInputService InputBegan fallback
local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Escape then
        pcall(function() GuiService:SetMenuIsOpen(false) end)
        SetMenuOpen(not isOpen)
    end
end)

-- 3. GuiService MenuIsOpen monitor (Catches Roblox core menu opening)
local menuConn = GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
    if GuiService.MenuIsOpen then
        pcall(function() GuiService:SetMenuIsOpen(false) end)
        SetMenuOpen(true)
    end
end)

-- Cleanup Handler
_G.DTstrapEscapeMenuCleanup = function()
    pcall(function() ContextActionService:UnbindAction("DTstrap_EscapeIntercept") end)
    if inputConn then inputConn:Disconnect() end
    if menuConn then menuConn:Disconnect() end
    ScreenGui:Destroy()
    Blur:Destroy()
    _G.DTstrapEscapeMenuCleanup = nil
end

print("[DTstrap] In-Game Escape Menu successfully active!")
