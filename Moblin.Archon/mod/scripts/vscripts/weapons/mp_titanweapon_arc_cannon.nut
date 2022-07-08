untyped

global function MpTitanweaponArcCannonArchon_Init

global function OnWeaponActivate_titanweapon_arc_cannon_archon
global function OnWeaponDeactivate_titanweapon_arc_cannon_archon
global function OnWeaponReload_titanweapon_arc_cannon_archon
global function OnWeaponOwnerChanged_titanweapon_arc_cannon_archon
global function OnWeaponChargeBegin_titanweapon_arc_cannon_archon
global function OnWeaponChargeEnd_titanweapon_arc_cannon_archon
global function OnWeaponPrimaryAttack_titanweapon_arc_cannon_archon

global function UpdateWeaponChargeTracker

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_arc_cannon_archon
#endif // #if SERVER

const FX_EMP_BODY_HUMAN			= $"P_emp_body_human"
const FX_EMP_BODY_TITAN			= $"P_emp_body_titan"

const BASE_ENERGY_GAIN = 25
const CRIT_COUNT_MULTIPLIER_ENERGY_GAIN = 5
const BONUS_ENERGY_GAIN = 75
#if SERVER
struct{
	int critShots = 0
	bool isCharging = false
	float weaponCharge = 0.0

}weaponData
#endif

void function MpTitanweaponArcCannonArchon_Init()
{
	PrecacheWeapon( "mp_titanweapon_arc_cannon" )
	ArchonCannon_PrecacheFX()

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_arc_cannon, ArcCannonOnDamage )
	#endif

	RegisterWeaponDamageSourceName( "mp_titanweapon_arc_cannon", "Arc Cannon" )
}

void function UpdateWeaponChargeTracker(entity weapon)
{
#if SERVER
	wait 0.01

	entity player = weapon.GetWeaponOwner()

	while(weaponData.isCharging == true)
	{
		WaitFrame()

		if(IsAlive(player))
		{
			float chargeFrac = player.GetActiveWeapon().GetWeaponChargeFraction()

			//print(mainWeapon.GetWeaponChargeFraction())

			if(chargeFrac > 0)
			{
				weaponData.weaponCharge = chargeFrac
			}
			else
				weaponData.isCharging = false
		}

	}
	#endif
}


void function OnWeaponActivate_titanweapon_arc_cannon_archon( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	thread DelayedArcCannonStart( weapon, weaponOwner )
	if( !("weaponOwner" in weapon.s) )
		weapon.s.weaponOwner <- weaponOwner
}

function DelayedArcCannonStart( entity weapon, entity weaponOwner )
{
	weapon.EndSignal( "WeaponDeactivateEvent" )

	WaitFrame()

	if ( IsValid( weapon ) && IsValid( weaponOwner ) && weapon == weaponOwner.GetActiveWeapon() )
	{
		if( weaponOwner.IsPlayer() )
		{
			entity modelEnt = weaponOwner.GetViewModelEntity()
	 		if( IsValid( modelEnt ) && EntHasModelSet( modelEnt ) )
				ArchonCannon_Start( weapon )
		}
		else
		{
			ArchonCannon_Start( weapon )
		}
	}
}

void function OnWeaponDeactivate_titanweapon_arc_cannon_archon( entity weapon )
{
	ArchonCannon_ChargeEnd( weapon, expect entity( weapon.s.weaponOwner ) )
	ArchonCannon_Stop( weapon )
}

void function OnWeaponReload_titanweapon_arc_cannon_archon( entity weapon, int milestoneIndex )
{
	local reloadTime = weapon.GetWeaponInfoFileKeyField( "reload_time" )
	thread ArchonCannon_HideIdleEffect( weapon, reloadTime ) //constant seems to help it sync up better


}

void function OnWeaponOwnerChanged_titanweapon_arc_cannon_archon( entity weapon, WeaponOwnerChangedParams changeParams )
{
	#if CLIENT
		entity viewPlayer = GetLocalViewPlayer()
		if ( changeParams.oldOwner != null && changeParams.oldOwner == viewPlayer )
		{
			ArchonCannon_ChargeEnd( weapon, changeParams.oldOwner )
			ArchonCannon_Stop( weapon)
		}

		if ( changeParams.newOwner != null && changeParams.newOwner == viewPlayer )
			thread ArchonCannon_HideIdleEffect( weapon, 0.25 )
	#else
		if ( changeParams.oldOwner != null )
		{
			ArchonCannon_ChargeEnd( weapon, changeParams.oldOwner )
			ArchonCannon_Stop( weapon )
		}

		if ( changeParams.newOwner != null )
			thread ArchonCannon_HideIdleEffect( weapon, 0.25 )
	#endif
}

bool function OnWeaponChargeBegin_titanweapon_arc_cannon_archon( entity weapon )
{
	local stub = "this is here to suppress the untyped message.  This can go away when the .s. usage is removed from this file."
	#if SERVER
	//if ( weapon.HasMod( "fastpacitor_push_apart" ) )
	//	weapon.GetWeaponOwner().StunMovementBegin( weapon.GetWeaponSettingFloat( eWeaponVar.charge_time ) )
	#endif
	#if SERVER
	 weaponData.isCharging = true
	#endif
	thread UpdateWeaponChargeTracker( weapon )
	ArchonCannon_ChargeBegin( weapon )

	return true
}

void function OnWeaponChargeEnd_titanweapon_arc_cannon_archon( entity weapon )
{
	#if SERVER
	 weaponData.isCharging = false
	 #endif
	 ArchonCannon_ChargeEnd( weapon, weapon )
}

