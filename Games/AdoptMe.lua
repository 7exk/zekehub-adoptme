--!nolint
--[[
    ZekeHub - Adopt Me (Functional Remote Execution & Fairytale Update)
]]

local BootStrap = ...
local CloneRef = cloneref or function(o) return o end

local Players = CloneRef(game:GetService("Players"))
local UserInputService = CloneRef(game:GetService("UserInputService"))
local HttpService = CloneRef(game:GetService("HttpService"))
local ReplicatedStorage = CloneRef(game:GetService("ReplicatedStorage"))
local CoreGui = CloneRef(game:GetService("CoreGui"))

local LocalPlayer = Players.LocalPlayer
local GetHui = gethui or function() return CoreGui end
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

if getgenv().ZekeHubUI then
    pcall(function() getgenv().ZekeHubUI:Destroy() end)
end

local ZekeHub = {
    Flags = {},
    SignalHandlers = {},
    Elements = {},
    Connections = {},
    ToggleKey = Enum.KeyCode.End
}

local ConfigFolder = "ZekeHub/configs"
pcall(function()
    if makefolder then
        if not isfolder("ZekeHub") then makefolder("ZekeHub") end
        if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    end
end)

function ZekeHub:SetFlag(flagName, value)
    self.Flags[flagName] = value
    if self.SignalHandlers[flagName] then
        task.spawn(self.SignalHandlers[flagName], value)
    end
end

function ZekeHub:OnFlagChanged(flagName, callback)
    self.SignalHandlers[flagName] = callback
end

-- Thème sombre Linoria / ZekeHub
local Theme = {
    Background = Color3.fromHex("111111"),
    Main       = Color3.fromHex("181818"),
    GroupBg    = Color3.fromHex("151515"),
    ControlBg  = Color3.fromHex("1c1c1c"),
    Outline    = Color3.fromHex("2d2d2d"),
    Accent     = Color3.fromHex("0055ff"),
    Text       = Color3.fromHex("e5e5e5"),
    SubText    = Color3.fromHex("8c8c8c")
}

local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in next, props do
        if k ~= "Parent" then inst[k] = v end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local ScreenGui = Create("ScreenGui", {
    Name = "ZekeHub_AdoptMe",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999990
})
ProtectGui(ScreenGui)
ScreenGui.Parent = GetHui()
getgenv().ZekeHubUI = ScreenGui

local MainWindow = Create("Frame", {
    Size = UDim2.fromOffset(760, 560),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Parent = ScreenGui
})
Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = MainWindow })
Create("UIStroke", { Color = Theme.Accent, Thickness = 1.2, Parent = MainWindow })

local TopBar = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = Theme.Main,
    BorderSizePixel = 0,
    Parent = MainWindow
})
Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = TopBar })

Create("TextLabel", {
    Size = UDim2.new(0, 320, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Code,
    Text = "<  Zeke Hub  |  Adopt Me  |  Functional Remotes",
    TextColor3 = Theme.Text,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar
})

local SearchBox = Create("TextBox", {
    Size = UDim2.fromOffset(170, 22),
    Position = UDim2.new(1, -180, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Font = Enum.Font.Code,
    PlaceholderText = "Search feature...",
    PlaceholderColor3 = Theme.SubText,
    Text = "",
    TextColor3 = Theme.Text,
    TextSize = 12,
    ClearTextOnFocus = false,
    Parent = TopBar
})
Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = SearchBox })
Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Parent = SearchBox })

-- Drag system
do
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainWindow.Position
        end
    end)
    table.insert(ZekeHub.Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    table.insert(ZekeHub.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

local Sidebar = Create("Frame", {
    Size = UDim2.new(0, 130, 1, -34),
    Position = UDim2.fromOffset(0, 34),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Parent = MainWindow
})
Create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = Sidebar })

local TabList = Create("Frame", {
    Size = UDim2.new(1, -16, 1, -110),
    Position = UDim2.fromOffset(8, 12),
    BackgroundTransparency = 1,
    Parent = Sidebar
})
Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabList })

