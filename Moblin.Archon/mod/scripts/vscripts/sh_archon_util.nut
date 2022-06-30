untyped

global function GiveArchon
global function ArchonPrecache
//global function FX_Test_01
global function ShouldGiveTimerCredit

#if SERVER
global function DamageShieldsInRadiusOnEntity
#endif


void function ArchonPrecache()
{
	#if SERVER
	RegisterWeaponDamageSources(
		{
			mp_titanweapon_tesla_node = "Tesla Node",
			mp_titanweapon_charge_ball = "Charge Ball",
			mp_titanweapon_shock_shield = "Shock Shield",
			//mp_titanweapon_arc_cannon_lite = "Arc Cannon",
			mp_titancore_storm_core = "Storm Core"
		}
	)
	#endif
	RegisterSignal( "KillBruteShield" )
	//RegisterNewVortexIgnoreClassname("mp_titancore_stormcore", true)
	MpTitanweaponArcCannonArchon_Init()
	ArchonCannon_Init()
	MpTitanweaponShockShield_Init()
	MpTitanweaponArcBall2_Init()
	MpTitanAbilityArcPylon_Init()
	MpTitanWeaponStormWave_Init()
	PrimeTitanPlus_Init()
	#if SERVER
        GameModeRulesRegisterTimerCreditException( eDamageSourceId.mp_titancore_storm_core )
	#endif
}

void function GiveArchon( int i = 0 )
{
	#if SERVER
		entity player = GetPlayerArray()[i]

		if( player.IsTitan() && GetTitanCharacterName( player ) == "ion" )
		{
			array<entity> weapons = player.GetMainWeapons()
			player.TakeWeapon( weapons[0].GetWeaponClassName() )
			player.GiveWeapon( "mp_titanweapon_arc_cannon" )
			player.SetActiveWeaponByName("mp_titanweapon_arc_cannon" )
			player.TakeOffhandWeapon( OFFHAND_SPECIAL )
			player.GiveOffhandWeapon( "mp_titanweapon_shock_shield", OFFHAND_SPECIAL )
			player.TakeOffhandWeapon( OFFHAND_ANTIRODEO )
			player.GiveOffhandWeapon( "mp_titanweapon_tesla_node", OFFHAND_ANTIRODEO )
			player.TakeOffhandWeapon( OFFHAND_RIGHT )
			player.GiveOffhandWeapon( "mp_titanweapon_charge_ball", OFFHAND_RIGHT )
			player.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
			player.GiveOffhandWeapon( "mp_titancore_storm_core", OFFHAND_EQUIPMENT )
		}
	#endif
}

bool function ShouldGiveTimerCredit( entity player, entity victim, var damageInfo )
{
    if ( player == victim )
        return false

    if ( player.IsTitan() && !IsCoreAvailable( player ) )
        return false

    if ( GAMETYPE == FREE_AGENCY && !player.IsTitan() )
        return false

    int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
    switch ( damageSourceID )
    {
        case eDamageSourceId.mp_titancore_storm_core: // Modded damageSourceID
        case eDamageSourceId.mp_titancore_flame_wave:
        case eDamageSourceId.mp_titancore_flame_wave_secondary:
        case eDamageSourceId.mp_titancore_salvo_core:
        case damagedef_titan_fall:
        case damagedef_nuclear_core:
            return false
    }

    return true
}

vector function ApplyVectorSpread_Archon( vector vecShotDirection, float spreadDegrees, float bias = 1.0 )
{
	vector angles = VectorToAngles( vecShotDirection )
	vector vecUp = AnglesToUp( angles )
	vector vecRight = AnglesToRight( angles )

	float sinDeg = deg_sin( spreadDegrees / 2.0 )

	// get circular gaussian spread
	float x
	float y
	float z

	if ( bias > 1.0 )
		bias = 1.0
	else if ( bias < 0.0 )
		bias = 0.0

	// code gets these values from cvars ai_shot_bias_min & ai_shot_bias_max
	float shotBiasMin = -1.0
	float shotBiasMax = 1.0

	// 1.0 gaussian, 0.0 is flat, -1.0 is inverse gaussian
	float shotBias = ( ( shotBiasMax - shotBiasMin ) * bias ) + shotBiasMin
	float flatness = ( fabs(shotBias) * 0.5 )

	while ( true )
	{
		x = RandomFloatRange( -1.0, 1.0 ) * flatness + RandomFloatRange( -1.0, 1.0 ) * (1 - flatness)
		y = RandomFloatRange( -1.0, 1.0 ) * flatness + RandomFloatRange( -1.0, 1.0 ) * (1 - flatness)
		if ( shotBias < 0 )
		{
			x = ( x >= 0 ) ? 1.0 - x : -1.0 - x
			y = ( y >= 0 ) ? 1.0 - y : -1.0 - y
		}
		z = x * x + y * y

		if ( z <= 1 )
			break
	}

	vector addX = vecRight * ( x * sinDeg )
	vector addY = vecUp * ( y * sinDeg )
	vector m_vecResult = vecShotDirection + addX + addY

	return m_vecResult
}


