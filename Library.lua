local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Library = {Flags = {}, Setters = {}, Folders = {Root = "Atramenta.rip", Directory = "Atramenta.rip", Configs = "Atramenta.rip/Configs", Assets = "Atramenta.rip/Assets", Fonts = "Atramenta.rip/Fonts"}, MenuKeybind = Enum.KeyCode.F2, Theme = {Accent = Color3.fromRGB(150, 120, 150), Background = Color3.fromRGB(8, 8, 8), Surface = Color3.fromRGB(0, 0, 0), Control = Color3.fromRGB(12, 11, 12), Border = Color3.fromRGB(56, 52, 56), Text = Color3.fromRGB(140, 130, 140), TextBright = Color3.fromRGB(197, 197, 197), TextDim = Color3.fromRGB(77, 72, 77), Header = Color3.fromRGB(127, 115, 127)}, Connections = {}, Guis = {}, Keybinds = {}, Renderers = {}, ActiveWindow = nil, Capture = nil}

local function Call(Function, ...)
    if type(Function) ~= "function" then return false, nil end
    local Args = table.pack(...)
    local Results = table.pack(xpcall(function() return Function(table.unpack(Args, 1, Args.n)) end, function(Error) return tostring(Error) end))
    if Results[1] ~= true then return false, Results[2] end
    return true, table.unpack(Results, 2, Results.n)
end
Library.Call = Call

local GlobalEnvironment = type(getgenv) == "function" and getgenv() or _G
local AtramentaEnvironment = rawget(GlobalEnvironment, "Atramenta")
if type(AtramentaEnvironment) ~= "table" then
    AtramentaEnvironment = {}
    rawset(GlobalEnvironment, "Atramenta", AtramentaEnvironment)
end
local PreviousAtramentaLibrary = rawget(AtramentaEnvironment, "Library")
if type(PreviousAtramentaLibrary) == "table" and PreviousAtramentaLibrary ~= Library and type(PreviousAtramentaLibrary.Unload) == "function" then
    Call(function() PreviousAtramentaLibrary:Unload() end)
end
AtramentaEnvironment.Library = Library
Library.Environment = AtramentaEnvironment

