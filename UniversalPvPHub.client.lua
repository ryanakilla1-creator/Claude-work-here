--[[
  UNIVERSAL PVP HUB - LOCAL TRAINING UI
  Uso permitido: Roblox Studio, em uma experiência sua.
  Coloque este LocalScript em StarterPlayer > StarterPlayerScripts.
  Este projeto é apenas uma interface/HUD local: não mira em jogadores,
  não revela jogadores através de paredes e não altera combate/movimento.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("UniversalPvPHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "UniversalPvPHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local main = make("Frame", {
    Name = "Main", Size = UDim2.fromOffset(520, 350),
    Position = UDim2.new(0.5, -260, 0.5, -175),
    BackgroundColor3 = Color3.fromRGB(17, 19, 26), BorderSizePixel = 0
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, main)
make("UIStroke", {Color = Color3.fromRGB(70, 78, 100), Thickness = 1}, main)

local top = make("Frame", {
    Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Color3.fromRGB(25, 28, 38),
    BorderSizePixel = 0
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, top)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0),
    Size = UDim2.new(1, -100, 1, 0), Font = Enum.Font.GothamBold,
    Text = "UNIVERSAL PVP HUB  •  TRAINING", TextColor3 = Color3.fromRGB(235, 240, 255),
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
}, top)

local close = make("TextButton", {
    Size = UDim2.fromOffset(32, 28), Position = UDim2.new(1, -42, 0, 8),
    Text = "×", Font = Enum.Font.GothamBold, TextSize = 20,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundColor3 = Color3.fromRGB(170, 55, 70), BorderSizePixel = 0
}, top)
make("UICorner", {CornerRadius = UDim.new(0, 7)}, close)

-- Janela arrastável pelo cabeçalho.
do
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(12, 56), Size = UDim2.fromOffset(132, 282),
    BackgroundColor3 = Color3.fromRGB(22, 25, 34), BorderSizePixel = 0
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 9)}, sidebar)
local content = make("Frame", {
    Position = UDim2.fromOffset(156, 56), Size = UDim2.new(1, -168, 1, -68),
    BackgroundTransparency = 1
}, main)

local crosshair, fovRing, fpsLabel, status, movementHint, floating\nlocal pages = {}
local activePage
local function newPage(name)
    local page = make("Frame", {Name = name, Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, Visible = false}, content)
    make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    pages[name] = page
    return page
end

local function showPage(name)
    for pageName, page in pairs(pages) do page.Visible = pageName == name end
    activePage = name
end

local function addTab(name)
    local button = make("TextButton", {
        Size = UDim2.new(1, -14, 0, 36), Position = UDim2.fromOffset(7, 0),
        BackgroundColor3 = Color3.fromRGB(35, 40, 54), BorderSizePixel = 0,
        Text = name, Font = Enum.Font.GothamSemibold, TextSize = 12,
        TextColor3 = Color3.fromRGB(225, 230, 245), AutoButtonColor = true
    }, sidebar)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, button)
    button.MouseButton1Click:Connect(function() showPage(name) end)
end

local combat = newPage("Combat")
local movement = newPage("Movement")
local sharp = newPage("SHARP")
local visual = newPage("Visual")
local settings = newPage("Settings")

for _, name in ipairs({"Combat", "Movement", "SHARP", "Visual", "Settings"}) do addTab(name) end

local function heading(page, title, subtitle)
    make("TextLabel", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
        Text = title, Font = Enum.Font.GothamBold, TextSize = 17,
        TextColor3 = Color3.fromRGB(240, 243, 255), TextXAlignment = Enum.TextXAlignment.Left}, page)
    if subtitle then
        make("TextLabel", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1,
            Text = subtitle, Font = Enum.Font.Gotham, TextSize = 11,
            TextWrapped = true, TextColor3 = Color3.fromRGB(150, 160, 180),
            TextXAlignment = Enum.TextXAlignment.Left}, page)
    end
end

