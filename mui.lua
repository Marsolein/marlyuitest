local player = game.Players.LocalPlayer
local initList = {}
local Utility = {}
local globalArgs = {
	['Client'] = {},
	['Initialized'] = {},
	['Keybinds'] = {},
	['InstanceCache'] = {},
	['Settings'] = {
		font = "BuilderSans",
		colors = {
			primary = Color3.fromHex("#8000ff"),
			secondary = Color3.fromRGB(255,255,255),
			base = Color3.fromRGB(0,0,0),
			negative = Color3.fromRGB(255, 0, 0),
			positive = Color3.fromRGB(0,255,0),
		}
	},
	['States'] = {},
	['Garbage'] = {},
}
local templates = {
	textButton = {
		Size = UDim2.new(0.5,0,.1,0),
		BorderSizePixel = 3,
		TextScaled = true,
	}
}
function killMarly()
	
end
Utility['getCharacter'] = function() 
	if player.Character then
		return player.Character
	end
end
Utility['waitForCharacter'] = function()
	local character = Utility['getCharacter']()
	if character then
		return character
	else
		repeat task.wait()
			character = Utility['getCharacter']()
		until character
		return character
	end
end
Utility['createInstance'] = function(name:string,properties,childList)
	local newInstance
	if globalArgs["InstanceCache"][name] then
		newInstance = globalArgs["InstanceCache"][name]:Clone()
	else
		local success , fail = pcall(function()
			newInstance = Instance.new(name)
		end)
		if success then
			globalArgs["InstanceCache"][name] = newInstance:Clone()
		end
	end
	if properties then
		for i,v in pairs(properties) do
			local success, fail = pcall(function()
				newInstance[i] = newInstance[i]
			end)
			if success then
				newInstance[i] = v
			end
		end
	end
	if childList then
		for i,v in pairs(childList) do
			childList[i] = v
		end
	end
	return newInstance
end
Utility['getMatchFile'] = function()
	local character = Utility['waitForCharacter']()
	local characters = game.Workspace:WaitForChild('Characters')
	local matchFile
	for i,v in pairs(characters:GetChildren()) do
		if character:IsDescendantOf(v) then
			matchFile = v
		end
	end
	if matchFile then
		local alphaTeam = matchFile:WaitForChild('A')
		local bravoTeam = matchFile:WaitForChild('B')
		if character:IsDescendantOf(alphaTeam) then
			return alphaTeam , bravoTeam
		else
			return bravoTeam , alphaTeam
		end
	end
end
Utility['getTeammates'] = function()
	local teammates , opponents = Utility['getMatchFile']()
	if teammates then
		local character = Utility['waitForCharacter']
		local list = {}
		for i,v in pairs(teammates:GetChildren()) do
			if v ~= character then
				table.insert(list,v)
			end
		end
		return list
	end
end
Utility['getOpponents'] = function()
	local teammates , opponents = Utility['getMatchFile']()
	if opponents then
		local character = Utility['waitForCharacter']
		local list = {}
		for i,v in pairs(opponents:GetChildren()) do
			table.insert(list,v)
		end
		return list
	end