local function Bind(Connection)
    if Connection then Library.Connections[#Library.Connections + 1] = Connection end
    return Connection
end

local function Create(Class, Properties, Children)
    local Object = Instance.new(Class)
    for Key, Value in pairs(Properties or {}) do Object[Key] = Value end
    for _, Child in ipairs(Children or {}) do Child.Parent = Object end
    return Object
end

local function ParentGui()
    if type(gethui) == "function" then
        local Success, Result = Call(gethui)
        if Success and typeof(Result) == "Instance" then return Result end
    end
    return CoreGui
end

local function EnsureFolder(Path)
    if type(Path) ~= "string" or Path == "" or type(makefolder) ~= "function" then return false end
    if type(isfolder) == "function" and isfolder(Path) then return true end
    local Success = Call(makefolder, Path)
    return Success == true
end

local function EnsureFolders()
    EnsureFolder(Library.Folders.Root)
    EnsureFolder(Library.Folders.Configs)
    EnsureFolder(Library.Folders.Assets)
    EnsureFolder(Library.Folders.Fonts)
end
EnsureFolders()

function Library:FontPath(Name)
    local FileName = tostring(Name or ""):gsub("\\", "/"):match("([^/]+)$") or ""
    if FileName == "" then return self.Folders.Fonts end
    return self.Folders.Fonts .. "/" .. FileName
end

function Library:EnsureFont(Name, Source)
    EnsureFolders()
    local Path = self:FontPath(Name)
    if type(isfile) == "function" and isfile(Path) then return true, Path end
    if type(writefile) ~= "function" then return false, Path end
    local Body = Source
    if type(Source) == "string" and Source:match("^https?://") then
        local Success, Result = Call(function() return game:HttpGet(Source) end)
        Body = Success and Result or nil
    elseif type(Source) == "function" then
        local Success, Result = Call(Source)
        Body = Success and Result or nil
    end
    if type(Body) ~= "string" or #Body < 128 then return false, Path end
    local Saved = Call(writefile, Path, Body)
    return Saved == true and (type(isfile) ~= "function" or isfile(Path)), Path
end

function Library:LoadFont(Name, Weight, Style, Source)
    EnsureFolders()
    local Path = self:FontPath(Name)
    if type(isfile) == "function" and not isfile(Path) and Source ~= nil then self:EnsureFont(Name, Source) end
    if type(isfile) == "function" and not isfile(Path) then return nil, nil, Path end
    local AssetFunction = type(getcustomasset) == "function" and getcustomasset or type(getsynasset) == "function" and getsynasset or nil
    if not AssetFunction then return nil, nil, Path end
    local AssetSuccess, Asset = Call(AssetFunction, Path)
    if not AssetSuccess or type(Asset) ~= "string" or Asset == "" then return nil, nil, Path end
    local FontSuccess, FontFace = Call(Font.new, Asset, Weight or Enum.FontWeight.Regular, Style or Enum.FontStyle.Normal)
    if not FontSuccess or typeof(FontFace) ~= "Font" then return nil, Asset, Path end
    return FontFace, Asset, Path
end

local Colors = {
    Bg = Library.Theme.Background, TitleBg = Library.Theme.Surface, Control = Library.Theme.Control, Text = Library.Theme.Text, TextBright = Library.Theme.TextBright,
    TextDim = Library.Theme.TextDim, TextBind = Library.Theme.Header, Section = Library.Theme.Background, CbBg = Library.Theme.Surface,
    CbBorder = Library.Theme.Border, SliderTrack = Color3.fromRGB(24,22,24), DropdownBg = Library.Theme.Background,
    DropdownBord = Library.Theme.Border, Divider = Library.Theme.Border, TabBg = Library.Theme.Surface, ColHdr = Library.Theme.Header,
    SectionBorder = Library.Theme.Border
}
local function SyncThemeColors()
    Colors.Bg=Library.Theme.Background or Colors.Bg Colors.TitleBg=Library.Theme.Surface or Colors.TitleBg Colors.Control=Library.Theme.Control or Colors.Control Colors.Text=Library.Theme.Text or Colors.Text
    Colors.TextBright=Library.Theme.TextBright or Colors.TextBright Colors.TextDim=Library.Theme.TextDim or Colors.TextDim Colors.TextBind=Library.Theme.Header or Colors.TextBind
    Colors.Section=Colors.Bg Colors.CbBg=Colors.TitleBg Colors.CbBorder=Library.Theme.Border or Colors.CbBorder Colors.DropdownBg=Colors.Bg Colors.DropdownBord=Colors.CbBorder
    Colors.Divider=Colors.CbBorder Colors.TabBg=Colors.TitleBg Colors.ColHdr=Library.Theme.Header or Colors.ColHdr Colors.SectionBorder=Colors.CbBorder
end

local function Accent() return Library.Theme.Accent or Color3.fromRGB(150, 120, 150) end
local function AccentDark()
    local H, S, V = Color3.toHSV(Accent())
    return Color3.fromHSV(H, S, V * 0.32)
end
local function AccentHover()
    local H, S, V = Color3.toHSV(Accent())
    return Color3.fromHSV(H, S, math.min(V * 1.09, 1))
end
local function AccentBorder()
    local H, S, V = Color3.toHSV(Accent())
    return Color3.fromHSV(H, S, V * 0.82)
end

function Library:ChangeTheme(Index, Color)
    local Name=tostring(Index or "")
    if typeof(Color)~="Color3" then return end
    local Map={accent="Accent",background="Background",surface="Surface",control="Control",border="Border",text="Text",textbright="TextBright",textdim="TextDim",header="Header"}
    local Key=Map[Name:lower()] or Name
    local Old=self.Theme[Key]
    self.Theme[Key]=Color
    if typeof(Old)=="Color3" and Old~=Color then
        local Properties={"BackgroundColor3","TextColor3","ImageColor3","ScrollBarImageColor3","Color"}
        for _,Gui in ipairs(self.Guis) do
            if Gui and Gui.Parent then
                for _,Object in ipairs(Gui:GetDescendants()) do
                    for _,Property in ipairs(Properties) do
                        local Success,Value=Call(function() return Object[Property] end)
                        if Success and typeof(Value)=="Color3" and Value==Old then Call(function() Object[Property]=Color end) end
                    end
                end
            end
        end
    end
    SyncThemeColors()
    for RendererIndex=#self.Renderers,1,-1 do
        local Renderer=self.Renderers[RendererIndex]
        if type(Renderer)=="function" then Call(Renderer) else table.remove(self.Renderers,RendererIndex) end
    end
end

local function RegisterRenderer(Renderer)
    Library.Renderers[#Library.Renderers + 1] = Renderer
    Call(Renderer)
    return Renderer
end

local function RegisterFlag(Flag, Default, Setter)
    if type(Flag) ~= "string" or Flag == "" then return end
    if Library.Flags[Flag] == nil then Library.Flags[Flag] = Default end
    if type(Setter) == "function" then Library.Setters[Flag] = Setter end
end

local function CloneValue(Value, Seen)
    if type(Value) ~= "table" then return Value end
    Seen = Seen or {}
    if Seen[Value] then return Seen[Value] end
    local Result = {}
    Seen[Value] = Result
    for Key, Item in pairs(Value) do Result[CloneValue(Key, Seen)] = CloneValue(Item, Seen) end
    return Result
end

local function GetGuiInset(ScreenGui)
    if ScreenGui and ScreenGui.IgnoreGuiInset then return Vector2.zero end
    local TopLeft = GuiService:GetGuiInset()
    return TopLeft
end

local function GuiPoint(ScreenGui,Point) return Point end
local function MousePoint(ScreenGui) return UserInputService:GetMouseLocation()-GetGuiInset(ScreenGui) end

local function GetViewportSize(ScreenGui)
    local Viewport=ScreenGui and ScreenGui.AbsoluteSize or Vector2.zero
    if Viewport.X<=0 or Viewport.Y<=0 then
        local Camera=workspace.CurrentCamera
        Viewport=Camera and Camera.ViewportSize or Vector2.new(1920,1080)
    end
    return Viewport
end

local function ClampFrameToViewport(Frame,ScreenGui,Margin)
    if not Frame or not Frame.Parent then return end
    Margin=math.max(tonumber(Margin) or 4,0)
    local Viewport=GetViewportSize(ScreenGui or Frame:FindFirstAncestorOfClass("ScreenGui"))
    local Size=Frame.AbsoluteSize
    local MaxWidth=math.max(80,Viewport.X-Margin*2) local MaxHeight=math.max(60,Viewport.Y-Margin*2)
    if (Size.X>MaxWidth or Size.Y>MaxHeight) and Frame.Size.X.Scale==0 and Frame.Size.Y.Scale==0 then
        Frame.Size=UDim2.fromOffset(math.min(Size.X,MaxWidth),math.min(Size.Y,MaxHeight))
        Size=Frame.AbsoluteSize
    end
    local X=math.clamp(Frame.AbsolutePosition.X,Margin,math.max(Margin,Viewport.X-Size.X-Margin))
    local Y=math.clamp(Frame.AbsolutePosition.Y,Margin,math.max(Margin,Viewport.Y-Size.Y-Margin))
    local Anchor=Frame.AnchorPoint
    Frame.Position=UDim2.fromOffset(X+Size.X*Anchor.X,Y+Size.Y*Anchor.Y)
end

local function BindFrameToViewport(Frame,ScreenGui,Margin)
    local Queued=false
    local function Queue()
        if Queued then return end
        Queued=true
        task.defer(function() Queued=false ClampFrameToViewport(Frame,ScreenGui,Margin) end)
    end
    if ScreenGui then Bind(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(Queue)) end
    Bind(Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(Queue))
    task.defer(Queue)
end

local function MakeDraggable(Frame,Handle,ScreenGui)
    local Dragging,DragInput,StartMouse,StartAbsolute
    ScreenGui=ScreenGui or Frame:FindFirstAncestorOfClass("ScreenGui")
    Bind(Handle.InputBegan:Connect(function(Input)
        if Input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        Dragging=true StartMouse=Input.Position StartAbsolute=Frame.AbsolutePosition
        Bind(Input.Changed:Connect(function() if Input.UserInputState==Enum.UserInputState.End then Dragging=false end end))
    end))
    Bind(Handle.InputChanged:Connect(function(Input) if Input.UserInputType==Enum.UserInputType.MouseMovement then DragInput=Input end end))
    Bind(UserInputService.InputChanged:Connect(function(Input)
        if not Dragging or Input~=DragInput then return end
        local Delta=Input.Position-StartMouse local Viewport=GetViewportSize(ScreenGui) local Size=Frame.AbsoluteSize
        local X=math.clamp(StartAbsolute.X+Delta.X,4,math.max(4,Viewport.X-Size.X-4))
        local Y=math.clamp(StartAbsolute.Y+Delta.Y,4,math.max(4,Viewport.Y-Size.Y-4))
        local Anchor=Frame.AnchorPoint Frame.Position=UDim2.fromOffset(X+Size.X*Anchor.X,Y+Size.Y*Anchor.Y)
    end))
    BindFrameToViewport(Frame,ScreenGui,4)
end

local function MakeResizable(Window,MinimumSize)
    local Frame=Window.Main MinimumSize=MinimumSize or Vector2.new(620,500)
    local Active,StartMouse,StartSize,StartPosition
    local Corners={{"TL",0,0,-1,-1},{"TR",1,0,1,-1},{"BL",0,1,-1,1},{"BR",1,1,1,1}}
    for _,Data in ipairs(Corners) do
        local Name,XScale,YScale,XDirection,YDirection=table.unpack(Data)
        local Handle=Create("TextButton",{Name="Resize"..Name,Parent=Frame,AnchorPoint=Vector2.new(XScale,YScale),Position=UDim2.fromScale(XScale,YScale),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=5000})
        Bind(Handle.InputBegan:Connect(function(Input)
            if Input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            Active={X=XDirection,Y=YDirection} StartMouse=Input.Position StartSize=Frame.AbsoluteSize StartPosition=Frame.AbsolutePosition
        end))
    end
    Bind(UserInputService.InputChanged:Connect(function(Input)
        if not Active or Input.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local Delta=Input.Position-StartMouse local Viewport=GetViewportSize(Window.ScreenGui)
        local MaxWidth=math.max(320,Viewport.X-8) local MaxHeight=math.max(280,Viewport.Y-8)
        local MinWidth=math.min(MinimumSize.X,MaxWidth) local MinHeight=math.min(MinimumSize.Y,MaxHeight)
        local Width=math.clamp(StartSize.X+Delta.X*Active.X,MinWidth,MaxWidth) local Height=math.clamp(StartSize.Y+Delta.Y*Active.Y,MinHeight,MaxHeight)
        local X=StartPosition.X local Y=StartPosition.Y
        if Active.X<0 then X=StartPosition.X+(StartSize.X-Width) end
        if Active.Y<0 then Y=StartPosition.Y+(StartSize.Y-Height) end
        X=math.clamp(X,4,math.max(4,Viewport.X-Width-4)) Y=math.clamp(Y,4,math.max(4,Viewport.Y-Height-4))
        Frame.AnchorPoint=Vector2.zero Frame.Position=UDim2.fromOffset(X,Y) Frame.Size=UDim2.fromOffset(Width,Height)
    end))
    Bind(UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType==Enum.UserInputType.MouseButton1 then Active=nil end end))
    BindFrameToViewport(Frame,Window.ScreenGui,4)
end

local BindSystem={CaptureDelay=0.08}
BindSystem.Display={MouseButton2="M2",MouseButton3="M3",Insert="INS",Delete="DEL",Backspace="BACKSPACE",Tab="TAB",Return="ENTER",Escape="ESC",Space="SPACE",CapsLock="CAPS",LeftAlt="LALT",RightAlt="RALT",LeftControl="LCTRL",RightControl="RCTRL",LeftShift="LSHIFT",RightShift="RSHIFT",LeftMeta="LWIN",RightMeta="RWIN",NumLock="NUM LOCK",ScrollLock="SCROLL LOCK",Pause="PAUSE",Print="PRINT SCREEN",Home="HOME",End="END",PageUp="PAGE UP",PageDown="PAGE DOWN",Up="UP",Down="DOWN",Left="LEFT",Right="RIGHT",QuotedDouble="DOUBLE QUOTE",Exclamation="EXCLAMATION",Hash="HASH",Dollar="DOLLAR",Percent="PERCENT",Ampersand="AMPERSAND",Quote="APOSTROPHE",LeftParenthesis="LEFT PAREN",RightParenthesis="RIGHT PAREN",Asterisk="ASTERISK",Plus="PLUS",Comma="COMMA",Minus="MINUS",Period="PERIOD",Slash="SLASH",Colon="COLON",Semicolon="SEMICOLON",LessThan="LESS THAN",Equals="EQUALS",GreaterThan="GREATER THAN",Question="QUESTION",At="AT",LeftBracket="LEFT BRACKET",BackSlash="BACKSLASH",RightBracket="RIGHT BRACKET",Caret="CARET",Underscore="UNDERSCORE",Backquote="BACKQUOTE",LeftCurly="LEFT CURLY",Pipe="PIPE",RightCurly="RIGHT CURLY",Tilde="TILDE"}
BindSystem.Aliases={NONE=false,INS="Insert",DEL="Delete",ESC="Escape",ENTER="Return",RETURN="Return",CTRL="LeftControl",LCTRL="LeftControl",RCTRL="RightControl",ALT="LeftAlt",LALT="LeftAlt",RALT="RightAlt",SHIFT="LeftShift",LSHIFT="LeftShift",RSHIFT="RightShift",SPACE="Space",TAB="Tab",CAPS="CapsLock",M2="M2",MB2="M2",RMB="M2",MOUSE2="M2",MOUSEBUTTON2="M2",M3="M3",MB3="M3",MMB="M3",MOUSE3="M3",MOUSEBUTTON3="M3"}
BindSystem.SymbolAliases={['!']="Exclamation",['@']="At",['#']="Hash",['$']="Dollar",['%']="Percent",['^']="Caret",['&']="Ampersand",['*']="Asterisk",['(']="LeftParenthesis",[')']="RightParenthesis",['_']="Underscore",['+']="Plus",['{']="LeftCurly",['}']="RightCurly",['|']="Pipe",[':']="Colon",['\"']="QuotedDouble",['<']="LessThan",['>']="GreaterThan",['?']="Question",['~']="Tilde",[',']="Comma",['-']="Minus",['.']="Period",['/']="Slash",[';']="Semicolon",["'"]="Quote",['[']="LeftBracket",['\\']="BackSlash",[']']="RightBracket",['`']="Backquote",['=']="Equals"}
BindSystem.ShiftedSymbols={One="Exclamation",Two="At",Three="Hash",Four="Dollar",Five="Percent",Six="Caret",Seven="Ampersand",Eight="Asterisk",Nine="LeftParenthesis",Zero="RightParenthesis",Minus="Underscore",Equals="Plus",LeftBracket="LeftCurly",RightBracket="RightCurly",BackSlash="Pipe",Semicolon="Colon",Quote="QuotedDouble",Comma="LessThan",Period="GreaterThan",Slash="Question",Backquote="Tilde"}
BindSystem.SymbolKeys={Exclamation={"One",true},At={"Two",true},Hash={"Three",true},Dollar={"Four",true},Percent={"Five",true},Caret={"Six",true},Ampersand={"Seven",true},Asterisk={"Eight",true},LeftParenthesis={"Nine",true},RightParenthesis={"Zero",true},Underscore={"Minus",true},Plus={"Equals",true},LeftCurly={"LeftBracket",true},RightCurly={"RightBracket",true},Pipe={"BackSlash",true},Colon={"Semicolon",true},QuotedDouble={"Quote",true},LessThan={"Comma",true},GreaterThan={"Period",true},Question={"Slash",true},Tilde={"Backquote",true},Comma={"Comma",false},Minus={"Minus",false},Period={"Period",false},Slash={"Slash",false},Semicolon={"Semicolon",false},Quote={"Quote",false},LeftBracket={"LeftBracket",false},BackSlash={"BackSlash",false},RightBracket={"RightBracket",false},Backquote={"Backquote",false},Equals={"Equals",false}}
BindSystem.Keypad={KEYPADZERO="KeypadZero",NUMPAD0="KeypadZero",NUM0="KeypadZero",KP0="KeypadZero",KEYPADONE="KeypadOne",NUMPAD1="KeypadOne",NUM1="KeypadOne",KP1="KeypadOne",KEYPADTWO="KeypadTwo",NUMPAD2="KeypadTwo",NUM2="KeypadTwo",KP2="KeypadTwo",KEYPADTHREE="KeypadThree",NUMPAD3="KeypadThree",NUM3="KeypadThree",KP3="KeypadThree",KEYPADFOUR="KeypadFour",NUMPAD4="KeypadFour",NUM4="KeypadFour",KP4="KeypadFour",KEYPADFIVE="KeypadFive",NUMPAD5="KeypadFive",NUM5="KeypadFive",KP5="KeypadFive",KEYPADSIX="KeypadSix",NUMPAD6="KeypadSix",NUM6="KeypadSix",KP6="KeypadSix",KEYPADSEVEN="KeypadSeven",NUMPAD7="KeypadSeven",NUM7="KeypadSeven",KP7="KeypadSeven",KEYPADEIGHT="KeypadEight",NUMPAD8="KeypadEight",NUM8="KeypadEight",KP8="KeypadEight",KEYPADNINE="KeypadNine",NUMPAD9="KeypadNine",NUM9="KeypadNine",KP9="KeypadNine",KEYPADPLUS="KeypadPlus",NUMPADPLUS="KeypadPlus",KPPLUS="KeypadPlus",KEYPADMINUS="KeypadMinus",NUMPADMINUS="KeypadMinus",KPMINUS="KeypadMinus",KEYPADMULTIPLY="KeypadMultiply",NUMPADMULTIPLY="KeypadMultiply",KPMULTIPLY="KeypadMultiply",KEYPADDIVIDE="KeypadDivide",NUMPADDIVIDE="KeypadDivide",KPDIVIDE="KeypadDivide",KEYPADPERIOD="KeypadPeriod",NUMPADDECIMAL="KeypadPeriod",KPDECIMAL="KeypadPeriod",KEYPADENTER="KeypadEnter",NUMPADENTER="KeypadEnter",KPENTER="KeypadEnter",KEYPADEQUALS="KeypadEquals",NUMPADEQUALS="KeypadEquals",KPEQUALS="KeypadEquals"}

local function EmptyModifiers() return {Ctrl=false,Shift=false,Alt=false} end
local function CopyModifiers(Value) Value=type(Value)=="table" and Value or {}; return {Ctrl=Value.Ctrl==true or Value.ctrl==true or Value.Control==true,Shift=Value.Shift==true or Value.shift==true,Alt=Value.Alt==true or Value.alt==true} end
local function IsModifierKey(Key) return Key==Enum.KeyCode.LeftControl or Key==Enum.KeyCode.RightControl or Key==Enum.KeyCode.LeftShift or Key==Enum.KeyCode.RightShift or Key==Enum.KeyCode.LeftAlt or Key==Enum.KeyCode.RightAlt end
local function ModifierName(Key) if Key==Enum.KeyCode.LeftControl or Key==Enum.KeyCode.RightControl then return "Ctrl" elseif Key==Enum.KeyCode.LeftShift or Key==Enum.KeyCode.RightShift then return "Shift" elseif Key==Enum.KeyCode.LeftAlt or Key==Enum.KeyCode.RightAlt then return "Alt" end end
local function KeyDown(Key) local Ok,Value=Call(UserInputService.IsKeyDown,UserInputService,Key); return Ok and Value==true end
function BindSystem.ReadModifiers(Exclude)
    local M={Ctrl=KeyDown(Enum.KeyCode.LeftControl) or KeyDown(Enum.KeyCode.RightControl),Shift=KeyDown(Enum.KeyCode.LeftShift) or KeyDown(Enum.KeyCode.RightShift),Alt=KeyDown(Enum.KeyCode.LeftAlt) or KeyDown(Enum.KeyCode.RightAlt)}
    local Name=ModifierName(Exclude) if Name then M[Name]=false end
    return M
end

function BindSystem.DisplayKey(Key)
    if Key==nil then return "none" end
    if type(Key)=="string" then return BindSystem.Display[Key] or Key:upper() end
    if typeof(Key)~="EnumItem" then return tostring(Key) end
    local Name=Key.Name local Number=Name:match("^Keypad(%a+)$")
    if Number then local Map={Zero="0",One="1",Two="2",Three="3",Four="4",Five="5",Six="6",Seven="7",Eight="8",Nine="9",Plus="PLUS",Minus="MINUS",Multiply="MULTIPLY",Divide="DIVIDE",Period="DECIMAL",Enter="ENTER",Equals="EQUALS"}; return "NUM "..(Map[Number] or Number:upper()) end
    return BindSystem.Display[Name] or Name:upper()
end
function BindSystem.DisplayChord(Key,Modifiers)
    local M=CopyModifiers(Modifiers) local Parts={} local Symbol=typeof(Key)=="EnumItem" and M.Shift and BindSystem.ShiftedSymbols[Key.Name] or nil
    if M.Ctrl then Parts[#Parts+1]="CTRL" end
    if M.Alt then Parts[#Parts+1]="ALT" end
    if Symbol then Parts[#Parts+1]=BindSystem.Display[Symbol] or Symbol:upper() else if M.Shift then Parts[#Parts+1]="SHIFT" end Parts[#Parts+1]=BindSystem.DisplayKey(Key) end
    return table.concat(Parts,"+")
end

function BindSystem.Normalize(Value)
    if typeof(Value)=="EnumItem" then if Value==Enum.UserInputType.MouseButton1 then return nil end if Value==Enum.UserInputType.MouseButton2 then return "M2" end if Value==Enum.UserInputType.MouseButton3 then return "M3" end if Value.EnumType==Enum.KeyCode then return Value end return nil end
    if type(Value)~="string" then return nil end
    local Symbol=BindSystem.SymbolAliases[Value] or BindSystem.SymbolKeys[Value] and Value or nil
    if Symbol and BindSystem.SymbolKeys[Symbol] then local Code=Enum.KeyCode[BindSystem.SymbolKeys[Symbol][1]]; return Code end
    local Compact=Value:upper():gsub("[%s_%-%+]","")
    if Compact=="M1" or Compact=="MB1" or Compact=="MOUSE1" or Compact=="LMB" then return nil end
    local Alias=BindSystem.Aliases[Compact] if Alias==false then return nil end if Alias=="M2" or Alias=="M3" then return Alias end
    local Wanted=Alias or BindSystem.Keypad[Compact] or Value
    for _,Code in ipairs(Enum.KeyCode:GetEnumItems()) do if Code.Name:upper()==tostring(Wanted):upper() or Code.Name:upper()==Compact then return Code end end
end
function BindSystem.NormalizeBinding(Value,Modifiers)
    local M=CopyModifiers(Modifiers)
    if type(Value)=="string" then local Symbol=BindSystem.SymbolAliases[Value] or BindSystem.SymbolKeys[Value] and Value or nil; local Def=Symbol and BindSystem.SymbolKeys[Symbol] or nil; if Def then M.Shift=Def[2]==true return Enum.KeyCode[Def[1]],M end end
    local Key=BindSystem.Normalize(Value) if not Key then return nil,M end return Key,M
end
function BindSystem.InputKey(Input) if not Input then return nil end if Input.UserInputType==Enum.UserInputType.MouseButton1 then return nil end if Input.UserInputType==Enum.UserInputType.MouseButton2 then return "M2" end if Input.UserInputType==Enum.UserInputType.MouseButton3 then return "M3" end if Input.UserInputType==Enum.UserInputType.Keyboard and Input.KeyCode~=Enum.KeyCode.Unknown then return Input.KeyCode end end
function BindSystem.ModifiersMatch(Expected,Exclude) local A=CopyModifiers(Expected) local B=BindSystem.ReadModifiers(Exclude); return A.Ctrl==B.Ctrl and A.Shift==B.Shift and A.Alt==B.Alt end
function BindSystem.Matches(Input,Key,Modifiers) local Expected=BindSystem.Normalize(Key) if not Expected then return false end local Current=BindSystem.InputKey(Input) if type(Expected)=="string" then return Current==Expected and BindSystem.ModifiersMatch(Modifiers,nil) end return typeof(Current)=="EnumItem" and Current==Expected and BindSystem.ModifiersMatch(Modifiers,Expected) end
function BindSystem.ReleaseMatches(Input,Key) local Expected=BindSystem.Normalize(Key) if not Expected then return false end local Current=BindSystem.InputKey(Input) if type(Expected)=="string" then return Current==Expected end return typeof(Current)=="EnumItem" and Current==Expected end
function BindSystem.KeyId(Key) Key=BindSystem.Normalize(Key) if not Key then return nil end if type(Key)=="string" then return "mouse:"..Key end return "key:"..Key.Name end
function BindSystem.PressedSnapshot()
    local Pressed={} local Success,Keys=Call(UserInputService.GetKeysPressed,UserInputService)
    if Success and type(Keys)=="table" then for _,Input in ipairs(Keys) do local Key=BindSystem.InputKey(Input) local Id=BindSystem.KeyId(Key) if Id then Pressed[Id]=true end end end
    for _,Code in ipairs(Enum.KeyCode:GetEnumItems()) do if Code~=Enum.KeyCode.Unknown then local Ok,Down=Call(UserInputService.IsKeyDown,UserInputService,Code) if Ok and Down==true then local Id=BindSystem.KeyId(Code) if Id then Pressed[Id]=true end end end end
    for _,Pair in ipairs({{Enum.UserInputType.MouseButton2,"M2"},{Enum.UserInputType.MouseButton3,"M3"}}) do local Ok,Down=Call(UserInputService.IsMouseButtonPressed,UserInputService,Pair[1]) if Ok and Down==true then Pressed[BindSystem.KeyId(Pair[2])]=true end end
    return Pressed
end
local function KeyDisplay(Key,Modifiers) return BindSystem.DisplayChord(Key,Modifiers) end
local function NormalizeKey(Value) return BindSystem.Normalize(Value) end
local function InputMatches(Input,Key,Modifiers) return BindSystem.Matches(Input,Key,Modifiers) end
local function RefreshKeybindList() local Controller=Library.KeybindListController if Controller and type(Controller.Refresh)=="function" then Controller:Refresh() end end
local function KeybindGateOpen(BindData)
    if not BindData or BindData.EnabledFlag == nil then return true end
    local Flag = tostring(BindData.EnabledFlag)
    return Library.Flags[Flag] == true
end
local function FireKeybind(BindData,Pressed)
    if not BindData or BindData.Destroyed then return end
    if Pressed == true and not KeybindGateOpen(BindData) then
        if BindData.Value == true then
            BindData.Value = false
            Library.Flags[BindData.Flag] = false
            if type(BindData.Callback) == "function" then Call(BindData.Callback,false) end
            BindData.Render()
            RefreshKeybindList()
        end
        return
    end
    local Current=BindData.TargetControl and BindData.TargetControl:Get() or BindData.Value==true
    local Mode,Value=BindData.Mode,Current
    if Mode=="Hold" then Value=Pressed==true elseif Mode=="Toggle" then if not Pressed then return end Value=not Current elseif Mode=="Always" then Value=true else if not Pressed then return end Value=not Current end
    if BindData.TargetControl then
        BindData.TargetControl:Set(Value)
        BindData.Value=BindData.TargetControl:Get()
    else
        if BindData.Value==Value and Mode=="Hold" then return end
        BindData.Value=Value Library.Flags[BindData.Flag]=Value
        if type(BindData.Callback)=="function" then Call(BindData.Callback,Value) end
    end
    Library.Flags[BindData.Flag]=BindData.Value
    BindData.Render() RefreshKeybindList()
end

local function CancelCapture()
    local Capture = Library.Capture
    if not Capture then return end
    Library.Capture = nil
    if Capture.Bind and Capture.Bind.Render then Capture.Bind.Render() end
end

local function BeginCapture(BindData)
    CancelCapture()
    if BindData.Window then BindData.Window:CloseDropdown() end
    local Blocked=BindSystem.PressedSnapshot()
    Library.Capture={Bind=BindData,Started=os.clock(),Blocked=Blocked,Armed=next(Blocked)==nil,Pending=nil,PendingId=nil,PendingModifiers=EmptyModifiers(),ModifierCandidates={}}
    BindData.Render()
end

local function CreateKeybind(Window,Row,Data,RightOffset,TargetControl,TargetFlag)
    Data=Data or {}
    local Flag=tostring(Data.Flag or Data.Name or ("Keybind"..tostring(#Library.Keybinds+1)))
    local Mode=tostring(Data.Mode or "Toggle") Mode=Mode=="Hold" and "Hold" or Mode=="Always" and "Always" or "Toggle"
    local Initial=TargetControl and TargetControl:Get() or Mode=="Always"
    local InitialKey,InitialModifiers=BindSystem.NormalizeBinding(Data.Default,Data.Modifiers)
    local DisplayName=tostring(Data.Name or "")
    if DisplayName=="" or string.lower(DisplayName)=="keybind" then DisplayName=tostring(TargetFlag or Data.Flag or Flag) end
    local BindData={Window=Window,Flag=Flag,TargetFlag=tostring(TargetFlag or Flag),Name=DisplayName,Key=InitialKey,Modifiers=InitialModifiers,Mode=Mode,Callback=Data.Callback,EnabledFlag=Data.EnabledFlag,TargetControl=TargetControl,Value=Initial,Destroyed=false}
    Library.Flags[Flag]=Initial
    local Button=Create("TextButton",{Parent=Row,Size=UDim2.fromOffset(70,16),Position=UDim2.new(1,-(RightOffset or 0)-70,0.5,-8),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=15})
    local Label=Create("TextLabel",{Parent=Button,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Right,Font=Enum.Font.SourceSans,TextSize=13,TextColor3=Colors.TextBind,Text=""})
    BindData.Button=Button

    function BindData.Render()
        local Capture=Library.Capture local Capturing=Capture and Capture.Bind==BindData local Text
        if Capturing and not Capture.Armed then Text="[release keys]" elseif Capturing and Capture.Pending then Text="[release "..BindSystem.DisplayChord(Capture.Pending,Capture.PendingModifiers).."]" elseif Capturing and next(Capture.ModifierCandidates or {}) then local Names={} for _,Key in pairs(Capture.ModifierCandidates) do Names[#Names+1]=BindSystem.DisplayKey(Key) end table.sort(Names) Text="["..table.concat(Names,"+").." + key]" elseif Capturing then Text="[press key]" else Text="["..BindSystem.DisplayChord(BindData.Key,BindData.Modifiers).."]" end
        Label.Text=Text Label.TextColor3=Capturing and Accent() or Colors.TextBind
        local Width=math.clamp(TextService:GetTextSize(Text,13,Enum.Font.SourceSans,Vector2.new(220,20)).X+4,42,130)
        Button.Size=UDim2.fromOffset(Width,16) Button.Position=UDim2.new(1,-(RightOffset or 0)-Width,0.5,-8)
    end

    function BindData:SetMode(NewMode,ApplyState)
        NewMode=string.lower(tostring(NewMode)) NewMode=NewMode=="hold" and "Hold" or NewMode=="always" and "Always" or "Toggle"
        local Previous=BindData.Mode local Current=BindData.TargetControl and BindData.TargetControl:Get() or BindData.Value==true BindData.Mode=NewMode
        local Desired=Current if NewMode=="Always" then Desired=true elseif Previous=="Always" then Desired=false end
        if ApplyState~=false and Desired~=Current then
            if BindData.TargetControl then BindData.TargetControl:Set(Desired) else BindData.Value=Desired Library.Flags[Flag]=Desired if type(BindData.Callback)=="function" then Call(BindData.Callback,Desired) end end
        end
        BindData.Value=BindData.TargetControl and BindData.TargetControl:Get() or (ApplyState~=false and Desired or BindData.Value)
        Library.Flags[Flag]=BindData.Value BindData.Render() RefreshKeybindList()
    end

    function BindData:Set(Value)
        if type(Value)=="table" then
            if Value.Key~=nil or Value.key~=nil then BindData.Key,BindData.Modifiers=BindSystem.NormalizeBinding(Value.Key or Value.key,Value.Modifiers or Value.modifiers) end
            if Value.Mode~=nil or Value.mode~=nil then local NewMode=Value.Mode or Value.mode BindData:SetMode(NewMode,string.lower(tostring(NewMode))=="always") end
        else BindData.Key,BindData.Modifiers=BindSystem.NormalizeBinding(Value,nil) end
        BindData.Value=BindData.TargetControl and BindData.TargetControl:Get() or BindData.Value Library.Flags[Flag]=BindData.Value
        BindData.Render() RefreshKeybindList()
    end

    local function OpenModeMenu()
        CancelCapture()
        local Owner={Get=function() return BindData.Mode end}
        Window:OpenDropdown(Owner,Button,{"Hold","Toggle","Always"},BindData.Mode,false,function(Value) BindData:SetMode(Value,true) end)
    end

    RegisterFlag(Flag,BindData.Value,function(Value)
        if type(Value)=="table" or typeof(Value)=="EnumItem" or type(Value)=="string" then BindData:Set(Value) return end
        if BindData.TargetControl then BindData.TargetControl:Set(Value==true) BindData.Value=BindData.TargetControl:Get() else BindData.Value=Value==true end
        Library.Flags[Flag]=BindData.Value BindData.Render()
    end)
    Bind(Button.MouseButton1Click:Connect(function() BeginCapture(BindData) end))
    Bind(Button.InputBegan:Connect(function(Input) if Input.UserInputType==Enum.UserInputType.MouseButton2 then OpenModeMenu() end end))
    Library.Keybinds[#Library.Keybinds+1]=BindData RegisterRenderer(BindData.Render)
    if BindData.Mode=="Always" then task.defer(function() if not BindData.Destroyed then if BindData.TargetControl then BindData.TargetControl:Set(true) BindData.Value=true elseif type(BindData.Callback)=="function" then Call(BindData.Callback,true) end end RefreshKeybindList() end) end
    return BindData
end

local function UpdateAll()
    for Index = #Library.Renderers, 1, -1 do
        local Renderer = Library.Renderers[Index]
        if type(Renderer) == "function" then Call(Renderer) else table.remove(Library.Renderers, Index) end
    end
end

local WindowMethods = {}
WindowMethods.__index = WindowMethods
local PageMethods = {}
PageMethods.__index = PageMethods
local SubPageMethods = {}
SubPageMethods.__index = SubPageMethods
local SectionMethods = {}
SectionMethods.__index = SectionMethods

local function ReflowTabs(Window)
    local Count = #Window.PagesOrder
    if Count == 0 then return end
    for Index, Page in ipairs(Window.PagesOrder) do
        Page.Button.Size = UDim2.new(1 / Count, 0, 1, 0)
        Page.Button.Position = UDim2.new((Index - 1) / Count, 0, 0, 0)
        if Page.Divider then Page.Divider.Visible = Index < Count end
    end
end

local function SelectPage(Window, Page)
    Window.ActivePage = Page
    for _, Item in ipairs(Window.PagesOrder) do
        local Selected = Item == Page
        Item.Panel.Visible = Selected
        Item.Button.TextColor3 = Selected and Colors.TextBright or Colors.TextDim
    end
end

local function SelectSubPage(Page, SubPage)
    Page.ActiveSubPage = SubPage
    for _, Item in ipairs(Page.SubPagesOrder) do
        local Selected = Item == SubPage
        Item.Frame.Visible = Selected
        Item.Button.TextColor3 = Selected and Accent() or Colors.TextDim
    end
end

local function CreatePopupLayer(Window)
    local Dropdown = Create("Frame", {
        Parent = Window.ScreenGui,
        Size = UDim2.fromOffset(120, 100),
        BackgroundColor3 = Colors.Bg,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 1000
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 3)}), Create("UIStroke", {Color = Colors.DropdownBord, Thickness = 1})})
    local Scroll = Create("ScrollingFrame", {
        Parent = Dropdown,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.fromOffset(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
        ZIndex = 1001
    }, {Create("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder})})
    Window.Dropdown = Dropdown
    Window.DropdownScroll = Scroll

    local Picker = Create("Frame", {
        Parent = Window.ScreenGui,
        Size = UDim2.fromOffset(220, 215),
        BackgroundColor3 = Colors.Bg,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 2000
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)}), Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1})})
    local SV = Create("Frame", {Parent = Picker, Size = UDim2.fromOffset(180, 180), Position = UDim2.fromOffset(10, 10), BackgroundColor3 = Color3.new(1, 0, 0), BorderSizePixel = 0, ZIndex = 2001})
    Create("Frame", {Parent = SV, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2002}, {Create("UIGradient", {Rotation = 0, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})})})
    Create("Frame", {Parent = SV, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 2003}, {Create("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})})})
    local SVCursor = Create("Frame", {Parent = SV, Size = UDim2.fromOffset(6, 6), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2004}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)}), Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1})})
    local Hue = Create("Frame", {Parent = Picker, Size = UDim2.fromOffset(14, 180), Position = UDim2.fromOffset(198, 10), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2001}, {Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})})
    local HueCursor = Create("Frame", {Parent = Hue, Size = UDim2.new(1, 4, 0, 2), Position = UDim2.fromOffset(-2, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2002}, {Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1})})
    local Alpha = Create("Frame", {Parent = Picker, Size = UDim2.fromOffset(180, 11), Position = UDim2.fromOffset(10, 196), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2001})
    local AlphaGradient = Create("UIGradient", {Parent = Alpha, Rotation = 0, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})})
    local AlphaCursor = Create("Frame", {Parent = Alpha, Size = UDim2.new(0, 2, 1, 4), Position = UDim2.new(1, 0, 0, -2), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2002}, {Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1})})
    Window.Picker = Picker
    Window.PickerSV = SV
    Window.PickerSVCursor = SVCursor
    Window.PickerHue = Hue
    Window.PickerHueCursor = HueCursor
    Window.PickerAlpha = Alpha
    Window.PickerAlphaGradient = AlphaGradient
    Window.PickerAlphaCursor = AlphaCursor
    Window.PickerActive = nil
    Window.PickerDragging = nil

    local function ClampPopup(Size, Position)
        local Viewport = Window.ScreenGui.AbsoluteSize
        if Viewport.X <= 0 or Viewport.Y <= 0 then
            local Camera = workspace.CurrentCamera
            Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
        end
        return Vector2.new(math.clamp(Position.X, 4, math.max(4, Viewport.X - Size.X - 4)), math.clamp(Position.Y, 4, math.max(4, Viewport.Y - Size.Y - 4)))
    end
    Window.ClampPopup = ClampPopup

    local function UpdatePickerFromPoint(Mode,Point)
        local Active=Window.PickerActive if not Active then return end
        local Mouse=Point or MousePoint(Window.ScreenGui) local H,S,V=Color3.toHSV(Active.Color)
        if Mode=="SV" then local Pos,Size=Window.PickerSV.AbsolutePosition,Window.PickerSV.AbsoluteSize if Size.X<=0 or Size.Y<=0 then return end S=math.clamp((Mouse.X-Pos.X)/Size.X,0,1) V=1-math.clamp((Mouse.Y-Pos.Y)/Size.Y,0,1)
        elseif Mode=="Hue" then local Pos,Size=Window.PickerHue.AbsolutePosition,Window.PickerHue.AbsoluteSize if Size.Y<=0 then return end H=math.clamp((Mouse.Y-Pos.Y)/Size.Y,0,1)
        elseif Mode=="Alpha" then local Pos,Size=Window.PickerAlpha.AbsolutePosition,Window.PickerAlpha.AbsoluteSize if Size.X<=0 then return end Active.Alpha=math.clamp((Mouse.X-Pos.X)/Size.X,0,1) end
        Active.Color=Color3.fromHSV(H,S,V) Window.PickerSV.BackgroundColor3=Color3.fromHSV(H,1,1) Window.PickerSVCursor.Position=UDim2.new(S,0,1-V,0) Window.PickerHueCursor.Position=UDim2.new(0,-2,H,0) Window.PickerAlphaCursor.Position=UDim2.new(Active.Alpha or 1,0,0,-2) Window.PickerAlphaGradient.Color=ColorSequence.new(Active.Color) Active:Set(Active.Color,Active.Alpha,true)
    end
    Bind(SV.InputBegan:Connect(function(Input) if Input.UserInputType==Enum.UserInputType.MouseButton1 then Window.PickerDragging="SV" UpdatePickerFromPoint("SV",Input.Position) end end))
    Bind(Hue.InputBegan:Connect(function(Input) if Input.UserInputType==Enum.UserInputType.MouseButton1 then Window.PickerDragging="Hue" UpdatePickerFromPoint("Hue",Input.Position) end end))
    Bind(Alpha.InputBegan:Connect(function(Input) if Input.UserInputType==Enum.UserInputType.MouseButton1 then Window.PickerDragging="Alpha" UpdatePickerFromPoint("Alpha",Input.Position) end end))
    Bind(UserInputService.InputChanged:Connect(function(Input) if Input.UserInputType==Enum.UserInputType.MouseMovement and Window.PickerDragging then UpdatePickerFromPoint(Window.PickerDragging,Input.Position) end end))
    Bind(UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Window.PickerDragging = nil end end))

    Bind(UserInputService.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if Window.Dropdown.Visible then
            local Mouse, Pos, Size = MousePoint(Window.ScreenGui), GuiPoint(Window.ScreenGui, Window.Dropdown.AbsolutePosition), Window.Dropdown.AbsoluteSize
            if not (Mouse.X >= Pos.X and Mouse.X <= Pos.X + Size.X and Mouse.Y >= Pos.Y and Mouse.Y <= Pos.Y + Size.Y) then Window:CloseDropdown() end
        end
        if Window.Picker.Visible then
            local Mouse, Pos, Size = MousePoint(Window.ScreenGui), GuiPoint(Window.ScreenGui, Window.Picker.AbsolutePosition), Window.Picker.AbsoluteSize
            if not (Mouse.X >= Pos.X and Mouse.X <= Pos.X + Size.X and Mouse.Y >= Pos.Y and Mouse.Y <= Pos.Y + Size.Y) then Window:ClosePicker() end
        end
    end))
