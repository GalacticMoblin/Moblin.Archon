global function OnWeaponActivate_titancore_storm_wave
global function MpTitanWeaponStormWave_Init

global function OnAbilityCharge_StormWave
global function OnAbilityChargeEnd_StormWave

global function OnWeaponPrimaryAttack_titancore_storm_wave



const float PROJECTILE_SEPARATION = 128
const float FLAME_WALL_MAX_HEIGHT = 110
const asset FLAME_WAVE_IMPACT_TITAN = $"P_impact_exp_med_metal"
const asset FLAME_WAVE_IMPACT 		= $"P_impact_exp_xsmll_metal"
const asset FLAMEWAVE_EFFECT 		= $"P_wpn_meteor_wave"
const asset FLAMEWAVE_EFFECT_CONTROL = $"P_wpn_meteor_waveCP"

const string FLAME_WAVE_LEFT_SFX = "flamewave_blast_left"
const string FLAME_WAVE_MIDDLE_SFX = "flamewave_blast_middle"
const string FLAME_WAVE_RIGHT_SFX = "flamewave_blast_right"

void function MpTitanWeaponStormWave_Init()
{
  PrecacheWeapon( "mp_titancore_storm_core" )
	PrecacheParticleSystem( FLAME_WAVE_IMPACT_TITAN )
	PrecacheParticleSystem( FLAME_WAVE_IMPACT )
	PrecacheParticleSystem( FLAMEWAVE_EFFECT )
	PrecacheParticleSystem( FLAMEWAVE_EFFECT_CONTROL )

	/*#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titancore_flame_wave, StormWave_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_titancore_flame_wave_secondary, StormWave_DamagedPlayerOrNPC )
	#endif*/
}

void function OnWeaponActivate_titancore_storm_wave( entity weapon )
{
	weapon.EmitWeaponSound_1p3p( "flamewave_start_1p", "flamewave_start_3p" )
	OnAbilityCharge_TitanCore( weapon )
}


bool function OnAbilityCharge_StormWave( entity weapon )
{
	#if SERVER
		entity owner = weapon.GetWeaponOwner()
		float chargeTime = weapon.GetWeaponSettingFloat( eWeaponVar.charge_time )
		entity soul = owner.GetTitanSoul()
		if ( soul == null )
			soul = owner
		StatusEffect_AddTimed( owner, eStatusEffect.move_slow, 0.6, chargeTime, 0 )
		StatusEffect_AddTimed( owner, eStatusEffect.dodge_speed_slow, 0.6, chargeTime, 0 )
    StatusEffect_AddTimed( owner, eStatusEffect.emp, 0.05, chargeTime*1.5, 0.35 )
		//StatusEffect_AddTimed( owner, eStatusEffect.damageAmpFXOnly, 1.0, chargeTime, 0 )

		if ( owner.IsPlayer() )
			owner.SetTitanDisembarkEnabled( false )
		else
			owner.Anim_ScriptedPlay( "at_antirodeo_anim_fast" )
	#endif

	return true
}

void function OnAbilityChargeEnd_StormWave( entity weapon )
{
	#if SERVER
		entity owner = weapon.GetWeaponOwner()
		if ( owner.IsPlayer() )
			owner.SetTitanDisembarkEnabled( true )
		OnAbilityChargeEnd_TitanCore( weapon )

		if ( owner == null )
			return

		if ( owner.IsPlayer() )
			owner.Server_TurnOffhandWeaponsDisabledOff()

		if ( owner.IsNPC() && IsAlive( owner ) )
		{
			owner.Anim_Stop()
		}
	#endif // #if SERVER
}

var function OnWeaponPrimaryAttack_titancore_storm_wave( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnAbilityStart_TitanCore( weapon )

	#if SERVER
	OnAbilityEnd_TitanCore( weapon )
	#endif
	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
		if ( !shouldPredict )
			return 1
	#endif


	#if SERVER
		weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.5 )
      	FireStormBall( weapon, attackParams.pos, attackParams.dir, shouldPredict)
	#elseif CLIENT
		ClientScreenShake( 8.0, 10.0, 1.0, Vector( 0.0, 0.0, 0.0 ) )
	#endif

	return 1
}