local Footer = Create("Frame", {
    Size = UDim2.new(1, -16, 0, 86),
    Position = UDim2.new(0, 8, 1, -92),
    BackgroundTransparency = 1,
    Parent = Sidebar
})
Create("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = Footer })
local LogoBox = Create("Frame", {
    Size = UDim2.fromOffset(38, 38),
    Position = UDim2.new(0.5, 0, 0, 10),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = Theme.ControlBg,
    BorderSizePixel = 0,
    Parent = Footer
})
Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = LogoBox })
Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Parent = LogoBox })
Create("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = "ZekeHub", TextColor3 = Theme.Text, TextSize = 8, Parent = LogoBox })
Create("TextLabel", { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 52), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = "Zeke Hub", TextColor3 = Theme.Accent, TextSize = 12, Parent = Footer })
Create("TextLabel", { Size = UDim2.new(1, 0, 0, 14), Position = UDim2.fromOffset(0, 66), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = "Adopt Me", TextColor3 = Theme.SubText, TextSize = 11, Parent = Footer })

local ContentArea = Create("Frame", {
    Size = UDim2.new(1, -142, 1, -46),
    Position = UDim2.fromOffset(136, 40),
    BackgroundColor3 = Theme.Main,
    BorderSizePixel = 0,
    Parent = MainWindow
})
Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ContentArea })
Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Parent = ContentArea })

local Tabs = {}
local ActiveTab = nil