end

function WindowMethods:CloseDropdown()
    self.Dropdown.Visible = false
    self.DropdownOwner = nil
end

function WindowMethods:ClosePicker()
    self.Picker.Visible = false
    self.PickerActive = nil
    self.PickerDragging = nil
end

function WindowMethods:OpenDropdown(Owner, Anchor, Items, Selected, Multi, Callback)
    self:ClosePicker()
    self:CloseDropdown()
    self.DropdownOwner = Owner
    local Scroll = self.DropdownScroll
    for _, Child in ipairs(Scroll:GetChildren()) do if Child:IsA("TextButton") then Child:Destroy() end end
    local RowHeight = 18
    for Index, Value in ipairs(Items or {}) do
        local IsSelected = Multi and type(Selected) == "table" and table.find(Selected, Value) ~= nil or Selected == Value
        local Button = Create("TextButton", {
            Parent = Scroll,
            Size = UDim2.new(1, 0, 0, RowHeight),
            BackgroundTransparency = 1,
            BackgroundColor3 = Colors.DropdownBg,
            Text = tostring(Value),
            TextColor3 = IsSelected and Accent() or Colors.Text,
            Font = Enum.Font.SourceSans,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            LayoutOrder = Index,
            ZIndex = 1002
        }, {Create("UIPadding", {PaddingLeft = UDim.new(0, 7)})})
        Bind(Button.MouseEnter:Connect(function() Button.BackgroundTransparency = 0.9 Button.BackgroundColor3 = Accent() Button.TextColor3 = Colors.TextBright end))
        Bind(Button.MouseLeave:Connect(function()
            local ActiveSelected = Multi and type(Owner.Get) == "function" and table.find(Owner:Get(), Value) ~= nil or (type(Owner.Get) == "function" and Owner:Get() == Value)
            Button.BackgroundTransparency = 1
            Button.TextColor3 = ActiveSelected and Accent() or Colors.Text
        end))
        Bind(Button.MouseButton1Click:Connect(function()
            Callback(Value)
            if not Multi then self:CloseDropdown() else
                local ActiveSelected = type(Owner.Get) == "function" and table.find(Owner:Get(), Value) ~= nil
                Button.TextColor3 = ActiveSelected and Accent() or Colors.Text
            end
        end))
    end
    local Width = math.max(Anchor.AbsoluteSize.X, 120)
    local Height = math.min((#Items * RowHeight) + 4, 180)
    self.Dropdown.Size = UDim2.fromOffset(Width, math.max(22, Height))
    Scroll.CanvasPosition = Vector2.zero
    local AnchorPos = GuiPoint(self.ScreenGui, Anchor.AbsolutePosition)
    local Position = self.ClampPopup(Vector2.new(Width, math.max(22, Height)), Vector2.new(AnchorPos.X, AnchorPos.Y + Anchor.AbsoluteSize.Y + 2))
    self.Dropdown.Position = UDim2.fromOffset(Position.X, Position.Y)
    self.Dropdown.Visible = true
end

function WindowMethods:OpenPicker(Object, Anchor)
    self:CloseDropdown()
    self.PickerActive = Object
    local H, S, V = Color3.toHSV(Object.Color)
    self.PickerSV.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
    self.PickerSVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
    self.PickerHueCursor.Position = UDim2.new(0, -2, H, 0)
    self.PickerAlphaCursor.Position = UDim2.new(Object.Alpha or 1, 0, 0, -2)
    self.PickerAlphaGradient.Color = ColorSequence.new(Object.Color)
    local AnchorPos = GuiPoint(self.ScreenGui, Anchor.AbsolutePosition)
    local PickerSize = Vector2.new(220, 215)
    local Viewport = self.ScreenGui.AbsoluteSize
    if Viewport.X <= 0 or Viewport.Y <= 0 then
        local Camera = workspace.CurrentCamera
        Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    end
    local RightX = AnchorPos.X + Anchor.AbsoluteSize.X + 6
    local LeftX = AnchorPos.X - PickerSize.X - 6
    local X = RightX + PickerSize.X <= Viewport.X - 4 and RightX or LeftX
    local Y = AnchorPos.Y - 10
    local Position = self.ClampPopup(PickerSize, Vector2.new(X, Y))
    self.Picker.Position = UDim2.fromOffset(Position.X, Position.Y)
    self.Picker.Visible = true
end

function Library:Window(Data)
    Data = Data or {}
    if self.ActiveWindow and type(self.ActiveWindow.Destroy) == "function" then self.ActiveWindow:Destroy() end
    local Parent = ParentGui()
    for _, Existing in ipairs(Parent:GetChildren()) do if Existing:IsA("ScreenGui") and Existing.Name == "AtramentaLibrary" then Existing:Destroy() end end
    local ScreenGui = Create("ScreenGui", {Name = "AtramentaLibrary", Parent = Parent, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = 100, IgnoreGuiInset = false})
    self.Guis[#self.Guis + 1] = ScreenGui
    self.Holder = ScreenGui
    local Size = Data.Size
    local Width, Height = 720, 580
    if typeof(Size) == "UDim2" then Width = math.max(Size.X.Offset, 560) Height = math.max(Size.Y.Offset, 480) end
    local Main = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.fromOffset(Width, Height),
        Position = UDim2.new(0.5, -math.floor(Width / 2), 0.5, -math.floor(Height / 2)),
        BackgroundColor3 = Colors.Bg,
        BorderSizePixel = 0,
        ClipsDescendants = false
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)}), Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1})})
    local TitleBar = Create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = Colors.TitleBg, BorderSizePixel = 0}, {
        Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 32)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))})}),
        Create("Frame", {Name = "AccentLine", Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Accent(), BorderSizePixel = 0}, {Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(0.5, Accent()), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))})})})
    })
    local TitleLabel = Create("TextLabel", {Name = "Title", Parent = TitleBar, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1,
        Text = string.lower(tostring(Data.Name or "atramenta.rip")), Font = Enum.Font.SourceSans, TextSize = 13,
        TextColor3 = Color3.fromRGB(214, 214, 218), TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3})
    local function UpdateTitleLayout()
        if not TitleBar.Parent or not TitleLabel.Parent then return end
        local Absolute = TitleBar.AbsoluteSize
        local WidthPixels = math.max(math.floor(Absolute.X + 0.5), 0)
        local HeightPixels = math.max(math.floor(Absolute.Y + 0.5), 0)
        local CenterX = math.floor(WidthPixels * 0.5 + 0.5)
        local CenterY = math.floor(HeightPixels * 0.5 + 0.5)
        TitleLabel.Position = UDim2.fromOffset(CenterX, CenterY)
        TitleLabel.Size = UDim2.fromOffset(math.max(WidthPixels - 16, 0), HeightPixels)
        TitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
        TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
    end
    Bind(TitleBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTitleLayout))
    Bind(Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTitleLayout))
    task.defer(UpdateTitleLayout)
    local Content = Create("Frame", {Parent = Main, Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 1, -48), BackgroundTransparency = 1, ClipsDescendants = false})
    local TabBar = Create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 1, -26), BackgroundColor3 = Colors.TabBg, BorderSizePixel = 0}, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Create("Frame", {Name = "AccentLine", Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Accent(), BorderSizePixel = 0}, {Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(0.5, Accent()), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))})})}),
        Create("Frame", {Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = Colors.TabBg, BorderSizePixel = 0, ZIndex = 0})
    })
    local Window = setmetatable({Library = self, ScreenGui = ScreenGui, Main = Main, TitleBar = TitleBar, TitleLabel = TitleLabel, UpdateTitleLayout = UpdateTitleLayout, Content = Content, TabBar = TabBar, Pages = {}, PagesOrder = {}, ActivePage = nil, Visible = true, MenuVisible = true, Destroyed = false}, WindowMethods)
    self.ActiveWindow = Window
    CreatePopupLayer(Window)
    MakeDraggable(Main,TitleBar,ScreenGui)
    MakeResizable(Window,Vector2.new(560,480))
    RegisterRenderer(function()
        SyncThemeColors()
        local A = Accent()
        Main.BackgroundColor3=Colors.Bg TitleBar.BackgroundColor3=Colors.TitleBg TabBar.BackgroundColor3=Colors.TabBg
        local MainStroke=Main:FindFirstChildOfClass("UIStroke") if MainStroke then MainStroke.Color=Colors.SectionBorder end
        local TitleLine = TitleBar:FindFirstChild("AccentLine")
        local TabLine = TabBar:FindFirstChild("AccentLine")
        for _, Line in ipairs({TitleLine, TabLine}) do
            if Line then
                Line.BackgroundColor3 = A
                local Gradient = Line:FindFirstChildOfClass("UIGradient")
                if Gradient then Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(0.5, A), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))}) end
            end
        end
    end)
    task.defer(function() if self.ActiveWindow==Window and Window:IsVisible() and type(self.SetNotificationPreviewVisible)=="function" then self:SetNotificationPreviewVisible(true) end end)
    return Window
end

function WindowMethods:ApplyVisibility()
    local State=self.Visible==true and self.MenuVisible~=false and Library.InterfaceOpen~=false
    self.Main.Visible=State
    if type(Library.SetNotificationPreviewVisible)=="function" then Library:SetNotificationPreviewVisible(State) end
    if not State then self:CloseDropdown() self:ClosePicker() end
    if Library.QuickPanelController and type(Library.QuickPanelController.Refresh)=="function" then task.defer(Library.QuickPanelController.Refresh) end
end

function WindowMethods:SetVisible(State)
    self.Visible=State==true
    self:ApplyVisibility()
end

function WindowMethods:SetMenuVisible(State)
    self.MenuVisible=State==true
    self:ApplyVisibility()
end

function WindowMethods:IsVisible() return self.Visible==true and self.MenuVisible~=false and Library.InterfaceOpen~=false end
function WindowMethods:IsRequestedVisible() return self.Visible==true end
function WindowMethods:Toggle() self:SetVisible(not self.Visible) end
function WindowMethods:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    if type(Library.SetNotificationPreviewVisible)=="function" then Library:SetNotificationPreviewVisible(false) end
    if self.ScreenGui and self.ScreenGui.Parent then self.ScreenGui:Destroy() end
    if Library.ActiveWindow == self then Library.ActiveWindow = nil end
end

