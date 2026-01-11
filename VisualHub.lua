local Players, RunService, Lighting = game:GetService("Players"), game:GetService("RunService"), game:GetService("Lighting")
local LocalPlayer, camera = Players.LocalPlayer, workspace.CurrentCamera
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({Name = "🎮 Visual Hub", ConfigurationSaving = {Enabled = true, FolderName = "VisualHub", FileName = "Config"}, Discord = {Enabled = false}})
local MainTab, VisualTab, PlayerTab = Window:CreateTab("📁 Основное"), Window:CreateTab("🌀 Визуал"), Window:CreateTab("👤 Игрок")

-- Все функции ВЫКЛЮЧЕНЫ по умолчанию
local Settings = {
    FOVEnabled = false,        -- ВЫКЛ
    TargetFOV = 140,
    FullbrightEnabled = false, -- ВЫКЛ
    NoFogEnabled = false,      -- ВЫКЛ
    BallsEnabled = false,      -- ВЫКЛ
    HideHeadEnabled = false,   -- ВЫКЛ
    DarkTexturesEnabled = false -- ВЫКЛ
}

-- Fullbright
local function updateLighting()
    if Settings.FullbrightEnabled then
        Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.GlobalShadows = 10, Color3.new(1,1,1), Color3.new(1,1,1), false
    else
        -- Возвращаем стандартные значения при выключении
        Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.GlobalShadows = 2, Color3.new(0.5,0.5,0.5), Color3.new(0.5,0.5,0.5), true
    end
    
    if Settings.NoFogEnabled then
        Lighting.FogEnd, Lighting.FogStart, Lighting.FogColor = 1000000, 1000000, Color3.new(1,1,1)
    else
        -- Возвращаем стандартный туман
        Lighting.FogEnd, Lighting.FogStart, Lighting.FogColor = 100000, 0, Color3.new(0.5,0.5,0.5)
    end
end

-- FOV защита
local fovConnection
local function setupFOV()
    if Settings.FOVEnabled then
        camera.FieldOfView = Settings.TargetFOV
        
        if fovConnection then fovConnection:Disconnect() end
        fovConnection = camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            if camera.FieldOfView ~= Settings.TargetFOV then
                camera.FieldOfView = Settings.TargetFOV
            end
        end)
        
        RunService.Heartbeat:Connect(function()
            if camera and camera.FieldOfView ~= Settings.TargetFOV then
                camera.FieldOfView = Settings.TargetFOV
            end
        end)
    else
        if fovConnection then 
            fovConnection:Disconnect()
            fovConnection = nil
        end
        -- Возвращаем стандартный FOV
        camera.FieldOfView = 70
    end
end

-- No Fog защита
local noFogConnections = {}
local function setupNoFog()
    -- Очищаем старые коннекты
    for _, conn in pairs(noFogConnections) do
        conn:Disconnect()
    end
    noFogConnections = {}
    
    if Settings.NoFogEnabled then
        local function forceNoFog()
            Lighting.FogEnd, Lighting.FogStart, Lighting.FogColor = 1000000, 1000000, Color3.new(1,1,1)
        end
        
        forceNoFog()
        table.insert(noFogConnections, Lighting:GetPropertyChangedSignal("FogEnd"):Connect(forceNoFog))
        table.insert(noFogConnections, Lighting:GetPropertyChangedSignal("FogStart"):Connect(forceNoFog))
        table.insert(noFogConnections, Lighting:GetPropertyChangedSignal("FogColor"):Connect(forceNoFog))
        table.insert(noFogConnections, RunService.Heartbeat:Connect(forceNoFog))
    end
end

