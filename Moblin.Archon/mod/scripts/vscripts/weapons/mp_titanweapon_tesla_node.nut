untyped


global function TeslaNode_Init

global function OnWeaponPrimaryAttack_titanweapon_tesla_node

global function OnWeaponOwnerChanged_titanweapon_tesla_node

#if SERVER
global function OnWeaponNPCPrimaryAttack_titanweapon_tesla_node
#endif

const asset LASER_TRIP_AIRBURST_FX = $"P_impact_exp_arcball_default"
const string LASER_TRIP_AIRBURST_SOUND = "Explo_ProximityEMP_Impact_3P"

const asset LASER_TRIP_BEAM_FX = $"P_wpn_lasertrip_beam"
const asset LASER_TRIP_ZAP_FX = $"P_arc_pylon_zap"

const FX_EMP_FIELD = $"P_xo_emp_field"
const FX_NODE_RING = $"atLight_CH_AR_ring"
const asset LASER_TRIP_MODEL = $"models/weapons/titan_trip_wire/titan_trip_wire.mdl"
const asset LASER_TRIP_FX_ALL = $"P_wpn_lasertrip_base"
const asset LASER_TRIP_FX_FRIENDLY = $"wpn_grenade_frag_blue_icon"
const asset LASER_TRIP_EXPLODE_FX = $"P_impact_exp_XLG_metal"
const float ARC_PYLON_HEALTH = 300.0
const float ARC_PYLON_INNER_RADIUS = 400.0
const float ARC_PYLON_OUTER_RADIUS = 400.0
const float ARC_PYLON_EXPLOSION_DAMAGE = 50.0
const float ARC_PYLON_EXPLOSION_DAMAGE_HEAVY_ARMOR = 750.0

const float ARC_PYLON_LIFETIME = 10.0
const float ARC_PYLON_BUILD_TIME = 0.5

const float LASER_TRIP_DEPLOY_POWER = 1400.0

const float DAMAGE_AGAINST_TITANS 			= 80.0   //150
const float DAMAGE_AGAINST_PILOTS 			= 8.0    //40

struct
{
	int ArcPylonsIdx
} file;

