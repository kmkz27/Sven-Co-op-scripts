/*
multi_target
Author: kmkz (e-mail: al_basualdo@hotmail.com)
This entity manages the target of an entity modifying and firing it following a pattern using this format:
keyvalue = prefix + variable value + suffix.

example:
target					= changevalue_solid (a trigger_changevalue that will turn some func_wall into non solid)
prefix 					= wall
suffix					= _big_room
initial variable value	= 2
final variable value	= 22
triggering time			= 20
Keyvalue to use			= targetname

when the multi_target is triggered this will happen:
the trigger_changevalue will be activated targeting entity with targetname wall2_big_room at 0 seconds.
then the same with wall3_big_room at 1 seconds.
then wall4_big_room at 2 seconds.
then wall5_big_room at 3 seconds.
then wall6_big_room at 4 seconds.
...
then wall22_big_room at 20 seconds

--------------------------------------
important vars:
target: entity whose target will be affected.
If target is !direct this entity will trigger entities directly following the prefix/suffix pattern.
If target is !killtarget the same as above but instead these entities will be destroyed. 
prefix(netname): first part of the name of the target entity of the multi_target target entity. (prefix and suffix can be an empty value)
suffix(message): last part of the name of the target entity of the multi_target target entity.
triggering time(speed): time length during the target will execute its tasks.
initial variable value(frags): initial number value that is between the prefix and suffix.
last variable value(health): last number value that is between the prefix and suffix.
Keyvalue to use: (noise): Keyvalue that will be used in the prefix/suffix pattern. By default is targetname but it can be any other.
---------------------------------------
flags:
1: "start on"
the multi_target will be triggered when the map starts.
4: "looped"
this will entity after finishing will trigger again. Trigger the multi_target again to stop it.
8: "Activate once"
instead of trigger all the targets it will trigger just one, trigger it againt to fire the next one.
16: "Do not trigger"
This will change the target normally but nothing will be fired.

---------------------------------------
To do: test delay
*/

enum MultiTargetSpawnFlag
{
	SF_START_ON 			= 1  << 0,
	SF_LOOPED	 			= 4  << 0,
	SF_ACTIVATE_ONCE		= 8  << 0,
	SF_DO_NOT_TRIGGER		= 16 << 0,
}

class multi_target : ScriptBaseEntity
{
	CBaseEntity@ pEntity = null;
	int iMax;
	string sPrefix;
	string sSuffix;
	float fInitialDelay = 0;
	float fDelay;
	string sKeyvalue;
	int i = 1;
		
	void Precache() 
	{
		BaseClass.Precache();
	}
	
	void Spawn() 
	{
		self.pev.movetype 		= MOVETYPE_NONE;
		self.pev.solid 			= SOLID_NOT;
		self.pev.framerate 		= 1.0f;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );
		SetUse(UseFunction(this.TriggerUse));
		self.Precache();
		
		if ( self.pev.SpawnFlagBitSet( SF_START_ON ))
		{
			SetThink(ThinkFunction(this.ThinkOn));
			self.pev.nextthink = g_Engine.time + fDelay;
		}	
		
		iMax = int (self.pev.health);
		float fTimeLength = self.pev.speed;
		fDelay = fTimeLength/float(iMax);
		sPrefix = self.pev.netname;
		sSuffix = self.pev.message;
		sKeyvalue = self.pev.noise;
		i = int(self.pev.frags);
	}
	
	bool KeyValue( const string& in szKey, const string& in szValue )
		{
			if(szKey == "delay")
			{
				fInitialDelay = atof(szValue);
				return true;
			}
			else 
			{
				return BaseClass.KeyValue( szKey, szValue );
			}
		}

	void TriggerUse(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		flValue = fInitialDelay;
		SetThink(ThinkFunction(this.ThinkOn));
		self.pev.nextthink = g_Engine.time + fDelay;
		if ( self.pev.SpawnFlagBitSet (SF_LOOPED) )	
		{
			SetUse(UseFunction(this.TriggerUseOff));
		}
	}
	
	void TriggerUseOff(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		if ( self.pev.SpawnFlagBitSet (SF_LOOPED) )	
		{
			SetThink(ThinkFunction(this.ThinkOff));
			SetUse(UseFunction(this.TriggerUse));
		}
	}
	
	void ThinkOn()
	{
		CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByTargetname( @pEntity, self.pev.target );
		CBaseEntity@ pTargetEntity = g_EntityFuncs.FindEntityByString( @pTargetEntity, sKeyvalue, sPrefix + string(i) + sSuffix );
				
		if (i <= iMax)
		{
			if (@pEntity != null) 
			{
				pEntity.pev.target = pTargetEntity.pev.targetname;
			}
			
			if ( self.pev.SpawnFlagBitSet (SF_KILLTARGET) )
			{
				CBaseEntity@ killentity = g_EntityFuncs.FindEntityByString( @killentity, sKeyvalue, sPrefix + string(i) + sSuffix );
				g_EntityFuncs.Remove( killentity );
				SetThink(ThinkFunction(this.ThinkOff));
			}
			else
			{
				if ( self.pev.SpawnFlagBitSet (SF_DO_NOT_TRIGGER))
				{
			
				}
				else
				{
					if (self.pev.target != "!direct")
					{
						g_EntityFuncs.FireTargets(self.pev.target, null, null, USE_TOGGLE, 0.0f, 0.0f);
					}
					else
					{
						g_EntityFuncs.FireTargets(pTargetEntity.pev.targetname, null, null, USE_TOGGLE, 0.0f, 0.0f);
					}
				}
			}
			i++;
			
			if ( self.pev.SpawnFlagBitSet (SF_ACTIVATE_ONCE) )
			{
				SetThink(ThinkFunction(this.ThinkOff));
			}
			
			self.pev.nextthink = g_Engine.time + fDelay;
		}
		else
		{
			i = int(self.pev.frags);
			
			if ( self.pev.SpawnFlagBitSet (SF_ACTIVATE_ONCE) )
			{
				SetThink(ThinkFunction(this.ThinkOff));
			}
			
			if ( self.pev.SpawnFlagBitSet (SF_LOOPED) )	
			{
				self.pev.nextthink = g_Engine.time + fDelay;
			}
			else
			{
				SetThink(ThinkFunction(this.ThinkOff));
			}
		}
	}
	
	void ThinkOff()
	{

	}
}

void Registermulti_target() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "multi_target", "multi_target" );
}