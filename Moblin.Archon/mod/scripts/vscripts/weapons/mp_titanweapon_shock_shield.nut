untyped

global function MpTitanweaponShockShield_Init

global function OnWeaponActivate_titanweapon_shock_shield
global function OnWeaponDeactivate_titanweapon_shock_shield
global function OnWeaponCustomActivityStart_titanweapon_shock_shield
global function OnWeaponVortexHitBullet_titanweapon_shock_shield
global function OnWeaponVortexHitProjectile_titanweapon_shock_shield
global function OnWeaponPrimaryAttack_titanweapon_shock_shield
global function OnWeaponChargeBegin_titanweapon_shock_shield
global function OnWeaponChargeEnd_titanweapon_shock_shield
global function OnWeaponAttemptOffhandSwitch_titanweapon_shock_shield
global function OnWeaponOwnerChanged_titanweapon_shock_shield

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_shock_shield
#endif // #if SERVER

#if CLIENT
global function OnClientAnimEvent_titanweapon_shock_shield
#endif // #if CLIENT

const ACTIVATION_COST_FRAC = 0.40
const SHOCK_ARM_EFFECT_FP = $"wpn_arc_cannon_electricity_fp"
const SHOCK_ARM_EFFECT = $"wpn_arc_cannon_electricity"
const SHOCK_HOLD_EFFECT_FP = $"arcTrap_CH_arcs_large"
const SHOCK_HOLD_EFFECT = $"arcTrap_CH_arcs_large"
const SHOCK_RELEASE_EFFECT_FP = $"P_wpn_muzzleflash_epg_FP"
const SHOCK_RELEASE_EFFECT = $"P_wpn_muzzleflash_epg"

const VortexIgnoreClassnames = {
	["mp_titancore_flame_wave"] = true,
	["mp_ability_grapple"] = true,
	["mp_ability_flame_wave"] = true,
	["mp_titancore_storm_core"] = true,
}


function MpTitanweaponShockShield_Init()
{
	PrecacheWeapon( "mp_titanweapon_shock_shield" )
	//PrecacheWeapon( "mp_titanweapon_shock_shield_archon" )
	PrecacheParticleSystem( SHOCK_HOLD_EFFECT )
	PrecacheParticleSystem( SHOCK_HOLD_EFFECT_FP )
	PrecacheParticleSystem( SHOCK_RELEASE_EFFECT )
	PrecacheParticleSystem( SHOCK_RELEASE_EFFECT_FP )
	ShockShieldPrecache()
	RegisterSignal( "DisableAmpedVortex" )
	RegisterSignal( "FireAmpedVortexBullet" )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_shock_shield, ShockShieldOnDamage )
	#endif


}

function ShockShieldPrecache()
{
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_titan_FP" )
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_titan_FP_replay" )
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_titan" )
	PrecacheParticleSystem( $"wpn_vortex_shield_impact_titan" )
	PrecacheParticleSystem( $"wpn_muzzleflash_vortex_titan_CP_FP" )

	PrecacheParticleSystem( $"wpn_vortex_chargingCP_mod_FP_arc" )
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_mod_FP_replay_arc" )
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_mod_arc" )
	PrecacheParticleSystem( $"wpn_vortex_shield_impact_mod_arc" )
	PrecacheParticleSystem( $"wpn_muzzleflash_vortex_mod_CP_FP_arc" )

	PrecacheParticleSystem( $"wpn_vortex_chargingCP_mod_FP_bftb" )
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_mod_FP_replay_bftb" )
	PrecacheParticleSystem( $"wpn_vortex_chargingCP_mod_bftb" )
	PrecacheParticleSystem( $"wpn_vortex_shield_impact_mod_bftb" )
	PrecacheParticleSystem( $"wpn_muzzleflash_vortex_mod_CP_FP_bftb" )


	PrecacheParticleSystem( $"P_impact_exp_emp_med_air" )


}

void function OnWeaponOwnerChanged_titanweapon_shock_shield( entity weapon, WeaponOwnerChangedParams changeParams )
{


	if ( !( "initialized" in weapon.s ) )
	{
		weapon.s.fxChargingFPControlPoint <- $"wpn_vortex_chargingCP_mod_FP_arc"
		weapon.s.fxChargingFPControlPointReplay <- $"wpn_vortex_chargingCP_mod_FP_replay_arc"
		weapon.s.fxChargingControlPoint <- $"wpn_vortex_chargingCP_mod_arc"
		weapon.s.fxBulletHit <- $"wpn_vortex_shield_impact_mod_arc"

		weapon.s.fxChargingFPControlPointBurn <- $"wpn_vortex_chargingCP_mod_FP_bftb"
		weapon.s.fxChargingFPControlPointReplayBurn <- $"wpn_vortex_chargingCP_mod_FP_replay_bftb"
		weapon.s.fxChargingControlPointBurn <- $"wpn_vortex_chargingCP_mod_bftb"
		weapon.s.fxBulletHitBurn <- $"wpn_vortex_shield_impact_mod_bftb"

		weapon.s.fxElectricalExplosion <- $"P_impact_exp_emp_med_air"

		weapon.s.lastFireTime <- 0
		weapon.s.hadChargeWhenFired <- false


		#if CLIENT
			weapon.s.lastUseTime <- 0
		#endif

		weapon.s.initialized <- true
	}
}

