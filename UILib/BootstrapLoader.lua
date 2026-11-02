if getgenv().BootStrap then
    pcall(function() getgenv().BootStrap:Destroy() end);
end;

local CloneRef = cloneref or function(Object) return Object end;
local TweenService = CloneRef(game:GetService('TweenService'));
local UserInputService = CloneRef(game:GetService('UserInputService'));
local HttpService = CloneRef(game:GetService('HttpService'));
local LogService = CloneRef(game:GetService('LogService'));
local StarterGui = CloneRef(game:GetService('StarterGui'));
local CoreGui = CloneRef(game:GetService('CoreGui'));

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end;
local GetHui = gethui or function() return CoreGui end;

local NotAllowed = identifyexecutor and string.find(identifyexecutor(), 'Real') or string.find(identifyexecutor(), 'Wave') or false;

local StallSeconds = 40;
local TraceLines = 12;

local function Create(ClassName, Properties)
    local Object = Instance.new(ClassName);
    for Property, Value in next, Properties do
        if Property ~= 'Parent' then
            Object[Property] = Value;
        end;
    end;
    if Properties.Parent then
        Object.Parent = Properties.Parent;
    end;
    return Object;
end;

local function Darken(Color, Amount)
    return Color3.new(
        math.clamp(Color.R - Amount, 0, 1),
        math.clamp(Color.G - Amount, 0, 1),
        math.clamp(Color.B - Amount, 0, 1)
    );
end;

local function ResolveTheme()
    local Theme = {
        Font       = Color3.fromHex('ffffff');
        Main       = Color3.fromHex('1c1c1c');
        Accent     = Color3.fromHex('0055ff');
        Background = Color3.fromHex('141414');
        Outline    = Color3.fromHex('323232');
    };

    pcall(function()
        if isfile and isfile('ZekeHub/themes/default.txt') then
            local Name = readfile('ZekeHub/themes/default.txt');
            local CustomPath = 'ZekeHub/themes/' .. Name .. '.json';
            if Name ~= '' and isfile(CustomPath) then
                local Scheme = HttpService:JSONDecode(readfile(CustomPath));
                if Scheme then
                    Theme.Font       = Color3.fromHex(Scheme.FontColor or 'ffffff');
                    Theme.Main       = Color3.fromHex(Scheme.MainColor or '1c1c1c');
                    Theme.Accent     = Color3.fromHex(Scheme.AccentColor or '0055ff');
                    Theme.Background = Color3.fromHex(Scheme.BackgroundColor or '141414');
                    Theme.Outline    = Color3.fromHex(Scheme.OutlineColor or '323232');
                end;
            end;
        end;
    end);

    return Theme;
end;

local BootStrap = {
    Finished = false;
    Minimized = false;
    Stalled = false;
    Progress = 0;
    StatusText = 'Starting...';
    Started = os.clock();
    LastStep = os.clock();
    Lines = {};
    Seen = {};
    Rows = {};
    Order = 0;
    RowStart = 0;
    Connections = {};
};

