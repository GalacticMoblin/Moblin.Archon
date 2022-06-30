untyped
//global funtions
global function ArcPylonField_Init

#if SERVER

global function CreateArcPylonField

global function DestroyArcPylonField

global function ArcPylonFieldDamage

global function OnArcPylonField_DamagedEntity

global function DestroyProjectiles

#endif







//global constants
const float ARC_PYLON_TOTAL_KILL_CAP              = 100.0
const float EMP_CORE_TOTAL_KILL_CAP              = 150.0
const float ARC_PYLON_MISSILE_KILL_COST           = 5.6
const float ARC_PYLON_GRENADE_KILL_COST           = 4.2

global const float ARC_PYLON_FIELD_RADIUS   = 500
const float ARC_PYLON_FIELD_MAX_KILL_SPEED  = ARC_PYLON_FIELD_RADIUS * 10 //Don't kill things that can cross the entire radius in one check interval

const DAMAGE_AGAINST_TITANS 			= 80   //150
const DAMAGE_AGAINST_PILOTS 			= 8    //40
const EMP_DAMAGE_TICK_RATE = 0.3                //We just damage every 0.1s atm (WaitFrame()), so not needed

const FX_EMP_FIELD						= $"P_xo_emp_field"
const FX_EMP_FIELD_1P					= $"P_body_emp_1P"
const ARC_FIELD_DURATION					= 10.0
const asset LASER_TRIP_ZAP_FX = $"P_arc_pylon_zap"

//Functions
function ArcPylonField_Init()
{
#if SERVER
	//AddDamageCallbackSourceID( eDamageSourceId.titanEmpField, OnArcPylonField_DamagedEntity )
	PrecacheParticleSystem( FX_EMP_FIELD )
	PrecacheParticleSystem( FX_EMP_FIELD_1P )
	PrecacheParticleSystem( FX_ELECTRIC_SMOKESCREEN_BURN )
	RegisterSignal( "StopEMPField" )
#endif
}

#if SERVER
function CreateArcPylonField(entity pylon, entity weapon, vector origin, string attachment, attachID, asset effectNamePrimary, asset effectNameSecondary, float duration)
{
	if(IsValid(pylon))
	{
		if(IsValid(weapon))
		{
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
			particles.append( particleSystem )

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

			waitthread UpdateArcPylonField(weaponOwner, pylon, weapon, origin, duration)

		    DestroyArcPylonField( pylon )
		}
	}
}

void function UpdateArcPylonField( entity owner, entity pylon, entity weapon, vector origin, float duration )
{
    pylon.EndSignal( "OnDestroy" )
    float endTime = Time() + duration
    float totalCostRemaining = ARC_PYLON_TOTAL_KILL_CAP
	if(!weapon.IsProjectile() && weapon.GetWeaponClassName() == "mp_titancore_emp") totalCostRemaining = EMP_CORE_TOTAL_KILL_CAP

	while ( Time() < endTime && totalCostRemaining > 0 )
	{
		WaitFrame()
		origin = pylon.GetOrigin()
		totalCostRemaining -= DestroyProjectiles( owner, pylon, origin, totalCostRemaining )
        //endTime -= DestroyProjectiles( owner, pylon, origin ) / ARC_PYLON_TOTAL_KILL_CAP * duration // This version subtracts from duration directly if needed
		ArcPylonFieldDamage( owner, pylon, origin )
	}
}