function WindowMethods:Page(Data)
    Data = Data or {}
    local Name = tostring(Data.Name or ("page" .. tostring(#self.PagesOrder + 1)))
    if self.Pages[Name] then return self.Pages[Name] end
    local Button = Create("TextButton", {Parent = self.TabBar, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = string.lower(Name), Font = Enum.Font.SourceSans, TextSize = 13, TextColor3 = Colors.TextDim, AutoButtonColor = false, ZIndex = 2})
    local Divider = Create("Frame", {Parent = Button, Size = UDim2.fromOffset(1, 14), Position = UDim2.new(1, -1, 0.5, -7), BackgroundColor3 = Color3.fromRGB(56, 52, 56), BorderSizePixel = 0, ZIndex = 3})
    local Panel = Create("Frame", {Parent = self.Content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false})
    local SubBar = Create("Frame", {Parent = Panel, Size = UDim2.new(1, -20, 0, 22), Position = UDim2.fromOffset(10, 4), BackgroundTransparency = 1, Visible = false})
    local SubLayout = Create("UIListLayout", {Parent = SubBar, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 18)})
    local Holder = Create("Frame", {Parent = Panel, Size = UDim2.new(1, 0, 1, -32), Position = UDim2.fromOffset(0, 32), BackgroundTransparency = 1, ClipsDescendants = true})
    local Page = setmetatable({Window = self, Name = Name, Button = Button, Divider = Divider, Panel = Panel, SubBar = SubBar, SubLayout = SubLayout, Holder = Holder, SubPages = {}, SubPagesOrder = {}, ActiveSubPage = nil, DefaultSubPage = nil}, PageMethods)
    self.Pages[Name] = Page
    self.PagesOrder[#self.PagesOrder + 1] = Page
    ReflowTabs(self)
    Bind(Button.MouseButton1Click:Connect(function() SelectPage(self, Page) end))
    if not self.ActivePage then SelectPage(self, Page) end
    return Page
end

function PageMethods:SubPage(Data)
    Data = Data or {}
    local Name = tostring(Data.Name or ("sub" .. tostring(#self.SubPagesOrder + 1)))
    if self.SubPages[Name] then return self.SubPages[Name] end
    self.SubBar.Visible = true
    local Button = Create("TextButton", {Parent = self.SubBar, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = string.lower(Name), Font = Enum.Font.SourceSans, TextSize = 13, TextColor3 = Colors.TextDim, AutoButtonColor = false, LayoutOrder = #self.SubPagesOrder + 1})
    local Frame = Create("Frame", {Parent = self.Holder, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false})
    local Left = Create("ScrollingFrame", {Parent = Frame, Position = UDim2.fromOffset(10, 8), Size = UDim2.new(0.5, -15, 1, -12), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(56, 52, 56), ScrollingDirection = Enum.ScrollingDirection.Y}, {Create("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)}), Create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 6)})})
    local Right = Create("ScrollingFrame", {Parent = Frame, Position = UDim2.new(0.5, 5, 0, 8), Size = UDim2.new(0.5, -15, 1, -12), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(56, 52, 56), ScrollingDirection = Enum.ScrollingDirection.Y}, {Create("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)}), Create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 6)})})
    local SubPage = setmetatable({Page = self, Name = Name, Button = Button, Frame = Frame, Left = Left, Right = Right, Sections = {}, Order = 0}, SubPageMethods)
    self.SubPages[Name] = SubPage
    self.SubPagesOrder[#self.SubPagesOrder + 1] = SubPage
    Bind(Button.MouseButton1Click:Connect(function() SelectSubPage(self, SubPage) end))
    if not self.ActiveSubPage then SelectSubPage(self, SubPage) end
    return SubPage
end

function PageMethods:Section(Data)
    if not self.DefaultSubPage then
        self.DefaultSubPage = self:SubPage({Name = self.Name, Columns = 2})
        self.SubBar.Visible = false
        self.Holder.Position = UDim2.fromOffset(0, 0)
        self.Holder.Size = UDim2.fromScale(1, 1)
    end
    return self.DefaultSubPage:Section(Data)
end

local function CreateSectionRoot(SubPage, Data)
    Data = Data or {}
    local Side = tonumber(Data.Side) == 2 and 2 or 1
    local Parent = Side == 2 and SubPage.Right or SubPage.Left
    SubPage.Order = SubPage.Order + 1
    local Container = Create("Frame", {Parent = Parent, Size = UDim2.new(1, -2, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = SubPage.Order})
    local Outline = Create("Frame", {Parent = Container, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, {
        Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1}),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 8)}),
        Create("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
    })
    local Header = Create("TextLabel", {Parent = Container, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 14), Position = UDim2.fromOffset(8, 2), AnchorPoint = Vector2.new(0, 0), BackgroundColor3 = Colors.Bg, BorderSizePixel = 0, Text = string.lower(tostring(Data.Name or "section")), TextColor3 = Colors.ColHdr, Font = Enum.Font.SourceSans, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 10}, {Create("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)})})
    RegisterRenderer(function() SyncThemeColors() Header.BackgroundColor3=Colors.Bg Header.TextColor3=Colors.ColHdr local Stroke=Outline:FindFirstChildOfClass("UIStroke") if Stroke then Stroke.Color=Colors.SectionBorder end end)
    return Container, Outline, Header
end

function SubPageMethods:Section(Data)
    local Container, Outline, Header = CreateSectionRoot(self, Data)
    local Section = setmetatable({SubPage = self, Window = self.Page.Window, Root = Container, Body = Outline, Header = Header, Controls = {}}, SectionMethods)
    self.Sections[#self.Sections + 1] = Section
    return Section
end

local function AddControl(Section, Object)
    Section.Controls[#Section.Controls + 1] = Object
    return Object
end

local function MakeColorpicker(Section, Row, Data, RightOffset)
    Data = Data or {}
    local Default = Data.Default
    local InitialColor, InitialAlpha = Color3.new(1, 1, 1), 1
    if typeof(Default) == "Color3" then InitialColor = Default
    elseif type(Default) == "table" and typeof(Default.Color) == "Color3" then InitialColor = Default.Color InitialAlpha = 1 - math.clamp(tonumber(Default.Transparency) or 0, 0, 1) end
    local Flag = tostring(Data.Flag or Data.Name or ("Color" .. tostring(#Section.Controls + 1)))
    if typeof(Library.Flags[Flag]) == "Color3" then InitialColor = Library.Flags[Flag] end
    local TallRow = Row.Size.Y.Offset > 20
    local ButtonPosition = TallRow and UDim2.new(1, -(RightOffset or 0) - 18, 0, 1) or UDim2.new(1, -(RightOffset or 0) - 18, 0.5, -6)
    local Button = Create("TextButton", {Parent = Row, Size = UDim2.fromOffset(18, 12), Position = ButtonPosition, BackgroundColor3 = InitialColor, AutoButtonColor = false, Text = "", ZIndex = 20}, {Create("UICorner", {CornerRadius = UDim.new(0, 2)}), Create("UIStroke", {Color = Colors.CbBorder, Thickness = 1})})
    local Object = {Row = Row, Button = Button, Color = InitialColor, Alpha = InitialAlpha, Flag = Flag}
    function Object:Set(Color, Alpha, FromPicker)
        if type(Color) == "table" and typeof(Color.Color) == "Color3" then
            Alpha = 1 - math.clamp(tonumber(Color.Transparency) or 0, 0, 1)
            Color = Color.Color
        end
        if typeof(Color) ~= "Color3" then return end
        Object.Color = Color
        if Alpha ~= nil then Object.Alpha = math.clamp(tonumber(Alpha) or 1, 0, 1) end
        Library.Flags[Flag] = Object.Color
        Button.BackgroundColor3 = Object.Color
        if type(Data.Callback) == "function" then Call(Data.Callback, Object.Color, Object.Alpha) end
    end
    function Object:Get() return Object.Color end
    RegisterFlag(Flag, InitialColor, function(Value) Object:Set(Value) end)
    Bind(Button.MouseButton1Click:Connect(function() Section.Window:OpenPicker(Object, Button) end))
    return Object
end

local function AttachColorpicker(Section, Object, Row, BaseRightOffset)
    Object.Section = Section
    Object.Row = Object.Row or Row
    Object.RightOffset = tonumber(Object.RightOffset) or tonumber(BaseRightOffset) or 0
    if type(Object.Colorpicker) ~= "function" then
        function Object:Colorpicker(ColorData)
            local Offset = tonumber(self.RightOffset) or 0
            local Picker = MakeColorpicker(Section, Row, ColorData, Offset)
            self.RightOffset = Offset + 22
            return Picker
        end
    end
    return Object
end

function SectionMethods:Toggle(Data)
    Data = Data or {}
    local Name, Flag = tostring(Data.Name or "toggle"), tostring(Data.Flag or Data.Name or "toggle")
    local Default = Data.Default == true
    if Library.Flags[Flag] ~= nil then Default = Library.Flags[Flag] == true end
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1})
    local Box = Create("Frame", {Parent = Row, Size = UDim2.fromOffset(9, 9), Position = UDim2.new(0, 0, 0.5, -4.5), BackgroundColor3 = Colors.CbBg}, {Create("UICorner", {CornerRadius = UDim.new(0, 1)}), Create("UIStroke", {Color = Colors.CbBorder, Thickness = 1})})
    local Label = Create("TextLabel", {Parent = Row, Position = UDim2.fromOffset(15, 0), Size = UDim2.new(1, -15, 1, 0), BackgroundTransparency = 1, Text = Name, TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Button = Create("TextButton", {Parent = Row, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 10})
    local Object = {Row = Row, Box = Box, Label = Label, Value = Default, Flag = Flag, RightOffset = 0}
    function Object:Render()
        Box.BackgroundColor3 = Object.Value and Accent() or Colors.CbBg
        Box:FindFirstChildOfClass("UIStroke").Color = Object.Value and Accent() or Colors.CbBorder
    end
    function Object:Set(Value, Silent)
        Object.Value = Value == true
        Library.Flags[Flag] = Object.Value
        Object:Render()
        if not Object.Value then
            for _,BindData in ipairs(Library.Keybinds) do
                if BindData and tostring(BindData.EnabledFlag or "")==Flag and BindData.Value==true then
                    BindData.Value=false
                    Library.Flags[BindData.Flag]=false
                    if type(BindData.Callback)=="function" then Call(BindData.Callback,false) end
                    if BindData.Render then BindData.Render() end
                end
            end
        end
        if not Silent and type(Data.Callback) == "function" then Call(Data.Callback, Object.Value) end
        RefreshKeybindList()
    end
    function Object:Get() return Object.Value end
    function Object:Colorpicker(ColorData)
        local Offset = Object.RightOffset
        local Picker = MakeColorpicker(self.Section, Row, ColorData, Offset)
        Object.RightOffset = Offset + 22
        return Picker
    end
    function Object:Keybind(KeyData)
        Object.RightOffset=Object.RightOffset+70
        return CreateKeybind(self.Section.Window,Row,KeyData,Object.RightOffset-70,Object,Object.Flag)
    end
    Object.Section = self
    RegisterFlag(Flag, Default, function(Value) Object:Set(Value) end)
    RegisterRenderer(function() Object:Render() end)
    Bind(Button.MouseButton1Click:Connect(function() Object:Set(not Object.Value) end))
    Bind(Button.MouseEnter:Connect(function() Box:FindFirstChildOfClass("UIStroke").Color = Object.Value and Accent() or AccentBorder() Label.TextColor3 = Colors.TextBright end))
    Bind(Button.MouseLeave:Connect(function() Object:Render() Label.TextColor3 = Colors.Text end))
    AddControl(self, Object)
    return Object
end

function SectionMethods:Keybind(Data)
    Data = Data or {}
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, -75, 1, 0), BackgroundTransparency = 1, Text = tostring(Data.Name or "keybind"), TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Object = CreateKeybind(self.Window, Row, Data, 0)
    AttachColorpicker(self, Object, Row, 70)
    AddControl(self, Object)
    return Object
end

local function RoundStep(Value, Step)
    Step = tonumber(Step) or 0
    if Step <= 0 then return Value end
    return math.floor(Value / Step + 0.5) * Step
end

function SectionMethods:Slider(Data)
    Data = Data or {}
    local Name, Flag = tostring(Data.Name or "slider"), tostring(Data.Flag or Data.Name or "slider")
    local Minimum, Maximum = tonumber(Data.Min) or 0, tonumber(Data.Max) or 100
    local Step = tonumber(Data.Step) or 1
    local Default = math.clamp(tonumber(Data.Default) or Minimum, Minimum, Maximum)
    if type(Library.Flags[Flag]) == "number" then Default = math.clamp(Library.Flags[Flag], Minimum, Maximum) end
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Text = Name, TextColor3 = Colors.TextDim, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Minus = Create("TextButton", {Parent = Row, Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(0, 13), BackgroundTransparency = 1, Text = "-", TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSansBold, TextSize = 14})
    local Plus = Create("TextButton", {Parent = Row, Size = UDim2.fromOffset(12, 12), Position = UDim2.new(1, -12, 0, 13), BackgroundTransparency = 1, Text = "+", TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSansBold, TextSize = 14})
    local Track = Create("Frame", {Parent = Row, Size = UDim2.new(1, -36, 0, 3), Position = UDim2.fromOffset(18, 17), BackgroundColor3 = Colors.SliderTrack, BorderSizePixel = 0})
    local Fill = Create("Frame", {Parent = Track, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0}, {Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, AccentDark()), ColorSequenceKeypoint.new(0.5, Accent()), ColorSequenceKeypoint.new(1, AccentDark())})})})
    local ValueLabel = Create("TextLabel", {Parent = Track, Size = UDim2.fromOffset(56, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Colors.TextBright, Font = Enum.Font.SourceSans, TextSize = 12, ZIndex = 5}, {Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1})})
    local Object = {Row = Row, Value = Default, Flag = Flag}
    function Object:Render()
        local Ratio = Maximum > Minimum and math.clamp((Object.Value - Minimum) / (Maximum - Minimum), 0, 1) or 0
        Fill.Size = UDim2.new(Ratio, 0, 1, 0)
        ValueLabel.Position = UDim2.new(Ratio, 0, 0.5, 0)
        local Decimals = Step < 1 and math.max(0, math.ceil(-math.log10(Step))) or 0
        ValueLabel.Text = string.format("%." .. tostring(math.min(Decimals, 4)) .. "f", Object.Value) .. tostring(Data.Suffix or "")
        local Gradient = Fill:FindFirstChildOfClass("UIGradient")
        if Gradient then Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, AccentDark()), ColorSequenceKeypoint.new(0.5, Accent()), ColorSequenceKeypoint.new(1, AccentDark())}) end
    end
    function Object:Set(Value, Silent)
        Value = math.clamp(RoundStep(tonumber(Value) or Minimum, Step), Minimum, Maximum)
        Object.Value = Value
        Library.Flags[Flag] = Value
        Object:Render()
        if not Silent and type(Data.Callback) == "function" then Call(Data.Callback, Value) end
    end
    function Object:Get() return Object.Value end
    local Dragging = false
    local function FromMouse()
        local Width = Track.AbsoluteSize.X
        if Width <= 0 then return end
        local Mouse = MousePoint(self.Window.ScreenGui)
        local T = math.clamp((Mouse.X - GuiPoint(self.Window.ScreenGui, Track.AbsolutePosition).X) / Width, 0, 1)
        Object:Set(Minimum + (Maximum - Minimum) * T)
    end
    Bind(Track.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true FromMouse() end end))
    Bind(UserInputService.InputChanged:Connect(function(Input) if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then FromMouse() end end))
    Bind(UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end))
    Bind(Minus.MouseButton1Click:Connect(function() Object:Set(Object.Value - Step) end))
    Bind(Plus.MouseButton1Click:Connect(function() Object:Set(Object.Value + Step) end))
    RegisterFlag(Flag, Default, function(Value) Object:Set(Value) end)
    RegisterRenderer(function() Object:Render() end)
    AttachColorpicker(self, Object, Row, 0)
    AddControl(self, Object)
    return Object
end

function SectionMethods:RangeSlider(Data)
    Data = Data or {}
    local Minimum, Maximum = tonumber(Data.Min) or 0, tonumber(Data.Max) or 100
    local Step = tonumber(Data.Step) or 1
    local Default = type(Data.Default) == "table" and Data.Default or {Minimum, Maximum}
    local Low = math.clamp(tonumber(Default[1]) or Minimum, Minimum, Maximum)
    local High = math.clamp(tonumber(Default[2]) or Maximum, Minimum, Maximum)
    if Low > High then Low, High = High, Low end
    local Flag = tostring(Data.Flag or Data.Name or "range")
    local MinFlag = tostring(Data.MinFlag or (Flag .. " Minimum"))
    local MaxFlag = tostring(Data.MaxFlag or (Flag .. " Maximum"))
    if type(Library.Flags[MinFlag]) == "number" then Low = Library.Flags[MinFlag] end
    if type(Library.Flags[MaxFlag]) == "number" then High = Library.Flags[MaxFlag] end
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Text = tostring(Data.Name or "range"), TextColor3 = Colors.TextDim, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Track = Create("Frame", {Parent = Row, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.fromOffset(0, 20), BackgroundColor3 = Colors.SliderTrack, BorderSizePixel = 0})
    local Fill = Create("Frame", {Parent = Track, BackgroundColor3 = Accent(), BorderSizePixel = 0})
    local LowLabel = Create("TextLabel", {Parent = Row, Size = UDim2.fromOffset(60, 10), Position = UDim2.fromOffset(0, 24), BackgroundTransparency = 1, TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSans, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
    local HighLabel = Create("TextLabel", {Parent = Row, Size = UDim2.fromOffset(60, 10), Position = UDim2.new(1, -60, 0, 24), BackgroundTransparency = 1, TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSans, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right})
    local Object = {Row = Row, Low = Low, High = High, Flag = Flag}
    function Object:Render()
        local A = Maximum > Minimum and (Object.Low - Minimum) / (Maximum - Minimum) or 0
        local B = Maximum > Minimum and (Object.High - Minimum) / (Maximum - Minimum) or 1
        Fill.Position = UDim2.new(A, 0, 0, 0)
        Fill.Size = UDim2.new(math.max(0, B - A), 0, 1, 0)
        Fill.BackgroundColor3 = Accent()
        LowLabel.Text = tostring(Object.Low) .. tostring(Data.Suffix or "")
        HighLabel.Text = tostring(Object.High) .. tostring(Data.Suffix or "")
    end
    function Object:Set(A, B, Silent)
        if type(A) == "table" then B = A[2] or A.Max or A.Maximum A = A[1] or A.Min or A.Minimum end
        A = math.clamp(RoundStep(tonumber(A) or Object.Low, Step), Minimum, Maximum)
        B = math.clamp(RoundStep(tonumber(B) or Object.High, Step), Minimum, Maximum)
        if A > B then A, B = B, A end
        Object.Low, Object.High = A, B
        Library.Flags[Flag] = {A, B}
        Library.Flags[MinFlag] = A
        Library.Flags[MaxFlag] = B
        Object:Render()
        if not Silent and type(Data.Callback) == "function" then Call(Data.Callback, A, B) end
    end
    function Object:Get() return {Object.Low, Object.High} end
    local Dragging
    local function FromMouse()
        local Width = Track.AbsoluteSize.X
        if Width <= 0 then return end
        local Mouse = MousePoint(self.Window.ScreenGui)
        local T = math.clamp((Mouse.X - GuiPoint(self.Window.ScreenGui, Track.AbsolutePosition).X) / Width, 0, 1)
        local Value = RoundStep(Minimum + (Maximum - Minimum) * T, Step)
        if math.abs(Value - Object.Low) <= math.abs(Value - Object.High) then Object:Set(Value, Object.High) else Object:Set(Object.Low, Value) end
    end
    Bind(Track.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true FromMouse() end end))
    Bind(UserInputService.InputChanged:Connect(function(Input) if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then FromMouse() end end))
    Bind(UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end))
    RegisterFlag(Flag, {Low, High}, function(Value) Object:Set(Value) end)
    RegisterFlag(MinFlag, Low, function(Value) Object:Set(Value, Object.High) end)
    RegisterFlag(MaxFlag, High, function(Value) Object:Set(Object.Low, Value) end)
    RegisterRenderer(function() Object:Render() end)
    AttachColorpicker(self, Object, Row, 0)
    AddControl(self, Object)
    return Object
end

local function MakeDropdown(Section, Data, Multi)
    Data = Data or {}
    local Name, Flag = tostring(Data.Name or "dropdown"), tostring(Data.Flag or Data.Name or "dropdown")
    local Items = type(Data.Items) == "table" and CloneValue(Data.Items) or {}
    local Default = Data.Default
    if Multi then
        Default = type(Default) == "table" and CloneValue(Default) or {}
        if type(Library.Flags[Flag]) == "table" then Default = CloneValue(Library.Flags[Flag]) end
    else
        if Default == nil then Default = Items[1] end
        if Library.Flags[Flag] ~= nil then Default = Library.Flags[Flag] end
    end
    local Row = Create("Frame", {Parent = Section.Body, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, 0, 0, 13), BackgroundTransparency = 1, Text = Name, TextColor3 = Colors.TextDim, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local DropFrame = Create("Frame", {Parent = Row, Size = UDim2.new(1, 0, 0, 17), Position = UDim2.fromOffset(0, 16), BackgroundColor3 = Colors.DropdownBg, BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(0, 2)}), Create("UIStroke", {Color = Colors.DropdownBord, Thickness = 1}), Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 32)), ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))})})})
    local Text = Create("TextLabel", {Parent = DropFrame, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(7, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Text = "", TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd})
    local Arrow = Create("TextLabel", {Parent = DropFrame, Size = UDim2.fromOffset(14, 17), Position = UDim2.new(1, -14, 0, 0), BackgroundTransparency = 1, Text = "▼", TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSans, TextSize = 9})
    local Button = Create("TextButton", {Parent = DropFrame, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5})
    local Object = {Section = Section, Row = Row, Frame = DropFrame, Items = Items, Value = Default, Flag = Flag, Multi = Multi}
    function Object:Get() return Multi and CloneValue(Object.Value) or Object.Value end
    function Object:Render()
        if Multi then
            Text.Text = #Object.Value > 0 and table.concat(Object.Value, ", ") or tostring(Data.Placeholder or "none")
        else Text.Text = tostring(Object.Value or "") end
        Arrow.TextColor3 = Section.Window.DropdownOwner == Object and Section.Window.Dropdown.Visible and Accent() or Colors.TextBind
    end
    function Object:Set(Value, Silent)
        if Multi then
            local Next = {}
            if type(Value) == "table" then
                for _, Item in ipairs(Value) do if table.find(Object.Items, Item) and not table.find(Next, Item) then Next[#Next + 1] = Item end end
            end
            if Data.AllowEmpty == false and #Next == 0 and Object.Items[1] then Next[1] = Object.Items[1] end
            local Maximum = tonumber(Data.Max) or #Object.Items
            while #Next > Maximum do table.remove(Next) end
            Object.Value = Next
            Library.Flags[Flag] = CloneValue(Next)
        else
            if table.find(Object.Items, Value) == nil and #Object.Items > 0 then Value = Object.Items[1] end
            Object.Value = Value
            Library.Flags[Flag] = Value
        end
        Object:Render()
        if not Silent and type(Data.Callback) == "function" then Call(Data.Callback, Object:Get()) end
    end
    function Object:SetItems(NewItems)
        Object.Items = type(NewItems) == "table" and CloneValue(NewItems) or {}
        if Multi then Object:Set(Object.Value, true) else if table.find(Object.Items, Object.Value) == nil then Object:Set(Object.Items[1], true) end end
    end
    local function Choose(Value)
        if Multi then
            local Next = Object:Get()
            local Index = table.find(Next, Value)
            if Index then
                if Data.AllowEmpty == false and #Next <= 1 then return end
                table.remove(Next, Index)
            else
                if #Next >= (tonumber(Data.Max) or #Object.Items) then return end
                Next[#Next + 1] = Value
            end
            Object:Set(Next)
        else Object:Set(Value) end
    end
    Bind(Button.MouseButton1Click:Connect(function()
        if Section.Window.DropdownOwner == Object and Section.Window.Dropdown.Visible then Section.Window:CloseDropdown() Object:Render() return end
        Section.Window:OpenDropdown(Object, DropFrame, Object.Items, Object.Value, Multi, Choose)
        Object:Render()
    end))
    RegisterFlag(Flag, CloneValue(Default), function(Value) Object:Set(Value) end)
    RegisterRenderer(function() Object:Render() end)
    AttachColorpicker(Section, Object, Row, 0)
    AddControl(Section, Object)
    return Object
end

function SectionMethods:Dropdown(Data) return MakeDropdown(self, Data, false) end
function SectionMethods:MultiDropdown(Data) return MakeDropdown(self, Data, true) end

function SectionMethods:Label(Data)
    Data = Data or {}
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1})
    local Label = Create("TextLabel", {Parent = Row, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = tostring(Data.Name or "label"), TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = tostring(Data.Alignment or "Left") == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left})
    local Object = {Section = self, Row = Row, Label = Label, RightOffset = 0}
    function Object:Set(Value) Label.Text = tostring(Value) end
    function Object:Colorpicker(ColorData) local Offset = Object.RightOffset local Picker = MakeColorpicker(self.Section, Row, ColorData, Offset) Object.RightOffset = Offset + 22 return Picker end
    function Object:Keybind(KeyData) Object.RightOffset = Object.RightOffset + 70 return CreateKeybind(self.Section.Window, Row, KeyData, Object.RightOffset - 70) end
    AddControl(self, Object)
    return Object
end

function SectionMethods:Button(Data, Callback)
    if type(Data) == "string" then Data = {Name = Data, Callback = Callback} end
    Data = Data or {}
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1})
    local Frame = Create("Frame", {Parent = Row, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Colors.Control, BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(0, 2)}), Create("UIStroke", {Color = Color3.fromRGB(56, 52, 56), Thickness = 1, Enabled = false}), Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Colors.Control), ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))})})})
    local AccentLine = Create("Frame", {Parent = Frame, Size = UDim2.new(0, 2, 1, -6), Position = UDim2.new(0, 1, 0.5, -3), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Accent(), Visible = false, BorderSizePixel = 0})
    local Label = Create("TextLabel", {Parent = Frame, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = tostring(Data.Name or "button"), TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13})
    local Button = Create("TextButton", {Parent = Row, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false})
    Bind(Button.MouseEnter:Connect(function() Frame:FindFirstChildOfClass("UIStroke").Enabled = true AccentLine.Visible = true Label.TextColor3 = Colors.TextBright end))
    Bind(Button.MouseLeave:Connect(function() Frame:FindFirstChildOfClass("UIStroke").Enabled = false AccentLine.Visible = false Label.TextColor3 = Colors.Text end))
    Bind(Button.MouseButton1Click:Connect(function() if type(Data.Callback) == "function" then Call(Data.Callback) end end))
    RegisterRenderer(function() AccentLine.BackgroundColor3 = Accent() end)
    local Object = {Section = self, Row = Row, Button = Button, Frame = Frame, Label = Label, RightOffset = 0}
    AttachColorpicker(self, Object, Row, 0)
    return AddControl(self, Object)
end

