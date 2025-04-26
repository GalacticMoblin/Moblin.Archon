# v1.7.0 (Latest)
**Feature Changes**
- Added Russian Translation by **Daurik_**
- Added Japanese Translation by **akinasu666** [#8](https://github.com/GalacticMoblin/Moblin.Archon/pull/8)
- `Bring the Thunder` and `Eye of the Storm` now have unique DamageSourceIDs for the obituary.
- `Static Feedback` now has its own associated visual identifier to go along with the rest of the kits.
- Tweaked some localisation strings.
- Added FX to the `Arc Cannon` firing animation.

**Bug Fixes**
- Fixed error on startup with dependency check. 
- Fixed Archon's Body Camo not being applied properly. (Requires remaking loadout, sorry)
- Stopped `Bring the Thunder` applying visual distortion to the attacker's team.
- Fixed the `Tesla Node` projectile being able to be locked onto by the Smart Pistol after it disappears.
- Fixed the `Tesla Node` projectile being left behind after being destroyed through damage.
- `Tesla Node` is now able to be attacked by AI.
- Fixed the custom "Titan Ready" message not being present. [#7](https://github.com/GalacticMoblin/Moblin.Archon/pull/7)
# v1.6.0
**Feature Changes:**
- Added Camo support for the Arc Cannon.
- Made the Arc Cannon use unique LocStrings.
- Updated the Missing Dependency warning dialogue.
- Updated Archon LocStrings.
- Removed the Prime Titan toggle.
- Tweaked Archon's Kit icons.
- Tweaked some LocStrings.

**Balance Changes:**
- Added Balance changes specifically for Frontier War.
   - Storm Core's damage is reduced by 33% against the Harvester.
   - Tesla Node's damage is reduced by 50% against the Harvester.
- Terminator's meter now gets wiped when exiting Archon.
- Terminator's damage requirement is lowered slightly. (8000 > 7500)
- Storm Core can now generate Terminator charge by inflicting damage.
- Tesla Node can now take damage. (1250 pilot damage)
- Thylord Module's shot spread was reduced by 30%.
- Thylord Module's Impact Damage reduction was reduced from x0.69 to x0.75.

**Bug Fixes:**
- Fixed the player being able to back out of the Missing Dependency dialogue and soft-locking the main menu.
- Fixed Tesla Node being able to generate Terminator charge by damaging itself.
- Fixed Storm Core not having the same visual effects other Titan Cores have.
- Fixed Static Feedback and Terminator not working at all.
- Fixed the Arc Cannon's idle muzzle flash not appearing in some cases.
- Fixed the Arc Cannon not applying damage FXs correctly.
- Fixed Bounty Hunt erroring out when attempting to play with Archon.
- Fixed Eye of the Storm being able to generate Terminator charge by damaging Tesla Node.
- Fixed Archon's Kit slot name not displaying  `ARCHON KIT:`
- Fixed Auto Archon crash from inflicting damage with Charge Ball while dead. [#3](https://github.com/GalacticMoblin/Moblin.Archon/pull/3)
- Fixed Auto Archon being unable to deal explosion damage with Charge Ball. [#4](https://github.com/GalacticMoblin/Moblin.Archon/pull/4)
- Fixed Archon's third person animations being broken. [#5](https://github.com/GalacticMoblin/Moblin.Archon/pull/5)
## v1.5.4
- Updated Archon's dependency versions.
## v1.5.3
**Feature Changes:**
- Replaced Static Feedback's Kit Icon
- Updated the rest of the Kit Icons to be more accurate to the rest of the roster.

**Balance Changes:**
- Buffed Eye of the Storm's Pilot damage from **30** per tick to **40** per tick.
- Buffed Eye of the Storm's Titan damage from **100** per tick to **120** per tick.

**Bug Fixes:**
- Fixes compatibility with `Northstar 1.17.0+`
## v1.5.2
**Balance Changes:**
- Added a 10% damage penalty to Charge Ball when Aegis Ranks are enabled.

**Bug Fixes:**
- Fixed the Arc Cannon's ability to sometimes shoot through Particle Wall.
- Removed a testing leftover modifying Ion's Laser Shot icon in Aegis modes.
- Finally properly fixed the Arc Cannon's ability to destroy Tethers and Satchels.
## v1.5.1
**Feature Changes:**
- Archon now has a unique titan icon.
- Selecting Archon now defaults to the Prime Ion model.
- Shock Shield has a new shield impact effect when someone shoots it.
- Tweaks to Aegis Ranks:
   - `Overtuned Amplifier` has been replaced with `Rolling Thunder`, which allows Storm Core to bounce twice before exploding.
   - Terminator now requires damage to be accumulated to trigger the effect.
   - Terminator now additionally increases Charge Ball's charge speed.
   - Archon's Aegis Rank order has been changed to:
      - Critical Overload
      - Chassis Upgrade
      - Eye of the Storm
      - Terminator
      - Shield Upgrade
      - Extra Capacitor
      - Rolling Thunder

**Bug Fixes:**
- Shock Shield no longer holds bullets and projectiles when blocking incoming fire.
- Archon's Chassis Upgrade and Shield Upgrade now properly apply.
# v1.5.0
**Feature Changes:**
- Archon now has it's own loadout slot, this requires a new dependency to work called `Peepee.TitanFramework`, new features because of this include:
   - New Kit Icons.
   - New Coloured Ability Icons.
   - New Weapon Descriptions.
   - New Titan hints.
   - New Titan stats.
- Included a warning if `Peepee.TitanFramework` is disabled or missing.
- Updated the Localisation files to use overrides. (if you'd like to translate for Archon, get in touch)
- Cleaned up Auto Archon's functionality.
   - Arc Cannon now charges properly.
   - Charge Ball now charges properly and fires the Triple/Thylord variant.
   - Shock Shield is fired properly.
- Updated a bunch of older icons to be less crispy around the edges, plus some recolours.
- Consolidated some split weapon files into single files and cleaned up the codebase.

**Balance Changes:**
- Decreased Arc Cannon's minimum damage from 700 to 550. (meant to do this last update, I forgot, lol.)

**Bug Fixes:**
- Fixed a validation error with Terminator's script.
- Fixed a crash to do with Arc Cannon's idle muzzle flash turning off and then dying before it reactivates.
- Fixed a crash where having the **First Person Embark/Executions** riff enabled would cause an error when terminating another titan.
- Fixed Storm Core's sound files overwriting MRVN sounds and having those play in War Games.
## v1.4.1
**Feature Changes:**
- Modified Arc Cannon and Charge Ball's visual recoil.

**Balance Changes:**
- Increased Charge Ball's base zapping damage from 250(125, 83) per tick to 300(150, 100) per tick.
- Increased Arc Cannon's max range from 2300 units to 3000 units.
- Increased Arc Cannon's maximum damage from 800 to 900.
- Increased Storm Core's explosion outer-radius from 400 to 450. (400 inner)
- Increased Storm Core's projectile speed from 850 to 1,000.

**Bug Fixes:**
- Fixed a crash where terminator's code would trigger at the end of a match with an invalid entity.
- Fixed Energy Siphon's FX not loading when the mod is active.
- Reverted the fix for being able to shoot satchels with Arc Cannon and Shock Shield.
- Fixed the Terminator Aegis Rank not working against piloted titans.
# v1.4.0
**ARCHON FRONTIER DEFENSE UPDATE (Aegis Ranks)**

**Feature Changes:**
- Archon now has a full set of 5 Aegis Ranks:
  - **Rank 1: Overtuned Amplifier.** Allows Shock Shield to chain to multiple targets.
  - **Rank 2: Critical Overload:** Increases Arc Cannon's Critical Hit Multiplier.
  - **Rank 3: Eye of the Storm:** Holding out Shock Shield produces a damaging Arc Field around the user.
  - **Rank 4: Terminator:** Terminating (Executing) enemy titans grants the Arc Cannon a temporary Charge Rate increase.
  - **Rank 5: Extra Capacitor:** Grants Charge Ball an additional ability charge.
- **ARC CANNON NOW HAS IT'S ORIGINAL MODEL AND ANIMATIONS WOOOOOOOOO.**
- Arc Cannon now has it's own icon alongside an alternate version while Terminator is active.
- Added a visual ring to Tesla Node.
- Changed Arc Cannon's Charge-up and Firing Sounds.
- Added Unique Storm Core sounds.
- Added Aegis Rank ability icons for Overtuned Amplifier and Extra Capacitor.
- Tesla Node's explosion now does a minor amount of damage.

**Balance Changes:**
- Increased Thylord Module's contact damage by 15%.
- Reduced Arc Cannon's damage from 900 > 800.
- Reimplemented Weakpoint damage for Arc Cannon and Shock Shield.
- Increased Tesla Node's recharge time from 13.3s to 15s.
- Increased Charge Ball's recharge time from 7s to 8s.

**Bug Fixes:**
- Fixed Arc Cannon and Shock Shield's tracer stopping when hitting electric smoke.
- Fixed Storm Core's Bring the Thunder kit applying the distortion effect to friendly players.
- Fixed Shock Shield's damage being charge dependent (Whoops).
- Fixed Arc Cannon not doing crit damage (whoops).
- Fixed Arc Cannon's tracers behaving strangely with certain entities.
- Fixed Arc Cannon and Shock Shield not being able to destroy sticky entities.
- Fixed a crash where you died before the Shock Shield and Arc Cannon tracers ended.
- Fixed a crash caused by trading kills while using Arc Cannon or Shock Shield.
- Fixed Tesla Node rarely spawning with no electricity and never disappearing.
- Fixed a visual bug where cancelling Arc Cannon into Shock Shield would make Shock Shield's beam end prematurely.
- Fixed Storm Core gaining insane speed by dashing as it fires.
- Fixed Charge Ball's ammo bar slowly draining when fired.
## v1.3.2
**Feature Changes:**
- The "Bolt from the Blue" kit now has a unique shield colour.
- Introduced a major visual distortion effect to Tesla Node and Storm Core.
- Introduced a minor visual distortion effect to Arc Cannon and Charge Ball.
- Storm Core now applies a miniscule distortion effect on activation.

**Balance Changes:**
- Increased Shock Shield's range from 1200 > 1500.
- Increased Arc Cannon's minimum damage falloff from 700 > 800.
- Increased Arc Cannon's NPC damage from 600 > 700.
- Introduced a minor move-speed slowdown effect to Tesla Node. (-10%)

**Bug Fixes:**
- Fixed Auto Titans doing 0 damage with Arc Cannon.
- Fixed Auto Titans targeting Tesla Node when they're not supposed to.
- Fixed Auto Titans using Melee on Tesla Node when they're not supposed to.
- Fixed Storm Core not destroying Brute's Dome Shield.
## v1.3.1
***1000 Thunderstore Downloads!***

**Feature Changes:**
- Made Bring the Thunder inflict the Sonar effect to enemies caught in the smoke.

**Bug Fixes:**
- Fixed Storm Core's interaction with Particle Wall, Gun Shield, Vortex Shield, Thermal Shield and Shock Shield, it now takes all of them down without having to consume the projectile.
- Storm Core can no longer hit weakpoints.
- Fixed Storm Core's animations being broken as hell.
# v1.3.0
**Feature Changes:**
- New UI Elements! Archon now has custom icons for all of it's abilities. (Made by GalacticMoblin and Hurbski)
- Shock Shield has been reworked, it now consumes only portions of your charge when firing rather than all of it at once.
- Bolt from the Blue has been changed, it now reduces the amount of charge lost from firing Shock Shield.
- Included some parity changes from Brute4.
- Storm Core's first person animation was changed from Flame Core to Laser Core.
- Changed Arc's Cannon icon from the 40mm to the Plasma Railgun.

**Balance Changes:**
- Shock Shield now has increased damage. (250 > 400)
- Shock Shield now has decreased range. (2300 > 1200)
- Shock Shield now has a recharge time of 8 seconds.
- Shock Shield now has an uptime of 4 seconds.
- Shock Shield's firing now only takes 40% charge instead of 100%.
- Arc Cannon's firing rate has been reduced from 1.6 > 1.3.
- Arc Cannon now has damage falloff at range.
- Thylord Module's orbs now have reduced impact damage against titans. (700 > 420)
- Increased Storm Core's Direct damage from 1500 > 3500.
- Increased Storm Core's Explosion damage from 1000 > 1500.

**Bug Fixes:**
Arc Cannon's beam no longer disappears if you fire it too fast.
Storm Core no longer bounces off of Particle Wall or Vortex Shield.
Fixed damage sources being weird with other mods.
Fixed Shock Shield crashing the game when picking up too many rockets.
Fixed Shock Shield crashing the game when zapping Gun Shield.
Fixed Storm Core producing 3 of itself.
## v1.2.1:
**Feature Changes:**
- Added support for the new `Northstar 1.8.0` core gain exceptions.
- New Kit: Static Feedback, hits with the Arc Cannon replenish ability charge.
- Replaced the Dual Nodes kit with the Static Feedback kit (keeping Dual Nodes for FD).

**Balance Changes:**
- Reduced Shock Shield's up time from 5 seconds > 2 seconds.
- Increased Shock Shield's Recharge time from 3 seconds > 4 seconds.
- Increased Charge Ball's Direct Impact damage to pilots from 90 > 100.
# v1.2.0:
**Feature Changes:**
- Archon's Kits are now usable, select your appropriate Ion/Archon Kit in the menu.
- Modified some in-game text to show Archon related info.

**Balance Changes:**
- Reworked Thylord Module.
- Actually implemented the single Charge Ball changes this time.
# v1.1.0:
**Feature Changes:**
- Charge Ball finally visually zaps enemies.

**Balance Changes:**
- Arc Cannon's Fire Rate has been reduced from 2 to 1.6.
- Single Charge Ball's damage per tick has been increased from 150 to 250.
Archon Kit Bolt from the Blue now has a camera slowdown effect.
## v1.0.1:
**Feature Changes:**
- Changed equip method to PrimeTitanPlus, swap to **Ion Prime** to select Archon.
# v1.0.0:
- Initial Release.