var function OnWeaponPrimaryAttack_titanweapon_arc_cannon_archon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if ( weapon.HasMod( "capacitor" ) && weapon.GetWeaponChargeFraction() < GetArcCannonChargeFraction( weapon ) )
		return 0

	if ( !attackParams.firstTimePredicted )
		return

	local fireRate = weapon.GetWeaponInfoFileKeyField( "fire_rate" )
	thread ArchonCannon_HideIdleEffect( weapon, (1 / fireRate) )
	int damageFlags = weapon.GetWeaponDamageFlags()

	return FireArchonCannon( weapon, attackParams )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_titanweapon_arc_cannon_archon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	local fireRate = weapon.GetWeaponInfoFileKeyField( "fire_rate" )
	thread ArchonCannon_HideIdleEffect( weapon, fireRate )

	return FireArchonCannon( weapon, attackParams )
}
#endif // #if SERVER


void function ArcCannonOnDamage( entity ent, var damageInfo )
{
	vector pos = DamageInfo_GetDamagePosition( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity mainWeapon = attacker.GetActiveWeapon()

	float damageMultiplier = DamageInfo_GetDamage( damageInfo ) / mainWeapon.GetWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor )

	if ( ent.IsPlayer() || ent.IsNPC() )
	{
		entity entToSlow = ent
		entity soul = ent.GetTitanSoul()

		if ( soul != null )
			entToSlow = soul
		//StatusEffect_AddTimed( entToSlow, eStatusEffect.move_slow, 0.5, 2.0, 1.0 )
		//StatusEffect_AddTimed( entToSlow, eStatusEffect.dodge_speed_slow, 0.5, 2.0, 1.0 )

		const ARC_TITAN_EMP_DURATION			= 0.35
		const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35

		StatusEffect_AddTimed( ent, eStatusEffect.emp, 0.2*damageMultiplier, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION )

		entity offhandWeaponRI = attacker.GetOffhandWeapon( OFFHAND_RIGHT )
		entity offhandWeaponAR = attacker.GetOffhandWeapon( OFFHAND_ANTIRODEO )
		entity offhandWeaponSP = attacker.GetOffhandWeapon( OFFHAND_SPECIAL )


		if(mainWeapon.HasMod("generator_mod"))
		{
			//Charge Ball Recharge
			if ( offhandWeaponRI.GetWeaponPrimaryClipCount() + 5 * damageMultiplier > 100 )
			{
				offhandWeaponRI.SetWeaponPrimaryClipCount( 100 )
			}
			else
			{
				offhandWeaponRI.SetWeaponPrimaryClipCount( offhandWeaponRI.GetWeaponPrimaryClipCount() + 5 * damageMultiplier)
			}

			//Tesla Node Recharge
			if ( offhandWeaponAR.GetWeaponPrimaryClipCount() + 12 * damageMultiplier > 200 )
			{
				offhandWeaponAR.SetWeaponPrimaryClipCount( 200 )
			}
			else
			{
				offhandWeaponAR.SetWeaponPrimaryClipCount( offhandWeaponAR.GetWeaponPrimaryClipCount() + 12 * damageMultiplier)
			}

			//Shock Shield Recharge
			if ( offhandWeaponSP.GetWeaponChargeFraction() - 0.05 * damageMultiplier < 0 )
			{
				//offhandWeaponSP.SetWeaponPrimaryClipCount( 100 )
				offhandWeaponSP.SetWeaponChargeFraction(0)
			}
			else
			{
				//offhandWeaponSP.SetWeaponPrimaryClipCount( offhandWeaponSP.GetWeaponPrimaryClipCount() + 0.2)
				offhandWeaponSP.SetWeaponChargeFraction(offhandWeaponSP.GetWeaponChargeFraction() - 0.05 * damageMultiplier)

			}
		}



	}


	#if SERVER
	string tag = ""
	asset effect

	if ( ent.IsTitan() )
	{
		tag = "exp_torso_front"
		effect = FX_EMP_BODY_TITAN
	}
	else if ( ChestFocusTarget( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = FX_EMP_BODY_HUMAN
	}
	else if ( IsAirDrone( ent ) )
	{
		tag = "HEADSHOT"
		effect = FX_EMP_BODY_HUMAN
	}
	else if ( IsGunship( ent ) )
	{
		tag = "ORIGIN"
		effect = FX_EMP_BODY_TITAN
	}

	if ( tag != "" )
	{
		float duration = 2.0
		//thread EMP_FX( effect, ent, tag, duration )
	}

	if ( ent.IsTitan() )
	{
		if ( ent.IsPlayer() )
		{
		 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "titan_energy_bulletimpact_3p_vs_1p" )
			EmitSoundOnEntityExceptToPlayer( ent, ent, "titan_energy_bulletimpact_3p_vs_3p" )
		}
		else
		{
		 	EmitSoundOnEntity( ent, "titan_energy_bulletimpact_3p_vs_3p" )
		}
	}
	else
	{
		if ( ent.IsPlayer() )
		{
		 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "flesh_lavafog_deathzap_3p" )
			EmitSoundOnEntityExceptToPlayer( ent, ent, "flesh_lavafog_deathzap_1p" )
		}
		else
		{
		 	EmitSoundOnEntity( ent, "flesh_lavafog_deathzap_1p" )
		}
	}
	#endif

}
#if SERVER
bool function ChestFocusTarget( entity ent )
{
	if ( IsSpectre( ent ) )
		return true
	if ( IsStalker( ent ) )
		return true
	if ( IsSuperSpectre( ent ) )
		return true
	if ( IsGrunt( ent ) )
		return true
	if ( IsPilot( ent ) )
		return true

	return false
}
#endif // #if SERVER