local function toggle(page, label, initial, callback)
    local row = make("Frame", {Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Color3.fromRGB(27, 31, 42), BorderSizePixel = 0}, page)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, row)
    make("TextLabel", {Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -76, 1, 0),
        BackgroundTransparency = 1, Text = label, Font = Enum.Font.Gotham,
        TextSize = 12, TextColor3 = Color3.fromRGB(225, 230, 242),
        TextXAlignment = Enum.TextXAlignment.Left}, row)
    local state = initial == true
    local button = make("TextButton", {Position = UDim2.new(1, -62, 0.5, -12),
        Size = UDim2.fromOffset(52, 24), BorderSizePixel = 0,
        BackgroundColor3 = state and Color3.fromRGB(55, 155, 115) or Color3.fromRGB(70, 75, 90),
        Text = state and "ON" or "OFF", Font = Enum.Font.GothamBold,
        TextSize = 10, TextColor3 = Color3.new(1, 1, 1)}, row)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, button)
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = state and "ON" or "OFF"
        button.BackgroundColor3 = state and Color3.fromRGB(55, 155, 115) or Color3.fromRGB(70, 75, 90)
        if callback then callback(state) end
    end)
    if callback then callback(state) end
end

heading(combat, "Combat", "Painel demonstrativo: sem assistência automática de mira.")
toggle(combat, "Mostrar dica de treino", false, function(on)
    if status then status.Visible = on end
end)

heading(movement, "Movement", "Atalhos visuais locais; não alteram a velocidade do personagem.")
toggle(movement, "Exibir indicador de movimento", false, function(on)
    if movementHint then movementHint.Visible = on end
end)

heading(sharp, "SHARP • Aim Trainer", "Ferramentas visuais para praticar sua própria mira.")
toggle(sharp, "Crosshair na tela", true, function(on) if crosshair then crosshair.Visible = on end end)
toggle(sharp, "Anel visual de referência", false, function(on) if fovRing then fovRing.Visible = on end end)

heading(visual, "Visual", "Informações e elementos exibidos somente na sua tela.")
toggle(visual, "Contador de FPS", true, function(on) if fpsLabel then fpsLabel.Visible = on end end)
toggle(visual, "Mostrar status do treino", false, function(on) status.Visible = on end)

heading(settings, "Settings", "Configurações da interface.")
toggle(settings, "Botão flutuante PVP", true, function(on) if floating then floating.Visible = on end end)
toggle(settings, "Dica de movimento", false, function(on) movementHint.Visible = on end)

-- HUDs locais.
crosshair = make("TextLabel", {Name = "Crosshair", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(30, 30),
    BackgroundTransparency = 1, Text = "+", Font = Enum.Font.GothamBold,
    TextSize = 26, TextColor3 = Color3.fromRGB(100, 255, 180)}, gui)

fovRing = make("Frame", {Name = "TrainingRing", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(180, 180),
    BackgroundTransparency = 1, Visible = false}, gui)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, fovRing)
make("UIStroke", {Color = Color3.fromRGB(100, 190, 255), Thickness = 1.5, Transparency = 0.2}, fovRing)

fpsLabel = make("TextLabel", {AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -14, 0, 14), Size = UDim2.fromOffset(100, 25),
    BackgroundColor3 = Color3.fromRGB(20, 24, 32), BackgroundTransparency = 0.15,
    Text = "FPS: --", Font = Enum.Font.GothamBold, TextSize = 12,
    TextColor3 = Color3.fromRGB(120, 255, 180)}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 6)}, fpsLabel)

status = make("TextLabel", {AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -24), Size = UDim2.fromOffset(250, 28),
    BackgroundColor3 = Color3.fromRGB(20, 24, 32), Text = "Modo de treino local ativado",
    Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(210, 230, 255),
    Visible = false}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 7)}, status)

movementHint = make("TextLabel", {AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 14, 1, -18), Size = UDim2.fromOffset(190, 25),
    BackgroundColor3 = Color3.fromRGB(20, 24, 32), Text = "Movimento: controle manual",
    Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(220, 225, 240),
    Visible = false}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 6)}, movementHint)

floating = make("TextButton", {AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(54, 54),
    BackgroundColor3 = Color3.fromRGB(80, 105, 210), Text = "PVP",
    Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.new(1, 1, 1)}, gui)
make("UICorner", {CornerRadius = UDim.new(1, 0)}, floating)

floating.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
close.MouseButton1Click:Connect(function() main.Visible = false end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)

local frames, elapsed = 0, 0
RunService.RenderStepped:Connect(function(dt)
    frames += 1
    elapsed += dt
    if elapsed >= 1 then
        fpsLabel.Text = "FPS: " .. tostring(math.floor(frames / elapsed + 0.5))
        frames, elapsed = 0, 0
    end
end)

showPage("SHARP")
