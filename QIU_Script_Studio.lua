
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("QIU_Script_UI")
if oldGui then oldGui:Destroy() end

local purple = Color3.fromRGB(118, 75, 190)
local panelColor = Color3.fromRGB(28, 22, 40)
local cardColor = Color3.fromRGB(42, 33, 59)
local textColor = Color3.fromRGB(245, 240, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "QIU_Script_UI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(330, 340)
main.Position = UDim2.new(0.5, -165, 0.5, -170)
main.BackgroundColor3 = panelColor
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = purple
stroke.Thickness = 1.5
stroke.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(37, 28, 53)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -88, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "QIU Script"
title.TextColor3 = textColor
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(32, 28)
minimize.Position = UDim2.new(1, -72, 0, 7)
minimize.Text = "—"
minimize.TextSize = 18
minimize.Font = Enum.Font.GothamBold
minimize.TextColor3 = textColor
minimize.BackgroundColor3 = cardColor
minimize.Parent = titleBar
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 7)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -34, 0, 7)
close.Text = "×"
close.TextSize = 20
close.Font = Enum.Font.GothamBold
close.TextColor3 = textColor
close.BackgroundColor3 = Color3.fromRGB(100, 43, 68)
close.Parent = titleBar
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, -20, 1, -55)
body.Position = UDim2.fromOffset(10, 48)
body.BackgroundTransparency = 1
body.Parent = main

local function makeLabel(text, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.Position = UDim2.fromOffset(0, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = body
    return label
end

local function makeBox(defaultText, y)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 32)
    box.Position = UDim2.fromOffset(0, y)
    box.BackgroundColor3 = cardColor
    box.BorderSizePixel = 0
    box.Text = defaultText
    box.PlaceholderText = "Enter a number"
    box.TextColor3 = textColor
    box.PlaceholderColor3 = Color3.fromRGB(170, 160, 185)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = body
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
    return box
end

local function makeButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 32)
    button.Position = UDim2.fromOffset(0, y)
    button.BackgroundColor3 = purple
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = body
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    return button
end

makeLabel("玩家设置 · 移动速度", 0)
local speedBox = makeBox("16", 22)
makeLabel("跳跃力度（JumpPower）", 60)
local jumpBox = makeBox("50", 82)
local applyButton = makeButton("应用速度 / 跳跃", 122)
local infiniteButton = makeButton("无限跳：关闭", 162)
local flyButton = makeButton("飞行：关闭", 202)
local resetButton = makeButton("还原默认设置", 242)
makeLabel("飞行时使用 WASD 移动，空格上升，Ctrl 下降。", 282)

local humanoid
local root
local defaultSpeed = 16
local defaultJump = 50
local infiniteJump = false
local flying = false
local minimized = false
local flyConnection
local flyVelocity
local flyGyro

local function getCharacter()
    local character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")
    return character
end

getCharacter()

local function applySettings()
    if not humanoid or humanoid.Health <= 0 then getCharacter() end
    local speed = tonumber(speedBox.Text)
    local jump = tonumber(jumpBox.Text)
    if speed then humanoid.WalkSpeed = math.clamp(speed, 0, 100) end
    if jump then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = math.clamp(jump, 0, 200)
    end
end

applyButton.MouseButton1Click:Connect(applySettings)

infiniteButton.MouseButton1Click:Connect(function()
    infiniteJump = not infiniteJump
    infiniteButton.Text = "无限跳：" .. (infiniteJump and "开启" or "关闭")
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJump and humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function stopFlying()
    flying = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    if flyGyro then flyGyro:Destroy(); flyGyro = nil end
    if humanoid then humanoid.PlatformStand = false end
    flyButton.Text = "飞行：关闭"
end

local function startFlying()
    getCharacter()
    flying = true
    humanoid.PlatformStand = true

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyGyro.P = 1e4
    flyGyro.CFrame = root.CFrame
    flyGyro.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not root or not root.Parent then stopFlying(); return end
        local camera = workspace.CurrentCamera
        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end
        flyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * 45 or Vector3.zero
        flyGyro.CFrame = camera.CFrame
    end)
    flyButton.Text = "飞行：开启"
end

flyButton.MouseButton1Click:Connect(function()
    if flying then stopFlying() else startFlying() end
end)

resetButton.MouseButton1Click:Connect(function()
    stopFlying()
    infiniteJump = false
    infiniteButton.Text = "无限跳：关闭"
    speedBox.Text = tostring(defaultSpeed)
    jumpBox.Text = tostring(defaultJump)
    getCharacter()
    humanoid.WalkSpeed = defaultSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = defaultJump
end)

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    main.Size = minimized and UDim2.fromOffset(330, 42) or UDim2.fromOffset(330, 340)
    minimize.Text = minimized and "□" or "—"
end)

close.MouseButton1Click:Connect(function()
    stopFlying()
    gui:Destroy()
end)

-- Drag window by its title bar (mouse and touch).
local dragging = false
local dragStart
local startPosition
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
                                  startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    getCharacter()
    if flying then stopFlying() end
end)
