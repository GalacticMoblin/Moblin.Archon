global function ArchonUIInit
void function ArchonUIInit()
{
	#if ARCHON_HAS_TITANFRAMEWORK
		ModdedTitanData Archon
		Archon.Name = "#DEFAULT_TITAN_1"
		Archon.Description = "#MP_TITAN_LOADOUT_DESC_ARCHON"
		Archon.BaseSetFile = "titan_atlas_stickybomb"
		Archon.BaseName = "ion"
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

		ModdedTitanWeaponAbilityData ArcCannon
		ArcCannon.custom = true //when this is false titanframework will not create items, useful if you want to use default items
		ArcCannon.displayName = "#WPN_TITAN_ARC_CANNON"
		ArcCannon.weaponName = "mp_titanweapon_arc_cannon"
		ArcCannon.description = "#WPN_TITAN_ARC_CANNON_LONGDESC"
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
		StormCore.image = $"archon/menu/storm_core"
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
		TeslaNode.displayName = "#WPN_TITAN_ARC_PYLON"
		TeslaNode.weaponName = "mp_titanweapon_tesla_node"
		TeslaNode.description = "#WPN_TITAN_ARC_PYLON_DESC"
		TeslaNode.image = $"archon/menu/arc_pylon"
		Archon.Mid = TeslaNode



		/*
		======IMPORTANT======
		titanFramework uses persitence masking to map real passives in persistent data to the "fake" ones created here
		this means the number of custom passives in a slot cannot exceed the number of default passives that exist
		I err, dont know what will happen if you do this. Probably an index error
		*/
		ModdedPassiveData ChainReaction //Define a new passive to equip the predator cannon
		ChainReaction.Name = "#GEAR_ARCHON_CHAIN"
		ChainReaction.description = "#GEAR_ARCHON_CHAIN_DESC"
		ChainReaction.image = $"archon/menu/chain_reaction"
		ChainReaction.customIcon = true
		Archon.passive2Array.append(ChainReaction) //If nothing is registered in passive2 it will
		//display the defaults passivesfor the base titan(vanguard in this case))

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


		CreateModdedTitanSimple(Archon)//Ah yes """"""""""""Simple""""""""""""
	#endif
}
