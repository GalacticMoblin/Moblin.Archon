global function Archon_Loadout_Util

void function Archon_Loadout_Util()
{
  #if SERVER
		AddCallback_OnTitanGetsNewTitanLoadout( SetArchonTitanLoadout );
  #endif
}

//==================================================//Apply loadout//==================================================//

void function SetArchonTitanLoadout( entity titan, TitanLoadoutDef loadout  )
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
			//Rank 1: Critical Overload
			array<entity> weapons = titan.GetMainWeapons()
			entity weapon = weapons[0]
			array<string> mods = weapon.GetMods()
			mods.append( "fd_crit_multiplier" )
			weapon.SetMods( mods )

			//Rank 2: Chassis Upgrade
			loadout.setFileMods.append( "fd_health_upgrade" )

			//Rank 3: Eye of the Storm
			weapon = titan.GetOffhandWeapon(OFFHAND_SPECIAL)
			mods = weapon.GetMods()
			mods.append( "fd_eye_of_the_storm" )
			weapon.SetMods( mods )

			//Rank 4: Terminator
			weapons = titan.GetMainWeapons()
			weapon = weapons[0]
			mods = weapon.GetMods()
			mods.append( "fd_terminator" )
			weapon.SetMods( mods )

			weapon = titan.GetOffhandWeapon(OFFHAND_RIGHT)
			mods = weapon.GetMods()
			mods.append( "fd_terminator" )
			weapon.SetMods( mods )

			weapon = titan.GetOffhandWeapon(OFFHAND_ANTIRODEO)
			mods = weapon.GetMods()
			mods.append( "fd_terminator" )
			weapon.SetMods( mods )

			weapon = titan.GetOffhandWeapon(OFFHAND_SPECIAL)
			mods = weapon.GetMods()
			mods.append( "fd_terminator" )
			weapon.SetMods( mods )

			//Rank 5: Shield Upgrade
			float titanShieldHealth = GetTitanSoulShieldHealth( soul )
			soul.SetShieldHealthMax( int( titanShieldHealth * 1.5 ) )

			//Rank 6: Extra Capacitor
			weapon = titan.GetOffhandWeapon(OFFHAND_RIGHT)
			mods = weapon.GetMods()
			mods.append( "fd_extra_capacitor" )
			weapon.SetMods( mods )
			weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponSettingInt( eWeaponVar.ammo_default_total ) )

			//Rank 7: Rolling Thunder
			weapon = titan.GetOffhandWeapon(OFFHAND_EQUIPMENT)
			mods = weapon.GetMods()
			mods.append( "fd_rolling_thunder" )
			weapon.SetMods( mods )

			//FD Balance
			weapon = titan.GetOffhandWeapon(OFFHAND_RIGHT)
			mods = weapon.GetMods()
			mods.append( "fd_balance" )
			weapon.SetMods( mods )
		}
	}
	#endif
}
