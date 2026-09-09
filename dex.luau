local nodes = {}
local selection

local function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

local cloneref = missing("function", cloneref, function(...) return ... end)
local service = setmetatable({}, {
	__index = function(self, name)
		self[name] = cloneref(game:GetService(name))
		return self[name]
	end
})




local oldgame = game
local game = workspace.Parent

local _getgenv = type(getgenv) == "function" and getgenv or function() return _G end
local GENV = _getgenv()
local DEX_BUILD_VERSION = "V23"
local function dexCacheToken()
	local ok,guid = pcall(function()
		return game:GetService("HttpService"):GenerateGUID(false)
	end)
	if ok and type(guid)=="string" and guid~="" then
		return guid:gsub("%-","").."_"..tostring(math.random(100000,999999))
	end
	local ms
	pcall(function() ms=DateTime.now().UnixTimestampMillis end)
	ms=ms or math.floor((os.clock and os.clock() or tick())*1000000)
	return tostring(ms).."_"..tostring(math.random(100000000,999999999))
end
local function dexCacheBust(url)
	url=tostring(url)
	url=url:gsub("([?&])_dexcb=[^&]*", "%1"):gsub("%?&", "?"):gsub("&&+", "&"):gsub("[?&]$", "")
	local sep=url:find("?",1,true) and "&" or "?"
	return url..sep.."_dexcb="..dexCacheToken()
end
local DEX_SOURCE_URL = "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/refs/heads/main/dex.luau"
GENV.DEX_SOURCE_URL = GENV.DEX_SOURCE_URL or DEX_SOURCE_URL
GENV.DEX_BUILD_ID = DEX_BUILD_VERSION.."_"..dexCacheToken()
GENV.DEX_PRETTY_MODE = GENV.DEX_PRETTY_MODE or "aggressive"
GENV.DEX_PRETTY_INLINE_FIELDS = GENV.DEX_PRETTY_INLINE_FIELDS or 5
GENV.DEX_PRETTY_INLINE_WIDTH = GENV.DEX_PRETTY_INLINE_WIDTH or 140
GENV.DEX_PRETTY_MAX_INDENT = GENV.DEX_PRETTY_MAX_INDENT or 10
if GENV.DEX_PRETTY_CANONICAL_INDENT == nil then GENV.DEX_PRETTY_CANONICAL_INDENT = true end
if GENV.DEX_PRETTY_FLOATS == nil then GENV.DEX_PRETTY_FLOATS = true end
if GENV.DEX_POSTDOM_STRUCTURING == nil then GENV.DEX_POSTDOM_STRUCTURING = true end
if GENV.DEX_OBFUSCATION_GUARDS == nil then GENV.DEX_OBFUSCATION_GUARDS = true end
if GENV.DEX_SEMANTIC_NAMES == nil then GENV.DEX_SEMANTIC_NAMES = true end
if GENV.DEX_PRETTY_FLATTEN_GUARDS == nil then GENV.DEX_PRETTY_FLATTEN_GUARDS = true end
GENV.DEX_CACHE_BUST = dexCacheBust
GENV.DEX_HTTPGET = function(url)
	return oldgame:HttpGet(dexCacheBust(url), false)
end
GENV.DEX_LOAD_LATEST = function(url)
	url = url or GENV.DEX_SOURCE_URL or DEX_SOURCE_URL
	local src = oldgame:HttpGet(dexCacheBust(url), false)
	return loadstring(src)()
end

local EmbeddedModules = {
	Explorer = function()






		
		local Main,Lib,Apps,Settings 
		local Explorer, Properties, ScriptViewer, Notebook 
		local API,RMD,env,service,plr,create,createSimple 

		local function initDeps(data)
			Main = data.Main
			Lib = data.Lib
			Apps = data.Apps
			Settings = data.Settings

			API = data.API
			RMD = data.RMD
			env = data.env
			service = data.service
			plr = data.plr
			create = data.create
			createSimple = data.createSimple
		end

		local function initAfterMain()
			Explorer = Apps.Explorer
			Properties = Apps.Properties
			ScriptViewer = Apps.ScriptViewer
			Notebook = Apps.Notebook
		end

		local function main()
			local Explorer = {}
			local tree,listEntries,explorerOrders,searchResults,specResults = {},{},{},{},{}
			local expanded
			local entryTemplate,treeFrame,toolBar,descendantAddedCon,descendantRemovingCon,itemChangedCon
			local ffa = game.FindFirstAncestorWhichIsA
			local getDescendants = game.GetDescendants
			local getTextSize = service.TextService.GetTextSize
			local updateDebounce,refreshDebounce = false,false
			local nilNode = {Obj = Instance.new("Folder")}
			local idCounter = 0
			local scrollV,scrollH,clipboard
			local renameBox,renamingNode,searchFunc
			local sortingEnabled,autoUpdateSearch
			local table,math = table,math
			local nilMap,nilCons = {},{}
			local connectSignal = game.DescendantAdded.Connect
			local addObject,removeObject,moveObject = nil,nil,nil

			addObject = function(root)
				if nodes[root] then return end

				local isNil = false
				local rootParObj = ffa(root,"Instance")
				local par = nodes[rootParObj]

				
				if not par then
					if nilMap[root] then
						nilCons[root] = nilCons[root] or {
							connectSignal(root.ChildAdded,addObject),
							connectSignal(root.AncestryChanged,moveObject),
						}
						par = nilNode
						isNil = true
					else
						return
					end
				elseif nilMap[rootParObj] or par == nilNode then
					nilMap[root] = true
					nilCons[root] = nilCons[root] or {
						connectSignal(root.ChildAdded,addObject),
						connectSignal(root.AncestryChanged,moveObject),
					}
					isNil = true
				end

				local newNode = {Obj = root, Parent = par}
				nodes[root] = newNode

				
				if sortingEnabled and expanded[par] and par.Sorted then
					local left,right = 1,#par
					local floor = math.floor
					local sorter = Explorer.NodeSorter
					local pos = (right == 0 and 1)

					if not pos then
						while true do
							if left >= right then
								if sorter(newNode,par[left]) then
									pos = left
								else
									pos = left+1
								end
								break
							end

							local mid = floor((left+right)/2)
							if sorter(newNode,par[mid]) then
								right = mid-1
							else
								left = mid+1
							end
						end
					end

					table.insert(par,pos,newNode)
				else
					par[#par+1] = newNode
					par.Sorted = nil
				end

				local insts = getDescendants(root)
				for i = 1,#insts do
					local obj = insts[i]
					if nodes[obj] then continue end 

					local par = nodes[ffa(obj,"Instance")]
					if not par then continue end
					local newNode = {Obj = obj, Parent = par}
					nodes[obj] = newNode
					par[#par+1] = newNode

					
					if isNil then
						nilMap[obj] = true
						nilCons[obj] = nilCons[obj] or {
							connectSignal(obj.ChildAdded,addObject),
							connectSignal(obj.AncestryChanged,moveObject),
						}
					end
				end

				if searchFunc and autoUpdateSearch then
					searchFunc({newNode})
				end

				if not updateDebounce and Explorer.IsNodeVisible(par) then
					if expanded[par] then
						Explorer.PerformUpdate()
					elseif not refreshDebounce then
						Explorer.PerformRefresh()
					end
				end
			end

			removeObject = function(root)
				local node = nodes[root]
				if not node then return end

				
				if nilMap[node.Obj] then
					moveObject(node.Obj)
					return
				end

				local par = node.Parent
				if par then
					par.HasDel = true
				end

				local function recur(root)
					for i = 1,#root do
						local node = root[i]
						if not node.Del then
							nodes[node.Obj] = nil
							if #node > 0 then recur(node) end
						end
					end
				end
				recur(node)
				node.Del = true
				nodes[root] = nil

				if par and not updateDebounce and Explorer.IsNodeVisible(par) then
					if expanded[par] then
						Explorer.PerformUpdate()
					elseif not refreshDebounce then
						Explorer.PerformRefresh()
					end
				end
			end

			moveObject = function(obj)
				local node = nodes[obj]
				if not node then return end

				local oldPar = node.Parent
				local newPar = nodes[ffa(obj,"Instance")]
				if oldPar == newPar then return end

				
				if not newPar then
					if nilMap[obj] then
						newPar = nilNode
					else
						return
					end
				elseif nilMap[newPar.Obj] or newPar == nilNode then
					nilMap[obj] = true
					nilCons[obj] = nilCons[obj] or {
						connectSignal(obj.ChildAdded,addObject),
						connectSignal(obj.AncestryChanged,moveObject),
					}
				end

				if oldPar then
					local parPos = table.find(oldPar,node)
					if parPos then table.remove(oldPar,parPos) end
				end

				node.Id = nil
				node.Parent = newPar

				if sortingEnabled and expanded[newPar] and newPar.Sorted then
					local left,right = 1,#newPar
					local floor = math.floor
					local sorter = Explorer.NodeSorter
					local pos = (right == 0 and 1)

					if not pos then
						while true do
							if left >= right then
								if sorter(node,newPar[left]) then
									pos = left
								else
									pos = left+1
								end
								break
							end

							local mid = floor((left+right)/2)
							if sorter(node,newPar[mid]) then
								right = mid-1
							else
								left = mid+1
							end
						end
					end

					table.insert(newPar,pos,node)
				else
					newPar[#newPar+1] = node
					newPar.Sorted = nil
				end

				if searchFunc and searchResults[node] then
					local currentNode = node.Parent
					while currentNode and (not searchResults[currentNode] or expanded[currentNode] == 0) do
						expanded[currentNode] = true
						searchResults[currentNode] = true
						currentNode = currentNode.Parent
					end
				end

				if not updateDebounce and (Explorer.IsNodeVisible(newPar) or Explorer.IsNodeVisible(oldPar)) then
					if expanded[newPar] or expanded[oldPar] then
						Explorer.PerformUpdate()
					elseif not refreshDebounce then
						Explorer.PerformRefresh()
					end
				end
			end

			Explorer.ViewWidth = 0
			Explorer.Index = 0
			Explorer.EntryIndent = 20
			Explorer.FreeWidth = 32
			Explorer.GuiElems = {}

			Explorer.InitRenameBox = function()
				renameBox = create({{1,"TextBox",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.062745101749897,0.51764708757401,1),BorderMode=2,ClearTextOnFocus=false,Font=3,Name="RenameBox",PlaceholderColor3=Color3.new(0.69803923368454,0.69803923368454,0.69803923368454),Position=UDim2.new(0,26,0,2),Size=UDim2.new(0,200,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,Visible=false,ZIndex=2}}})

				renameBox.Parent = Explorer.Window.GuiElems.Content.List

				renameBox.FocusLost:Connect(function()
					if not renamingNode then return end

					pcall(function() renamingNode.Obj.Name = renameBox.Text end)
					renamingNode = nil
					Explorer.Refresh()
				end)

				renameBox.Focused:Connect(function()
					renameBox.SelectionStart = 1
					renameBox.CursorPosition = #renameBox.Text + 1
				end)
			end

			Explorer.SetRenamingNode = function(node)
				renamingNode = node
				renameBox.Text = tostring(node.Obj)
				renameBox:CaptureFocus()
				Explorer.Refresh()
			end

			Explorer.SetSortingEnabled = function(val)
				sortingEnabled = val
				Settings.Explorer.Sorting = val
			end

			Explorer.UpdateView = function()
				local maxNodes = math.ceil(treeFrame.AbsoluteSize.Y / 20)
				local maxX = treeFrame.AbsoluteSize.X
				local totalWidth = Explorer.ViewWidth + Explorer.FreeWidth

				scrollV.VisibleSpace = maxNodes
				scrollV.TotalSpace = #tree + 1
				scrollH.VisibleSpace = maxX
				scrollH.TotalSpace = totalWidth

				scrollV.Gui.Visible = #tree + 1 > maxNodes
				scrollH.Gui.Visible = totalWidth > maxX

				local oldSize = treeFrame.Size
				treeFrame.Size = UDim2.new(1,(scrollV.Gui.Visible and -16 or 0),1,(scrollH.Gui.Visible and -39 or -23))
				if oldSize ~= treeFrame.Size then
					Explorer.UpdateView()
				else
					scrollV:Update()
					scrollH:Update()

					renameBox.Size = UDim2.new(0,maxX-100,0,16)

					if scrollV.Gui.Visible and scrollH.Gui.Visible then
						scrollV.Gui.Size = UDim2.new(0,16,1,-39)
						scrollH.Gui.Size = UDim2.new(1,-16,0,16)
						Explorer.Window.GuiElems.Content.ScrollCorner.Visible = true
					else
						scrollV.Gui.Size = UDim2.new(0,16,1,-23)
						scrollH.Gui.Size = UDim2.new(1,0,0,16)
						Explorer.Window.GuiElems.Content.ScrollCorner.Visible = false
					end

					Explorer.Index = scrollV.Index
				end
			end

			Explorer.NodeSorter = function(a,b)
				if a.Del or b.Del then return false end 

				local aClass = a.Class
				local bClass = b.Class
				if not aClass then aClass = a.Obj.ClassName a.Class = aClass end
				if not bClass then bClass = b.Obj.ClassName b.Class = bClass end

				local aOrder = explorerOrders[aClass]
				local bOrder = explorerOrders[bClass]
				if not aOrder then aOrder = RMD.Classes[aClass] and tonumber(RMD.Classes[aClass].ExplorerOrder) or 9999 explorerOrders[aClass] = aOrder end
				if not bOrder then bOrder = RMD.Classes[bClass] and tonumber(RMD.Classes[bClass].ExplorerOrder) or 9999 explorerOrders[bClass] = bOrder end

				if aOrder ~= bOrder then
					return aOrder < bOrder
				else
					local aName,bName = tostring(a.Obj),tostring(b.Obj)
					if aName ~= bName then
						return aName < bName
					elseif aClass ~= bClass then
						return aClass < bClass
					else
						local aId = a.Id if not aId then aId = idCounter idCounter = (idCounter+0.001)%999999999 a.Id = aId end
						local bId = b.Id if not bId then bId = idCounter idCounter = (idCounter+0.001)%999999999 b.Id = bId end
						return aId < bId
					end
				end
			end

			Explorer.Update = function()
				table.clear(tree)
				local maxNameWidth,maxDepth,count = 0,1,1
				local nameCache = {}
				local font = Enum.Font.SourceSans
				local size = Vector2.new(math.huge,20)
				local useNameWidth = Settings.Explorer.UseNameWidth
				local tSort = table.sort
				local sortFunc = Explorer.NodeSorter
				local isSearching = (expanded == Explorer.SearchExpanded)
				local textServ = service.TextService

				local function recur(root,depth)
					if depth > maxDepth then maxDepth = depth end
					depth = depth + 1
					if sortingEnabled and not root.Sorted then
						tSort(root,sortFunc)
						root.Sorted = true
					end
					for i = 1,#root do
						local n = root[i]

						if (isSearching and not searchResults[n]) or n.Del then continue end

						if useNameWidth then
							local nameWidth = n.NameWidth
							if not nameWidth then
								local objName = tostring(n.Obj)
								nameWidth = nameCache[objName]
								if not nameWidth then
									nameWidth = getTextSize(textServ,objName,14,font,size).X
									nameCache[objName] = nameWidth
								end
								n.NameWidth = nameWidth
							end
							if nameWidth > maxNameWidth then
								maxNameWidth = nameWidth
							end
						end

						tree[count] = n
						count = count + 1
						if expanded[n] and #n > 0 then
							recur(n,depth)
						end
					end
				end

				recur(nodes[game],1)

				
				if env.getnilinstances then
					if not (isSearching and not searchResults[nilNode]) then
						tree[count] = nilNode
						count = count + 1
						if expanded[nilNode] then
							recur(nilNode,2)
						end
					end
				end

				Explorer.MaxNameWidth = maxNameWidth
				Explorer.MaxDepth = maxDepth
				Explorer.ViewWidth = useNameWidth and Explorer.EntryIndent*maxDepth + maxNameWidth + 26 or Explorer.EntryIndent*maxDepth + 226
				Explorer.UpdateView()
			end

			Explorer.StartDrag = function(offX,offY)
				if Explorer.Dragging then return end
				for i,v in next, selection.List do
					local Obj = v.Obj
					if Obj.Parent == game or Obj:IsA("Player") then
						return
					end
				end
				Explorer.Dragging = true

				local dragTree = treeFrame:Clone()
				dragTree:ClearAllChildren()

				for i,v in pairs(listEntries) do
					local node = tree[i + Explorer.Index]
					if node and selection.Map[node] then
						local clone = v:Clone()
						clone.Active = false
						clone.Indent.Expand.Visible = false
						clone.Parent = dragTree
					end
				end

				local newGui = Instance.new("ScreenGui")
				newGui.DisplayOrder = Main.DisplayOrders.Menu
				dragTree.Parent = newGui
				Lib.ShowGui(newGui)

				local dragOutline = create({
					{1,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="DragSelect",Size=UDim2.new(1,0,1,0),}},
					{2,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Line",Parent={1},Size=UDim2.new(1,0,0,1),ZIndex=2,}},
					{3,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Line",Parent={1},Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),ZIndex=2,}},
					{4,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Line",Parent={1},Size=UDim2.new(0,1,1,0),ZIndex=2,}},
					{5,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Line",Parent={1},Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0),ZIndex=2,}},
				})
				dragOutline.Parent = treeFrame

				local mouse = Main.Mouse or service.Players.LocalPlayer:GetMouse()
				local function move()
					local posX = mouse.X - offX
					local posY = mouse.Y - offY
					dragTree.Position = UDim2.new(0,posX,0,posY)

					for i = 1,#listEntries do
						local entry = listEntries[i]
						if Lib.CheckMouseInGui(entry) then
							dragOutline.Position = UDim2.new(0,entry.Indent.Position.X.Offset-scrollH.Index,0,entry.Position.Y.Offset)
							dragOutline.Size = UDim2.new(0,entry.Size.X.Offset-entry.Indent.Position.X.Offset,0,20)
							dragOutline.Visible = true
							return
						end
					end
					dragOutline.Visible = false
				end
				move()

				local input = service.UserInputService
				local mouseEvent,releaseEvent

				mouseEvent = input.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						move()
					end
				end)

				releaseEvent = input.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						releaseEvent:Disconnect()
						mouseEvent:Disconnect()
						newGui:Destroy()
						dragOutline:Destroy()
						Explorer.Dragging = false

						for i = 1,#listEntries do
							if Lib.CheckMouseInGui(listEntries[i]) then
								local node = tree[i + Explorer.Index]
								if node then
									if selection.Map[node] then return end
									local newPar = node.Obj
									local sList = selection.List
									for i = 1,#sList do
										local n = sList[i]
										pcall(function() n.Obj.Parent = newPar end)
									end
									Explorer.ViewNode(sList[1])
								end
								break
							end
						end
					end
				end)
			end

			Explorer.NewListEntry = function(index)
				local newEntry = entryTemplate:Clone()
				newEntry.Position = UDim2.new(0,0,0,20*(index-1))

				local isRenaming = false

				newEntry.InputBegan:Connect(function(input)
					local node = tree[index + Explorer.Index]
					if not node or selection.Map[node] or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end

					newEntry.Indent.BackgroundColor3 = Settings.Theme.Button
					newEntry.Indent.BorderSizePixel = 0
					newEntry.Indent.BackgroundTransparency = 0
				end)

				newEntry.InputEnded:Connect(function(input)
					local node = tree[index + Explorer.Index]
					if not node or selection.Map[node] or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end

					newEntry.Indent.BackgroundTransparency = 1
				end)

				newEntry.MouseButton1Down:Connect(function()

				end)

				newEntry.MouseButton1Up:Connect(function()

				end)

				newEntry.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						local releaseEvent, mouseEvent

						local mouse = Main.Mouse or plr:GetMouse()
						local startX, startY

						if input.UserInputType == Enum.UserInputType.Touch then
							startX = input.Position.X
							startY = input.Position.Y
						else
							startX = mouse.X
							startY = mouse.Y
						end

						local listOffsetX = startX - treeFrame.AbsolutePosition.X
						local listOffsetY = startY - treeFrame.AbsolutePosition.Y

						releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								releaseEvent:Disconnect()
								mouseEvent:Disconnect()
							end
						end)

						mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
								local currentX, currentY

								if input.UserInputType == Enum.UserInputType.Touch then
									currentX = input.Position.X
									currentY = input.Position.Y
								else
									currentX = mouse.X
									currentY = mouse.Y
								end

								local deltaX = currentX - startX
								local deltaY = currentY - startY
								local dist = math.sqrt(deltaX^2 + deltaY^2)

								if dist > 5 then
									releaseEvent:Disconnect()
									mouseEvent:Disconnect()
									isRenaming = false
									Explorer.StartDrag(listOffsetX, listOffsetY)
								end
							end
						end)
					end
				end)

				newEntry.MouseButton2Down:Connect(function()

				end)

				newEntry.Indent.Expand.InputBegan:Connect(function(input)
					local node = tree[index + Explorer.Index]
					if not node or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end

					if input.UserInputType == Enum.UserInputType.Touch then
						Explorer.MiscIcons:DisplayByKey(newEntry.Indent.Expand.Icon, expanded[node] and "Collapse_Over" or "Expand_Over")
					elseif input.UserInputType == Enum.UserInputType.MouseMovement then
						Explorer.MiscIcons:DisplayByKey(newEntry.Indent.Expand.Icon, expanded[node] and "Collapse_Over" or "Expand_Over")
					end
				end)

				newEntry.Indent.Expand.InputEnded:Connect(function(input)
					local node = tree[index + Explorer.Index]
					if not node or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end

					if input.UserInputType == Enum.UserInputType.Touch then
						Explorer.MiscIcons:DisplayByKey(newEntry.Indent.Expand.Icon, expanded[node] and "Collapse" or "Expand")
					elseif input.UserInputType == Enum.UserInputType.MouseMovement then
						Explorer.MiscIcons:DisplayByKey(newEntry.Indent.Expand.Icon, expanded[node] and "Collapse" or "Expand")
					end
				end)

				newEntry.Indent.Expand.MouseButton1Down:Connect(function()
					local node = tree[index + Explorer.Index]
					if not node or #node == 0 then return end

					expanded[node] = not expanded[node]
					Explorer.Update()
					Explorer.Refresh()
				end)

				newEntry.Parent = treeFrame
				return newEntry
			end

			Explorer.Refresh = function()
				local maxNodes = math.max(math.ceil((treeFrame.AbsoluteSize.Y) / 20), 0)	
				local renameNodeVisible = false
				local isa = game.IsA

				for i = 1,maxNodes do
					local entry = listEntries[i]
					if not listEntries[i] then entry = Explorer.NewListEntry(i) listEntries[i] = entry Explorer.ClickSystem:Add(entry) end

					local node = tree[i + Explorer.Index]
					if node then
						local obj = node.Obj
						local depth = Explorer.EntryIndent*Explorer.NodeDepth(node)

						entry.Visible = true
						entry.Position = UDim2.new(0,-scrollH.Index,0,entry.Position.Y.Offset)
						entry.Size = UDim2.new(0,Explorer.ViewWidth,0,20)
						entry.Indent.EntryName.Text = tostring(node.Obj)
						entry.Indent.Position = UDim2.new(0,depth,0,0)
						entry.Indent.Size = UDim2.new(1,-depth,1,0)

						entry.Indent.EntryName.TextTruncate = (Settings.Explorer.UseNameWidth and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd)

						Explorer.MiscIcons:DisplayExplorerIcons(entry.Indent.Icon, obj.ClassName)

						if selection.Map[node] then
							entry.Indent.BackgroundColor3 = Settings.Theme.ListSelection
							entry.Indent.BorderSizePixel = 0
							entry.Indent.BackgroundTransparency = 0
						else
							if Lib.CheckMouseInGui(entry) then
								entry.Indent.BackgroundColor3 = Settings.Theme.Button
							else
								entry.Indent.BackgroundTransparency = 1
							end
						end

						if node == renamingNode then
							renameNodeVisible = true
							renameBox.Position = UDim2.new(0,depth+25-scrollH.Index,0,entry.Position.Y.Offset+2)
							renameBox.Visible = true
						end

						if #node > 0 and expanded[node] ~= 0 then
							if Lib.CheckMouseInGui(entry.Indent.Expand) then
								Explorer.MiscIcons:DisplayByKey(entry.Indent.Expand.Icon, expanded[node] and "Collapse_Over" or "Expand_Over")
							else
								Explorer.MiscIcons:DisplayByKey(entry.Indent.Expand.Icon, expanded[node] and "Collapse" or "Expand")
							end
							entry.Indent.Expand.Visible = true
						else
							entry.Indent.Expand.Visible = false
						end
					else
						entry.Visible = false
					end
				end

				if not renameNodeVisible then
					renameBox.Visible = false
				end

				for i = maxNodes+1, #listEntries do
					Explorer.ClickSystem:Remove(listEntries[i])
					listEntries[i]:Destroy()
					listEntries[i] = nil
				end
			end

			Explorer.PerformUpdate = function(instant)
				updateDebounce = true
				Lib.FastWait(not instant and 0.1)
				if not updateDebounce then return end
				updateDebounce = false
				if not Explorer.Window:IsVisible() then return end
				Explorer.Update()
				Explorer.Refresh()
			end

			Explorer.ForceUpdate = function(norefresh)
				updateDebounce = false
				Explorer.Update()
				if not norefresh then Explorer.Refresh() end
			end

			Explorer.PerformRefresh = function()
				refreshDebounce = true
				Lib.FastWait(0.1)
				refreshDebounce = false
				if updateDebounce or not Explorer.Window:IsVisible() then return end
				Explorer.Refresh()
			end

			Explorer.IsNodeVisible = function(node)
				if not node then return end

				local curNode = node.Parent
				while curNode do
					if not expanded[curNode] then return false end
					curNode = curNode.Parent
				end
				return true
			end

			Explorer.NodeDepth = function(node)
				local depth = 0

				if node == nilNode then
					return 1
				end

				local curNode = node.Parent
				while curNode do
					if curNode == nilNode then depth = depth + 1 end
					curNode = curNode.Parent
					depth = depth + 1
				end
				return depth
			end

			Explorer.SetupConnections = function()
				if descendantAddedCon then descendantAddedCon:Disconnect() end
				if descendantRemovingCon then descendantRemovingCon:Disconnect() end
				if itemChangedCon then itemChangedCon:Disconnect() end

				if Main.Elevated then
					descendantAddedCon = game.DescendantAdded:Connect(addObject)
					descendantRemovingCon = game.DescendantRemoving:Connect(removeObject)
				else
					descendantAddedCon = game.DescendantAdded:Connect(function(obj) pcall(addObject,obj) end)
					descendantRemovingCon = game.DescendantRemoving:Connect(function(obj) pcall(removeObject,obj) end)
				end

				if Settings.Explorer.UseNameWidth then
					itemChangedCon = game.ItemChanged:Connect(function(obj,prop)
						if prop == "Parent" and nodes[obj] then
							moveObject(obj)
						elseif prop == "Name" and nodes[obj] then
							nodes[obj].NameWidth = nil
						end
					end)
				else
					itemChangedCon = game.ItemChanged:Connect(function(obj,prop)
						if prop == "Parent" and nodes[obj] then
							moveObject(obj)
						end
					end)
				end
			end

			Explorer.ViewNode = function(node)
				if not node then return end

				Explorer.MakeNodeVisible(node)
				Explorer.ForceUpdate(true)
				local visibleSpace = scrollV.VisibleSpace

				for i,v in next,tree do
					if v == node then
						local relative = i - 1
						if Explorer.Index > relative then
							scrollV.Index = relative
						elseif Explorer.Index + visibleSpace - 1 <= relative then
							scrollV.Index = relative - visibleSpace + 2
						end
					end
				end

				scrollV:Update() Explorer.Index = scrollV.Index
				Explorer.Refresh()
			end

			Explorer.ViewObj = function(obj)
				Explorer.ViewNode(nodes[obj])
			end

			Explorer.MakeNodeVisible = function(node,expandRoot)
				if not node then return end

				local hasExpanded = false

				if expandRoot and not expanded[node] then
					expanded[node] = true
					hasExpanded = true
				end

				local currentNode = node.Parent
				while currentNode do
					hasExpanded = true
					expanded[currentNode] = true
					currentNode = currentNode.Parent
				end

				if hasExpanded and not updateDebounce then
					coroutine.wrap(Explorer.PerformUpdate)(true)
				end
			end

			Explorer.ShowRightClick = function(MousePos)
				local Mouse = MousePos or Main.Mouse
				local context = Explorer.RightClickContext
				local absoluteSize = context.Gui.AbsoluteSize
				context.MaxHeight = (absoluteSize.Y <= 600 and (absoluteSize.Y - 40)) or nil
				context:Clear()

				local sList = selection.List
				local sMap = selection.Map
				local emptyClipboard = #clipboard == 0
				local presentClasses = {}
				local apiClasses = API.Classes

				for i = 1, #sList do
					local node = sList[i]
					local class = node.Class
					local obj = node.Obj

					if not presentClasses.isViableDecompileScript then
						presentClasses.isViableDecompileScript = env.isViableDecompileScript(obj)
					end
					if not class then
						class = obj.ClassName
						node.Class = class
					end

					local curClass = apiClasses[class]
					while curClass and not presentClasses[curClass.Name] do
						presentClasses[curClass.Name] = true
						curClass = curClass.Superclass
					end
				end

				context:AddRegistered("CUT")
				context:AddRegistered("COPY")
				context:AddRegistered("PASTE", emptyClipboard)
				context:AddRegistered("DUPLICATE")
				context:AddRegistered("DELETE")
				context:AddRegistered("RENAME", #sList ~= 1)

				context:AddDivider()
				context:AddRegistered("GROUP")
				context:AddRegistered("UNGROUP")
				context:AddRegistered("SELECT_CHILDREN")
				context:AddRegistered("JUMP_TO_PARENT")
				context:AddRegistered("EXPAND_ALL")
				context:AddRegistered("COLLAPSE_ALL")

				context:AddDivider()

				if expanded == Explorer.SearchExpanded then context:AddRegistered("CLEAR_SEARCH_AND_JUMP_TO") end
				if env.setclipboard then context:AddRegistered("COPY_PATH") end
				context:AddRegistered("INSERT_OBJECT")
				context:AddRegistered("SELECT_SERVICE")
				
				
				
				
				

				context:QueueDivider()

				if presentClasses["BasePart"] or presentClasses["Model"] then
					context:AddRegistered("TELEPORT_TO")
					context:AddRegistered("VIEW_OBJECT")
				end
				if presentClasses["Tween"] then context:AddRegistered("PLAY_TWEEN") end
				if presentClasses["Animation"] then
					context:AddRegistered("LOAD_ANIMATION")
					context:AddRegistered("STOP_ANIMATION")
				end

				if presentClasses["TouchTransmitter"] then context:AddRegistered("FIRE_TOUCHTRANSMITTER", firetouchinterest == nil) end
				if presentClasses["ClickDetector"] then context:AddRegistered("FIRE_CLICKDETECTOR", fireclickdetector == nil) end
				if presentClasses["ProximityPrompt"] then context:AddRegistered("FIRE_PROXIMITYPROMPT", fireproximityprompt == nil) end

				if presentClasses["Player"] then context:AddRegistered("SELECT_CHARACTER")context:AddRegistered("VIEW_PLAYER") end
				if presentClasses["Players"] then
					context:AddRegistered("SELECT_LOCAL_PLAYER")
					context:AddRegistered("SELECT_ALL_CHARACTERS")
				end

				if presentClasses["LuaSourceContainer"] then
					context:AddRegistered("VIEW_SCRIPT", not presentClasses.isViableDecompileScript or env.decompile == nil)
					context:AddRegistered("SAVE_SCRIPT", not presentClasses.isViableDecompileScript or env.decompile == nil or env.writefile == nil)
					context:AddRegistered("SAVE_BYTECODE", not presentClasses.isViableDecompileScript or env.getscriptbytecode == nil or env.writefile == nil)
				end

				if sMap[nilNode] then
					context:AddRegistered("REFRESH_NIL")
					context:AddRegistered("HIDE_NIL")
				end

				Explorer.LastRightClickX, Explorer.LastRightClickY = Mouse.X, Mouse.Y
				context:Show(Mouse.X, Mouse.Y)
			end

			Explorer.InitRightClick = function()
				local context = Lib.ContextMenu.new()

				context:Register("CUT",{Name = "Cut", IconMap = Explorer.MiscIcons, Icon = "Cut", DisabledIcon = "Cut_Disabled", Shortcut = "Ctrl+Z", OnClick = function()
					local destroy,clone = game.Destroy,game.Clone
					local sList,newClipboard = selection.List,{}
					local count = 1
					for i = 1,#sList do
						local inst = sList[i].Obj
						local s,cloned = pcall(clone,inst)
						if s and cloned then
							newClipboard[count] = cloned
							count = count + 1
						end
						pcall(destroy,inst)
					end
					clipboard = newClipboard
					selection:Clear()
				end})

				context:Register("COPY",{Name = "Copy", IconMap = Explorer.MiscIcons, Icon = "Copy", DisabledIcon = "Copy_Disabled", Shortcut = "Ctrl+C", OnClick = function()
					local clone = game.Clone
					local sList,newClipboard = selection.List,{}
					local count = 1
					for i = 1,#sList do
						local inst = sList[i].Obj
						local s,cloned = pcall(clone,inst)
						if s and cloned then
							newClipboard[count] = cloned
							count = count + 1
						end
					end
					clipboard = newClipboard
				end})

				context:Register("PASTE",{Name = "Paste Into", IconMap = Explorer.MiscIcons, Icon = "Paste", DisabledIcon = "Paste_Disabled", Shortcut = "Ctrl+Shift+V", OnClick = function()
					local sList = selection.List
					local newSelection = {}
					local count = 1
					for i = 1,#sList do
						local node = sList[i]
						local inst = node.Obj
						Explorer.MakeNodeVisible(node,true)
						for c = 1,#clipboard do
							local cloned = clipboard[c]:Clone()
							if cloned then
								cloned.Parent = inst
								local clonedNode = nodes[cloned]
								if clonedNode then newSelection[count] = clonedNode count = count + 1 end
							end
						end
					end
					selection:SetTable(newSelection)

					if #newSelection > 0 then
						Explorer.ViewNode(newSelection[1])
					end
				end})

				context:Register("DUPLICATE",{Name = "Duplicate", IconMap = Explorer.MiscIcons, Icon = "Copy", DisabledIcon = "Copy_Disabled", Shortcut = "Ctrl+D", OnClick = function()
					local clone = game.Clone
					local sList = selection.List
					local newSelection = {}
					local count = 1
					for i = 1,#sList do
						local node = sList[i]
						local inst = node.Obj
						local instPar = node.Parent and node.Parent.Obj
						Explorer.MakeNodeVisible(node)
						local s,cloned = pcall(clone,inst)
						if s and cloned then
							cloned.Parent = instPar
							local clonedNode = nodes[cloned]
							if clonedNode then newSelection[count] = clonedNode count = count + 1 end
						end
					end

					selection:SetTable(newSelection)
					if #newSelection > 0 then
						Explorer.ViewNode(newSelection[1])
					end
				end})

				context:Register("DELETE",{Name = "Delete", IconMap = Explorer.MiscIcons, Icon = "Delete", DisabledIcon = "Delete_Disabled", Shortcut = "Del", OnClick = function()
					local destroy = game.Destroy
					local sList = selection.List
					for i = 1,#sList do
						pcall(destroy,sList[i].Obj)
					end
					selection:Clear()
				end})

				context:Register("RENAME",{Name = "Rename", IconMap = Explorer.MiscIcons, Icon = "Rename", DisabledIcon = "Rename_Disabled", Shortcut = "F2", OnClick = function()
					local sList = selection.List
					if sList[1] then
						Explorer.SetRenamingNode(sList[1])
					end
				end})

				context:Register("GROUP",{Name = "Group", IconMap = Explorer.MiscIcons, Icon = "Group", DisabledIcon = "Group_Disabled", Shortcut = "Ctrl+G", OnClick = function()
					local sList = selection.List
					if #sList == 0 then return end

					local model = Instance.new("Model",sList[#sList].Obj.Parent)
					for i = 1,#sList do
						pcall(function() sList[i].Obj.Parent = model end)
					end

					if nodes[model] then
						selection:Set(nodes[model])
						Explorer.ViewNode(nodes[model])
					end
				end})

				context:Register("UNGROUP",{Name = "Ungroup", IconMap = Explorer.MiscIcons, Icon = "Ungroup", DisabledIcon = "Ungroup_Disabled", Shortcut = "Ctrl+U", OnClick = function()
					local newSelection = {}
					local count = 1
					local isa = game.IsA

					local function ungroup(node)
						local par = node.Parent.Obj
						local ch = {}
						local chCount = 1

						for i = 1,#node do
							local n = node[i]
							newSelection[count] = n
							ch[chCount] = n
							count = count + 1
							chCount = chCount + 1
						end

						for i = 1,#ch do
							pcall(function() ch[i].Obj.Parent = par end)
						end

						node.Obj:Destroy()
					end

					for i,v in next,selection.List do
						if isa(v.Obj,"Model") then
							ungroup(v)
						end
					end

					selection:SetTable(newSelection)
					if #newSelection > 0 then
						Explorer.ViewNode(newSelection[1])
					end
				end})

				context:Register("SELECT_CHILDREN",{Name = "Select Children", IconMap = Explorer.MiscIcons, Icon = "SelectChildren", DisabledIcon = "SelectChildren_Disabled", OnClick = function()
					local newSelection = {}
					local count = 1
					local sList = selection.List

					for i = 1,#sList do
						local node = sList[i]
						for ind = 1,#node do
							local cNode = node[ind]
							if ind == 1 then Explorer.MakeNodeVisible(cNode) end

							newSelection[count] = cNode
							count = count + 1
						end
					end

					selection:SetTable(newSelection)
					if #newSelection > 0 then
						Explorer.ViewNode(newSelection[1])
					else
						Explorer.Refresh()
					end
				end})

				context:Register("JUMP_TO_PARENT",{Name = "Jump to Parent", IconMap = Explorer.MiscIcons, Icon = "JumpToParent", OnClick = function()
					local newSelection = {}
					local count = 1
					local sList = selection.List

					for i = 1,#sList do
						local node = sList[i]
						if node.Parent then
							newSelection[count] = node.Parent
							count = count + 1
						end
					end

					selection:SetTable(newSelection)
					if #newSelection > 0 then
						Explorer.ViewNode(newSelection[1])
					else
						Explorer.Refresh()
					end
				end})

				context:Register("TELEPORT_TO",{Name = "Teleport To", IconMap = Explorer.MiscIcons, Icon = "TeleportTo", OnClick = function()
					local sList = selection.List
					local plrRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")

					if not plrRP then return end

					for _,node in next, sList do
						local Obj = node.Obj

						if Obj:IsA("BasePart") then
							if Obj.CanCollide then
								plr.Character:MoveTo(Obj.Position)
							else
								plrRP.CFrame = CFrame.new(Obj.Position + Settings.Explorer.TeleportToOffset)
							end
							break
						elseif Obj:IsA("Model") then
							if Obj.PrimaryPart then
								if Obj.PrimaryPart.CanCollide then
									plr.Character:MoveTo(Obj.PrimaryPart.Position)
								else
									plrRP.CFrame = CFrame.new(Obj.PrimaryPart.Position + Settings.Explorer.TeleportToOffset)
								end
								break
							else
								local part = Obj:FindFirstChildWhichIsA("BasePart", true)
								if part and nodes[part] then
									if part.CanCollide then
										plr.Character:MoveTo(part.Position)
									else
										plrRP.CFrame = CFrame.new(part.Position + Settings.Explorer.TeleportToOffset)
									end
									break
								elseif Obj.WorldPivot then
									plrRP.CFrame = Obj.WorldPivot
								end
							end
						end
					end
				end})

				local OldAnimation
				context:Register("PLAY_TWEEN",{Name = "Play Tween", IconMap = Explorer.MiscIcons, Icon = "Play", OnClick = function()
					local sList = selection.List

					for i = 1, #sList do
						local node = sList[i]
						local Obj = node.Obj

						if Obj:IsA("Tween") then Obj:Play() end
					end
				end})

				local OldAnimation
				context:Register("LOAD_ANIMATION",{Name = "Load Animation", IconMap = Explorer.MiscIcons, Icon = "Play", OnClick = function()
					local sList = selection.List

					local Humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
					if not Humanoid then return end

					for i = 1, #sList do
						local node = sList[i]
						local Obj = node.Obj

						if Obj:IsA("Animation") then
							if OldAnimation then OldAnimation:Stop() end
							OldAnimation = Humanoid:LoadAnimation(Obj)
							OldAnimation:Play()
							break
						end
					end
				end})

				context:Register("STOP_ANIMATION",{Name = "Stop Animation", IconMap = Explorer.MiscIcons, Icon = "Pause", OnClick = function()
					local sList = selection.List

					local Humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
					if not Humanoid then return end

					for i = 1, #sList do
						local node = sList[i]
						local Obj = node.Obj

						if Obj:IsA("Animation") then
							if OldAnimation then OldAnimation:Stop() end
							Humanoid:LoadAnimation(Obj):Stop()
							break
						end
					end
				end})

				context:Register("EXPAND_ALL",{Name = "Expand All", OnClick = function()
					local sList = selection.List

					local function expand(node)
						expanded[node] = true
						for i = 1,#node do
							if #node[i] > 0 then
								expand(node[i])
							end
						end
					end

					for i = 1,#sList do
						expand(sList[i])
					end

					Explorer.ForceUpdate()
				end})

				context:Register("COLLAPSE_ALL",{Name = "Collapse All", OnClick = function()
					local sList = selection.List

					local function expand(node)
						expanded[node] = nil
						for i = 1,#node do
							if #node[i] > 0 then
								expand(node[i])
							end
						end
					end

					for i = 1,#sList do
						expand(sList[i])
					end

					Explorer.ForceUpdate()
				end})

				context:Register("CLEAR_SEARCH_AND_JUMP_TO",{Name = "Clear Search and Jump to", OnClick = function()
					local newSelection = {}
					local count = 1
					local sList = selection.List

					for i = 1,#sList do
						newSelection[count] = sList[i]
						count = count + 1
					end

					selection:SetTable(newSelection)
					Explorer.ClearSearch()
					if #newSelection > 0 then
						Explorer.ViewNode(newSelection[1])
					end
				end})

				
				local clth = function(str)
					if str:sub(1, 28) == "game:GetService(\"Workspace\")" then str = str:gsub("game:GetService%(\"Workspace\"%)", "workspace", 1) end
					if str:sub(1, 27 + #plr.Name) == "game:GetService(\"Players\")." .. plr.Name then str = str:gsub("game:GetService%(\"Players\"%)." .. plr.Name, "game:GetService(\"Players\").LocalPlayer", 1) end
					return str
				end

				context:Register("COPY_PATH",{Name = "Copy Path", IconMap = Explorer.ClassIcons, Icon = 50, OnClick = function()
					local sList = selection.List
					if #sList == 1 then
						env.setclipboard(clth(Explorer.GetInstancePath(sList[1].Obj)))
					elseif #sList > 1 then
						local resList = {"{"}
						local count = 2
						for i = 1,#sList do
							local path = "\t"..clth(Explorer.GetInstancePath(sList[i].Obj))..","
							if #path > 0 then
								resList[count] = path
								count = count+1
							end
						end
						resList[count] = "}"
						env.setclipboard(table.concat(resList,"\n"))
					end
				end})

				context:Register("INSERT_OBJECT",{Name = "Insert Object", IconMap = Explorer.MiscIcons, Icon = "InsertObject", OnClick = function()
					local mouse = Main.Mouse
					local x,y = Explorer.LastRightClickX or mouse.X, Explorer.LastRightClickY or mouse.Y
					Explorer.InsertObjectContext:Show(x,y)
				end})
				context:Register("SELECT_SERVICE",{Name = "Select Service", IconMap = Explorer.ClassIcons, Icon = 1, OnClick = function()
					local mouse = Main.Mouse
					local x,y = Explorer.LastRightClickX or mouse.X, Explorer.LastRightClickY or mouse.Y
					if Explorer.ServiceContext then Explorer.ServiceContext:Show(x,y) end
				end})

				



















				context:Register("VIEW_OBJECT",{Name = "View Object (Right click to reset)", IconMap = Explorer.ClassIcons, Icon = 5, OnClick = function()
					local sList = selection.List
					local isa = game.IsA

					for i = 1,#sList do
						local node = sList[i]

						if isa(node.Obj,"BasePart") or isa(node.Obj, "Model") then
							workspace.CurrentCamera.CameraSubject = node.Obj
							break
						end
					end
				end, OnRightClick = function()
					workspace.CurrentCamera.CameraSubject = plr.Character
				end})

				context:Register("FIRE_TOUCHTRANSMITTER",{Name = "Fire TouchTransmitter", IconMap = Explorer.ClassIcons, Icon = 37, OnClick = function()
					local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
					if not hrp then return end
					for _, v in ipairs(selection.List) do if v.Obj and v.Obj:IsA("TouchTransmitter") then firetouchinterest(hrp, v.Obj.Parent, 0) end end
				end})

				context:Register("FIRE_CLICKDETECTOR",{Name = "Fire ClickDetector", IconMap = Explorer.ClassIcons, Icon = 41, OnClick = function()
					local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
					if not hrp then return end
					for _, v in ipairs(selection.List) do if v.Obj and v.Obj:IsA("ClickDetector") then fireclickdetector(v.Obj) end end
				end})

				context:Register("FIRE_PROXIMITYPROMPT",{Name = "Fire ProximityPrompt", IconMap = Explorer.ClassIcons, Icon = 124, OnClick = function()
					local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
					if not hrp then return end
					for _, v in ipairs(selection.List) do if v.Obj and v.Obj:IsA("ProximityPrompt") then fireproximityprompt(v.Obj) end end
				end})

				context:Register("VIEW_SCRIPT",{Name = "View Script", IconMap = Explorer.MiscIcons, Icon = "ViewScript", OnClick = function()
					local scr = selection.List[1] and selection.List[1].Obj
					if scr then ScriptViewer.ViewScript(scr) end
				end})

				context:Register("SAVE_SCRIPT",{Name = "Save Script", IconMap = Explorer.MiscIcons, Icon = "Save", OnClick = function()
					for _, v in next, selection.List do
						if v.Obj:IsA("LuaSourceContainer") and env.isViableDecompileScript(v.Obj) then
							local success, source = pcall(env.decompile, v.Obj)
							if not success then source = "Decompiler error: " .. tostring(source) elseif type(source) ~= "string" then source = "Decompiler returned no source" end
							local fileName = ("%i.%s.%s.Source.txt"):format(game.PlaceId, v.Obj.ClassName, env.parsefile(v.Obj.Name))
							env.writefile(fileName, source)
							task.wait(0.2)
						end
					end
				end})

				context:Register("SAVE_BYTECODE",{Name = "Save Script Bytecode", IconMap = Explorer.MiscIcons, Icon = "Save", OnClick = function()
					for _, v in next, selection.List do
						if v.Obj:IsA("LuaSourceContainer") and env.isViableDecompileScript(v.Obj) then
							local success, bytecode = pcall(getscriptbytecode, v.Obj)
							if success and type(bytecode) == "string" then
								local fileName = ("%i.%s.%s.Bytecode.txt"):format(game.PlaceId, v.Obj.ClassName, env.parsefile(v.Obj.Name))
								env.writefile(fileName, bytecode)
								task.wait(0.2)
							end
						end
					end
				end})

				context:Register("SELECT_CHARACTER",{Name = "Select Character", IconMap = Explorer.ClassIcons, Icon = 9, OnClick = function()
					local newSelection = {}
					local count = 1
					local sList = selection.List
					local isa = game.IsA

					for i = 1,#sList do
						local node = sList[i]
						if isa(node.Obj,"Player") and nodes[node.Obj.Character] then
							newSelection[count] = nodes[node.Obj.Character]
							count = count + 1
						end
					end

					selection:SetTable(newSelection)
					if #newSelection > 0 then
						Explorer.ViewNode(newSelection[1])
					else
						Explorer.Refresh()
					end
				end})

				context:Register("VIEW_PLAYER",{Name = "View Player", IconMap = Explorer.ClassIcons, Icon = 5, OnClick = function()
					local newSelection = {}
					local count = 1
					local sList = selection.List
					local isa = game.IsA

					for i = 1,#sList do
						local node = sList[i]
						local Obj = node.Obj
						if Obj:IsA("Player") and Obj.Character then
							workspace.CurrentCamera.CameraSubject = Obj.Character
							break
						end
					end
				end})

				context:Register("SELECT_LOCAL_PLAYER",{Name = "Select Local Player", IconMap = Explorer.ClassIcons, Icon = 9, OnClick = function()
					pcall(function() if nodes[plr] then selection:Set(nodes[plr]) Explorer.ViewNode(nodes[plr]) end end)
				end})

				context:Register("SELECT_ALL_CHARACTERS",{Name = "Select All Characters", IconMap = Explorer.ClassIcons, Icon = 2, OnClick = function()
					local newSelection = {}
					local sList = selection.List

					for i,v in next, service.Players:GetPlayers() do
						if v.Character and nodes[v.Character] then
							if i == 1 then Explorer.MakeNodeVisible(v.Character) end
							table.insert(newSelection, nodes[v.Character])
						end
					end

					selection:SetTable(newSelection)
					if #newSelection > 0 then
						Explorer.ViewNode(newSelection[1])
					else
						Explorer.Refresh()
					end
				end})

				context:Register("REFRESH_NIL",{Name = "Refresh Nil Instances", OnClick = function()
					Explorer.RefreshNilInstances()
				end})

				context:Register("HIDE_NIL",{Name = "Hide Nil Instances", OnClick = function()
					Explorer.HideNilInstances()
				end})

				Explorer.RightClickContext = context
			end

			Explorer.HideNilInstances = function()
				table.clear(nilMap)

				local disconnectCon = Instance.new("Folder").ChildAdded:Connect(function() end).Disconnect
				for i,v in next,nilCons do
					disconnectCon(v[1])
					disconnectCon(v[2])
				end
				table.clear(nilCons)

				for i = 1,#nilNode do
					coroutine.wrap(removeObject)(nilNode[i].Obj)
				end

				Explorer.Update()
				Explorer.Refresh()
			end

			Explorer.RefreshNilInstances = function()
				if not env.getnilinstances then return end

				local nilInsts = env.getnilinstances()
				local game = game
				local getDescs = game.GetDescendants
				
				
				
				
				
				

				for i = 1,#nilInsts do
					local obj = nilInsts[i]
					if obj ~= game then
						nilMap[obj] = true
						

						local descs = getDescs(obj)
						for j = 1,#descs do
							nilMap[descs[j]] = true
						end
					end
				end

				
		







				

				for i = 1,#nilInsts do
					local obj = nilInsts[i]
					local node = nodes[obj]
					if not node then coroutine.wrap(addObject)(obj) end
				end

		


















				
				

				Explorer.Update()
				Explorer.Refresh()
			end

			Explorer.GetInstancePath = function(obj)
				local ffc = game.FindFirstChild
				local getCh = game.GetChildren
				local path = ""
				local curObj = obj
				local ts = tostring
				local match = string.match
				local gsub = string.gsub
				local tableFind = table.find
				local useGetCh = Settings.Explorer.CopyPathUseGetChildren
				local formatLuaString = Lib.FormatLuaString

				while curObj do
					if curObj == game then
						path = "game"..path
						break
					end

					local className = curObj.ClassName
					local curName = ts(curObj)
					local indexName
					if match(curName,"^[%a_][%w_]*$") then
						indexName = "."..curName
					else
						local cleanName = formatLuaString(curName)
						indexName = '["'..cleanName..'"]'
					end

					local parObj = curObj.Parent
					if parObj then
						local fc = ffc(parObj,curName)
						if useGetCh and fc and fc ~= curObj then
							local parCh = getCh(parObj)
							local fcInd = tableFind(parCh,curObj)
							indexName = ":GetChildren()["..fcInd.."]"
						elseif parObj == game and API.Classes[className] and API.Classes[className].Tags.Service then
							indexName = ':GetService("'..className..'")'
						end
					elseif parObj == nil then
						local getnil = "local getNil = function(name, class) for _, v in next, getnilinstances() do if v.ClassName == class and v.Name == name then return v end end end"
						local gotnil = "\n\ngetNil(\"%s\", \"%s\")"
						indexName = getnil .. gotnil:format(curObj.Name, className)
					end

					path = indexName..path
					curObj = parObj
				end

				return path
			end

			Explorer.DefaultProps = {
				["BasePart"] = {
					Position = function(Obj)
						local Player = service.Players.LocalPlayer
						if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
							Obj.Position = (Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10)).p
						end
						return Obj.Position
					end,
					Anchored = true
				},
				["GuiObject"] = {
					Position = function(Obj) return (Obj.Parent:IsA("ScreenGui") and UDim2.new(0.5, 0, 0.5, 0)) or Obj.Position end,
					Active = true
				}
			}

			Explorer.InitInsertObject = function()
				local context = Lib.ContextMenu.new()
				context.SearchEnabled = true
				context.MaxHeight = 400
				context:ApplyTheme({
					ContentColor = Settings.Theme.Main2,
					OutlineColor = Settings.Theme.Outline1,
					DividerColor = Settings.Theme.Outline1,
					TextColor = Settings.Theme.Text,
					HighlightColor = Settings.Theme.ButtonHover
				})

				local classes = {}
				for i,class in next,API.Classes do
					local tags = class.Tags
					if not tags.NotCreatable and not tags.Service then
						local rmdEntry = RMD.Classes[class.Name]
						classes[#classes+1] = {class,rmdEntry and rmdEntry.ClassCategory or "Uncategorized"}
					end
				end
				table.sort(classes,function(a,b)
					if a[2] ~= b[2] then
						return a[2] < b[2]
					else
						return a[1].Name < b[1].Name
					end
				end)

				local function defaultProps(obj)
					for class, props in pairs(Explorer.DefaultProps) do
						if obj:IsA(class) then
							for prop, value in pairs(props) do
								obj[prop] = (type(value) == "function" and value(obj)) or value
							end
						end
					end
				end

				local function onClick(className)
					local sList = selection.List
					local instNew = Instance.new
					for i = 1,#sList do
						local node = sList[i]
						local obj = node.Obj
						Explorer.MakeNodeVisible(node, true)
						local success, obj = pcall(instNew, className, obj)
						if success and obj then defaultProps(obj) end
					end
				end

				local lastCategory = ""
				for i = 1,#classes do
					local class = classes[i][1]
					local rmdEntry = RMD.Classes[class.Name]
					local iconInd = rmdEntry and tonumber(rmdEntry.ExplorerImageIndex) or 0
					local category = classes[i][2]

					if lastCategory ~= category then
						context:AddDivider(category)
						lastCategory = category
					end
					context:Add({Name = class.Name, IconMap = Explorer.ClassIcons, Icon = iconInd, OnClick = onClick})
				end

				Explorer.InsertObjectContext = context
				local serviceContext = Lib.ContextMenu.new()
				serviceContext.SearchEnabled = true
				serviceContext.MaxHeight = 400
				serviceContext:ApplyTheme({
					ContentColor = Settings.Theme.Main2,
					OutlineColor = Settings.Theme.Outline1,
					DividerColor = Settings.Theme.Outline1,
					TextColor = Settings.Theme.Text,
					HighlightColor = Settings.Theme.ButtonHover
				})
				local services = {}
				for _,class in pairs(API.Classes) do
					if class.Tags and class.Tags.Service then
						local rmdEntry = RMD.Classes[class.Name]
						services[#services+1] = {class.Name,rmdEntry and rmdEntry.ClassCategory or "Services",rmdEntry and tonumber(rmdEntry.ExplorerImageIndex) or 0}
					end
				end
				table.sort(services,function(a,b) if a[2]~=b[2] then return a[2]<b[2] end return a[1]<b[1] end)
				local function selectService(name)
					local ok,obj = pcall(game.GetService,game,name)
					if not ok or not obj then return end
					if not nodes[obj] then pcall(addObject,obj) end
					local node = nodes[obj]
					if node then
						selection:Set(node)
						Explorer.MakeNodeVisible(node,true)
						Explorer.ViewNode(node)
					end
				end
				local lastServiceCategory = ""
				for _,entry in ipairs(services) do
					if entry[2]~=lastServiceCategory then
						serviceContext:AddDivider(entry[2])
						lastServiceCategory=entry[2]
					end
					serviceContext:Add({Name=entry[1],IconMap=Explorer.ClassIcons,Icon=entry[3],OnClick=selectService})
				end
				Explorer.ServiceContext = serviceContext
			end

			Explorer._SearchFilters = {} do
				local Filters = Explorer._SearchFilters

				local function NewFilter(list, func)
					for _,v in next, list do
						Filters[v:lower() .. ":"] = func
					end
				end

				local Only = {
					remotes = {"RemoteEvent", "RemoteFunction", "BindableEvent", "BindableFunction"},
					scripts = {"Script", "LocalScript", "ModuleScript"},
					players = {"Player"}
				}

				NewFilter({"parent", "p"}, function(Obj, str) return Obj.Parent and (Obj.Parent.Name:lower()):find(str) end)
				NewFilter({"class", "c"}, function(Obj, str) return (Obj.ClassName:lower()):find(str) end)
				NewFilter({"isa", "i"}, function(Obj, str) return Obj:IsA(str) end)

				NewFilter({"only", "o"}, function(Obj, str)
					local Special = Only[str]
					return Special and table.find(Special, Obj.ClassName)
				end)
			end

			Explorer.DoSearch = function(query)
				table.clear(Explorer.SearchExpanded)
				table.clear(searchResults)
				expanded = (#query == 0 and Explorer.Expanded) or Explorer.SearchExpanded

				local tostr = tostring;
				local tfind = table.find;

				local Filters = Explorer._SearchFilters
				local expandTable = Explorer.SearchExpanded

				local allnodes = nodes[game]

				local defaultSearch = (function(Obj, str) return (Obj.Name:lower()):find(str, 1, true) end)

				local function searchTable(root, str, func)
					local expandedpar = false
					for _,node in ipairs(root) do
						if func(node.Obj, str) then
							expandTable[node] = 0
							searchResults[node] = true
							if not expandedpar then
								local parnode = node.Parent
								while parnode and (not searchResults[parnode] or expandTable[parnode] == 0) do
									expanded[parnode] = true
									searchResults[parnode] = true
									parnode = parnode.Parent
								end
								expandedpar = true
							end
						end

						if #node > 0 then searchTable(node, str, func) end
					end
				end

				local function Search(query)
					if query:len() == 0 then return end

					local lower = query:lower()
					local split = lower:split(":")
					local Filter = (Filters[split[1] .. ":"]) or nil

					if Filter then
						searchTable(allnodes, (split[2] or ""), Filter)
					else
						searchTable(allnodes, (lower or ""), defaultSearch)
					end
				end

				for _,v in ipairs(query:split(",")) do
					if v:len() > 0 then
						Search(v)
					end
				end

		


































































				Explorer.ForceUpdate()
			end

			Explorer.ClearSearch = function()
				Explorer.GuiElems.SearchBar.Text = ""
				expanded = Explorer.Expanded
				searchFunc = nil
			end

			Explorer.InitSearch = function()
				local TweenService = service.TweenService
				local SearchFrame = Explorer.GuiElems.ToolBar.SearchFrame
				local searchBox = SearchFrame.SearchBox
				Explorer.GuiElems.SearchBar = searchBox

				local TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint)
				local Tweens = {
					Start = TweenService:Create(SearchFrame.UIStroke, TweenInfo, { Color = Color3.fromRGB(0, 120, 215) }),
					End = TweenService:Create(SearchFrame.UIStroke, TweenInfo, { Color = Color3.fromRGB(42, 42, 42) })
				}

				searchBox.FocusLost:Connect(function() Tweens.End:Play() end)
				searchBox.Focused:Connect(function() Tweens.Start:Play() end)

				Lib.ViewportTextBox.convert(searchBox)

				searchBox.FocusLost:Connect(function()
					Explorer.DoSearch(searchBox.Text)
				end)
			end

			Explorer.InitEntryTemplate = function()
				entryTemplate = create({
					{1,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderColor3=Color3.new(0,0,0),Font=3,Name="Entry",Position=UDim2.new(0,1,0,1),Size=UDim2.new(0,250,0,20),Text="",TextSize=14,}},
					{2,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BackgroundTransparency=1,BorderColor3=Color3.new(0.33725491166115,0.49019610881805,0.73725491762161),BorderSizePixel=0,Name="Indent",Parent={1},Position=UDim2.new(0,20,0,0),Size=UDim2.new(1,-20,1,0),}},
					{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="EntryName",Parent={2},Position=UDim2.new(0,26,0,0),Size=UDim2.new(1,-26,1,0),Text="Workspace",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
					{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClipsDescendants=true,Font=3,Name="Expand",Parent={2},Position=UDim2.new(0,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextSize=14,}},
					{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5642383285",ImageRectOffset=Vector2.new(144,16),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={4},Position=UDim2.new(0,2,0,2),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
					{6,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ImageRectOffset=Vector2.new(304,0),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={2},Position=UDim2.new(0,4,0,2),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
				})

				local sys = Lib.ClickSystem.new()
				sys.AllowedButtons = {1,2}
				sys.OnDown:Connect(function(item,combo,button)
					local ind = table.find(listEntries,item)
					if not ind then return end
					local node = tree[ind + Explorer.Index]
					if not node then return end

					local entry = listEntries[ind]

					if button == 1 then
						if combo == 2 then
							if node.Obj:IsA("LuaSourceContainer") then
								ScriptViewer.ViewScript(node.Obj)
							elseif #node > 0 and expanded[node] ~= 0 then
								expanded[node] = not expanded[node]
								Explorer.Update()
							end
						end

						if Properties.SelectObject(node.Obj) then
							sys.IsRenaming = false
							return
						end

						sys.IsRenaming = selection.Map[node]

						if Lib.IsShiftDown() then
							if not selection.Piviot then return end

							local fromIndex = table.find(tree,selection.Piviot)
							local toIndex = table.find(tree,node)
							if not fromIndex or not toIndex then return end
							fromIndex,toIndex = math.min(fromIndex,toIndex),math.max(fromIndex,toIndex)

							local sList = selection.List
							for i = #sList,1,-1 do
								local elem = sList[i]
								if selection.ShiftSet[elem] then
									selection.Map[elem] = nil
									table.remove(sList,i)
								end
							end
							selection.ShiftSet = {}
							for i = fromIndex,toIndex do
								local elem = tree[i]
								if not selection.Map[elem] then
									selection.ShiftSet[elem] = true
									selection.Map[elem] = true
									sList[#sList+1] = elem
								end
							end
							selection.Changed:Fire()
						elseif Lib.IsCtrlDown() then
							selection.ShiftSet = {}
							if selection.Map[node] then selection:Remove(node) else selection:Add(node) end
							selection.Piviot = node
							sys.IsRenaming = false
						elseif not selection.Map[node] then
							selection.ShiftSet = {}
							selection:Set(node)
							selection.Piviot = node
						end
					elseif button == 2 then
						if Properties.SelectObject(node.Obj) then
							return
						end

						if not Lib.IsCtrlDown() and not selection.Map[node] then
							selection.ShiftSet = {}
							selection:Set(node)
							selection.Piviot = node
							Explorer.Refresh()
						end
					end

					Explorer.Refresh()
				end)

				sys.OnRelease:Connect(function(item,combo,button,position)
					local ind = table.find(listEntries,item)
					if not ind then return end
					local node = tree[ind + Explorer.Index]
					if not node then return end

					if button == 1 then
						if selection.Map[node] and not Lib.IsShiftDown() and not Lib.IsCtrlDown() then
							selection.ShiftSet = {}
							selection:Set(node)
							selection.Piviot = node
							Explorer.Refresh()
						end

						local id = sys.ClickId
						Lib.FastWait(sys.ComboTime)
						if combo == 1 and id == sys.ClickId and sys.IsRenaming and selection.Map[node] then
							Explorer.SetRenamingNode(node)
						end
					elseif button == 2 then
						Explorer.ShowRightClick(position)
					end
				end)
				Explorer.ClickSystem = sys
			end

			Explorer.InitDelCleaner = function()
				coroutine.wrap(function()
					local fw = Lib.FastWait
					while true do
						local processed = false
						local c = 0
						for _,node in next,nodes do
							if node.HasDel then
								local delInd
								for i = 1,#node do
									if node[i].Del then
										delInd = i
										break
									end
								end
								if delInd then
									for i = delInd+1,#node do
										local cn = node[i]
										if not cn.Del then
											node[delInd] = cn
											delInd = delInd+1
										end
									end
									for i = delInd,#node do
										node[i] = nil
									end
								end
								node.HasDel = false
								processed = true
								fw()
							end
							c = c + 1
							if c > 10000 then
								c = 0
								fw()
							end
						end
						if processed and not refreshDebounce then Explorer.PerformRefresh() end
						fw(0.5)
					end
				end)()
			end

			Explorer.UpdateSelectionVisuals = function()
				local holder = Explorer.SelectionVisualsHolder
				local isa = game.IsA
				local clone = game.Clone
				if not holder then
					holder = Instance.new("ScreenGui")
					holder.Name = "ExplorerSelections"
					holder.DisplayOrder = Main.DisplayOrders.Core
					Lib.ShowGui(holder)
					Explorer.SelectionVisualsHolder = holder
					Explorer.SelectionVisualCons = {}

					local guiTemplate = create({
						{1,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Size=UDim2.new(0,100,0,100),}},
						{2,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,-1,0,-1),Size=UDim2.new(1,2,0,1),}},
						{3,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,-1,1,0),Size=UDim2.new(1,2,0,1),}},
						{4,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,-1,0,0),Size=UDim2.new(0,1,1,0),}},
						{5,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BorderSizePixel=0,Parent={1},Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,1,1,0),}},
					})
					Explorer.SelectionVisualGui = guiTemplate

					local boxTemplate = Instance.new("SelectionBox")
					boxTemplate.LineThickness = 0.03
					boxTemplate.Color3 = Color3.fromRGB(0, 170, 255)
					Explorer.SelectionVisualBox = boxTemplate
				end
				holder:ClearAllChildren()

				
				for i,v in pairs(Explorer.SelectionVisualGui:GetChildren()) do
					v.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
				end

				local attachCons = Explorer.SelectionVisualCons
				for i = 1,#attachCons do
					attachCons[i].Destroy()
				end
				table.clear(attachCons)

				local partEnabled = Settings.Explorer.PartSelectionBox
				local guiEnabled = Settings.Explorer.GuiSelectionBox
				if not partEnabled and not guiEnabled then return end

				local svg = Explorer.SelectionVisualGui
				local svb = Explorer.SelectionVisualBox
				local attachTo = Lib.AttachTo
				local sList = selection.List
				local count = 1
				local boxCount = 0
				local workspaceNode = nodes[workspace]
				for i = 1,#sList do
					if boxCount > 1000 then break end
					local node = sList[i]
					local obj = node.Obj

					if node ~= workspaceNode then
						if isa(obj,"GuiObject") and guiEnabled then
							local newVisual = clone(svg)
							attachCons[count] = attachTo(newVisual,{Target = obj, Resize = true})
							count = count + 1
							newVisual.Parent = holder
							boxCount = boxCount + 1
						elseif isa(obj,"PVInstance") and partEnabled then
							local newBox = clone(svb)
							newBox.Adornee = obj
							newBox.Parent = holder
							boxCount = boxCount + 1
						end
					end
				end
			end

			Explorer.Init = function()
				Explorer.ClassIcons = Lib.IconMap.newLinear("rbxasset://textures/ClassImages.PNG", 16, 16)
				Explorer.MiscIcons = Main.MiscIcons

				clipboard = {}

				selection = Lib.Set.new()
				selection.ShiftSet = {}
				selection.Changed:Connect(Properties.ShowExplorerProps)
				Explorer.Selection = selection

				Explorer.InitRightClick()
				Explorer.InitInsertObject()
				Explorer.SetSortingEnabled(Settings.Explorer.Sorting)
				Explorer.Expanded = setmetatable({},{__mode = "k"})
				Explorer.SearchExpanded = setmetatable({},{__mode = "k"})
				expanded = Explorer.Expanded

				nilNode.Obj.Name = "Nil Instances"
				nilNode.Locked = true

				local explorerItems = create({
					{1,"Folder",{Name="ExplorerItems",}},
					{2,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="ToolBar",Parent={1},Size=UDim2.new(1,0,0,22),}},
					{3,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.1176470592618,0.1176470592618,0.1176470592618),BorderSizePixel=0,Name="SearchFrame",Parent={2},Position=UDim2.new(0,3,0,1),Size=UDim2.new(1,-6,0,18),}},
					{4,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Name="SearchBox",Parent={3},PlaceholderColor3=Color3.new(0.39215689897537,0.39215689897537,0.39215689897537),PlaceholderText="Search workspace",Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-24,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,}},
					{5,"UICorner",{CornerRadius=UDim.new(0,2),Parent={3},}},
					{6,"UIStroke",{Thickness=1.4,Parent={3},Color=Color3.fromRGB(42,42,42)}},
					{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Reset",Parent={3},Position=UDim2.new(1,-17,0,1),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
					{8,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5034718129",ImageColor3=Color3.new(0.39215686917305,0.39215686917305,0.39215686917305),Parent={7},Size=UDim2.new(0,16,0,16),}},
					{9,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Refresh",Parent={2},Position=UDim2.new(1,-20,0,1),Size=UDim2.new(0,18,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,Visible=false,}},
					{10,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5642310344",Parent={9},Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,12,0,12),}},
					{11,"Frame",{BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="ScrollCorner",Parent={1},Position=UDim2.new(1,-16,1,-16),Size=UDim2.new(0,16,0,16),Visible=false,}},
					{12,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClipsDescendants=true,Name="List",Parent={1},Position=UDim2.new(0,0,0,23),Size=UDim2.new(1,0,1,-23),}}
				})

				toolBar = explorerItems.ToolBar
				treeFrame = explorerItems.List

				Explorer.GuiElems.ToolBar = toolBar
				Explorer.GuiElems.TreeFrame = treeFrame

				scrollV = Lib.ScrollBar.new()		
				scrollV.WheelIncrement = 3
				scrollV.Gui.Position = UDim2.new(1,-16,0,23)
				scrollV:SetScrollFrame(treeFrame)
				scrollV.Scrolled:Connect(function()
					Explorer.Index = scrollV.Index
					Explorer.Refresh()
				end)

				scrollH = Lib.ScrollBar.new(true)
				scrollH.Increment = 5
				scrollH.WheelIncrement = Explorer.EntryIndent
				scrollH.Gui.Position = UDim2.new(0,0,1,-16)
				scrollH.Scrolled:Connect(function()
					Explorer.Refresh()
				end)

				local window = Lib.Window.new()
				Explorer.Window = window
				window:SetTitle("Explorer")
				window.GuiElems.Line.Position = UDim2.new(0,0,0,22)

				Explorer.InitEntryTemplate()
				toolBar.Parent = window.GuiElems.Content
				treeFrame.Parent = window.GuiElems.Content
				explorerItems.ScrollCorner.Parent = window.GuiElems.Content
				scrollV.Gui.Parent = window.GuiElems.Content
				scrollH.Gui.Parent = window.GuiElems.Content

				
				Explorer.InitRenameBox()
				Explorer.InitSearch()
				Explorer.InitDelCleaner()
				selection.Changed:Connect(Explorer.UpdateSelectionVisuals)

				
				window.GuiElems.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					if Explorer.Active then
						Explorer.UpdateView()
						Explorer.Refresh()
					end
				end)
				window.OnActivate:Connect(function()
					Explorer.Active = true
					Explorer.UpdateView()
					Explorer.Update()
					Explorer.Refresh()
				end)
				window.OnRestore:Connect(function()
					Explorer.Active = true
					Explorer.UpdateView()
					Explorer.Update()
					Explorer.Refresh()
				end)
				window.OnDeactivate:Connect(function() Explorer.Active = false end)
				window.OnMinimize:Connect(function() Explorer.Active = false end)

				
				autoUpdateSearch = Settings.Explorer.AutoUpdateSearch

				
				nodes[game] = {Obj = game}
				expanded[nodes[game]] = true

				
				if env.getnilinstances then
					nodes[nilNode.Obj] = nilNode
				end

				Explorer.SetupConnections()

				local insts = getDescendants(game)
				if Main.Elevated then
					for i = 1,#insts do
						local obj = insts[i]
						local par = nodes[ffa(obj,"Instance")]
						if not par then continue end
						local newNode = {
							Obj = obj,
							Parent = par,
						}
						nodes[obj] = newNode
						par[#par+1] = newNode
					end
				else
					for i = 1,#insts do
						local obj = insts[i]
						local s,parObj = pcall(ffa,obj,"Instance")
						local par = nodes[parObj]
						if not par then continue end
						local newNode = {
							Obj = obj,
							Parent = par,
						}
						nodes[obj] = newNode
						par[#par+1] = newNode
					end
				end
			end

			return Explorer
		end

		return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
	end,
	Properties = function()






		
		local Main,Lib,Apps,Settings 
		local Explorer, Properties, ScriptViewer, Notebook 
		local API,RMD,env,service,plr,create,createSimple 

		local function initDeps(data)
			Main = data.Main
			Lib = data.Lib
			Apps = data.Apps
			Settings = data.Settings

			API = data.API
			RMD = data.RMD
			env = data.env
			service = data.service
			plr = data.plr
			create = data.create
			createSimple = data.createSimple
		end

		local function initAfterMain()
			Explorer = Apps.Explorer
			Properties = Apps.Properties
			ScriptViewer = Apps.ScriptViewer
			Notebook = Apps.Notebook
		end

		local function main()
			local Properties = {}

			local window, toolBar, propsFrame
			local scrollV, scrollH
			local categoryOrder
			local props,viewList,expanded,indexableProps,propEntries,autoUpdateObjs = {},{},{},{},{},{}
			local inputBox,inputTextBox,inputProp
			local checkboxes,propCons = {},{}
			local table,string = table,string
			local getPropChangedSignal = game.GetPropertyChangedSignal
			local getAttributeChangedSignal = game.GetAttributeChangedSignal
			local isa = game.IsA
			local getAttribute = game.GetAttribute
			local setAttribute = game.SetAttribute

			Properties.GuiElems = {}
			Properties.Index = 0
			Properties.ViewWidth = 0
			Properties.MinInputWidth = 100
			Properties.EntryIndent = 16
			Properties.EntryOffset = 4
			Properties.NameWidthCache = {}
			Properties.SubPropCache = {}
			Properties.ClassLists = {}
			Properties.SearchText = ""

			Properties.AddAttributeProp = {Category = "Attributes", Class = "", Name = "", SpecialRow = "AddAttribute", Tags = {}}
			Properties.SoundPreviewProp = {Category = "Data", ValueType = {Name = "SoundPlayer"}, Class = "Sound", Name = "Preview", Tags = {}}

			Properties.IgnoreProps = {
				["DataModel"] = {
					["PrivateServerId"] = true,
					["PrivateServerOwnerId"] = true,
					["VIPServerId"] = true,
					["VIPServerOwnerId"] = true
				}
			}

			Properties.ExpandableTypes = {
				["Vector2"] = true,
				["Vector3"] = true,
				["UDim"] = true,
				["UDim2"] = true,
				["CFrame"] = true,
				["Rect"] = true,
				["PhysicalProperties"] = true,
				["Ray"] = true,
				["NumberRange"] = true,
				["Faces"] = true,
				["Axes"] = true
			}

			Properties.ExpandableProps = {
				["Sound.SoundId"] = true
			}

			Properties.CollapsedCategories = {
				["Surface Inputs"] = true,
				["Surface"] = true
			}

			Properties.ConflictSubProps = {
				["Vector2"] = {"X","Y"},
				["Vector3"] = {"X","Y","Z"},
				["UDim"] = {"Scale","Offset"},
				["UDim2"] = {"X","X.Scale","X.Offset","Y","Y.Scale","Y.Offset"},
				["CFrame"] = {"Position","Position.X","Position.Y","Position.Z",
					"RightVector","RightVector.X","RightVector.Y","RightVector.Z",
					"UpVector","UpVector.X","UpVector.Y","UpVector.Z",
					"LookVector","LookVector.X","LookVector.Y","LookVector.Z"},
				["Rect"] = {"Min.X","Min.Y","Max.X","Max.Y"},
				["PhysicalProperties"] = {"Density","Elasticity","ElasticityWeight","Friction","FrictionWeight"},
				["Ray"] = {"Origin","Origin.X","Origin.Y","Origin.Z","Direction","Direction.X","Direction.Y","Direction.Z"},
				["NumberRange"] = {"Min","Max"},
				["Faces"] = {"Back","Bottom","Front","Left","Right","Top"},
				["Axes"] = {"X","Y","Z"}
			}

			Properties.ConflictIgnore = {
				["BasePart"] = {
					["ResizableFaces"] = true
				}
			}

			Properties.RoundableTypes = {
				["float"] = true,
				["double"] = true,
				["Color3"] = true,
				["UDim"] = true,
				["UDim2"] = true,
				["Vector2"] = true,
				["Vector3"] = true,
				["NumberRange"] = true,
				["Rect"] = true,
				["NumberSequence"] = true,
				["ColorSequence"] = true,
				["Ray"] = true,
				["CFrame"] = true
			}

			Properties.TypeNameConvert = {
				["number"] = "double",
				["boolean"] = "bool"
			}

			Properties.ToNumberTypes = {
				["int"] = true,
				["int64"] = true,
				["float"] = true,
				["double"] = true
			}

			Properties.DefaultPropValue = {
				string = "",
				bool = false,
				double = 0,
				UDim = UDim.new(0,0),
				UDim2 = UDim2.new(0,0,0,0),
				BrickColor = BrickColor.new("Medium stone grey"),
				Color3 = Color3.new(1,1,1),
				Vector2 = Vector2.new(0,0),
				Vector3 = Vector3.new(0,0,0),
				NumberSequence = NumberSequence.new(1),
				ColorSequence = ColorSequence.new(Color3.new(1,1,1)),
				NumberRange = NumberRange.new(0),
				Rect = Rect.new(0,0,0,0)
			}

			Properties.AllowedAttributeTypes = {"string","boolean","number","UDim","UDim2","BrickColor","Color3","Vector2","Vector3","NumberSequence","ColorSequence","NumberRange","Rect"}

			Properties.StringToValue = function(prop,str)
				local typeData = prop.ValueType
				local typeName = typeData.Name

				if typeName == "string" or typeName == "Content" then
					return str
				elseif Properties.ToNumberTypes[typeName] then
					return tonumber(str)
				elseif typeName == "Vector2" then
					local vals = str:split(",")
					local x,y = tonumber(vals[1]),tonumber(vals[2])
					if x and y and #vals >= 2 then return Vector2.new(x,y) end
				elseif typeName == "Vector3" then
					local vals = str:split(",")
					local x,y,z = tonumber(vals[1]),tonumber(vals[2]),tonumber(vals[3])
					if x and y and z and #vals >= 3 then return Vector3.new(x,y,z) end
				elseif typeName == "UDim" then
					local vals = str:split(",")
					local scale,offset = tonumber(vals[1]),tonumber(vals[2])
					if scale and offset and #vals >= 2 then return UDim.new(scale,offset) end
				elseif typeName == "UDim2" then
					local vals = str:gsub("[{}]",""):split(",")
					local xScale,xOffset,yScale,yOffset = tonumber(vals[1]),tonumber(vals[2]),tonumber(vals[3]),tonumber(vals[4])
					if xScale and xOffset and yScale and yOffset and #vals >= 4 then return UDim2.new(xScale,xOffset,yScale,yOffset) end
				elseif typeName == "CFrame" then
					local vals = str:split(",")
					local s,result = pcall(CFrame.new, unpack(vals))
					if s and #vals >= 12 then return result end
				elseif typeName == "Rect" then
					local vals = str:split(",")
					local s,result = pcall(Rect.new,unpack(vals))
					if s and #vals >= 4 then return result end
				elseif typeName == "Ray" then
					local vals = str:gsub("[{}]",""):split(",")
					local s,origin = pcall(Vector3.new,unpack(vals,1,3))
					local s2,direction = pcall(Vector3.new,unpack(vals,4,6))
					if s and s2 and #vals >= 6 then return Ray.new(origin,direction) end
				elseif typeName == "NumberRange" then
					local vals = str:split(",")
					local s,result = pcall(NumberRange.new,unpack(vals))
					if s and #vals >= 1 then return result end
				elseif typeName == "Color3" then
					local vals = str:gsub("[{}]",""):split(",")
					local s,result = pcall(Color3.fromRGB,unpack(vals))
					if s and #vals >= 3 then return result end
				end

				return nil
			end

			Properties.ValueToString = function(prop,val)
				local typeData = prop.ValueType
				local typeName = typeData.Name

				if typeName == "Color3" then
					return Lib.ColorToBytes(val)
				elseif typeName == "NumberRange" then
					return val.Min..", "..val.Max
				end

				return tostring(val)
			end

			Properties.GetIndexableProps = function(obj,classData)
				if not Main.Elevated then
					if not pcall(function() return obj.ClassName end) then return nil end
				end

				local ignoreProps = Properties.IgnoreProps[classData.Name] or {}

				local result = {}
				local count = 1
				local props = classData.Properties
				for i = 1,#props do
					local prop = props[i]
					if not ignoreProps[prop.Name] then
						local s = pcall(function() return obj[prop.Name] end)
						if s then
							result[count] = prop
							count = count + 1
						end
					end
				end

				return result
			end

			Properties.FindFirstObjWhichIsA = function(class)
				local classList = Properties.ClassLists[class] or {}
				if classList and #classList > 0 then
					return classList[1]
				end

				return nil
			end

			Properties.ComputeConflicts = function(p)
				local maxConflictCheck = Settings.Properties.MaxConflictCheck
				local sList = Explorer.Selection.List
				local classLists = Properties.ClassLists
				local stringSplit = string.split
				local t_clear = table.clear
				local conflictIgnore = Properties.ConflictIgnore
				local conflictMap = {}
				local propList = p and {p} or props

				if p then
					local gName = p.Class.."."..p.Name
					autoUpdateObjs[gName] = nil
					local subProps = Properties.ConflictSubProps[p.ValueType.Name] or {}
					for i = 1,#subProps do
						autoUpdateObjs[gName.."."..subProps[i]] = nil
					end
				else
					table.clear(autoUpdateObjs)
				end

				if #sList > 0 then
					for i = 1,#propList do
						local prop = propList[i]
						local propName,propClass = prop.Name,prop.Class
						local typeData = prop.RootType or prop.ValueType
						local typeName = typeData.Name
						local attributeName = prop.AttributeName
						local gName = propClass.."."..propName

						local checked = 0
						local subProps = Properties.ConflictSubProps[typeName] or {}
						local subPropCount = #subProps
						local toCheck = subPropCount + 1
						local conflictsFound = 0
						local indexNames = {}
						local ignored = conflictIgnore[propClass] and conflictIgnore[propClass][propName]
						local truthyCheck = (typeName == "PhysicalProperties")
						local isAttribute = prop.IsAttribute
						local isMultiType = prop.MultiType

						t_clear(conflictMap)

						if not isMultiType then
							local firstVal,firstObj,firstSet
							local classList = classLists[prop.Class] or {}
							for c = 1,#classList do
								local obj = classList[c]
								if not firstSet then
									if isAttribute then
										firstVal = getAttribute(obj,attributeName)
										if firstVal ~= nil then
											firstObj = obj
											firstSet = true
										end
									else
										firstVal = obj[propName]
										firstObj = obj
										firstSet = true
									end
									if ignored then break end
								else
									local propVal,skip
									if isAttribute then
										propVal = getAttribute(obj,attributeName)
										if propVal == nil then skip = true end
									else
										propVal = obj[propName]
									end

									if not skip then
										if not conflictMap[1] then
											if truthyCheck then
												if (firstVal and true or false) ~= (propVal and true or false) then
													conflictMap[1] = true
													conflictsFound = conflictsFound + 1
												end
											elseif firstVal ~= propVal then
												conflictMap[1] = true
												conflictsFound = conflictsFound + 1
											end
										end

										if subPropCount > 0 then
											for sPropInd = 1,subPropCount do
												local indexes = indexNames[sPropInd]
												if not indexes then indexes = stringSplit(subProps[sPropInd],".") indexNames[sPropInd] = indexes end

												local firstValSub = firstVal
												local propValSub = propVal

												for j = 1,#indexes do
													if not firstValSub or not propValSub then break end 
													local indexName = indexes[j]
													firstValSub = firstValSub[indexName]
													propValSub = propValSub[indexName]
												end

												local mapInd = sPropInd + 1
												if not conflictMap[mapInd] and firstValSub ~= propValSub then
													conflictMap[mapInd] = true
													conflictsFound = conflictsFound + 1
												end
											end
										end

										if conflictsFound == toCheck then break end
									end
								end

								checked = checked + 1
								if checked == maxConflictCheck then break end
							end

							if not conflictMap[1] then autoUpdateObjs[gName] = firstObj end
							for sPropInd = 1,subPropCount do
								if not conflictMap[sPropInd+1] then
									autoUpdateObjs[gName.."."..subProps[sPropInd]] = firstObj
								end
							end
						end
					end
				end

				if p then
					Properties.Refresh()
				end
			end

			
			Settings.Properties.ShowAttributes = true 
			Properties.ShowExplorerProps = function()
				local maxConflictCheck = Settings.Properties.MaxConflictCheck
				local sList = Explorer.Selection.List
				local foundClasses = {}
				local propCount = 1
				local elevated = Main.Elevated
				local showDeprecated,showHidden = Settings.Properties.ShowDeprecated,Settings.Properties.ShowHidden
				local Classes = API.Classes
				local classLists = {}
				local lower = string.lower
				local RMDCustomOrders = RMD.PropertyOrders
				local getAttributes = game.GetAttributes
				local maxAttrs = Settings.Properties.MaxAttributes
				local showingAttrs = Settings.Properties.ShowAttributes
				local foundAttrs = {}
				local attrCount = 0
				local typeof = typeof
				local typeNameConvert = Properties.TypeNameConvert

				table.clear(props)

				for i = 1,#sList do
					local node = sList[i]
					local obj = node.Obj
					local class = node.Class
					if not class then class = obj.ClassName node.Class = class end

					local apiClass = Classes[class]
					while apiClass do
						local APIClassName = apiClass.Name
						if not foundClasses[APIClassName] then
							local apiProps = indexableProps[APIClassName]
							if not apiProps then apiProps = Properties.GetIndexableProps(obj,apiClass) indexableProps[APIClassName] = apiProps end

							for i = 1,#apiProps do
								local prop = apiProps[i]
								local tags = prop.Tags
								if (not tags.Deprecated or showDeprecated) and (not tags.Hidden or showHidden) then
									props[propCount] = prop
									propCount = propCount + 1
								end
							end
							foundClasses[APIClassName] = true
						end

						local classList = classLists[APIClassName]
						if not classList then classList = {} classLists[APIClassName] = classList end
						classList[#classList+1] = obj

						apiClass = apiClass.Superclass
					end

					if showingAttrs and attrCount < maxAttrs then
						local attrs = getAttributes(obj)
						for name,val in pairs(attrs) do
							local typ = typeof(val)
							if not foundAttrs[name] then
								local category = (typ == "Instance" and "Class") or (typ == "EnumItem" and "Enum") or "Other"
								local valType = {Name = typeNameConvert[typ] or typ, Category = category}
								local attrProp = {IsAttribute = true, Name = "ATTR_"..name, AttributeName = name, DisplayName = name, Class = "Instance", ValueType = valType, Category = "Attributes", Tags = {}}
								props[propCount] = attrProp
								propCount = propCount + 1
								attrCount = attrCount + 1
								foundAttrs[name] = {typ,attrProp}
								if attrCount == maxAttrs then break end
							elseif foundAttrs[name][1] ~= typ then
								foundAttrs[name][2].MultiType = true
								foundAttrs[name][2].Tags.ReadOnly = true
								foundAttrs[name][2].ValueType = {Name = "string"}
							end
						end
					end
				end

				table.sort(props,function(a,b)
					if a.Category ~= b.Category then
						return (categoryOrder[a.Category] or 9999) < (categoryOrder[b.Category] or 9999)
					else
						local aOrder = (RMDCustomOrders[a.Class] and RMDCustomOrders[a.Class][a.Name]) or 9999999
						local bOrder = (RMDCustomOrders[b.Class] and RMDCustomOrders[b.Class][b.Name]) or 9999999
						if aOrder ~= bOrder then
							return aOrder < bOrder
						else
							return lower(a.Name) < lower(b.Name)
						end
					end
				end)

				
				Properties.ClassLists = classLists
				Properties.ComputeConflicts()
				
				if #props > 0 then
					props[#props+1] = Properties.AddAttributeProp
				end

				Properties.Update()
				Properties.Refresh()
			end

			Properties.UpdateView = function()
				local maxEntries = math.ceil(propsFrame.AbsoluteSize.Y / 23)
				local maxX = propsFrame.AbsoluteSize.X
				local totalWidth = Properties.ViewWidth + Properties.MinInputWidth

				scrollV.VisibleSpace = maxEntries
				scrollV.TotalSpace = #viewList + 1
				scrollH.VisibleSpace = maxX
				scrollH.TotalSpace = totalWidth

				scrollV.Gui.Visible = #viewList + 1 > maxEntries
				scrollH.Gui.Visible = Settings.Properties.ScaleType == 0 and totalWidth > maxX

				local oldSize = propsFrame.Size
				propsFrame.Size = UDim2.new(1,(scrollV.Gui.Visible and -16 or 0),1,(scrollH.Gui.Visible and -39 or -23))
				if oldSize ~= propsFrame.Size then
					Properties.UpdateView()
				else
					scrollV:Update()
					scrollH:Update()

					if scrollV.Gui.Visible and scrollH.Gui.Visible then
						scrollV.Gui.Size = UDim2.new(0,16,1,-39)
						scrollH.Gui.Size = UDim2.new(1,-16,0,16)
						Properties.Window.GuiElems.Content.ScrollCorner.Visible = true
					else
						scrollV.Gui.Size = UDim2.new(0,16,1,-23)
						scrollH.Gui.Size = UDim2.new(1,0,0,16)
						Properties.Window.GuiElems.Content.ScrollCorner.Visible = false
					end

					Properties.Index = scrollV.Index
				end
			end

			Properties.MakeSubProp = function(prop,subName,valueType,displayName)
				local subProp = {}
				for i,v in pairs(prop) do
					subProp[i] = v
				end
				subProp.RootType = subProp.RootType or subProp.ValueType
				subProp.ValueType = valueType
				subProp.SubName = subProp.SubName and (subProp.SubName..subName) or subName
				subProp.DisplayName = displayName

				return subProp
			end

			Properties.GetExpandedProps = function(prop) 
				local result = {}
				local typeData = prop.ValueType
				local typeName = typeData.Name
				local makeSubProp = Properties.MakeSubProp

				if typeName == "Vector2" then
					result[1] = makeSubProp(prop,".X",{Name = "float"})
					result[2] = makeSubProp(prop,".Y",{Name = "float"})
				elseif typeName == "Vector3" then
					result[1] = makeSubProp(prop,".X",{Name = "float"})
					result[2] = makeSubProp(prop,".Y",{Name = "float"})
					result[3] = makeSubProp(prop,".Z",{Name = "float"})
				elseif typeName == "CFrame" then
					result[1] = makeSubProp(prop,".Position",{Name = "Vector3"})
					result[2] = makeSubProp(prop,".RightVector",{Name = "Vector3"})
					result[3] = makeSubProp(prop,".UpVector",{Name = "Vector3"})
					result[4] = makeSubProp(prop,".LookVector",{Name = "Vector3"})
				elseif typeName == "UDim" then
					result[1] = makeSubProp(prop,".Scale",{Name = "float"})
					result[2] = makeSubProp(prop,".Offset",{Name = "int"})
				elseif typeName == "UDim2" then
					result[1] = makeSubProp(prop,".X",{Name = "UDim"})
					result[2] = makeSubProp(prop,".Y",{Name = "UDim"})
				elseif typeName == "Rect" then
					result[1] = makeSubProp(prop,".Min.X",{Name = "float"},"X0")
					result[2] = makeSubProp(prop,".Min.Y",{Name = "float"},"Y0")
					result[3] = makeSubProp(prop,".Max.X",{Name = "float"},"X1")
					result[4] = makeSubProp(prop,".Max.Y",{Name = "float"},"Y1")
				elseif typeName == "PhysicalProperties" then
					result[1] = makeSubProp(prop,".Density",{Name = "float"})
					result[2] = makeSubProp(prop,".Elasticity",{Name = "float"})
					result[3] = makeSubProp(prop,".ElasticityWeight",{Name = "float"})
					result[4] = makeSubProp(prop,".Friction",{Name = "float"})
					result[5] = makeSubProp(prop,".FrictionWeight",{Name = "float"})
				elseif typeName == "Ray" then
					result[1] = makeSubProp(prop,".Origin",{Name = "Vector3"})
					result[2] = makeSubProp(prop,".Direction",{Name = "Vector3"})
				elseif typeName == "NumberRange" then
					result[1] = makeSubProp(prop,".Min",{Name = "float"})
					result[2] = makeSubProp(prop,".Max",{Name = "float"})
				elseif typeName == "Faces" then
					result[1] = makeSubProp(prop,".Back",{Name = "bool"})
					result[2] = makeSubProp(prop,".Bottom",{Name = "bool"})
					result[3] = makeSubProp(prop,".Front",{Name = "bool"})
					result[4] = makeSubProp(prop,".Left",{Name = "bool"})
					result[5] = makeSubProp(prop,".Right",{Name = "bool"})
					result[6] = makeSubProp(prop,".Top",{Name = "bool"})
				elseif typeName == "Axes" then
					result[1] = makeSubProp(prop,".X",{Name = "bool"})
					result[2] = makeSubProp(prop,".Y",{Name = "bool"})
					result[3] = makeSubProp(prop,".Z",{Name = "bool"})
				end

				if prop.Name == "SoundId" and prop.Class == "Sound" then
					result[1] = Properties.SoundPreviewProp
				end

				return result
			end

			Properties.Update = function()
				table.clear(viewList)

				local nameWidthCache = Properties.NameWidthCache
				local lastCategory
				local count = 1
				local maxWidth,maxDepth = 0,1

				local textServ = service.TextService
				local getTextSize = textServ.GetTextSize
				local font = Enum.Font.SourceSans
				local size = Vector2.new(math.huge,20)
				local stringSplit = string.split
				local entryIndent = Properties.EntryIndent
				local isFirstScaleType = Settings.Properties.ScaleType == 0
				local find,lower = string.find,string.lower
				local searchText = (#Properties.SearchText > 0 and lower(Properties.SearchText))

				local function recur(props,depth)
					for i = 1,#props do
						local prop = props[i]
						local propName = prop.Name
						local subName = prop.SubName
						local category = prop.Category

						local visible
						if searchText and depth == 1 then
							if find(lower(propName),searchText,1,true) then
								visible = true
							end
						else
							visible = true
						end

						if visible and lastCategory ~= category then
							viewList[count] = {CategoryName = category}
							count = count + 1
							lastCategory = category
						end

						if (expanded["CAT_"..category] and visible) or prop.SpecialRow then
							if depth > 1 then prop.Depth = depth if depth > maxDepth then maxDepth = depth end end

							if isFirstScaleType then
								local nameArr = subName and stringSplit(subName,".")
								local displayName = prop.DisplayName or (nameArr and nameArr[#nameArr]) or propName

								local nameWidth = nameWidthCache[displayName]
								if not nameWidth then nameWidth = getTextSize(textServ,displayName,14,font,size).X nameWidthCache[displayName] = nameWidth end

								local totalWidth = nameWidth + entryIndent*depth
								if totalWidth > maxWidth then
									maxWidth = totalWidth
								end
							end

							viewList[count] = prop
							count = count + 1

							local fullName = prop.Class.."."..prop.Name..(prop.SubName or "")
							if expanded[fullName] then
								local nextDepth = depth+1
								local expandedProps = Properties.GetExpandedProps(prop)
								if #expandedProps > 0 then
									recur(expandedProps,nextDepth)
								end
							end
						end
					end
				end
				recur(props,1)

				inputProp = nil
				Properties.ViewWidth = maxWidth + 9 + Properties.EntryOffset
				Properties.UpdateView()
			end

			Properties.NewPropEntry = function(index)
				local newEntry = Properties.EntryTemplate:Clone()
				local nameFrame = newEntry.NameFrame
				local valueFrame = newEntry.ValueFrame
				local newCheckbox = Lib.Checkbox.new(1)
				newCheckbox.Gui.Position = UDim2.new(0,3,0,3)
				newCheckbox.Gui.Parent = valueFrame
				newCheckbox.OnInput:Connect(function()
					local prop = viewList[index + Properties.Index]
					if not prop then return end

					if prop.ValueType.Name == "PhysicalProperties" then
						Properties.SetProp(prop,newCheckbox.Toggled and true or nil)
					else
						Properties.SetProp(prop,newCheckbox.Toggled)
					end
				end)
				checkboxes[index] = newCheckbox

				local iconFrame = Main.MiscIcons:GetLabel()
				iconFrame.Position = UDim2.new(0,2,0,3)
				iconFrame.Parent = newEntry.ValueFrame.RightButton

				newEntry.Position = UDim2.new(0,0,0,23*(index-1))

				nameFrame.Expand.InputBegan:Connect(function(input)
					local prop = viewList[index + Properties.Index]
					if not prop or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end

					local fullName = (prop.CategoryName and "CAT_"..prop.CategoryName) or prop.Class.."."..prop.Name..(prop.SubName or "")

					Main.MiscIcons:DisplayByKey(newEntry.NameFrame.Expand.Icon, expanded[fullName] and "Collapse_Over" or "Expand_Over")
				end)

				nameFrame.Expand.InputEnded:Connect(function(input)
					local prop = viewList[index + Properties.Index]
					if not prop or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end

					local fullName = (prop.CategoryName and "CAT_"..prop.CategoryName) or prop.Class.."."..prop.Name..(prop.SubName or "")

					Main.MiscIcons:DisplayByKey(newEntry.NameFrame.Expand.Icon, expanded[fullName] and "Collapse" or "Expand")
				end)

				nameFrame.Expand.MouseButton1Down:Connect(function()
					local prop = viewList[index + Properties.Index]
					if not prop then return end

					local fullName = (prop.CategoryName and "CAT_"..prop.CategoryName) or prop.Class.."."..prop.Name..(prop.SubName or "")
					if not prop.CategoryName and not Properties.ExpandableTypes[prop.ValueType and prop.ValueType.Name] and not Properties.ExpandableProps[fullName] then return end

					expanded[fullName] = not expanded[fullName]
					Properties.Update()
					Properties.Refresh()
				end)

				nameFrame.PropName.InputBegan:Connect(function(input)
					local prop = viewList[index + Properties.Index]
					if not prop then return end
					if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and not nameFrame.PropName.TextFits then
						local fullNameFrame = Properties.FullNameFrame	
						local nameArr = string.split(prop.Class.."."..prop.Name..(prop.SubName or ""), ".")
						local dispName = prop.DisplayName or nameArr[#nameArr]
						local sizeX = service.TextService:GetTextSize(dispName, 14, Enum.Font.SourceSans, Vector2.new(math.huge, 20)).X

						fullNameFrame.TextLabel.Text = dispName
						fullNameFrame.Size = UDim2.new(0, sizeX + 4, 0, 22)
						fullNameFrame.Visible = true
						Properties.FullNameFrameIndex = index
						Properties.FullNameFrameAttach.SetData(fullNameFrame, {Target = nameFrame})
						Properties.FullNameFrameAttach.Enable()
					end
				end)

				nameFrame.PropName.InputEnded:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and Properties.FullNameFrameIndex == index then
						Properties.FullNameFrame.Visible = false
						Properties.FullNameFrameAttach.Disable()
					end
				end)


				valueFrame.ValueBox.MouseButton1Down:Connect(function()
					local prop = viewList[index + Properties.Index]
					if not prop then return end

					Properties.SetInputProp(prop,index)
				end)

				valueFrame.ColorButton.MouseButton1Down:Connect(function()
					local prop = viewList[index + Properties.Index]
					if not prop then return end

					Properties.SetInputProp(prop,index,"color")
				end)

				valueFrame.RightButton.MouseButton1Click:Connect(function()
					local prop = viewList[index + Properties.Index]
					if not prop then return end

					local fullName = prop.Class.."."..prop.Name..(prop.SubName or "")
					local inputFullName = inputProp and (inputProp.Class.."."..inputProp.Name..(inputProp.SubName or ""))

					if fullName == inputFullName and inputProp.ValueType.Category == "Class" then
						inputProp = nil
						Properties.SetProp(prop,nil)
					else
						Properties.SetInputProp(prop,index,"right")
					end
				end)

				nameFrame.ToggleAttributes.MouseButton1Click:Connect(function()
					Settings.Properties.ShowAttributes = not Settings.Properties.ShowAttributes
					Properties.ShowExplorerProps()
				end)

				newEntry.RowButton.MouseButton1Click:Connect(function()
					Properties.DisplayAddAttributeWindow()
				end)

				newEntry.EditAttributeButton.MouseButton1Down:Connect(function()
					local prop = viewList[index + Properties.Index]
					if not prop then return end

					Properties.DisplayAttributeContext(prop)
				end)

				valueFrame.SoundPreview.ControlButton.MouseButton1Click:Connect(function()
					if Properties.PreviewSound and Properties.PreviewSound.Playing then
						Properties.SetSoundPreview(false)
					else
						local soundObj = Properties.FindFirstObjWhichIsA("Sound")
						if soundObj then Properties.SetSoundPreview(soundObj) end
					end
				end)

				valueFrame.SoundPreview.InputBegan:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end

					local releaseEvent, inputEvent
					releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							releaseEvent:Disconnect()
							if inputEvent then
								inputEvent:Disconnect()
							end
						end
					end)

					local timeLine = newEntry.ValueFrame.SoundPreview.TimeLine
					local soundObj = Properties.FindFirstObjWhichIsA("Sound")
					if soundObj then Properties.SetSoundPreview(soundObj, true) end

					local function update(input)
						local sound = Properties.PreviewSound
						if not sound or sound.TimeLength == 0 then return end

						local inputX = (input.UserInputType == Enum.UserInputType.Touch) and input.Position.X or input.Position.X
						local timeLineSize = timeLine.AbsoluteSize
						local relaX = inputX - timeLine.AbsolutePosition.X

						if timeLineSize.X <= 1 then return end
						if relaX < 0 then relaX = 0 elseif relaX >= timeLineSize.X then relaX = timeLineSize.X - 1 end

						local perc = (relaX / (timeLineSize.X - 1))
						sound.TimePosition = perc * sound.TimeLength
						timeLine.Slider.Position = UDim2.new(perc, -4, 0, -8)
					end

					update(input)

					inputEvent = service.UserInputService.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							update(input)
						end
					end)
				end)


				newEntry.Parent = propsFrame

				return {
					Gui = newEntry,
					GuiElems = {
						NameFrame = nameFrame,
						ValueFrame = valueFrame,
						PropName = nameFrame.PropName,
						ValueBox = valueFrame.ValueBox,
						Expand = nameFrame.Expand,
						ColorButton = valueFrame.ColorButton,
						ColorPreview = valueFrame.ColorButton.ColorPreview,
						Gradient = valueFrame.ColorButton.ColorPreview.UIGradient,
						EnumArrow = valueFrame.EnumArrow,
						Checkbox = valueFrame.Checkbox,
						RightButton = valueFrame.RightButton,
						RightButtonIcon = iconFrame,
						RowButton = newEntry.RowButton,
						EditAttributeButton = newEntry.EditAttributeButton,
						ToggleAttributes = nameFrame.ToggleAttributes,
						SoundPreview = valueFrame.SoundPreview,
						SoundPreviewSlider = valueFrame.SoundPreview.TimeLine.Slider
					}
				}
			end

			Properties.GetSoundPreviewEntry = function()
				for i = 1,#viewList do
					if viewList[i] == Properties.SoundPreviewProp then
						return propEntries[i - Properties.Index]
					end
				end
			end

			Properties.SetSoundPreview = function(soundObj,noplay)
				local sound = Properties.PreviewSound
				if not sound then
					sound = Instance.new("Sound")
					sound.Name = "Preview"
					sound.Paused:Connect(function()
						local entry = Properties.GetSoundPreviewEntry()
						if entry then Main.MiscIcons:DisplayByKey(entry.GuiElems.SoundPreview.ControlButton.Icon, "Play") end
					end)
					sound.Resumed:Connect(function() Properties.Refresh() end)
					sound.Ended:Connect(function()
						local entry = Properties.GetSoundPreviewEntry()
						if entry then entry.GuiElems.SoundPreviewSlider.Position = UDim2.new(0,-4,0,-8) end
						Properties.Refresh()
					end)
					sound.Parent = window.Gui
					Properties.PreviewSound = sound
				end

				if not soundObj then
					sound:Pause()
				else
					local newId = sound.SoundId ~= soundObj.SoundId
					sound.SoundId = soundObj.SoundId
					sound.PlaybackSpeed = soundObj.PlaybackSpeed
					sound.Volume = soundObj.Volume
					if newId then sound.TimePosition = 0 end
					if not noplay then sound:Resume() end

					coroutine.wrap(function()
						local previewTime = tick()
						Properties.SoundPreviewTime = previewTime
						while previewTime == Properties.SoundPreviewTime and sound.Playing do
							local entry = Properties.GetSoundPreviewEntry()
							if entry then
								local tl = sound.TimeLength
								local perc = sound.TimePosition/(tl == 0 and 1 or tl)
								entry.GuiElems.SoundPreviewSlider.Position = UDim2.new(perc,-4,0,-8)
							end
							Lib.FastWait()
						end
					end)()
					Properties.Refresh()
				end
			end

			Properties.DisplayAttributeContext = function(prop)
				local context = Properties.AttributeContext
				if not context then
					context = Lib.ContextMenu.new()
					context.Iconless = true
					context.Width = 80
				end
				context:Clear()

				context:Add({Name = "Edit", OnClick = function()
					Properties.DisplayAddAttributeWindow(prop)
				end})
				context:Add({Name = "Delete", OnClick = function()
					Properties.SetProp(prop,nil,true)
					Properties.ShowExplorerProps()
				end})

				context:Show()
			end

			Properties.DisplayAddAttributeWindow = function(editAttr)
				local win = Properties.AddAttributeWindow
				if not win then
					win = Lib.Window.new()
					win.Alignable = false
					win.Resizable = false
					win:SetTitle("Add Attribute")
					win:SetSize(200,130)

					local saveButton = Lib.Button.new()
					local nameLabel = Lib.Label.new()
					nameLabel.Text = "Name"
					nameLabel.Position = UDim2.new(0,30,0,10)
					nameLabel.Size = UDim2.new(0,40,0,20)
					win:Add(nameLabel)

					local nameBox = Lib.ViewportTextBox.new()
					nameBox.Position = UDim2.new(0,75,0,10)
					nameBox.Size = UDim2.new(0,120,0,20)
					win:Add(nameBox,"NameBox")
					nameBox.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
						saveButton:SetDisabled(#nameBox:GetText() == 0)
					end)

					local typeLabel = Lib.Label.new()
					typeLabel.Text = "Type"
					typeLabel.Position = UDim2.new(0,30,0,40)
					typeLabel.Size = UDim2.new(0,40,0,20)
					win:Add(typeLabel)

					local typeChooser = Lib.DropDown.new()
					typeChooser.CanBeEmpty = false
					typeChooser.Position = UDim2.new(0,75,0,40)
					typeChooser.Size = UDim2.new(0,120,0,20)
					typeChooser:SetOptions(Properties.AllowedAttributeTypes)
					win:Add(typeChooser,"TypeChooser")

					local errorLabel = Lib.Label.new()
					errorLabel.Text = ""
					errorLabel.Position = UDim2.new(0,5,1,-45)
					errorLabel.Size = UDim2.new(1,-10,0,20)
					errorLabel.TextColor3 = Settings.Theme.Important
					win.ErrorLabel = errorLabel
					win:Add(errorLabel,"Error")

					local cancelButton = Lib.Button.new()
					cancelButton.Text = "Cancel"
					cancelButton.Position = UDim2.new(1,-97,1,-25)
					cancelButton.Size = UDim2.new(0,92,0,20)
					cancelButton.OnClick:Connect(function()
						win:Close()
					end)
					win:Add(cancelButton)

					saveButton.Text = "Save"
					saveButton.Position = UDim2.new(0,5,1,-25)
					saveButton.Size = UDim2.new(0,92,0,20)
					saveButton.OnClick:Connect(function()
						local name = nameBox:GetText()
						if #name > 100 then
							errorLabel.Text = "Error: Name over 100 chars"
							return
						elseif name:sub(1,3) == "RBX" then
							errorLabel.Text = "Error: Name begins with 'RBX'"
							return
						end

						local typ = typeChooser.Selected
						local valType = {Name = Properties.TypeNameConvert[typ] or typ, Category = "DataType"}
						local attrProp = {IsAttribute = true, Name = "ATTR_"..name, AttributeName = name, DisplayName = name, Class = "Instance", ValueType = valType, Category = "Attributes", Tags = {}}

						Settings.Properties.ShowAttributes = true
						Properties.SetProp(attrProp,Properties.DefaultPropValue[valType.Name],true,Properties.EditingAttribute)
						Properties.ShowExplorerProps()
						win:Close()
					end)
					win:Add(saveButton,"SaveButton")

					Properties.AddAttributeWindow = win
				end

				Properties.EditingAttribute = editAttr
				win:SetTitle(editAttr and "Edit Attribute "..editAttr.AttributeName or "Add Attribute")
				win.Elements.Error.Text = ""
				win.Elements.NameBox:SetText("")
				win.Elements.SaveButton:SetDisabled(true)
				win.Elements.TypeChooser:SetSelected(1)
				win:Show()
			end

			Properties.IsTextEditable = function(prop)
				local typeData = prop.ValueType
				local typeName = typeData.Name

				return typeName ~= "bool" and typeData.Category ~= "Enum" and typeData.Category ~= "Class" and typeName ~= "BrickColor"
			end

			Properties.DisplayEnumDropdown = function(entryIndex)
				local context = Properties.EnumContext
				if not context then
					context = Lib.ContextMenu.new()
					context.Iconless = true
					context.MaxHeight = 200
					context.ReverseYOffset = 22
					Properties.EnumDropdown = context
				end

				if not inputProp or inputProp.ValueType.Category ~= "Enum" then return end
				local prop = inputProp

				local entry = propEntries[entryIndex]
				local valueFrame = entry.GuiElems.ValueFrame

				local enum = Enum[prop.ValueType.Name]
				if not enum then return end

				local sorted = {}
				for name,enum in next,enum:GetEnumItems() do
					sorted[#sorted+1] = enum
				end
				table.sort(sorted,function(a,b) return a.Name < b.Name end)

				context:Clear()

				local function onClick(name)
					if prop ~= inputProp then return end

					local enumItem = enum[name]
					inputProp = nil
					Properties.SetProp(prop,enumItem)
				end

				for i = 1,#sorted do
					local enumItem = sorted[i]
					context:Add({Name = enumItem.Name, OnClick = onClick})
				end

				context.Width = valueFrame.AbsoluteSize.X
				context:Show(valueFrame.AbsolutePosition.X, valueFrame.AbsolutePosition.Y + 22)
			end

			Properties.DisplayBrickColorEditor = function(prop,entryIndex,col)
				local editor = Properties.BrickColorEditor
				if not editor then
					editor = Lib.BrickColorPicker.new()
					editor.Gui.DisplayOrder = Main.DisplayOrders.Menu
					editor.ReverseYOffset = 22

					editor.OnSelect:Connect(function(col)
						if not editor.CurrentProp or editor.CurrentProp.ValueType.Name ~= "BrickColor" then return end

						if editor.CurrentProp == inputProp then inputProp = nil end
						Properties.SetProp(editor.CurrentProp,BrickColor.new(col))
					end)

					editor.OnMoreColors:Connect(function() 
						editor:Close()
						local colProp
						for i,v in pairs(API.Classes.BasePart.Properties) do
							if v.Name == "Color" then
								colProp = v
								break
							end
						end
						Properties.DisplayColorEditor(colProp,editor.SavedColor.Color)
					end)

					Properties.BrickColorEditor = editor
				end

				local entry = propEntries[entryIndex]
				local valueFrame = entry.GuiElems.ValueFrame

				editor.CurrentProp = prop
				editor.SavedColor = col
				if prop and prop.Class == "BasePart" and prop.Name == "BrickColor" then
					editor:SetMoreColorsVisible(true)
				else
					editor:SetMoreColorsVisible(false)
				end
				editor:Show(valueFrame.AbsolutePosition.X, valueFrame.AbsolutePosition.Y + 22)
			end

			Properties.DisplayColorEditor = function(prop,col)
				local editor = Properties.ColorEditor
				if not editor then
					editor = Lib.ColorPicker.new()

					editor.OnSelect:Connect(function(col)
						if not editor.CurrentProp then return end
						local typeName = editor.CurrentProp.ValueType.Name
						if typeName ~= "Color3" and typeName ~= "BrickColor" then return end

						local colVal = (typeName == "Color3" and col or BrickColor.new(col))

						if editor.CurrentProp == inputProp then inputProp = nil end
						Properties.SetProp(editor.CurrentProp,colVal)
					end)

					Properties.ColorEditor = editor
				end

				editor.CurrentProp = prop
				if col then
					editor:SetColor(col)
				else
					local firstVal = Properties.GetFirstPropVal(prop)
					if firstVal then editor:SetColor(firstVal) end
				end
				editor:Show()
			end

			Properties.DisplayNumberSequenceEditor = function(prop,seq)
				local editor = Properties.NumberSequenceEditor
				if not editor then
					editor = Lib.NumberSequenceEditor.new()

					editor.OnSelect:Connect(function(val)
						if not editor.CurrentProp or editor.CurrentProp.ValueType.Name ~= "NumberSequence" then return end

						if editor.CurrentProp == inputProp then inputProp = nil end
						Properties.SetProp(editor.CurrentProp,val)
					end)

					Properties.NumberSequenceEditor = editor
				end

				editor.CurrentProp = prop
				if seq then
					editor:SetSequence(seq)
				else
					local firstVal = Properties.GetFirstPropVal(prop)
					if firstVal then editor:SetSequence(firstVal) end
				end
				editor:Show()
			end

			Properties.DisplayColorSequenceEditor = function(prop,seq)
				local editor = Properties.ColorSequenceEditor
				if not editor then
					editor = Lib.ColorSequenceEditor.new()

					editor.OnSelect:Connect(function(val)
						if not editor.CurrentProp or editor.CurrentProp.ValueType.Name ~= "ColorSequence" then return end

						if editor.CurrentProp == inputProp then inputProp = nil end
						Properties.SetProp(editor.CurrentProp,val)
					end)

					Properties.ColorSequenceEditor = editor
				end

				editor.CurrentProp = prop
				if seq then
					editor:SetSequence(seq)
				else
					local firstVal = Properties.GetFirstPropVal(prop)
					if firstVal then editor:SetSequence(firstVal) end
				end
				editor:Show()
			end

			Properties.GetFirstPropVal = function(prop)
				local first = Properties.FindFirstObjWhichIsA(prop.Class)
				if first then
					return Properties.GetPropVal(prop,first)
				end
			end

			Properties.GetPropVal = function(prop,obj)
				if prop.MultiType then return "<Multiple Types>" end
				if not obj then return end

				local propVal
				if prop.IsAttribute then
					propVal = getAttribute(obj,prop.AttributeName)
					if propVal == nil then return nil end

					local typ = typeof(propVal)
					local currentType = Properties.TypeNameConvert[typ] or typ
					if prop.RootType then
						if prop.RootType.Name ~= currentType then
							return nil
						end
					elseif prop.ValueType.Name ~= currentType then
						return nil
					end
				else
					propVal = obj[prop.Name]
				end
				if prop.SubName then
					local indexes = string.split(prop.SubName,".")
					for i = 1,#indexes do
						local indexName = indexes[i]
						if #indexName > 0 and propVal then
							propVal = propVal[indexName]
						end
					end
				end

				return propVal
			end

			Properties.SelectObject = function(obj)
				if inputProp and inputProp.ValueType.Category == "Class" then
					local prop = inputProp
					inputProp = nil

					if isa(obj,prop.ValueType.Name) then
						Properties.SetProp(prop,obj)
					else
						Properties.Refresh()
					end

					return true
				end

				return false
			end

			Properties.DisplayProp = function(prop,entryIndex)
				local propName = prop.Name
				local typeData = prop.ValueType
				local typeName = typeData.Name
				local tags = prop.Tags
				local gName = prop.Class.."."..prop.Name..(prop.SubName or "")
				local propObj = autoUpdateObjs[gName]
				local entryData = propEntries[entryIndex]
				local UDim2 = UDim2

				local guiElems = entryData.GuiElems
				local valueFrame = guiElems.ValueFrame
				local valueBox = guiElems.ValueBox
				local colorButton = guiElems.ColorButton
				local colorPreview = guiElems.ColorPreview
				local gradient = guiElems.Gradient
				local enumArrow = guiElems.EnumArrow
				local checkbox = guiElems.Checkbox
				local rightButton = guiElems.RightButton
				local soundPreview = guiElems.SoundPreview

				local propVal = Properties.GetPropVal(prop,propObj)
				local inputFullName = inputProp and (inputProp.Class.."."..inputProp.Name..(inputProp.SubName or ""))

				local offset = 4
				local endOffset = 6

				
				if (typeName == "Color3" or typeName == "BrickColor" or typeName == "ColorSequence") then
					colorButton.Visible = true
					enumArrow.Visible = false
					if propVal then
						gradient.Color = (typeName == "Color3" and ColorSequence.new(propVal)) or (typeName == "BrickColor" and ColorSequence.new(propVal.Color)) or propVal
					else
						gradient.Color = ColorSequence.new(Color3.new(1,1,1))
					end
					colorPreview.BorderColor3 = (typeName == "ColorSequence" and Color3.new(1,1,1) or Color3.new(0,0,0))
					offset = 22
					endOffset = 24 + (typeName == "ColorSequence" and 20 or 0)
				elseif typeData.Category == "Enum" then
					colorButton.Visible = false
					enumArrow.Visible = not prop.Tags.ReadOnly
					endOffset = 22
				elseif (gName == inputFullName and typeData.Category == "Class") or typeName == "NumberSequence" then
					colorButton.Visible = false
					enumArrow.Visible = false
					endOffset = 26
				else
					colorButton.Visible = false
					enumArrow.Visible = false
				end

				valueBox.Position = UDim2.new(0,offset,0,0)
				valueBox.Size = UDim2.new(1,-endOffset,1,0)

				
				if inputFullName == gName and typeData.Category == "Class" then
					Main.MiscIcons:DisplayByKey(guiElems.RightButtonIcon, "Delete")
					guiElems.RightButtonIcon.Visible = true
					rightButton.Text = ""
					rightButton.Visible = true
				elseif typeName == "NumberSequence" or typeName == "ColorSequence" then
					guiElems.RightButtonIcon.Visible = false
					rightButton.Text = "..."
					rightButton.Visible = true
				else
					rightButton.Visible = false
				end

				
				if typeName == "bool" or typeName == "PhysicalProperties" then
					valueBox.Visible = false
					checkbox.Visible = true
					soundPreview.Visible = false
					checkboxes[entryIndex].Disabled = tags.ReadOnly
					if typeName == "PhysicalProperties" and autoUpdateObjs[gName] then
						checkboxes[entryIndex]:SetState(propVal and true or false)
					else
						checkboxes[entryIndex]:SetState(propVal)
					end
				elseif typeName == "SoundPlayer" then
					valueBox.Visible = false
					checkbox.Visible = false
					soundPreview.Visible = true
					local playing = Properties.PreviewSound and Properties.PreviewSound.Playing
					Main.MiscIcons:DisplayByKey(soundPreview.ControlButton.Icon, playing and "Pause" or "Play")
				else
					valueBox.Visible = true
					checkbox.Visible = false
					soundPreview.Visible = false

					if propVal ~= nil then
						if typeName == "Color3" then
							valueBox.Text = "["..Lib.ColorToBytes(propVal).."]"
						elseif typeData.Category == "Enum" then
							valueBox.Text = propVal.Name
						elseif Properties.RoundableTypes[typeName] and Settings.Properties.NumberRounding then
							local rawStr = Properties.ValueToString(prop,propVal)
							valueBox.Text = rawStr:gsub("-?%d+%.%d+",function(num)
								return tostring(tonumber(("%."..Settings.Properties.NumberRounding.."f"):format(num)))
							end)
						else
							valueBox.Text = Properties.ValueToString(prop,propVal)
						end
					else
						valueBox.Text = ""
					end

					valueBox.TextColor3 = tags.ReadOnly and Settings.Theme.PlaceholderText or Settings.Theme.Text
				end
			end

			Properties.Refresh = function()
				local maxEntries = math.max(math.ceil((propsFrame.AbsoluteSize.Y) / 23),0)	
				local maxX = propsFrame.AbsoluteSize.X
				local valueWidth = math.max(Properties.MinInputWidth,maxX-Properties.ViewWidth)
				local inputPropVisible = false
				local isa = game.IsA
				local UDim2 = UDim2
				local stringSplit = string.split
				local scaleType = Settings.Properties.ScaleType

				
				for i = 1,#propCons do
					propCons[i]:Disconnect()
				end
				table.clear(propCons)

				
				Properties.FullNameFrame.Visible = false
				Properties.FullNameFrameAttach.Disable()

				for i = 1,maxEntries do
					local entryData = propEntries[i]
					if not propEntries[i] then entryData = Properties.NewPropEntry(i) propEntries[i] = entryData end

					local entry = entryData.Gui
					local guiElems = entryData.GuiElems
					local nameFrame = guiElems.NameFrame
					local propNameLabel = guiElems.PropName
					local valueFrame = guiElems.ValueFrame
					local expand = guiElems.Expand
					local valueBox = guiElems.ValueBox
					local propNameBox = guiElems.PropName
					local rightButton = guiElems.RightButton
					local editAttributeButton = guiElems.EditAttributeButton
					local toggleAttributes = guiElems.ToggleAttributes

					local prop = viewList[i + Properties.Index]
					if prop then
						local entryXOffset = (scaleType == 0 and scrollH.Index or 0)
						entry.Visible = true
						entry.Position = UDim2.new(0,-entryXOffset,0,entry.Position.Y.Offset)
						entry.Size = UDim2.new(scaleType == 0 and 0 or 1, scaleType == 0 and Properties.ViewWidth + valueWidth or 0,0,22)

						if prop.SpecialRow then
							if prop.SpecialRow == "AddAttribute" then
								nameFrame.Visible = false
								valueFrame.Visible = false
								guiElems.RowButton.Visible = true
							end
						else
							
							nameFrame.Visible = true
							guiElems.RowButton.Visible = false

							local depth = Properties.EntryIndent*(prop.Depth or 1)
							local leftOffset = depth + Properties.EntryOffset
							nameFrame.Position = UDim2.new(0,leftOffset,0,0)
							propNameLabel.Size = UDim2.new(1,-2 - (scaleType == 0 and 0 or 6),1,0)

							local gName = (prop.CategoryName and "CAT_"..prop.CategoryName) or prop.Class.."."..prop.Name..(prop.SubName or "")

							if prop.CategoryName then
								entry.BackgroundColor3 = Settings.Theme.Main1
								valueFrame.Visible = false

								propNameBox.Text = prop.CategoryName
								propNameBox.Font = Enum.Font.SourceSansBold
								expand.Visible = true
								propNameBox.TextColor3 = Settings.Theme.Text
								nameFrame.BackgroundTransparency = 1
								nameFrame.Size = UDim2.new(1,0,1,0)
								editAttributeButton.Visible = false

								local showingAttrs = Settings.Properties.ShowAttributes
								toggleAttributes.Position = UDim2.new(1,-85-leftOffset,0,0)
								toggleAttributes.Text = (showingAttrs and "[Setting: ON]" or "[Setting: OFF]")
								toggleAttributes.TextColor3 = Settings.Theme.Text
								toggleAttributes.Visible = (prop.CategoryName == "Attributes")
							else
								local propName = prop.Name
								local typeData = prop.ValueType
								local typeName = typeData.Name
								local tags = prop.Tags
								local propObj = autoUpdateObjs[gName]

								local attributeOffset = (prop.IsAttribute and 20 or 0)
								editAttributeButton.Visible = (prop.IsAttribute and not prop.RootType)
								toggleAttributes.Visible = false

								
								if scaleType == 0 then
									nameFrame.Size = UDim2.new(0,Properties.ViewWidth - leftOffset - 1,1,0)
									valueFrame.Position = UDim2.new(0,Properties.ViewWidth,0,0)
									valueFrame.Size = UDim2.new(0,valueWidth - attributeOffset,1,0)
								else
									nameFrame.Size = UDim2.new(0.5,-leftOffset - 1,1,0)
									valueFrame.Position = UDim2.new(0.5,0,0,0)
									valueFrame.Size = UDim2.new(0.5,-attributeOffset,1,0)
								end

								local nameArr = stringSplit(gName,".")
								propNameBox.Text = prop.DisplayName or nameArr[#nameArr]
								propNameBox.Font = Enum.Font.SourceSans
								entry.BackgroundColor3 = Settings.Theme.Main2
								valueFrame.Visible = true

								expand.Visible = typeData.Category == "DataType" and Properties.ExpandableTypes[typeName] or Properties.ExpandableProps[gName]
								propNameBox.TextColor3 = tags.ReadOnly and Settings.Theme.PlaceholderText or Settings.Theme.Text

								
								Properties.DisplayProp(prop,i)
								if propObj then
									if prop.IsAttribute then
										propCons[#propCons+1] = getAttributeChangedSignal(propObj,prop.AttributeName):Connect(function()
											Properties.DisplayProp(prop,i)
										end)
									else
										propCons[#propCons+1] = getPropChangedSignal(propObj,propName):Connect(function()
											Properties.DisplayProp(prop,i)
										end)
									end
								end

								
								local beforeVisible = valueBox.Visible
								local inputFullName = inputProp and (inputProp.Class.."."..inputProp.Name..(inputProp.SubName or ""))
								if gName == inputFullName then
									nameFrame.BackgroundColor3 = Settings.Theme.ListSelection
									nameFrame.BackgroundTransparency = 0
									if typeData.Category == "Class" or typeData.Category == "Enum" or typeName == "BrickColor" then
										valueFrame.BackgroundColor3 = Settings.Theme.TextBox
										valueFrame.BackgroundTransparency = 0
										valueBox.Visible = true
									else
										inputPropVisible = true
										local scale = (scaleType == 0 and 0 or 0.5)
										local offset = (scaleType == 0 and Properties.ViewWidth-scrollH.Index or 0)
										local endOffset = 0

										if typeName == "Color3" or typeName == "ColorSequence" then
											offset = offset + 22
										end

										if typeName == "NumberSequence" or typeName == "ColorSequence" then
											endOffset = 20
										end

										inputBox.Position = UDim2.new(scale,offset,0,entry.Position.Y.Offset)
										inputBox.Size = UDim2.new(1-scale,-offset-endOffset-attributeOffset,0,22)
										inputBox.Visible = true
										valueBox.Visible = false
									end
								else
									nameFrame.BackgroundColor3 = Settings.Theme.Main1
									nameFrame.BackgroundTransparency = 1
									valueFrame.BackgroundColor3 = Settings.Theme.Main1
									valueFrame.BackgroundTransparency = 1
									valueBox.Visible = beforeVisible
								end
							end

							
							if prop.CategoryName or Properties.ExpandableTypes[prop.ValueType and prop.ValueType.Name] or Properties.ExpandableProps[gName] then
								if Lib.CheckMouseInGui(expand) then
									Main.MiscIcons:DisplayByKey(expand.Icon, expanded[gName] and "Collapse_Over" or "Expand_Over")
								else
									Main.MiscIcons:DisplayByKey(expand.Icon, expanded[gName] and "Collapse" or "Expand")
								end
								expand.Visible = true
							else
								expand.Visible = false
							end
						end
						entry.Visible = true
					else
						entry.Visible = false
					end
				end

				if not inputPropVisible then
					inputBox.Visible = false
				end

				for i = maxEntries+1,#propEntries do
					propEntries[i].Gui:Destroy()
					propEntries[i] = nil
					checkboxes[i] = nil
				end
			end

			Properties.SetProp = function(prop,val,noupdate,prevAttribute)
				local sList = Explorer.Selection.List
				local propName = prop.Name
				local subName = prop.SubName
				local propClass = prop.Class
				local typeData = prop.ValueType
				local typeName = typeData.Name
				local attributeName = prop.AttributeName
				local rootTypeData = prop.RootType
				local rootTypeName = rootTypeData and rootTypeData.Name
				local fullName = prop.Class.."."..prop.Name..(prop.SubName or "")
				local Vector3 = Vector3

				for i = 1,#sList do
					local node = sList[i]
					local obj = node.Obj

					if isa(obj,propClass) then
						pcall(function()
							local setVal = val
							local root
							if prop.IsAttribute then
								root = getAttribute(obj,attributeName)
							else
								root = obj[propName]
							end

							if prevAttribute then
								if prevAttribute.ValueType.Name == typeName then
									setVal = getAttribute(obj,prevAttribute.AttributeName) or setVal
								end
								setAttribute(obj,prevAttribute.AttributeName,nil)
							end

							if rootTypeName then
								if rootTypeName == "Vector2" then
									setVal = Vector2.new((subName == ".X" and setVal) or root.X, (subName == ".Y" and setVal) or root.Y)
								elseif rootTypeName == "Vector3" then
									setVal = Vector3.new((subName == ".X" and setVal) or root.X, (subName == ".Y" and setVal) or root.Y, (subName == ".Z" and setVal) or root.Z)
								elseif rootTypeName == "UDim" then
									setVal = UDim.new((subName == ".Scale" and setVal) or root.Scale, (subName == ".Offset" and setVal) or root.Offset)
								elseif rootTypeName == "UDim2" then
									local rootX,rootY = root.X,root.Y
									local X_UDim = (subName == ".X" and setVal) or UDim.new((subName == ".X.Scale" and setVal) or rootX.Scale, (subName == ".X.Offset" and setVal) or rootX.Offset)
									local Y_UDim = (subName == ".Y" and setVal) or UDim.new((subName == ".Y.Scale" and setVal) or rootY.Scale, (subName == ".Y.Offset" and setVal) or rootY.Offset)
									setVal = UDim2.new(X_UDim,Y_UDim)
								elseif rootTypeName == "CFrame" then
									local rootPos,rootRight,rootUp,rootLook = root.Position,root.RightVector,root.UpVector,root.LookVector
									local pos = (subName == ".Position" and setVal) or Vector3.new((subName == ".Position.X" and setVal) or rootPos.X, (subName == ".Position.Y" and setVal) or rootPos.Y, (subName == ".Position.Z" and setVal) or rootPos.Z)
									local rightV = (subName == ".RightVector" and setVal) or Vector3.new((subName == ".RightVector.X" and setVal) or rootRight.X, (subName == ".RightVector.Y" and setVal) or rootRight.Y, (subName == ".RightVector.Z" and setVal) or rootRight.Z)
									local upV = (subName == ".UpVector" and setVal) or Vector3.new((subName == ".UpVector.X" and setVal) or rootUp.X, (subName == ".UpVector.Y" and setVal) or rootUp.Y, (subName == ".UpVector.Z" and setVal) or rootUp.Z)
									local lookV = (subName == ".LookVector" and setVal) or Vector3.new((subName == ".LookVector.X" and setVal) or rootLook.X, (subName == ".RightVector.Y" and setVal) or rootLook.Y, (subName == ".RightVector.Z" and setVal) or rootLook.Z)
									setVal = CFrame.fromMatrix(pos,rightV,upV,-lookV)
								elseif rootTypeName == "Rect" then
									local rootMin,rootMax = root.Min,root.Max
									local min = Vector2.new((subName == ".Min.X" and setVal) or rootMin.X, (subName == ".Min.Y" and setVal) or rootMin.Y)
									local max = Vector2.new((subName == ".Max.X" and setVal) or rootMax.X, (subName == ".Max.Y" and setVal) or rootMax.Y)
									setVal = Rect.new(min,max)
								elseif rootTypeName == "PhysicalProperties" then
									local rootProps = PhysicalProperties.new(obj.Material)
									local density = (subName == ".Density" and setVal) or (root and root.Density) or rootProps.Density
									local friction = (subName == ".Friction" and setVal) or (root and root.Friction) or rootProps.Friction
									local elasticity = (subName == ".Elasticity" and setVal) or (root and root.Elasticity) or rootProps.Elasticity
									local frictionWeight = (subName == ".FrictionWeight" and setVal) or (root and root.FrictionWeight) or rootProps.FrictionWeight
									local elasticityWeight = (subName == ".ElasticityWeight" and setVal) or (root and root.ElasticityWeight) or rootProps.ElasticityWeight
									setVal = PhysicalProperties.new(density,friction,elasticity,frictionWeight,elasticityWeight)
								elseif rootTypeName == "Ray" then
									local rootOrigin,rootDirection = root.Origin,root.Direction
									local origin = (subName == ".Origin" and setVal) or Vector3.new((subName == ".Origin.X" and setVal) or rootOrigin.X, (subName == ".Origin.Y" and setVal) or rootOrigin.Y, (subName == ".Origin.Z" and setVal) or rootOrigin.Z)
									local direction = (subName == ".Direction" and setVal) or Vector3.new((subName == ".Direction.X" and setVal) or rootDirection.X, (subName == ".Direction.Y" and setVal) or rootDirection.Y, (subName == ".Direction.Z" and setVal) or rootDirection.Z)
									setVal = Ray.new(origin,direction)
								elseif rootTypeName == "Faces" then
									local faces = {}
									local faceList = {"Back","Bottom","Front","Left","Right","Top"}
									for _,face in pairs(faceList) do
										local val
										if subName == "."..face then
											val = setVal
										else
											val = root[face]
										end
										if val then faces[#faces+1] = Enum.NormalId[face] end
									end
									setVal = Faces.new(unpack(faces))
								elseif rootTypeName == "Axes" then
									local axes = {}
									local axesList = {"X","Y","Z"}
									for _,axe in pairs(axesList) do
										local val
										if subName == "."..axe then
											val = setVal
										else
											val = root[axe]
										end
										if val then axes[#axes+1] = Enum.Axis[axe] end
									end
									setVal = Axes.new(unpack(axes))
								elseif rootTypeName == "NumberRange" then
									setVal = NumberRange.new(subName == ".Min" and setVal or root.Min, subName == ".Max" and setVal or root.Max)
								end
							end

							if typeName == "PhysicalProperties" and setVal then
								setVal = root or PhysicalProperties.new(obj.Material)
							end

							if prop.IsAttribute then
								setAttribute(obj,attributeName,setVal)
							else
								obj[propName] = setVal
							end
						end)
					end
				end

				if not noupdate then
					Properties.ComputeConflicts(prop)
				end
			end

			Properties.InitInputBox = function()
				inputBox = create({
					{1,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderSizePixel=0,Name="InputBox",Size=UDim2.new(0,200,0,22),Visible=false,ZIndex=2,}},
					{2,"TextBox",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BackgroundTransparency=1,BorderColor3=Color3.new(0.062745101749897,0.51764708757401,1),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Parent={1},PlaceholderColor3=Color3.new(0.69803923368454,0.69803923368454,0.69803923368454),Position=UDim2.new(0,3,0,0),Size=UDim2.new(1,-6,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=2,}},
				})
				inputTextBox = inputBox.TextBox
				inputBox.BackgroundColor3 = Settings.Theme.TextBox
				inputBox.Parent = Properties.Window.GuiElems.Content.List

				inputTextBox.FocusLost:Connect(function()
					if not inputProp then return end

					local prop = inputProp
					inputProp = nil
					local val = Properties.StringToValue(prop,inputTextBox.Text)
					if val then Properties.SetProp(prop,val) else Properties.Refresh() end
				end)

				inputTextBox.Focused:Connect(function()
					inputTextBox.SelectionStart = 1
					inputTextBox.CursorPosition = #inputTextBox.Text + 1
				end)

				Lib.ViewportTextBox.convert(inputTextBox)
			end

			Properties.SetInputProp = function(prop,entryIndex,special)
				local typeData = prop.ValueType
				local typeName = typeData.Name
				local fullName = prop.Class.."."..prop.Name..(prop.SubName or "")
				local propObj = autoUpdateObjs[fullName]
				local propVal = Properties.GetPropVal(prop,propObj)

				if prop.Tags.ReadOnly then return end

				inputProp = prop
				if special then
					if special == "color" then
						if typeName == "Color3" then
							inputTextBox.Text = propVal and Properties.ValueToString(prop,propVal) or ""
							Properties.DisplayColorEditor(prop,propVal)
						elseif typeName == "BrickColor" then
							Properties.DisplayBrickColorEditor(prop,entryIndex,propVal)
						elseif typeName == "ColorSequence" then
							inputTextBox.Text = propVal and Properties.ValueToString(prop,propVal) or ""
							Properties.DisplayColorSequenceEditor(prop,propVal)
						end
					elseif special == "right" then
						if typeName == "NumberSequence" then
							inputTextBox.Text = propVal and Properties.ValueToString(prop,propVal) or ""
							Properties.DisplayNumberSequenceEditor(prop,propVal)
						elseif typeName == "ColorSequence" then
							inputTextBox.Text = propVal and Properties.ValueToString(prop,propVal) or ""
							Properties.DisplayColorSequenceEditor(prop,propVal)
						end
					end
				else
					if Properties.IsTextEditable(prop) then
						inputTextBox.Text = propVal and Properties.ValueToString(prop,propVal) or ""
						inputTextBox:CaptureFocus()
					elseif typeData.Category == "Enum" then
						Properties.DisplayEnumDropdown(entryIndex)
					elseif typeName == "BrickColor" then
						Properties.DisplayBrickColorEditor(prop,entryIndex,propVal)
					end
				end
				Properties.Refresh()
			end

			Properties.InitSearch = function()
				local TweenService = service.TweenService
				local SearchFrame = Properties.GuiElems.ToolBar.SearchFrame
				local searchBox = SearchFrame.SearchBox

				local TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint)

				local Tweens = {
					Start = TweenService:Create(SearchFrame.UIStroke, TweenInfo, { Color = Color3.fromRGB(0, 120, 215) }),
					End = TweenService:Create(SearchFrame.UIStroke, TweenInfo, { Color = Color3.fromRGB(42, 42, 42) })
				}

				Lib.ViewportTextBox.convert(searchBox)

				searchBox.FocusLost:Connect(function() Tweens.End:Play() end)
				searchBox.Focused:Connect(function() Tweens.Start:Play() end)

				searchBox:GetPropertyChangedSignal("Text"):Connect(function()
					Properties.SearchText = searchBox.Text
					Properties.Update()
					Properties.Refresh()
				end)
			end

			Properties.InitEntryStuff = function()
				Properties.EntryTemplate = create({
					{1,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),Font=3,Name="Entry",Position=UDim2.new(0,1,0,1),Size=UDim2.new(0,250,0,22),Text="",TextSize=14,}},
					{2,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BackgroundTransparency=1,BorderColor3=Color3.new(0.33725491166115,0.49019610881805,0.73725491762161),BorderSizePixel=0,Name="NameFrame",Parent={1},Position=UDim2.new(0,20,0,0),Size=UDim2.new(1,-40,1,0),}},
					{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="PropName",Parent={2},Position=UDim2.new(0,2,0,0),Size=UDim2.new(1,-2,1,0),Text="Anchored",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.10000000149012,TextTruncate=1,TextXAlignment=0,}},
					{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClipsDescendants=true,Font=3,Name="Expand",Parent={2},Position=UDim2.new(0,-20,0,1),Size=UDim2.new(0,20,0,20),Text="",TextSize=14,Visible=false,}},
					{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5642383285",ImageRectOffset=Vector2.new(144,16),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={4},Position=UDim2.new(0,2,0,2),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
					{6,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=4,Name="ToggleAttributes",Parent={2},Position=UDim2.new(1,-85,0,0),Size=UDim2.new(0,85,0,22),Text="[SETTING: OFF]",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.10000000149012,Visible=false,}},
					{7,"Frame",{BackgroundColor3=Color3.new(0.04313725605607,0.35294118523598,0.68627452850342),BackgroundTransparency=1,BorderColor3=Color3.new(0.33725491166115,0.49019607901573,0.73725491762161),BorderSizePixel=0,Name="ValueFrame",Parent={1},Position=UDim2.new(1,-100,0,0),Size=UDim2.new(0,80,1,0),}},
					{8,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderColor3=Color3.new(0.33725491166115,0.49019610881805,0.73725491762161),BorderSizePixel=0,Name="Line",Parent={7},Position=UDim2.new(0,-1,0,0),Size=UDim2.new(0,1,1,0),}},
					{9,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="ColorButton",Parent={7},Size=UDim2.new(0,20,0,22),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,Visible=false,}},
					{10,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0,0,0),Name="ColorPreview",Parent={9},Position=UDim2.new(0,5,0,6),Size=UDim2.new(0,10,0,10),}},
					{11,"UIGradient",{Parent={10},}},
					{12,"Frame",{BackgroundTransparency=1,Name="EnumArrow",Parent={7},Position=UDim2.new(1,-16,0,3),Size=UDim2.new(0,16,0,16),Visible=false,}},
					{13,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={12},Position=UDim2.new(0,8,0,9),Size=UDim2.new(0,1,0,1),}},
					{14,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={12},Position=UDim2.new(0,7,0,8),Size=UDim2.new(0,3,0,1),}},
					{15,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={12},Position=UDim2.new(0,6,0,7),Size=UDim2.new(0,5,0,1),}},
					{16,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="ValueBox",Parent={7},Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-8,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.10000000149012,TextTruncate=1,TextXAlignment=0,}},
					{17,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="RightButton",Parent={7},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,22),Text="...",TextColor3=Color3.new(1,1,1),TextSize=14,Visible=false,}},
					{18,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="SettingsButton",Parent={7},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,22),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,Visible=false,}},
					{19,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="SoundPreview",Parent={7},Size=UDim2.new(1,0,1,0),Visible=false,}},
					{20,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="ControlButton",Parent={19},Size=UDim2.new(0,20,0,22),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
					{21,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5642383285",ImageRectOffset=Vector2.new(144,16),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={20},Position=UDim2.new(0,2,0,3),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
					{22,"Frame",{BackgroundColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,Name="TimeLine",Parent={19},Position=UDim2.new(0,26,0.5,-1),Size=UDim2.new(1,-34,0,2),}},
					{23,"Frame",{BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),Name="Slider",Parent={22},Position=UDim2.new(0,-4,0,-8),Size=UDim2.new(0,8,0,18),}},
					{24,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="EditAttributeButton",Parent={1},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,22),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
					{25,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5034718180",ImageTransparency=0.20000000298023,Name="Icon",Parent={24},Position=UDim2.new(0,2,0,3),Size=UDim2.new(0,16,0,16),}},
					{26,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderSizePixel=0,Font=3,Name="RowButton",Parent={1},Size=UDim2.new(1,0,1,0),Text="Add Attribute",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.10000000149012,Visible=false,}},
				})

				local fullNameFrame = Lib.Frame.new()
				local label = Lib.Label.new()
				label.Parent = fullNameFrame.Gui
				label.Position = UDim2.new(0,2,0,0)
				label.Size = UDim2.new(1,-4,1,0)
				fullNameFrame.Visible = false
				fullNameFrame.Parent = window.Gui

				Properties.FullNameFrame = fullNameFrame
				Properties.FullNameFrameAttach = Lib.AttachTo(fullNameFrame)
			end

			Properties.Init = function() 
				local guiItems = create({
					{1,"Folder",{Name="Items",}},
					{2,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="ToolBar",Parent={1},Size=UDim2.new(1,0,0,22),}},
					{3,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.1176470592618,0.1176470592618,0.1176470592618),BorderSizePixel=0,Name="SearchFrame",Parent={2},Position=UDim2.new(0,3,0,1),Size=UDim2.new(1,-6,0,18),}},
					{4,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Name="SearchBox",Parent={3},PlaceholderColor3=Color3.new(0.39215689897537,0.39215689897537,0.39215689897537),PlaceholderText="Search properties",Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-24,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,}},
					{5,"UICorner",{CornerRadius=UDim.new(0,2),Parent={3},}},
					{6,"UIStroke",{Thickness=1.4,Parent={3},Color=Color3.fromRGB(42,42,42)}},
					{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Reset",Parent={3},Position=UDim2.new(1,-17,0,1),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
					{8,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5034718129",ImageColor3=Color3.new(0.39215686917305,0.39215686917305,0.39215686917305),Parent={7},Size=UDim2.new(0,16,0,16),}},
					{9,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Refresh",Parent={2},Position=UDim2.new(1,-20,0,1),Size=UDim2.new(0,18,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,Visible=false,}},
					{10,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5642310344",Parent={9},Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,12,0,12),}},
					{11,"Frame",{BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="ScrollCorner",Parent={1},Position=UDim2.new(1,-16,1,-16),Size=UDim2.new(0,16,0,16),Visible=false,}},
					{12,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClipsDescendants=true,Name="List",Parent={1},Position=UDim2.new(0,0,0,23),Size=UDim2.new(1,0,1,-23),}},
				})

				
				categoryOrder =	API.CategoryOrder
				for category,_ in next,categoryOrder do
					if not Properties.CollapsedCategories[category] then
						expanded["CAT_"..category] = true
					end
				end
				expanded["Sound.SoundId"] = true

				
				window = Lib.Window.new()
				Properties.Window = window
				window:SetTitle("Properties")

				toolBar = guiItems.ToolBar
				propsFrame = guiItems.List

				Properties.GuiElems.ToolBar = toolBar
				Properties.GuiElems.PropsFrame = propsFrame

				Properties.InitEntryStuff()

				
				window.GuiElems.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					if Properties.Window:IsContentVisible() then
						Properties.UpdateView()
						Properties.Refresh()
					end
				end)
				window.OnActivate:Connect(function()
					Properties.UpdateView()
					Properties.Update()
					Properties.Refresh()
				end)
				window.OnRestore:Connect(function()
					Properties.UpdateView()
					Properties.Update()
					Properties.Refresh()
				end)

				
				scrollV = Lib.ScrollBar.new()		
				scrollV.WheelIncrement = 3
				scrollV.Gui.Position = UDim2.new(1,-16,0,23)
				scrollV:SetScrollFrame(propsFrame)
				scrollV.Scrolled:Connect(function()
					Properties.Index = scrollV.Index
					Properties.Refresh()
				end)

				scrollH = Lib.ScrollBar.new(true)
				scrollH.Increment = 5
				scrollH.WheelIncrement = 20
				scrollH.Gui.Position = UDim2.new(0,0,1,-16)
				scrollH.Scrolled:Connect(function()
					Properties.Refresh()
				end)

				
				window.GuiElems.Line.Position = UDim2.new(0,0,0,22)
				toolBar.Parent = window.GuiElems.Content
				propsFrame.Parent = window.GuiElems.Content
				guiItems.ScrollCorner.Parent = window.GuiElems.Content
				scrollV.Gui.Parent = window.GuiElems.Content
				scrollH.Gui.Parent = window.GuiElems.Content
				Properties.InitInputBox()
				Properties.InitSearch()
			end

			return Properties
		end

		return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
	end,
	ScriptViewer = function()






		
		local Main,Lib,Apps,Settings 
		local Explorer, Properties, ScriptViewer, Notebook 
		local API,RMD,env,service,plr,create,createSimple 

		local function initDeps(data)
			Main = data.Main
			Lib = data.Lib
			Apps = data.Apps
			Settings = data.Settings

			API = data.API
			RMD = data.RMD
			env = data.env
			service = data.service
			plr = data.plr
			create = data.create
			createSimple = data.createSimple
		end

		local function initAfterMain()
			Explorer = Apps.Explorer
			Properties = Apps.Properties
			ScriptViewer = Apps.ScriptViewer
			Notebook = Apps.Notebook
		end

		local function main()
			local ScriptViewer = {}
			local window, codeFrame
			local PreviousScr = nil
			local CurrentSource = ""

			ScriptViewer.ViewScript = function(scr)
				local success, source = pcall(env.decompile, scr)
				if not success then
					CurrentSource = "Decompiler error: " .. tostring(source) .. "\nScript: " .. scr:GetFullName()
					PreviousScr = nil
				elseif type(source) ~= "string" or source == "" then
					CurrentSource = "Decompiler returned no source\nScript: " .. scr:GetFullName()
					PreviousScr = nil
				else
					CurrentSource = source
					PreviousScr = scr
				end
				local display = CurrentSource
				if #display > 1500000 then
					display = string.sub(display, 1, 1500000) .. "\n\nOutput is too large for Script Viewer. Copy/Save still uses the full source."
				end
				codeFrame:SetText(display:gsub("\0", "\\0"))
				window:Show()
			end

			ScriptViewer.Init = function()
				window = Lib.Window.new()
				window:SetTitle("Script Viewer")
				window:Resize(500, 400)
				ScriptViewer.Window = window

				codeFrame = Lib.CodeFrame.new()
				codeFrame.Frame.Position = UDim2.new(0,0,0,20)
				codeFrame.Frame.Size = UDim2.new(1,0,1,-20)
				codeFrame.Frame.Parent = window.GuiElems.Content

				
				local copy = Instance.new("TextButton", window.GuiElems.Content)
				copy.BackgroundTransparency = 1
				copy.Size = UDim2.new(0.5,0,0,20)
				copy.Text = "Copy to Clipboard"
				copy.TextColor3 = Color3.new(1,1,1)

				copy.MouseButton1Click:Connect(function()
					env.setclipboard(CurrentSource)
				end)

				local save = Instance.new("TextButton",window.GuiElems.Content)
				save.BackgroundTransparency = 1
				save.Position = UDim2.new(0.35,0,0,0)
				save.Size = UDim2.new(0.3,0,0,20)
				save.Text = "Save to File"
				save.TextColor3 = Color3.new(1,1,1)

				save.MouseButton1Click:Connect(function()
					local filename = "Place_"..game.PlaceId.."_Script_"..os.time()..".txt"

					env.writefile(filename, CurrentSource)
					if env.movefileas then
						env.movefileas(filename, ".txt")
					end
				end)

				local dumpbtn = Instance.new("TextButton",window.GuiElems.Content)
				dumpbtn.BackgroundTransparency = 1
				dumpbtn.Position = UDim2.new(0.7,0,0,0)
				dumpbtn.Size = UDim2.new(0.3,0,0,20)
				dumpbtn.Text = "Dump Functions"
				dumpbtn.TextColor3 = Color3.new(1,1,1)

				dumpbtn.MouseButton1Click:Connect(function()
					if PreviousScr ~= nil then
						pcall(function()
							
							local getgc = getgc or get_gc_objects
							local getupvalues = (debug and debug.getupvalues) or getupvalues or getupvals
							local getconstants = (debug and debug.getconstants) or getconstants or getconsts
							local getinfo = (debug and (debug.getinfo or debug.info)) or getinfo
							local original = ("\n-- // Function Dumper made by King.Kevin\n-- // Script Path: %s\n\n--[["):format(PreviousScr:GetFullName())
							local dump = original
							local functions, function_count, data_base = {}, 0, {}
							function functions:add_to_dump(str, indentation, new_line)
								local new_line = new_line or true
								dump = dump .. ("%s%s%s"):format(string.rep("		", indentation), tostring(str), new_line and "\n" or "")
							end
							function functions:get_function_name(func)
								local n = getinfo(func).name
								return n ~= "" and n or "Unknown Name"
							end
							function functions:dump_table(input, indent, index)
								local indent = indent < 0 and 0 or indent
								functions:add_to_dump(("%s [%s] %s"):format(tostring(index), tostring(typeof(input)), tostring(input)), indent - 1)
								local count = 0
								for index, value in pairs(input) do
									count = count + 1
									if type(value) == "function" then
										functions:add_to_dump(("%d [function] = %s"):format(count, functions:get_function_name(value)), indent)
									elseif type(value) == "table" then
										if not data_base[value] then
											data_base[value] = true
											functions:add_to_dump(("%d [table]:"):format(count), indent)
											functions:dump_table(value, indent + 1, index)
										else
											functions:add_to_dump(("%d [table] (Recursive table detected)"):format(count), indent)
										end
									else
										functions:add_to_dump(("%d [%s] = %s"):format(count, tostring(typeof(value)), tostring(value)), indent)
									end
								end
							end
							function functions:dump_function(input, indent)
								functions:add_to_dump(("\nFunction Dump: %s"):format(functions:get_function_name(input)), indent)
								functions:add_to_dump(("\nFunction Upvalues: %s"):format(functions:get_function_name(input)), indent)
								for index, upvalue in pairs(getupvalues(input)) do
									if type(upvalue) == "function" then
										functions:add_to_dump(("%d [function] = %s"):format(index, functions:get_function_name(upvalue)), indent + 1)
									elseif type(upvalue) == "table" then
										if not data_base[upvalue] then
											data_base[upvalue] = true
											functions:add_to_dump(("%d [table]:"):format(index), indent + 1)
											functions:dump_table(upvalue, indent + 2, index)
										else
											functions:add_to_dump(("%d [table] (Recursive table detected)"):format(index), indent + 1)
										end
									else
										functions:add_to_dump(("%d [%s] = %s"):format(index, tostring(typeof(upvalue)), tostring(upvalue)), indent + 1)
									end
								end
								functions:add_to_dump(("\nFunction Constants: %s"):format(functions:get_function_name(input)), indent)
								for index, constant in pairs(getconstants(input)) do
									if type(constant) == "function" then
										functions:add_to_dump(("%d [function] = %s"):format(index, functions:get_function_name(constant)), indent + 1)
									elseif type(constant) == "table" then
										if not data_base[constant] then
											data_base[constant] = true
											functions:add_to_dump(("%d [table]:"):format(index), indent + 1)
											functions:dump_table(constant, indent + 2, index)
										else
											functions:add_to_dump(("%d [table] (Recursive table detected)"):format(index), indent + 1)
										end
									else
										functions:add_to_dump(("%d [%s] = %s"):format(index, tostring(typeof(constant)), tostring(constant)), indent + 1)
									end
								end
							end
							for _, _function in pairs(getgc()) do
								if typeof(_function) == "function" and getfenv(_function).script and getfenv(_function).script == PreviousScr then
									functions:dump_function(_function, 0)
									functions:add_to_dump("\n" .. ("="):rep(100), 0, false)
								end
							end
							local source = codeFrame:GetText()

							if dump ~= original then source = source .. dump .. "]]" end
							codeFrame:SetText(source)
						end)
					end
				end)
			end

			return ScriptViewer
		end

		return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
	end,
	Lib = function()






		
		local Main,Lib,Apps,Settings 
		local Explorer, Properties, ScriptViewer, Notebook 
		local API,RMD,env,service,plr,create,createSimple 

		local function initDeps(data)
			Main = data.Main
			Lib = data.Lib
			Apps = data.Apps
			Settings = data.Settings

			API = data.API
			RMD = data.RMD
			env = data.env
			service = data.service
			plr = data.plr
			create = data.create
			createSimple = data.createSimple
		end

		local function initAfterMain()
			Explorer = Apps.Explorer
			Properties = Apps.Properties
			ScriptViewer = Apps.ScriptViewer
			Notebook = Apps.Notebook
		end

		local function main()
			local Lib = {}

			local renderStepped = service.RunService.RenderStepped
			local signalWait = renderStepped.wait
			local PH = newproxy() 
			local SIGNAL = newproxy()

			
			local function initObj(props,mt)
				local type = type
				local function copy(t)
					local res = {}
					for i,v in pairs(t) do
						if v == SIGNAL then
							res[i] = Lib.Signal.new()
						elseif type(v) == "table" then
							res[i] = copy(v)
						else
							res[i] = v
						end
					end		
					return res
				end

				local newObj = copy(props)
				return setmetatable(newObj,mt)
			end

			local function getGuiMT(props,funcs)
				return {__index = function(self,ind) if not props[ind] then return funcs[ind] or self.Gui[ind] end end,
				__newindex = function(self,ind,val) if not props[ind] then self.Gui[ind] = val else rawset(self,ind,val) end end}
			end

			

			Lib.FormatLuaString = (function()
				local string = string
				local gsub = string.gsub
				local format = string.format
				local char = string.char
				local cleanTable = {['"'] = '\\"', ['\\'] = '\\\\'}
				for i = 0,31 do
					cleanTable[char(i)] = "\\"..format("%03d",i)
				end
				for i = 127,255 do
					cleanTable[char(i)] = "\\"..format("%03d",i)
				end

				return function(str)
					return gsub(str,"[\"\\\0-\31\127-\255]",cleanTable)
				end
			end)()

			Lib.CheckMouseInGui = function(gui)
				if gui == nil then return false end
				local mouse = Main.Mouse
				local guiPosition = gui.AbsolutePosition
				local guiSize = gui.AbsoluteSize	

				return mouse.X >= guiPosition.X and mouse.X < guiPosition.X + guiSize.X and mouse.Y >= guiPosition.Y and mouse.Y < guiPosition.Y + guiSize.Y
			end

			Lib.IsShiftDown = function()
				return service.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or service.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
			end

			Lib.IsCtrlDown = function()
				return service.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or service.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			end

			Lib.CreateArrow = function(size,num,dir)
				local max = num
				local arrowFrame = createSimple("Frame",{
					BackgroundTransparency = 1,
					Name = "Arrow",
					Size = UDim2.new(0,size,0,size)
				})
				if dir == "up" then
					for i = 1,num do
						local newLine = createSimple("Frame",{
							BackgroundColor3 = Color3.new(220/255,220/255,220/255),
							BorderSizePixel = 0,
							Position = UDim2.new(0,math.floor(size/2)-(i-1),0,math.floor(size/2)+i-math.floor(max/2)-1),
							Size = UDim2.new(0,i+(i-1),0,1),
							Parent = arrowFrame
						})
					end
					return arrowFrame
				elseif dir == "down" then
					for i = 1,num do
						local newLine = createSimple("Frame",{
							BackgroundColor3 = Color3.new(220/255,220/255,220/255),
							BorderSizePixel = 0,
							Position = UDim2.new(0,math.floor(size/2)-(i-1),0,math.floor(size/2)-i+math.floor(max/2)+1),
							Size = UDim2.new(0,i+(i-1),0,1),
							Parent = arrowFrame
						})
					end
					return arrowFrame
				elseif dir == "left" then
					for i = 1,num do
						local newLine = createSimple("Frame",{
							BackgroundColor3 = Color3.new(220/255,220/255,220/255),
							BorderSizePixel = 0,
							Position = UDim2.new(0,math.floor(size/2)+i-math.floor(max/2)-1,0,math.floor(size/2)-(i-1)),
							Size = UDim2.new(0,1,0,i+(i-1)),
							Parent = arrowFrame
						})
					end
					return arrowFrame
				elseif dir == "right" then
					for i = 1,num do
						local newLine = createSimple("Frame",{
							BackgroundColor3 = Color3.new(220/255,220/255,220/255),
							BorderSizePixel = 0,
							Position = UDim2.new(0,math.floor(size/2)-i+math.floor(max/2)+1,0,math.floor(size/2)-(i-1)),
							Size = UDim2.new(0,1,0,i+(i-1)),
							Parent = arrowFrame
						})
					end
					return arrowFrame
				end
				error("r u ok")
			end

			Lib.ParseXML = (function()
				local func = function()
					
					

					local string, print, pairs = string, print, pairs

					
					local trim = function(s)
						local from = s:match"^%s*()"
						return from > #s and "" or s:match(".*%S", from)
					end

					local gtchar = string.byte('>', 1)
					local slashchar = string.byte('/', 1)
					local D = string.byte('D', 1)
					local E = string.byte('E', 1)

					function parse(s, evalEntities)
						
						s = s:gsub('<!%-%-(.-)%-%->', '')

						local entities, tentities = {}

						if evalEntities then
							local pos = s:find('<[_%w]')
							if pos then
								s:sub(1, pos):gsub('<!ENTITY%s+([_%w]+)%s+(.)(.-)%2', function(name, q, entity)
									entities[#entities+1] = {name=name, value=entity}
								end)
								tentities = createEntityTable(entities)
								s = replaceEntities(s:sub(pos), tentities)
							end
						end

						local t, l = {}, {}

						local addtext = function(txt)
							txt = txt:match'^%s*(.*%S)' or ''
							if #txt ~= 0 then
								t[#t+1] = {text=txt}
							end		
						end

						s:gsub('<([?!/]?)([-:_%w]+)%s*(/?>?)([^<]*)', function(type, name, closed, txt)
							
							if #type == 0 then
								local a = {}
								if #closed == 0 then
									local len = 0
									for all,aname,_,value,starttxt in string.gmatch(txt, "(.-([-_%w]+)%s*=%s*(.)(.-)%3%s*(/?>?))") do
										len = len + #all
										a[aname] = value
										if #starttxt ~= 0 then
											txt = txt:sub(len+1)
											closed = starttxt
											break
										end
									end
								end
								t[#t+1] = {tag=name, attrs=a, children={}}

								if closed:byte(1) ~= slashchar then
									l[#l+1] = t
									t = t[#t].children
								end

								addtext(txt)
								
							elseif '/' == type then
								t = l[#l]
								l[#l] = nil

								addtext(txt)
								
							elseif '!' == type then
								if E == name:byte(1) then
									txt:gsub('([_%w]+)%s+(.)(.-)%2', function(name, q, entity)
										entities[#entities+1] = {name=name, value=entity}
									end, 1)
								end
								
								
								
								
								
								
							end
						end)

						return {children=t, entities=entities, tentities=tentities}
					end

					function parseText(txt)
						return parse(txt)
					end

					function defaultEntityTable()
						return { quot='"', apos='\'', lt='<', gt='>', amp='&', tab='\t', nbsp=' ', }
					end

					function replaceEntities(s, entities)
						return s:gsub('&([^;]+);', entities)
					end

					function createEntityTable(docEntities, resultEntities)
						entities = resultEntities or defaultEntityTable()
						for _,e in pairs(docEntities) do
							e.value = replaceEntities(e.value, entities)
							entities[e.name] = e.value
						end
						return entities
					end

					return parseText
				end
				local newEnv = setmetatable({},{__index = getfenv()})
				setfenv(func,newEnv)
				return func()
			end)()

			Lib.FastWait = function(s)
				if not s then return signalWait(renderStepped) end
				local start = tick()
				while tick() - start < s do signalWait(renderStepped) end
			end

			Lib.ButtonAnim = function(button,data)
				local holding = false
				local disabled = false
				local mode = data and data.Mode or 1
				local control = {}

				if mode == 2 then
					local lerpTo = data.LerpTo or Color3.new(0,0,0)
					local delta = data.LerpDelta or 0.2
					control.StartColor = data.StartColor or button.BackgroundColor3
					control.PressColor = data.PressColor or control.StartColor:lerp(lerpTo,delta)
					control.HoverColor = data.HoverColor or control.StartColor:lerp(control.PressColor,0.6)
					control.OutlineColor = data.OutlineColor
				end

				button.InputBegan:Connect(function(input)
					if disabled then return end

					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						if not holding then
							if mode == 1 then
								button.BackgroundTransparency = 0.4
							elseif mode == 2 then
								button.BackgroundColor3 = control.HoverColor
							end
						end
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						holding = true
						if mode == 1 then
							button.BackgroundTransparency = 0
						elseif mode == 2 then
							button.BackgroundColor3 = control.PressColor
							if control.OutlineColor then button.BorderColor3 = control.PressColor end
						end
					end
				end)

				button.InputEnded:Connect(function(input)
					if disabled then return end

					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						if not holding then
							if mode == 1 then
								button.BackgroundTransparency = 1
							elseif mode == 2 then
								button.BackgroundColor3 = control.StartColor
							end
						end
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						holding = false
						if mode == 1 then
							button.BackgroundTransparency = Lib.CheckMouseInGui(button) and 0.4 or 1
						elseif mode == 2 then
							button.BackgroundColor3 = Lib.CheckMouseInGui(button) and control.HoverColor or control.StartColor
							if control.OutlineColor then button.BorderColor3 = control.OutlineColor end
						end
					end
				end)

				control.Disable = function()
					disabled = true
					holding = false

					if mode == 1 then
						button.BackgroundTransparency = 1
					elseif mode == 2 then
						button.BackgroundColor3 = control.StartColor
					end
				end

				control.Enable = function()
					disabled = false
				end

				return control
			end

			Lib.FindAndRemove = function(t,item)
				local pos = table.find(t,item)
				if pos then table.remove(t,pos) end
			end

			Lib.AttachTo = function(obj,data)
				local target,posOffX,posOffY,sizeOffX,sizeOffY,resize,con
				local disabled = false

				local function update()
					if not obj or not target then return end

					local targetPos = target.AbsolutePosition
					local targetSize = target.AbsoluteSize
					obj.Position = UDim2.new(0,targetPos.X + posOffX,0,targetPos.Y + posOffY)
					if resize then obj.Size = UDim2.new(0,targetSize.X + sizeOffX,0,targetSize.Y + sizeOffY) end
				end

				local function setup(o,data)
					obj = o
					data = data or {}
					target = data.Target
					posOffX = data.PosOffX or 0
					posOffY = data.PosOffY or 0
					sizeOffX = data.SizeOffX or 0
					sizeOffY = data.SizeOffY or 0
					resize = data.Resize or false

					if con then con:Disconnect() con = nil end
					if target then
						con = target.Changed:Connect(function(prop)
							if not disabled and prop == "AbsolutePosition" or prop == "AbsoluteSize" then
								update()
							end
						end)
					end

					update()
				end
				setup(obj,data)

				return {
					SetData = function(obj,data)
						setup(obj,data)
					end,
					Enable = function()
						disabled = false
						update()
					end,
					Disable = function()
						disabled = true
					end,
					Destroy = function()
						con:Disconnect()
						con = nil
					end,
				}
			end

			Lib.ProtectedGuis = {}

			Lib.ShowGui = function(gui)
				if env.gethui then
					gui.Parent = env.gethui()
				elseif env.protectgui then
					env.protectgui(gui)
					gui.Parent = Main.GuiHolder
				else
					gui.Parent = Main.GuiHolder
				end
			end

			Lib.ColorToBytes = function(col)
				local round = math.round
				return string.format("%d, %d, %d",round(col.r*255),round(col.g*255),round(col.b*255))
			end

			Lib.ReadFile = function(filename)
				if not env.readfile then return end

				local s,contents = pcall(env.readfile,filename)
				if s and contents then return contents end
			end

			Lib.DeferFunc = function(f,...)
				signalWait(renderStepped)
				return f(...)
			end

			Lib.LoadCustomAsset = function(filepath)
				if not env.getcustomasset or not env.isfile or not env.isfile(filepath) then return end

				return env.getcustomasset(filepath)
			end

			Lib.FetchCustomAsset = function(url,filepath)
				if not env.writefile then return end

				local s,data = pcall(oldgame.HttpGet,game,url)
				if not s then return end

				env.writefile(filepath,data)
				return Lib.LoadCustomAsset(filepath)
			end

			

			Lib.Signal = (function()
				local funcs = {}

				local disconnect = function(con)
					local pos = table.find(con.Signal.Connections,con)
					if pos then table.remove(con.Signal.Connections,pos) end
				end

				funcs.Connect = function(self,func)
					if type(func) ~= "function" then error("Attempt to connect a non-function") end		
					local con = {
						Signal = self,
						Func = func,
						Disconnect = disconnect
					}
					self.Connections[#self.Connections+1] = con
					return con
				end

				funcs.Fire = function(self,...)
					for i,v in next,self.Connections do
						xpcall(coroutine.wrap(v.Func),function(e) warn(e.."\n"..debug.traceback()) end,...)
					end
				end

				local mt = {
					__index = funcs,
					__tostring = function(self)
						return "Signal: " .. tostring(#self.Connections) .. " Connections"
					end
				}

				local function new()
					local obj = {}
					obj.Connections = {}

					return setmetatable(obj,mt)
				end

				return {new = new}
			end)()

			Lib.Set = (function()
				local funcs = {}

				funcs.Add = function(self,obj)
					if self.Map[obj] then return end

					local list = self.List
					list[#list+1] = obj
					self.Map[obj] = true
					self.Changed:Fire()
				end

				funcs.AddTable = function(self,t)
					local changed
					local list,map = self.List,self.Map
					for i = 1,#t do
						local elem = t[i]
						if not map[elem] then
							list[#list+1] = elem
							map[elem] = true
							changed = true
						end
					end
					if changed then self.Changed:Fire() end
				end

				funcs.Remove = function(self,obj)
					if not self.Map[obj] then return end

					local list = self.List
					local pos = table.find(list,obj)
					if pos then table.remove(list,pos) end
					self.Map[obj] = nil
					self.Changed:Fire()
				end

				funcs.RemoveTable = function(self,t)
					local changed
					local list,map = self.List,self.Map
					local removeSet = {}
					for i = 1,#t do
						local elem = t[i]
						map[elem] = nil
						removeSet[elem] = true
					end

					for i = #list,1,-1 do
						local elem = list[i]
						if removeSet[elem] then
							table.remove(list,i)
							changed = true
						end
					end
					if changed then self.Changed:Fire() end
				end

				funcs.Set = function(self,obj)
					if #self.List == 1 and self.List[1] == obj then return end

					self.List = {obj}
					self.Map = {[obj] = true}
					self.Changed:Fire()
				end

				funcs.SetTable = function(self,t)
					local newList,newMap = {},{}
					self.List,self.Map = newList,newMap
					table.move(t,1,#t,1,newList)
					for i = 1,#t do
						newMap[t[i]] = true
					end
					self.Changed:Fire()
				end

				funcs.Clear = function(self)
					if #self.List == 0 then return end
					self.List = {}
					self.Map = {}
					self.Changed:Fire()
				end

				local mt = {__index = funcs}

				local function new()
					local obj = setmetatable({
						List = {},
						Map = {},
						Changed = Lib.Signal.new()
					},mt)

					return obj
				end

				return {new = new}
			end)()

			Lib.IconMap = (function()
				local funcs = {}
				local _MapId, _Icons = (483448923), {
					["Accessory"] = 32;
					["Accoutrement"] = 32;
					["AdService"] = 73;
					["Animation"] = 60;
					["AnimationController"] = 60;
					["AnimationTrack"] = 60;
					["Animator"] = 60;
					["ArcHandles"] = 56;
					["AssetService"] = 72;
					["Attachment"] = 34;
					["Backpack"] = 20;
					["BadgeService"] = 75;
					["BallSocketConstraint"] = 89;
					["BillboardGui"] = 64;
					["BinaryStringValue"] = 4;
					["BindableEvent"] = 67;
					["BindableFunction"] = 66;
					["BlockMesh"] = 8;
					["BloomEffect"] = 90;
					["BlurEffect"] = 90;
					["BodyAngularVelocity"] = 14;
					["BodyForce"] = 14;
					["BodyGyro"] = 14;
					["BodyPosition"] = 14;
					["BodyThrust"] = 14;
					["BodyVelocity"] = 14;
					["BoolValue"] = 4;
					["BoxHandleAdornment"] = 54;
					["BrickColorValue"] = 4;
					["Camera"] = 5;
					["CFrameValue"] = 4;
					["CharacterMesh"] = 60;
					["Chat"] = 33;
					["ClickDetector"] = 41;
					["CollectionService"] = 30;
					["Color3Value"] = 4;
					["ColorCorrectionEffect"] = 90;
					["ConeHandleAdornment"] = 54;
					["Configuration"] = 58;
					["ContentProvider"] = 72;
					["ContextActionService"] = 41;
					["CoreGui"] = 46;
					["CoreScript"] = 18;
					["CornerWedgePart"] = 1;
					["CustomEvent"] = 4;
					["CustomEventReceiver"] = 4;
					["CylinderHandleAdornment"] = 54;
					["CylinderMesh"] = 8;
					["CylindricalConstraint"] = 89;
					["Debris"] = 30;
					["Decal"] = 7;
					["Dialog"] = 62;
					["DialogChoice"] = 63;
					["DoubleConstrainedValue"] = 4;
					["Explosion"] = 36;
					["FileMesh"] = 8;
					["Fire"] = 61;
					["Flag"] = 38;
					["FlagStand"] = 39;
					["FloorWire"] = 4;
					["Folder"] = 70;
					["ForceField"] = 37;
					["Frame"] = 48;
					["GamePassService"] = 19;
					["Glue"] = 34;
					["GuiButton"] = 52;
					["GuiMain"] = 47;
					["GuiService"] = 47;
					["Handles"] = 53;
					["HapticService"] = 84;
					["Hat"] = 45;
					["HingeConstraint"] = 89;
					["Hint"] = 33;
					["HopperBin"] = 22;
					["HttpService"] = 76;
					["Humanoid"] = 9;
					["ImageButton"] = 52;
					["ImageLabel"] = 49;
					["InsertService"] = 72;
					["IntConstrainedValue"] = 4;
					["IntValue"] = 4;
					["JointInstance"] = 34;
					["JointsService"] = 34;
					["Keyframe"] = 60;
					["KeyframeSequence"] = 60;
					["KeyframeSequenceProvider"] = 60;
					["Lighting"] = 13;
					["LineHandleAdornment"] = 54;
					["LocalScript"] = 18;
					["LogService"] = 87;
					["MarketplaceService"] = 46;
					["Message"] = 33;
					["Model"] = 2;
					["ModuleScript"] = 71;
					["Motor"] = 34;
					["Motor6D"] = 34;
					["MoveToConstraint"] = 89;
					["NegateOperation"] = 78;
					["NetworkClient"] = 16;
					["NetworkReplicator"] = 29;
					["NetworkServer"] = 15;
					["NumberValue"] = 4;
					["ObjectValue"] = 4;
					["Pants"] = 44;
					["ParallelRampPart"] = 1;
					["Part"] = 1;
					["ParticleEmitter"] = 69;
					["PartPairLasso"] = 57;
					["PathfindingService"] = 37;
					["Platform"] = 35;
					["Player"] = 12;
					["PlayerGui"] = 46;
					["Players"] = 21;
					["PlayerScripts"] = 82;
					["PointLight"] = 13;
					["PointsService"] = 83;
					["Pose"] = 60;
					["PrismaticConstraint"] = 89;
					["PrismPart"] = 1;
					["PyramidPart"] = 1;
					["RayValue"] = 4;
					["ReflectionMetadata"] = 86;
					["ReflectionMetadataCallbacks"] = 86;
					["ReflectionMetadataClass"] = 86;
					["ReflectionMetadataClasses"] = 86;
					["ReflectionMetadataEnum"] = 86;
					["ReflectionMetadataEnumItem"] = 86;
					["ReflectionMetadataEnums"] = 86;
					["ReflectionMetadataEvents"] = 86;
					["ReflectionMetadataFunctions"] = 86;
					["ReflectionMetadataMember"] = 86;
					["ReflectionMetadataProperties"] = 86;
					["ReflectionMetadataYieldFunctions"] = 86;
					["RemoteEvent"] = 80;
					["RemoteFunction"] = 79;
					["ReplicatedFirst"] = 72;
					["ReplicatedStorage"] = 72;
					["RightAngleRampPart"] = 1;
					["RocketPropulsion"] = 14;
					["RodConstraint"] = 89;
					["RopeConstraint"] = 89;
					["Rotate"] = 34;
					["RotateP"] = 34;
					["RotateV"] = 34;
					["RunService"] = 66;
					["ScreenGui"] = 47;
					["Script"] = 6;
					["ScrollingFrame"] = 48;
					["Seat"] = 35;
					["Selection"] = 55;
					["SelectionBox"] = 54;
					["SelectionPartLasso"] = 57;
					["SelectionPointLasso"] = 57;
					["SelectionSphere"] = 54;
					["ServerScriptService"] = 0;
					["ServerStorage"] = 74;
					["Shirt"] = 43;
					["ShirtGraphic"] = 40;
					["SkateboardPlatform"] = 35;
					["Sky"] = 28;
					["SlidingBallConstraint"] = 89;
					["Smoke"] = 59;
					["Snap"] = 34;
					["Sound"] = 11;
					["SoundService"] = 31;
					["Sparkles"] = 42;
					["SpawnLocation"] = 25;
					["SpecialMesh"] = 8;
					["SphereHandleAdornment"] = 54;
					["SpotLight"] = 13;
					["SpringConstraint"] = 89;
					["StarterCharacterScripts"] = 82;
					["StarterGear"] = 20;
					["StarterGui"] = 46;
					["StarterPack"] = 20;
					["StarterPlayer"] = 88;
					["StarterPlayerScripts"] = 82;
					["Status"] = 2;
					["StringValue"] = 4;
					["SunRaysEffect"] = 90;
					["SurfaceGui"] = 64;
					["SurfaceLight"] = 13;
					["SurfaceSelection"] = 55;
					["Team"] = 24;
					["Teams"] = 23;
					["TeleportService"] = 81;
					["Terrain"] = 65;
					["TerrainRegion"] = 65;
					["TestService"] = 68;
					["TextBox"] = 51;
					["TextButton"] = 51;
					["TextLabel"] = 50;
					["Texture"] = 10;
					["TextureTrail"] = 4;
					["Tool"] = 17;
					["TouchTransmitter"] = 37;
					["TrussPart"] = 1;
					["UnionOperation"] = 77;
					["UserInputService"] = 84;
					["Vector3Value"] = 4;
					["VehicleSeat"] = 35;
					["VelocityMotor"] = 34;
					["WedgePart"] = 1;
					["Weld"] = 34;
					["Workspace"] = 19;

				}
				funcs.ExplorerIcons = { ["MapId"] = _MapId, ["Icons"] = _Icons }

				funcs.GetLabel = function(self)
					local label = Instance.new("ImageLabel")
					self:SetupLabel(label)
					return label
				end

				funcs.SetupLabel = function(self,obj)
					obj.BackgroundTransparency = 1
					obj.ImageRectOffset = Vector2.new(0, 0)
					obj.ImageRectSize = Vector2.new(self.IconSizeX, self.IconSizeY)
					obj.ScaleType = Enum.ScaleType.Crop
					obj.Size = UDim2.new(0, self.IconSizeX, 0, self.IconSizeY)
				end

				funcs.Display = function(self,obj,index)
					obj.Image = self.MapId
					if not self.NumX then
						obj.ImageRectOffset = Vector2.new(self.IconSizeX*index, 0)
					else
						obj.ImageRectOffset = Vector2.new(self.IconSizeX*(index % self.NumX), self.IconSizeY*math.floor(index / self.NumX))
					end
				end

				funcs.DisplayByKey = function(self, obj, key)
					if self.IndexDict[key] then
						self:Display(obj, self.IndexDict[key])
					else
						local rmdEntry = RMD.Classes[obj.ClassName]
						Explorer.ClassIcons:Display(obj, rmdEntry and rmdEntry.ExplorerImageIndex or 0)
					end
				end

				funcs.IconDehash = function(self, _id)
					return math.floor(_id / 14 % 14), math.floor(_id % 14)
				end

				funcs.GetExplorerIcon = function(self, obj, index)
					index = (self.ExplorerIcons.Icons[index] or 0)
					local row, col = self:IconDehash(index)
					local MapSize = Vector2.new(256, 256)
					local pad, border = 2, 1
					local IconSize = 16

					obj.Position = UDim2.new(-col - (pad * (col + 1) + border) / IconSize, 0, -row - (pad * (row + 1) + border) / IconSize, 0)
					obj.Size = UDim2.new(MapSize.X / IconSize, 0, MapSize.Y / IconSize, 0)
				end

				funcs.DisplayExplorerIcons = function(self, Frame, index)
					if Frame:FindFirstChild("IconMap") then
						self:GetExplorerIcon(Frame.IconMap, index)
					else
						Frame.ClipsDescendants = true

						local obj = Instance.new("ImageLabel", Frame)
						obj.BackgroundTransparency = 1
						obj.Image = ("http://www.roblox.com/asset/?id=" .. (self.ExplorerIcons.MapId))
						obj.Name = "IconMap"
						self:GetExplorerIcon(obj, index)
					end
				end

				funcs.SetDict = function(self,dict)
					self.IndexDict = dict
				end

				local mt = {}
				mt.__index = funcs

				local function new(mapId,mapSizeX,mapSizeY,iconSizeX,iconSizeY)
					local obj = setmetatable({
						MapId = mapId,
						MapSizeX = mapSizeX,
						MapSizeY = mapSizeY,
						IconSizeX = iconSizeX,
						IconSizeY = iconSizeY,
						NumX = mapSizeX/iconSizeX,
						IndexDict = {}
					}, mt)
					return obj
				end

				local function newLinear(mapId,iconSizeX,iconSizeY)
					local obj = setmetatable({
						MapId = mapId,
						IconSizeX = iconSizeX,
						IconSizeY = iconSizeY,
						IndexDict = {}
					},mt)
					return obj
				end

				return {new = new, newLinear = newLinear}
			end)()

			Lib.ScrollBar = (function()
				local funcs = {}
				local user = service.UserInputService
				local mouse = plr:GetMouse()
				local checkMouseInGui = Lib.CheckMouseInGui
				local createArrow = Lib.CreateArrow

				local function drawThumb(self)
					local total = self.TotalSpace
					local visible = self.VisibleSpace
					local index = self.Index
					local scrollThumb = self.GuiElems.ScrollThumb
					local scrollThumbFrame = self.GuiElems.ScrollThumbFrame

					if not (self:CanScrollUp()	or self:CanScrollDown()) then
						scrollThumb.Visible = false
					else
						scrollThumb.Visible = true
					end

					if self.Horizontal then
						scrollThumb.Size = UDim2.new(visible/total,0,1,0)
						if scrollThumb.AbsoluteSize.X < 16 then
							scrollThumb.Size = UDim2.new(0,16,1,0)
						end
						local fs = scrollThumbFrame.AbsoluteSize.X
						local bs = scrollThumb.AbsoluteSize.X
						scrollThumb.Position = UDim2.new(self:GetScrollPercent()*(fs-bs)/fs,0,0,0)
					else
						scrollThumb.Size = UDim2.new(1,0,visible/total,0)
						if scrollThumb.AbsoluteSize.Y < 16 then
							scrollThumb.Size = UDim2.new(1,0,0,16)
						end
						local fs = scrollThumbFrame.AbsoluteSize.Y
						local bs = scrollThumb.AbsoluteSize.Y
						scrollThumb.Position = UDim2.new(0,0,self:GetScrollPercent()*(fs-bs)/fs,0)
					end
				end

				local function createFrame(self)
					local newFrame = createSimple("Frame",{Style=0,Active=true,AnchorPoint=Vector2.new(0,0),BackgroundColor3=Color3.new(0.35294118523598,0.35294118523598,0.35294118523598),BackgroundTransparency=0,BorderColor3=Color3.new(0.10588236153126,0.16470588743687,0.20784315466881),BorderSizePixel=0,ClipsDescendants=false,Draggable=false,Position=UDim2.new(1,-16,0,0),Rotation=0,Selectable=false,Size=UDim2.new(0,16,1,0),SizeConstraint=0,Visible=true,ZIndex=1,Name="ScrollBar",})
					local button1, button2

					if self.Horizontal then
						newFrame.Size = UDim2.new(1,0,0,16)
						button1 = createSimple("ImageButton",{
							Parent = newFrame,
							Name = "Left",
							Size = UDim2.new(0,16,0,16),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							AutoButtonColor = false
						})
						createArrow(16,4,"left").Parent = button1
						button2 = createSimple("ImageButton",{
							Parent = newFrame,
							Name = "Right",
							Position = UDim2.new(1,-16,0,0),
							Size = UDim2.new(0,16,0,16),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							AutoButtonColor = false
						})
						createArrow(16,4,"right").Parent = button2
					else
						newFrame.Size = UDim2.new(0,16,1,0)
						button1 = createSimple("ImageButton",{
							Parent = newFrame,
							Name = "Up",
							Size = UDim2.new(0,16,0,16),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							AutoButtonColor = false
						})
						createArrow(16,4,"up").Parent = button1
						button2 = createSimple("ImageButton",{
							Parent = newFrame,
							Name = "Down",
							Position = UDim2.new(0,0,1,-16),
							Size = UDim2.new(0,16,0,16),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							AutoButtonColor = false
						})
						createArrow(16,4,"down").Parent = button2
					end

					local scrollThumbFrame = createSimple("ImageButton", {
						BackgroundTransparency = 1,
						Parent = newFrame
					})
					if self.Horizontal then
						scrollThumbFrame.Position = UDim2.new(0,16,0,0)
						scrollThumbFrame.Size = UDim2.new(1,-32,1,0)
					else
						scrollThumbFrame.Position = UDim2.new(0,0,0,16)
						scrollThumbFrame.Size = UDim2.new(1,0,1,-32)
					end

					local scrollThumb = createSimple("Frame", {
						BackgroundColor3 = Color3.new(120/255, 120/255, 120/255),
						BorderSizePixel = 0,
						Parent = scrollThumbFrame
					})

					local markerFrame = createSimple("Frame", {
						BackgroundTransparency = 1,
						Name = "Markers",
						Size = UDim2.new(1, 0, 1, 0),
						Parent = scrollThumbFrame
					})

					local buttonPress = false
					local thumbPress = false
					local thumbFramePress = false

					local function handleButtonPress(button, scrollDirection)
						if self:CanScroll(scrollDirection) then
							button.BackgroundTransparency = 0.5
							self:ScrollToDirection(scrollDirection)
							self.Scrolled:Fire()
							local buttonTick = tick()
							local releaseEvent
							releaseEvent = user.InputEnded:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
									releaseEvent:Disconnect()
									button.BackgroundTransparency = checkMouseInGui(button) and 0.8 or 1
									buttonPress = false
								end
							end)
							while buttonPress do
								if tick() - buttonTick >= 0.25 and self:CanScroll(scrollDirection) then
									self:ScrollToDirection(scrollDirection)
									self.Scrolled:Fire()
								end
								task.wait()
							end
						end
					end

					button1.MouseButton1Down:Connect(function(input)
						buttonPress = true
						handleButtonPress(button1, "Up")
					end)

					button1.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							button1.BackgroundTransparency = 1
						end
					end)

					button2.MouseButton1Down:Connect(function(input)
						buttonPress = true
						handleButtonPress(button2, "Down")
					end)

					button2.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							button2.BackgroundTransparency = 1
						end
					end)

					scrollThumb.InputBegan:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
							local dir = self.Horizontal and "X" or "Y"
							local lastThumbPos = nil
							thumbPress = true
							scrollThumb.BackgroundTransparency = 0
							local mouseOffset = mouse[dir] - scrollThumb.AbsolutePosition[dir]
							local releaseEvent
							local mouseEvent

							releaseEvent = user.InputEnded:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
									releaseEvent:Disconnect()
									if mouseEvent then mouseEvent:Disconnect() end
									scrollThumb.BackgroundTransparency = 0.2
									thumbPress = false
								end
							end)

							mouseEvent = user.InputChanged:Connect(function(input)
								if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and thumbPress then
									local thumbFrameSize = scrollThumbFrame.AbsoluteSize[dir] - scrollThumb.AbsoluteSize[dir]
									local pos = mouse[dir] - scrollThumbFrame.AbsolutePosition[dir] - mouseOffset
									if pos > thumbFrameSize then pos = thumbFrameSize
									elseif pos < 0 then pos = 0 end
									if lastThumbPos ~= pos then
										lastThumbPos = pos
										self:ScrollTo(math.floor(0.5 + pos / thumbFrameSize * (self.TotalSpace - self.VisibleSpace)))
									end
								end
							end)
						end
					end)

					scrollThumb.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							scrollThumb.BackgroundTransparency = 0
						end
					end)

					scrollThumbFrame.InputBegan:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not checkMouseInGui(scrollThumb) then
							local dir = self.Horizontal and "X" or "Y"
							local scrollDir = (mouse[dir] >= scrollThumb.AbsolutePosition[dir] + scrollThumb.AbsoluteSize[dir]) and 1 or 0
							local function doTick()
								local scrollSize = self.VisibleSpace - 1
								if scrollDir == 0 and mouse[dir] < scrollThumb.AbsolutePosition[dir] then
									self:ScrollTo(self.Index - scrollSize)
								elseif scrollDir == 1 and mouse[dir] >= scrollThumb.AbsolutePosition[dir] + scrollThumb.AbsoluteSize[dir] then
									self:ScrollTo(self.Index + scrollSize)
								end
							end

							thumbPress = false
							thumbFramePress = true
							doTick()
							local thumbFrameTick = tick()
							local releaseEvent
							releaseEvent = user.InputEnded:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
									releaseEvent:Disconnect()
									thumbFramePress = false
								end
							end)

							while thumbFramePress do
								if tick() - thumbFrameTick >= 0.3 and checkMouseInGui(scrollThumbFrame) then
									doTick()
								end
								task.wait()
							end
						end
					end)

					newFrame.MouseWheelForward:Connect(function()
						self:ScrollTo(self.Index - self.WheelIncrement)
					end)

					newFrame.MouseWheelBackward:Connect(function()
						self:ScrollTo(self.Index + self.WheelIncrement)
					end)

					self.GuiElems.ScrollThumb = scrollThumb
					self.GuiElems.ScrollThumbFrame = scrollThumbFrame
					self.GuiElems.Button1 = button1
					self.GuiElems.Button2 = button2
					self.GuiElems.MarkerFrame = markerFrame

					return newFrame
				end

				funcs.Update = function(self,nocallback)
					local total = self.TotalSpace
					local visible = self.VisibleSpace
					local index = self.Index
					local button1 = self.GuiElems.Button1
					local button2 = self.GuiElems.Button2

					self.Index = math.clamp(self.Index, 0, math.max(0, total - visible))

					if self.LastTotalSpace ~= self.TotalSpace then
						self.LastTotalSpace = self.TotalSpace
						self:UpdateMarkers()
					end

					if self:CanScrollUp() then
						for i,v in pairs(button1.Arrow:GetChildren()) do
							v.BackgroundTransparency = 0
						end
					else
						button1.BackgroundTransparency = 1
						for i,v in pairs(button1.Arrow:GetChildren()) do
							v.BackgroundTransparency = 0.5
						end
					end
					if self:CanScrollDown() then
						for i,v in pairs(button2.Arrow:GetChildren()) do
							v.BackgroundTransparency = 0
						end
					else
						button2.BackgroundTransparency = 1
						for i,v in pairs(button2.Arrow:GetChildren()) do
							v.BackgroundTransparency = 0.5
						end
					end

					drawThumb(self)
				end

				funcs.UpdateMarkers = function(self)
					local markerFrame = self.GuiElems.MarkerFrame
					markerFrame:ClearAllChildren()

					for i,v in pairs(self.Markers) do
						if i < self.TotalSpace then
							createSimple("Frame", {
								BackgroundTransparency = 0,
								BackgroundColor3 = v,
								BorderSizePixel = 0,
								Position = self.Horizontal and UDim2.new(i/self.TotalSpace,0,1,-6) or UDim2.new(1,-6,i/self.TotalSpace,0),
								Size = self.Horizontal and UDim2.new(0,1,0,6) or UDim2.new(0,6,0,1),
								Name = "Marker"..tostring(i),
								Parent = markerFrame
							})
						end
					end
				end

				funcs.AddMarker = function(self,ind,color)
					self.Markers[ind] = color or Color3.new(0,0,0)
				end
				funcs.ScrollTo = function(self, ind, nocallback)
					self.Index = ind
					self:Update()
					if not nocallback then
						self.Scrolled:Fire()
					end
				end
				funcs.ScrollUp = function(self)
					self.Index = self.Index - self.Increment
					self:Update()
				end
				funcs.CanScroll = function(self, direction)
					if direction == "Up" then
						return self:CanScrollUp()
					elseif direction == "Down" then
						return self:CanScrollDown()
					end
					return false
				end
				funcs.ScrollDown = function(self)
					self.Index = self.Index + self.Increment
					self:Update()
				end
				funcs.CanScrollUp = function(self)
					return self.Index > 0
				end
				funcs.CanScrollDown = function(self)
					return self.Index + self.VisibleSpace < self.TotalSpace
				end
				funcs.GetScrollPercent = function(self)
					return self.Index/(self.TotalSpace-self.VisibleSpace)
				end
				funcs.SetScrollPercent = function(self,perc)
					self.Index = math.floor(perc*(self.TotalSpace-self.VisibleSpace))
					self:Update()
				end
				funcs.ScrollToDirection = function(self, Direaction)
					if Direaction == "Up" then
						self:ScrollUp()
					elseif Direaction == "Down" then
						self:ScrollDown()
					end
				end

				funcs.Texture = function(self,data)
					self.ThumbColor = data.ThumbColor or Color3.new(0,0,0)
					self.ThumbSelectColor = data.ThumbSelectColor or Color3.new(0,0,0)
					self.GuiElems.ScrollThumb.BackgroundColor3 = data.ThumbColor or Color3.new(0,0,0)
					self.Gui.BackgroundColor3 = data.FrameColor or Color3.new(0,0,0)
					self.GuiElems.Button1.BackgroundColor3 = data.ButtonColor or Color3.new(0,0,0)
					self.GuiElems.Button2.BackgroundColor3 = data.ButtonColor or Color3.new(0,0,0)
					for i,v in pairs(self.GuiElems.Button1.Arrow:GetChildren()) do
						v.BackgroundColor3 = data.ArrowColor or Color3.new(0,0,0)
					end
					for i,v in pairs(self.GuiElems.Button2.Arrow:GetChildren()) do
						v.BackgroundColor3 = data.ArrowColor or Color3.new(0,0,0)
					end
				end

				funcs.SetScrollFrame = function(self,frame)
					if self.ScrollUpEvent then self.ScrollUpEvent:Disconnect() self.ScrollUpEvent = nil end
					if self.ScrollDownEvent then self.ScrollDownEvent:Disconnect() self.ScrollDownEvent = nil end
					self.ScrollUpEvent = frame.MouseWheelForward:Connect(function() self:ScrollTo(self.Index - self.WheelIncrement) end)
					self.ScrollDownEvent = frame.MouseWheelBackward:Connect(function() self:ScrollTo(self.Index + self.WheelIncrement) end)
				end

				local mt = {}
				mt.__index = funcs

				local function new(hor)
					local obj = setmetatable({
						Index = 0,
						VisibleSpace = 0,
						TotalSpace = 0,
						Increment = 1,
						WheelIncrement = 1,
						Markers = {},
						GuiElems = {},
						Horizontal = hor,
						LastTotalSpace = 0,
						Scrolled = Lib.Signal.new()
					},mt)
					obj.Gui = createFrame(obj)
					obj:Texture({
						ThumbColor = Color3.fromRGB(60,60,60),
						ThumbSelectColor = Color3.fromRGB(75,75,75),
						ArrowColor = Color3.new(1,1,1),
						FrameColor = Color3.fromRGB(40,40,40),
						ButtonColor = Color3.fromRGB(75,75,75)
					})
					return obj
				end

				return {new = new}
			end)()

			Lib.Window = (function()
				local funcs = {}
				local static = {MinWidth = 200, FreeWidth = 200}
				local mouse = plr:GetMouse()
				local sidesGui, alignIndicator
				local visibleWindows = {}
				local leftSide = {Width = 300, Windows = {}, ResizeCons = {}, Hidden = true}
				local rightSide = {Width = 300, Windows = {}, ResizeCons = {}, Hidden = true}

				local displayOrderStart
				local sideDisplayOrder
				local sideTweenInfo = TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
				local tweens = {}
				local isA = game.IsA

				local theme = {
					MainColor1 = Color3.fromRGB(52,52,52),
					MainColor2 = Color3.fromRGB(45,45,45),
					Button = Color3.fromRGB(60,60,60)
				}

				local function stopTweens()
					for i = 1,#tweens do
						tweens[i]:Cancel()
					end
					tweens = {}
				end

				local function resizeHook(self,resizer,dir)
					local guiMain = self.GuiElems.Main
					resizer.InputBegan:Connect(function(input)
						if not self.Dragging and not self.Resizing and self.Resizable and self.ResizableInternal then
							local isH = dir:find("[WE]") and true
							local isV = dir:find("[NS]") and true
							local signX = dir:find("W",1,true) and -1 or 1
							local signY = dir:find("N",1,true) and -1 or 1

							if self.Minimized and isV then return end

							if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
								resizer.BackgroundTransparency = 0.5
							elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								local releaseEvent, mouseEvent

								local offX = input.Position.X - resizer.AbsolutePosition.X
								local offY = input.Position.Y - resizer.AbsolutePosition.Y

								self.Resizing = resizer
								resizer.BackgroundTransparency = 1

								releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
									if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
										releaseEvent:Disconnect()
										if mouseEvent then mouseEvent:Disconnect() end
										self.Resizing = false
										resizer.BackgroundTransparency = 1
									end
								end)

								mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
									if self.Resizable and self.ResizableInternal and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
										self:StopTweens()
										local deltaX = input.Position.X - resizer.AbsolutePosition.X - offX
										local deltaY = input.Position.Y - resizer.AbsolutePosition.Y - offY

										if guiMain.AbsoluteSize.X + deltaX * signX < self.MinX then deltaX = signX * (self.MinX - guiMain.AbsoluteSize.X) end
										if guiMain.AbsoluteSize.Y + deltaY * signY < self.MinY then deltaY = signY * (self.MinY - guiMain.AbsoluteSize.Y) end
										if signY < 0 and guiMain.AbsolutePosition.Y + deltaY < 0 then deltaY = -guiMain.AbsolutePosition.Y end

										guiMain.Position = guiMain.Position + UDim2.new(0, (signX < 0 and deltaX or 0), 0, (signY < 0 and deltaY or 0))
										self.SizeX = self.SizeX + (isH and deltaX * signX or 0)
										self.SizeY = self.SizeY + (isV and deltaY * signY or 0)
										guiMain.Size = UDim2.new(0, self.SizeX, 0, self.Minimized and 20 or self.SizeY)
									end
								end)
							end
						end
					end)

					resizer.InputEnded:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and self.Resizing ~= resizer then
							resizer.BackgroundTransparency = 1
						end
					end)
				end

				local updateWindows

				local function moveToTop(window)
					local found = table.find(visibleWindows,window)
					if found then
						table.remove(visibleWindows,found)
						table.insert(visibleWindows,1,window)
						updateWindows()
					end
				end

				local function sideHasRoom(side,neededSize)
					local maxY = sidesGui.AbsoluteSize.Y - (math.max(0,#side.Windows - 1) * 4)
					local inc = 0
					for i,v in pairs(side.Windows) do
						inc = inc + (v.MinY or 100)
						if inc > maxY - neededSize then return false end
					end

					return true
				end

				local function getSideInsertPos(side,curY)
					local pos = #side.Windows + 1
					local range = {0,sidesGui.AbsoluteSize.Y}

					for i,v in pairs(side.Windows) do
						local midPos = v.PosY + v.SizeY/2
						if curY <= midPos then
							pos = i
							range[2] = midPos
							break
						else
							range[1] = midPos
						end
					end

					return pos,range
				end

				local function focusInput(self,obj)
					if isA(obj,"GuiButton") then
						obj.MouseButton1Down:Connect(function()
							moveToTop(self)
						end)
					elseif isA(obj,"TextBox") then
						obj.Focused:Connect(function()
							moveToTop(self)
						end)
					end
				end

				local createGui = function(self)
					local gui = create({
						{1,"ScreenGui",{Name="Window",}},
						{2,"Frame",{Active=true,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Main",Parent={1},Position=UDim2.new(0.40000000596046,0,0.40000000596046,0),Size=UDim2.new(0,300,0,300),}},
						{3,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,Name="Content",Parent={2},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),ClipsDescendants=true}},
						{4,"Frame",{BackgroundColor3=Color3.fromRGB(33,33,33),BorderSizePixel=0,Name="Line",Parent={3},Size=UDim2.new(1,0,0,1),}},
						{5,"TextButton",{Text="",AutoButtonColor=false,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="TopBar",Parent={2},Size=UDim2.new(1,0,0,20),}},
						{6,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={5},Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,0,20),Text="Window",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,}},
						{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Close",Parent={5},Position=UDim2.new(1,-18,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
						{8,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5054663650",Parent={7},Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,10,0,10),}},
						{9,"UICorner",{CornerRadius=UDim.new(0,4),Parent={7},}},
						{10,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Minimize",Parent={5},Position=UDim2.new(1,-36,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
						{11,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://5034768003",Parent={10},Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,10,0,10),}},
						{12,"UICorner",{CornerRadius=UDim.new(0,4),Parent={10},}},
						{13,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://1427967925",Name="Outlines",Parent={2},Position=UDim2.new(0,-5,0,-5),ScaleType=1,Size=UDim2.new(1,10,1,10),SliceCenter=Rect.new(6,6,25,25),TileSize=UDim2.new(0,20,0,20),}},
						{14,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="ResizeControls",Parent={2},Position=UDim2.new(0,-5,0,-5),Size=UDim2.new(1,10,1,10),}},
						{15,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="North",Parent={14},Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{16,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="South",Parent={14},Position=UDim2.new(0,5,1,-5),Size=UDim2.new(1,-10,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{17,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="NorthEast",Parent={14},Position=UDim2.new(1,-5,0,0),Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{18,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="East",Parent={14},Position=UDim2.new(1,-5,0,5),Size=UDim2.new(0,5,1,-10),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{19,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="West",Parent={14},Position=UDim2.new(0,0,0,5),Size=UDim2.new(0,5,1,-10),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{20,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="SouthEast",Parent={14},Position=UDim2.new(1,-5,1,-5),Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{21,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="NorthWest",Parent={14},Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{22,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.27450981736183,0.27450981736183,0.27450981736183),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="SouthWest",Parent={14},Position=UDim2.new(0,0,1,-5),Size=UDim2.new(0,5,0,5),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
					})

					local guiMain = gui.Main
					local guiTopBar = guiMain.TopBar
					local guiResizeControls = guiMain.ResizeControls

					self.GuiElems.Main = guiMain
					self.GuiElems.TopBar = guiMain.TopBar
					self.GuiElems.Content = guiMain.Content
					self.GuiElems.Line = guiMain.Content.Line
					self.GuiElems.Outlines = guiMain.Outlines
					self.GuiElems.Title = guiTopBar.Title
					self.GuiElems.Close = guiTopBar.Close
					self.GuiElems.Minimize = guiTopBar.Minimize
					self.GuiElems.ResizeControls = guiResizeControls
					self.ContentPane = guiMain.Content

					local ButtonDown = false
					guiTopBar.MouseButton1Down:Connect(function() ButtonDown = true end)
					guiTopBar.MouseButton1Up:Connect(function() ButtonDown = false end)

					guiTopBar.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							if self.Draggable then
								local releaseEvent, mouseEvent

								local maxX = sidesGui.AbsoluteSize.X
								local initX = guiMain.AbsolutePosition.X
								local initY = guiMain.AbsolutePosition.Y
								local offX = input.Position.X - initX
								local offY = input.Position.Y - initY

								local alignInsertPos, alignInsertSide

								guiDragging = true

								releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
									if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
										releaseEvent:Disconnect()
										if mouseEvent then mouseEvent:Disconnect() end
										guiDragging = false
										alignIndicator.Parent = nil
										if alignInsertSide then
											local targetSide = (alignInsertSide == "left" and leftSide) or (alignInsertSide == "right" and rightSide)
											self:AlignTo(targetSide, alignInsertPos)
										end
									end
								end)

								mouseEvent = service.UserInputService.InputChanged:Connect(function(input)
									if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and self.Draggable and not self.Closed and ButtonDown then
										if self.Aligned then
											if leftSide.Resizing or rightSide.Resizing then return end
											local posX, posY = input.Position.X - offX, input.Position.Y - offY
											local delta = math.sqrt((posX - initX)^2 + (posY - initY)^2)
											if delta >= 5 then
												self:SetAligned(false)
											end
										else
											local inputX, inputY = input.Position.X, input.Position.Y
											local posX, posY = inputX - offX, inputY - offY
											if posY < 0 then posY = 0 end
											guiMain.Position = UDim2.new(0, posX, 0, posY)

											if self.Resizable and self.Alignable then
												if inputX < 25 then
													if sideHasRoom(leftSide, self.MinY or 100) then
														local insertPos, range = getSideInsertPos(leftSide, inputY)
														alignIndicator.Indicator.Position = UDim2.new(0, -15, 0, range[1])
														alignIndicator.Indicator.Size = UDim2.new(0, 40, 0, range[2] - range[1])
														Lib.ShowGui(alignIndicator)
														alignInsertPos = insertPos
														alignInsertSide = "left"
														return
													end
												elseif inputX >= maxX - 25 then
													if sideHasRoom(rightSide, self.MinY or 100) then
														local insertPos, range = getSideInsertPos(rightSide, inputY)
														alignIndicator.Indicator.Position = UDim2.new(0, maxX - 25, 0, range[1])
														alignIndicator.Indicator.Size = UDim2.new(0, 40, 0, range[2] - range[1])
														Lib.ShowGui(alignIndicator)
														alignInsertPos = insertPos
														alignInsertSide = "right"
														return
													end
												end
											end
											alignIndicator.Parent = nil
											alignInsertPos = nil
											alignInsertSide = nil
										end
									end
								end)
							end
						end
					end)

					guiTopBar.Close.MouseButton1Click:Connect(function()
						if self.Closed then return end
						self:Close()
					end)

					guiTopBar.Minimize.MouseButton1Click:Connect(function()
						if self.Closed then return end
						if self.Aligned then
							self:SetAligned(false)
						else
							self:SetMinimized()
						end
					end)

					guiTopBar.Minimize.MouseButton2Click:Connect(function()
						if self.Closed then return end
						if not self.Aligned then
							self:SetMinimized(nil,2)
							guiTopBar.Minimize.BackgroundTransparency = 1
						end
					end)

					guiMain.InputBegan:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not self.Aligned and not self.Closed then
							moveToTop(self)
						end
					end)

					guiMain:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
						local absPos = guiMain.AbsolutePosition
						self.PosX = absPos.X
						self.PosY = absPos.Y
					end)

					resizeHook(self,guiResizeControls.North,"N")
					resizeHook(self,guiResizeControls.NorthEast,"NE")
					resizeHook(self,guiResizeControls.East,"E")
					resizeHook(self,guiResizeControls.SouthEast,"SE")
					resizeHook(self,guiResizeControls.South,"S")
					resizeHook(self,guiResizeControls.SouthWest,"SW")
					resizeHook(self,guiResizeControls.West,"W")
					resizeHook(self,guiResizeControls.NorthWest,"NW")

					guiMain.Size = UDim2.new(0,self.SizeX,0,self.SizeY)

					gui.DescendantAdded:Connect(function(obj) focusInput(self,obj) end)
					local descs = gui:GetDescendants()
					for i = 1,#descs do
						focusInput(self,descs[i])
					end

					self.MinimizeAnim = Lib.ButtonAnim(guiTopBar.Minimize)
					self.CloseAnim = Lib.ButtonAnim(guiTopBar.Close)

					return gui
				end

				local function updateSideFrames(noTween)
					stopTweens()
					leftSide.Frame.Size = UDim2.new(0,leftSide.Width,1,0)
					rightSide.Frame.Size = UDim2.new(0,rightSide.Width,1,0)
					leftSide.Frame.Resizer.Position = UDim2.new(0,leftSide.Width,0,0)
					rightSide.Frame.Resizer.Position = UDim2.new(0,-5,0,0)

					
					

			






					local leftHidden = #leftSide.Windows == 0 or leftSide.Hidden
					local rightHidden = #rightSide.Windows == 0 or rightSide.Hidden
					local leftPos = (leftHidden and UDim2.new(0,-leftSide.Width-10,0,0) or UDim2.new(0,0,0,0))
					local rightPos = (rightHidden and UDim2.new(1,10,0,0) or UDim2.new(1,-rightSide.Width,0,0))

					sidesGui.LeftToggle.Text = leftHidden and ">" or "<"
					sidesGui.RightToggle.Text = rightHidden and "<" or ">"

					if not noTween then
						local function insertTween(...)
							local tween = service.TweenService:Create(...)
							tweens[#tweens+1] = tween
							tween:Play()
						end
						insertTween(leftSide.Frame,sideTweenInfo,{Position = leftPos})
						insertTween(rightSide.Frame,sideTweenInfo,{Position = rightPos})
						insertTween(sidesGui.LeftToggle,sideTweenInfo,{Position = UDim2.new(0,#leftSide.Windows == 0 and -16 or 0,0,-36)})
						insertTween(sidesGui.RightToggle,sideTweenInfo,{Position = UDim2.new(1,#rightSide.Windows == 0 and 0 or -16,0,-36)})
					else
						leftSide.Frame.Position = leftPos
						rightSide.Frame.Position = rightPos
						sidesGui.LeftToggle.Position = UDim2.new(0,#leftSide.Windows == 0 and -16 or 0,0,-36)
						sidesGui.RightToggle.Position = UDim2.new(1,#rightSide.Windows == 0 and 0 or -16,0,-36)
					end
				end

				local function getSideFramePos(side)
					local leftHidden = #leftSide.Windows == 0 or leftSide.Hidden
					local rightHidden = #rightSide.Windows == 0 or rightSide.Hidden
					if side == leftSide then
						return (leftHidden and UDim2.new(0,-leftSide.Width-10,0,0) or UDim2.new(0,0,0,0))
					else
						return (rightHidden and UDim2.new(1,10,0,0) or UDim2.new(1,-rightSide.Width,0,0))
					end
				end

				local function sideResized(side)
					local currentPos = 0
					local sideFramePos = getSideFramePos(side)
					for i,v in pairs(side.Windows) do
						v.SizeX = side.Width
						v.GuiElems.Main.Size = UDim2.new(0,side.Width,0,v.SizeY)
						v.GuiElems.Main.Position = UDim2.new(sideFramePos.X.Scale,sideFramePos.X.Offset,0,currentPos)
						currentPos = currentPos + v.SizeY+4
					end
				end

				local function sideResizerHook(resizer,dir,side,pos)
					local mouse = Main.Mouse
					local windows = side.Windows

					resizer.InputBegan:Connect(function(input)
						if not side.Resizing then
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								resizer.BackgroundColor3 = theme.MainColor2
							elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								local releaseEvent, inputEvent

								local offX = input.Position.X - resizer.AbsolutePosition.X
								local offY = input.Position.Y - resizer.AbsolutePosition.Y

								side.Resizing = resizer
								resizer.BackgroundColor3 = theme.MainColor2

								releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
									if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
										releaseEvent:Disconnect()
										if inputEvent then inputEvent:Disconnect() end
										side.Resizing = false
										resizer.BackgroundColor3 = theme.Button
									end
								end)

								inputEvent = service.UserInputService.InputChanged:Connect(function(input)
									if not resizer.Parent then
										releaseEvent:Disconnect()
										if inputEvent then inputEvent:Disconnect() end
										side.Resizing = false
										return
									end

									if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
										if dir == "V" then
											local delta = input.Position.Y - resizer.AbsolutePosition.Y - offY

											if delta > 0 then
												local neededSize = delta
												for i = pos + 1, #windows do
													local window = windows[i]
													local newSize = math.max(window.SizeY - neededSize, (window.MinY or 100))
													neededSize = neededSize - (window.SizeY - newSize)
													window.SizeY = newSize
												end
												windows[pos].SizeY = windows[pos].SizeY + math.max(0, delta - neededSize)
											else
												local neededSize = -delta
												for i = pos, 1, -1 do
													local window = windows[i]
													local newSize = math.max(window.SizeY - neededSize, (window.MinY or 100))
													neededSize = neededSize - (window.SizeY - newSize)
													window.SizeY = newSize
												end
												windows[pos + 1].SizeY = windows[pos + 1].SizeY + math.max(0, -delta - neededSize)
											end

											updateSideFrames()
											sideResized(side)
										elseif dir == "H" then
											local maxWidth = math.max(300, sidesGui.AbsoluteSize.X - static.FreeWidth)
											local otherSide = (side == leftSide and rightSide or leftSide)
											local delta = input.Position.X - resizer.AbsolutePosition.X - offX
											delta = (side == leftSide and delta or -delta)

											local proposedSize = math.max(static.MinWidth, side.Width + delta)
											if proposedSize + otherSide.Width <= maxWidth then
												side.Width = proposedSize
											else
												local newOtherSize = maxWidth - proposedSize
												if newOtherSize >= static.MinWidth then
													side.Width = proposedSize
													otherSide.Width = newOtherSize
												else
													side.Width = maxWidth - static.MinWidth
													otherSide.Width = static.MinWidth
												end
											end

											updateSideFrames(true)
											sideResized(side)
											sideResized(otherSide)
										end
									end
								end)
							end
						end
					end)

					resizer.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							if side.Resizing ~= resizer then
								resizer.BackgroundColor3 = theme.Button
							end
						end
					end)

				end

				local function renderSide(side,noTween) 
					local currentPos = 0
					local sideFramePos = getSideFramePos(side)
					local template = side.WindowResizer:Clone()
					for i,v in pairs(side.ResizeCons) do v:Disconnect() end
					for i,v in pairs(side.Frame:GetChildren()) do if v.Name == "WindowResizer" then v:Destroy() end end
					side.ResizeCons = {}
					side.Resizing = nil

					for i,v in pairs(side.Windows) do
						v.SidePos = i
						local isEnd = i == #side.Windows
						local size = UDim2.new(0,side.Width,0,v.SizeY)
						local pos = UDim2.new(sideFramePos.X.Scale,sideFramePos.X.Offset,0,currentPos)
						Lib.ShowGui(v.Gui)
						
						if noTween then
							v.GuiElems.Main.Size = size
							v.GuiElems.Main.Position = pos
						else
							local tween = service.TweenService:Create(v.GuiElems.Main,sideTweenInfo,{Size = size, Position = pos})
							tweens[#tweens+1] = tween
							tween:Play()
						end
						currentPos = currentPos + v.SizeY+4

						if not isEnd then
							local newTemplate = template:Clone()
							newTemplate.Position = UDim2.new(1,-side.Width,0,currentPos-4)
							side.ResizeCons[#side.ResizeCons+1] = v.Gui.Main:GetPropertyChangedSignal("Size"):Connect(function()
								newTemplate.Position = UDim2.new(1,-side.Width,0, v.GuiElems.Main.Position.Y.Offset + v.GuiElems.Main.Size.Y.Offset)
							end)
							side.ResizeCons[#side.ResizeCons+1] = v.Gui.Main:GetPropertyChangedSignal("Position"):Connect(function()
								newTemplate.Position = UDim2.new(1,-side.Width,0, v.GuiElems.Main.Position.Y.Offset + v.GuiElems.Main.Size.Y.Offset)
							end)
							sideResizerHook(newTemplate,"V",side,i)
							newTemplate.Parent = side.Frame
						end
					end

					
					
				end

				local function updateSide(side,noTween)
					local oldHeight = 0
					local currentPos = 0
					local neededSize = 0
					local windows = side.Windows
					local height = sidesGui.AbsoluteSize.Y - (math.max(0,#windows - 1) * 4)

					for i,v in pairs(windows) do oldHeight = oldHeight + v.SizeY end
					for i,v in pairs(windows) do
						if i == #windows then
							v.SizeY = height-currentPos
							neededSize = math.max(0,(v.MinY or 100)-v.SizeY)
						else
							v.SizeY = math.max(math.floor(v.SizeY/oldHeight*height),v.MinY or 100)
						end
						currentPos = currentPos + v.SizeY
					end

					if neededSize > 0 then
						for i = #windows-1,1,-1 do
							local window = windows[i]
							local newSize = math.max(window.SizeY-neededSize,(window.MinY or 100))
							neededSize = neededSize - (window.SizeY - newSize)
							window.SizeY = newSize
						end
						local lastWindow = windows[#windows]
						lastWindow.SizeY = (lastWindow.MinY or 100)-neededSize
					end
					renderSide(side,noTween)
				end

				updateWindows = function(noTween)
					updateSideFrames(noTween)
					updateSide(leftSide,noTween)
					updateSide(rightSide,noTween)
					local count = 0
					for i = #visibleWindows,1,-1 do
						visibleWindows[i].Gui.DisplayOrder = displayOrderStart + count
						Lib.ShowGui(visibleWindows[i].Gui)
						count = count + 1
					end

			



				end

				funcs.SetMinimized = function(self,set,mode)
					local oldVal = self.Minimized
					local newVal
					if set == nil then newVal = not self.Minimized else newVal = set end
					self.Minimized = newVal
					if not mode then mode = 1 end

					local resizeControls = self.GuiElems.ResizeControls
					local minimizeControls = {"North","NorthEast","NorthWest","South","SouthEast","SouthWest"}
					for i = 1,#minimizeControls do
						local control = resizeControls:FindFirstChild(minimizeControls[i])
						if control then control.Visible = not newVal end
					end

					if mode == 1 or mode == 2 then
						self:StopTweens()
						if mode == 1 then
							self.GuiElems.Main:TweenSize(UDim2.new(0,self.SizeX,0,newVal and 20 or self.SizeY),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
						else
							local maxY = sidesGui.AbsoluteSize.Y
							local newPos = UDim2.new(0,self.PosX,0,newVal and math.min(maxY-20,self.PosY + self.SizeY - 20) or math.max(0,self.PosY - self.SizeY + 20))

							self.GuiElems.Main:TweenPosition(newPos,Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
							self.GuiElems.Main:TweenSize(UDim2.new(0,self.SizeX,0,newVal and 20 or self.SizeY),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
						end
						self.GuiElems.Minimize.ImageLabel.Image = newVal and "rbxassetid://5060023708" or "rbxassetid://5034768003"
					end

					if oldVal ~= newVal then
						if newVal then
							self.OnMinimize:Fire()
						else
							self.OnRestore:Fire()
						end
					end
				end

				funcs.Resize = function(self,sizeX,sizeY)
					self.SizeX = sizeX or self.SizeX
					self.SizeY = sizeY or self.SizeY
					self.GuiElems.Main.Size = UDim2.new(0,self.SizeX,0,self.SizeY)
				end

				funcs.SetSize = funcs.Resize

				funcs.SetTitle = function(self,title)
					self.GuiElems.Title.Text = title
				end

				funcs.SetResizable = function(self,val)
					self.Resizable = val
					self.GuiElems.ResizeControls.Visible = self.Resizable and self.ResizableInternal
				end

				funcs.SetResizableInternal = function(self,val)
					self.ResizableInternal = val
					self.GuiElems.ResizeControls.Visible = self.Resizable and self.ResizableInternal
				end

				funcs.SetAligned = function(self,val)
					self.Aligned = val
					self:SetResizableInternal(not val)
					self.GuiElems.Main.Active = not val
					self.GuiElems.Main.Outlines.Visible = not val
					if not val then
						for i,v in pairs(leftSide.Windows) do if v == self then table.remove(leftSide.Windows,i) break end end
						for i,v in pairs(rightSide.Windows) do if v == self then table.remove(rightSide.Windows,i) break end end
						if not table.find(visibleWindows,self) then table.insert(visibleWindows,1,self) end
						self.GuiElems.Minimize.ImageLabel.Image = "rbxassetid://5034768003"
						self.Side = nil
						updateWindows()
					else
						self:SetMinimized(false,3)
						for i,v in pairs(visibleWindows) do if v == self then table.remove(visibleWindows,i) break end end
						self.GuiElems.Minimize.ImageLabel.Image = "rbxassetid://5448127505"
					end
				end

				funcs.Add = function(self,obj,name)
					if type(obj) == "table" and obj.Gui and obj.Gui:IsA("GuiObject") then
						obj.Gui.Parent = self.ContentPane
					else
						obj.Parent = self.ContentPane
					end
					if name then self.Elements[name] = obj end
				end

				funcs.GetElement = function(self,obj,name)
					return self.Elements[name]
				end

				funcs.AlignTo = function(self,side,pos,size,silent)
					if table.find(side.Windows,self) or self.Closed then return end

					size = size or self.SizeY
					if size > 0 and size <= 1 then
						local totalSideHeight = 0
						for i,v in pairs(side.Windows) do totalSideHeight = totalSideHeight + v.SizeY end
						self.SizeY = (totalSideHeight > 0 and totalSideHeight * size * 2) or size
					else
						self.SizeY = (size > 0 and size or 100)
					end

					self:SetAligned(true)
					self.Side = side
					self.SizeX = side.Width
					self.Gui.DisplayOrder = sideDisplayOrder + 1
					for i,v in pairs(side.Windows) do v.Gui.DisplayOrder = sideDisplayOrder end
					pos = math.min(#side.Windows+1, pos or 1)
					self.SidePos = pos
					table.insert(side.Windows, pos, self)

					if not silent then
						side.Hidden = false
					end
					
				end

				funcs.Close = function(self)
					self.Closed = true
					self:SetResizableInternal(false)

					Lib.FindAndRemove(leftSide.Windows,self)
					Lib.FindAndRemove(rightSide.Windows,self)
					Lib.FindAndRemove(visibleWindows,self)

					self.MinimizeAnim.Disable()
					self.CloseAnim.Disable()
					self.ClosedSide = self.Side
					self.Side = nil
					self.OnDeactivate:Fire()

					if not self.Aligned then
						self:StopTweens()
						local ti = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)

						local closeTime = tick()
						self.LastClose = closeTime

						self:DoTween(self.GuiElems.Main,ti,{Size = UDim2.new(0,self.SizeX,0,20)})
						self:DoTween(self.GuiElems.Title,ti,{TextTransparency = 1})
						self:DoTween(self.GuiElems.Minimize.ImageLabel,ti,{ImageTransparency = 1})
						self:DoTween(self.GuiElems.Close.ImageLabel,ti,{ImageTransparency = 1})
						Lib.FastWait(0.2)
						if closeTime ~= self.LastClose then return end

						self:DoTween(self.GuiElems.TopBar,ti,{BackgroundTransparency = 1})
						self:DoTween(self.GuiElems.Outlines,ti,{ImageTransparency = 1})
						Lib.FastWait(0.2)
						if closeTime ~= self.LastClose then return end
					end

					self.Aligned = false
					self.Gui.Parent = nil
					updateWindows(true)
				end

				funcs.Hide = funcs.Close

				funcs.IsVisible = function(self)
					return not self.Closed and ((self.Side and not self.Side.Hidden) or not self.Side)
				end

				funcs.IsContentVisible = function(self)
					return self:IsVisible() and not self.Minimized
				end

				funcs.Focus = function(self)
					moveToTop(self)
				end

				funcs.MoveInBoundary = function(self)
					local posX,posY = self.PosX,self.PosY
					local maxX,maxY = sidesGui.AbsoluteSize.X,sidesGui.AbsoluteSize.Y
					posX = math.min(posX,maxX-self.SizeX)
					posY = math.min(posY,maxY-20)
					self.GuiElems.Main.Position = UDim2.new(0,posX,0,posY)
				end

				funcs.DoTween = function(self,...)
					local tween = service.TweenService:Create(...)
					self.Tweens[#self.Tweens+1] = tween
					tween:Play()
				end

				funcs.StopTweens = function(self)
					for i,v in pairs(self.Tweens) do
						v:Cancel()
					end
					self.Tweens = {}
				end

				funcs.Show = function(self,data)
					return static.ShowWindow(self,data)
				end

				funcs.ShowAndFocus = function(self,data)
					static.ShowWindow(self,data)
					service.RunService.RenderStepped:wait()
					self:Focus()
				end

				static.ShowWindow = function(window,data)
					data = data or {}
					local align = data.Align
					local pos = data.Pos
					local size = data.Size
					local targetSide = (align == "left" and leftSide) or (align == "right" and rightSide)

					if not window.Closed then
						if not window.Aligned then
							window:SetMinimized(false)
						elseif window.Side and not data.Silent then
							static.SetSideVisible(window.Side,true)
						end
						return
					end

					window.Closed = false
					window.LastClose = tick()
					window.GuiElems.Title.TextTransparency = 0
					window.GuiElems.Minimize.ImageLabel.ImageTransparency = 0
					window.GuiElems.Close.ImageLabel.ImageTransparency = 0
					window.GuiElems.TopBar.BackgroundTransparency = 0
					window.GuiElems.Outlines.ImageTransparency = 0
					window.GuiElems.Minimize.ImageLabel.Image = "rbxassetid://5034768003"
					window.GuiElems.Main.Active = true
					window.GuiElems.Main.Outlines.Visible = true
					window:SetMinimized(false,3)
					window:SetResizableInternal(true)
					window.MinimizeAnim.Enable()
					window.CloseAnim.Enable()

					if align then
						window:AlignTo(targetSide,pos,size,data.Silent)
					else
						if align == nil and window.ClosedSide then 
							window:AlignTo(window.ClosedSide,window.SidePos,size,true)
							static.SetSideVisible(window.ClosedSide,true)
						else
							if table.find(visibleWindows,window) then return end

							
							window.GuiElems.Main.Size = UDim2.new(0,window.SizeX,0,20)
							local ti = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
							window:StopTweens()
							window:DoTween(window.GuiElems.Main,ti,{Size = UDim2.new(0,window.SizeX,0,window.SizeY)})

							window.SizeY = size or window.SizeY
							table.insert(visibleWindows,1,window)
							updateWindows()
						end
					end

					window.ClosedSide = nil
					window.OnActivate:Fire()
				end

				static.ToggleSide = function(name)
					local side = (name == "left" and leftSide or rightSide)
					side.Hidden = not side.Hidden
					for i,v in pairs(side.Windows) do
						if side.Hidden then
							v.OnDeactivate:Fire()
						else
							v.OnActivate:Fire()
						end
					end
					updateWindows()
				end

				static.SetSideVisible = function(s,vis)
					local side = (type(s) == "table" and s) or (s == "left" and leftSide or rightSide)
					side.Hidden = not vis
					for i,v in pairs(side.Windows) do
						if side.Hidden then
							v.OnDeactivate:Fire()
						else
							v.OnActivate:Fire()
						end
					end
					updateWindows()
				end

				static.Init = function()
					displayOrderStart = Main.DisplayOrders.Window
					sideDisplayOrder = Main.DisplayOrders.SideWindow

					sidesGui = Instance.new("ScreenGui")
					local leftFrame = create({
						{1,"Frame",{Active=true,Name="LeftSide",BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,}},
						{2,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="Resizer",Parent={1},Size=UDim2.new(0,5,1,0),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{3,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={2},Position=UDim2.new(0,0,0,0),Size=UDim2.new(0,1,1,0),}},
						{4,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="WindowResizer",Parent={1},Position=UDim2.new(1,-300,0,0),Size=UDim2.new(1,0,0,4),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{5,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={4},Size=UDim2.new(1,0,0,1),}},
					})
					leftSide.Frame = leftFrame
					leftFrame.Position = UDim2.new(0,-leftSide.Width-10,0,0)
					leftSide.WindowResizer = leftFrame.WindowResizer
					leftFrame.WindowResizer.Parent = nil
					leftFrame.Parent = sidesGui

					local rightFrame = create({
						{1,"Frame",{Active=true,Name="RightSide",BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,}},
						{2,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="Resizer",Parent={1},Size=UDim2.new(0,5,1,0),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{3,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={2},Position=UDim2.new(0,4,0,0),Size=UDim2.new(0,1,1,0),}},
						{4,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2549019753933,0.2549019753933,0.2549019753933),BorderSizePixel=0,Font=3,Name="WindowResizer",Parent={1},Position=UDim2.new(1,-300,0,0),Size=UDim2.new(1,0,0,4),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
						{5,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={4},Size=UDim2.new(1,0,0,1),}},
					})
					rightSide.Frame = rightFrame
					rightFrame.Position = UDim2.new(1,10,0,0)
					rightSide.WindowResizer = rightFrame.WindowResizer
					rightFrame.WindowResizer.Parent = nil
					rightFrame.Parent = sidesGui

					sideResizerHook(leftFrame.Resizer,"H",leftSide)
					sideResizerHook(rightFrame.Resizer,"H",rightSide)

					alignIndicator = Instance.new("ScreenGui")
					alignIndicator.DisplayOrder = Main.DisplayOrders.Core
					local indicator = Instance.new("Frame",alignIndicator)
					indicator.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
					indicator.BorderSizePixel = 0
					indicator.BackgroundTransparency = 0.8
					indicator.Name = "Indicator"
					local corner = Instance.new("UICorner",indicator)
					corner.CornerRadius = UDim.new(0,10)

					local leftToggle = create({{1,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderMode=2,Font=10,Name="LeftToggle",Position=UDim2.new(0,0,0,-36),Size=UDim2.new(0,16,0,36),Text="<",TextColor3=Color3.new(1,1,1),TextSize=14,}}})
					local rightToggle = leftToggle:Clone()
					rightToggle.Name = "RightToggle"
					rightToggle.Position = UDim2.new(1,-16,0,-36)
					Lib.ButtonAnim(leftToggle,{Mode = 2,PressColor = Color3.fromRGB(32,32,32)})
					Lib.ButtonAnim(rightToggle,{Mode = 2,PressColor = Color3.fromRGB(32,32,32)})

					leftToggle.MouseButton1Click:Connect(function()
						static.ToggleSide("left")
					end)

					rightToggle.MouseButton1Click:Connect(function()
						static.ToggleSide("right")
					end)

					leftToggle.Parent = sidesGui
					rightToggle.Parent = sidesGui

					sidesGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
						local maxWidth = math.max(300,sidesGui.AbsoluteSize.X-static.FreeWidth)
						leftSide.Width = math.max(static.MinWidth,math.min(leftSide.Width,maxWidth-rightSide.Width))
						rightSide.Width = math.max(static.MinWidth,math.min(rightSide.Width,maxWidth-leftSide.Width))
						for i = 1,#visibleWindows do
							visibleWindows[i]:MoveInBoundary()
						end
						updateWindows(true)
					end)

					sidesGui.DisplayOrder = sideDisplayOrder - 1
					Lib.ShowGui(sidesGui)
					updateSideFrames()
				end

				local mt = {__index = funcs}
				static.new = function()
					local obj = setmetatable({
						Minimized = false,
						Dragging = false,
						Resizing = false,
						Aligned = false,
						Draggable = true,
						Resizable = true,
						ResizableInternal = true,
						Alignable = true,
						Closed = true,
						SizeX = 300,
						SizeY = 300,
						MinX = 200,
						MinY = 200,
						PosX = 0,
						PosY = 0,
						GuiElems = {},
						Tweens = {},
						Elements = {},
						OnActivate = Lib.Signal.new(),
						OnDeactivate = Lib.Signal.new(),
						OnMinimize = Lib.Signal.new(),
						OnRestore = Lib.Signal.new()
					},mt)
					obj.Gui = createGui(obj)
					return obj
				end

				return static
			end)()

			Lib.ContextMenu = (function()
				local funcs = {}
				local mouse

				local function createGui(self)
					local contextGui = create({
						{1,"ScreenGui",{DisplayOrder=1000000,Name="Context",ZIndexBehavior=1,}},
						{2,"Frame",{Active=true,BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),Name="Main",Parent={1},Position=UDim2.new(0.5,-100,0.5,-150),Size=UDim2.new(0,200,0,100),}},
						{3,"UICorner",{CornerRadius=UDim.new(0,4),Parent={2},}},
						{4,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),Name="Container",Parent={2},Position=UDim2.new(0,1,0,1),Size=UDim2.new(1,-2,1,-2),}},
						{5,"UICorner",{CornerRadius=UDim.new(0,4),Parent={4},}},
						{6,"ScrollingFrame",{Active=true,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,0),Name="List",Parent={4},Position=UDim2.new(0,2,0,2),ScrollBarImageColor3=Color3.new(0,0,0),ScrollBarThickness=4,Size=UDim2.new(1,-4,1,-4),VerticalScrollBarInset=1,}},
						{7,"UIListLayout",{Parent={6},SortOrder=2,}},
						{8,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="SearchFrame",Parent={4},Size=UDim2.new(1,0,0,24),Visible=false,}},
						{9,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.1176470592618,0.1176470592618,0.1176470592618),BorderSizePixel=0,Name="SearchContainer",Parent={8},Position=UDim2.new(0,3,0,3),Size=UDim2.new(1,-6,0,18),}},
						{10,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="SearchBox",Parent={9},PlaceholderColor3=Color3.new(0.39215689897537,0.39215689897537,0.39215689897537),PlaceholderText="Search",Position=UDim2.new(0,4,0,0),Size=UDim2.new(1,-8,0,18),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,}},
						{11,"UICorner",{CornerRadius=UDim.new(0,2),Parent={9},}},
						{12,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="Line",Parent={8},Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1),}},
						{13,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BackgroundTransparency=1,BorderColor3=Color3.new(0.33725491166115,0.49019610881805,0.73725491762161),BorderSizePixel=0,Font=3,Name="Entry",Parent={1},Size=UDim2.new(1,0,0,22),Text="",TextSize=14,Visible=false,}},
						{14,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="EntryName",Parent={13},Position=UDim2.new(0,24,0,0),Size=UDim2.new(1,-24,1,0),Text="Duplicate",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{15,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Shortcut",Parent={13},Position=UDim2.new(0,24,0,0),Size=UDim2.new(1,-30,1,0),Text="Ctrl+D",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{16,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ImageRectOffset=Vector2.new(304,0),ImageRectSize=Vector2.new(16,16),Name="Icon",Parent={13},Position=UDim2.new(0,2,0,3),ScaleType=4,Size=UDim2.new(0,16,0,16),}},
						{17,"UICorner",{CornerRadius=UDim.new(0,4),Parent={13},}},
						{18,"Frame",{BackgroundColor3=Color3.new(0.21568629145622,0.21568629145622,0.21568629145622),BackgroundTransparency=1,BorderSizePixel=0,Name="Divider",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,7),Visible=false,}},
						{19,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="Line",Parent={18},Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0,1),}},
						{20,"TextLabel",{AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="DividerName",Parent={18},Position=UDim2.new(0,2,0.5,0),Size=UDim2.new(1,-4,1,0),Text="Objects",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.60000002384186,TextXAlignment=0,Visible=false,}}
					})

					self.GuiElems.Main = contextGui.Main
					self.GuiElems.List = contextGui.Main.Container.List
					self.GuiElems.Entry = contextGui.Entry
					self.GuiElems.Divider = contextGui.Divider
					self.GuiElems.SearchFrame = contextGui.Main.Container.SearchFrame
					self.GuiElems.SearchBar = self.GuiElems.SearchFrame.SearchContainer.SearchBox
					Lib.ViewportTextBox.convert(self.GuiElems.SearchBar)

					self.GuiElems.SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
						local lower,find = string.lower,string.find
						local searchText = lower(self.GuiElems.SearchBar.Text)
						local items = self.Items
						local map = self.ItemToEntryMap

						if searchText ~= "" then
							local results = {}
							local count = 1
							for i = 1,#items do
								local item = items[i]
								local entry = map[item]
								if entry then
									if not item.Divider and find(lower(item.Name),searchText,1,true) then
										results[count] = item
										count = count + 1
									else
										entry.Visible = false
									end
								end
							end
							table.sort(results,function(a,b) return a.Name < b.Name end)
							for i = 1,#results do
								local entry = map[results[i]]
								entry.LayoutOrder = i
								entry.Visible = true
							end
						else
							for i = 1,#items do
								local entry = map[items[i]]
								if entry then entry.LayoutOrder = i entry.Visible = true end
							end
						end

						local toSize = self.GuiElems.List.UIListLayout.AbsoluteContentSize.Y + 6
						self.GuiElems.List.CanvasSize = UDim2.new(0,0,0,toSize-6)
					end)

					return contextGui
				end

				funcs.Add = function(self,item)
					local newItem = {
						Name = item.Name or "Item",
						Icon = item.Icon or "",
						Shortcut = item.Shortcut or "",
						OnClick = item.OnClick,
						OnHover = item.OnHover,
						Disabled = item.Disabled or false,
						DisabledIcon = item.DisabledIcon or "",
						IconMap = item.IconMap,
						OnRightClick = item.OnRightClick
					}

					if self.QueuedDivider then
						local text = self.QueuedDividerText and #self.QueuedDividerText > 0 and self.QueuedDividerText
						self:AddDivider(text)
					end
					self.Items[#self.Items+1] = newItem
					self.Updated = nil
				end

				funcs.AddRegistered = function(self,name,disabled)
					if not self.Registered[name] then error(name.." is not registered") end

					if self.QueuedDivider then
						local text = self.QueuedDividerText and #self.QueuedDividerText > 0 and self.QueuedDividerText
						self:AddDivider(text)
					end
					self.Registered[name].Disabled = disabled
					self.Items[#self.Items+1] = self.Registered[name]
					self.Updated = nil
				end

				funcs.Register = function(self,name,item)
					self.Registered[name] = {
						Name = item.Name or "Item",
						Icon = item.Icon or "",
						Shortcut = item.Shortcut or "",
						OnClick = item.OnClick,
						OnHover = item.OnHover,
						DisabledIcon = item.DisabledIcon or "",
						IconMap = item.IconMap,
						OnRightClick = item.OnRightClick
					}
				end

				funcs.UnRegister = function(self,name)
					self.Registered[name] = nil
				end

				funcs.AddDivider = function(self,text)
					self.QueuedDivider = false
					local textWidth = text and service.TextService:GetTextSize(text,14,Enum.Font.SourceSans,Vector2.new(999999999,20)).X or nil
					table.insert(self.Items,{Divider = true, Text = text, TextSize = textWidth and textWidth+4})
					self.Updated = nil
				end

				funcs.QueueDivider = function(self,text)
					self.QueuedDivider = true
					self.QueuedDividerText = text or ""
				end

				funcs.Clear = function(self)
					self.Items = {}
					self.Updated = nil
				end

				funcs.Refresh = function(self)
					for i,v in pairs(self.GuiElems.List:GetChildren()) do
						if not v:IsA("UIListLayout") then
							v:Destroy()
						end
					end
					local map = {}
					self.ItemToEntryMap = map

					local dividerFrame = self.GuiElems.Divider
					local contextList = self.GuiElems.List
					local entryFrame = self.GuiElems.Entry
					local items = self.Items

					for i = 1,#items do
						local item = items[i]
						if item.Divider then
							local newDivider = dividerFrame:Clone()
							newDivider.Line.BackgroundColor3 = self.Theme.DividerColor
							if item.Text then
								newDivider.Size = UDim2.new(1,0,0,20)
								newDivider.Line.Position = UDim2.new(0,item.TextSize,0.5,0)
								newDivider.Line.Size = UDim2.new(1,-item.TextSize,0,1)
								newDivider.DividerName.TextColor3 = self.Theme.TextColor
								newDivider.DividerName.Text = item.Text
								newDivider.DividerName.Visible = true
							end
							newDivider.Visible = true
							map[item] = newDivider
							newDivider.Parent = contextList
						else
							local newEntry = entryFrame:Clone()
							newEntry.BackgroundColor3 = self.Theme.HighlightColor
							newEntry.EntryName.TextColor3 = self.Theme.TextColor
							newEntry.EntryName.Text = item.Name
							newEntry.Shortcut.Text = item.Shortcut
							if item.Disabled then
								newEntry.EntryName.TextColor3 = Color3.new(150/255,150/255,150/255)
								newEntry.Shortcut.TextColor3 = Color3.new(150/255,150/255,150/255)
							end

							if self.Iconless then
								newEntry.EntryName.Position = UDim2.new(0,2,0,0)
								newEntry.EntryName.Size = UDim2.new(1,-4,0,20)
								newEntry.Icon.Visible = false
							else
								local iconIndex = item.Disabled and item.DisabledIcon or item.Icon
								
								if item.IconMap then
									if type(iconIndex) == "number" then
										item.IconMap:Display(newEntry.Icon, iconIndex)
									elseif type(iconIndex) == "string" then
										item.IconMap:DisplayByKey(newEntry.Icon, iconIndex)
									end
								elseif type(iconIndex) == "string" then
									newEntry.Icon.Image = iconIndex
								end
							end

							if not item.Disabled then
								if item.OnClick then
									newEntry.MouseButton1Click:Connect(function()
										item.OnClick(item.Name)
										if not item.NoHide then
											self:Hide()
										end
									end)
								end

								if item.OnRightClick then
									newEntry.MouseButton2Click:Connect(function()
										item.OnRightClick(item.Name)
										if not item.NoHide then
											self:Hide()
										end
									end)
								end
							end

							newEntry.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
									newEntry.BackgroundTransparency = 0
								end
							end)

							newEntry.InputEnded:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
									newEntry.BackgroundTransparency = 1
								end
							end)

							newEntry.Visible = true
							map[item] = newEntry
							newEntry.Parent = contextList
						end
					end
					self.Updated = true
				end

				funcs.Show = function(self,x,y)
					local elems = self.GuiElems
					elems.SearchFrame.Visible = self.SearchEnabled
					elems.List.Position = UDim2.new(0,2,0,2 + (self.SearchEnabled and 24 or 0))
					elems.List.Size = UDim2.new(1,-4,1,-4 - (self.SearchEnabled and 24 or 0))
					if self.SearchEnabled and self.ClearSearchOnShow then elems.SearchBar.Text = "" end
					self.GuiElems.List.CanvasPosition = Vector2.new(0,0)

					if not self.Updated then
						self:Refresh()
					end

					
					local reverseY = false
					local x,y = x or mouse.X, y or mouse.Y
					local maxX,maxY = mouse.ViewSizeX,mouse.ViewSizeY

					
					if x + self.Width > maxX then
						x = self.ReverseX and x - self.Width or maxX - self.Width
					end
					elems.Main.Position = UDim2.new(0,x,0,y)
					elems.Main.Size = UDim2.new(0,self.Width,0,0)
					self.Gui.DisplayOrder = Main.DisplayOrders.Menu
					Lib.ShowGui(self.Gui)

					
					local toSize = elems.List.UIListLayout.AbsoluteContentSize.Y + 6 
					if self.MaxHeight and toSize > self.MaxHeight then
						elems.List.CanvasSize = UDim2.new(0,0,0,toSize-6)
						toSize = self.MaxHeight
					else
						elems.List.CanvasSize = UDim2.new(0,0,0,0)
					end
					if y + toSize > maxY then reverseY = true end

					
					local closable
					if self.CloseEvent then self.CloseEvent:Disconnect() end
					self.CloseEvent = service.UserInputService.InputBegan:Connect(function(input)
						if not closable then return end

						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							if not Lib.CheckMouseInGui(elems.Main) then
								self.CloseEvent:Disconnect()
								self:Hide()
							end
						end
					end)

					
					if reverseY then
						elems.Main.Position = UDim2.new(0,x,0,y-(self.ReverseYOffset or 0))
						local newY = y - toSize - (self.ReverseYOffset or 0)
						y = newY >= 0 and newY or 0
						elems.Main:TweenSizeAndPosition(UDim2.new(0,self.Width,0,toSize),UDim2.new(0,x,0,y),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.2,true)
					else
						elems.Main:TweenSize(UDim2.new(0,self.Width,0,toSize),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.2,true)
					end

					
					Lib.FastWait()
					if self.SearchEnabled and self.FocusSearchOnShow then elems.SearchBar:CaptureFocus() end
					closable = true
				end

				funcs.Hide = function(self)
					self.Gui.Parent = nil
				end

				funcs.ApplyTheme = function(self,data)
					local theme = self.Theme
					theme.ContentColor = data.ContentColor or Settings.Theme.Menu
					theme.OutlineColor = data.OutlineColor or Settings.Theme.Menu
					theme.DividerColor = data.DividerColor or Settings.Theme.Outline2
					theme.TextColor = data.TextColor or Settings.Theme.Text
					theme.HighlightColor = data.HighlightColor or Settings.Theme.Main1

					self.GuiElems.Main.BackgroundColor3 = theme.OutlineColor
					self.GuiElems.Main.Container.BackgroundColor3 = theme.ContentColor
				end

				local mt = {__index = funcs}
				local function new()
					if not mouse then mouse = Main.Mouse or service.Players.LocalPlayer:GetMouse() end

					local obj = setmetatable({
						Width = 200,
						MaxHeight = nil,
						Iconless = false,
						SearchEnabled = false,
						ClearSearchOnShow = true,
						FocusSearchOnShow = true,
						Updated = false,
						QueuedDivider = false,
						QueuedDividerText = "",
						Items = {},
						Registered = {},
						GuiElems = {},
						Theme = {}
					},mt)
					obj.Gui = createGui(obj)
					obj:ApplyTheme({})
					return obj
				end

				return {new = new}
			end)()

			Lib.CodeFrame = (function()
				local funcs = {}

				local typeMap = {
					[1] = "String",
					[2] = "String",
					[3] = "String",
					[4] = "Comment",
					[5] = "Operator",
					[6] = "Number",
					[7] = "Keyword",
					[8] = "BuiltIn",
					[9] = "LocalMethod",
					[10] = "LocalProperty",
					[11] = "Nil",
					[12] = "Bool",
					[13] = "Function",
					[14] = "Local",
					[15] = "Self",
					[16] = "FunctionName",
					[17] = "Bracket"
				}

				local specialKeywordsTypes = {
					["nil"] = 11,
					["true"] = 12,
					["false"] = 12,
					["function"] = 13,
					["local"] = 14,
					["self"] = 15
				}

				local keywords = {
					["and"] = true,
					["break"] = true, 
					["do"] = true,
					["else"] = true,
					["elseif"] = true,
					["end"] = true,
					["false"] = true,
					["for"] = true,
					["function"] = true,
					["if"] = true,
					["in"] = true,
					["local"] = true,
					["nil"] = true,
					["not"] = true,
					["or"] = true,
					["repeat"] = true,
					["return"] = true,
					["then"] = true,
					["true"] = true,
					["until"] = true,
					["while"] = true,
					["plugin"] = true
				}

				local builtIns = {
					["delay"] = true,
					["elapsedTime"] = true,
					["require"] = true,
					["spawn"] = true,
					["tick"] = true,
					["time"] = true,
					["typeof"] = true,
					["UserSettings"] = true,
					["wait"] = true,
					["warn"] = true,
					["game"] = true,
					["shared"] = true,
					["script"] = true,
					["workspace"] = true,
					["assert"] = true,
					["collectgarbage"] = true,
					["error"] = true,
					["getfenv"] = true,
					["getmetatable"] = true,
					["ipairs"] = true,
					["loadstring"] = true,
					["newproxy"] = true,
					["next"] = true,
					["pairs"] = true,
					["pcall"] = true,
					["print"] = true,
					["rawequal"] = true,
					["rawget"] = true,
					["rawset"] = true,
					["select"] = true,
					["setfenv"] = true,
					["setmetatable"] = true,
					["tonumber"] = true,
					["tostring"] = true,
					["type"] = true,
					["unpack"] = true,
					["xpcall"] = true,
					["_G"] = true,
					["_VERSION"] = true,
					["coroutine"] = true,
					["debug"] = true,
					["math"] = true,
					["os"] = true,
					["string"] = true,
					["table"] = true,
					["bit32"] = true,
					["utf8"] = true,
					["Axes"] = true,
					["BrickColor"] = true,
					["CFrame"] = true,
					["Color3"] = true,
					["ColorSequence"] = true,
					["ColorSequenceKeypoint"] = true,
					["DockWidgetPluginGuiInfo"] = true,
					["Enum"] = true,
					["Faces"] = true,
					["Instance"] = true,
					["NumberRange"] = true,
					["NumberSequence"] = true,
					["NumberSequenceKeypoint"] = true,
					["PathWaypoint"] = true,
					["PhysicalProperties"] = true,
					["Random"] = true,
					["Ray"] = true,
					["Rect"] = true,
					["Region3"] = true,
					["Region3int16"] = true,
					["TweenInfo"] = true,
					["UDim"] = true,
					["UDim2"] = true,
					["Vector2"] = true,
					["Vector2int16"] = true,
					["Vector3"] = true,
					["Vector3int16"] = true
				}

				local builtInInited = false

				local richReplace = {
					["'"] = "&apos;",
					["\""] = "&quot;",
					["<"] = "&lt;",
					[">"] = "&gt;",
					["&"] = "&amp;"
				}

				local tabSub = "\t"
				local tabReplacement = (" %s "):format(tabSub)

				local tabJumps = {
					[("[^%s] "):format(tabSub)] = 0,
					[(" %s"):format(tabSub)] = -1,
					[("%s "):format(tabSub)] = 2,
					[(" [^%s]"):format(tabSub)] = 1,
				}

				local tweenService = service.TweenService
				local lineTweens = {}

				local function initBuiltIn()
					local env = getfenv()
					local type = type
					local tostring = tostring
					for name,_ in next,builtIns do
						local envVal = env[name]
						if type(envVal) == "table" then
							local items = {}
							for i,v in next,envVal do
								items[i] = true
							end
							builtIns[name] = items
						end
					end

					local enumEntries = {}
					local enums = Enum:GetEnums()
					for i = 1,#enums do
						enumEntries[tostring(enums[i])] = true
					end
					builtIns["Enum"] = enumEntries

					builtInInited = true
				end

				local function setupEditBox(obj)
					local editBox = obj.GuiElems.EditBox

					editBox.Focused:Connect(function()
						obj:ConnectEditBoxEvent()
						obj.Editing = true
					end)

					editBox.FocusLost:Connect(function()
						obj:DisconnectEditBoxEvent()
						obj.Editing = false
					end)

					editBox:GetPropertyChangedSignal("Text"):Connect(function()
						local text = editBox.Text
						if #text == 0 or obj.EditBoxCopying then return end
						editBox.Text = ""
						obj:AppendText(text)
					end)
				end

				local function setupMouseSelection(obj)
					local mouse = plr:GetMouse()
					local codeFrame = obj.GuiElems.LinesFrame
					local lines = obj.Lines

					codeFrame.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							local fontSizeX, fontSizeY = math.ceil(obj.FontSize / 2), obj.FontSize
							local relX = input.Position.X - codeFrame.AbsolutePosition.X
							local relY = input.Position.Y - codeFrame.AbsolutePosition.Y
							local selX = math.round(relX / fontSizeX) + obj.ViewX
							local selY = math.floor(relY / fontSizeY) + obj.ViewY
							local releaseEvent, inputEvent, scrollEvent
							local scrollPowerV, scrollPowerH = 0, 0
							selY = math.min(#lines - 1, selY)
							local relativeLine = lines[selY + 1] or ""
							selX = math.min(#relativeLine, selX + obj:TabAdjust(selX, selY))

							obj.SelectionRange = {{-1, -1}, {-1, -1}}
							obj:MoveCursor(selX, selY)
							obj.FloatCursorX = selX

							local function updateSelection()
								local relX = input.Position.X - codeFrame.AbsolutePosition.X
								local relY = input.Position.Y - codeFrame.AbsolutePosition.Y
								local sel2X = math.max(0, math.round(relX / fontSizeX) + obj.ViewX)
								local sel2Y = math.max(0, math.floor(relY / fontSizeY) + obj.ViewY)

								sel2Y = math.min(#lines - 1, sel2Y)
								local relativeLine = lines[sel2Y + 1] or ""
								sel2X = math.min(#relativeLine, sel2X + obj:TabAdjust(sel2X, sel2Y))

								if sel2Y < selY or (sel2Y == selY and sel2X < selX) then
									obj.SelectionRange = {{sel2X, sel2Y}, {selX, selY}}
								else						
									obj.SelectionRange = {{selX, selY}, {sel2X, sel2Y}}
								end

								obj:MoveCursor(sel2X, sel2Y)
								obj.FloatCursorX = sel2X
								obj:Refresh()
							end

							releaseEvent = service.UserInputService.InputEnded:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
									releaseEvent:Disconnect()
									inputEvent:Disconnect()
									scrollEvent:Disconnect()
									obj:SetCopyableSelection()
								end
							end)

							inputEvent = service.UserInputService.InputChanged:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
									local upDelta = input.Position.Y - codeFrame.AbsolutePosition.Y
									local downDelta = input.Position.Y - codeFrame.AbsolutePosition.Y - codeFrame.AbsoluteSize.Y
									local leftDelta = input.Position.X - codeFrame.AbsolutePosition.X
									local rightDelta = input.Position.X - codeFrame.AbsolutePosition.X - codeFrame.AbsoluteSize.X

									scrollPowerV = 0
									scrollPowerH = 0
									if downDelta > 0 then
										scrollPowerV = math.floor(downDelta * 0.05) + 1
									elseif upDelta < 0 then
										scrollPowerV = math.ceil(upDelta * 0.05) - 1
									end
									if rightDelta > 0 then
										scrollPowerH = math.floor(rightDelta * 0.05) + 1
									elseif leftDelta < 0 then
										scrollPowerH = math.ceil(leftDelta * 0.05) - 1
									end
									updateSelection()
								end
							end)

							scrollEvent = service.RunService.RenderStepped:Connect(function()
								if scrollPowerV ~= 0 or scrollPowerH ~= 0 then
									obj:ScrollDelta(scrollPowerH, scrollPowerV)
									updateSelection()
								end
							end)

							obj:Refresh()
						end
					end)

				end

				local function makeFrame(obj)
					local frame = create({
						{1,"Frame",{BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel = 0,Position=UDim2.new(0.5,-300,0.5,-200),Size=UDim2.new(0,600,0,400),}},
					})
					local elems = {}

					local linesFrame = Instance.new("Frame")
					linesFrame.Name = "Lines"
					linesFrame.BackgroundTransparency = 1
					linesFrame.Size = UDim2.new(1,0,1,0)
					linesFrame.ClipsDescendants = true
					linesFrame.Parent = frame

					local lineNumbersLabel = Instance.new("TextLabel")
					lineNumbersLabel.Name = "LineNumbers"
					lineNumbersLabel.BackgroundTransparency = 1
					lineNumbersLabel.Font = Enum.Font.Code
					lineNumbersLabel.TextXAlignment = Enum.TextXAlignment.Right
					lineNumbersLabel.TextYAlignment = Enum.TextYAlignment.Top
					lineNumbersLabel.ClipsDescendants = true
					lineNumbersLabel.RichText = true
					lineNumbersLabel.Parent = frame

					local cursor = Instance.new("Frame")
					cursor.Name = "Cursor"
					cursor.BackgroundColor3 = Color3.fromRGB(220,220,220)
					cursor.BorderSizePixel = 0
					cursor.Parent = frame

					local editBox = Instance.new("TextBox")
					editBox.Name = "EditBox"
					editBox.MultiLine = true
					editBox.Visible = false
					editBox.Parent = frame

					lineTweens.Invis = tweenService:Create(cursor,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundTransparency = 1})
					lineTweens.Vis = tweenService:Create(cursor,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{BackgroundTransparency = 0})

					elems.LinesFrame = linesFrame
					elems.LineNumbersLabel = lineNumbersLabel
					elems.Cursor = cursor
					elems.EditBox = editBox
					elems.ScrollCorner = create({{1,"Frame",{BackgroundColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="ScrollCorner",Position=UDim2.new(1,-16,1,-16),Size=UDim2.new(0,16,0,16),Visible=false,}}})

					elems.ScrollCorner.Parent = frame
					linesFrame.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							obj:SetEditing(true, input)
						end
					end)


					obj.Frame = frame
					obj.Gui = frame
					obj.GuiElems = elems
					setupEditBox(obj)
					setupMouseSelection(obj)

					return frame
				end

				funcs.GetSelectionText = function(self)
					if not self:IsValidRange() then return "" end

					local selectionRange = self.SelectionRange
					local selX,selY = selectionRange[1][1], selectionRange[1][2]
					local sel2X,sel2Y = selectionRange[2][1], selectionRange[2][2]
					local deltaLines = sel2Y-selY
					local lines = self.Lines

					if not lines[selY+1] or not lines[sel2Y+1] then return "" end

					if deltaLines == 0 then
						return self:ConvertText(lines[selY+1]:sub(selX+1,sel2X), false)
					end

					local leftSub = lines[selY+1]:sub(selX+1)
					local rightSub = lines[sel2Y+1]:sub(1,sel2X)

					local result = leftSub.."\n" 
					for i = selY+1,sel2Y-1 do
						result = result..lines[i+1].."\n"
					end
					result = result..rightSub

					return self:ConvertText(result,false)
				end

				funcs.SetCopyableSelection = function(self)
					local text = self:GetSelectionText()
					local editBox = self.GuiElems.EditBox

					self.EditBoxCopying = true
					editBox.Text = text
					editBox.SelectionStart = 1
					editBox.CursorPosition = #editBox.Text + 1
					self.EditBoxCopying = false
				end

				funcs.ConnectEditBoxEvent = function(self)
					if self.EditBoxEvent then
						self.EditBoxEvent:Disconnect()
					end

					self.EditBoxEvent = service.UserInputService.InputBegan:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

						local keycodes = Enum.KeyCode
						local keycode = input.KeyCode

						local function setupMove(key,func)
							local endCon,finished
							endCon = service.UserInputService.InputEnded:Connect(function(input)
								if input.KeyCode ~= key then return end
								endCon:Disconnect()
								finished = true
							end)
							func()
							Lib.FastWait(0.5)
							while not finished do func() Lib.FastWait(0.03) end
						end

						if keycode == keycodes.Down then
							setupMove(keycodes.Down,function()
								self.CursorX = self.FloatCursorX
								self.CursorY = self.CursorY + 1
								self:UpdateCursor()
								self:JumpToCursor()
							end)
						elseif keycode == keycodes.Up then
							setupMove(keycodes.Up,function()
								self.CursorX = self.FloatCursorX
								self.CursorY = self.CursorY - 1
								self:UpdateCursor()
								self:JumpToCursor()
							end)
						elseif keycode == keycodes.Left then
							setupMove(keycodes.Left,function()
								local line = self.Lines[self.CursorY+1] or ""
								self.CursorX = self.CursorX - 1 - (line:sub(self.CursorX-3,self.CursorX) == tabReplacement and 3 or 0)
								if self.CursorX < 0 then
									self.CursorY = self.CursorY - 1
									local line2 = self.Lines[self.CursorY+1] or ""
									self.CursorX = #line2
								end
								self.FloatCursorX = self.CursorX
								self:UpdateCursor()
								self:JumpToCursor()
							end)
						elseif keycode == keycodes.Right then
							setupMove(keycodes.Right,function()
								local line = self.Lines[self.CursorY+1] or ""
								self.CursorX = self.CursorX + 1 + (line:sub(self.CursorX+1,self.CursorX+4) == tabReplacement and 3 or 0)
								if self.CursorX > #line then
									self.CursorY = self.CursorY + 1
									self.CursorX = 0
								end
								self.FloatCursorX = self.CursorX
								self:UpdateCursor()
								self:JumpToCursor()
							end)
						elseif keycode == keycodes.Backspace then
							setupMove(keycodes.Backspace,function()
								local startRange,endRange
								if self:IsValidRange() then
									startRange = self.SelectionRange[1]
									endRange = self.SelectionRange[2]
								else
									endRange = {self.CursorX,self.CursorY}
								end

								if not startRange then
									local line = self.Lines[self.CursorY+1] or ""
									self.CursorX = self.CursorX - 1 - (line:sub(self.CursorX-3,self.CursorX) == tabReplacement and 3 or 0)
									if self.CursorX < 0 then
										self.CursorY = self.CursorY - 1
										local line2 = self.Lines[self.CursorY+1] or ""
										self.CursorX = #line2
									end
									self.FloatCursorX = self.CursorX
									self:UpdateCursor()

									startRange = startRange or {self.CursorX,self.CursorY}
								end

								self:DeleteRange({startRange,endRange},false,true)
								self:ResetSelection(true)
								self:JumpToCursor()
							end)
						elseif keycode == keycodes.Delete then
							setupMove(keycodes.Delete,function()
								local startRange,endRange
								if self:IsValidRange() then
									startRange = self.SelectionRange[1]
									endRange = self.SelectionRange[2]
								else
									startRange = {self.CursorX,self.CursorY}
								end

								if not endRange then
									local line = self.Lines[self.CursorY+1] or ""
									local endCursorX = self.CursorX + 1 + (line:sub(self.CursorX+1,self.CursorX+4) == tabReplacement and 3 or 0)
									local endCursorY = self.CursorY
									if endCursorX > #line then
										endCursorY = endCursorY + 1
										endCursorX = 0
									end
									self:UpdateCursor()

									endRange = endRange or {endCursorX,endCursorY}
								end

								self:DeleteRange({startRange,endRange},false,true)
								self:ResetSelection(true)
								self:JumpToCursor()
							end)
						elseif service.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
							if keycode == keycodes.A then
								self.SelectionRange = {{0,0},{#self.Lines[#self.Lines],#self.Lines-1}}
								self:SetCopyableSelection()
								self:Refresh()
							end
						end
					end)
				end

				funcs.DisconnectEditBoxEvent = function(self)
					if self.EditBoxEvent then
						self.EditBoxEvent:Disconnect()
					end
				end

				funcs.ResetSelection = function(self,norefresh)
					self.SelectionRange = {{-1,-1},{-1,-1}}
					if not norefresh then self:Refresh() end
				end

				funcs.IsValidRange = function(self,range)
					local selectionRange = range or self.SelectionRange
					local selX,selY = selectionRange[1][1], selectionRange[1][2]
					local sel2X,sel2Y = selectionRange[2][1], selectionRange[2][2]

					if selX == -1 or (selX == sel2X and selY == sel2Y) then return false end

					return true
				end

				funcs.DeleteRange = function(self,range,noprocess,updatemouse)
					range = range or self.SelectionRange
					if not self:IsValidRange(range) then return end

					local lines = self.Lines
					local selX,selY = range[1][1], range[1][2]
					local sel2X,sel2Y = range[2][1], range[2][2]
					local deltaLines = sel2Y-selY

					if not lines[selY+1] or not lines[sel2Y+1] then return end

					local leftSub = lines[selY+1]:sub(1,selX)
					local rightSub = lines[sel2Y+1]:sub(sel2X+1)
					lines[selY+1] = leftSub..rightSub

					local remove = table.remove
					for i = 1,deltaLines do
						remove(lines,selY+2)
					end

					if range == self.SelectionRange then self.SelectionRange = {{-1,-1},{-1,-1}} end
					if updatemouse then
						self.CursorX = selX
						self.CursorY = selY
						self:UpdateCursor()
					end

					if not noprocess then
						self:ProcessTextChange()
					end
				end

				funcs.AppendText = function(self,text)
					self:DeleteRange(nil,true,true)
					local lines,cursorX,cursorY = self.Lines,self.CursorX,self.CursorY
					local line = lines[cursorY+1]
					local before = line:sub(1,cursorX)
					local after = line:sub(cursorX+1)

					text = text:gsub("\r\n","\n")
					text = self:ConvertText(text,true) 

					local textLines = text:split("\n")
					local insert = table.insert

					for i = 1,#textLines do
						local linePos = cursorY+i
						if i > 1 then insert(lines,linePos,"") end

						local textLine = textLines[i]
						local newBefore = (i == 1 and before or "")
						local newAfter = (i == #textLines and after or "")

						lines[linePos] = newBefore..textLine..newAfter
					end

					if #textLines > 1 then cursorX = 0 end

					self:ProcessTextChange()
					self.CursorX = cursorX + #textLines[#textLines]
					self.CursorY = cursorY + #textLines-1
					self:UpdateCursor()
				end

				funcs.ScrollDelta = function(self,x,y)
					self.ScrollV:ScrollTo(self.ScrollV.Index + y)
					self.ScrollH:ScrollTo(self.ScrollH.Index + x)
				end

				
				funcs.TabAdjust = function(self,x,y)
					local lines = self.Lines
					local line = lines[y+1]
					x=x+1

					if line then
						local left = line:sub(x-1,x-1)
						local middle = line:sub(x,x)
						local right = line:sub(x+1,x+1)
						local selRange = (#left > 0 and left or " ") .. (#middle > 0 and middle or " ") .. (#right > 0 and right or " ")

						for i,v in pairs(tabJumps) do
							if selRange:find(i) then
								return v
							end
						end
					end
					return 0
				end

				funcs.SetEditing = function(self,on,input)			
					self:UpdateCursor(input)

					if on then
						if self.Editable then
							self.GuiElems.EditBox.Text = ""
							self.GuiElems.EditBox:CaptureFocus()
						end
					else
						self.GuiElems.EditBox:ReleaseFocus()
					end
				end

				funcs.CursorAnim = function(self,on)
					local cursor = self.GuiElems.Cursor
					local animTime = tick()
					self.LastAnimTime = animTime

					if not on then return end

					lineTweens.Invis:Cancel()
					lineTweens.Vis:Cancel()
					cursor.BackgroundTransparency = 0

					coroutine.wrap(function()
						while self.Editable do
							Lib.FastWait(0.5)
							if self.LastAnimTime ~= animTime then return end
							lineTweens.Invis:Play()
							Lib.FastWait(0.4)
							if self.LastAnimTime ~= animTime then return end
							lineTweens.Vis:Play()
							Lib.FastWait(0.2)
						end
					end)()
				end

				funcs.MoveCursor = function(self,x,y)
					self.CursorX = x
					self.CursorY = y
					self:UpdateCursor()
					self:JumpToCursor()
				end

				funcs.JumpToCursor = function(self)
					self:Refresh()
				end

				funcs.UpdateCursor = function(self,input)
					local linesFrame = self.GuiElems.LinesFrame
					local cursor = self.GuiElems.Cursor			
					local hSize = math.max(0,linesFrame.AbsoluteSize.X)
					local vSize = math.max(0,linesFrame.AbsoluteSize.Y)
					local maxLines = math.ceil(vSize / self.FontSize)
					local maxCols = math.ceil(hSize / math.ceil(self.FontSize/2))
					local viewX,viewY = self.ViewX,self.ViewY
					local totalLinesStr = tostring(#self.Lines)
					local fontWidth = math.ceil(self.FontSize / 2)
					local linesOffset = #totalLinesStr*fontWidth + 4*fontWidth

					if input then
						local linesFrame = self.GuiElems.LinesFrame
						local frameX,frameY = linesFrame.AbsolutePosition.X,linesFrame.AbsolutePosition.Y
						local mouseX,mouseY = input.Position.X,input.Position.Y
						local fontSizeX,fontSizeY = math.ceil(self.FontSize/2),self.FontSize

						self.CursorX = self.ViewX + math.round((mouseX - frameX) / fontSizeX)
						self.CursorY = self.ViewY + math.floor((mouseY - frameY) / fontSizeY)
					end

					local cursorX,cursorY = self.CursorX,self.CursorY

					local line = self.Lines[cursorY+1] or ""
					if cursorX > #line then cursorX = #line
					elseif cursorX < 0 then cursorX = 0 end

					if cursorY >= #self.Lines then
						cursorY = math.max(0,#self.Lines-1)
					elseif cursorY < 0 then
						cursorY = 0
					end

					cursorX = cursorX + self:TabAdjust(cursorX,cursorY)

					
					self.CursorX = cursorX
					self.CursorY = cursorY

					local cursorVisible = (cursorX >= viewX) and (cursorY >= viewY) and (cursorX <= viewX + maxCols) and (cursorY <= viewY + maxLines)
					if cursorVisible then
						local offX = (cursorX - viewX)
						local offY = (cursorY - viewY)
						cursor.Position = UDim2.new(0,linesOffset + offX*math.ceil(self.FontSize/2) - 1,0,offY*self.FontSize)
						cursor.Size = UDim2.new(0,1,0,self.FontSize+2)
						cursor.Visible = true
						self:CursorAnim(true)
					else
						cursor.Visible = false
					end
				end

				funcs.MapNewLines = function(self)
					local newLines = {}
					local count = 1
					local text = self.Text
					local find = string.find
					local init = 1

					local pos = find(text,"\n",init,true)
					while pos do
						newLines[count] = pos
						count = count + 1
						init = pos + 1
						pos = find(text,"\n",init,true)
					end

					self.NewLines = newLines
				end

				funcs.PreHighlight = function(self)
					local start = tick()
					local text = self.Text:gsub("\\\\","	")
					
					local textLen = #text
					local found = {}
					local foundMap = {}
					local extras = {}
					local find = string.find
					local sub = string.sub
					self.ColoredLines = {}

					local function findAll(str,pattern,typ,raw)
						local count = #found+1
						local init = 1
						local x,y,extra = find(str,pattern,init,raw)
						while x do
							found[count] = x
							foundMap[x] = typ
							if extra then
								extras[x] = extra
							end

							count = count+1
							init = y+1
							x,y,extra = find(str,pattern,init,raw)
						end
					end
					local start = tick()
					findAll(text,'"',1,true)
					findAll(text,"'",2,true)
					findAll(text,"%[(=*)%[",3)
					findAll(text,"--",4,true)
					table.sort(found)

					local newLines = self.NewLines
					local curLine = 0
					local lineTableCount = 1
					local lineStart = 0
					local lineEnd = 0
					local lastEnding = 0
					local foundHighlights = {}

					for i = 1,#found do
						local pos = found[i]
						if pos <= lastEnding then continue end

						local ending = pos
						local typ = foundMap[pos]
						if typ == 1 then
							ending = find(text,'"',pos+1,true)
							while ending and sub(text,ending-1,ending-1) == "\\" do
								ending = find(text,'"',ending+1,true)
							end
							if not ending then ending = textLen end
						elseif typ == 2 then
							ending = find(text,"'",pos+1,true)
							while ending and sub(text,ending-1,ending-1) == "\\" do
								ending = find(text,"'",ending+1,true)
							end
							if not ending then ending = textLen end
						elseif typ == 3 then
							_,ending = find(text,"]"..extras[pos].."]",pos+1,true)
							if not ending then ending = textLen end
						elseif typ == 4 then
							local ahead = foundMap[pos+2]

							if ahead == 3 then
								_,ending = find(text,"]"..extras[pos+2].."]",pos+1,true)
								if not ending then ending = textLen end
							else
								ending = find(text,"\n",pos+1,true) or textLen
							end
						end

						while pos > lineEnd do
							curLine = curLine + 1
							
							lineEnd = newLines[curLine] or textLen+1
						end
						while true do
							local lineTable = foundHighlights[curLine]
							if not lineTable then lineTable = {} foundHighlights[curLine] = lineTable end
							lineTable[pos] = {typ,ending}
							

							if ending > lineEnd then
								curLine = curLine + 1
								lineEnd = newLines[curLine] or textLen+1
							else
								break
							end
						end

						lastEnding = ending
						
					end
					self.PreHighlights = foundHighlights
					
					
				end

				funcs.HighlightLine = function(self,line)
					local cached = self.ColoredLines[line]
					if cached then return cached end

					local sub = string.sub
					local find = string.find
					local match = string.match
					local highlights = {}
					local preHighlights = self.PreHighlights[line] or {}
					local lineText = self.Lines[line] or ""
					local lineLen = #lineText
					local lastEnding = 0
					local currentType = 0
					local lastWord = nil
					local wordBeginsDotted = false
					local funcStatus = 0
					local lineStart = self.NewLines[line-1] or 0

					local preHighlightMap = {}
					for pos,data in next,preHighlights do
						local relativePos = pos-lineStart
						if relativePos < 1 then
							currentType = data[1]
							lastEnding = data[2] - lineStart
							
						else
							preHighlightMap[relativePos] = {data[1],data[2]-lineStart}
						end
					end

					for col = 1,#lineText do
						if col <= lastEnding then highlights[col] = currentType continue end

						local pre = preHighlightMap[col]
						if pre then
							currentType = pre[1]
							lastEnding = pre[2]
							highlights[col] = currentType
							wordBeginsDotted = false
							lastWord = nil
							funcStatus = 0
						else
							local char = sub(lineText,col,col)
							if find(char,"[%a_]") then
								local word = match(lineText,"[%a%d_]+",col)
								local wordType = (keywords[word] and 7) or (builtIns[word] and 8)

								lastEnding = col+#word-1

								if wordType ~= 7 then
									if wordBeginsDotted then
										local prevBuiltIn = lastWord and builtIns[lastWord]
										wordType = (prevBuiltIn and type(prevBuiltIn) == "table" and prevBuiltIn[word] and 8) or 10
									end

									if wordType ~= 8 then
										local x,y,br = find(lineText,"^%s*([%({\"'])",lastEnding+1)
										if x then
											wordType = (funcStatus > 0 and br == "(" and 16) or 9
											funcStatus = 0
										end
									end
								else
									wordType = specialKeywordsTypes[word] or wordType
									funcStatus = (word == "function" and 1 or 0)
								end

								lastWord = word
								wordBeginsDotted = false
								if funcStatus > 0 then funcStatus = 1 end

								if wordType then
									currentType = wordType
									highlights[col] = currentType
								else
									currentType = nil
								end
							elseif find(char,"%p") then
								local isDot = (char == ".")
								local isNum = isDot and find(sub(lineText,col+1,col+1),"%d")
								highlights[col] = (isNum and 6 or 5)

								if not isNum then
									local dotStr = isDot and match(lineText,"%.%.?%.?",col)
									if dotStr and #dotStr > 1 then
										currentType = 5
										lastEnding = col+#dotStr-1
										wordBeginsDotted = false
										lastWord = nil
										funcStatus = 0
									else
										if isDot then
											if wordBeginsDotted then
												lastWord = nil
											else
												wordBeginsDotted = true
											end
										else
											wordBeginsDotted = false
											lastWord = nil
										end

										funcStatus = ((isDot or char == ":") and funcStatus == 1 and 2) or 0
									end
								end
							elseif find(char,"%d") then
								local _,endPos = find(lineText,"%x+",col)
								local endPart = sub(lineText,endPos,endPos+1)
								if (endPart == "e+" or endPart == "e-") and find(sub(lineText,endPos+2,endPos+2),"%d") then
									endPos = endPos + 1
								end
								currentType = 6
								lastEnding = endPos
								highlights[col] = 6
								wordBeginsDotted = false
								lastWord = nil
								funcStatus = 0
							else
								highlights[col] = currentType
								local _,endPos = find(lineText,"%s+",col)
								if endPos then
									lastEnding = endPos
								end
							end
						end
					end

					self.ColoredLines[line] = highlights
					return highlights
				end

				funcs.Refresh = function(self)
					local start = tick()

					local linesFrame = self.Frame.Lines
					local hSize = math.max(0,linesFrame.AbsoluteSize.X)
					local vSize = math.max(0,linesFrame.AbsoluteSize.Y)
					local maxLines = math.ceil(vSize / self.FontSize)
					local maxCols = math.ceil(hSize / math.ceil(self.FontSize/2))
					local gsub = string.gsub
					local sub = string.sub

					local viewX,viewY = self.ViewX,self.ViewY

					local lineNumberStr = ""

					for row = 1,maxLines do
						local lineFrame = self.LineFrames[row]
						if not lineFrame then
							lineFrame = Instance.new("Frame")
							lineFrame.Name = "Line"
							lineFrame.Position = UDim2.new(0,0,0,(row-1)*self.FontSize)
							lineFrame.Size = UDim2.new(1,0,0,self.FontSize)
							lineFrame.BorderSizePixel = 0
							lineFrame.BackgroundTransparency = 1

							local selectionHighlight = Instance.new("Frame")
							selectionHighlight.Name = "SelectionHighlight"
							selectionHighlight.BorderSizePixel = 0
							selectionHighlight.BackgroundColor3 = Settings.Theme.Syntax.SelectionBack
							selectionHighlight.Parent = lineFrame

							local label = Instance.new("TextLabel")
							label.Name = "Label"
							label.BackgroundTransparency = 1
							label.Font = Enum.Font.Code
							label.TextSize = self.FontSize
							label.Size = UDim2.new(1,0,0,self.FontSize)
							label.RichText = true
							label.TextXAlignment = Enum.TextXAlignment.Left
							label.TextColor3 = self.Colors.Text
							label.ZIndex = 2
							label.Parent = lineFrame

							lineFrame.Parent = linesFrame
							self.LineFrames[row] = lineFrame
						end

						local relaY = viewY + row
						local lineText = self.Lines[relaY] or ""
						local resText = ""
						local highlights = self:HighlightLine(relaY)
						local colStart = viewX + 1

						local richTemplates = self.RichTemplates
						local textTemplate = richTemplates.Text
						local selectionTemplate = richTemplates.Selection
						local curType = highlights[colStart]
						local curTemplate = richTemplates[typeMap[curType]] or textTemplate

						
						local selectionRange = self.SelectionRange
						local selPos1 = selectionRange[1]
						local selPos2 = selectionRange[2]
						local selRow,selColumn = selPos1[2],selPos1[1]
						local sel2Row,sel2Column = selPos2[2],selPos2[1]
						local selRelaX,selRelaY = viewX,relaY-1

						if selRelaY >= selPos1[2] and selRelaY <= selPos2[2] then
							local fontSizeX = math.ceil(self.FontSize/2)
							local posX = (selRelaY == selPos1[2] and selPos1[1] or 0) - viewX
							local sizeX = (selRelaY == selPos2[2] and selPos2[1]-posX-viewX or maxCols+viewX)

							lineFrame.SelectionHighlight.Position = UDim2.new(0,posX*fontSizeX,0,0)
							lineFrame.SelectionHighlight.Size = UDim2.new(0,sizeX*fontSizeX,1,0)
							lineFrame.SelectionHighlight.Visible = true
						else
							lineFrame.SelectionHighlight.Visible = false
						end

						
						local inSelection = selRelaY >= selRow and selRelaY <= sel2Row and (selRelaY == selRow and viewX >= selColumn or selRelaY ~= selRow) and (selRelaY == sel2Row and viewX < sel2Column or selRelaY ~= sel2Row)
						if inSelection then
							curType = -999
							curTemplate = selectionTemplate
						end

						for col = 2,maxCols do
							local relaX = viewX + col
							local selRelaX = relaX-1
							local posType = highlights[relaX]

							
							local inSelection = selRelaY >= selRow and selRelaY <= sel2Row and (selRelaY == selRow and selRelaX >= selColumn or selRelaY ~= selRow) and (selRelaY == sel2Row and selRelaX < sel2Column or selRelaY ~= sel2Row)
							if inSelection then
								posType = -999
							end

							if posType ~= curType then
								local template = (inSelection and selectionTemplate) or richTemplates[typeMap[posType]] or textTemplate

								if template ~= curTemplate then
									local nextText = gsub(sub(lineText,colStart,relaX-1),"['\"<>&]",richReplace)
									resText = resText .. (curTemplate ~= textTemplate and (curTemplate .. nextText .. "</font>") or nextText)
									colStart = relaX
									curTemplate = template
								end
								curType = posType
							end
						end

						local lastText = gsub(sub(lineText,colStart,viewX+maxCols),"['\"<>&]",richReplace)
						
						if #lastText > 0 then
							resText = resText .. (curTemplate ~= textTemplate and (curTemplate .. lastText .. "</font>") or lastText)
						end

						if self.Lines[relaY] then
							lineNumberStr = lineNumberStr .. (relaY == self.CursorY and ("<b>"..relaY.."</b>\n") or relaY .. "\n")
						end

						lineFrame.Label.Text = resText
					end

					for i = maxLines+1,#self.LineFrames do
						self.LineFrames[i]:Destroy()
						self.LineFrames[i] = nil
					end

					self.Frame.LineNumbers.Text = lineNumberStr
					self:UpdateCursor()

					
				end

				funcs.UpdateView = function(self)
					local totalLinesStr = tostring(#self.Lines)
					local fontWidth = math.ceil(self.FontSize / 2)
					local linesOffset = #totalLinesStr*fontWidth + 4*fontWidth

					local linesFrame = self.Frame.Lines
					local hSize = linesFrame.AbsoluteSize.X
					local vSize = linesFrame.AbsoluteSize.Y
					local maxLines = math.ceil(vSize / self.FontSize)
					local totalWidth = self.MaxTextCols*fontWidth
					local scrollV = self.ScrollV
					local scrollH = self.ScrollH

					scrollV.VisibleSpace = maxLines
					scrollV.TotalSpace = #self.Lines + 1
					scrollH.VisibleSpace = math.ceil(hSize/fontWidth)
					scrollH.TotalSpace = self.MaxTextCols + 1

					scrollV.Gui.Visible = #self.Lines + 1 > maxLines
					scrollH.Gui.Visible = totalWidth > hSize

					local oldOffsets = self.FrameOffsets
					self.FrameOffsets = Vector2.new(scrollV.Gui.Visible and -16 or 0, scrollH.Gui.Visible and -16 or 0)
					if oldOffsets ~= self.FrameOffsets then
						self:UpdateView()
					else
						scrollV:ScrollTo(self.ViewY,true)
						scrollH:ScrollTo(self.ViewX,true)

						if scrollV.Gui.Visible and scrollH.Gui.Visible then
							scrollV.Gui.Size = UDim2.new(0,16,1,-16)
							scrollH.Gui.Size = UDim2.new(1,-16,0,16)
							self.GuiElems.ScrollCorner.Visible = true
						else
							scrollV.Gui.Size = UDim2.new(0,16,1,0)
							scrollH.Gui.Size = UDim2.new(1,0,0,16)
							self.GuiElems.ScrollCorner.Visible = false
						end

						self.ViewY = scrollV.Index
						self.ViewX = scrollH.Index
						self.Frame.Lines.Position = UDim2.new(0,linesOffset,0,0)
						self.Frame.Lines.Size = UDim2.new(1,-linesOffset+oldOffsets.X,1,oldOffsets.Y)
						self.Frame.LineNumbers.Position = UDim2.new(0,fontWidth,0,0)
						self.Frame.LineNumbers.Size = UDim2.new(0,#totalLinesStr*fontWidth,1,oldOffsets.Y)
						self.Frame.LineNumbers.TextSize = self.FontSize
					end
				end

				funcs.ProcessTextChange = function(self)
					local maxCols = 0
					local lines = self.Lines

					for i = 1,#lines do
						local lineLen = #lines[i]
						if lineLen > maxCols then
							maxCols = lineLen
						end
					end

					self.MaxTextCols = maxCols
					self:UpdateView()	
					self.Text = table.concat(self.Lines,"\n")
					self:MapNewLines()
					self:PreHighlight()
					self:Refresh()
					
				end

				funcs.ConvertText = function(self,text,toEditor)
					if toEditor then
						return text:gsub("\t",(" %s "):format(tabSub))
					else
						return text:gsub((" %s "):format(tabSub),"\t")
					end
				end

				funcs.GetText = function(self) 
					local source = table.concat(self.Lines,"\n")
					return self:ConvertText(source,false) 
				end

				funcs.SetText = function(self,txt)
					txt = self:ConvertText(txt,true) 
					local lines = self.Lines
					table.clear(lines)
					local count = 1

					for line in txt:gmatch("([^\n\r]*)[\n\r]?") do
						local len = #line
						lines[count] = line
						count = count + 1
					end

					self:ProcessTextChange()
				end

				funcs.MakeRichTemplates = function(self)
					local floor = math.floor
					local templates = {}

					for name,color in pairs(self.Colors) do
						templates[name] = ('<font color="rgb(%s,%s,%s)">'):format(floor(color.r*255),floor(color.g*255),floor(color.b*255))
					end

					self.RichTemplates = templates
				end

				funcs.ApplyTheme = function(self)
					local colors = Settings.Theme.Syntax
					self.Colors = colors
					self.Frame.LineNumbers.TextColor3 = colors.Text
					self.Frame.BackgroundColor3 = colors.Background
				end

				local mt = {__index = funcs}

				local function new()
					if not builtInInited then initBuiltIn() end

					local scrollV = Lib.ScrollBar.new()
					local scrollH = Lib.ScrollBar.new(true)
					scrollH.Gui.Position = UDim2.new(0,0,1,-16)
					local obj = setmetatable({
						FontSize = 15,
						ViewX = 0,
						ViewY = 0,
						Colors = Settings.Theme.Syntax,
						ColoredLines = {},
						Lines = {""},
						LineFrames = {},
						Editable = true,
						Editing = false,
						CursorX = 0,
						CursorY = 0,
						FloatCursorX = 0,
						Text = "",
						PreHighlights = {},
						SelectionRange = {{-1,-1},{-1,-1}},
						NewLines = {},
						FrameOffsets = Vector2.new(0,0),
						MaxTextCols = 0,
						ScrollV = scrollV,
						ScrollH = scrollH
					},mt)

					scrollV.WheelIncrement = 3
					scrollH.Increment = 2
					scrollH.WheelIncrement = 7

					scrollV.Scrolled:Connect(function()
						obj.ViewY = scrollV.Index
						obj:Refresh()
					end)

					scrollH.Scrolled:Connect(function()
						obj.ViewX = scrollH.Index
						obj:Refresh()
					end)

					makeFrame(obj)
					obj:MakeRichTemplates()
					obj:ApplyTheme()
					scrollV:SetScrollFrame(obj.Frame.Lines)
					scrollV.Gui.Parent = obj.Frame
					scrollH.Gui.Parent = obj.Frame

					obj:UpdateView()
					obj.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
						obj:UpdateView()
						obj:Refresh()
					end)

					return obj
				end

				return {new = new}
			end)()

			Lib.Checkbox = (function()
				local funcs = {}
				local c3 = Color3.fromRGB
				local v2 = Vector2.new
				local ud2s = UDim2.fromScale
				local ud2o = UDim2.fromOffset
				local ud = UDim.new
				local max = math.max
				local new = Instance.new
				local TweenSize = new("Frame").TweenSize
				local ti = TweenInfo.new
				local delay = delay

				local function ripple(object, color)
					local circle = new('Frame')
					circle.BackgroundColor3 = color
					circle.BackgroundTransparency = 0.75
					circle.BorderSizePixel = 0
					circle.AnchorPoint = v2(0.5, 0.5)
					circle.Size = ud2o()
					circle.Position = ud2s(0.5, 0.5)
					circle.Parent = object
					local rounding = new('UICorner')
					rounding.CornerRadius = ud(1)
					rounding.Parent = circle

					local abssz = object.AbsoluteSize
					local size = max(abssz.X, abssz.Y) * 5/3

					TweenSize(circle, ud2o(size, size), "Out", "Quart", 0.4)
					service.TweenService:Create(circle, ti(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()

					service.Debris:AddItem(circle, 0.4)
				end

				local function initGui(self,frame)
					local checkbox = frame or create({
						{1,"ImageButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Checkbox",Position=UDim2.new(0,3,0,3),Size=UDim2.new(0,16,0,16),}},
						{2,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ripples",Parent={1},Size=UDim2.new(1,0,1,0),}},
						{3,"Frame",{BackgroundColor3=Color3.new(0.10196078568697,0.10196078568697,0.10196078568697),BorderSizePixel=0,Name="outline",Parent={1},Size=UDim2.new(0,16,0,16),}},
						{4,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14117647707462),BorderSizePixel=0,Name="filler",Parent={3},Position=UDim2.new(0,1,0,1),Size=UDim2.new(0,14,0,14),}},
						{5,"Frame",{BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="top",Parent={4},Size=UDim2.new(0,16,0,0),}},
						{6,"Frame",{AnchorPoint=Vector2.new(0,1),BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="bottom",Parent={4},Position=UDim2.new(0,0,0,14),Size=UDim2.new(0,16,0,0),}},
						{7,"Frame",{BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="left",Parent={4},Size=UDim2.new(0,0,0,16),}},
						{8,"Frame",{AnchorPoint=Vector2.new(1,0),BackgroundColor3=Color3.new(0.90196084976196,0.90196084976196,0.90196084976196),BorderSizePixel=0,Name="right",Parent={4},Position=UDim2.new(0,14,0,0),Size=UDim2.new(0,0,0,16),}},
						{9,"Frame",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,Name="checkmark",Parent={4},Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,0,0,20),}},
						{10,"ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://6234266378",Parent={9},Position=UDim2.new(0.5,0,0.5,0),ScaleType=3,Size=UDim2.new(0,15,0,11),}},
						{11,"ImageLabel",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6401617475",ImageColor3=Color3.new(0.20784313976765,0.69803923368454,0.98431372642517),Name="checkmark2",Parent={4},Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,12,0,12),Visible=false,}},
						{12,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6425281788",ImageTransparency=0.20000000298023,Name="middle",Parent={4},ScaleType=2,Size=UDim2.new(1,0,1,0),TileSize=UDim2.new(0,2,0,2),Visible=false,}},
						{13,"UICorner",{CornerRadius=UDim.new(0,2),Parent={3},}},
					})
					local outline = checkbox.outline
					local filler = outline.filler
					local checkmark = filler.checkmark
					local ripples_container = checkbox.ripples

					
					local top, bottom, left, right = filler.top, filler.bottom, filler.left, filler.right

					self.Gui = checkbox
					self.GuiElems = {
						Top = top,
						Bottom = bottom,
						Left = left,
						Right = right,
						Outline = outline,
						Filler = filler,
						Checkmark = checkmark,
						Checkmark2 = filler.checkmark2,
						Middle = filler.middle
					}

					checkbox.Activated:Connect(function()
						if Lib.CheckMouseInGui(checkbox) then
							if self.Style == 0 then
								ripple(ripples_container, self.Disabled and self.Colors.Disabled or self.Colors.Primary)
							end

							if not self.Disabled then
								self:SetState(not self.Toggled,true)
							else
								self:Paint()
							end

							self.OnInput:Fire()
						end
					end)

					
			
























					self:Paint()
				end

				funcs.Collapse = function(self,anim)
					local guiElems = self.GuiElems
					if anim then
						TweenSize(guiElems.Top, ud2o(14, 14), "In", "Quart", 4/15, true)
						TweenSize(guiElems.Bottom, ud2o(14, 14), "In", "Quart", 4/15, true)
						TweenSize(guiElems.Left, ud2o(14, 14), "In", "Quart", 4/15, true)
						TweenSize(guiElems.Right, ud2o(14, 14), "In", "Quart", 4/15, true)
					else
						guiElems.Top.Size = ud2o(14, 14)
						guiElems.Bottom.Size = ud2o(14, 14)
						guiElems.Left.Size = ud2o(14, 14)
						guiElems.Right.Size = ud2o(14, 14)
					end
				end

				funcs.Expand = function(self,anim)
					local guiElems = self.GuiElems
					if anim then
						TweenSize(guiElems.Top, ud2o(14, 0), "InOut", "Quart", 4/15, true)
						TweenSize(guiElems.Bottom, ud2o(14, 0), "InOut", "Quart", 4/15, true)
						TweenSize(guiElems.Left, ud2o(0, 14), "InOut", "Quart", 4/15, true)
						TweenSize(guiElems.Right, ud2o(0, 14), "InOut", "Quart", 4/15, true)
					else
						guiElems.Top.Size = ud2o(14, 0)
						guiElems.Bottom.Size = ud2o(14, 0)
						guiElems.Left.Size = ud2o(0, 14)
						guiElems.Right.Size = ud2o(0, 14)
					end
				end

				funcs.Paint = function(self)
					local guiElems = self.GuiElems

					if self.Style == 0 then
						local color_base = self.Disabled and self.Colors.Disabled
						guiElems.Outline.BackgroundColor3 = color_base or (self.Toggled and self.Colors.Primary) or self.Colors.Secondary
						local walls_color = color_base or self.Colors.Primary
						guiElems.Top.BackgroundColor3 = walls_color
						guiElems.Bottom.BackgroundColor3 = walls_color
						guiElems.Left.BackgroundColor3 = walls_color
						guiElems.Right.BackgroundColor3 = walls_color
					else
						guiElems.Outline.BackgroundColor3 = self.Disabled and self.Colors.Disabled or self.Colors.Secondary
						guiElems.Filler.BackgroundColor3 = self.Disabled and self.Colors.DisabledBackground or self.Colors.Background
						guiElems.Checkmark2.ImageColor3 = self.Disabled and self.Colors.DisabledCheck or self.Colors.Primary
					end
				end

				funcs.SetState = function(self,val,anim)
					self.Toggled = val

					if self.OutlineColorTween then self.OutlineColorTween:Cancel() end
					local setStateTime = tick()
					self.LastSetStateTime = setStateTime

					if self.Toggled then
						if self.Style == 0 then
							if anim then
								self.OutlineColorTween = service.TweenService:Create(self.GuiElems.Outline, ti(4/15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {BackgroundColor3 = self.Colors.Primary})
								self.OutlineColorTween:Play()
								delay(0.15, function()
									if setStateTime ~= self.LastSetStateTime then return end
									self:Paint()
									TweenSize(self.GuiElems.Checkmark, ud2o(14, 20), "Out", "Bounce", 2/15, true)
								end)
							else
								self.GuiElems.Outline.BackgroundColor3 = self.Colors.Primary
								self:Paint()
								self.GuiElems.Checkmark.Size = ud2o(14, 20)
							end
							self:Collapse(anim)
						else
							self:Paint()
							self.GuiElems.Checkmark2.Visible = true
							self.GuiElems.Middle.Visible = false
						end
					else
						if self.Style == 0 then
							if anim then
								self.OutlineColorTween = service.TweenService:Create(self.GuiElems.Outline, ti(4/15, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {BackgroundColor3 = self.Colors.Secondary})
								self.OutlineColorTween:Play()
								delay(0.15, function()
									if setStateTime ~= self.LastSetStateTime then return end
									self:Paint()
									TweenSize(self.GuiElems.Checkmark, ud2o(0, 20), "Out", "Quad", 1/15, true)
								end)
							else
								self.GuiElems.Outline.BackgroundColor3 = self.Colors.Secondary
								self:Paint()
								self.GuiElems.Checkmark.Size = ud2o(0, 20)
							end
							self:Expand(anim)
						else
							self:Paint()
							self.GuiElems.Checkmark2.Visible = false
							self.GuiElems.Middle.Visible = self.Toggled == nil
						end
					end
				end

				local mt = {__index = funcs}

				local function new(style)
					local obj = setmetatable({
						Toggled = false,
						Disabled = false,
						OnInput = Lib.Signal.new(),
						Style = style or 0,
						Colors = {
							Background = c3(36,36,36),
							Primary = c3(49,176,230),
							Secondary = c3(25,25,25),
							Disabled = c3(64,64,64),
							DisabledBackground = c3(52,52,52),
							DisabledCheck = c3(80,80,80)
						}
					},mt)
					initGui(obj)
					return obj
				end

				local function fromFrame(frame)
					local obj = setmetatable({
						Toggled = false,
						Disabled = false,
						Colors = {
							Background = c3(36,36,36),
							Primary = c3(49,176,230),
							Secondary = c3(25,25,25),
							Disabled = c3(64,64,64),
							DisabledBackground = c3(52,52,52)
						}
					},mt)
					initGui(obj,frame)
					return obj
				end

				return {new = new, fromFrame}
			end)()

			Lib.BrickColorPicker = (function()
				local funcs = {}
				local paletteCount = 0
				local mouse = service.Players.LocalPlayer:GetMouse()
				local hexStartX = 4
				local hexSizeX = 27
				local hexTriangleStart = 1
				local hexTriangleSize = 8

				local bottomColors = {
					Color3.fromRGB(17,17,17),
					Color3.fromRGB(99,95,98),
					Color3.fromRGB(163,162,165),
					Color3.fromRGB(205,205,205),
					Color3.fromRGB(223,223,222),
					Color3.fromRGB(237,234,234),
					Color3.fromRGB(27,42,53),
					Color3.fromRGB(91,93,105),
					Color3.fromRGB(159,161,172),
					Color3.fromRGB(202,203,209),
					Color3.fromRGB(231,231,236),
					Color3.fromRGB(248,248,248)
				}

				local function isMouseInHexagon(hex, touchPos)
					local relativeX = touchPos.X - hex.AbsolutePosition.X
					local relativeY = touchPos.Y - hex.AbsolutePosition.Y
					if relativeX >= hexStartX and relativeX < hexStartX + hexSizeX then
						relativeX = relativeX - 4
						local relativeWidth = (13 - math.min(relativeX, 26 - relativeX)) / 13
						if relativeY >= hexTriangleStart + hexTriangleSize * relativeWidth and relativeY < hex.AbsoluteSize.Y - hexTriangleStart - hexTriangleSize * relativeWidth then
							return true
						end
					end
					return false
				end

				local function hexInput(self, hex, color)
					hex.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							if isMouseInHexagon(hex, input.Position) then
								self.OnSelect:Fire(color)
								self:Close()
							end
						end
					end)

					hex.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							if isMouseInHexagon(hex, input.Position) then
								self.OnPreview:Fire(color)
							end
						end
					end)
				end

				local function createGui(self)
					local gui = create({
						{1,"ScreenGui",{Name="BrickColor",}},
						{2,"Frame",{Active=true,BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),Parent={1},Position=UDim2.new(0.40000000596046,0,0.40000000596046,0),Size=UDim2.new(0,337,0,380),}},
						{3,"TextButton",{BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="MoreColors",Parent={2},Position=UDim2.new(0,5,1,-30),Size=UDim2.new(1,-10,0,25),Text="More Colors",TextColor3=Color3.new(1,1,1),TextSize=14,}},
						{4,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://1281023007",ImageColor3=Color3.new(0.33333334326744,0.33333334326744,0.49803924560547),Name="Hex",Parent={2},Size=UDim2.new(0,35,0,35),Visible=false,}},
					})
					local colorFrame = gui.Frame
					local hex = colorFrame.Hex

					for row = 1,13 do
						local columns = math.min(row,14-row)+6
						for column = 1,columns do
							local nextColor = BrickColor.palette(paletteCount).Color
							local newHex = hex:Clone()
							newHex.Position = UDim2.new(0, (column-1)*25-(columns-7)*13+3*26 + 1, 0, (row-1)*23 + 4)
							newHex.ImageColor3 = nextColor
							newHex.Visible = true
							hexInput(self,newHex,nextColor)
							newHex.Parent = colorFrame
							paletteCount = paletteCount + 1
						end
					end

					for column = 1,12 do
						local nextColor = bottomColors[column]
						local newHex = hex:Clone()
						newHex.Position = UDim2.new(0, (column-1)*25-(12-7)*13+3*26 + 3, 0, 308)
						newHex.ImageColor3 = nextColor
						newHex.Visible = true
						hexInput(self,newHex,nextColor)
						newHex.Parent = colorFrame
						paletteCount = paletteCount + 1
					end

					colorFrame.MoreColors.MouseButton1Click:Connect(function()
						self.OnMoreColors:Fire()
						self:Close()
					end)

					self.Gui = gui
				end

				funcs.SetMoreColorsVisible = function(self,vis)
					local colorFrame = self.Gui.Frame
					colorFrame.Size = UDim2.new(0,337,0,380 - (not vis and 33 or 0))
					colorFrame.MoreColors.Visible = vis
				end

				funcs.Show = function(self,x,y,prevColor)
					self.PrevColor = prevColor or self.PrevColor

					local reverseY = false

					local x,y = x or mouse.X, y or mouse.Y
					local maxX,maxY = mouse.ViewSizeX,mouse.ViewSizeY
					Lib.ShowGui(self.Gui)
					local sizeX,sizeY = self.Gui.Frame.AbsoluteSize.X,self.Gui.Frame.AbsoluteSize.Y

					if x + sizeX > maxX then x = self.ReverseX and x - sizeX or maxX - sizeX end
					if y + sizeY > maxY then reverseY = true end

					local closable = false
					if self.CloseEvent then self.CloseEvent:Disconnect() end

					self.CloseEvent = service.UserInputService.InputBegan:Connect(function(input)
						if not closable or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then
							return
						end

						if not Lib.CheckMouseInGui(self.Gui.Frame) then
							self.CloseEvent:Disconnect()
							self:Close()
						end
					end)


					if reverseY then
						local newY = y - sizeY - (self.ReverseYOffset or 0)
						y = newY >= 0 and newY or 0
					end

					self.Gui.Frame.Position = UDim2.new(0,x,0,y)

					Lib.FastWait()
					closable = true
				end

				funcs.Close = function(self)
					self.Gui.Parent = nil
					self.OnCancel:Fire()
				end

				local mt = {__index = funcs}

				local function new()
					local obj = setmetatable({
						OnPreview = Lib.Signal.new(),
						OnSelect = Lib.Signal.new(),
						OnCancel = Lib.Signal.new(),
						OnMoreColors = Lib.Signal.new(),
						PrevColor = Color3.new(0,0,0)
					}, mt)
					createGui(obj)
					return obj
				end

				return {new = new}
			end)()

			Lib.ColorPicker = (function() 
				local funcs = {}

				local function new()
					local newMt = setmetatable({},{})

					newMt.OnSelect = Lib.Signal.new()
					newMt.OnCancel = Lib.Signal.new()
					newMt.OnPreview = Lib.Signal.new()

					local guiContents = create({
						{1,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Content",Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),}},
						{2,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="BasicColors",Parent={1},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,180,0,200),}},
						{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,0,0,-5),Size=UDim2.new(1,0,0,26),Text="Basic Colors",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{4,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Blue",Parent={1},Position=UDim2.new(1,-63,0,255),Size=UDim2.new(0,52,0,16),}},
						{5,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={4},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{6,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={5},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
						{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={6},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{8,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={7},Size=UDim2.new(0,16,0,8),}},
						{9,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={8},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
						{10,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={8},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{11,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={8},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
						{12,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={6},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{13,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={12},Size=UDim2.new(0,16,0,8),}},
						{14,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={13},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
						{15,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={13},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{16,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={13},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
						{17,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={4},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Blue:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{18,"Frame",{BackgroundColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,ClipsDescendants=true,Name="ColorSpaceFrame",Parent={1},Position=UDim2.new(1,-261,0,4),Size=UDim2.new(0,222,0,202),}},
						{19,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),BorderSizePixel=0,Image="rbxassetid://1072518406",Name="ColorSpace",Parent={18},Position=UDim2.new(0,1,0,1),Size=UDim2.new(0,220,0,200),}},
						{20,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Scope",Parent={19},Position=UDim2.new(0,210,0,190),Size=UDim2.new(0,20,0,20),}},
						{21,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Name="Line",Parent={20},Position=UDim2.new(0,9,0,0),Size=UDim2.new(0,2,0,20),}},
						{22,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Name="Line",Parent={20},Position=UDim2.new(0,0,0,9),Size=UDim2.new(0,20,0,2),}},
						{23,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="CustomColors",Parent={1},Position=UDim2.new(0,5,0,210),Size=UDim2.new(0,180,0,90),}},
						{24,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={23},Size=UDim2.new(1,0,0,20),Text="Custom Colors (RC = Set)",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{25,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Green",Parent={1},Position=UDim2.new(1,-63,0,233),Size=UDim2.new(0,52,0,16),}},
						{26,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={25},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{27,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={26},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
						{28,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={27},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{29,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={28},Size=UDim2.new(0,16,0,8),}},
						{30,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={29},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
						{31,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={29},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{32,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={29},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
						{33,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={27},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{34,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={33},Size=UDim2.new(0,16,0,8),}},
						{35,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={34},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
						{36,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={34},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{37,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={34},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
						{38,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={25},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Green:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{39,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Hue",Parent={1},Position=UDim2.new(1,-180,0,211),Size=UDim2.new(0,52,0,16),}},
						{40,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={39},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{41,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={40},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
						{42,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={41},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{43,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={42},Size=UDim2.new(0,16,0,8),}},
						{44,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={43},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
						{45,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={43},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{46,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={43},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
						{47,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={41},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{48,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={47},Size=UDim2.new(0,16,0,8),}},
						{49,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={48},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
						{50,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={48},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{51,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={48},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
						{52,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={39},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Hue:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{53,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="Preview",Parent={1},Position=UDim2.new(1,-260,0,211),Size=UDim2.new(0,35,1,-245),}},
						{54,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Red",Parent={1},Position=UDim2.new(1,-63,0,211),Size=UDim2.new(0,52,0,16),}},
						{55,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={54},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{56,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={55},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
						{57,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={56},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{58,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={57},Size=UDim2.new(0,16,0,8),}},
						{59,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={58},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
						{60,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={58},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{61,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={58},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
						{62,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={56},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{63,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={62},Size=UDim2.new(0,16,0,8),}},
						{64,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={63},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
						{65,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={63},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{66,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={63},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
						{67,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={54},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Red:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{68,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Sat",Parent={1},Position=UDim2.new(1,-180,0,233),Size=UDim2.new(0,52,0,16),}},
						{69,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={68},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{70,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={69},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
						{71,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={70},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{72,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={71},Size=UDim2.new(0,16,0,8),}},
						{73,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={72},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
						{74,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={72},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{75,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={72},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
						{76,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={70},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{77,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={76},Size=UDim2.new(0,16,0,8),}},
						{78,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={77},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
						{79,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={77},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{80,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={77},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
						{81,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={68},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Sat:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{82,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Val",Parent={1},Position=UDim2.new(1,-180,0,255),Size=UDim2.new(0,52,0,16),}},
						{83,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Font=3,Name="Input",Parent={82},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,50,0,16),Text="255",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{84,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={83},Position=UDim2.new(1,-16,0,0),Size=UDim2.new(0,16,1,0),}},
						{85,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Up",Parent={84},Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{86,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={85},Size=UDim2.new(0,16,0,8),}},
						{87,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={86},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,1),}},
						{88,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={86},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{89,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={86},Position=UDim2.new(0,6,0,5),Size=UDim2.new(0,5,0,1),}},
						{90,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Down",Parent={84},Position=UDim2.new(0,0,0,8),Size=UDim2.new(1,0,0,8),Text="",TextSize=14,}},
						{91,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={90},Size=UDim2.new(0,16,0,8),}},
						{92,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={91},Position=UDim2.new(0,8,0,5),Size=UDim2.new(0,1,0,1),}},
						{93,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={91},Position=UDim2.new(0,7,0,4),Size=UDim2.new(0,3,0,1),}},
						{94,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={91},Position=UDim2.new(0,6,0,3),Size=UDim2.new(0,5,0,1),}},
						{95,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={82},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Val:",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{96,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Cancel",Parent={1},Position=UDim2.new(1,-105,1,-28),Size=UDim2.new(0,100,0,25),Text="Cancel",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
						{97,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Ok",Parent={1},Position=UDim2.new(1,-210,1,-28),Size=UDim2.new(0,100,0,25),Text="OK",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
						{98,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Image="rbxassetid://1072518502",Name="ColorStrip",Parent={1},Position=UDim2.new(1,-30,0,5),Size=UDim2.new(0,13,0,200),}},
						{99,"Frame",{BackgroundColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BackgroundTransparency=1,BorderSizePixel=0,Name="ArrowFrame",Parent={1},Position=UDim2.new(1,-16,0,1),Size=UDim2.new(0,5,0,208),}},
						{100,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={99},Position=UDim2.new(0,-2,0,-4),Size=UDim2.new(0,8,0,16),}},
						{101,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,2,0,8),Size=UDim2.new(0,1,0,1),}},
						{102,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,3,0,7),Size=UDim2.new(0,1,0,3),}},
						{103,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,4,0,6),Size=UDim2.new(0,1,0,5),}},
						{104,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,1,0,7),}},
						{105,"Frame",{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Parent={100},Position=UDim2.new(0,6,0,4),Size=UDim2.new(0,1,0,9),}},
					})
					local window = Lib.Window.new()
					window.Resizable = false
					window.Alignable = false
					window:SetTitle("Color Picker")
					window:Resize(450,330)
					for i,v in pairs(guiContents:GetChildren()) do
						v.Parent = window.GuiElems.Content
					end
					newMt.Window = window
					newMt.Gui = window.Gui
					local pickerGui = window.Gui.Main
					local pickerTopBar = pickerGui.TopBar
					local pickerFrame = pickerGui.Content
					local colorSpace = pickerFrame.ColorSpaceFrame.ColorSpace
					local colorStrip = pickerFrame.ColorStrip
					local previewFrame = pickerFrame.Preview
					local basicColorsFrame = pickerFrame.BasicColors
					local customColorsFrame = pickerFrame.CustomColors
					local okButton = pickerFrame.Ok
					local cancelButton = pickerFrame.Cancel
					local closeButton = pickerTopBar.Close

					local colorScope = colorSpace.Scope
					local colorArrow = pickerFrame.ArrowFrame.Arrow

					local hueInput = pickerFrame.Hue.Input
					local satInput = pickerFrame.Sat.Input
					local valInput = pickerFrame.Val.Input

					local redInput = pickerFrame.Red.Input
					local greenInput = pickerFrame.Green.Input
					local blueInput = pickerFrame.Blue.Input

					local user = service.UserInputService
					local mouse = service.Players.LocalPlayer:GetMouse()

					local hue,sat,val = 0,0,1
					local red,green,blue = 1,1,1
					local chosenColor = Color3.new(0,0,0)

					local basicColors = {Color3.new(0,0,0),Color3.new(0.66666668653488,0,0),Color3.new(0,0.33333334326744,0),Color3.new(0.66666668653488,0.33333334326744,0),Color3.new(0,0.66666668653488,0),Color3.new(0.66666668653488,0.66666668653488,0),Color3.new(0,1,0),Color3.new(0.66666668653488,1,0),Color3.new(0,0,0.49803924560547),Color3.new(0.66666668653488,0,0.49803924560547),Color3.new(0,0.33333334326744,0.49803924560547),Color3.new(0.66666668653488,0.33333334326744,0.49803924560547),Color3.new(0,0.66666668653488,0.49803924560547),Color3.new(0.66666668653488,0.66666668653488,0.49803924560547),Color3.new(0,1,0.49803924560547),Color3.new(0.66666668653488,1,0.49803924560547),Color3.new(0,0,1),Color3.new(0.66666668653488,0,1),Color3.new(0,0.33333334326744,1),Color3.new(0.66666668653488,0.33333334326744,1),Color3.new(0,0.66666668653488,1),Color3.new(0.66666668653488,0.66666668653488,1),Color3.new(0,1,1),Color3.new(0.66666668653488,1,1),Color3.new(0.33333334326744,0,0),Color3.new(1,0,0),Color3.new(0.33333334326744,0.33333334326744,0),Color3.new(1,0.33333334326744,0),Color3.new(0.33333334326744,0.66666668653488,0),Color3.new(1,0.66666668653488,0),Color3.new(0.33333334326744,1,0),Color3.new(1,1,0),Color3.new(0.33333334326744,0,0.49803924560547),Color3.new(1,0,0.49803924560547),Color3.new(0.33333334326744,0.33333334326744,0.49803924560547),Color3.new(1,0.33333334326744,0.49803924560547),Color3.new(0.33333334326744,0.66666668653488,0.49803924560547),Color3.new(1,0.66666668653488,0.49803924560547),Color3.new(0.33333334326744,1,0.49803924560547),Color3.new(1,1,0.49803924560547),Color3.new(0.33333334326744,0,1),Color3.new(1,0,1),Color3.new(0.33333334326744,0.33333334326744,1),Color3.new(1,0.33333334326744,1),Color3.new(0.33333334326744,0.66666668653488,1),Color3.new(1,0.66666668653488,1),Color3.new(0.33333334326744,1,1),Color3.new(1,1,1)}
					local customColors = {}

					local function updateColor(noupdate)
						local relativeX, relativeY, relativeStripY = 219 - hue * 219, 199 - sat * 199, 199 - val * 199
						local hsvColor = Color3.fromHSV(hue, sat, val)

						if noupdate == 2 or not noupdate then
							hueInput.Text = tostring(math.ceil(359 * hue))
							satInput.Text = tostring(math.ceil(255 * sat))
							valInput.Text = tostring(math.floor(255 * val))
						end
						if noupdate == 1 or not noupdate then
							redInput.Text = tostring(math.floor(255 * red))
							greenInput.Text = tostring(math.floor(255 * green))
							blueInput.Text = tostring(math.floor(255 * blue))
						end

						chosenColor = Color3.new(red, green, blue)
						colorScope.Position = UDim2.new(0, (relativeX - 9), 0, (relativeY - 9))
						colorStrip.ImageColor3 = Color3.fromHSV(hue, sat, 1)
						colorArrow.Position = UDim2.new(0, -2, 0, (relativeStripY - 4))
						previewFrame.BackgroundColor3 = chosenColor

						newMt.Color = chosenColor
						newMt.OnPreview:Fire(chosenColor)
					end

					local function handleInputBegan(input, updateFunc)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							while user:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
								updateFunc()task.wait()
							end
						end
					end

					local function colorSpaceInput()
						local relativeX = mouse.X - colorSpace.AbsolutePosition.X
						local relativeY = mouse.Y - colorSpace.AbsolutePosition.Y

						if relativeX < 0 then relativeX = 0 elseif relativeX > 219 then relativeX = 219 end
						if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end

						hue = (219 - relativeX) / 219
						sat = (199 - relativeY) / 199

						local hsvColor = Color3.fromHSV(hue, sat, val)
						red, green, blue = hsvColor.R, hsvColor.G, hsvColor.B
						updateColor()
					end

					local function colorStripInput()
						local relativeY = mouse.Y - colorStrip.AbsolutePosition.Y

						if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end	

						val = (199 - relativeY) / 199

						local hsvColor = Color3.fromHSV(hue, sat, val)
						red, green, blue = hsvColor.R, hsvColor.G, hsvColor.B
						updateColor()
					end

					colorSpace.InputBegan:Connect(function(input) handleInputBegan(input, colorSpaceInput) end)
					colorStrip.InputBegan:Connect(function(input) handleInputBegan(input, colorStripInput) end)

					local function hookButtons(frame, func)
						frame.ArrowFrame.Up.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								local releaseEvent, runEvent
								local startTime = tick()
								local pressing = true
								local startNum = tonumber(frame.Text)

								if not startNum then return end

								releaseEvent = user.InputEnded:Connect(function(endInput)
									if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
										releaseEvent:Disconnect()
										pressing = false
									end
								end)

								startNum = startNum + 1
								func(startNum)
								while pressing do
									if tick() - startTime > 0.3 then
										startNum = startNum + 1
										func(startNum)
										startTime = tick()
									end
									task.wait(0.1)
								end
							end
						end)

						frame.ArrowFrame.Down.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								local releaseEvent, runEvent
								local startTime = tick()
								local pressing = true
								local startNum = tonumber(frame.Text)

								if not startNum then return end

								releaseEvent = user.InputEnded:Connect(function(endInput)
									if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
										releaseEvent:Disconnect()
										pressing = false
									end
								end)

								startNum = startNum - 1
								func(startNum)
								while pressing do
									if tick() - startTime > 0.3 then
										startNum = startNum - 1
										func(startNum)
										startTime = tick()
									end
									task.wait(0.1)
								end
							end
						end)
					end

			











					local function updateHue(str)
						local num = tonumber(str)
						if num then
							hue = math.clamp(math.floor(num),0,359)/359
							local hsvColor = Color3.fromHSV(hue,sat,val)
							red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b

							hueInput.Text = tostring(hue*359)
							updateColor(1)
						end
					end
					hueInput.FocusLost:Connect(function() updateHue(hueInput.Text) end) hookButtons(hueInput, hueInput)

					local function updateSat(str)
						local num = tonumber(str)
						if num then
							sat = math.clamp(math.floor(num),0,255)/255
							local hsvColor = Color3.fromHSV(hue,sat,val)
							red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
							satInput.Text = tostring(sat*255)
							updateColor(1)
						end
					end
					satInput.FocusLost:Connect(function() updateSat(satInput.Text) end) hookButtons(satInput,updateSat)

					local function updateVal(str)
						local num = tonumber(str)
						if num then
							val = math.clamp(math.floor(num),0,255)/255
							local hsvColor = Color3.fromHSV(hue,sat,val)
							red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
							valInput.Text = tostring(val*255)
							updateColor(1)
						end
					end
					valInput.FocusLost:Connect(function() updateVal(valInput.Text) end) hookButtons(valInput,updateVal)

					local function updateRed(str)
						local num = tonumber(str)
						if num then
							red = math.clamp(math.floor(num),0,255)/255
							local newColor = Color3.new(red,green,blue)
							hue,sat,val = Color3.toHSV(newColor)
							redInput.Text = tostring(red*255)
							updateColor(2)
						end
					end
					redInput.FocusLost:Connect(function() updateRed(redInput.Text) end) hookButtons(redInput,updateRed)

					local function updateGreen(str)
						local num = tonumber(str)
						if num then
							green = math.clamp(math.floor(num),0,255)/255
							local newColor = Color3.new(red,green,blue)
							hue,sat,val = Color3.toHSV(newColor)
							greenInput.Text = tostring(green*255)
							updateColor(2)
						end
					end
					greenInput.FocusLost:Connect(function() updateGreen(greenInput.Text) end) hookButtons(greenInput,updateGreen)

					local function updateBlue(str)
						local num = tonumber(str)
						if num then
							blue = math.clamp(math.floor(num),0,255)/255
							local newColor = Color3.new(red,green,blue)
							hue,sat,val = Color3.toHSV(newColor)
							blueInput.Text = tostring(blue*255)
							updateColor(2)
						end
					end
					blueInput.FocusLost:Connect(function() updateBlue(blueInput.Text) end) hookButtons(blueInput,updateBlue)

					local colorChoice = Instance.new("TextButton")
					colorChoice.Name = "Choice"
					colorChoice.Size = UDim2.new(0,25,0,18)
					colorChoice.BorderColor3 = Color3.fromRGB(55,55,55)
					colorChoice.Text = ""
					colorChoice.AutoButtonColor = false

					local row = 0
					local column = 0
					for i,v in pairs(basicColors) do
						local newColor = colorChoice:Clone()
						newColor.BackgroundColor3 = v
						newColor.Position = UDim2.new(0,1 + 30*column,0,21 + 23*row)

						newColor.MouseButton1Click:Connect(function()
							red,green,blue = v.r,v.g,v.b
							local newColor = Color3.new(red,green,blue)
							hue,sat,val = Color3.toHSV(newColor)
							updateColor()
						end)

						newColor.Parent = basicColorsFrame
						column = column + 1
						if column == 6 then row = row + 1 column = 0 end
					end

					row = 0
					column = 0
					for i = 1,12 do
						local color = customColors[i] or Color3.new(0,0,0)
						local newColor = colorChoice:Clone()
						newColor.BackgroundColor3 = color
						newColor.Position = UDim2.new(0,1 + 30*column,0,20 + 23*row)

						newColor.MouseButton1Click:Connect(function()
							local curColor = customColors[i] or Color3.new(0,0,0)
							red,green,blue = curColor.r,curColor.g,curColor.b
							hue,sat,val = Color3.toHSV(curColor)
							updateColor()
						end)

						newColor.MouseButton2Click:Connect(function()
							customColors[i] = chosenColor
							newColor.BackgroundColor3 = chosenColor
						end)

						newColor.Parent = customColorsFrame
						column = column + 1
						if column == 6 then row = row + 1 column = 0 end
					end

					okButton.MouseButton1Click:Connect(function() newMt.OnSelect:Fire(chosenColor) window:Close() end)
					okButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then okButton.BackgroundTransparency = 0.4 end end)
					okButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then okButton.BackgroundTransparency = 0 end end)


					cancelButton.MouseButton1Click:Connect(function() newMt.OnCancel:Fire() window:Close() end)
					cancelButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then cancelButton.BackgroundTransparency = 0.4 end end)
					cancelButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then cancelButton.BackgroundTransparency = 0 end end)

					updateColor()

					newMt.SetColor = function(self,color)
						red,green,blue = color.r,color.g,color.b
						hue,sat,val = Color3.toHSV(color)
						updateColor()
					end

					newMt.Show = function(self)
						self.Window:Show()
					end

					return newMt
				end

				return {new = new}
			end)()

			Lib.NumberSequenceEditor = (function()
				local function new() 
					local newMt = setmetatable({},{})
					newMt.OnSelect = Lib.Signal.new()
					newMt.OnCancel = Lib.Signal.new()
					newMt.OnPreview = Lib.Signal.new()

					local guiContents = create({
						{1,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Content",Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),}},
						{2,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Time",Parent={1},Position=UDim2.new(0,40,0,210),Size=UDim2.new(0,60,0,20),}},
						{3,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={2},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,58,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{4,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Time",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{5,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Close",Parent={1},Position=UDim2.new(1,-90,0,210),Size=UDim2.new(0,80,0,20),Text="Close",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
						{6,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Reset",Parent={1},Position=UDim2.new(1,-180,0,210),Size=UDim2.new(0,80,0,20),Text="Reset",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
						{7,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Font=3,Name="Delete",Parent={1},Position=UDim2.new(0,380,0,210),Size=UDim2.new(0,80,0,20),Text="Delete",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
						{8,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="NumberLineOutlines",Parent={1},Position=UDim2.new(0,10,0,20),Size=UDim2.new(1,-20,0,170),}},
						{9,"Frame",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),Name="NumberLine",Parent={1},Position=UDim2.new(0,10,0,20),Size=UDim2.new(1,-20,0,170),}},
						{10,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Value",Parent={1},Position=UDim2.new(0,170,0,210),Size=UDim2.new(0,60,0,20),}},
						{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={10},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Value",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{12,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={10},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,58,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{13,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Envelope",Parent={1},Position=UDim2.new(0,300,0,210),Size=UDim2.new(0,60,0,20),}},
						{14,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={13},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,58,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{15,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={13},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Envelope",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
					})
					local window = Lib.Window.new()
					window.Resizable = false
					window:Resize(680,265)
					window:SetTitle("NumberSequence Editor")
					newMt.Window = window
					newMt.Gui = window.Gui
					for i,v in pairs(guiContents:GetChildren()) do
						v.Parent = window.GuiElems.Content
					end
					local gui = window.Gui
					local pickerGui = gui.Main
					local pickerTopBar = pickerGui.TopBar
					local pickerFrame = pickerGui.Content
					local numberLine = pickerFrame.NumberLine
					local numberLineOutlines = pickerFrame.NumberLineOutlines
					local timeBox = pickerFrame.Time.Input
					local valueBox = pickerFrame.Value.Input
					local envelopeBox = pickerFrame.Envelope.Input
					local deleteButton = pickerFrame.Delete
					local resetButton = pickerFrame.Reset
					local closeButton = pickerFrame.Close
					local topClose = pickerTopBar.Close

					local points = {{1,0,3},{8,0.05,1},{5,0.6,2},{4,0.7,4},{6,1,4}}
					local lines = {}
					local eLines = {}
					local beginPoint = points[1]
					local endPoint = points[#points]
					local currentlySelected = nil
					local currentPoint = nil
					local resetSequence = nil

					local user = service.UserInputService
					local mouse = service.Players.LocalPlayer:GetMouse()

					for i = 2,10 do
						local newLine = Instance.new("Frame")
						newLine.BackgroundTransparency = 0.5
						newLine.BackgroundColor3 = Color3.new(96/255,96/255,96/255)
						newLine.BorderSizePixel = 0
						newLine.Size = UDim2.new(0,1,1,0)
						newLine.Position = UDim2.new((i-1)/(11-1),0,0,0)
						newLine.Parent = numberLineOutlines
					end

					for i = 2,4 do
						local newLine = Instance.new("Frame")
						newLine.BackgroundTransparency = 0.5
						newLine.BackgroundColor3 = Color3.new(96/255,96/255,96/255)
						newLine.BorderSizePixel = 0
						newLine.Size = UDim2.new(1,0,0,1)
						newLine.Position = UDim2.new(0,0,(i-1)/(5-1),0)
						newLine.Parent = numberLineOutlines
					end

					local lineTemp = Instance.new("Frame")
					lineTemp.BackgroundColor3 = Color3.new(0,0,0)
					lineTemp.BorderSizePixel = 0
					lineTemp.Size = UDim2.new(0,1,0,1)

					local sequenceLine = Instance.new("Frame")
					sequenceLine.BackgroundColor3 = Color3.new(0,0,0)
					sequenceLine.BorderSizePixel = 0
					sequenceLine.Size = UDim2.new(0,1,0,0)

					for i = 1,numberLine.AbsoluteSize.X do
						local line = sequenceLine:Clone()
						eLines[i] = line
						line.Name = "E"..tostring(i)
						line.BackgroundTransparency = 0.5
						line.BackgroundColor3 = Color3.new(199/255,44/255,28/255)
						line.Position = UDim2.new(0,i-1,0,0)
						line.Parent = numberLine
					end

					for i = 1,numberLine.AbsoluteSize.X do
						local line = sequenceLine:Clone()
						lines[i] = line
						line.Name = tostring(i)
						line.Position = UDim2.new(0,i-1,0,0)
						line.Parent = numberLine
					end

					local envelopeDrag = Instance.new("Frame")
					envelopeDrag.BackgroundTransparency = 1
					envelopeDrag.BackgroundColor3 = Color3.new(0,0,0)
					envelopeDrag.BorderSizePixel = 0
					envelopeDrag.Size = UDim2.new(0,7,0,20)
					envelopeDrag.Visible = false
					envelopeDrag.ZIndex = 2
					local envelopeDragLine = Instance.new("Frame",envelopeDrag)
					envelopeDragLine.Name = "Line"
					envelopeDragLine.BackgroundColor3 = Color3.new(0,0,0)
					envelopeDragLine.BorderSizePixel = 0
					envelopeDragLine.Position = UDim2.new(0,3,0,0)
					envelopeDragLine.Size = UDim2.new(0,1,0,20)
					envelopeDragLine.ZIndex = 2

					local envelopeDragTop,envelopeDragBottom = envelopeDrag:Clone(),envelopeDrag:Clone()
					envelopeDragTop.Parent = numberLine
					envelopeDragBottom.Parent = numberLine

					local function buildSequence()
						local newPoints = {}
						for i,v in pairs(points) do
							table.insert(newPoints,NumberSequenceKeypoint.new(v[2],v[1],v[3]))
						end
						newMt.Sequence = NumberSequence.new(newPoints)
						newMt.OnSelect:Fire(newMt.Sequence)
					end

					local function round(num,places)
						local multi = 10^places
						return math.floor(num*multi + 0.5)/multi
					end

					local function updateInputs(point)
						if point then
							currentPoint = point
							local rawT,rawV,rawE = point[2],point[1],point[3]
							timeBox.Text = round(rawT,(rawT < 0.01 and 5) or (rawT < 0.1 and 4) or 3)
							valueBox.Text = round(rawV,(rawV < 0.01 and 5) or (rawV < 0.1 and 4) or (rawV < 1 and 3) or 2)
							envelopeBox.Text = round(rawE,(rawE < 0.01 and 5) or (rawE < 0.1 and 4) or (rawV < 1 and 3) or 2)

							local envelopeDistance = numberLine.AbsoluteSize.Y*(point[3]/10)
							envelopeDragTop.Position = UDim2.new(0,point[4].Position.X.Offset-1,0,point[4].Position.Y.Offset-envelopeDistance-17)
							envelopeDragTop.Visible = true
							envelopeDragBottom.Position = UDim2.new(0,point[4].Position.X.Offset-1,0,point[4].Position.Y.Offset+envelopeDistance+2)
							envelopeDragBottom.Visible = true
						end
					end

					envelopeDragTop.InputBegan:Connect(function(input)
						if (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) or not currentPoint or Lib.CheckMouseInGui(currentPoint[4].Select) then return end

						local mouseEvent, releaseEvent
						local maxSize = numberLine.AbsoluteSize.Y
						local mouseDelta = math.abs(envelopeDragTop.AbsolutePosition.Y - mouse.Y)

						envelopeDragTop.Line.Position = UDim2.new(0, 2, 0, 0)
						envelopeDragTop.Line.Size = UDim2.new(0, 3, 0, 20)

						releaseEvent = user.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
							mouseEvent:Disconnect()
							releaseEvent:Disconnect()
							envelopeDragTop.Line.Position = UDim2.new(0, 3, 0, 0)
							envelopeDragTop.Line.Size = UDim2.new(0, 1, 0, 20)
						end)

						mouseEvent = user.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
								local topDiff = (currentPoint[4].AbsolutePosition.Y + 2) - (mouse.Y - mouseDelta) - 19
								local newEnvelope = 10 * (math.max(topDiff, 0) / maxSize)
								local maxEnvelope = math.min(currentPoint[1], 10 - currentPoint[1])
								currentPoint[3] = math.min(newEnvelope, maxEnvelope)
								newMt:Redraw()
								buildSequence()
								updateInputs(currentPoint)
							end
						end)
					end)

					envelopeDragBottom.InputBegan:Connect(function(input)
						if (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) or not currentPoint or Lib.CheckMouseInGui(currentPoint[4].Select) then return end

						local mouseEvent, releaseEvent
						local maxSize = numberLine.AbsoluteSize.Y
						local mouseDelta = math.abs(envelopeDragBottom.AbsolutePosition.Y - mouse.Y)

						envelopeDragBottom.Line.Position = UDim2.new(0, 2, 0, 0)
						envelopeDragBottom.Line.Size = UDim2.new(0, 3, 0, 20)

						releaseEvent = user.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
							mouseEvent:Disconnect()
							releaseEvent:Disconnect()
							envelopeDragBottom.Line.Position = UDim2.new(0, 3, 0, 0)
							envelopeDragBottom.Line.Size = UDim2.new(0, 1, 0, 20)
						end)

						mouseEvent = user.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
								local bottomDiff = (mouse.Y + (20 - mouseDelta)) - (currentPoint[4].AbsolutePosition.Y + 2) - 19
								local newEnvelope = 10 * (math.max(bottomDiff, 0) / maxSize)
								local maxEnvelope = math.min(currentPoint[1], 10 - currentPoint[1])
								currentPoint[3] = math.min(newEnvelope, maxEnvelope)
								newMt:Redraw()
								buildSequence()
								updateInputs(currentPoint)
							end
						end)
					end)

					local function placePoint(point)
						local newPoint = Instance.new("Frame")
						newPoint.Name = "Point"
						newPoint.BorderSizePixel = 0
						newPoint.Size = UDim2.new(0,5,0,5)
						newPoint.Position = UDim2.new(0,math.floor((numberLine.AbsoluteSize.X-1) * point[2])-2,0,numberLine.AbsoluteSize.Y*(10-point[1])/10-2)
						newPoint.BackgroundColor3 = Color3.new(0,0,0)

						local newSelect = Instance.new("Frame")
						newSelect.Name = "Select"
						newSelect.BackgroundTransparency = 1
						newSelect.BackgroundColor3 = Color3.new(199/255,44/255,28/255)
						newSelect.Position = UDim2.new(0,-2,0,-2)
						newSelect.Size = UDim2.new(0,9,0,9)
						newSelect.Parent = newPoint

						newPoint.Parent = numberLine


						newSelect.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
								for i, v in pairs(points) do 
									v[4].Select.BackgroundTransparency = 1 
								end

								newSelect.BackgroundTransparency = 0
								updateInputs(point)
							end

							if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not currentlySelected then
								currentPoint = point
								local mouseEvent, releaseEvent
								currentlySelected = true
								newSelect.BackgroundColor3 = Color3.new(249/255, 191/255, 59/255)

								local oldEnvelope = point[3]

								releaseEvent = user.InputEnded:Connect(function(input)
									if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then	return end

									mouseEvent:Disconnect()
									releaseEvent:Disconnect()
									currentlySelected = nil
									newSelect.BackgroundColor3 = Color3.new(199/255, 44/255, 28/255)
								end)

								mouseEvent = user.InputChanged:Connect(function(input)
									if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
										local maxX = numberLine.AbsoluteSize.X - 1
										local relativeX = (input.Position.X - numberLine.AbsolutePosition.X)
										if relativeX < 0 then relativeX = 0 end
										if relativeX > maxX then relativeX = maxX end

										local maxY = numberLine.AbsoluteSize.Y - 1
										local relativeY = (input.Position.Y - numberLine.AbsolutePosition.Y)
										if relativeY < 0 then relativeY = 0 end
										if relativeY > maxY then relativeY = maxY end

										if point ~= beginPoint and point ~= endPoint then
											point[2] = relativeX / maxX
										end

										point[1] = 10 - (relativeY / maxY) * 10
										local maxEnvelope = math.min(point[1], 10 - point[1])
										point[3] = math.min(oldEnvelope, maxEnvelope)
										newMt:Redraw()
										updateInputs(point)

										for i, v in pairs(points) do 
											v[4].Select.BackgroundTransparency = 1 
										end

										newSelect.BackgroundTransparency = 0
										buildSequence()
									end
								end)
							end
						end)

						return newPoint
					end

					local function placePoints()
						for i,v in pairs(points) do
							v[4] = placePoint(v)
						end
					end

					local function redraw(self)
						local numberLineSize = numberLine.AbsoluteSize
						table.sort(points,function(a,b) return a[2] < b[2] end)
						for i,v in pairs(points) do
							v[4].Position = UDim2.new(0,math.floor((numberLineSize.X-1) * v[2])-2,0,(numberLineSize.Y-1)*(10-v[1])/10-2)
						end
						lines[1].Size = UDim2.new(0,1,0,0)
						for i = 1,#points-1 do
							local fromPoint = points[i]
							local toPoint = points[i+1]
							local deltaY = toPoint[4].Position.Y.Offset-fromPoint[4].Position.Y.Offset
							local deltaX = toPoint[4].Position.X.Offset-fromPoint[4].Position.X.Offset
							local slope = deltaY/deltaX

							local fromEnvelope = fromPoint[3]
							local nextEnvelope = toPoint[3]

							local currentRise = math.abs(slope)
							local totalRise = 0
							local maxRise = math.abs(toPoint[4].Position.Y.Offset-fromPoint[4].Position.Y.Offset)

							for lineCount = math.min(fromPoint[4].Position.X.Offset+1,toPoint[4].Position.X.Offset),toPoint[4].Position.X.Offset do
								if deltaX == 0 and deltaY == 0 then return end
								local riseNow = math.floor(currentRise)
								local line = lines[lineCount+3]
								if line then
									if totalRise+riseNow > maxRise then riseNow = maxRise-totalRise end
									if math.sign(slope) == -1 then
										line.Position = UDim2.new(0,lineCount+2,0,fromPoint[4].Position.Y.Offset + -(totalRise+riseNow)+2)
									else
										line.Position = UDim2.new(0,lineCount+2,0,fromPoint[4].Position.Y.Offset + totalRise+2)
									end
									line.Size = UDim2.new(0,1,0,math.max(riseNow,1))
								end
								totalRise = totalRise + riseNow
								currentRise = currentRise - riseNow + math.abs(slope)

								local envPercent = (lineCount-fromPoint[4].Position.X.Offset)/(toPoint[4].Position.X.Offset-fromPoint[4].Position.X.Offset)
								local envLerp = fromEnvelope+(nextEnvelope-fromEnvelope)*envPercent
								local relativeSize = (envLerp/10)*numberLineSize.Y						

								local line = eLines[lineCount + 3]
								if line then
									line.Position = UDim2.new(0,lineCount+2,0,lines[lineCount+3].Position.Y.Offset-math.floor(relativeSize))
									line.Size = UDim2.new(0,1,0,math.floor(relativeSize*2))
								end
							end
						end
					end
					newMt.Redraw = redraw



					local function loadSequence(self,seq)
						resetSequence = seq
						for i,v in pairs(points) do if v[4] then v[4]:Destroy() end end
						points = {}
						for i,v in pairs(seq.Keypoints) do
							local maxEnvelope = math.min(v.Value,10-v.Value)
							local newPoint = {v.Value,v.Time,math.min(v.Envelope,maxEnvelope)}
							newPoint[4] = placePoint(newPoint)
							table.insert(points,newPoint)
						end
						beginPoint = points[1]
						endPoint = points[#points]
						currentlySelected = nil
						redraw()
						envelopeDragTop.Visible = false
						envelopeDragBottom.Visible = false
					end
					newMt.SetSequence = loadSequence

					timeBox.FocusLost:Connect(function()
						local point = currentPoint
						local num = tonumber(timeBox.Text)
						if point and num and point ~= beginPoint and point ~= endPoint then
							num = math.clamp(num,0,1)
							point[2] = num
							redraw()
							buildSequence()
							updateInputs(point)
						end
					end)

					valueBox.FocusLost:Connect(function()
						local point = currentPoint
						local num = tonumber(valueBox.Text)
						if point and num then
							local oldEnvelope = point[3]
							num = math.clamp(num,0,10)
							point[1] = num
							local maxEnvelope = math.min(point[1],10-point[1])
							point[3] = math.min(oldEnvelope,maxEnvelope)
							redraw()
							buildSequence()
							updateInputs(point)
						end
					end)

					envelopeBox.FocusLost:Connect(function()
						local point = currentPoint
						local num = tonumber(envelopeBox.Text)
						if point and num then
							num = math.clamp(num,0,5)
							local maxEnvelope = math.min(point[1],10-point[1])
							point[3] = math.min(num,maxEnvelope)
							redraw()
							buildSequence()
							updateInputs(point)
						end
					end)

					local function buttonAnimations(button,inverse)
						button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then button.BackgroundTransparency = (inverse and 0.5 or 0.4) end end)
						button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then button.BackgroundTransparency = (inverse and 1 or 0) end end)
					end

					numberLine.InputBegan:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and #points < 20 then

							if Lib.CheckMouseInGui(envelopeDragTop) or Lib.CheckMouseInGui(envelopeDragBottom) then return end

							for i, v in pairs(points) do
								if Lib.CheckMouseInGui(v[4].Select) then
									return
								end
							end

							local maxX = numberLine.AbsoluteSize.X - 1
							local relativeX = (input.Position.X - numberLine.AbsolutePosition.X)
							if relativeX < 0 then relativeX = 0 end
							if relativeX > maxX then relativeX = maxX end

							local maxY = numberLine.AbsoluteSize.Y - 1
							local relativeY = (input.Position.Y - numberLine.AbsolutePosition.Y)
							if relativeY < 0 then relativeY = 0 end
							if relativeY > maxY then relativeY = maxY end

							local raw = relativeX / maxX
							local newPoint = {10 - (relativeY / maxY) * 10, raw, 0}
							newPoint[4] = placePoint(newPoint)
							table.insert(points, newPoint)
							redraw()
							buildSequence()
						end
					end)

					deleteButton.MouseButton1Click:Connect(function()
						if currentPoint and currentPoint ~= beginPoint and currentPoint ~= endPoint then
							for i,v in pairs(points) do
								if v == currentPoint then
									v[4]:Destroy()
									table.remove(points,i)
									break
								end
							end
							currentlySelected = nil
							redraw()
							buildSequence()
							updateInputs(points[1])
						end
					end)

					resetButton.MouseButton1Click:Connect(function()
						if resetSequence then
							newMt:SetSequence(resetSequence)
							buildSequence()
						end
					end)

					closeButton.MouseButton1Click:Connect(function()
						window:Close()
					end)

					buttonAnimations(deleteButton)
					buttonAnimations(resetButton)
					buttonAnimations(closeButton)

					placePoints()
					redraw()

					newMt.Show = function(self)
						window:Show()
					end

					return newMt
				end

				return {new = new}
			end)()

			Lib.ColorSequenceEditor = (function() 
				local function new()
					local newMt = setmetatable({},{})
					newMt.OnSelect = Lib.Signal.new()
					newMt.OnCancel = Lib.Signal.new()
					newMt.OnPreview = Lib.Signal.new()
					newMt.OnPickColor = Lib.Signal.new()

					local guiContents = create({
						{1,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Content",Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),}},
						{2,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="ColorLine",Parent={1},Position=UDim2.new(0,10,0,5),Size=UDim2.new(1,-20,0,70),}},
						{3,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Name="Gradient",Parent={2},Size=UDim2.new(1,0,1,0),}},
						{4,"UIGradient",{Parent={3},}},
						{5,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Name="Arrows",Parent={1},Position=UDim2.new(0,1,0,73),Size=UDim2.new(1,-2,0,16),}},
						{6,"Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.5,BorderSizePixel=0,Name="Cursor",Parent={1},Position=UDim2.new(0,10,0,0),Size=UDim2.new(0,1,0,80),}},
						{7,"Frame",{BackgroundColor3=Color3.new(0.14901961386204,0.14901961386204,0.14901961386204),BorderColor3=Color3.new(0.12549020349979,0.12549020349979,0.12549020349979),Name="Time",Parent={1},Position=UDim2.new(0,40,0,95),Size=UDim2.new(0,100,0,20),}},
						{8,"TextBox",{BackgroundColor3=Color3.new(0.25098040699959,0.25098040699959,0.25098040699959),BackgroundTransparency=1,BorderColor3=Color3.new(0.37647062540054,0.37647062540054,0.37647062540054),ClipsDescendants=true,Font=3,Name="Input",Parent={7},Position=UDim2.new(0,2,0,0),Size=UDim2.new(0,98,0,20),Text="0",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=0,}},
						{9,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={7},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Time",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{10,"Frame",{BackgroundColor3=Color3.new(1,1,1),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),Name="ColorBox",Parent={1},Position=UDim2.new(0,220,0,95),Size=UDim2.new(0,20,0,20),}},
						{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={10},Position=UDim2.new(0,-40,0,0),Size=UDim2.new(0,34,1,0),Text="Color",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,TextXAlignment=1,}},
						{12,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="Close",Parent={1},Position=UDim2.new(1,-90,0,95),Size=UDim2.new(0,80,0,20),Text="Close",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
						{13,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="Reset",Parent={1},Position=UDim2.new(1,-180,0,95),Size=UDim2.new(0,80,0,20),Text="Reset",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
						{14,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderColor3=Color3.new(0.21568627655506,0.21568627655506,0.21568627655506),BorderSizePixel=0,Font=3,Name="Delete",Parent={1},Position=UDim2.new(0,280,0,95),Size=UDim2.new(0,80,0,20),Text="Delete",TextColor3=Color3.new(0.86274516582489,0.86274516582489,0.86274516582489),TextSize=14,}},
						{15,"Frame",{BackgroundTransparency=1,Name="Arrow",Parent={1},Size=UDim2.new(0,16,0,16),Visible=false,}},
						{16,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,8,0,3),Size=UDim2.new(0,1,0,2),}},
						{17,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,7,0,5),Size=UDim2.new(0,3,0,2),}},
						{18,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,6,0,7),Size=UDim2.new(0,5,0,2),}},
						{19,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,5,0,9),Size=UDim2.new(0,7,0,2),}},
						{20,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={15},Position=UDim2.new(0,4,0,11),Size=UDim2.new(0,9,0,2),}},
					})
					local window = Lib.Window.new()
					window.Resizable = false
					window:Resize(650,150)
					window:SetTitle("ColorSequence Editor")
					newMt.Window = window
					newMt.Gui = window.Gui
					for i,v in pairs(guiContents:GetChildren()) do
						v.Parent = window.GuiElems.Content
					end
					local gui = window.Gui
					local pickerGui = gui.Main
					local pickerTopBar = pickerGui.TopBar
					local pickerFrame = pickerGui.Content
					local colorLine = pickerFrame.ColorLine
					local gradient = colorLine.Gradient.UIGradient
					local arrowFrame = pickerFrame.Arrows
					local arrow = pickerFrame.Arrow
					local cursor = pickerFrame.Cursor
					local timeBox = pickerFrame.Time.Input
					local colorBox = pickerFrame.ColorBox
					local deleteButton = pickerFrame.Delete
					local resetButton = pickerFrame.Reset
					local closeButton = pickerFrame.Close
					local topClose = pickerTopBar.Close

					local user = service.UserInputService
					local mouse = service.Players.LocalPlayer:GetMouse()

					local colors = {{Color3.new(1,0,1),0},{Color3.new(0.2,0.9,0.2),0.2},{Color3.new(0.4,0.5,0.9),0.7},{Color3.new(0.6,1,1),1}}
					local resetSequence = nil

					local beginPoint = colors[1]
					local endPoint = colors[#colors]

					local currentlySelected = nil
					local currentPoint = nil

					local sequenceLine = Instance.new("Frame")
					sequenceLine.BorderSizePixel = 0
					sequenceLine.Size = UDim2.new(0,1,1,0)

					newMt.Sequence = ColorSequence.new(Color3.new(1,1,1))
					local function buildSequence(noupdate)
						local newPoints = {}
						table.sort(colors,function(a,b) return a[2] < b[2] end)
						for i,v in pairs(colors) do
							table.insert(newPoints,ColorSequenceKeypoint.new(v[2],v[1]))
						end
						newMt.Sequence = ColorSequence.new(newPoints)
						if not noupdate then newMt.OnSelect:Fire(newMt.Sequence) end
					end

					local function round(num,places)
						local multi = 10^places
						return math.floor(num*multi + 0.5)/multi
					end

					local function updateInputs(point)
						if point then
							currentPoint = point
							local raw = point[2]
							timeBox.Text = round(raw,(raw < 0.01 and 5) or (raw < 0.1 and 4) or 3)
							colorBox.BackgroundColor3 = point[1]
						end
					end

					local function placeArrow(ind,point)
						local newArrow = arrow:Clone()
						newArrow.Position = UDim2.new(0,ind-1,0,0)
						newArrow.Visible = true
						newArrow.Parent = arrowFrame

						newArrow.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
								cursor.Visible = true
								cursor.Position = UDim2.new(0, 9 + newArrow.Position.X.Offset, 0, 0)
							end

							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								updateInputs(point)
								if point == beginPoint or point == endPoint or currentlySelected then return end

								local mouseEvent, releaseEvent
								currentlySelected = true

								releaseEvent = user.InputEnded:Connect(function(input)
									if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
									mouseEvent:Disconnect()
									releaseEvent:Disconnect()
									currentlySelected = nil
									cursor.Visible = false
								end)

								mouseEvent = user.InputChanged:Connect(function(input)
									if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
										local maxSize = colorLine.AbsoluteSize.X - 1
										local relativeX = (input.Position.X - colorLine.AbsolutePosition.X)
										if relativeX < 0 then relativeX = 0 end
										if relativeX > maxSize then relativeX = maxSize end
										local raw = relativeX / maxSize
										point[2] = relativeX / maxSize
										updateInputs(point)
										cursor.Visible = true
										cursor.Position = UDim2.new(0, 9 + newArrow.Position.X.Offset, 0, 0)
										buildSequence()
										newMt:Redraw()
									end
								end)
							end
						end)

						newArrow.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
								cursor.Visible = false
							end
						end)



						return newArrow
					end

					local function placeArrows()
						for i,v in pairs(colors) do
							v[3] = placeArrow(math.floor((colorLine.AbsoluteSize.X-1) * v[2]) + 1,v)
						end
					end

					local function redraw(self)
						gradient.Color = newMt.Sequence or ColorSequence.new(Color3.new(1,1,1))

						for i = 2,#colors do
							local nextColor = colors[i]
							local endPos = math.floor((colorLine.AbsoluteSize.X-1) * nextColor[2]) + 1
							nextColor[3].Position = UDim2.new(0,endPos,0,0)
						end		
					end
					newMt.Redraw = redraw

					local function loadSequence(self,seq)
						resetSequence = seq
						for i,v in pairs(colors) do if v[3] then v[3]:Destroy() end end
						colors = {}
						currentlySelected = nil
						for i,v in pairs(seq.Keypoints) do
							local newPoint = {v.Value,v.Time}
							newPoint[3] = placeArrow(v.Time,newPoint)
							table.insert(colors,newPoint)
						end
						beginPoint = colors[1]
						endPoint = colors[#colors]
						currentlySelected = nil
						updateInputs(colors[1])
						buildSequence(true)
						redraw()
					end
					newMt.SetSequence = loadSequence

					local function buttonAnimations(button,inverse)
						button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then button.BackgroundTransparency = (inverse and 0.5 or 0.4) end end)
						button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then button.BackgroundTransparency = (inverse and 1 or 0) end end)
					end

					colorLine.InputBegan:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and #colors < 20 then
							local maxSize = colorLine.AbsoluteSize.X - 1
							local relativeX = (input.Position.X - colorLine.AbsolutePosition.X)
							if relativeX < 0 then relativeX = 0 end
							if relativeX > maxSize then relativeX = maxSize end

							local raw = relativeX / maxSize
							local fromColor = nil
							local toColor = nil
							for i, col in pairs(colors) do
								if col[2] >= raw then
									fromColor = colors[math.max(i - 1, 1)]
									toColor = colors[i]
									break
								end
							end
							local lerpColor = fromColor[1]:lerp(toColor[1], (raw - fromColor[2]) / (toColor[2] - fromColor[2]))
							local newPoint = {lerpColor, raw}
							newPoint[3] = placeArrow(newPoint[2], newPoint)
							table.insert(colors, newPoint)
							updateInputs(newPoint)
							buildSequence()
							redraw()
						end
					end)

					colorLine.InputChanged:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
							local maxSize = colorLine.AbsoluteSize.X - 1
							local relativeX = (input.Position.X - colorLine.AbsolutePosition.X)
							if relativeX < 0 then relativeX = 0 end
							if relativeX > maxSize then relativeX = maxSize end
							cursor.Visible = true
							cursor.Position = UDim2.new(0, 10 + relativeX, 0, 0)
						end
					end)

					colorLine.InputEnded:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
							local inArrow = false
							for i, v in pairs(colors) do
								if Lib.CheckMouseInGui(v[3]) then
									inArrow = v[3]
								end
							end
							cursor.Visible = inArrow and true or false
							if inArrow then cursor.Position = UDim2.new(0, 9 + inArrow.Position.X.Offset, 0, 0) end
						end
					end)

					timeBox:GetPropertyChangedSignal("Text"):Connect(function()
						local point = currentPoint
						local num = tonumber(timeBox.Text)
						if point and num and point ~= beginPoint and point ~= endPoint then
							num = math.clamp(num,0,1)
							point[2] = num
							buildSequence()
							redraw()
						end
					end)

					colorBox.InputBegan:Connect(function(input)
						if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
							local editor = newMt.ColorPicker
							if not editor then
								editor = Lib.ColorPicker.new()
								editor.Window:SetTitle("ColorSequence Color Picker")

								editor.OnSelect:Connect(function(col)
									if currentPoint then
										currentPoint[1] = col
									end
									buildSequence()
									redraw()
								end)

								newMt.ColorPicker = editor
							end

							editor.Window:ShowAndFocus()
						end
					end)

					deleteButton.MouseButton1Click:Connect(function()
						if currentPoint and currentPoint ~= beginPoint and currentPoint ~= endPoint then
							for i,v in pairs(colors) do
								if v == currentPoint then
									v[3]:Destroy()
									table.remove(colors,i)
									break
								end
							end
							currentlySelected = nil
							updateInputs(colors[1])
							buildSequence()
							redraw()
						end
					end)

					resetButton.MouseButton1Click:Connect(function()
						if resetSequence then
							newMt:SetSequence(resetSequence)
						end
					end)

					closeButton.MouseButton1Click:Connect(function()
						window:Close()
					end)

					topClose.MouseButton1Click:Connect(function()
						window:Close()
					end)

					buttonAnimations(deleteButton)
					buttonAnimations(resetButton)
					buttonAnimations(closeButton)

					placeArrows()
					redraw()

					newMt.Show = function(self)
						window:Show()
					end

					return newMt
				end

				return {new = new}
			end)()

			Lib.ViewportTextBox = (function()
				local textService = service.TextService

				local props = {
					OffsetX = 0,
					TextBox = PH,
					CursorPos = -1,
					Gui = PH,
					View = PH
				}
				local funcs = {}
				funcs.Update = function(self)
					local cursorPos = self.CursorPos or -1
					local text = self.TextBox.Text
					if text == "" then self.TextBox.Position = UDim2.new(0,0,0,0) return end
					if cursorPos == -1 then return end

					local cursorText = text:sub(1,cursorPos-1)
					local pos = nil
					local leftEnd = -self.TextBox.Position.X.Offset
					local rightEnd = leftEnd + self.View.AbsoluteSize.X

					local totalTextSize = textService:GetTextSize(text,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
					local cursorTextSize = textService:GetTextSize(cursorText,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X

					if cursorTextSize > rightEnd then
						pos = math.max(-1,cursorTextSize - self.View.AbsoluteSize.X + 2)
					elseif cursorTextSize < leftEnd then
						pos = math.max(-1,cursorTextSize-2)
					elseif totalTextSize < rightEnd then
						pos = math.max(-1,totalTextSize - self.View.AbsoluteSize.X + 2)
					end

					if pos then
						self.TextBox.Position = UDim2.new(0,-pos,0,0)
						self.TextBox.Size = UDim2.new(1,pos,1,0)
					end
				end

				funcs.GetText = function(self)
					return self.TextBox.Text
				end

				funcs.SetText = function(self,text)
					self.TextBox.Text = text
				end

				local mt = getGuiMT(props,funcs)

				local function convert(textbox)
					local obj = initObj(props,mt)

					local view = Instance.new("Frame")
					view.BackgroundTransparency = textbox.BackgroundTransparency
					view.BackgroundColor3 = textbox.BackgroundColor3
					view.BorderSizePixel = textbox.BorderSizePixel
					view.BorderColor3 = textbox.BorderColor3
					view.Position = textbox.Position
					view.Size = textbox.Size
					view.ClipsDescendants = true
					view.Name = textbox.Name
					textbox.BackgroundTransparency = 1
					textbox.Position = UDim2.new(0,0,0,0)
					textbox.Size = UDim2.new(1,0,1,0)
					textbox.TextXAlignment = Enum.TextXAlignment.Left
					textbox.Name = "Input"

					obj.TextBox = textbox
					obj.View = view
					obj.Gui = view

					textbox.Changed:Connect(function(prop)
						if prop == "Text" or prop == "CursorPosition" or prop == "AbsoluteSize" then
							local cursorPos = obj.TextBox.CursorPosition
							if cursorPos ~= -1 then obj.CursorPos = cursorPos end
							obj:Update()
						end
					end)

					obj:Update()

					view.Parent = textbox.Parent
					textbox.Parent = view

					return obj
				end

				local function new()
					local textBox = Instance.new("TextBox")
					textBox.Size = UDim2.new(0,100,0,20)
					textBox.BackgroundColor3 = Settings.Theme.TextBox
					textBox.BorderColor3 = Settings.Theme.Outline3
					textBox.ClearTextOnFocus = false
					textBox.TextColor3 = Settings.Theme.Text
					textBox.Font = Enum.Font.SourceSans
					textBox.TextSize = 14
					textBox.Text = ""
					return convert(textBox)
				end

				return {new = new, convert = convert}
			end)()

			Lib.Label = (function()
				local props,funcs = {},{}

				local mt = getGuiMT(props,funcs)

				local function new()
					local label = Instance.new("TextLabel")
					label.BackgroundTransparency = 1
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.TextColor3 = Settings.Theme.Text
					label.TextTransparency = 0.1
					label.Size = UDim2.new(0,100,0,20)
					label.Font = Enum.Font.SourceSans
					label.TextSize = 14

					local obj = setmetatable({
						Gui = label
					},mt)
					return obj
				end

				return {new = new}
			end)()

			Lib.Frame = (function()
				local props,funcs = {},{}

				local mt = getGuiMT(props,funcs)

				local function new()
					local fr = Instance.new("Frame")
					fr.BackgroundColor3 = Settings.Theme.Main1
					fr.BorderColor3 = Settings.Theme.Outline1
					fr.Size = UDim2.new(0,50,0,50)

					local obj = setmetatable({
						Gui = fr
					},mt)
					return obj
				end

				return {new = new}
			end)()

			Lib.Button = (function()
				local props = {
					Gui = PH,
					Anim = PH,
					Disabled = false,
					OnClick = SIGNAL,
					OnDown = SIGNAL,
					OnUp = SIGNAL,
					AllowedButtons = {1}
				}
				local funcs = {}
				local tableFind = table.find

				funcs.Trigger = function(self,event,button)
					if not self.Disabled and tableFind(self.AllowedButtons,button) then
						self["On"..event]:Fire(button)
					end
				end

				funcs.SetDisabled = function(self,dis)
					self.Disabled = dis

					if dis then
						self.Anim:Disable()
						self.Gui.TextTransparency = 0.5
					else
						self.Anim.Enable()
						self.Gui.TextTransparency = 0
					end
				end

				local mt = getGuiMT(props,funcs)

				local function new()
					local b = Instance.new("TextButton")
					b.AutoButtonColor = false
					b.TextColor3 = Settings.Theme.Text
					b.TextTransparency = 0.1
					b.Size = UDim2.new(0,100,0,20)
					b.Font = Enum.Font.SourceSans
					b.TextSize = 14
					b.BackgroundColor3 = Settings.Theme.Button
					b.BorderColor3 = Settings.Theme.Outline2

					local obj = initObj(props,mt)
					obj.Gui = b
					obj.Anim = Lib.ButtonAnim(b,{Mode = 2, StartColor = Settings.Theme.Button, HoverColor = Settings.Theme.ButtonHover, PressColor = Settings.Theme.ButtonPress, OutlineColor = Settings.Theme.Outline2})

					b.MouseButton1Click:Connect(function() obj:Trigger("Click",1) end)
					b.MouseButton1Down:Connect(function() obj:Trigger("Down",1) end)
					b.MouseButton1Up:Connect(function() obj:Trigger("Up",1) end)

					b.MouseButton2Click:Connect(function() obj:Trigger("Click",2) end)
					b.MouseButton2Down:Connect(function() obj:Trigger("Down",2) end)
					b.MouseButton2Up:Connect(function() obj:Trigger("Up",2) end)

					return obj
				end

				return {new = new}
			end)()

			Lib.DropDown = (function()
				local props = {
					Gui = PH,
					Anim = PH,
					Context = PH,
					Selected = PH,
					Disabled = false,
					CanBeEmpty = true,
					Options = {},
					GuiElems = {},
					OnSelect = SIGNAL
				}
				local funcs = {}

				funcs.Update = function(self)
					local options = self.Options

					if #options > 0 then
						if not self.Selected then
							if not self.CanBeEmpty then
								self.Selected = options[1]
								self.GuiElems.Label.Text = options[1]
							else
								self.GuiElems.Label.Text = "- Select -"
							end
						else
							self.GuiElems.Label.Text = self.Selected
						end
					else
						self.GuiElems.Label.Text = "- Select -"
					end
				end

				funcs.ShowOptions = function(self)
					local context = self.Context

					context.Width = self.Gui.AbsoluteSize.X
					context.ReverseYOffset = self.Gui.AbsoluteSize.Y
					context:Show(self.Gui.AbsolutePosition.X, self.Gui.AbsolutePosition.Y + context.ReverseYOffset)
				end

				funcs.SetOptions = function(self,opts)
					self.Options = opts

					local context = self.Context
					local options = self.Options
					context:Clear()

					local onClick = function(option) self.Selected = option self.OnSelect:Fire(option) self:Update() end

					if self.CanBeEmpty then
						context:Add({Name = "- Select -", function() self.Selected = nil self.OnSelect:Fire(nil) self:Update() end})
					end

					for i = 1,#options do
						context:Add({Name = options[i], OnClick = onClick})
					end

					self:Update()
				end

				funcs.SetSelected = function(self,opt)
					self.Selected = type(opt) == "number" and self.Options[opt] or opt
					self:Update()
				end

				local mt = getGuiMT(props,funcs)

				local function new()
					local f = Instance.new("TextButton")
					f.AutoButtonColor = false
					f.Text = ""
					f.Size = UDim2.new(0,100,0,20)
					f.BackgroundColor3 = Settings.Theme.TextBox
					f.BorderColor3 = Settings.Theme.Outline3

					local label = Lib.Label.new()
					label.Position = UDim2.new(0,2,0,0)
					label.Size = UDim2.new(1,-22,1,0)
					label.TextTruncate = Enum.TextTruncate.AtEnd
					label.Parent = f
					local arrow = create({
						{1,"Frame",{BackgroundTransparency=1,Name="EnumArrow",Position=UDim2.new(1,-16,0,2),Size=UDim2.new(0,16,0,16),}},
						{2,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,8,0,9),Size=UDim2.new(0,1,0,1),}},
						{3,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,7,0,8),Size=UDim2.new(0,3,0,1),}},
						{4,"Frame",{BackgroundColor3=Color3.new(0.86274510622025,0.86274510622025,0.86274510622025),BorderSizePixel=0,Parent={1},Position=UDim2.new(0,6,0,7),Size=UDim2.new(0,5,0,1),}},
					})
					arrow.Parent = f

					local obj = initObj(props,mt)
					obj.Gui = f
					obj.Anim = Lib.ButtonAnim(f,{Mode = 2, StartColor = Settings.Theme.TextBox, LerpTo = Settings.Theme.Button, LerpDelta = 0.15})
					obj.Context = Lib.ContextMenu.new()
					obj.Context.Iconless = true
					obj.Context.MaxHeight = 200
					obj.Selected = nil
					obj.GuiElems = {Label = label}
					f.MouseButton1Down:Connect(function() obj:ShowOptions() end)
					obj:Update()
					return obj
				end

				return {new = new}
			end)()

			Lib.ClickSystem = (function()
				local props = {
					LastItem = PH,
					OnDown = SIGNAL,
					OnRelease = SIGNAL,
					AllowedButtons = {1},
					Combo = 0,
					MaxCombo = 2,
					ComboTime = 0.5,
					Items = {},
					ItemCons = {},
					ClickId = -1,
					LastButton = ""
				}
				local funcs = {}
				local tostring = tostring

				local disconnect = function(con)
					local pos = table.find(con.Signal.Connections,con)
					if pos then table.remove(con.Signal.Connections,pos) end
				end

				funcs.Trigger = function(self, item, button, X, Y)
					if table.find(self.AllowedButtons, button) then
						if self.LastButton ~= button or self.LastItem ~= item or self.Combo == self.MaxCombo or tick() - self.ClickId > self.ComboTime then
							self.Combo = 0
							self.LastButton = button
							self.LastItem = item
						end

						self.Combo = self.Combo + 1
						self.ClickId = tick()

						task.spawn(function()
							if self.InputDown then
								self.InputDown = false
							else
								self.InputDown = tick()

								local Connection = item.MouseButton1Up:Once(function()
									self.InputDown = false
								end)

								while self.InputDown and not Explorer.Dragging do
									if (tick() - self.InputDown) >= 0.4 then
										self.InputDown = false
										self["OnRelease"]:Fire(item, self.Combo, 2, Vector2.new(X, Y))
										break
									end;task.wait()
								end
							end
						end)

						local release
						release = service.UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType["MouseButton" .. button] then
								release:Disconnect()
								if Lib.CheckMouseInGui(item) and self.LastButton == button and self.LastItem == item then
									self["OnRelease"]:Fire(item,self.Combo,button)
								end
							end
						end)

						self["OnDown"]:Fire(item,self.Combo,button)
					end
				end

				funcs.Add = function(self,item)
					if table.find(self.Items,item) then return end

					local cons = {}
					cons[1] = item.MouseButton1Down:Connect(function(X, Y) self:Trigger(item, 1, X, Y) end)
					cons[2] = item.MouseButton2Down:Connect(function(X, Y) self:Trigger(item, 2, X, Y) end)

					self.ItemCons[item] = cons
					self.Items[#self.Items+1] = item
				end

				funcs.Remove = function(self,item)
					local ind = table.find(self.Items,item)
					if not ind then return end

					for i,v in pairs(self.ItemCons[item]) do
						v:Disconnect()
					end
					self.ItemCons[item] = nil
					table.remove(self.Items,ind)
				end

				local mt = {__index = funcs}

				local function new()
					local obj = initObj(props,mt)

					return obj
				end

				return {new = new}
			end)()

			return Lib
		end

		return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
	end,
	Console = function()



		
		local Main,Lib,Apps,Settings 
		local Explorer, Properties, ScriptViewer, Notebook 
		local API,RMD,env,service,plr,create,createSimple 

		local function initDeps(data)
			Main = data.Main
			Lib = data.Lib
			Apps = data.Apps
			Settings = data.Settings

			API = data.API
			RMD = data.RMD
			env = data.env
			service = data.service
			plr = data.plr
			create = data.create
			createSimple = data.createSimple
		end

		local function initAfterMain()
			Explorer = Apps.Explorer
			Properties = Apps.Properties
			ScriptViewer = Apps.ScriptViewer
			Notebook = Apps.Notebook
		end

		local function main()
			local Console = {}

			local window,ConsoleFrame

			local OutputLimit = 500 


			
			local G2L = {};

			
			window = Lib.Window.new()
			window:SetTitle("Console")
			window:Resize(500,400)
			Console.Window = window

			
			ConsoleFrame = Instance.new("ImageButton", window.GuiElems.Content);
			ConsoleFrame["BorderSizePixel"] = 0;
			ConsoleFrame["AutoButtonColor"] = false;
			ConsoleFrame["BackgroundTransparency"] = 1;
			ConsoleFrame["BackgroundColor3"] = Color3.fromRGB(47, 47, 47);
			ConsoleFrame["Selectable"] = false;
			ConsoleFrame["Size"] = UDim2.new(1,0,1,0);
			ConsoleFrame["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			ConsoleFrame["Name"] = [[Console]];
			ConsoleFrame["Position"] = UDim2.new(0,0,0,0);


			
			G2L["3"] = Lib.Frame.new().Gui
			G2L["3"].Parent = ConsoleFrame
			G2L["3"]["BorderSizePixel"] = 0;
			G2L["3"]["BackgroundColor3"] = Color3.fromRGB(37, 37, 37);
			G2L["3"]["AnchorPoint"] = Vector2.new(0.5, 1);
			G2L["3"]["ClipsDescendants"] = true;
			G2L["3"]["Size"] = UDim2.new(1, -8, 0, 22);
			G2L["3"]["Position"] = UDim2.new(0.5, 0, 1, -5);
			G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["3"]["Name"] = [[CommandLine]];


			
			G2L["4"] = Instance.new("UIStroke", G2L["3"]);
			G2L["4"]["Transparency"] = 0.65;
			G2L["4"]["Thickness"] = 1.25;


			
			G2L["5"] = Instance.new("ScrollingFrame", G2L["3"]);
			G2L["5"]["Active"] = true;
			G2L["5"]["ScrollingDirection"] = Enum.ScrollingDirection.X;
			G2L["5"]["BorderSizePixel"] = 0;
			G2L["5"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
			G2L["5"]["ElasticBehavior"] = Enum.ElasticBehavior.Never;
			G2L["5"]["TopImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
			G2L["5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["5"]["HorizontalScrollBarInset"] = Enum.ScrollBarInset.Always;
			G2L["5"]["BottomImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
			G2L["5"]["AutomaticCanvasSize"] = Enum.AutomaticSize.X;
			G2L["5"]["Size"] = UDim2.new(1, 0, 1, 0);
			G2L["5"]["ScrollBarImageColor3"] = Color3.fromRGB(57, 57, 57);
			G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["5"]["ScrollBarThickness"] = 2;
			G2L["5"]["BackgroundTransparency"] = 1;

			
			G2L["6"] = Instance.new("TextBox", G2L["5"]);
			G2L["6"]["CursorPosition"] = -1;
			G2L["6"]["TextXAlignment"] = Enum.TextXAlignment.Left;
			G2L["6"]["PlaceholderColor3"] = Color3.fromRGB(211, 211, 211);
			G2L["6"]["BorderSizePixel"] = 0;
			G2L["6"]["TextSize"] = 13;
			G2L["6"]["TextColor3"] = Color3.fromRGB(211, 211, 211);
			G2L["6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["6"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
			G2L["6"]["AutomaticSize"] = Enum.AutomaticSize.X;
			G2L["6"]["ClearTextOnFocus"] = false;
			G2L["6"]["PlaceholderText"] = [[Run a command]];
			G2L["6"]["Size"] = UDim2.new(0, 246, 0, 22);
			G2L["6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["6"]["Text"] = [[]];
			G2L["6"]["BackgroundTransparency"] = 1;


			
			G2L["7"] = Instance.new("UIPadding", G2L["6"]);
			G2L["7"]["PaddingLeft"] = UDim.new(0, 7);


			
			G2L["8"] = Instance.new("TextLabel", G2L["5"]);
			G2L["8"]["Interactable"] = false;
			G2L["8"]["ZIndex"] = 2;
			G2L["8"]["BorderSizePixel"] = 0;
			G2L["8"]["TextSize"] = 13;
			G2L["8"]["TextXAlignment"] = Enum.TextXAlignment.Left;
			G2L["8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["8"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
			G2L["8"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["8"]["BackgroundTransparency"] = 1;
			G2L["8"]["RichText"] = true;
			G2L["8"]["Size"] = UDim2.new(0, 246, 0, 22);
			G2L["8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["8"]["Text"] = [[]];
			G2L["8"]["Selectable"] = true;
			G2L["8"]["AutomaticSize"] = Enum.AutomaticSize.X;
			G2L["8"]["Name"] = [[Highlight]];


			
			G2L["9"] = Instance.new("UIPadding", G2L["8"]);
			G2L["9"]["PaddingLeft"] = UDim.new(0, 7);

			G2L["backgroundOutput"] = Instance.new("Frame", ConsoleFrame);
			G2L["backgroundOutput"]["BorderSizePixel"] = 0;
			G2L["backgroundOutput"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 36);
			G2L["backgroundOutput"]["Name"] = [[BackgroundOutput]];
			G2L["backgroundOutput"]["AnchorPoint"] = Vector2.new(0, 0);
			G2L["backgroundOutput"]["Size"] = UDim2.new(1, -8, 1, -55);
			G2L["backgroundOutput"]["Position"] = UDim2.new(0, 4, 0, 23);
			G2L["backgroundOutput"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["backgroundOutput"]["ZIndex"] = 1;

			local scrollbar = Lib.ScrollBar.new()
			scrollbar.Gui.Parent = ConsoleFrame
			scrollbar.Gui.Size = UDim2.new(0, 16, 1, -55);
			scrollbar.Gui.Position = UDim2.new(1, -20,0, 23);
			scrollbar.Gui.Up.ZIndex = 3
			scrollbar.Gui.Down.ZIndex = 3

			
			G2L["a"] = Instance.new("ScrollingFrame", ConsoleFrame);
			G2L["a"]["Active"] = true;
			G2L["a"]["BorderSizePixel"] = 0;
			G2L["a"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
			G2L["a"]["TopImage"] = '';
			G2L["a"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 36);
			G2L["a"].BackgroundTransparency = 1
			G2L["a"]["Name"] = [[Output]];
			G2L["a"]["ScrollBarImageTransparency"] = 0;
			G2L["a"]["BottomImage"] = '';
			G2L["a"]["AnchorPoint"] = Vector2.new(0, 0);
			G2L["a"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;
			G2L["a"]["Size"] = UDim2.new(1, -8, 1, -55);
			G2L["a"]["Position"] = UDim2.new(0, 4, 0, 23);
			G2L["a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["a"].ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
			G2L["a"]["ScrollBarThickness"] = 16;
			G2L["a"]["ZIndex"] = 1;

			G2L["a"]:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
				if G2L["a"].AbsoluteCanvasSize ~= G2L["a"].AbsoluteWindowSize then
					scrollbar.Gui.Visible = true
				else
					scrollbar.Gui.Visible = false
				end
			end)

			
			G2L["b"] = Instance.new("UIListLayout", G2L["a"]);
			G2L["b"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


			
			G2L["c"] = Instance.new("UIStroke", G2L["a"]);
			G2L["c"]["Transparency"] = 0.7;
			G2L["c"]["Thickness"] = 1.25;
			G2L["c"]["Color"] = Color3.fromRGB(12, 12, 12);


			
			G2L["d"] = Instance.new("NumberValue", G2L["a"]);
			G2L["d"]["Name"] = [[OutputTextSize]];
			G2L["d"]["Value"] = 15;


			
			G2L["e"] = Instance.new("NumberValue", G2L["a"]);
			G2L["e"]["Name"] = [[OutputLimit]];
			G2L["e"]["Value"] = OutputLimit;


			
			G2L["f"] = Instance.new("UIPadding", G2L["a"]);
			G2L["f"]["PaddingTop"] = UDim.new(0, 2);


			
			G2L["10"] = Instance.new("Frame", ConsoleFrame);
			G2L["10"]["BorderSizePixel"] = 0;
			G2L["10"]["BackgroundColor3"] = Color3.fromRGB(37, 37, 37);
			G2L["10"]["ClipsDescendants"] = true;
			G2L["10"]["Size"] = UDim2.new(0, 37, 0, 15);
			G2L["10"]["Position"] = UDim2.new(0, 4, 0, 4);
			G2L["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["10"]["Name"] = [[TextSizeBox]];


			
			G2L["11"] = Instance.new("TextBox", G2L["10"]);
			G2L["11"]["PlaceholderColor3"] = Color3.fromRGB(108, 108, 108);
			G2L["11"]["BorderSizePixel"] = 0;
			G2L["11"]["TextWrapped"] = true;
			G2L["11"]["TextSize"] = 15;
			G2L["11"]["TextColor3"] = Color3.fromRGB(211, 211, 211);
			G2L["11"]["TextScaled"] = true;
			G2L["11"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["11"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
			G2L["11"]["PlaceholderText"] = [[Size]];
			G2L["11"]["Size"] = UDim2.new(1, 0, 1, 0);
			G2L["11"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["11"]["Text"] = [[]];
			G2L["11"]["BackgroundTransparency"] = 1;


			
			G2L["12"] = Instance.new("UIPadding", G2L["11"]);
			G2L["12"]["PaddingTop"] = UDim.new(0, 2);
			G2L["12"]["PaddingRight"] = UDim.new(0, 5);
			G2L["12"]["PaddingLeft"] = UDim.new(0, 5);
			G2L["12"]["PaddingBottom"] = UDim.new(0, 2);


			
			G2L["13"] = Instance.new("UIStroke", G2L["10"]);
			G2L["13"]["Transparency"] = 0.65;
			G2L["13"]["Thickness"] = 1.25;


			
			G2L["14"] = Instance.new("ImageButton", ConsoleFrame);
			G2L["14"]["BorderSizePixel"] = 0;
			G2L["14"]["BackgroundColor3"] = Color3.fromRGB(57, 57, 57);
			G2L["14"]["Size"] = UDim2.new(0, 37, 0, 15);
			G2L["14"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["14"]["Name"] = [[Clear]];
			G2L["14"]["Position"] = UDim2.new(1, -42, 0, 4);


			
			G2L["15"] = Instance.new("TextLabel", G2L["14"]);
			G2L["15"]["TextWrapped"] = true;
			G2L["15"]["Interactable"] = false;
			G2L["15"]["BorderSizePixel"] = 0;
			G2L["15"]["TextSize"] = 20;
			G2L["15"]["TextScaled"] = true;
			G2L["15"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["15"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
			G2L["15"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["15"]["BackgroundTransparency"] = 1;
			G2L["15"]["Size"] = UDim2.new(1, 0, 1, 0);
			G2L["15"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["15"]["Text"] = [[Clear]];


			
			G2L["16"] = Instance.new("UIPadding", G2L["14"]);
			G2L["16"]["PaddingTop"] = UDim.new(0, 1);
			G2L["16"]["PaddingBottom"] = UDim.new(0, 1);


			
			G2L["17"] = Instance.new("TextBox", ConsoleFrame);
			G2L["17"]["Visible"] = false;
			G2L["17"]["Active"] = false;
			G2L["17"]["Name"] = [[OutputTemplate]];
			G2L["17"]["TextXAlignment"] = Enum.TextXAlignment.Left;
			G2L["17"]["BorderSizePixel"] = 0;
			G2L["17"]["TextEditable"] = false;
			G2L["17"]["TextWrapped"] = true;
			G2L["17"]["TextSize"] = 15;
			G2L["17"]["TextColor3"] = Color3.fromRGB(171, 171, 171);
			G2L["17"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["17"]["RichText"] = true;
			G2L["17"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
			G2L["17"]["AutomaticSize"] = Enum.AutomaticSize.Y;
			G2L["17"]["Selectable"] = false;
			G2L["17"]["ClearTextOnFocus"] = false;
			G2L["17"]["Size"] = UDim2.new(1, 0, 0, 1);
			G2L["17"]["Position"] = UDim2.new(0, 20, 0, 0);
			G2L["17"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["17"]["Text"] = [[(timestamp) <font color="rgb(255, 255, 255)">Output</font>]];
			G2L["17"]["BackgroundTransparency"] = 1;


			
			G2L["18"] = Instance.new("UIPadding", G2L["17"]);
			G2L["18"]["PaddingRight"] = UDim.new(0, 6);
			G2L["18"]["PaddingLeft"] = UDim.new(0, 6);


			
			G2L["19"] = Instance.new("ImageButton", ConsoleFrame);
			G2L["19"]["BorderSizePixel"] = 0;
			G2L["19"]["BackgroundColor3"] = Color3.fromRGB(57, 57, 57);
			G2L["19"]["Size"] = UDim2.new(0, 60, 0, 15);
			G2L["19"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["19"]["Name"] = [[CtrlScroll]];
			G2L["19"]["Position"] = UDim2.new(0, 46, 0, 4);


			
			G2L["1a"] = Instance.new("TextLabel", G2L["19"]);
			G2L["1a"]["TextWrapped"] = true;
			G2L["1a"]["Interactable"] = false;
			G2L["1a"]["BorderSizePixel"] = 0;
			G2L["1a"]["TextSize"] = 20;
			G2L["1a"]["TextScaled"] = true;
			G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["1a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
			G2L["1a"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["1a"]["BackgroundTransparency"] = 1;
			G2L["1a"]["Size"] = UDim2.new(1, 0, 1, 0);
			G2L["1a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["1a"]["Text"] = [[Ctrl Scroll]];


			
			G2L["1b"] = Instance.new("UIPadding", G2L["19"]);
			G2L["1b"]["PaddingTop"] = UDim.new(0, 1);
			G2L["1b"]["PaddingBottom"] = UDim.new(0, 1);

			
			G2L["20"] = Instance.new("ImageButton", ConsoleFrame);
			G2L["20"]["BorderSizePixel"] = 0;
			G2L["20"]["BackgroundColor3"] = Color3.fromRGB(57, 57, 57);
			G2L["20"]["Size"] = UDim2.new(0, 60, 0, 15);
			G2L["20"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["20"]["Name"] = [[AutoScroll]];
			G2L["20"]["Position"] = UDim2.new(0, 110, 0, 4);


			
			G2L["1e"] = Instance.new("TextLabel", G2L["20"]);
			G2L["1e"]["TextWrapped"] = true;
			G2L["1e"]["Interactable"] = false;
			G2L["1e"]["BorderSizePixel"] = 0;
			G2L["1e"]["TextSize"] = 20;
			G2L["1e"]["TextScaled"] = true;
			G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["1e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
			G2L["1e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
			G2L["1e"]["BackgroundTransparency"] = 1;
			G2L["1e"]["Size"] = UDim2.new(1, 0, 1, 0);
			G2L["1e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
			G2L["1e"]["Text"] = [[Auto Scroll]];


			
			G2L["1f"] = Instance.new("UIPadding", G2L["20"]);
			G2L["1f"]["PaddingTop"] = UDim.new(0, 1);
			G2L["1f"]["PaddingBottom"] = UDim.new(0, 1);


			
			G2L["1c"] = Instance.new("LocalScript", G2L["1"]);
			G2L["1c"]["Name"] = [[ConsoleHandler]];


			
			G2L["1d"] = Instance.new("ModuleScript", G2L["1c"]);
			G2L["1d"]["Name"] = [[SyntaxHighlighter]];


			
			local G2L_REQUIRE = require;
			local G2L_MODULES = {};
			local function require(Module)
				local ModuleState = G2L_MODULES[Module];
				if ModuleState then
					if not ModuleState.Required then
						ModuleState.Required = true;
						ModuleState.Value = ModuleState.Closure();
					end
					return ModuleState.Value;
				end;
				return G2L_REQUIRE(Module);
			end

			G2L_MODULES[G2L["1d"]] = {
				Closure = function()
					local script = G2L["1d"];local highlighter = {}
					local keywords = {
						lua = {
							"and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", "while", "do", "for", "in", "end",
							"local", "return", "function", "export"
						},
						rbx = {
							"game", "workspace", "script", "math", "string", "table", "task", "wait", "select", "next", "Enum",
							"error", "warn", "tick", "assert", "shared", "loadstring", "tonumber", "tostring", "type",
							"typeof", "unpack", "print", "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor",
							"OverlapParams", "RaycastParams", "Axes", "Random", "Region3", "Rect", "TweenInfo",
							"collectgarbage", "not", "utf8", "pcall", "xpcall", "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs"
						},
						exploit = {
							"hookmetamethod", "hookfunction", "getgc", "filtergc", "Drawing", "getgenv", "getsenv", "getrenv", "getfenv", "setfenv",
							"decompile", "saveinstance", "getrawmetatable", "setrawmetatable", "checkcaller", "cloneref", "clonefunction",
							"iscclosure", "islclosure", "isexecutorclosure", "newcclosure", "getfunctionhash", "crypt", "writefile", "appendfile", "loadfile", "readfile", "listfiles",
							"makefolder", "isfolder", "isfile", "delfile", "delfolder", "getcustomasset", "fireclickdetector", "firetouchinterest", "fireproximityprompt"
						},
						operators = {
							"#", "+", "-", "*", "%", "/", "^", "=", "~", "=", "<", ">", ",", ".", "(", ")", "{", "}", "[", "]", ";", ":"
						}
					}

					local colors = {
						numbers = Color3.fromRGB(255, 198, 0),
						boolean = Color3.fromRGB(255, 198, 0),
						operator = Color3.fromRGB(204, 204, 204),
						lua = Color3.fromRGB(132, 214, 247),
						exploit = Color3.fromRGB(171, 84, 247),
						rbx = Color3.fromRGB(248, 109, 124),
						str = Color3.fromRGB(173, 241, 132),
						comment = Color3.fromRGB(102, 102, 102),
						null = Color3.fromRGB(255, 198, 0),
						call = Color3.fromRGB(253, 251, 172),
						self_call = Color3.fromRGB(253, 251, 172),
						local_color = Color3.fromRGB(248, 109, 115),
						function_color = Color3.fromRGB(248, 109, 115),
						self_color = Color3.fromRGB(248, 109, 115),
						local_property = Color3.fromRGB(97, 161, 241),
					}

					local function createKeywordSet(keywords)
						local keywordSet = {}
						for _, keyword in ipairs(keywords) do
							keywordSet[keyword] = true
						end
						return keywordSet
					end

					local luaSet = createKeywordSet(keywords.lua)
					local exploitSet = createKeywordSet(keywords.exploit)
					local rbxSet = createKeywordSet(keywords.rbx)
					local operatorsSet = createKeywordSet(keywords.operators)

					local function getHighlight(tokens, index)
						local token = tokens[index]

						if colors[token .. "_color"] then
							return colors[token .. "_color"]
						end

						if tonumber(token) then
							return colors.numbers
						elseif token == "nil" then
							return colors.null
						elseif token:sub(1, 2) == "--" then
							return colors.comment
						elseif operatorsSet[token] then
							return colors.operator
						elseif luaSet[token] then
							return colors.rbx
						elseif rbxSet[token] then
							return colors.lua
						elseif exploitSet[token] then
							return colors.exploit
						elseif token:sub(1, 1) == "\"" or token:sub(1, 1) == "\'" then
							return colors.str
						elseif token == "true" or token == "false" then
							return colors.boolean
						end

						if tokens[index + 1] == "(" then
							if tokens[index - 1] == ":" then
								return colors.self_call
							end

							return colors.call
						end

						if tokens[index - 1] == "." then
							if tokens[index - 2] == "Enum" then
								return colors.rbx
							end

							return colors.local_property
						end
					end

					function highlighter.run(source)
						local tokens = {}
						local currentToken = ""

						local inString = false
						local inComment = false
						local commentPersist = false

						for i = 1, #source do
							local character = source:sub(i, i)

							if inComment then
								if character == "\n" and not commentPersist then
									table.insert(tokens, currentToken)
									table.insert(tokens, character)
									currentToken = ""

									inComment = false
								elseif source:sub(i - 1, i) == "]]" and commentPersist then
									currentToken ..= "]"

									table.insert(tokens, currentToken)
									currentToken = ""

									inComment = false
									commentPersist = false
								else
									currentToken = currentToken .. character
								end
							elseif inString then
								if character == inString and source:sub(i-1, i-1) ~= "\\" or character == "\n" then
									currentToken = currentToken .. character
									inString = false
								else
									currentToken = currentToken .. character
								end
							else
								if source:sub(i, i + 1) == "--" then
									table.insert(tokens, currentToken)
									currentToken = "-"
									inComment = true
									commentPersist = source:sub(i + 2, i + 3) == "[["
								elseif character == "\"" or character == "\'" then
									table.insert(tokens, currentToken)
									currentToken = character
									inString = character
								elseif operatorsSet[character] then
									table.insert(tokens, currentToken)
									table.insert(tokens, character)
									currentToken = ""
								elseif character:match("[%w_]") then
									currentToken = currentToken .. character
								else
									table.insert(tokens, currentToken)
									table.insert(tokens, character)
									currentToken = ""
								end
							end
						end

						table.insert(tokens, currentToken)

						local highlighted = {}

						for i, token in ipairs(tokens) do
							local highlight = getHighlight(tokens, i)

							if highlight then
								local syntax = string.format("<font color = \"#%s\">%s</font>", highlight:ToHex(), token:gsub("<", "&lt;"):gsub(">", "&gt;"))

								table.insert(highlighted, syntax)
							else
								table.insert(highlighted, token)
							end
						end

						return table.concat(highlighted)
					end

					return highlighter
				end;
			};

			Console.Init = function()
				

				local CtrlScroll = false
				local AutoScroll = false

				local LogService = game:GetService("LogService")
				local Players = game:GetService("Players")
				local LocalPlayer = Players.LocalPlayer
				local Mouse = LocalPlayer:GetMouse()
				local UserInputService = game:GetService("UserInputService")
				local RunService = game:GetService("RunService")

				local Console = ConsoleFrame
				local SyntaxHighlightingModule = require(G2L["1c"].SyntaxHighlighter)
				local OutputTextSize = Console.Output.OutputTextSize

				local function Tween(obj, info, prop)
					local tween = game:GetService("TweenService"):Create(obj, info, prop)
					tween:Play()
					return tween
				end



				

				if CtrlScroll == true then
					Console.CtrlScroll.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
				elseif CtrlScroll == false then
					Console.CtrlScroll.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
				end
				Console.CtrlScroll.MouseButton1Click:Connect(function()
					CtrlScroll = not CtrlScroll
					if CtrlScroll == true then
						Console.CtrlScroll.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
					elseif CtrlScroll == false then
						Console.CtrlScroll.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
					end
				end)

				local IsHoldingCTRL = false
				UserInputService.InputBegan:Connect(function(input, gameproc)
					if not gameproc then
						if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
							IsHoldingCTRL = true
						end
					end
				end)
				UserInputService.InputEnded:Connect(function(input, gameproc)
					if not gameproc then
						if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
							IsHoldingCTRL = false
						end
					end
				end)

				if AutoScroll == true then
					Console.AutoScroll.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
				elseif AutoScroll == false then
					Console.AutoScroll.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
				end
				Console.AutoScroll.MouseButton1Click:Connect(function()
					AutoScroll = not AutoScroll
					if AutoScroll == true then
						Console.AutoScroll.BackgroundColor3 = Color3.fromRGB(11, 90, 175)
						Console.Output.CanvasPosition = Vector2.new(0, 9e9)
					elseif AutoScroll == false then
						Console.AutoScroll.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
					end
				end)

				
				local displayedOutput = {}
				local OutputLimit = Console.Output.OutputLimit

				Console.TextSizeBox.TextBox.Text = tostring(OutputTextSize.Value)

				Console.TextSizeBox.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
					local tonum = tonumber(Console.TextSizeBox.TextBox.Text)
					if tonum then
						OutputTextSize.Value = tonum
					end
				end)
				OutputTextSize:GetPropertyChangedSignal("Value"):Connect(function()
					Console.TextSizeBox.TextBox.Text = tostring(OutputTextSize.Value)
				end)

				local scrollConsoleInput
				Console.Output.MouseEnter:Connect(function()
					scrollConsoleInput = UserInputService.InputChanged:Connect(function(input)
						if CtrlScroll and input.UserInputType == Enum.UserInputType.MouseWheel and IsHoldingCTRL == true then
							Console.Output.ScrollingEnabled = false
							local newTextSize = OutputTextSize.Value + input.Position.Z
							if newTextSize >= 1 then
								OutputTextSize.Value = newTextSize
							end
						else
							Console.Output.ScrollingEnabled = true
						end
					end)
				end)
				Console.Output.MouseLeave:Connect(function()
					if scrollConsoleInput then
						scrollConsoleInput:Disconnect()
						scrollConsoleInput = nil
					end
				end)


				Console.Clear.MouseButton1Click:Connect(function()
					for _, log in pairs(Console.Output:GetChildren()) do
						if log:IsA("TextBox") then
							log:Destroy()
						end
					end
				end)

				local focussedOutput

				LogService.MessageOut:Connect(function(msg, msgtype)
					local formattedText = ""
					local unformattedText = ""
					local newOutputText = Console.OutputTemplate:Clone()
					table.insert(displayedOutput, newOutputText)

					if #displayedOutput > OutputLimit.Value then
						local oldest = table.remove(displayedOutput, 1)
						if oldest and typeof(oldest) == "Instance" then
							oldest:Destroy()
						end
					end

					unformattedText = os.date("%H:%M:%S")..'   '..msg
					if msgtype == Enum.MessageType.MessageOutput then
						formattedText = os.date("%H:%M:%S")..'   <font color="rgb(204, 204, 204)">'..msg..'</font>'
						newOutputText.Text = formattedText
					elseif msgtype == Enum.MessageType.MessageWarning then
						formattedText = os.date("%H:%M:%S")..'   <b><font color="rgb(255, 142, 60)">'..msg..'</font></b>'
						newOutputText.Text = formattedText
					elseif msgtype == Enum.MessageType.MessageError then
						formattedText = os.date("%H:%M:%S")..'   <b><font color="rgb(255, 68, 68)">'..msg..'</font></b>'
						newOutputText.Text = formattedText
					elseif msgtype == Enum.MessageType.MessageInfo then
						formattedText = os.date("%H:%M:%S")..'   <font color="rgb(128, 215, 255)">'..msg..'</font>'
						newOutputText.Text = formattedText
					end

					newOutputText.TextSize = OutputTextSize.Value
					OutputTextSize:GetPropertyChangedSignal("Value"):Connect(function()
						newOutputText.TextSize = OutputTextSize.Value
					end)

					newOutputText.Focused:Connect(function()
						focussedOutput = newOutputText
						newOutputText.Text = unformattedText
					end)
					newOutputText.FocusLost:Connect(function()
						focussedOutput = nil
						newOutputText.Text = formattedText
					end)

					newOutputText.Parent = Console.Output
					newOutputText.Visible = true

					if AutoScroll then
						Console.Output.CanvasPosition = Vector2.new(0, 9e9)
					end
				end)

				Console.Output.MouseLeave:Connect(function()
					if focussedOutput then
						focussedOutput:ReleaseFocus()
					end
				end)

				Console.CommandLine.ScrollingFrame.TextBox:GetPropertyChangedSignal("Text"):Connect(function()

					local oneliner = string.gsub(Console.CommandLine.ScrollingFrame.TextBox.Text, "\n", "    ")
					Console.CommandLine.ScrollingFrame.TextBox.Text = oneliner

					Console.CommandLine.ScrollingFrame.Highlight.Text = SyntaxHighlightingModule.run(Console.CommandLine.ScrollingFrame.TextBox.Text)
				end)



				Console.CommandLine.ScrollingFrame.TextBox.FocusLost:Connect(function(enterPressed)
					if enterPressed and Console.CommandLine.ScrollingFrame.TextBox.Text ~= "" then
						print("> "..Console.CommandLine.ScrollingFrame.TextBox.Text)
						loadstring(Console.CommandLine.ScrollingFrame.TextBox.Text)()
					end
				end)
			end

			return Console
		end

		return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
	end,
	SaveInstance = function()



		
		local Main,Lib,Apps,Settings 
		local Explorer, Properties, ScriptViewer, Notebook 
		local API,RMD,env,service,plr,create,createSimple 

		local function initDeps(data)
			Main = data.Main
			Lib = data.Lib
			Apps = data.Apps
			Settings = data.Settings

			API = data.API
			RMD = data.RMD
			env = data.env
			service = data.service
			plr = data.plr
			create = data.create
			createSimple = data.createSimple
		end

		local function initAfterMain()
			Explorer = Apps.Explorer
			Properties = Apps.Properties
			ScriptViewer = Apps.ScriptViewer
			Notebook = Apps.Notebook
		end

		local function main()
			local SaveInstance = {}
			local window, ListFrame
			local fileName = "Place_"..game.PlaceId.."_"..service.MarketplaceService:GetProductInfo(game.PlaceId).Name.."_{TIMESTAMP}"
			local Saving = false

			local SaveInstanceArgs = {
				Decompile = true,
				DecompileTimeout = 10,
				DecompileIgnore = {"Chat", "CoreGui", "CorePackages"},
				NilInstances = false,
				RemovePlayerCharacters = true,
				SavePlayers = false,
				MaxThreads = 3,
				ShowStatus = true,
				IgnoreDefaultProps = true,
				IsolateStarterPlayer = true
			}

			local function AddCheckbox(title, default)
				local frame = Lib.Frame.new()
				frame.Gui.Parent = ListFrame
				frame.Gui.Transparency = 1
				frame.Gui.Size = UDim2.new(1,0,0,20)

				local listlayout = Instance.new("UIListLayout")
				listlayout.Parent = frame.Gui
				listlayout.FillDirection = Enum.FillDirection.Horizontal
				listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				listlayout.VerticalAlignment = Enum.VerticalAlignment.Center
				listlayout.Padding = UDim.new(0, 10)

				
				local checkbox = Lib.Checkbox.new()

				checkbox.Gui.Parent = frame.Gui
				checkbox.Gui.Size = UDim2.new(0,15,0,15)

				
				local label = Lib.Label.new()

				label.Gui.Parent = frame.Gui
				label.Gui.Size = UDim2.new(1, 0,1, -15)
				label.Gui.Text = title
				label.TextTruncate = Enum.TextTruncate.AtEnd

				checkbox:SetState(default)

				return checkbox
			end

			local function AddTextbox(title, default, sizeX)
				default = tostring(default)
				local frame = Lib.Frame.new()
				frame.Gui.Parent = ListFrame
				frame.Gui.Transparency = 1
				frame.Gui.Size = UDim2.new(1,0,0,20)

				local listlayout = Instance.new("UIListLayout")
				listlayout.Parent = frame.Gui
				listlayout.FillDirection = Enum.FillDirection.Horizontal
				listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				listlayout.VerticalAlignment = Enum.VerticalAlignment.Center
				listlayout.Padding = UDim.new(0, 10)

				
				local textbox = Lib.ViewportTextBox.new()

				textbox.Gui.Parent = frame.Gui
				if sizeX and type(sizeX) == "number" then
					textbox.Gui.Size = UDim2.new(0,sizeX,0,15)
				else
					textbox.Gui.Size = UDim2.new(0,45,0,15)
				end

				textbox.Gui.AutomaticSize = Enum.AutomaticSize.X
				textbox.TextBox.AutomaticSize = Enum.AutomaticSize.X

				
				local label = Lib.Label.new()

				label.Gui.Parent = frame.Gui
				label.Gui.Size = UDim2.new(1, 0,1, -15)
				label.Gui.Text = title
				label.TextTruncate = Enum.TextTruncate.AtEnd

				textbox:SetText(default)

				return textbox
			end

			local function AddDropdown(title, items, default, sizeX)
				local frame = Lib.Frame.new()
				frame.Gui.Parent = ListFrame
				frame.Gui.Transparency = 1
				frame.Gui.Size = UDim2.new(1,0,0,20)

				local listlayout = Instance.new("UIListLayout")
				listlayout.Parent = frame.Gui
				listlayout.FillDirection = Enum.FillDirection.Horizontal
				listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				listlayout.VerticalAlignment = Enum.VerticalAlignment.Center
				listlayout.Padding = UDim.new(0, 10)

				
				local dropdown = Lib.ViewportTextBox.new()

				dropdown.Gui.Parent = frame.Gui
				if sizeX and type(sizeX) == "number" then
					dropdown.Gui.Size = UDim2.new(0,sizeX,0,15)
				else
					dropdown.Gui.Size = UDim2.new(0,65,0,15)
				end

				
				local label = Lib.Label.new()

				label.Gui.Parent = frame.Gui
				label.Gui.Size = UDim2.new(1, 0,1, -15)
				label.Gui.Text = title
				label.TextTruncate = Enum.TextTruncate.AtEnd

				dropdown:SetOptions(items)
				dropdown:SetSelected(default)

				return dropdown
			end

			SaveInstance.Init = function()
				window = Lib.Window.new()
				window:SetTitle("Save Instance")
				window:Resize(350,350)
				SaveInstance.Window = window

				

				
				ListFrame = Instance.new("ScrollingFrame")
				ListFrame.Parent = window.GuiElems.Content
				ListFrame.Size = UDim2.new(1, 0,1, -40)
				ListFrame.Position = UDim2.new(0, 0, 0, 0)
				ListFrame.Transparency = 1
				ListFrame.CanvasSize = UDim2.new(0,0,0,0)
				ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
				ListFrame.ScrollBarThickness = 16
				ListFrame.BottomImage = ""
				ListFrame.TopImage = ""
				ListFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
				ListFrame.ScrollBarImageTransparency = 0
				ListFrame.ZIndex = 2
				ListFrame.BorderSizePixel = 0

				local scrollbar = Lib.ScrollBar.new()
				scrollbar.Gui.Parent = window.GuiElems.Content
				scrollbar.Gui.Size = UDim2.new(1, 0,1, -40)
				scrollbar.Gui.Up.ZIndex = 3
				scrollbar.Gui.Down.ZIndex = 3

				ListFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
					if ListFrame.AbsoluteCanvasSize ~= ListFrame.AbsoluteWindowSize then
						scrollbar.Gui.Visible = true
					else
						scrollbar.Gui.Visible = false
					end
				end)

				local ListLayout = Instance.new("UIListLayout")
				ListLayout.Parent = ListFrame
				ListLayout.Padding = UDim.new(0, 5)

				local Padding = Instance.new("UIPadding")
				Padding.Parent = ListFrame
				Padding.PaddingBottom = UDim.new(0, 5)
				Padding.PaddingLeft = UDim.new(0, 10)
				Padding.PaddingRight = UDim.new(0, 10)
				Padding.PaddingTop = UDim.new(0, 5)

				

				local Decompile = AddCheckbox("Decompile Scripts (LocalScript and ModuleScript)", SaveInstanceArgs.Decompile)
				Decompile.OnInput:Connect(function()
					SaveInstanceArgs.Decompile = Decompile.Toggled
				end)

				local decompileTimeout = AddTextbox("Decompile Timeout (s)", SaveInstanceArgs.DecompileTimeout, 15)
				decompileTimeout.TextBox.FocusLost:Connect(function()
					SaveInstanceArgs.DecompileTimeout = tonumber(decompileTimeout.TextBox.Text)
				end)

				local decompileThread = AddTextbox("Decompiler Max Threads", "3", 15)
				decompileThread.TextBox.FocusLost:Connect(function()
					SaveInstanceArgs.MaxThreads = tonumber(decompileThread.TextBox.Text)
				end)

				local decompileIgnore = AddTextbox("Decompile Ignore", table.concat(SaveInstanceArgs.DecompileIgnore, ","), 50)
				decompileIgnore.TextBox.FocusLost:Connect(function()
					local inputText = decompileIgnore.TextBox.Text
					local rawList = string.split(inputText, ", ") or string.split(inputText, ",")
					local finalList = {}

					for _, text in ipairs(rawList) do
						local split = string.split(text, ",") or string.split(text, ", ")
						for _, textFound in ipairs(split) do
							table.insert(finalList, textFound)
						end
					end
					SaveInstanceArgs.DecompileIgnore = finalList
				end)


				local NilObj = AddCheckbox("Save Nil Instances", SaveInstanceArgs.NilInstances)
				NilObj.OnInput:Connect(function()
					SaveInstanceArgs.NilInstances = NilObj.Toggled
				end)

				local RemovePlayerChar = AddCheckbox("Remove Player Characters", SaveInstanceArgs.RemovePlayerCharacters)
				RemovePlayerChar.OnInput:Connect(function()
					SaveInstanceArgs.RemovePlayerCharacters = RemovePlayerChar.Toggled
				end)

				local SavePlayerObj = AddCheckbox("Save Player Instance", SaveInstanceArgs.SavePlayers)
				SavePlayerObj.OnInput:Connect(function()
					SaveInstanceArgs.SavePlayers = SavePlayerObj.Toggled
				end)

				local IsolateStarterPlr = AddCheckbox("Isolate StarterPlayer", SaveInstanceArgs.IsolateStarterPlayer)
				IsolateStarterPlr.OnInput:Connect(function()
					SaveInstanceArgs.IsolateStarterPlayer = IsolateStarterPlr.Toggled
				end)

				local IgnoreDefaultProps = AddCheckbox("Ignore Default Properties", SaveInstanceArgs.IgnoreDefaultProps)
				IgnoreDefaultProps.OnInput:Connect(function()
					SaveInstanceArgs.IgnoreDefaultProps = IgnoreDefaultProps.Toggled
				end)

				local ShowStat = AddCheckbox("Show Status", SaveInstanceArgs.ShowStatus)
				ShowStat.OnInput:Connect(function()
					SaveInstanceArgs.ShowStatus = ShowStat.Toggled
				end)


				
				local FilenameTextBox = Lib.ViewportTextBox.new()
				FilenameTextBox.Gui.Parent = window.GuiElems.Content
				FilenameTextBox.Size = UDim2.new(1,0, 0,20)
				FilenameTextBox.Position = UDim2.new(0,0, 1,-40)

				local textpadding = Instance.new("UIPadding")
				textpadding.Parent = FilenameTextBox.Gui
				textpadding.PaddingLeft = UDim.new(0, 5)
				textpadding.PaddingRight = UDim.new(0, 5)

				local BackgroundButton = Lib.Frame.new()
				BackgroundButton.Gui.Parent = window.GuiElems.Content
				BackgroundButton.Size = UDim2.new(1,0, 0,20)
				BackgroundButton.Position = UDim2.new(0,0, 1,-20)

				local LabelButton = Lib.Label.new()
				LabelButton.Gui.Parent = window.GuiElems.Content
				LabelButton.Size = UDim2.new(1,0, 0,20)
				LabelButton.Position = UDim2.new(0,0, 1,-20)
				LabelButton.Gui.Text = "Save"
				LabelButton.Gui.TextXAlignment = Enum.TextXAlignment.Center

				local Button = Instance.new("TextButton")
				Button.Parent = BackgroundButton.Gui
				Button.Size = UDim2.new(1,0, 1,0)
				Button.Position = UDim2.new(0,0, 0,0)
				Button.Transparency = 1

				FilenameTextBox.TextBox.Text = fileName
				Button.MouseButton1Click:Connect(function()
					local fileName = FilenameTextBox.TextBox.Text:gsub("{TIMESTAMP}", os.date("%d-%m-%Y_%H-%M-%S"))
					window:SetTitle("Save Instance - Saving")
					local s, result = pcall(env.saveinstance, game, env.parsefile(fileName), SaveInstanceArgs)
					if s then
						window:SetTitle("Save Instance - Saved")
					else
						window:SetTitle("Save Instance - Error")
						task.spawn(error("Failed to save the game: "..result))
					end
					task.wait(5)
					window:SetTitle("Save Instance")
				end)
			end

			return SaveInstance
		end

		return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
	end
}


local Main, Explorer, Properties, ScriptViewer, DefaultSettings, Notebook, Serializer, Lib, Console, SaveInstance
local API, RM


DefaultSettings = (function()
	local rgb = Color3.fromRGB
	return {
		Explorer = {
			_Recurse = true,
			Sorting = true,
			TeleportToOffset = Vector3.new(0,0,0),
			ClickToRename = true,
			AutoUpdateSearch = true,
			AutoUpdateMode = 0, 
			PartSelectionBox = true,
			GuiSelectionBox = true,
			CopyPathUseGetChildren = true
		},
		Properties = {
			_Recurse = true,
			MaxConflictCheck = 50,
			ShowDeprecated = false,
			ShowHidden = false,
			ClearOnFocus = false,
			LoadstringInput = true,
			NumberRounding = 3,
			ShowAttributes = false,
			MaxAttributes = 50,
			ScaleType = 1 
		},
		Theme = {
			_Recurse = true,
			Main1 = rgb(52,52,52),
			Main2 = rgb(45,45,45),
			Outline1 = rgb(33,33,33), 
			Outline2 = rgb(55,55,55), 
			Outline3 = rgb(30,30,30), 
			TextBox = rgb(38,38,38),
			Menu = rgb(32,32,32),
			ListSelection = rgb(11,90,175),
			Button = rgb(60,60,60),
			ButtonHover = rgb(68,68,68),
			ButtonPress = rgb(40,40,40),
			Highlight = rgb(75,75,75),
			Text = rgb(255,255,255),
			PlaceholderText = rgb(100,100,100),
			Important = rgb(255,0,0),
			ExplorerIconMap = "",
			MiscIconMap = "",
			Syntax = {
				Text = rgb(204,204,204),
				Background = rgb(36,36,36),
				Selection = rgb(255,255,255),
				SelectionBack = rgb(11,90,175),
				Operator = rgb(204,204,204),
				Number = rgb(255,198,0),
				String = rgb(173,241,149),
				Comment = rgb(102,102,102),
				Keyword = rgb(248,109,124),
				Error = rgb(255,0,0),
				FindBackground = rgb(141,118,0),
				MatchingWord = rgb(85,85,85),
				BuiltIn = rgb(132,214,247),
				CurrentLine = rgb(45,50,65),
				LocalMethod = rgb(253,251,172),
				LocalProperty = rgb(97,161,241),
				Nil = rgb(255,198,0),
				Bool = rgb(255,198,0),
				Function = rgb(248,109,124),
				Local = rgb(248,109,124),
				Self = rgb(248,109,124),
				FunctionName = rgb(253,251,172),
				Bracket = rgb(204,204,204)
			},
		}
	}
end)()


local Settings = {}
local Apps = {}
local env = {}

local plr = service.Players.LocalPlayer or service.Players.PlayerAdded:wait()

local create = function(data)
	local insts = {}
	for i,v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end

	for _,v in pairs(data) do
		for prop,val in pairs(v[3]) do
			if type(val) == "table" then
				insts[v[1]][prop] = insts[val[1]]
			else
				insts[v[1]][prop] = val
			end
		end
	end

	return insts[1]
end

local createSimple = function(class,props)
	local inst = Instance.new(class)
	for i,v in next,props do
		inst[i] = v
	end
	return inst
end

Main = (function()
	local Main = {}

	Main.ModuleList = {"Explorer", "Properties", "ScriptViewer", "Console", "SaveInstance"}
	Main.Elevated = false
	Main.MissingEnv = {}
	Main.Version = "" 
	Main.Mouse = plr:GetMouse()
	Main.AppControls = {}
	Main.Apps = Apps
	Main.MenuApps = {}

	Main.DisplayOrders = {
		SideWindow = 8,
		Window = 10,
		Menu = 100000,
		Core = 101000
	}

	Main.GetInitDeps = function()
		return {
			Main = Main,
			Lib = Lib,
			Apps = Apps,
			Settings = Settings,

			API = API,
			RMD = RMD,
			env = env,
			service = service,
			plr = plr,
			create = create,
			createSimple = createSimple
		}
	end

	Main.Error = function(str)
		if rconsoleprint then
			rconsoleprint("DEX ERROR: "..tostring(str).."\n")
			wait(9e9)
		else
			error(str)
		end
	end

	Main.LoadModule = function(name)
		


























		local control

		if EmbeddedModules then 
			control = EmbeddedModules[name]()

			if not control then Main.Error("Missing Embedded Module: "..name) end
		end

		Main.AppControls[name] = control
		control.InitDeps(Main.GetInitDeps())

		local moduleData = control.Main()
		Apps[name] = moduleData
		return moduleData
	end

	Main.LoadModules = function()
		for i,v in pairs(Main.ModuleList) do
			local s,e = pcall(Main.LoadModule,v)
			if not s then
				Main.Error(("FAILED LOADING %s CAUSE %s"):format(v, e))
			end
		end

		
		Explorer = Apps.Explorer
		Properties = Apps.Properties
		ScriptViewer = Apps.ScriptViewer
		Console = Apps.Console
		SaveInstance = Apps.SaveInstance
		Notebook = Apps.Notebook
		local appTable = {
			Explorer = Explorer,
			Properties = Properties,
			ScriptViewer = ScriptViewer,
			Console = Console,
			SaveInstance = SaveInstance,
			Notebook = Notebook
		}

		Main.AppControls.Lib.InitAfterMain(appTable)
		for i,v in pairs(Main.ModuleList) do
			local control = Main.AppControls[v]
			if control then
				control.InitAfterMain(appTable)
			end
		end
	end

	Main.InitEnv = function()
		setmetatable(env, {__newindex = function(self, name, func)
			if not func then Main.MissingEnv[#Main.MissingEnv + 1] = name return end
			rawset(self, name, func)
		end})

		
		env.readfile = missing("function", readfile)
		env.writefile = missing("function", writefile)
		env.appendfile = missing("function", appendfile)
		env.makefolder = missing("function", makefolder)
		env.listfiles = missing("function", listfiles)
		env.loadfile = missing("function", loadfile)
		env.movefileas = missing("function", movefileas)
		env.saveinstance = missing("function", saveinstance) or (function()
			
			local success, res = pcall(function()
				return loadstring(oldgame:HttpGet(dexCacheBust("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau"), false))()
			end)
			return success and res or nil
		end)()
		env.parsefile = function(name)
			return tostring(name):gsub("[*\\?:<>|]+", ""):sub(1, 175)
		end

		
		env.getupvalues = missing("function", (debug and debug.getupvalues) or getupvalues or getupvals)
		env.getconstants = missing("function", (debug and debug.getconstants) or getconstants or getconsts)
		env.getinfo = missing("function", (debug and (debug.getinfo or debug.info)) or getinfo)
		env.islclosure = missing("function", islclosure or is_l_closure or is_lclosure)
		env.checkcaller = missing("function", checkcaller)
		
		env.getgc = missing("function", getgc or get_gc_objects)
		
		env.getgenv = missing("function", getgenv, _getgenv)
		env.getscriptbytecode = missing("function", getscriptbytecode or get_script_bytecode)
		env.getscriptclosure = missing("function", getscriptclosure or getscriptfunction or get_script_closure or get_script_function)
		env.dumpclosurebytecode = missing("function", dumpstring or dumpclosure or (string and string.dump))

		
		
		env.request = missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))

		local DECOMPILER_VERSION = DEX_BUILD_VERSION
		local function makeBytecodeDecompiler(getbc)
			local MAX_PROTO_DEPTH = 160
			local YIELD_EVERY = 4096
			local globalWork = 0
			local function cooperate(step)
				globalWork += step or 1
				if globalWork >= YIELD_EVERY then
					globalWork = 0
					if task and task.wait then task.wait() end
				end
			end
			local opnames = {
				"NOP","BREAK","LOADNIL","LOADB","LOADN","LOADK","MOVE","GETGLOBAL","SETGLOBAL","GETUPVAL","SETUPVAL","CLOSEUPVALS","GETIMPORT","GETTABLE","SETTABLE","GETTABLEKS","SETTABLEKS","GETTABLEN","SETTABLEN","NEWCLOSURE","NAMECALL","CALL","RETURN","JUMP","JUMPBACK","JUMPIF","JUMPIFNOT","JUMPIFEQ","JUMPIFLE","JUMPIFLT","JUMPIFNOTEQ","JUMPIFNOTLE","JUMPIFNOTLT","ADD","SUB","MUL","DIV","MOD","POW","ADDK","SUBK","MULK","DIVK","MODK","POWK","AND","OR","ANDK","ORK","CONCAT","NOT","MINUS","LENGTH","NEWTABLE","DUPTABLE","SETLIST","FORNPREP","FORNLOOP","FORGLOOP","FORGPREP_INEXT","FASTCALL3","FORGPREP_NEXT","NATIVECALL","GETVARARGS","DUPCLOSURE","PREPVARARGS","LOADKX","JUMPX","FASTCALL","COVERAGE","CAPTURE","SUBRK","DIVRK","FASTCALL1","FASTCALL2","FASTCALL2K","FORGPREP","JUMPXEQKNIL","JUMPXEQKB","JUMPXEQKN","JUMPXEQKS","IDIV","IDIVK","GETUDATAKS","SETUDATAKS","NAMECALLUDATA","NEWCLASSMEMBER","CALLFB","CMPPROTO","FASTPCALL","NEWCLASS"
			}
			local auxops = {}
			for _, n in ipairs({
				"GETGLOBAL","SETGLOBAL","GETIMPORT","GETTABLEKS","SETTABLEKS","NAMECALL","JUMPIFEQ","JUMPIFLE","JUMPIFLT","JUMPIFNOTEQ","JUMPIFNOTLE","JUMPIFNOTLT","NEWTABLE","SETLIST","FORGLOOP","FASTCALL3","LOADKX","FASTCALL2","FASTCALL2K","JUMPXEQKNIL","JUMPXEQKB","JUMPXEQKN","JUMPXEQKS","GETUDATAKS","SETUDATAKS","NAMECALLUDATA","NEWCLASSMEMBER","CALLFB","CMPPROTO","NEWCLASS"
			}) do
				auxops[n] = true
			end
			local opcodeIndex = {}
			for i,n in ipairs(opnames) do opcodeIndex[n]=i-1 end
			local robloxServices,robloxClasses,robloxEnums = {},{},{}
			pcall(function()
				if API and API.Classes then
					for name,class in pairs(API.Classes) do
						robloxClasses[name]=true
						if class.Tags and class.Tags.Service then robloxServices[name]=true end
					end
				end
				if API and API.Enums then
					for name in pairs(API.Enums) do robloxEnums[name]=true end
				end
			end)
			local immutableConstructors = {
				Axes=true,BrickColor=true,CFrame=true,Color3=true,ColorSequence=true,ColorSequenceKeypoint=true,Content=true,DateTime=true,Faces=true,FloatCurveKey=true,Font=true,NumberRange=true,NumberSequence=true,NumberSequenceKeypoint=true,Path2DControlPoint=true,PhysicalProperties=true,Ray=true,Rect=true,Region3=true,Region3int16=true,RotationCurveKey=true,TweenInfo=true,UDim=true,UDim2=true,Vector2=true,Vector2int16=true,Vector3=true,Vector3int16=true
			}
			local vmNoopOps = {NOP=true,BREAK=true,COVERAGE=true,PREPVARARGS=true,NATIVECALL=true,FASTCALL=true,FASTCALL1=true,FASTCALL2=true,FASTCALL2K=true,FASTCALL3=true,FASTPCALL=true,CAPTURE=true}
			local function reader(data)
				return {d=data,p=1,n=#data}
			end
			local function u8(r)
				if r.p > r.n then error("unexpected eof") end
				local v = string.byte(r.d,r.p)
				r.p += 1
				return v
			end
			local function bytes(r,n)
				if r.p+n-1 > r.n then error("unexpected eof") end
				local s = string.sub(r.d,r.p,r.p+n-1)
				r.p += n
				return s
			end
			local function skip(r,n)
				if r.p+n-1 > r.n then error("unexpected eof") end
				r.p += n
			end
			local function var(r)
				local v = 0
				local sh = 0
				while true do
					local b = u8(r)
					v += (b % 128) * 2^sh
					if b < 128 then return v end
					sh += 7
					if sh > 63 then error("invalid varint") end
				end
			end
			local function decmuladd(v,m,a)
				local out={}
				local carry=a
				for i=#v,1,-1 do
					local n=(string.byte(v,i)-48)*m+carry
					out[#out+1]=string.char(48+(n%10))
					carry=math.floor(n/10)
				end
				while carry>0 do
					out[#out+1]=string.char(48+(carry%10))
					carry=math.floor(carry/10)
				end
				for i=1,math.floor(#out/2) do out[i],out[#out-i+1]=out[#out-i+1],out[i] end
				return table.concat(out)
			end
			local function var64str(r)
				local groups={}
				while true do
					local b=u8(r)
					groups[#groups+1]=b%128
					if b<128 then break end
				end
				local v="0"
				for i=#groups,1,-1 do v=decmuladd(v,128,groups[i]) end
				return v
			end
			local function u32(r)
				local a,b,c,d = u8(r),u8(r),u8(r),u8(r)
				return a+b*256+c*65536+d*16777216
			end
			local function i32(r)
				local v = u32(r)
				return v >= 2147483648 and v-4294967296 or v
			end
			local function f32(r)
				local w = u32(r)
				local s = w >= 2147483648 and -1 or 1
				local e = math.floor(w/8388608)%256
				local f = w%8388608
				if e == 255 then
					return f == 0 and s*math.huge or 0/0
				elseif e == 0 then
					return s*2^-126*(f/8388608)
				end
				return s*2^(e-127)*(1+f/8388608)
			end
			local function f64(r)
				local lo,hi = u32(r),u32(r)
				local s = hi >= 2147483648 and -1 or 1
				local e = math.floor(hi/1048576)%2048
				local f = (hi%1048576)*4294967296+lo
				if e == 2047 then
					return f == 0 and s*math.huge or 0/0
				elseif e == 0 then
					return s*2^-1022*(f/4503599627370496)
				end
				return s*2^(e-1023)*(1+f/4503599627370496)
			end
			local function abcv(w)
				return math.floor(w/256)%256,math.floor(w/65536)%256,math.floor(w/16777216)%256
			end
			local function dv(w)
				local d = math.floor(w/65536)%65536
				return d >= 32768 and d-65536 or d
			end
			local function ev(w)
				local e = math.floor(w/256)%16777216
				return e >= 8388608 and e-16777216 or e
			end
			local function opid(w,m)
				return ((w%256)*m)%256
			end
			local function opcodeAvailable(n,version)
				if version==100 then return true end
				if n=="IDIV" or n=="IDIVK" then return version>=4 end
				if n=="SUBRK" or n=="DIVRK" then return version>=5 end
				if n=="FASTCALL3" then return version>=6 end
				if n=="GETUDATAKS" or n=="SETUDATAKS" or n=="NAMECALLUDATA" then return version>=9 end
				if n=="NEWCLASSMEMBER" then return version>=10 end
				if n=="CALLFB" or n=="CMPPROTO" then return version>=11 end
				if n=="FASTPCALL" then return version>=14 end
				if n=="NEWCLASS" then return false end
				return true
			end
			local function score(words,m,limit,version)
				local i,s,valid,unknown = 1,0,0,0
				local stop=math.min(#words,limit or #words)
				local prev=nil
				while i <= stop do
					local w=words[i]
					local id = opid(w,m)
					local n = opnames[id+1]
					if not n or not opcodeAvailable(n,version or 100) then
						unknown += 1
						s -= 30
						i += 1
						prev=nil
					else
						valid += 1
						s += 5
						if n == "RETURN" or n == "CALL" or n == "LOADK" or n == "GETIMPORT" or n == "MOVE" then s += 2 end
						local sz=auxops[n] and 2 or 1
						if sz==2 and i>=#words then s-=100 break end
						if n=="JUMP" or n=="JUMPBACK" or n=="JUMPIF" or n=="JUMPIFNOT" or n=="JUMPIFEQ" or n=="JUMPIFLE" or n=="JUMPIFLT" or n=="JUMPIFNOTEQ" or n=="JUMPIFNOTLE" or n=="JUMPIFNOTLT" or n=="FORNPREP" or n=="FORNLOOP" or n=="FORGLOOP" or n=="FORGPREP_INEXT" or n=="FORGPREP_NEXT" or n=="FORGPREP" or n=="JUMPXEQKNIL" or n=="JUMPXEQKB" or n=="JUMPXEQKN" or n=="JUMPXEQKS" or n=="CMPPROTO" then
							local t=(i-1)+1+dv(w)
							if t<0 or t>#words then s-=35 else s+=2 end
						elseif n=="JUMPX" then
							local t=(i-1)+1+ev(w)
							if t<0 or t>#words then s-=35 else s+=2 end
						elseif n=="LOADB" then
							local _,_,c=abcv(w)
							if c>0 and i+c>#words+1 then s-=15 end
						end
						if n=="CAPTURE" then
							if prev=="NEWCLOSURE" or prev=="CAPTURE" then s+=5 else s-=8 end
						end
						if n=="NAMECALL" and i+2<=#words then
							local nn=opnames[opid(words[i+2],m)+1]
							if nn=="CALL" or nn=="CALLFB" then s+=8 else s-=10 end
						end
						prev=n
						i += sz
					end
				end
				return valid == 0 and -1e30 or s,unknown,valid
			end
			local function multiplier(words,mod,ignoreHint)
				if #words==0 then return 1 end
				local version=mod and mod.version or 100
				local sample=math.min(#words,4096)
				if mod and mod.opmul and not ignoreHint then
					local _,u,v=score(words,mod.opmul,sample,version)
					if u==0 and v>0 then return mod.opmul end
				end
				local best={}
				for m=1,255,2 do
					cooperate(32)
					local sc,u=score(words,m,sample,version)
					best[#best+1]={m=m,s=sc,u=u}
				end
				table.sort(best,function(a,b) if a.u~=b.u then return a.u<b.u end return a.s>b.s end)
				local bm,bs,bu=best[1].m,-1e30,math.huge
				for i=1,math.min(8,#best) do
					local sc,u=score(words,best[i].m,nil,version)
					if u<bu or (u==bu and sc>bs) then bm,bs,bu=best[i].m,sc,u end
				end
				return bm
			end
			local function futureScore(words,pos,m,version,depth,memo)
				if pos>#words or depth<=0 then return 0 end
				local key=pos*32+depth
				local cached=memo[key]
				if cached then return cached end
				local n=opnames[opid(words[pos],m)+1]
				local out
				if n and opcodeAvailable(n,version) then
					local sz=auxops[n] and 2 or 1
					if pos+sz-1>#words then out=-50 else out=7+futureScore(words,pos+sz,m,version,depth-1,memo) end
				else
					local a=-5+futureScore(words,pos+1,m,version,depth-1,memo)
					local b=pos<#words and (-7+futureScore(words,pos+2,m,version,depth-1,memo)) or -1e9
					out=math.max(a,b)
				end
				memo[key]=out
				return out
			end
			local function decodepass(words,mod,m)
				local version=mod and mod.version or 100
				local out = {}
				local i = 1
				local unknown=0
				while i <= #words do
					local w = words[i]
					local id = opid(w,m)
					local n = opnames[id+1]
					local known=n and opcodeAvailable(n,version)
					if not known then n="UNKNOWN" unknown+=1 end
					local a,b,c = abcv(w)
					local x = {pc=i-1,w=w,id=id,n=n,a=a,b=b,c=c,d=dv(w),e=ev(w),size=1}
					if known and auxops[n] then
						if i<#words then x.aux=words[i+1] x.size=2 else x.n="UNKNOWN" unknown+=1 end
					elseif not known and i<#words then
						local memo={}
						local s1=futureScore(words,i+1,m,version,10,memo)
						local s2=futureScore(words,i+2,m,version,10,memo)-2
						if s2>s1 then x.aux=words[i+1] x.size=2 end
					end
					out[#out+1] = x
					i += x.size
				end
				return out,unknown
			end
			local function decode(words,mod)
				local m=multiplier(words,mod,false)
				local out,unknown=decodepass(words,mod,m)
				if unknown>0 then
					local m2=multiplier(words,mod,true)
					if m2~=m then
						local out2,u2=decodepass(words,mod,m2)
						if u2<unknown then out,unknown,m=out2,u2,m2 end
					end
				end
				if mod and #words>=32 and unknown==0 then mod.opmul=m end
				return out
			end
			local function readconst(r,strings)
				local t = u8(r)
				if t == 0 then
					return {t=t,v=nil}
				elseif t == 1 then
					return {t=t,v=u8(r)~=0}
				elseif t == 2 then
					return {t=t,v=f64(r)}
				elseif t == 3 then
					local i = var(r)
					return {t=t,v=strings[i]}
				elseif t == 4 then
					return {t=t,v=u32(r)}
				elseif t == 5 then
					local n = var(r)
					local v = {}
					for i=1,n do v[i]=var(r) end
					return {t=t,v=v}
				elseif t == 6 then
					return {t=t,v=var(r)}
				elseif t == 7 then
					return {t=t,v={f32(r),f32(r),f32(r),f32(r)}}
				elseif t == 8 then
					local n = var(r)
					local v = {}
					for i=1,n do v[i]={var(r),i32(r)} end
					return {t=t,v=v}
				elseif t == 9 then
					local neg = u8(r)~=0
					local v = var64str(r)
					return {t=t,v=(neg and v~="0") and ("-"..v) or v}
				elseif t == 10 then
					local cn,pc,mc = var(r),var(r),var(r)
					local v = {cn=cn,p={},m={}}
					for i=1,pc do v.p[i]=var(r) end
					for i=1,mc do v.m[i]=var(r) end
					return {t=t,v=v}
				elseif t == 11 then
					return {t=t,v={f64(r),f64(r),f64(r),f64(r)}}
				end
				error("unsupported constant tag "..tostring(t))
			end
			local function readproto(r,mod)
				local p = {}
				p.max = u8(r)
				p.params = u8(r)
				p.ups = u8(r)
				p.vararg = u8(r)~=0
				if mod.version >= 4 then
					p.flags = u8(r)
					local ts = var(r)
					if ts > 0 then skip(r,ts) end
				else
					p.flags = 0
				end
				local nc = var(r)
				if nc > 10000000 then error("instruction count too large: "..tostring(nc)) end
				p.words = {}
				for i=1,nc do
					p.words[i]=u32(r)
					if i%4096==0 then cooperate(4096) end
				end
				p.ins = decode(p.words,mod)
				local nk = var(r)
				if nk > 5000000 then error("constant count too large: "..tostring(nk)) end
				p.k = {}
				for i=1,nk do
					p.k[i]=readconst(r,mod.strings)
					if i%2048==0 then cooperate(4096) end
				end
				local np = var(r)
				p.children = {}
				for i=1,np do p.children[i]=var(r)+1 end
				p.line = var(r)
				local dn = var(r)
				p.name = dn~=0 and mod.strings[dn] or nil
				if u8(r)~=0 then
					local lg = u8(r)
					skip(r,nc)
					local spans = nc > 0 and math.floor((nc-1)/2^lg)+1 or 0
					skip(r,spans*4)
				end
				p.locals = {}
				p.upnames = {}
				if u8(r)~=0 then
					local nl = var(r)
					for _=1,nl do
						local ni = var(r)
						local sp = var(r)
						local ep = var(r)
						local rg = u8(r)
						p.locals[#p.locals+1] = {name=mod.strings[ni],start=sp,finish=ep,reg=rg}
					end
					local nu = var(r)
					for i=1,nu do
						local ni = var(r)
						p.upnames[i] = mod.strings[ni]
					end
				end
				if mod.version >= 11 then
					local nf = var(r)
					for _=1,nf do
						u8(r)
						var(r)
					end
				end
				if mod.version >= 12 and bit32.band(p.flags or 0,8)~=0 then
					var(r)
				end
				return p
			end
			local function deserialize(data)
				local r = reader(data)
				local version = u8(r)
				if version == 0 then error(bytes(r,r.n-r.p+1)) end
				if not ((version>=3 and version<=14) or version==100) then error("unsupported bytecode version "..tostring(version)) end
				local tv = version>=4 and u8(r) or 0
				if version>=4 and (tv<1 or tv>3) then error("unsupported bytecode type version "..tostring(tv)) end
				local ns = var(r)
				if ns > 5000000 then error("string count too large: "..tostring(ns)) end
				local strings = {}
				for i=1,ns do
					strings[i]=bytes(r,var(r))
					if i%2048==0 then cooperate(4096) end
				end
				if tv == 3 then
					while true do
						local i = u8(r)
						if i == 0 then break end
						var(r)
					end
				end
				local mod = {version=version,typeversion=tv,strings=strings,protos={}}
				local np = var(r)
				if np > 1000000 then error("proto count too large: "..tostring(np)) end
				for i=1,np do
					local endp
					if version >= 12 then
						local sz = var(r)
						endp = r.p+sz
					end
					mod.protos[i]=readproto(r,mod)
					cooperate(64)
					if endp then
						if endp > r.n+1 then error("proto extends past bytecode") end
						if r.p > endp then error("proto parser overread") end
						if r.p < endp then r.p=endp end
					end
				end
				mod.main = var(r)+1
				return mod
			end
			local function q(v)
				return string.format("%q",tostring(v))
			end
			local function ident(s)
				return type(s)=="string" and s:match("^[%a_][%w_]*$")~=nil
			end
			local function kval(p,i)
				local k = p.k[i+1]
				if not k then return "nil" end
				if k.t == 0 then return "nil"
				elseif k.t == 1 then return tostring(k.v)
				elseif k.t == 2 then return k.v==math.huge and "math.huge" or k.v==-math.huge and "-math.huge" or k.v~=k.v and "(0/0)" or tostring(k.v)
				elseif k.t == 9 then return tostring(k.v)
				elseif k.t == 3 then return q(k.v)
				elseif k.t == 7 then
					if k.v[4] and k.v[4] ~= 0 then return ("vector.create(%s,%s,%s,%s)"):format(tostring(k.v[1]),tostring(k.v[2]),tostring(k.v[3]),tostring(k.v[4])) end
					return ("Vector3.new(%s,%s,%s)"):format(tostring(k.v[1]),tostring(k.v[2]),tostring(k.v[3]))
				elseif k.t == 11 then
					if k.v[4] and k.v[4] ~= 0 then return ("vector.create(%s,%s,%s,%s)"):format(tostring(k.v[1]),tostring(k.v[2]),tostring(k.v[3]),tostring(k.v[4])) end
					return ("Vector3.new(%s,%s,%s)"):format(tostring(k.v[1]),tostring(k.v[2]),tostring(k.v[3]))
				elseif k.t == 5 then
					local items={}
					for _,keyi in ipairs(k.v) do
						local ks=p.k[keyi+1]
						local lhs=ks and ks.t==3 and ident(ks.v) and ks.v or ("["..kval(p,keyi).."]")
						items[#items+1]=lhs.." = 0"
					end
					return "{"..table.concat(items,", ").."}"
				elseif k.t == 8 then
					local items={}
					for _,pair in ipairs(k.v) do
						local keyi,vali=pair[1],pair[2]
						local ks=p.k[keyi+1]
						local lhs=ks and ks.t==3 and ident(ks.v) and ks.v or ("["..kval(p,keyi).."]")
						if vali and vali >= 0 then
							local vv=p.k[vali+1]
							if vv and vv.t~=0 then items[#items+1]=lhs.." = "..kval(p,vali) end
						else
							items[#items+1]=lhs.." = 0"
						end
					end
					return "{"..table.concat(items,", ").."}"
				end
				return "nil"
			end
			local function kstr(p,i)
				local k = p.k[i+1]
				return k and k.t==3 and k.v or nil
			end
			local function prop(base,key)
				return ident(key) and (base.."."..key) or (base.."["..q(key or "?").."]")
			end
			local function importpath(p,aux)
				local n = math.floor(aux/1073741824)%4
				local ids = {
					math.floor(aux/1048576)%1024,
					math.floor(aux/1024)%1024,
					aux%1024
				}
				local out
				for i=1,n do
					local s = kstr(p,ids[i]) or ("k"..tostring(ids[i]))
					out = out and prop(out,s) or (ident(s) and s or ("_G["..q(s).."]"))
				end
				return out or "_G"
			end
			local function canonicalindent_source(s)
				if GENV.DEX_PRETTY_CANONICAL_INDENT == false then return s end
				local maxindent=tonumber(GENV.DEX_PRETTY_MAX_INDENT) or 10
				if maxindent<1 then maxindent=1 end
				local out={}
				local blockdepth=0
				local tabledepth=0
				local function trimline(x)
					return (x:gsub("^%s+",""):gsub("%s+$",""))
				end
				local function bracedelta(x)
					local d=0
					local q=nil
					local esc=false
					local i=1
					while i<=#x do
						local c=x:sub(i,i)
						if q then
							if esc then
								esc=false
							elseif c=="\\" then
								esc=true
							elseif c==q then
								q=nil
							end
						else
							if c=='"' or c=="'" or c=="`" then
								q=c
							elseif c=="{" then
								d+=1
							elseif c=="}" then
								d-=1
							end
						end
						i+=1
					end
					return d
				end
				local function leadingcloses(x)
					local n=0
					for i=1,#x do
						if x:sub(i,i)=="}" then n+=1 else break end
					end
					return n
				end
				local function ismid(x)
					return x=="else" or x:match("^elseif%s+.+%s+then[,;]?$")~=nil
				end
				local function isclose(x)
					return x:match("^end[,;]?$")~=nil or x:match("^until%s+.+[,;]?$")~=nil
				end
				local function opens(x)
					if x:match("^if%s+.+%s+then$") then return true end
					if x:match("^while%s+.+%s+do$") then return true end
					if x:match("^for%s+.+%s+do$") then return true end
					if x=="repeat" or x=="do" then return true end
					if x:match("^local%s+function%s+") or x:match("^function%s+") then return true end
					if x:find("=%s*function%s*%(") or x:match("^return%s+function%s*%(") then
						if not x:match("function%s*%b()%s*end%s*[,;]?$") then return true end
					end
					return false
				end
				for raw in (s.."\n"):gmatch("(.-)\n") do
					local t=trimline(raw)
					if t=="" then
						out[#out+1]=""
					else
						local mid=ismid(t)
						local close=isclose(t)
						local preblock=(mid or close) and 1 or 0
						local pretable=leadingcloses(t)
						local logical=blockdepth-preblock+tabledepth-pretable
						if logical<0 then logical=0 end
						local visual=math.min(logical,maxindent)
						out[#out+1]=string.rep("\t",visual)..t
						tabledepth=math.max(0,tabledepth+bracedelta(t))
						if close then
							blockdepth=math.max(0,blockdepth-1)
						elseif not mid and opens(t) then
							blockdepth+=1
						end
					end
				end
				while #out>0 and out[#out]=="" do out[#out]=nil end
				return table.concat(out,"\n")
			end
			local function cleanupsource(s)
				local ls={}
				for line in (s.."\n"):gmatch("(.-)\n") do ls[#ls+1]=line end
				local function tr(x)
					return (x:gsub("^%s+",""):gsub("%s+$",""))
				end
				local function dep(x)
					local p=x:match("^\t*") or ""
					return #p
				end
				local function opener(t)
					if t:match("^if%s+.+%s+then$") then return "if" end
					if t:match("^while%s+.+%s+do$") then return "end" end
					if t:match("^for%s+.+%s+do$") then return "end" end
					if t=="repeat" then return "repeat" end
					if t:match("^do$") then return "end" end
					if t:match("^local%s+function%s+") or t:match("^function%s+") then return "end" end
					if t:find("function%s*%(") and not t:match("%f[%a]end%f[%A]") then return "end" end
					return nil
				end
				local function pairifs(a)
					local stack={}
					local mt={}
					for i,line in ipairs(a) do
						local t=tr(line)
						local d=dep(line)
						local k=opener(t)
						if k then
							stack[#stack+1]={kind=k,depth=d,line=i}
						elseif t=="end" then
							local top=stack[#stack]
							if top and top.depth==d and top.kind~="repeat" then
								stack[#stack]=nil
								if top.kind=="if" then mt[top.line]=i end
							end
						elseif t:match("^until%s+") then
							local top=stack[#stack]
							if top and top.depth==d and top.kind=="repeat" then stack[#stack]=nil end
						end
					end
					return mt
				end
				local mt=pairifs(ls)
				local del={}
				local rep={}
				for i=1,#ls-1 do
					if tr(ls[i])=="else" then
						local d=dep(ls[i])
						local j=i+1
						while j<=#ls and tr(ls[j])=="" do j+=1 end
						local t=j<=#ls and tr(ls[j]) or ""
						if j<=#ls and dep(ls[j])==d+1 and t:match("^if%s+.+%s+then$") then
							local e=mt[j]
							if e then
								local k=e+1
								while k<=#ls and tr(ls[k])=="" do k+=1 end
								if k<=#ls and dep(ls[k])==d and tr(ls[k])=="end" then
									local c=t:match("^if%s+(.+)%s+then$")
									if c then
										rep[i]=string.rep("\t",d).."elseif "..c.." then"
										del[j]=true
										del[e]=true
									end
								end
							end
						end
					end
				end
				if next(del) or next(rep) then
					local n={}
					for i,line in ipairs(ls) do
						if not del[i] then n[#n+1]=rep[i] or line end
					end
					ls=n
				end
				local td={}
				for i=1,#ls do
					local lead,name=ls[i]:match("^(\t*)local%s+([%a_][%w_]*)%s*=%s*{}%s*$")
					if name then
						local vals={}
						local j=i+1
						local want=1
						while j<=#ls do
							local idx,val=ls[j]:match("^"..lead..name:gsub("([^%w])","%%%1").."%[(%d+)%]%s*=%s*(.+)$")
							if tonumber(idx)~=want or not val then break end
							vals[#vals+1]=val want+=1 td[j]=true j+=1
						end
						if #vals>=2 then ls[i]=lead.."local "..name.." = {"..table.concat(vals,", ").."}" else for k=i+1,j-1 do td[k]=nil end end
					end
				end
				if next(td) then
					local n={}
					for i,line in ipairs(ls) do if not td[i] then n[#n+1]=line end end
					ls=n
				end
				mt=pairifs(ls)
				local pref={[0]=0}
				for i,line in ipairs(ls) do
					local t=tr(line)
					local control=t=="" or t=="else" or t=="end" or t:match("^if%s+.+%s+then$") or t:match("^elseif%s+.+%s+then$")
					pref[i]=(pref[i-1] or 0)+(control and 0 or 1)
				end
				local diff={}
				for a,b in pairs(mt) do
					if (pref[b-1] or 0)-(pref[a] or 0)==0 then
						diff[a]=(diff[a] or 0)+1
						diff[b+1]=(diff[b+1] or 0)-1
					end
				end
				local compact={}
				local active=0
				for i,line in ipairs(ls) do
					active+=diff[i] or 0
					if active==0 then compact[#compact+1]=line end
				end
				local out={}
				local stack={}
				local function findclose(depth,kind)
					for j=#stack,1,-1 do
						local b=stack[j]
						if b.depth<depth then break end
						if b.depth==depth and (not kind or b.kind==kind) then return j end
					end
					return nil
				end
				for _,line in ipairs(compact) do
					local t=tr(line)
					local d=dep(line)
					local k=opener(t)
					if k then
						stack[#stack+1]={kind=k,depth=d,seenElse=false}
						out[#out+1]=line
					elseif t:match("^elseif%s+.+%s+then$") then
						local j=findclose(d,"if")
						if j and not stack[j].seenElse then
							out[#out+1]=line
						end
					elseif t=="else" then
						local j=findclose(d,"if")
						if j and not stack[j].seenElse then
							stack[j].seenElse=true
							out[#out+1]=line
						end
					elseif t=="end" then
						local j=findclose(d)
						if j and stack[j].kind~="repeat" then
							for z=#stack,j,-1 do stack[z]=nil end
							out[#out+1]=line
						end
					elseif t:match("^until%s+") then
						local j=findclose(d,"repeat")
						if j then
							for z=#stack,j,-1 do stack[z]=nil end
							out[#out+1]=line
						end
					else
						out[#out+1]=line
					end
				end
				for i=#stack,1,-1 do
					local b=stack[i]
					if b.kind=="repeat" then
						out[#out+1]=string.rep("\t",b.depth).."until false"
					else
						out[#out+1]=string.rep("\t",b.depth).."end"
					end
				end
				local final={}
				local last=""
				for _,line in ipairs(out) do
					local t=tr(line)
					if not (t=="end" and last=="end" and dep(line)==0) then
						final[#final+1]=line
					end
					last=t
				end
				while #final>0 and tr(final[#final])=="" do final[#final]=nil end
				local function countword(s,w)
					local n=0
					local p="%f[%w_]"..w.."%f[^%w_]"
					s:gsub(p,function() n+=1 return w end)
					return n
				end
				local function replaceword(s,w,r)
					return (s:gsub("%f[%w_]"..w.."%f[^%w_]",r))
				end
				local function simpleatom(s)
					s=tr(s)
					if s:match('^[-+]?%d+%.?%d*[eE]?[-+]?%d*$') or s=="true" or s=="false" or s=="nil" or s=="..." then return true end
					if s:match('^".*"$') or s:match("^'.*'$") then return true end
					if s:match('^[%a_][%w_%.]*$') then return true end
					if s:match('^Enum%.[%w_]+%.[%w_]+$') then return true end
					return false
				end
				local function wrapexpr(s)
					s=tr(s)
					return simpleatom(s) and s or ("("..s..")")
				end
				local function splitfields(s)
					local out={}
					local start=1
					local dp,db,ds=0,0,0
					local quote=nil
					local esc=false
					for i=1,#s do
						local c=s:sub(i,i)
						if quote then
							if esc then esc=false elseif c=="\\" then esc=true elseif c==quote then quote=nil end
						else
							if c=='"' or c=="'" then quote=c
							elseif c=="(" then dp+=1 elseif c==")" then dp-=1
							elseif c=="{" then db+=1 elseif c=="}" then db-=1
							elseif c=="[" then ds+=1 elseif c=="]" then ds-=1
							elseif c=="," and dp==0 and db==0 and ds==0 then
								out[#out+1]=tr(s:sub(start,i-1))
								start=i+1
							end
						end
					end
					local tail=tr(s:sub(start))
					if tail~="" then out[#out+1]=tail end
					return out
				end
				local function renderbuilder(lead,target,inside,sets)
					local fields=splitfields(inside)
					local order={}
					local map={}
					local arr={}
					for _,f in ipairs(fields) do
						local k,v=f:match('^([%a_][%w_]*)%s*=%s*(.+)$')
						if k then
							if not map[k] then order[#order+1]=k end
							map[k]=v
						elseif f~="" then arr[#arr+1]=f end
					end
					for _,p in ipairs(sets) do
						if p.kind=="field" then
							if not map[p.key] then order[#order+1]=p.key end
							map[p.key]=p.value
						elseif p.kind=="index" and type(p.key)=="number" and p.key>=1 and p.key<=#arr+1 then
							arr[p.key]=p.value
						else
							local key=tostring(p.key)
							if not map[key] then order[#order+1]=key end
							map[key]=p.value
						end
					end
					local total=#arr+#order
					if total==0 then return lead..target.." = {}" end
					local pieces={}
					for i=1,#arr do pieces[#pieces+1]=arr[i] end
					for _,k in ipairs(order) do
						if ident(k) then pieces[#pieces+1]=k.." = "..map[k] else pieces[#pieces+1]="["..k.."] = "..map[k] end
					end
					local one=lead..target.." = {"..table.concat(pieces,", ").."}"
					if #one<=150 and total<=5 then return one end
					local out={lead..target.." = {"}
					for _,p in ipairs(pieces) do out[#out+1]=lead.."\t"..p.."," end
					out[#out+1]=lead.."}"
					return table.concat(out,"\n")
				end
				local function compactlocals(a)
					local out={}
					local i=1
					while i<=#a do
						local lead,name=a[i]:match('^(\t*)local%s+([%a_][%w_]*)%s*$')
						if lead and name then
							local names={name}
							local seen={[name]=true}
							local j=i+1
							while j<=#a do
								local l2,n2=a[j]:match('^(\t*)local%s+([%a_][%w_]*)%s*$')
								if l2~=lead or not n2 then break end
								if not seen[n2] then names[#names+1]=n2 seen[n2]=true end
								j+=1
							end
							if #names>=2 then
								table.sort(names,function(x,y)
									local nx=tonumber(x:match('^v(%d+)$'))
									local ny=tonumber(y:match('^v(%d+)$'))
									if nx and ny then return nx<ny end
									return x<y
								end)
								out[#out+1]=lead.."local "..table.concat(names,", ") i=j
							else out[#out+1]=a[i] i+=1 end
						else
							local l,n=a[i]:match('^(\t*)local%s+([%a_][%w_]*)%s*=%s*nil%s*$')
							out[#out+1]=(l and n) and (l.."local "..n) or a[i]
							i+=1
						end
					end
					return out
				end
				local function parsevassign(line)
					local lead,var,rhs=line:match('^(\t*)local%s+([%a_][%w_]*)%s*=%s*(.+)$')
					if lead then return lead,true,var,rhs end
					lead,var,rhs=line:match('^(\t*)([%a_][%w_]*)%s*=%s*(.+)$')
					if lead then return lead,false,var,rhs end
					return nil
				end
				local function redefsoon(a,from,var,depth)
					for k=from,#a do
						local t=tr(a[k])
						local d=dep(a[k])
						if d<depth then return true end
						if d==depth then
							if t=="end" or t=="else" or t:match('^elseif%s+') or t:match('^until%s+') then return true end
							if t:match('^'..var..'%s*=') or t:match('^local%s+'..var..'%s*=') then return true end
							if countword(t,var)>0 then return false end
							if t:match('^return') then return true end
						end
					end
					return true
				end
				local function foldaliases(a)
					for _=1,16 do
						local changed=false
						local del={}
						for i=1,#a-1 do
							if not del[i] then
								local lead,islocal,var,rhs=parsevassign(a[i])
								if lead and dep(a[i+1])==#lead then
									local t2=tr(a[i+1])
									local args=t2:match('^'..var..'%s*=%s*'..var..'%((.*)%)$')
									if args then
										a[i+1]=lead..(islocal and "local " or "")..var.." = "..tr(rhs).."("..args..")"
										del[i]=true changed=true
									else
										local lhs=t2:match('^(.+)%s*=%s*'..var..'$')
										if lhs and not lhs:match('^'..var..'%f[^%w_]') and redefsoon(a,i+2,var,#lead) then
											a[i+1]=lead..lhs.." = "..tr(rhs)
											del[i]=true changed=true
										end
									end
								end
							end
						end
						if not changed then break end
						local n={}
						for i,line in ipairs(a) do if not del[i] then n[#n+1]=line end end
						a=n
					end
					return a
				end
				local function foldbuilders(a)
					for _=1,10 do
						local changed=false
						local out={}
						local i=1
						while i<=#a do
							local lead,islocal,var,rhs=parsevassign(a[i])
							local inside=rhs and rhs:match('^{(.*)}%s*$')
							if lead and var and inside then
								local sets={}
								local j=i+1
								local target=nil
								while j<=#a and dep(a[j])==#lead do
									local t=tr(a[j])
									local fk,fv=t:match('^'..var..'%.([%a_][%w_]*)%s*=%s*(.+)$')
									local ik,iv=t:match('^'..var..'%[(%-?%d+)%]%s*=%s*(.+)$')
									local lhs=t:match('^(.+)%s*=%s*'..var..'$')
									if fk then
										sets[#sets+1]={kind="field",key=fk,value=fv}
									elseif ik then
										sets[#sets+1]={kind="index",key=tonumber(ik),value=iv}
									elseif lhs and not lhs:match('^'..var..'%f[^%w_]') and redefsoon(a,j+1,var,#lead) then
										target=lhs
										break
									else
										break
									end
									j+=1
								end
								if target then
									local rendered=renderbuilder(lead,target,inside,sets)
									for line in (rendered.."\n"):gmatch("(.-)\n") do out[#out+1]=line end
									i=j+1
									changed=true
								else
									out[#out+1]=a[i]
									i+=1
								end
							else
								out[#out+1]=a[i]
								i+=1
							end
						end
						a=out
						if not changed then break end
					end
					return a
				end
				local function renameconfig(a)
					local candidate=nil
					local ci=nil
					local base=nil
					for i,line in ipairs(a) do
						local lead,var=line:match('^(\t*)local%s+([%a_][%w_]*)%s*=%s*{}%s*$')
						if lead then
							for j=#a,i+1,-1 do
								if dep(a[j])==#lead and tr(a[j])=="return "..var then candidate=var ci=i base=#lead break end
							end
						end
						if candidate then break end
					end
					if not candidate then return a end
					local bad=false
					for i,line in ipairs(a) do
						if i~=ci and countword(line,candidate)>0 then
							local t=tr(line)
							if t~="return "..candidate and not t:match('^'..candidate..'%.([%a_][%w_]*)%s*=') and not t:match('^'..candidate..'%[.+%]%s*=') then bad=true break end
						end
					end
					if bad then return a end
					for i,line in ipairs(a) do a[i]=replaceword(line,candidate,"config") end
					return a
				end
				local function bracechange(s)
					local d=0
					local quote=nil
					local esc=false
					for i=1,#s do
						local c=s:sub(i,i)
						if quote then
							if esc then esc=false elseif c=="\\" then esc=true elseif c==quote then quote=nil end
						else
							if c=='"' or c=="'" then quote=c elseif c=="{" then d+=1 elseif c=="}" then d-=1 end
						end
					end
					return d
				end
				local function foldconfigtable(a)
					local si,ei,base,lead
					for i,line in ipairs(a) do
						local l=line:match('^(\t*)local%s+config%s*=%s*{}%s*$')
						if l then si=i base=#l lead=l break end
					end
					if not si then return a end
					for i=#a,si+1,-1 do
						if dep(a[i])==base and tr(a[i])=="return config" then ei=i break end
					end
					if not ei then return a end
					local fields={}
					local i=si+1
					while i<ei do
						if tr(a[i])=="" then i+=1 continue end
						if dep(a[i])~=base then return a end
						local key,rhs=tr(a[i]):match('^config%.([%a_][%w_]*)%s*=%s*(.+)$')
						if not key or countword(rhs,"config")>0 then return a end
						local block={rhs}
						local bal=bracechange(rhs)
						local j=i+1
						while bal>0 and j<ei do
							block[#block+1]=a[j]
							bal+=bracechange(a[j])
							j+=1
						end
						if bal~=0 then return a end
						fields[#fields+1]={key=key,block=block}
						i=j
					end
					if #fields<4 then return a end
					local repl={lead.."local config = {"}
					for _,f in ipairs(fields) do
						if #f.block==1 then
							repl[#repl+1]=lead.."\t"..f.key.." = "..tr(f.block[1]).."," 
						else
							repl[#repl+1]=lead.."\t"..f.key.." = "..tr(f.block[1])
							for k=2,#f.block-1 do
								local ln=f.block[k]
								local stripped=ln:gsub("^"..lead,"")
								repl[#repl+1]=lead.."\t"..stripped
							end
							local last=tr(f.block[#f.block])
							repl[#repl+1]=lead.."\t"..last.."," 
						end
					end
					repl[#repl+1]=lead.."}"
					local out={}
					for k=1,si-1 do out[#out+1]=a[k] end
					for _,line in ipairs(repl) do out[#out+1]=line end
					out[#out+1]=lead.."return config"
					for k=ei+1,#a do out[#out+1]=a[k] end
					return out
				end
				local function tableinside2(expr)
					expr=tr(expr)
					if expr:sub(1,1)=="{" and expr:sub(-1)=="}" then return expr:sub(2,-2) end
					return nil
				end
				local function topassign2(s)
					local dp,db,ds=0,0,0
					local quote=nil
					local esc=false
					for i=1,#s do
						local c=s:sub(i,i)
						if quote then
							if esc then esc=false elseif c=="\\" then esc=true elseif c==quote then quote=nil end
						else
							if c=='"' or c=="'" then quote=c
							elseif c=="(" then dp+=1 elseif c==")" then dp-=1
							elseif c=="{" then db+=1 elseif c=="}" then db-=1
							elseif c=="[" then ds+=1 elseif c=="]" then ds-=1
							elseif c=="=" and dp==0 and db==0 and ds==0 then
								local p=s:sub(i-1,i-1)
								local n=s:sub(i+1,i+1)
								if p~="=" and p~="<" and p~=">" and p~="~" and n~="=" then
									return tr(s:sub(1,i-1)),tr(s:sub(i+1))
								end
							end
						end
					end
					return nil
				end
				local function prettyexpr2(expr)
					expr=tr(expr)
					if not expr:find('"',1,true) and not expr:find("'",1,true) then
						expr=expr:gsub(",%s*", ", ")
						if GENV.DEX_PRETTY_FLOATS~=false and not expr:find("e",1,true) and not expr:find("E",1,true) then
							expr=expr:gsub("([%-]?%d+%.%d%d%d%d%d%d%d+)",function(tok)
								local n=tonumber(tok)
								if not n then return tok end
								for d=0,6 do
									local m=10^d
									local r
									if n>=0 then r=math.floor(n*m+0.5)/m else r=math.ceil(n*m-0.5)/m end
									if math.abs(n-r)<=math.max(1,math.abs(n))*5e-8 then
										if d==0 then return tostring(math.floor(r)) end
										local txt=string.format("%."..d.."f",r):gsub("0+$",""):gsub("%.$","")
										if txt=="-0" then txt="0" end
										return txt
									end
								end
								return tok
							end)
						end
					end
					return expr
				end
				local function formatvalue2(expr,indent)
					expr=tr(expr)
					local inside=tableinside2(expr)
					if inside==nil then return prettyexpr2(expr) end
					local fs=splitfields(inside)
					if #fs==0 then return "{}" end
					local items={}
					local compact=true
					for _,f in ipairs(fs) do
						local l,r=topassign2(f)
						local prefix=""
						local value
						if l then
							value=r
							if ident(l) then prefix=l.." = " else prefix=l.." = " end
						else
							value=tr(f)
						end
						local fv=formatvalue2(value,indent.."\t")
						if fv:find("\n",1,true) then compact=false end
						items[#items+1]={prefix=prefix,value=fv}
					end
					local one={}
					for _,it in ipairs(items) do one[#one+1]=it.prefix..it.value end
					local oneText="{"..table.concat(one,", ").."}"
					if compact and #items<=(tonumber(GENV.DEX_PRETTY_INLINE_FIELDS) or 5) and #oneText<=(tonumber(GENV.DEX_PRETTY_INLINE_WIDTH) or 140) then return oneText end
					local out={"{"}
					for _,it in ipairs(items) do
						local fv=it.value
						local nl=fv:find("\n",1,true)
						if not nl then
							out[#out+1]=indent.."\t"..it.prefix..fv.."," 
						else
							local first=true
							for ln in (fv.."\n"):gmatch("(.-)\n") do
								if first then
									out[#out+1]=indent.."\t"..it.prefix..ln
									first=false
								else
									out[#out+1]=ln
								end
							end
							out[#out]=out[#out].."," 
						end
					end
					out[#out+1]=indent.."}"
					return table.concat(out,"\n")
				end
				local function renderbuilder2(lead,target,inside,sets)
					local fs=splitfields(inside or "")
					local order={}
					local values={}
					local arr={}
					for _,f in ipairs(fs) do
						local l,r=topassign2(f)
						if l and ident(l) then
							if values[l]==nil then order[#order+1]=l end
							values[l]=r
					elseif l then
							local k="@"..l
							if values[k]==nil then order[#order+1]=k end
							values[k]=r
					elseif tr(f)~="" then
							arr[#arr+1]=tr(f)
					end
					end
					for _,p in ipairs(sets or {}) do
						if p.kind=="field" then
							if values[p.key]==nil then order[#order+1]=p.key end
							values[p.key]=p.value
					elseif p.kind=="index" and p.key and p.key>=1 and p.key<=#arr+1 then
							arr[p.key]=p.value
					else
							local k="@"..tostring(p.key)
							if values[k]==nil then order[#order+1]=k end
							values[k]=p.value
						end
					end
					local pieces={}
					for i=1,#arr do pieces[#pieces+1]=arr[i] end
					for _,k in ipairs(order) do
						if k:sub(1,1)=="@" then pieces[#pieces+1]=k:sub(2).." = "..values[k]
						else pieces[#pieces+1]=k.." = "..values[k] end
					end
					local expr="{"..table.concat(pieces,", ").."}"
					return lead..target.." = "..formatvalue2(expr,lead)
				end
				local function collectrhs2(a,i,rhs)
					local parts={rhs}
					local bal=bracechange(rhs)
					local j=i+1
					while bal>0 and j<=#a do
						parts[#parts+1]=a[j]
						bal+=bracechange(a[j])
						j+=1
					end
					if bal~=0 then return nil,i end
					return table.concat(parts,"\n"),j-1
				end
				local function joinlocalassign2(a)
					local out={}
					local i=1
					while i<=#a do
						local lead,var=a[i]:match('^(\t*)local%s+([%a_][%w_]*)%s*$')
						if lead and i<#a then
							local l2,v2,rhs=a[i+1]:match('^(\t*)([%a_][%w_]*)%s*=%s*(.+)$')
							if l2==lead and v2==var then
								out[#out+1]=lead.."local "..var.." = "..rhs
								i+=2
							else out[#out+1]=a[i] i+=1 end
						else out[#out+1]=a[i] i+=1 end
					end
					return out
				end
				local function foldbuilders2(a)
					for _=1,32 do
						local changed=false
						local out={}
						local i=1
						while i<=#a do
							local lead,islocal,var,rhs=parsevassign(a[i])
							if lead and var and rhs and tr(rhs):sub(1,1)=="{" then
								local whole,ie=collectrhs2(a,i,rhs)
								local inside=whole and tableinside2(whole)
								if inside~=nil then
									local sets={}
									local j=ie+1
									local target=nil
									local targetEnd=nil
									while j<=#a and dep(a[j])==#lead do
										local t=tr(a[j])
										local fk,fv=t:match('^'..var..'%.([%a_][%w_]*)%s*=%s*(.*)$')
										local ik,iv=t:match('^'..var..'%[(%-?%d+)%]%s*=%s*(.*)$')
										if fk and fv~="" then
											local val,je=collectrhs2(a,j,fv)
											sets[#sets+1]={kind="field",key=fk,value=val}
											j=je+1
										elseif ik and iv~="" then
											local val,je=collectrhs2(a,j,iv)
											sets[#sets+1]={kind="index",key=tonumber(ik),value=val}
											j=je+1
										else
											local lhs=t:match('^(.+)%s*=%s*'..var..'%s*$')
											if lhs and not lhs:match('^'..var..'%f[^%w_]') then target=lhs targetEnd=j end
											break
										end
									end
									if target then
										local rendered=renderbuilder2(lead,target,inside,sets)
										for ln in (rendered.."\n"):gmatch("(.-)\n") do out[#out+1]=ln end
										i=targetEnd+1
										changed=true
									else
										for k=i,ie do out[#out+1]=a[k] end
										i=ie+1
									end
								else out[#out+1]=a[i] i+=1 end
							else out[#out+1]=a[i] i+=1 end
						end
						a=out
						if not changed then break end
					end
					return a
				end
				local function renameconfig2(a)
					if table.concat(a,"\n"):match('%f[%w_]config%f[^%w_]') then return a end
					for i,line in ipairs(a) do
						local lead,var,rhs=line:match('^(\t*)local%s+([%a_][%w_]*)%s*=%s*(.+)$')
						if lead and rhs and tr(rhs):sub(1,1)=="{" then
							local base=#lead
							local ri=nil
							for j=#a,i+1,-1 do
								if dep(a[j])==base and tr(a[j])=="return "..var then ri=j break end
							end
							if ri then
								local shadow=false
								for j=i+1,ri do if tr(a[j]):match('^local%s+'..var..'%f[^%w_]') then shadow=true break end end
								if not shadow then
									for j=i,ri do a[j]=replaceword(a[j],var,"config") end
									return a
								end
							end
						end
					end
					return a
				end
				local function foldrootconfig2(a)
					local i=1
					while i<=#a do
						local lead,rhs=a[i]:match('^(\t*)local%s+config%s*=%s*(.+)$')
						if lead and rhs and tr(rhs):sub(1,1)=="{" then
							local whole,ie=collectrhs2(a,i,rhs)
							local inside=whole and tableinside2(whole)
							if inside~=nil then
								local sets={}
								local j=ie+1
								while j<=#a do
									if tr(a[j])=="" then j+=1 continue end
									if dep(a[j])~=#lead then break end
									local t=tr(a[j])
									local fk,fv=t:match('^config%.([%a_][%w_]*)%s*=%s*(.*)$')
									if not fk or fv=="" then break end
									local val,je=collectrhs2(a,j,fv)
									sets[#sets+1]={kind="field",key=fk,value=val}
									j=je+1
								end
								if #sets>0 then
									local rendered=renderbuilder2(lead,"local config",inside,sets)
									local out={}
									for k=1,i-1 do out[#out+1]=a[k] end
									for ln in (rendered.."\n"):gmatch("(.-)\n") do out[#out+1]=ln end
									for k=j,#a do out[#out+1]=a[k] end
									return out
								end
							end
						end
						i+=1
					end
					return a
				end
				local function foldreceiveraliases2(a)
					local out={}
					local i=1
					while i<=#a do
						local lead,var,rhs=a[i]:match('^(\t*)([%a_][%w_]*)%s*=%s*(.+)$')
						if lead and i<#a and dep(a[i+1])==#lead then
							local field,val=tr(a[i+1]):match('^'..var..'%.([%a_][%w_]*)%s*=%s*(.+)$')
							if field and countword(rhs,var)==0 then
								out[#out+1]=lead..tr(rhs).."."..field.." = "..val
								i+=2
							else out[#out+1]=a[i] i+=1 end
						else out[#out+1]=a[i] i+=1 end
					end
					return out
				end
				local function foldservicechains2(a)
					local out={}
					local i=1
					while i<=#a do
						local lead,var=a[i]:match('^(\t*)([%a_][%w_]*)%s*=%s*game%s*$')
						if lead and i+2<=#a then
							local j=i+1
							local serviceName=nil
							local argVar,argStr=tr(a[j]):match('^([%a_][%w_]*)%s*=%s*"([^"]+)"%s*$')
							if argVar then
								local call=tr(a[j+1])
								local av=call:match('^'..var..'%s*=%s*'..var..':GetService%(([%a_][%w_]*)%)$')
								if av==argVar then serviceName=argStr j+=2 end
							else
								local direct=tr(a[j]):match('^'..var..'%s*=%s*'..var..':GetService%("([^"]+)"%)$')
								if direct then serviceName=direct j+=1 end
							end
							if serviceName then
								local expr='game:GetService("'..serviceName..'")'
								while j<=#a and dep(a[j])==#lead do
									local field=tr(a[j]):match('^'..var..'%s*=%s*'..var..'%.([%a_][%w_]*)$')
									if not field then break end
									expr=expr.."."..field
									j+=1
								end
								if j<=#a and dep(a[j])==#lead and tr(a[j])=="if "..var.." then" then
									out[#out+1]=lead.."if "..expr.." then"
									i=j+1
								else out[#out+1]=a[i] i+=1 end
							else out[#out+1]=a[i] i+=1 end
						else out[#out+1]=a[i] i+=1 end
					end
					return out
				end

				local function controlhead3(t)
					return t:match('^if%s+.+%s+then$') or t:match('^elseif%s+.+%s+then$') or t=='else' or t=='end' or t:match('^while%s+.+%s+do$') or t:match('^for%s+.+%s+do$') or t=='repeat' or t:match('^until%s+') or t=='do' or t:match('^return%f[^%w_]') or t=='return' or t=='break' or t=='continue'
				end
				local function purealias3(rhs)
					rhs=tr(rhs)
					if simpleatom(rhs) then return true end
					if rhs:match('^[%a_][%w_]*([%.][%a_][%w_]*)+$') then return true end
					if rhs:match('^[%a_][%w_]*%[[^%]]+%]$') then return true end
					if rhs:match('^Enum%.[%w_]+%.[%w_]+$') then return true end
					return false
				end
				local function parseassign3(line)
					local lead,loc,var,rhs=line:match('^(\t*)(local%s+)([%a_][%w_]*)%s*=%s*(.+)$')
					if lead then return lead,true,var,rhs end
					lead,var,rhs=line:match('^(\t*)([%a_][%w_]*)%s*=%s*(.+)$')
					if lead then return lead,false,var,rhs end
					return nil
				end
				local function foldselfchains3(a)
					for _=1,24 do
						local changed=false
						local del={}
						for i=1,#a-1 do
							if not del[i] then
								local lead,islocal,var,rhs=parseassign3(a[i])
								if lead and dep(a[i+1])==#lead then
									local t=tr(a[i+1])
									local field=t:match('^'..var..'%s*=%s*'..var..'%.([%a_][%w_]*)$')
									local idx=t:match('^'..var..'%s*=%s*'..var..'%[([^%]]+)%]$')
									local meth,args=t:match('^'..var..'%s*=%s*'..var..':([%a_][%w_]*)%((.*)%)$')
									local callargs=t:match('^'..var..'%s*=%s*'..var..'%((.*)%)$')
									local stmtmeth,stmtargs=t:match('^'..var..':([%a_][%w_]*)%((.*)%)$')
									if field then
										a[i]=lead..(islocal and 'local ' or '')..var..' = '..tr(rhs)..'.'..field
										del[i+1]=true changed=true
									elseif idx then
										a[i]=lead..(islocal and 'local ' or '')..var..' = '..tr(rhs)..'['..idx..']'
										del[i+1]=true changed=true
									elseif meth then
										a[i]=lead..(islocal and 'local ' or '')..var..' = '..tr(rhs)..':'..meth..'('..args..')'
										del[i+1]=true changed=true
									elseif callargs then
										a[i]=lead..(islocal and 'local ' or '')..var..' = '..tr(rhs)..'('..callargs..')'
										del[i+1]=true changed=true
									elseif stmtmeth and purealias3(rhs) then
										a[i+1]=lead..tr(rhs)..':'..stmtmeth..'('..stmtargs..')'
										del[i]=true changed=true
									end
								end
							end
						end
						if not changed then break end
						local n={}
						for i,line in ipairs(a) do if not del[i] then n[#n+1]=line end end
						a=n
					end
					return a
				end
				local function foldsingleusetemps3(a)
					for _=1,24 do
						local changed=false
						local del={}
						for i=1,#a do
							local lead,islocal,var,rhs=parseassign3(a[i])
							if lead and purealias3(rhs) then
								local base=#lead
								local usei=nil
								local uses=0
								local safe=true
								for j=i+1,#a do
									local d=dep(a[j])
									if d<base then break end
									if d==base then
										local t=tr(a[j])
										local _,_,av=parseassign3(a[j])
										if av==var then break end
										if controlhead3(t) and countword(t,var)==0 then break end
										local c=countword(t,var)
										if c>0 then uses+=c usei=j if uses>1 then break end end
										if c==0 and t~='' then
											local _,_,ov,orhs=parseassign3(a[j])
											if not (ov and orhs and purealias3(orhs)) and not t:match('^local%s+[%w_,%s]+$') then safe=false break end
										end
									end
								end
								if safe and uses==1 and usei then
									local t=tr(a[usei])
									local lhs=t:match('^'..var..'%s*=') or t:match('^local%s+'..var..'%s*=')
									if not lhs then
										a[usei]=replaceword(a[usei],var,wrapexpr(rhs))
										del[i]=true changed=true
									end
								end
							end
						end
						if not changed then break end
						local n={}
						for i,line in ipairs(a) do if not del[i] then n[#n+1]=line end end
						a=n
					end
					return a
				end
				local function foldconditiontemps3(a)
					local del={}
					for i=1,#a-1 do
						local lead,islocal,var,rhs=parseassign3(a[i])
						if lead then
							local j=i+1
							while j<=#a and tr(a[j])=='' do j+=1 end
							if j<=#a and dep(a[j])==#lead then
								local t=tr(a[j])
								local cond=t:match('^if%s+(.+)%s+then$') or t:match('^elseif%s+(.+)%s+then$')
								if cond and countword(cond,var)==1 then
									a[j]=replaceword(a[j],var,wrapexpr(rhs))
									del[i]=true
								end
							end
						end
					end
					if next(del) then
						local n={}
						for i,line in ipairs(a) do if not del[i] then n[#n+1]=line end end
						return n
					end
					return a
				end
				local function builtinref3(rhs)
					rhs=tr(rhs)
					if rhs=='require' or rhs=='pcall' or rhs=='warn' or rhs=='print' or rhs=='assert' or rhs=='error' or rhs=='type' or rhs=='typeof' then return true end
					if rhs:match('^task%.[%a_][%w_]*$') or rhs:match('^table%.[%a_][%w_]*$') or rhs:match('^string%.[%a_][%w_]*$') or rhs:match('^math%.[%a_][%w_]*$') or rhs:match('^bit32%.[%a_][%w_]*$') then return true end
					if rhs:match('^CFrame%.[%a_][%w_]*$') or rhs:match('^Vector[23]%.[%a_][%w_]*$') or rhs:match('^Color3%.[%a_][%w_]*$') then return true end
					return false
				end
				local function foldbuiltinaliases3(a)
					for _=1,12 do
						local changed=false
						local del={}
						for i=1,#a do
							local lead,islocal,var,rhs=parseassign3(a[i])
							if lead and builtinref3(rhs) then
								local base=#lead
								local usei=nil
								local uses=0
								for j=i+1,#a do
									local d=dep(a[j])
									if d<base then break end
									local t=tr(a[j])
									if d==base then
										local _,_,av=parseassign3(a[j])
										if av==var then break end
									end
									local c=countword(t,var)
									if c>0 then uses+=c usei=j if uses>1 then break end end
								end
								if uses==1 and usei then
									local t=tr(a[usei])
									if t:match('^'..var..'%s*%(') then
										a[usei]=a[usei]:gsub('%f[%w_]'..var..'%f[^%w_]',tr(rhs),1)
										del[i]=true changed=true
									end
								end
							end
						end
						if not changed then break end
						local n={}
						for i,line in ipairs(a) do if not del[i] then n[#n+1]=line end end
						a=n
					end
					return a
				end
				local function foldfunctionargs3(a)
					local i=1
					while i<=#a do
						local lead,islocal,var,rhs=parseassign3(a[i])
						local args=rhs and tr(rhs):match('^function%s*(%b())%s*$')
						if lead and var and args then
							local base=#lead
							local j=i+1
							while j<=#a do
								if dep(a[j])==base and tr(a[j])=='end' then break end
								j+=1
							end
							if j<=#a then
								local k=j+1
								while k<=#a and tr(a[k])=='' do k+=1 end
								if k<=#a and dep(a[k])==base and countword(a[k],var)==1 then
									local callee=tr(a[k]):match('^([%a_][%w_%.:]*)%('..var..'%)$')
									if callee and countword(table.concat(a,'\n',i+1,j-1),var)==0 then
										a[i]=lead..callee..'(function'..args
										a[j]=lead..'end)'
										table.remove(a,k)
										i=j+1
										continue
									end
								end
							end
						end
						i+=1
					end
					return a
				end
				local function foldarrayassignments3(a)
					local out={}
					local i=1
					while i<=#a do
						local lead,islocal,var,rhs=parseassign3(a[i])
						if lead and var and tr(rhs)=='{}' then
							local vals={}
							local j=i+1
							local want=1
							while j<=#a and dep(a[j])==#lead do
								local idx,val=tr(a[j]):match('^'..var..'%[(%d+)%]%s*=%s*(.+)$')
								if tonumber(idx)~=want or not val then break end
								vals[#vals+1]=val want+=1 j+=1
							end
							if #vals>=2 then
								local expr='{'..table.concat(vals,', ')..'}'
								out[#out+1]=lead..(islocal and 'local ' or '')..var..' = '..formatvalue2(expr,lead)
								i=j
							else out[#out+1]=a[i] i+=1 end
						else out[#out+1]=a[i] i+=1 end
					end
					return out
				end
				local function simplifygenericfor3(a)
					for i,line in ipairs(a) do
						local lead,vars,iter=line:match('^(\t*)for%s+(.+)%s+in%s+(.+),%s*nil,%s*nil%s+do%s*$')
						if lead then a[i]=lead..'for '..vars..' in '..iter..' do' end
					end
					return a
				end
				local function renameservicevars3(a)
					if GENV.DEX_PRETTY_SEMANTIC_LOCALS==false then return a end
					local usedText=table.concat(a,'\n')
					for i,line in ipairs(a) do
						local lead,islocal,var,rhs=parseassign3(line)
						local svc=rhs and tr(rhs):match('^game:GetService%(["\']([%w_]+)["\']%)$')
						if lead and var and svc then
							local name=svc=='Workspace' and 'workspace' or svc
							if ident(name) and (name==svc or name=='workspace') then
								local base=#lead
								a[i]=lead..'local '..name..' = '..tr(rhs)
								local shadow=nil
								for j=i+1,#a do
									local d=dep(a[j])
									if d<base then break end
									if shadow and d<=shadow then shadow=nil end
									local t=tr(a[j])
									if d==base then
										local _,_,av=parseassign3(a[j])
										if av==var then break end
									end
									if d>base and t:match('^local%s+[^=]*%f[%w_]'..var..'%f[^%w_]') then shadow=d end
									if not shadow then a[j]=replaceword(a[j],var,name) end
								end
							end
						end
					end
					return a
				end

				local function renametableiter3(a)
					if GENV.DEX_PRETTY_SEMANTIC_LOCALS==false then return a end
					local wholeText=table.concat(a,'\n')
					local usedModules=countword(wholeText,'modules')>0
					local name=usedModules and 'moduleList' or 'modules'
					for i,line in ipairs(a) do
						local lead,islocal,var,rhs=parseassign3(line)
						if lead and var and rhs and tr(rhs):sub(1,1)=='{' then
							local expr,ie=collectrhs2(a,i,rhs)
							if expr then
								local j=ie+1
								while j<=#a and tr(a[j])=='' do j+=1 end
								if j<=#a and dep(a[j])==#lead then
									local vars,iter=tr(a[j]):match('^for%s+(.+)%s+in%s+(.+)%s+do$')
									if vars and iter and countword(iter,var)==1 then
										local k=j+1
										while k<=#a and not (dep(a[k])==#lead and tr(a[k])=='end') do k+=1 end
										local body=k<=#a and table.concat(a,'\n',j+1,k-1) or ''
										if body:find('require',1,true) or expr:find('.Client',1,true) or expr:find('.Shared',1,true) then
											a[i]=lead..'local '..name..' = '..rhs
											for q=i+1,math.min(k,#a) do a[q]=replaceword(a[q],var,name) end
											return a
										end
									end
								end
							end
						end
					end
					return a
				end
				local function foldbuiltinclosures3(a)
					local i=1
					while i<=#a do
						local lead,islocal,var,rhs=parseassign3(a[i])
						if lead and var and (tr(rhs)=='task.spawn' or tr(rhs)=='task.defer') then
							local base=#lead
							local j=i+1
							while j<=#a and dep(a[j])>base do j+=1 end
							if j<=#a and dep(a[j])==base and tr(a[j]):match('^'..var..'%s*%(%s*function%s*%(') then
								local start=j
								local k=j+1
								while k<=#a and not (dep(a[k])==base and tr(a[k])=='end)') do k+=1 end
								if k<=#a then
									local shadow=false
									local unsafe=false
									for q=start+1,k-1 do
										local tq=tr(a[q])
										if dep(a[q])==base+1 and tq:match('^local%s+[^=]*%f[%w_]'..var..'%f[^%w_]') then shadow=true end
										if countword(tq,var)>0 and not shadow then unsafe=true break end
									end
									if not unsafe then
										a[j]=a[j]:gsub('%f[%w_]'..var..'%f[^%w_]',tr(rhs),1)
										table.remove(a,i)
										continue
									end
								end
							end
						end
						i+=1
					end
					return a
				end
				local function renamemoduleloops3(a)
					if GENV.DEX_PRETTY_SEMANTIC_LOCALS==false then return a end
					for i,line in ipairs(a) do
						local lead,var1,var2,iter=line:match('^(\t*)for%s+([%a_][%w_]*),%s*([%a_][%w_]*)%s+in%s+(.+)%s+do%s*$')
						if lead then
							local base=#lead
							local j=i+1
							while j<=#a and not (dep(a[j])==base and tr(a[j])=='end') do j+=1 end
							if j<=#a then
								local body=table.concat(a,'\n',i+1,j-1)
								local n1=countword(body,var1)
								local moduleish=body:match('require%s*%(%s*'..var2..'%s*%)') or body:match('pcall%s*%(%s*require%s*,%s*'..var2..'%s*%)') or body:match(var2..':GetFullName%s*%(')
								local new1=n1==0 and '_' or var1
								local new2=moduleish and 'module' or var2
								if new2~=var2 then
									for k=i+1,j-1 do a[k]=replaceword(a[k],var2,new2) end
								end
								if new1~=var1 or new2~=var2 then a[i]=lead..'for '..new1..', '..new2..' in '..iter..' do' end
							end
						end
					end
					return a
				end
				local function foldpcallrequire3(a)
					for i=1,#a-2 do
						local l0,loc0,v0,r0=parseassign3(a[i])
						local l1,loc1,v1,r1=parseassign3(a[i+1])
						if l0 and l1==l0 and tr(r0)=='pcall' and tr(r1)=='require' then
							local t=tr(a[i+2])
							local arg=t:match('^'..v0..'%s*,%s*'..v1..'%s*=%s*'..v0..'%s*%(%s*'..v1..'%s*,%s*(.+)%)$')
							if arg then
								a[i]=l0..'local success, result = pcall(require, '..arg..')'
								table.remove(a,i+2) table.remove(a,i+1)
								local base=#l0
								for j=i+1,#a do
									if dep(a[j])<base then break end
									a[j]=replaceword(a[j],v0,'success')
									a[j]=replaceword(a[j],v1,'result')
								end
								return a
							end
						end
					end
					return a
				end
				local function prunelocaldecls3(a)
					local text=table.concat(a,'\n')
					local out={}
					for i,line in ipairs(a) do
						local lead,namestr=line:match('^(\t*)local%s+([%a_][%w_]*(%s*,%s*[%a_][%w_]*)+)%s*$')
						if lead and namestr then
							local keep={}
							for n in namestr:gmatch('[%a_][%w_]*') do
								local c=countword(text,n)-countword(line,n)
								if c>0 then keep[#keep+1]=n end
							end
							if #keep>0 then out[#out+1]=lead..'local '..table.concat(keep,', ') end
						else out[#out+1]=line end
					end
					return out
				end
				local function removejunk2(a)
					local out={}
					local last=nil
					for _,line in ipairs(a) do
						local t=tr(line)
						local lhs,rhs=t:match('^([%a_][%w_]*)%s*=%s*([%a_][%w_]*)$')
						local drop=lhs and rhs and lhs==rhs
						if not drop and last and t==last then
							local _,drhs=t:match('^([%a_][%w_]*)%s*=%s*(.+)$')
							if drhs and simpleatom(drhs) then drop=true end
						end
						if not drop then out[#out+1]=line last=t end
					end
					return out
				end
				local function foldconditiontemps2(a)
					local del={}
					for i=1,#a-1 do
						local lead,islocal,var,rhs=parsevassign(a[i])
						if lead and var and rhs and simpleatom(rhs) then
							local ni=i+1
							while ni<=#a and tr(a[ni])=="" do ni+=1 end
							if ni<=#a and dep(a[ni])==#lead then
								local t=tr(a[ni])
								local cond=t:match('^if%s+(.+)%s+then$') or t:match('^elseif%s+(.+)%s+then$')
								if cond and countword(cond,var)==1 then
									local uses=0
									for j=ni,#a do
										local tj=tr(a[j])
										if j>ni and dep(a[j])<=#lead then
											local _,_,v2=parsevassign(a[j])
											if v2==var then break end
										end
										uses+=countword(a[j],var)
										if uses>1 then break end
									end
									if uses==1 then
										a[ni]=replaceword(a[ni],var,tr(rhs))
										del[i]=true
									end
								end
							end
						end
					end
					if next(del) then
						local out={}
						for i,line in ipairs(a) do if not del[i] then out[#out+1]=line end end
						return out
					end
					return a
				end
				local function flattenGuardClauses2(a)
					if GENV.DEX_PRETTY_FLATTEN_GUARDS==false then return a end
					for _=1,32 do
						local stack={}
						local pairs={}
						for i,line in ipairs(a) do
							local t=tr(line)
							local kind=nil
							if t:match('^if%s+.+%s+then$') then kind="if"
							elseif t:match('^while%s+.+%s+do$') then kind="while"
							elseif t:match('^for%s+.+%s+do$') then kind="for"
							elseif t=="repeat" then kind="repeat"
							elseif t=="do" then kind="do"
							elseif t:match('^local%s+function%s+') or t:match('^function%s+') or t:find('=%s*function%s*%(') then kind="function" end
							if kind then
								stack[#stack+1]={kind=kind,start=i,elsei=nil}
							elseif t=="else" then
								local top=stack[#stack]
								if top and top.kind=="if" then top.elsei=i end
							elseif t:match('^elseif%s+') then
								local top=stack[#stack]
								if top and top.kind=="if" then top.elseifed=true end
							elseif t=="end" then
								local top=stack[#stack]
								if top and top.kind~="repeat" then
									stack[#stack]=nil
									if top.kind=="if" then pairs[#pairs+1]={start=top.start,elsei=top.elsei,finish=i,elseifed=top.elseifed} end
								end
							elseif t:match('^until%s+') then
								local top=stack[#stack]
								if top and top.kind=="repeat" then stack[#stack]=nil end
							end
						end
						local changed=false
						for pi=#pairs,1,-1 do
							local pif=pairs[pi]
							if pif.elsei and not pif.elseifed then
								local j=pif.elsei-1
								while j>pif.start and tr(a[j])=="" do j-=1 end
								local last=tr(a[j] or "")
								if last=="return" or last:match('^return%s+') then
									local lead=a[pif.start]:match('^(\t*)') or ""
									local out={}
									for k=1,#a do
										if k==pif.elsei then
											out[#out+1]=lead.."end"
										elseif k==pif.finish then
										elseif k>pif.elsei and k<pif.finish then
											local line=a[k]
											if line:sub(1,#lead+1)==lead.."\t" then line=lead..line:sub(#lead+2) end
											out[#out+1]=line
										else
											out[#out+1]=a[k]
										end
									end
									a=out
									changed=true
									break
								end
							end
						end
						if not changed then break end
					end
					return a
				end

				local function camelname4(s)
					if type(s)~="string" then return nil end
					s=s:gsub("[^%w_ ]"," "):gsub("_"," ")
					local out=""
					for part in s:gmatch("[%w]+") do
						if out=="" then out=part:sub(1,1):lower()..part:sub(2)
						else out=out..part:sub(1,1):upper()..part:sub(2) end
					end
					if out=="" or out:match("^%d") or not ident(out) then return nil end
					return out
				end
				local function saferename4(a,old,new,starti,endi,base)
					if not old or not new or old==new then return end
					local text=table.concat(a,"\n")
					if countword(text,new)>0 then
						local n=2
						local root=new
						while countword(text,new)>0 do new=root..tostring(n) n+=1 end
					end
					for j=starti,math.min(endi or #a,#a) do
						if dep(a[j])<base then break end
						a[j]=replaceword(a[j],old,new)
					end
				end
				local function renameinstances4(a)
					local used={}
					for _,line in ipairs(a) do
						for n in tr(line):gmatch("%f[%a_][%a_][%w_]*%f[^%w_]") do used[n]=true end
					end
					local i=1
					while i<=#a do
						local lead,islocal,var,rhs=parseassign3(a[i])
						if lead and islocal and var and rhs then
							local class=tr(rhs):match('^Instance%.new%("([%w_]+)"%)$')
							local special
							if not class then
								if tr(rhs):match('Players%.LocalPlayer:WaitForChild%("PlayerGui"%)') then special="playerGui"
								elseif tr(rhs):match(':WaitForChild%("PlayerGui"%)') then special="playerGui" end
							end
							if class or special then
								local base=#lead
								local stop=#a
								local objname=special
								if class then
									local fallback={
										ScreenGui="screenGui",BillboardGui="billboardGui",Frame="frame",ImageLabel="imageLabel",TextLabel="textLabel",TextButton="textButton",
										UIGradient="gradient",UIStroke="stroke",UIScale="uiScale",NumberValue="progress",UICorner="corner",ImageButton="imageButton",
										Folder="folder",Part="part",Model="model",Attachment="attachment",Sound="sound"
									}
									objname=fallback[class] or camelname4(class)
									for j=i+1,#a do
										local d=dep(a[j])
										if d<base then stop=j-1 break end
										if d==base then
											local _,_,av=parseassign3(a[j])
											if av==var then stop=j-1 break end
											local nm=tr(a[j]):match('^'..var..'%.Name%s*=%s*"([^"]+)"$')
											if nm then objname=camelname4(nm) or objname break end
										end
									end
								end
								if objname and objname~=var then
									local root=objname
									local n=2
									while used[objname] and objname~=var do objname=root..tostring(n) n+=1 end
									used[objname]=true
									for j=i,stop do a[j]=replaceword(a[j],var,objname) end
								end
							end
						end
						i+=1
					end
					return a
				end
				local function foldservicevars4(a)
					local i=1
					while i<=#a-1 do
						local l0,loc0,v0,r0=parseassign3(a[i])
						local l1,loc1,v1,r1=parseassign3(a[i+1])
						if l0 and l1==l0 and v0==v1 and tr(r0)=="game" then
							local svc=tr(r1):match('^'..v0..':GetService%("([%w_]+)"%)$')
							if svc then
								local name=svc=="Workspace" and "workspace" or svc
								if ident(name) then
									local text=table.concat(a,"\n")
									if countword(text,name)>0 then
										local root=name
										local n=2
										while countword(text,name)>0 do name=root..tostring(n) n+=1 end
									end
									a[i]=l0.."local "..name..' = game:GetService("'..svc..'")'
									table.remove(a,i+1)
									local base=#l0
									local j=i+1
									while j<=#a do
										if dep(a[j])<base then break end
										if dep(a[j])==base then
											local _,_,av=parseassign3(a[j])
											if av==v0 then break end
										end
										a[j]=replaceword(a[j],v0,name)
										j+=1
									end
									i+=1
									continue
								end
							end
						end
						i+=1
					end
					return a
				end
				local function folditerprep4(a)
					local i=1
					while i<=#a-3 do
						local l0,loc0,v0,r0=parseassign3(a[i])
						local l1,loc1,v1,r1=parseassign3(a[i+1])
						if l0 and l1==l0 and tr(r0)=="ipairs" and v0 and v1 and r1 then
							local t2=tr(a[i+2])
							local third=t2:match('^'..v0..'%s*,%s*'..v1..'%s*,%s*([%a_][%w_]*)%s*=%s*'..v0..'%s*%(%s*'..v1..'%s*%)$')
							if third then
								local lead,iv1,iv2,iiter=a[i+3]:match('^(\t*)for%s+([%a_][%w_]*),%s*([%a_][%w_]*)%s+in%s+(.+)%s+do%s*$')
								if lead==l0 and iiter and countword(iiter,v0)==1 and countword(iiter,v1)==1 and countword(iiter,third)==1 then
									local item=iv2
									if item:match("^v%d+_?%d*$") then item="item" end
									a[i]=l0.."for "..(iv1:match("^v%d+_?%d*$") and "_" or iv1)..", "..item.." in ipairs("..tr(r1)..") do"
									table.remove(a,i+3)
									table.remove(a,i+2)
									table.remove(a,i+1)
									local depth=#l0
									local j=i+1
									while j<=#a do
										if dep(a[j])==depth and tr(a[j])=="end" then break end
										a[j]=replaceword(a[j],iv2,item)
										j+=1
									end
									i+=1
									continue
								end
							end
						end
						i+=1
					end
					return a
				end
				local function foldkeymaps4(a)
					local out={}
					local i=1
					while i<=#a do
						local lead,islocal,var,rhs=parseassign3(a[i])
						if lead and islocal and var and tr(rhs)=="{}" then
							local pairs={}
							local j=i+1
							while j<=#a and dep(a[j])==#lead do
								local key,val=tr(a[j]):match('^'..var..'%[(.+)%]%s*=%s*(.+)$')
								if not key then break end
								pairs[#pairs+1]={key=key,value=val}
								j+=1
							end
							if #pairs>=3 then
								local joined=""
								for _,p0 in ipairs(pairs) do joined=joined..p0.key.." "..p0.value.." " end
								local name
								if joined:find("Enum.KeyCode.Button",1,true) or joined:find("DPad",1,true) then name="gamepadButtonImages"
								elseif joined:find("backspace.png",1,true) or joined:find("shift.png",1,true) then name="keyboardButtonImages"
								elseif joined:find("Controls/",1,true) then name="keyImages"
								elseif joined:find("Enum.KeyCode.",1,true) then name="keyNames" end
								if name then
									local block={lead.."local "..name.." = {"}
									for _,p0 in ipairs(pairs) do block[#block+1]=lead.."\t["..p0.key.."] = "..prettyexpr2(p0.value).."," end
									block[#block+1]=lead.."}"
									for _,ln in ipairs(block) do out[#out+1]=ln end
									for k=j,#a do a[k]=replaceword(a[k],var,name) end
									i=j
								else
									out[#out+1]=a[i] i+=1
								end
							else out[#out+1]=a[i] i+=1 end
						else out[#out+1]=a[i] i+=1 end
					end
					return out
				end
				local function invalidreceiver4(lhs)
					lhs=tr(lhs)
					local recv=lhs:match('^(.+)%.([%a_][%w_]*)$')
					if not recv then return false end
					recv=tr(recv)
					if recv:match('^["\']') or recv:match('^[%+%-]?%d') or recv=="true" or recv=="false" or recv=="nil" then return true end
					if recv:match('^Enum%.[%w_]+%.[%w_]+$') then return true end
					return false
				end
				local function semanticvalid4(a)
					for _,line in ipairs(a) do
						local t=tr(line)
						local lhs=topassign2(t)
						if lhs and invalidreceiver4(lhs) then return false end
						if t:match('^Instance%.new%b()%.') and t:find("%s*=",1) then return false end
					end
					return true
				end
				local function foldpackmove4(a)
					local out={}
					local i=1
					while i<=#a do
						if i+2<=#a then
							local lead,dst=a[i]:match("^(%s*)local%s+([%a_][%w_]*)%s*=%s*{}%s*$")
							if dst then
								local lead2,tmp,args=a[i+1]:match("^(%s*)local%s+([%a_][%w_]*)%s*=%s*table%.pack%((.*)%)%s*$")
								if tmp and lead2==lead then
									local lead3,t1,t2,t3=a[i+2]:match("^(%s*)table%.move%(([%a_][%w_]*),%s*1,%s*([%a_][%w_]*)%.n,%s*1,%s*([%a_][%w_]*)%)%s*$")
									if lead3==lead and t1==tmp and t2==tmp and t3==dst then
										out[#out+1]=lead.."local "..dst.." = {"..args.."}"
										i+=3
									else out[#out+1]=a[i] i+=1 end
								else out[#out+1]=a[i] i+=1 end
							else out[#out+1]=a[i] i+=1 end
						else out[#out+1]=a[i] i+=1 end
					end
					return out
				end
				local function elseifclean4(a)
					local skip={}
					local repl={}
					local function lead(line) return line:match("^(%s*)") or "" end
					for i=1,#a-1 do
						if not skip[i] and tr(a[i])=="else" then
							local base=lead(a[i])
							local child=lead(a[i+1])
							local cond=tr(a[i+1]):match("^if%s+(.+)%s+then$")
							if cond and #child>#base then
								local close=nil
								for j=i+2,#a do
									local lj=lead(a[j])
									if #lj<#child then break end
									if lj==child and tr(a[j])=="end" then close=j break end
								end
								if close then
									repl[i]=base.."elseif "..cond.." then"
									skip[i+1]=true
									skip[close]=true
									for k=i+2,close-1 do
										if a[k]:sub(1,#child)==child then a[k]=base..a[k]:sub(#child+1) end
									end
								end
							end
						end
					end
					local out={}
					for i=1,#a do if not skip[i] then out[#out+1]=repl[i] or a[i] end end
					return out
				end
				local function structuralclean4(a)
					local out={}
					local i=1
					local function lead(line) return line:match("^(%s*)") or "" end
					while i<=#a do
						local t=tr(a[i])
						local cond=t:match("^if%s+(.+)%s+then$")
						if cond and i+1<=#a and tr(a[i+1])=="else" and lead(a[i+1])==lead(a[i]) then
							local inv
							if cond:match("^%(not%s+.+%)$") then inv=cond:match("^%(not%s+(.+)%)$")
							elseif cond:match("^not%s+.+$") then inv=cond:match("^not%s+(.+)$")
							else inv="not ("..cond..")" end
							out[#out+1]=lead(a[i]).."if "..inv.." then"
							i+=2
						elseif cond and i+1<=#a and tr(a[i+1])=="end" and lead(a[i+1])==lead(a[i]) then
							i+=2
						elseif cond and i+4<=#a and tr(a[i+2])=="else" and tr(a[i+4])=="end" and lead(a[i+2])==lead(a[i]) and lead(a[i+4])==lead(a[i]) then
							local l1=tr(a[i+1])
							local l2=tr(a[i+3])
							if l1==l2 and topassign2(l1) then
								out[#out+1]=lead(a[i])..l1
								i+=5
							else out[#out+1]=a[i] i+=1 end
						else
							out[#out+1]=a[i] i+=1
						end
					end
					return out
				end
				local function safesimplify4(a)
					a=joinlocalassign2(a)
					a=foldservicevars4(a)
					a=foldarrayassignments3(a)
					a=folditerprep4(a)
					a=simplifygenericfor3(a)
					a=renameservicevars3(a)
					a=renameinstances4(a)
					a=foldkeymaps4(a)
					a=renamemoduleloops3(a)
					a=prunelocaldecls3(a)
					return a
				end
				final=compactlocals(final)
				if GENV.DEX_PRETTY_MODE~="off" then
					local baseline={}
					for i,line in ipairs(final) do baseline[i]=line end
					if GENV.DEX_SSA_SAFE_PRETTY~=false then
						local prettyApplied=0
						local prettyRejected=0
						local function clone4(a)
							local o={}
							for i,line in ipairs(a) do o[i]=line end
							return o
						end
						local function transaction4(pass,a)
							local ok,cand=pcall(pass,clone4(a))
							if ok and type(cand)=="table" and semanticvalid4(cand) then
								prettyApplied+=1
								return cand
							end
							prettyRejected+=1
							return a
						end
						local passes={
							joinlocalassign2,
							foldselfchains3,
							foldsingleusetemps3,
							foldconditiontemps3,
							foldbuiltinaliases3,
							foldfunctionargs3,
							foldpackmove4,
							foldarrayassignments3,
							simplifygenericfor3,
							renametableiter3,
							renameservicevars3,
							renameinstances4,
							foldkeymaps4,
							renamemoduleloops3,
							foldbuiltinclosures3,
							foldpcallrequire3,
							foldaliases,
							foldbuilders,
							foldbuilders2,
							renameconfig2,
							foldrootconfig2,
							foldservicechains2,
							foldservicevars4,
							elseifclean4,
							structuralclean4,
							prunelocaldecls3,
							compactlocals,
						}
						for _=1,2 do
							for _,pass in ipairs(passes) do final=transaction4(pass,final) end
						end
						if depth==0 then
							GENV.DEX_LAST_PRETTY={version=DECOMPILER_VERSION,applied=prettyApplied,rejected=prettyRejected,baselineLines=#baseline,finalLines=#final}
						end
					else
						final=joinlocalassign2(final)
						final=foldselfchains3(final)
						final=foldsingleusetemps3(final)
						final=foldconditiontemps3(final)
						final=foldbuiltinaliases3(final)
						final=foldfunctionargs3(final)
						final=foldpackmove4(final)
						final=foldarrayassignments3(final)
						final=simplifygenericfor3(final)
						final=renametableiter3(final)
						final=renameservicevars3(final)
						final=renamemoduleloops3(final)
						final=foldbuiltinclosures3(final)
						final=foldpcallrequire3(final)
						final=foldaliases(final)
						final=foldbuilders(final)
						final=foldbuilders2(final)
						final=renameconfig2(final)
						final=foldrootconfig2(final)
					end
				end
				final=compactlocals(final)
				local text=table.concat(final,"\n")
				return canonicalindent_source(text)
			end
			local function validstructure(s)
				local stack={}
				local function trim(x) return (x:gsub("^%s+",""):gsub("%s+$","")) end
				local function hasloop()
					for i=#stack,1,-1 do local k=stack[i] if k=="while" or k=="for" or k=="repeat" then return true end end
					return false
				end
				for line in (s.."\n"):gmatch("(.-)\n") do
					local t=trim(line)
					if t:match("^if%s+.+%s+then$") then stack[#stack+1]="if"
					elseif t:match("^while%s+.+%s+do$") then stack[#stack+1]="while"
					elseif t:match("^for%s+.+%s+do$") then stack[#stack+1]="for"
					elseif t=="repeat" then stack[#stack+1]="repeat"
					elseif t=="do" then stack[#stack+1]="do"
					elseif (t:match("^local%s+function%s+") or t:match("^function%s+") or t:find("function%s*%(",1)) and not t:match("^return%s+function") and not t:match("%f[%a]end%f[%A]") then stack[#stack+1]="function"
					elseif t:match("^elseif%s+.+%s+then$") or t=="else" then if stack[#stack]~="if" then return false end
					elseif t=="end" then if #stack==0 or stack[#stack]=="repeat" then return false end stack[#stack]=nil
					elseif t:match("^until%s+") then if stack[#stack]~="repeat" then return false end stack[#stack]=nil
					elseif t=="continue" or t=="break" then if not hasloop() then return false end
					end
				end
				return #stack==0
			end
			local function customsource(mod,p,depth,seen,upmap,exprMode)
				depth = depth or 0
				seen = seen or {}
				upmap = upmap or {}
				exprMode = exprMode or false
				if depth > MAX_PROTO_DEPTH then return "function(...) end" end
				if seen[p] then return "function(...) end" end
				seen[p]=true
				local ind = exprMode and "" or string.rep("\t",depth)
				local lines = {}
				local level = 1
				local expr = {}
				local vars = {}
				local names = {}
				local nameLife = {}
				local method = {}
				local multi = {}
				local top = p.params
				local usedNames = {}
				local skipPc = {}
				local structure = {}
				local endAt = {}
				local elseAt = {}
				local repeatAt = {}
				local forceVar = {}
				local forceDef = {}
				local ssaDefs
				local ssaWriteId
				local ssaReadAt
				local ssaParam
				local currentPc = -1
				local defExpr = {}
				local defName = {}
				local defMaterialized = {}
				local defPure = {}
				local defMulti = {}
				local phiIf = {}
				local renderPhiIf
				local declaredNames = {}
				local loopRanges = {}
				local pinned = {}
				local phiRegs = {}
				local phiLinks = {}
				local phiDefRoot = {}
				local phiGroupMembers = {}
				local phiGroupName = {}
				local semanticHints = {}
				local forceRanges = {}
				local byPc = {}
				local indexByPc = {}
				local function breathe()
					cooperate(1)
				end
				local function cleanname(s)
					if not ident(s) then return nil end
					if s=="and" or s=="break" or s=="continue" or s=="do" or s=="else" or s=="elseif" or s=="end" or s=="false" or s=="for" or s=="function" or s=="if" or s=="in" or s=="local" or s=="nil" or s=="not" or s=="or" or s=="repeat" or s=="return" or s=="then" or s=="true" or s=="until" or s=="while" then return nil end
					return s
				end
				for _,capturedName in pairs(upmap) do
					if type(capturedName)=="string" then
						local cn=cleanname(capturedName)
						if cn then usedNames[cn]=math.max(usedNames[cn] or 0,1) end
					end
				end
				local function unique(s)
					s=cleanname(s)
					if not s then return nil end
					if not usedNames[s] then usedNames[s]=1 return s end
					usedNames[s]+=1
					local sep=s:match("^v%d+_?%d*$") and "_" or ""
					return s..sep..tostring(usedNames[s])
				end
				local function dbglocal(r,pc)
					if p.locals then
						for _,l in ipairs(p.locals) do
							if l.reg==r and pc>=l.start and pc<l.finish then return l end
						end
					end
				end
				local function dbgname(r,pc)
					local l=dbglocal(r,pc)
					return l and cleanname(l.name) or nil
				end
				local function upname(i)
					return upmap[i] or (p.upnames and cleanname(p.upnames[i+1])) or ("upvalue"..tostring(i))
				end
				local function bodyindent()
					return ind..string.rep("\t",level)
				end
				local function emit(s)
					lines[#lines+1]=bodyindent()..s
				end
				local function emitLevel(s,l)
					lines[#lines+1]=ind..string.rep("\t",l)..s
				end
				local function readdef(r,pc)
					local rm=ssaReadAt and ssaReadAt[pc or currentPc]
					if rm then return rm[r] end
					return ssaParam and ssaParam[r]
				end
				local function writedef(r,pc)
					local wm=ssaWriteId and ssaWriteId[pc]
					return wm and wm[r]
				end
				local function regat(i,pc)
					local rm=ssaReadAt and ssaReadAt[pc]
					local id=(rm and rm[i]) or (not rm and ssaParam and ssaParam[i])
					if id then
						if defMaterialized[id] and defName[id] then return defName[id] end
						if defExpr[id] then return defExpr[id] end
						if phiIf[id] and renderPhiIf then
							local e=renderPhiIf(id)
							if e then defExpr[id]=e defPure[id]=true return e end
						end
					end
					if rm then
						if i<(p.params or 0) and names[i] then return names[i] end
						return "nil"
					end
					return vars[i] and names[i] or expr[i] or multi[i] or names[i] or ("v"..tostring(i))
				end
				local function reg(i)
					return regat(i,currentPc)
				end
				local function regpure(i,pc)
					local id=readdef(i,pc or currentPc)
					return id and (defMaterialized[id] or defPure[id]) or false
				end
				local function multireg(i)
					local id=readdef(i,currentPc)
					return (id and defMulti[id]) or multi[i]
				end
				local function touch(r,count)
					local t=r+(count or 1)
					if t>top then top=t end
				end
				local function clearMulti(r)
					multi[r]=nil
				end
				local function camel(s)
					if type(s)~="string" or s=="" then return nil end
					s=s:gsub("[^%w_]","_")
					if s:match("^%d") then s="value_"..s end
					return s:sub(1,1):lower()..s:sub(2)
				end
				local function suggest(s)
					if type(s)~="string" then return nil end
					local svc=s:match('^game:GetService%("([%w_]+)"%)$')
					if svc and (next(robloxServices)==nil or robloxServices[svc]) then
						if svc=="Workspace" then return "workspace" end
						return svc
					end
					local cls=s:match('^Instance%.new%("([%w_]+)"%)$')
					if cls and (next(robloxClasses)==nil or robloxClasses[cls]) then return camel(cls) end
					local et=s:match("^Enum%.([%w_]+)%.[%w_]+$")
					if et and (next(robloxEnums)==nil or robloxEnums[et]) then return camel(et) end
					local child=s:match(':WaitForChild%("([^"]+)"%)$')
					if child then return camel(child) end
					local found=s:match(':FindFirstChild%("([^"]+)"%)$')
					if found then return camel(found) end
					if s:match("^TweenInfo%.new%(") then return "tweenInfo" end
					if s:match(":Create%(") and s:find("Tween",1,true) then return "tween" end
					if s:match(":Connect%(") then return "connection" end
					if s:match("%.LocalPlayer$") then return "player" end
					if s:match("%.PlayerGui$") then return "playerGui" end
					if s:match("%.Changed$") or s:match("ChangedSignal") then return "signal" end
					local req=s:match('^require%((.+)%)$')
					if req then
						local last=req:match('%.([%a_][%w_]*)$')
						if last then return camel(last) end
						return "module"
					end
					if s:match("^function%(") then return "callback" end
				end
				local function varname(r,pc,s)
					local d=dbgname(r,pc)
					if not d and nameLife[r] then
						names[r]=nil
						nameLife[r]=nil
						vars[r]=nil
						expr[r]=nil
						multi[r]=nil
					end
					if d and nameLife[r]~=d then
						local n=unique(d) or ("v"..tostring(r))
						names[r]=n
						nameLife[r]=d
						vars[r]=nil
						expr[r]=nil
						multi[r]=nil
						return n
					end
					if names[r] then return names[r] end
					local n=unique(d or suggest(s) or (GENV.DEX_SEMANTIC_NAMES~=false and semanticHints[r] or nil) or ("v"..tostring(r))) or ("v"..tostring(r))
					names[r]=n
					nameLife[r]=d
					return n
				end
				local debugDefNames={}
				local function defvarname(r,pc,s,id)
					if id and defName[id] then return defName[id] end
					if id and phiDefRoot[id] then
						local n=phiGroupName[phiDefRoot[id]]
						if n then
							defName[id]=n
							return n
						end
					end
					local l=dbglocal(r,pc)
					local d=l and cleanname(l.name) or nil
					local n
					if d and l then
						local key=tostring(r)..":"..tostring(l.start)..":"..tostring(l.finish)..":"..d
						n=debugDefNames[key]
						if not n then n=unique(d) or d debugDefNames[key]=n end
					else
						local base=suggest(s) or (GENV.DEX_SEMANTIC_NAMES~=false and semanticHints[r] or nil)
						if not base then
							local sd=id and ssaDefs and ssaDefs[id]
							if sd and sd.op=="CALL" then base="result"
							elseif sd and (sd.op=="NEWCLOSURE" or sd.op=="DUPCLOSURE") then base="callback"
							elseif sd and (sd.op=="NEWTABLE" or sd.op=="DUPTABLE") then base="data"
							else base="v"..tostring(r) end
						end
						n=unique(base) or ("v"..tostring(r))
					end
					if id then defName[id]=n end
					return n
				end
				local function emitassign(lhs,s,islocal)
					if type(s)=="string" and s:find("\n",1,true) then
						local parts={}
						for line in (s.."\n"):gmatch("(.-)\n") do parts[#parts+1]=line end
						emit((islocal and "local " or "")..lhs.." = "..(parts[1] or "nil"))
						for j=2,#parts do lines[#lines+1]=bodyindent()..parts[j] end
					else
						emit((islocal and "local " or "")..lhs.." = "..s)
					end
				end
				local function setexpr(r,s,pc,pure)
					clearMulti(r)
					touch(r,1)
					local id=writedef(r,pc)
					if id then
						defExpr[id]=s
						defPure[id]=not not pure
						defMulti[id]=nil
					end
					expr[r]=s
				end
				local function materialize(r,s,pc)
					clearMulti(r)
					touch(r,1)
					local id=writedef(r,pc)
					if id then
						local n=defvarname(r,pc,s,id)
						local islocal=not declaredNames[n]
						emitassign(n,s,islocal)
						declaredNames[n]=true
						defMaterialized[id]=true
						defExpr[id]=n
						defMulti[id]=nil
						expr[r]=n
						return n
					end
					local n=varname(r,pc,s)
					if vars[r] then emitassign(n,s,false) else vars[r]=true emitassign(n,s,true) end
					expr[r]=n
					return n
				end
				local function materializeread(r,pc,s)
					local id=readdef(r,pc)
					if not id then
						local n=varname(r,pc,s)
						if not declaredNames[n] then emitassign(n,s,true) declaredNames[n]=true end
						vars[r]=true expr[r]=n
						return n
					end
					if defMaterialized[id] and defName[id] then return defName[id] end
					local n=defvarname(r,pc,s,id)
					local islocal=not declaredNames[n]
					emitassign(n,s,islocal)
					declaredNames[n]=true
					defMaterialized[id]=true
					defExpr[id]=n
					return n
				end
				local function forcedef(r,pc)
					local id=writedef(r,pc)
					if id then return forceDef[id] or false end
					return forceVar[r] or false
				end
				local function put(r,s,pc,hard,pure)
					local id=writedef(r,pc)
					local d=id and ssaDefs and ssaDefs[id]
					local must=hard or forcedef(r,pc) or dbgname(r,pc)~=nil
					if d then
						if d.receiver and d.uses>1 then must=true end
						if d.cross and not pure then must=true end
						if d.uses>1 and not pure then must=true end
						if not pure and d.firstUsePc and barrierBetween(pc,d.firstUsePc) then must=true end
					end
					if must then return materialize(r,s,pc) end
					setexpr(r,s,pc,pure)
					return s
				end
				local function multiassign(regs,rhs,pc)
					local lhs,fresh={},{}
					local preferred={}
					if type(rhs)=="string" then
						if rhs:match("^pcall%(") or rhs:match("^xpcall%(") then preferred[1]="success" preferred[2]="result"
						elseif rhs:match("^next%(") then preferred[1]="key" preferred[2]="value"
						elseif rhs:match("^string%.find%(") then preferred[1]="startIndex" preferred[2]="endIndex" end
					end
					for idx,r in ipairs(regs) do
						clearMulti(r)
						local id=writedef(r,pc)
						if id and preferred[idx] and not dbgname(r,pc) and not defName[id] then defName[id]=unique(preferred[idx]) or preferred[idx] end
						local nm=id and defvarname(r,pc,nil,id) or varname(r,pc,nil)
						lhs[#lhs+1]=nm
						if not declaredNames[nm] then fresh[#fresh+1]=nm end
					end
					if #fresh==#regs then
						emit("local "..table.concat(lhs,", ").." = "..rhs)
					elseif #fresh>0 then
						emit("local "..table.concat(fresh,", "))
						emit(table.concat(lhs,", ").." = "..rhs)
					else
						emit(table.concat(lhs,", ").." = "..rhs)
					end
					for _,r in ipairs(regs) do
						local id=writedef(r,pc)
						local nm=id and defName[id] or names[r]
						if nm then declaredNames[nm]=true end
						if id then defMaterialized[id]=true defExpr[id]=nm end
						vars[r]=true expr[r]=nm
					end
				end
				local function nextpc(x)
					return x.pc+x.size
				end
				local function jumptarget(x)
					return x.pc+1+(x.n=="JUMPX" and x.e or x.d)
				end
				for i,x in ipairs(p.ins) do byPc[x.pc]=x indexByPc[x.pc]=i end
				local barrierOps={CALL=true,CALLFB=true,SETGLOBAL=true,SETUPVAL=true,SETTABLE=true,SETTABLEKS=true,SETTABLEN=true,SETUDATAKS=true,SETLIST=true,NEWCLASSMEMBER=true,GETTABLE=true,GETTABLEKS=true,GETTABLEN=true,GETUDATAKS=true,CLOSEUPVALS=true}
				local barrierPrefix={}
				local barrierCount=0
				for j,y in ipairs(p.ins) do
					barrierPrefix[j]=barrierCount
					if barrierOps[y.n] then barrierCount+=1 end
				end
				local function barrierBetween(a,b)
					if type(a)~="number" or type(b)~="number" or b<=a then return false end
					local ai=indexByPc[a]
					local bi=indexByPc[b]
					if not ai or not bi or bi<=ai+1 then return false end
					local beforeB=barrierPrefix[bi] or 0
					local afterA=(barrierPrefix[ai] or 0)+(barrierOps[p.ins[ai].n] and 1 or 0)
					return beforeB>afterA
				end
				local condops={JUMPIF=true,JUMPIFNOT=true,JUMPIFEQ=true,JUMPIFLE=true,JUMPIFLT=true,JUMPIFNOTEQ=true,JUMPIFNOTLE=true,JUMPIFNOTLT=true,JUMPXEQKNIL=true,JUMPXEQKB=true,JUMPXEQKN=true,JUMPXEQKS=true,CMPPROTO=true}
				local cfgcondops={JUMPIF=true,JUMPIFNOT=true,JUMPIFEQ=true,JUMPIFLE=true,JUMPIFLT=true,JUMPIFNOTEQ=true,JUMPIFNOTLE=true,JUMPIFNOTLT=true,JUMPXEQKNIL=true,JUMPXEQKB=true,JUMPXEQKN=true,JUMPXEQKS=true,CMPPROTO=true}
				local loopops={FORNPREP=true,FORNLOOP=true,FORGLOOP=true}
				local uncondops={JUMP=true,JUMPBACK=true,JUMPX=true,FORGPREP=true,FORGPREP_INEXT=true,FORGPREP_NEXT=true}
				local terminalops={RETURN=true}
				local leaders={[0]=true}
				for _,x in ipairs(p.ins) do
					local np=nextpc(x)
					if cfgcondops[x.n] or loopops[x.n] then
						local t=jumptarget(x)
						if byPc[t] then leaders[t]=true end
						if byPc[np] then leaders[np]=true end
					elseif uncondops[x.n] then
						local t=jumptarget(x)
						if byPc[t] then leaders[t]=true end
						if byPc[np] then leaders[np]=true end
					elseif x.n=="LOADB" and x.c~=0 then
						local t=x.pc+1+x.c
						if byPc[t] then leaders[t]=true end
						if byPc[np] then leaders[np]=true end
					elseif terminalops[x.n] and byPc[np] then
						leaders[np]=true
					end
				end
				local blocks={}
				local blockOf={}
				local cur
				for _,x in ipairs(p.ins) do
					if leaders[x.pc] or not cur then
						cur={id=#blocks+1,start=x.pc,finish=x.pc,ins={},succ={},pred={}}
						blocks[#blocks+1]=cur
					end
					cur.finish=x.pc
					cur.ins[#cur.ins+1]=x
					blockOf[x.pc]=cur.id
				end
				local function addsucc(b,pc)
					local id=blockOf[pc]
					if not id then return end
					for _,v in ipairs(b.succ) do if v==id then return end end
					b.succ[#b.succ+1]=id
				end
				for _,b in ipairs(blocks) do
					local x=b.ins[#b.ins]
					local np=nextpc(x)
					if x.n=="CMPPROTO" then
						addsucc(b,jumptarget(x))
						addsucc(b,np)
					elseif cfgcondops[x.n] or loopops[x.n] then
						addsucc(b,jumptarget(x))
						addsucc(b,np)
					elseif uncondops[x.n] then
						addsucc(b,jumptarget(x))
					elseif x.n=="LOADB" and x.c~=0 then
						addsucc(b,x.pc+1+x.c)
					elseif not terminalops[x.n] then
						addsucc(b,np)
					end
				end
				for _,b in ipairs(blocks) do
					for _,sid in ipairs(b.succ) do
						blocks[sid].pred[#blocks[sid].pred+1]=b.id
					end
				end
				if GENV.DEX_SEMANTIC_NAMES~=false then
					local score={}
					local function addscore(r,n)
						if type(r)=="number" and r>=0 and r<255 then score[r]=(score[r] or 0)+(n or 1) end
					end
					local function literalwrite(b,r)
						for j=#b.ins-1,1,-1 do
							local y=b.ins[j]
							if y.a==r then
								if y.n=="LOADN" or y.n=="LOADK" or y.n=="LOADKX" or y.n=="LOADB" or y.n=="LOADNIL" then return true end
								return false
							end
						end
						return false
					end
					for _,b in ipairs(blocks) do
						local x=b.ins[#b.ins]
						if x then
							if x.n=="JUMPXEQKN" or x.n=="JUMPXEQKS" or x.n=="JUMPXEQKB" or x.n=="JUMPXEQKNIL" then
								addscore(x.a,4)
							elseif x.n=="JUMPIFEQ" or x.n=="JUMPIFNOTEQ" or x.n=="JUMPIFLE" or x.n=="JUMPIFLT" or x.n=="JUMPIFNOTLE" or x.n=="JUMPIFNOTLT" then
								local rb=(x.aux or 0)%256
								local al=literalwrite(b,x.a)
								local bl=literalwrite(b,rb)
								if al~=bl then addscore(al and rb or x.a,3) else addscore(x.a,1) addscore(rb,1) end
							end
						end
					end
					local promptProps={Style=true,HoldDuration=true,GamepadKeyCode=true,KeyboardKeyCode=true,ClickablePrompt=true,PromptButtonHoldBegan=true,PromptButtonHoldEnded=true,Triggered=true,TriggerEnded=true,PromptHidden=true,ActionText=true,ObjectText=true,UIOffset=true,AutoLocalize=true,RootLocalizationTable=true}
					local inputProps={UserInputType=true,UserInputState=true,KeyCode=true,Position=true,Delta=true}
					local guiProps={Size=true,Position=true,AnchorPoint=true,BackgroundTransparency=true,Parent=true,Visible=true}
					local propScores={}
					local function propscore(r,name,weight)
						if type(r)~="number" or r<0 or r>=(p.params or 0) or type(name)~="string" then return end
						local ps=propScores[r]
						if not ps then ps={} propScores[r]=ps end
						ps[name]=(ps[name] or 0)+(weight or 1)
					end
					for _,x in ipairs(p.ins) do
						if x.n=="GETTABLEKS" or x.n=="GETUDATAKS" then
							local ci=x.n=="GETUDATAKS" and ((x.aux or 0)%65536) or (x.aux or 0)
							local key=kstr(p,ci)
							if promptProps[key] then propscore(x.b,"prompt",4)
							elseif inputProps[key] then propscore(x.b,"input",3)
							elseif guiProps[key] then propscore(x.b,"gui",1) end
						elseif x.n=="NAMECALL" or x.n=="NAMECALLUDATA" then
							local ci=x.n=="NAMECALLUDATA" and ((x.aux or 0)%65536) or (x.aux or 0)
							local key=kstr(p,ci)
							if key=="GetAttribute" then propscore(x.b,"prompt",2)
							elseif key=="GetFullName" then propscore(x.b,"instance",2)
							elseif key=="Connect" then propscore(x.b,"signal",1) end
						end
					end
					for r,ps in pairs(propScores) do
						local best,bn=nil,-1
						for name,n in pairs(ps) do if n>bn then best,bn=name,n end end
						if best and bn>=3 and not semanticHints[r] then semanticHints[r]=best end
					end
					for r,n in pairs(score) do
						if n>=8 then semanticHints[r]=n>=28 and "opcode" or "state" end
					end
				end
				local CUNDEF={}
				local CNAC={}
				local CNIL={}
				local function cval(t,v)
					return {t=t,v=v}
				end
				local function ceq(a,b)
					if a==b then return true end
					if type(a)~="table" or type(b)~="table" then return false end
					return a.t~=nil and a.t==b.t and a.v==b.v
				end
				local function cmeet(a,b)
					a=a or CUNDEF
					b=b or CUNDEF
					if a==CUNDEF then return b end
					if b==CUNDEF then return a end
					if a==CNAC or b==CNAC then return CNAC end
					return ceq(a,b) and a or CNAC
				end
				local function ccopy(a)
					local o={}
					for r=0,(p.max or 0)-1 do o[r]=a and a[r] or CUNDEF end
					return o
				end
				local function cstateeq(a,b)
					for r=0,(p.max or 0)-1 do
						if not ceq((a and a[r]) or CUNDEF,(b and b[r]) or CUNDEF) then return false end
					end
					return true
				end
				local function ck(i)
					local k=p.k[(i or -1)+1]
					if not k then return CNAC end
					if k.t==0 then return CNIL end
					if k.t==1 then return cval("b",not not k.v) end
					if k.t==2 then return cval("n",k.v) end
					if k.t==9 then return CNAC end
					if k.t==3 then return cval("s",k.v) end
					return CNAC
				end
				local function ctruth(v)
					if v==CUNDEF or v==CNAC then return nil end
					if v==CNIL then return false end
					if v.t=="b" then return v.v end
					return true
				end
				local function cnum(v)
					return type(v)=="table" and v~=CNAC and v~=CUNDEF and v~=CNIL and v.t=="n" and v.v or nil
				end
				local function cscalar(v)
					if v==CNIL then return "nil",nil end
					if type(v)=="table" and v~=CNAC and v~=CUNDEF then return v.t,v.v end
				end
				local function cwrite(st,r,v)
					if type(r)=="number" and r>=0 and r<(p.max or 0) then st[r]=v or CNAC end
				end
				local function carith(op,a,b)
					local av,bv=cnum(a),cnum(b)
					if av==nil or bv==nil then return CNAC end
					local ok,res=pcall(function()
						if op=="ADD" then return av+bv end
						if op=="SUB" then return av-bv end
						if op=="MUL" then return av*bv end
						if op=="DIV" then return av/bv end
						if op=="MOD" then return av%bv end
						if op=="POW" then return av^bv end
						if op=="IDIV" then return math.floor(av/bv) end
					end)
					return ok and type(res)=="number" and cval("n",res) or CNAC
				end
				local cWriteA={LOADNIL=true,LOADB=true,LOADN=true,LOADK=true,MOVE=true,GETGLOBAL=true,GETUPVAL=true,GETIMPORT=true,GETTABLE=true,GETTABLEKS=true,GETTABLEN=true,NEWCLOSURE=true,ADD=true,SUB=true,MUL=true,DIV=true,MOD=true,POW=true,ADDK=true,SUBK=true,MULK=true,DIVK=true,MODK=true,POWK=true,AND=true,OR=true,ANDK=true,ORK=true,CONCAT=true,NOT=true,MINUS=true,LENGTH=true,NEWTABLE=true,DUPTABLE=true,DUPCLOSURE=true,LOADKX=true,SUBRK=true,DIVRK=true,IDIV=true,IDIVK=true,GETUDATAKS=true,NEWCLASS=true}
				local function cunknownwrites(x)
					local n=x.n
					if n=="NAMECALL" or n=="NAMECALLUDATA" then return {x.a,x.a+1} end
					if n=="CALL" or n=="CALLFB" then
						if x.c==1 then return {} end
						local o={}
						local count=x.c==0 and 1 or x.c-1
						for j=0,count-1 do o[#o+1]=x.a+j end
						return o
					end
					if n=="GETVARARGS" then
						local o={}
						local count=x.b==0 and 1 or x.b-1
						for j=0,count-1 do o[#o+1]=x.a+j end
						return o
					end
					if n=="FORNPREP" or n=="FORNLOOP" then return {x.a+2,x.a+3} end
					if n=="FORGLOOP" then
						local o={x.a+2}
						local count=(x.aux or 1)%256
						for j=0,count-1 do o[#o+1]=x.a+3+j end
						return o
					end
					return cWriteA[n] and {x.a} or {}
				end
				local function ctransfer(st,x)
					local n=x.n
					if n=="LOADNIL" then cwrite(st,x.a,CNIL)
					elseif n=="LOADB" then cwrite(st,x.a,cval("b",x.b~=0))
					elseif n=="LOADN" then cwrite(st,x.a,cval("n",x.d))
					elseif n=="LOADK" then cwrite(st,x.a,ck(math.floor(x.w/65536)%65536))
					elseif n=="LOADKX" then cwrite(st,x.a,ck(x.aux or 0))
					elseif n=="MOVE" then cwrite(st,x.a,st[x.b] or CUNDEF)
					elseif n=="NOT" then
						local v=ctruth(st[x.b] or CUNDEF)
						cwrite(st,x.a,v==nil and CNAC or cval("b",not v))
					elseif n=="MINUS" then
						local v=cnum(st[x.b] or CUNDEF)
						cwrite(st,x.a,v==nil and CNAC or cval("n",-v))
					elseif n=="LENGTH" then
						local v=st[x.b] or CUNDEF
						cwrite(st,x.a,(type(v)=="table" and v.t=="s") and cval("n",#v.v) or CNAC)
					elseif n=="ADD" or n=="SUB" or n=="MUL" or n=="DIV" or n=="MOD" or n=="POW" or n=="IDIV" then
						cwrite(st,x.a,carith(n,st[x.b] or CUNDEF,st[x.c] or CUNDEF))
					elseif n=="ADDK" or n=="SUBK" or n=="MULK" or n=="DIVK" or n=="MODK" or n=="POWK" or n=="IDIVK" then
						cwrite(st,x.a,carith(n:sub(1,-2),st[x.b] or CUNDEF,ck(x.c)))
					elseif n=="AND" or n=="OR" or n=="ANDK" or n=="ORK" then
						local left=st[x.b] or CUNDEF
						local lt=ctruth(left)
						local right=(n=="ANDK" or n=="ORK") and ck(x.c) or (st[x.c] or CUNDEF)
						if lt==nil then cwrite(st,x.a,CNAC)
						elseif n=="AND" or n=="ANDK" then cwrite(st,x.a,lt and right or left)
						else cwrite(st,x.a,lt and left or right) end
					elseif n=="SUBRK" then cwrite(st,x.a,carith("SUB",ck(x.b),st[x.c] or CUNDEF))
					elseif n=="DIVRK" then cwrite(st,x.a,carith("DIV",ck(x.b),st[x.c] or CUNDEF))
					elseif n=="CONCAT" then
						local ss={}
						local good=true
						for r=x.b,x.c do
							local t,v=cscalar(st[r] or CUNDEF)
							if t=="s" or t=="n" then ss[#ss+1]=tostring(v) else good=false break end
						end
						cwrite(st,x.a,good and cval("s",table.concat(ss)) or CNAC)
					else
						for _,r in ipairs(cunknownwrites(x)) do cwrite(st,r,CNAC) end
					end
				end
				local function cevalbranch(x,st)
					local n=x.n
					if n=="JUMPIF" or n=="JUMPIFNOT" then
						local v=ctruth(st[x.a] or CUNDEF)
						if v==nil then return nil end
						return n=="JUMPIF" and v or not v
					end
					if n=="JUMPIFEQ" or n=="JUMPIFNOTEQ" or n=="JUMPIFLE" or n=="JUMPIFLT" or n=="JUMPIFNOTLE" or n=="JUMPIFNOTLT" then
						local a=st[x.a] or CUNDEF
						local b=st[(x.aux or 0)%256] or CUNDEF
						if a==CUNDEF or a==CNAC or b==CUNDEF or b==CNAC then return nil end
						local at,av=cscalar(a)
						local bt,bv=cscalar(b)
						if n=="JUMPIFEQ" or n=="JUMPIFNOTEQ" then
							local eq=at==bt and av==bv
							return n=="JUMPIFEQ" and eq or not eq
						end
						if at~=bt or (at~="n" and at~="s") then return nil end
						local ok,res=pcall(function()
							if n=="JUMPIFLE" then return av<=bv end
							if n=="JUMPIFLT" then return av<bv end
							if n=="JUMPIFNOTLE" then return not (av<=bv) end
							return not (av<bv)
						end)
						return ok and res or nil
					end
					if n=="JUMPXEQKNIL" then
						local a=st[x.a] or CUNDEF
						if a==CUNDEF or a==CNAC then return nil end
						local eq=a==CNIL
						local notf=math.floor((x.aux or 0)/2147483648)%2
						return notf==1 and not eq or eq
					end
					if n=="JUMPXEQKB" then
						local a=st[x.a] or CUNDEF
						if a==CUNDEF or a==CNAC then return nil end
						local at,av=cscalar(a)
						local val=(x.aux or 0)%2~=0
						local eq=at=="b" and av==val
						local notf=math.floor((x.aux or 0)/2147483648)%2
						return notf==1 and not eq or eq
					end
					if n=="JUMPXEQKN" or n=="JUMPXEQKS" then
						local a=st[x.a] or CUNDEF
						if a==CUNDEF or a==CNAC then return nil end
						local b=ck((x.aux or 0)%16777216)
						if b==CNAC then return nil end
						local eq=ceq(a,b)
						local notf=math.floor((x.aux or 0)/2147483648)%2
						return notf==1 and not eq or eq
					end
					return nil
				end
				local staticBranch={}
				local function equalityfact(x,st)
					local n=x.n
					if n=="JUMPIFEQ" or n=="JUMPIFNOTEQ" then
						local rb=(x.aux or 0)%256
						local a=st[x.a] or CUNDEF
						local b=st[rb] or CUNDEF
						local ac=a~=CUNDEF and a~=CNAC
						local bc=b~=CUNDEF and b~=CNAC
						if ac and not bc then return rb,a,n=="JUMPIFEQ" end
						if bc and not ac then return x.a,b,n=="JUMPIFEQ" end
					elseif n=="JUMPXEQKNIL" or n=="JUMPXEQKB" or n=="JUMPXEQKN" or n=="JUMPXEQKS" then
						local k
						if n=="JUMPXEQKNIL" then k=CNIL
						elseif n=="JUMPXEQKB" then k=cval("b",(x.aux or 0)%2~=0)
						else k=ck((x.aux or 0)%16777216) end
						if k and k~=CNAC then
							local notf=math.floor((x.aux or 0)/2147483648)%2
							return x.a,k,notf==0
						end
					end
				end
				local function constpass()
					local constIn,constOut,edgeOut={}, {}, {}
					local entryConst=blockOf[0] or 1
					local init={}
					for r=0,(p.max or 0)-1 do init[r]=r<(p.params or 0) and CNAC or CNIL end
					local changed=true
					local rounds=0
					while changed and rounds<512 do
						changed=false
						rounds+=1
						for _,b in ipairs(blocks) do
							local incoming=nil
							local any=false
							if b.id==entryConst then incoming=ccopy(init) any=true end
							for _,pid in ipairs(b.pred) do
								local po=(edgeOut[pid] and edgeOut[pid][b.id]) or constOut[pid]
								if po then
									if not any then
										incoming=ccopy(po)
										any=true
									else
										for r=0,(p.max or 0)-1 do incoming[r]=cmeet(incoming[r],po[r]) end
									end
								end
							end
							if any then
								if not constIn[b.id] or not cstateeq(constIn[b.id],incoming) then constIn[b.id]=incoming changed=true end
								local st=ccopy(incoming)
								for _,y in ipairs(b.ins) do ctransfer(st,y) end
								if not constOut[b.id] or not cstateeq(constOut[b.id],st) then constOut[b.id]=ccopy(st) changed=true end
								local eo={}
								for _,sid in ipairs(b.succ) do eo[sid]=ccopy(st) end
								local last=b.ins[#b.ins]
								if last and cfgcondops[last.n] and last.n~="CMPPROTO" then
									local rr,kv,eqJump=equalityfact(last,st)
									if rr~=nil and kv~=nil then
										local eqid=blockOf[eqJump and jumptarget(last) or nextpc(last)]
										if eqid and eo[eqid] then eo[eqid][rr]=kv end
									end
								end
								local oldeo=edgeOut[b.id] or {}
								local edgeChanged=false
								for sid,es in pairs(eo) do if not oldeo[sid] or not cstateeq(oldeo[sid],es) then edgeChanged=true break end end
								if not edgeChanged then for sid in pairs(oldeo) do if not eo[sid] then edgeChanged=true break end end end
								if edgeChanged then edgeOut[b.id]=eo changed=true end
							end
						end
						breathe()
					end
					local pruned=false
					for _,b in ipairs(blocks) do
						local st=constIn[b.id] and ccopy(constIn[b.id]) or nil
						if st then
							for j,y in ipairs(b.ins) do
								if j==#b.ins and cfgcondops[y.n] and y.n~="CMPPROTO" and staticBranch[y.pc]==nil then
									local br=cevalbranch(y,st)
									if br~=nil then
										staticBranch[y.pc]=br
										local pc=br and jumptarget(y) or nextpc(y)
										local sid=blockOf[pc]
										b.succ=sid and {sid} or {}
										pruned=true
									end
								end
								ctransfer(st,y)
							end
						end
					end
					return pruned
				end
				local function rcopy(st)
					local o={}
					for r=0,(p.max or 0)-1 do
						local v=st and st[r]
						if v then o[r]={lo=v.lo,hi=v.hi,loOpen=v.loOpen,hiOpen=v.hiOpen} end
					end
					return o
				end
				local function rexact(n)
					if type(n)~="number" or n~=n or n==math.huge or n==-math.huge then return nil end
					return {lo=n,hi=n,loOpen=false,hiOpen=false}
				end
				local function req(a,b)
					if a==nil or b==nil then return a==b end
					return a.lo==b.lo and a.hi==b.hi and a.loOpen==b.loOpen and a.hiOpen==b.hiOpen
				end
				local function rstateeq(a,b)
					for r=0,(p.max or 0)-1 do if not req(a and a[r],b and b[r]) then return false end end
					return true
				end
				local function rhull(a,b)
					if not a or not b then return nil end
					local lo,loOpen
					if a.lo<b.lo then lo,loOpen=a.lo,a.loOpen elseif b.lo<a.lo then lo,loOpen=b.lo,b.loOpen else lo,loOpen=a.lo,a.loOpen and b.loOpen end
					local hi,hiOpen
					if a.hi>b.hi then hi,hiOpen=a.hi,a.hiOpen elseif b.hi>a.hi then hi,hiOpen=b.hi,b.hiOpen else hi,hiOpen=a.hi,a.hiOpen and b.hiOpen end
					return {lo=lo,hi=hi,loOpen=loOpen,hiOpen=hiOpen}
				end
				local function rintersect(a,b)
					a=a or {lo=-math.huge,hi=math.huge,loOpen=false,hiOpen=false}
					b=b or {lo=-math.huge,hi=math.huge,loOpen=false,hiOpen=false}
					local lo,loOpen
					if a.lo>b.lo then lo,loOpen=a.lo,a.loOpen elseif b.lo>a.lo then lo,loOpen=b.lo,b.loOpen else lo,loOpen=a.lo,a.loOpen or b.loOpen end
					local hi,hiOpen
					if a.hi<b.hi then hi,hiOpen=a.hi,a.hiOpen elseif b.hi<a.hi then hi,hiOpen=b.hi,b.hiOpen else hi,hiOpen=a.hi,a.hiOpen or b.hiOpen end
					if lo>hi or (lo==hi and (loOpen or hiOpen)) then return nil,false end
					return {lo=lo,hi=hi,loOpen=loOpen,hiOpen=hiOpen},true
				end
				local function rexactvalue(r)
					if r and r.lo==r.hi and not r.loOpen and not r.hiOpen then return r.lo end
				end
				local function rtransfer(st,x)
					local n=x.n
					if n=="LOADN" then st[x.a]=rexact(x.d)
					elseif n=="LOADK" then st[x.a]=rexact(cnum(ck(math.floor(x.w/65536)%65536)))
					elseif n=="LOADKX" then st[x.a]=rexact(cnum(ck(x.aux or 0)))
					elseif n=="MOVE" then st[x.a]=st[x.b] and rcopy({[x.b]=st[x.b]})[x.b] or nil
					elseif n=="MINUS" then
						local v=st[x.b]
						if v then st[x.a]={lo=-v.hi,hi=-v.lo,loOpen=v.hiOpen,hiOpen=v.loOpen} else st[x.a]=nil end
					else
						for _,r in ipairs(cunknownwrites(x)) do st[r]=nil end
					end
				end
				local function ropinfo(x,st)
					local op
					if x.n=="JUMPIFLT" then op="<"
					elseif x.n=="JUMPIFLE" then op="<="
					elseif x.n=="JUMPIFNOTLT" then op=">="
					elseif x.n=="JUMPIFNOTLE" then op=">"
					else return nil end
					local rb=(x.aux or 0)%256
					local ar=st[x.a]
					local br=st[rb]
					local av=rexactvalue(ar)
					local bv=rexactvalue(br)
					if bv~=nil and av==nil then return x.a,op,bv end
					if av~=nil and bv==nil then
						local inv={["<"]=">",["<="]=">=", [">"]="<",[">="]="<="}
						return rb,inv[op],av
					end
					if av~=nil and bv~=nil then
						local ok,res=pcall(function()
							if op=="<" then return av<bv elseif op=="<=" then return av<=bv elseif op==">" then return av>bv else return av>=bv end
						end)
						if ok then return false,res,nil end
					end
				end
				local function reval(r,op,c)
					if not r then return nil end
					if op=="<" then
						if r.hi<c or (r.hi==c and r.hiOpen) then return true end
						if r.lo>=c then return false end
					elseif op=="<=" then
						if r.hi<=c then return true end
						if r.lo>c or (r.lo==c and r.loOpen) then return false end
					elseif op==">" then
						if r.lo>c or (r.lo==c and r.loOpen) then return true end
						if r.hi<=c then return false end
					elseif op==">=" then
						if r.lo>=c then return true end
						if r.hi<c or (r.hi==c and r.hiOpen) then return false end
					end
				end
				local function rconstraint(op,c,truth)
					if not truth then
						local inv={["<"]=">=",["<="]=">",[">"]="<=",[">="]="<"}
						op=inv[op]
					end
					if op=="<" then return {lo=-math.huge,hi=c,loOpen=false,hiOpen=true}
					elseif op=="<=" then return {lo=-math.huge,hi=c,loOpen=false,hiOpen=false}
					elseif op==">" then return {lo=c,hi=math.huge,loOpen=true,hiOpen=false}
					else return {lo=c,hi=math.huge,loOpen=false,hiOpen=false} end
				end
				local function rangepass()
					local rin,rout,redge={},{},{}
					local entry=blockOf[0] or 1
					local changed=true
					local rounds=0
					while changed and rounds<256 do
						changed=false rounds+=1
						for _,b in ipairs(blocks) do
							local incoming=nil
							local any=false
							if b.id==entry then incoming={} any=true end
							for _,pid in ipairs(b.pred) do
								local em=redge[pid]
								local ev=em and em[b.id] or nil
								local po=ev==false and nil or (ev or rout[pid])
								if po then
									if not any then incoming=rcopy(po) any=true
									else
										for r=0,(p.max or 0)-1 do incoming[r]=rhull(incoming[r],po[r]) end
									end
								end
							end
							if any then
								if not rin[b.id] or not rstateeq(rin[b.id],incoming) then rin[b.id]=rcopy(incoming) changed=true end
								local st=rcopy(incoming)
								for _,y in ipairs(b.ins) do rtransfer(st,y) end
								if not rout[b.id] or not rstateeq(rout[b.id],st) then rout[b.id]=rcopy(st) changed=true end
								local eo={}
								for _,sid in ipairs(b.succ) do eo[sid]=rcopy(st) end
								local last=b.ins[#b.ins]
								if last and cfgcondops[last.n] and staticBranch[last.pc]==nil then
									local rr,op,c=ropinfo(last,st)
									if rr and rr~=false and op and c~=nil then
										local jid=blockOf[jumptarget(last)]
										local fid=blockOf[nextpc(last)]
										for _,pair in ipairs({{jid,true},{fid,false}}) do
											local sid,truth=pair[1],pair[2]
											if sid and eo[sid] then
												local nr,ok=rintersect(eo[sid][rr],rconstraint(op,c,truth))
												if ok then eo[sid][rr]=nr else eo[sid]=false end
											end
										end
									end
								end
								local old=redge[b.id] or {}
								local ec=false
								for sid,es in pairs(eo) do
									local os=old[sid]
									if es==false then
										if os~=false then ec=true break end
									elseif os==false or not os or not rstateeq(os,es) then
										ec=true
										break
									end
								end
								if not ec then for sid in pairs(old) do if eo[sid]==nil then ec=true break end end end
								if ec then redge[b.id]=eo changed=true end
							end
						end
						breathe()
					end
					local pruned=false
					for _,b in ipairs(blocks) do
						local st=rin[b.id] and rcopy(rin[b.id]) or nil
						if st then
							for _,y in ipairs(b.ins) do rtransfer(st,y) end
							local y=b.ins[#b.ins]
							if y and cfgcondops[y.n] and staticBranch[y.pc]==nil then
								local rr,op,c=ropinfo(y,st)
								local br
								if rr==false then br=op elseif rr and op and c~=nil then br=reval(st[rr],op,c) end
								if br~=nil then
									staticBranch[y.pc]=br
									local sid=blockOf[br and jumptarget(y) or nextpc(y)]
									b.succ=sid and {sid} or {}
									pruned=true
								end
							end
						end
					end
					return pruned
				end
				for _=1,8 do
					local pruned=constpass()
					if not pruned then break end
					for _,b in ipairs(blocks) do b.pred={} end
					for _,b in ipairs(blocks) do
						for _,sid in ipairs(b.succ) do blocks[sid].pred[#blocks[sid].pred+1]=b.id end
					end
				end
				for _=1,6 do
					local pruned=rangepass()
					if not pruned then break end
					for _,b in ipairs(blocks) do b.pred={} end
					for _,b in ipairs(blocks) do
						for _,sid in ipairs(b.succ) do blocks[sid].pred[#blocks[sid].pred+1]=b.id end
					end
				end
				for _,b in ipairs(blocks) do b.pred={} end
				for _,b in ipairs(blocks) do
					for _,sid in ipairs(b.succ) do blocks[sid].pred[#blocks[sid].pred+1]=b.id end
				end
				local reachableBlock={}
				local stack={blockOf[0] or 1}
				while #stack>0 do
					local id=stack[#stack]
					stack[#stack]=nil
					if id and not reachableBlock[id] then
						reachableBlock[id]=true
						for _,sid in ipairs(blocks[id].succ) do stack[#stack+1]=sid end
					end
					breathe()
				end
				local reachablePc={}
				for _,b in ipairs(blocks) do
					if reachableBlock[b.id] then
						for _,x in ipairs(b.ins) do reachablePc[x.pc]=true end
					end
				end
				local entryBlock=blockOf[0] or 1
				local dom={}
				local allReach={}
				for id in pairs(reachableBlock) do allReach[id]=true end
				for _,b in ipairs(blocks) do
					if reachableBlock[b.id] then
						if b.id==entryBlock then dom[b.id]={[b.id]=true} else
							local d={}
							for id in pairs(allReach) do d[id]=true end
							dom[b.id]=d
						end
					else
						dom[b.id]={}
					end
				end
				local domChanged=true
				local domRounds=0
				while domChanged and domRounds<512 do
					domChanged=false domRounds+=1
					for _,b in ipairs(blocks) do
						if reachableBlock[b.id] and b.id~=entryBlock then
							local nd=nil
							for _,pid in ipairs(b.pred) do
								if reachableBlock[pid] then
									if not nd then
										nd={}
										for k in pairs(dom[pid]) do nd[k]=true end
									else
										for k in pairs(nd) do if not dom[pid][k] then nd[k]=nil end end
									end
								end
							end
							nd=nd or {}
							nd[b.id]=true
							local old=dom[b.id]
							local eq=true
							for k in pairs(nd) do if not old[k] then eq=false break end end
							if eq then for k in pairs(old) do if not nd[k] then eq=false break end end end
							if not eq then dom[b.id]=nd domChanged=true end
						end
					end
					breathe()
				end
				local function dominates(a,b)
					return a and b and dom[b] and dom[b][a] or false
				end
				local EXIT_ID=#blocks+1
				local postdom={}
				local postUniverse={[EXIT_ID]=true}
				for id in pairs(reachableBlock) do postUniverse[id]=true end
				postdom[EXIT_ID]={[EXIT_ID]=true}
				for _,b in ipairs(blocks) do
					if reachableBlock[b.id] then
						local d={}
						for id in pairs(postUniverse) do d[id]=true end
						postdom[b.id]=d
					else
						postdom[b.id]={}
					end
				end
				local pdChanged=true
				local pdRounds=0
				while pdChanged and pdRounds<512 do
					pdChanged=false
					pdRounds+=1
					for bi=#blocks,1,-1 do
						local b=blocks[bi]
						if reachableBlock[b.id] then
							local succs={}
							for _,sid in ipairs(b.succ) do if reachableBlock[sid] then succs[#succs+1]=sid end end
							if #succs==0 then succs[1]=EXIT_ID end
							local nd=nil
							for _,sid in ipairs(succs) do
								local sd=postdom[sid] or {[EXIT_ID]=true}
								if not nd then
									nd={}
									for k in pairs(sd) do nd[k]=true end
								else
									for k in pairs(nd) do if not sd[k] then nd[k]=nil end end
								end
							end
							nd=nd or {[EXIT_ID]=true}
							nd[b.id]=true
							local old=postdom[b.id] or {}
							local eq=true
							for k in pairs(nd) do if not old[k] then eq=false break end end
							if eq then for k in pairs(old) do if not nd[k] then eq=false break end end end
							if not eq then postdom[b.id]=nd pdChanged=true end
						end
					end
					breathe()
				end
				local ipdom={}
				for _,b in ipairs(blocks) do
					if reachableBlock[b.id] then
						local set=postdom[b.id] or {}
						for c in pairs(set) do
							if c~=b.id then
								local immediate=true
								for d in pairs(set) do
									if d~=b.id and d~=c and postdom[d] and postdom[d][c] then immediate=false break end
								end
								if immediate then ipdom[b.id]=c break end
							end
						end
					end
				end
				local function writeRegs(x)
					local n=x.n
					if n=="NAMECALL" or n=="NAMECALLUDATA" then return {x.a,x.a+1} end
					if n=="CALL" or n=="CALLFB" then
						if x.c==1 then return {} end
						local out={}
						local count=x.c==0 and 1 or x.c-1
						for j=0,count-1 do out[#out+1]=x.a+j end
						return out
					end
					if n=="GETVARARGS" then
						local out={}
						local count=x.b==0 and 1 or x.b-1
						for j=0,count-1 do out[#out+1]=x.a+j end
						return out
					end
					if n=="FORNPREP" or n=="FORNLOOP" then return {x.a+2,x.a+3} end
					if n=="FORGLOOP" then
						local out={x.a+2}
						local count=(x.aux or 1)%256
						for j=0,count-1 do out[#out+1]=x.a+3+j end
						return out
					end
					local writesA={
						LOADNIL=true,LOADB=true,LOADN=true,LOADK=true,MOVE=true,GETGLOBAL=true,GETUPVAL=true,GETIMPORT=true,
						GETTABLE=true,GETTABLEKS=true,GETTABLEN=true,NEWCLOSURE=true,ADD=true,SUB=true,MUL=true,DIV=true,MOD=true,POW=true,
						ADDK=true,SUBK=true,MULK=true,DIVK=true,MODK=true,POWK=true,AND=true,OR=true,ANDK=true,ORK=true,CONCAT=true,
						NOT=true,MINUS=true,LENGTH=true,NEWTABLE=true,DUPTABLE=true,DUPCLOSURE=true,LOADKX=true,SUBRK=true,DIVRK=true,
						IDIV=true,IDIVK=true,GETUDATAKS=true,NEWCLASS=true
					}
					return writesA[n] and {x.a} or {}
				end
				local function readRegs(x)
					local n=x.n
					local out={}
					local function add(r)
						if type(r)=="number" and r>=0 and r<255 then out[#out+1]=r end
					end
					if n=="MOVE" or n=="NOT" or n=="MINUS" or n=="LENGTH" then add(x.b)
					elseif n=="SETGLOBAL" or n=="SETUPVAL" then add(x.a)
					elseif n=="GETTABLE" then add(x.b) add(x.c)
					elseif n=="SETTABLE" then add(x.a) add(x.b) add(x.c)
					elseif n=="GETTABLEKS" or n=="GETTABLEN" or n=="GETUDATAKS" then add(x.b)
					elseif n=="SETTABLEKS" or n=="SETTABLEN" or n=="SETUDATAKS" then add(x.a) add(x.b)
					elseif n=="NAMECALL" or n=="NAMECALLUDATA" then add(x.b)
					elseif n=="CALL" or n=="CALLFB" then
						add(x.a)
						local last=x.b==0 and math.max(x.a,(p.max or x.a+1)-1) or (x.a+x.b-1)
						for r=x.a+1,last do add(r) end
					elseif n=="RETURN" then
						local last=x.b==0 and math.max(x.a,(p.max or x.a+1)-1) or (x.a+x.b-2)
						for r=x.a,last do add(r) end
					elseif cfgcondops[n] then
						add(x.a)
						if n=="JUMPIFEQ" or n=="JUMPIFLE" or n=="JUMPIFLT" or n=="JUMPIFNOTEQ" or n=="JUMPIFNOTLE" or n=="JUMPIFNOTLT" then add((x.aux or 0)%256) end
					elseif n=="ADD" or n=="SUB" or n=="MUL" or n=="DIV" or n=="MOD" or n=="POW" or n=="AND" or n=="OR" or n=="IDIV" then add(x.b) add(x.c)
					elseif n=="ADDK" or n=="SUBK" or n=="MULK" or n=="DIVK" or n=="MODK" or n=="POWK" or n=="ANDK" or n=="ORK" or n=="IDIVK" then add(x.b)
					elseif n=="SUBRK" or n=="DIVRK" then add(x.c)
					elseif n=="CONCAT" then for r=x.b,x.c do add(r) end
					elseif n=="SETLIST" then
						add(x.a)
						local last=x.c==0 and math.max(x.b,(p.max or x.b+1)-1) or (x.b+x.c-2)
						for r=x.b,last do add(r) end
					elseif n=="FORNPREP" or n=="FORNLOOP" then for r=x.a,x.a+3 do add(r) end
					elseif n=="FORGPREP" or n=="FORGPREP_INEXT" or n=="FORGPREP_NEXT" or n=="FORGLOOP" then
						for r=x.a,x.a+2 do add(r) end
					elseif n=="NEWCLASS" and x.b~=255 then add(x.b)
					elseif n=="NEWCLASSMEMBER" then add(x.a) add(x.c)
					elseif n=="CAPTURE" and (x.a==0 or x.a==1) then add(x.b)
					end
					return out
				end
				local ssaBlockUse,ssaBlockDef={},{}
				for _,b in ipairs(blocks) do
					local use,def={},{}
					if reachableBlock[b.id] then
						for _,y in ipairs(b.ins) do
							for _,r in ipairs(readRegs(y)) do if not def[r] then use[r]=true end end
							for _,r in ipairs(writeRegs(y)) do def[r]=true end
						end
					end
					ssaBlockUse[b.id]=use ssaBlockDef[b.id]=def
				end
				local ssaLiveIn,ssaLiveOut={},{}
				for _,b in ipairs(blocks) do ssaLiveIn[b.id]={} ssaLiveOut[b.id]={} end
				local function ssaSetEq(a,b)
					for k in pairs(a) do if not b[k] then return false end end
					for k in pairs(b) do if not a[k] then return false end end
					return true
				end
				local ssaLiveChanged=true
				local ssaLiveRounds=0
				while ssaLiveChanged and ssaLiveRounds<512 do
					ssaLiveChanged=false ssaLiveRounds+=1
					for bi=#blocks,1,-1 do
						local b=blocks[bi]
						if reachableBlock[b.id] then
							local out={}
							for _,sid in ipairs(b.succ) do if reachableBlock[sid] then for r in pairs(ssaLiveIn[sid]) do out[r]=true end end end
							local inn={}
							for r in pairs(ssaBlockUse[b.id]) do inn[r]=true end
							for r in pairs(out) do if not ssaBlockDef[b.id][r] then inn[r]=true end end
							if not ssaSetEq(out,ssaLiveOut[b.id]) then ssaLiveOut[b.id]=out ssaLiveChanged=true end
							if not ssaSetEq(inn,ssaLiveIn[b.id]) then ssaLiveIn[b.id]=inn ssaLiveChanged=true end
						end
					end
					breathe()
				end
				ssaDefs={}
				ssaWriteId={}
				local ssaPhiId={}
				local ssaNext=1
				local function newSsaDef(reg,pc,op,kind)
					local id=ssaNext
					ssaNext+=1
					local db=pc and pc>=0 and blockOf[pc] or (blockOf[0] or 1)
					ssaDefs[id]={id=id,reg=reg,pc=pc,op=op,kind=kind or "write",uses=0,blocks={},receiver=false,cross=false,defBlock=db,firstUsePc=nil,lastUsePc=nil}
					return id
				end
				ssaParam={}
				for r=0,(p.params or 0)-1 do ssaParam[r]=newSsaDef(r,-1,"PARAM","param") end
				for _,y in ipairs(p.ins) do
					local wm={}
					for _,r in ipairs(writeRegs(y)) do wm[r]=newSsaDef(r,y.pc,y.n,"write") end
					ssaWriteId[y.pc]=wm
				end
				local function ssaCopy(m)
					local o={}
					if m then for r,id in pairs(m) do o[r]=id end end
					return o
				end
				local function ssaMapEq(a,b)
					for r,id in pairs(a or {}) do if (b or {})[r]~=id then return false end end
					for r,id in pairs(b or {}) do if (a or {})[r]~=id then return false end end
					return true
				end
				local function ssaPhi(bid,r)
					local pm=ssaPhiId[bid]
					if not pm then pm={} ssaPhiId[bid]=pm end
					if not pm[r] then pm[r]=newSsaDef(r,blocks[bid] and blocks[bid].start or -1,"PHI","phi") end
					return pm[r]
				end
				local ssaIn,ssaOut={},{}
				local ssaEntry=blockOf[0] or 1
				local ssaRounds=0
				local ssaChanged=true
				while ssaChanged and ssaRounds<256 do
					ssaChanged=false
					ssaRounds+=1
					for _,b in ipairs(blocks) do
						if reachableBlock[b.id] then
							local incoming={}
							local needed=ssaLiveIn[b.id] or {}
							if b.id==ssaEntry then
								for r in pairs(needed) do local id=ssaParam[r] if id then incoming[r]=id end end
							else
								local first=true
								local seenAny=false
								for _,pid in ipairs(b.pred) do
									if reachableBlock[pid] and ssaOut[pid] then
										seenAny=true
										if first then
											for r in pairs(needed) do incoming[r]=ssaOut[pid][r] end
											first=false
										else
											for r in pairs(needed) do
												local a=incoming[r]
												local c=ssaOut[pid][r]
												if a~=c then incoming[r]=ssaPhi(b.id,r) end
											end
										end
									end
								end
								if not seenAny then incoming={} end
							end
							local st=ssaCopy(incoming)
							for _,y in ipairs(b.ins) do
								for r,id in pairs(ssaWriteId[y.pc] or {}) do st[r]=id end
							end
							if not ssaMapEq(ssaIn[b.id],incoming) then ssaIn[b.id]=incoming ssaChanged=true end
							if not ssaMapEq(ssaOut[b.id],st) then ssaOut[b.id]=st ssaChanged=true end
						end
					end
					breathe()
				end
				ssaReadAt={}
				local ssaMutationOps={SETTABLE=true,SETTABLEKS=true,SETTABLEN=true,SETUDATAKS=true,SETLIST=true,NEWCLASSMEMBER=true}
				for _,b in ipairs(blocks) do
					if reachableBlock[b.id] then
						local st=ssaCopy(ssaIn[b.id] or {})
						for _,y in ipairs(b.ins) do
							local rm={}
							for _,r in ipairs(readRegs(y)) do
								local id=st[r]
								if id then
									rm[r]=id
									local d=ssaDefs[id]
									if d then
										d.uses+=1
										d.blocks[b.id]=true
										if d.defBlock and d.defBlock~=b.id then d.cross=true end
										if not d.firstUsePc or y.pc<d.firstUsePc then d.firstUsePc=y.pc end
										if not d.lastUsePc or y.pc>d.lastUsePc then d.lastUsePc=y.pc end
										if (y.n=="SETTABLE" or y.n=="SETTABLEKS" or y.n=="SETTABLEN" or y.n=="SETUDATAKS") and r==y.b then d.receiver=true end
										if y.n=="SETLIST" and r==y.a then d.receiver=true end
										if y.n=="NAMECALL" or y.n=="NAMECALLUDATA" then if r==y.b then d.receiver=true end end
										if y.n=="NEWCLASSMEMBER" and r==y.a then d.receiver=true end
									end
								end
							end
							ssaReadAt[y.pc]=rm
							for r,id in pairs(ssaWriteId[y.pc] or {}) do st[r]=id end
						end
					end
				end
				local defConst={}
				local defConstSet={}
				for _,y in ipairs(p.ins) do
					local wm=ssaWriteId[y.pc] or {}
					local id=wm[y.a]
					if id then
						if y.n=="LOADNIL" then defConst[id]="nil" defConstSet[id]=true
						elseif y.n=="LOADB" then defConst[id]=y.b~=0 and "true" or "false" defConstSet[id]=true
						elseif y.n=="LOADN" then defConst[id]=tostring(y.d) defConstSet[id]=true
						elseif y.n=="LOADK" then defConst[id]=kval(p,math.floor(y.w/65536)%65536) defConstSet[id]=true
						elseif y.n=="LOADKX" then defConst[id]=kval(p,y.aux or 0) defConstSet[id]=true
						elseif y.n=="MOVE" then
							local src=ssaReadAt[y.pc] and ssaReadAt[y.pc][y.b]
							if src and defConstSet[src] then defConst[id]=defConst[src] defConstSet[id]=true end
						end
					end
				end
				local diamondForMerge={}
				for _,cb in ipairs(blocks) do
					if reachableBlock[cb.id] and ipdom[cb.id] and ipdom[cb.id]~=EXIT_ID then
						local merge=ipdom[cb.id]
						local last=cb.ins[#cb.ins]
						if last and condops[last.n] and last.n~="CMPPROTO" then
							local jid=blockOf[jumptarget(last)]
							local fid=blockOf[nextpc(last)]
							local mb=blocks[merge]
							if mb and #mb.pred==2 then
								local hasJ,hasF=false,false
								for _,pid in ipairs(mb.pred) do if pid==jid then hasJ=true elseif pid==fid then hasF=true end end
								if hasJ and hasF then diamondForMerge[merge]={condPc=last.pc,jumpId=jid,fallId=fid} end
							end
						end
					end
				end
				local simplifiedPhi={}
				local ssaSimplifiedPhi=0
				local ssaPhiCount=0
				local ssaReceiverDefs=0
				for bid,pm in pairs(ssaPhiId) do
					for r,id in pairs(pm) do
						ssaPhiCount+=1
						local b=blocks[bid]
						local sameConst=true
						local constValue=nil
						local haveConst=false
						if b then
							for _,pid in ipairs(b.pred) do
								local incoming=ssaOut[pid] and ssaOut[pid][r]
								if not incoming or not defConstSet[incoming] then sameConst=false break end
								local cv=defConst[incoming]
								if not haveConst then constValue=cv haveConst=true elseif cv~=constValue then sameConst=false break end
							end
						else sameConst=false end
						local diamond=diamondForMerge[bid]
						local ifFolded=false
						if not sameConst and diamond then
							local jdef=ssaOut[diamond.jumpId] and ssaOut[diamond.jumpId][r]
							local fdef=ssaOut[diamond.fallId] and ssaOut[diamond.fallId][r]
							if jdef and fdef and defConstSet[jdef] and defConstSet[fdef] then
								phiIf[id]={condPc=diamond.condPc,jumpValue=defConst[jdef],fallValue=defConst[fdef]}
								simplifiedPhi[id]=true
								ssaSimplifiedPhi+=1
								ifFolded=true
							end
						end
						if sameConst and haveConst then
							simplifiedPhi[id]=true
							ssaSimplifiedPhi+=1
							defExpr[id]=constValue
							defPure[id]=true
							defConst[id]=constValue defConstSet[id]=true
						elseif ifFolded then
						else
							phiRegs[r]=true
							local d=ssaDefs[id]
							if d then d.cross=true end
							if b then
								for _,pid in ipairs(b.pred) do
									local incoming=ssaOut[pid] and ssaOut[pid][r]
									if incoming then
										forceDef[incoming]=true
										phiLinks[#phiLinks+1]={id,incoming}
									end
								end
							end
						end
					end
				end
				local phiParent={}
				local function phiFind(id)
					local p0=phiParent[id]
					if not p0 then phiParent[id]=id return id end
					while p0~=phiParent[p0] do
						phiParent[p0]=phiParent[phiParent[p0]]
						p0=phiParent[p0]
					end
					local cur=id
					while phiParent[cur] and phiParent[cur]~=p0 do
						local nxt=phiParent[cur]
						phiParent[cur]=p0
						cur=nxt
					end
					return p0
				end
				local function phiUnion(a,b)
					local ra,rb=phiFind(a),phiFind(b)
					if ra~=rb then
						if ra<rb then phiParent[rb]=ra else phiParent[ra]=rb end
					end
				end
				for _,ln in ipairs(phiLinks) do phiUnion(ln[1],ln[2]) end
				for id in pairs(phiParent) do
					local root=phiFind(id)
					phiDefRoot[id]=root
					local members=phiGroupMembers[root]
					if not members then members={} phiGroupMembers[root]=members end
					members[#members+1]=id
				end
				for _,d in pairs(ssaDefs) do
					local bc=0
					for _ in pairs(d.blocks) do bc+=1 end
					if bc>1 then d.cross=true end
					if d.receiver then
						ssaReceiverDefs+=1
						if d.uses>1 or d.op=="NEWTABLE" or d.op=="DUPTABLE" or d.op=="NEWCLASS" or d.op=="CALL" or d.op=="CALLFB" or d.op=="NEWCLOSURE" or d.op=="DUPCLOSURE" then
							forceDef[d.id]=true
						end
					end
					if d.uses>1 and (d.op=="CALL" or d.op=="CALLFB" or d.op=="NEWCLOSURE" or d.op=="DUPCLOSURE" or d.op=="NEWTABLE" or d.op=="DUPTABLE" or d.op=="NEWCLASS") then
						forceDef[d.id]=true
					end
				end
				if depth==0 then
					local forcedCount=0
					for _ in pairs(forceDef) do forcedCount+=1 end
					GENV.DEX_LAST_ANALYSIS={
						version=DECOMPILER_VERSION,
						valueIR=true,
						blocks=#blocks,
						ssaDefs=ssaNext-1,
						phi=ssaPhiCount,
						simplifiedPhi=ssaSimplifiedPhi,
						stableReceivers=ssaReceiverDefs,
						forcedDefs=forcedCount,
						instructions=#p.ins
					}
				end
				local blockUse,blockDef={},{}
				for _,b in ipairs(blocks) do
					local use,def={},{}
					if reachableBlock[b.id] then
						for _,y in ipairs(b.ins) do
							for _,r in ipairs(readRegs(y)) do if not def[r] then use[r]=true end end
							for _,r in ipairs(writeRegs(y)) do def[r]=true end
						end
					end
					blockUse[b.id]=use blockDef[b.id]=def
				end
				local liveIn,liveOut={},{}
				for _,b in ipairs(blocks) do liveIn[b.id]={} liveOut[b.id]={} end
				local function sameSet(a,b)
					for k in pairs(a) do if not b[k] then return false end end
					for k in pairs(b) do if not a[k] then return false end end
					return true
				end
				local changed=true
				local rounds=0
				while changed and rounds<512 do
					changed=false rounds+=1
					for bi=#blocks,1,-1 do
						local b=blocks[bi]
						if reachableBlock[b.id] then
							local no={}
							for _,sid in ipairs(b.succ) do if reachableBlock[sid] then for r in pairs(liveIn[sid]) do no[r]=true end end end
							local ni={}
							for r in pairs(blockUse[b.id]) do ni[r]=true end
							for r in pairs(no) do if not blockDef[b.id][r] then ni[r]=true end end
							if not sameSet(no,liveOut[b.id]) then liveOut[b.id]=no changed=true end
							if not sameSet(ni,liveIn[b.id]) then liveIn[b.id]=ni changed=true end
						end
					end
					breathe()
				end
				local boolFold={}
				for _,x in ipairs(p.ins) do
					if condops[x.n] and x.n~="CMPPROTO" and staticBranch[x.pc]==nil then
						local target=jumptarget(x)
						local f=byPc[nextpc(x)]
						local j=byPc[target]
						if f and j and f.n=="LOADB" and j.n=="LOADB" and f.a==j.a and f.c~=0 and f.pc+1+f.c==nextpc(j) then
							boolFold[x.pc]={reg=f.a,fall=f.b~=0,jump=j.b~=0}
							skipPc[f.pc]=true
							skipPc[j.pc]=true
						end
					end
				end
				local function forceRange(a,b)
					if b>a then forceRanges[#forceRanges+1]={a,b} end
				end
				local loopByPrepPc={}
				local loopByLatchPc={}
				for ii,lx in ipairs(p.ins) do
					if lx.n=="FORNPREP" then
						local exit=jumptarget(lx)
						for jj=ii+1,#p.ins do
							local bx=p.ins[jj]
							if bx.pc>=exit then break end
							if bx.n=="FORNLOOP" and bx.a==lx.a and jumptarget(bx)==nextpc(lx) and nextpc(bx)==exit then
								local lr={kind="forn",start=lx.pc,finish=exit,cont=bx.pc,prep=lx.pc,latch=bx.pc,emitted=false}
								loopRanges[#loopRanges+1]=lr loopByPrepPc[lx.pc]=lr loopByLatchPc[bx.pc]=lr
								break
							end
						end
					elseif lx.n=="FORGPREP" or lx.n=="FORGPREP_INEXT" or lx.n=="FORGPREP_NEXT" then
						local bx=byPc[jumptarget(lx)]
						if bx and bx.n=="FORGLOOP" and bx.a==lx.a and jumptarget(bx)==nextpc(lx) then
							local lr={kind="forg",start=lx.pc,finish=nextpc(bx),cont=bx.pc,prep=lx.pc,latch=bx.pc,emitted=false}
							loopRanges[#loopRanges+1]=lr loopByPrepPc[lx.pc]=lr loopByLatchPc[bx.pc]=lr
						end
					end
				end
				for _,lr in ipairs(loopRanges) do
					if lr.kind=="forn" then
						local px=byPc[lr.prep]
						local vr=px and (px.a+3) or nil
						local startId=px and blockOf[nextpc(px)] or nil
						if vr and startId then
							local q={{id=startId,open=true}}
							local qi=1
							local seenState={}
							local used=false
							while qi<=#q and not used and qi<4096 do
								local it=q[qi]
								qi+=1
								local key=tostring(it.id)..":"..tostring(it.open)
								if not seenState[key] then
									seenState[key]=true
									local b=blocks[it.id]
									if b and b.start>lr.start and b.start<lr.finish then
										local open=it.open
										for _,y in ipairs(b.ins) do
											if open then
												for _,r in ipairs(readRegs(y)) do if r==vr then used=true break end end
												if used then break end
												for _,r in ipairs(writeRegs(y)) do if r==vr then open=false break end end
											end
										end
										if not used and b.finish<lr.cont then for _,sid in ipairs(b.succ) do q[#q+1]={id=sid,open=open} end end
									end
								end
							end
							lr.iterUnused=not used
						end
					end
				end
				local structuredCond={}
				local function singleUncondBlock(id)
					local b=id and blocks[id]
					if not b or not reachableBlock[id] or #b.ins~=1 then return nil end
					local y=b.ins[1]
					if y.n=="JUMP" or y.n=="JUMPBACK" or y.n=="JUMPX" then return y end
				end
				local function canReachWithin(startId,goalId,minpc,maxpc)
					if not startId or not goalId then return false end
					local qids={startId}
					local qi=1
					local seenIds={}
					local steps=0
					while qi<=#qids and steps<math.min(#blocks+8,4096) do
						local id=qids[qi] qi+=1 steps+=1
						if id==goalId then return true end
						if not seenIds[id] then
							seenIds[id]=true
							local b=blocks[id]
							if b and b.start>=minpc and b.start<=maxpc then
								for _,sid in ipairs(b.succ) do
									local sb=blocks[sid]
									if sb and reachableBlock[sid] and sb.start>=minpc and sb.start<=maxpc and not seenIds[sid] then qids[#qids+1]=sid end
								end
							end
						end
					end
					return false
				end
				local function allPathsTerminateBefore(startId,boundaryPc)
					local memo={}
					local visiting={}
					local function walk(id)
						if memo[id]~=nil then return memo[id] end
						if visiting[id] then return false end
						local b=id and blocks[id]
						if not b or not reachableBlock[id] or b.start>=boundaryPc then memo[id]=false return false end
						visiting[id]=true
						local last=b.ins[#b.ins]
						if last and last.n=="RETURN" then
							visiting[id]=nil memo[id]=true return true
						end
						local any=false
						for _,sid in ipairs(b.succ) do
							local sb=blocks[sid]
							if sb and reachableBlock[sid] then
								any=true
								if sb.start>=boundaryPc or not walk(sid) then visiting[id]=nil memo[id]=false return false end
							end
						end
						visiting[id]=nil
						memo[id]=any
						return any
					end
					return walk(startId)
				end
				local function skipJumpsTo(startPc,endPc,targetPc)
					for _,b in ipairs(blocks) do
						if reachableBlock[b.id] and b.start>=startPc and b.start<endPc then
							local y=b.ins[#b.ins]
							if y and (y.n=="JUMP" or y.n=="JUMPX" or y.n=="JUMPBACK") and jumptarget(y)==targetPc then
								skipPc[y.pc]=true
							end
						end
					end
				end
				local backLatch={}
				for _,b in ipairs(blocks) do
					if reachableBlock[b.id] then
						local latch=b.ins[#b.ins]
						if latch and (latch.n=="JUMPBACK" or latch.n=="JUMP" or latch.n=="JUMPX") then
							local hid=blockOf[jumptarget(latch)]
							local hb=hid and blocks[hid]
							if hb and hb.start<=b.start and dominates(hid,b.id) then
								local old=backLatch[hid]
								if not old or b.start>old.start then backLatch[hid]=b end
							end
						end
					end
				end
				for hid,b in pairs(backLatch) do
					local latch=b.ins[#b.ins]
					local hb=blocks[hid]
					local hx=hb and hb.ins[#hb.ins]
					if hx and condops[hx.n] and not boolFold[hx.pc] and not structuredCond[hx.pc] then
						local fid=blockOf[nextpc(hx)]
						local jid=blockOf[jumptarget(hx)]
						local fr=fid and canReachWithin(fid,b.id,hb.start,b.finish) or false
						local jr=jid and canReachWithin(jid,b.id,hb.start,b.finish) or false
						if fr~=jr then
							local bodyId=fr and fid or jid
							local exitId=fr and jid or fid
							local eb=exitId and blocks[exitId]
							if eb and eb.start>b.start then
								local lr={kind="while",start=hb.start,finish=eb.start,cont=hb.start,latch=latch.pc,emitted=false}
								structure[hx.pc]={kind="whilecfg",mode=(bodyId==fid and "fall" or "jump"),loop=lr}
								structuredCond[hx.pc]=true
								skipPc[latch.pc]=true
								endAt[eb.start]=(endAt[eb.start] or 0)+1
								loopRanges[#loopRanges+1]=lr
							end
						end
					end
					breathe()
				end
				for _,x in ipairs(p.ins) do
					if condops[x.n] and staticBranch[x.pc]==nil and not boolFold[x.pc] and not structuredCond[x.pc] then
						local target=jumptarget(x)
						local np=nextpc(x)
						if target==np then
							skipPc[x.pc]=true
						elseif target< x.pc then
							local hid=blockOf[target]
							local bid=blockOf[x.pc]
							if hid and bid and dominates(hid,bid) then
								local lr={kind="repeat",start=target,finish=nextpc(x),cont=x.pc,latch=x.pc,emitted=false}
								structure[x.pc]={kind="untilcfg",mode="fall",loop=lr}
								repeatAt[target]=(repeatAt[target] or 0)+1
								structuredCond[x.pc]=true
								loopRanges[#loopRanges+1]=lr
							end
						elseif target>np and byPc[target] then
							local fallId=blockOf[np]
							local jumpId=blockOf[target]
							local bid=blockOf[x.pc]
							if GENV.DEX_POSTDOM_STRUCTURING~=false and bid then
								local mid=ipdom[bid]
								local mb=mid and mid~=EXIT_ID and blocks[mid] or nil
								if mb and mb.start>=target and mb.start>x.pc then
									if mid==jumpId then
										structure[x.pc]={kind="ifcfg",mode="fall"}
										endAt[mb.start]=(endAt[mb.start] or 0)+1
										skipJumpsTo(np,mb.start,mb.start)
										structuredCond[x.pc]=true
									elseif mid~=fallId and mb.start>target then
										local fr=canReachWithin(fallId,mid,np,mb.start)
										local jr=canReachWithin(jumpId,mid,target,mb.start)
										if fr and jr then
											structure[x.pc]={kind="ifcfg",mode="fall"}
											elseAt[target]=(elseAt[target] or 0)+1
											endAt[mb.start]=(endAt[mb.start] or 0)+1
											skipJumpsTo(np,mb.start,mb.start)
											structuredCond[x.pc]=true
										end
									end
								end
							end
							if not structuredCond[x.pc] and GENV.DEX_OBFUSCATION_GUARDS~=false and fallId and allPathsTerminateBefore(fallId,target) then
								structure[x.pc]={kind="ifcfg",mode="fall"}
								endAt[target]=(endAt[target] or 0)+1
								structuredCond[x.pc]=true
							end
							if not structuredCond[x.pc] then
								local trampoline=singleUncondBlock(fallId)
								if trampoline then
									local ft=jumptarget(trampoline)
									if ft>target and byPc[ft] then
										structure[x.pc]={kind="ifcfg",mode="jump"}
										skipPc[trampoline.pc]=true
										endAt[ft]=(endAt[ft] or 0)+1
										structuredCond[x.pc]=true
									end
								end
							end
							if not structuredCond[x.pc] then
								local ti=indexByPc[target]
								local prev=ti and p.ins[ti-1] or nil
								if prev and (prev.n=="JUMP" or prev.n=="JUMPX" or prev.n=="JUMPBACK") then
									local ft=jumptarget(prev)
									if ft>target and byPc[ft] then
										structure[x.pc]={kind="ifcfg",mode="fall"}
										elseAt[target]=(elseAt[target] or 0)+1
										skipPc[prev.pc]=true
										endAt[ft]=(endAt[ft] or 0)+1
										structuredCond[x.pc]=true
									end
								end
							end
							if not structuredCond[x.pc] then
								structure[x.pc]={kind="ifcfg",mode="fall"}
								endAt[target]=(endAt[target] or 0)+1
								structuredCond[x.pc]=true
							end
						end
					end
					breathe()
				end
				for i=0,p.params-1 do
					local dl=dbglocal(i,0)
					local dn=dl and cleanname(dl.name) or nil
					local n=unique(dn or (GENV.DEX_SEMANTIC_NAMES~=false and semanticHints[i] or nil) or ("a"..tostring(i+1))) or ("a"..tostring(i+1))
					names[i]=n
					nameLife[i]=dn
					vars[i]=true
					expr[i]=n
					declaredNames[n]=true
					local id=ssaParam and ssaParam[i]
					if id then defName[id]=n defExpr[id]=n defMaterialized[id]=true defPure[id]=true end
				end
				for root,members in pairs(phiGroupMembers) do
					local paramReg=nil
					local regHint=nil
					local dbgHint=nil
					for _,id in ipairs(members) do
						local d=ssaDefs[id]
						if d then
							regHint=regHint or d.reg
							if d.kind=="param" then paramReg=d.reg end
							if not dbgHint and p.locals then
								for _,l in ipairs(p.locals) do
									if l.reg==d.reg then dbgHint=cleanname(l.name) break end
								end
							end
						end
					end
					local n
					if paramReg~=nil and names[paramReg] then
						n=names[paramReg]
					else
						local r=regHint or 0
						n=unique(dbgHint or (GENV.DEX_SEMANTIC_NAMES~=false and semanticHints[r] or nil) or ("v"..tostring(r))) or ("v"..tostring(r))
						emit("local "..n)
						declaredNames[n]=true
					end
					phiGroupName[root]=n
					if n then
						declaredNames[n]=true
						for _,id in ipairs(members) do
							local d=ssaDefs[id]
							defName[id]=n
							if d and d.kind=="phi" then
								defExpr[id]=n
								defMaterialized[id]=true
								defPure[id]=true
							end
						end
					end
				end
				local bin={ADD="+",SUB="-",MUL="*",DIV="/",MOD="%",POW="^",AND="and",OR="or",IDIV="//"}
				local bink={ADDK="+",SUBK="-",MULK="*",DIVK="/",MODK="%",POWK="^",ANDK="and",ORK="or",IDIVK="//"}
				local function jumpcond(x)
					local n=x.n
					if n=="JUMPIF" then return reg(x.a) end
					if n=="JUMPIFNOT" then return "(not "..reg(x.a)..")" end
					local rb=(x.aux or 0)%256
					local direct={JUMPIFEQ="==",JUMPIFLE="<=",JUMPIFLT="<",JUMPIFNOTEQ="~=",JUMPIFNOTLE=">",JUMPIFNOTLT=">="}
					if direct[n] then return reg(x.a).." "..direct[n].." "..reg(rb) end
					if n=="JUMPXEQKNIL" then
						local notf=math.floor((x.aux or 0)/2147483648)%2
						return reg(x.a)..(notf==1 and " ~= nil" or " == nil")
					elseif n=="JUMPXEQKB" then
						local aux=x.aux or 0
						local val=aux%2~=0
						local notf=math.floor(aux/2147483648)%2
						return reg(x.a).." "..(notf==1 and "~=" or "==").." "..tostring(val)
					elseif n=="JUMPXEQKN" or n=="JUMPXEQKS" then
						local aux=x.aux or 0
						local ci=aux%16777216
						local notf=math.floor(aux/2147483648)%2
						return reg(x.a).." "..(notf==1 and "~=" or "==").." "..kval(p,ci)
					elseif n=="CMPPROTO" then
						return "type("..reg(x.a)..") ~= \"function\""
					end
					return "true"
				end
				local function fallcond(x)
					local n=x.n
					if n=="JUMPIF" then return "(not "..reg(x.a)..")" end
					if n=="JUMPIFNOT" then return reg(x.a) end
					local rb=(x.aux or 0)%256
					local inv={JUMPIFEQ="~=",JUMPIFLE=">",JUMPIFLT=">=",JUMPIFNOTEQ="==",JUMPIFNOTLE="<=",JUMPIFNOTLT="<"}
					if inv[n] then return reg(x.a).." "..inv[n].." "..reg(rb) end
					if n=="JUMPXEQKNIL" then
						local notf=math.floor((x.aux or 0)/2147483648)%2
						return reg(x.a)..(notf==1 and " == nil" or " ~= nil")
					elseif n=="JUMPXEQKB" then
						local aux=x.aux or 0
						local val=aux%2~=0
						local notf=math.floor(aux/2147483648)%2
						return reg(x.a).." "..(notf==1 and "==" or "~=").." "..tostring(val)
					elseif n=="JUMPXEQKN" or n=="JUMPXEQKS" then
						local aux=x.aux or 0
						local ci=aux%16777216
						local notf=math.floor(aux/2147483648)%2
						return reg(x.a).." "..(notf==1 and "==" or "~=").." "..kval(p,ci)
					elseif n=="CMPPROTO" then
						return "type("..reg(x.a)..") == \"function\""
					end
					return "true"
				end
				renderPhiIf=function(id)
					local d=phiIf[id]
					if not d then return nil end
					local x=byPc[d.condPc]
					if not x then return nil end
					local oldpc=currentPc
					currentPc=x.pc
					local c=jumpcond(x)
					currentPc=oldpc
					return "(if "..c.." then "..d.jumpValue.." else "..d.fallValue..")"
				end
				local function loopfor(pc)
					local best
					for _,lr in ipairs(loopRanges) do
						if lr.emitted and pc>lr.start and pc<lr.finish and (not best or lr.start>=best.start) then best=lr end
					end
					return best
				end
				local function purecall(fn,m)
					if m then
						if m.base=="game" and m.name=="GetService" then return true end
						return false
					end
					if type(fn)~="string" then return false end
					if fn=="type" or fn=="typeof" or fn=="tostring" or fn=="tonumber" then return true end
					local safeString={["string.byte"]=true,["string.char"]=true,["string.find"]=true,["string.format"]=true,["string.len"]=true,["string.lower"]=true,["string.match"]=true,["string.pack"]=true,["string.packsize"]=true,["string.rep"]=true,["string.reverse"]=true,["string.sub"]=true,["string.unpack"]=true,["string.upper"]=true}
					if safeString[fn] or fn:match("^bit32%.") or fn:match("^buffer%.read") then return true end
					local root=fn:match("^([%a_][%w_]*)%.")
					if root and immutableConstructors[root] then return true end
					if fn:match("^math%.") and fn~="math.random" and fn~="math.randomseed" then return true end
					return false
				end
				local function normalizecall(m,args,call)
					if m and m.base=="game" and m.name=="GetService" and #args==1 then
						local svc=args[1]:match('^"([%w_]+)"$')
						if svc and (next(robloxServices)==nil or robloxServices[svc]) then
							if svc=="Workspace" then return "workspace" end
							return 'game:GetService("'..svc..'")'
						end
					end
					return call
				end
				local i=1
				while i<=#p.ins do
					breathe()
					local x=p.ins[i]
					currentPc=x.pc
					local n=x.n
					if not reachablePc[x.pc] then i+=1 continue end
					if endAt[x.pc] then
						for _=1,endAt[x.pc] do level=math.max(1,level-1) emitLevel("end",level) end
					end
					if repeatAt[x.pc] then
						for _=1,repeatAt[x.pc] do emit("repeat") level+=1 end
					end
					if elseAt[x.pc] then
						for _=1,elseAt[x.pc] do level=math.max(1,level-1) emitLevel("else",level) level+=1 end
					end
					local bid=blockOf[x.pc]
					local bb=bid and blocks[bid]
					if bb and bb.start==x.pc and x.pc~=0 then
						local nonLinearPred=false
						for _,pid in ipairs(bb.pred) do
							local pb=blocks[pid]
							local pl=pb and pb.ins[#pb.ins]
							if not pl or nextpc(pl)~=bb.start then nonLinearPred=true break end
						end
						if #bb.pred>1 or nonLinearPred then
							for r in pairs(liveIn[bid] or {}) do
								if vars[r] then expr[r]=names[r] else expr[r]=nil multi[r]=nil end
							end
						end
					end
					if skipPc[x.pc] then i+=1 continue end
					if staticBranch[x.pc]~=nil then i+=1 continue end
					local bf=boolFold[x.pc]
					if bf then
						local value
						if bf.jump==bf.fall then
							value=bf.jump and "true" or "false"
						elseif bf.jump then
							value="("..jumpcond(x)..")"
						else
							value="("..fallcond(x)..")"
						end
						put(bf.reg,value,x.pc,false,true)
						i+=1
						continue
					end
					local st=structure[x.pc]
					if type(st)=="table" and st.kind=="ifcfg" then
						emit("if "..(st.mode=="jump" and jumpcond(x) or fallcond(x)).." then")
						level+=1
						i+=1
						continue
					elseif type(st)=="table" and st.kind=="whilecfg" then
						emit("while "..(st.mode=="jump" and jumpcond(x) or fallcond(x)).." do")
						if st.loop then st.loop.emitted=true end
						level+=1
						i+=1
						continue
					elseif type(st)=="table" and st.kind=="untilcfg" then
						if st.loop then st.loop.emitted=true end
						level=math.max(1,level-1)
						emitLevel("until "..(st.mode=="jump" and jumpcond(x) or fallcond(x)),level)
						i+=1
						continue
					end
					if n=="UNKNOWN" then
						for r=0,(p.max or 0)-1 do
							local v=expr[r] or multi[r]
							if v and not vars[r] and type(v)=="string" then materialize(r,v,x.pc) end
							if vars[r] then expr[r]=names[r] else expr[r]=nil end
							multi[r]=nil
							forceVar[r]=true
						end
						top=math.max(top,p.params or 0)
					elseif vmNoopOps[n] then
					elseif n=="LOADNIL" then put(x.a,"nil",x.pc,false,true)
					elseif n=="LOADB" then put(x.a,x.b~=0 and "true" or "false",x.pc,false,true)
					elseif n=="LOADN" then put(x.a,tostring(x.d),x.pc,false,true)
					elseif n=="LOADK" then put(x.a,kval(p,math.floor(x.w/65536)%65536),x.pc,false,true)
					elseif n=="LOADKX" then put(x.a,kval(p,x.aux or 0),x.pc,false,true)
					elseif n=="MOVE" then put(x.a,reg(x.b),x.pc,false,regpure(x.b))
					elseif n=="GETGLOBAL" then
						local s=kstr(p,x.aux or 0)
						put(x.a,s and (ident(s) and s or ("_G["..q(s).."]")) or "_G",x.pc,false,s=="game" or s=="workspace")
					elseif n=="SETGLOBAL" then
						local s=kstr(p,x.aux or 0)
						emit((s and (ident(s) and s or ("_G["..q(s).."]")) or "_G").." = "..reg(x.a))
					elseif n=="GETIMPORT" then put(x.a,importpath(p,x.aux or 0),x.pc,false,true)
					elseif n=="GETUPVAL" then put(x.a,upname(x.b),x.pc,false,false)
					elseif n=="SETUPVAL" then emit(upname(x.b).." = "..reg(x.a))
					elseif n=="GETTABLE" then put(x.a,reg(x.b).."["..reg(x.c).."]",x.pc,false,false)
					elseif n=="SETTABLE" then emit(reg(x.b).."["..reg(x.c).."] = "..reg(x.a))
					elseif n=="GETTABLEKS" or n=="GETUDATAKS" then
						local ci=n=="GETUDATAKS" and ((x.aux or 0)%65536) or (x.aux or 0)
						put(x.a,prop(reg(x.b),kstr(p,ci)),x.pc,false,false)
					elseif n=="SETTABLEKS" or n=="SETUDATAKS" then
						local ci=n=="SETUDATAKS" and ((x.aux or 0)%65536) or (x.aux or 0)
						emit(prop(reg(x.b),kstr(p,ci)).." = "..reg(x.a))
					elseif n=="GETTABLEN" then put(x.a,reg(x.b).."["..tostring(x.c+1).."]",x.pc,false,false)
					elseif n=="SETTABLEN" then emit(reg(x.b).."["..tostring(x.c+1).."] = "..reg(x.a))
					elseif bin[n] then
						local logical=n=="AND" or n=="OR"
						put(x.a,"("..reg(x.b).." "..bin[n].." "..reg(x.c)..")",x.pc,false,logical and regpure(x.b) and regpure(x.c))
					elseif bink[n] then
						local logical=n=="ANDK" or n=="ORK"
						put(x.a,"("..reg(x.b).." "..bink[n].." "..kval(p,x.c)..")",x.pc,false,logical and regpure(x.b))
					elseif n=="SUBRK" then put(x.a,"("..kval(p,x.b).." - "..reg(x.c)..")",x.pc,false,false)
					elseif n=="DIVRK" then put(x.a,"("..kval(p,x.b).." / "..reg(x.c)..")",x.pc,false,false)
					elseif n=="NOT" then put(x.a,"(not "..reg(x.b)..")",x.pc,false,regpure(x.b))
					elseif n=="MINUS" then put(x.a,"(-"..reg(x.b)..")",x.pc,false,false)
					elseif n=="LENGTH" then put(x.a,"(#"..reg(x.b)..")",x.pc,false,false)
					elseif n=="CONCAT" then
						local a={}
						for r=x.b,x.c do a[#a+1]=reg(r) end
						put(x.a,"("..table.concat(a," .. ")..")",x.pc,false,false)
					elseif n=="NEWTABLE" then put(x.a,"{}",x.pc,false,true)
					elseif n=="DUPTABLE" then put(x.a,kval(p,x.d),x.pc,false,true)
					elseif n=="SETLIST" then
						local start=x.aux or 1
						if x.c==0 then
							local vals={}
							local hasMulti=false
							for r=x.b,top-1 do
								local mv=multireg(r)
								if mv then vals[#vals+1]=mv hasMulti=true break end
								vals[#vals+1]=reg(r)
							end
							if hasMulti then
								local tn=unique("values") or "values"
								emit("local "..tn.." = table.pack("..table.concat(vals,", ")..")")
								emit("table.move("..tn..", 1, "..tn..".n, "..tostring(start)..", "..reg(x.a)..")")
							else
								for j,v in ipairs(vals) do emit(reg(x.a).."["..tostring(start+j-1).."] = "..v) end
							end
						else
							local count=x.c-1
							for j=0,count-1 do emit(reg(x.a).."["..tostring(start+j).."] = "..reg(x.b+j)) end
						end
					elseif n=="NAMECALL" or n=="NAMECALLUDATA" then
						local ci=n=="NAMECALLUDATA" and ((x.aux or 0)%65536) or (x.aux or 0)
						clearMulti(x.a)
						clearMulti(x.a+1)
						touch(x.a,2)
						method[x.a]={base=reg(x.b),name=kstr(p,ci) or "method"}
						expr[x.a]=method[x.a].base..":"..method[x.a].name
						expr[x.a+1]=method[x.a].base
					elseif n=="CALL" or n=="CALLFB" then
						local args={}
						local m=method[x.a]
						if x.b==0 then
							for r=x.a+1,top-1 do
								if not (m and r==x.a+1) then
									local mv=multireg(r)
									if mv then args[#args+1]=mv break end
									args[#args+1]=reg(r)
								end
							end
						else
							for j=1,x.b-1 do
								if not (m and j==1) then args[#args+1]=reg(x.a+j) end
							end
						end
						local fn=m and (m.base..":"..m.name) or reg(x.a)
						local call=normalizecall(m,args,fn.."("..table.concat(args,", ")..")")
						method[x.a]=nil
						if x.c==1 then
							emit(call)
							expr[x.a]=nil
							multi[x.a]=nil
							top=x.a
						elseif x.c==0 then
							expr[x.a]=nil
							multi[x.a]=call
							local wid=writedef(x.a,x.pc)
							if wid then defMulti[wid]=call defExpr[wid]=nil defPure[wid]=false end
							top=x.a+1
						elseif x.c==2 then
							local wid=writedef(x.a,x.pc)
							local wd=wid and ssaDefs[wid]
							local callPure=purecall(fn,m)
							local firstUse=wd and wd.firstUsePc or nil
							local singleSafe=wd and wd.uses==1 and not wd.cross and not wd.receiver and (not firstUse or not barrierBetween(x.pc,firstUse))
							if callPure and wd and wd.uses<=1 and not wd.cross and not forcedef(x.a,x.pc) and not dbgname(x.a,x.pc) then
								put(x.a,call,x.pc,false,true)
							elseif singleSafe and not forcedef(x.a,x.pc) and not dbgname(x.a,x.pc) then
								put(x.a,call,x.pc,false,false)
							else
								materialize(x.a,call,x.pc)
							end
							top=x.a+1
						else
							local regs={}
							for j=0,x.c-2 do regs[#regs+1]=x.a+j end
							multiassign(regs,call,x.pc)
							top=x.a+x.c-1
						end
					elseif n=="GETVARARGS" then
						if x.b==0 then
							expr[x.a]=nil
							multi[x.a]="..."
							local wid=writedef(x.a,x.pc)
							if wid then defMulti[wid]="..." defExpr[wid]=nil defPure[wid]=true end
							top=x.a+1
						elseif x.b==2 then
							put(x.a,"...",x.pc,false,true)
							top=x.a+1
						else
							local regs={}
							for j=0,x.b-2 do regs[#regs+1]=x.a+j end
							multiassign(regs,"...",x.pc)
							top=x.a+x.b-1
						end
					elseif n=="NEWCLOSURE" or n=="DUPCLOSURE" then
						local cp
						if n=="NEWCLOSURE" then
							local ci=p.children[x.d+1]
							cp=ci and mod.protos[ci]
						else
							local k=p.k[x.d+1]
							cp=k and k.t==6 and mod.protos[(k.v or 0)+1]
						end
						local caps={}
						if cp then
							for u=0,cp.ups-1 do
								local cx=p.ins[i+1+u]
								if cx and cx.n=="CAPTURE" then
									if cx.a==0 or cx.a==1 then
										local rid=readdef(cx.b,cx.pc)
										if cx.a==1 and rid then forceDef[rid]=true end
										local value=regat(cx.b,cx.pc)
										if rid and not defMaterialized[rid] then value=materializeread(cx.b,cx.pc,value)
										elseif not rid and not vars[cx.b] then value=materializeread(cx.b,cx.pc,value) end
										caps[u]=value
									elseif cx.a==2 then
										caps[u]=upname(cx.b)
									end
									skipPc[cx.pc]=true
								end
							end
						end
						local childSource="function(...) end"
						if cp then
							local okChild,resChild=pcall(customsource,mod,cp,depth+1,seen,caps,true)
							if okChild and type(resChild)=="string" and resChild~="" then childSource=resChild end
						end
						local cid=writedef(x.a,x.pc)
						local cd=cid and ssaDefs[cid]
						if cd and cd.uses==1 and not cd.cross and not cd.receiver and not forcedef(x.a,x.pc) and not dbgname(x.a,x.pc) then
							put(x.a,childSource,x.pc,false,true)
						else
							materialize(x.a,childSource,x.pc)
						end
					elseif n=="CLOSEUPVALS" then
					elseif n=="RETURN" then
						local a={}
						if x.b==0 then
							for r=x.a,top-1 do
								local mv=multireg(r)
								if mv then a[#a+1]=mv break end
								a[#a+1]=reg(r)
							end
						else
							for j=0,x.b-2 do a[#a+1]=reg(x.a+j) end
						end
						emit(#a>0 and ("return "..table.concat(a,", ")) or "return")
					elseif n=="FORNPREP" then
						local lr=loopByPrepPc[x.pc]
						if lr then
							local vr=x.a+3
							local vn
							if lr.iterUnused then
								vn="_" expr[vr]=nil
							else
								vn=varname(vr,x.pc,nil) vars[vr]=true expr[vr]=vn
							end
							lr.emitted=true
							emit("for "..vn.." = "..reg(x.a+2)..", "..reg(x.a)..", "..reg(x.a+1).." do")
							level+=1
						end
					elseif n=="FORNLOOP" then
						local lr=loopByLatchPc[x.pc]
						if lr and lr.emitted then level=math.max(1,level-1) emitLevel("end",level) end
					elseif n=="FORGPREP" or n=="FORGPREP_INEXT" or n=="FORGPREP_NEXT" then
						local lr=loopByPrepPc[x.pc]
						if lr then
							local target=x.pc+1+x.d
							local loop=byPc[target]
							local vc=loop and loop.n=="FORGLOOP" and ((loop.aux or 1)%256) or 1
							if vc==0 then vc=1 end
							local vl={}
							for j=0,vc-1 do
								local r=x.a+3+j
								local nm=varname(r,x.pc,nil)
								vars[r]=true expr[r]=nm vl[#vl+1]=nm
							end
							lr.emitted=true
							emit("for "..table.concat(vl,", ").." in "..reg(x.a)..", "..reg(x.a+1)..", "..reg(x.a+2).." do")
							level+=1
						end
					elseif n=="FORGLOOP" then
						local lr=loopByLatchPc[x.pc]
						if lr and lr.emitted then level=math.max(1,level-1) emitLevel("end",level) end
					elseif n=="JUMP" or n=="JUMPBACK" or n=="JUMPX" then
						local t=jumptarget(x)
						local lr=loopfor(x.pc)
						if lr and (t==lr.cont or t<=lr.start) then
							emit("continue")
						elseif lr and t>=lr.finish then
							emit("break")
						end
					elseif n=="NEWCLASS" then put(x.a,"{}",x.pc,false,true)
					elseif n=="NEWCLASSMEMBER" then
						local s=kstr(p,x.aux or 0) or "member"
						emit(prop(reg(x.a),s).." = "..reg(x.c))
					end
					i+=1
				end
				local finalpc=#p.words
				if endAt[finalpc] then for _=1,endAt[finalpc] do level=math.max(1,level-1) emitLevel("end",level) end end
				while level>1 do level-=1 emitLevel("end",level) end
				seen[p]=nil
				local args={}
				for i=0,p.params-1 do args[#args+1]=names[i] or ("a"..tostring(i+1)) end
				if p.vararg then args[#args+1]="..." end
				local rawbody=table.concat(lines,"\n")
				local okClean,bodytext=pcall(cleanupsource,rawbody)
				if not okClean or type(bodytext)~="string" or not validstructure(bodytext) then bodytext=rawbody end
				if not validstructure(bodytext) then
					local safe={}
					local stack={}
					local function trim(x) return (x:gsub("^%s+",""):gsub("%s+$","")) end
					local function hasloop() for j=#stack,1,-1 do local k=stack[j] if k=="while" or k=="for" or k=="repeat" then return true end end return false end
					for line in (bodytext.."\n"):gmatch("(.-)\n") do
						local t=trim(line)
						if (t=="continue" or t=="break") and not hasloop() then
						else
							safe[#safe+1]=line
							if t:match("^if%s+.+%s+then$") then stack[#stack+1]="if"
							elseif t:match("^while%s+.+%s+do$") then stack[#stack+1]="while"
							elseif t:match("^for%s+.+%s+do$") then stack[#stack+1]="for"
							elseif t=="repeat" then stack[#stack+1]="repeat"
							elseif t=="do" then stack[#stack+1]="do"
							elseif (t:match("^local%s+function%s+") or t:match("^function%s+") or t:find("function%s*%(",1)) and not t:match("^return%s+function") and not t:match("%f[%a]end%f[%A]") then stack[#stack+1]="function"
							elseif t=="end" and #stack>0 and stack[#stack]~="repeat" then stack[#stack]=nil
							elseif t:match("^until%s+") and stack[#stack]=="repeat" then stack[#stack]=nil end
						end
					end
					bodytext=table.concat(safe,"\n")
				end
				if validstructure(bodytext) then bodytext=canonicalindent_source(bodytext) end
				local function parsecheck(src)
					if type(loadstring)~="function" then return true,nil end
					local ok,fn,err=pcall(loadstring,src)
					if not ok then return false,fn end
					return fn~=nil,err
				end
				local checksrc
				if depth==0 and not exprMode then checksrc=bodytext else checksrc="return function("..table.concat(args,", ")..")\n"..bodytext.."\nend" end
				local parsed,parseerr=parsecheck(checksrc)
				if not parsed then
					local rawcheck
					if depth==0 and not exprMode then rawcheck=rawbody else rawcheck="return function("..table.concat(args,", ")..")\n"..rawbody.."\nend" end
					local rawok,rawerr=parsecheck(rawcheck)
					if rawok then
						bodytext=rawbody
						parsed=true
						parseerr=nil
					else
						parseerr=tostring(parseerr or rawerr or "parse failed")
					end
				end
				if depth==0 then GENV.DEX_LAST_PARSE_ERROR=parsed and nil or parseerr end
				if depth==0 and not exprMode then return bodytext end
				if bodytext=="" then return "function("..table.concat(args,", ")..") end" end
				return "function("..table.concat(args,", ")..")\n"..bodytext.."\n"..ind.."end"
			end
			local function validLuauBytecode(bc)
				if type(bc)~="string" or #bc<2 then return false end
				local v=string.byte(bc,1)
				return (v and v>=3 and v<=14) or v==100
			end
			local function scriptRunContext(scr)
				local ok,rc=pcall(function() return scr.RunContext end)
				return ok and rc or nil
			end
			local function serverOnlyScript(scr)
				if not scr or not scr.IsA or not scr:IsA("Script") then return false end
				local rc=scriptRunContext(scr)
				return rc~=Enum.RunContext.Client
			end
			local function unavailableSource(scr,details)
				local rc=scriptRunContext(scr)
				local rcname=rc and tostring(rc) or "unknown"
				local name="unknown"
				pcall(function() name=scr:GetFullName() end)
				local out={
					"-- ["..DECOMPILER_VERSION.."] bytecode unavailable",
					"-- Script: "..tostring(name),
					"-- Class: "..tostring(scr and scr.ClassName or "unknown"),
					"-- RunContext: "..rcname,
					"-- This server-side Script has no client-visible Luau bytecode.",
					"-- The decompiler can only reconstruct bytecode that the client/executor can actually retrieve."
				}
				if details and details~="" then out[#out+1]="-- Acquisition: "..details end
				return table.concat(out,"\n")
			end
			local function acquireBytecode(scr)
				local notes={}
				if type(getbc)=="function" then
					local ok,bc=pcall(getbc,scr)
					if ok and validLuauBytecode(bc) then return bc,"getscriptbytecode" end
					if ok then
						if type(bc)=="string" then notes[#notes+1]="getscriptbytecode returned "..tostring(#bc).." bytes" else notes[#notes+1]="getscriptbytecode returned "..type(bc) end
					else
						notes[#notes+1]="getscriptbytecode failed: "..tostring(bc)
					end
				end
				local getcl=env.getscriptclosure
				local dumpcl=env.dumpclosurebytecode
				if type(getcl)=="function" and type(dumpcl)=="function" then
					local okc,cl=pcall(getcl,scr)
					if okc and type(cl)=="function" then
						local okd,dbc=pcall(dumpcl,cl)
						if okd and validLuauBytecode(dbc) then return dbc,"script closure dump" end
						if okd then notes[#notes+1]="closure dump returned non-Luau data" else notes[#notes+1]="closure dump failed: "..tostring(dbc) end
					elseif okc then
						notes[#notes+1]="script closure unavailable"
					else
						notes[#notes+1]="script closure failed: "..tostring(cl)
					end
				end
				return nil,table.concat(notes,"; ")
			end
			return function(scr)
				local bc,how=acquireBytecode(scr)
				if not bc then
					if serverOnlyScript(scr) then return unavailableSource(scr,how) end
					error("["..DECOMPILER_VERSION.."] bytecode acquisition failed: "..tostring(how),0)
				end
				local okMod,mod=pcall(deserialize,bc)
				if not okMod then error("["..DECOMPILER_VERSION.."] deserialize ("..tostring(how).."): "..tostring(mod),0) end
				local p=mod.protos[mod.main]
				if not p then error("["..DECOMPILER_VERSION.."] main proto missing",0) end
				local okSource,source=pcall(customsource,mod,p,0,{})
				if not okSource then error("["..DECOMPILER_VERSION.."] reconstruct: "..tostring(source),0) end
				return source
			end
		end
		env.decompile = (env.getscriptbytecode or (env.getscriptclosure and env.dumpclosurebytecode)) and makeBytecodeDecompiler(env.getscriptbytecode) or nil
		pcall(function()
			GENV.DEX_CUSTOM_DECOMPILER_VERSION=DECOMPILER_VERSION
			if GENV.DEX_PRETTY_DATAFLOW==nil then GENV.DEX_PRETTY_DATAFLOW=true end
			if GENV.DEX_PRETTY_SEMANTIC_LOCALS==nil then GENV.DEX_PRETTY_SEMANTIC_LOCALS=true end
			if GENV.DEX_PRETTY_FOLD_CLOSURES==nil then GENV.DEX_PRETTY_FOLD_CLOSURES=true end
			if GENV.DEX_SSA_SAFE_PRETTY==nil then GENV.DEX_SSA_SAFE_PRETTY=true end
			if GENV.DEX_DEF_SENSITIVE_RECOVERY==nil then GENV.DEX_DEF_SENSITIVE_RECOVERY=true end
			if GENV.DEX_STRICT_LVALUE_VALIDATION==nil then GENV.DEX_STRICT_LVALUE_VALIDATION=true end
			GENV.DEX_DECOMPILE=env.decompile
			GENV.DEX_GET_BYTECODE=env.getscriptbytecode
			GENV.DEX_GET_SCRIPT_CLOSURE=env.getscriptclosure
		end)
		env.isViableDecompileScript = function(obj)
			if obj:IsA("ModuleScript") then
				return true
			elseif obj:IsA("LocalScript") and (obj.RunContext == Enum.RunContext.Client or obj.RunContext == Enum.RunContext.Legacy) then
				return true
			elseif obj:IsA("Script") and obj.RunContext == Enum.RunContext.Client then
				return true
			end
			return false
		end
		env.protectgui = missing("function", protect_gui or (syn and syn.protect_gui))
		env.gethui = missing("function", gethui or get_hidden_gui)
		env.setclipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
		env.getnilinstances = missing("function", getnilinstances or get_nil_instances)
		env.getloadedmodules = missing("function", getloadedmodules)

		env.executor = (function()
			local identifyexec = identifyexecutor or getexecutorname or whatexecutor
			local success, name = pcall(function()
				return tostring(identifyexec())
			end)
			return success and name or "Your executor"
		end)()

		Main.GuiHolder = Main.Elevated and service.CoreGui or plr:FindFirstChildWhichIsA("PlayerGui")

		setmetatable(env, nil)
	end

	Main.LoadSettings = function()
		local s,data = pcall(env.readfile or error,"DexSettings.json")
		if s and data and data ~= "" then
			local s,decoded = service.HttpService:JSONDecode(data)
			if s and decoded then
				for i,v in next,decoded do

				end
			else
				
			end
		else
			Main.ResetSettings()
		end
	end

	Main.ResetSettings = function()
		local function recur(t,res)
			for set,val in pairs(t) do
				if type(val) == "table" and val._Recurse then
					if type(res[set]) ~= "table" then
						res[set] = {}
					end
					recur(val,res[set])
				else
					res[set] = val
				end
			end
			return res
		end
		recur(DefaultSettings,Settings)
	end

	local function jsonDecode(str)
		local suc, res = pcall(service.HttpService.JSONDecode, service.HttpService, str)
		return suc and res or suc
	end

	Main.FetchAPI = function()
		local api,rawAPI
		if Main.Elevated then
			if Main.LocalDepsUpToDate() then
				local localAPI = Lib.ReadFile("dex/rbx_api.dat")
				if localAPI then 
					rawAPI = localAPI
				else
					Main.DepsVersionData[1] = ""
				end
			end
			rawAPI = rawAPI or oldgame:HttpGet("http://setup.roblox.com/"..Main.RobloxVersion.."-API-Dump.json")
		else
			if script:FindFirstChild("API") then
				rawAPI = require(script.API)
			else
				error("NO API EXISTS")
			end
		end
		Main.RawAPI = rawAPI
		api = jsonDecode(rawAPI)

		
		if not api then
			rawAPI = oldgame:HttpGet(dexCacheBust("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/rbx_api.dat"), false)
			Main.RawAPI = rawAPI
			api = jsonDecode(rawAPI)
		end

		local classes,enums = {},{}
		local categoryOrder,seenCategories = {},{}

		local function insertAbove(t,item,aboveItem)
			local findPos = table.find(t,item)
			if not findPos then return end
			table.remove(t,findPos)

			local pos = table.find(t,aboveItem)
			if not pos then return end
			table.insert(t,pos,item)
		end

		for _,class in pairs(api.Classes) do
			local newClass = {}
			newClass.Name = class.Name
			newClass.Superclass = class.Superclass
			newClass.Properties = {}
			newClass.Functions = {}
			newClass.Events = {}
			newClass.Callbacks = {}
			newClass.Tags = {}

			if class.Tags then for c,tag in pairs(class.Tags) do newClass.Tags[tag] = true end end
			for __,member in pairs(class.Members) do
				local newMember = {}
				newMember.Name = member.Name
				newMember.Class = class.Name
				newMember.Security = member.Security
				newMember.Tags ={}
				if member.Tags then for c,tag in pairs(member.Tags) do newMember.Tags[tag] = true end end

				local mType = member.MemberType
				if mType == "Property" then
					local propCategory = member.Category or "Other"
					propCategory = propCategory:match("^%s*(.-)%s*$")
					if not seenCategories[propCategory] then
						categoryOrder[#categoryOrder+1] = propCategory
						seenCategories[propCategory] = true
					end
					newMember.ValueType = member.ValueType
					newMember.Category = propCategory
					newMember.Serialization = member.Serialization
					table.insert(newClass.Properties,newMember)
				elseif mType == "Function" then
					newMember.Parameters = {}
					newMember.ReturnType = member.ReturnType.Name
					for c,param in pairs(member.Parameters) do
						table.insert(newMember.Parameters,{Name = param.Name, Type = param.Type.Name})
					end
					table.insert(newClass.Functions,newMember)
				elseif mType == "Event" then
					newMember.Parameters = {}
					for c,param in pairs(member.Parameters) do
						table.insert(newMember.Parameters,{Name = param.Name, Type = param.Type.Name})
					end
					table.insert(newClass.Events,newMember)
				end
			end

			classes[class.Name] = newClass
		end

		for _,class in pairs(classes) do
			class.Superclass = classes[class.Superclass]
		end

		for _,enum in pairs(api.Enums) do
			local newEnum = {}
			newEnum.Name = enum.Name
			newEnum.Items = {}
			newEnum.Tags = {}

			if enum.Tags then for c,tag in pairs(enum.Tags) do newEnum.Tags[tag] = true end end
			for __,item in pairs(enum.Items) do
				local newItem = {}
				newItem.Name = item.Name
				newItem.Value = item.Value
				table.insert(newEnum.Items,newItem)
			end

			enums[enum.Name] = newEnum
		end

		local function getMember(class,member)
			if not classes[class] or not classes[class][member] then return end
			local result = {}

			local currentClass = classes[class]
			while currentClass do
				for _,entry in pairs(currentClass[member]) do
					result[#result+1] = entry
				end
				currentClass = currentClass.Superclass
			end

			table.sort(result,function(a,b) return a.Name < b.Name end)
			return result
		end

		insertAbove(categoryOrder,"Behavior","Tuning")
		insertAbove(categoryOrder,"Appearance","Data")
		insertAbove(categoryOrder,"Attachments","Axes")
		insertAbove(categoryOrder,"Cylinder","Slider")
		insertAbove(categoryOrder,"Localization","Jump Settings")
		insertAbove(categoryOrder,"Surface","Motion")
		insertAbove(categoryOrder,"Surface Inputs","Surface")
		insertAbove(categoryOrder,"Part","Surface Inputs")
		insertAbove(categoryOrder,"Assembly","Surface Inputs")
		insertAbove(categoryOrder,"Character","Controls")
		categoryOrder[#categoryOrder+1] = "Unscriptable"
		categoryOrder[#categoryOrder+1] = "Attributes"

		local categoryOrderMap = {}
		for i = 1,#categoryOrder do
			categoryOrderMap[categoryOrder[i]] = i
		end

		return {
			Classes = classes,
			Enums = enums,
			CategoryOrder = categoryOrderMap,
			GetMember = getMember
		}
	end

	Main.FetchRMD = function()
		local rawXML
		if Main.Elevated then
			if Main.LocalDepsUpToDate() then
				local localRMD = Lib.ReadFile("dex/rbx_rmd.dat")
				if localRMD then 
					rawXML = localRMD
				else
					Main.DepsVersionData[1] = ""
				end
			end
			rawXML = rawXML or oldgame:HttpGet(dexCacheBust("https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml"), false)
		else
			if script:FindFirstChild("RMD") then
				rawXML = require(script.RMD)
			else
				error("NO RMD EXISTS")
			end
		end
		Main.RawRMD = rawXML
		local parsed = Lib.ParseXML(rawXML)
		local classList = parsed.children[1].children[1].children
		local enumList = parsed.children[1].children[2].children
		local propertyOrders = {}

		local classes,enums = {},{}
		for _,class in pairs(classList) do
			local className = ""
			for _,child in pairs(class.children) do
				if child.tag == "Properties" then
					local data = {Properties = {}, Functions = {}}
					local props = child.children
					for _,prop in pairs(props) do
						local name = prop.attrs.name
						name = name:sub(1,1):upper()..name:sub(2)
						data[name] = prop.children[1].text
					end
					className = data.Name
					classes[className] = data
				elseif child.attrs.class == "ReflectionMetadataProperties" then
					local members = child.children
					for _,member in pairs(members) do
						if member.attrs.class == "ReflectionMetadataMember" then
							local data = {}
							if member.children[1].tag == "Properties" then
								local props = member.children[1].children
								for _,prop in pairs(props) do
									if prop.attrs then
										local name = prop.attrs.name
										name = name:sub(1,1):upper()..name:sub(2)
										data[name] = prop.children[1].text
									end
								end
								if data.PropertyOrder then
									local orders = propertyOrders[className]
									if not orders then orders = {} propertyOrders[className] = orders end
									orders[data.Name] = tonumber(data.PropertyOrder)
								end
								classes[className].Properties[data.Name] = data
							end
						end
					end
				elseif child.attrs.class == "ReflectionMetadataFunctions" then
					local members = child.children
					for _,member in pairs(members) do
						if member.attrs.class == "ReflectionMetadataMember" then
							local data = {}
							if member.children[1].tag == "Properties" then
								local props = member.children[1].children
								for _,prop in pairs(props) do
									if prop.attrs then
										local name = prop.attrs.name
										name = name:sub(1,1):upper()..name:sub(2)
										data[name] = prop.children[1].text
									end
								end
								classes[className].Functions[data.Name] = data
							end
						end
					end
				end
			end
		end

		for _,enum in pairs(enumList) do
			local enumName = ""
			for _,child in pairs(enum.children) do
				if child.tag == "Properties" then
					local data = {Items = {}}
					local props = child.children
					for _,prop in pairs(props) do
						local name = prop.attrs.name
						name = name:sub(1,1):upper()..name:sub(2)
						data[name] = prop.children[1].text
					end
					enumName = data.Name
					enums[enumName] = data
				elseif child.attrs.class == "ReflectionMetadataEnumItem" then
					local data = {}
					if child.children[1].tag == "Properties" then
						local props = child.children[1].children
						for _,prop in pairs(props) do
							local name = prop.attrs.name
							name = name:sub(1,1):upper()..name:sub(2)
							data[name] = prop.children[1].text
						end
						enums[enumName].Items[data.Name] = data
					end
				end
			end
		end

		return {Classes = classes, Enums = enums, PropertyOrders = propertyOrders}
	end

	Main.ShowGui = function(gui)
		if env.gethui then
			gui.Parent = env.gethui()
		elseif env.protectgui then
			env.protectgui(gui)
			gui.Parent = Main.GuiHolder
		else
			gui.Parent = Main.GuiHolder
		end
	end

	Main.CreateIntro = function(initStatus) 
		local gui = create({
			{1,"ScreenGui",{Name="Intro",}},
			{2,"Frame",{Active=true,BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="Main",Parent={1},Position=UDim2.new(0.5,-175,0.5,-100),Size=UDim2.new(0,350,0,200),}},
			{3,"Frame",{BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,ClipsDescendants=true,Name="Holder",Parent={2},Size=UDim2.new(1,0,1,0),}},
			{4,"UIGradient",{Parent={3},Rotation=30,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(1,1,0),}),}},
			{5,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Title",Parent={3},Position=UDim2.new(0,-190,0,15),Size=UDim2.new(0,100,0,50),Text="Dex",TextColor3=Color3.new(1,1,1),TextSize=50,TextTransparency=1,}},
			{6,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Desc",Parent={3},Position=UDim2.new(0,-230,0,60),Size=UDim2.new(0,180,0,25),Text="Ultimate Debugging Suite",TextColor3=Color3.new(1,1,1),TextSize=18,TextTransparency=1,}},
			{7,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="StatusText",Parent={3},Position=UDim2.new(0,20,0,110),Size=UDim2.new(0,180,0,25),Text="Fetching API",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=1,}},
			{8,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="ProgressBar",Parent={3},Position=UDim2.new(0,110,0,145),Size=UDim2.new(0,0,0,4),}},
			{9,"Frame",{BackgroundColor3=Color3.new(0.2392156869173,0.56078433990479,0.86274510622025),BorderSizePixel=0,Name="Bar",Parent={8},Size=UDim2.new(0,0,1,0),}},
			{10,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://2764171053",ImageColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),Parent={8},ScaleType=1,Size=UDim2.new(1,0,1,0),SliceCenter=Rect.new(2,2,254,254),}},
			{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Creator",Parent={2},Position=UDim2.new(1,-110,1,-20),Size=UDim2.new(0,105,0,20),Text="Developed by Moon",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=1,}},
			{12,"UIGradient",{Parent={11},Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(1,1,0),}),}},
			{13,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Version",Parent={2},Position=UDim2.new(1,-110,1,-35),Size=UDim2.new(0,105,0,20),Text=Main.Version,TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=1,}},
			{14,"UIGradient",{Parent={13},Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(1,1,0),}),}},
			{15,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Image="rbxassetid://1427967925",Name="Outlines",Parent={2},Position=UDim2.new(0,-5,0,-5),ScaleType=1,Size=UDim2.new(1,10,1,10),SliceCenter=Rect.new(6,6,25,25),TileSize=UDim2.new(0,20,0,20),}},
			{16,"UIGradient",{Parent={15},Rotation=-30,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(1,1,0),}),}},
			{17,"UIGradient",{Parent={2},Rotation=-30,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(1,1,0),}),}},
		})
		Main.ShowGui(gui)
		local backGradient = gui.Main.UIGradient
		local outlinesGradient = gui.Main.Outlines.UIGradient
		local holderGradient = gui.Main.Holder.UIGradient
		local titleText = gui.Main.Holder.Title
		local descText = gui.Main.Holder.Desc
		local versionText = gui.Main.Version
		local versionGradient = versionText.UIGradient
		local creatorText = gui.Main.Creator
		local creatorGradient = creatorText.UIGradient
		local statusText = gui.Main.Holder.StatusText
		local progressBar = gui.Main.Holder.ProgressBar
		local tweenS = service.TweenService

		local renderStepped = service.RunService.RenderStepped
		local signalWait = renderStepped.wait
		local fastwait = function(s)
			if not s then return signalWait(renderStepped) end
			local start = tick()
			while tick() - start < s do signalWait(renderStepped) end
		end

		statusText.Text = initStatus

		local function tweenNumber(n,ti,func)
			local tweenVal = Instance.new("IntValue")
			tweenVal.Value = 0
			tweenVal.Changed:Connect(func)
			local tween = tweenS:Create(tweenVal,ti,{Value = n})
			tween:Play()
			tween.Completed:Connect(function()
				tweenVal:Destroy()
			end)
		end

		local ti = TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
		tweenNumber(100,ti,function(val)
			val = val/200
			local start = NumberSequenceKeypoint.new(0,0)
			local a1 = NumberSequenceKeypoint.new(val,0)
			local a2 = NumberSequenceKeypoint.new(math.min(0.5,val+math.min(0.05,val)),1)
			if a1.Time == a2.Time then a2 = a1 end
			local b1 = NumberSequenceKeypoint.new(1-val,0)
			local b2 = NumberSequenceKeypoint.new(math.max(0.5,1-val-math.min(0.05,val)),1)
			if b1.Time == b2.Time then b2 = b1 end
			local goal = NumberSequenceKeypoint.new(1,0)
			backGradient.Transparency = NumberSequence.new({start,a1,a2,b2,b1,goal})
			outlinesGradient.Transparency = NumberSequence.new({start,a1,a2,b2,b1,goal})
		end)

		fastwait(0.4)

		tweenNumber(100,ti,function(val)
			val = val/166.66
			local start = NumberSequenceKeypoint.new(0,0)
			local a1 = NumberSequenceKeypoint.new(val,0)
			local a2 = NumberSequenceKeypoint.new(val+0.01,1)
			local goal = NumberSequenceKeypoint.new(1,1)
			holderGradient.Transparency = NumberSequence.new({start,a1,a2,goal})
		end)

		tweenS:Create(titleText,ti,{Position = UDim2.new(0,60,0,15), TextTransparency = 0}):Play()
		tweenS:Create(descText,ti,{Position = UDim2.new(0,20,0,60), TextTransparency = 0}):Play()

		local function rightTextTransparency(obj)
			tweenNumber(100,ti,function(val)
				val = val/100
				local a1 = NumberSequenceKeypoint.new(1-val,0)
				local a2 = NumberSequenceKeypoint.new(math.max(0,1-val-0.01),1)
				if a1.Time == a2.Time then a2 = a1 end
				local start = NumberSequenceKeypoint.new(0,a1 == a2 and 0 or 1)
				local goal = NumberSequenceKeypoint.new(1,0)
				obj.Transparency = NumberSequence.new({start,a2,a1,goal})
			end)
		end
		rightTextTransparency(versionGradient)
		rightTextTransparency(creatorGradient)

		fastwait(0.9)

		local progressTI = TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)

		tweenS:Create(statusText,progressTI,{Position = UDim2.new(0,20,0,120), TextTransparency = 0}):Play()
		tweenS:Create(progressBar,progressTI,{Position = UDim2.new(0,60,0,145), Size = UDim2.new(0,100,0,4)}):Play()

		fastwait(0.25)

		local function setProgress(text,n)
			statusText.Text = text
			tweenS:Create(progressBar.Bar,progressTI,{Size = UDim2.new(n,0,1,0)}):Play()
		end

		local function close()
			tweenS:Create(titleText,progressTI,{TextTransparency = 1}):Play()
			tweenS:Create(descText,progressTI,{TextTransparency = 1}):Play()
			tweenS:Create(versionText,progressTI,{TextTransparency = 1}):Play()
			tweenS:Create(creatorText,progressTI,{TextTransparency = 1}):Play()
			tweenS:Create(statusText,progressTI,{TextTransparency = 1}):Play()
			tweenS:Create(progressBar,progressTI,{BackgroundTransparency = 1}):Play()
			tweenS:Create(progressBar.Bar,progressTI,{BackgroundTransparency = 1}):Play()
			tweenS:Create(progressBar.ImageLabel,progressTI,{ImageTransparency = 1}):Play()

			tweenNumber(100,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.In),function(val)
				val = val/250
				local start = NumberSequenceKeypoint.new(0,0)
				local a1 = NumberSequenceKeypoint.new(0.6+val,0)
				local a2 = NumberSequenceKeypoint.new(math.min(1,0.601+val),1)
				if a1.Time == a2.Time then a2 = a1 end
				local goal = NumberSequenceKeypoint.new(1,a1 == a2 and 0 or 1)
				holderGradient.Transparency = NumberSequence.new({start,a1,a2,goal})
			end)

			fastwait(0.5)
			gui.Main.BackgroundTransparency = 1
			outlinesGradient.Rotation = 30

			tweenNumber(100,ti,function(val)
				val = val/100
				local start = NumberSequenceKeypoint.new(0,1)
				local a1 = NumberSequenceKeypoint.new(val,1)
				local a2 = NumberSequenceKeypoint.new(math.min(1,val+math.min(0.05,val)),0)
				if a1.Time == a2.Time then a2 = a1 end
				local goal = NumberSequenceKeypoint.new(1,a1 == a2 and 1 or 0)
				outlinesGradient.Transparency = NumberSequence.new({start,a1,a2,goal})
				holderGradient.Transparency = NumberSequence.new({start,a1,a2,goal})
			end)

			fastwait(0.45)
			gui:Destroy()
		end

		return {SetProgress = setProgress, Close = close}
	end

	Main.CreateApp = function(data)
		if Main.MenuApps[data.Name] then return end 
		local control = {}

		local app = Main.AppTemplate:Clone()

		local iconIndex = data.Icon
		if data.IconMap and iconIndex then
			if type(iconIndex) == "number" then
				data.IconMap:Display(app.Main.Icon,iconIndex)
			elseif type(iconIndex) == "string" then
				data.IconMap:DisplayByKey(app.Main.Icon,iconIndex)
			end
		elseif type(iconIndex) == "string" then
			app.Main.Icon.Image = iconIndex
		else
			app.Main.Icon.Image = ""
		end

		local function updateState()
			app.Main.BackgroundTransparency = data.Open and 0 or (Lib.CheckMouseInGui(app.Main) and 0 or 1)
			app.Main.Highlight.Visible = data.Open
		end

		local function enable(silent)
			if data.Open then return end
			data.Open = true
			updateState()
			if not silent then
				if data.Window then data.Window:Show() end
				if data.OnClick then data.OnClick(data.Open) end
			end
		end

		local function disable(silent)
			if not data.Open then return end
			data.Open = false
			updateState()
			if not silent then
				if data.Window then data.Window:Hide() end
				if data.OnClick then data.OnClick(data.Open) end
			end
		end

		updateState()

		local ySize = service.TextService:GetTextSize(data.Name,14,Enum.Font.SourceSans,Vector2.new(62,999999)).Y
		app.Main.Size = UDim2.new(1,0,0,math.clamp(46+ySize,60,74))
		app.Main.AppName.Text = data.Name

		app.Main.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				app.Main.BackgroundTransparency = 0
				app.Main.BackgroundColor3 = Settings.Theme.ButtonHover
			end
		end)

		app.Main.InputEnded:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				app.Main.BackgroundTransparency = data.Open and 0 or 1
				app.Main.BackgroundColor3 = Settings.Theme.Button
			end
		end)

		app.Main.MouseButton1Click:Connect(function()
			if data.Open then disable() else enable() end
		end)

		local window = data.Window
		if window then
			window.OnActivate:Connect(function() enable(true) end)
			window.OnDeactivate:Connect(function() disable(true) end)
		end

		app.Visible = true
		app.Parent = Main.AppsContainer
		Main.AppsFrame.CanvasSize = UDim2.new(0,0,0,Main.AppsContainerGrid.AbsoluteCellCount.Y*82 + 8)

		control.Enable = enable
		control.Disable = disable
		Main.MenuApps[data.Name] = control
		return control
	end

	Main.SetMainGuiOpen = function(val)
		Main.MainGuiOpen = val

		Main.MainGui.OpenButton.Text = val and "X" or "Dex"
		if val then Main.MainGui.OpenButton.MainFrame.Visible = true end
		Main.MainGui.OpenButton.MainFrame:TweenSize(val and UDim2.new(0,224,0,200) or UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true)
		
		service.TweenService:Create(Main.MainGui.OpenButton,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency = val and 0 or (Lib.CheckMouseInGui(Main.MainGui.OpenButton) and 0 or 0.2)}):Play()

		if Main.MainGuiMouseEvent then Main.MainGuiMouseEvent:Disconnect() end

		if not val then
			local startTime = tick()
			Main.MainGuiCloseTime = startTime
			coroutine.wrap(function()
				Lib.FastWait(0.2)
				if not Main.MainGuiOpen and startTime == Main.MainGuiCloseTime then Main.MainGui.OpenButton.MainFrame.Visible = false end
			end)()
		else
			Main.MainGuiMouseEvent = service.UserInputService.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not Lib.CheckMouseInGui(Main.MainGui.OpenButton) and not Lib.CheckMouseInGui(Main.MainGui.OpenButton.MainFrame) then

					Main.SetMainGuiOpen(false)
				end
			end)
		end
	end

	Main.CreateMainGui = function()
		local gui = create({
			{1,"ScreenGui",{IgnoreGuiInset=true,Name="MainMenu",}},
			{2,"TextButton",{AnchorPoint=Vector2.new(0.5,0),AutoButtonColor=false,BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),BorderSizePixel=0,Font=4,Name="OpenButton",Parent={1},Position=UDim2.new(0.5,0,0,2),Size=UDim2.new(0,32,0,32),Text="Dex",TextColor3=Color3.new(1,1,1),TextSize=16,TextTransparency=0.20000000298023,}},
			{3,"UICorner",{CornerRadius=UDim.new(0,4),Parent={2},}},
			{4,"Frame",{AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=Color3.new(0.17647059261799,0.17647059261799,0.17647059261799),ClipsDescendants=true,Name="MainFrame",Parent={2},Position=UDim2.new(0.5,0,1,-4),Size=UDim2.new(0,224,0,200),}},
			{5,"UICorner",{CornerRadius=UDim.new(0,4),Parent={4},}},
			{6,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),Name="BottomFrame",Parent={4},Position=UDim2.new(0,0,1,-24),Size=UDim2.new(1,0,0,24),}},
			{7,"UICorner",{CornerRadius=UDim.new(0,4),Parent={6},}},
			{8,"Frame",{BackgroundColor3=Color3.new(0.20392157137394,0.20392157137394,0.20392157137394),BorderSizePixel=0,Name="CoverFrame",Parent={6},Size=UDim2.new(1,0,0,4),}},
			{9,"Frame",{BackgroundColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),BorderSizePixel=0,Name="Line",Parent={8},Position=UDim2.new(0,0,0,-1),Size=UDim2.new(1,0,0,1),}},
			{10,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Settings",Parent={6},Position=UDim2.new(1,-48,0,0),Size=UDim2.new(0,24,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
			{11,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6578871732",ImageTransparency=0.20000000298023,Name="Icon",Parent={10},Position=UDim2.new(0,4,0,4),Size=UDim2.new(0,16,0,16),}},
			{12,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Information",Parent={6},Position=UDim2.new(1,-24,0,0),Size=UDim2.new(0,24,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,}},
			{13,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6578933307",ImageTransparency=0.20000000298023,Name="Icon",Parent={12},Position=UDim2.new(0,4,0,4),Size=UDim2.new(0,16,0,16),}},
			{14,"ScrollingFrame",{Active=true,AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderColor3=Color3.new(0.1294117718935,0.1294117718935,0.1294117718935),BorderSizePixel=0,Name="AppsFrame",Parent={4},Position=UDim2.new(0.5,0,0,0),ScrollBarImageColor3=Color3.new(0,0,0),ScrollBarThickness=4,Size=UDim2.new(0,222,1,-25),}},
			{15,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Container",Parent={14},Position=UDim2.new(0,7,0,8),Size=UDim2.new(1,-14,0,2),}},
			{16,"UIGridLayout",{CellSize=UDim2.new(0,66,0,74),Parent={15},SortOrder=2,}},
			{17,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="App",Parent={1},Size=UDim2.new(0,100,0,100),Visible=false,}},
			{18,"TextButton",{AutoButtonColor=false,BackgroundColor3=Color3.new(0.2352941185236,0.2352941185236,0.2352941185236),BorderSizePixel=0,Font=3,Name="Main",Parent={17},Size=UDim2.new(1,0,0,60),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,}},
			{19,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image="rbxassetid://6579106223",ImageRectSize=Vector2.new(32,32),Name="Icon",Parent={18},Position=UDim2.new(0.5,-16,0,4),ScaleType=4,Size=UDim2.new(0,32,0,32),}},
			{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="AppName",Parent={18},Position=UDim2.new(0,2,0,38),Size=UDim2.new(1,-4,1,-40),Text="Explorer",TextColor3=Color3.new(1,1,1),TextSize=14,TextTransparency=0.10000000149012,TextTruncate=1,TextWrapped=true,TextYAlignment=0,}},
			{21,"Frame",{BackgroundColor3=Color3.new(0,0.66666668653488,1),BorderSizePixel=0,Name="Highlight",Parent={18},Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),}},
		})
		Main.MainGui = gui
		Main.AppsFrame = gui.OpenButton.MainFrame.AppsFrame
		Main.AppsContainer = Main.AppsFrame.Container
		Main.AppsContainerGrid = Main.AppsContainer.UIGridLayout
		Main.AppTemplate = gui.App
		Main.MainGuiOpen = false

		local openButton = gui.OpenButton
		openButton.BackgroundTransparency = 0.2
		openButton.MainFrame.Size = UDim2.new(0,0,0,0)
		openButton.MainFrame.Visible = false
		openButton.MouseButton1Click:Connect(function()
			Main.SetMainGuiOpen(not Main.MainGuiOpen)
		end)

		openButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				service.TweenService:Create(Main.MainGui.OpenButton,TweenInfo.new(0,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency = 0}):Play()
			end
		end)

		openButton.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				service.TweenService:Create(Main.MainGui.OpenButton,TweenInfo.new(0,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency = Main.MainGuiOpen and 0 or 0.2}):Play()
			end
		end)

		
		Main.CreateApp({Name = "Explorer", IconMap = Main.LargeIcons, Icon = "Explorer", Open = true, Window = Explorer.Window})

		Main.CreateApp({Name = "Properties", IconMap = Main.LargeIcons, Icon = "Properties", Open = true, Window = Properties.Window})

		Main.CreateApp({Name = "Script Viewer", IconMap = Main.LargeIcons, Icon = "Script_Viewer", Window = ScriptViewer.Window})

		local cptsOnMouseClick = nil
		Main.CreateApp({Name = "Click part to select", IconMap = Main.LargeIcons, Icon = 6, OnClick = function(callback)
			if callback then
				local mouse = Main.Mouse
				cptsOnMouseClick = mouse.Button1Down:Connect(function()
					pcall(function()
						local object = mouse.Target
						if nodes[object] then
							selection:Set(nodes[object])
							Explorer.ViewNode(nodes[object])
						end
					end)
				end)
			else if cptsOnMouseClick ~= nil then cptsOnMouseClick:Disconnect() cptsOnMouseClick = nil end end
		end})

		Main.CreateApp({Name = "Console", IconMap = Main.LargeIcons, Icon = "Output", Window = Console.Window})

		Main.CreateApp({Name = "Save Instance", IconMap = Main.LargeIcons, Icon = "Watcher", Window = SaveInstance.Window})

		Lib.ShowGui(gui)
	end

	Main.SetupFilesystem = function()
		if not env.writefile or not env.makefolder then return end
		local writefile, makefolder = env.writefile, env.makefolder
		makefolder("dex")
		makefolder("dex/assets")
		makefolder("dex/saved")
		makefolder("dex/plugins")
		makefolder("dex/ModuleCache")
	end

	Main.LocalDepsUpToDate = function()
		return Main.DepsVersionData and Main.ClientVersion == Main.DepsVersionData[1]
	end

	Main.Init = function()
		Main.Elevated = pcall(function() local a = service.CoreGui:GetFullName() end)
		Main.InitEnv()
		Main.LoadSettings()
		Main.SetupFilesystem()

		
		local intro = Main.CreateIntro("Initializing Library")
		Lib = Main.LoadModule("Lib")
		Lib.FastWait()

		
		

		
		Main.MiscIcons = Lib.IconMap.new("http://www.roblox.com/asset/?id=6511490623",256,256,16,16) 

		Main.MiscIcons:SetDict({
			["Reference"] = 0;
			["Cut"] = 1;
			["Cut_Disabled"] = 2;
			["Copy"] = 3;
			["Copy_Disabled"] = 4;
			["Paste"] = 5;
			["Paste_Disabled"] = 6;
			["Delete"] = 7;
			["Delete_Disabled"] = 8;
			["Group"] = 9;
			["Group_Disabled"] = 10;
			["Ungroup"] = 11;
			["Ungroup_Disabled"] = 12;
			["TeleportTo"] = 13;
			["Rename"] = 14;
			["JumpToParent"] = 15;
			["ExploreData"] = 16;
			["Save"] = 17;
			["CallFunction"] = 18;
			["CallRemote"] = 19;
			["Undo"] = 20,
			["Undo_Disabled"] = 21;
			["Redo"] = 22;
			["Redo_Disabled"] = 23;
			["Expand_Over"] = 24;
			["Expand"] = 25;
			["Collapse_Over"] = 26;
			["Collapse"] = 27;
			["SelectChildren"] = 28;
			["SelectChildren_Disabled"] = 29;
			["InsertObject"] = 30;
			["ViewScript"] = 31;
			["AddStar"] = 32;
			["RemoveStar"] = 33;
			["Script_Disabled"] = 34;
			["LocalScript_Disabled"] = 35;
			["Play"] = 36;
			["Pause"] = 37;
			["Rename_Disabled"] = 38;
		})
		Main.LargeIcons = Lib.IconMap.new("rbxassetid://6579106223",256,256,32,32)
		Main.LargeIcons:SetDict({
			Explorer = 0, Properties = 1, Script_Viewer = 2, Watcher = 3, Output = 4
		})

		
		intro.SetProgress("Fetching Roblox Version",0.2)
		if Main.Elevated then
			local fileVer = Lib.ReadFile("dex/deps_version.dat")
			Main.ClientVersion = Version()

			if fileVer then
				Main.DepsVersionData = string.split(fileVer,"\n")
				if Main.LocalDepsUpToDate() then
					Main.RobloxVersion = Main.DepsVersionData[2]
				end
			end
			Main.RobloxVersion = Main.RobloxVersion or oldgame:HttpGet("http://setup.roblox.com/versionQTStudio")

			
			if #Main.RobloxVersion < 1 then
				Main.RobloxVersion = oldgame:HttpGet(dexCacheBust("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/deps_version.dat"), false):gsub("%s+", "")
			end
		end

		
		intro.SetProgress("Fetching API",0.35)
		API = Main.FetchAPI()
		Lib.FastWait()
		intro.SetProgress("Fetching RMD",0.5)
		RMD = Main.FetchRMD()
		Lib.FastWait()

		
		if Main.Elevated and env.writefile and not Main.LocalDepsUpToDate() then
			env.writefile("dex/deps_version.dat",Main.ClientVersion.."\n"..Main.RobloxVersion)
			env.writefile("dex/rbx_api.dat",Main.RawAPI)
			env.writefile("dex/rbx_rmd.dat",Main.RawRMD)
		end

		
		intro.SetProgress("Loading Modules",0.75)
		Main.AppControls.Lib.InitDeps(Main.GetInitDeps()) 
		Main.LoadModules()
		Lib.FastWait()

		
		intro.SetProgress("Initializing Modules",0.9)
		Explorer.Init()
		Properties.Init()
		ScriptViewer.Init()
		Console.Init()
		SaveInstance.Init()
		Lib.FastWait()

		
		intro.SetProgress("Complete",1)
		coroutine.wrap(function()
			Lib.FastWait(1.25)
			intro.Close()
		end)()

		
		Lib.Window.Init()
		Main.CreateMainGui()
		Explorer.Window:Show({Align = "right", Pos = 1, Size = 0.5, Silent = true})
		Properties.Window:Show({Align = "right", Pos = 2, Size = 0.5, Silent = true})
		Lib.DeferFunc(function() Lib.Window.ToggleSide("right") end)
	end

	return Main
end)()


Main.Init()