-- Шары
local balls, ballHeights, ballDirections, ballOffsets = {}, {}, {}, {}
local function createBalls(character)
    if not character or not Settings.BallsEnabled then return end
    
    -- Очищаем старые шары
    for _, ball in pairs(balls) do 
        if ball then 
            ball:Destroy() 
        end 
    end
    balls, ballHeights, ballDirections, ballOffsets = {}, {}, {}, {}
    
    for i = 1, 3 do
        local ball = Instance.new("Part")
        ball.Shape, ball.Size, ball.Color, ball.Material = Enum.PartType.Ball, Vector3.new(0.7,0.7,0.7), Color3.fromRGB(255,255,255), Enum.Material.Neon
        ball.Transparency, ball.CanCollide, ball.Anchored, ball.Parent = 0.1, false, true, workspace
        
        local trail = Instance.new("Trail")
        trail.Color, trail.Transparency, trail.Lifetime, trail.WidthScale = ColorSequence.new(Color3.fromRGB(255,255,255)), NumberSequence.new(0.2,1), 0.8, NumberSequence.new(0.3,0.1)
        
        local att0, att1 = Instance.new("Attachment"), Instance.new("Attachment")
        att0.Position, att1.Position = Vector3.new(-0.35,0,0), Vector3.new(0.35,0,0)
        att0.Parent, att1.Parent = ball, ball
        trail.Attachment0, trail.Attachment1, trail.Parent = att0, att1, ball
        
        balls[i], ballHeights[i], ballDirections[i], ballOffsets[i] = ball, math.random(100,500)/100, math.random()>0.5 and 1 or -1, (i-1)*(2*math.pi/3)
    end
end

-- Удаление шаров
local function removeBalls()
    for _, ball in pairs(balls) do 
        if ball then 
            ball:Destroy() 
        end 
    end
    balls, ballHeights, ballDirections, ballOffsets = {}, {}, {}, {}
end

-- Анимация шаров
RunService.Heartbeat:Connect(function(deltaTime)
    if Settings.BallsEnabled and #balls>0 and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for i = 1, 3 do
                local ball = balls[i]
                if ball then
                    ballHeights[i] = ballHeights[i] + (ballDirections[i]*1.5*deltaTime)
                    if ballHeights[i]>=5 then ballHeights[i]=5; ballDirections[i]=-1 
                    elseif ballHeights[i]<=1 then ballHeights[i]=1; ballDirections[i]=1 end
                    
                    local angle = os.clock()*1.5 + ballOffsets[i]
                    ball.Position = root.Position + Vector3.new(math.cos(angle)*2.5, ballHeights[i], math.sin(angle)*2.5)
                end
            end
        end
    end
end)

-- Скрытие головы
local headHidden = false
local originalHeadTransparency = {}
local originalDecalTransparency = {}

local function hideHead()
    if Settings.HideHeadEnabled and LocalPlayer.Character and not headHidden then
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head then 
            -- Сохраняем оригинальную прозрачность
            originalHeadTransparency[head] = head.Transparency
            head.Transparency = 1
            
            -- Сохраняем и скрываем декали
            for _, decal in ipairs(head:GetChildren()) do
                if decal:IsA("Decal") then
                    originalDecalTransparency[decal] = decal.Transparency
                    decal.Transparency = 1
                end
            end
            headHidden = true
        end
    elseif not Settings.HideHeadEnabled and headHidden then
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head and originalHeadTransparency[head] then
            -- Восстанавливаем оригинальную прозрачность
            head.Transparency = originalHeadTransparency[head]
            
            for decal, transparency in pairs(originalDecalTransparency) do
                if decal and decal.Parent then
                    decal.Transparency = transparency
                end
            end
            headHidden = false
        end
    end
end

-- Темные текстуры
local darkColor, darkenConnections = Color3.fromRGB(40,40,40), {}
local darkenedObjects = {}