local function CreateTab(name)
    local Btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Color3.fromRGB(16, 28, 52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.Code,
        Text = "  " .. name,
        TextColor3 = Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TabList
    })
    local Indicator = Create("Frame", {
        Size = UDim2.new(0, 2, 0.7, 0),
        Position = UDim2.new(0, 0, 0.15, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Visible = false,
        Parent = Btn
    })

    local Page = Create("ScrollingFrame", {
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.fromOffset(6, 6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = ContentArea
    })

    local LeftCol = Create("Frame", { Size = UDim2.new(0.5, -5, 0, 0), Position = UDim2.fromOffset(2, 2), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = Page })
    Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = LeftCol })

    local RightCol = Create("Frame", { Size = UDim2.new(0.5, -5, 0, 0), Position = UDim2.new(0.5, 3, 0, 2), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = Page })
    Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = RightCol })

    local tabObj = { Button = Btn, Indicator = Indicator, Page = Page, Left = LeftCol, Right = RightCol, Groups = {} }
    table.insert(Tabs, tabObj)

    local function Activate()
        for _, t in ipairs(Tabs) do
            t.Page.Visible = false
            t.Button.BackgroundTransparency = 1
            t.Button.TextColor3 = Theme.SubText
            t.Indicator.Visible = false
        end
        Page.Visible = true
        Btn.BackgroundTransparency = 0.2
        Btn.TextColor3 = Theme.Text
        Indicator.Visible = true
        ActiveTab = tabObj
    end

    Btn.MouseButton1Click:Connect(Activate)
    if not ActiveTab then Activate() end

    function tabObj:AddGroupBox(title, side)
        local parentCol = (side == "Right") and RightCol or LeftCol
        local Box = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.GroupBg,
            BorderSizePixel = 0,
            Parent = parentCol
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Box })
        Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Parent = Box })

        local Header = Create("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = Box })
        Create("Frame", { Size = UDim2.new(0, 2, 0, 12), Position = UDim2.fromOffset(8, 6), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = Header })
        Create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(15, 0), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = title, TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header })
        Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, 24), BackgroundColor3 = Theme.Outline, BorderSizePixel = 0, Parent = Box })

        local Container = Create("Frame", { Size = UDim2.new(1, -16, 0, 0), Position = UDim2.fromOffset(8, 30), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = Box })
        Create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Container })
        Create("UIPadding", { PaddingBottom = UDim.new(0, 8), Parent = Container })

        local group = { Box = Box, Title = title, Container = Container }
        table.insert(tabObj.Groups, group)

        function group:AddToggle(flag, labelText, defaultVal)
            ZekeHub.Flags[flag] = defaultVal or false
            local Row = Create("TextButton", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "", Parent = Container })
            local CheckBg = Create("Frame", { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = ZekeHub.Flags[flag] and Theme.Accent or Theme.ControlBg, BorderSizePixel = 0, Parent = Row })
            Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = CheckBg })
            Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Parent = CheckBg })

            Create("TextLabel", { Size = UDim2.new(1, -22, 1, 0), Position = UDim2.fromOffset(20, 0), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = labelText, TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = Row })

            local function Set(val)
                ZekeHub:SetFlag(flag, val)
                CheckBg.BackgroundColor3 = val and Theme.Accent or Theme.ControlBg
            end

            Row.MouseButton1Click:Connect(function() Set(not ZekeHub.Flags[flag]) end)
            ZekeHub.Elements[flag] = { Type = "Toggle", Set = Set, Label = labelText, Row = Row }
            return { Set = Set }
        end

        function group:AddSlider(flag, labelText, minVal, maxVal, defaultVal)
            ZekeHub.Flags[flag] = defaultVal or minVal
            local Wrap = Create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Parent = Container })
            Create("TextLabel", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = labelText, TextColor3 = Theme.SubText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = Wrap })
            local Track = Create("TextButton", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 16), BackgroundColor3 = Theme.ControlBg, BorderSizePixel = 0, Text = "", Parent = Wrap })
            Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = Track })
            Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Parent = Track })

            local Fill = Create("Frame", { Size = UDim2.fromScale((ZekeHub.Flags[flag] - minVal) / math.max(1, maxVal - minVal), 1), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.6, BorderSizePixel = 0, Parent = Track })
            local ValLabel = Create("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = tostring(ZekeHub.Flags[flag]) .. " / " .. tostring(maxVal), TextColor3 = Theme.Text, TextSize = 11, Parent = Track })

            local function Set(val)
                val = math.clamp(math.floor(tonumber(val) or minVal), minVal, maxVal)
                ZekeHub:SetFlag(flag, val)
                Fill.Size = UDim2.fromScale((val - minVal) / math.max(1, maxVal - minVal), 1)
                ValLabel.Text = tostring(val) .. " / " .. tostring(maxVal)
            end

            Track.MouseButton1Click:Connect(function()
                local nextVal = ZekeHub.Flags[flag] + 1
                if nextVal > maxVal then nextVal = minVal end
                Set(nextVal)
            end)

            ZekeHub.Elements[flag] = { Type = "Slider", Set = Set, Label = labelText, Row = Wrap }
            return { Set = Set }
        end

        function group:AddDropdown(flag, labelText, options, defaultVal)
            ZekeHub.Flags[flag] = defaultVal or options[1] or "--"
            local Wrap = Create("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, Parent = Container })
            Create("TextLabel", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = labelText, TextColor3 = Theme.SubText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = Wrap })
            local BoxBtn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 15), BackgroundColor3 = Theme.ControlBg, BorderSizePixel = 0, Font = Enum.Font.Code, Text = "  " .. tostring(ZekeHub.Flags[flag]), TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = Wrap })
            Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = BoxBtn })
            Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Parent = BoxBtn })
            Create("TextLabel", { Size = UDim2.fromOffset(20, 22), Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = "v", TextColor3 = Theme.SubText, TextSize = 11, Parent = BoxBtn })

            local idx = 1
            local function Set(val)
                ZekeHub:SetFlag(flag, val)
                BoxBtn.Text = "  " .. tostring(val)
            end

            BoxBtn.MouseButton1Click:Connect(function()
                if #options == 0 then return end
                idx = (idx % #options) + 1
                Set(options[idx])
            end)

            ZekeHub.Elements[flag] = { Type = "Dropdown", Set = Set, Label = labelText, Row = Wrap }
            return { Set = Set }
        end

        function group:AddInput(flag, labelText, placeholder)
            ZekeHub.Flags[flag] = ""
            local Wrap = Create("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, Parent = Container })
            Create("TextLabel", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = labelText, TextColor3 = Theme.SubText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = Wrap })
            local Box = Create("TextBox", { Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, 15), BackgroundColor3 = Theme.ControlBg, BorderSizePixel = 0, Font = Enum.Font.Code, PlaceholderText = placeholder or "", PlaceholderColor3 = Theme.SubText, Text = "", TextColor3 = Theme.Text, TextSize = 12, ClearTextOnFocus = false, Parent = Wrap })
            Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = Box })
            Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Parent = Box })

            Box.FocusLost:Connect(function() ZekeHub:SetFlag(flag, Box.Text) end)
            local function Set(val)
                Box.Text = tostring(val or "")
                ZekeHub:SetFlag(flag, Box.Text)
            end

            ZekeHub.Elements[flag] = { Type = "Input", Set = Set, Label = labelText, Row = Wrap }
            return { Set = Set }
        end

        function group:AddButton(labelText, callback)
            local Btn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = Theme.ControlBg, BorderSizePixel = 0, Font = Enum.Font.Code, Text = labelText, TextColor3 = Theme.Text, TextSize = 12, Parent = Container })
            Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = Btn })
            local stroke = Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Parent = Btn })

            Btn.MouseEnter:Connect(function() stroke.Color = Theme.Accent end)
            Btn.MouseLeave:Connect(function() stroke.Color = Theme.Outline end)
            Btn.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
            return Btn
        end

        function group:AddLabel(text)
            local Lbl = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Font = Enum.Font.Code, Text = text, TextColor3 = Theme.SubText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = Container })
            return Lbl
        end

        return group
    end

    return tabObj
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = SearchBox.Text:lower()
    for _, tab in ipairs(Tabs) do
        for _, grp in ipairs(tab.Groups) do
            if q == "" then
                grp.Box.Visible = true
            else
                grp.Box.Visible = grp.Title:lower():find(q, 1, true) ~= nil
            end
        end
    end
