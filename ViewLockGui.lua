-- Roblox ViewLock GUI System (Mobile Optimized)
-- モバイル対応版：タッチ操作、ドラッグ可能なGUI、自動リセット機能付き

local ViewLockGui = {}
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- 設定
local settings = {
    isViewLocked = false,
    guiVisible = true,
    offsetDistance = 0,
    autoReenableOnSpawn = true -- 死亡後に自動で再度有効化
}

-- ドラッグ状態
local dragState = {
    isDragging = false,
    dragStart = nil,
    frameStart = nil
}

-- GUI要素の作成
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ViewLockGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- メインフレーム
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 150)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true -- ドラッグ機能を有効化
    mainFrame.Parent = screenGui

    -- 角丸エフェクト
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame

    -- タイトルラベル（ドラッグバーとして機能）
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "ViewLock GUI"
    titleLabel.BorderSizePixel = 0
    titleLabel.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleLabel

    -- ステータス表示ラベル
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 50)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "Status: OFF"
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame

    -- トグルボタン
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 120, 0, 35)
    toggleButton.Position = UDim2.new(0.5, -60, 0, 85)
    toggleButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = "Toggle"
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = mainFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = toggleButton

    -- ボタンのホバー効果
    local originalColor = toggleButton.BackgroundColor3
    toggleButton.MouseEnter:Connect(function()
        toggleButton.BackgroundColor3 = Color3.fromRGB(120, 70, 170)
    end)

    toggleButton.MouseLeave:Connect(function()
        toggleButton.BackgroundColor3 = originalColor
    end)

    return screenGui, statusLabel, toggleButton
end

-- ビューロック機能
local function updateViewLock()
    if not settings.isViewLocked then return end

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = character.HumanoidRootPart
    
    -- カメラを体の位置に固定
    camera.CFrame = rootPart.CFrame * CFrame.new(0, 0, settings.offsetDistance)
end

-- ビューロック機能を切り替え
local function toggleViewLock()
    settings.isViewLocked = not settings.isViewLocked
    return settings.isViewLocked
end

-- GUI を初期化
local screenGui, statusLabel, toggleButton = createGui()

-- ボタンクリック時の処理
toggleButton.MouseButton1Click:Connect(function()
    local newState = toggleViewLock()
    statusLabel.Text = newState and "Status: ON ✓" or "Status: OFF ✗"
    statusLabel.TextColor3 = newState and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    toggleButton.BackgroundColor3 = newState and Color3.fromRGB(150, 100, 200) or Color3.fromRGB(100, 50, 150)
end)

-- フレーム更新（毎フレームビューロック更新）
RunService.RenderStepped:Connect(updateViewLock)

-- プレイヤーの視点が復帰する際の処理
player.CharacterAdded:Connect(function(character)
    -- autoReenableOnSpawn が有効の場合、自動で再度有効化
    if settings.autoReenableOnSpawn then
        wait(0.5) -- キャラクターが完全に読み込まれるまで待機
        settings.isViewLocked = true
        statusLabel.Text = "Status: ON ✓"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        toggleButton.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
    else
        settings.isViewLocked = false
        statusLabel.Text = "Status: OFF ✗"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        toggleButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    end
end)

ViewLockGui.toggleViewLock = toggleViewLock
ViewLockGui.settings = settings

return ViewLockGui
