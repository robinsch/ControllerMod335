ControllerMod = {}

S_BUTTON = nil;

BINDING_HEADER_CONTROLLERMOD = "Controller Mod"
BINDING_NAME_START = "Start"
BINDING_NAME_INTERACT = "Interact"
BINDING_NAME_BACK = "Back"
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
function ClickButton()
    if S_BUTTON == nil then
        return false
    elseif S_BUTTON:GetName() == "CharacterMicroButton" then
        ToggleCharacter("PaperDollFrame");
        return true
    end

    S_BUTTON:Click();
    return true
end

function ClearButton()
    S_BUTTON = nil;
    SetCursorPosition(0.5, 0.25);
end

function SetButton(button)
    if button == nil then return end
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
        return
    end

    local newButtonName = string.gsub(buttonName, buttonIndex .. "$", buttonIndex + index);
    if _G[newButtonName] and _G[newButtonName]:IsVisible() then
        SetButton(_G[newButtonName]);
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
    if GetCVar("gxMaximize") ~= 1 then
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
}

-- @robinsch: binding handlers (Esc -> Key Bindings -> ControllerMod)
-- sorted by priority
BINDING_HANDLERS =
{
    GossipFrame =
    {
        Interact = { ClickButton },
        Back = { CloseGossip },
        Left = { SetButton, "GossipTitleButton1" },
        Right = { SetButton, "GossipFrameGreetingGoodbyeButton" },
        Up = { SetButtonIndex, -1 },
        Down = { SetButtonIndex, 1 },
    },

    QuestFrameGreetingPanel =
    {
        Interact = { ClickButton },
        Back = { CloseQuest },
        Left = { SetButton, "QuestTitleButton1" },
        Right = { SetButton, "QuestFrameGreetingGoodbyeButton" },
        Up = { SetButtonIndex, -1 },
        Down = { SetButtonIndex, 1 },
    },

    QuestFrameDetailPanel =
    {
        Interact = { ClickButton },
        Back = { CloseQuest },
        Left = { SetButton, "QuestFrameAcceptButton" },
        Right = { SetButton, "QuestFrameDeclineButton" },
        Up = { ClickButton, "QuestDetailScrollFrameScrollBarScrollUpButton"  },
        Down = { ClickButton, "QuestDetailScrollFrameScrollBarScrollDownButton"  },
    },

    WorldFrame =
    {
        Start = { SetMicroButton, "CharacterMicroButton"},
        Interact = { ClickButton },
        Left = { SetMicroButtonIndex, -1 },
        Right = { SetMicroButtonIndex, 1 },
    },
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

-- @robinsch: register event listeners
for event, _ in pairs(EVENT_HANDLERS) do
    frame:RegisterEvent(event);
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if not CheckDLL() then
            return StaticPopup_Show("POPUP_EXTENSIONS")
        end

        SetCVar("autoLootDefault", 1);
    end

    handler = EVENT_HANDLERS[event];
    if handler then
         ControllerMod_Handle(handler);
    end
end)

-- @robinsch: check if DLL lua API is injected
function CheckDLL(self)
    return InteractNearest and SetCursorPosition;
end

-- @robinsch: Bindings.xml handlers
function ControllerMod_Start()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Start"] then
            ControllerMod_Handle(handler["Start"]);
            return
        end
    end
end

function ControllerMod_Interact()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Interact"] then
            if ControllerMod_Handle(handler["Interact"]) then
                print("Return")
                return
            end
        end
    end

    InteractNearest();
end

function ControllerMod_Back()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Back"] then
            ControllerMod_Handle(handler["Back"]);
        end
    end    
end

function ControllerMod_Left()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Left"] then
            ControllerMod_Handle(handler["Left"]);
        end
    end   
end

function ControllerMod_Right()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Right"] then
            ControllerMod_Handle(handler["Right"]);
        end
    end   
end

function ControllerMod_Up()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Up"] then
            ControllerMod_Handle(handler["Up"]);
        end
    end  
end

function ControllerMod_Down()
    for frame, handler in pairs(BINDING_HANDLERS) do
        if _G[frame] and _G[frame]:IsVisible() and handler["Down"] then
            ControllerMod_Handle(handler["Down"]);
        end
    end  
end

function ControllerMod_Handle(handle)
    local fn = handle[1];
    if fn == nil then
        return false
    end

    -- @robinsch: handle fn parameter parsing
    if fn == SetButton or fn == SetMicroButton then
        return fn(_G[handle[2]]);
    elseif fn == ClickButton then
        if handle[2] then
            _G[handle[2]]:Click();
        else
            return ClickButton(S_BUTTON);
        end
    elseif fn == SetButtonIndex or fn == SetMicroButtonIndex then
        return fn(handle[2]);
    else
        return fn();
    end

    return false
end