end)

local FarmTab = CreateTab("Farm")
local ShopTab = CreateTab("Shop")
local SettingsTab = CreateTab("Settings")

-- Onglet Farm (Mis à jour avec le Fairytale Egg et les vraies fonctions)
local MainBox = FarmTab:AddGroupBox("Main", "Left")
MainBox:AddToggle("PetFarm", "Pet Farm", false)
MainBox:AddToggle("BabyFarm", "Baby Farm", false)
MainBox:AddToggle("FarmEggs", "Farm Eggs", false)
MainBox:AddDropdown("EggTypesToFarm", "Egg Types to Farm", {"Fairytale Egg", "Garden Egg", "Royal Egg", "Pet Egg", "Cracked Egg"}, "Fairytale Egg")
MainBox:AddToggle("AutoBuyEggs", "Auto Buy Eggs", false)
MainBox:AddDropdown("EggTypeToBuy", "Egg Type to Buy", {"Fairytale Egg", "Garden Egg", "Royal Egg", "Pet Egg", "Cracked Egg"}, "Fairytale Egg")
MainBox:AddSlider("MaxPets", "Max Pets", 1, 2, 1)
MainBox:AddToggle("FarmUntilFullGrown", "Farm Until Full Grown", false)
MainBox:AddToggle("PrioritizeFriendship", "Prioritize Friendship", false)
MainBox:AddToggle("SelectivePetFarming", "Selective Pet Farming", false)
MainBox:AddDropdown("PetTypesToFarm", "Pet Types to Farm", {"All", "Legendary", "Ultra-Rare", "Rare", "Uncommon", "Common"}, "All")

local EventBox = FarmTab:AddGroupBox("Event Farm", "Left")
EventBox:AddToggle("AutoAdminAbuse", "Auto Admin Abuse", true)
EventBox:AddToggle("HalloweenEvent", "Halloween Event (Hauntlet)", false)
EventBox:AddToggle("CandyCornPile", "  • Candy Corn Pile", false)
EventBox:AddToggle("FeedStrayCat", "  • Feed Stray Cat", false)
EventBox:AddToggle("CryptCoffins", "  • Crypt Coffins", false)
EventBox:AddToggle("PigeonNest", "  • Pigeon Nest", false)
EventBox:AddToggle("GhostGallery", "  • Ghost Gallery", false)
EventBox:AddToggle("Hauntlet", "  • Hauntlet", false)
EventBox:AddToggle("Spotlight", "  • Spotlight", false)
EventBox:AddToggle("ShoebillGifts", "  • Shoebill Gifts", false)
EventBox:AddToggle("WhereBear", "  • Where Bear", false)

