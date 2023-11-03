ControllerMod = {}

-- @robinsch: check if DLL lua API is injected
function CheckDLL(self)
    return InteractNearest and SetCursorPosition;
end

S_DEBUG = false;

S_BUTTON = nil;

BINDING_HEADER_CONTROLLERMOD = "Controller Mod"
BINDING_NAME_START = "Start"
BINDING_NAME_INTERACT = "Interact"
BINDING_NAME_BACK = "Back"
BINDING_NAME_BUTTON_A = "Button A"
BINDING_NAME_BUTTON_B = "Button B"
BINDING_NAME_BUTTON_X = "Button X"
BINDING_NAME_BUTTON_Y = "Button Y"
BINDING_NAME_LEFT = "Left"
BINDING_NAME_RIGHT = "Right"
BINDING_NAME_UP = "Up"
BINDING_NAME_DOWN = "Down"

StaticPopupDialogs["POPUP_EXTENSIONS"] = {
    text = "Couldn\'t load |cffFF8800Extensions.dll|r.\n\nPlease visit |cffFF8800https://github.com/robinsch/ControllerMod335|r for more details.",
    button1 = "Exit Game",
    OnAccept = function()
        ForceQuit();
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function CloseMenus()
    CloseGossip();
    CloseQuest();
end

-- @robinsch: button helpers
function ClickButtonA()
    if UnitExists("target") and not UnitIsFriend("player", "target") then
        BT4Button1:Click();
        ActionButton1:Click();
    else
        InteractNearest();
    end
end

function ClickButtonB()
    if UnitExists("target") then
        ClearTarget();
    end
end

function ClickButtonX()
    BT4Button13:Click();
    ActionButton3:Click();
end

function ClickButtonY()
    BT4Button37:Click();
    ActionButton4:Click();
end

function ClickButtonLeft()
    if S_BUTTON == nil then
        if S_DEBUG then
            print("(ClickButtonLeft) nil");
        end
        return false
    elseif S_BUTTON:GetName() == "CharacterMicroButton" then
        ToggleCharacter("PaperDollFrame");
        return true
    end

    if S_DEBUG then
        print("(ClickButtonLeft) "..S_BUTTON:GetName());
    end

    S_BUTTON:Click("LeftButton");
    return true
end

function ClickButtonRight()
    if S_BUTTON == nil then
        return false
    end

    S_BUTTON:Click("RightButton");
    return true
end

function ClearButton()
    if S_BUTTON == nil then return end

    if S_DEBUG then
        print("(ClearButton) "..S_BUTTON:GetName());
    end

    S_BUTTON = nil;
    SetCursorPosition(0.5, 0.25);
end

function SetButton(button)
    if button == nil then return end

    if S_DEBUG then
        print("(SetButton) "..button:GetName());
    end

    MoveCursor(button)
    S_BUTTON = button
end

function SetButtonIndex(index)
    if S_BUTTON == nil then return end
    local buttonName = S_BUTTON:GetName();
    local buttonIndex
    for idx in string.gmatch (buttonName, "%d+") do
        buttonIndex = idx
    end

    if buttonIndex == nil then
        return false
    end

    local newButtonName = string.gsub(buttonName, buttonIndex .. "$", buttonIndex + index);
    if _G[newButtonName] and _G[newButtonName]:IsVisible() then
        SetButton(_G[newButtonName]);
        return true
    end

    return false
end

function SetTradeSkillIndex(index)
    if not SetButtonIndex(index) then
        if index == 1 then
            if _G["TradeSkillListScrollFrameScrollBarScrollDownButton"]:IsEnabled() == 1 then
                _G["TradeSkillListScrollFrameScrollBarScrollDownButton"]:Click();
                SetButtonIndex(-3);
            end
        else
            if _G["TradeSkillListScrollFrameScrollBarScrollUpButton"]:IsEnabled() == 1 then
                _G["TradeSkillListScrollFrameScrollBarScrollUpButton"]:Click();
                SetButtonIndex(3);
            end
        end
    end

    local _, type = GetTradeSkillInfo(S_BUTTON:GetID());
    if type ~= "header" then
        ClickButtonLeft();
    end
end

function SetTradeSkillButton()
    local _, type = GetTradeSkillInfo(S_BUTTON:GetID());
    if type == "header" then
        ClickButtonLeft();
    else
        _G["TradeSkillCreateButton"]:Click();
    end
end

function SetMerchantIndex(index)
    if S_BUTTON == nil then return end
    local buttonName = S_BUTTON:GetName();

    -- @robinsch: ContainerFrame priorty if cursor is in container
    if string.find(buttonName, "ContainerFrame") then
        return false
    end

    local merchantIndex = string.match(buttonName, "%d+");

    local numSlots = GetMerchantNumItems();
    if ( merchantIndex + index ) > numSlots then
        return
    else
        merchantIndex = merchantIndex + index;
    end
        
    local newButtonName = "MerchantItem" .. merchantIndex .. "ItemButton";
    if _G[newButtonName] and _G[newButtonName]:IsVisible() then
        SetButton(_G[newButtonName]);
        return true
    end

    return false
end

function SetSpellIndex(index)
    if S_BUTTON == nil then return end
    local buttonName = S_BUTTON:GetName();
    local buttonIndex
    for idx in string.gmatch (buttonName, "%d+") do
        buttonIndex = idx
    end

    if buttonIndex == nil then
        return false
    end

    -- Cursor @ Spell Book (Skill Line Tab)
    if string.find(buttonName, "SpellBookSkillLineTab") then
        -- Right => Unbind
        if index == 1 then return true end

        -- Left => SpellButton
        if index == -1 then
            SetButton(_G["SpellButton1"]);
            return true
        end

        -- @robinsch: clamp
        if index == -2 then index = -1 end
        if index == 2 then index = 1 end
    -- Cursor @ Spell Book
    elseif string.find(buttonName, "SpellButton") then
        -- Down => Action Bar
        if (buttonIndex + index) >= 12 then
            SetButton(_G["ActionButton1"]);
            return true
        end

        -- Cursor @ Left Side
        if buttonIndex % 2 == 0 then
            -- Right => Spell Book (Skill Line Tab)
            if index == 1 then
                SetButton(_G["SpellBookSkillLineTab1"]);
                return true
            end
        -- Cursor @ Left Side
        elseif buttonIndex % 1 == 0 then
            -- Left => Unbind
            if index == -1 then return true end
        end
    -- Cursor @ Action Bar
    elseif string.find(buttonName, "ActionButton") then
        -- Up to SpellButton
        if index == -2 then
            SetButton(_G["SpellButton1"]);
        end

        -- Down => Unbind
        if index == 2 then return true end
    end

    local newButtonName = string.gsub(buttonName, buttonIndex .. "$", buttonIndex + index);
    if _G[newButtonName] and _G[newButtonName]:IsVisible() then
        SetButton(_G[newButtonName]);
        return true
    else
        -- @robinsch: for some classes ActionButton is called BonusActionButton
        if string.find(buttonName, "ActionButton") then
            newButtonName = "Bonus"..newButtonName;
            if _G[newButtonName] and _G[newButtonName]:IsVisible() then
                SetButton(_G[newButtonName]);
                return true
            end
        end
    end

    return false
end

function SetBagIndex(index)
    if S_BUTTON == nil then return end
    local buttonName = S_BUTTON:GetName();

    local bagIndex, itemIndex;
    local i = 1;
    for idx in string.gmatch(buttonName, "%d+") do
        if i == 1 then bagIndex = tonumber(idx) end
        if i == 2 then itemIndex = tonumber(idx) end
        i = i + 1;
    end 

    if bagIndex == nil or itemIndex == nil then
        return false
    end

    local numSlots = GetContainerNumSlots(bagIndex - 1);
    if ( itemIndex + index ) > GetContainerNumSlots(bagIndex - 1) then
        if bagIndex < 5 then
            bagIndex = bagIndex + 1;
            itemIndex = ( itemIndex + index ) % numSlots;
        end
    elseif ( itemIndex + index ) < 1 then
        bagIndex = bagIndex - 1;
        itemIndex = GetContainerNumSlots(bagIndex - 1) + ( itemIndex + index );
    else
        itemIndex = itemIndex + index;
    end
        
    local newButtonName = "ContainerFrame" .. bagIndex .. "Item" .. itemIndex;
    if _G[newButtonName] and _G[newButtonName]:IsVisible() then
        SetButton(_G[newButtonName]);
        return true
    end

    return false
end

function SetSpellButton()
    if S_BUTTON == nil then return false end

    if string.find(S_BUTTON:GetName(), "SpellBookSkillLineTab") then
        ClickButtonLeft();
        return true;
    end

    if string.find(S_BUTTON:GetName(), "ActionButton") then
        if GetCursorInfo() ~= nil then
            PlaceAction(S_BUTTON:GetID());
        else
            PickupAction(S_BUTTON:GetID());
        end

        return true;
    end

    if S_BUTTON == _G["SpellbookMicroButton"] then
        ClickButtonLeft();
        return true;
    end

    local id = SpellBook_GetSpellID(S_BUTTON:GetID());
    PickupSpell(id, BOOKTYPE_SPELL);
    return true;
end

function ClearSpellButton()
    if S_BUTTON == nil then
        _G["SpellBookFrame"]:Hide();
    end

    if S_DEBUG then
        print(S_BUTTON:GetName());
    end
    
    ClearCursor();
    return true;
end

function DeleteItem()
    local cursorType, _, link = GetCursorInfo();
    if cursorType == "item" then
        StaticPopup_Show("DELETE_ITEM", link);
    end

    return true;
end

FRAME_BUTTONS =
{
    QuestLogFrame =
    { 
        "QuestLogFrameAbandonButton", "QuestLogFramePushQuestButton", "QuestLogFrameTrackButton", "QuestLogFrameCancelButton"
    },
}

function SetFrameLRIndex(frame, index)
    if S_BUTTON == nil then return end
    local buttonName = S_BUTTON:GetName();

    local buttonIndex = 0;
    for i, v in ipairs(FRAME_BUTTONS[frame:GetName()]) do
        if v == buttonName then
            buttonIndex = i;
            break;
        end
    end

    if index > 0 then
        for i = ( buttonIndex + index ), #FRAME_BUTTONS[frame:GetName()] do
            local newButton = _G[FRAME_BUTTONS[frame:GetName()][i]];
            if newButton and newButton:IsEnabled() == 1 then
                SetButton(_G[FRAME_BUTTONS[frame:GetName()][i]]);
                return
            end
        end
    else
        for i = ( buttonIndex + index ), 1, index do
            local newButton = _G[FRAME_BUTTONS[frame:GetName()][i]];
            if newButton and newButton:IsEnabled() == 1 then
                SetButton(_G[FRAME_BUTTONS[frame:GetName()][i]]);
                return
            end
        end
    end
end

function QuestLogFrame_Right()
    if CursorHasItem() then
        ClearCursor();
    else
        ClearButton();
        CloseAllBags();
    end
end

-- @robinsch: micro button helpers
MICRO_BUTTONS = { "CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "SocialsMicroButton", "PVPMicroButton", "LFDMicroButton", "MainMenuMicroButton", "HelpMicroButton" };
function SetMicroButton(button)
    if S_BUTTON == nil then
        SetButton(button);
    else
        ClearButton();
        CloseMenus();
    end
end

function SetMicroButtonIndex(index)
    if S_BUTTON == nil then return end
    local buttonName = S_BUTTON:GetName();
    for i, v in ipairs(MICRO_BUTTONS) do
        if v == buttonName then
            if _G[MICRO_BUTTONS[i + index]] then
                SetButton(_G[MICRO_BUTTONS[i + index]]);
            end
        end
    end
end

function MoveCursor(button)
    if button:IsVisible() then
        x, y = GetNormalizedPosition(button);
        SetCursorPosition(x, y);
    end
end

function GetNormalizedPosition(frame)
    if GetCVar("gxWindow") == 1 and GetCVar("gxMaximize") ~= 1 then
        print("ControllerMod: Windowed Mode (Maximized = 0) is not supported yet!");
    end

    local w, h = GetScreenWidth(), GetScreenHeight()
    local x, y = frame:GetCenter()
    return x/w, y/h
end

-- @robinsch: event handlers (https://wowpedia.fandom.com/wiki/Events)
EVENT_HANDLERS =
{
    GOSSIP_SHOW     = { SetButton, "GossipTitleButton1" },
    GOSSIP_CLOSED   = { ClearButton },

    QUEST_GREETING  = { SetButton, "QuestTitleButton1" },
    QUEST_DETAIL    = { SetButton, "QuestFrameAcceptButton" },
    QUEST_FINISHED  = { ClearButton },
    QUEST_COMPLETE  = { SetButton, "QuestFrameCompleteQuestButton" },

    SPELLS_CHANGED  = { SetButton, "SpellButton1" },

    TRADE_SKILL_SHOW  = { SetButton, "TradeSkillSkill2" },
    TRADE_SKILL_CLOSE = { ClearButton },
}

-- @robinsch: binding handlers (Esc -> Key Bindings -> ControllerMod)
-- sorted by priority
BINDING_HANDLERS =
{
    GossipFrame =
    {
        Button_A = { ClickButtonLeft },
        Button_B = { CloseGossip },
        Left = { SetButton, "GossipTitleButton1" },
        Right = { SetButton, "GossipFrameGreetingGoodbyeButton" },
        Up = { SetButtonIndex, -1 },
        Down = { SetButtonIndex, 1 },
    },

    QuestFrameGreetingPanel =
    {
        Button_A = { ClickButtonLeft },
        Button_B = { CloseQuest },
        Left = { SetButton, "QuestTitleButton1" },
        Right = { SetButton, "QuestFrameGreetingGoodbyeButton" },
        Up = { SetButtonIndex, -1 },
        Down = { SetButtonIndex, 1 },
    },

    QuestFrameDetailPanel =
    {
        Button_A = { ClickButtonLeft },
        Button_B = { CloseQuest },
        Left = { SetButton, "QuestFrameAcceptButton" },
        Right = { SetButton, "QuestFrameDeclineButton" },
        Up = { ClickButtonLeft, "QuestDetailScrollFrameScrollBarScrollUpButton"  },
        Down = { ClickButtonLeft, "QuestDetailScrollFrameScrollBarScrollDownButton"  },
    },

    QuestFrameRewardPanel =
    {
        Button_A = { ClickButtonLeft },
        Button_B = { CloseQuest },
        Left = { SetButton, "QuestFrameCompleteQuestButton" },
        Right = { SetButton, "QuestFrameCancelButton" },
        Up = { ClickButtonLeft, "QuestRewardScrollFrameScrollBarScrollUpButton"  },
        Down = { ClickButtonLeft, "QuestRewardScrollFrameScrollBarScrollDownButton"  },
    },

    QuestLogFrame =
    {
        Button_A = { ClickButtonLeft },
        Button_B = { ClickButtonLeft, "QuestLogFrameCloseButton" },
        Left = { SetFrameLRIndex, -1 },
        Right = { SetFrameLRIndex, 1 },
        Up = { SetButtonIndex, -1 },
        Down = { SetButtonIndex, 1 },
    },

    TradeSkillFrame =
    {
        Button_A = { ClickTradeSkillButton },
        Button_B = { ClickButtonLeft, "TradeSkillFrameCloseButton" },
        Button_X = { ClickButtonLeft, "TradeSkillCreateAllButton" },
        Up = { SetTradeSkillIndex, -1 },
        Down = { SetTradeSkillIndex, 1 },
    },

    MerchantFrame =
    {
        Button_A = { ClickButtonLeft },
        Button_B = { ClickButtonLeft, "MerchantFrameCloseButton" },
        Button_X = { ClickButtonRight },
        Left = { SetMerchantIndex, -1 },
        Right = { SetMerchantIndex, 1 },
        Up = { SetMerchantIndex, -2 },
        Down = { SetMerchantIndex, 2 },
    },

    SpellBookFrame =
    {
        Button_A = { SetSpellButton },
        Button_B = { ClearSpellButton },
        Left = { SetSpellIndex, -1 },
        Right = { SetSpellIndex, 1 },
        Up = { SetSpellIndex, -2 },
        Down = { SetSpellIndex, 2 },
    },

    ContainerFrame1 =
    {
        Button_A = { ClickButtonLeft },
        Button_B = { ClickButtonLeft, "MainMenuBarBackpackButton" },
        Button_X = { ClickButtonRight },
        Button_Y = { DeleteItem },
        Left = { SetBagIndex, 1 },
        Right = { SetBagIndex, -1 },
        Up = { SetBagIndex, 4 },
        Down = { SetBagIndex, -4 },
    },

    WorldFrame =
    {
        Button_A = { ClickButtonLeft },
        Start = { ClickButtonLeft, "MainMenuBarBackpackButton"},
        Back = { SetMicroButton, "CharacterMicroButton" },
        Left = { SetMicroButtonIndex, -1 },
        Right = { SetMicroButtonIndex, 1 },
    },
}

QuestLogFrame:HookScript("OnShow", function(self)
    SetButton(_G["QuestLogScrollFrameButton1"]);
end)

QuestLogFrame:HookScript("OnHide", function(self)
    ClearButton();
end)

MerchantFrame:HookScript("OnShow", function(self)
    if not CheckDLL() then
        return StaticPopup_Show("POPUP_EXTENSIONS")
    end

    SetButton(_G["MerchantItem1ItemButton"]);
    _G["MainMenuBarBackpackButton"]:Click();
end)

ContainerFrame1:HookScript("OnShow", function(self)
    if not CheckDLL() then
        return StaticPopup_Show("POPUP_EXTENSIONS")
    end

    SetButton(_G["ContainerFrame1Item16"]);
    _G["CharacterBag0Slot"]:Click();
    _G["CharacterBag1Slot"]:Click();
    _G["CharacterBag2Slot"]:Click();
    _G["CharacterBag3Slot"]:Click();
end)

ContainerFrame1:HookScript("OnHide", function(self)
    if not CheckDLL() then
        return StaticPopup_Show("POPUP_EXTENSIONS")
    end

    ClearButton();

    if _G["MerchantFrame"]:IsVisible() then
        SetButton(_G["MerchantItem1ItemButton"]);
    end
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

-- @robinsch: register event listeners
if CheckDLL() then
    for event, _ in pairs(EVENT_HANDLERS) do
        frame:RegisterEvent(event);
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    if not CheckDLL() then
        return StaticPopup_Show("POPUP_EXTENSIONS")
    end

    if event == "ADDON_LOADED" then
        SetCVar("autoLootDefault", 1);
        SetCVar("cameraTerrainTilt", 1);
    end

    handler = EVENT_HANDLERS[event];
    if handler then
         ControllerMod_Handle(nil, handler);
    end
end)

-- @robinsch: Bindings.xml handlers
function ControllerMod_Start()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Start"] then
            ControllerMod_Handle(_G[frame], handler["Start"]);
            return
        end
    end
end

function ControllerMod_Back()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Back"] then
            if ControllerMod_Handle(_G[frame], handler["Back"]) then
                return
            end
        end
    end
end

function ControllerMod_Button_A()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Button_A"] then
            if ControllerMod_Handle(_G[frame], handler["Button_A"]) then
                return
            end
        end
    end

    ClickButtonA();
end

function ControllerMod_Button_B()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Button_B"] then
            if ControllerMod_Handle(_G[frame], handler["Button_B"]) then
                return
            end
        end
    end

    ClickButtonB();
end

function ControllerMod_Button_X()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Button_X"] then
            if ControllerMod_Handle(_G[frame], handler["Button_X"]) then
                return
            end
        end
    end

    ClickButtonX();
end

function ControllerMod_Button_Y()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Button_Y"] then
            if ControllerMod_Handle(_G[frame], handler["Button_Y"]) then
                return
            end
        end
    end

    ClickButtonY();
end

function ControllerMod_Left()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Left"] then
            if ControllerMod_Handle(_G[frame], handler["Left"]) then
                return
            end
        end
    end   
end

function ControllerMod_Right()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Right"] then
            if ControllerMod_Handle(_G[frame], handler["Right"]) then
                return
            end
        end
    end   
end

function ControllerMod_Up()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Up"] then
            if ControllerMod_Handle(_G[frame], handler["Up"]) then
                return
            end
        end
    end  
end

function ControllerMod_Down()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Down"] then
            if ControllerMod_Handle(_G[frame], handler["Down"]) then
                return
            end
        end
    end  
end

function ControllerMod_Handle(frame, handle)
    if handle == nil then
        return false
    end

    local fn = handle[1];
    if fn == nil then
        return false
    end

    -- @robinsch: handle fn parameter parsing
    if fn == SetButton or fn == SetMicroButton then
        return fn(_G[handle[2]]);
    elseif fn == ClickButtonLeft then
        if handle[2] then
            _G[handle[2]]:Click("LeftButton");
            return true;
        else
            return ClickButtonLeft(S_BUTTON);
        end
    elseif fn == ClickButtonRight then
        if handle[2] then
            _G[handle[2]]:Click("RightButton");
            return true;
        else
            return ClickButtonRight(S_BUTTON);
    end
    elseif fn == SetButtonIndex or fn == SetTradeSkillIndex or fn == SetMicroButtonIndex or fn == SetBagIndex or fn == SetMerchantIndex or fn == SetSpellIndex then
        return fn(handle[2]);
    elseif fn == SetFrameLRIndex then
        return fn(frame, handle[2])
    else
        return fn();
    end

    return false
end
