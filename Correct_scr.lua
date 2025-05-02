local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- SETTINGS
local imageId = "rbxassetid://138101750778183"

-- GAME SCRIPTS LIST (for debugging, loadstrings are commented out)
local gameScripts = {
    [6989117155] = {name = "R6 Baseplate", loadstring = "print('Load Blox Fruits script')"},
    [1234567890] = {name = "Example Game", loadstring = "print('Load Example Game script')"},
    -- Add more game IDs and their loadstrings here
}

local currentGameId = game.PlaceId
local currentGameInfo = gameScripts[currentGameId]

if not currentGameInfo then
    print("No FSOR script available for this game. Closing script.")
    return
end

-- BLUR EFFECT
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- UI CONTAINER
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

-- MAIN FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 360)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- GLOWING BORDER
local uistroke = Instance.new("UIStroke")
uistroke.Thickness = 2
uistroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uistroke.Color = Color3.new(1, 1, 1)
uistroke.Transparency = 1
uistroke.Parent = frame

-- IMAGE
local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(0, 300, 0, 220)
imageLabel.Position = UDim2.new(0.5, 0, 0, 10)
imageLabel.AnchorPoint = Vector2.new(0.5, 0)
imageLabel.BackgroundTransparency = 1
imageLabel.Image = imageId
imageLabel.ImageTransparency = 1
imageLabel.Parent = frame

-- TEXT LABEL (dynamic text based on game)
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -40, 0, 60)
textLabel.Position = UDim2.new(0, 20, 0, 240)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.SourceSansBold
textLabel.TextTransparency = 1
textLabel.TextWrapped = true
textLabel.Text = "You have joined " .. currentGameInfo.name .. ", FSOR has a script for this game, would you like to load it?"
textLabel.Parent = frame

-- YES BUTTON
local yesButton = Instance.new("TextButton")
yesButton.Size = UDim2.new(0.3, 0, 0, 30)
yesButton.Position = UDim2.new(0.1, 0, 0, 300)
yesButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
yesButton.TextColor3 = Color3.new(1, 1, 1)
yesButton.Text = "Yes"
yesButton.TextScaled = true
yesButton.Font = Enum.Font.SourceSansBold
yesButton.BackgroundTransparency = 1
yesButton.TextTransparency = 1
yesButton.Parent = frame

-- NO BUTTON
local noButton = Instance.new("TextButton")
noButton.Size = UDim2.new(0.3, 0, 0, 30)
noButton.Position = UDim2.new(0.6, 0, 0, 300)
noButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
noButton.TextColor3 = Color3.new(1, 1, 1)
noButton.Text = "No"
noButton.TextScaled = true
noButton.Font = Enum.Font.SourceSansBold
noButton.BackgroundTransparency = 1
noButton.TextTransparency = 1
noButton.Parent = frame

local function fadeIn()
	local SoundService = game:GetService("SoundService")
	local launchSound = Instance.new("Sound")
	launchSound.SoundId = "rbxassetid://93127027451637"
	launchSound.Volume = 1
	launchSound.Parent = SoundService
	launchSound:Play()
	TweenService:Create(frame, TweenInfo.new(0.6), {BackgroundTransparency = 0}):Play()
	TweenService:Create(uistroke, TweenInfo.new(0.6), {Transparency = 0}):Play()
	TweenService:Create(imageLabel, TweenInfo.new(0.6), {ImageTransparency = 0}):Play()
	TweenService:Create(textLabel, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
	TweenService:Create(yesButton, TweenInfo.new(0.6), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
	TweenService:Create(noButton, TweenInfo.new(0.6), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
	TweenService:Create(blur, TweenInfo.new(0.6), {Size = 20}):Play()
end

local function fadeOut(callback)
	local tweens = {
		TweenService:Create(frame, TweenInfo.new(0.6), {BackgroundTransparency = 1}),
		TweenService:Create(uistroke, TweenInfo.new(0.6), {Transparency = 1}),
		TweenService:Create(imageLabel, TweenInfo.new(0.6), {ImageTransparency = 1}),
		TweenService:Create(textLabel, TweenInfo.new(0.6), {TextTransparency = 1}),
		TweenService:Create(yesButton, TweenInfo.new(0.6), {BackgroundTransparency = 1, TextTransparency = 1}),
		TweenService:Create(noButton, TweenInfo.new(0.6), {BackgroundTransparency = 1, TextTransparency = 1}),
		TweenService:Create(blur, TweenInfo.new(0.6), {Size = 0})
	}

	for _, tween in pairs(tweens) do
		tween:Play()
	end

	task.delay(0.6, function()
		if callback then callback() end
	end)
end

fadeIn()

yesButton.MouseButton1Click:Connect(function()
	fadeOut(function()
		screenGui:Destroy()
		blur:Destroy()
		print("Launching code")
		-- Run the loadstring associated with the current game ID
		local success, err = pcall(function()
			loadstring(currentGameInfo.loadstring)()
		end)
		if not success then
			warn("Failed to run game script: " .. tostring(err))
		end
	end)
end)

noButton.MouseButton1Click:Connect(function()
	fadeOut(function()
		screenGui:Destroy()
		blur:Destroy()
		print("Launching FSOR hub")
		loadstring(game:HttpGet("https://raw.githubusercontent.com/OdiRulez/FSOR-Stuff/refs/heads/main/Universal_script.lua"))()
	end)
end)