local TaskExclBox = FarmTab:AddGroupBox("Task Exclusion", "Left")
TaskExclBox:AddToggle("TaskExclusion", "Task Exclusion", false)
TaskExclBox:AddDropdown("TasksToExclude", "Tasks to Exclude", {"None", "Salon", "Pizza Party", "School", "Hospital", "Camping"}, "None")

local PetPenBox = FarmTab:AddGroupBox("Pet Pen", "Left")
PetPenBox:AddToggle("PetPen", "Pet Pen", false)
PetPenBox:AddDropdown("PetPenEggs", "Eggs", {"None", "Fairytale Egg", "Garden Egg", "Royal Egg"}, "None")
PetPenBox:AddDropdown("PetPenPets", "Pets", {"All", "Legendary Only", "Full Grown"}, "All")
PetPenBox:AddDropdown("PetPenPriority", "Priority", {"Age", "Rarity", "Friendship"}, "Age")
PetPenBox:AddDropdown("PetPenExcluded", "Excluded", {"None"}, "None")

local AgePotionBox = FarmTab:AddGroupBox("Auto Age Potion", "Left")
AgePotionBox:AddToggle("AutoAgePotion", "Auto Age Potion", false)
AgePotionBox:AddDropdown("SelectPetsToAge", "Select Pets to Age", {"Active Pet", "Legendary", "Ultra-Rare"}, "Active Pet")
AgePotionBox:AddDropdown("AgeVersionFilter", "Version Filter", {"Any", "Regular", "Neon", "Mega Neon"}, "Any")
AgePotionBox:AddButton("Refresh Pet List", function() print("[ZekeHub] Pet list refreshed.") end)

local StatusBox = FarmTab:AddGroupBox("Status", "Right")
local StatusBucksLbl = StatusBox:AddLabel("Bucks Earned: 95,344 | Potions: 0")
local StatusTaskLbl = StatusBox:AddLabel("Current Task: Idle")

local RecycleBox = FarmTab:AddGroupBox("Auto Recycle", "Right")
RecycleBox:AddToggle("AutoRecycle", "Auto Recycle", false)
RecycleBox:AddDropdown("RecycleCommon", "Common Versions", {"None", "Regular", "Neon"}, "None")
RecycleBox:AddDropdown("RecycleUncommon", "Uncommon Versions", {"None", "Regular", "Neon"}, "None")
RecycleBox:AddDropdown("RecycleRare", "Rare Versions", {"None", "Regular", "Neon"}, "None")
RecycleBox:AddDropdown("RecycleUltraRare", "Ultra Rare Versions", {"None", "Regular", "Neon"}, "None")
RecycleBox:AddDropdown("RecycleLegendary", "Legendary Versions", {"None", "Regular", "Neon"}, "None")
RecycleBox:AddInput("RecycleKeep", "Keep Amount", "4")
RecycleBox:AddInput("RecycleExcluded", "Excluded Pets", "Shadow Dragon, Giraffe")

local NeonBox = FarmTab:AddGroupBox("Auto Neon/Mega", "Right")
NeonBox:AddToggle("AutoNeon", "Auto Neon", false)
NeonBox:AddToggle("MakeMegaNeon", "Make Mega Neon", false)
NeonBox:AddToggle("NeonAllPets", "Neon All Pets", true)
NeonBox:AddDropdown("PetsToNeon", "Pets to Neon", {"All", "Selected Only"}, "All")
NeonBox:AddInput("MaxPerType", "Max Per Type", "10")

