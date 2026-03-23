local player = game:GetService("Players").LocalPlayer
local character, root, humanoid
local function Update()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")
end

Update()

player.CharacterAdded:Connect(function()
    for i, v in next, getgenv().Connections do
        if v then
            v:Disconnect()
        end
    end
    Update()
end)

local camera = workspace.CurrentCamera

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

local Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()
Sense.sharedSettings.limitDistance = true


local Window = Library:CreateWindow({
    Title = "Not Found",
    Footer = "version: 0.0.1",
    Icon = nil,
    NotifySide = "Right",
})
 
local Tabs = {
    Main = Window:AddTab("Main"),
    Visuals = Window:AddTab("Visuals"),
    Movement = Window:AddTab("Movement"),
    Combat = Window:AddTab("Combat"),
    ["UI Settings"] = Window:AddTab("UI Settings")
}


getgenv().Connections = {}
getgenv().General = {
    Speed = {
        Current = 0,
        Type = "Velocity",
        Default = humanoid.WalkSpeed
    },
    Aimbot = {
        Active = false
    },
    Desync = {
        Type = "UnderGround"
    }
}

local Movement = Tabs.Movement:AddLeftGroupbox("Movement", "wind")
Movement:AddToggle("Speed", {
	Text = "Enable Speed",
	Default = false
})

Toggles.Speed:AddKeyPicker("SpeedKey", {
	Text = "Speed Keybind",
	Default = "Q",
	Mode = "Hold",
	SyncToggleState = false,

})

Toggles.Speed:OnChanged(function(active)
	if active then
		if getgenv().General.Speed.Type == "Velocity" then
            getgenv().Connections.Speed = RunService.Heartbeat:Connect(function()
				local state = Options.SpeedKey:GetState()
				if state then
                    local look = humanoid.MoveDirection:Dot(root.CFrame.LookVector)
                    local right = humanoid.MoveDirection:Dot(root.CFrame.RightVector)
                    local velocity = Vector3.zero

                    if math.abs(look) > 0.1 then
                        velocity += root.CFrame.LookVector * look * getgenv().General.Speed.Current
                    end
                    if math.abs(right) > 0.1 then
                        velocity += root.CFrame.RightVector * right * getgenv().General.Speed.Current
                    end

                    if velocity.Magnitude > 0 then
                        root.AssemblyLinearVelocity = Vector3.new(velocity.X, root.AssemblyLinearVelocity.Y, velocity.Z)
                    end
                end
			end)
		end
	else
		if getgenv().Connections.Speed then
        	getgenv().Connections.Speed:Disconnect()
            getgenv().Connections.Speed = nil
        end
	end
end)

Movement:AddSlider("SpeedAmount", {
	Text = "Speed Amount",
	Default = 0,
	Min = 0,
	Max = 250,
	Rounding = 0
})

Options.SpeedAmount:OnChanged(function()
	getgenv().General.Speed.Current = Options.SpeedAmount.Value
end)

local Visuals = Tabs.Visuals:AddLeftGroupbox("Visuals", "eye")
Visuals:AddToggle("Esp", {
    Text = "Enable Esp",
    Default = false,
})

Toggles.Esp:OnChanged(function()
    Sense.teamSettings.enemy.enabled = Toggles.Esp.Value
    Sense.teamSettings.enemy.box = Toggles.Esp.Value
    Sense.teamSettings.enemy.boxColor[1] = Color3.new(1, 1, 1)
    Sense.teamSettings.enemy.healthBar = Toggles.Esp.Value
    Sense.teamSettings.enemy.name = Toggles.Esp.Value
end)

Visuals:AddToggle("Tracer", {
    Text = "Enable Tracers",
    Default = false,
})

Toggles.Tracer:OnChanged(function()
    Sense.teamSettings.enemy.tracer = Toggles.Tracer.Value
end)

Visuals:AddToggle("Chams", {
    Text = "Enable Chams",
    Default = false,
})

Toggles.Chams:OnChanged(function()
    Sense.teamSettings.enemy.chams = Toggles.Chams.Value
    Sense.teamSettings.enemy.chamsOutlineColor = { Color3.new(0.886274, 0.537254, 0.537254), 0 }
end)

Visuals:AddSlider("Render", {
    Text = "Render Distance",
    Default = 5000,
    Min = 1000, 
    Max = 10000,
    Rounding = 0,
    Compact = false
})

Options.Render:OnChanged(function()
    Sense.sharedSettings.maxDistance = Options.Render.Value
end)

local Aimbot = Tabs.Combat:AddLeftGroupbox("Aimbot")
local Desync = Tabs.Combat:AddRightGroupbox("Desync")

Aimbot:AddToggle("Aimbot", {
    Text = "Enable Aimbot",
    Default = false
})