function SectionMethods:Textbox(Data)
    Data = Data or {}
    local Name, Flag = tostring(Data.Name or "textbox"), tostring(Data.Flag or Data.Name or "textbox")
    local Default = tostring(Data.Default or "")
    if type(Library.Flags[Flag]) == "string" then Default = Library.Flags[Flag] end
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, 0, 0, 13), BackgroundTransparency = 1, Text = Name, TextColor3 = Colors.TextDim, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Frame = Create("Frame", {Parent = Row, Size = UDim2.new(1, 0, 0, 17), Position = UDim2.fromOffset(0, 16), BackgroundColor3 = Color3.fromRGB(8, 8, 8), BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(0, 2)}), Create("UIStroke", {Color = Colors.CbBorder, Thickness = 1}), Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Colors.Control), ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))})})})
    local Box = Create("TextBox", {Parent = Frame, Size = UDim2.new(1, -12, 1, 0), Position = UDim2.fromOffset(6, 0), BackgroundTransparency = 1, Text = Default, PlaceholderText = tostring(Data.Placeholder or "..."), PlaceholderColor3 = Colors.TextDim, TextColor3 = Colors.TextBright, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
    local Object = {Section = self, Row = Row, Box = Box, Value = Default, Flag = Flag, RightOffset = 0}
    function Object:Set(Value, Silent)
        Object.Value = tostring(Value or "")
        Library.Flags[Flag] = Object.Value
        if Box.Text ~= Object.Value then Box.Text = Object.Value end
        if not Silent and type(Data.Callback) == "function" then Call(Data.Callback, Object.Value) end
    end
    function Object:Get() return Object.Value end
    RegisterFlag(Flag, Default, function(Value) Object:Set(Value) end)
    Bind(Box:GetPropertyChangedSignal("Text"):Connect(function() Object:Set(Box.Text) end))
    Bind(Box.Focused:Connect(function() Frame:FindFirstChildOfClass("UIStroke").Color = Accent() end))
    Bind(Box.FocusLost:Connect(function() Frame:FindFirstChildOfClass("UIStroke").Color = Colors.CbBorder end))
    AttachColorpicker(self, Object, Row, 0)
    AddControl(self, Object)
    return Object
end

function SectionMethods:Listbox(Data)
    Data = Data or {}
    local Height = tonumber(Data.Height) or 110
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, Height), BackgroundTransparency = 1})
    local List = Create("ScrollingFrame", {Parent = Row, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(8, 8, 8), BorderSizePixel = 0, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Colors.TextBind}, {Create("UICorner", {CornerRadius = UDim.new(0, 3)}), Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1}), Create("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder})})
    local Object = {Section = self, Row = Row, List = List, Items = {}, Selected = nil, Buttons = {}, RightOffset = 0}
    function Object:SetItems(Items)
        Object.Items = type(Items) == "table" and CloneValue(Items) or {}
        for _, Button in ipairs(Object.Buttons) do if Button and Button.Parent then Button:Destroy() end end
        table.clear(Object.Buttons)
        if Object.Selected and not table.find(Object.Items, Object.Selected) then Object.Selected = nil end
        for Index, Item in ipairs(Object.Items) do
            local Button = Create("TextButton", {Parent = List, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = tostring(Item), TextColor3 = Item == Object.Selected and Accent() or Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, LayoutOrder = Index}, {Create("UIPadding", {PaddingLeft = UDim.new(0, 6)})})
            Object.Buttons[#Object.Buttons + 1] = Button
            Bind(Button.MouseButton1Click:Connect(function()
                Object.Selected = Item
                for I, Other in ipairs(Object.Buttons) do Other.TextColor3 = Object.Items[I] == Object.Selected and Accent() or Colors.Text end
                if type(Data.Callback) == "function" then Call(Data.Callback, Item) end
            end))
        end
    end
    function Object:Get() return Object.Selected end
    function Object:Set(Value)
        if table.find(Object.Items, Value) then
            Object.Selected = Value
            for I, Other in ipairs(Object.Buttons) do Other.TextColor3 = Object.Items[I] == Object.Selected and Accent() or Colors.Text end
        end
    end
    Object:SetItems(Data.Items or {})
    AttachColorpicker(self, Object, Row, 0)
    return AddControl(self, Object)
end

function SectionMethods:Colorpicker(Data)
    Data = Data or {}
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, -26, 1, 0), BackgroundTransparency = 1, Text = tostring(Data.Name or "color"), TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Picker = MakeColorpicker(self, Row, Data, 0)
    return AddControl(self, Picker)
end

local function CleanConfigNumber(Value)
    if type(Value) ~= "number" or Value ~= Value or Value <= -math.huge or Value >= math.huge then return nil end
    local Scaled = Value * 1000000
    local Rounded = (Scaled >= 0 and math.floor(Scaled + 0.5) or math.ceil(Scaled - 0.5)) / 1000000
    if math.abs(Rounded) < 0.0000005 then Rounded = 0 end
    return Rounded
end

local function EncodeValue(Value, Seen, Depth)
    Depth = Depth or 0
    if Depth > 10 then return nil end
    local ValueType = typeof(Value)
    if ValueType == "Color3" then
        return {__type = "Color3", R = CleanConfigNumber(Value.R), G = CleanConfigNumber(Value.G), B = CleanConfigNumber(Value.B)}
    end
    if ValueType == "EnumItem" then return {__type = "EnumItem", EnumType = tostring(Value.EnumType), Name = Value.Name} end
    if ValueType == "Vector2" then return {__type = "Vector2", X = CleanConfigNumber(Value.X), Y = CleanConfigNumber(Value.Y)} end
    if ValueType == "Vector3" then return {__type = "Vector3", X = CleanConfigNumber(Value.X), Y = CleanConfigNumber(Value.Y), Z = CleanConfigNumber(Value.Z)} end
    if ValueType == "UDim2" then
        return {__type = "UDim2", XScale = CleanConfigNumber(Value.X.Scale), XOffset = CleanConfigNumber(Value.X.Offset), YScale = CleanConfigNumber(Value.Y.Scale), YOffset = CleanConfigNumber(Value.Y.Offset)}
    end
    if type(Value) == "boolean" or type(Value) == "string" then return Value end
    if type(Value) == "number" then return CleanConfigNumber(Value) end
    if type(Value) ~= "table" then return nil end
    Seen = Seen or {}
    if Seen[Value] then return nil end
    Seen[Value] = true
    local Result, Count, MaxIndex, Array = {}, 0, 0, true
    for Key in pairs(Value) do
        Count += 1
        if type(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then Array = false break end
        MaxIndex = math.max(MaxIndex, Key)
    end
    Array = Array and Count == MaxIndex
    if Array then
        for Index = 1, MaxIndex do
            local Encoded = EncodeValue(Value[Index], Seen, Depth + 1)
            if Encoded ~= nil then Result[#Result + 1] = Encoded end
        end
    else
        for Key, Item in pairs(Value) do
            if type(Key) == "string" or type(Key) == "number" then
                local Encoded = EncodeValue(Item, Seen, Depth + 1)
                if Encoded ~= nil then Result[tostring(Key)] = Encoded end
            end
        end
    end
    Seen[Value] = nil
    return Result
end

local function DecodeValue(Value, Depth)
    Depth = Depth or 0
    if Depth > 10 or type(Value) ~= "table" then return Value end
    if Value.__type == "Color3" then
        if type(Value.Hex) == "string" then
            local Clean = Value.Hex:gsub("#", "")
            if #Clean >= 6 then local Success, Parsed = Call(Color3.fromHex, Clean:sub(1, 6)) if Success then return Parsed end end
        end
        return Color3.new(tonumber(Value.R) or 0, tonumber(Value.G) or 0, tonumber(Value.B) or 0)
    end
    if Value.__type == "EnumItem" then
        local EnumName = tostring(Value.EnumType or ""):match("Enum%.(.+)")
        local EnumType = EnumName and Enum[EnumName]
        return EnumType and EnumType[Value.Name] or Value.Name
    end
    if Value.__type == "Vector2" then return Vector2.new(tonumber(Value.X) or 0, tonumber(Value.Y) or 0) end
    if Value.__type == "Vector3" then return Vector3.new(tonumber(Value.X) or 0, tonumber(Value.Y) or 0, tonumber(Value.Z) or 0) end
    if Value.__type == "UDim2" then
        if type(Value.X) == "table" or type(Value.Y) == "table" then
            local X, Y = type(Value.X) == "table" and Value.X or {}, type(Value.Y) == "table" and Value.Y or {}
            return UDim2.new(tonumber(X.Scale) or 0, tonumber(X.Offset) or 0, tonumber(Y.Scale) or 0, tonumber(Y.Offset) or 0)
        end
        return UDim2.new(tonumber(Value.XScale) or 0, tonumber(Value.XOffset) or 0, tonumber(Value.YScale) or 0, tonumber(Value.YOffset) or 0)
    end
    if Value.Color ~= nil and Value.Transparency ~= nil then
        local ColorValue = DecodeValue(Value.Color, Depth + 1)
        if type(ColorValue) == "string" then
            local Clean = ColorValue:gsub("#", "")
            if #Clean >= 6 then local Success, Parsed = Call(Color3.fromHex, Clean:sub(1, 6)) if Success then ColorValue = Parsed end end
        end
        return {Color = ColorValue, Transparency = math.clamp(tonumber(Value.Transparency) or 0, 0, 1)}
    end
    local Result = {}
    for Key, Item in pairs(Value) do Result[Key] = DecodeValue(Item, Depth + 1) end
    return Result
end

local ConfigKeyPriority = {Config = 1, Interface = 2, Binds = 3, Flags = 4, __type = -30, Format = -29, Version = -28, Id = -20, Key = -19, KeyType = -18, Mode = -17, Modifiers = -16, EnumType = -15, Name = -14, R = -13, G = -12, B = -11, X = -13, Y = -12, Z = -11, XScale = -13, XOffset = -12, YScale = -11, YOffset = -10}
local function ConfigTableIsArray(Value)
    if type(Value) ~= "table" then return false, 0 end
    local Count, MaxIndex = 0, 0
    for Key in pairs(Value) do
        if type(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then return false, 0 end
        Count += 1
        MaxIndex = math.max(MaxIndex, Key)
    end
    return Count == MaxIndex, MaxIndex
end

local function ConfigSortedKeys(Value)
    local Keys = {}
    for Key in pairs(Value) do Keys[#Keys + 1] = tostring(Key) end
    table.sort(Keys, function(A, B)
        local AP, BP = ConfigKeyPriority[A] or 100, ConfigKeyPriority[B] or 100
        if AP ~= BP then return AP < BP end
        local AL, BL = A:lower(), B:lower()
        if AL ~= BL then return AL < BL end
        return A < B
    end)
    return Keys
end

local function ConfigJsonScalar(Value)
    local Success, Source = Call(HttpService.JSONEncode, HttpService, Value)
    return Success and Source or "null"
end

local function PrettyConfigJson(Value, Depth)
    Depth = Depth or 0
    local ValueType = type(Value)
    if ValueType ~= "table" then return ConfigJsonScalar(Value) end
    local IsArray, Length = ConfigTableIsArray(Value)
    local Indent = string.rep("  ", Depth)
    local ChildIndent = string.rep("  ", Depth + 1)
    if IsArray then
        if Length == 0 then return "[]" end
        local Inline = Length <= 8
        if Inline then
            local Parts = {}
            for Index = 1, Length do
                if type(Value[Index]) == "table" then Inline = false break end
                Parts[Index] = PrettyConfigJson(Value[Index], Depth + 1)
            end
            if Inline then return "[ " .. table.concat(Parts, ", ") .. " ]" end
        end
        local Lines = {"["}
        for Index = 1, Length do
            Lines[#Lines + 1] = ChildIndent .. PrettyConfigJson(Value[Index], Depth + 1) .. (Index < Length and "," or "")
        end
        Lines[#Lines + 1] = Indent .. "]"
        return table.concat(Lines, "\n")
    end
    local Keys = ConfigSortedKeys(Value)
    if #Keys == 0 then return "{}" end
    local Inline = #Keys <= 5
    if Inline then
        local Parts = {}
        for Index, Key in ipairs(Keys) do
            if type(Value[Key]) == "table" then Inline = false break end
            Parts[Index] = ConfigJsonScalar(Key) .. ": " .. PrettyConfigJson(Value[Key], Depth + 1)
        end
        if Inline then return "{ " .. table.concat(Parts, ", ") .. " }" end
    end
    local Lines = {"{"}
    for Index, Key in ipairs(Keys) do
        local KeyText = ConfigJsonScalar(Key)
        Lines[#Lines + 1] = ChildIndent .. KeyText .. ": " .. PrettyConfigJson(Value[Key], Depth + 1) .. (Index < #Keys and "," or "")
    end
    Lines[#Lines + 1] = Indent .. "}"
    return table.concat(Lines, "\n")
end

function Library:GetConfig()
    local Flags, BindFlags = {}, {}
    for _, BindData in ipairs(self.Keybinds or {}) do
        if BindData and BindData.Flag then BindFlags[tostring(BindData.Flag)] = true end
    end
    for Name, Value in pairs(self.Flags or {}) do
        local FlagName = tostring(Name)
        if FlagName:sub(1, 2) ~= "__" and not BindFlags[FlagName] and type(self.Setters[FlagName]) == "function" then
            local Success, Encoded = Call(EncodeValue, Value, {}, 0)
            if Success and Encoded ~= nil then Flags[FlagName] = Encoded end
        end
    end

    local ControlBinds = {}
    for _, BindData in ipairs(self.Keybinds or {}) do
        if BindData and type(BindData.Flag) == "string" then
            local Target = tostring(BindData.TargetFlag or BindData.Flag)
            local Key, KeyType = BindData.Key, "KeyCode"
            if Key == nil then Key = "none"
            elseif type(Key) == "string" then
                KeyType = "UserInputType"
            elseif typeof(Key) == "EnumItem" then
                KeyType = tostring(Key.EnumType):find("UserInputType", 1, true) and "UserInputType" or "KeyCode"
                Key = Key.Name
            end
            local Entry = {Id = "Main:" .. tostring(BindData.Flag), KeyType = KeyType, Key = Key, Mode = BindData.Mode, Modifiers = CopyModifiers(BindData.Modifiers)}
            local Existing = ControlBinds[Target]
            if Existing == nil then
                ControlBinds[Target] = Entry
            elseif Existing.Key ~= nil or Existing.key ~= nil then
                ControlBinds[Target] = {Existing, Entry}
            else
                Existing[#Existing + 1] = Entry
            end
        end
    end

    local Interface = {}
    if self.ActiveWindow and self.ActiveWindow.Main then
        Interface.MainPosition = self.ActiveWindow.Main.Position
        Interface.MainSize = self.ActiveWindow.Main.Size
        Interface.MainVisible = self.ActiveWindow.Visible == true
    end
    if self.PlayerListController and self.PlayerListController.Frame then
        Interface.PlayerListPosition = self.PlayerListController.Frame.Position
        Interface.PlayerListVisible = self.PlayerListController.RequestedVisible == true
    end
    if self.QuickPanelController and self.QuickPanelController.Root then Interface.QuickPanelPosition = self.QuickPanelController.Root.Position end
    Interface.Theme = CloneValue(self.Theme)
    Interface.MenuBind = self.MenuBindData and {Key = self.MenuBindData.Key, Modifiers = CopyModifiers(self.MenuBindData.Modifiers)} or {Key = self.MenuKeybind, Modifiers = EmptyModifiers()}
    Interface.NotificationPoint = typeof(self.NotificationPoint) == "Vector2" and self.NotificationPoint or Vector2.new(0.94, 0.08)

    local EncodedInterface, EncodedBinds = {}, {}
    local InterfaceSuccess, InterfaceValue = Call(EncodeValue, Interface, {}, 0)
    if InterfaceSuccess and type(InterfaceValue) == "table" then EncodedInterface = InterfaceValue end
    local BindsSuccess, BindsValue = Call(EncodeValue, ControlBinds, {}, 0)
    if BindsSuccess and type(BindsValue) == "table" then EncodedBinds = BindsValue end

    local Payload = {
        Config = {Format = "Atramenta", Version = 2},
        Interface = EncodedInterface,
        Binds = EncodedBinds,
        Flags = Flags
    }
    return PrettyConfigJson(Payload, 0)
end

function Library:LoadConfig(Source)
    CancelCapture()
    local Success, Decoded = Call(HttpService.JSONDecode, HttpService, tostring(Source or "{}"))
    if not Success or type(Decoded) ~= "table" then return false end

    local FlagsSource
    if type(Decoded.Flags) == "table" then FlagsSource = Decoded.Flags
    elseif type(Decoded.flags) == "table" then FlagsSource = Decoded.flags
    elseif type(Decoded.Settings) == "table" then FlagsSource = Decoded.Settings
    elseif type(Decoded.settings) == "table" then FlagsSource = Decoded.settings
    else FlagsSource = Decoded end

    local Flags, Names, BindFlags = {}, {}, {}
    for _, BindData in ipairs(self.Keybinds or {}) do if BindData and BindData.Flag then BindFlags[tostring(BindData.Flag)] = true end end
    for Name, Value in pairs(FlagsSource) do
        local FlagName = tostring(Name)
        if FlagName:sub(1, 2) ~= "__" and FlagName ~= "Flags" and FlagName ~= "flags" and FlagName ~= "Settings" and FlagName ~= "settings"
            and FlagName ~= "Config" and FlagName ~= "config" and FlagName ~= "Interface" and FlagName ~= "interface" and FlagName ~= "Binds" and FlagName ~= "binds"
            and FlagName ~= "AccentAlpha" and not BindFlags[FlagName] then
            Flags[FlagName] = DecodeValue(Value, 0)
            Names[#Names + 1] = FlagName
        end
    end
    table.sort(Names)
    local Applied, Failed = 0, 0
    local function Apply(Name)
        local Value, Setter = CloneValue(Flags[Name]), self.Setters[Name]
        if type(Setter) == "function" then
            local Ok = Call(Setter, Value)
            if Ok then Applied += 1 else Failed += 1 end
        else
            self.Flags[Name] = Value
            Applied += 1
        end
    end
    for _, Name in ipairs(Names) do if type(Flags[Name]) ~= "boolean" then Apply(Name) end end
    for _, Name in ipairs(Names) do if Flags[Name] == false then Apply(Name) end end
    for _, Name in ipairs(Names) do if Flags[Name] == true then Apply(Name) end end

    local LoadedBinds = Decoded.Binds or Decoded.binds or Decoded.__AtramentaControlBinds or FlagsSource.__AtramentaControlBinds
    if LoadedBinds ~= nil then LoadedBinds = DecodeValue(LoadedBinds, 0) end
    local function EntryFrom(Value, BindData)
        Value = DecodeValue(Value, 0)
        if type(Value) ~= "table" then return nil end
        if Value.Key ~= nil or Value.key ~= nil or tostring(Value.Display or Value.display or ""):lower() == "none" then return Value end
        local PreferredId, First = "Main:" .. tostring(BindData.Flag), nil
        for _, Entry in pairs(Value) do
            if type(Entry) == "table" and (Entry.Key ~= nil or Entry.key ~= nil or tostring(Entry.Display or Entry.display or ""):lower() == "none") then
                First = First or Entry
                if tostring(Entry.Id or Entry.id or "") == PreferredId then return Entry end
            end
        end
        return First
    end
    for _, BindData in ipairs(self.Keybinds or {}) do
        local Stored
        if type(LoadedBinds) == "table" then
            Stored = EntryFrom(LoadedBinds[tostring(BindData.TargetFlag or BindData.Flag)], BindData) or EntryFrom(LoadedBinds[tostring(BindData.Flag)], BindData)
        end
        if not Stored then Stored = EntryFrom(FlagsSource[tostring(BindData.Flag)], BindData) end
        if Stored then
            local Key = Stored.Key ~= nil and Stored.Key or Stored.key
            if Key == nil and tostring(Stored.Display or Stored.display or ""):lower() == "none" then Key = "none" end
            local Modifiers = Stored.Modifiers or Stored.modifiers
            local KeyType = tostring(Stored.KeyType or Stored.keyType or Stored.Type or "")
            if type(Key) == "string" then
                local Tail = Key:match("([%w_]+)$")
                if Tail then Key = Tail end
                local Compact = Key:upper():gsub("[%s_%-%+]", "")
                if KeyType:find("UserInputType", 1, true) or Compact == "MOUSEBUTTON2" or Compact == "MOUSEBUTTON3" then
                    if Compact == "MOUSEBUTTON2" then Key = "M2" elseif Compact == "MOUSEBUTTON3" then Key = "M3" end
                end
            end
            BindData:Set({Key = Key, Modifiers = Modifiers, Mode = Stored.Mode or Stored.mode})
            Applied += 1
        end
    end

    local InterfaceSource = Decoded.Interface or Decoded.interface or Decoded.__AtramentaInterface or FlagsSource.__AtramentaInterface
    local Interface = InterfaceSource and DecodeValue(InterfaceSource, 0) or nil
    if type(Interface) == "table" then
        if type(Interface.Theme) == "table" then
            for Key, Value in pairs(Interface.Theme) do if typeof(Value) == "Color3" then self.Theme[Key] = Value end end
            SyncThemeColors()
        elseif typeof(Interface.Accent) == "Color3" then self.Theme.Accent = Interface.Accent end
        if self.ActiveWindow and self.ActiveWindow.Main then
            if typeof(Interface.MainSize) == "UDim2" then self.ActiveWindow.Main.Size = Interface.MainSize end
            if typeof(Interface.MainPosition) == "UDim2" then self.ActiveWindow.Main.Position = Interface.MainPosition end
            if type(Interface.MainVisible) == "boolean" then self.ActiveWindow:SetVisible(Interface.MainVisible) end
            ClampFrameToViewport(self.ActiveWindow.Main, self.ActiveWindow.ScreenGui, 4)
        end
        if self.PlayerListController and self.PlayerListController.Frame then
            if typeof(Interface.PlayerListPosition) == "UDim2" then self.PlayerListController.Frame.Position = Interface.PlayerListPosition end
            if type(Interface.PlayerListVisible) == "boolean" then self.PlayerListController:SetVisibility(Interface.PlayerListVisible) end
            ClampFrameToViewport(self.PlayerListController.Frame, self.PlayerListController.Gui, 4)
        end
        if self.QuickPanelController and self.QuickPanelController.Root and typeof(Interface.QuickPanelPosition) == "UDim2" then
            self.QuickPanelController.Root.Position = Interface.QuickPanelPosition
            ClampFrameToViewport(self.QuickPanelController.Root, self.QuickPanelController.Gui, 4)
        end
        if typeof(Interface.NotificationPoint) == "Vector2" then
            self.NotificationPoint = Interface.NotificationPoint
            if type(self.ApplyNotificationLayout) == "function" then self:ApplyNotificationLayout() end
        end
        if self.MenuBindData and type(Interface.MenuBind) == "table" then self.MenuBindData:Set(Interface.MenuBind) end
    end
    UpdateAll()
    self.LastConfigLoadResult = {Applied = Applied, Failed = Failed}
    return Failed == 0 or Applied > 0
end

local function NormalizeConfigName(Name)
    Name = tostring(Name or ""):gsub("[%c%?%*%:%\"%<%>%|/\\]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    return Name:sub(1, 64)
end

local function ConfigPath(Name) return Library.Folders.Configs .. "/" .. NormalizeConfigName(Name) .. ".json" end
local LegacyFolders = {"Atramenta.rip/Configs", "Atramenta.rip/configs", "obels/configs"}

function Library:ListConfigs()
    EnsureFolders()
    local Seen, Items = {}, {}
    if type(listfiles) == "function" then
        for _, Folder in ipairs(LegacyFolders) do
            if type(isfolder) ~= "function" or isfolder(Folder) then
                local Success, Files = Call(listfiles, Folder)
                if Success and type(Files) == "table" then
                    for _, File in ipairs(Files) do
                        local Name = tostring(File):match("([^/\\]+)%.json$") or tostring(File):match("([^/\\]+)%.cfg$")
                        if Name and not Seen[Name:lower()] and Name ~= "Atramenta" and Name ~= "AtramentaConfigs" then
                            Seen[Name:lower()] = true
                            Items[#Items + 1] = Name
                        end
                    end
                end
            end
        end
    end
    table.sort(Items, function(A, B) return A:lower() < B:lower() end)
    return Items
end

function Library:ConfigExists(Name)
    Name = NormalizeConfigName(Name)
    if Name == "" then return false end
    if type(isfile) == "function" and isfile(ConfigPath(Name)) then return true end
    for _, Folder in ipairs(LegacyFolders) do
        if type(isfile) == "function" and (isfile(Folder .. "/" .. Name .. ".json") or isfile(Folder .. "/" .. Name .. ".cfg")) then return true end
    end
    return false
end

function Library:SaveConfig(Name)
    Name = NormalizeConfigName(Name)
    if self.MenuBuildComplete == false then
        self.LastConfigSaveError = "menu build incomplete"
        return false
    end
    if Name == "" or type(writefile) ~= "function" then return false end
    EnsureFolders()
    local Source = self:GetConfig()
    if type(Source) ~= "string" then return false end
    return Call(writefile, ConfigPath(Name), Source) == true
end

function Library:LoadConfigFile(Name)
    Name = NormalizeConfigName(Name)
    if Name == "" or type(readfile) ~= "function" then return false end
    local Paths, Seen = {}, {}
    local function Push(Path)
        if not Seen[Path] then Seen[Path] = true Paths[#Paths + 1] = Path end
    end
    Push(ConfigPath(Name))
    for _, Folder in ipairs(LegacyFolders) do
        Push(Folder .. "/" .. Name .. ".json")
        Push(Folder .. "/" .. Name .. ".cfg")
    end
    for _, Path in ipairs(Paths) do
        local Exists = type(isfile) ~= "function" or isfile(Path)
        if Exists then
            local Success, Source = Call(readfile, Path)
            if Success and type(Source) == "string" and self:LoadConfig(Source) then return true end
        end
    end
    return false
end

function Library:DeleteConfig(Name)
    Name = NormalizeConfigName(Name)
    if Name == "" or type(delfile) ~= "function" then return false end
    local Deleted, Paths, Seen = false, {}, {}
    local function Push(Path)
        if not Seen[Path] then Seen[Path] = true Paths[#Paths + 1] = Path end
    end
    Push(ConfigPath(Name))
    for _, Folder in ipairs(LegacyFolders) do
        Push(Folder .. "/" .. Name .. ".json")
        Push(Folder .. "/" .. Name .. ".cfg")
    end
    for _, Path in ipairs(Paths) do
        if type(isfile) ~= "function" or isfile(Path) then
            local Success = Call(delfile, Path)
            Deleted = Success == true or Deleted
        end
    end
    return Deleted
end

function Library:RefreshConfigsList(Listbox)
    local Items = self:ListConfigs()
    if type(Listbox) == "table" and type(Listbox.SetItems) == "function" then Listbox:SetItems(Items) end
    return Items
end

function WindowMethods:ConfigSystem()
    if self.ConfigPage then return self.ConfigPage end
    local Page=self:Page({Name="settings"})
    local Browser=Page:Section({Name="configs",Side=1})
    local Manager=Page:Section({Name="config actions",Side=2})
    local Interface=Page:Section({Name="interface",Side=1})
    local Theme=Page:Section({Name="theme",Side=2})
    local Selected,Listbox
    local CountLabel=Browser:Label({Name="0 configs",Alignment="Left"})
    local NameBox=Manager:Textbox({Name="config name",Flag="__ConfigName",Default="",Placeholder="enter name"})
    local Status=Manager:Label({Name="ready",Alignment="Left"})
    local function Notify(Text) Status:Set(tostring(Text)) Library:Notification({Title="config",Description=Text,Duration=2}) end
    local function SetSelected(Name)
        Selected=Name and NormalizeConfigName(Name) or nil if Selected then NameBox:Set(Selected,true) end
    end
    local function Refresh(Preserve)
        local Items=Library:ListConfigs() Listbox:SetItems(Items) CountLabel:Set(tostring(#Items)..(#Items==1 and " config" or " configs"))
        if Preserve~=false and Selected and table.find(Items,Selected) then Listbox:Set(Selected) else SetSelected(nil) end Status:Set("ready") return Items
    end
    local function CurrentName(AllowInput) local Name=Selected if (not Name or Name=="") and AllowInput then Name=NormalizeConfigName(NameBox:Get()) end return NormalizeConfigName(Name or "") end
    Listbox=Browser:Listbox({Items={},Height=164,Callback=function(Value) SetSelected(Value) Status:Set("selected "..tostring(Value)) end})
    Browser:Button({Name="refresh",Callback=function() Refresh(true) end})
    Manager:Button({Name="create",Callback=function()
        local Name=NormalizeConfigName(NameBox:Get())
        if Name=="" then Notify("enter a config name") return end
        if Library:ConfigExists(Name) then Notify(Name.." already exists") return end
        Library.LastConfigSaveError=nil
        if Library:SaveConfig(Name) then
            SetSelected(Name) Refresh(true) Listbox:Set(Name) Notify(Name.." created")
        else
            Notify(Library.LastConfigSaveError=="menu build incomplete" and "menu build incomplete - config was not created" or "failed to create "..Name)
        end
    end})
    Manager:Button({Name="save",Callback=function()
        local Name=CurrentName(true)
        if Name=="" then Notify("select or enter a config") return end
        Library.LastConfigSaveError=nil
        if Library:SaveConfig(Name) then
            SetSelected(Name) Refresh(true) Listbox:Set(Name) Notify(Name.." saved")
        else
            Notify(Library.LastConfigSaveError=="menu build incomplete" and "menu build incomplete - config was not overwritten" or "failed to save "..Name)
        end
    end})
    Manager:Button({Name="load",Callback=function() local Name=CurrentName(false) if Name=="" then Notify("select a config") return end if Library:LoadConfigFile(Name) then SetSelected(Name) Notify(Name.." loaded") else Notify("failed to load "..Name) end end})
    Manager:Button({Name="delete",Callback=function() local Name=CurrentName(false) if Name=="" then Notify("select a config") return end if Library:DeleteConfig(Name) then SetSelected(nil) NameBox:Set("",true) Refresh(false) Notify(Name.." deleted") else Notify("failed to delete "..Name) end end})

    Library.MenuBindData=Interface:Keybind({Name="menu bind",Flag="__AtramentaMenuBind",Default=Enum.KeyCode.F2,Mode="Toggle",Callback=function() end})
    Interface:Toggle({Name="watermark",Flag="__InterfaceWatermark",Default=true,Callback=function(Value) if Library.WatermarkController then Library.WatermarkController:SetVisibility(Value==true) end end})
    Interface:Toggle({Name="keybind list",Flag="__InterfaceKeybindList",Default=false,Callback=function(Value) if Library.KeybindListController then Library.KeybindListController:SetVisibility(Value==true) end end})
    Interface:Slider({Name="watermark scale",Flag="__InterfaceWatermarkScale",Min=60,Max=160,Default=100,Step=5,Suffix="%",Callback=function(Value) if Library.WatermarkController then Library.WatermarkController:SetScale(Value) end end})
    Interface:Slider({Name="keybind scale",Flag="__InterfaceKeybindScale",Min=60,Max=160,Default=100,Step=5,Suffix="%",Callback=function(Value) if Library.KeybindListController then Library.KeybindListController:SetScale(Value) end end})

    local function ThemePicker(Name,Flag,Key)
        Theme:Label({Name=Name,Alignment="Left"}):Colorpicker({Name=Name,Flag=Flag,Default=Library.Theme[Key],Callback=function(Value) Library:ChangeTheme(Key,Value) end})
    end
    ThemePicker("accent","__ThemeAccent","Accent") ThemePicker("background","__ThemeBackground","Background") ThemePicker("surface","__ThemeSurface","Surface") ThemePicker("controls","__ThemeControl","Control") ThemePicker("border","__ThemeBorder","Border")
    ThemePicker("text","__ThemeText","Text") ThemePicker("bright text","__ThemeTextBright","TextBright") ThemePicker("muted text","__ThemeTextDim","TextDim") ThemePicker("section text","__ThemeHeader","Header")
    Refresh(false)
    self.ConfigPage,self.SettingsPage,self.ConfigListbox,self.RefreshConfigs=Page,Page,Listbox,Refresh return Page
end

function Library:Watermark(Text)
    local Parent=ParentGui() local Gui=Create("ScreenGui",{Name="AtramentaWatermark",Parent=Parent,ResetOnSpawn=false,DisplayOrder=101,ZIndexBehavior=Enum.ZIndexBehavior.Global,IgnoreGuiInset=false}) self.Guis[#self.Guis+1]=Gui
    local Frame=Create("Frame",{Parent=Gui,Position=UDim2.fromOffset(12,12),Size=UDim2.fromOffset(250,23),BackgroundColor3=Color3.fromRGB(5,5,6),BorderSizePixel=0},{Create("UICorner",{CornerRadius=UDim.new(0,2)}),Create("UIStroke",{Color=Color3.fromRGB(2,2,3),Thickness=1})})
    local Inner=Create("Frame",{Parent=Frame,Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,1,-2),BackgroundColor3=Colors.TitleBg,BorderSizePixel=0},{Create("UICorner",{CornerRadius=UDim.new(0,1)}),Create("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Colors.Control),ColorSequenceKeypoint.new(0.52,Color3.fromRGB(8,8,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,8,8))})})})
    local LineGradient=Create("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,AccentDark()),ColorSequenceKeypoint.new(0.28,Accent()),ColorSequenceKeypoint.new(0.5,AccentHover()),ColorSequenceKeypoint.new(0.72,Accent()),ColorSequenceKeypoint.new(1,AccentDark())}),Offset=Vector2.new(-1,0)})
    local Line=Create("Frame",{Parent=Frame,Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,0,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=4},{LineGradient})
    local Label=Create("TextLabel",{Parent=Inner,Position=UDim2.fromOffset(8,1),Size=UDim2.new(1,-16,1,-2),BackgroundTransparency=1,Font=Enum.Font.SourceSans,TextSize=13,TextColor3=Colors.TextBright,TextXAlignment=Enum.TextXAlignment.Left,Text="",TextTruncate=Enum.TextTruncate.None,ZIndex=5})
    local TextGradient=Create("UIGradient",{Parent=Label,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Colors.TextBright),ColorSequenceKeypoint.new(0.38,Colors.TextBright),ColorSequenceKeypoint.new(0.5,AccentHover()),ColorSequenceKeypoint.new(0.62,Colors.TextBright),ColorSequenceKeypoint.new(1,Colors.TextBright)}),Offset=Vector2.new(-1,0)})
    local Scale=Create("UIScale",{Parent=Frame,Scale=1}) MakeDraggable(Frame,Frame,Gui)
    local Object={Gui=Gui,Frame=Frame,Label=Label,Scale=Scale,Line=Line,Brand=string.lower(tostring(Text or "atramenta.rip")),FPS=0,Ping=0,Alive=true,RequestedVisible=true,MenuVisible=true}
    function Object:ApplyVisibility() Frame.Visible=Object.RequestedVisible==true and Object.MenuVisible~=false and Library.InterfaceOpen~=false end
    function Object:Resize() local Bounds=TextService:GetTextSize(Label.Text,13,Enum.Font.SourceSans,Vector2.new(1200,23)) Frame.Size=UDim2.fromOffset(math.max(170,math.ceil(Bounds.X)+18),23) end
    function Object:SetVisibility(State) Object.RequestedVisible=State==true Object:ApplyVisibility() end
    function Object:SetMenuVisible(State) Object.MenuVisible=State==true Object:ApplyVisibility() end
    function Object:IsRequestedVisible() return Object.RequestedVisible==true end
    function Object:SetScale(Value) Scale.Scale=math.clamp((tonumber(Value) or 100)/100,0.5,2) end
    function Object:SetText(Value) Object.Brand=string.lower(tostring(Value or "atramenta.rip")) Object:RefreshText() end
    function Object:SetPosition(Position) if typeof(Position)=="UDim2" then Frame.Position=Position end end
    function Object:RefreshText() Label.Text=string.format("%s | FPS %d | PING %d MS | release",Object.Brand,math.max(0,math.floor(Object.FPS+0.5)),math.max(0,math.floor(Object.Ping+0.5))) Object:Resize() end
    Object:RefreshText()
    local Frames,Elapsed,InfoElapsed,Phase=0,0,0,0
    Bind(RunService.RenderStepped:Connect(function(Delta)
        if not Object.Alive or not Frame.Parent then return end
        Frames+=1 Elapsed+=Delta InfoElapsed+=Delta Phase=(Phase+Delta*0.72)%2
        if Elapsed>=0.45 then Object.FPS=Frames/Elapsed Frames=0 Elapsed=0 end
        if InfoElapsed>=0.45 then local Player=Players.LocalPlayer local Success,Value=Call(function() return Player and Player:GetNetworkPing() end) if Success and type(Value)=="number" then Object.Ping=Value*1000 end InfoElapsed=0 Object:RefreshText() end
        local A=Accent() local Dark=AccentDark() local Bright=AccentHover() local Offset=Phase-1
        LineGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Dark),ColorSequenceKeypoint.new(0.28,A),ColorSequenceKeypoint.new(0.5,Bright),ColorSequenceKeypoint.new(0.72,A),ColorSequenceKeypoint.new(1,Dark)}) LineGradient.Offset=Vector2.new(Offset,0)
        TextGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Colors.TextBright),ColorSequenceKeypoint.new(0.38,Colors.TextBright),ColorSequenceKeypoint.new(0.5,Bright),ColorSequenceKeypoint.new(0.62,Colors.TextBright),ColorSequenceKeypoint.new(1,Colors.TextBright)}) TextGradient.Offset=Vector2.new(Offset,0)
    end))
    RegisterRenderer(function() Object:RefreshText() end)
    BindFrameToViewport(Frame,Gui,4) self.WatermarkController=Object
    return Object
end

function Library:KeybindList()
    if self.KeybindListController then return self.KeybindListController end
    local Parent=ParentGui() local Gui=Create("ScreenGui",{Name="AtramentaKeybinds",Parent=Parent,ResetOnSpawn=false,DisplayOrder=101,ZIndexBehavior=Enum.ZIndexBehavior.Global,IgnoreGuiInset=false}) self.Guis[#self.Guis+1]=Gui
    local Frame=Create("Frame",{Parent=Gui,Position=UDim2.fromOffset(12,43),Size=UDim2.fromOffset(270,25),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Colors.Bg,BorderSizePixel=0,Visible=false},{Create("UICorner",{CornerRadius=UDim.new(0,3)}),Create("UIStroke",{Color=Color3.fromRGB(2,2,3),Thickness=1}),Create("UIPadding",{PaddingBottom=UDim.new(0,5)})})
    local Header=Create("Frame",{Parent=Frame,Size=UDim2.new(1,0,0,20),BackgroundColor3=Colors.TitleBg,BorderSizePixel=0},{Create("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Colors.Control),ColorSequenceKeypoint.new(1,Color3.fromRGB(8,8,8))})})})
    local HeaderText=Create("TextLabel",{Parent=Header,Position=UDim2.fromOffset(7,0),Size=UDim2.new(1,-14,1,0),BackgroundTransparency=1,Text="keybinds",TextColor3=Colors.TextBright,Font=Enum.Font.SourceSans,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
    local HeaderCount=Create("TextLabel",{Parent=Header,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-7,0,0),Size=UDim2.fromOffset(110,20),BackgroundTransparency=1,Text="",TextColor3=Colors.TextDim,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right})
    local Line=Create("Frame",{Parent=Header,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=Accent(),BorderSizePixel=0,ZIndex=3},{Create("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(0.16,Accent()),ColorSequenceKeypoint.new(0.84,Accent()),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})})})
    local Holder=Create("Frame",{Parent=Frame,Position=UDim2.fromOffset(7,23),Size=UDim2.new(1,-14,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},{Create("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder})})
    local Scale=Create("UIScale",{Parent=Frame,Scale=1}) MakeDraggable(Frame,Header,Gui)
    local Object={Gui=Gui,Frame=Frame,Holder=Holder,Scale=Scale,Rows={},RequestedVisible=false,MenuVisible=true}
    function Object:ApplyVisibility() Frame.Visible=Object.RequestedVisible==true and Object.MenuVisible~=false and Library.InterfaceOpen~=false end
    function Object:SetVisibility(State) Object.RequestedVisible=State==true Object:ApplyVisibility() end
    function Object:SetMenuVisible(State) Object.MenuVisible=State==true Object:ApplyVisibility() end
    function Object:IsRequestedVisible() return Object.RequestedVisible==true end
    function Object:SetScale(Value) Scale.Scale=math.clamp((tonumber(Value) or 100)/100,0.5,2) end
    function Object:Refresh()
        for _,Row in ipairs(Object.Rows) do if Row and Row.Parent then Row:Destroy() end end table.clear(Object.Rows)

        local Width=256
        local Assigned,Active=0,0
        for _,BindData in ipairs(Library.Keybinds) do
            if BindData.TargetControl then BindData.Value=BindData.TargetControl:Get() end
            local Key=NormalizeKey(BindData.Key)
            if not BindData.Destroyed and Key~=nil then
                Assigned+=1
                local GateOpen=KeybindGateOpen(BindData)
                local IsActive=GateOpen and (BindData.Value==true or BindData.Mode=="Always")
                if IsActive then Active+=1 end

                local KeyText="["..KeyDisplay(BindData.Key,BindData.Modifiers).."]"
                local ModeText=BindData.Mode=="Hold" and "hold" or BindData.Mode=="Always" and "always" or "toggle"
                local StateText=not GateOpen and "disabled" or IsActive and "on" or "off"
                local StateColor=IsActive and Accent() or Colors.TextDim
                local NameColor=IsActive and Colors.TextBright or Colors.Text
                local KeyColor=IsActive and Accent() or Colors.TextBind

                local NameWidth=TextService:GetTextSize(BindData.Name,12,Enum.Font.SourceSans,Vector2.new(500,16)).X
                local RightText=KeyText.."  "..ModeText.."  "..StateText
                local RightWidth=TextService:GetTextSize(RightText,11,Enum.Font.SourceSans,Vector2.new(500,16)).X
                Width=math.max(Width,math.ceil(NameWidth+RightWidth+34))

                local Row=Create("Frame",{Parent=Holder,Size=UDim2.new(1,0,0,16),BackgroundColor3=IsActive and Accent() or Colors.Control,BackgroundTransparency=IsActive and 0.91 or 1,BorderSizePixel=0,LayoutOrder=Assigned})
                local Dot=Create("Frame",{Parent=Row,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.fromOffset(3,10),BackgroundColor3=StateColor,BackgroundTransparency=IsActive and 0 or 0.55,BorderSizePixel=0},{Create("UICorner",{CornerRadius=UDim.new(1,0)})})
                Create("TextLabel",{Parent=Row,Position=UDim2.fromOffset(7,0),Size=UDim2.new(1,-176,1,0),BackgroundTransparency=1,Text=BindData.Name,TextColor3=NameColor,Font=Enum.Font.SourceSans,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
                Create("TextLabel",{Parent=Row,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-89,0,0),Size=UDim2.fromOffset(82,16),BackgroundTransparency=1,Text=KeyText,TextColor3=KeyColor,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd})
                Create("TextLabel",{Parent=Row,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-39,0,0),Size=UDim2.fromOffset(46,16),BackgroundTransparency=1,Text=ModeText,TextColor3=Colors.TextDim,Font=Enum.Font.SourceSans,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right})
                Create("TextLabel",{Parent=Row,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.fromOffset(36,16),BackgroundTransparency=1,Text=StateText,TextColor3=StateColor,Font=Enum.Font.SourceSans,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right})
                Object.Rows[#Object.Rows+1]=Row
            end
        end

        HeaderCount.Text=tostring(Active).." active / "..tostring(Assigned)
        if Assigned==0 then
            local Empty=Create("TextLabel",{Parent=Holder,Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text="no keybinds assigned",TextColor3=Colors.TextDim,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left})
            Object.Rows[#Object.Rows+1]=Empty
        end
        Frame.Size=UDim2.fromOffset(math.clamp(Width,256,380),25)
    end
    RegisterRenderer(function()
        local A=Accent() Line.BackgroundColor3=A
        local G=Line:FindFirstChildOfClass("UIGradient") if G then G.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(0.16,A),ColorSequenceKeypoint.new(0.84,A),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}) end
        Object:Refresh()
    end)
    BindFrameToViewport(Frame,Gui,4) self.KeybindListController=Object Object:Refresh() return Object
end

function Library:PlayerList(Data)
    Data=type(Data)=="table" and Data or {}
    if self.PlayerListController then return self.PlayerListController end
    self.PlayerStatuses=type(self.PlayerStatuses)=="table" and self.PlayerStatuses or {}
    local Parent=ParentGui()
    local Gui=Create("ScreenGui",{Name="AtramentaPlayerList",Parent=Parent,ResetOnSpawn=false,DisplayOrder=150,ZIndexBehavior=Enum.ZIndexBehavior.Global,IgnoreGuiInset=false})
    self.Guis[#self.Guis+1]=Gui
    local Frame=Create("Frame",{Parent=Gui,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.72,0.52),Size=UDim2.fromOffset(720,420),BackgroundColor3=Color3.fromRGB(2,2,3),BorderSizePixel=0,Visible=false,Active=true,ZIndex=150},{Create("UICorner",{CornerRadius=UDim.new(0,2)}),Create("UIStroke",{Color=Color3.fromRGB(0,0,0),Thickness=1})})
    local Inner=Create("Frame",{Parent=Frame,Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,1,-2),BackgroundColor3=Colors.Bg,BorderSizePixel=0,ZIndex=151},{Create("UICorner",{CornerRadius=UDim.new(0,1)})})
    local Header=Create("Frame",{Parent=Inner,Size=UDim2.new(1,0,0,21),BackgroundColor3=Colors.TitleBg,BorderSizePixel=0,Active=true,ZIndex=152},{Create("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Colors.Control),ColorSequenceKeypoint.new(1,Colors.TitleBg)})})})
    local AccentLine=Create("Frame",{Parent=Header,Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundColor3=Accent(),BorderSizePixel=0,ZIndex=154},{Create("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new()),ColorSequenceKeypoint.new(0.12,Accent()),ColorSequenceKeypoint.new(0.88,Accent()),ColorSequenceKeypoint.new(1,Color3.new())})})})
    Create("TextLabel",{Parent=Header,Position=UDim2.fromOffset(7,0),Size=UDim2.new(1,-14,1,0),BackgroundTransparency=1,Text=string.lower(tostring(Data.Brand or "atramenta.rip")).."  /  playerlist",TextColor3=Colors.TextBright,Font=Enum.Font.SourceSans,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=153})
    local Body=Create("Frame",{Parent=Inner,Position=UDim2.fromOffset(6,27),Size=UDim2.new(1,-12,1,-33),BackgroundTransparency=1,ZIndex=152})
    local Left=Create("Frame",{Parent=Body,Size=UDim2.new(0.60,-3,1,0),BackgroundColor3=Colors.TitleBg,BackgroundTransparency=0.50,BorderSizePixel=0,ZIndex=152},{Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.52})})
    local Right=Create("Frame",{Parent=Body,Position=UDim2.new(0.60,4,0,0),Size=UDim2.new(0.40,-4,1,0),BackgroundColor3=Colors.TitleBg,BackgroundTransparency=0.50,BorderSizePixel=0,ZIndex=152},{Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.52})})
    local LeftHead=Create("Frame",{Parent=Left,Size=UDim2.new(1,0,0,20),BackgroundColor3=Colors.TitleBg,BackgroundTransparency=0.10,BorderSizePixel=0,ZIndex=153})
    local Count=Create("TextLabel",{Parent=LeftHead,Position=UDim2.fromOffset(7,0),Size=UDim2.new(1,-14,1,0),BackgroundTransparency=1,Text="players  0",TextColor3=Colors.TextBright,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=154})
    Create("Frame",{Parent=LeftHead,Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundColor3=Colors.SectionBorder,BackgroundTransparency=0.62,BorderSizePixel=0,ZIndex=154})
    local Search=Create("TextBox",{Parent=Left,Position=UDim2.fromOffset(6,26),Size=UDim2.new(1,-12,0,22),BackgroundColor3=Colors.Bg,BackgroundTransparency=0.22,BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText="search...",PlaceholderColor3=Colors.TextDim,Text="",TextColor3=Colors.TextBright,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=153},{Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.60}),Create("UIPadding",{PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,7)})})
    local ListHead=Create("Frame",{Parent=Left,Position=UDim2.fromOffset(6,54),Size=UDim2.new(1,-12,0,18),BackgroundColor3=Colors.Bg,BackgroundTransparency=0.48,BorderSizePixel=0,ZIndex=153})
    Create("TextLabel",{Parent=ListHead,Position=UDim2.fromOffset(28,0),Size=UDim2.new(1,-116,1,0),BackgroundTransparency=1,Text="name",TextColor3=Colors.TextDim,Font=Enum.Font.SourceSans,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=154})
    Create("TextLabel",{Parent=ListHead,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,0),Size=UDim2.fromOffset(82,18),BackgroundTransparency=1,Text="status",TextColor3=Colors.TextDim,Font=Enum.Font.SourceSans,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=154})
    local List=Create("ScrollingFrame",{Parent=Left,Position=UDim2.fromOffset(6,73),Size=UDim2.new(1,-12,1,-79),BackgroundColor3=Colors.Bg,BackgroundTransparency=0.68,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=2,ScrollBarImageColor3=Colors.TextDim,ZIndex=153},{Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.70}),Create("UIListLayout",{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder}),Create("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,2),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,2)})})
    local RightHead=Create("Frame",{Parent=Right,Size=UDim2.new(1,0,0,20),BackgroundColor3=Colors.TitleBg,BackgroundTransparency=0.10,BorderSizePixel=0,ZIndex=153})
    Create("TextLabel",{Parent=RightHead,Position=UDim2.fromOffset(7,0),Size=UDim2.new(1,-14,1,0),BackgroundTransparency=1,Text="selected",TextColor3=Colors.TextBright,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=154})
    Create("Frame",{Parent=RightHead,Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundColor3=Colors.SectionBorder,BackgroundTransparency=0.62,BorderSizePixel=0,ZIndex=154})
    local Empty=Create("TextLabel",{Parent=Right,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.50),Size=UDim2.new(1,-16,0,20),BackgroundTransparency=1,Text="no player selected",TextColor3=Colors.TextDim,Font=Enum.Font.SourceSans,TextSize=11,ZIndex=153})
    local Profile=Create("Frame",{Parent=Right,Position=UDim2.fromOffset(7,27),Size=UDim2.new(1,-14,1,-34),BackgroundTransparency=1,Visible=false,ZIndex=153})
    local Identity=Create("Frame",{Parent=Profile,Size=UDim2.new(1,0,0,58),BackgroundColor3=Colors.Bg,BackgroundTransparency=0.58,BorderSizePixel=0,ZIndex=153},{Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.66})})
    local AvatarHolder=Create("Frame",{Parent=Identity,Position=UDim2.fromOffset(6,6),Size=UDim2.fromOffset(46,46),BackgroundColor3=Colors.Control,BorderSizePixel=0,ClipsDescendants=true,ZIndex=154},{Create("UICorner",{CornerRadius=UDim.new(1,0)}),Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.40})})
    local Avatar=Create("ImageLabel",{Parent=AvatarHolder,Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,1,-2),BackgroundTransparency=1,Image="",ScaleType=Enum.ScaleType.Crop,ZIndex=155},{Create("UICorner",{CornerRadius=UDim.new(1,0)})})
    local User=Create("TextLabel",{Parent=Identity,Position=UDim2.fromOffset(60,8),Size=UDim2.new(1,-66,0,18),BackgroundTransparency=1,Text="",TextColor3=Colors.TextBright,Font=Enum.Font.SourceSans,TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=154})
    local Info=Create("TextLabel",{Parent=Identity,Position=UDim2.fromOffset(60,28),Size=UDim2.new(1,-66,0,16),BackgroundTransparency=1,Text="",TextColor3=Colors.TextDim,Font=Enum.Font.SourceSans,TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=154})
    Create("TextLabel",{Parent=Profile,Position=UDim2.fromOffset(0,69),Size=UDim2.new(1,0,0,15),BackgroundTransparency=1,Text="status",TextColor3=Colors.TextDim,Font=Enum.Font.SourceSans,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=154})
    local StatusButton=Create("TextButton",{Parent=Profile,Position=UDim2.fromOffset(0,87),Size=UDim2.new(1,0,0,24),BackgroundColor3=Colors.Bg,BackgroundTransparency=0.30,BorderSizePixel=0,AutoButtonColor=false,Text="Neutral",TextColor3=Colors.Text,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=156},{Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.58}),Create("UIPadding",{PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,7)})})
    local StatusArrow=Create("TextLabel",{Parent=StatusButton,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-7,0.5,0),Size=UDim2.fromOffset(11,14),BackgroundTransparency=1,Text="v",TextColor3=Colors.TextDim,Font=Enum.Font.SourceSans,TextSize=10,ZIndex=157})
    local StatusDrop=Create("Frame",{Parent=Profile,Position=UDim2.fromOffset(0,114),Size=UDim2.new(1,0,0,66),BackgroundColor3=Colors.Bg,BackgroundTransparency=0.04,BorderSizePixel=0,Visible=false,ClipsDescendants=true,ZIndex=170},{Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.44}),Create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder})})
    local ActionHolder=Create("Frame",{Parent=Profile,Position=UDim2.new(0,0,1,-27),Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,ZIndex=154},{Create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Left,Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder})})
    local Scale=Create("UIScale",{Parent=Frame,Scale=math.clamp((tonumber(Data.Scale) or 100)/100,0.65,1.5)})
    local StatusColors={Client=Accent(),Neutral=Colors.TextDim,Whitelist=Color3.fromRGB(87,196,129),Enemy=Color3.fromRGB(224,92,102)}
    local Object={Gui=Gui,Frame=Frame,Header=Header,List=List,Scale=Scale,Rows={},RequestedVisible=Data.Visible==true,MenuVisible=true,Selected=nil,Search="",Data=Data,DropOpen=false}
    local function NormalizeStatus(Status)
        Status=tostring(Status or "Neutral")
        if Status=="None" or Status=="none" or Status=="" then return "Neutral" end
        if Status=="Whitelist" or Status=="Enemy" or Status=="Neutral" then return Status end
        return "Neutral"
    end
    local function ReadStatus(Player)
        if not Player then return "Neutral" end
        if Player==Players.LocalPlayer then return "Client" end
        local UserId=tonumber(Player.UserId) or 0 local External
        if type(Data.GetStatus)=="function" then local Ok,Value=Call(Data.GetStatus,Player) if Ok then External=Value end end
        local Status=NormalizeStatus(External or Library.PlayerStatuses[UserId])
        Library.PlayerStatuses[UserId]=Status
        return Status
    end
    local RefreshRows local RefreshSelected
    local function CloseDrop() Object.DropOpen=false StatusDrop.Visible=false StatusArrow.Text="v" end
    local function SetStatus(Player,Status,Silent)
        if not Player or Player==Players.LocalPlayer then return "Client" end
        Status=NormalizeStatus(Status) Library.PlayerStatuses[tonumber(Player.UserId) or 0]=Status
        if not Silent and type(Data.StatusChanged)=="function" then Call(Data.StatusChanged,Player,Status) end
        if RefreshRows then RefreshRows() end if RefreshSelected and Object.Selected==Player then RefreshSelected(false) end
        return Status
    end
    local function MakeStatusOption(Name,Order)
        local Button=Create("TextButton",{Parent=StatusDrop,Size=UDim2.new(1,0,0,22),BackgroundColor3=Colors.Control,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Text=Name,TextColor3=StatusColors[Name] or Colors.Text,Font=Enum.Font.SourceSans,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=Order,ZIndex=171},{Create("UIPadding",{PaddingLeft=UDim.new(0,7)})})
        Bind(Button.MouseEnter:Connect(function() Button.BackgroundTransparency=0.78 end))
        Bind(Button.MouseLeave:Connect(function() Button.BackgroundTransparency=1 end))
        Bind(Button.MouseButton1Click:Connect(function() if Object.Selected then SetStatus(Object.Selected,Name,false) end CloseDrop() end))
    end
    MakeStatusOption("Neutral",1) MakeStatusOption("Whitelist",2) MakeStatusOption("Enemy",3)
    local function MakeAction(Name,CallbackKey,Order)
        local Button=Create("TextButton",{Parent=ActionHolder,Size=UDim2.new(0.5,-2,1,0),BackgroundColor3=Colors.Bg,BackgroundTransparency=0.38,BorderSizePixel=0,Text=string.lower(Name),TextColor3=Colors.Text,Font=Enum.Font.SourceSans,TextSize=10,AutoButtonColor=false,LayoutOrder=Order,ZIndex=155},{Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.62})})
        Bind(Button.MouseEnter:Connect(function() Button.BackgroundTransparency=0.22 Button.TextColor3=Colors.TextBright end))
        Bind(Button.MouseLeave:Connect(function() Button.BackgroundTransparency=0.38 Button.TextColor3=Colors.Text end))
        Bind(Button.MouseButton1Click:Connect(function() local Callback=Data[CallbackKey] if type(Callback)~="function" then return end if CallbackKey=="Unspectate" then task.spawn(Callback) elseif Object.Selected then task.spawn(Callback,Object.Selected) end end))
        return Button
    end
    MakeAction("spectate","Spectate",1)
    MakeAction("unspectate","Unspectate",2)
    RefreshSelected=function(LoadImage)
        local Player=Object.Selected local Valid=Player and Player.Parent==Players
        Empty.Visible=not Valid Profile.Visible=Valid CloseDrop()
        if not Valid then Object.Selected=nil Avatar.Image="" User.Text="" Info.Text="" return end
        if LoadImage~=false then Avatar.Image="rbxthumb://type=AvatarHeadShot&id="..tostring(Player.UserId).."&w=150&h=150" end
        User.Text=Player.Name
        Info.Text=(Player.DisplayName~=Player.Name and Player.DisplayName.."  /  " or "")..tostring(Player.UserId)
        local Status=ReadStatus(Player) StatusButton.Text=Status StatusButton.TextColor3=StatusColors[Status] or Colors.Text
        StatusButton.Active=Player~=Players.LocalPlayer StatusArrow.Visible=Player~=Players.LocalPlayer
    end
    local function Select(Player)
        if Player and Player.Parent~=Players then Player=nil end Object.Selected=Player
        if RefreshRows then RefreshRows() end if RefreshSelected then RefreshSelected(true) end
    end
    RefreshRows=function()
        for _,Row in ipairs(Object.Rows) do if Row and Row.Parent then Row:Destroy() end end table.clear(Object.Rows)
        local Query=string.lower(Object.Search or "") local Items=Players:GetPlayers()
        table.sort(Items,function(A,B)
            if A==Players.LocalPlayer then return true end if B==Players.LocalPlayer then return false end
            local Rank={Enemy=1,Whitelist=2,Neutral=3} local SA,SB=ReadStatus(A),ReadStatus(B)
            if Rank[SA] and Rank[SB] and Rank[SA]~=Rank[SB] then return Rank[SA]<Rank[SB] end
            return A.Name:lower()<B.Name:lower()
        end)
        local VisibleCount=0
        for _,Player in ipairs(Items) do
            local SearchName=string.lower(Player.Name.." "..Player.DisplayName)
            if Query=="" or string.find(SearchName,Query,1,true) then
                VisibleCount+=1 local Status=ReadStatus(Player) local Selected=Object.Selected==Player
                local Row=Create("TextButton",{Parent=List,Size=UDim2.new(1,0,0,24),BackgroundColor3=Colors.Control,BackgroundTransparency=Selected and 0.54 or 1,BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=VisibleCount,ZIndex=154})
                Create("Frame",{Parent=Row,Position=UDim2.fromOffset(0,3),Size=UDim2.fromOffset(1,18),BackgroundColor3=Accent(),BackgroundTransparency=Selected and 0 or 1,BorderSizePixel=0,ZIndex=156})
                local MiniHolder=Create("Frame",{Parent=Row,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,5,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=Colors.Control,BorderSizePixel=0,ClipsDescendants=true,ZIndex=155},{Create("UICorner",{CornerRadius=UDim.new(1,0)})})
                Create("ImageLabel",{Parent=MiniHolder,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Image="rbxthumb://type=AvatarHeadShot&id="..tostring(Player.UserId).."&w=48&h=48",ScaleType=Enum.ScaleType.Crop,ZIndex=156},{Create("UICorner",{CornerRadius=UDim.new(1,0)})})
                local NameLabel=Create("TextLabel",{Parent=Row,Position=UDim2.fromOffset(27,0),Size=UDim2.new(1,-116,1,0),BackgroundTransparency=1,Text=Player.Name,TextColor3=Selected and Colors.TextBright or Colors.Text,Font=Enum.Font.SourceSans,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=155})
                local StatusLabel=Create("TextLabel",{Parent=Row,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-5,0,0),Size=UDim2.fromOffset(82,24),BackgroundTransparency=1,Text=Status,TextColor3=StatusColors[Status] or Colors.TextDim,Font=Enum.Font.SourceSans,TextSize=9,TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=155})
                Bind(Row.MouseEnter:Connect(function() if Object.Selected~=Player then Row.BackgroundTransparency=0.86 NameLabel.TextColor3=Colors.TextBright end end))
                Bind(Row.MouseLeave:Connect(function() if Object.Selected~=Player then Row.BackgroundTransparency=1 NameLabel.TextColor3=Colors.Text end end))
                Bind(Row.MouseButton1Click:Connect(function() Select(Player) end))
                Object.Rows[#Object.Rows+1]=Row
            end
        end
        Count.Text="players  "..tostring(VisibleCount)
    end
    Bind(StatusButton.MouseButton1Click:Connect(function()
        if not Object.Selected or Object.Selected==Players.LocalPlayer then return end
        Object.DropOpen=not Object.DropOpen StatusDrop.Visible=Object.DropOpen StatusArrow.Text=Object.DropOpen and "^" or "v"
    end))
    function Object:ApplyVisibility()
        Frame.Visible=Object.RequestedVisible==true and Object.MenuVisible~=false and Library.InterfaceOpen~=false
        if not Frame.Visible then CloseDrop() end
        if Library.QuickPanelController and type(Library.QuickPanelController.Refresh)=="function" then task.defer(Library.QuickPanelController.Refresh) end
    end
    function Object:SetVisibility(State) Object.RequestedVisible=State==true Object:ApplyVisibility() end
    function Object:SetMenuVisible(State) Object.MenuVisible=State==true Object:ApplyVisibility() end
    function Object:IsVisible() return Object.RequestedVisible==true and Object.MenuVisible~=false and Library.InterfaceOpen~=false end
    function Object:IsRequestedVisible() return Object.RequestedVisible==true end
    function Object:Toggle() Object:SetVisibility(not Object.RequestedVisible) end
    function Object:SetScale(Value) Scale.Scale=math.clamp((tonumber(Value) or 100)/100,0.65,1.5) end
    function Object:SetStatus(Player,Status) return SetStatus(Player,Status,false) end
    function Object:GetStatus(Player) return ReadStatus(Player) end
    function Object:SelectPlayer(Player) Select(Player) end
    function Object:Refresh() RefreshRows() RefreshSelected(false) end
    Bind(Search:GetPropertyChangedSignal("Text"):Connect(function() Object.Search=Search.Text RefreshRows() end))
    Bind(Players.PlayerAdded:Connect(function() task.defer(function() Object:Refresh() end) end))
    Bind(Players.PlayerRemoving:Connect(function(Player) Library.PlayerStatuses[tonumber(Player.UserId) or 0]=nil if Object.Selected==Player then Object.Selected=nil end task.defer(function() Object:Refresh() end) end))
    MakeDraggable(Frame,Header,Gui)
    MakeResizable({Main=Frame,ScreenGui=Gui},Vector2.new(520,300))
    RegisterRenderer(function()
        local A=Accent() StatusColors.Client=A AccentLine.BackgroundColor3=A
        local Gradient=AccentLine:FindFirstChildOfClass("UIGradient") if Gradient then Gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new()),ColorSequenceKeypoint.new(0.12,A),ColorSequenceKeypoint.new(0.88,A),ColorSequenceKeypoint.new(1,Color3.new())}) end
        if Object.Selected then RefreshSelected(false) end
    end)
    Object:Refresh() self.PlayerListController=Object Object:ApplyVisibility() return Object
end

function Library:QuickPanel(Data)
    Data=type(Data)=="table" and Data or {}
    if self.QuickPanelController then return self.QuickPanelController end
    self.InterfaceOpen=self.InterfaceOpen~=false
    local Parent=ParentGui()
    local Gui=Create("ScreenGui",{Name="AtramentaQuickPanel",Parent=Parent,ResetOnSpawn=false,DisplayOrder=190,ZIndexBehavior=Enum.ZIndexBehavior.Global,IgnoreGuiInset=false})
    self.Guis[#self.Guis+1]=Gui
    local Root=Create("Frame",{Parent=Gui,AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,8),Size=UDim2.fromOffset(174,29),BackgroundColor3=Colors.TitleBg,BackgroundTransparency=0,BorderSizePixel=0,Visible=self.InterfaceOpen,Active=true,ZIndex=190},{Create("UICorner",{CornerRadius=UDim.new(0,2)}),Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.58})})
    local Inner=Create("Frame",{Parent=Root,Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,1,-2),BackgroundColor3=Colors.TitleBg,BorderSizePixel=0,ZIndex=191},{Create("UICorner",{CornerRadius=UDim.new(0,2)}),Create("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Colors.Control),ColorSequenceKeypoint.new(0.55,Colors.TitleBg),ColorSequenceKeypoint.new(1,Colors.Bg)})})})
    local AccentLine=Create("Frame",{Parent=Inner,Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundColor3=Accent(),BorderSizePixel=0,ZIndex=194},{Create("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new()),ColorSequenceKeypoint.new(0.18,Accent()),ColorSequenceKeypoint.new(0.82,Accent()),ColorSequenceKeypoint.new(1,Color3.new())})})})
    local Holder=Create("Frame",{Parent=Inner,Position=UDim2.fromOffset(5,4),Size=UDim2.new(1,-10,1,-8),BackgroundTransparency=1,ZIndex=192},{Create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})})
    local Object={Gui=Gui,Root=Root,Buttons={}}
    local function RequestedMenu() local Window=Library.ActiveWindow return Window and Window.Visible==true or false end
    local function RequestedPlayers() local Controller=Library.PlayerListController return Controller and Controller.RequestedVisible==true or false end
    local function Paint(Button,State)
        Button.BackgroundTransparency=State and 0.60 or 0.84 Button.TextColor3=State and Accent() or Colors.Text
        local Stroke=Button:FindFirstChildOfClass("UIStroke") if Stroke then Stroke.Color=State and Accent() or Colors.SectionBorder Stroke.Transparency=State and 0.68 or 0.72 end
    end
    local function Make(Name,Order,Callback)
        local Button=Create("TextButton",{Parent=Holder,Size=UDim2.new(0.5,-3,1,0),BackgroundColor3=Colors.Bg,BackgroundTransparency=0.80,BorderSizePixel=0,Text=string.lower(Name),TextColor3=Colors.Text,Font=Enum.Font.SourceSans,TextSize=11,AutoButtonColor=false,LayoutOrder=Order,ZIndex=193},{Create("UICorner",{CornerRadius=UDim.new(0,2)}),Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.55})})
        Object.Buttons[Name]=Button Bind(Button.MouseButton1Click:Connect(Callback)) return Button
    end
    function Object.Refresh()
        if Object.Buttons.Menu then Paint(Object.Buttons.Menu,RequestedMenu()) end
        if Object.Buttons.PlayerList then Paint(Object.Buttons.PlayerList,RequestedPlayers()) end
    end
    Make("Menu",1,function() local Window=Library.ActiveWindow if Window then Window:SetVisible(not Window.Visible) end Object.Refresh() end)
    Make("PlayerList",2,function() local Controller=Library.PlayerListController if Controller then Controller:SetVisibility(not Controller.RequestedVisible) end Object.Refresh() end)
    function Object:SetInterfaceVisible(State)
        State=State==true Library.InterfaceOpen=State Root.Visible=State
        local Window=Library.ActiveWindow if Window and type(Window.SetMenuVisible)=="function" then Window:SetMenuVisible(State) end
        local PlayersPanel=Library.PlayerListController if PlayersPanel and type(PlayersPanel.SetMenuVisible)=="function" then PlayersPanel:SetMenuVisible(State) end
        local Watermark=Library.WatermarkController if Watermark and type(Watermark.SetMenuVisible)=="function" then Watermark:SetMenuVisible(State) end
        local Keybinds=Library.KeybindListController if Keybinds and type(Keybinds.SetMenuVisible)=="function" then Keybinds:SetMenuVisible(State) end
        if not State and type(Library.SetNotificationPreviewVisible)=="function" then Library:SetNotificationPreviewVisible(false)
        elseif State and Window and Window:IsVisible() and type(Library.SetNotificationPreviewVisible)=="function" then Library:SetNotificationPreviewVisible(true) end
        Object.Refresh()
    end
    function Object:ToggleInterface() Object:SetInterfaceVisible(not (Library.InterfaceOpen~=false)) end
    function Object:IsVisible() return Library.InterfaceOpen~=false end
    MakeDraggable(Root,Root,Gui) BindFrameToViewport(Root,Gui,4)
    RegisterRenderer(function()
        local A=Accent() AccentLine.BackgroundColor3=A local Gradient=AccentLine:FindFirstChildOfClass("UIGradient")
        if Gradient then Gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new()),ColorSequenceKeypoint.new(0.18,A),ColorSequenceKeypoint.new(0.82,A),ColorSequenceKeypoint.new(1,Color3.new())}) end Object.Refresh()
    end)
    self.QuickPanelController=Object Object.Refresh() return Object
