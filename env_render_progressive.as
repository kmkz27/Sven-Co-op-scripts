/*
env_render_progressive
Author: kmkz (e-mail: al_basualdo@hotmail.com )

This renders gradually an entity from an amount to another.
starting from a initial value of the target entity(renderamt) to 
a final value (dmg).

--------------------------------------
important vars:

(TARGET ENTITY) renderamt: "FX amount"
initial render amount. Use values that are multiple of 5

dmg : "Render final value"
final render amount. Use values that are multiple of 5

speed : "Rendering time"
Time that will take to start rendering the entity until finish. With higher values will take longer.

health: "change solid render value"
value on render amount that will trigger the change in the solid state of the entity.
if the render amount is dropping will change from solid to non solid.
if the render amount is raising will change from non solid to solid.
Use values that are multiple of 5.

rendermode: "Render mode"
sets the rendermode of the target entity.

---------------------------------------

flags:

1: "Destroy target after use"
destroys the entity after use.

2: "Change solid value"
enables the usage of health|"change solid render value" check these for more information. 

4: "Render solid when finished"
entities will change its rendercolor while rendering. This changes the rendercolor to solid
when finished. 
*/

enum EnvRenderExpandedRemoveAfterTriggerFlag
{
	SF_REMOVE_AFTER_TRIGGER 		= 1 << 0,
	SF_CHANGE_SOLID					= 2 << 0,
	SF_RENDER_SOLID_ON_END			= 4 << 0,
}

class env_render_progressive : ScriptBaseEntity
{
	CBaseEntity@ pEntity = null;
		
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
	}

	void TriggerUse(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, self.pev.target );
		
		if (pEntity !is null)
		{	
			float renderamt_end = self.pev.dmg;
			float fIntervalTime = self.pev.speed / 100.0f;
			int iRepeats = int(abs((pEntity.pev.renderamt - renderamt_end )/ 5.0f));
			float fKillTime = (fIntervalTime * float (iRepeats)) + 0.05f;
			float fRenderOnTime = fKillTime ;
			pEntity.pev.rendermode = self.pev.rendermode;
						
			if (pEntity.pev.renderamt > renderamt_end )
			{
				g_Scheduler.SetInterval( "DeductRenderamt", fIntervalTime , iRepeats, @pEntity);
			
				if( self.pev.SpawnFlagBitSet( SF_REMOVE_AFTER_TRIGGER ) )
				{
					g_Scheduler.SetTimeout( "KillEntity", fKillTime, @pEntity); 
				}
				
				if ( self.pev.SpawnFlagBitSet( SF_CHANGE_SOLID ))
				{
					float fSolidTime = fIntervalTime *(abs((pEntity.pev.renderamt - self.pev.health )/ 5.0f));
					g_Scheduler.SetTimeout( "SolidNot", fSolidTime, @pEntity); 
				}
			}
		
			if (pEntity.pev.renderamt < renderamt_end ) 
			{
				g_Scheduler.SetInterval( "AddRenderamt", fIntervalTime , iRepeats, @pEntity);
				
				if( self.pev.SpawnFlagBitSet( SF_REMOVE_AFTER_TRIGGER ) )
				{
					g_Scheduler.SetTimeout( "KillEntity", fKillTime, @pEntity); 
				}
				
				if ( self.pev.SpawnFlagBitSet( SF_CHANGE_SOLID ))
				{
					float fSolidTime = fIntervalTime *(abs((pEntity.pev.renderamt - self.pev.health )/ 5.0f));
					g_Scheduler.SetTimeout( "SolidYes", fSolidTime, @pEntity); 
				}
				
				if( self.pev.SpawnFlagBitSet( SF_RENDER_SOLID_ON_END ) )
				{
					g_Scheduler.SetTimeout( "RenderSolidOnEnd", fRenderOnTime, @pEntity);
				}
			}
		}
	}
}

void AddRenderamt ( CBaseEntity@ pEntity)
{
	pEntity.pev.renderamt = pEntity.pev.renderamt + 5; 
}

void DeductRenderamt ( CBaseEntity@ pEntity)
{
	pEntity.pev.renderamt = pEntity.pev.renderamt - 5; 
}

void KillEntity (CBaseEntity@ pEntity)
{
	g_EntityFuncs.Remove( pEntity );
}

void SolidNot (CBaseEntity@ pEntity)
{
	pEntity.pev.solid = SOLID_NOT;
}
	
void SolidYes (CBaseEntity@ pEntity)
{
	pEntity.pev.solid = SOLID_BSP;
}

void RenderSolidOnEnd (CBaseEntity@ pEntity)
{
	pEntity.pev.rendermode = 4;
}

void Registerenv_render_progressive() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "env_render_progressive", "env_render_progressive" );
}