void function TeslaNode_Init()
{
	PrecacheModel( LASER_TRIP_MODEL )
	PrecacheParticleSystem( LASER_TRIP_FX_ALL )
	PrecacheParticleSystem( LASER_TRIP_FX_FRIENDLY )
	PrecacheParticleSystem( LASER_TRIP_EXPLODE_FX )
	PrecacheParticleSystem( LASER_TRIP_AIRBURST_FX )
	PrecacheParticleSystem( LASER_TRIP_BEAM_FX )
	PrecacheParticleSystem( LASER_TRIP_ZAP_FX )
	PrecacheParticleSystem( FX_NODE_RING )
  PrecacheWeapon( "mp_titanweapon_tesla_node" )

	#if SERVER
		file.ArcPylonsIdx = CreateScriptManagedEntArray()
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_tesla_node, ArcPylon_DamagedPlayerOrNPC )
	#endif
}
    void function OnWeaponOwnerChanged_titanweapon_tesla_node( entity weapon, WeaponOwnerChangedParams changeParams )
{
	#if SERVER
	entity owner = weapon.GetWeaponOwner()

	if ( owner == null )
		return
	#endif
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_titanweapon_tesla_node( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return OnWeaponPrimaryAttack_titanweapon_tesla_node( weapon, attackParams )
}
#endif

var function OnWeaponPrimaryAttack_titanweapon_tesla_node( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()

#if CLIENT
		vector origin = owner.OffsetPositionFromView( Vector(0, 0, 0), Vector(25, -25, 15) )
		vector angles = owner.CameraAngles()

		StartParticleEffectOnEntityWithPos( owner, GetParticleSystemIndex( $"wpn_mflash_xo_rocket_shoulder_FP" ), FX_PATTACH_EYES_FOLLOW, -1, origin, angles )
#endif // #if CLIENT

	if ( owner.IsPlayer() )
		PlayerUsedOffhand( owner, weapon )

#if SERVER
	//This wave attack is spawning 3 waves, and we want them all to only do damage once to any individual target.
	entity inflictor = CreateDamageInflictorHelper( -1.0 )
#endif

	vector right = CrossProduct( attackParams.dir, <0,0,1> )
	vector dir = attackParams.dir

	array<entity> deployables = []

	dir.z = min( dir.z, -0.2 )

	attackParams.dir = dir
	deployables.append( ThrowDeployable( weapon, attackParams, LASER_TRIP_DEPLOY_POWER, OnArcPylonPlanted ) )

	#if SERVER
	foreach ( i, deployable in deployables )
	{
		deployable.proj.projectileID = i
		deployable.proj.projectileGroup = clone deployables
		deployable.proj.inflictorOverride = inflictor
	}
	#endif
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function OnArcPylonPlanted( entity projectile )
{
	#if SERVER
		thread DeployArcPylon( projectile )
	#endif
}

#if SERVER
function DeployArcPylon( entity projectile )
{

	vector origin = projectile.GetOrigin() // - <0,0,40>
	vector angles = projectile.proj.savedAngles
	entity owner = projectile.GetOwner()
	entity inflictor = projectile.proj.inflictorOverride
	entity attachparent = projectile.GetParent()

	projectile.SetModel( $"models/dev/empty_model.mdl" )
	projectile.Hide()

	if ( !IsValid( owner ) )
		return

	if ( IsNPCTitan( owner ) )
	{
		entity bossPlayer = owner.GetBossPlayer()
		if ( IsValid( bossPlayer ) )
			bossPlayer.EndSignal( "OnDestroy" )
	}
	else
	{
		owner.EndSignal( "OnDestroy" )
	}

	int team = owner.GetTeam()

	entity tower = CreatePropScript( LASER_TRIP_MODEL, origin, angles, SOLID_VPHYSICS )
	tower.kv.collisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	//tower.EnableAttackableByAI( 20, 0, AI_AP_FLAG_NONE )
	SetTargetName( tower, "Laser Tripwire Base" )
	tower.SetMaxHealth( 500000 )
	tower.SetHealth( 500000 )
	tower.SetTakeDamageType( DAMAGE_NO )
	tower.SetDamageNotifications( true )
	tower.SetDeathNotifications( true )
	tower.SetArmorType( ARMOR_TYPE_HEAVY )
	tower.SetTitle( "Laser Tripwire" )
	tower.EndSignal( "OnDestroy" )
	EmitSoundOnEntity( tower, "Wpn_LaserTripMine_Land" )
	tower.e.noOwnerFriendlyFire = true

	tower.Anim_Play( "trip_wire_closed_to_open" )
	tower.Anim_DisableUpdatePosition()

	if ( attachparent != null )
		tower.SetParent( attachparent )

	// hijacking this int so we don't create a new one
	string noSpawnIdx = CreateNoSpawnArea( TEAM_INVALID, team, origin, ARC_PYLON_BUILD_TIME + ARC_PYLON_LIFETIME, ARC_PYLON_OUTER_RADIUS )

	SetTeam( tower, team )
	SetObjectCanBeMeleed( tower, false )
	SetVisibleEntitiesInConeQueriableEnabled( tower, true )
    //AddEntityCallback_OnDamaged( tower, OnArcPylonBodyDamaged )
	SetCustomSmartAmmoTarget( tower, false )
	thread TrapDestroyOnRoundEnd( owner, tower )

	entity pylon = CreateEntity( "script_mover" )
	pylon.SetValueForModelKey( $"models/weapons/bullets/triple_threat_projectile.mdl" )
	pylon.kv.fadedist = -1
	pylon.kv.physdamagescale = 0.1
	pylon.kv.inertiaScale = 1.0
	pylon.kv.renderamt = 255
	pylon.kv.rendercolor = "0 0 255"
	pylon.kv.solid = SOLID_HITBOXES
	pylon.kv.SpawnAsPhysicsMover = 0
	SetTargetName( pylon, "Laser Tripwire" )
	pylon.SetOrigin( origin )
	pylon.SetAngles( angles )
	pylon.SetOwner( owner.GetTitanSoul() )

	pylon.SetMaxHealth( ARC_PYLON_HEALTH )
	pylon.SetHealth( ARC_PYLON_HEALTH )
	pylon.SetTakeDamageType( DAMAGE_YES )
	pylon.SetDamageNotifications( false )
	pylon.SetDeathNotifications( true )
	pylon.SetArmorType( ARMOR_TYPE_HEAVY )
	SetVisibleEntitiesInConeQueriableEnabled( pylon, true )
	SetTeam( pylon, team )
	pylon.NotSolid()
	pylon.Hide()


	DispatchSpawn( pylon )

	int damageSourceId = projectile.ProjectileGetDamageSourceID()
	pylon.EndSignal( "OnDestroy" )

	pylon.SetParent( tower, "", true, 0 )
	pylon.NonPhysicsSetMoveModeLocal( true )
	pylon.NonPhysicsMoveTo( pylon.GetLocalOrigin() + <0,0,45>, ARC_PYLON_BUILD_TIME, 0, 0 )
	pylon.e.spawnTime = Time()
	pylon.e.projectileID = projectile.proj.projectileID

	int projCount = projectile.proj.projectileGroup.len()
	foreach ( p in projectile.proj.projectileGroup )
	{
		if ( IsValid( p ) && p.IsProjectile() && p != projectile )
			p.proj.projectileGroup.append( pylon )
	}

	vector pylonOrigin = pylon.GetOrigin()

	//print("PREDEP ----- Pylon: " + pylon + " Projectile: " + projectile)


	OnThreadEnd(
	function() : ( projectile, inflictor, tower, pylon, noSpawnIdx, team, pylonOrigin )
		{
			PlayFX( LASER_TRIP_EXPLODE_FX, pylonOrigin, < -90.0, 0.0, 0.0 > )
			EmitSoundAtPosition( team, pylonOrigin, "Wpn_LaserTripMine_MineDestroyed" )
      DeleteNoSpawnArea( noSpawnIdx )

			entity soul = pylon.GetOwner()
			if ( IsValid( soul ) )
			{
				entity titan = soul.GetTitan()
				if ( IsValid( titan ) )
				{
					RadiusDamage(
						pylonOrigin,											// center
						titan,											// attacker
						inflictor,										// inflictor
						ARC_PYLON_EXPLOSION_DAMAGE,								// damage
						ARC_PYLON_EXPLOSION_DAMAGE_HEAVY_ARMOR,					// damageHeavyArmor
						ARC_TITAN_EMP_FIELD_RADIUS/2,						// innerRadius
						ARC_TITAN_EMP_FIELD_RADIUS/1.5,						// outerRadius
						SF_ENVEXPLOSION_NO_DAMAGEOWNER,					// flags
						0,												// distanceFromAttacker
						0,												// explosionForce
						DF_ELECTRICAL,									// scriptDamageFlags
						eDamageSourceId.mp_titanweapon_tesla_node )	// scriptDamageSourceIdentifier
				}
			}

			if ( IsValid( tower ) )
			{
				tower.Destroy()
			}

			if ( IsValid( pylon ) )
			{
				pylon.Destroy()
			}

			if ( IsValid( inflictor ) )
				inflictor.Kill_Deprecated_UseDestroyInstead( 1.0 )
			}
    )

	wait ARC_PYLON_BUILD_TIME

  if( !IsValid( pylon ) )
      return

  //AI_CreateDangerousArea_Static( pylon, projectile, ARC_TITAN_EMP_FIELD_RADIUS + 50, TEAM_INVALID, true, true, pylonOrigin )

  string attachment = ""
	int attachID = pylon.LookupAttachment( attachment )
	//print("DEPLOYED ----- Pylon: " + pylon + " Projectile: " + projectile)
  thread CreateArcPylonField( pylon, projectile, pylonOrigin, attachment, attachID, FX_EMP_FIELD, FX_NODE_RING, ARC_PYLON_LIFETIME )

	PlayLoopFXOnEntity( LASER_TRIP_FX_ALL, pylon )

	entity soul = owner.IsTitan() ? owner.GetTitanSoul() : owner.GetTitanSoul()

	if ( IsAlive(soul))
		owner.EndSignal( "OnDeath" )

    WaitForever() //CreateArcPylonField kills the pylon
}
#endif //SERVER


#if SERVER
void function StopArcSoundAtPosition( entity pylon, vector position )
{
	pylon.WaitSignal( "OnDestroy" )
	StopSoundAtPosition( position, "Wpn_LaserTripMine_LaserLoop" )
}
#endif

/*
void function OnArcPylonBodyDamaged( entity pylonBody, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	int attackerTeam = attacker.GetTeam()

	if ( pylonBody.GetTeam() != attackerTeam )
	{
		if ( attacker.IsPlayer() )
		{
			//attacker.NotifyDidDamage( pylonBody, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
		}
	}
}*/

#if SERVER
void function ArcPylon_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( ent.IsPlayer() )
	{
		if ( ent.IsTitan() )
		 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "titan_rocket_explosion_3p_vs_1p" )
		else
		 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "flesh_explo_med_3p_vs_1p" )
	}

	if ( !IsAlive( ent ) )
		return

	entity titan = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( titan ) )
		return

	/*local className = ent.GetClassName()
	if ( ent.IsProjectile() || className == "npc_turret_sentry" )
	{
		DamageInfo_SetDamage( damageInfo, 0 ) // Won't damage things hurt by AoE damage like Satchels and Tethers
		return
	}*/

	if ( DamageInfo_GetDamage( damageInfo ) <= 0 )
		return

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS )
		return

	StatusEffect_AddTimed( ent, eStatusEffect.move_slow, 0.1, 0.25, 0.0 )

	const ARC_TITAN_SCREEN_EFFECTS 			= 0.8
	const ARC_TITAN_EMP_DURATION			= 0.35
	const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	local origin 	   = inflictor.GetOrigin()
	local distSqr 	 = Distance( origin, ent.GetOrigin() )

	local empFxHigh = ARC_TITAN_SCREEN_EFFECTS
	local empFxLow 	= ( ARC_TITAN_SCREEN_EFFECTS * 0.15 )
	float screenEffectAmplitude = GraphCapped( distSqr, ARC_TITAN_EMP_FIELD_INNER_RADIUS, ARC_TITAN_EMP_FIELD_RADIUS, empFxHigh, empFxLow )

	StatusEffect_AddTimed( ent, eStatusEffect.emp, screenEffectAmplitude, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION )

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity mainWeapon = attacker.GetOffhandWeapon( OFFHAND_SPECIAL )

	if(IsValid(mainWeapon)){
		if ( mainWeapon.HasMod( "fd_terminator" ) )
			UpdateArchonTerminatorMeter( attacker, DamageInfo_GetDamage( damageInfo ) )
	}
}
#endif

