untyped

global function MpTitanweaponStormBall_Init

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_storm_ball
#endif

global function OnWeaponPrimaryAttack_titanweapon_storm_ball

global function FireStormBall

global function OnWeaponAttemptOffhandSwitch_titanweapon_storm_ball
global function OnWeaponChargeBegin_titanweapon_storm_ball
global function OnWeaponChargeEnd_titanweapon_storm_ball


const ARC_BALL_AIRBURST_FX = $"P_impact_exp_emp_med_air"
const ARC_BALL_AIRBURST_SOUND = "Explo_ProximityEMP_Impact_3P"
const ARC_BALL_COLL_MODEL = $"models/Weapons/bullets/projectile_arc_ball.mdl"

const ARC_BALL_AIRBURST_CHARGED_FX = $"P_impact_exp_emp_med_air"

const ARC_BALL_CHARGE_FX_1P = $"wpn_arc_cannon_charge_fp"
const ARC_BALL_CHARGE_FX_3P = $"wpn_arc_cannon_charge"

const FX_EMP_FIELD						= $"P_xo_emp_field"
const FX_EMP_FIELD_1P					= $"P_body_emp_1P"
const FX_EMP_GLOW             = $"P_titan_core_atlas_charge"
const FX_EMP_ORB              = $"P_wpn_arcball_trail"

struct {
	table<entity, float> sonarExpiryTimes
} file

void function MpTitanweaponStormBall_Init()
{
	PrecacheModel( ARC_BALL_COLL_MODEL )
	PrecacheParticleSystem( ARC_BALL_AIRBURST_FX )

	PrecacheParticleSystem( ARC_BALL_CHARGE_FX_1P )
	PrecacheParticleSystem( ARC_BALL_CHARGE_FX_3P )

	PrecacheParticleSystem( FX_EMP_FIELD )
	PrecacheParticleSystem( FX_EMP_FIELD_1P )
	PrecacheParticleSystem( FX_EMP_GLOW )
	PrecacheParticleSystem( FX_EMP_ORB )
	//PrecacheParticleSystem( "wpn_smokescreen_elec_arc" )


}

bool function OnWeaponAttemptOffhandSwitch_titanweapon_storm_ball( entity weapon )
{
	bool allowSwitch = ( weapon.GetWeaponChargeFraction() == 0.0 )

	return allowSwitch
}


bool function OnWeaponChargeBegin_titanweapon_storm_ball( entity weapon )
{
	local stub = "this is here to suppress the untyped message.  This can go away when the .s. usage is removed from this file."

	#if CLIENT
		if ( !IsFirstTimePredicted() )
			return true
	#endif

	weapon.EmitWeaponSound( "Weapon_ChargeRifle_Charged_Loop" )

	entity weaponOwner = weapon.GetWeaponOwner()
	weapon.PlayWeaponEffect( ARC_BALL_CHARGE_FX_1P, ARC_BALL_CHARGE_FX_3P, "muzzle_flash" )


	return true
}

