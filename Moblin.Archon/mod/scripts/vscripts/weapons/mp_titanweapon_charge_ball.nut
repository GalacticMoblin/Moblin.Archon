untyped
global function ChargeBall_Init
global function OnWeaponPrimaryAttack_weapon_titanweapon_charge_ball
global function OnWeaponChargeBegin_titanweapon_charge_ball
global function OnWeaponChargeEnd_titanweapon_charge_ball

const ARCBALL2_CHARGE_FX_1P = $"wpn_arc_cannon_charge_fp"
const ARCBALL2_CHARGE_FX_3P = $"wpn_arc_cannon_charge"

void function ChargeBall_Init()
{
	PrecacheParticleSystem( $"Weapon_ArcLauncher_Fire_1P" )
	PrecacheParticleSystem( $"Weapon_ArcLauncher_Fire_3P" )
	PrecacheParticleSystem( ARCBALL2_CHARGE_FX_1P )
	PrecacheParticleSystem( ARCBALL2_CHARGE_FX_3P )
	PrecacheWeapon( "mp_titanweapon_charge_ball" )
	PrecacheParticleSystem( $"P_impact_exp_emp_med_air" )



	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_charge_ball, ChargeBallOnDamage )
		RegisterBallLightningDamage( eDamageSourceId.mp_titanweapon_charge_ball )
	#endif
}

var function OnWeaponPrimaryAttack_weapon_titanweapon_charge_ball( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	#if SERVER
		if ( weaponOwner.IsPlayer() )
		{
			vector angles = VectorToAngles( weaponOwner.GetViewVector() )
			vector up = AnglesToUp( angles )
			PlayerUsedOffhand( weaponOwner, weapon )

			if ( weaponOwner.GetTitanSoulBeingRodeoed() != null )
				attackParams.pos = attackParams.pos + up * 20
		}
	#endif

	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
		if ( !shouldPredict )
			return
	#endif

	var fireMode = weapon.GetWeaponInfoFileKeyField( "fire_mode" )

	vector attackPos = attackParams.pos
	vector attackDir = attackParams.dir

	float charge = weapon.GetWeaponChargeFraction()
	float angleoffset = 0.05
	float angleMultiplier = 1.6
	int extraBallAmount = 0

	vector rightVec = AnglesToRight(VectorToAngles(attackDir))

	if (charge == 1.0)
	{
  	extraBallAmount++
  	if (weapon.HasMod("thylord_module") ) { extraBallAmount++ }
	}

	for (int i = -extraBallAmount ; i < extraBallAmount+1 ; i++)
	{
		float finalMultiplier = angleMultiplier*i
		int damageSplitter = extraBallAmount+1
		float zapDamage = 300.0 / damageSplitter
		if( weapon.HasMod( "fd_balance" ) )
			float zapDamage = zapDamage * 0.9
		FireArcBall( weapon, attackPos, attackDir + rightVec * angleoffset*finalMultiplier, shouldPredict, zapDamage )
		//Single = 300 per, Triple = 150 per, Thylord = 100 per
		//270, 135, 90 in FD
	}
	weapon.EmitWeaponSound_1p3p( "Weapon_ArcLauncher_Fire_1P", "Weapon_ArcLauncher_Fire_3P" )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

bool function OnWeaponChargeBegin_titanweapon_charge_ball( entity weapon )
{
	weapon.EmitWeaponSound("Weapon_EnergySyphon_Charge_3P")

	#if CLIENT
		if ( !IsFirstTimePredicted() )
			return true
	#endif

	return true
}

void function OnWeaponChargeEnd_titanweapon_charge_ball( entity weapon )
{
	weapon.StopWeaponSound("Weapon_EnergySyphon_Charge_3P")
	#if CLIENT
		if ( !IsFirstTimePredicted() )
			return
	#endif
}

void function ChargeBallOnDamage( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	// check attacker validation before getting their weapon
	if ( !IsValid( attacker ) || attacker.GetTeam() == ent.GetTeam() )
		return
	// for npc titans without a pettitan owner
	// the inflictor( ball lightning mover ) can become attacker after they're destroyed
	// needs to add a check, otherwise attacker.GetOffhandWeapon(OFFHAND_RIGHT) may crash the server
	if ( !( attacker instanceof CBaseCombatCharacter ) )
	{
		// when a mover without valid owner damages player, it also causes crash on client-side
		// to prevent that, simply remove the damage to avoid damage indicator shows up on client
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	// all checks passed, it's now safe to do emp screen effect and get attacker's weapon
	const ARC_TITAN_EMP_DURATION			= 0.35
	const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35

	StatusEffect_AddTimed( ent, eStatusEffect.emp, 0.1, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION )
	
	entity weapon = attacker.GetOffhandWeapon(OFFHAND_RIGHT)

	if( IsValid( weapon ) ){
		if ( weapon.HasMod( "fd_terminator" ) )
			UpdateArchonTerminatorMeter( attacker, DamageInfo_GetDamage( damageInfo ) )
	}
}
