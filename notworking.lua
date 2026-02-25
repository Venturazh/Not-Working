local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local EspManager = loadstring(game:HttpGet("https://github.com/Venturazh/Not-Working/raw/refs/heads/main/EspLibrary.lua", true))()
EspManager.Load()
EspManager.sharedSettings.limitDistance = true
EspManager.sharedSettings.maxDistance = 10000

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local root = character:FindFirstChild("HumanoidRootPart")
local camera = game.Workspace.CurrentCamera

local PlayerGui = player:WaitForChild("PlayerGui")

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Connections = {}

local Window = Library:CreateWindow({
    Title = 'Not Working!',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
	Visuals = Window:AddTab('Visuals'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local Movement = Tabs.Main:AddLeftGroupbox('Movement')
local Removals = Tabs.Main:AddLeftGroupbox('Removals')
local Quality = Tabs.Main:AddRightGroupbox("Quality of Life")
local PlayerEsp = Tabs.Visuals:AddLeftGroupbox("Player Esp")
local NpcEsp = Tabs.Visuals:AddLeftGroupbox("Npc Esp")

Movement:AddToggle("Fly", {
    Text = "Enable Fly",
    Default = false,
    Tooltip = "Enables Flying"
}):AddKeyPicker("FlyKey", {
    Default = 'nil',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Fly Keybind',
    NoUI = false,
})

getgenv().FlySettings = {
    Speed = 25
}

Toggles.Fly:OnChanged(function()
    if Toggles.Fly.Value then
        getgenv().FlySettings.LinearVelocity = Instance.new("LinearVelocity")
        getgenv().FlySettings.Attachment = Instance.new("Attachment")

        local LinearVelocity = getgenv().FlySettings.LinearVelocity
        local Attachment = getgenv().FlySettings.Attachment

        Connections.FlyConn = RunService.Heartbeat:Connect(function()
            local move = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end

            if move.Magnitude > 0 then
                move = move.Unit * getgenv().FlySettings.Speed
            end

            LinearVelocity.VectorVelocity = move
        end)

        Attachment.Parent = root
        LinearVelocity.Parent = root
        LinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        LinearVelocity.MaxForce = 100000
        LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
        LinearVelocity.Attachment0 = Attachment
    else
        if Connections.FlyConn then
            Connections.FlyConn:Disconnect()
        end
        if getgenv().FlySettings.LinearVelocity then
            FlySettings.LinearVelocity:Destroy()
        end 
        if FlySettings.Attachment then
            getgenv().FlySettings.Attachment:Destroy()
        end
    end
end)

Movement:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 50,
    Min = 25,
    Max = 150,
    Rounding = 1,
    Compact = false
})

Options.FlySpeed:OnChanged(function()
    getgenv().FlySettings.Speed = Options.FlySpeed.Value
end)


--============================ Removals ======================================================= 

Removals:AddToggle("nofall", {
    Text = "No Fall Dmg",
    Default = false,
    Tooltip = "Disables Fall Damage"
}):AddKeyPicker("nofall", {
    Default = 'nil',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'No Fall Keybind',
    NoUI = false,
})

Toggles.nofall:OnChanged(function()
    if Toggles.nofall.Value then
        local Requests = game:GetService("ReplicatedStorage").Requests
        local children = Requests:GetChildren()

        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        Connections.OldNamecall = oldNamecall

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()

            if method == "FireServer" then
                local arg = {...}
                if type(arg[1]) == "number" and arg[1] > 10 and type(arg[2]) == "boolean" and arg[2] == false then
                    return
                end
            end
            return oldNamecall(self, ...)
        end)
    else
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        if Connections.OldNamecall then
            mt.__namecall = Connections.OldNamecall
        end
        setreadonly(mt, true)
    end
end)





--============================ Extrasensory Perception( ESP ) ======================================================= 


PlayerEsp:AddToggle("Esp", {
    Text = "Esp",
    Default = false,
    Tooltip = "Enables Player Esp"
}):AddKeyPicker("EspBind", {
    Default = 'nil',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Enable Esp',
    NoUI = false,
})

