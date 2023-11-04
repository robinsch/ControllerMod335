### Notes
In development, ControllerMod does not offer native controller support. You need to use [Steam Big Picture Mode](https://store.steampowered.com/bigpicture).

### Installation
1. Move Patcher.exe to WoW folder and run it.
2. Move Extensions.dll to WoW folder.
3. Move patch-controllermod.mpq to WoW/Data folder.
4. Import steam controller profile.

## Steam Controller Profiles
steam://controllerconfig/3255281634/3069784775

(copy and paste into browser)


## Steam Auto-Login
You can enable auto login by entering launch options game properties general tab

`-login "user" -password "pass" -realmName "Sunfury" - character "Testchar"`


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
