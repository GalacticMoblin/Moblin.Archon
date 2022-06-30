global function PrimeTitanPlus_Init

struct {
	array<entity> reminded // Used to only give players the HUD message on the first drop per match
} file

void function PrimeTitanPlus_Init()
{
  #if SERVER
		AddSpawnCallback("npc_titan", SetTitanLoadout );
  #endif
}


//Apply loadout

void function SetTitanLoadout( entity titan )
{
	#if SERVER
	if (IsValid( titan )) //Anti Crash
	{
		entity player = GetPetTitanOwner( titan )
		entity soul = titan.GetTitanSoul()

		if (IsValid( soul ) && IsValid( player )) //Anti Crash 2

		{
			array<entity> weapons = titan.GetMainWeapons()

 			//Archon
			if (titan.GetModelName() == $"models/titans/medium/titan_medium_ion_prime.mdl")
			{
				entity player = GetPetTitanOwner( titan )
				if ( IsValid( player ) && !file.reminded.contains( player ) )
				{
					SendHudMessage( player, "Archon Loadout Applied\n To use regular loadout, unequip prime titan skin.",  -1, 0.7, 200, 200, 225, 255, 0.15, 6, 1 )
					file.reminded.append( player )
				}

        //entity weapon5 = titan.GetOffhandWeapon( OFFHAND_SPECIAL )

				//Defence
        if(SoulHasPassive( soul, ePassives.PAS_ION_TRIPWIRE )){
          titan.TakeOffhandWeapon(OFFHAND_SPECIAL)
          titan.GiveOffhandWeapon("mp_titanweapon_shock_shield", OFFHAND_SPECIAL, ["immobilizer_shield"] )
        }
        else{
          titan.TakeOffhandWeapon(OFFHAND_SPECIAL)
          titan.GiveOffhandWeapon("mp_titanweapon_shock_shield", OFFHAND_SPECIAL )
        }

        //Offence
        /*if(SoulHasPassive( soul, ePassives.PAS_ION_LASERCANNON )){
          titan.TakeOffhandWeapon(OFFHAND_ANTIRODEO)
          titan.GiveOffhandWeapon("mp_titanweapon_tesla_node", OFFHAND_ANTIRODEO, ["dual_nodes"] )
        }
        else{*/
          titan.TakeOffhandWeapon(OFFHAND_ANTIRODEO)
          titan.GiveOffhandWeapon("mp_titanweapon_tesla_node", OFFHAND_ANTIRODEO )
        //}

				//Tactical
        if ( SoulHasPassive( soul, ePassives.PAS_ION_VORTEX ) ){
          titan.TakeOffhandWeapon(OFFHAND_RIGHT)
          titan.GiveOffhandWeapon("mp_titanweapon_charge_ball", OFFHAND_RIGHT, ["thylord_module"] )
        }
        else{
          titan.TakeOffhandWeapon(OFFHAND_RIGHT)
          titan.GiveOffhandWeapon("mp_titanweapon_charge_ball", OFFHAND_RIGHT )
        }

				//Weapon
				if(SoulHasPassive( soul, ePassives.PAS_ION_WEAPON )){
					titan.TakeWeaponNow( weapons[0].GetWeaponClassName() )
					titan.GiveWeapon ("mp_titanweapon_arc_cannon", ["chain_reaction"])
        }
				else if(SoulHasPassive( soul, ePassives.PAS_ION_LASERCANNON )){
					titan.TakeWeaponNow( weapons[0].GetWeaponClassName() )
					titan.GiveWeapon ("mp_titanweapon_arc_cannon", ["generator_mod"])
				}
        else{
					titan.TakeWeaponNow( weapons[0].GetWeaponClassName() )
					titan.GiveWeapon ("mp_titanweapon_arc_cannon")
				}

				//Titan Core
				if(SoulHasPassive( soul, ePassives.PAS_ION_WEAPON_ADS )){
          titan.TakeOffhandWeapon(OFFHAND_EQUIPMENT)
          titan.GiveOffhandWeapon( "mp_titancore_storm_core", OFFHAND_EQUIPMENT, ["bring_the_thunder"] )
        }
        else{
          titan.TakeOffhandWeapon(OFFHAND_EQUIPMENT)
          titan.GiveOffhandWeapon( "mp_titancore_storm_core", OFFHAND_EQUIPMENT )
        }

				//pas_ion_weapon_ads

			}
		}
	}
	#endif
}
