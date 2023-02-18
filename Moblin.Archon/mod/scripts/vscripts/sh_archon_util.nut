untyped

//global function GiveArchon
global function ArchonPrecache

#if SERVER
global function DamageShieldsInRadiusOnEntity
#endif

const float TERMINATOR_EFFECT_LENGTH = 15.0

void function ArchonPrecache()
{
	#if SERVER
	RegisterWeaponDamageSources(
		{
			mp_titanweapon_tesla_node = "#WPN_TITAN_ARC_PYLON",
			mp_titanweapon_charge_ball = "#WPN_TITAN_CHARGE_BALL",
			mp_titanweapon_shock_shield = "#WPN_TITAN_SHOCK_SHIELD",
			mp_titancore_storm_core = "#TITANCORE_STORM"
		}
	)
	#endif
	RegisterSignal("StopTerminator")
	ArchonArcCannon_Init()
	ShockShield_Init()
	ChargeBall_Init()
	TeslaNode_Init()
	StormCore_Init()
	Archon_Loadout_Util()
	#if SERVER
        GameModeRulesRegisterTimerCreditException( eDamageSourceId.mp_titancore_storm_core )
				AddDeathCallback( "npc_titan", OnTitanTerminated )
				AddDeathCallback( "player", OnTitanTerminated )
	#endif
}

#if SERVER
array<entity> function DamageShieldsInRadiusOnEntity( entity weapon, entity inflictor, float radius, float damage )
{
	array<entity> damagedEnts = [] // used so that we only damage a shield once per function call
	array<string> shieldClasses = [ "mp_titanweapon_vortex_shield", "mp_titanweapon_shock_shield", "mp_titanweapon_heat_shield", "mp_titanability_brute4_bubble_shield" ] // add shields that are like vortex shield/heat shield to this, they seem to be exceptions?

	// not ideal
	foreach ( entity shield in GetEntArrayByClass_Expensive( "vortex_sphere" ) )
	{
		VortexBulletHit ornull vortexHit = VortexBulletHitCheck( weapon.GetWeaponOwner(), inflictor.GetOrigin(), shield.GetCenter() )
		if ( vortexHit )
		{
			expect VortexBulletHit( vortexHit )

			if ( damagedEnts.contains( vortexHit.vortex ) )
				continue
			if ( Distance( inflictor.GetCenter(), vortexHit.vortex.GetCenter() ) > radius )
				continue

			entity vortexWeapon = vortexHit.vortex.GetOwnerWeapon()

			if ( vortexWeapon && shieldClasses.contains( vortexWeapon.GetWeaponClassName() ) )
				VortexDrainedByImpact( vortexWeapon, weapon, inflictor, null ) // drain the vortex shield
			else if ( IsVortexSphere( vortexHit.vortex ) )
				VortexSphereDrainHealthForDamage( vortexHit.vortex, damage )

			damagedEnts.append( vortexHit.vortex )

		}
	}

	foreach ( entity npc in GetNPCArrayOfEnemies( weapon.GetWeaponOwner().GetTeam() ) )
	{
		VortexBulletHit ornull vortexHit = VortexBulletHitCheck( weapon.GetWeaponOwner(), inflictor.GetOrigin(), npc.GetCenter() )
		if ( vortexHit )
		{
			expect VortexBulletHit( vortexHit )

			if ( damagedEnts.contains( vortexHit.vortex ) )
				continue
			if ( Distance( inflictor.GetCenter(), vortexHit.vortex.GetCenter() ) > radius )
				continue

			entity vortexWeapon = vortexHit.vortex.GetOwnerWeapon()

			if ( vortexWeapon && shieldClasses.contains( vortexWeapon.GetWeaponClassName() ) )
				VortexDrainedByImpact( vortexWeapon, weapon, inflictor, null ) // drain the vortex shield
			else if ( IsVortexSphere( vortexHit.vortex ) )
				VortexSphereDrainHealthForDamage( vortexHit.vortex, damage )

			damagedEnts.append( vortexHit.vortex )

		}
	}

	foreach ( entity player in GetPlayerArray() )
	{
		if (player.GetTeam() == weapon.GetWeaponOwner().GetTeam())
			continue

		VortexBulletHit ornull vortexHit = VortexBulletHitCheck( weapon.GetWeaponOwner(), inflictor.GetOrigin(), player.GetCenter() )
		if ( vortexHit )
		{
			expect VortexBulletHit( vortexHit )

			if ( damagedEnts.contains( vortexHit.vortex ) )
				continue
			if ( Distance( inflictor.GetCenter(), vortexHit.vortex.GetCenter() ) > radius )
				continue

			entity vortexWeapon = vortexHit.vortex.GetOwnerWeapon()

			if ( vortexWeapon && shieldClasses.contains( vortexWeapon.GetWeaponClassName() ) )
				VortexDrainedByImpact( vortexWeapon, weapon, inflictor, null ) // drain the vortex shield
			else if ( IsVortexSphere( vortexHit.vortex ) )
				VortexSphereDrainHealthForDamage( vortexHit.vortex, damage )

			damagedEnts.append( vortexHit.vortex )

		}
	}

	return damagedEnts // returning an array of the things you damaged with a RadiusDamage-esque function?? crazy
}
#endif

#if SERVER
void function OnTitanTerminated( entity ent, var damageInfo )
{
	vector pos = DamageInfo_GetDamagePosition( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if(DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.titan_execution)
	{
		if ( IsValid( attacker ) )
		{
			if(!attacker.IsTitan())
				return
			entity weapon = attacker.GetActiveWeapon()
			if (weapon.HasMod( "fd_terminator" ))
			{
				attacker.Signal("StopTerminator")
				thread PlayerGotTerminator( attacker )
			}
		}
	}
}
#endif

void function PlayerGotTerminator( entity player )
{
	player.EndSignal("StopTerminator")

	entity ChargeBall = player.GetOffhandWeapon( OFFHAND_RIGHT )
	entity ShockShield = player.GetOffhandWeapon( OFFHAND_SPECIAL )

	array<entity> weapons = player.GetMainWeapons()
	weapons.append( ChargeBall )
	weapons.append( ShockShield )
	foreach ( entity weapon in weapons )
	{
		foreach ( string mod in GetWeaponBurnMods( weapon.GetWeaponClassName() ) )
		{
			// catch incompatibilities just in case
			try
			{
				weapon.AddMod( mod )
			}
			catch( ex )
			{
				weapons.removebyvalue( weapon )
			}
		}

		// needed to display amped weapon time left
		weapon.SetScriptFlags0( weapon.GetScriptFlags0() | WEAPONFLAG_AMPED )
		weapon.SetScriptTime0( Time() + TERMINATOR_EFFECT_LENGTH )
		print("Flags "+ weapon.GetScriptFlags0())
	}

	wait TERMINATOR_EFFECT_LENGTH

	// note: weapons may have been destroyed or picked up by other people by this point, so need to verify this
	foreach ( entity weapon in weapons )
	{
		if ( !IsValid( weapon ) )
			continue

		foreach ( string mod in GetWeaponBurnMods( weapon.GetWeaponClassName() ) )
			weapon.RemoveMod( mod )

		weapon.SetScriptFlags0( weapon.GetScriptFlags0() & ~WEAPONFLAG_AMPED )
	}
}