end

function Library:GetNotificationAlign()
    local Point=typeof(self.NotificationPoint)=="Vector2" and self.NotificationPoint or Vector2.new(0.94,0.08)
    Point=Vector2.new(math.clamp(Point.X,0.02,0.98),math.clamp(Point.Y,0.02,0.98))
    self.NotificationPoint=Point
    local AX=Point.X<0.34 and 0 or Point.X>0.66 and 1 or 0.5
    local AY=Point.Y<0.34 and 0 or Point.Y>0.66 and 1 or 0.5
    local H=AX==0 and Enum.HorizontalAlignment.Left or AX==1 and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Center
    local V=AY==0 and Enum.VerticalAlignment.Top or AY==1 and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Center
    return Point,Vector2.new(AX,AY),H,V
end

function Library:ApplyNotificationLayout()
    local Holder=self.NotificationHolder
    local Gui=self.NotificationGui
    if not Holder or not Holder.Parent or not Gui or not Gui.Parent then return end
    local Point,Anchor,H,V=self:GetNotificationAlign()
    local Viewport=GetViewportSize(Gui)
    Holder.Size=UDim2.fromOffset(math.max(140,math.min(320,Viewport.X-24)),math.max(120,math.min(560,Viewport.Y-24)))
    Holder.AnchorPoint=Anchor Holder.Position=UDim2.fromScale(Point.X,Point.Y)
    local Layout=Holder:FindFirstChildOfClass("UIListLayout")
    if Layout then Layout.HorizontalAlignment=H Layout.VerticalAlignment=V end
    if self.NotificationPreview and self.NotificationPreview.Parent then self.NotificationPreview.Position=UDim2.fromScale(Point.X,Point.Y) end