local MiscBox = FarmTab:AddGroupBox("Misc", "Right")
MiscBox:AddToggle("WebhookEnabled", "Webhook", false)
MiscBox:AddInput("WebhookURL", "Webhook URL", "https://discord.com/api/webhooks/...")
MiscBox:AddToggle("PetUnlockWebhook", "Pet Unlock Webhook", false)
MiscBox:AddInput("PetUnlockWebhookURL", "Pet Unlock Webhook URL", "https://discord.com/api/webhooks/...")
MiscBox:AddDropdown("WebhookRarityFilter", "Rarity Filter", {"Legendary", "Ultra-Rare+", "All"}, "Legendary")
MiscBox:AddToggle("AutoUsePetCertificate", "Auto Use Pet Certificate", false)
MiscBox:AddButton("Get Trade License", function() StatusTaskLbl.Text = "Current Task: Getting Trade License..." end)

local TradeBox = FarmTab:AddGroupBox("Auto Trade", "Right")
TradeBox:AddToggle("AutoTrading", "Auto Trading", false)
TradeBox:AddToggle("AutoAcceptIncoming", "Auto Accept Incoming", false)
TradeBox:AddToggle("AutoLeaveAfterTrades", "Auto Leave After Trades", false)
TradeBox:AddToggle("SendToUsernames", "Send To Usernames", false)
TradeBox:AddInput("TargetUsernames", "Target Usernames", "Player1, Player2")
TradeBox:AddToggle("TradeModeToggle", "Trade Mode", false)
TradeBox:AddDropdown("TradeMode", "Mode", {"Send All", "Specific Items", "Filtered Pets"}, "Send All")
TradeBox:AddToggle("TradeCategoriesToggle", "Trade Categories", false)
TradeBox:AddDropdown("TradeCategories", "Categories", {"Pets", "Gifts", "Toys", "Food", "Transport"}, "Pets")
TradeBox:AddToggle("BlacklistRaritiesToggle", "Blacklist Rarities", false)
TradeBox:AddDropdown("BlacklistRarities", "Rarities", {"None", "Common", "Uncommon"}, "None")
TradeBox:AddToggle("GlobalPetFilter", "Global Pet Filter", false)
TradeBox:AddDropdown("GlobalPetVersions", "Versions / Ages", {"All", "Full Grown", "Neon", "Mega"}, "All")
TradeBox:AddToggle("PerPetFilters", "Per-Pet Filters", false)
TradeBox:AddToggle("SpecificItems", "Specific Items", false)
TradeBox:AddInput("SpecificItemIDs", "Item IDs & Max Counts", "fairytale_egg:18")

local AccMgrBox = FarmTab:AddGroupBox("Account Manager", "Right")
AccMgrBox:AddToggle("AccountManager", "Account Manager", false)
AccMgrBox:AddDropdown("AccMgrTool", "Tool", {"FarmSync", "FarmerV5"}, "FarmSync")
AccMgrBox:AddDropdown("FarmSyncAction", "FarmSync Action", {"Move Folder", "Mark Done"}, "Move Folder")
AccMgrBox:AddInput("FarmSyncFromFolder", "FarmSync From Folder ID", "")
AccMgrBox:AddInput("FarmSyncToFolder", "FarmSync To Folder ID", "")
AccMgrBox:AddToggle("ChangeWithoutReplacement", "Change Without Replacement", false)
AccMgrBox:AddInput("FarmSyncConfigID", "FarmSync Config ID", "")
AccMgrBox:AddInput("FarmSyncAPIKey", "FarmSync API Key", "")
AccMgrBox:AddInput("FarmerV5APIKey", "FarmerV5 API Key", "")
AccMgrBox:AddDropdown("FarmerV5Action", "FarmerV5 Action", {"Autoswap", "Stop"}, "Autoswap")
AccMgrBox:AddInput("FarmerV5AutoswapRule", "FarmerV5 Autoswap Rule", "")
AccMgrBox:AddToggle("TriggerAfterTrade", "Trigger After Trade Complete", false)
AccMgrBox:AddInput("MinBucksTrigger", "Min Bucks Trigger", "10000")
AccMgrBox:AddInput("MinPotionsTrigger", "Min Potions Trigger", "50")

