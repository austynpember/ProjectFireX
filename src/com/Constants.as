package com  
{
	[Bindable]
	public class Constants
	{
		// Game Modes
		public static const GOTOINTRO:String = "IntroScreen";
		public static const STARTGAME:String = "Interface";
		public static const SAVEGAME:String = "Save Game";
		public static const LOADGAME:String = "Load Game";
		public static const PAUSETOGGLE:String = "Pause Toggle";
		public static const PAUSEGAME:String = "Pause Game";
		public static const UNPAUSEGAME:String = "UNPause Game";
		
		// Game Extra Menus
		public static const GOTOOPTIONS:String = "Options";
		public static const GOTOHELP:String = "Help";
		public static const GOTOHIGHSCORE:String = "Highscore";
		public static const DEBUG:String = "Debug";
		
		// Scoring
		public static const SCORE:String = "Score";
		public static const CALCSCORE:String = "Calculate Score";
		public static const CALLSCORE:String = "Call Score";
		public static const DRONEPTS:int = 10;
		public static const SHOOTERPTS:int = 15;
		public static const SMART1PTS:int = 20;
		public static const SMART2PTS:int = 25;
		public static const BOSS1PTS:int = 50;
		public static const BOSS2PTS:int = 75;
		public static const BOSS3PTS:int = 100;
		public static const BOSS4PTS:int = 150;
		public static const SINGLEPTS:int = -1;
		
		// Game Dimensions
		public static const GAMEWIDTH:int = 800;
		public static const GAMEHEIGHT:int = 600;
		
		// Damage
		public static const DMG:String = "Damage";
		public static const ENEMYDMG:String = "EnemyDamage";
		public static const LDMG:int = 5;
		public static const BEAMDMG:int = 1;
		public static const DRONEDMG:int = 20;
		public static const SHOOTERDMG:int = 15;
		public static const SMART1DMG:int = 15;
		public static const SMART2DMG:int = 25;
		
		// Level
		public static const LEVEL:String = "Level";
		
		// Rates
		public static const SPAWNRATE:Number = .2;
		
		// Extra
		public static const ITEMBOXHEALTH:int = -20;
		public static const HEALTH:int = 100;
		
		// Weapons
		public static const FIRENORMAL:String = "Fire Normal";
		public static const LASERONE:String = "Laser One";
		public static const LASERTWO:String = "Laser Two";
		public static const LASERTHREE:String = "Laser Three";
		public static const BEAM:String = "Beam";
		public static const WPN:String = "Weapon";
		
		// Bosses
		public static const BOSS1HEALTH:int = 130;
		public static const BOSS2HEALTH:int = 200;
		public static const BOSS3HEALTH:int = 300;
		public static const BOSS4HEALTH:int = 600;
		
		// MISC
		public static const RESET:String = "Reset";
		public static const EXP:String = "Explosion";
		public static const ERP:String = "Eruption";
		public static const WARP:String = "Warp";
		public static const VOLUME:Number = 0.05;
		public static const VOLUMEMED:Number = 0.2;
		public static const VOLUMEHIGH:Number = 0.5;
		public static const PLAYFADE:String = "Play Fade";
		
		// ITEMS
		public static const HEALTHITEM:String = "Health Item";
		public static const LASERITEM:String = "Laser Item";
		public static const NUKEITEM:String = "Nuke Item";
		public static const NUKE:String = "Nuke";
		
		// Passwords / Labels / DEBUG
		public static const DEBUGPASSWORD:String = "han123";
		public static const CLEARBOSSHEALTH:String = "Clear Boss Health";
		
		// SERVER
		public static const BASE_SERVICE_URL:String = "http://pfx-leaderboard.hanson-dev.com";
		public static const SAVE_SCORES_URL:String =  "/Score/Save";
		public static const SCORES_URL:String = "/Score";
		public static const GAMEID:String = "?gameID=8cb7c1a6-1545-4c3b-8e06-41f9021f4d91";
		
		//Game Version
		public static const GAME_VERSION:int = 1.0;
		
		public function Constants() {
		}
	}
}