local function setupDarkTextures()
    if not Settings.DarkTexturesEnabled then 
        -- Возвращаем оригинальные цвета
        for obj, originalColor in pairs(darkenedObjects) do
            if obj and obj.Parent then
                if obj:IsA("BasePart") then
                    obj.Color = originalColor
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Color3 = originalColor
                end
            end
        end
        darkenedObjects = {}
        
        for _, connection in pairs(darkenConnections) do 
            connection:Disconnect() 
        end
        darkenConnections = {}
        return 
    end
    
    local function darkenObject(obj)
        if obj:IsA("BasePart") and obj.Parent~=LocalPlayer.Character then
            if not darkenedObjects[obj] then
                darkenedObjects[obj] = obj.Color
            end
            obj.Color, obj.Material = darkColor, Enum.Material.SmoothPlastic
        elseif (obj:IsA("Decal") or obj:IsA("Texture")) and obj.Parent~=LocalPlayer.Character then
            if not darkenedObjects[obj] then
                darkenedObjects[obj] = obj.Color3
            end
            obj.Color3 = Color3.fromRGB(20,20,20)
        end
    end
    
    for _, obj in workspace:GetDescendants() do 
        darkenObject(obj) 
    end
    
    table.insert(darkenConnections, workspace.DescendantAdded:Connect(darkenObject))
end

-- NOCLIP (всегда включен, скрытый)
local noclippedParts = {}
local function refreshNoclip()
    noclippedParts = {}
    for _, plr in Players:GetPlayers() do
        if plr~=LocalPlayer and plr.Character then
            for _, obj in plr.Character:GetDescendants() do
                if obj:IsA("BasePart") then
                    noclippedParts[obj], obj.CanCollide = true, false
                end
            end
        end
    end
end
local function applyNoclip()
    for part in pairs(noclippedParts) do
        if part and part.Parent then 
            part.CanCollide = false 
        else 
            noclippedParts[part]=nil 
        end
    end
end
refreshNoclip()
RunService.Heartbeat:Connect(applyNoclip)
Players.PlayerAdded:Connect(function(plr) 
    plr.CharacterAdded:Connect(refreshNoclip) 
    refreshNoclip() 
end)
Players.PlayerRemoving:Connect(refreshNoclip)
LocalPlayer.CharacterAdded:Connect(refreshNoclip)
for _, plr in Players:GetPlayers() do 
    plr.CharacterAdded:Connect(refreshNoclip) 
end

-- ИНТЕРФЕЙС
MainTab:CreateSection("⚙️ Основные настройки")

MainTab:CreateToggle({
    Name="FOV защита", 
    CurrentValue=Settings.FOVEnabled, 
    Flag="FOVToggle", 
    Callback=function(Value) 
        Settings.FOVEnabled=Value 
        setupFOV()
        Rayfield:Notify({
            Title = Value and "✅ FOV включен" or "❌ FOV выключен",
            Content = Value and "FOV установлен на 140" or "FOV возвращен в стандарт",
            Duration = 2
        })
    end
})

MainTab:CreateSlider({
    Name="Значение FOV", 
    Range={70,140}, 
    Increment=5, 
    Suffix="°", 
    CurrentValue=Settings.TargetFOV, 
    Flag="FOVSlider", 
    Callback=function(Value) 
        Settings.TargetFOV=Value 
        if Settings.FOVEnabled then 
            camera.FieldOfView=Value 
        end
    end
})

MainTab:CreateToggle({
    Name="Fullbright", 
    CurrentValue=Settings.FullbrightEnabled, 
    Flag="FullbrightToggle", 
    Callback=function(Value) 
        Settings.FullbrightEnabled=Value 
        updateLighting()
        Rayfield:Notify({
            Title = Value and "💡 Fullbright включен" or "🌙 Fullbright выключен",
            Content = Value and "Максимальная яркость" or "Стандартное освещение",
            Duration = 2
        })
    end
})

MainTab:CreateToggle({
    Name="No Fog", 
    CurrentValue=Settings.NoFogEnabled, 
    Flag="NoFogToggle", 
    Callback=function(Value) 
        Settings.NoFogEnabled=Value 
        setupNoFog()
        updateLighting()
        Rayfield:Notify({
            Title = Value and "🌫️ No Fog включен" or "☁️ Туман восстановлен",
            Content = Value and "Туман убран" or "Туман возвращен",
            Duration = 2
        })
    end
})

VisualTab:CreateSection("🌀 Шары и визуал")