end

function Library:SetNotificationLayout(Position)
    if typeof(Position)=="Vector2" then self.NotificationPoint=Position
    elseif typeof(Position)=="UDim2" then self.NotificationPoint=Vector2.new(Position.X.Scale,Position.Y.Scale)
    elseif type(Position)=="string" then
        local Map={
            ["Top Left"]=Vector2.new(0.06,0.08),["Top Center"]=Vector2.new(0.5,0.08),["Top Right"]=Vector2.new(0.94,0.08),
            ["Middle Left"]=Vector2.new(0.06,0.5),["Middle Center"]=Vector2.new(0.5,0.5),["Middle Right"]=Vector2.new(0.94,0.5),
            ["Bottom Left"]=Vector2.new(0.06,0.92),["Bottom Center"]=Vector2.new(0.5,0.92),["Bottom Right"]=Vector2.new(0.94,0.92)
        }
        if Map[Position] then self.NotificationPoint=Map[Position] end
    end
    self:ApplyNotificationLayout()
end

function Library:EnsureNotificationGui()
    local Parent=ParentGui() local Gui=self.NotificationGui
    if Gui and Gui.Parent and self.NotificationHolder and self.NotificationHolder.Parent then return Gui end
    Gui=Create("ScreenGui",{Name="AtramentaNotifications",Parent=Parent,ResetOnSpawn=false,DisplayOrder=200,ZIndexBehavior=Enum.ZIndexBehavior.Global,IgnoreGuiInset=false})
    self.Guis[#self.Guis+1]=Gui self.NotificationGui=Gui
    self.NotificationHolder=Create("Frame",{Parent=Gui,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,10),Size=UDim2.fromOffset(320,560),BackgroundTransparency=1},{Create("UIListLayout",{Padding=UDim.new(0,4),HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Top,SortOrder=Enum.SortOrder.LayoutOrder})})
    local Preview=Create("Frame",{Name="NotificationExample",Parent=Gui,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.94,0.08),Size=UDim2.fromOffset(238,42),BackgroundColor3=Colors.Bg,BorderSizePixel=0,Visible=false,Active=true,ZIndex=5000},{Create("UICorner",{CornerRadius=UDim.new(0,2)}),Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1}),Create("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Colors.Control),ColorSequenceKeypoint.new(1,Colors.Bg)})})})
    local AccentLine=Create("Frame",{Parent=Preview,Position=UDim2.fromOffset(0,0),Size=UDim2.new(0,2,1,0),BackgroundColor3=Accent(),BorderSizePixel=0,ZIndex=5002})
    local Header=Create("Frame",{Parent=Preview,Position=UDim2.fromOffset(2,1),Size=UDim2.new(1,-3,0,17),BackgroundColor3=Colors.TitleBg,BackgroundTransparency=0.22,BorderSizePixel=0,ZIndex=5001})
    Create("TextLabel",{Parent=Header,Position=UDim2.fromOffset(6,0),Size=UDim2.new(1,-12,1,0),BackgroundTransparency=1,Text="atramenta.rip",TextColor3=Colors.TextBright,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5002})
    Create("TextLabel",{Parent=Preview,Position=UDim2.fromOffset(8,19),Size=UDim2.new(1,-14,0,18),BackgroundTransparency=1,Text="example notification - drag me",TextColor3=Colors.Text,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5002})
    self.NotificationPreview=Preview
    local Dragging=false local StartMouse local StartPoint
    Bind(Preview.InputBegan:Connect(function(Input)
        if Input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        Dragging=true StartMouse=Input.Position StartPoint=typeof(self.NotificationPoint)=="Vector2" and self.NotificationPoint or Vector2.new(0.94,0.08)
    end))
    Bind(UserInputService.InputChanged:Connect(function(Input)
        if not Dragging or Input.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local Viewport=GetViewportSize(Gui) if Viewport.X<=0 or Viewport.Y<=0 then return end
        local Delta=Input.Position-StartMouse
        local HalfX=(Preview.AbsoluteSize.X*0.5+6)/Viewport.X local HalfY=(Preview.AbsoluteSize.Y*0.5+6)/Viewport.Y
        self.NotificationPoint=Vector2.new(math.clamp(StartPoint.X+Delta.X/Viewport.X,HalfX,1-HalfX),math.clamp(StartPoint.Y+Delta.Y/Viewport.Y,HalfY,1-HalfY))
        self:ApplyNotificationLayout()
    end))
    Bind(UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType==Enum.UserInputType.MouseButton1 then Dragging=false end end))
    Bind(Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:ApplyNotificationLayout() end))
    RegisterRenderer(function() if Preview and Preview.Parent then AccentLine.BackgroundColor3=Accent() end end)
    self:ApplyNotificationLayout()
    return Gui