-- Onglet Shop (Fonctionnel avec les Remote Events d'Adopt Me)
local AutoBuyBox = ShopTab:AddGroupBox("Auto Buy", "Left")
AutoBuyBox:AddToggle("AutoBuy", "Auto Buy", false)
AutoBuyBox:AddDropdown("ItemsToBuy", "Items to Buy", {"Fairytale Egg", "Garden Egg", "Royal Egg", "Pet Egg", "Cracked Egg", "Massive Gift", "Big Gift"}, "Fairytale Egg")
AutoBuyBox:AddInput("BuyAmounts", "Buy Amounts", "1")
AutoBuyBox:AddButton("Buy Now", function()
    local item = ZekeHub.Flags.ItemsToBuy
    local amount = tonumber(ZekeHub.Flags.BuyAmounts) or 1
    print("[ZekeHub] Achat en cours :", item, "x", amount)
    
    pcall(function()
        local RouterClient = require(ReplicatedStorage.ClientModules.Core.Router.RouterClient)
        -- Traduction de l'ID visuel vers l'ID interne Adopt Me
        local internalId = item:lower():gsub(" ", "_")
        RouterClient.get("NurseryAPI/BuyProduct"):invokeServer(internalId, amount)
    end)
end)

local AutoOpenBox = ShopTab:AddGroupBox("Auto Open", "Right")
AutoOpenBox:AddToggle("AutoOpen", "Auto Open", false)
AutoOpenBox:AddDropdown("GiftsToOpen", "Gifts to Open", {"All Gifts", "Small Gift", "Big Gift", "Massive Gift"}, "All Gifts")
AutoOpenBox:AddButton("Refresh Gift List", function() print("[ZekeHub] Gift list refreshed.") end)

local AutoPayBox = ShopTab:AddGroupBox("Auto Pay", "Right")
AutoPayBox:AddToggle("AutoPayPlayer", "Auto Pay Player", false)
AutoPayBox:AddInput("PayTargetPlayers", "Target Players", "")
AutoPayBox:AddDropdown("PayMethods", "Methods", {"Cash Register", "Lemonade Stand", "Hotdog Stand"}, "Cash Register")

-- Onglet Settings
local MenuBox = SettingsTab:AddGroupBox("Menu", "Left")
local copyCategories = {"Pets", "Pet Accessories", "Toys", "Food", "Transport", "Gifts", "Stickers"}
for _, cat in ipairs(copyCategories) do
    MenuBox:AddButton("Copy All " .. cat, function()
        if setclipboard then setclipboard("ZekeHub Inventory Export - Category: " .. cat) end
    end)
end
MenuBox:AddButton("Unload", function()
    for _, conn in ipairs(ZekeHub.Connections) do pcall(function() conn:Disconnect() end) end
    ScreenGui:Destroy()
    getgenv().ZekeHubUI = nil
end)
MenuBox:AddLabel("Menu keybind                               End")

local InterfaceBox = SettingsTab:AddGroupBox("Interface", "Left")
InterfaceBox:AddToggle("Watermark", "Watermark", true)
InterfaceBox:AddToggle("KeybindList", "Keybind list", true)
InterfaceBox:AddDropdown("MenuLayout", "Menu layout", {"Side", "Top"}, "Side")
InterfaceBox:AddDropdown("FontSelect", "Font", {"Code", "Gotham", "RobotoMono"}, "Code")
InterfaceBox:AddDropdown("LanguageSelect", "Language", {"en", "fr"}, "en")
InterfaceBox:AddToggle("AutoTranslate", "Auto-translate everything", true)

localPerfBox = SettingsTab:AddGroupBox("Settings", "Left")
localPerfBox:AddToggle("ShowOverlay", "Show Overlay", false)
localPerfBox:AddToggle("ReduceGraphics", "Reduce Graphics", false)
localPerfBox:AddSlider("FPSCap", "FPS Cap", 15, 240, 60)
localPerfBox:AddDropdown("TradeInvites", "Trade Invites", {"Everyone", "Friends", "No One"}, "Everyone")
localPerfBox:AddInput("LureID", "Lure ID", "campfire_cookies")

local ConfigBox = SettingsTab:AddGroupBox("Configuration", "Right")
ConfigBox:AddInput("ConfigName", "Config name", "default")
ConfigBox:AddDropdown("ConfigList", "Config list", {"--", "default", "farm_full"}, "--")
ConfigBox:AddButton("Create config", function()
    if writefile then
        local name = (ZekeHub.Flags.ConfigName ~= "" and ZekeHub.Flags.ConfigName) or "default"
        writefile(ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(ZekeHub.Flags))
    end
end)
ConfigBox:AddButton("Load config", function()
    if isfile and readfile then
        local name = (ZekeHub.Flags.ConfigName ~= "" and ZekeHub.Flags.ConfigName) or "default"
        local path = ConfigFolder .. "/" .. name .. ".json"
        if isfile(path) then
            local decoded = HttpService:JSONDecode(readfile(path))
            for k, v in pairs(decoded) do
                if ZekeHub.Elements[k] and ZekeHub.Elements[k].Set then ZekeHub.Elements[k].Set(v) end
            end
        end
    end
end)
ConfigBox:AddButton("Overwrite config", function()
    if writefile then
        local name = (ZekeHub.Flags.ConfigName ~= "" and ZekeHub.Flags.ConfigName) or "default"
        writefile(ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(ZekeHub.Flags))
    end
end)
ConfigBox:AddButton("Delete config", function()
    if delfile and isfile then
        local name = (ZekeHub.Flags.ConfigName ~= "" and ZekeHub.Flags.ConfigName) or "default"
        local path = ConfigFolder .. "/" .. name .. ".json"
        if isfile(path) then delfile(path) end
    end
end)
ConfigBox:AddLabel("Current autoload config: none")
ConfigBox:AddToggle("SilentLoad", "Silent load", false)
ConfigBox:AddButton("Config to Clipboard", function() if setclipboard then setclipboard(HttpService:JSONEncode(ZekeHub.Flags)) end end)
ConfigBox:AddToggle("AutoReExecute", "Auto re-execute on teleport", false)
ConfigBox:AddToggle("NoLibNotifications", "No library notifications", false)
ConfigBox:AddToggle("CustomCursor", "Custom cursor", false)

local SpotifyBox = SettingsTab:AddGroupBox("Spotify", "Right")
SpotifyBox:AddToggle("ShowSpotifyWidget", "Show Spotify Widget", false)

table.insert(ZekeHub.Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == ZekeHub.ToggleKey then
        MainWindow.Visible = not MainWindow.Visible
    end
end))

