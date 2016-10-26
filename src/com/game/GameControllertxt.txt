
package com.game    
{

	import com.Constants;
	import com.Levels.*;
	import com.Environments.Environment;
	import com.Objects.*;
	import com.Objects.flyingObjs.inatimate.InanimateObject;
	import com.Objects.flyingObjs.projectile.EnemyProjectile;
	import com.Objects.flyingObjs.projectile.Projectile;
	import com.Ships.*;
	import com.adobe.serialization.json.*;
	import com.Effects.Eruption;
	import com.Effects.SphereBang;
	import com.Effects.Warp;
	
	import events.*;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.ui.*;
	import flash.utils.getTimer;
	
	import mx.controls.Label;
	
	import org.flintparticles.common.emitters.Emitter;
	import org.flintparticles.common.events.EmitterEvent;
	import org.flintparticles.integration.papervision3d.PV3DPixelRenderer;
	import org.flintparticles.integration.papervision3d.PV3DRenderer;
	import org.flintparticles.threeD.emitters.Emitter3D;
	import org.papervision3d.core.effects.BitmapLayerEffect;
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.materials.BitmapColorMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	
	[SWF (width="800", height = "600", backgroundColor="0x0000FF", frameRate="30")] 
	
	/**
	 * @author Austyn Pember
	 * @version 1.0
	 */
	
	public class GameController extends BasicView
	{
		//TEMP
		private var _name:String = "GameController";
		private var _begin:Label;
		
		//Debug mode flag
		public static var debug:Boolean = false;
		
		// Game Objects
		/** Player 1 is the Class reference for the player1.  Created explicitly in GameController createObjects */
		public static var player1 : Player;
		private static var plane1:Plane;
		private static var plane2:Plane;
		/** Holds the Player, and the Bounding Auras. */
		public static var gameContainer : DisplayObject3D; 
		/** Holds all the Enemies, Projectiles, and Items. */
		public static var enemyContainer : DisplayObject3D;
		/** Holds the Level, and certain inanimate projectiles. */
		public static var levelContainer : DisplayObject3D;
		
		// Level and score info
		private var _level:Level;
		public static var currentLevel:int = 1;
		/** Used for save/load, and score gathering */
		public static var currentScore:int;
		private static var _lastSavedScore:int;
		
		// Paused info
		private static var _paused:Boolean = false;
		public static function get paused():Boolean {
			return _paused;
		}
		/**
		 * This is the main function that will pause the game and all objects in it by calling the pause methods in the shell objects.
		 * @param p
		 * @return
		 */
		public static function set paused(p:Boolean):void {
			_paused = p
			if(_paused){
				InanimateObject.pauseAll(); 
				Ship.pauseAll(); 
				Projectile.pauseAll(); 
				EnemyProjectile.pauseAll(); 
				Environment.pauseAll(); 
				Level.pauseSound(); 
			}
			else{
				InanimateObject.unpauseAll();
				Ship.unpauseAll();
				Projectile.unpauseAll();
				EnemyProjectile.unpauseAll();
				Environment.unpauseAll();
				Level.unpauseSound();
			}
		}
		// Camera Info
		private var pitch : Number = 0; 
		private var targetPitch : Number = 0; 
		private var yaw : Number = 0; 
		private var targetYaw : Number = 0; 
		
		// Mouse info
		public var lastMousePoint : Point = new Point(); 
		public var isMouseDown : Boolean = false; 
		
		//KEYCODES
		private static const SPACE:int = 32;
		private static const LEFT:int = 37;
		private static const UP:int = 38;
		private static const RIGHT:int = 39;
		private static const DOWN:int = 40;
		private static const ZERO:int = 48;
		private static const NINE:int = 57;
		private static const A:int = 65;
		private static const D:int = 68;
		private static const B:int = 66;
		private static const W:int = 87;
		private static const S:int = 83;
		
		/** Holds the current players Log-in Name. */
		public static var playerName:String = "Austyn";
		/** Holds the weapon which the player is currently using */
		public static var playerWeapon:int;
		/** Holds the number of nukes the player has */
		public static var playerNuke:int;
		//public var so:SharedObject = SharedObject.getLocal("userData");
		
		// Flint
		private var emitter:Emitter3D;
		private var bitmapEffectLayer:BitmapEffectLayer;
		private var bfx:BitmapEffectLayer;
		private var pv3dRenderer:PV3DPixelRenderer;
		private var pixels:Pixels;
		private var vector:Vector3D;
		private var flintRenderer:PV3DRenderer;
		
		// FPS Meter
		private var startTime:Number;  
		private var framesNumber:Number = 0;  
		private var fps:TextField = new TextField();  
		
		//Sound	
		[Embed(source="assets/Sound/Explosions/Exp4_SFX.mp3")] 
		private var soundAsset1:Class;
		[Embed(source="assets/Sound/Explosions/Exp5_SFX.mp3")] 
		private var soundAsset2:Class;
		[Embed(source="assets/Sound/Explosions/Exp6_SFX.mp3")] 
		private var soundAsset3:Class;
		[Embed(source="assets/Sound/Explosions/Exp7_SFX.mp3")] 
		private var soundAsset4:Class; 
		private var sound1:Sound = new soundAsset1() as Sound;
		private var sound2:Sound = new soundAsset2() as Sound;
		private var sound3:Sound = new soundAsset3() as Sound;
		private var sound4:Sound = new soundAsset4() as Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUMEMED);
		
		/**
		 * This is the visual and intantiatory part of the FPS meter 
		 * @return
		 */
		private function fpsCounter():void  {  
			startTime = getTimer();  
			fps.textColor = 0xFFFFFF;
			fps.y = 100;
			addChildAt(fps, 1);  
			addEventListener(Event.ENTER_FRAME, checkFPS);  
		}     
		/**
		 * This is the FPS meter that runs on the top left of the screen.
		 * @param e
		 * @return
		 */
		private function checkFPS(e:Event):void {  
			var currentTime:Number = (getTimer() - startTime) / 1000;  
			framesNumber++;  
			if (currentTime > 1)  {  
				fps.text = "FPS: " + (Math.floor((framesNumber/currentTime)*10.0)/10.0);  
				startTime = getTimer();  
				framesNumber = 0;  
			}  
		}   
		/**
		 * Load Game method that looks at the Shared object and pulls all the infomation from it
		 * @return
		 */
		public static function loadGame():void
		{
			// Call from a flex component that lands inside ProjectFireX.
			var so:SharedObject = SharedObject.getLocal("userData");
			var username:String = so.data.username;
			var level:String = so.data.inLevel;
			var score:String = so.data.inScore;
			playerWeapon = so.data.inWeapon;
			playerNuke = so.data.inNuke;
			
			trace("Loaded Data :");
			trace(username);
			trace(level);
			trace(playerWeapon);
			trace(score);
			trace(playerNuke);
		}
		/**
		 * SaveGame will grab all relative information and store it in the SharedObject.
		 * @return
		 */
		public static function saveGame():void
		{
			// Call from a flex component that lands inside ProjectFireX.
			var so:SharedObject = SharedObject.getLocal("userData")
			so.data.username = playerName;
			so.data.inLevel = currentLevel;
			so.data.inWeapon = playerWeapon;
			so.data.inScore = _lastSavedScore;
			so.data.inNuke = playerNuke;
			
			so.flush();
		}
		/**
		 * GameController Constructor - sets up init/destroy.
		 * @return
		 */
		public function GameController()
		{ 
			// Game constructor - init/destroy
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
		}
		/**
		 * Main initialization function of the gameController. This starts by initializing all of the Game Objects
		 * like the player, levels, the scene itself (Stage,) and the camera.
		 * Dispatch a level event to notify the Interface, and then call the level class.
		 * Finally, set up all of the listeners for user input, damage, and other events.
		 * @param e
		 * @return
		 */
		public function init(e:Event = null):void
		{
			// Main initialization function of the gameController. This starts by initializing all of the Game Objects
			// like the player, levels, the scene itself (Stage,) and the camera.
			// Dispatch a level event to notify the Interface, and then call the level class.
			// Finally, set up all of the listeners for user input, damage, and other events.
			fpsCounter();
			_paused = false;
			initObjects(); 
			initFlint();
			camera.fov = 45;
			stage.quality = "MEDIUM";
			dispatchLevel(currentLevel);
			_level = new Level(levelContainer, enemyContainer, currentLevel);
			initListeners();
		}
		/**
		 * initListeners Sets up the main ENTERFRAME gameLoop, Game Listeners, and Object Listeners.
		 * These event listeners are attached to the 3 main Game Objects (gameContainer, levelContainer,
		 * enemyContainer)
		 * @return
		 */
		private function initListeners():void
		{
			//Game Listeners
			addEventListener(Event.ENTER_FRAME, gameLoop, false, 0, true); 	
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true); 
			addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true); 
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp, false, 0, true);
			
			//Object Listeners
			gameContainer.addEventListener(Constants.DMG, updateHealth, false, 0, true);
			gameContainer.addEventListener(Constants.WPN, updateWeapon, false, 0, true);
			gameContainer.addEventListener(Constants.NUKE, updateNuke, false, 0, true);
			levelContainer.addEventListener(Constants.DMG, updateHealth, false, 0, true);
			levelContainer.addEventListener(Constants.NUKE, updateNuke, false, 0, true);
			enemyContainer.addEventListener(Constants.DMG, updateHealth, false, 0, true);
			enemyContainer.addEventListener(Constants.SCORE, updateScore, false, 0, true);
			enemyContainer.addEventListener(Constants.ENEMYDMG, enemyDmg, false, 0, true);
			enemyContainer.addEventListener(Constants.GOTOHIGHSCORE, gotoHS, false, 0, true);
			enemyContainer.addEventListener(Constants.LEVEL, updateLevel, false, 0, true);
			
			gameContainer.addEventListener(Constants.EXP, explosion, false, 0, true);
			levelContainer.addEventListener(Constants.EXP, explosion, false, 0, true);
			enemyContainer.addEventListener(Constants.EXP, explosion, false, 0, true);
			enemyContainer.addEventListener(Constants.WARP, warp, false, 0, true);
			levelContainer.addEventListener(Constants.ERP, eruption, false, 0, true);
		}
		/**
		 * This will remove all GameController listeners, as well as canceling all key events, 
		 * clearing all registries, and removing GameController Children.
		 * @param e
		 * @return
		 */
		private function destroy(e:Event):void
		{
			// This will remove all GameController listeners, as well as canceling all key events, 
			// clearing all registries, and removing GameController Children.
			removeEventListener(Event.ENTER_FRAME, gameLoop); 	
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown); 
			removeEventListener(MouseEvent.MOUSE_UP, mouseUp); 
			stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			
			gameContainer.removeEventListener(Constants.DMG, updateHealth);
			gameContainer.removeEventListener(Constants.WPN, updateWeapon);
			gameContainer.removeEventListener(Constants.NUKE, updateNuke);
			levelContainer.removeEventListener(Constants.DMG, updateHealth);
			levelContainer.removeEventListener(Constants.NUKE, updateNuke);
			enemyContainer.removeEventListener(Constants.DMG, updateHealth);
			enemyContainer.removeEventListener(Constants.SCORE, updateScore);
			enemyContainer.removeEventListener(Constants.ENEMYDMG, enemyDmg);
			enemyContainer.removeEventListener(Constants.GOTOHIGHSCORE, gotoHS);
			enemyContainer.removeEventListener(Constants.LEVEL, updateLevel);
			
			gameContainer.removeEventListener(Constants.EXP, explosion);
			levelContainer.removeEventListener(Constants.EXP, explosion);
			enemyContainer.removeEventListener(Constants.EXP, explosion);
			enemyContainer.removeEventListener(Constants.WARP, warp);
			levelContainer.removeEventListener(Constants.ERP, eruption);
			
			removeEventListener(Event.ENTER_FRAME, checkFPS);
			
			trace("Destroying Game Container");
			cancelKeys();
			_level.cancelTimer();
			
			// Pausing Makes sure that no Timers are being ran before deletion in order to
			// cancel watchers for certain objects in vector positions such as the player at [0]
		
			GameController.paused = true;
				
			// Take Everything in the Registries and make sure they are destroyed.
			for (var p:int = Projectile.registry.length - 1; p >= 0; p--) {
				Projectile.registry[p].destroy();
			}
			for (var n:int = EnemyProjectile.registry.length - 1; n >= 0; n--) {
				EnemyProjectile.registry[0].destroy();
			}
			for (var i:int = InanimateObject.registry.length - 1; i >= 0; i--) {
				InanimateObject.registry[i].destroy();
			}
			for (var s:int = Ship.registry.length - 1; s >= 0; s--) {
				Ship.registry[s].destroy();
			}
			for (var v:int = Environment.registry.length - 1; v >= 0; v--) {
				Environment.registry[v].destroy();
			}
			// Clear all registries by making anew.
			Projectile.registry = new Vector.<Projectile>();
			EnemyProjectile.registry = new Vector.<EnemyProjectile>();
			Ship.registry = new Vector.<Ship>();
			InanimateObject.registry = new Vector.<InanimateObject>();
			Environment.registry = new Vector.<Environment>();
			
			scene.removeChild(gameContainer);
			scene.removeChild(enemyContainer);
			scene.removeChild(levelContainer);
			
			// Flint and level reset
			viewport.containerSprite.removeAllLayers();
			scene.removeChild(pixels);
			currentLevel = 1;
			for each( var emitter:Emitter in pv3dRenderer.emitters ) {
				emitter.stop();
			}
			for each( var emitter2:Emitter in flintRenderer.emitters ) {
				emitter2.stop();
			}
		}
		
		// ***************************************//
		//            Flint Particles             //
		/**
		 * InitFlint called back in init.  This function creates a layer to which there are going to be effects generated.
		 * It then adds the bitmaplayer to the Scenes viewport
		 * @return
		 */
		private function initFlint():void {
			// Create a layer to which there are going to be effects generated.
			bfx = new BitmapEffectLayer(viewport,800,600);
			viewport.containerSprite.addLayer( bfx );
			pixels = new Pixels(bfx);
			bfx.addDisplayObject3D(pixels);
			scene.addChild(pixels);
			//bfx.addEffect( new BitmapLayerEffect(new BlurFilter(3, 3, 1) ) );
			bfx.addEffect( new BitmapLayerEffect(new ColorMatrixFilter( [ 1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0.95,0 ] ) ) );
			pv3dRenderer = new PV3DPixelRenderer(pixels);
			flintRenderer = new PV3DRenderer( scene );
			//initPlayerEffects();
		}
		//private function initPlayerEffects():void {
			// This is the jet exhaust material that comes out of the back of the Player Ship. (Lags too much);
			//spray = new SprayEmitter3D();
			//pv3dRenderer.addEmitter( spray );
			//spray.start();
			//Vector to translate the position of the ship into flint format
			//vector = new Vector3D(); 
		//}
		/**
		 * Explosion function, this GameController listens for the even, fired from a ship who has just been hit (usually.)
		 * @param exp
		 * @return
		 */
		public function explosion( exp:ExplosionEvent):void {
			// Explosion called from elsewhere.
			var random:int = Math.round(Math.random() * (4-1)) + 1;
			switch (random) {
				case 1:
					sound1.play(0,0,st);
					break;
				case 2:
					sound2.play(0,0,st);
					break;
				case 3:
					sound3.play(0,0,st);
					break;
				case 4:
					sound4.play(0,0,st);
					break;
			}
			var bang:Emitter3D = new SphereBang( exp.location, exp.size );
			bang.addEventListener( EmitterEvent.EMITTER_EMPTY, removeEmitter, false, 0, true );
			pv3dRenderer.addEmitter( bang );
			bang.start();
		}
		/**
		 * Eruption is called from the Planet Class on Level1a which randomly makes
		 * an eruption and adds it to the screen.
		 * @param erp
		 * @return
		 */
		public function eruption( erp:EruptionEvent ): void {
			var eruption:Emitter3D = new Eruption(erp.location);
			eruption.addEventListener( EmitterEvent.EMITTER_EMPTY, removeEmitter, false, 0, true );
			flintRenderer.addEmitter( eruption ); 
			eruption.start();
		}
		/**
		 * Warp in is called from the Ships when they spawn. This GameController Listens for the Event.
		 * @param erp
		 * @return
		 */
		public function warp( warp:WarpEvent ): void {
			var warpIn:Emitter3D = new Warp(warp.location, warp.size);
			warpIn.addEventListener( EmitterEvent.EMITTER_EMPTY, removeEmitter, false, 0, true );
			flintRenderer.addEmitter( warpIn ); 
			warpIn.start();
		}
		/**
		 * This will remove all GameController listeners, as well as canceling all key events, 
		 * clearing all registries, and removing GameController Children.
		 * @param ev
		 * @return
		 */
		private function removeEmitter( ev:EmitterEvent ):void {
			Emitter3D( ev.target ).removeEventListener( EmitterEvent.EMITTER_EMPTY, removeEmitter );
			Emitter3D( ev.target ).stop();
			pv3dRenderer.removeEmitter( Emitter3D( ev.target ) );
			flintRenderer.removeEmitter( Emitter3D( ev.target ) );
		}
		
		// ***************************************//
		/**
		 * gameLoop that runs on ADDED_TO_STAGE.  This loop can be paused in order to not render and uplate level tracker.
		 * @param event
		 * @return
		 */
		private function gameLoop(event:Event):void 
		{	
			// Game loop which is ran from ADDED TO STAGE. Runs functions while game is unpaused.
			if(! paused)
			{
				updateCameraAndRender();
				Level.updateTracker();
			}
		}
		/**
		 * initObjects will instantiate the 3 Primary DisplayGroups, the player, and the bounding auras on permanent stage.
		 * @return
		 */
		private function initObjects() : void
		{
			// Create all the Containers for Game Objects (DisplayObject3Ds)
			// GameContainer will hold the Player and Destruction wall.
			gameContainer = new DisplayObject3D;
			levelContainer = new DisplayObject3D;
			enemyContainer = new DisplayObject3D;
			
			// Player Character
			player1 = new Player(gameContainer, playerWeapon, playerNuke);
			player1.z = -240;
			gameContainer.addChild(player1);
			
			//Bounding auras
			var _mat:BitmapColorMaterial = new BitmapColorMaterial(0x00AAFF,0.5);
			_mat.doubleSided = true;
			plane1 = new Plane(_mat,90,2);
			plane1.z = -240;
			plane1.x = 275;
			plane2 = new Plane(_mat,90,2);
			plane2.z = -240;
			plane2.x = -275;
			plane1.useOwnContainer = true;
			plane2.useOwnContainer = true;
			var glowFilter:GlowFilter = new GlowFilter(0x00FFFF,1,40,40,2);
			plane1.filters = [glowFilter];
			plane2.filters = [glowFilter];
			gameContainer.addChild(plane1);
			gameContainer.addChild(plane2);
			
			// Add the DisplayObject3D containers to the scene.
			scene.addChild(gameContainer); 
			scene.addChild(levelContainer); 
			scene.addChild(enemyContainer); 
			
		}
		
		// ***************** EVENT FUNCTIONS ********************** //
		/**
		 * updateHealth will fire to PFX into Interface > Health, updating Player health.
		 * @param dmg
		 * @return
		 */
		public function updateHealth(dmg:DamageEvent):void {
			//Fire to PFX into Interface > Health, updating Player health.
			dispatchEvent(dmg);
		}
		/**
		 * updateHealth will fire to PFX into Interface > EnemyHealth, updating Boss health.
		 * @param enemyDmg
		 * @return
		 */
		public function enemyDmg(enemyDmg:EnemyDamageEvent):void {
			//Fire to PFX into Interface > EnemyHealth, updating Boss health.
			dispatchEvent(enemyDmg);
		}
		/**
		 * enemyDMG will fire to PFX to to to High Score (will cause this.destroy())
		 * @param mod
		 * @return
		 */
		public function gotoHS(mod:modEvent):void {
			//Fire to PFX to to to High Score (will cause this.destroy())
			dispatchEvent(mod);
		}
		/**
		 * updateWeapon will this will grab the Player.weapon
		 * @param wpn
		 * @return
		 */
		public function updateWeapon(wpn:WeaponEvent):void {
			//This will grab the Player.weapon
			playerWeapon = wpn.weaponNumber;
		}
		/**
		 * updateScore catalogs the score as well as fires score to PFX then Interface.
		 * @param score
		 * @return
		 */
		public function updateScore(score:ScoreEvent):void {
			//This catalogs the score as well as fires score to PFX then Interface.
			if(!debug) {
				currentScore += score.score;
				dispatchEvent(score);
			}
		}
		/**
		 * updateNuke will fire to PFX to update the nuke counter.
		 * @param dmg
		 * @return
		 */
		public function updateNuke(nuke:NukeEvent):void {
			//Fire to PFX to update the nuke counter.
			dispatchEvent(nuke);
		}
		
		
		// ***************** LEVEL FUNCTIONS ********************** //
		/**
		 * updateLevel will fire inside the Level class to update its JSON file and clear the Tracker,
		 * It also fires to PFX to update the visual Level number on the Interface, as well as setting 
		 * GameControllers currentLevel.
		 * @param e
		 * @return
		 */
		public function updateLevel(e:LevelEvent):void {
			_level.updateLevel(e.level);
			dispatchLevel(e.level);
			//Update this gameController currentlevel.
			currentLevel = e.level;
			//Save the score at this point for save/load games.
			_lastSavedScore = currentScore;
		}
		/**
		 * dispatchLevel fires the param level to PFX.
		 * @param level
		 * @return
		 */
		private function dispatchLevel(level:int):void {
			// This function will let the Interface know which Level is current (fires to PFX.)
			var eventObj:LevelEvent = new LevelEvent(Constants.LEVEL);
			eventObj.level = level;
			dispatchEvent(eventObj);
		}
		
		
		// *********** BEGIN CAMERA/MOUSE/KEYBOARD FUNCTIONS ****************** //
		/**
		 * 1 If the mouse is down, we will be able to spin the camera around the central axis (0,0,0).
		 * 2 Pitch and Yaw to the new target pitch set (if mouse down), else this doesnt change.
		 * 3 Make sure camera is always anchored to the origin.
		 * 4 Move the camera back behind the ship initially, keep it 500 game length away from the origin.
		 * @return
		 */
		private function updateCameraAndRender() : void
		{
			if(isMouseDown)
			{
				// If the mouse is down, we will be able to spin the camera around the central axis (0,0,0).
				targetPitch += ((mouseY - lastMousePoint.y)*0.1);
				targetYaw += ((mouseX - lastMousePoint.x)*0.1);
				
				lastMousePoint.x = mouseX; 
				lastMousePoint.y = mouseY; 
				//singleRender();
			}
			
			// Pitch and Yaw to the new target pitch set (if mouse down), else this doesnt change.
			pitch+=((targetPitch-pitch)*0.2); 
			yaw +=((targetYaw-yaw)*0.2); 
			
			// Make sure camera is always anchored to the origin.
			camera.x = camera.y = camera.z = 0;
			
			camera.rotationX = pitch;
			camera.rotationY = yaw; 
			
			// Move the camera back behind the ship initially, keep it 500 game length away from the origin.
			camera.moveBackward(500); 
			camera.moveUp(400); 
			
			singleRender();
		}
		/**
		 * keyDown first checks if the game is paused, then interprets the keyboard event and designates how to handle it.
		 * @param e
		 * @return
		 */
		private function keyDown(e:KeyboardEvent):void {
			if (!_paused) {
				switch (e.keyCode) {
					case LEFT:
						Player.leftPressed = true;
						break;
					case A:
						Player.leftPressed = true;
						break;
					case RIGHT:
						Player.rightPressed = true;
						break;
					case D:
						Player.rightPressed = true;
						break;
					case SPACE:
						//Space is the firing mechanism for the player ship.
						Player.normalPressed = true;
						break;
					case B:
						player1.fireSecondaryWeapon();
						break;
					case UP:
						if(debug){
							Player.changeBasicWeapon(1);
						}
						break;
					case DOWN:
						if(debug){
							Player.changeBasicWeapon(-1);
						}
						break;
					case ZERO:
						if(debug){
							if (currentLevel != 4) {
								dispatchEvent(new Event(Constants.CLEARBOSSHEALTH,true));
								var eventObj:LevelEvent = new LevelEvent(Constants.LEVEL);
								eventObj.level = currentLevel + 1;
								enemyContainer.dispatchEvent(eventObj);
							}
						}
						break;
					case NINE:
						if(debug){
							if (currentLevel != 1) {
								dispatchEvent(new Event(Constants.CLEARBOSSHEALTH,true));
								var eventObj2:LevelEvent = new LevelEvent(Constants.LEVEL);
								eventObj2.level = currentLevel - 1;
								enemyContainer.dispatchEvent(eventObj2);
							}
						}
						break;
					case W:
						if (debug) {
							//Give 10 HP to player.
							var eventObj3:DamageEvent = new DamageEvent(Constants.DMG);
							eventObj3.damage = -10;
							enemyContainer.dispatchEvent(eventObj3);
						}
						break;
					case S:
						if (debug) {
							//Give a player a nuke if they dont have 3 or more.
							if (Player.nukeNumber < 3) {
								Player.nukeNumber ++;
								var eventObj4:NukeEvent = new NukeEvent(Constants.NUKE);
								eventObj4.Nuke = 1;
								levelContainer.dispatchEvent(eventObj4);
							}
						}
						break;
				} // End switch
			} // End If
		} // End KeyDown
		/**
		 * keyUp will let go of the previous flags for keyDown.
		 * @param e
		 * @return
		 */
		private function keyUp(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case LEFT:
					Player.leftPressed = false;
					break;
				case A:
					Player.leftPressed = false;
					break;
				case RIGHT:
					Player.rightPressed = false;
					break;
				case D:
					Player.rightPressed = false;
					break;
				case SPACE:
					//Space is the firing mechanism for the player ship.
					Player.normalPressed = false;
					break;
				default:
					break;
			}
		}
		/**
		 * mouseDown will flag true and grab the mouseX and Y.  MouseDown signal, used for camera movement.
		 * @param e
		 * @return
		 */
		private function mouseDown(e : MouseEvent) : void {
			// MouseDown signal, used for camera movement.
			isMouseDown = true; 
			lastMousePoint.x = mouseX; 
			lastMousePoint.y = mouseY; 
			
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
		}
		private function onMouseLeave(e : Event):void {
			stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			mouseUp();
		}
		/**
		 * mouseUp will flag mouseDown to false
		 * @param e
		 * @return
		 */
		private function mouseUp(e : MouseEvent = null) : void {
			isMouseDown = false; 
		}
		
		// Clearing Functions
		/**
		 * cancelKeys will turn all keyFlags manually to false.
		 * @return
		 */
		private function cancelKeys():void {
			// Turn off all key flags.
			Player.normalPressed = false;
			Player.leftPressed = false;
			Player.rightPressed = false;
		}
		/**
		 * gotoHighscore fires to PFX a mod event that will cause GameController to destroy itself and go to HighScore module.
		 * @return
		 */
		public function goToHighscore():void {
			var eventObj:modEvent = new modEvent(Constants.GOTOHIGHSCORE);
			eventObj.modName = Constants.GOTOHIGHSCORE;
			dispatchEvent(eventObj);
		}
		
		private function giveNuke():void {
			if (Player.nukeNumber < 3) {
				Player.nukeNumber ++;
				var eventObj:NukeEvent = new NukeEvent(Constants.NUKE);
				eventObj.Nuke = 1;
				dispatchEvent(eventObj);
			}
		}
	} // End class
} // End Package