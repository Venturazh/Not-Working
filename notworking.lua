-- New example script written by wally
-- You can suggest changes with a pull request or something

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

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
    -- Set Center to true if you want the menu to appear in the center
    -- Set AutoShow to true if you want the menu to appear when it is created
    -- Position and Size are also valid options here
    -- but you do not need to define them unless you are changing them :)

    Title = 'Not Working!',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- CALLBACK NOTE:
-- Passing in callback functions via the initial element parameters (i.e. Callback = function(Value)...) works
-- HOWEVER, using Toggles/Options.INDEX:OnChanged(function(Value) ... ) is the RECOMMENDED way to do this.
-- I strongly recommend decoupling UI code from logic code. i.e. Create your UI elements FIRST, and THEN setup :OnChanged functions later.

-- You do not have to set your tabs & groups up this way, just a prefrence.
local Tabs = {
    -- Creates a new tab titled Main
    Main = Window:AddTab('Main'),
	Local = Window:AddTab('Local'),
	Visuals = Window:AddTab('Visuals'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Groupbox and Tabbox inherit the same functions
-- except Tabboxes you have to call the functions on a tab (Tabbox:AddTab(name))
local Self = Tabs.Local:AddLeftGroupbox('Local Player')
local Esp = Tabs.Visuals:AddLeftGroupbox("Visuals")
local Quality = Tabs.Local:AddRightGroupbox("Quality of Life")
local Others = Tabs.Local:AddRightGroupbox("Other Players")

local Esp = require(Main/EspLibrary.lua)

local SpeedHack_Settings = {
    Value = 0,
    Active = false,
    Saved = 0,
}

Self:AddToggle("SpeedHack", {
    Text = "Speed Hack",
    Default = false,
})
Toggles.SpeedHack:OnChanged(function()
    SpeedHack_Settings.Active = Toggles.SpeedHack.Value
    if SpeedHack_Settings.Active then
        Connections.SpeedConn1 = RunService.Heartbeat:Connect(function()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                root.AssemblyLinearVelocity = root.CFrame.LookVector * SpeedHack_Settings.Value
            end
        end)
    else
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        if Connections.SpeedConn1 then
            Connections.SpeedConn1:Disconnect()
        end
        SpeedHack_Settings.Value = false
    end
end)

Self:AddSlider("SpeedHackSpeed", {
    Text = "SpeedHack Speed Multiplier",
    Default = 25,
    Min = 1, 
    Max = 150,
    Rounding = 1,
    Compact = false
})

Options.SpeedHackSpeed:OnChanged(function()
    SpeedHack_Settings.Value = Options.SpeedHackSpeed.Value
    if SpeedHack_Settings.Active then
        Connections.SpeedConn2 = RunService.Heartbeat:Connect(function()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                root.AssemblyLinearVelocity = root.CFrame.LookVector * SpeedHack_Settings.Value
            end
        end)
    else
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        if Connections.SpeedConn2 then
            Connections.SpeedConn2:Disconnect()
        end
        SpeedHack_Settings.Value = false
    end
end)


-- local PlayerSpeed = {
--     Speed = humanoid.WalkSpeed,
--     Bool = false,
--     Saved = 16,
-- }
-- local PlayerJump = {
--     Jump = humanoid.JumpPower,
--     Bool = false,
--     Saved = 7.2,
-- }

-- Self:AddToggle('Walkspeed', {
--     Text = 'Walkspeed',
--     Default = false,
--     Tooltip = 'Changes local player walkspeed',
-- })
-- Toggles.Walkspeed:OnChanged(function()
--     PlayerSpeed.Bool = Toggles.Walkspeed.Value
--     if PlayerSpeed.Bool then
--         humanoid.WalkSpeed = PlayerSpeed.Saved
--     else
--         humanoid.WalkSpeed = PlayerSpeed.Speed
--     end
-- end)

-- Self:AddSlider("Speed", {
--     Text = 'Walkspeed Value',
--     Default = 16,
--     Min = 16,
--     Max = 200,
--     Rounding = 1,
--     Compact = false
-- })
-- Options.Speed:OnChanged(function()
--     PlayerSpeed.Saved = Options.Speed.Value
--     if PlayerSpeed.Bool then
--         humanoid.WalkSpeed = Options.Speed.Value
--     end
-- end)

-- --=================================================================================================--
-- --|                                                                                               |--
-- --=================================================================================================--

-- Self:AddToggle('Jumppower', {
--     Text = 'JumpPower',
--     Default = false,
--     Tooltip = 'Changes local player jump power',
-- })
-- Toggles.Jumppower:OnChanged(function()
--     PlayerJump.Bool = Toggles.Jumppower.Value
--     print("Made Check1")
--     if PlayerJump.Bool then
--         humanoid.JumpPower = PlayerJump.Saved
--         print("Made Check2")
--     else
--         humanoid.JumpPower = PlayerJump.Speed
--         print("Made Check3")
--     end
-- end)

-- Self:AddSlider("Power", {
--     Text = 'Jumppower Value',
--     Default = 7.2,
--     Min = 7.2,
--     Max = 200,
--     Rounding = 1,
--     Compact = false
-- })
-- Options.Power:OnChanged(function()
--     PlayerJump.Saved = Options.Power.Value
--     print("Made Check4")
--     if PlayerJump.Bool then
--         print("Made Check5")
--         humanoid.JumpPower = Options.Power.Value
--     end
--     print("Made Check 6")
-- end)

local FlySettings = {
    Speed = 50,
    LinearVelocity = Instance.new("LinearVelocity"),
    Attachment = Instance.new("Attachment")
}

Self:AddToggle('Fly', {
    Text = 'Fly',
    Default = false,
    Tooltip = 'Toggle To Enable Flying',
})

Toggles.Fly:OnChanged(function()
    if Toggles.Fly.Value == true then

        FlySettings.LinearVelocity = Instance.new("LinearVelocity")
        FlySettings.Attachment = Instance.new("Attachment")

        local LinearVelocity = FlySettings.LinearVelocity
        local Attachment = FlySettings.Attachment

        Connections.FlyConn = RunService.Heartbeat:Connect(function()
            local move = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end

            if move.Magnitude > 0 then
                move = move.Unit * FlySettings.Speed
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
        if FlySettings.LinearVelocity then
            FlySettings.LinearVelocity:Destroy()
        end 
        if FlySettings.Attachment then
            FlySettings.Attachment:Destroy()
        end
    end
end)

Self:AddSlider("FlySpeed", {
    Text = 'Fly Speed',
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 1,
    Compact = false
})
Options.FlySpeed:OnChanged(function()
    FlySettings.Speed = Options.FlySpeed.Value
end)

--=================================================================================================--
--|                                                                                               |--
--=================================================================================================--

local function GetAllPlayers()

    local otherPlayers = {}
    for _, others in pairs(game.Players:GetPlayers()) do
        table.insert(otherPlayers, others.DisplayName)
    end
    return otherPlayers

end

Others:AddDropdown('Players', {
    Values = GetAllPlayers(),
    Default = 1,
    Multi = false,

    Text = 'Players To Spectate',
    Tooltip = 'Players To Spectate',

    Callback = function()

    end   
})

local function RefreshPlayerList()
    Options.Players:SetValues(GetAllPlayers())
end

game.Players.PlayerAdded:Connect(RefreshPlayerList)
game.Players.PlayerRemoving:Connect(RefreshPlayerList)

Options.Players:OnChanged(function()
    for _, others in pairs(game.Players:GetPlayers()) do
        if string.lower(Options.Players.Value)  == string.lower(others.DisplayName) then
            local ochar = others.Character or others.CharacterAdded:Wait()
            local ohum = ochar:FindFirstChildOfClass("Humanoid")

            camera.CameraSubject = ohum
        end
    end
end)

local StopSpectate = Others:AddButton({
    Text = "Stop Spectating",
    Func = function()
        camera.CameraSubject = humanoid
    end,  
    DoubleClick = false,
    Tooltip = "Used To Stop Spectating"
})

Self:AddToggle('NoFall', {
    Text = 'NoFall',
    Default = false,
    Tooltip = 'Toggle To Enable NoFall',
})

Toggles.NoFall:OnChanged(function()
    if Toggles.NoFall.Value == true then

        local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Requests").Ecjodoian

        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()

            if method == "FireServer" and self == Remote then
                return
            end
            return oldNamecall(self, ...)
        end)

        setreadonly(mt, true)
    else
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        if Connections.OldNamecall then
            mt.__namecall = Connections.OldNamecall
        end
        setreadonly(mt, true)
    end
end)

local Points = Quality:AddButton({
    Text = "Free 90 Points",
    Func = function()
        local List = {"Strength", "Fortitude", "Agility", "Intelligence", "Willpower", "Charisma", "WeaponMedium", "WeaponHeavy", "WeaponLight"}

        local Reroll = game:GetService("ReplicatedStorage").Requests.CharacterCreator.RerollAttributes:InvokeServer()
        for i = 0, 20 do
            for _, types in pairs(List) do
                local Decrease = game:GetService("ReplicatedStorage").Requests.CharacterCreator.DecreaseAttribute:InvokeServer(types)
            end
        end
        for i = 0, 30 do
            local Increase = game:GetService("ReplicatedStorage").Requests.IncreaseAttribute:InvokeServer("WeaponMedium")
        end
        local Reroll = game:GetService("ReplicatedStorage").Requests.CharacterCreator.RerollAttributes:InvokeServer()
        for i = 0, 40 do
            for _, types in pairs(List) do
                local Decrease = game:GetService("ReplicatedStorage").Requests.CharacterCreator.DecreaseAttribute:InvokeServer(types)
            end
        end
        for i = 0, 50 do
            local Increase = game:GetService("ReplicatedStorage").Requests.IncreaseAttribute:InvokeServer("WeaponMedium")
        end
        local Reroll = game:GetService("ReplicatedStorage").Requests.CharacterCreator.RerollAttributes:InvokeServer()
        for i = 0, 60 do
            for _, types in pairs(List) do
                local Decrease = game:GetService("ReplicatedStorage").Requests.CharacterCreator.DecreaseAttribute:InvokeServer(types)
            end
        end
        for i = 0, 70 do
            local Increase = game:GetService("ReplicatedStorage").Requests.IncreaseAttribute:InvokeServer("WeaponMedium")
        end
        local Reroll = game:GetService("ReplicatedStorage").Requests.CharacterCreator.RerollAttributes:InvokeServer()
        for i = 0, 80  do
            for _, types in pairs(List) do
                local Decrease = game:GetService("ReplicatedStorage").Requests.CharacterCreator.DecreaseAttribute:InvokeServer(types)
            end
        end
        for i = 0, 100 do
            local Increase = game:GetService("ReplicatedStorage").Requests.IncreaseAttribute:InvokeServer("WeaponMedium")
        end
        local Reroll = game:GetService("ReplicatedStorage").Requests.CharacterCreator.RerollAttributes:InvokeServer()
        for i = 0, 100 do
            for _, types in pairs(List) do
                local Decrease = game:GetService("ReplicatedStorage").Requests.CharacterCreator.DecreaseAttribute:InvokeServer(types)
            end
        end
        for i = 0, 100 do
            local Increase = game:GetService("ReplicatedStorage").Requests.IncreaseAttribute:InvokeServer("WeaponMedium")
        end
        local Reroll = game:GetService("ReplicatedStorage").Requests.CharacterCreator.RerollAttributes:InvokeServer()
        for i = 0, 100 do
            for _, types in pairs(List) do
                local Decrease = game:GetService("ReplicatedStorage").Requests.CharacterCreator.DecreaseAttribute:InvokeServer(types)
            end
        end
    end,  
    DoubleClick = false,
    Tooltip = "Use In Character Creation"
})



--=================================================================================================--
--|                                          ESP                                                     |--
--=================================================================================================--


local function AttachEsp()

    while true do
        for _, others in pairs(game.Players:GetPlayers()) do
            local ochar = others.Character or others.CharacterAdded:Wait()
            local ohum = ochar:FindFirstChildOfClass("Humanoid")
            local oroot = ochar:FindFirstChild("HumanoidRootPart")

            local user = others.UserId
            if Connections.Esp[user] then continue end

            Connections.Esp = Connections.Esp or {}

            Connections.Esp = RunService.Heartbeat:Connect(function()
                
                
            end)

            others.PlayerRemoving:Connect(function(leaving)
                local leavingUser = leaving.UserId
                if Connections.Esp[leavingUser] then
                    Connections.Esp[leavingUser]:Disconnect()
                    Connections.Esp[leavingUser] = nil
                end
            end)
        end
        task.wait()
    end
end


-- We can also get our Main tab via the following code:
-- local LeftGroupBox = Window.Tabs.Main:AddLeftGroupbox('Groupbox')

-- Tabboxes are a tiny bit different, but here's a basic example:
--[[

local TabBox = Tabs.Main:AddLeftTabbox() -- Add Tabbox on left side

local Tab1 = TabBox:AddTab('Tab 1')
local Tab2 = TabBox:AddTab('Tab 2')

-- You can now call AddToggle, etc on the tabs you added to the Tabbox
]]

-- Groupbox:AddToggle
-- Arguments: Index, Options


-- Fetching a toggle object for later use:
-- Toggles.MyToggle.Value

-- Toggles is a table added to getgenv() by the library
-- You index Toggles with the specified index, in this case it is 'MyToggle'
-- To get the state of the toggle you do toggle.Value

-- Calls the passed function when the toggle is updated
-- Toggles.MyToggle:OnChanged(function()
--     -- here we get our toggle object & then get its value
--     print('MyToggle changed to:', Toggles.MyToggle.Value)
-- end)

-- -- This should print to the console: "My toggle state changed! New value: false"
-- Toggles.MyToggle:SetValue(false)

-- -- 1/15/23
-- -- Deprecated old way of creating buttons in favor of using a table
-- -- Added DoubleClick button functionality

-- --[[
--     Groupbox:AddButton
--     Arguments: {
--         Text = string,
--         Func = function,
--         DoubleClick = boolean
--         Tooltip = string,
--     }

--     You can call :AddButton on a button to add a SubButton!
-- ]]

-- local MyButton = LeftGroupBox:AddButton({
--     Text = 'Button',
--     Func = function()
--         print('You clicked a button!')
--     end,
--     DoubleClick = false,
--     Tooltip = 'This is the main button'
-- })

-- local MyButton2 = MyButton:AddButton({
--     Text = 'Sub button',
--     Func = function()
--         print('You clicked a sub button!')
--     end,
--     DoubleClick = true, -- You will have to click this button twice to trigger the callback
--     Tooltip = 'This is the sub button (double click me!)'
-- })

-- --[[
--     NOTE: You can chain the button methods!
--     EXAMPLE:

--     LeftGroupBox:AddButton({ Text = 'Kill all', Func = Functions.KillAll, Tooltip = 'This will kill everyone in the game!' })
--         :AddButton({ Text = 'Kick all', Func = Functions.KickAll, Tooltip = 'This will kick everyone in the game!' })
-- ]]

-- -- Groupbox:AddLabel
-- -- Arguments: Text, DoesWrap
-- LeftGroupBox:AddLabel('This is a label')
-- LeftGroupBox:AddLabel('This is a label\n\nwhich wraps its text!', true)

-- -- Groupbox:AddDivider
-- -- Arguments: None
-- LeftGroupBox:AddDivider()

-- --[[
--     Groupbox:AddSlider
--     Arguments: Idx, SliderOptions

--     SliderOptions: {
--         Text = string,
--         Default = number,
--         Min = number,
--         Max = number,
--         Suffix = string,
--         Rounding = number,
--         Compact = boolean,
--         HideMax = boolean,
--     }

--     Text, Default, Min, Max, Rounding must be specified.
--     Suffix is optional.
--     Rounding is the number of decimal places for precision.

--     Compact will hide the title label of the Slider

--     HideMax will only display the value instead of the value & max value of the slider
--     Compact will do the same thing
-- ]]
-- LeftGroupBox:AddSlider('MySlider', {
--     Text = 'This is my slider!',
--     Default = 0,
--     Min = 0,
--     Max = 5,
--     Rounding = 1,
--     Compact = false,

--     Callback = function(Value)
--         print('[cb] MySlider was changed! New value:', Value)
--     end
-- })

-- -- Options is a table added to getgenv() by the library
-- -- You index Options with the specified index, in this case it is 'MySlider'
-- -- To get the value of the slider you do slider.Value

-- local Number = Options.MySlider.Value
-- Options.MySlider:OnChanged(function()
--     print('MySlider was changed! New value:', Options.MySlider.Value)
-- end)

-- -- This should print to the console: "MySlider was changed! New value: 3"
-- Options.MySlider:SetValue(3)

-- -- Groupbox:AddInput
-- -- Arguments: Idx, Info
-- LeftGroupBox:AddInput('MyTextbox', {
--     Default = 'My textbox!',
--     Numeric = false, -- true / false, only allows numbers
--     Finished = false, -- true / false, only calls callback when you press enter

--     Text = 'This is a textbox',
--     Tooltip = 'This is a tooltip', -- Information shown when you hover over the textbox

--     Placeholder = 'Placeholder text', -- placeholder text when the box is empty
--     -- MaxLength is also an option which is the max length of the text

--     Callback = function(Value)
--         print('[cb] Text updated. New text:', Value)
--     end
-- })

-- Options.MyTextbox:OnChanged(function()
--     print('Text updated. New text:', Options.MyTextbox.Value)
-- end)

-- -- Groupbox:AddDropdown
-- -- Arguments: Idx, Info

-- LeftGroupBox:AddDropdown('MyDropdown', {
--     Values = { 'This', 'is', 'a', 'dropdown' },
--     Default = 1, -- number index of the value / string
--     Multi = false, -- true / false, allows multiple choices to be selected

--     Text = 'A dropdown',
--     Tooltip = 'This is a tooltip', -- Information shown when you hover over the dropdown

--     Callback = function(Value)
--         print('[cb] Dropdown got changed. New value:', Value)
--     end
-- })

-- Options.MyDropdown:OnChanged(function()
--     print('Dropdown got changed. New value:', Options.MyDropdown.Value)
-- end)

-- Options.MyDropdown:SetValue('This')

-- -- Multi dropdowns
-- LeftGroupBox:AddDropdown('MyMultiDropdown', {
--     -- Default is the numeric index (e.g. "This" would be 1 since it if first in the values list)
--     -- Default also accepts a string as well

--     -- Currently you can not set multiple values with a dropdown

--     Values = { 'This', 'is', 'a', 'dropdown' },
--     Default = 1,
--     Multi = true, -- true / false, allows multiple choices to be selected

--     Text = 'A dropdown',
--     Tooltip = 'This is a tooltip', -- Information shown when you hover over the dropdown

--     Callback = function(Value)
--         print('[cb] Multi dropdown got changed:', Value)
--     end
-- })

-- Options.MyMultiDropdown:OnChanged(function()
--     -- print('Dropdown got changed. New value:', )
--     print('Multi dropdown got changed:')
--     for key, value in next, Options.MyMultiDropdown.Value do
--         print(key, value) -- should print something like This, true
--     end
-- end)

-- Options.MyMultiDropdown:SetValue({
--     This = true,
--     is = true,
-- })

-- LeftGroupBox:AddDropdown('MyPlayerDropdown', {
--     SpecialType = 'Player',
--     Text = 'A player dropdown',
--     Tooltip = 'This is a tooltip', -- Information shown when you hover over the dropdown

--     Callback = function(Value)
--         print('[cb] Player dropdown got changed:', Value)
--     end
-- })

-- -- Label:AddColorPicker
-- -- Arguments: Idx, Info

-- -- You can also ColorPicker & KeyPicker to a Toggle as well

-- LeftGroupBox:AddLabel('Color'):AddColorPicker('ColorPicker', {
--     Default = Color3.new(0, 1, 0), -- Bright green
--     Title = 'Some color', -- Optional. Allows you to have a custom color picker title (when you open it)
--     Transparency = 0, -- Optional. Enables transparency changing for this color picker (leave as nil to disable)

--     Callback = function(Value)
--         print('[cb] Color changed!', Value)
--     end
-- })

-- Options.ColorPicker:OnChanged(function()
--     print('Color changed!', Options.ColorPicker.Value)
--     print('Transparency changed!', Options.ColorPicker.Transparency)
-- end)

-- Options.ColorPicker:SetValueRGB(Color3.fromRGB(0, 255, 140))

-- -- Label:AddKeyPicker
-- -- Arguments: Idx, Info

-- LeftGroupBox:AddLabel('Keybind'):AddKeyPicker('KeyPicker', {
--     -- SyncToggleState only works with toggles.
--     -- It allows you to make a keybind which has its state synced with its parent toggle

--     -- Example: Keybind which you use to toggle flyhack, etc.
--     -- Changing the toggle disables the keybind state and toggling the keybind switches the toggle state

--     Default = 'MB2', -- String as the name of the keybind (MB1, MB2 for mouse buttons)
--     SyncToggleState = false,


--     -- You can define custom Modes but I have never had a use for it.
--     Mode = 'Toggle', -- Modes: Always, Toggle, Hold

--     Text = 'Auto lockpick safes', -- Text to display in the keybind menu
--     NoUI = false, -- Set to true if you want to hide from the Keybind menu,

--     -- Occurs when the keybind is clicked, Value is `true`/`false`
--     Callback = function(Value)
--         print('[cb] Keybind clicked!', Value)
--     end,

--     -- Occurs when the keybind itself is changed, `New` is a KeyCode Enum OR a UserInputType Enum
--     ChangedCallback = function(New)
--         print('[cb] Keybind changed!', New)
--     end
-- })

-- -- OnClick is only fired when you press the keybind and the mode is Toggle
-- -- Otherwise, you will have to use Keybind:GetState()
-- Options.KeyPicker:OnClick(function()
--     print('Keybind clicked!', Options.KeyPicker:GetState())
-- end)

-- Options.KeyPicker:OnChanged(function()
--     print('Keybind changed!', Options.KeyPicker.Value)
-- end)

-- task.spawn(function()
--     while true do
--         wait(1)

--         -- example for checking if a keybind is being pressed
--         local state = Options.KeyPicker:GetState()
--         if state then
--             print('KeyPicker is being held down')
--         end

--         if Library.Unloaded then break end
--     end
-- end)

-- Options.KeyPicker:SetValue({ 'MB2', 'Toggle' }) -- Sets keybind to MB2, mode to Hold

-- -- Long text label to demonstrate UI scrolling behaviour.
-- local LeftGroupBox2 = Tabs.Main:AddLeftGroupbox('Groupbox #2');
-- LeftGroupBox2:AddLabel('Oh no...\nThis label spans multiple lines!\n\nWe\'re gonna run out of UI space...\nJust kidding! Scroll down!\n\n\nHello from below!', true)

-- local TabBox = Tabs.Main:AddRightTabbox() -- Add Tabbox on right side

-- -- Anything we can do in a Groupbox, we can do in a Tabbox tab (AddToggle, AddSlider, AddLabel, etc etc...)
-- local Tab1 = TabBox:AddTab('Tab 1')
-- Tab1:AddToggle('Tab1Toggle', { Text = 'Tab1 Toggle' });

-- local Tab2 = TabBox:AddTab('Tab 2')
-- Tab2:AddToggle('Tab2Toggle', { Text = 'Tab2 Toggle' });

-- -- Dependency boxes let us control the visibility of UI elements depending on another UI elements state.
-- -- e.g. we have a 'Feature Enabled' toggle, and we only want to show that features sliders, dropdowns etc when it's enabled!
-- -- Dependency box example:
-- local RightGroupbox = Tabs.Main:AddRightGroupbox('Groupbox #3');
-- RightGroupbox:AddToggle('ControlToggle', { Text = 'Dependency box toggle' });

-- local Depbox = RightGroupbox:AddDependencyBox();
-- Depbox:AddToggle('DepboxToggle', { Text = 'Sub-dependency box toggle' });

-- -- We can also nest dependency boxes!
-- -- When we do this, our SupDepbox automatically relies on the visiblity of the Depbox - on top of whatever additional dependencies we set
-- local SubDepbox = Depbox:AddDependencyBox();
-- SubDepbox:AddSlider('DepboxSlider', { Text = 'Slider', Default = 50, Min = 0, Max = 100, Rounding = 0 });
-- SubDepbox:AddDropdown('DepboxDropdown', { Text = 'Dropdown', Default = 1, Values = {'a', 'b', 'c'} });

-- Depbox:SetupDependencies({
--     { Toggles.ControlToggle, true } -- We can also pass `false` if we only want our features to show when the toggle is off!
-- });

-- SubDepbox:SetupDependencies({
--     { Toggles.DepboxToggle, true }
-- });

-- Library functions
-- Sets the watermark visibility
Library:SetWatermarkVisibility(false)

-- Example of dynamically-updating watermark with common traits (fps and ping)
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

    -- Library:SetWatermark(('LinoriaLib demo | %s fps | %s ms'):format(
    --     math.floor(FPS),
    --     math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    -- ));
end);

Library.KeybindFrame.Visible = true; -- todo: add a function for this

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