void function OnWeaponActivate_titanweapon_shock_shield( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	// just for NPCs (they don't do the deploy event)
	if ( !weaponOwner.IsPlayer() )
	{
		Assert( !( "isVortexing" in weaponOwner.s ), "NPC trying to vortex before cleaning up last vortex" )
		StartVortex( weapon )
	}

	#if SERVER
		thread AmpedVortexRefireThink( weapon )
	#endif
}

void function OnWeaponDeactivate_titanweapon_shock_shield( entity weapon )
{
	EndVortex( weapon )

	weapon.Signal( "DisableAmpedVortex" )
}

void function OnWeaponCustomActivityStart_titanweapon_shock_shield( entity weapon )
{
	EndVortex( weapon )
}

function StartVortex( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

#if CLIENT
	if ( weaponOwner != GetLocalViewPlayer() )
		return

	if ( IsFirstTimePredicted() )
		Rumble_Play( "rumble_titan_vortex_start", {} )
#endif

	Assert( IsAlive( weaponOwner ),  "ent trying to start vortexing after death: " + weaponOwner )

	if ( "shotgunPelletsToIgnore" in weapon.s )
		weapon.s.shotgunPelletsToIgnore = 0
	else
		weapon.s.shotgunPelletsToIgnore <- 0

	Vortex_SetBulletCollectionOffset( weapon, Vector( 110, -28, -22.0 ) )

	int sphereRadius = 150
	int bulletFOV = 120

	//ApplyActivationCost( weapon, ACTIVATION_COST_FRAC )

	if ( weapon.GetWeaponChargeFraction() < 1 )
	{
		weapon.s.hadChargeWhenFired = true
		CreateVortexSphere( weapon, false, false, sphereRadius, bulletFOV )
		EnableVortexSphere( weapon )
		weapon.EmitWeaponSound_1p3p( "vortex_shield_loop_1P", "vortex_shield_loop_3P" )
	}
	else
	{
		weapon.s.hadChargeWhenFired = false
		weapon.EmitWeaponSound_1p3p( "vortex_shield_empty_1P", "vortex_shield_empty_3P" )
	}

	#if SERVER
		thread ForceReleaseOnPlayerEject( weapon )
	#endif

	#if CLIENT
		weapon.s.lastUseTime = Time()
	#endif
}

function AmpedVortexRefireThink( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	weapon.EndSignal( "DisableAmpedVortex" )
	weapon.EndSignal( "OnDestroy" )
	weaponOwner.EndSignal( "OnDestroy" )

	for ( ;; )
	{
		weapon.WaitSignal( "FireAmpedVortexBullet" )

		if ( IsValid( weaponOwner )	)
		{
			ShotgunBlast( weapon, weaponOwner.EyePosition(), weaponOwner.GetPlayerOrNPCViewVector(), expect int( weapon.s.ampedBulletCount ), damageTypes.shotgun | DF_VORTEX_REFIRE )
			weapon.s.ampedBulletCount = 0
		}
	}
}

function ForceReleaseOnPlayerEject( entity weapon )
{
	weapon.EndSignal( "VortexFired" )
	weapon.EndSignal( "OnDestroy" )

	entity weaponOwner = weapon.GetWeaponOwner()
	if ( !IsAlive( weaponOwner ) )
		return

	weaponOwner.EndSignal( "OnDeath" )

	weaponOwner.WaitSignal( "TitanEjectionStarted" )

	weapon.ForceRelease()
}

function ApplyActivationCost( entity weapon, float frac )
{
	if ( weapon.HasMod( "vortex_extended_effect_and_no_use_penalty" ) )
		return

	float fracLeft = weapon.GetWeaponChargeFraction()

	if ( fracLeft + frac >= 1 )
	{
		#if SERVER
		weapon.ForceRelease()

		weapon.SetWeaponChargeFraction( 1.0 )
		#endif
	}
	else
	{
		#if SERVER
		weapon.SetWeaponChargeFraction( fracLeft + frac )
		#endif
	}
}

