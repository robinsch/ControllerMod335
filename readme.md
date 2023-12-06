### Notes
In development, ControllerMod does not offer native controller support. You need to use [Steam Big Picture Mode](https://store.steampowered.com/bigpicture).

### Installation
1. Move Patcher.exe to WoW folder and run it.
2. Move Extensions.dll to WoW folder.
3. Move patch-controllermod.mpq to WoW/Data folder.
4. Import steam controller profile.

## Steam Setup
0. Download and Install Steam (https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe)
1. Launch Steam
2. Click the **Games** menu, choose **Add a Non-Steam Game to My Library**.
3. Browse for Wow.exe on your computer.
4. Click on **Add Selected Programs**.

## Steam Controller
1. Launch Steam in Big Picture Mode.
2. Browse for Wow in your Steam Library.
3. Select the gamepad icon on the right.
4. Click the **Search** menu, search for **ControllerMod335** (or download it through your browser: steam://controllerconfig/3255281634/3069784775)
5. Download and activate the controller layout.


## Steam Auto-Login
1. Launch Steam in Big Picture Mode.
2. Browse for Ascension in your Steam Library.
3. Select the setting icon on the right (next to the gamepad icon).
4. Copy and paste the text segement below and adjust it to your 

`-login "user e.g. Myaccount" -password "pass e.g. Mysecretpass" -realmName "realm e.g. Sunfury" - character "char e.g. Mychar"`


### Features
* New LUA API:
  * InteractNearest()
  * SetCursorPosition(x, y)
  * DeleteCursorItemConfirm()
 
* New CVARs:
  * autoTarget (enables targeting attack on melee attack or spell hit)
  * tabTargetFriend (enables tab targeting to target friendly units)
    
* Supported Frames:
  * QuestFrame
  * GossipFrame
  * MerchantFrame
  * SpellBookFrame
  * ContainerFrame
  * StaticPopup
  * TradeSkillFrame


### Updating
1. Replace Extensions.dll.
2. Replace patch-controllermod in WoW/Data folder.
