local addonName = ...

local defaults = {
	cameraActionAngle = 4.0,
    cameraActionAngleMin = 0.0,
    cameraActionAngleMax = 6.28,
}

RegisterCVar("CM_CameraAngle", defaults.worldTimeSpeed)

-- @robinsch: Option Panel
ControllerModPanelOptions = {
    CM_CameraAngle = { text = "Camera Angle", minValue = defaults.cameraActionAngle, minValue = defaults.cameraActionAngleMin, maxValue = defaults.cameraActionAngleMax, valueStep = 0.0025, },
}

function ControllerModOptions_UpdateSettings(cvar, value)
	ControllerModOptionsDB[cvar] = value

	if cvar == "CM_CameraAngle" then
		SetCVar("cameraActionAngle", ControllerModOptionsDB["CM_CameraAngle"])
	end
end

function ControllerModOptions_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED")
	self.name = addonName;
	self.options = ControllerModPanelOptions;
end

function ControllerModOptions_OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		local addon = ...
		if addon == addonName then
			InterfaceOptionsPanel_OnLoad(self);

			ControllerModOptionsDB = ControllerModOptionsDB or {
				CM_CameraAngle = defaults.cameraActionAngle,
			}
		end
	end
end