VisualTab:CreateToggle({
    Name="Вращающиеся шары", 
    CurrentValue=Settings.BallsEnabled, 
    Flag="BallsToggle", 
    Callback=function(Value) 
        Settings.BallsEnabled=Value 
        if Value and LocalPlayer.Character then 
            createBalls(LocalPlayer.Character)
            Rayfield:Notify({
                Title = "🌀 Шары созданы",
                Content = "3 шара с трейлами",
                Duration = 2
            })
        else
            removeBalls()
            Rayfield:Notify({
                Title = "🗑️ Шары удалены",
                Content = "Шары убраны",
                Duration = 2
            })
        end
    end
})

VisualTab:CreateToggle({
    Name="Темные текстуры", 
    CurrentValue=Settings.DarkTexturesEnabled, 
    Flag="DarkTexturesToggle", 
    Callback=function(Value) 
        Settings.DarkTexturesEnabled=Value 
        setupDarkTextures()
        Rayfield:Notify({
            Title = Value and "⚫ Темные текстуры" or "⚪ Обычные текстуры",
            Content = Value and "Все объекты затемнены" or "Цвета восстановлены",
            Duration = 2
        })
    end
})

PlayerTab:CreateSection("👤 Настройки игрока")

PlayerTab:CreateToggle({
    Name="Скрыть голову", 
    CurrentValue=Settings.HideHeadEnabled, 
    Flag="HideHeadToggle", 
    Callback=function(Value) 
        Settings.HideHeadEnabled=Value 
        hideHead()
        Rayfield:Notify({
            Title = Value and "👻 Голова скрыта" or "👤 Голова видима",
            Content = Value and "Голова невидима" or "Голова отображается",
            Duration = 2
        })
    end
})

PlayerTab:CreateButton({
    Name="Обновить шары", 
    Callback=function() 
        if Settings.BallsEnabled and LocalPlayer.Character then 
            createBalls(LocalPlayer.Character) 
            Rayfield:Notify({
                Title="🌀 Шары обновлены", 
                Content="Шары пересозданы", 
                Duration=2
            })
        else
            Rayfield:Notify({
                Title="⚠️ Шары выключены", 
                Content="Включите шары сначала", 
                Duration=2
            })
        end
    end
})

PlayerTab:CreateButton({
    Name="Выключить всё", 
    Callback=function()
        -- Выключаем все функции
        Settings.FOVEnabled = false
        Settings.FullbrightEnabled = false
        Settings.NoFogEnabled = false
        Settings.BallsEnabled = false
        Settings.HideHeadEnabled = false
        Settings.DarkTexturesEnabled = false
        
        -- Применяем изменения
        setupFOV()
        updateLighting()
        setupNoFog()
        removeBalls()
        setupDarkTextures()
        hideHead()
        
        -- Обновляем UI
        Window:GetConfiguration().Flags.FOVToggle:Set(false)
        Window:GetConfiguration().Flags.FullbrightToggle:Set(false)
        Window:GetConfiguration().Flags.NoFogToggle:Set(false)
        Window:GetConfiguration().Flags.BallsToggle:Set(false)
        Window:GetConfiguration().Flags.HideHeadToggle:Set(false)
        Window:GetConfiguration().Flags.DarkTexturesToggle:Set(false)
        
        Rayfield:Notify({
            Title="🔌 Все выключено", 
            Content="Все функции отключены", 
            Duration=3
        })
    end
})

-- Инициализация (все функции выключены)
updateLighting() -- Стандартное освещение
setupFOV() -- Стандартный FOV
setupNoFog() -- Стандартный туман
setupDarkTextures() -- Стандартные текстуры
hideHead() -- Голова видима

-- Обновления при смене персонажа
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    hideHead()
    if Settings.BallsEnabled then
        createBalls(character)
    end
end)

-- Heartbeat для обновлений
RunService.Heartbeat:Connect(function()
    hideHead()
    updateLighting()
end)

Rayfield:Notify({
    Title="🎮 Visual Hub загружен", 
    Content="Все функции выключены по умолчанию\nВключайте нужные в меню", 
    Duration=5
})