#if SERVER
function CreateArcPylonField(entity pylon, entity weapon, vector origin, string attachment, attachID, asset effectNamePrimary, asset effectNameSecondary, float duration)
{
	//print("---PYLON DEPLOYED---")
	if(IsValid(pylon))
	{
		//print("-----PYLON VALIDATED-----")
		if(IsValid(weapon))
		{
			//print("---------WEAPON VALIDATED---------")
			entity weaponOwner = weapon.GetOwner()
			EmitSoundOnEntity( pylon, "EMP_Titan_Electrical_Field" )

			array<entity> particles = []

			entity particleSystem = CreateEntity( "info_particle_system" )
			particleSystem.kv.start_active = 1
			if ( weaponOwner.IsPlayer() )
				particleSystem.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
			else
				particleSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
			particleSystem.SetValueForEffectNameKey( effectNamePrimary )
			particleSystem.SetOwner( pylon )
			particleSystem.SetOrigin( origin )
			DispatchSpawn( particleSystem )
			particleSystem.SetParent( pylon, attachment )

			entity particleSystem2 = CreateEntity( "info_particle_system" )
			particleSystem2.kv.start_active = 1
			if ( weaponOwner.IsPlayer() )
				particleSystem2.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
			else
				particleSystem2.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
			particleSystem2.SetValueForEffectNameKey( effectNameSecondary )
			particleSystem2.SetOwner( pylon )
			particleSystem2.SetOrigin( origin )
			DispatchSpawn( particleSystem2 )
			particleSystem2.SetParent( pylon, attachment )

			particles.append( particleSystem )
			particles.append( particleSystem2 )

			pylon.EndSignal( "OnDestroy" )

			OnThreadEnd(
				function () : ( pylon, particles )
				{
					if ( IsValid( pylon ) )
					{
						StopSoundOnEntity( pylon, "EMP_Titan_Electrical_Field" )
					}

					foreach ( particleSystem in particles )
					{
						if ( IsValid_ThisFrame( particleSystem ) )
						{
							particleSystem.ClearParent()
							particleSystem.Fire( "StopPlayEndCap" )
							particleSystem.Kill_Deprecated_UseDestroyInstead( 1.0 )
						}
					}
				}
			)

			if(IsValid(particleSystem2))
			{
				particleSystem2.Kill_Deprecated_UseDestroyInstead(0.5)
			}

			waitthread UpdateArcPylonField(weaponOwner, pylon, weapon, origin, duration)

			//print("PREVAL ------------ " + weapon)
			if ( IsValid( weapon ) )
				weapon.Destroy()
			//print("VALIDATED? ------------ " + weapon)


		    pylon.Destroy()
		}
		else
		{
			pylon.Destroy()
			//print("PYLON DESTROYEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD")
		}
	}
}

