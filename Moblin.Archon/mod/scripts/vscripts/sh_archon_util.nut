untyped

//global function GiveArchon
global function ArchonPrecache
global function ArchonNetworkVars
global function UpdateArchonTerminatorMeter

#if SERVER
global function DamageShieldsInRadiusOnEntity
global function ConeDamageTethersException
#endif

const float TERMINATOR_EFFECT_LENGTH = 20.0
const int FD_TERMINATOR_DAMAGE_MAX = 7500

struct
{
	var archonTerminatorRui
} file

void function ArchonPrecache()
{
	#if SERVER
	RegisterWeaponDamageSources(
		{
			mp_titanweapon_archon_arc_cannon = "#WPN_TITAN_ARCHON_ARC_CANNON",
			mp_titanweapon_tesla_node = "#WPN_TITAN_TESLA_NODE",
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
				AddCallback_OnPilotBecomesTitan( OnArchonChange )
				AddCallback_OnTitanBecomesPilot( OnArchonChange )
	#endif
	#if CLIENT
		AddTitanCockpitManagedRUI( Archon_CreateTerminatorBar, Archon_DestroyTerminatorBar, Archon_ShouldCreateTerminatorBar, RUI_DRAW_COCKPIT ) //RUI_DRAW_HUD
	#endif
}

/*#if UI
void function ArchonBriefingVideo()
{
	AddTitanBriefingMilesAudio( "meet_#DEFAULT_TITAN_1", "Titan_Video_Ion" )
}
#endif*/

#if SERVER
void function OnArchonChange( entity pilot, entity npc_titan )
{
	if( npc_titan.ai.titanSpawnLoadout.name == "#DEFAULT_TITAN_1" )
	{
		pilot.SetPlayerNetFloat( "coreMeterModifier", 0 )
		pilot.Signal("StopTerminator")

		//Gotta make this a seperate function at some point
		entity ChargeBall = npc_titan.GetOffhandWeapon( OFFHAND_RIGHT )
		entity ShockShield = npc_titan.GetOffhandWeapon( OFFHAND_SPECIAL )

		array<entity> weapons = npc_titan.GetMainWeapons()
		weapons.append( ChargeBall )
		weapons.append( ShockShield )

		RemoveTerminator( pilot, weapons )
	}
}
#endif

void function ArchonNetworkVars()
{
	//AddCallback_OnRegisteringCustomNetworkVars( RegisterArchonNetworkVars )
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
	}

	wait TERMINATOR_EFFECT_LENGTH

	// note: weapons may have been destroyed or picked up by other people by this point, so need to verify this
	RemoveTerminator( player, weapons )
}

void function RemoveTerminator( entity pilot, array<entity> weapons )
{
	foreach ( entity weapon in weapons )
	{
		if ( !IsValid( weapon ) )
			continue

		foreach ( string mod in GetWeaponBurnMods( weapon.GetWeaponClassName() ) )
			weapon.RemoveMod( mod )
			pilot.SetPlayerNetFloat( "coreMeterModifier", 0.0)

		weapon.SetScriptFlags0( weapon.GetScriptFlags0() & ~WEAPONFLAG_AMPED )
	}
}

void function RegisterArchonNetworkVars()
{
	if (!IsLobby())
	{
		RegisterNetworkedVariable( "coreMeterModifier", SNDC_PLAYER_GLOBAL, SNVT_FLOAT_RANGE_OVER_TIME, 0.0, 0.0, 1.0 )
	}
}

#if CLIENT
var function Archon_CreateTerminatorBar()
{
	Assert( file.archonTerminatorRui == null )

	file.archonTerminatorRui = CreateFixedTitanCockpitRui( $"ui/scorch_hotstreak_bar.rpak" )

	RuiTrackFloat( file.archonTerminatorRui, "coreMeterMultiplier", GetLocalViewPlayer(), RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "coreMeterModifier" ) )

	return file.archonTerminatorRui
}

void function Archon_DestroyTerminatorBar()
{
	TitanCockpitDestroyRui( file.archonTerminatorRui )
	file.archonTerminatorRui = null
}

bool function Archon_ShouldCreateTerminatorBar()
{
	entity player = GetLocalViewPlayer()

	if ( !IsAlive( player ) )
		return false

	array<entity> mainWeapons = player.GetMainWeapons()
	if ( mainWeapons.len() == 0 )
		return false

	entity primaryWeapon = mainWeapons[0]
	return primaryWeapon.HasMod( "fd_terminator" )
}
#endif

void function UpdateArchonTerminatorMeter( entity attacker, float damage )
{
	if ( !attacker.IsPlayer() )
		return

	if(!attacker.GetMainWeapons()[0].HasMod("burn_mod_fd_terminator_active")){
		float baseValue = attacker.GetPlayerNetFloat( "coreMeterModifier" )
		float newValue = damage / FD_TERMINATOR_DAMAGE_MAX * 0.5
		float combinedValue = baseValue + newValue
		if ( baseValue + newValue >= 0.5 )
			combinedValue = 1.0

		attacker.SetPlayerNetFloat( "coreMeterModifier", combinedValue )
	}

	if(attacker.GetPlayerNetFloat( "coreMeterModifier" ) >= 1.0 && !attacker.GetMainWeapons()[0].HasMod("burn_mod_fd_terminator_active"))
		thread PlayerGotTerminator( attacker )
}

#if SERVER
void function ConeDamageTethersException( entity ent, var damageInfo )
{
	int attackerDamageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )

	if ( attackerDamageSourceID == eDamageSourceId.mp_weapon_shotgun )
		DamageInfo_SetDamage( damageInfo, 0 )
}
#endif