do
    local Theme = ResolveTheme();
    local Viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080);
    local Scale = math.clamp(math.min(Viewport.X / 1280, Viewport.Y / 720), 0.75, 1);
    local Mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled;
    local Width, Height = 300, 140;

    BootStrap.Colors = {
        Info = Darken(Theme.Font, 0.4);
        Good = Theme.Font;
        Warn = Color3.fromRGB(255, 200, 80);
        Error = Color3.fromRGB(255, 80, 80);
        Accent = Theme.Accent;
    };

    local ScreenGui = Create('ScreenGui', {
        Name = HttpService:GenerateGUID(false):gsub('-', '');
        ResetOnSpawn = false;
        IgnoreGuiInset = true;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        DisplayOrder = 1000000;
    });
    ProtectGui(ScreenGui);
    ScreenGui.Parent = GetHui();

    local Outer = Create('Frame', {
        AnchorPoint = Mobile and Vector2.new(0.5, 0) or Vector2.new(0, 1);
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Position = Mobile and UDim2.new(0.5, 0, 0, 64) or UDim2.new(0, 20, 1, -20);
        Size = UDim2.fromOffset(Width, Height);
        Parent = ScreenGui;
    });
    Create('UICorner', { CornerRadius = UDim.new(0, 12); Parent = Outer; });
    Create('UIScale', { Scale = Scale; Parent = Outer; });

    local Inner = Create('Frame', {
        BackgroundColor3 = Theme.Main;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        Parent = Outer;
    });
    Create('UICorner', { CornerRadius = UDim.new(0, 11); Parent = Inner; });
    Create('UIStroke', { Color = Theme.Accent; Thickness = 1; ApplyStrokeMode = Enum.ApplyStrokeMode.Border; Parent = Inner; });

    local Title = Create('TextLabel', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 14, 0, 6);
        Size = UDim2.new(1, -60, 0, 20);
        Font = Enum.Font.Code;
        Text = 'ZekeHub';
        TextColor3 = Theme.Font;
        TextSize = 15;
        TextStrokeTransparency = 0;
        TextXAlignment = Enum.TextXAlignment.Left;
        Parent = Inner;
    });

    local function MakeButton(Symbol, OffsetX, TextSize, ButtonWidth)
        local Button = Create('TextButton', {
            AnchorPoint = Vector2.new(1, 0);
            BackgroundTransparency = 1;
            Position = UDim2.new(1, OffsetX, 0, 7);
            Size = UDim2.fromOffset(ButtonWidth or 18, 18);
            Font = Enum.Font.Code;
            Text = Symbol;
            TextColor3 = Darken(Theme.Font, 0.45);
            TextSize = TextSize;
            TextStrokeTransparency = 0;
            Parent = Inner;
        });
        Button.MouseEnter:Connect(function() Button.TextColor3 = Theme.Accent; end);
        Button.MouseLeave:Connect(function() Button.TextColor3 = Darken(Theme.Font, 0.45); end);
        return Button;
    end;

    local CloseButton = MakeButton('X', -10, 13);
    local MinimizeButton = MakeButton('-', -32, 18);
    local CopyButton = MakeButton('Copy log', -54, 12, 64);
    CopyButton.Visible = false;

    local Section = Create('Frame', {
        BackgroundColor3 = Theme.Background;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 8, 0, 30);
        Size = UDim2.new(1, -16, 1, -38);
        Parent = Inner;
    });
    Create('UICorner', { CornerRadius = UDim.new(0, 4); Parent = Section; });
    Create('UIStroke', { Color = Theme.Outline; Thickness = 1; Parent = Section; });

    local Status = Create('TextLabel', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 10, 0, 6);
        Size = UDim2.new(1, -20, 0, 15);
        Font = Enum.Font.Code;
        Text = 'Starting...';
        TextColor3 = Theme.Accent;
        TextSize = 13;
        TextStrokeTransparency = 0;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextTruncate = Enum.TextTruncate.AtEnd;
        Parent = Section;
    });

    local Log = Create('ScrollingFrame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 10, 0, 24);
        Size = UDim2.new(1, -14, 1, -46);
        CanvasSize = UDim2.new();
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 2;
        ScrollBarImageColor3 = Theme.Accent;
        ScrollingDirection = Enum.ScrollingDirection.Y;
        Parent = Section;
    });
    Create('UIListLayout', { SortOrder = Enum.SortOrder.LayoutOrder; Padding = UDim.new(0, 1); Parent = Log; });

    local Percent = Create('TextLabel', {
        AnchorPoint = Vector2.new(1, 1);
        BackgroundTransparency = 1;
        Position = UDim2.new(1, -10, 1, -12);
        Size = UDim2.fromOffset(40, 14);
        Font = Enum.Font.Code;
        Text = '0%';
        TextColor3 = Theme.Accent;
        TextSize = 12;
        TextStrokeTransparency = 0;
        TextXAlignment = Enum.TextXAlignment.Right;
        Parent = Section;
    });

    local BarTrack = Create('Frame', {
        AnchorPoint = Vector2.new(0, 1);
        BackgroundColor3 = Darken(Theme.Main, 0.03);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 10, 1, -11);
        Size = UDim2.new(1, -58, 0, 5);
        Parent = Section;
    });
    Create('UICorner', { CornerRadius = UDim.new(1, 0); Parent = BarTrack; });

    local BarFill = Create('Frame', {
        BackgroundColor3 = Theme.Accent;
        BorderSizePixel = 0;
        Size = UDim2.fromScale(0, 1);
        Parent = BarTrack;
    });
    Create('UICorner', { CornerRadius = UDim.new(1, 0); Parent = BarFill; });

    BootStrap.ScreenGui = ScreenGui;
    BootStrap.Outer = Outer;
    BootStrap.Section = Section;
    BootStrap.Title = Title;
    BootStrap.Status = Status;
    BootStrap.LogFrame = Log;
    BootStrap.Percent = Percent;
    BootStrap.BarFill = BarFill;
    BootStrap.CopyButton = CopyButton;
    BootStrap.Width = Width;
    BootStrap.FullHeight = Height;

    CloseButton.MouseButton1Click:Connect(function() BootStrap:Destroy(); end);
    MinimizeButton.MouseButton1Click:Connect(function() BootStrap:ToggleMinimize(); end);
    CopyButton.MouseButton1Click:Connect(function() BootStrap:CopyReport(); end);