void function UpdateArcPylonField( entity owner, entity pylon, entity weapon, vector origin, float duration )
{
  pylon.EndSignal( "OnDestroy" )
  float endTime = Time() + duration

	while ( Time() < endTime )
	{
		WaitFrame()
		origin = pylon.GetOrigin()
		ArcPylonFieldDamage( owner, pylon, origin )
	}
}

function ArcPylonFieldDamage( entity owner, entity pylon, vector origin )
{
    RadiusDamage(
        origin,									// center
        owner,									// attacker
        pylon,									// inflictor
        DAMAGE_AGAINST_PILOTS,					// damage
        DAMAGE_AGAINST_TITANS,					// damageHeavyArmor
        ARC_TITAN_EMP_FIELD_INNER_RADIUS,		// innerRadius
        ARC_TITAN_EMP_FIELD_RADIUS,				// outerRadius
        SF_ENVEXPLOSION_NO_DAMAGEOWNER,			// flags
        0,										// distanceFromAttacker
        0,					                    // explosionForce
        DF_ELECTRICAL | DF_STOPS_TITAN_REGEN,	// scriptDamageFlags
        eDamageSourceId.mp_titanweapon_tesla_node )			// scriptDamageSourceIdentifier
}

void function OnArcPylonField_DamagedEntity( entity target, var damageInfo )
{

	if ( !IsAlive( target ) )
		return

	entity titan = DamageInfo_GetAttacker( damageInfo )
	float outputDamage = DamageInfo_GetDamage( damageInfo )

	//print("TESLA DAMAGE: " + outputDamage)

	if ( !IsValid( titan ) )
		return

	local className = target.GetClassName()
	if ( target.IsProjectile() || className == "npc_turret_sentry" )
	{
		DamageInfo_SetDamage( damageInfo, 0 ) // Won't damage things hurt by AoE damage like Satchels and Tethers
		return
	}

	if ( DamageInfo_GetDamage( damageInfo ) <= 0 )
		return

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS )
		return

	float slowMultiplier = GraphCapped( outputDamage, 0, DAMAGE_AGAINST_TITANS, DAMAGE_AGAINST_TITANS / 2, DAMAGE_AGAINST_TITANS )

	StatusEffect_AddTimed( target, eStatusEffect.move_slow, 0.25, 0.01, 0.25 )

	const ARC_TITAN_SCREEN_EFFECTS 			= 0.085
	const ARC_TITAN_EMP_DURATION			= 0.35
	const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35

	local attachID 	= titan.LookupAttachment( "" )
	local origin 	= titan.GetAttachmentOrigin( attachID )
	local distSqr 	= Distance( origin, target.GetOrigin() )

	local minDist 	= ARC_TITAN_EMP_FIELD_INNER_RADIUS_SQR
	local maxDist 	= ARC_TITAN_EMP_FIELD_RADIUS_SQR
	local empFxHigh = ARC_TITAN_SCREEN_EFFECTS
	local empFxLow 	= ( ARC_TITAN_SCREEN_EFFECTS * 0.6 )
	float screenEffectAmplitude = GraphCapped( distSqr, ARC_TITAN_EMP_FIELD_INNER_RADIUS, ARC_TITAN_EMP_FIELD_RADIUS, empFxHigh, empFxLow )

	StatusEffect_AddTimed( target, eStatusEffect.emp, screenEffectAmplitude, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION )
}
#endif
