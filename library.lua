local Core_Gui_Service = game:GetService("CoreGui")
local User_Input_Service = game:GetService("UserInputService")
local Run_Service = game:GetService("RunService")
local Tween_Service = game:GetService("TweenService")
local Text_Service = game:GetService("TextService")
local Http_Service = game:GetService("HttpService")
local Workspace_Service = game:GetService("Workspace")
local Players_Service = game:GetService("Players")
local Local_Player = Players_Service.LocalPlayer

local Library_Api = {
	Flags = {},
	Registry = {},
	Keybind_Names = {},
	Theme_Objects = {},
	Saved_Positions = {},
	Instances = {},
	Folder_Name = "PhantomHub",
	Config_Name = "AutoSaveConfig.json"
}

local Hub_Colors = {
	mainBackground = Color3.fromRGB(13, 13, 13),
	sidebarBackground = Color3.fromRGB(9, 9, 9),
	sectionBackground = Color3.fromRGB(17, 17, 17),
	elementBackground = Color3.fromRGB(23, 23, 23),
	elementHoverBackground = Color3.fromRGB(30, 18, 18),
	borderColor = Color3.fromRGB(36, 20, 20),
	borderLightColor = Color3.fromRGB(52, 26, 26),
	accentColor = Color3.fromRGB(195, 28, 28),
	accentGradientColor1 = Color3.fromRGB(205, 32, 32),
	accentGradientColor2 = Color3.fromRGB(110, 14, 14),
	textWhiteColor = Color3.fromRGB(235, 235, 235),
	textDarkColor = Color3.fromRGB(130, 130, 130),
	tooltipBackground = Color3.fromRGB(11, 11, 11),
	notificationInfoColor = Color3.fromRGB(195, 28, 28),
	notificationSuccessColor = Color3.fromRGB(45, 185, 45),
	notificationWarningColor = Color3.fromRGB(200, 140, 28),
	notificationErrorColor = Color3.fromRGB(230, 48, 48)
}

local Main_Font = Enum.Font.GothamMedium
local Bold_Font = Enum.Font.GothamBold

local Custom_Input_Names = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
}

local Screen_Gui = Instance.new("ScreenGui")
Screen_Gui.Name = Http_Service:GenerateGUID(false)
Screen_Gui.Parent = Core_Gui_Service
Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen_Gui.DisplayOrder = 999
Screen_Gui.IgnoreGuiInset = true

local function Get_Input_Name(Input_Enum)
	if Custom_Input_Names[Input_Enum] then return Custom_Input_Names[Input_Enum] end
	if Input_Enum == Enum.KeyCode.Unknown then return "None" end
	return Input_Enum.Name
end

local function GetTextWidth(Text_String, Size, Font)
	return Text_Service:GetTextSize(Text_String, Size, Font, Vector2.new(10000, 10000)).X
end

function Library_Api:UpdateTheme(New_Color)
	local Old_Color = Hub_Colors.accentColor
	Hub_Colors.accentColor = New_Color
	for _, Obj in ipairs(Screen_Gui:GetDescendants()) do
		pcall(function()
			if Obj:IsA("Frame") or Obj:IsA("TextButton") then
				if Obj.BackgroundColor3 == Old_Color then Obj.BackgroundColor3 = New_Color end
			elseif Obj:IsA("TextLabel") or Obj:IsA("TextBox") then
				if Obj.TextColor3 == Old_Color then Obj.TextColor3 = New_Color end
			elseif Obj:IsA("UIStroke") then
				if Obj.Color == Old_Color then Obj.Color = New_Color end
			elseif Obj:IsA("ImageLabel") or Obj:IsA("ImageButton") then
				if Obj.ImageColor3 == Old_Color then Obj.ImageColor3 = New_Color end
			elseif Obj:IsA("ScrollingFrame") then
				if Obj.ScrollBarImageColor3 == Old_Color then Obj.ScrollBarImageColor3 = New_Color end
			end
		end)
	end
end

local function Save_To_File(FileName)
	task.spawn(function()
		pcall(function()
			if type(isfolder) == "function" and not isfolder(Library_Api.Folder_Name) then
				makefolder(Library_Api.Folder_Name)
			elseif type(makefolder) == "function" then
				pcall(makefolder, Library_Api.Folder_Name)
			end
		end)
		pcall(function()
			local Serialized_Data = {}
			for Key, Val in pairs(Library_Api.Flags) do
				pcall(function()
					if typeof(Val) == "Color3" then
						Serialized_Data[Key] = {Type = "Color3", R = Val.R, G = Val.G, B = Val.B}
					elseif typeof(Val) == "EnumItem" then
						Serialized_Data[Key] = {Type = "EnumItem", EnumType = tostring(Val.EnumType), Name = Val.Name}
					elseif type(Val) == "table" and Val.Min ~= nil and Val.Max ~= nil then
						Serialized_Data[Key] = {Type = "Range", Min = Val.Min, Max = Val.Max}
					elseif type(Val) == "table" then
						Serialized_Data[Key] = {Type = "Array", Data = Val}
					else
						Serialized_Data[Key] = Val
					end
				end)
			end
			if Library_Api.Instances.Menu then
				local pos = Library_Api.Instances.Menu.Position
				Serialized_Data["$$MenuPos"] = {X = pos.X.Scale, XOff = pos.X.Offset, Y = pos.Y.Scale, YOff = pos.Y.Offset}
			end
			if Library_Api.Instances.Keybinds then
				local pos = Library_Api.Instances.Keybinds.Position
				Serialized_Data["$$KbPos"] = {X = pos.X.Scale, XOff = pos.X.Offset, Y = pos.Y.Scale, YOff = pos.Y.Offset}
			end
			writefile(Library_Api.Folder_Name .. "/" .. FileName, Http_Service:JSONEncode(Serialized_Data))
		end)
	end)
end

local Save_Pending = false
local Last_Save_Time = tick()

local function Auto_Save()
	if Save_Pending then return end
	Save_Pending = true
	task.delay(1, function()
		Save_To_File(Library_Api.Config_Name)
		Last_Save_Time = tick()
		Save_Pending = false
	end)
end

Run_Service.Heartbeat:Connect(function()
	if tick() - Last_Save_Time >= 5 then
		Last_Save_Time = tick()
		Save_To_File(Library_Api.Config_Name)
	end
end)

local function Load_From_File(FileName)
	local success, content = pcall(function()
		return readfile(Library_Api.Folder_Name .. "/" .. FileName)
	end)
	if success and content then
		pcall(function()
			local Decoded_Data = Http_Service:JSONDecode(content)
			if type(Decoded_Data) == "table" then
				for Key, Val in pairs(Decoded_Data) do
					pcall(function()
						if Key == "$$MenuPos" then
							local pos = UDim2.new(Val.X, Val.XOff, Val.Y, Val.YOff)
							Library_Api.Saved_Positions.Menu = pos
							if Library_Api.Instances.Menu then
								Library_Api.Instances.Menu.Position = pos
								Library_Api.Instances.MenuTargetPos = pos
							end
						elseif Key == "$$KbPos" then
							local pos = UDim2.new(Val.X, Val.XOff, Val.Y, Val.YOff)
							Library_Api.Saved_Positions.Keybinds = pos
							if Library_Api.Instances.Keybinds then
								Library_Api.Instances.Keybinds.Position = pos
								Library_Api.Instances.KeybindsTarget = pos
							end
						elseif type(Val) == "table" then
							if Val.Type == "Color3" then
								Library_Api.Flags[Key] = Color3.new(Val.R, Val.G, Val.B)
							elseif Val.Type == "EnumItem" then
								local enumGroup = tostring(Val.EnumType):gsub("Enum%.", "")
								local enumType = Enum[enumGroup]
								if enumType then
									Library_Api.Flags[Key] = enumType[tostring(Val.Name)] or Enum.KeyCode.Unknown
								end
							elseif Val.Type == "Range" then
								Library_Api.Flags[Key] = {Min = Val.Min, Max = Val.Max}
							elseif Val.Type == "Array" then
								Library_Api.Flags[Key] = Val.Data
							else
								Library_Api.Flags[Key] = Val
							end
						else
							Library_Api.Flags[Key] = Val
						end
						if Library_Api.Registry[Key] then
							task.spawn(Library_Api.Registry[Key], Library_Api.Flags[Key])
						end
					end)
				end
			end
		end)
	end
end

Load_From_File(Library_Api.Config_Name)

local Tooltip_Frame = Instance.new("Frame")
Tooltip_Frame.BackgroundColor3 = Hub_Colors.tooltipBackground
Tooltip_Frame.BackgroundTransparency = 0.1
Tooltip_Frame.Size = UDim2.new(0, 0, 0, 22)
Tooltip_Frame.ZIndex = 2000
Tooltip_Frame.Visible = false
Tooltip_Frame.Parent = Screen_Gui

local Tooltip_Corner = Instance.new("UICorner")
Tooltip_Corner.CornerRadius = UDim.new(0, 3)
Tooltip_Corner.Parent = Tooltip_Frame

local Tooltip_Stroke = Instance.new("UIStroke")
Tooltip_Stroke.Color = Hub_Colors.borderLightColor
Tooltip_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Tooltip_Stroke.Transparency = 1
Tooltip_Stroke.Thickness = 1
Tooltip_Stroke.Parent = Tooltip_Frame

local Tooltip_Text = Instance.new("TextLabel")
Tooltip_Text.Size = UDim2.new(1, -14, 1, 0)
Tooltip_Text.Position = UDim2.new(0, 7, 0, 0)
Tooltip_Text.BackgroundTransparency = 1
Tooltip_Text.TextColor3 = Hub_Colors.textWhiteColor
Tooltip_Text.TextTransparency = 1
Tooltip_Text.TextSize = 11
Tooltip_Text.Font = Main_Font
Tooltip_Text.TextXAlignment = Enum.TextXAlignment.Left
Tooltip_Text.ZIndex = 2001
Tooltip_Text.Parent = Tooltip_Frame

local Notification_Container = Instance.new("Frame")
Notification_Container.Size = UDim2.new(0, 240, 1, -40)
Notification_Container.Position = UDim2.new(1, -260, 0, 20)
Notification_Container.BackgroundTransparency = 1
Notification_Container.ZIndex = 1500
Notification_Container.Parent = Screen_Gui

local Notification_Layout = Instance.new("UIListLayout")
Notification_Layout.SortOrder = Enum.SortOrder.LayoutOrder
Notification_Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
Notification_Layout.Padding = UDim.new(0, 6)
Notification_Layout.Parent = Notification_Container

local Tooltip_Target_Text = ""

local function Animate_Element(Element, Properties, Speed)
	local Tween = Tween_Service:Create(Element, TweenInfo.new(Speed or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Properties)
	Tween:Play()
	return Tween
end

local function Apply_Acrylic_Effect(Parent, Transparency, Corner_Radius)
	local Blur_Image = Instance.new("ImageLabel")
	Blur_Image.Size = UDim2.new(1, 0, 1, 0)
	Blur_Image.BackgroundTransparency = 1
	Blur_Image.Image = "rbxassetid://8992230113"
	Blur_Image.TileSize = UDim2.new(0, 256, 0, 256)
	Blur_Image.ScaleType = Enum.ScaleType.Tile
	Blur_Image.ImageTransparency = Transparency or 0.88
	Blur_Image.ZIndex = Parent.ZIndex - 1
	Blur_Image.Parent = Parent
	if Corner_Radius then
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = Corner_Radius
		Corner.Parent = Blur_Image
	end
	return Blur_Image
end

local Keybinds_Frame = Instance.new("Frame")
Keybinds_Frame.Size = UDim2.new(0, 210, 0, 30)
Keybinds_Frame.Position = Library_Api.Saved_Positions.Keybinds or UDim2.new(0, 20, 0, 20)
Keybinds_Frame.BackgroundColor3 = Hub_Colors.mainBackground
Keybinds_Frame.BackgroundTransparency = 0.08
Keybinds_Frame.Visible = false
Keybinds_Frame.Parent = Screen_Gui
Apply_Acrylic_Effect(Keybinds_Frame, 0.9, UDim.new(0, 6))
Library_Api.Instances.Keybinds = Keybinds_Frame
Library_Api.Instances.KeybindsTarget = Keybinds_Frame.Position

local Kb_Corner = Instance.new("UICorner")
Kb_Corner.CornerRadius = UDim.new(0, 6)
Kb_Corner.Parent = Keybinds_Frame

local Kb_Stroke = Instance.new("UIStroke")
Kb_Stroke.Color = Hub_Colors.borderColor
Kb_Stroke.Thickness = 1
Kb_Stroke.Parent = Keybinds_Frame

local Kb_Top = Instance.new("Frame")
Kb_Top.Size = UDim2.new(1, 0, 0, 30)
Kb_Top.BackgroundTransparency = 1
Kb_Top.Parent = Keybinds_Frame

local Kb_Title = Instance.new("TextLabel")
Kb_Title.Size = UDim2.new(1, -20, 1, 0)
Kb_Title.Position = UDim2.new(0, 10, 0, 0)
Kb_Title.BackgroundTransparency = 1
Kb_Title.Text = "Active Keybinds"
Kb_Title.TextColor3 = Hub_Colors.accentColor
Kb_Title.TextSize = 11
Kb_Title.Font = Bold_Font
Kb_Title.TextXAlignment = Enum.TextXAlignment.Center
Kb_Title.Parent = Kb_Top

local Kb_Line = Instance.new("Frame")
Kb_Line.Size = UDim2.new(1, -16, 0, 1)
Kb_Line.Position = UDim2.new(0, 8, 1, 0)
Kb_Line.BackgroundColor3 = Hub_Colors.borderColor
Kb_Line.BorderSizePixel = 0
Kb_Line.Parent = Kb_Top

local Kb_Container = Instance.new("Frame")
Kb_Container.Size = UDim2.new(1, -16, 1, -38)
Kb_Container.Position = UDim2.new(0, 8, 0, 34)
Kb_Container.BackgroundTransparency = 1
Kb_Container.Parent = Keybinds_Frame

local Kb_Layout = Instance.new("UIListLayout")
Kb_Layout.Padding = UDim.new(0, 5)
Kb_Layout.Parent = Kb_Container

local Kb_Dragging = false
local Kb_Drag_Input = nil
local Kb_Drag_Start = nil
local Kb_Start_Pos = nil

Kb_Top.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		Kb_Dragging = true
		Kb_Drag_Start = Input.Position
		Kb_Start_Pos = Keybinds_Frame.Position
		Library_Api.Instances.KeybindsTarget = Kb_Start_Pos
		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then Kb_Dragging = false end
		end)
	end
end)

Kb_Top.InputChanged:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
		Kb_Drag_Input = Input
	end
end)

User_Input_Service.InputChanged:Connect(function(Input)
	if Input == Kb_Drag_Input and Kb_Dragging then
		local Delta = Input.Position - Kb_Drag_Start
		Library_Api.Instances.KeybindsTarget = UDim2.new(Kb_Start_Pos.X.Scale, Kb_Start_Pos.X.Offset + Delta.X, Kb_Start_Pos.Y.Scale, Kb_Start_Pos.Y.Offset + Delta.Y)
		Auto_Save()
	end
end)

Run_Service.RenderStepped:Connect(function()
	if Keybinds_Frame.Visible then
		Keybinds_Frame.Position = Keybinds_Frame.Position:Lerp(Library_Api.Instances.KeybindsTarget, 0.35)
	end
end)

