package com.Ships
{
	import com.Constants;
	import com.Objects.flyingObjs.inatimate.GasCloud;
	import com.Objects.flyingObjs.inatimate.InanimateObject;
	import com.Objects.flyingObjs.projectile.ELaserTwo;
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
	
	public class Boss1 extends Ship
	{
		/** public hitbox that is the object that we collision detect. */
		public var hitbox:Cube;
		// Model
		private var _dae:DAE;
		
		public var healthLevel:int;
		private var goLeft:Boolean;
		private var goRight:Boolean;
		private var _laserTwo:ELaserTwo;
		private var _lastPos:Number3D;
		private var _counter:int;
		
		// Random Object Creation
		private var _gas:GasCloud;
		private var _low:int = -500;
		private var _high:int = 500;
		
		// Movement
		private var _xVel:int;
		private var _zVel:int;
		
		private var _cm:ColorMaterial = new ColorMaterial(0xFF00FF,0);
		private var _ml:MaterialsList = new MaterialsList();

		private var _levelContainer:DisplayObject3D;
		
		//Sound
		[Embed(source="assets/Sound/Alien/AlienVoice1_SFX.mp3")] 
		private var soundAsset:Class;
		private var sound:Sound = new soundAsset() as Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUMEHIGH);
		/**
		 * Boss1 Constructor sets up the boss health, the DAE (model), the hitbox, and starts moving.
		 * @param x @param y @param z @param enemyContainer @param levelContainer 
		 * @return
		 */
		public function Boss1( x:int, y:int, z:int, enemyContainer:DisplayObject3D, levelContainer:DisplayObject3D)
		{
			super();
			enemyContainer.addChild(this);
			_container = enemyContainer;
			_levelContainer = levelContainer;
			_warpSize = 10;
			
			healthLevel = Constants.BOSS1HEALTH;
			
			_lastPos = new Number3D();
			_dae = new DAE();
			_dae.load("com/assets/Boss1.dae");
			_dae.rotationY = 180;
			_dae.z -= 15;
			_dae.scale = 0;
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
			
			var gas:GasCloud = new GasCloud(x,y,z, _levelContainer);
			
			sound.play(0,0,st);
			
			startMoving();
		}
		/**
		 * update function.  This updates the current position of the boss, then increases the counter that provides AI.
		 * The boss heads in a direction until it crosses the 250 marker in either X direction.  Once it does, switch 
		 * the directional flag, make a gas cloud somewhere random, then call Move.
		 * @return
		 */
		public override function update():void
		{ 
			//Update the current Position of Boss
			_lastPos.x = x;
			_lastPos.y = y;
			_lastPos.z = z - 80;
			
			_timer++;
			if (_timer < 20)
				_dae.scale += .3;
			
			//If boss is on its position bounds, make an environment object and switch direction.
			if (x > 250) {
				goRight = false;
				goLeft = true;
				makeInanimateObject();
				move();
			}
			if (x < -250) {
				goLeft = false;
				goRight = true;
				makeInanimateObject();
				move();
			}
			else {
				move();
			}

			hitbox.position = this.position;
			
			checkCollision();
			checkHealth();
		}
		
		private function makeInanimateObject():void 
		{
			var x:int = Math.round(Math.random() * (_high - _low)) + _low;
			var y:int = Math.round(Math.random() * (_high - _low)) + _low;
			var z:int = Math.round(Math.random() * (_high - _low)) + _low;

			var gas:GasCloud = new GasCloud(x,y,z, _levelContainer);
			sound.play(0,0,st);
			//Reset gun counter to fire new burst.
			_counter = 0;
		}
		
		private function move():void {
			if (goLeft == true) {
				if (_timer % 5 == 0 && _counter < 15) {
					_laserTwo = new ELaserTwo(_lastPos,_container,0);
					_counter++;
				}
				x -= 5;
			}
			if (goRight == true) {
				if (_timer % 5 == 0 && _counter < 15) {
					_laserTwo = new ELaserTwo(_lastPos,_container,0);
					_counter++;
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
			if (healthLevel <= 0) {
				tallyScore();
				destroy();
				// LEVEL EVENT = TRIGGER TO CHANGE THE LEVEL HERE
				var eventObj:LevelEvent = new LevelEvent(Constants.LEVEL);
				eventObj.level = 2;
				_container.dispatchEvent(eventObj);
			}
			if (healthLevel < 25 && _timer % 25 == 0) {
				explode();
			}
		}
		/**
		 * Tallys the score, fires the points through the container to gameController > PFX > Interface for the current ship.
		 * @return
		 */
		public override function tallyScore():void {
			var eventObj:ScoreEvent = new ScoreEvent(Constants.SCORE);
			eventObj.score = Constants.BOSS1PTS;
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