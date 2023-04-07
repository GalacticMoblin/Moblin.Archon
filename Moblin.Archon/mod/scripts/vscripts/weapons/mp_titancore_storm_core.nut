untyped

global function StormCore_Init

global function FireStormBall

global function OnWeaponActivate_titancore_storm_core
global function OnAbilityCharge_Storm_Core
global function OnAbilityChargeEnd_Storm_Core
global function OnWeaponPrimaryAttack_titancore_storm_core
global function OnProjectileCollision_titancore_storm_core

const FX_EMP_FIELD						= $"P_xo_emp_field"
const FX_EMP_GLOW             = $"P_titan_core_atlas_charge"

struct {
	table<entity, float> sonarExpiryTimes
} file

void function StormCore_Init()
{
	PrecacheWeapon( "mp_titancore_storm_core" )
	PrecacheParticleSystem( FX_EMP_FIELD )
	PrecacheParticleSystem( FX_EMP_GLOW )
}

void function OnWeaponActivate_titancore_storm_core( entity weapon )
{
	weapon.EmitWeaponSound_1p3p( "bt_hotdrop_turbo", "bt_hotdrop_turbo_upgraded" )
	OnAbilityCharge_TitanCore( weapon )
}

bool function OnAbilityCharge_Storm_Core( entity weapon )
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

void function OnAbilityChargeEnd_Storm_Core( entity weapon )
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

var function OnWeaponPrimaryAttack_titancore_storm_core( entity weapon, WeaponPrimaryAttackParams attackParams )
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

void function FireStormBall( entity weapon, vector pos, vector dir, bool shouldPredict, float damage = BALL_LIGHTNING_DAMAGE )
{
	entity owner = weapon.GetWeaponOwner()

	float speed = 1000.0

	if ( owner.IsPlayer() )
	{
		vector myVelocity = owner.GetVelocity()

		float mySpeed = Length( myVelocity )

		myVelocity = Normalize( myVelocity )

		float dotProduct = DotProduct( myVelocity, dir )

		dotProduct = max( 0, dotProduct )

		mySpeed = mySpeed*0.30

		speed = speed + ( mySpeed*dotProduct )
	}

	int team = TEAM_UNASSIGNED
	if ( IsValid( owner ) )
		team = owner.GetTeam()

	int flags = DF_EXPLOSION | DF_STOPS_TITAN_REGEN | DF_DOOM_FATALITY | DF_SKIP_DAMAGE_PROT

	entity bolt = null
	if( weapon.HasMod("fd_rolling_thunder") ){
		vector angularVelocity = Vector( 0, 0, 0 )

		vector bulletVec = ApplyVectorSpread( dir, owner.GetAttackSpreadAngle() * 2 )
		print("BULLET VECTOR: " + bulletVec)

		bolt = weapon.FireWeaponGrenade( pos, bulletVec, angularVelocity, 0.0 , damageTypes.arcCannon | DF_ELECTRICAL, damageTypes.arcCannon | DF_EXPLOSION, shouldPredict, true, true )
	}
	else{
		bolt = weapon.FireWeaponBolt( pos, dir, speed, damageTypes.arcCannon | DF_ELECTRICAL, damageTypes.arcCannon | DF_EXPLOSION, shouldPredict, 0 )
	}
	if ( bolt != null )
	{
		bolt.kv.rendercolor = "0 0 0"
		bolt.kv.renderamt = 0
		bolt.kv.fadedist = 1
		bolt.kv.gravity = 0.75
		SetTeam( bolt, team )

		float lifetime = 25.0

		bolt.SetProjectileLifetime( lifetime )


		#if SERVER
			if ( IsValid( bolt ) )
			{
				PlayFXOnEntity( FX_EMP_FIELD, bolt, "", <0, 0, -21.0> )
				PlayFXOnEntity( FX_EMP_FIELD, bolt, "", <0, 0, -20.0> )
				PlayFXOnEntity( FX_EMP_FIELD, bolt, "", <0, 0, -22.0> )
				PlayFXOnEntity( FX_EMP_GLOW, bolt)
				EmitSoundOnEntity( bolt, "EMP_Titan_Electrical_Field" )
				EmitSoundOnEntity( bolt, "Wpn_LaserTripMine_LaserLoop" )


				vector origin = owner.OffsetPositionFromView( <0, 0, 0>, <25, -25, 15> )
				#if SERVER
					AddDamageCallbackSourceID( eDamageSourceId.mp_titancore_storm_core, StormCore_DamagedTarget )
				#endif

				thread UpdateStormCoreField( owner, bolt, weapon, origin, lifetime )

				if ( weapon.HasMod( "bring_the_thunder" ) )
				{
					thread UpdateStormCoreSmoke( owner, bolt, weapon, origin, lifetime )
				}
			}
		#endif
	}
}

void function OnProjectileCollision_titancore_storm_core( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
	if(IsValid(projectile) && IsValid(projectile.GetOwner()))
	{
		if( projectile.ProjectileGetMods().contains( "fd_rolling_thunder" ) )
		{
			projectile.proj.projectileBounceCount++
			if ( projectile.proj.projectileBounceCount > 2 )
			{
					projectile.GrenadeExplode( <0,0,0> )

				return
			}
			else{
				var impact_effect_table = projectile.ProjectileGetWeaponInfoFileKeyField( "impact_effect_table" )
				if ( impact_effect_table != null )
				{
					string fx = expect string( impact_effect_table )
					PlayImpactFXTable( pos, projectile.GetOwner(), fx )
				}
			}
		}
	}
	#endif
}