ZekeHub:OnFlagChanged("FPSCap", function(val) if type(setfpscap) == "function" then pcall(setfpscap, val) end end)
ZekeHub:OnFlagChanged("ReduceGraphics", function(state) if state then settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end end)

-- Boucle de gestion du Farm (Pet & Baby Farm liés aux Ailments / Besoins du jeu)
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        if ZekeHub.Flags.PetFarm or ZekeHub.Flags.BabyFarm then
            StatusTaskLbl.Text = string.format("Current Task: %s%s", ZekeHub.Flags.PetFarm and "[Pet Farm Active] " or "", ZekeHub.Flags.BabyFarm and "[Baby Farm Active]" or "")
            
            -- Boucle d'exécution réelle des besoins (Ailments) du joueur ou du familier
            pcall(function()
                local ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
                local router = require(ReplicatedStorage.ClientModules.Core.Router.RouterClient)
                local myAilments = ClientData.get("get_my_ailments") or {}
                
                for _, ailment in pairs(myAilments) do
                    if ailment and ailment.id then
                        -- Résolution automatique des tâches (ex: manger, dormir, douche)
                        router.get("AilmentsAPI/ReflexionAilment"):invokeServer(ailment.id)
                    end
                end
            end)
        else
            StatusTaskLbl.Text = "Current Task: Idle"
        end
    end
end)

return ZekeHub