void function OnWeaponChargeEnd_titanweapon_storm_ball( entity weapon )
{
	#if CLIENT
		if ( !IsFirstTimePredicted() )
			return
	#endif

	weapon.StopWeaponSound( "Weapon_ChargeRifle_Charged_Loop" )

	entity weaponOwner = weapon.GetWeaponOwner()
	weapon.StopWeaponEffect( ARC_BALL_CHARGE_FX_1P, ARC_BALL_CHARGE_FX_3P )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_titanweapon_storm_ball( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	vector attackPos = attackParams.pos
	vector attackDir = attackParams.dir

	FireStormBall( weapon, attackPos, attackDir, false )
	return weapon.GetWeaponInfoFileKeyField( "ammo_min_to_fire" )
}
#endif

var function OnWeaponPrimaryAttack_titanweapon_storm_ball( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	bool shouldPredict = weapon.ShouldPredictProjectiles()
	#if CLIENT
		if ( !shouldPredict )
			return weapon.GetWeaponInfoFileKeyField( "ammo_min_to_fire" )
	#endif

	var fireMode = weapon.GetWeaponInfoFileKeyField( "fire_mode" )

	vector attackDir = attackParams.dir
	vector attackPos = attackParams.pos

	if ( fireMode == "offhand_instant" )
	{
		// Get missile firing information
		entity owner = weapon.GetWeaponOwner()
		if ( owner.IsPlayer() )
			attackDir = GetVectorFromPositionToCrosshair( owner, attackParams.pos )
	}

	FireStormBall( weapon, attackPos, attackDir, shouldPredict )

	return weapon.GetWeaponInfoFileKeyField( "ammo_min_to_fire" )
}

void function FireStormBall( entity weapon, vector pos, vector dir, bool shouldPredict, float damage = BALL_LIGHTNING_DAMAGE )
{
	entity owner = weapon.GetWeaponOwner()

	float speed = 850.0

	if ( owner.IsPlayer() )
	{
		vector myVelocity = owner.GetVelocity()

		float mySpeed = Length( myVelocity )

		myVelocity = Normalize( myVelocity )

		float dotProduct = DotProduct( myVelocity, dir )

		dotProduct = max( 0, dotProduct )

		speed = speed + ( mySpeed*dotProduct )
	}

	int team = TEAM_UNASSIGNED
	if ( IsValid( owner ) )
		team = owner.GetTeam()

	int flags = DF_EXPLOSION | DF_STOPS_TITAN_REGEN | DF_DOOM_FATALITY | DF_SKIP_DAMAGE_PROT

	entity bolt = weapon.FireWeaponBolt( pos, dir, speed, damageTypes.arcCannon | DF_ELECTRICAL, damageTypes.arcCannon | DF_EXPLOSION, shouldPredict, 0 )
	if ( bolt != null )
	{
		bolt.kv.rendercolor = "0 0 0"
		bolt.kv.renderamt = 0
		bolt.kv.fadedist = 1
		bolt.kv.gravity = 0.75
		SetTeam( bolt, team )

		float lifetime = 4.0

		bolt.SetProjectileLifetime( lifetime )


		#if SERVER
			/*AttachBallLightning( weapon, bolt )

			entity ballLightning = expect entity( bolt.s.ballLightning )

			ballLightning.e.ballLightningData.damage = 550*/
			//ballLightning.e.ballLightningData.damageHeavyArmor = 550

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



			/*{
				// HACK: bolts don't have collision so...
				entity collision = CreateEntity( "prop_script" )
				collision.SetValueForModelKey( ARC_BALL_COLL_MODEL )
				collision.kv.fadedist = -1
				collision.kv.physdamagescale = 0.1
				collision.kv.inertiaScale = 1.0
				collision.kv.renderamt = 255
				collision.kv.rendercolor = "255 255 255"
				collision.kv.rendermode = 10
				collision.kv.solid = SOLID_VPHYSICS
				collision.SetOwner( owner )
				collision.SetOrigin( bolt.GetOrigin() )
				collision.SetAngles( bolt.GetAngles() )
				SetTargetName( collision, "Storm Ball" )
				SetVisibleEntitiesInConeQueriableEnabled( collision, true )
				DispatchSpawn( collision )
				collision.SetParent( bolt )
				collision.SetMaxHealth( 250 )
				collision.SetHealth( 250 )
				AddEntityCallback_OnDamaged( collision, OnStormBallCollDamaged )
				thread TrackCollision( collision, bolt )
			}*/
		#endif
	}
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

	if (Time() >= endTime)
	{
		//entity projectile = bolt
		StormBallExplode( bolt )
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
		450,					// damageHeavyArmor
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

void function OnStormBallCollDamaged( entity collision, var damageInfo )
{
	entity arcBall = collision.GetParent()
	float damage = DamageInfo_GetDamage( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( attacker.IsNPC() )
		return

	entity owner = collision.GetOwner()
	int ownerTeam = TEAM_UNASSIGNED
	if ( IsValid( owner ) )
	{
		ownerTeam = owner.GetTeam()
	}

	if ( arcBall != null )
	{
		if ( DamageInfo_GetInflictor( damageInfo ) != arcBall )
		{
			if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.mp_titanweapon_arc_cannon && attacker == owner )
			{
				entity ballLightning = expect entity( arcBall.s.ballLightning )
				int inflictorTeam = ballLightning.GetTeam()

				BallLightningData fxData
				fxData.zapFx = $"wpn_arc_cannon_beam"
				fxData.zapLifetime = 0.7
				fxData.zapSound = "weapon_arc_ball_tendril"
				fxData.zapImpactTable = "exp_arc_cannon"
				fxData.radius = BALL_LIGHTNING_ZAP_RADIUS * 3
				fxData.height = BALL_LIGHTNING_ZAP_HEIGHT * 3
				fxData.damage = float( arcBall.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage ) )
				fxData.deathPackage = fxData.deathPackage | DF_CRITICAL

				thread BallLightningZapTargets( expect entity( arcBall.s.ballLightning ), arcBall.GetOrigin(), inflictorTeam, eDamageSourceId.mp_titanweapon_arc_ball, fxData, true )
				thread StormBallExplode( arcBall )
			}
			else if ( attacker.GetTeam() != ownerTeam )
			{
				collision.SetHealth( collision.GetHealth() - DamageInfo_GetDamage( damageInfo ) )
			}
		}
	}
}

/*void function TrackCollision( entity prop_physics, entity projectile )
{
	prop_physics.EndSignal( "OnDestroy" )
	projectile.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( prop_physics, projectile )
		{
			if ( IsValid( projectile ) )
			{
				StormBallExplode( projectile )
			}
			if ( IsValid( prop_physics ) )
				prop_physics.Destroy()
		}
	)

	// while( prop_physics.GetHealth() > 0 )
	// {
	// 	var damageInfo = prop_physics.WaitSignal( "OnDamaged" )
	// 	if ( "inflictor" in damageInfo )
	// 	{ // sometimes there is no inflictor
	// 		if ( damageInfo.inflictor != projectile )
	// 			prop_physics.SetHealth( prop_physics.GetHealth() - damageInfo.value )
	// 	}
	// }
	WaitForever()
}*/

void function StormBallExplode( entity projectile )
{
	vector origin = projectile.GetOrigin()

	EmitSoundAtPosition( projectile.GetTeam(), origin, "Explo_ProximityEMP_Impact_3P" )
	PlayFX( ARC_BALL_AIRBURST_FX, origin )


	RadiusDamage(
		origin,									// center
		projectile.GetOwner(),					// attacker
		projectile,								// inflictor
		projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage ),		// damage
		projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage_heavy_armor ),		// damageHeavyArmor
		projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosion_inner_radius ),		// innerRadius
		projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosionradius ),		// outerRadius
		0,										// flags
		0,										// distanceFromAttacker
		0,										// explosionForce
		DF_ELECTRICAL | DF_STOPS_TITAN_REGEN | DF_DOOM_FATALITY | DF_SKIP_DAMAGE_PROT,							// scriptDamageFlags
		projectile.ProjectileGetDamageSourceID() )			// scriptDamageSourceIdentifier
	projectile.Destroy()
}

function DelayDestroyBolt( entity bolt )
{
	bolt.EndSignal( "OnDestroy" )
	wait 4
	bolt.Destroy()
}

void function StormCore_DamagedTarget( entity target, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    if ( attacker == target )
    {
        DamageInfo_SetDamage( damageInfo, 0 )
    }

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
	//smokescreen.dangerousAreaRadius = smokescreen.damageOuterRadius * 1.5
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
