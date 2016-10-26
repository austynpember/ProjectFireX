package com.Ships
{
	import com.Constants;
	import com.Objects.flyingObjs.inatimate.InanimateObject;
	import com.Objects.flyingObjs.projectile.EnemyBeam;
	import com.Objects.flyingObjs.projectile.EnemyProjectile;
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
	
	public class Boss3 extends Ship
	{
		/** public hitbox that is the object that we collision detect. */
		public var hitbox:Cube;
		// Model
		private var _dae:DAE;
		
		public var healthLevel:int;
		private var goLeft:Boolean;
		private var goRight:Boolean;
		private var _enemyBeam:EnemyBeam;
		private var _lastPos:Number3D;
		
		// Movement
		private var _xVel:int;
		private var _zVel:int;
		
		private var _cm:ColorMaterial = new ColorMaterial(0xFF00FF, 0);
		private var _ml:MaterialsList = new MaterialsList();
		
		private var _levelContainer:DisplayObject3D;
		
		//Sound
		[Embed(source="assets/Sound/Alien/AlienVoice3_SFX.mp3")] 
		private var soundAsset:Class;
		private var sound:Sound = new soundAsset() as Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUMEHIGH);
		/**
		 * Boss3 Constructor sets up the boss health, the DAE (model), the hitbox, and starts moving.
		 * @param x @param y @param z @param enemyContainer @param levelContainer 
		 * @return
		 */
		public function Boss3( x:int, y:int, z:int, enemyContainer:DisplayObject3D, levelContainer:DisplayObject3D)
		{
			super();
			enemyContainer.addChild(this);
			_container = enemyContainer;
			_levelContainer = levelContainer;
			_warpSize = 10;
			
			healthLevel = Constants.BOSS3HEALTH;
			
			_lastPos = new Number3D();
			_dae = new DAE();
			_dae.load("com/assets/Boss3.dae");
			_dae.scale = 7;
			_dae.y += 16;
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
		 * Update function.  This updates the current position of the boss, then increases the counter that provides AI.
		 * The boss heads in a direction until it crosses the 250 marker in either X direction.  Once it does, switch 
		 * the directional flag, make a Smart1 somewhere random, then call Move.
		 * @return
		 */
		public override function update():void
		{ 
			//Update the current Position of Boss
			_lastPos.x = x;
			_lastPos.y = y;
			_lastPos.z = z - 80;
			
			_timer++;
			
			//If boss is on its position bounds, make an environment object and switch direction.
			if (x > 250) {
				goRight = false;
				goLeft = true;
				makeSmart1();
				move();
			}
			if (x < -250) {
				goLeft = false;
				goRight = true;
				makeSmart1();
				move();
			}
			else {
				move();
			}
			
			hitbox.position = this.position;
			
			checkCollision();
			checkHealth();
		}
		
		private function makeSmart1():void {
			var smart1:Smart1 = new Smart1(this.x,this.y,this.z, _container);
			sound.play(0,0,st);
		}
		
		private function move():void {
			if (goLeft == true) {
				if (_timer % 20 == 0) {
					_enemyBeam = new EnemyBeam(_lastPos,_container);
				}
				x -= 5;
			}
			if (goRight == true) {
				if (_timer % 20 == 0) {
					_enemyBeam = new EnemyBeam(_lastPos,_container);
				}
				x += 5;
			}
		}
		
		private function checkCollision():void {
			for each (var nextProjectile:Projectile in Projectile.registry)
			{
				if (nextProjectile.particles3D != null) {
					if (hitbox.hitTestObject(nextProjectile.particles3D)) {
						hit(Constants.LDMG);
						nextProjectile.destroy();
						return;
					}
				} 
				else if (nextProjectile.sphere != null) {
					if(hitbox.hitTestObject(nextProjectile.sphere)) {
						hit(Constants.LDMG);
						return;
					}
				}
				else if (nextProjectile.plane != null) {
					if(hitbox.hitTestPoint(nextProjectile.plane.x,this.y,this.z)) {
						hit(Constants.BEAMDMG);
						return;
					}
				}
			}
		}
		
		private function hit(damage:int):void {
			healthLevel -= damage;
			var eventObj:EnemyDamageEvent = new EnemyDamageEvent(Constants.ENEMYDMG);
			eventObj.damage = damage;
			_container.dispatchEvent(eventObj);
		}
		
		private function checkHealth():void {
			if (healthLevel <= 0) {
				tallyScore();
				destroy();
				// LEVEL EVENT = TRIGGER TO CHANGE THE LEVEL HERE
				var eventObj:LevelEvent = new LevelEvent(Constants.LEVEL);
				eventObj.level = 4;
				_container.dispatchEvent(eventObj);
			}
			if (healthLevel < 70 && _timer % 25 == 0) {
				explode();
			}
		}
		/**
		 * Tallys the score, fires the points through the container to gameController > PFX > Interface for the current ship.
		 * @return
		 */
		public override function tallyScore():void {
			var eventObj:ScoreEvent = new ScoreEvent(Constants.SCORE);
			eventObj.score = Constants.BOSS3PTS;
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
			//Clear the randomly generated inanimateobjects
			_cm.unregisterObject(hitbox);
			_container.removeChild(hitbox);
			_container.removeChild(this);
		}
	} // End Boss1
}