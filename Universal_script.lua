-- FSOR Script
local SoundService = game:GetService("SoundService")
local launchSound = Instance.new("Sound")
launchSound.SoundId = "rbxassetid://133071738727579"
launchSound.Volume = 1
launchSound.Parent = SoundService
launchSound:Play()

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zxciaz/VenyxUI/main/Reuploaded"))()
local venyx = library.new("FSOR Universal Script", 5013109572)

-- themes
local themes = {
    Background = Color3.fromRGB(24, 24, 24),
    Glow = Color3.fromRGB(0, 0, 0),
    Accent = Color3.fromRGB(10, 10, 10),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),  
    TextColor = Color3.fromRGB(255, 255, 255)
}

---------------------------------------------------FIRST PAGE---------------------------------------------------
-- Section 1
local page1 = venyx:addPage("Aimbot", 5012544693)
local section1p1 = page1:addSection("Aimbot Settings")
local section2p1 = page1:addSection("Add Whitelist")
local section3p1 = page1:addSection("Remove Whitelist")

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- STATE
local scriptEnabled = false
local followMouse = false
local teamCheck = false
local aimForHead = true
local fov = 150
local thickness = 1.5
local aimColor = Color3.fromRGB(255, 128, 128)
local excludedPlayerNames = {}
local fsorIDs = {12345678, 87654321} -- Replace with actual FSOR user IDs
local trackFSORMembers = false
local whitelistEnabled = false
local showFOV = true -- controlled by the "Visible" toggle

-- DRAWING
local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = thickness
FOVring.Radius = fov
FOVring.Transparency = 1
FOVring.Color = aimColor
FOVring.Position = Camera.ViewportSize / 2

-- UI INTERACTIONS
section1p1:addToggle("Aimbot", false, function(v)
    scriptEnabled = v
    FOVring.Visible = v
end)

section1p1:addKeybind("Aimbot toggle Keybind", Enum.KeyCode.N, function()
    scriptEnabled = not scriptEnabled
    FOVring.Visible = scriptEnabled
end)

section1p1:addToggle("Follow mouse", false, function(v)
    followMouse = v
end)

section1p1:addToggle("Visible", true, function(v)
    showFOV = v
    FOVring.Visible = scriptEnabled and showFOV
end)

local function toggleScript()
    scriptEnabled = not scriptEnabled
    FOVring.Visible = scriptEnabled and showFOV
    print("Script enabled: " .. tostring(scriptEnabled))
end

section1p1:addSlider("Radius", 150, 0, 700, function(v)
    fov = v
    FOVring.Radius = fov
end)

section1p1:addSlider("Thickness", 1.5, 1, 10, function(v)
    thickness = v
    FOVring.Thickness = thickness
end)

section1p1:addColorPicker("ColorPicker", aimColor, function(v)
    aimColor = v
    FOVring.Color = aimColor
end)

section1p1:addDropdown("Aim parts", {"Head", "Body"}, function(v)
    aimForHead = v == "Head"
end)

-- WHITELISTING
local whitelist = {}

section2p1:addToggle("Team Check", false, function(v)
    teamCheck = v
end)

section2p1:addToggle("Enable Whitelist", false, function(v)
    whitelistEnabled = v
end)

-- Populate server players
local serverPlayers = {}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(serverPlayers, player.Name)
    end
end

section2p1:addDropdown("Choose who to whitelist", serverPlayers, function(name)
    if not table.find(whitelist, name) then
        table.insert(whitelist, name)
        print("Whitelisted:", name)
    end
end)

section2p1:addToggle("Whitelist all FSOR members in the server", false, function(v)
    trackFSORMembers = v
    if v then
        for _, player in ipairs(Players:GetPlayers()) do
            if table.find(fsorIDs, player.UserId) and not table.find(whitelist, player.Name) then
                table.insert(whitelist, player.Name)
                print("Auto-whitelisted FSOR:", player.Name)
            end
        end
    end
end)

-- Auto track FSOR members joining
Players.PlayerAdded:Connect(function(player)
    if trackFSORMembers and table.find(fsorIDs, player.UserId) then
        table.insert(whitelist, player.Name)
        print("Auto-whitelisted FSOR (join):", player.Name)
    end
end)

-- REMOVE FROM WHITELIST
section3p1:addDropdown("Choose who to remove from whitelist", whitelist, function(name)
    for i, v in ipairs(whitelist) do
        if v == name then
            table.remove(whitelist, i)
            print("Removed from whitelist:", name)
            break
        end
    end
end)

section3p1:addButton("Remove all from whitelist", function()
    table.clear(whitelist)
    print("Cleared whitelist")
end)

-- AIMBOT TARGETING
local function isExcluded(playerName)
    return table.find(whitelist, playerName)
end

local function getClosest(cframe)
    local ray = Ray.new(cframe.Position, cframe.LookVector).Unit
    local target = nil
    local mag = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("HumanoidRootPart") then
            if (not teamCheck or v.Team ~= LocalPlayer.Team) and (not whitelistEnabled or not isExcluded(v.Name)) then
                local part = aimForHead and v.Character.Head or v.Character.HumanoidRootPart
                local dist = (part.Position - ray:ClosestPoint(part.Position)).Magnitude
                if dist < mag then
                    mag = dist
                    target = v
                end
            end
        end
    end

    return target
end

