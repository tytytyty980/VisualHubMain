local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

Lighting.FogEnd = 1000000
Lighting.FogStart = 1000000
Lighting.FogColor = Color3.new(1, 1, 1)
Lighting.Brightness = 10
Lighting.GlobalShadows = false
Lighting.Ambient = Color3.new(1, 1, 1)
Lighting.OutdoorAmbient = Color3.new(1, 1, 1)

local targetFOV = 140
camera.FieldOfView = targetFOV

camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
    if camera.FieldOfView ~= targetFOV then
        camera.FieldOfView = targetFOV
    end
end)

RunService.Heartbeat:Connect(function()
    if camera and camera.FieldOfView ~= targetFOV then
        camera.FieldOfView = targetFOV
    end
end)

local function forceNoFog()
    Lighting.FogEnd = 1000000
    Lighting.FogStart = 1000000
    Lighting.FogColor = Color3.new(1, 1, 1)
end

Lighting:GetPropertyChangedSignal("FogEnd"):Connect(forceNoFog)
Lighting:GetPropertyChangedSignal("FogStart"):Connect(forceNoFog)
Lighting:GetPropertyChangedSignal("FogColor"):Connect(forceNoFog)

RunService.Heartbeat:Connect(forceNoFog)

local balls = {}
local ballHeights = {}
local ballDirections = {}
local ballOffsets = {}

local function createBalls(character)
    if not character then return end
    for _, ball in pairs(balls) do 
        if ball then 
            ball:Destroy() 
        end 
    end
    balls = {} 
    ballHeights = {} 
    ballDirections = {} 
    ballOffsets = {}
    
    for i = 1, 3 do
        local ball = Instance.new("Part")
        ball.Shape = Enum.PartType.Ball
        ball.Size = Vector3.new(0.7, 0.7, 0.7)
        ball.Color = Color3.fromRGB(255, 255, 255)
        ball.Material = Enum.Material.Neon
        ball.Transparency = 0.1
        ball.CanCollide = false
        ball.Anchored = true
        ball.Parent = workspace
        
        local trail = Instance.new("Trail")
        trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        trail.Transparency = NumberSequence.new(0.2, 1)
        trail.Lifetime = 0.8
        trail.WidthScale = NumberSequence.new(0.3, 0.1)
        
        local att0 = Instance.new("Attachment")
        local att1 = Instance.new("Attachment")
        att0.Position = Vector3.new(-0.35, 0, 0)
        att1.Position = Vector3.new(0.35, 0, 0)
        att0.Parent = ball
        att1.Parent = ball
        
        trail.Attachment0 = att0
        trail.Attachment1 = att1
        trail.Parent = ball
        
        balls[i] = ball
        ballHeights[i] = math.random(100, 500) / 100
        ballDirections[i] = math.random() > 0.5 and 1 or -1
        ballOffsets[i] = (i - 1) * (2 * math.pi / 3)
    end
end

RunService.Heartbeat:Connect(function(deltaTime)
    if #balls > 0 and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for i = 1, 3 do
                local ball = balls[i]
                if ball then
                    ballHeights[i] = ballHeights[i] + (ballDirections[i] * 1.5 * deltaTime)
                    if ballHeights[i] >= 5 then 
                        ballHeights[i] = 5
                        ballDirections[i] = -1
                    elseif ballHeights[i] <= 1 then 
                        ballHeights[i] = 1
                        ballDirections[i] = 1 
                    end

                    local angle = os.clock() * 1.5 + ballOffsets[i]
                    local x = math.cos(angle) * 2.5
                    local z = math.sin(angle) * 2.5
                    
                    ball.Position = root.Position + Vector3.new(x, ballHeights[i], z)
                end
            end
        end
    end
end)

local function hideHead()
    if LocalPlayer.Character then
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head then 
            head.Transparency = 1
            for _, decal in ipairs(head:GetChildren()) do
                if decal:IsA("Decal") then
                    decal.Transparency = 1
                end
            end
        end
    end
end

hideHead()
LocalPlayer.CharacterAdded:Connect(hideHead)
RunService.Heartbeat:Connect(hideHead)

local darkColor = Color3.fromRGB(40, 40, 40)

local function darkenObject(obj)
    if obj:IsA("BasePart") and obj.Parent ~= LocalPlayer.Character then
        obj.Color = darkColor
        obj.Material = Enum.Material.SmoothPlastic
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        if obj.Parent ~= LocalPlayer.Character then
            obj.Color3 = Color3.fromRGB(20, 20, 20)
        end
    end
end

for _, obj in workspace:GetDescendants() do
    darkenObject(obj)
end

workspace.DescendantAdded:Connect(darkenObject)

local fullbrightProps = {
    Brightness = 10,
    Ambient = Color3.new(1, 1, 1),
    OutdoorAmbient = Color3.new(1, 1, 1),
    GlobalShadows = false
}

for prop, value in pairs(fullbrightProps) do
    Lighting[prop] = value
    Lighting:GetPropertyChangedSignal(prop):Connect(function()
        task.wait()
        if Lighting[prop] ~= value then
            pcall(function()
                Lighting[prop] = value
            end)
        end
    end)
end

if LocalPlayer.Character then 
    createBalls(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(createBalls)

RunService.Heartbeat:Connect(function()
    Lighting.FogEnd = 1000000
    Lighting.FogStart = 1000000
    
    Lighting.Brightness = 10
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.GlobalShadows = false
end)
