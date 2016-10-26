package com.Levels
{
	import com.Constants;
	import com.Environments.Earth;
	import com.Environments.EarthLevel;
	import com.Environments.Environment;
	import com.Environments.Planet1;
	import com.Environments.Skybox;
	import com.Environments.Skybox2;
	import com.Environments.StarField;
	import com.Objects.flyingObjs.inatimate.Asteroid;
	import com.Objects.flyingObjs.inatimate.GasCloud;
	import com.Objects.flyingObjs.inatimate.InanimateObject;
	import com.Objects.flyingObjs.inatimate.Item;
	import com.Objects.flyingObjs.inatimate.Wreckage;
	import com.Objects.flyingObjs.projectile.EnemyProjectile;
	import com.Ships.Boss1;
	import com.Ships.Boss2;
	import com.Ships.Boss3;
	import com.Ships.Boss4;
	import com.Ships.Drone;
	import com.Ships.Ship;
	import com.Ships.Shooter;
	import com.Ships.Smart1;
	import com.Ships.Smart2;
	import com.adobe.serialization.json.*;
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.clearInterval;
	import flash.utils.getDefinitionByName;
	import flash.utils.setInterval;
	
	import org.papervision3d.objects.DisplayObject3D;
	
	public class Level
	{
		// This is the tracking(counting) number that operates the cycle of spawns
		/** This is the most critical part of the level.  It is incremented in the gameController update()
		 * it will increment, the CheckObjects function will check against this to determine when to release whatever object
		 * is at the current number of the tracker */
		public static var tracker:Number = 1;
		/** determines which level to Load up*/
		public static var currentLevel:int = 1;
		
		// This is going to be the registry of the object array
		private static var _registry:Array;
		
		// Game Interval - Every 50 ms, check tracker against trigger points in object array.
		private static var _gameInterval:uint;
		
		// instantiate instances of objects in order for the classes to be made
		private var _ast:Asteroid;
		private var _wreck:Wreckage;
		private var _item:Item;
		private var _gasCloud:GasCloud;
		
		private var _drone:Drone;
		private var _shooter:Shooter;
		private var _boss:Boss1;
		private var _boss2:Boss2;
		private var _boss3:Boss3;
		private var _boss4:Boss4;
		private var _smart1:Smart1;
		private var _smart2:Smart2;
		
		private var _earthLevel:EarthLevel;
		private var _starField:StarField;
		private var _skybox:Skybox;
		private var _skybox2:Skybox2;
		private var _earth:Earth;
		private var _planet1:Planet1;
		
		// Containers
		private var _levelContainer:DisplayObject3D;
		private var _enemyContainer:DisplayObject3D;
		
		// Class Objects
		private var tmpClass:Class;
		private var retVal:DisplayObject3D;
		
		// JSON
		private var _levelLoader:URLLoader;
		private var _objsDehydrated:String;
		private var _objsRehydrated:Array;
		
		private static var _increment:Number = Constants.SPAWNRATE;
		
		
		[Embed(source="assets/Sound/Levels/Level1_SFX.mp3")] 
		private static var soundAsset1:Class;
		private static var bossSound:Sound = new soundAsset1() as Sound;
		[Embed(source="assets/Sound/Levels/Level2_SFX.mp3")] 
		private static var soundAsset2:Class;
		private static var sound2:Sound = new soundAsset2() as Sound;
		[Embed(source="assets/Sound/Levels/Level3_SFX.mp3")] 
		private static var soundAsset3:Class;
		private static var sound3:Sound = new soundAsset3() as Sound;
		[Embed(source="assets/Sound/Levels/Level4_SFX.mp3")] 
		private static var soundAsset4:Class;
		private static var sound4:Sound = new soundAsset4() as Sound;
		
		[Embed(source="assets/Sound/Levels/Level1Music_SFX.mp3")] 
		private static var soundAsset5:Class;
		private static var music1:Sound = new soundAsset5() as Sound;
		[Embed(source="assets/Sound/Levels/Level2Music_SFX.mp3")] 
		private static var soundAsset6:Class;
		private static var music2:Sound = new soundAsset6() as Sound;
		[Embed(source="assets/Sound/Levels/Level3Music_SFX.mp3")] 
		private static var soundAsset7:Class;
		private static var music3:Sound = new soundAsset7() as Sound;
		[Embed(source="assets/Sound/Levels/Level4Music_SFX.mp3")] 
		private static var soundAsset8:Class;
		private static var music4:Sound = new soundAsset8() as Sound;
		
		private static var stH:SoundTransform = new SoundTransform(Constants.VOLUMEHIGH);
		private static var stM:SoundTransform = new SoundTransform(Constants.VOLUMEMED);
		private static var stL:SoundTransform = new SoundTransform(Constants.VOLUME);
		private static var myCurrentChannel:SoundChannel = new SoundChannel();
		private static var myCurrentSound:Sound;
		private static var pausePosition:Number = 0;
		private static var currentLoops:int = 5;
		private static var currentST:SoundTransform;
		private static var first:Boolean = true;
		
		
		/**
		 * This is the main function that will pause the game and all objects 
		 * in it by calling the pause methods in the shell objects.
		 * @param levelContainer @param enemyContainer @param levelNumber
		 * @return
		 */
		public function Level(levelContainer:DisplayObject3D, enemyContainer:DisplayObject3D, levelNumber:int)
		{
			_levelContainer = levelContainer;
			_enemyContainer = enemyContainer;
			currentLevel = levelNumber;
			init();
		}
		
		private function init():void {
			_registry = new Array;
			updateLevel(currentLevel);
		}
		/**
		 * Called from the gameLoop() inside of gameController. Increments tracker for checkObjects().
		 * @return
		 */
		public static function updateTracker():void {
			//This is updated on the main GameController game loop.
			tracker += _increment;
		}
		/**
		 * Pauses the sound. Called from gameController.
		 * @return
		 */
		public static function pauseSound():void {
			trace("pause Sound");
			if( (myCurrentChannel as SoundChannel).hasEventListener(Event.SOUND_COMPLETE)) {
				trace("remove Sound Complete");
				(myCurrentChannel as SoundChannel).removeEventListener(Event.SOUND_COMPLETE, playNextSound);
			}
			if(myCurrentChannel && myCurrentSound) {
				trace("paused?");
				pausePosition = myCurrentChannel.position;
				myCurrentChannel.stop();
			}
		}
		/**
		 * UNPauses the sound. Called from gamweController.
		 * @return
		 */
		public static function unpauseSound(e:Event = null):void {
			trace("unPause Sound");
			if( myCurrentChannel.hasEventListener(Event.SOUND_COMPLETE)) {
				myCurrentChannel.removeEventListener(Event.SOUND_COMPLETE, unpauseSound);
			}
			if(myCurrentChannel && myCurrentSound) myCurrentChannel = myCurrentSound.play(pausePosition,0,currentST);
			(myCurrentChannel as SoundChannel).addEventListener(Event.SOUND_COMPLETE, playNextSound);
		}
		/**
		 * This will update the level with the parameter. Destroys any registrys,
		 * and clears level registry. Then calls loadJSON.
		 * @param newLevel
		 * @return
		 */
		public function updateLevel(newLevel:int):void {
			clearLevel();
			currentLevel = newLevel;
			first = true;
			loadJSON(currentLevel);
			//Reset tracker for new level
			tracker = 1;
		}
		// 
		// *** JSON LOADING ***
		//
		/**
		 * creates a URLRequest and finds the current levels JSON file, then sets up the soundSequence for that level.
		 * @param currentLevel
		 * @return
		 */
		private function loadJSON(currentLevel:int):void
		{
			_levelLoader = new URLLoader();
			_levelLoader.load(new URLRequest("level" + currentLevel + ".JSON"));
			_levelLoader.addEventListener(Event.COMPLETE, parseJSON);
			
			setUpSound();
		}	
		private function setUpSound():void {
			switch(currentLevel) {
				case 1:
					myCurrentChannel = music1.play(0,5,stL);
					myCurrentSound = music1;
					currentLoops = 5;
					currentST = stL;
					break;
				case 2:
					myCurrentChannel = sound2.play(0,0,stM);
					myCurrentSound = sound2;
					currentLoops = 0;
					currentST = stM;
					myCurrentChannel.addEventListener(Event.SOUND_COMPLETE, playNextSound);
					break;
				case 3:
					myCurrentChannel = sound3.play(0,0,stM);
					myCurrentSound = sound3;
					currentLoops = 0;
					currentST = stM;
					myCurrentChannel.addEventListener(Event.SOUND_COMPLETE, playNextSound);
					break;
				case 4:
					myCurrentChannel = sound4.play(0,0,stM);
					myCurrentSound = sound4;
					currentLoops = 0;
					currentST = stM;
					myCurrentChannel.addEventListener(Event.SOUND_COMPLETE, playNextSound);
					break;
			}
		}
		private static function playNextSound(e:Event):void {
			(myCurrentChannel as SoundChannel).removeEventListener(Event.SOUND_COMPLETE, playNextSound);
			
			if(first) {
				switch (currentLevel) {
					case 1:
						myCurrentSound = music1;
						break;
					case 2:
						myCurrentSound = music2;
						break;
					case 3:
						myCurrentSound = music3;
						break;
					case 4:
						myCurrentSound = music4;
						break;
				}
				currentLoops = 4;
			}
	
			myCurrentChannel = myCurrentSound.play(0,currentLoops,currentST);
			currentLoops -= 1;
			first = false;
		}
		/**
		 * ParseJSON takes the URLLOADER JSON file and decode it and put it in createLevelRegistry
		 * @param e
		 * @return
		 */
		private function parseJSON(e:Event):void
		{
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, parseJSON);
			_objsDehydrated = (e.target as URLLoader).data as String;
			_objsRehydrated = JSON.decode(_objsDehydrated);
			createLevelRegistry(_objsRehydrated);
		}
		/**
		 * Takes the objects of the parseJSON and pushes them into the _registry. Then set up the _gameInterval.
		 * @param _objsRehydrated
		 * @return
		 */
		private function createLevelRegistry(_objsRehydrated:Array):void 
		{
			for each (var nextObject:Object in _objsRehydrated)
			{
				 _registry.push(nextObject);
			}
			_gameInterval = setInterval(checkObjects, 150);
		}
		/**
		 * Resume the current Sequence. Called after Boss4 Intro music is hit.
		 * @param $evt
		 * @return
		 */
		
		//
		// Object CREATION
		//
		
		private function checkObjects():void
		{
			// This function will cycle through the registry array and create new temporary classes that will be then converted
			// into tmpClasses (DisplayObject3D.)  This is done based on the tracker(counter) overtaking the release trigger on
			// the specific object.
			var _usedItems:Array = [];
			
			for (var i:uint = 0; i < _registry.length; i++) {
				var nextObject:Object = _registry[i];
				
				if (nextObject.trigger > tracker) {
					break;
				}
				if (nextObject.trigger <= tracker) {
					switch (nextObject.type)
					{
						case "Asteroid":
						case "Wreckage":
						case "GasCloud":
							tmpClass = getDefinitionByName("com.Objects.flyingObjs.inatimate." + nextObject.type) as Class;
							retVal = new tmpClass(nextObject.x, nextObject.y, nextObject.z, _levelContainer) as DisplayObject3D;
							break;
						
						case "Item":
							tmpClass = getDefinitionByName("com.Objects.flyingObjs.inatimate." + nextObject.type) as Class;
							retVal = new tmpClass(nextObject.x, nextObject.y, nextObject.z, _levelContainer, nextObject.kind ) as DisplayObject3D;
							break;
						
						case "Drone":
						case "Shooter":
							tmpClass = getDefinitionByName("com.Ships." + nextObject.type) as Class;
							retVal = new tmpClass(nextObject.x, nextObject.y, nextObject.z, nextObject.xVel, nextObject.zVel, _enemyContainer ) as DisplayObject3D;
							break;
						
						case "Smart1":
						case "Smart2":
							tmpClass = getDefinitionByName("com.Ships." + nextObject.type) as Class;
							retVal = new tmpClass(nextObject.x, nextObject.y, nextObject.z, _enemyContainer ) as DisplayObject3D;
							break;
						
						case "Boss1":
						case "Boss2":
						case "Boss3":
						case "Boss4":
							tmpClass = getDefinitionByName("com.Ships." + nextObject.type) as Class;
							retVal = new tmpClass(nextObject.x, nextObject.y, nextObject.z, _enemyContainer, _levelContainer ) as DisplayObject3D;
							break;
						
						case "EarthLevel":
						case "StarField":
						case "Skybox":
						case "Earth":
						case "Planet1":
						case "Skybox2":
							tmpClass = getDefinitionByName("com.Environments." + nextObject.type) as Class;
							retVal = new tmpClass(nextObject.x, nextObject.y, nextObject.z, _levelContainer ) as DisplayObject3D;
							break;
						
						case "Boss4IntroMusic":
							pauseSound();
							myCurrentChannel = bossSound.play(0,0,stH);
							myCurrentChannel.addEventListener(Event.SOUND_COMPLETE, unpauseSound);
							break;
						
						default:
							trace("No object Type");
					} // End Switch
					
					_usedItems.push(i); // Push the key into the used items array
					
				} // End IF nextObject.trigger <= tracker
				
			} // End FOR registry.length
			
			_usedItems.reverse();	// Make sure we're removing items from the array last to first
			
			for (i = 0; i < _usedItems.length; i++) 
			{
				_registry.splice(i, 1);
			}
			
			if (_registry.length <= 0) // If the registry is empy, stop the gameinterval check counter.
			{ 
				clearInterval(_gameInterval);
			}
		} // End checkObjects
		/** Hard clear, comes from a GameController Exit call or internally If switching level in Debug Mode.
		 * @return
		 */
		public function cancelTimer():void {
			// Hard clear, comes from a GameController Exit call.
			clearInterval(_gameInterval);
			for (var x:int = _registry.length - 1; x >= 0; x--) {
				_registry.pop();
			}
		}
		private function clearLevel():void {
			
			if (_gameInterval) {
				trace("There is a Game Interval Currently Running");
				clearInterval(_gameInterval);
			}
			//Stop current sound
			if(myCurrentChannel) myCurrentChannel.stop();
			
			for (var v:int = Environment.registry.length - 1; v >= 0; v--) {
				Environment.registry[v].destroy();
			}
			// Clear enemy projectile
			EnemyProjectile.pauseAll();
			for (var n:int = EnemyProjectile.registry.length - 1; n >= 0; n--) {
				EnemyProjectile.registry[0].destroy();
			}
			
			for (var s:int = Ship.registry.length - 1; s >= 1; s--) {
			// Leave one for the Player
				Ship.registry[s].destroy();
			}
			for (var i:int = InanimateObject.registry.length - 1; i >= 0; i--) {
				InanimateObject.registry[i].destroy();
			}
			//This is for the debug mode for a quick deletion of the JSON registry.
			for (var x:int = _registry.length - 1; x >= 0; x--) {
				_registry.pop();
			}
		}
	} // End Class
} // End Package