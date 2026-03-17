local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local root = character:FindFirstChild("HumanoidRootPart")
local camera = game.Workspace.CurrentCamera

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Vim = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local Connections = {}
local GeneralSettings = {
    Movement = {
        Speed = 15,
        FlySpeed = 15
    },
    Spoofer = {
        NewAgility = 0,
        Original = 0,
    }

}

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local EspLib = loadstring(game:HttpGet("https://github.com/Venturazh/Not-Working/raw/refs/heads/main/EspLibrary.lua"))();

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Currently Offline',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Visuals = Window:AddTab("Visuals"),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local MovementGroup = Tabs.Main:AddLeftGroupbox('Movement')
local EspGroup = Tabs.Visuals:AddLeftGroupbox("Esp")
local Removals = Tabs.Visuals:AddRightGroupbox("Removals")
local Others = Tabs.Visuals:AddRightGroupbox("Others")

MovementGroup:AddToggle("SpeedHack", {
    Text = "Speed Hack",
    Default = false,

}):AddKeyPicker("Speed Key", {
    Default = "G",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Speed Keybind",
    NoUi = false
})

Toggles.SpeedHack:OnChanged(function()
    if Toggles.SpeedHack.Value then
        Connections.SpeedConn = RunService.Heartbeat:Connect(function()
            
            --TODO: Fix getting stuck on walls if you run into them


            local Look = humanoid.MoveDirection:Dot(root.CFrame.LookVector) --LookVector dot product
            local Right = humanoid.MoveDirection:Dot(root.CFrame.RightVector) --RightVector dot product

            local velocity = Vector3.zero

            if math.abs(Look) > 0.1 then --checks to make sure mouse noise doesn't apply velocity
                velocity += root.CFrame.LookVector * Look * GeneralSettings.Movement.Speed
            end
            if math.abs(Right) > 0.1 then --same here
                velocity += root.CFrame.RightVector * Right * GeneralSettings.Movement.Speed
            end

            if velocity.Magnitude > 0 then --if moving apply velocity
                root.AssemblyLinearVelocity = Vector3.new(velocity.X, root.AssemblyLinearVelocity.Y, velocity.Z)
            end

            print(root.AssemblyLinearVelocity.Y)


        end)
    else
        if Connections.SpeedConn then
            Connections.SpeedConn:Disconnect()
        end
    end
end)

MovementGroup:AddSlider("SpeedMultiplier", {
    Text = "Speed Multiplier",
    Default = 100,
    Min = 90, 
    Max = 350,
    Rounding = 1,
    Compact = false
})

Options.SpeedMultiplier:OnChanged(function()
    GeneralSettings.Movement.Speed = Options.SpeedMultiplier.Value / 5
end)


MovementGroup:AddToggle("Fly", {
    Text = "Fly",
    Default = false,

}):AddKeyPicker("Fly Key", {
    Default = "F",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Fly Keybind",
    NoUi = false
})

local LinearVelocity, Attachment = nil

Toggles.Fly:OnChanged(function()
    if Toggles.Fly.Value then

        LinearVelocity = Instance.new("LinearVelocity")
        Attachment = Instance.new("Attachment")

        Connections.FlyConn = RunService.Heartbeat:Connect(function()
            local move = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end

            if move.Magnitude > 0 then
                move = move.Unit * GeneralSettings.Movement.FlySpeed
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
        if LinearVelocity then
            LinearVelocity:Destroy()
        end 
        if Attachment then
            Attachment:Destroy()
        end
    end
end)

MovementGroup:AddSlider("FlyMultiplier", {
    Text = "Fly Multiplier",
    Default = 100,
    Min = 90, 
    Max = 350,
    Rounding = 1,
    Compact = false
})

Options.FlyMultiplier:OnChanged(function()
    GeneralSettings.Movement.FlySpeed = Options.FlyMultiplier.Value
end)

MovementGroup:AddToggle("AgilitySpoof", {
    Text = "Agility Spoofer",
    Default = false,

})

Toggles.AgilitySpoof:OnChanged(function()
    
    local Live
    local Agility
    
    local ok, result = pcall(function()
        Live = game.workspace:FindFirstChild("Live")
    end)
    
    if ok and Live then
        Agility = Live[player.Name].PassiveAgility
    end
    
    if Agility then
        GeneralSettings.Spoofer.Original = Agility.Value
        if Toggles.AgilitySpoof.Value then
            Agility.Value = GeneralSettings.Spoofer.NewAgility
        else
            Agility.Value = GeneralSettings.Spoofer.Original
        end
    end
end)

MovementGroup:AddSlider("AgilityValue", {
    Text = "Agility Value",
    Default = 100,
    Min = 90, 
    Max = 200,
    Rounding = 1,
    Compact = false
})

Options.AgilityValue:OnChanged(function()
    GeneralSettings.Spoofer.NewAgility = Options.AgilityValue.Value
end)

-------------------------------------------------------------------------------------------

EspGroup:AddToggle("Esp", {
    Text = 'Enable Esp',
    Default = false
}):AddKeyPicker("Enable Esp", {
    Default = "E",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Esp Keybind",
    NoUi = false
})

Toggles.Esp:OnChanged(function()
    if Toggles.Esp.Value then
        EspLib.Enabled = true
        EspLib.ShowBox = true
        EspLib.BoxType = "Corner Box Esp"
        EspLib.ShowName = true
        EspLib.ShowHealth = true
        EspLib.ShowDistance = true
    else
        EspLib.Enabled = false
    end
end)

EspGroup:AddToggle("Tracer", {
    Text = 'Enable Tracers',
    Default = false
})

Toggles.Tracer:OnChanged(function()
    if Toggles.Tracer.Value then
        EspLib.ShowTracer = true
    else
        EspLib.ShowTracer = false
    end
end)

local nofog = Removals:AddButton({
    Text = "Fog Removal",
    Func = function()
        Lighting.FogEnd = 1e10
        Lighting.FogStart = 1e10
    end,
})

local FullBright = Removals:AddButton({
    Text = "Full Bright",
    Func = function()
        Lighting.Brightness = 5
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1e10
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end,
})

-------TODO: Finish Spectate And Make Ts Work This Is Some Bull Shit Ts PMO
-- local function GetAllPlayers()
--     local List = {}
--     for _, player in pairs(game.Players:GetPlayers()) do
--         table.insert(List, player)
--     end
--     return List
-- end


-- local function Spectate()
--     local players = GetAllPlayers()
--     print(players.Name)
-- end


-- Others:AddDropdown("Spectate", {
--     Values = {"Hello", "Hi", "Hey"},
--     Default = 1,
--     Multi = false,

--     Text = "Players",

-- })

-- Options.Spectate:OnChanged(function()
--     Spectate()
-- end)

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

    -- Library:SetWatermark(('No Name | %s fps | %s ms'):format(
    --     math.floor(FPS),
    --     math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    -- ));
end);



Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Home', NoUI = true, Text = 'Menu keybind' })
MenuGroup:AddToggle('Keybinds', { Text = "Keybinds Menu", Default = false })
Toggles.Keybinds:OnChanged(function() Library.KeybindFrame.Visible = Toggles.Keybinds.Value end)

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