Toggles.Aimbot:AddKeyPicker("Aimbot",{
	Default = "E",
    SyncToggleState = false,
    Mode = "Hold",
    Text = "Aimbot Keybind",
    NoUI = false
})

local function TeamCheck(toggled : boolean, key : Player)
    if toggled then
        if key.Team ~= player.Team then
            return true
        else
            return false
        end
    else
        return false
    end
end

local function GetClosestPlayer()
    local closestDistance = math.huge
    local closestPlayer = nil

    for _, v in next, game.Players:GetPlayers() do
        local char = v.Character
        if not char then return end

        if char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 and v ~= player then
            local vector, onScreen = camera.worldToScreenPoint(camera, char:FindFirstChild("HumanoidRootPart").Position)
            local distance = (Vector2.new(UIS.GetMouseLocation(UIS).X, UIS.GetMouseLocation(UIS).Y) - Vector2.new(vector.X, vector.Y)).Magnitude
            --and TeamCheck(true, v)
            if distance < closestDistance and onScreen and distance < 250 then
                closestDistance = distance
                closestPlayer = v
            end
        end
    end

    if closestPlayer then
        local head = closestPlayer.Character:FindFirstChild("Head")
        if not head then return end

        local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
        if not headPos then return end

        local mousePos = UIS.GetMouseLocation(UIS)

        local deltaX = headPos.X - mousePos.X
        local deltaY = headPos.Y - mousePos.Y

        mousemoverel(deltaX, deltaY)
    end
end

Toggles.Aimbot:OnChanged(function()
    if Toggles.Aimbot.Value then
        getgenv().Connections.Aimbot = RunService.Heartbeat:Connect(function()
            local state = Options.Aimbot:GetState()
            if state then
                GetClosestPlayer()
            end
        end)
    else
        if getgenv().Connections.Aimbot then
            getgenv().Connections.Aimbot:Disconnect()
        end
    end
end)

Desync:AddToggle("Desync", {
    Text = "Enable Desync",
    Default = false
})

Toggles.Desync:AddKeyPicker("Desync",
{
	Default = "X",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Desync Keybind",
    NoUI = false
})

local hook
Toggles.Desync:OnChanged(function()
    if Toggles.Desync.Value then
        if getgenv().General.Desync.Type == "UnderGround" then
            local desyncOffset

            getgenv().Connections.Desync = RunService.Heartbeat:Connect(function()
                if not root or not root.Parent then return end
                pcall(function()
                    local offset = CFrame.new(0, -6.4, 0)
                    desyncOffset = root.CFrame
                    local newCframe = desyncOffset * offset
                    root.CFrame = newCframe
                    RunService.RenderStepped:Wait()
                    root.CFrame = desyncOffset
                end)
            end)
            hook = hookmetamethod(game, "__index", newcclosure(function(self, key)
                if key == "CFrame" and self == player.Character.HumanoidRootPart and not checkcaller() and player.Character then
                    return desyncOffset
                end
                return hook(self, key)
            end))
        elseif getgenv().General.Desync.Type == "Random" then
            local desyncOffset

            workspace.FallenPartsDestroyHeight=0/0

            getgenv().Connections.Desync = RunService.Heartbeat:Connect(function()
                if not root or not root.Parent then return end
                pcall(function()
                    workspace.FallenPartsDestroyHeight=0/0

                    local offset = CFrame.new(
                        root.CFrame.X * math.random(1, 15), 
                        root.CFrame.Y * math.random(1, 15), 
                        root.CFrame.Z * math.random(1, 15)
                    )
                    desyncOffset = root.CFrame
                    local newCframe = desyncOffset * offset
                    root.CFrame = newCframe
                    RunService.RenderStepped:Wait()
                    root.CFrame = desyncOffset
                end)
            end)
            hook = hookmetamethod(game, "__index", newcclosure(function(self, key)
                if key == "CFrame" and self == player.Character.HumanoidRootPart and not checkcaller() and player.Character then
                    return desyncOffset
                end
                return hook(self, key)
            end))
        end
    else
        if getgenv().Connections.Desync then
            getgenv().Connections.Desync:Disconnect()
        end
        if hook then
            hookmetamethod(game, "__index", hook)
            hook = nil
        end
    end
end)

Desync:AddDropdown("DesyncTypes", {
    Values = {"UnderGround", "Random"},
    Default = 1,
    Multi = false,

    Text = 'Desync Type'
})

Options.DesyncTypes:OnChanged(function()
    getgenv().General.Desync.Type = Options.DesyncTypes.Value
end)


Sense.Load()

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("MyScriptHub")
ThemeManager:ApplyToTab(Tabs["UI Settings"])
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("Lobby")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