function EndVortex( entity weapon )
{
	#if CLIENT
		weapon.s.lastUseTime = Time()
	#endif
	weapon.StopWeaponSound( "vortex_shield_loop_1P" )
	weapon.StopWeaponSound( "vortex_shield_loop_3P" )
	weapon.StopWeaponEffect( SHOCK_HOLD_EFFECT_FP, SHOCK_HOLD_EFFECT )
	weapon.StopWeaponEffect( SHOCK_ARM_EFFECT_FP, SHOCK_ARM_EFFECT )
	DestroyVortexSphereFromVortexWeapon( weapon )
}

bool function OnWeaponVortexHitBullet_titanweapon_shock_shield( entity weapon, entity vortexSphere, var damageInfo )
{
	if ( weapon.HasMod( "shield_only" ) )
			return true

		#if CLIENT
			return true
		#else
			if ( !ValidateVortexImpact( vortexSphere ) )
				return false

			entity attacker				= DamageInfo_GetAttacker( damageInfo )
			vector origin				= DamageInfo_GetDamagePosition( damageInfo )
			int damageSourceID			= DamageInfo_GetDamageSourceIdentifier( damageInfo )
			entity attackerWeapon		= DamageInfo_GetWeapon( damageInfo )
			if ( PROTO_ATTurretsEnabled() && !IsValid( attackerWeapon ) )
				return true
			string attackerWeaponName	= attackerWeapon.GetWeaponClassName()
			int damageType				= DamageInfo_GetCustomDamageType( damageInfo )

			return TryVortexAbsorb( vortexSphere, attacker, origin, damageSourceID, attackerWeapon, attackerWeaponName, "hitscan", null, damageType, false )



		#endif
}

bool function OnWeaponVortexHitProjectile_titanweapon_shock_shield( entity weapon, entity vortexSphere, entity attacker, entity projectile, vector contactPos )
{
	if ( weapon.HasMod( "shield_only" ) )
		return true

	#if CLIENT
		return true
	#else
		if ( !ValidateVortexImpact( vortexSphere, projectile ) )
			return false

		int damageSourceID = projectile.ProjectileGetDamageSourceID()
		string weaponName = projectile.ProjectileGetWeaponClassName()

		return TryVortexAbsorb( vortexSphere, attacker, contactPos, damageSourceID, projectile, weaponName, "projectile", projectile, null, weapon.HasMod( "burn_mod_titan_vortex_shield" ) )
	#endif
}

var function OnWeaponPrimaryAttack_titanweapon_shock_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	string attackSound1p = "vortex_shield_end_1P"
	string attackSound3p = "vortex_shield_end_3P"

	attackSound1p = "Vortex_Shield_Deflect_Amped"
	attackSound3p = "Vortex_Shield_Deflect_Amped"

	weapon.EmitWeaponSound_1p3p( attackSound1p, attackSound3p )
	thread OnShieldDestroyed(weapon, attackParams)

	DestroyVortexSphereFromVortexWeapon( weapon )  // sphere ent holds networked ammo count, destroy it after predicted firing is done

	FadeOutSoundOnEntity( weapon, "vortex_shield_start_amped_1P", 0.15 )
	FadeOutSoundOnEntity( weapon, "vortex_shield_start_amped_3P", 0.15 )

	return true
}


#if SERVER
var function OnWeaponNpcPrimaryAttack_titanweapon_shock_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int bulletsFired = VortexPrimaryAttack( weapon, attackParams )

	DestroyVortexSphereFromVortexWeapon( weapon )  // sphere ent holds networked ammo count, destroy it after predicted firing is done

	return bulletsFired
}
#endif // #if SERVER

#if CLIENT
void function OnClientAnimEvent_titanweapon_shock_shield( entity weapon, string name )
{
	if ( name == "muzzle_flash" )
	{
		asset fpEffect = $"wpn_muzzleflash_vortex_mod_CP_FP_arc"

		int handle
		if ( GetLocalViewPlayer() == weapon.GetWeaponOwner() )
		{
			handle = weapon.PlayWeaponEffectReturnViewEffectHandle( fpEffect, $"", "vortex_center" )
		}
		else
		{
			handle = StartParticleEffectOnEntity( weapon, GetParticleSystemIndex( fpEffect ), FX_PATTACH_POINT_FOLLOW, weapon.LookupAttachment( "vortex_center" ) )
		}

		Assert( handle )
		// This Assert isn't valid because Effect might have been culled
		// Assert( EffectDoesExist( handle ), "vortex shield OnClientAnimEvent: Couldn't find viewmodel effect handle for vortex muzzle flash effect on client " + GetLocalViewPlayer() )

		vector colorVec = GetVortexSphereCurrentColor( weapon.GetWeaponChargeFraction() )
		EffectSetControlPointVector( handle, 1, colorVec )
	}
}
#endif