function Library_Api:RefreshKeybinds()
	for _, Child in ipairs(Kb_Container:GetChildren()) do
		if Child:IsA("Frame") then Child:Destroy() end
	end
	local Count = 0
	for Flag, Key in pairs(Library_Api.Flags) do
		if typeof(Key) == "EnumItem" and Key ~= Enum.KeyCode.Unknown then
			local Name = Library_Api.Keybind_Names[Flag] or Flag
			local BindText = "[" .. Get_Input_Name(Key) .. "]"
			local BindWidth = GetTextWidth(BindText, 10, Bold_Font)
			Count = Count + 1
			local Kb_Item = Instance.new("Frame")
			Kb_Item.Size = UDim2.new(1, 0, 0, 20)
			Kb_Item.BackgroundColor3 = Hub_Colors.elementBackground
			Kb_Item.BackgroundTransparency = 0.4
			Kb_Item.Parent = Kb_Container

			local Item_Corner = Instance.new("UICorner")
			Item_Corner.CornerRadius = UDim.new(0, 3)
			Item_Corner.Parent = Kb_Item

			local Item_Stroke = Instance.new("UIStroke")
			Item_Stroke.Color = Hub_Colors.borderColor
			Item_Stroke.Thickness = 1
			Item_Stroke.Parent = Kb_Item

			local Kb_Val = Instance.new("TextLabel")
			Kb_Val.AnchorPoint = Vector2.new(1, 0.5)
			Kb_Val.Size = UDim2.new(0, BindWidth, 1, 0)
			Kb_Val.Position = UDim2.new(1, -7, 0.5, 0)
			Kb_Val.BackgroundTransparency = 1
			Kb_Val.Text = BindText
			Kb_Val.TextColor3 = Hub_Colors.accentColor
			Kb_Val.TextSize = 10
			Kb_Val.Font = Bold_Font
			Kb_Val.TextXAlignment = Enum.TextXAlignment.Right
			Kb_Val.Parent = Kb_Item

			local Kb_Name = Instance.new("TextLabel")
			Kb_Name.Size = UDim2.new(1, -(BindWidth + 18), 1, 0)
			Kb_Name.Position = UDim2.new(0, 7, 0, 0)
			Kb_Name.BackgroundTransparency = 1
			Kb_Name.Text = Name
			Kb_Name.TextColor3 = Hub_Colors.textWhiteColor
			Kb_Name.TextSize = 10
			Kb_Name.Font = Main_Font
			Kb_Name.TextXAlignment = Enum.TextXAlignment.Left
			Kb_Name.TextTruncate = Enum.TextTruncate.AtEnd
			Kb_Name.Parent = Kb_Item
		end
	end
	Animate_Element(Keybinds_Frame, {Size = UDim2.new(0, 210, 0, 40 + (Count * 26))}, 0.2)
end

local function Show_Tooltip(Text_String)
	if User_Input_Service.TouchEnabled and not User_Input_Service.MouseEnabled then return end
	if not Text_String or Text_String == "" then
		Tooltip_Target_Text = ""
		return
	end
	local Text_Bounds = Text_Service:GetTextSize(Text_String, 11, Main_Font, Vector2.new(500, 22))
	Tooltip_Frame.Size = UDim2.new(0, Text_Bounds.X + 14, 0, 22)
	Tooltip_Text.Text = Text_String
	Tooltip_Target_Text = Text_String
end

local function Snap_Value(Value, Step)
	if not Step then return Value end
	return math.floor((Value / Step) + 0.5) * Step
end

local function Format_Value(Value, Step)
	if Step and Step < 1 then
		local Decimal_Places = tostring(Step):len() - 2
		return string.format("%." .. Decimal_Places .. "f", Value)
	end
	return tostring(Value)
end

Run_Service.RenderStepped:Connect(function()
	if Tooltip_Target_Text ~= "" then
		local Mouse_Loc = User_Input_Service:GetMouseLocation()
		Tooltip_Frame.Position = UDim2.new(0, Mouse_Loc.X + 14, 0, Mouse_Loc.Y + 14)
		if not Tooltip_Frame.Visible then
			Tooltip_Frame.Visible = true
			Animate_Element(Tooltip_Frame, {BackgroundTransparency = 0.1}, 0.2)
			Animate_Element(Tooltip_Stroke, {Transparency = 0}, 0.2)
			Animate_Element(Tooltip_Text, {TextTransparency = 0}, 0.2)
		end
	else
		Animate_Element(Tooltip_Frame, {BackgroundTransparency = 1}, 0.12)
		Animate_Element(Tooltip_Stroke, {Transparency = 1}, 0.12)
		Animate_Element(Tooltip_Text, {TextTransparency = 1}, 0.12)
		task.delay(0.12, function()
			if Tooltip_Target_Text == "" then
				Tooltip_Frame.Visible = false
			end
		end)
	end
end)

function Library_Api:Notify(Config)
	local Title = Config.Title or "Notification"
	local Text = Config.Text or ""
	local Duration = Config.Duration or 3
	local Notification_Type = Config.Type or "Info"
	local Accent_Color = Hub_Colors["notification" .. Notification_Type .. "Color"] or Hub_Colors.accentColor

	local Notification_Frame = Instance.new("Frame")
	Notification_Frame.Size = UDim2.new(1, 0, 0, 48)
	Notification_Frame.Position = UDim2.new(1, 260, 0, 0)
	Notification_Frame.BackgroundColor3 = Hub_Colors.sectionBackground
	Notification_Frame.BackgroundTransparency = 0.04
	Notification_Frame.ZIndex = 1501
	Notification_Frame.Parent = Notification_Container

	local Notification_Corner = Instance.new("UICorner")
	Notification_Corner.CornerRadius = UDim.new(0, 4)
	Notification_Corner.Parent = Notification_Frame

	local Notification_Stroke = Instance.new("UIStroke")
	Notification_Stroke.Color = Hub_Colors.borderColor
	Notification_Stroke.Thickness = 1
	Notification_Stroke.Parent = Notification_Frame

	local Line_Frame = Instance.new("Frame")
	Line_Frame.Size = UDim2.new(0, 2, 1, -14)
	Line_Frame.Position = UDim2.new(0, 7, 0, 7)
	Line_Frame.BackgroundColor3 = Accent_Color
	Line_Frame.BorderSizePixel = 0
	Line_Frame.ZIndex = 1502
	Line_Frame.Parent = Notification_Frame

	local Line_Corner = Instance.new("UICorner")
	Line_Corner.CornerRadius = UDim.new(0, 2)
	Line_Corner.Parent = Line_Frame

	local Title_Label = Instance.new("TextLabel")
	Title_Label.Size = UDim2.new(1, -22, 0, 13)
	Title_Label.Position = UDim2.new(0, 15, 0, 7)
	Title_Label.BackgroundTransparency = 1
	Title_Label.Text = Title
	Title_Label.TextColor3 = Hub_Colors.textWhiteColor
	Title_Label.TextSize = 11
	Title_Label.Font = Bold_Font
	Title_Label.TextXAlignment = Enum.TextXAlignment.Left
	Title_Label.ZIndex = 1502
	Title_Label.Parent = Notification_Frame

	local Text_Label = Instance.new("TextLabel")
	Text_Label.Size = UDim2.new(1, -22, 0, 18)
	Text_Label.Position = UDim2.new(0, 15, 0, 22)
	Text_Label.BackgroundTransparency = 1
	Text_Label.Text = Text
	Text_Label.TextColor3 = Hub_Colors.textDarkColor
	Text_Label.TextSize = 10
	Text_Label.Font = Main_Font
	Text_Label.TextXAlignment = Enum.TextXAlignment.Left
	Text_Label.TextWrapped = true
	Text_Label.ZIndex = 1502
	Text_Label.Parent = Notification_Frame

	Animate_Element(Notification_Frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)

	task.delay(Duration, function()
		local Hide_Tween = Animate_Element(Notification_Frame, {Position = UDim2.new(1, 260, 0, 0)}, 0.3)
		Hide_Tween.Completed:Connect(function()
			Notification_Frame:Destroy()
		end)
	end)
end