Toggles.Esp:OnChanged(function()
    EspManager.teamSettings.enemy.enabled = Toggles.Esp.Value
    EspManager.teamSettings.enemy.box = Toggles.Esp.Value
    EspManager.teamSettings.enemy.name = Toggles.Esp.Value
    EspManager.teamSettings.enemy.healthBar = Toggles.Esp.Value
    EspManager.teamSettings.enemy.distance = Toggles.Esp.Value
    EspManager.teamSettings.enemy.boxColor = { Color3.new(0.984314, 1, 0), 1 }
    EspManager.teamSettings.enemy.boxOutlineColor = { Color3.new(0, 0, 0), 1 }
end)

PlayerEsp:AddToggle("Highlight", {
    Text = "Highlight Player",
    Default = false,
    Tooltip = "Enables Player Highlight"
})

Toggles.Highlight:OnChanged(function()
    EspManager.teamSettings.enemy.chams = Toggles.Highlight.Value
end)

PlayerEsp:AddSlider("Distance", {
    Text = "Esp Distance",
    Default = 10000,
    Min = 1000,
    Max = 20000,
    Rounding = 1,
    Compact = false
})

Options.Distance:OnChanged(function()
    EspManager.sharedSettings.maxDistance = Options.Distance.Value
end)

local Npcs = {}

NpcEsp:AddToggle('Npc', {
    Text = 'Npc Esp',
    Default = false,
    Tooltip = 'Toggle To Enable Npc Esp',
})

Toggles.Npc:OnChanged(function()
    if Toggles.Npc.Value then

        local Liveplayers = {}
        for _, oplayer in pairs(game.Players:GetPlayers()) do
            Liveplayers[oplayer.Name] = true
        end

            for _, alive in pairs(game.Workspace.Live:GetChildren()) do
                if not Liveplayers[alive.Name] then

                local NpcObjectEsp = EspManager.AddInstance(alive, {
                    text = alive.Name .. " " .. "( " .. math.round(alive.Humanoid.Health) .. ' / ' .. alive.Humanoid.MaxHealth .. " ) " .. math.round((alive.Humanoid.Health / alive.Humanoid.MaxHealth) * 100) .. '%',
                    textColor = { Color3.new(0, 0.882353, 1), 1 },
                    limitDistance = true,
                    maxDistance = 400,
                })
                table.insert(Npcs, NpcObjectEsp)
                end    
            end

        game.Workspace.Live.ChildAdded:Connect(function()
            for _, alive in pairs(game.Workspace.Live:GetChildren()) do
                if not Liveplayers[alive.Name] then
                if EspManager._objectCache[alive] then return end

                local NpcObjectEsp = EspManager.AddInstance(alive, {
                    text = alive.Name .. " " .. "( " .. math.round(alive.Humanoid.Health) .. ' / ' .. alive.Humanoid.MaxHealth .. " ) " .. math.round((alive.Humanoid.Health / alive.Humanoid.MaxHealth) * 100) .. '%',
                    textColor = { Color3.new(0, 0.882353, 1), 1 },
                    limitDistance = true,
                    maxDistance = 400,
                })
                table.insert(Npcs, NpcObjectEsp)
                end    
            end
        end)
    else
        for _, instance in pairs(Npcs) do
            instance:Destruct()
        end
        Npcs = {}

        for _, items in pairs(game.Workspace.Live:GetChildren()) do
            EspManager._objectCache[items] = nil
        end

        if Connections.NpcHp then
            Connections.NpcHp:Disconnect()
        end
    end
end)


Library:SetWatermarkVisibility(false)

local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;
end);

Library.KeybindFrame.Visible = tr

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)


local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
MenuGroup:AddToggle("KeybindMenu", {Text = "Keybind Menu", Default = false, Tooltip = "Enable/Disable Keybinds Menu", Callback = function() Library.KeybindFrame.Visible = Toggles.KeybindMenu.Value end})


Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
