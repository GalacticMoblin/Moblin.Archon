global function Archon_Loadout_Util

void function Archon_Loadout_Util()
{
  #if SERVER
		AddCallback_OnTitanGetsNewTitanLoadout( SetTitanLoadout );
  #endif
}

//==================================================//Apply loadout//==================================================//

void function SetTitanLoadout( entity titan, TitanLoadoutDef loadout  )
{
	#if SERVER
	if(loadout.titanClass == "#DEFAULT_TITAN_1")
	{
		entity player = GetPetTitanOwner( titan )
		entity soul = titan.GetTitanSoul()

		if (!(IsValid( soul )))
			return

//==================================================//KITS//==================================================//

		if(SoulHasPassive( soul, ePassives["#GEAR_ARCHON_CHAIN"] ) )
		{
			titan.GetMainWeapons()[0].SetMods(["chain_reaction"])
        }
		if(SoulHasPassive( soul, ePassives["#GEAR_ARCHON_FEEDBACK"] ) )
		{
			titan.GetMainWeapons()[0].SetMods(["static_feedback"])
        }
        if(SoulHasPassive( soul, ePassives["#GEAR_ARCHON_SMOKE"] ) )
		{
			titan.GetOffhandWeapon(OFFHAND_EQUIPMENT).SetMods(["bring_the_thunder"])
        }
        if(SoulHasPassive( soul, ePassives["#GEAR_ARCHON_THYLORD"] ) )
		{
			titan.GetOffhandWeapon(OFFHAND_RIGHT).SetMods(["thylord_module"])
        }
		if(SoulHasPassive( soul, ePassives["#GEAR_ARCHON_SHIELD"] ) )
		{
			titan.GetOffhandWeapon(OFFHAND_SPECIAL).SetMods(["bolt_from_the_blue"])
        }

//==================================================//AEGIS RANKS//==================================================//

		if(GetCurrentPlaylistVarInt("aegis_upgrades", 0) == 1)
		{

			//Rank 1: Enhanced Shocking
			entity weapon = titan.GetOffhandWeapon(OFFHAND_SPECIAL)
			array<string> mods = weapon.GetMods()
			mods.append( "fd_enhanced_shocking" )
			weapon.SetMods( mods )

			//Rank 3: Critical Overload
			array<entity> weapons = titan.GetMainWeapons()
			weapon = weapons[0]
			mods = weapon.GetMods()
			mods.append( "fd_crit_multiplier" )
			weapon.SetMods( mods )

			//Rank 4: Eye of the Storm
			weapon = titan.GetOffhandWeapon(OFFHAND_SPECIAL)
			mods = weapon.GetMods()
			mods.append( "fd_eye_of_the_storm" )
			weapon.SetMods( mods )

			//Rank 6: Terminator
			weapons = titan.GetMainWeapons()
			weapon = weapons[0]
			mods = weapon.GetMods()
			mods.append( "fd_terminator" )
			weapon.SetMods( mods )

			//Rank 7: Extra Capacitor
			weapon = titan.GetOffhandWeapon(OFFHAND_RIGHT)
			mods = weapon.GetMods()
			mods.append( "fd_extra_capacitor" )
			weapon.SetMods( mods )
			weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponSettingInt( eWeaponVar.ammo_default_total ) )
		}
	}
	#endif
}