end;

function BootStrap:Time() return os.clock() - self.Started; end;
function BootStrap:Record(Text, Kind)
    local Prefix = (Kind == 'Warn' or Kind == 'Error') and (Kind:upper() .. ': ') or '';
    for Line in tostring(Text or ''):gmatch('[^\n]+') do
        table.insert(self.Lines, string.format('[%5.1fs] %s%s', self:Time(), Prefix, Line));
    end;
end;

function BootStrap:AddLine(Text, Kind)
    self.Order = self.Order + 1;
    local Label = Create('TextLabel', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -4, 0, 0);
        AutomaticSize = Enum.AutomaticSize.Y;
        Font = Enum.Font.Code;
        Text = Text;
        TextColor3 = self.Colors[Kind or 'Info'];
        TextSize = 12;
        TextStrokeTransparency = 0;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Top;
        TextWrapped = true;
        LayoutOrder = self.Order;
        Parent = self.LogFrame;
    });
    return Label;
end;

function BootStrap:Log(Text, Kind)
    if self.Finished then return end;
    self:Record(Text, Kind);
    for Line in tostring(Text or ''):gmatch('[^\n]+') do self:AddLine(Line, Kind); end;
end;

function BootStrap:SetStatus(Text)
    if self.Finished then return end;
    self.StatusText = tostring(Text or '');
    self.Status.Text = self.StatusText;
    self:Log(Text);
end;

function BootStrap:SetDetails(Text) self:Log(Text); end;

function BootStrap:SetProgress(Value)
    if self.Finished then return end;
    Value = math.clamp(tonumber(Value) or 0, 0, 100);
    self.Progress = Value;
    TweenService:Create(self.BarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.fromScale(Value / 100, 1);
    }):Play();
    self.Percent.Text = string.format('%d%%', math.floor(Value + 0.5));
end;

function BootStrap:ToggleMinimize()
    if self.Finished then return end;
    self.Minimized = not self.Minimized;
    self.Section.Visible = not self.Minimized;
    TweenService:Create(self.Outer, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(self.Width, self.Minimized and 30 or self.FullHeight);
    }):Play();
end;

function BootStrap:Finish(Text)
    if self.Finished then return end;
    self:SetProgress(100);
    self:SetStatus(Text or 'Loaded');
    task.delay(0.5, function() self:Destroy(); end);
end;

function BootStrap:Fail(Title, Body)
    if self.Finished then return end;
    self.Failed = true;
    local Red = self.Colors.Error;
    self.Status.TextColor3 = Red;
    self.Percent.TextColor3 = Red;
    self.BarFill.BackgroundColor3 = Red;
    self.StatusText = Title or 'Failed';
    self.Status.Text = self.StatusText;
    if Body then self:Log(Body, 'Error'); end;
end;

function BootStrap:Destroy()
    if self.Finished then return end;
    self.Finished = true;
    getgenv().BootStrap = nil;
    if self.ScreenGui then self.ScreenGui:Destroy(); end;
end;

getgenv().BootStrap = BootStrap;
return BootStrap;