#if SERVER
void function UpdateStormCoreField( entity owner, entity bolt, entity weapon, vector origin, float lifetime )
{
    bolt.EndSignal( "OnDestroy" )
    float endTime = Time() + lifetime

	while ( Time() < endTime )
	{
		WaitFrame()
		origin = bolt.GetOrigin()
		StormCoreFieldDamage( weapon, bolt, origin )
	}

}

void function UpdateStormCoreSmoke( entity owner, entity bolt, entity weapon, vector origin, float lifetime )
{
    bolt.EndSignal( "OnDestroy" )
    float endTime = Time() + lifetime

	while ( Time() < endTime )
	{
		wait 0.1
		origin = bolt.GetOrigin()
		StormCoreSmokescreen( bolt, FX_ELECTRIC_SMOKESCREEN, owner )
		wait 0.15
	}
}

function StormCoreFieldDamage( entity weapon, entity bolt, vector origin )
{

	int flags = DF_EXPLOSION | DF_STOPS_TITAN_REGEN | DF_DOOM_FATALITY | DF_SKIP_DAMAGE_PROT

	// sonar things
	if ( !IsValid( weapon ) ) // i guess if you die you dont get more sonar, too bad!
		return
	if ( weapon.HasMod( "bring_the_thunder" ) )
	{
		// construct array of sonar-able things
		array<entity> enemiesToSonar = GetPlayerArrayEx( "any", TEAM_ANY, weapon.GetOwner().GetTeam(), origin, ARC_TITAN_EMP_FIELD_RADIUS )
		enemiesToSonar.extend( GetNPCArrayEx( "any", TEAM_ANY, weapon.GetOwner().GetTeam(), origin, ARC_TITAN_EMP_FIELD_RADIUS ) )

		foreach ( entity enemy in enemiesToSonar )
		{
			if ( enemy.GetTeam() == weapon.GetOwner().GetTeam() )
				continue

			// nothing is blocking LOS
			if ( TraceLineSimple(origin, enemy.GetCenter(), enemy) == 1.0 )
			{
				float oldExpiryTime = 0
				if ( enemy in file.sonarExpiryTimes )
					oldExpiryTime = file.sonarExpiryTimes[enemy]
				file.sonarExpiryTimes[enemy] <- Time() + 5.0 // this 5.0 is how long the sonar should stay
				if ( Time() > oldExpiryTime )
					thread StormCoreSonar_Think( enemy, weapon.GetOwner().GetTeam(), weapon.GetOwner(), origin )

			}
		}
	}

	// damage shields first and then other things
	DamageShieldsInRadiusOnEntity( weapon, bolt, ARC_TITAN_EMP_FIELD_RADIUS, 450 * 8 ) // damageheavyArmor * 8
	RadiusDamage(
		origin,									// center
		weapon.GetWeaponOwner(),									// attacker
		bolt,									// inflictor
		90,					// damage
		700,					// damageHeavyArmor
		ARC_TITAN_EMP_FIELD_INNER_RADIUS,		// innerRadius
		ARC_TITAN_EMP_FIELD_RADIUS,				// outerRadius
		SF_ENVEXPLOSION_NO_DAMAGEOWNER,			// flags
		0,										// distanceFromAttacker
		0,					                    // explosionForce
		flags,	// scriptDamageFlags
		eDamageSourceId.mp_titancore_storm_core )			// scriptDamageSourceIdentifier
}

void function StormCoreSonar_Think( entity ent, int sonarTeam, entity owner, vector origin )
{
	SonarStart( ent, origin, sonarTeam, owner )
	IncrementSonarPerTeam( sonarTeam )

	while ( Time() < file.sonarExpiryTimes[ent] )
	{
		wait file.sonarExpiryTimes[ent] - Time()
	}

	DecrementSonarPerTeam( sonarTeam )
	SonarEnd( ent, sonarTeam )
}

void function StormCore_DamagedTarget( entity target, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if ( attacker == target )
    {
        DamageInfo_SetDamage( damageInfo, 0 )
    }

		if ( DamageInfo_GetDamage( damageInfo ) <= 0 )
			return

		const ARC_TITAN_EMP_DURATION			= 0.35
		const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35

		StatusEffect_AddTimed( target, eStatusEffect.emp, 1.0, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION )
}

void function StormCoreSmokescreen( entity bolt, asset fx, entity owner )
{
	if ( !IsValid( owner ) )
		return

	RadiusDamageData radiusDamageData = GetRadiusDamageDataFromProjectile( bolt, owner )

	SmokescreenStruct smokescreen
	smokescreen.smokescreenFX = fx
	smokescreen.lifetime = 5.0
	smokescreen.ownerTeam = owner.GetTeam()
	smokescreen.damageSource = eDamageSourceId.mp_titancore_storm_core
	smokescreen.deploySound1p = ""
	smokescreen.deploySound3p = ""
	smokescreen.attacker = owner
	smokescreen.inflictor = owner
	smokescreen.weaponOrProjectile = bolt
	smokescreen.damageInnerRadius = 50
	smokescreen.damageOuterRadius = 210
	smokescreen.damageDelay = 1.0
	smokescreen.dpsPilot = 150
	smokescreen.dpsTitan = 800

	smokescreen.origin = bolt.GetOrigin()
	smokescreen.angles = bolt.GetAngles()
	smokescreen.fxUseWeaponOrProjectileAngles = true
	smokescreen.fxOffsets = [ <0.0, 0.0, 0.0> ]

	Smokescreen( smokescreen )
}
#endif
