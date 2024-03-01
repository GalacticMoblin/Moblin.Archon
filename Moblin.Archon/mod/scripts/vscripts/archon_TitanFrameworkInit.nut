global function ArchonUIInit
void function ArchonUIInit()
{
	#if ARCHON_HAS_TITANFRAMEWORK
		#if UI
			//AddTitanBriefingMilesAudio( "meet_#DEFAULT_TITAN_1", "bt_hotdrop_turbo" )
		#endif
	//========================================//-NAMES AND STATS-//========================================//
		ModdedTitanData Archon
		Archon.Name = "#DEFAULT_TITAN_1"
		Archon.icon = $"archon/menu/archon_icon_medium"
		Archon.Description = "#MP_TITAN_LOADOUT_DESC_ARCHON"
		Archon.BaseSetFile = "titan_atlas_ion_prime"
		Archon.BaseName = "ion"
		Archon.altChassisType = frameworkAltChassisMethod.NONE
		Archon.passiveDisplayNameOverride = "#TITAN_ARCHON_PASSIVE_TITLE"
		Archon.difficulty = 2
		Archon.speedStat = 2
		Archon.damageStat = 3
		Archon.healthStat = 2
		Archon.titanHints = ["#DEATH_HINT_ARCHON_001",
		"#DEATH_HINT_ARCHON_002",
		"#DEATH_HINT_ARCHON_003",
		"#DEATH_HINT_ARCHON_004",
		"#DEATH_HINT_ARCHON_005",
		"#DEATH_HINT_ARCHON_006",
		"#DEATH_HINT_ARCHON_007" ]

		//========================================//-WEAPONS-//========================================//
		ModdedTitanWeaponAbilityData ArcCannon
		ArcCannon.custom = true
		ArcCannon.displayName = "#WPN_TITAN_ARCHON_ARC_CANNON"
		ArcCannon.weaponName = "mp_titanweapon_archon_arc_cannon"
		ArcCannon.description = "#WPN_TITAN_ARCHON_ARC_CANNON_LONGDESC"
		ArcCannon.image = $"archon/hud/arc_cannon"
		Archon.Primary = ArcCannon

		ModdedTitanWeaponAbilityData ChargeBall
		ChargeBall.custom = true
		ChargeBall.displayName = "#WPN_TITAN_CHARGE_BALL"
		ChargeBall.weaponName = "mp_titanweapon_charge_ball"
		ChargeBall.description = "#WPN_TITAN_CHARGE_BALL_DESC"
		ChargeBall.image = $"archon/menu/charge_ball"
		Archon.Right = ChargeBall

		ModdedTitanWeaponAbilityData StormCore
		StormCore.custom = true
		StormCore.weaponName = "mp_titancore_storm_core"
		StormCore.displayName = "#TITANCORE_STORM"
		StormCore.description = "#TITANCORE_STORM_DESC"
		StormCore.image = $"archon/hud/storm_core"
		Archon.Core = StormCore

		ModdedTitanWeaponAbilityData ShockShield
		ShockShield.custom = true
		ShockShield.displayName = "#WPN_TITAN_SHOCK_SHIELD"
		ShockShield.weaponName = "mp_titanweapon_shock_shield"
		ShockShield.description = "#WPN_TITAN_SHOCK_SHIELD_DESC"
		ShockShield.image = $"archon/menu/shock_shield"
		Archon.Left = ShockShield

		ModdedTitanWeaponAbilityData TeslaNode
		TeslaNode.custom = true
		TeslaNode.displayName = "#WPN_TITAN_TESLA_NODE"
		TeslaNode.weaponName = "mp_titanweapon_tesla_node"
		TeslaNode.description = "#WPN_TITAN_TESLA_NODE_DESC"
		TeslaNode.image = $"archon/menu/tesla_node"
		Archon.Mid = TeslaNode

		//========================================//-KITS-//========================================//
		ModdedPassiveData ChainReaction
		ChainReaction.Name = "#GEAR_ARCHON_CHAIN"
		ChainReaction.description = "#GEAR_ARCHON_CHAIN_DESC"
		ChainReaction.image = $"archon/menu/chain_reaction"
		ChainReaction.customIcon = true
		Archon.passive2Array.append(ChainReaction)

		ModdedPassiveData boltfromtheblue
		boltfromtheblue.Name = "#GEAR_ARCHON_SHIELD"
		boltfromtheblue.description = "#GEAR_ARCHON_SHIELD_DESC"
		boltfromtheblue.image = $"archon/menu/bolt_from_the_blue"
		boltfromtheblue.customIcon = true
		Archon.passive2Array.append(boltfromtheblue)

		ModdedPassiveData thylord
		thylord.Name = "#GEAR_ARCHON_THYLORD"
		thylord.description = "#GEAR_ARCHON_THYLORD_DESC"
		thylord.image =  $"archon/menu/thylord_module"
		thylord.customIcon = true
		Archon.passive2Array.append(thylord)

		ModdedPassiveData StaticFeedback
		StaticFeedback.Name = "#GEAR_ARCHON_FEEDBACK"
		StaticFeedback.description = "#GEAR_ARCHON_FEEDBACK_DESC"
		StaticFeedback.image =  $"archon/menu/static_feedback"
		StaticFeedback.customIcon = true
		Archon.passive2Array.append(StaticFeedback)

		ModdedPassiveData BringTheThunder
		BringTheThunder.Name = "#GEAR_ARCHON_SMOKE"
		BringTheThunder.description = "#GEAR_ARCHON_SMOKE_LONGDESC"
		BringTheThunder.image = $"archon/menu/bring_the_thunder"
		BringTheThunder.customIcon = true
		Archon.passive2Array.append(BringTheThunder)

		//========================================//-AEGIS RANKS-//========================================//
		ModdedPassiveData CriticalOverload
		CriticalOverload.Name = "#FD_UPGRADE_ARCHON_WEAPON_TIER_1"
		CriticalOverload.description = "#FD_UPGRADE_ARCHON_WEAPON_TIER_1_DESC"
		CriticalOverload.image = $"archon/hud/fd_critical_overload"
		CriticalOverload.customIcon = true
		Archon.passiveFDArray.append(CriticalOverload)

		ModdedPassiveData ChassisUpgrade
		ChassisUpgrade.Name = "#FD_UPGRADE_ARCHON_DEFENSE_TIER_1"
		ChassisUpgrade.description = "#FD_UPGRADE_ARCHON_DEFENSE_TIER_1_DESC"
		ChassisUpgrade.image = $"archon/hud/fd_archon_health_upgrade"
		ChassisUpgrade.customIcon = true
		Archon.passiveFDArray.append(ChassisUpgrade)

		ModdedPassiveData eyeOfTheStorm
		eyeOfTheStorm.Name = "#FD_UPGRADE_ARCHON_UTILITY_TIER_2"
		eyeOfTheStorm.description = "#FD_UPGRADE_ARCHON_UTILITY_TIER_2_DESC"
		eyeOfTheStorm.image = $"archon/hud/fd_eye_of_the_storm"
		eyeOfTheStorm.customIcon = true
		Archon.passiveFDArray.append(eyeOfTheStorm)

		ModdedPassiveData Terminator
		Terminator.Name = "#FD_UPGRADE_ARCHON_WEAPON_TIER_2"
		Terminator.description = "#FD_UPGRADE_ARCHON_WEAPON_TIER_2_DESC"
		Terminator.image = $"archon/hud/fd_terminator"
		Terminator.customIcon = true
		Archon.passiveFDArray.append(Terminator)

		ModdedPassiveData ShieldUpgrade
		ShieldUpgrade.Name = "#FD_UPGRADE_ARCHON_DEFENSE_TIER_2"
		ShieldUpgrade.description = "#FD_UPGRADE_ARCHON_DEFENSE_TIER_2_DESC"
		ShieldUpgrade.image = $"archon/hud/fd_archon_shield_upgrade"
		ShieldUpgrade.customIcon = true
		Archon.passiveFDArray.append(ShieldUpgrade)

		ModdedPassiveData ExtraCapacitor
		ExtraCapacitor.Name = "#FD_UPGRADE_ARCHON_UTILITY_TIER_1"
		ExtraCapacitor.description = "#FD_UPGRADE_ARCHON_UTILITY_TIER_1_DESC"
		ExtraCapacitor.image = $"archon/hud/fd_extra_capacitor"
		ExtraCapacitor.customIcon = true
		Archon.passiveFDArray.append(ExtraCapacitor)

		ModdedPassiveData RollingThunder
		RollingThunder.Name = "#FD_UPGRADE_ARCHON_ULTIMATE"
		RollingThunder.description = "#FD_UPGRADE_ARCHON_ULTIMATE_DESC"
		RollingThunder.image = $"archon/hud/fd_rolling_thunder"
		RollingThunder.customIcon = true
		Archon.passiveFDArray.append(RollingThunder)

		CreateModdedTitanSimple(Archon)
	#endif
}
