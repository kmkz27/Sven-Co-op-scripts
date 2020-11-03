/*
game_text_custom
Author: kmkz (e-mail: al_basualdo@hotmail.com )

This works game_text but with language options included.
Depending on the language selected it will display the right message.

---------------------------------------

flags:

1: "All players"
the message is shown to all players.

2: "No console echo"
WIP: Console echo is not displayed yet. 

*/

namespace GameTextCustom

{
	enum EnumLanguage
	{
		LANGUAGE_SPANISH		= 0 ,
		LANGUAGE_ENGLISH			,
		LANGUAGE_3					,
		LANGUAGE_4					,
		LANGUAGE_5					,
		LANGUAGE_6					,
		LANGUAGE_7					,
		LANGUAGE_8					,
	}
	
	int iLanguage = LANGUAGE_ENGLISH;
	
	enum EnumSpawnFlags
	{
		SF_ALL_PLAYERS			= 1 << 0,
		//SF_NO_CONSOLE_ECHO 	= 2	<< 0,
	}
	 
	class game_text_custom : ScriptBaseEntity
	{
		HUDTextParams textParams;
		string message2 = "";
		string message3 = "";
		string message4 = "";
		string message5 = "";
		string message6 = "";
		string message7 = "";
		string message8 = "";
		
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
		
		bool KeyValue( const string& in szKey, const string& in szValue )
		{
			if(szKey == "channel")
			{
			textParams.channel = atoi (szValue);
    		return true;
			}
			else if(szKey == "x")
			{
			textParams.x = atof (szValue);
    		return true;
			}
			else if(szKey == "y")
			{
				textParams.y = atof (szValue);
				return true;
			}
			else if(szKey == "effect")
			{
				textParams.effect = atoi(szValue );
				return true;
			}
			else if(szKey == "color")
			{
				string delimiter = " ";
				array<string> splitColor = {"","","",""};
				splitColor = szValue.Split(delimiter);
				array<uint8>result = {0,0,0,0};
				result[0] = atoi(splitColor[0]);
				result[1] = atoi(splitColor[1]);
				result[2] = atoi(splitColor[2]);
				result[3] = atoi(splitColor[3]);
				if (result[0] > 255) result[0] = 255;
				if (result[1] > 255) result[1] = 255;
				if (result[2] > 255) result[2] = 255;
				if (result[3] > 255) result[3] = 255;
				RGBA vcolor = RGBA(result[0],result[1],result[2],result[3]);
				textParams.r1 = vcolor.r;
				textParams.g1 = vcolor.g;
				textParams.b1 = vcolor.b;
				textParams.a1 = vcolor.a;
				return true;
			}
			else if(szKey == "color2")
			{
				string delimiter2 = " ";
				array<string> splitColor2 = {"","","",""};
				splitColor2 = szValue.Split(delimiter2);
				array<uint8>result2 = {0,0,0,0};
				result2[0] = atoi(splitColor2[0]);
				result2[1] = atoi(splitColor2[1]);
				result2[2] = atoi(splitColor2[2]);
				result2[3] = atoi(splitColor2[3]);
				if (result2[0] > 255) result2[0] = 255;
				if (result2[1] > 255) result2[1] = 255;
				if (result2[2] > 255) result2[2] = 255;
				if (result2[3] > 255) result2[3] = 255;
				RGBA vcolor2 = RGBA(result2[0],result2[1],result2[2],result2[3]);
				textParams.r2 = vcolor2.r;
				textParams.g2 = vcolor2.g;
				textParams.b2 = vcolor2.b;
				textParams.a2 = vcolor2.a;
				return true;
			}
			else if(szKey == "fadein")
			{
				textParams.fadeinTime = atof(szValue);
				return true;
			}
			else if(szKey == "fadeout")
			{
				textParams.fadeoutTime = atof(szValue);
				return true;
			}
			else if(szKey == "holdtime")
			{
				textParams.holdTime = atof(szValue);
				return true;
			}
			else if(szKey == "fxtime")
			{
				textParams.fxTime = atof(szValue);
				return true;
			}
			else if(szKey == "message2")
			{
				message2 = szValue;
				return true;
			}
			else if(szKey == "message3")
			{
				message3 = szValue;
				return true;
			}
			else if(szKey == "message4")
			{
				message4 = szValue;
				return true;
			}
			else if(szKey == "message5")
			{
				message5 = szValue;
				return true;
			}
			else if(szKey == "message6")
			{
				message6 = szValue;
				return true;
			}
			else if(szKey == "message7")
			{
				message7 = szValue;
				return true;
			}
			else if(szKey == "message8")
			{
				message8 = szValue;
				return true;
			}
			else 
			{
				return BaseClass.KeyValue( szKey, szValue );
			}
		}
		
		void TriggerUse(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
			
			if ( self.pev.SpawnFlagBitSet (SF_ALL_PLAYERS) )
			{
				if (iLanguage == LANGUAGE_SPANISH) 	{g_PlayerFuncs.HudMessageAll( textParams, self.pev.message );}
				if (iLanguage == LANGUAGE_ENGLISH) 	{g_PlayerFuncs.HudMessageAll( textParams, message2 );}
				if (iLanguage == LANGUAGE_3)		{g_PlayerFuncs.HudMessageAll( textParams, message3 );}
				if (iLanguage == LANGUAGE_4) 		{g_PlayerFuncs.HudMessageAll( textParams, message4 );}
				if (iLanguage == LANGUAGE_5) 		{g_PlayerFuncs.HudMessageAll( textParams, message5 );}
				if (iLanguage == LANGUAGE_6) 		{g_PlayerFuncs.HudMessageAll( textParams, message6 );}
				if (iLanguage == LANGUAGE_7) 		{g_PlayerFuncs.HudMessageAll( textParams, message7 );}
				if (iLanguage == LANGUAGE_8) 		{g_PlayerFuncs.HudMessageAll( textParams, message8 );}
			}
			else
			{
				if ( pActivator.IsPlayer())
				{
					if (iLanguage == LANGUAGE_SPANISH) 	{g_PlayerFuncs.HudMessage( pPlayer, textParams, self.pev.message );}
					if (iLanguage == LANGUAGE_ENGLISH)	{g_PlayerFuncs.HudMessage( pPlayer, textParams, message2 );}
					if (iLanguage == LANGUAGE_3)		{g_PlayerFuncs.HudMessage( pPlayer, textParams, message3 );}
					if (iLanguage == LANGUAGE_4) 		{g_PlayerFuncs.HudMessage( pPlayer, textParams, message4 );}
					if (iLanguage == LANGUAGE_5) 		{g_PlayerFuncs.HudMessage( pPlayer, textParams, message5 );}
					if (iLanguage == LANGUAGE_6) 		{g_PlayerFuncs.HudMessage( pPlayer, textParams, message6 );}
					if (iLanguage == LANGUAGE_7) 		{g_PlayerFuncs.HudMessage( pPlayer, textParams, message7 );}
					if (iLanguage == LANGUAGE_8) 		{g_PlayerFuncs.HudMessage( pPlayer, textParams, message8 );}
				}
			}
		}
	}
	
	void Register()
	{
		g_CustomEntityFuncs.RegisterCustomEntity( "GameTextCustom::game_text_custom", "game_text_custom" );
	}
}