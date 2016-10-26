package com.Ships
{
	import com.Constants;
	import com.Objects.flyingObjs.inatimate.Asteroid;
	import com.Objects.flyingObjs.inatimate.InanimateObject;
	import com.Objects.flyingObjs.projectile.ELaserThree;
	import com.Objects.flyingObjs.projectile.Projectile;
	
	import events.EnemyDamageEvent;
	import events.ExplosionEvent;
	import events.LevelEvent;
	import events.ScoreEvent;
	
	import flash.geom.Vector3D;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.primitives.Cube;
	
	public class Boss2 extends Ship
	{
		/** public hitbox that is the object that we collision detect. */
		public var hitbox:Cube;
		// Model
		private var _dae:DAE;
		
		public var healthLevel:int;
		private var goLeft:Boolean;
		private var goRight:Boolean;
		private var _laserThree:ELaserThree;
		private var _gun1:Number3D = new Number3D;
		private var _gun2:Number3D = new Number3D;
		
		// Random Object Creation
		private var _ast1:Asteroid;
		private var _low:Number = -500;
		private var _high:Number = 500;
		
		// Movement
		private var _xVel:int;
		private var _zVel:int;
		
		private var _cm:ColorMaterial = new ColorMaterial(0x0000FF,0);
		private var _ml:MaterialsList = new MaterialsList();
		
		private var _levelContainer:DisplayObject3D;
		
		//Sound
		[Embed(source="assets/Sound/Alien/AlienVoice2_SFX.mp3")] 
		private var soundAsset:Class;
		private var sound:Sound = new soundAsset() as Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUMEHIGH);
		/**
		 * Boss2 Constructor sets up the boss health, the DAE (model), the hitbox, and starts moving.
		 * @param x @param y @param z @param enemyContainer @param levelContainer 
		 * @return
		 */
		public function Boss2( x:int, y:int, z:int, container:DisplayObject3D, levelContainer:DisplayObject3D)
		{
			super();
			container.addChild(this);
			_container = container;
			_levelContainer = levelContainer;
			_warpSize = 10;
			
			healthLevel = Constants.BOSS2HEALTH;
			
			_dae = new DAE();
			_dae.load("com/assets/Boss2.dae");
			_dae.rotationY = 180;
			_dae.x += 25;
			_dae.scale = 12;
			addChild(_dae);
			
			this.z = z;	
			this.x = x;
			this.y = y;
			
			_ml.addMaterial(_cm,"all");
			hitbox = new Cube(_ml,100,100,100);
			hitbox.position = this.position;
			_container.addChild(hitbox);
			
			goRight = true;
			
			warp();
			
			startMoving();
			
			sound.play(0,0,st);
		}
		/**
		 * Update function.  This updates the current position of the boss, updates the two gun firing positions, then increases the counter that provides AI.
		 * The boss heads in a direction until it crosses the 250 marker in either X direction.  Once it does, switch 
		 * the directional flag, make an asteroid somewhere random, then call Move.
		 * @return
		 */
		public override function update():void
		{ 
			//Update the current Position of Boss
			_gun1.x = x + 40;
			_gun1.y = y;
			_gun1.z = z - 80;
			_gun2.x = x - 40;
			_gun2.y = y;
			_gun2.z = z - 80;
			
			_timer++;
			
			//If boss is on its position bounds, make an environment object and switch direction.
			if (x > 250) {
				goRight = false;
				goLeft = true;
				makeInactiveObject();
				move();
			}
			if (x < -250) {
				goLeft = false;
				goRight = true;
				makeInactiveObject();
				move();
			}
			else {
				move();
			}
			
			hitbox.position = this.position;
			checkCollision();
			checkHealth();
		}
		
		private function makeInactiveObject():void 
		{
			var x:int = Math.round(Math.random() * (_high - _low)) + _low;
			var y:int = Math.round(Math.random() * (_high - _low)) + _low;
			
			var ast:Asteroid = new Asteroid(x,y,900, _levelContainer);
			sound.play(0,0,st);
		}
		
		private function move():void {
			if (goLeft == true) {
				if (_timer % 10 == 0) {
					_laserThree = new ELaserThree(_gun1,_container);
					_laserThree = new ELaserThree(_gun2,_container);
				}
				x -= 5;
			}
			if (goRight == true) {
				if (_timer % 10 == 0) {
					_laserThree = new ELaserThree(_gun1,_container);
					_laserThree = new ELaserThree(_gun2,_container);
				}
				x += 5;
			}
		}
		
		private function checkCollision():void {
			for each (var nextProjectile:Projectile in Projectile.registry)
			{
				if (nextProjectile.particles3D != null) {
					if (hitbox.hitTestObject(nextProjectile.particles3D)) {
						hit();
						nextProjectile.destroy();
						return;
					}
				}
				else if (nextProjectile.sphere != null) {
					if(hitbox.hitTestObject(nextProjectile.sphere)) 
						hit();
					return;
				}
			}
		}
		private function hit():void {
			healthLevel -= Constants.LDMG;
			var eventObj:EnemyDamageEvent = new EnemyDamageEvent(Constants.ENEMYDMG);
			eventObj.damage = Constants.LDMG;
			_container.dispatchEvent(eventObj);
		}
		
		private function checkHealth():void {
			if (healthLevel <= 0){
				tallyScore();
				destroy();
				// LEVEL EVENT = TRIGGER TO CHANGE THE LEVEL HERE
				var eventObj:LevelEvent = new LevelEvent(Constants.LEVEL);
				eventObj.level = 3;
				_container.dispatchEvent(eventObj);
			}
			if (healthLevel < 35 && _timer % 25 == 0) {
				explode();
			}
		}
		/**
		 * Tallys the score, fires the points through the container to gameController > PFX > Interface for the current ship.
		 * @return
		 */
		public override function tallyScore():void {
			var eventObj:ScoreEvent = new ScoreEvent(Constants.SCORE);
			eventObj.score = Constants.BOSS2PTS;
			_container.dispatchEvent(eventObj);
		}
		/**
		 * Fires an explode to the container to gameController for the current ship.
		 * @return
		 */
		private function explode():void {
			var eventObj:ExplosionEvent = new ExplosionEvent(Constants.EXP);
			eventObj.size = 150;
			eventObj.location = new Vector3D(this.x, this.y, this.z);
			_container.dispatchEvent(eventObj);
		}
		/**
		 * Destroys this Ship.  Stops this from moving(updating.)
		 * Finds the position in the Registry and splices it out. Unregisters all materials.
		 * Removes objects from the container to disconnect from display tree.
		 * @return
		 */
		public override function destroy():void 
		{
			stopMoving();
			_cm.unregisterObject(hitbox);
			_container.removeChild(hitbox);
			_container.removeChild(this);
		}
	} // End Boss1
}