bool function OnWeaponChargeBegin_titanweapon_shock_shield( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	// just for players
	if ( weaponOwner.IsPlayer() )
	{
		PlayerUsedOffhand( weaponOwner, weapon )
		StartVortex( weapon )
	}

	weapon.PlayWeaponEffect( SHOCK_ARM_EFFECT_FP, SHOCK_ARM_EFFECT, "vortex_center")
	weapon.PlayWeaponEffect( SHOCK_HOLD_EFFECT_FP, SHOCK_HOLD_EFFECT, "vortex_center")
	weapon.PlayWeaponEffect( SHOCK_HOLD_EFFECT_FP, SHOCK_HOLD_EFFECT, "vortex_center")
	weapon.EmitWeaponSound("EMP_Titan_Electrical_Field")

	return true
}


void function OnWeaponChargeEnd_titanweapon_shock_shield( entity weapon )
{
	float activationCost = ACTIVATION_COST_FRAC

	if ( weapon.HasMod( "immobilizer_shield" ) )
	{
			activationCost = activationCost * 0.75
	}

	ApplyActivationCost( weapon, activationCost )

	entity weaponOwner = weapon.GetWeaponOwner()
	weapon.StopWeaponEffect( SHOCK_HOLD_EFFECT_FP, SHOCK_HOLD_EFFECT )
	weapon.StopWeaponEffect( SHOCK_ARM_EFFECT_FP, SHOCK_ARM_EFFECT )
	weapon.StopWeaponSound("EMP_Titan_Electrical_Field")

}

bool function OnWeaponAttemptOffhandSwitch_titanweapon_shock_shield( entity weapon )
{

	bool allowSwitch
	entity weaponOwner = weapon.GetWeaponOwner()
	entity soul = weaponOwner.GetTitanSoul()
	Assert( IsValid( soul ) )
	entity activeWeapon = weaponOwner.GetActiveWeapon()

	float activationCost = ACTIVATION_COST_FRAC

	if ( weapon.HasMod( "immobilizer_shield" ) )
	{
			activationCost = activationCost * 0.75
	}

	allowSwitch = weapon.GetWeaponChargeFraction() <= 1 - activationCost

	return allowSwitch
}

function OnShieldDestroyed(entity weapon, WeaponPrimaryAttackParams attackParams)
{
	entity player = weapon.GetWeaponOwner()
	FireArchonCannon( weapon, attackParams )

	weapon.PlayWeaponEffect( SHOCK_RELEASE_EFFECT_FP, SHOCK_RELEASE_EFFECT, "vortex_center")
	weapon.StopWeaponSound( "vortex_shield_loop_1P" )
	weapon.StopWeaponSound( "vortex_shield_loop_3P" )
	weapon.StopWeaponEffect( SHOCK_HOLD_EFFECT_FP, SHOCK_HOLD_EFFECT )
	weapon.StopWeaponEffect( SHOCK_ARM_EFFECT_FP, SHOCK_ARM_EFFECT )
}

void function ShockShieldOnDamage( entity ent, var damageInfo )
{
	vector pos = DamageInfo_GetDamagePosition( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	vector origin = DamageInfo_GetDamagePosition( damageInfo )

	if ( ent.IsPlayer() || ent.IsNPC() )
	{
		entity entToSlow = ent
		entity soul = ent.GetTitanSoul()

		if ( soul != null )
			entToSlow = soul

		const ARC_TITAN_EMP_DURATION			= 0.35
		const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35


		StatusEffect_AddTimed( entToSlow, eStatusEffect.move_slow, 0.5, 1.0, 1.0 )
		StatusEffect_AddTimed( entToSlow, eStatusEffect.dodge_speed_slow, 0.5, 1.0, 1.0 )
		StatusEffect_AddTimed( ent, eStatusEffect.emp, 1.0, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION )
	}

	if ( false )//ent.IsPlayer() || ent.IsNPC() )
	{
		entity entToSlow = ent
		entity soul = ent.GetTitanSoul()

		if ( soul != null )
			entToSlow = soul

		entity weapon = attacker.GetOffhandWeapon(OFFHAND_SPECIAL)

		if (!IsValid(entToSlow))
			return
		StatusEffect_AddTimed( entToSlow, eStatusEffect.move_slow, 0.5, 1.0, 1.0 )
		StatusEffect_AddTimed( entToSlow, eStatusEffect.dodge_speed_slow, 0.5, 1.0, 1.0 )

		const ARC_TITAN_EMP_DURATION			= 0.35
		const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35

		StatusEffect_AddTimed( entToSlow, eStatusEffect.emp, 0.25, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION )


		//print("ENEMY: " + ent)
		//print("USER: " + attacker)




	}
}