end
initList[1] = {
	['name'] = 'marlyBuild',
	['init'] = function(args)
		local uiContainer = Utility.createInstance('ScreenGui',{
			Parent = player.PlayerGui,
			Name = 'MarlyUI',
			ClipToDeviceSafeArea = false,
			ScreenInsets = Enum.ScreenInsets.None
		})
		local background = Utility.createInstance('Frame',{
			Parent = uiContainer,
			Name = 'background',
			Size = UDim2.new(.6,0,.6,0),
			Position = UDim2.new(.5,0,.5,0),
			AnchorPoint = Vector2.new(.5,.5),
			BorderSizePixel = 3,
			ClipsDescendants = true,
		})
		local backgroundAspectRatio = Utility.createInstance('UIAspectRatioConstraint',{
			Parent = background,
			AspectRatio = 0.875,
		})
		local titleContainer = Utility.createInstance('Frame',{
			Parent = background,
			Name = 'TitleContainer',
			Size = UDim2.new(1,0,.15,0),
			BorderSizePixel = 3,
		})
		local title = Utility.createInstance('TextBox',{
			Parent = titleContainer,
			Name = 'Title',
			Text = 'MarlyUI',
			Interactable = false,
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			TextScaled = true
		})
		local buttonContainer = Utility.createInstance('ScrollingFrame',{
			Parent = background,
			Name = 'ButtonContainer',
			Size = UDim2.new(1,0,.85,0),
			AnchorPoint = Vector2.new(0,1),
			Position = UDim2.new(0,0,1,0),
			BorderSizePixel = 3,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
			ScrollBarTransparency = 1,
		})
		local backgroundDrag = Utility.createInstance('UIDragDetector',{
			Parent = background
		})
		local buttonUILayout = Utility.createInstance('UIListLayout',{
			Parent = buttonContainer,
			FillDirection = Enum.FillDirection.Horizontal,
			Wraps = true,
		})
		return {
			container = uiContainer,
			background = background,
			buttonContainer = buttonContainer,
			titleContainer = titleContainer
		}
	end,
}
initList[2] = {
	['name'] = 'clairvoyance',
	['applyHighlight'] = function()
		local opponents = Utility['getOpponents']()
		if opponents then
			for i,v in pairs(opponents) do
				if v:FindFirstChild('esp') then
					return
				else
					local esp = Utility.createInstance('Highlight',{
						Parent = v,
						Name = 'esp',
						FillColor = globalArgs['Settings']['colors']['negative'],
					})
				end
			end
		end
	end,
	['clearHighlight'] = function()
		local opponents = Utility['getOpponents']()
		if opponents then
			for i,v in pairs(opponents) do
				if v:FindFirstChild('esp') then
					v:FindFirstChild('esp'):Destroy()
				end
			end
		end
	end,
	['init'] = function(args)
		local initialized = globalArgs['Initialized']
		local ui = initialized['marlyBuild']
		
		local button = Utility.createInstance('TextButton',templates['textButton'])
		button.Text = initList[2]["name"]
		button.Parent = ui['buttonContainer']
		
		globalArgs['States']['clairvoyance'] = false
		
		button.Activated:Connect(function()
			globalArgs['States']['clairvoyance'] = not globalArgs['States']['clairvoyance']
			if globalArgs['States']['clairvoyance'] then
				initList[2]['applyHighlight']()
			else
				initList[2]['clearHighlight']()
			end
		end)
	end,
}
initList[999] = {
	['name'] = 'settings',
	['updateColor'] = function()
		local initialized = globalArgs['Initialized']
		local Settings = globalArgs['Settings']
		local colors = Settings['colors']
		local ui = initialized['marlyBuild']
		
		ui['background'].BackgroundColor3 = colors['base']
		ui['background'].BorderColor3 = colors['primary']
		
		ui['titleContainer'].BackgroundColor3 = colors['base']
		ui['titleContainer'].BorderColor3 = colors['primary']
		
		ui['titleContainer']['Title'].TextColor3 = colors.secondary
		ui['titleContainer']['Title'].Font = Settings['font']
		
		ui['buttonContainer'].BackgroundColor3 = colors['base']
		ui['buttonContainer'].BorderColor3 = colors['primary']
	
		for i,v in pairs(ui['buttonContainer']:GetChildren()) do
			if v:IsA('TextButton') or v:IsA('ImageButton') then
				v.BackgroundColor3 = colors['base']
				v.BorderColor3 = colors['primary']
				if v:IsA('TextButton') then
					v.TextColor3 = colors.secondary
					v.Font = Settings['font']
				end
			end
		end
	end,
	['init'] = function(args)
		initList[999]['updateColor']()
	end,
}
for i,v in pairs(initList) do
	local name = i
	local success , fail = pcall(function()
		if initList[i]['name'] then
			name = initList[i]['name']
		end
		globalArgs['Client'][name] = initList[i]
		if initList[i]['init'] then
			globalArgs['Initialized'][name] = initList[i]['init'](globalArgs)
		end
	end)
	if success then
		print('Loaded:// '..name)
	else
		warn(name..' Failed // '..fail)
	end
end
print(globalArgs)