-- UPDATE FOV RING
RunService.RenderStepped:Connect(function()
    if not scriptEnabled then return end
    if followMouse then
        local mouse = UserInputService:GetMouseLocation()
        FOVring.Position = Vector2.new(mouse.X, mouse.Y)
    else
        FOVring.Position = Camera.ViewportSize / 2
    end

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosest(Camera.CFrame)
        if target and target.Character then
            local part = aimForHead and target.Character.Head or target.Character.HumanoidRootPart
            local screenPos = Camera:WorldToScreenPoint(part.Position)
            local center = followMouse and UserInputService:GetMouseLocation() or Camera.ViewportSize / 2
            if (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude < fov then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), 0.2)
            end
        end
    end
end)

---------------------------------------------------SECOND PAGE---------------------------------------------------
-- Setup
local page2 = venyx:addPage("Silent aim", 5012544693)
local section1p2 = page2:addSection("Disable anticheats")
local section2p2 = page2:addSection("Silent aim settings")
local section3p2 = page2:addSection("Add whitelist")
local section4p2 = page2:addSection("Remove whitelist")

-- Section 1
section1p2:addButton("indexinstance detector detected", function()
    print("Disabled anticheats")
end)

-- Section 2
section2p2:addToggle("Silent aim", nil, function(value)
    print("Toggled", value)
end)
section2p2:addToggle("Visible", nil, function(value)
    print("Clicked", value)
end)
section2p2:addDropdown("Aim parts", {"Head", "Body"})
section2p2:addSlider("Radius", 150, 0, 700, function(value)
    print("Dragged", value)
end)
section2p2:addSlider("Thickness", 150, 0, 700, function(value)
    print("Dragged", value)
end)
section2p2:addColorPicker("ColorPicker", Color3.fromRGB(53, 56, 241))

-- Section 3
section3p2:addToggle("Team Check", nil, function(value)
    print("Toggled", value)
end)
section3p2:addToggle("Enable Whitelist", nil, function(value)
    print("Toggled", value)
end)
section3p2:addDropdown("Choose who to whitelist", {})
section3p2:addToggle("Whitelist all FSOR members in the server", function()
    print("Added to whitelist")
end)

-- Section 4
section4p2:addDropdown("Choose who to remove from whitelist", {})
section4p2:addButton("Remove all from whitelist", function()
    print("Removed from whitelist")
end)
---------------------------------------------------THIRD PAGE---------------------------------------------------
local page3 = venyx:addPage("Extra", 5012544693)
local section1p3 = page3:addSection("Anti Fly bypass")
local section2p3 = page3:addSection("Anti Walkspeed bypass")
local section3p3 = page3:addSection("Troll 🤪")
local section4p3 = page3:addSection("Other Universal Scripts")

section1p3:addButton("Anti Fly bypass", function()
    print("Bypassed fly")
end)
section1p3:addSlider("Fly speed", 100, 0, 1000, function(value)
    print("Dragged", value)
end)

-- Section 2
section2p3:addButton("Anti Walkspeed bypass", function()
    print("Bypassed walkspeed")
end)
section2p3:addSlider("Walkspeed", 2, 0, 200, function(value)
    print("Dragged", value)
end)

-- Section 3
section3p3:addToggle("Fling All", function()
    print("Flinging")
end)
section3p3:addToggle("Kill All", function()
    print("KIlling")
end)
section3p3:addButton("Gooning tool", function()
    print("Yes")
end)

-- Section 4
section4p3:addButton("Infinite Yield", function()
    print("Loaded FSOR script")
end)
section4p3:addButton("CMD-X", function()
    print("Loaded FSOR script 2")
end)
section4p3:addButton("Orca", function()
    print("Loaded FSOR script 3")
end)

---------------------------------------------------Settings---------------------------------------------------
local theme = venyx:addPage("Settings", 5012544693)
local colors = theme:addSection("Colors")

-- Table to track current theme colors
local currentThemeColors = {}

-- JSON encode/decode setup
local HttpService = game:GetService("HttpService")

local function encodeJSON(tbl)
    return HttpService:JSONEncode(tbl)
end

local function decodeJSON(str)
    return HttpService:JSONDecode(str)
end

-- FSOR folder and theme file setup
local fsorFolder = "FSOR"
local themeFileName = fsorFolder .. "/Theme.json"

-- Check and create FSOR folder if needed
if not isfolder then
    error("Your executor does not support isfolder function")
end

if not isfolder(fsorFolder) then
    makefolder(fsorFolder)
end

-- Initialize color pickers and track colors
for themeName, color in pairs(themes) do
    currentThemeColors[themeName] = color
    colors:addColorPicker(themeName, color, function(color3)
        venyx:setTheme(themeName, color3)
        currentThemeColors[themeName] = color3
    end)
end

-- Load saved theme if exists
if isfile(themeFileName) then
    local content = readfile(themeFileName)
    local success, data = pcall(function()
        return decodeJSON(content)
    end)
    if success and type(data) == "table" then
        for themeName, colorHex in pairs(data) do
            local color3 = Color3.fromHex(colorHex)
            venyx:setTheme(themeName, color3)
            currentThemeColors[themeName] = color3
        end
        venyx:Notify("Theme loaded!", "Loaded you're saved theme!")
    end
end

-- Add Save Theme button
colors:addButton("Save Theme", function()
    local themeToSave = {}
    for themeName, color3 in pairs(currentThemeColors) do
        local hex = string.format("#%02X%02X%02X", math.floor(color3.R * 255), math.floor(color3.G * 255), math.floor(color3.B * 255))
        themeToSave[themeName] = hex
    end

    local encoded = encodeJSON(themeToSave)
    writefile(themeFileName, encoded)
    venyx:Notify("Saved!", "Your theme has been saved!")
end)

-- load first page by default
venyx:SelectPage(venyx.pages[1], true)