float function DegreesToTarget_Archon( vector origin, vector forward, vector targetPos )
{
	vector dirToTarget = targetPos - origin
	dirToTarget = Normalize( dirToTarget )
	float dot = DotProduct( forward, dirToTarget )
	float degToTarget = (acos( dot ) * 180 / PI)

	return degToTarget
}



function CreateArcCannonBeam_Archon( weapon, target, startPos, endPos, player, lifeDuration = 1.0, radius = 256, boltWidth = 4, noiseAmplitude = 5, hasTarget = true, firstBeam = false )
{
	Assert( startPos )
	Assert( endPos )

	//**************************
	// 	LIGHTNING BEAM EFFECT
	//**************************
	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
		lifeDuration = ARC_CANNON_BEAM_LIFETIME_BURN
	// If it's the first beam and on client we do a special beam so it's lined up with the muzzle origin
	#if CLIENT
		if ( firstBeam )
			thread CreateClientArcBeam_Archon( weapon, endPos, lifeDuration, target )
	#endif

	#if SERVER
		// Control point sets the end position of the effect
		entity cpEnd = CreateEntity( "info_placement_helper" )
		SetTargetName( cpEnd, UniqueString( "arc_cannon_beam_cpEnd" ) )
		cpEnd.SetOrigin( endPos )
		DispatchSpawn( cpEnd )

		entity zapBeam = CreateEntity( "info_particle_system" )
		zapBeam.kv.cpoint1 = cpEnd.GetTargetName()

		zapBeam.SetValueForEffectNameKey( GetBeamEffect_Archon( weapon ) )

		zapBeam.kv.start_active = 0
		zapBeam.SetOwner( player )
		zapBeam.SetOrigin( startPos )
		if ( firstBeam )
		{
			zapBeam.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
			zapBeam.SetParent( player.GetActiveWeapon(), "muzzle_flash", false, 0.0 )
		}
		DispatchSpawn( zapBeam )

		zapBeam.Fire( "Start" )
		zapBeam.Fire( "StopPlayEndCap", "", lifeDuration )
		zapBeam.Kill_Deprecated_UseDestroyInstead( lifeDuration )
		cpEnd.Kill_Deprecated_UseDestroyInstead( lifeDuration )
	#endif
}

function GetBeamEffect_Archon( weapon )
{
	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
		return ARC_CANNON_BEAM_EFFECT_MOD

	return ARC_CANNON_BEAM_EFFECT
}

#if CLIENT
function CreateClientArcBeam_Archon( weapon, endPos, lifeDuration, target )
{
	Assert( IsClient() )

	local beamEffect = GetBeamEffect_Archon( weapon )

	// HACK HACK HACK HACK
	string tag = "muzzle_flash"
	if ( weapon.GetWeaponInfoFileKeyField( "client_tag_override" ) != null )
		tag = expect string( weapon.GetWeaponInfoFileKeyField( "client_tag_override" ) )

	local handle = weapon.PlayWeaponEffectReturnViewEffectHandle( beamEffect, $"", tag )
	if ( !EffectDoesExist( handle ) )
		return

	EffectSetControlPointVector( handle, 1, endPos )

	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
		lifeDuration = 1.0

	wait( lifeDuration )

	if ( IsValid( weapon ) )
		weapon.StopWeaponEffect( beamEffect, $"" )
}
#endif // CLIENT

/*void function FX_Test_01(asset effect, vector color)
{
	print("ran")
	PrecacheParticleSystem( effect )
	entity player = GetPlayerArray()[0]


	//int fxHandle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( effect ), player.GetOrigin(), <0,0,0> )
	//vector controlPoint = color
	//EffectSetControlPointVector( fxHandle, 1, controlPoint )
#if SERVER
	local colorVec = color
	entity cpoint = CreateEntity( "info_placement_helper" )
	SetTargetName( cpoint, UniqueString( "pickup_controlpoint" ) )
	DispatchSpawn( cpoint )
	cpoint.SetOrigin( colorVec )
	entity glowFX = PlayFXWithControlPoint( effect, player.GetOrigin(), cpoint, -1, null, null, C_PLAYFX_LOOP )
	print(glowFX.e.fxControlPoints.len() > 0)
#endif
}*/

#if SERVER
array<entity> function DamageShieldsInRadiusOnEntity( entity weapon, entity inflictor, float radius, float damage )
{
	array<entity> damagedEnts = [] // used so that we only damage a shield once per function call
	array<string> shieldClasses = [ "mp_titanweapon_vortex_shield", "mp_titanweapon_shock_shield", "mp_titanweapon_heat_shield" ] // add shields that are like vortex shield/heat shield to this, they seem to be exceptions?

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
