global function ArchonUIInit
global function ArchonUIInitP2
void function ArchonUIInit(){
	RegisterNewItemInitCallback(ArchonUIInitP2)
	RegisterModdedTitan("Archon", "mp_titanweapon_arc_cannon",
	"mp_titanweapon_shock_shield", "mp_titanweapon_tesla_node",
	"mp_titanweapon_charge_ball", "mp_titancore_storm_core",
	"titan_atlas_stickybomb", "ion", 3, "TITAN_ION_PASSIVE",
	eItemTypes.TITAN_SCORCH_EXECUTION //[
		//["pp_pas_highcaptanks", "Why does the pain not stop", "I am in pain", "So much pain", $"rui/titan_loadout/tactical/titan_tactical_rearm_menu"],
	//["pp_pas_enhancedacid", "Enhanced nanofoundries", "I am in pain", "So much pain", $"rui/titan_loadout/tactical/titan_tactical_rearm_menu"],
	//["pp_pas_stickyacid", "Adhesive compound", "I am in pain", "So much pain", $"rui/titan_loadout/tactical/titan_tactical_rearm_menu"],
	//[ "pp_pas_radaracid", "Hijack comms", "I am in pain", "So much pain", $"rui/titan_loadout/tactical/titan_tactical_rearm_menu"]]
	)
	#if MP
	ArchonUIInitP2()
	#endif
}
void function ArchonUIInitP2(){
	//print("/////////GENERATING ITEMS FOR ARCHON")
	CreateGenericItem(999, eItemTypes.TITAN_ANTIRODEO, "mp_titanweapon_tesla_node", "Tesla node", "I am in pain", "Deploys a tesla node, dealing electrical damage to anything that gets too close", $"rui/titan_loadout/tactical/titan_tactical_rearm_menu", 0, false)
	CreateGenericItem(999, eItemTypes.TITAN_PRIMARY, "mp_titanweapon_arc_cannon", "Arc cannon", "The pain does not stop", "Charge and release a devastating burst of energy", $"ui/temp", 0, false)
	CreateGenericItem(999, eItemTypes.TITAN_CORE_ABILITY, "mp_titancore_storm_core", "Storm core", "AAAAAAAA", "Electricity go brrrrr", $"rui/titan_loadout/core/titan_core_flame_wave", 0, false)
	CreateGenericItem(999, eItemTypes.TITAN_ORDNANCE, "mp_titanweapon_shock_shield", "Shock shield", "Using static forces or some science shit stop bullets", "Using static forces or some science shit stop bullets", $"ui/temp", 0, false)
	CreateGenericItem(999, eItemTypes.TITAN_SPECIAL, "mp_titanweapon_charge_ball", "Charge ball", "Using static forces or some science shit stop bullets", "Ayo that ball do be kinda charged tho", $"ui/temp", 0, false)

	RegisterModdedTitanItems("Archon", "mp_titanweapon_arc_cannon",
	"mp_titanweapon_shock_shield", "mp_titanweapon_tesla_node",
	"mp_titanweapon_charge_ball", "mp_titancore_storm_core",
	"titan_atlas_stickybomb", "ion", 3, "TITAN_ION_PASSIVE",
	eItemTypes.TITAN_SCORCH_EXECUTION// [
	//	["pp_pas_highcaptanks", "Why does the pain not stop", "I am in pain", "So much pain", $"rui/titan_loadout/tactical/titan_tactical_rearm_menu"],
	//["pp_pas_enhancedacid", "Enhanced nanofoundries", "I am in pain", "So much pain", $"rui/titan_loadout/tactical/titan_tactical_rearm_menu"],
	//["pp_pas_stickyacid", "Adhesive compound", "I am in pain", "So much pain", $"rui/titan_loadout/tactical/titan_tactical_rearm_menu"],
	//[ "pp_pas_radaracid", "Hijack comms", "I am in pain", "So much pain", $"rui/titan_loadout/tactical/titan_tactical_rearm_menu"]]
	)
}