function Library_Api:CreateWindow(Window_Name)
	local Main_Background = Instance.new("Frame")
	Main_Background.Size = UDim2.new(0, 720, 0, 480)
	Main_Background.Position = Library_Api.Saved_Positions.Menu or UDim2.new(0.5, -360, 0.5, -240)
	Main_Background.BackgroundColor3 = Hub_Colors.mainBackground
	Main_Background.BackgroundTransparency = 0.15
	Main_Background.BorderSizePixel = 0
	Main_Background.Active = true
	Main_Background.Parent = Screen_Gui
	Library_Api.Instances.Menu = Main_Background

	local Ui_Scale_Modifier = Instance.new("UIScale")
	Ui_Scale_Modifier.Parent = Main_Background

	local Main_Corner = Instance.new("UICorner")
	Main_Corner.CornerRadius = UDim.new(0, 6)
	Main_Corner.Parent = Main_Background

	local Main_Stroke = Instance.new("UIStroke")
	Main_Stroke.Color = Hub_Colors.borderColor
	Main_Stroke.Thickness = 1
	Main_Stroke.Parent = Main_Background

	Apply_Acrylic_Effect(Main_Background, 0.88, UDim.new(0, 6))

	local Top_Bar = Instance.new("Frame")
	Top_Bar.Size = UDim2.new(1, 0, 0, 36)
	Top_Bar.BackgroundColor3 = Hub_Colors.sidebarBackground
	Top_Bar.BackgroundTransparency = 0.18
	Top_Bar.BorderSizePixel = 0
	Top_Bar.Parent = Main_Background

	local Top_Corner = Instance.new("UICorner")
	Top_Corner.CornerRadius = UDim.new(0, 6)
	Top_Corner.Parent = Top_Bar

	local Top_Hider = Instance.new("Frame")
	Top_Hider.Size = UDim2.new(1, 0, 0, 6)
	Top_Hider.Position = UDim2.new(0, 0, 1, -6)
	Top_Hider.BackgroundColor3 = Hub_Colors.sidebarBackground
	Top_Hider.BackgroundTransparency = 0.18
	Top_Hider.BorderSizePixel = 0
	Top_Hider.Parent = Top_Bar

	local Accent_Line = Instance.new("Frame")
	Accent_Line.Size = UDim2.new(1, 0, 0, 1)
	Accent_Line.BackgroundColor3 = Color3.new(1, 1, 1)
	Accent_Line.BorderSizePixel = 0
	Accent_Line.BackgroundTransparency = 0
	Accent_Line.Parent = Top_Bar

	local Accent_Corner = Instance.new("UICorner")
	Accent_Corner.CornerRadius = UDim.new(0, 6)
	Accent_Corner.Parent = Accent_Line

	local Accent_Gradient = Instance.new("UIGradient")
	Accent_Gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(0.08, Hub_Colors.accentGradientColor1),
		ColorSequenceKeypoint.new(0.5, Hub_Colors.accentGradientColor2),
		ColorSequenceKeypoint.new(0.92, Hub_Colors.accentGradientColor1),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	}
	Accent_Gradient.Parent = Accent_Line

	local Top_Border = Instance.new("Frame")
	Top_Border.Size = UDim2.new(1, 0, 0, 1)
	Top_Border.Position = UDim2.new(0, 0, 1, 0)
	Top_Border.BackgroundColor3 = Hub_Colors.borderColor
	Top_Border.BorderSizePixel = 0
	Top_Border.Parent = Top_Bar

	local Title_Label = Instance.new("TextLabel")
	Title_Label.Size = UDim2.new(1, -20, 1, -2)
	Title_Label.Position = UDim2.new(0, 15, 0, 2)
	Title_Label.BackgroundTransparency = 1
	Title_Label.Text = Window_Name
	Title_Label.TextColor3 = Hub_Colors.textWhiteColor
	Title_Label.TextSize = 12
	Title_Label.Font = Bold_Font
	Title_Label.TextXAlignment = Enum.TextXAlignment.Left
	Title_Label.Parent = Top_Bar

	local Sidebar_Width = 135
	local Sidebar_Frame = Instance.new("Frame")
	Sidebar_Frame.Size = UDim2.new(0, Sidebar_Width, 1, -37)
	Sidebar_Frame.Position = UDim2.new(0, 0, 0, 37)
	Sidebar_Frame.BackgroundColor3 = Hub_Colors.sidebarBackground
	Sidebar_Frame.BackgroundTransparency = 0.18
	Sidebar_Frame.BorderSizePixel = 0
	Sidebar_Frame.Parent = Main_Background

	local Sidebar_Corner = Instance.new("UICorner")
	Sidebar_Corner.CornerRadius = UDim.new(0, 6)
	Sidebar_Corner.Parent = Sidebar_Frame

	local Sidebar_Hider_Right = Instance.new("Frame")
	Sidebar_Hider_Right.Size = UDim2.new(0, 6, 1, 0)
	Sidebar_Hider_Right.Position = UDim2.new(1, -6, 0, 0)
	Sidebar_Hider_Right.BackgroundColor3 = Hub_Colors.sidebarBackground
	Sidebar_Hider_Right.BackgroundTransparency = 0.18
	Sidebar_Hider_Right.BorderSizePixel = 0
	Sidebar_Hider_Right.Parent = Sidebar_Frame

	local Sidebar_Hider_Top = Instance.new("Frame")
	Sidebar_Hider_Top.Size = UDim2.new(1, 0, 0, 6)
	Sidebar_Hider_Top.BackgroundColor3 = Hub_Colors.sidebarBackground
	Sidebar_Hider_Top.BackgroundTransparency = 0.18
	Sidebar_Hider_Top.BorderSizePixel = 0
	Sidebar_Hider_Top.Parent = Sidebar_Frame

	local Sidebar_Border = Instance.new("Frame")
	Sidebar_Border.Size = UDim2.new(0, 1, 1, 0)
	Sidebar_Border.Position = UDim2.new(1, 0, 0, 0)
	Sidebar_Border.BackgroundColor3 = Hub_Colors.borderColor
	Sidebar_Border.BorderSizePixel = 0
	Sidebar_Border.Parent = Sidebar_Frame

	local Tab_Scrolling_Frame = Instance.new("ScrollingFrame")
	Tab_Scrolling_Frame.Size = UDim2.new(1, -10, 1, -58)
	Tab_Scrolling_Frame.Position = UDim2.new(0, 5, 0, 5)
	Tab_Scrolling_Frame.BackgroundTransparency = 1
	Tab_Scrolling_Frame.BorderSizePixel = 0
	Tab_Scrolling_Frame.ScrollBarThickness = 0
	Tab_Scrolling_Frame.Active = true
	Tab_Scrolling_Frame.Parent = Sidebar_Frame

	local Tab_Layout = Instance.new("UIListLayout")
	Tab_Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Tab_Layout.Padding = UDim.new(0, 3)
	Tab_Layout.Parent = Tab_Scrolling_Frame

	local Profile_Button = Instance.new("TextButton")
	Profile_Button.Size = UDim2.new(1, -10, 0, 44)
	Profile_Button.Position = UDim2.new(0, 5, 1, -49)
	Profile_Button.BackgroundColor3 = Hub_Colors.elementBackground
	Profile_Button.BackgroundTransparency = 1
	Profile_Button.Text = ""
	Profile_Button.AutoButtonColor = false
	Profile_Button.Parent = Sidebar_Frame

	local Profile_Corner = Instance.new("UICorner")
	Profile_Corner.CornerRadius = UDim.new(0, 5)
	Profile_Corner.Parent = Profile_Button

	local Avatar_Img = Instance.new("ImageLabel")
	Avatar_Img.Size = UDim2.new(0, 24, 0, 24)
	Avatar_Img.Position = UDim2.new(0, 8, 0.5, -12)
	Avatar_Img.BackgroundTransparency = 1
	Avatar_Img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Local_Player.UserId .. "&w=48&h=48"
	Avatar_Img.Parent = Profile_Button

	local Av_Corner = Instance.new("UICorner")
	Av_Corner.CornerRadius = UDim.new(1, 0)
	Av_Corner.Parent = Avatar_Img

	local Av_Stroke = Instance.new("UIStroke")
	Av_Stroke.Color = Hub_Colors.accentColor
	Av_Stroke.Thickness = 1
	Av_Stroke.Parent = Avatar_Img

	local Profile_Name_Label = Instance.new("TextLabel")
	Profile_Name_Label.Size = UDim2.new(1, -40, 0, 13)
	Profile_Name_Label.Position = UDim2.new(0, 38, 0, 8)
	Profile_Name_Label.BackgroundTransparency = 1
	Profile_Name_Label.Text = Local_Player.DisplayName
	Profile_Name_Label.TextColor3 = Hub_Colors.textWhiteColor
	Profile_Name_Label.TextSize = 10
	Profile_Name_Label.Font = Bold_Font
	Profile_Name_Label.TextXAlignment = Enum.TextXAlignment.Left
	Profile_Name_Label.TextTruncate = Enum.TextTruncate.AtEnd
	Profile_Name_Label.Parent = Profile_Button

	local Profile_Sub_Label = Instance.new("TextLabel")
	Profile_Sub_Label.Size = UDim2.new(1, -40, 0, 11)
	Profile_Sub_Label.Position = UDim2.new(0, 38, 0, 22)
	Profile_Sub_Label.BackgroundTransparency = 1
	Profile_Sub_Label.Text = "Settings"
	Profile_Sub_Label.TextColor3 = Hub_Colors.textDarkColor
	Profile_Sub_Label.TextSize = 9
	Profile_Sub_Label.Font = Main_Font
	Profile_Sub_Label.TextXAlignment = Enum.TextXAlignment.Left
	Profile_Sub_Label.Parent = Profile_Button

	local Content_Area_Frame = Instance.new("Frame")
	Content_Area_Frame.Size = UDim2.new(1, -(Sidebar_Width + 1), 1, -37)
	Content_Area_Frame.Position = UDim2.new(0, Sidebar_Width + 1, 0, 37)
	Content_Area_Frame.BackgroundTransparency = 1
	Content_Area_Frame.Parent = Main_Background

	local Mobile_Toggle_Button = Instance.new("ImageButton")
	Mobile_Toggle_Button.Size = UDim2.new(0, 44, 0, 44)
	Mobile_Toggle_Button.Position = UDim2.new(0, 16, 0.5, -22)
	Mobile_Toggle_Button.BackgroundColor3 = Hub_Colors.mainBackground
	Mobile_Toggle_Button.BorderSizePixel = 0
	Mobile_Toggle_Button.ZIndex = 1000
	Mobile_Toggle_Button.Visible = true
	Mobile_Toggle_Button.Image = "rbxassetid://131244616689186"
	Mobile_Toggle_Button.Parent = Screen_Gui

	local Mobile_Toggle_Corner = Instance.new("UICorner")
	Mobile_Toggle_Corner.CornerRadius = UDim.new(1, 0)
	Mobile_Toggle_Corner.Parent = Mobile_Toggle_Button

	local Mobile_Toggle_Stroke = Instance.new("UIStroke")
	Mobile_Toggle_Stroke.Color = Hub_Colors.accentColor
	Mobile_Toggle_Stroke.Thickness = 1
	Mobile_Toggle_Stroke.Parent = Mobile_Toggle_Button

	local Toggle_Dragging = false
	local Toggle_Drag_Input = nil
	local Toggle_Drag_Start = nil
	local Toggle_Start_Pos = nil
	local Toggle_Target_Pos = Mobile_Toggle_Button.Position

	Mobile_Toggle_Button.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Toggle_Dragging = true
			Toggle_Drag_Start = Input.Position
			Toggle_Start_Pos = Mobile_Toggle_Button.Position
			Toggle_Target_Pos = Toggle_Start_Pos
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then Toggle_Dragging = false end
			end)
		end
	end)

	Mobile_Toggle_Button.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			Toggle_Drag_Input = Input
		end
	end)

	User_Input_Service.InputChanged:Connect(function(Input)
		if Input == Toggle_Drag_Input and Toggle_Dragging then
			local Delta = Input.Position - Toggle_Drag_Start
			Toggle_Target_Pos = UDim2.new(Toggle_Start_Pos.X.Scale, Toggle_Start_Pos.X.Offset + Delta.X, Toggle_Start_Pos.Y.Scale, Toggle_Start_Pos.Y.Offset + Delta.Y)
		end
	end)

	Run_Service.RenderStepped:Connect(function()
		Mobile_Toggle_Button.Position = Mobile_Toggle_Button.Position:Lerp(Toggle_Target_Pos, 0.35)
	end)

	local Toggle_Click_Time = 0
	Mobile_Toggle_Button.MouseButton1Down:Connect(function()
		Toggle_Click_Time = tick()
		Animate_Element(Mobile_Toggle_Button, {Size = UDim2.new(0, 38, 0, 38)}, 0.2)
	end)

	Mobile_Toggle_Button.MouseButton1Up:Connect(function()
		Animate_Element(Mobile_Toggle_Button, {Size = UDim2.new(0, 44, 0, 44)}, 0.2)
		if tick() - Toggle_Click_Time < 0.2 then
			Main_Background.Visible = not Main_Background.Visible
		end
	end)

	local function Update_Responsive_Scale()
		local Vp = Workspace_Service.CurrentCamera.ViewportSize
		if Vp.X < 1 or Vp.Y < 1 then
			Ui_Scale_Modifier.Scale = 1
			return
		end
		local Is_Mobile = User_Input_Service.TouchEnabled and not User_Input_Service.MouseEnabled
		if Is_Mobile then
			local scaleX = (Vp.X - 12) / 720
			local scaleY = (Vp.Y - 90) / 480
			local scale = math.min(scaleX, scaleY)
			Ui_Scale_Modifier.Scale = math.clamp(scale, 0.32, 0.78)
			if not Library_Api.Saved_Positions.Menu then
				local scaledW = 720 * Ui_Scale_Modifier.Scale
				local scaledH = 480 * Ui_Scale_Modifier.Scale
				Main_Background.Position = UDim2.new(0, (Vp.X - scaledW) / 2, 0, (Vp.Y - scaledH) / 2)
				Library_Api.Instances.MenuTargetPos = Main_Background.Position
			end
		else
			local Scale_X = Vp.X / 800
			local Scale_Y = Vp.Y / 500
			local Scale = math.min(Scale_X, Scale_Y)
			Ui_Scale_Modifier.Scale = math.clamp(Scale * 0.94, 0.42, 1)
		end
	end

	Workspace_Service.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Update_Responsive_Scale)
	Update_Responsive_Scale()

	local Main_Dragging = false
	local Main_Drag_Input = nil
	local Main_Drag_Start = nil
	local Main_Start_Pos = nil
	Library_Api.Instances.MenuTargetPos = Main_Background.Position

	Top_Bar.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Main_Dragging = true
			Main_Drag_Start = Input.Position
			Main_Start_Pos = Main_Background.Position
			Library_Api.Instances.MenuTargetPos = Main_Start_Pos
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then Main_Dragging = false end
			end)
		end
	end)

	Top_Bar.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			Main_Drag_Input = Input
		end
	end)

	User_Input_Service.InputChanged:Connect(function(Input)
		if Input == Main_Drag_Input and Main_Dragging then
			local Delta = Input.Position - Main_Drag_Start
			Library_Api.Instances.MenuTargetPos = UDim2.new(Main_Start_Pos.X.Scale, Main_Start_Pos.X.Offset + (Delta.X / Ui_Scale_Modifier.Scale), Main_Start_Pos.Y.Scale, Main_Start_Pos.Y.Offset + (Delta.Y / Ui_Scale_Modifier.Scale))
			Auto_Save()
		end
	end)

	Run_Service.RenderStepped:Connect(function()
		if Main_Background.Visible then
			Main_Background.Position = Main_Background.Position:Lerp(Library_Api.Instances.MenuTargetPos, 0.35)
		end
	end)

	local Window_Context = {Tabs = {}, Active_Tab = nil}

	function Window_Context:Tab_Create(Tab_Name, Icon_Id)
		local Tab_Data = {}

		local Tab_Button = Instance.new("TextButton")
		Tab_Button.Size = UDim2.new(1, 0, 0, 28)
		Tab_Button.BackgroundColor3 = Hub_Colors.elementBackground
		Tab_Button.BackgroundTransparency = 1
		Tab_Button.Text = ""
		Tab_Button.AutoButtonColor = false
		Tab_Button.Parent = Tab_Scrolling_Frame

		local Button_Corner = Instance.new("UICorner")
		Button_Corner.CornerRadius = UDim.new(0, 4)
		Button_Corner.Parent = Tab_Button

		local Tab_Label = Instance.new("TextLabel")
		Tab_Label.BackgroundTransparency = 1
		Tab_Label.Text = Tab_Name
		Tab_Label.TextColor3 = Hub_Colors.textDarkColor
		Tab_Label.TextSize = 11
		Tab_Label.Font = Main_Font
		Tab_Label.TextXAlignment = Enum.TextXAlignment.Left
		Tab_Label.TextTruncate = Enum.TextTruncate.AtEnd
		Tab_Label.Parent = Tab_Button

		if Icon_Id and Icon_Id ~= "" then
			local Tab_Icon = Instance.new("ImageLabel")
			Tab_Icon.Size = UDim2.new(0, 13, 0, 13)
			Tab_Icon.Position = UDim2.new(0, 10, 0.5, -6)
			Tab_Icon.BackgroundTransparency = 1
			Tab_Icon.Image = Icon_Id
			Tab_Icon.ImageColor3 = Hub_Colors.textDarkColor
			Tab_Icon.Parent = Tab_Button
			Tab_Data.Icon = Tab_Icon
			Tab_Label.Position = UDim2.new(0, 30, 0, 0)
			Tab_Label.Size = UDim2.new(1, -36, 1, 0)
		else
			Tab_Label.Position = UDim2.new(0, 10, 0, 0)
			Tab_Label.Size = UDim2.new(1, -16, 1, 0)
		end

		local Tab_Indicator = Instance.new("Frame")
		Tab_Indicator.Size = UDim2.new(0, 2, 0, 0)
		Tab_Indicator.Position = UDim2.new(0, 0, 0.5, 0)
		Tab_Indicator.BackgroundColor3 = Hub_Colors.accentColor
		Tab_Indicator.BorderSizePixel = 0
		Tab_Indicator.Parent = Tab_Button

		local Indicator_Corner = Instance.new("UICorner")
		Indicator_Corner.CornerRadius = UDim.new(0, 2)
		Indicator_Corner.Parent = Tab_Indicator

		local Page_Scrolling_Frame = Instance.new("ScrollingFrame")
		Page_Scrolling_Frame.Size = UDim2.new(1, 0, 1, 0)
		Page_Scrolling_Frame.BackgroundTransparency = 1
		Page_Scrolling_Frame.BorderSizePixel = 0
		Page_Scrolling_Frame.ScrollBarThickness = 2
		Page_Scrolling_Frame.ScrollBarImageColor3 = Hub_Colors.accentColor
		Page_Scrolling_Frame.Active = true
		Page_Scrolling_Frame.Visible = false
		Page_Scrolling_Frame.Parent = Content_Area_Frame

		local Left_Column_Frame = Instance.new("Frame")
		Left_Column_Frame.Size = UDim2.new(0.5, -12, 1, 0)
		Left_Column_Frame.Position = UDim2.new(0, 8, 0, 8)
		Left_Column_Frame.BackgroundTransparency = 1
		Left_Column_Frame.Parent = Page_Scrolling_Frame

		local Right_Column_Frame = Instance.new("Frame")
		Right_Column_Frame.Size = UDim2.new(0.5, -12, 1, 0)
		Right_Column_Frame.Position = UDim2.new(0.5, 4, 0, 8)
		Right_Column_Frame.BackgroundTransparency = 1
		Right_Column_Frame.Parent = Page_Scrolling_Frame

		local Left_Column_Layout = Instance.new("UIListLayout")
		Left_Column_Layout.Padding = UDim.new(0, 7)
		Left_Column_Layout.Parent = Left_Column_Frame

		local Right_Column_Layout = Instance.new("UIListLayout")
		Right_Column_Layout.Padding = UDim.new(0, 7)
		Right_Column_Layout.Parent = Right_Column_Frame

		local function Update_Canvas()
			local Max_Column_Height = math.max(Left_Column_Layout.AbsoluteContentSize.Y, Right_Column_Layout.AbsoluteContentSize.Y)
			Animate_Element(Page_Scrolling_Frame, {CanvasSize = UDim2.new(0, 0, 0, Max_Column_Height + 16)}, 0.2)
		end

		Left_Column_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Canvas)
		Right_Column_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Canvas)

		Tab_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Animate_Element(Tab_Scrolling_Frame, {CanvasSize = UDim2.new(0, 0, 0, Tab_Layout.AbsoluteContentSize.Y + 10)}, 0.2)
		end)

		function Tab_Data:Activate()
			if Window_Context.Active_Tab == Tab_Data then return end
			if Window_Context.Active_Tab then
				Animate_Element(Window_Context.Active_Tab.Btn, {BackgroundTransparency = 1}, 0.2)
				Animate_Element(Window_Context.Active_Tab.Lbl, {TextColor3 = Hub_Colors.textDarkColor}, 0.2)
				if Window_Context.Active_Tab.Icon then Animate_Element(Window_Context.Active_Tab.Icon, {ImageColor3 = Hub_Colors.textDarkColor}, 0.2) end
				Animate_Element(Window_Context.Active_Tab.Ind, {Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.2)
				Window_Context.Active_Tab.Page.Visible = false
			end
			if Tab_Name ~= "Settings" then
				Animate_Element(Profile_Button, {BackgroundTransparency = 1}, 0.2)
			end
			Window_Context.Active_Tab = Tab_Data
			Page_Scrolling_Frame.Visible = true
			Animate_Element(Tab_Button, {BackgroundTransparency = 0.12}, 0.2)
			Animate_Element(Tab_Label, {TextColor3 = Hub_Colors.textWhiteColor}, 0.2)
			if Tab_Data.Icon then Animate_Element(Tab_Data.Icon, {ImageColor3 = Hub_Colors.accentColor}, 0.2) end
			Animate_Element(Tab_Indicator, {Size = UDim2.new(0, 2, 0, 14), Position = UDim2.new(0, 0, 0.5, -7)}, 0.2)
		end

		Tab_Button.MouseButton1Click:Connect(function() Tab_Data:Activate() end)

		Tab_Data.Btn = Tab_Button
		Tab_Data.Lbl = Tab_Label
		Tab_Data.Ind = Tab_Indicator
		Tab_Data.Page = Page_Scrolling_Frame

		table.insert(Window_Context.Tabs, Tab_Data)
		if #Window_Context.Tabs == 1 then Tab_Data:Activate() end

		local function Element_Injector(Target_Container)
			local Elements = {}

			function Elements:Label_Create(Name, Initial_Value)
				local Label_Bg = Instance.new("Frame")
				Label_Bg.Size = UDim2.new(1, 0, 0, 22)
				Label_Bg.BackgroundColor3 = Hub_Colors.elementBackground
				Label_Bg.BackgroundTransparency = 0.18
				Label_Bg.Parent = Target_Container

				local Label_Corner = Instance.new("UICorner")
				Label_Corner.CornerRadius = UDim.new(0, 4)
				Label_Corner.Parent = Label_Bg

				local Label_Stroke = Instance.new("UIStroke")
				Label_Stroke.Color = Hub_Colors.borderColor
				Label_Stroke.Thickness = 1
				Label_Stroke.Parent = Label_Bg

				local titleWidth = GetTextWidth(Name, 11, Main_Font)
				titleWidth = math.clamp(titleWidth + 10, 50, 160)

				local Title_Label = Instance.new("TextLabel")
				Title_Label.Size = UDim2.new(0, titleWidth, 1, 0)
				Title_Label.Position = UDim2.new(0, 8, 0, 0)
				Title_Label.BackgroundTransparency = 1
				Title_Label.Text = Name
				Title_Label.TextColor3 = Hub_Colors.textDarkColor
				Title_Label.TextSize = 11
				Title_Label.Font = Main_Font
				Title_Label.TextXAlignment = Enum.TextXAlignment.Left
				Title_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Title_Label.Parent = Label_Bg

				local Value_Label = Instance.new("TextLabel")
				Value_Label.AnchorPoint = Vector2.new(1, 0)
				Value_Label.Size = UDim2.new(1, -(titleWidth + 20), 1, 0)
				Value_Label.Position = UDim2.new(1, -8, 0, 0)
				Value_Label.BackgroundTransparency = 1
				Value_Label.Text = Initial_Value or ""
				Value_Label.TextColor3 = Hub_Colors.textWhiteColor
				Value_Label.TextSize = 11
				Value_Label.Font = Bold_Font
				Value_Label.TextXAlignment = Enum.TextXAlignment.Right
				Value_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Value_Label.Parent = Label_Bg

				local Api = {}
				function Api:Set(Text)
					Value_Label.Text = tostring(Text)
				end
				return Api
			end

			function Elements:Subtext_Create(Text)
				local Subtext_Label = Instance.new("TextLabel")
				Subtext_Label.Size = UDim2.new(1, -10, 0, 13)
				Subtext_Label.BackgroundTransparency = 1
				Subtext_Label.Text = Text
				Subtext_Label.TextColor3 = Hub_Colors.textDarkColor
				Subtext_Label.TextSize = 10
				Subtext_Label.Font = Main_Font
				Subtext_Label.TextXAlignment = Enum.TextXAlignment.Left
				Subtext_Label.TextWrapped = true
				Subtext_Label.Parent = Target_Container
			end

			function Elements:Toggle_Create(Name, Flag, Default, Tooltip, Callback)
				Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or false)

				local Toggle_Button = Instance.new("TextButton")
				Toggle_Button.Size = UDim2.new(1, 0, 0, 16)
				Toggle_Button.BackgroundTransparency = 1
				Toggle_Button.Text = ""
				Toggle_Button.Parent = Target_Container

				local Checkbox_Frame = Instance.new("Frame")
				Checkbox_Frame.Size = UDim2.new(0, 13, 0, 13)
				Checkbox_Frame.Position = UDim2.new(0, 2, 0.5, -6)
				Checkbox_Frame.BackgroundColor3 = Hub_Colors.elementBackground
				Checkbox_Frame.BackgroundTransparency = 0.18
				Checkbox_Frame.Parent = Toggle_Button

				local Checkbox_Corner = Instance.new("UICorner")
				Checkbox_Corner.CornerRadius = UDim.new(0, 3)
				Checkbox_Corner.Parent = Checkbox_Frame

				local Checkbox_Stroke = Instance.new("UIStroke")
				Checkbox_Stroke.Color = Hub_Colors.borderColor
				Checkbox_Stroke.Thickness = 1
				Checkbox_Stroke.Parent = Checkbox_Frame

				local Toggle_Label = Instance.new("TextLabel")
				Toggle_Label.Size = UDim2.new(1, -24, 1, 0)
				Toggle_Label.Position = UDim2.new(0, 22, 0, 0)
				Toggle_Label.BackgroundTransparency = 1
				Toggle_Label.Text = Name
				Toggle_Label.TextColor3 = Hub_Colors.textDarkColor
				Toggle_Label.TextSize = 11
				Toggle_Label.Font = Main_Font
				Toggle_Label.TextXAlignment = Enum.TextXAlignment.Left
				Toggle_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Toggle_Label.Parent = Toggle_Button

				Library_Api.Registry[Flag] = function(New_State)
					Animate_Element(Checkbox_Frame, {BackgroundColor3 = New_State and Hub_Colors.accentColor or Hub_Colors.elementBackground}, 0.2)
					Animate_Element(Checkbox_Stroke, {Color = New_State and Hub_Colors.accentColor or Hub_Colors.borderColor}, 0.2)
					Animate_Element(Toggle_Label, {TextColor3 = New_State and Hub_Colors.textWhiteColor or Hub_Colors.textDarkColor}, 0.2)
					if Callback then task.spawn(Callback, New_State) end
				end

				Toggle_Button.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					if not Library_Api.Flags[Flag] then Animate_Element(Checkbox_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15) end
				end)
				Toggle_Button.MouseLeave:Connect(function()
					Show_Tooltip("")
					if not Library_Api.Flags[Flag] then Animate_Element(Checkbox_Stroke, {Color = Hub_Colors.borderColor}, 0.15) end
				end)

				Toggle_Button.MouseButton1Click:Connect(function()
					Library_Api.Flags[Flag] = not Library_Api.Flags[Flag]
					Library_Api.Registry[Flag](Library_Api.Flags[Flag])
					Auto_Save()
				end)

				task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
			end

			function Elements:Slider_Create(Name, Flag, Min, Max, Default, Step, Tooltip, Callback)
				Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or Snap_Value(Default or Min, Step)

				local Slider_Frame = Instance.new("Frame")
				Slider_Frame.Size = UDim2.new(1, 0, 0, 30)
				Slider_Frame.BackgroundTransparency = 1
				Slider_Frame.Parent = Target_Container

				local Slider_Label = Instance.new("TextLabel")
				Slider_Label.Size = UDim2.new(1, -60, 0, 13)
				Slider_Label.Position = UDim2.new(0, 2, 0, 0)
				Slider_Label.BackgroundTransparency = 1
				Slider_Label.Text = Name
				Slider_Label.TextColor3 = Hub_Colors.textWhiteColor
				Slider_Label.TextSize = 11
				Slider_Label.Font = Main_Font
				Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
				Slider_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Slider_Label.Parent = Slider_Frame

				local Value_Text_Box = Instance.new("TextBox")
				Value_Text_Box.AnchorPoint = Vector2.new(1, 0)
				Value_Text_Box.Size = UDim2.new(0, 50, 0, 13)
				Value_Text_Box.Position = UDim2.new(1, -4, 0, 0)
				Value_Text_Box.BackgroundTransparency = 1
				Value_Text_Box.Text = Format_Value(Library_Api.Flags[Flag], Step)
				Value_Text_Box.TextColor3 = Hub_Colors.textWhiteColor
				Value_Text_Box.TextSize = 11
				Value_Text_Box.Font = Main_Font
				Value_Text_Box.TextXAlignment = Enum.TextXAlignment.Right
				Value_Text_Box.ClearTextOnFocus = false
				Value_Text_Box.Parent = Slider_Frame

				local function UpdateValSize(text)
					local w = GetTextWidth(text, 11, Main_Font)
					w = math.max(28, w + 10)
					Value_Text_Box.Size = UDim2.new(0, w, 0, 13)
					Slider_Label.Size = UDim2.new(1, -(w + 14), 0, 13)
				end

				local Slider_Background = Instance.new("TextButton")
				Slider_Background.Size = UDim2.new(1, -4, 0, 5)
				Slider_Background.Position = UDim2.new(0, 2, 0, 20)
				Slider_Background.BackgroundColor3 = Hub_Colors.elementBackground
				Slider_Background.BackgroundTransparency = 0.18
				Slider_Background.Text = ""
				Slider_Background.AutoButtonColor = false
				Slider_Background.Parent = Slider_Frame

				local Slider_Background_Corner = Instance.new("UICorner")
				Slider_Background_Corner.CornerRadius = UDim.new(0, 3)
				Slider_Background_Corner.Parent = Slider_Background

				local Slider_Background_Stroke = Instance.new("UIStroke")
				Slider_Background_Stroke.Color = Hub_Colors.borderColor
				Slider_Background_Stroke.Thickness = 1
				Slider_Background_Stroke.Parent = Slider_Background

				local Slider_Fill = Instance.new("Frame")
				Slider_Fill.Size = UDim2.new(0, 0, 1, 0)
				Slider_Fill.BackgroundColor3 = Hub_Colors.accentColor
				Slider_Fill.Parent = Slider_Background

				local Slider_Fill_Corner = Instance.new("UICorner")
				Slider_Fill_Corner.CornerRadius = UDim.new(0, 3)
				Slider_Fill_Corner.Parent = Slider_Fill

				local Slider_Knob = Instance.new("Frame")
				Slider_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
				Slider_Knob.Size = UDim2.new(0, 9, 0, 9)
				Slider_Knob.BackgroundColor3 = Hub_Colors.textWhiteColor
				Slider_Knob.ZIndex = 2
				Slider_Knob.Parent = Slider_Background
				local Slider_Knob_Corner = Instance.new("UICorner"); Slider_Knob_Corner.CornerRadius = UDim.new(1, 0); Slider_Knob_Corner.Parent = Slider_Knob
				local Slider_Knob_Stroke = Instance.new("UIStroke"); Slider_Knob_Stroke.Color = Hub_Colors.borderColor; Slider_Knob_Stroke.Thickness = 1; Slider_Knob_Stroke.Parent = Slider_Knob

				Library_Api.Registry[Flag] = function(New_Value)
					local Clamped_Value = math.clamp(New_Value, Min, Max)
					local Snapped_Value = Snap_Value(Clamped_Value, Step)
					Library_Api.Flags[Flag] = Snapped_Value
					local Denominator = Max - Min
					if Denominator == 0 then Denominator = 1 end
					local Percentage = (Snapped_Value - Min) / Denominator
					local formatStr = Format_Value(Snapped_Value, Step)
					Animate_Element(Slider_Fill, {Size = UDim2.new(Percentage, 0, 1, 0)}, 0.12)
					Animate_Element(Slider_Knob, {Position = UDim2.new(Percentage, 0, 0.5, 0)}, 0.12)
					Value_Text_Box.Text = formatStr
					UpdateValSize(formatStr)
					if Callback then task.spawn(Callback, Snapped_Value) end
				end

				Slider_Background.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					Animate_Element(Slider_Background_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15)
				end)
				Slider_Background.MouseLeave:Connect(function()
					Show_Tooltip("")
					Animate_Element(Slider_Background_Stroke, {Color = Hub_Colors.borderColor}, 0.15)
				end)

				local Is_Sliding = false
				local Slider_Drag_Input = nil

				Slider_Background.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Is_Sliding = true
						local Percentage = math.clamp((Input.Position.X - Slider_Background.AbsolutePosition.X) / Slider_Background.AbsoluteSize.X, 0, 1)
						Library_Api.Registry[Flag](Min + ((Max - Min) * Percentage))
						Input.Changed:Connect(function()
							if Input.UserInputState == Enum.UserInputState.End then
								Is_Sliding = false
								Auto_Save()
							end
						end)
					end
				end)

				Slider_Background.InputChanged:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
						Slider_Drag_Input = Input
					end
				end)

				User_Input_Service.InputChanged:Connect(function(Input)
					if Input == Slider_Drag_Input and Is_Sliding then
						local Percentage = math.clamp((Input.Position.X - Slider_Background.AbsolutePosition.X) / Slider_Background.AbsoluteSize.X, 0, 1)
						Library_Api.Registry[Flag](Min + ((Max - Min) * Percentage))
					end
				end)

				Value_Text_Box.FocusLost:Connect(function()
					local Input_Value = tonumber(Value_Text_Box.Text)
					if Input_Value then
						Library_Api.Registry[Flag](Input_Value)
						Auto_Save()
					else
						Value_Text_Box.Text = Format_Value(Library_Api.Flags[Flag], Step)
					end
				end)

				task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
			end

			function Elements:RangeSlider_Create(Name, Flag, Min, Max, Default_Min, Default_Max, Step, Tooltip, Callback)
				if not Library_Api.Flags[Flag] then
					Library_Api.Flags[Flag] = {Min = Snap_Value(Default_Min or Min, Step), Max = Snap_Value(Default_Max or Max, Step)}
				end

				local Range_Slider_Frame = Instance.new("Frame")
				Range_Slider_Frame.Size = UDim2.new(1, 0, 0, 30)
				Range_Slider_Frame.BackgroundTransparency = 1
				Range_Slider_Frame.Parent = Target_Container

				local Range_Slider_Label = Instance.new("TextLabel")
				Range_Slider_Label.Size = UDim2.new(1, -110, 0, 13)
				Range_Slider_Label.Position = UDim2.new(0, 2, 0, 0)
				Range_Slider_Label.BackgroundTransparency = 1
				Range_Slider_Label.Text = Name
				Range_Slider_Label.TextColor3 = Hub_Colors.textWhiteColor
				Range_Slider_Label.TextSize = 11
				Range_Slider_Label.Font = Main_Font
				Range_Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
				Range_Slider_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Range_Slider_Label.Parent = Range_Slider_Frame

				local Value_Label = Instance.new("TextLabel")
				Value_Label.AnchorPoint = Vector2.new(1, 0)
				Value_Label.Size = UDim2.new(0, 100, 0, 13)
				Value_Label.Position = UDim2.new(1, -4, 0, 0)
				Value_Label.BackgroundTransparency = 1
				Value_Label.Text = ""
				Value_Label.TextColor3 = Hub_Colors.textWhiteColor
				Value_Label.TextSize = 11
				Value_Label.Font = Main_Font
				Value_Label.TextXAlignment = Enum.TextXAlignment.Right
				Value_Label.Parent = Range_Slider_Frame

				local function UpdateValSize(text)
					local w = GetTextWidth(text, 11, Main_Font)
					w = math.max(60, w + 10)
					Value_Label.Size = UDim2.new(0, w, 0, 13)
					Range_Slider_Label.Size = UDim2.new(1, -(w + 14), 0, 13)
				end

				local Range_Slider_Background = Instance.new("TextButton")
				Range_Slider_Background.Size = UDim2.new(1, -4, 0, 5)
				Range_Slider_Background.Position = UDim2.new(0, 2, 0, 20)
				Range_Slider_Background.BackgroundColor3 = Hub_Colors.elementBackground
				Range_Slider_Background.BackgroundTransparency = 0.18
				Range_Slider_Background.Text = ""
				Range_Slider_Background.AutoButtonColor = false
				Range_Slider_Background.Parent = Range_Slider_Frame

				local Range_Slider_Background_Corner = Instance.new("UICorner")
				Range_Slider_Background_Corner.CornerRadius = UDim.new(0, 3)
				Range_Slider_Background_Corner.Parent = Range_Slider_Background

				local Range_Slider_Background_Stroke = Instance.new("UIStroke")
				Range_Slider_Background_Stroke.Color = Hub_Colors.borderColor
				Range_Slider_Background_Stroke.Thickness = 1
				Range_Slider_Background_Stroke.Parent = Range_Slider_Background

				local Range_Slider_Fill = Instance.new("Frame")
				Range_Slider_Fill.BackgroundColor3 = Hub_Colors.accentColor
				Range_Slider_Fill.Parent = Range_Slider_Background

				local Range_Slider_Fill_Corner = Instance.new("UICorner")
				Range_Slider_Fill_Corner.CornerRadius = UDim.new(0, 3)
				Range_Slider_Fill_Corner.Parent = Range_Slider_Fill

				local Min_Range_Knob = Instance.new("Frame")
				Min_Range_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
				Min_Range_Knob.Size = UDim2.new(0, 9, 0, 9)
				Min_Range_Knob.BackgroundColor3 = Hub_Colors.textWhiteColor
				Min_Range_Knob.ZIndex = 2
				Min_Range_Knob.Parent = Range_Slider_Background
				local Min_Range_Knob_Corner = Instance.new("UICorner"); Min_Range_Knob_Corner.CornerRadius = UDim.new(1, 0); Min_Range_Knob_Corner.Parent = Min_Range_Knob
				local Min_Range_Knob_Stroke = Instance.new("UIStroke"); Min_Range_Knob_Stroke.Color = Hub_Colors.borderColor; Min_Range_Knob_Stroke.Thickness = 1; Min_Range_Knob_Stroke.Parent = Min_Range_Knob

				local Max_Range_Knob = Instance.new("Frame")
				Max_Range_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
				Max_Range_Knob.Size = UDim2.new(0, 9, 0, 9)
				Max_Range_Knob.BackgroundColor3 = Hub_Colors.textWhiteColor
				Max_Range_Knob.ZIndex = 2
				Max_Range_Knob.Parent = Range_Slider_Background
				local Max_Range_Knob_Corner = Instance.new("UICorner"); Max_Range_Knob_Corner.CornerRadius = UDim.new(1, 0); Max_Range_Knob_Corner.Parent = Max_Range_Knob
				local Max_Range_Knob_Stroke = Instance.new("UIStroke"); Max_Range_Knob_Stroke.Color = Hub_Colors.borderColor; Max_Range_Knob_Stroke.Thickness = 1; Max_Range_Knob_Stroke.Parent = Max_Range_Knob

				Library_Api.Registry[Flag] = function(New_Range)
					Library_Api.Flags[Flag].Min = math.clamp(New_Range.Min, Min, Max)
					Library_Api.Flags[Flag].Max = math.clamp(New_Range.Max, Min, Max)
					local Denominator = Max - Min
					if Denominator == 0 then Denominator = 1 end
					local Min_Percentage = (Library_Api.Flags[Flag].Min - Min) / Denominator
					local Max_Percentage = (Library_Api.Flags[Flag].Max - Min) / Denominator
					local formatStr = Format_Value(Library_Api.Flags[Flag].Min, Step) .. " - " .. Format_Value(Library_Api.Flags[Flag].Max, Step)
					Animate_Element(Range_Slider_Fill, {Position = UDim2.new(Min_Percentage, 0, 0, 0), Size = UDim2.new(Max_Percentage - Min_Percentage, 0, 1, 0)}, 0.12)
					Animate_Element(Min_Range_Knob, {Position = UDim2.new(Min_Percentage, 0, 0.5, 0)}, 0.12)
					Animate_Element(Max_Range_Knob, {Position = UDim2.new(Max_Percentage, 0, 0.5, 0)}, 0.12)
					Value_Label.Text = formatStr
					UpdateValSize(formatStr)
					if Callback then task.spawn(Callback, Library_Api.Flags[Flag]) end
				end

				Range_Slider_Background.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					Animate_Element(Range_Slider_Background_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15)
				end)
				Range_Slider_Background.MouseLeave:Connect(function()
					Show_Tooltip("")
					Animate_Element(Range_Slider_Background_Stroke, {Color = Hub_Colors.borderColor}, 0.15)
				end)

				local Is_Sliding_Min = false
				local Is_Sliding_Max = false
				local Range_Drag_Input = nil

				Range_Slider_Background.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						local Mouse_X = Input.Position.X
						local Denominator = Max - Min
						if Denominator == 0 then Denominator = 1 end
						local Min_Percentage = (Library_Api.Flags[Flag].Min - Min) / Denominator
						local Max_Percentage = (Library_Api.Flags[Flag].Max - Min) / Denominator
						local Min_Knob_Position = Range_Slider_Background.AbsolutePosition.X + (Range_Slider_Background.AbsoluteSize.X * Min_Percentage)
						local Max_Knob_Position = Range_Slider_Background.AbsolutePosition.X + (Range_Slider_Background.AbsoluteSize.X * Max_Percentage)
						if math.abs(Mouse_X - Min_Knob_Position) < math.abs(Mouse_X - Max_Knob_Position) then
							Is_Sliding_Min = true
						else
							Is_Sliding_Max = true
						end
						Input.Changed:Connect(function()
							if Input.UserInputState == Enum.UserInputState.End then
								Is_Sliding_Min = false
								Is_Sliding_Max = false
								Auto_Save()
							end
						end)
					end
				end)

				Range_Slider_Background.InputChanged:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
						Range_Drag_Input = Input
					end
				end)

				User_Input_Service.InputChanged:Connect(function(Input)
					if Input == Range_Drag_Input and (Is_Sliding_Min or Is_Sliding_Max) then
						local Percentage = math.clamp((Input.Position.X - Range_Slider_Background.AbsolutePosition.X) / Range_Slider_Background.AbsoluteSize.X, 0, 1)
						local Calculated_Value = Snap_Value(Min + ((Max - Min) * Percentage), Step)
						local tempRange = {Min = Library_Api.Flags[Flag].Min, Max = Library_Api.Flags[Flag].Max}
						if Is_Sliding_Min then
							tempRange.Min = math.clamp(Calculated_Value, Min, tempRange.Max)
						elseif Is_Sliding_Max then
							tempRange.Max = math.clamp(Calculated_Value, tempRange.Min, Max)
						end
						Library_Api.Registry[Flag](tempRange)
					end
				end)

				task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
			end

			function Elements:Textbox_Create(Name, Flag, Default, Tooltip, Callback)
				Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or "")

				local Textbox_Frame = Instance.new("Frame")
				Textbox_Frame.Size = UDim2.new(1, 0, 0, 30)
				Textbox_Frame.BackgroundTransparency = 1
				Textbox_Frame.Parent = Target_Container

				local labelWidth = GetTextWidth(Name, 11, Main_Font)
				labelWidth = math.clamp(labelWidth + 10, 50, 160)

				local Textbox_Label = Instance.new("TextLabel")
				Textbox_Label.Size = UDim2.new(0, labelWidth, 1, 0)
				Textbox_Label.Position = UDim2.new(0, 2, 0, 0)
				Textbox_Label.BackgroundTransparency = 1
				Textbox_Label.Text = Name
				Textbox_Label.TextColor3 = Hub_Colors.textWhiteColor
				Textbox_Label.TextSize = 11
				Textbox_Label.Font = Main_Font
				Textbox_Label.TextXAlignment = Enum.TextXAlignment.Left
				Textbox_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Textbox_Label.Parent = Textbox_Frame

				local Textbox_Input_Background = Instance.new("Frame")
				Textbox_Input_Background.AnchorPoint = Vector2.new(1, 0.5)
				Textbox_Input_Background.Size = UDim2.new(1, -(labelWidth + 14), 0, 20)
				Textbox_Input_Background.Position = UDim2.new(1, -4, 0.5, 0)
				Textbox_Input_Background.BackgroundColor3 = Hub_Colors.elementBackground
				Textbox_Input_Background.BackgroundTransparency = 0.18
				Textbox_Input_Background.Parent = Textbox_Frame

				local Textbox_Input_Background_Corner = Instance.new("UICorner")
				Textbox_Input_Background_Corner.CornerRadius = UDim.new(0, 4)
				Textbox_Input_Background_Corner.Parent = Textbox_Input_Background

				local Textbox_Input_Background_Stroke = Instance.new("UIStroke")
				Textbox_Input_Background_Stroke.Color = Hub_Colors.borderColor
				Textbox_Input_Background_Stroke.Thickness = 1
				Textbox_Input_Background_Stroke.Parent = Textbox_Input_Background

				local Input_Text_Box = Instance.new("TextBox")
				Input_Text_Box.Size = UDim2.new(1, -10, 1, 0)
				Input_Text_Box.Position = UDim2.new(0, 5, 0, 0)
				Input_Text_Box.BackgroundTransparency = 1
				Input_Text_Box.Text = ""
				Input_Text_Box.TextColor3 = Hub_Colors.textDarkColor
				Input_Text_Box.TextSize = 11
				Input_Text_Box.Font = Main_Font
				Input_Text_Box.ClearTextOnFocus = false
				Input_Text_Box.TextXAlignment = Enum.TextXAlignment.Left
				Input_Text_Box.ClipsDescendants = true
				Input_Text_Box.Parent = Textbox_Input_Background

				Library_Api.Registry[Flag] = function(New_Text)
					Library_Api.Flags[Flag] = New_Text
					Input_Text_Box.Text = New_Text
					if Callback then task.spawn(Callback, New_Text) end
				end

				Input_Text_Box.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					Animate_Element(Textbox_Input_Background_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15)
				end)
				Input_Text_Box.MouseLeave:Connect(function()
					Show_Tooltip("")
					Animate_Element(Textbox_Input_Background_Stroke, {Color = Hub_Colors.borderColor}, 0.15)
				end)

				Input_Text_Box.Focused:Connect(function()
					Animate_Element(Textbox_Input_Background_Stroke, {Color = Hub_Colors.accentColor}, 0.15)
					Animate_Element(Input_Text_Box, {TextColor3 = Hub_Colors.textWhiteColor}, 0.15)
				end)

				Input_Text_Box.FocusLost:Connect(function()
					Animate_Element(Textbox_Input_Background_Stroke, {Color = Hub_Colors.borderColor}, 0.15)
					Animate_Element(Input_Text_Box, {TextColor3 = Hub_Colors.textDarkColor}, 0.15)
					Library_Api.Registry[Flag](Input_Text_Box.Text)
					Auto_Save()
				end)

				task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
			end

			function Elements:Keybind_Create(Name, Flag, Default, Tooltip, Callback)
				Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or Enum.KeyCode.Unknown)
				Library_Api.Keybind_Names[Flag] = Name
				local Is_Listening = false

				local Keybind_Frame = Instance.new("Frame")
				Keybind_Frame.Size = UDim2.new(1, 0, 0, 24)
				Keybind_Frame.BackgroundTransparency = 1
				Keybind_Frame.Parent = Target_Container

				local Keybind_Icon = Instance.new("ImageLabel")
				Keybind_Icon.Size = UDim2.new(0, 14, 0, 14)
				Keybind_Icon.Position = UDim2.new(0, 5, 0.5, -7)
				Keybind_Icon.BackgroundTransparency = 1
				Keybind_Icon.Image = "rbxassetid://104798010403294"
				Keybind_Icon.ImageColor3 = Hub_Colors.textWhiteColor
				Keybind_Icon.Parent = Keybind_Frame

				local Keybind_Label = Instance.new("TextLabel")
				Keybind_Label.Size = UDim2.new(1, -100, 1, 0)
				Keybind_Label.Position = UDim2.new(0, 24, 0, 0)
				Keybind_Label.BackgroundTransparency = 1
				Keybind_Label.Text = Name
				Keybind_Label.TextColor3 = Hub_Colors.textWhiteColor
				Keybind_Label.TextSize = 11
				Keybind_Label.Font = Main_Font
				Keybind_Label.TextXAlignment = Enum.TextXAlignment.Left
				Keybind_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Keybind_Label.Parent = Keybind_Frame

				local Keybind_Button = Instance.new("TextButton")
				Keybind_Button.AnchorPoint = Vector2.new(1, 0.5)
				Keybind_Button.Size = UDim2.new(0, 65, 0, 18)
				Keybind_Button.Position = UDim2.new(1, -4, 0.5, 0)
				Keybind_Button.BackgroundColor3 = Hub_Colors.elementBackground
				Keybind_Button.BackgroundTransparency = 0.18
				Keybind_Button.Text = ""
				Keybind_Button.TextColor3 = Hub_Colors.textDarkColor
				Keybind_Button.TextSize = 10
				Keybind_Button.Font = Bold_Font
				Keybind_Button.AutoButtonColor = false
				Keybind_Button.Parent = Keybind_Frame

				local Keybind_Button_Corner = Instance.new("UICorner")
				Keybind_Button_Corner.CornerRadius = UDim.new(0, 3)
				Keybind_Button_Corner.Parent = Keybind_Button

				local Keybind_Button_Stroke = Instance.new("UIStroke")
				Keybind_Button_Stroke.Color = Hub_Colors.borderColor
				Keybind_Button_Stroke.Thickness = 1
				Keybind_Button_Stroke.Parent = Keybind_Button

				local function UpdateKeybindSize(text)
					local w = GetTextWidth(text, 10, Bold_Font)
					w = math.clamp(w + 18, 46, 110)
					Animate_Element(Keybind_Button, {Size = UDim2.new(0, w, 0, 18)}, 0.15)
					Keybind_Label.Size = UDim2.new(1, -(w + 30), 1, 0)
				end

				Library_Api.Registry[Flag] = function(New_Bind)
					Library_Api.Flags[Flag] = New_Bind
					local bindStr = "[ " .. Get_Input_Name(New_Bind) .. " ]"
					Keybind_Button.Text = bindStr
					UpdateKeybindSize(bindStr)
					Library_Api:RefreshKeybinds()
				end

				Keybind_Button.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					if not Is_Listening then Animate_Element(Keybind_Button_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15) end
				end)
				Keybind_Button.MouseLeave:Connect(function()
					Show_Tooltip("")
					if not Is_Listening then Animate_Element(Keybind_Button_Stroke, {Color = Hub_Colors.borderColor}, 0.15) end
				end)

				Keybind_Button.MouseButton1Click:Connect(function()
					Is_Listening = true
					Keybind_Button.Text = "[ ... ]"
					UpdateKeybindSize("[ ... ]")
					Animate_Element(Keybind_Button_Stroke, {Color = Hub_Colors.accentColor}, 0.2)
					Animate_Element(Keybind_Button, {TextColor3 = Hub_Colors.textWhiteColor}, 0.2)
				end)

				User_Input_Service.InputBegan:Connect(function(Input)
					if Is_Listening then
						local Key = Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType or Input.KeyCode
						if Key ~= Enum.KeyCode.Unknown and not (Input.UserInputType == Enum.UserInputType.MouseMovement) then
							if Key == Enum.KeyCode.Escape then
								Library_Api.Registry[Flag](Enum.KeyCode.Unknown)
							else
								Library_Api.Registry[Flag](Key)
							end
							Is_Listening = false
							Animate_Element(Keybind_Button_Stroke, {Color = Hub_Colors.borderColor}, 0.2)
							Animate_Element(Keybind_Button, {TextColor3 = Hub_Colors.textDarkColor}, 0.2)
							Auto_Save()
						end
					else
						if User_Input_Service:GetFocusedTextBox() then return end
						local Key = Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType or Input.KeyCode
						if Key == Library_Api.Flags[Flag] and Key ~= Enum.KeyCode.Unknown then
							if Callback then task.spawn(Callback, Library_Api.Flags[Flag]) end
						end
					end
				end)

				task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
			end

			function Elements:Dropdown_Create(Name, Flag, Options, Default, Tooltip, Callback)
				Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or Options[1])
				local Is_Dropdown_Open = false

				local Dropdown_Frame = Instance.new("Frame")
				Dropdown_Frame.Size = UDim2.new(1, 0, 0, 40)
				Dropdown_Frame.BackgroundTransparency = 1
				Dropdown_Frame.ClipsDescendants = true
				Dropdown_Frame.Parent = Target_Container

				local Dropdown_Label = Instance.new("TextLabel")
				Dropdown_Label.Size = UDim2.new(1, -10, 0, 13)
				Dropdown_Label.Position = UDim2.new(0, 2, 0, 0)
				Dropdown_Label.BackgroundTransparency = 1
				Dropdown_Label.Text = Name
				Dropdown_Label.TextColor3 = Hub_Colors.textWhiteColor
				Dropdown_Label.TextSize = 11
				Dropdown_Label.Font = Main_Font
				Dropdown_Label.TextXAlignment = Enum.TextXAlignment.Left
				Dropdown_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Dropdown_Label.Parent = Dropdown_Frame

				local Dropdown_Main_Button = Instance.new("TextButton")
				Dropdown_Main_Button.Size = UDim2.new(1, -4, 0, 20)
				Dropdown_Main_Button.Position = UDim2.new(0, 2, 0, 18)
				Dropdown_Main_Button.BackgroundColor3 = Hub_Colors.elementBackground
				Dropdown_Main_Button.BackgroundTransparency = 0.18
				Dropdown_Main_Button.Text = ""
				Dropdown_Main_Button.AutoButtonColor = false
				Dropdown_Main_Button.Parent = Dropdown_Frame

				local Dropdown_Main_Button_Corner = Instance.new("UICorner")
				Dropdown_Main_Button_Corner.CornerRadius = UDim.new(0, 4)
				Dropdown_Main_Button_Corner.Parent = Dropdown_Main_Button

				local Dropdown_Main_Button_Stroke = Instance.new("UIStroke")
				Dropdown_Main_Button_Stroke.Color = Hub_Colors.borderColor
				Dropdown_Main_Button_Stroke.Thickness = 1
				Dropdown_Main_Button_Stroke.Parent = Dropdown_Main_Button

				local Selected_Option_Label = Instance.new("TextLabel")
				Selected_Option_Label.Size = UDim2.new(1, -28, 1, 0)
				Selected_Option_Label.Position = UDim2.new(0, 7, 0, 0)
				Selected_Option_Label.BackgroundTransparency = 1
				Selected_Option_Label.Text = ""
				Selected_Option_Label.TextColor3 = Hub_Colors.textDarkColor
				Selected_Option_Label.TextSize = 11
				Selected_Option_Label.Font = Main_Font
				Selected_Option_Label.TextXAlignment = Enum.TextXAlignment.Left
				Selected_Option_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Selected_Option_Label.Parent = Dropdown_Main_Button

				local Dropdown_Arrow_Icon = Instance.new("ImageLabel")
				Dropdown_Arrow_Icon.Size = UDim2.new(0, 12, 0, 12)
				Dropdown_Arrow_Icon.Position = UDim2.new(1, -19, 0.5, -6)
				Dropdown_Arrow_Icon.BackgroundTransparency = 1
				Dropdown_Arrow_Icon.Image = "rbxassetid://6031090656"
				Dropdown_Arrow_Icon.ImageColor3 = Hub_Colors.textDarkColor
				Dropdown_Arrow_Icon.Parent = Dropdown_Main_Button

				local Dropdown_Option_List_Frame = Instance.new("ScrollingFrame")
				Dropdown_Option_List_Frame.Size = UDim2.new(1, -4, 0, 0)
				Dropdown_Option_List_Frame.Position = UDim2.new(0, 2, 0, 41)
				Dropdown_Option_List_Frame.BackgroundColor3 = Hub_Colors.elementBackground
				Dropdown_Option_List_Frame.BackgroundTransparency = 0.18
				Dropdown_Option_List_Frame.BorderSizePixel = 0
				Dropdown_Option_List_Frame.ScrollBarThickness = 2
				Dropdown_Option_List_Frame.ScrollBarImageColor3 = Hub_Colors.accentColor
				Dropdown_Option_List_Frame.ClipsDescendants = true
				Dropdown_Option_List_Frame.Active = true
				Dropdown_Option_List_Frame.Parent = Dropdown_Frame

				local Dropdown_Option_List_Corner = Instance.new("UICorner")
				Dropdown_Option_List_Corner.CornerRadius = UDim.new(0, 4)
				Dropdown_Option_List_Corner.Parent = Dropdown_Option_List_Frame

				local Dropdown_Option_List_Stroke = Instance.new("UIStroke")
				Dropdown_Option_List_Stroke.Color = Hub_Colors.borderColor
				Dropdown_Option_List_Stroke.Thickness = 1
				Dropdown_Option_List_Stroke.Transparency = 1
				Dropdown_Option_List_Stroke.Parent = Dropdown_Option_List_Frame

				local Dropdown_Option_List_Layout = Instance.new("UIListLayout")
				Dropdown_Option_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
				Dropdown_Option_List_Layout.Parent = Dropdown_Option_List_Frame

				local function Toggle_Dropdown_State()
					Is_Dropdown_Open = not Is_Dropdown_Open
					local Max_List_Height = math.min(#Options * 20, 100)
					local Target_List_Height = Is_Dropdown_Open and Max_List_Height or 0
					Animate_Element(Dropdown_Main_Button_Stroke, {Color = Is_Dropdown_Open and Hub_Colors.accentColor or Hub_Colors.borderColor}, 0.2)
					Animate_Element(Dropdown_Arrow_Icon, {Rotation = Is_Dropdown_Open and 180 or 0, ImageColor3 = Is_Dropdown_Open and Hub_Colors.accentColor or Hub_Colors.textDarkColor}, 0.2)
					Animate_Element(Dropdown_Option_List_Frame, {Size = UDim2.new(1, -4, 0, Target_List_Height)}, 0.2)
					Animate_Element(Dropdown_Option_List_Stroke, {Transparency = Is_Dropdown_Open and 0 or 1}, 0.2)
					Animate_Element(Dropdown_Frame, {Size = UDim2.new(1, 0, 0, 40 + Target_List_Height + (Is_Dropdown_Open and 4 or 0))}, 0.2)
				end

				Dropdown_Main_Button.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15) end
				end)
				Dropdown_Main_Button.MouseLeave:Connect(function()
					Show_Tooltip("")
					if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button_Stroke, {Color = Hub_Colors.borderColor}, 0.15) end
				end)
				Dropdown_Main_Button.MouseButton1Click:Connect(Toggle_Dropdown_State)

				local function Render_Options()
					for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
						if Child:IsA("TextButton") then Child:Destroy() end
					end
					for _, Option in ipairs(Options) do
						local Option_Button = Instance.new("TextButton")
						Option_Button.Size = UDim2.new(1, 0, 0, 20)
						Option_Button.BackgroundColor3 = Hub_Colors.elementHoverBackground
						Option_Button.BackgroundTransparency = 1
						Option_Button.Text = ""
						Option_Button.Parent = Dropdown_Option_List_Frame

						local Option_Label = Instance.new("TextLabel")
						Option_Label.Size = UDim2.new(1, -18, 1, 0)
						Option_Label.Position = UDim2.new(0, 7, 0, 0)
						Option_Label.BackgroundTransparency = 1
						Option_Label.Text = Option
						Option_Label.TextColor3 = Library_Api.Flags[Flag] == Option and Hub_Colors.accentColor or Hub_Colors.textDarkColor
						Option_Label.TextSize = 11
						Option_Label.Font = Main_Font
						Option_Label.TextXAlignment = Enum.TextXAlignment.Left
						Option_Label.TextTruncate = Enum.TextTruncate.AtEnd
						Option_Label.Parent = Option_Button

						Option_Button.MouseEnter:Connect(function()
							Animate_Element(Option_Button, {BackgroundTransparency = 0.18}, 0.15)
							if Library_Api.Flags[Flag] ~= Option then
								Animate_Element(Option_Label, {TextColor3 = Hub_Colors.textWhiteColor}, 0.15)
							end
						end)
						Option_Button.MouseLeave:Connect(function()
							Animate_Element(Option_Button, {BackgroundTransparency = 1}, 0.15)
							if Library_Api.Flags[Flag] ~= Option then
								Animate_Element(Option_Label, {TextColor3 = Hub_Colors.textDarkColor}, 0.15)
							end
						end)

						Option_Button.MouseButton1Click:Connect(function()
							Library_Api.Registry[Flag](Option)
							Toggle_Dropdown_State()
							Auto_Save()
						end)
					end
					Dropdown_Option_List_Frame.CanvasSize = UDim2.new(0, 0, 0, #Options * 20)
				end

				Library_Api.Registry[Flag] = function(New_Val)
					Library_Api.Flags[Flag] = New_Val
					Selected_Option_Label.Text = New_Val
					for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
						if Child:IsA("TextButton") then
							local Lbl = Child:FindFirstChildOfClass("TextLabel")
							if Lbl then
								Animate_Element(Lbl, {TextColor3 = (Lbl.Text == New_Val and Hub_Colors.accentColor or Hub_Colors.textDarkColor)}, 0.2)
							end
						end
					end
					if Callback then task.spawn(Callback, New_Val) end
				end

				Render_Options()
				task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])

				local Api = {}
				function Api:Refresh(New_Opts)
					Options = New_Opts
					Render_Options()
				end
				return Api
			end

			function Elements:MultiDropdown_Create(Name, Flag, Options, Default, Tooltip, Callback)
				Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or {})
				local Is_Dropdown_Open = false

				local Dropdown_Frame = Instance.new("Frame")
				Dropdown_Frame.Size = UDim2.new(1, 0, 0, 40)
				Dropdown_Frame.BackgroundTransparency = 1
				Dropdown_Frame.ClipsDescendants = true
				Dropdown_Frame.Parent = Target_Container

				local Dropdown_Label = Instance.new("TextLabel")
				Dropdown_Label.Size = UDim2.new(1, -10, 0, 13)
				Dropdown_Label.Position = UDim2.new(0, 2, 0, 0)
				Dropdown_Label.BackgroundTransparency = 1
				Dropdown_Label.Text = Name
				Dropdown_Label.TextColor3 = Hub_Colors.textWhiteColor
				Dropdown_Label.TextSize = 11
				Dropdown_Label.Font = Main_Font
				Dropdown_Label.TextXAlignment = Enum.TextXAlignment.Left
				Dropdown_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Dropdown_Label.Parent = Dropdown_Frame

				local Dropdown_Main_Button = Instance.new("TextButton")
				Dropdown_Main_Button.Size = UDim2.new(1, -4, 0, 20)
				Dropdown_Main_Button.Position = UDim2.new(0, 2, 0, 18)
				Dropdown_Main_Button.BackgroundColor3 = Hub_Colors.elementBackground
				Dropdown_Main_Button.BackgroundTransparency = 0.18
				Dropdown_Main_Button.Text = ""
				Dropdown_Main_Button.AutoButtonColor = false
				Dropdown_Main_Button.Parent = Dropdown_Frame

				local Dropdown_Main_Button_Corner = Instance.new("UICorner")
				Dropdown_Main_Button_Corner.CornerRadius = UDim.new(0, 4)
				Dropdown_Main_Button_Corner.Parent = Dropdown_Main_Button

				local Dropdown_Main_Button_Stroke = Instance.new("UIStroke")
				Dropdown_Main_Button_Stroke.Color = Hub_Colors.borderColor
				Dropdown_Main_Button_Stroke.Thickness = 1
				Dropdown_Main_Button_Stroke.Parent = Dropdown_Main_Button

				local Selected_Option_Label = Instance.new("TextLabel")
				Selected_Option_Label.Size = UDim2.new(1, -28, 1, 0)
				Selected_Option_Label.Position = UDim2.new(0, 7, 0, 0)
				Selected_Option_Label.BackgroundTransparency = 1
				Selected_Option_Label.TextColor3 = Hub_Colors.textDarkColor
				Selected_Option_Label.TextSize = 11
				Selected_Option_Label.Font = Main_Font
				Selected_Option_Label.TextXAlignment = Enum.TextXAlignment.Left
				Selected_Option_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Selected_Option_Label.Parent = Dropdown_Main_Button

				local Dropdown_Arrow_Icon = Instance.new("ImageLabel")
				Dropdown_Arrow_Icon.Size = UDim2.new(0, 12, 0, 12)
				Dropdown_Arrow_Icon.Position = UDim2.new(1, -19, 0.5, -6)
				Dropdown_Arrow_Icon.BackgroundTransparency = 1
				Dropdown_Arrow_Icon.Image = "rbxassetid://6031090656"
				Dropdown_Arrow_Icon.ImageColor3 = Hub_Colors.textDarkColor
				Dropdown_Arrow_Icon.Parent = Dropdown_Main_Button

				local Dropdown_Option_List_Frame = Instance.new("ScrollingFrame")
				Dropdown_Option_List_Frame.Size = UDim2.new(1, -4, 0, 0)
				Dropdown_Option_List_Frame.Position = UDim2.new(0, 2, 0, 41)
				Dropdown_Option_List_Frame.BackgroundColor3 = Hub_Colors.elementBackground
				Dropdown_Option_List_Frame.BackgroundTransparency = 0.18
				Dropdown_Option_List_Frame.BorderSizePixel = 0
				Dropdown_Option_List_Frame.ScrollBarThickness = 2
				Dropdown_Option_List_Frame.ScrollBarImageColor3 = Hub_Colors.accentColor
				Dropdown_Option_List_Frame.ClipsDescendants = true
				Dropdown_Option_List_Frame.Active = true
				Dropdown_Option_List_Frame.Parent = Dropdown_Frame

				local Dropdown_Option_List_Corner = Instance.new("UICorner")
				Dropdown_Option_List_Corner.CornerRadius = UDim.new(0, 4)
				Dropdown_Option_List_Corner.Parent = Dropdown_Option_List_Frame

				local Dropdown_Option_List_Stroke = Instance.new("UIStroke")
				Dropdown_Option_List_Stroke.Color = Hub_Colors.borderColor
				Dropdown_Option_List_Stroke.Thickness = 1
				Dropdown_Option_List_Stroke.Transparency = 1
				Dropdown_Option_List_Stroke.Parent = Dropdown_Option_List_Frame

				local Dropdown_Option_List_Layout = Instance.new("UIListLayout")
				Dropdown_Option_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
				Dropdown_Option_List_Layout.Parent = Dropdown_Option_List_Frame

				local function Toggle_Dropdown_State()
					Is_Dropdown_Open = not Is_Dropdown_Open
					local Max_List_Height = math.min(#Options * 20, 100)
					local Target_List_Height = Is_Dropdown_Open and Max_List_Height or 0
					Animate_Element(Dropdown_Main_Button_Stroke, {Color = Is_Dropdown_Open and Hub_Colors.accentColor or Hub_Colors.borderColor}, 0.2)
					Animate_Element(Dropdown_Arrow_Icon, {Rotation = Is_Dropdown_Open and 180 or 0, ImageColor3 = Is_Dropdown_Open and Hub_Colors.accentColor or Hub_Colors.textDarkColor}, 0.2)
					Animate_Element(Dropdown_Option_List_Frame, {Size = UDim2.new(1, -4, 0, Target_List_Height)}, 0.2)
					Animate_Element(Dropdown_Option_List_Stroke, {Transparency = Is_Dropdown_Open and 0 or 1}, 0.2)
					Animate_Element(Dropdown_Frame, {Size = UDim2.new(1, 0, 0, 40 + Target_List_Height + (Is_Dropdown_Open and 4 or 0))}, 0.2)
				end

				Dropdown_Main_Button.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15) end
				end)
				Dropdown_Main_Button.MouseLeave:Connect(function()
					Show_Tooltip("")
					if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button_Stroke, {Color = Hub_Colors.borderColor}, 0.15) end
				end)
				Dropdown_Main_Button.MouseButton1Click:Connect(Toggle_Dropdown_State)

				Library_Api.Registry[Flag] = function(New_Array)
					Library_Api.Flags[Flag] = New_Array
					if #New_Array == 0 then
						Selected_Option_Label.Text = "None"
					else
						Selected_Option_Label.Text = table.concat(New_Array, ", ")
					end
					for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
						if Child:IsA("TextButton") then
							local Lbl = Child:FindFirstChildOfClass("TextLabel")
							if Lbl then
								local isSelected = table.find(New_Array, Lbl.Text) ~= nil
								Animate_Element(Lbl, {TextColor3 = isSelected and Hub_Colors.accentColor or Hub_Colors.textDarkColor}, 0.2)
							end
						end
					end
					if Callback then task.spawn(Callback, New_Array) end
				end

				for _, Option in ipairs(Options) do
					local Option_Button = Instance.new("TextButton")
					Option_Button.Size = UDim2.new(1, 0, 0, 20)
					Option_Button.BackgroundColor3 = Hub_Colors.elementHoverBackground
					Option_Button.BackgroundTransparency = 1
					Option_Button.Text = ""
					Option_Button.Parent = Dropdown_Option_List_Frame

					local Option_Label = Instance.new("TextLabel")
					Option_Label.Size = UDim2.new(1, -18, 1, 0)
					Option_Label.Position = UDim2.new(0, 7, 0, 0)
					Option_Label.BackgroundTransparency = 1
					Option_Label.Text = Option
					Option_Label.TextColor3 = Hub_Colors.textDarkColor
					Option_Label.TextSize = 11
					Option_Label.Font = Main_Font
					Option_Label.TextXAlignment = Enum.TextXAlignment.Left
					Option_Label.TextTruncate = Enum.TextTruncate.AtEnd
					Option_Label.Parent = Option_Button

					Option_Button.MouseEnter:Connect(function()
						Animate_Element(Option_Button, {BackgroundTransparency = 0.18}, 0.15)
						if table.find(Library_Api.Flags[Flag], Option) == nil then
							Animate_Element(Option_Label, {TextColor3 = Hub_Colors.textWhiteColor}, 0.15)
						end
					end)
					Option_Button.MouseLeave:Connect(function()
						Animate_Element(Option_Button, {BackgroundTransparency = 1}, 0.15)
						if table.find(Library_Api.Flags[Flag], Option) == nil then
							Animate_Element(Option_Label, {TextColor3 = Hub_Colors.textDarkColor}, 0.15)
						end
					end)

					Option_Button.MouseButton1Click:Connect(function()
						local Idx = table.find(Library_Api.Flags[Flag], Option)
						local newArr = {}
						for _, v in ipairs(Library_Api.Flags[Flag]) do table.insert(newArr, v) end
						if Idx then
							table.remove(newArr, Idx)
						else
							table.insert(newArr, Option)
						end
						Library_Api.Registry[Flag](newArr)
						Auto_Save()
					end)
				end
				Dropdown_Option_List_Frame.CanvasSize = UDim2.new(0, 0, 0, #Options * 20)

				task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
			end

			function Elements:ColorPicker_Create(Name, Flag, Default, Tooltip, Callback)
				Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or Color3.new(1, 1, 1))
				local Is_Color_Picker_Open = false
				local Hue, Saturation, Value = Library_Api.Flags[Flag]:ToHSV()

				local Color_Picker_Frame = Instance.new("Frame")
				Color_Picker_Frame.Size = UDim2.new(1, 0, 0, 22)
				Color_Picker_Frame.BackgroundTransparency = 1
				Color_Picker_Frame.ClipsDescendants = true
				Color_Picker_Frame.Parent = Target_Container

				local Color_Picker_Label = Instance.new("TextLabel")
				Color_Picker_Label.Size = UDim2.new(1, -38, 0, 22)
				Color_Picker_Label.Position = UDim2.new(0, 2, 0, 0)
				Color_Picker_Label.BackgroundTransparency = 1
				Color_Picker_Label.Text = Name
				Color_Picker_Label.TextColor3 = Hub_Colors.textWhiteColor
				Color_Picker_Label.TextSize = 11
				Color_Picker_Label.Font = Main_Font
				Color_Picker_Label.TextXAlignment = Enum.TextXAlignment.Left
				Color_Picker_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Color_Picker_Label.Parent = Color_Picker_Frame

				local Color_Preview_Button = Instance.new("TextButton")
				Color_Preview_Button.AnchorPoint = Vector2.new(1, 0)
				Color_Preview_Button.Size = UDim2.new(0, 28, 0, 13)
				Color_Preview_Button.Position = UDim2.new(1, -4, 0, 4)
				Color_Preview_Button.BackgroundColor3 = Library_Api.Flags[Flag]
				Color_Preview_Button.Text = ""
				Color_Preview_Button.AutoButtonColor = false
				Color_Preview_Button.Parent = Color_Picker_Frame

				local Color_Preview_Button_Corner = Instance.new("UICorner")
				Color_Preview_Button_Corner.CornerRadius = UDim.new(0, 3)
				Color_Preview_Button_Corner.Parent = Color_Preview_Button

				local Color_Preview_Button_Stroke = Instance.new("UIStroke")
				Color_Preview_Button_Stroke.Color = Hub_Colors.borderColor
				Color_Preview_Button_Stroke.Thickness = 1
				Color_Preview_Button_Stroke.Parent = Color_Preview_Button

				local Expanded_Picker_Frame = Instance.new("Frame")
				Expanded_Picker_Frame.Size = UDim2.new(1, -4, 0, 110)
				Expanded_Picker_Frame.Position = UDim2.new(0, 2, 0, 26)
				Expanded_Picker_Frame.BackgroundColor3 = Hub_Colors.elementBackground
				Expanded_Picker_Frame.BackgroundTransparency = 0.18
				Expanded_Picker_Frame.Parent = Color_Picker_Frame

				local Expanded_Picker_Corner = Instance.new("UICorner")
				Expanded_Picker_Corner.CornerRadius = UDim.new(0, 4)
				Expanded_Picker_Corner.Parent = Expanded_Picker_Frame

				local Expanded_Picker_Stroke = Instance.new("UIStroke")
				Expanded_Picker_Stroke.Color = Hub_Colors.borderColor
				Expanded_Picker_Stroke.Thickness = 1
				Expanded_Picker_Stroke.Parent = Expanded_Picker_Frame

				local Saturation_Value_Map = Instance.new("ImageButton")
				Saturation_Value_Map.Size = UDim2.new(1, -16, 0, 76)
				Saturation_Value_Map.Position = UDim2.new(0, 8, 0, 7)
				Saturation_Value_Map.Image = "rbxassetid://4155801252"
				Saturation_Value_Map.ImageColor3 = Color3.fromHSV(Hue, 1, 1)
				Saturation_Value_Map.AutoButtonColor = false
				Saturation_Value_Map.Parent = Expanded_Picker_Frame
				local Saturation_Value_Map_Corner = Instance.new("UICorner"); Saturation_Value_Map_Corner.CornerRadius = UDim.new(0, 3); Saturation_Value_Map_Corner.Parent = Saturation_Value_Map
				local Saturation_Value_Map_Stroke = Instance.new("UIStroke"); Saturation_Value_Map_Stroke.Color = Hub_Colors.borderColor; Saturation_Value_Map_Stroke.Thickness = 1; Saturation_Value_Map_Stroke.Parent = Saturation_Value_Map

				local Saturation_Value_Map_Cursor = Instance.new("Frame")
				Saturation_Value_Map_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
				Saturation_Value_Map_Cursor.Size = UDim2.new(0, 5, 0, 5)
				Saturation_Value_Map_Cursor.Position = UDim2.new(Saturation, 0, 1 - Value, 0)
				Saturation_Value_Map_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
				Saturation_Value_Map_Cursor.Parent = Saturation_Value_Map
				local Saturation_Value_Map_Cursor_Corner = Instance.new("UICorner"); Saturation_Value_Map_Cursor_Corner.CornerRadius = UDim.new(1, 0); Saturation_Value_Map_Cursor_Corner.Parent = Saturation_Value_Map_Cursor
				local Saturation_Value_Map_Cursor_Stroke = Instance.new("UIStroke"); Saturation_Value_Map_Cursor_Stroke.Color = Color3.new(0, 0, 0); Saturation_Value_Map_Cursor_Stroke.Thickness = 1; Saturation_Value_Map_Cursor_Stroke.Parent = Saturation_Value_Map_Cursor

				local Hue_Map = Instance.new("TextButton")
				Hue_Map.Size = UDim2.new(1, -16, 0, 9)
				Hue_Map.Position = UDim2.new(0, 8, 0, 91)
				Hue_Map.Text = ""
				Hue_Map.AutoButtonColor = false
				Hue_Map.BackgroundColor3 = Color3.new(1, 1, 1)
				Hue_Map.Parent = Expanded_Picker_Frame
				local Hue_Map_Corner = Instance.new("UICorner"); Hue_Map_Corner.CornerRadius = UDim.new(0, 3); Hue_Map_Corner.Parent = Hue_Map
				local Hue_Map_Stroke = Instance.new("UIStroke"); Hue_Map_Stroke.Color = Hub_Colors.borderColor; Hue_Map_Stroke.Thickness = 1; Hue_Map_Stroke.Parent = Hue_Map

				local Hue_Gradient = Instance.new("UIGradient")
				Hue_Gradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
					ColorSequenceKeypoint.new(1/6, Color3.new(1, 1, 0)),
					ColorSequenceKeypoint.new(2/6, Color3.new(0, 1, 0)),
					ColorSequenceKeypoint.new(3/6, Color3.new(0, 1, 1)),
					ColorSequenceKeypoint.new(4/6, Color3.new(0, 0, 1)),
					ColorSequenceKeypoint.new(5/6, Color3.new(1, 0, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
				}
				Hue_Gradient.Parent = Hue_Map

				local Hue_Map_Cursor = Instance.new("Frame")
				Hue_Map_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
				Hue_Map_Cursor.Size = UDim2.new(0, 3, 1, 4)
				Hue_Map_Cursor.Position = UDim2.new(Hue, 0, 0.5, 0)
				Hue_Map_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
				Hue_Map_Cursor.Parent = Hue_Map
				local Hue_Map_Cursor_Corner = Instance.new("UICorner"); Hue_Map_Cursor_Corner.CornerRadius = UDim.new(0, 2); Hue_Map_Cursor_Corner.Parent = Hue_Map_Cursor
				local Hue_Map_Cursor_Stroke = Instance.new("UIStroke"); Hue_Map_Cursor_Stroke.Color = Color3.new(0, 0, 0); Hue_Map_Cursor_Stroke.Thickness = 1; Hue_Map_Cursor_Stroke.Parent = Hue_Map_Cursor

				Library_Api.Registry[Flag] = function(New_Color)
					Library_Api.Flags[Flag] = New_Color
					Hue, Saturation, Value = New_Color:ToHSV()
					Saturation_Value_Map.ImageColor3 = Color3.fromHSV(Hue, 1, 1)
					Color_Preview_Button.BackgroundColor3 = New_Color
					Saturation_Value_Map_Cursor.Position = UDim2.new(Saturation, 0, 1 - Value, 0)
					Hue_Map_Cursor.Position = UDim2.new(Hue, 0, 0.5, 0)
					if Callback then task.spawn(Callback, New_Color) end
				end

				local Is_Sliding_Sat = false
				local Is_Sliding_Hue = false
				local Picker_Drag_Input = nil

				local function Process_Sat(Input)
					local S = math.clamp((Input.Position.X - Saturation_Value_Map.AbsolutePosition.X) / Saturation_Value_Map.AbsoluteSize.X, 0, 1)
					local V = 1 - math.clamp((Input.Position.Y - Saturation_Value_Map.AbsolutePosition.Y) / Saturation_Value_Map.AbsoluteSize.Y, 0, 1)
					Library_Api.Registry[Flag](Color3.fromHSV(Hue, S, V))
					Auto_Save()
				end

				local function Process_Hue(Input)
					local H = math.clamp((Input.Position.X - Hue_Map.AbsolutePosition.X) / Hue_Map.AbsoluteSize.X, 0, 1)
					Library_Api.Registry[Flag](Color3.fromHSV(H, Saturation, Value))
					Auto_Save()
				end

				Saturation_Value_Map.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Is_Sliding_Sat = true
						Process_Sat(Input)
						Input.Changed:Connect(function()
							if Input.UserInputState == Enum.UserInputState.End then Is_Sliding_Sat = false end
						end)
					end
				end)

				Hue_Map.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Is_Sliding_Hue = true
						Process_Hue(Input)
						Input.Changed:Connect(function()
							if Input.UserInputState == Enum.UserInputState.End then Is_Sliding_Hue = false end
						end)
					end
				end)

				Saturation_Value_Map.InputChanged:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
						Picker_Drag_Input = Input
					end
				end)

				Hue_Map.InputChanged:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
						Picker_Drag_Input = Input
					end
				end)

				User_Input_Service.InputChanged:Connect(function(Input)
					if Input == Picker_Drag_Input then
						if Is_Sliding_Sat then Process_Sat(Input) end
						if Is_Sliding_Hue then Process_Hue(Input) end
					end
				end)

				Color_Preview_Button.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					if not Is_Color_Picker_Open then Animate_Element(Color_Preview_Button_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15) end
				end)
				Color_Preview_Button.MouseLeave:Connect(function()
					Show_Tooltip("")
					if not Is_Color_Picker_Open then Animate_Element(Color_Preview_Button_Stroke, {Color = Hub_Colors.borderColor}, 0.15) end
				end)

				Color_Preview_Button.MouseButton1Click:Connect(function()
					Is_Color_Picker_Open = not Is_Color_Picker_Open
					Animate_Element(Color_Preview_Button_Stroke, {Color = Is_Color_Picker_Open and Hub_Colors.accentColor or Hub_Colors.borderColor}, 0.2)
					Animate_Element(Color_Picker_Frame, {Size = UDim2.new(1, 0, 0, Is_Color_Picker_Open and 140 or 22)}, 0.2)
				end)

				task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
			end

			function Elements:Button_Create(Name, Tooltip, Callback)
				local Button_Frame = Instance.new("Frame")
				Button_Frame.Size = UDim2.new(1, 0, 0, 26)
				Button_Frame.BackgroundTransparency = 1
				Button_Frame.Parent = Target_Container

				local Action_Button = Instance.new("TextButton")
				Action_Button.Size = UDim2.new(1, -4, 1, 0)
				Action_Button.Position = UDim2.new(0, 2, 0, 0)
				Action_Button.BackgroundColor3 = Hub_Colors.elementBackground
				Action_Button.BackgroundTransparency = 0.18
				Action_Button.Text = Name
				Action_Button.TextColor3 = Hub_Colors.textDarkColor
				Action_Button.TextSize = 11
				Action_Button.Font = Main_Font
				Action_Button.AutoButtonColor = false
				Action_Button.TextTruncate = Enum.TextTruncate.AtEnd
				Action_Button.Parent = Button_Frame

				local Action_Button_Corner = Instance.new("UICorner")
				Action_Button_Corner.CornerRadius = UDim.new(0, 4)
				Action_Button_Corner.Parent = Action_Button

				local Action_Button_Stroke = Instance.new("UIStroke")
				Action_Button_Stroke.Color = Hub_Colors.borderColor
				Action_Button_Stroke.Thickness = 1
				Action_Button_Stroke.Parent = Action_Button

				Action_Button.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					Animate_Element(Action_Button, {BackgroundColor3 = Hub_Colors.elementHoverBackground, BackgroundTransparency = 0.08}, 0.15)
					Animate_Element(Action_Button_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15)
					Animate_Element(Action_Button, {TextColor3 = Hub_Colors.textWhiteColor}, 0.15)
				end)
				Action_Button.MouseLeave:Connect(function()
					Show_Tooltip("")
					Animate_Element(Action_Button, {BackgroundColor3 = Hub_Colors.elementBackground, BackgroundTransparency = 0.18}, 0.15)
					Animate_Element(Action_Button_Stroke, {Color = Hub_Colors.borderColor}, 0.15)
					Animate_Element(Action_Button, {TextColor3 = Hub_Colors.textDarkColor}, 0.15)
				end)
				Action_Button.MouseButton1Down:Connect(function()
					Animate_Element(Action_Button, {Size = UDim2.new(0.97, 0, 0.88, 0), Position = UDim2.new(0.015, 0, 0.06, 0)}, 0.12)
				end)
				Action_Button.MouseButton1Up:Connect(function()
					Animate_Element(Action_Button, {Size = UDim2.new(1, -4, 1, 0), Position = UDim2.new(0, 2, 0, 0)}, 0.12)
					if Callback then task.spawn(Callback) end
				end)
			end

			function Elements:SubButton_Create(Name, Tooltip, Callback)
				local Sub_Button_Frame = Instance.new("Frame")
				Sub_Button_Frame.Size = UDim2.new(1, 0, 0, 20)
				Sub_Button_Frame.BackgroundTransparency = 1
				Sub_Button_Frame.Parent = Target_Container

				local Sub_Button_Action = Instance.new("TextButton")
				Sub_Button_Action.Size = UDim2.new(1, -16, 1, 0)
				Sub_Button_Action.Position = UDim2.new(0, 8, 0, 0)
				Sub_Button_Action.BackgroundColor3 = Hub_Colors.sectionBackground
				Sub_Button_Action.BackgroundTransparency = 0.18
				Sub_Button_Action.Text = Name
				Sub_Button_Action.TextColor3 = Hub_Colors.textDarkColor
				Sub_Button_Action.TextSize = 10
				Sub_Button_Action.Font = Main_Font
				Sub_Button_Action.AutoButtonColor = false
				Sub_Button_Action.TextTruncate = Enum.TextTruncate.AtEnd
				Sub_Button_Action.Parent = Sub_Button_Frame

				local Sub_Button_Corner = Instance.new("UICorner")
				Sub_Button_Corner.CornerRadius = UDim.new(0, 3)
				Sub_Button_Corner.Parent = Sub_Button_Action

				local Sub_Button_Stroke = Instance.new("UIStroke")
				Sub_Button_Stroke.Color = Hub_Colors.borderColor
				Sub_Button_Stroke.Thickness = 1
				Sub_Button_Stroke.Parent = Sub_Button_Action

				Sub_Button_Action.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					Animate_Element(Sub_Button_Action, {BackgroundColor3 = Hub_Colors.elementBackground, BackgroundTransparency = 0.08}, 0.15)
					Animate_Element(Sub_Button_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15)
					Animate_Element(Sub_Button_Action, {TextColor3 = Hub_Colors.textWhiteColor}, 0.15)
				end)
				Sub_Button_Action.MouseLeave:Connect(function()
					Show_Tooltip("")
					Animate_Element(Sub_Button_Action, {BackgroundColor3 = Hub_Colors.sectionBackground, BackgroundTransparency = 0.18}, 0.15)
					Animate_Element(Sub_Button_Stroke, {Color = Hub_Colors.borderColor}, 0.15)
					Animate_Element(Sub_Button_Action, {TextColor3 = Hub_Colors.textDarkColor}, 0.15)
				end)
				Sub_Button_Action.MouseButton1Down:Connect(function()
					Animate_Element(Sub_Button_Action, {Size = UDim2.new(0.97, -16, 0.88, 0), Position = UDim2.new(0.015, 8, 0.06, 0)}, 0.12)
				end)
				Sub_Button_Action.MouseButton1Up:Connect(function()
					Animate_Element(Sub_Button_Action, {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0)}, 0.12)
					if Callback then task.spawn(Callback) end
				end)
			end

			function Elements:Module_Create(Name, Flag, Description_Text, Default, Tooltip, Callback)
				Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or false)

				local Module_Frame = Instance.new("Frame")
				Module_Frame.Size = UDim2.new(1, 0, 0, 38)
				Module_Frame.BackgroundTransparency = 1
				Module_Frame.ClipsDescendants = true
				Module_Frame.Parent = Target_Container

				local Module_Toggle_Button = Instance.new("TextButton")
				Module_Toggle_Button.Size = UDim2.new(1, -4, 0, 36)
				Module_Toggle_Button.Position = UDim2.new(0, 2, 0, 0)
				Module_Toggle_Button.BackgroundColor3 = Hub_Colors.elementBackground
				Module_Toggle_Button.BackgroundTransparency = 0.18
				Module_Toggle_Button.Text = ""
				Module_Toggle_Button.AutoButtonColor = false
				Module_Toggle_Button.Parent = Module_Frame

				local Module_Toggle_Button_Corner = Instance.new("UICorner")
				Module_Toggle_Button_Corner.CornerRadius = UDim.new(0, 4)
				Module_Toggle_Button_Corner.Parent = Module_Toggle_Button

				local Module_Toggle_Button_Stroke = Instance.new("UIStroke")
				Module_Toggle_Button_Stroke.Color = Hub_Colors.borderColor
				Module_Toggle_Button_Stroke.Thickness = 1
				Module_Toggle_Button_Stroke.Parent = Module_Toggle_Button

				local Module_Checkbox_Frame = Instance.new("Frame")
				Module_Checkbox_Frame.Size = UDim2.new(0, 13, 0, 13)
				Module_Checkbox_Frame.Position = UDim2.new(0, 11, 0.5, -6)
				Module_Checkbox_Frame.BackgroundColor3 = Hub_Colors.sectionBackground
				Module_Checkbox_Frame.BackgroundTransparency = 0.18
				Module_Checkbox_Frame.Parent = Module_Toggle_Button

				local Module_Checkbox_Corner = Instance.new("UICorner")
				Module_Checkbox_Corner.CornerRadius = UDim.new(0, 3)
				Module_Checkbox_Corner.Parent = Module_Checkbox_Frame

				local Module_Checkbox_Stroke = Instance.new("UIStroke")
				Module_Checkbox_Stroke.Color = Hub_Colors.borderColor
				Module_Checkbox_Stroke.Thickness = 1
				Module_Checkbox_Stroke.Parent = Module_Checkbox_Frame

				local Module_Label = Instance.new("TextLabel")
				Module_Label.Size = UDim2.new(1, -44, 0, 13)
				Module_Label.Position = UDim2.new(0, 34, 0, 4)
				Module_Label.BackgroundTransparency = 1
				Module_Label.Text = Name
				Module_Label.TextColor3 = Hub_Colors.textDarkColor
				Module_Label.TextSize = 11
				Module_Label.Font = Bold_Font
				Module_Label.TextXAlignment = Enum.TextXAlignment.Left
				Module_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Module_Label.Parent = Module_Toggle_Button

				local Module_Description_Label = Instance.new("TextLabel")
				Module_Description_Label.Size = UDim2.new(1, -44, 0, 11)
				Module_Description_Label.Position = UDim2.new(0, 34, 0, 19)
				Module_Description_Label.BackgroundTransparency = 1
				Module_Description_Label.Text = Description_Text
				Module_Description_Label.TextColor3 = Hub_Colors.textDarkColor
				Module_Description_Label.TextSize = 9
				Module_Description_Label.Font = Main_Font
				Module_Description_Label.TextXAlignment = Enum.TextXAlignment.Left
				Module_Description_Label.TextTruncate = Enum.TextTruncate.AtEnd
				Module_Description_Label.Parent = Module_Toggle_Button

				local Module_Arrow_Icon = Instance.new("ImageLabel")
				Module_Arrow_Icon.Size = UDim2.new(0, 11, 0, 11)
				Module_Arrow_Icon.Position = UDim2.new(1, -18, 0, 12)
				Module_Arrow_Icon.BackgroundTransparency = 1
				Module_Arrow_Icon.Image = "rbxassetid://6031090656"
				Module_Arrow_Icon.ImageColor3 = Hub_Colors.textDarkColor
				Module_Arrow_Icon.Rotation = 0
				Module_Arrow_Icon.Parent = Module_Toggle_Button

				local Module_Content_Frame = Instance.new("Frame")
				Module_Content_Frame.Size = UDim2.new(1, -16, 0, 0)
				Module_Content_Frame.Position = UDim2.new(0, 12, 0, 40)
				Module_Content_Frame.BackgroundTransparency = 1
				Module_Content_Frame.Parent = Module_Frame

				local Module_Content_Layout = Instance.new("UIListLayout")
				Module_Content_Layout.Padding = UDim.new(0, 7)
				Module_Content_Layout.Parent = Module_Content_Frame

				local function Synchronize_Module_Size()
					if Library_Api.Flags[Flag] then
						Animate_Element(Module_Frame, {Size = UDim2.new(1, 0, 0, 38 + Module_Content_Layout.AbsoluteContentSize.Y + 8)}, 0.2)
						Animate_Element(Module_Arrow_Icon, {Rotation = 180, ImageColor3 = Hub_Colors.accentColor}, 0.2)
					else
						Animate_Element(Module_Frame, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
						Animate_Element(Module_Arrow_Icon, {Rotation = 0, ImageColor3 = Hub_Colors.textDarkColor}, 0.2)
					end
				end

				Module_Content_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					if Library_Api.Flags[Flag] then Synchronize_Module_Size() end
				end)

				Library_Api.Registry[Flag] = function(New_State)
					Library_Api.Flags[Flag] = New_State
					Animate_Element(Module_Checkbox_Frame, {BackgroundColor3 = New_State and Hub_Colors.accentColor or Hub_Colors.sectionBackground}, 0.2)
					Animate_Element(Module_Toggle_Button_Stroke, {Color = New_State and Hub_Colors.accentColor or Hub_Colors.borderColor}, 0.2)
					Animate_Element(Module_Label, {TextColor3 = New_State and Hub_Colors.textWhiteColor or Hub_Colors.textDarkColor}, 0.2)
					Synchronize_Module_Size()
					if Callback then task.spawn(Callback, New_State) end
				end

				Module_Toggle_Button.MouseEnter:Connect(function()
					Show_Tooltip(Tooltip)
					if not Library_Api.Flags[Flag] then Animate_Element(Module_Toggle_Button_Stroke, {Color = Hub_Colors.borderLightColor}, 0.15) end
				end)
				Module_Toggle_Button.MouseLeave:Connect(function()
					Show_Tooltip("")
					if not Library_Api.Flags[Flag] then Animate_Element(Module_Toggle_Button_Stroke, {Color = Hub_Colors.borderColor}, 0.15) end
				end)

				Module_Toggle_Button.MouseButton1Click:Connect(function()
					Library_Api.Registry[Flag](not Library_Api.Flags[Flag])
					Auto_Save()
				end)

				task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])

				return Element_Injector(Module_Content_Frame)
			end

			return Elements
		end

		function Tab_Data:Section_Create(Column_Side, Section_Title)
			local Section_Background_Frame = Instance.new("Frame")
			Section_Background_Frame.Size = UDim2.new(1, 0, 0, 36)
			Section_Background_Frame.BackgroundColor3 = Hub_Colors.sectionBackground
			Section_Background_Frame.BackgroundTransparency = 0.18
			Section_Background_Frame.ClipsDescendants = true
			Section_Background_Frame.Parent = (Column_Side == "Left") and Left_Column_Frame or Right_Column_Frame

			local Section_Background_Corner = Instance.new("UICorner")
			Section_Background_Corner.CornerRadius = UDim.new(0, 5)
			Section_Background_Corner.Parent = Section_Background_Frame

			local Section_Background_Stroke = Instance.new("UIStroke")
			Section_Background_Stroke.Color = Hub_Colors.borderColor
			Section_Background_Stroke.Thickness = 1
			Section_Background_Stroke.Parent = Section_Background_Frame

			local Section_Header_Frame = Instance.new("Frame")
			Section_Header_Frame.Size = UDim2.new(1, 0, 0, 22)
			Section_Header_Frame.BackgroundTransparency = 1
			Section_Header_Frame.Parent = Section_Background_Frame

			local Section_Label = Instance.new("TextLabel")
			Section_Label.Size = UDim2.new(1, -18, 1, 0)
			Section_Label.Position = UDim2.new(0, 9, 0, 0)
			Section_Label.BackgroundTransparency = 1
			Section_Label.Text = Section_Title
			Section_Label.TextColor3 = Hub_Colors.textWhiteColor
			Section_Label.TextSize = 11
			Section_Label.Font = Bold_Font
			Section_Label.TextXAlignment = Enum.TextXAlignment.Left
			Section_Label.TextTruncate = Enum.TextTruncate.AtEnd
			Section_Label.Parent = Section_Header_Frame

			local Section_Separator_Line = Instance.new("Frame")
			Section_Separator_Line.Size = UDim2.new(1, -18, 0, 1)
			Section_Separator_Line.Position = UDim2.new(0, 9, 1, 0)
			Section_Separator_Line.BackgroundColor3 = Hub_Colors.borderColor
			Section_Separator_Line.BorderSizePixel = 0
			Section_Separator_Line.Parent = Section_Header_Frame

			local Section_Content_Frame = Instance.new("Frame")
			Section_Content_Frame.Size = UDim2.new(1, -14, 1, -28)
			Section_Content_Frame.Position = UDim2.new(0, 7, 0, 26)
			Section_Content_Frame.BackgroundTransparency = 1
			Section_Content_Frame.Parent = Section_Background_Frame

			local Section_Content_Layout = Instance.new("UIListLayout")
			Section_Content_Layout.SortOrder = Enum.SortOrder.LayoutOrder
			Section_Content_Layout.Padding = UDim.new(0, 7)
			Section_Content_Layout.Parent = Section_Content_Frame

			Section_Content_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Animate_Element(Section_Background_Frame, {Size = UDim2.new(1, 0, 0, Section_Content_Layout.AbsoluteContentSize.Y + 34)}, 0.2)
			end)
			Section_Background_Frame.Size = UDim2.new(1, 0, 0, Section_Content_Layout.AbsoluteContentSize.Y + 34)

			return Element_Injector(Section_Content_Frame)
		end

		Tab_Data.Elements = Element_Injector(Page_Scrolling_Frame)

		return Tab_Data
	end

	local Settings_Api = Window_Context:Tab_Create("Settings", "")
	local Settings_Tab_Obj = Settings_Api
	Settings_Tab_Obj.Btn.Visible = false

	Profile_Button.MouseEnter:Connect(function() Animate_Element(Profile_Button, {BackgroundTransparency = 0.12}, 0.15) end)
	Profile_Button.MouseLeave:Connect(function()
		if Window_Context.Active_Tab ~= Settings_Tab_Obj then
			Animate_Element(Profile_Button, {BackgroundTransparency = 1}, 0.15)
		end
	end)
	Profile_Button.MouseButton1Click:Connect(function()
		Settings_Tab_Obj:Activate()
		Animate_Element(Profile_Button, {BackgroundTransparency = 0.12}, 0.2)
	end)

	local Left_Settings = Settings_Api:Section_Create("Left", "Menu UI")

	Left_Settings:Keybind_Create("Menu Toggle", "Menu_Toggle_Key", Enum.KeyCode.Delete, "Toggle Menu Visibility", function()
		Main_Background.Visible = not Main_Background.Visible
	end)

	Left_Settings:Toggle_Create("Keybinds List", "Show_Keybinds", false, "Toggle Keybinds Tracker", function(State)
		Keybinds_Frame.Visible = State
	end)

	Left_Settings:ColorPicker_Create("Theme Accent", "Theme_Color", Hub_Colors.accentColor, "Change Hub Palette", function(Color_Val)
		Library_Api:UpdateTheme(Color_Val)
	end)

	local Right_Settings = Settings_Api:Section_Create("Right", "Configurations")

	local function Get_Configs()
		local List = {}
		local success, _ = pcall(function()
			if type(isfolder) == "function" and not isfolder(Library_Api.Folder_Name) then makefolder(Library_Api.Folder_Name) end
			for _, File in ipairs(listfiles(Library_Api.Folder_Name)) do
				local Name = File:match("([^/\\]+)%.json$")
				if Name and Name ~= "AutoSaveConfig" then table.insert(List, Name) end
			end
		end)
		return #List > 0 and List or {"None"}
	end

	local Config_Name_Input = ""
	Right_Settings:Textbox_Create("Config Name", "Cfg_Name", "", "", function(Val) Config_Name_Input = Val end)

	local Cfg_Dropdown = Right_Settings:Dropdown_Create("Select Config", "Cfg_Select", Get_Configs(), "None", "", function() end)

	Right_Settings:Button_Create("Save Config", "", function()
		if Config_Name_Input ~= "" then
			Save_To_File(Config_Name_Input .. ".json")
			Cfg_Dropdown:Refresh(Get_Configs())
			Library_Api:Notify({Title = "Phantom Hub", Text = "Saved Config: " .. Config_Name_Input, Type = "Success"})
		end
	end)

	Right_Settings:Button_Create("Rewrite Config", "", function()
		if Library_Api.Flags["Cfg_Select"] and Library_Api.Flags["Cfg_Select"] ~= "None" then
			Save_To_File(Library_Api.Flags["Cfg_Select"] .. ".json")
			Library_Api:Notify({Title = "Phantom Hub", Text = "Rewritten Config", Type = "Info"})
		end
	end)

	Right_Settings:Button_Create("Load Config", "", function()
		if Library_Api.Flags["Cfg_Select"] and Library_Api.Flags["Cfg_Select"] ~= "None" then
			Load_From_File(Library_Api.Flags["Cfg_Select"] .. ".json")
			Library_Api:RefreshKeybinds()
			Library_Api:Notify({Title = "Phantom Hub", Text = "Loaded Config", Type = "Success"})
		end
	end)

	Right_Settings:Button_Create("Delete Config", "", function()
		if Library_Api.Flags["Cfg_Select"] and Library_Api.Flags["Cfg_Select"] ~= "None" then
			pcall(function() delfile(Library_Api.Folder_Name .. "/" .. Library_Api.Flags["Cfg_Select"] .. ".json") end)
			Cfg_Dropdown:Refresh(Get_Configs())
			Library_Api:Notify({Title = "Phantom Hub", Text = "Deleted Config", Type = "Error"})
		end
	end)

	return Window_Context
end

return Library_Api