end

function Library:SetNotificationPreviewVisible(State)
    self:EnsureNotificationGui()
    local Window=self.ActiveWindow
    State=State==true and self.InterfaceOpen~=false and Window and Window:IsVisible() or false
    if self.NotificationPreview and self.NotificationPreview.Parent then self.NotificationPreview.Visible=State end
end


function Library:GetCombatLogAlign(Position)
    Position=tostring(Position or self.CombatLogPosition or "Top Right")
    local Map={
        ["Top Left"]=Vector2.new(0.015,0.145),["Top Center"]=Vector2.new(0.5,0.145),["Top Right"]=Vector2.new(0.985,0.145),
        ["Middle Left"]=Vector2.new(0.015,0.5),["Middle Center"]=Vector2.new(0.5,0.5),["Middle Right"]=Vector2.new(0.985,0.5),
        ["Bottom Left"]=Vector2.new(0.015,0.92),["Bottom Center"]=Vector2.new(0.5,0.92),["Bottom Right"]=Vector2.new(0.985,0.92)
    }
    local Point=Map[Position] or Map["Top Right"]
    local AX=Point.X<0.34 and 0 or Point.X>0.66 and 1 or 0.5
    local AY=Point.Y<0.34 and 0 or Point.Y>0.66 and 1 or 0.5
    local H=AX==0 and Enum.HorizontalAlignment.Left or AX==1 and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Center
    local V=AY==0 and Enum.VerticalAlignment.Top or AY==1 and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Center
    return Position,Point,Vector2.new(AX,AY),H,V
end

function Library:EnsureCombatLogGui()
    local Parent=ParentGui() local Gui=self.CombatLogGui
    if Gui and Gui.Parent and self.CombatLogHolder and self.CombatLogHolder.Parent then return Gui end
    Gui=Create("ScreenGui",{Name="AtramentaCombatLogs",Parent=Parent,ResetOnSpawn=false,DisplayOrder=199,ZIndexBehavior=Enum.ZIndexBehavior.Global,IgnoreGuiInset=false})
    self.Guis[#self.Guis+1]=Gui self.CombatLogGui=Gui
    local Holder=Create("Frame",{Name="CombatLogHolder",Parent=Gui,AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(0.985,0.145),Size=UDim2.fromOffset(320,520),BackgroundTransparency=1,ZIndex=4500},{Create("UIListLayout",{Padding=UDim.new(0,4),HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Top,SortOrder=Enum.SortOrder.LayoutOrder})})
    self.CombatLogHolder=Holder
    self.CombatLogScaleObject=Create("UIScale",{Parent=Holder,Scale=1})
    self:SetCombatLogLayout(self.CombatLogPosition or "Top Right",self.CombatLogScale or 100)
    return Gui
end

function Library:SetCombatLogLayout(Position,Scale)
    if Position~=nil then self.CombatLogPosition=tostring(Position) end
    self.CombatLogScale=math.clamp(tonumber(Scale) or tonumber(self.CombatLogScale) or 100,60,160)
    local Gui=self.CombatLogGui local Holder=self.CombatLogHolder
    if not Gui or not Gui.Parent or not Holder or not Holder.Parent then return end
    local _,Point,Anchor,H,V=self:GetCombatLogAlign(self.CombatLogPosition)
    Holder.AnchorPoint=Anchor Holder.Position=UDim2.fromScale(Point.X,Point.Y)
    local Layout=Holder:FindFirstChildOfClass("UIListLayout") if Layout then Layout.HorizontalAlignment=H Layout.VerticalAlignment=V end
    local ScaleObject=self.CombatLogScaleObject if ScaleObject and ScaleObject.Parent then ScaleObject.Scale=self.CombatLogScale/100 end
end

function Library:CombatLogNotification(Data)
    if type(Data)=="string" then Data={Description=Data} end Data=Data or {}
    local Gui=self:EnsureCombatLogGui()
    self:SetCombatLogLayout(Data.Position or self.CombatLogPosition or "Top Right",Data.Scale or self.CombatLogScale or 100)
    self.CombatLogSerial=(self.CombatLogSerial or 0)+1
    local Title=string.lower(tostring(Data.Title or "log")) local Description=tostring(Data.Description or "")
    local MaxTextWidth=270
    local DescBounds=TextService:GetTextSize(Description,11,Enum.Font.SourceSans,Vector2.new(MaxTextWidth,1000))
    local TitleBounds=TextService:GetTextSize(Title,11,Enum.Font.SourceSans,Vector2.new(MaxTextWidth,16))
    local Viewport=GetViewportSize(Gui) local MaximumWidth=math.max(150,math.min(310,Viewport.X-28))
    local Width=math.clamp(math.ceil(math.max(TitleBounds.X+20,math.min(DescBounds.X,MaxTextWidth)+20)),math.min(170,MaximumWidth),MaximumWidth)
    local DescWidth=Width-18 local Wrapped=TextService:GetTextSize(Description,11,Enum.Font.SourceSans,Vector2.new(DescWidth,1000))
    local DescHeight=Description=="" and 0 or math.clamp(math.ceil(Wrapped.Y),13,34) local Height=Description=="" and 22 or 22+DescHeight
    local Wrapper=Create("Frame",{Parent=self.CombatLogHolder,Size=UDim2.fromOffset(Width,Height),BackgroundTransparency=1,LayoutOrder=self.CombatLogSerial,ZIndex=4501})
    local Group=Create("CanvasGroup",{Parent=Wrapper,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,GroupTransparency=1,ZIndex=4502})
    local Panel=Create("Frame",{Parent=Group,Size=UDim2.fromScale(1,1),BackgroundColor3=Colors.Bg,BorderSizePixel=0,ZIndex=4503},{Create("UICorner",{CornerRadius=UDim.new(0,2)}),Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0.12}),Create("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Colors.Control),ColorSequenceKeypoint.new(1,Colors.Bg)})})})
    local AccentLine=Create("Frame",{Parent=Panel,Size=UDim2.new(0,2,1,0),BackgroundColor3=Accent(),BorderSizePixel=0,ZIndex=4505})
    local Header=Create("Frame",{Parent=Panel,Position=UDim2.fromOffset(2,1),Size=UDim2.new(1,-3,0,17),BackgroundColor3=Colors.TitleBg,BackgroundTransparency=0.24,BorderSizePixel=0,ZIndex=4504})
    Create("TextLabel",{Parent=Header,Position=UDim2.fromOffset(6,0),Size=UDim2.new(1,-12,1,0),BackgroundTransparency=1,Text=Title,TextColor3=Colors.TextBright,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=4505})
    if Description~="" then Create("TextLabel",{Parent=Panel,Position=UDim2.fromOffset(8,19),Size=UDim2.new(1,-14,0,DescHeight),BackgroundTransparency=1,Text=Description,TextColor3=Colors.Text,Font=Enum.Font.SourceSans,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=4505}) end
    local Duration=math.max(tonumber(Data.Duration) or 3,0.35)
    local Progress=Create("Frame",{Parent=Panel,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,2,1,0),Size=UDim2.new(1,-2,0,1),BackgroundColor3=Accent(),BorderSizePixel=0,ZIndex=4506})
    local _,Point=self:GetCombatLogAlign(self.CombatLogPosition) local Direction=Point.X<0.34 and -1 or Point.X>0.66 and 1 or 0
    Group.Position=UDim2.fromOffset(Direction*8,0)
    TweenService:Create(Group,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(0,0),GroupTransparency=0}):Play()
    TweenService:Create(Progress,TweenInfo.new(Duration,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,1)}):Play()
    RegisterRenderer(function() if not Panel.Parent then return end local A=Accent() AccentLine.BackgroundColor3=A Progress.BackgroundColor3=A end)
    local Alive=true
    local function Close()
        if not Alive then return end Alive=false
        TweenService:Create(Group,TweenInfo.new(0.10,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.fromOffset(Direction*7,0),GroupTransparency=1}):Play()
        task.delay(0.11,function() if Wrapper and Wrapper.Parent then Wrapper:Destroy() end end)
    end
    Bind(Wrapper.InputBegan:Connect(function(Input) if Input.UserInputType==Enum.UserInputType.MouseButton2 then Close() end end))
    task.delay(Duration,Close)
    local Count=0 local Oldest local Maximum=math.max(math.floor(tonumber(Data.MaximumVisible) or 8),1)
    for _,Child in ipairs(self.CombatLogHolder:GetChildren()) do if Child:IsA("Frame") then Count+=1 if not Oldest or Child.LayoutOrder<Oldest.LayoutOrder then Oldest=Child end end end
    if Count>Maximum and Oldest and Oldest~=Wrapper then Oldest:Destroy() end
    return Wrapper
end

function Library:Notification(Data)
    if type(Data)=="string" then Data={Description=Data} end Data=Data or {}
    local Gui=self:EnsureNotificationGui()
    self.NotificationSerial=(self.NotificationSerial or 0)+1
    local Title=string.lower(tostring(Data.Title or "atramenta.rip")) local Description=tostring(Data.Description or "") local GenericTitles={warn=true,warning=true,success=true,error=true,info=true,notice=true} if GenericTitles[Title] then Title="atramenta.rip" end
    local MaxTextWidth=252
    local DescBounds=TextService:GetTextSize(Description,11,Enum.Font.SourceSans,Vector2.new(MaxTextWidth,1000))
    local TitleBounds=TextService:GetTextSize(Title,11,Enum.Font.SourceSans,Vector2.new(MaxTextWidth,16))
    local Viewport=GetViewportSize(Gui) local MaximumWidth=math.max(140,math.min(292,Viewport.X-24)) local Width=math.clamp(math.ceil(math.max(TitleBounds.X+18,math.min(DescBounds.X,MaxTextWidth)+18)),math.min(160,MaximumWidth),MaximumWidth)
    local DescWidth=Width-16
    local Wrapped=TextService:GetTextSize(Description,11,Enum.Font.SourceSans,Vector2.new(DescWidth,1000))
    local DescHeight=Description=="" and 0 or math.clamp(math.ceil(Wrapped.Y),13,30)
    local Height=Description=="" and 22 or 22+DescHeight
    local Wrapper=Create("Frame",{Parent=self.NotificationHolder,Size=UDim2.fromOffset(Width,Height),BackgroundTransparency=1,LayoutOrder=self.NotificationSerial})
    local Group=Create("CanvasGroup",{Parent=Wrapper,Size=UDim2.fromScale(1,1),Position=UDim2.fromOffset(0,0),BackgroundTransparency=1,GroupTransparency=1})
    local Panel=Create("Frame",{Parent=Group,Size=UDim2.fromScale(1,1),BackgroundColor3=Colors.Bg,BorderSizePixel=0},{
        Create("UICorner",{CornerRadius=UDim.new(0,2)}),Create("UIStroke",{Color=Colors.SectionBorder,Thickness=1,Transparency=0}),Create("UIGradient",{Rotation=90,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Colors.Control),ColorSequenceKeypoint.new(1,Colors.Bg)})})
    })
    local AccentLine=Create("Frame",{Parent=Panel,Position=UDim2.fromOffset(0,0),Size=UDim2.new(0,2,1,0),BackgroundColor3=Accent(),BorderSizePixel=0,ZIndex=3})
    local Header=Create("Frame",{Parent=Panel,Position=UDim2.fromOffset(2,1),Size=UDim2.new(1,-3,0,17),BackgroundColor3=Colors.TitleBg,BackgroundTransparency=0.22,BorderSizePixel=0})
    Create("TextLabel",{Parent=Header,Position=UDim2.fromOffset(6,0),Size=UDim2.new(1,-12,1,0),BackgroundTransparency=1,Text=Title,TextColor3=Colors.TextBright,Font=Enum.Font.SourceSans,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
    if Description~="" then Create("TextLabel",{Parent=Panel,Position=UDim2.fromOffset(8,19),Size=UDim2.new(1,-14,0,DescHeight),BackgroundTransparency=1,Text=Description,TextColor3=Colors.Text,Font=Enum.Font.SourceSans,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top}) end
    local Duration=math.max(tonumber(Data.Duration) or 3,0.35)
    local Progress=Create("Frame",{Parent=Panel,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,2,1,0),Size=UDim2.new(1,-2,0,1),BackgroundColor3=Accent(),BorderSizePixel=0,ZIndex=4})
    local Point=typeof(self.NotificationPoint)=="Vector2" and self.NotificationPoint or Vector2.new(0.94,0.08) local Direction=Point.X<0.34 and -1 or Point.X>0.66 and 1 or 0
    Group.Position=UDim2.fromOffset(Direction*9,0)
    TweenService:Create(Group,TweenInfo.new(0.14,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(0,0),GroupTransparency=0}):Play()
    TweenService:Create(Progress,TweenInfo.new(Duration,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,1)}):Play()
    RegisterRenderer(function() if not Panel.Parent then return end local A=Accent() AccentLine.BackgroundColor3=A Progress.BackgroundColor3=A end)
    local Alive=true
    local function Close()
        if not Alive then return end Alive=false
        TweenService:Create(Group,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.fromOffset(Direction*8,0),GroupTransparency=1}):Play()
        task.delay(0.13,function() if Wrapper and Wrapper.Parent then Wrapper:Destroy() end end)
    end
    Bind(Wrapper.InputBegan:Connect(function(Input) if Input.UserInputType==Enum.UserInputType.MouseButton2 then Close() end end))
    task.delay(Duration,Close)
    local Count=0 local Oldest local Maximum=math.max(math.floor(tonumber(Data.MaximumVisible) or tonumber(self.NotificationMaximumVisible) or 8),1)
    for _,Child in ipairs(self.NotificationHolder:GetChildren()) do if Child:IsA("Frame") then Count+=1 if not Oldest or Child.LayoutOrder<Oldest.LayoutOrder then Oldest=Child end end end
    if Count>Maximum and Oldest and Oldest~=Wrapper then Oldest:Destroy() end
    return Wrapper
end

local function PointInside(Object,Point)
    if not Object or not Object.Parent then return false end
    local P,S=Object.AbsolutePosition,Object.AbsoluteSize
    return Point.X>=P.X and Point.X<=P.X+S.X and Point.Y>=P.Y and Point.Y<=P.Y+S.Y
end

Bind(UserInputService.InputBegan:Connect(function(Input,Processed)
    local Capture=Library.Capture
    if Capture then
        if Input.UserInputType==Enum.UserInputType.MouseButton1 then return end
        if Input.UserInputType==Enum.UserInputType.Keyboard and Input.KeyCode==Enum.KeyCode.Escape and not next(Capture.ModifierCandidates or {}) then CancelCapture() return end
        local Key=BindSystem.InputKey(Input) local Id=BindSystem.KeyId(Key) if not Key or not Id then return end
        if not Capture.Armed or os.clock()-Capture.Started<BindSystem.CaptureDelay then return end
        if typeof(Key)=="EnumItem" and IsModifierKey(Key) then Capture.ModifierCandidates[Id]=Key Capture.Bind.Render() return end
        if not Capture.Pending then Capture.Pending,Capture.PendingId=Key,Id Capture.PendingModifiers=BindSystem.ReadModifiers(nil) Capture.Bind.Render() end
        return
    end
    if Input.UserInputType==Enum.UserInputType.MouseButton2 then
        local Point=Input.Position
        for _,BindData in ipairs(Library.Keybinds) do if BindData.Button and PointInside(BindData.Button,Point) then return end end
    end
    if not Processed and Library.ActiveWindow then
        local MenuBind=Library.MenuBindData
        if MenuBind and InputMatches(Input,MenuBind.Key,MenuBind.Modifiers) or not MenuBind and InputMatches(Input,Library.MenuKeybind) then
            Library.ActiveWindow:Toggle()
            return
        end
    end
    if Processed or Input.UserInputType==Enum.UserInputType.MouseButton1 then return end
    for _,BindData in ipairs(Library.Keybinds) do if InputMatches(Input,BindData.Key,BindData.Modifiers) then FireKeybind(BindData,true) end end
end))

Bind(UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType==Enum.UserInputType.MouseButton1 then return end
    local Capture=Library.Capture
    if Capture then
        local Key=BindSystem.InputKey(Input) local Id=BindSystem.KeyId(Key) if not Id then return end
        if Capture.Blocked[Id] then Capture.Blocked[Id]=nil if next(Capture.Blocked)==nil then Capture.Armed=true Capture.Started=os.clock() Capture.Bind.Render() end return end
        if not Capture.Armed then return end
        if Capture.PendingId==Id then
            local BindData=Capture.Bind BindData.Key,BindData.Modifiers=BindSystem.NormalizeBinding(Capture.Pending,Capture.PendingModifiers) Library.Capture=nil BindData.Render() RefreshKeybindList() return
        end
        if Capture.ModifierCandidates and Capture.ModifierCandidates[Id] then
            local Candidate=Capture.ModifierCandidates[Id] Capture.ModifierCandidates[Id]=nil
            if not Capture.Pending then local BindData=Capture.Bind BindData.Key,BindData.Modifiers=BindSystem.NormalizeBinding(Candidate,EmptyModifiers()) Library.Capture=nil BindData.Render() RefreshKeybindList() else Capture.Bind.Render() end
        end
        return
    end
    for _,BindData in ipairs(Library.Keybinds) do if BindData.Mode=="Hold" and BindSystem.ReleaseMatches(Input,BindData.Key) then FireKeybind(BindData,false) end end
end))

function Library.Unload(...)
    for _, BindData in ipairs(Library.Keybinds) do BindData.Destroyed = true end
    table.clear(Library.Keybinds)
    for Index = #Library.Connections, 1, -1 do local Connection = Library.Connections[Index] if Connection then Call(function() Connection:Disconnect() end) end Library.Connections[Index] = nil end
    for Index = #Library.Guis, 1, -1 do local Gui = Library.Guis[Index] if Gui and Gui.Parent then Call(function() Gui:Destroy() end) end Library.Guis[Index] = nil end
    Library.ActiveWindow = nil
    Library.PlayerListController = nil
    Library.QuickPanelController = nil
    Library.InterfaceOpen = true
    Library.KeybindListController = nil
    Library.NotificationGui = nil
    Library.NotificationHolder = nil
    Library.NotificationPreview = nil
    Library.NotificationPoint = nil
    Library.CombatLogGui = nil
    Library.CombatLogHolder = nil
    Library.CombatLogScaleObject = nil
    Library.CombatLogPosition = nil
    Library.CombatLogScale = nil
    Library.Holder = nil
    table.clear(Library.Renderers)
    if rawget(AtramentaEnvironment, "Library") == Library then AtramentaEnvironment.Library = nil end
end
Library.Destroy = Library.Unload

function Library:GetFlag(Name)
    return self.Flags[Name]
end

function Library:SetFlag(Name, Value)
    local Setter = self.Setters[Name]
    if type(Setter) == "function" then
        local Success = Call(Setter, Value)
        return Success == true
    end
    self.Flags[Name] = Value
    UpdateAll()
    return true
end

function Library:SetVisible(State)
    if self.QuickPanelController and type(self.QuickPanelController.SetInterfaceVisible)=="function" then self.QuickPanelController:SetInterfaceVisible(State==true)
    elseif self.ActiveWindow then self.ActiveWindow:SetVisible(State) end
end

function Library:Toggle()
    if self.QuickPanelController and type(self.QuickPanelController.ToggleInterface)=="function" then self.QuickPanelController:ToggleInterface()
    elseif self.ActiveWindow then self.ActiveWindow:Toggle() end
end

Library.window = Library.Window
Library.setvisible = Library.SetVisible
Library.toggle = Library.Toggle
Library.getflag = Library.GetFlag
Library.setflag = Library.SetFlag
Library.notification = Library.Notification
Library.setnotificationlayout = Library.SetNotificationLayout
Library.combatlognotification = Library.CombatLogNotification
Library.setcombatloglayout = Library.SetCombatLogLayout
Library.watermark = Library.Watermark
Library.keybindlist = Library.KeybindList
Library.playerlist = Library.PlayerList
Library.getconfig = Library.GetConfig
Library.loadconfig = Library.LoadConfig
Library.saveconfig = Library.SaveConfig
Library.configexists = Library.ConfigExists
Library.loadconfigfile = Library.LoadConfigFile
Library.deleteconfig = Library.DeleteConfig
Library.refreshconfigslist = Library.RefreshConfigsList
Library.destroy = Library.Destroy

return Library