void function DestroyArcPylonField( entity pylon )
{
	pylon.Destroy()
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

function CreateBeam( weapon, target, startPos, endPos, lifeDuration = ARC_CANNON_BEAM_LIFETIME, radius = 256, boltWidth = 4, noiseAmplitude = 5, hasTarget = true, firstBeam = false )
{
	Assert( startPos )
	Assert( endPos )

	//**************************
	// 	LIGHTNING BEAM EFFECT
	//**************************

		// Control point sets the end position of the effect
		entity cpEnd = CreateEntity( "info_placement_helper" )
		SetTargetName( cpEnd, UniqueString( "arc_cannon_beam_cpEnd" ) )
		cpEnd.SetOrigin( endPos )
		DispatchSpawn( cpEnd )

		entity zapBeam = CreateEntity( "info_particle_system" )
		zapBeam.kv.cpoint1 = cpEnd.GetTargetName()

		zapBeam.SetValueForEffectNameKey( GetBeamEffect( weapon ) )

		zapBeam.kv.start_active = 0
//		zapBeam.SetOwner( player )
		zapBeam.SetOrigin( startPos )
		DispatchSpawn( zapBeam )

		zapBeam.Fire( "Start" )
		zapBeam.Fire( "StopPlayEndCap", "", lifeDuration )
		zapBeam.Kill_Deprecated_UseDestroyInstead( lifeDuration )
		cpEnd.Kill_Deprecated_UseDestroyInstead( lifeDuration )
}

function GetBeamEffect( weapon )
{
	return LASER_TRIP_ZAP_FX
}

const array<int> ARC_PYLON_VANILLA_KILL_WHITELIST = [ eDamageSourceId.mp_titanweapon_homing_rockets ]

array<int> function ArcPylon_GetWhitelist()
{
    array<int> whitelist = clone( ARC_PYLON_VANILLA_KILL_WHITELIST )
    const array<string> modded = [ "" ] // Modded sources need to be added in runtime since they don't exist at compile
    foreach( id in modded )
        if( id in eDamageSourceId )
            whitelist.append( eDamageSourceId[id] )
    return whitelist
}

float function DestroyProjectiles(entity owner, entity pylon, vector origin, float costRemaining )
{
    array<int> whitelist = ArcPylon_GetWhitelist()

		int friendlyTeam = 0
		friendlyTeam = owner.GetTeam()

    int enemyTeam = friendlyTeam == TEAM_IMC ? TEAM_MILITIA : TEAM_IMC

    array<entity> projectiles = GetProjectileArrayEx( "grenade", TEAM_ANY, friendlyTeam, origin, ARC_PYLON_FIELD_RADIUS )
    projectiles.extend( GetProjectileArrayEx( "rpg_missile", TEAM_ANY, friendlyTeam, origin, ARC_PYLON_FIELD_RADIUS ) )

    if ( !projectiles.len() )
        return 0.0

    float totalCost = 0.0
    foreach( projectile in projectiles )
    {
        int id = projectile.ProjectileGetDamageSourceID()
        if ( id <= 0 || !whitelist.contains( id ) )
            continue

        if ( Length( projectile.GetVelocity() ) >= ARC_PYLON_FIELD_MAX_KILL_SPEED )
            continue

        switch( projectile.GetClassName() )
        {
            case "grenade":
                CreateBeam( pylon/*weapon*/, projectile/*the thing hitting*/, origin /*projectile origin*/, projectile.GetOrigin()/*the thing to be hit*/, 0.5, 256, 4, 5, true, false)
                projectile.GrenadeExplode(  projectile.GetForwardVector() )
                totalCost += ARC_PYLON_GRENADE_KILL_COST
                break
            case "rpg_missile":
                CreateBeam( pylon, projectile, origin, projectile.GetOrigin(), 0.5, 256, 4, 5, true, false)
                projectile.MissileExplode()
                projectile.Destroy()
                totalCost += ARC_PYLON_MISSILE_KILL_COST
        }
        if ( totalCost > costRemaining ) // Stop destroying projectiles; we hit the cap
            return totalCost
    }
    return totalCost
}

void function OnArcPylonField_DamagedEntity( entity target, var damageInfo )
{

	if ( !IsAlive( target ) )
		return

	// entity titan = DamageInfo_GetAttacker( damageInfo )

	// if ( !IsValid( titan ) )
	// 	 return

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

	if ( target.IsPlayer() )
	{
        StatusEffect_AddTimed( target, eStatusEffect.move_slow, 0.0, 0.01, 0.25 )
		// if ( !titan.IsPlayer() && IsArcTitan( titan ) )
		// {
		// 	if ( !titan.s.electrocutedPlayers.contains( target ) )
		// 		titan.s.electrocutedPlayers.append( target )
		// }

		// const ARC_TITAN_SCREEN_EFFECTS 			= 0.085
		// const ARC_TITAN_EMP_DURATION			= 0.35
		// const ARC_TITAN_EMP_FADEOUT_DURATION	= 0.35

		// local attachID 	= titan.LookupAttachment( "hijack" )
		// local origin 	= titan.GetAttachmentOrigin( attachID )
		// local distSqr 	= DistanceSqr( origin, target.GetOrigin() )

		// local minDist 	= ARC_TITAN_EMP_FIELD_INNER_RADIUS_SQR
		// local maxDist 	= ARC_TITAN_EMP_FIELD_RADIUS_SQR
		// local empFxHigh = ARC_TITAN_SCREEN_EFFECTS
		// local empFxLow 	= ( ARC_TITAN_SCREEN_EFFECTS * 0.6 )
		// float screenEffectAmplitude = GraphCapped( distSqr, minDist, maxDist, empFxHigh, empFxLow )

		// StatusEffect_AddTimed( target, eStatusEffect.emp, screenEffectAmplitude, ARC_TITAN_EMP_DURATION, ARC_TITAN_EMP_FADEOUT_DURATION )
	}
}
#endif
