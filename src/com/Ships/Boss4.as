package com.Ships
{
	import com.Constants;
	import com.Objects.flyingObjs.inatimate.InanimateObject;
	import com.Objects.flyingObjs.projectile.ELaserThree;
	import com.Objects.flyingObjs.projectile.EnemyBeam;
	import com.Objects.flyingObjs.projectile.EnemyProjectile;
	import com.Objects.flyingObjs.projectile.Projectile;
	
	import events.EnemyDamageEvent;
	import events.ExplosionEvent;
	import events.LevelEvent;
	import events.ScoreEvent;
	import events.modEvent;
	
	import flash.geom.Vector3D;
	import flash.media.Sound;
	
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.primitives.Cube;
	
	public class Boss4 extends Ship
	{
		/** public hitbox that is the object that we collision detect. */
		public var hitbox:Cube;
		/** Left gun (hitbox) that is the object that we collision detect. */
		public var gunbox1:Cube;
		/** Right gun (hitbox) that is the object that we collision detect. */
		public var gunbox2:Cube;
		private var _phase1:Boolean;
		// Model
		private var _dae:DAE;
		private var _gun1dae:DAE;
		private var _gun2dae:DAE;
		
		public var healthLevel:int;
		private var gun1Health:int;
		private var gun2Health:int;
		private var _enemyBeam:EnemyBeam;
		private var _enemyLaserThree:ELaserThree;
		private var _gun1:Number3D = new Number3D;
		private var _gun2:Number3D = new Number3D;
		private var gun1Destroyed:Boolean = false;
		private var gun2Destroyed:Boolean = false;
		private var failPlayed:Boolean = false;
		private var _highSpeed:int = 8;
		private var _lowSpeed:int = -8;
		private var _xboundLEFT:int = -400;
		private var _xboundRIGHT:int = 400;
		private var _zboundFar:int = 700;
		private var _zboundClose:int = 50;
		
		// Movement
		private var _xVel:int;
		private var _zVel:int;
		
		private var _cm:ColorMaterial = new ColorMaterial(0xFF00FF,0);
		private var _ml:MaterialsList = new MaterialsList();
		
		private var _levelContainer:DisplayObject3D;
		
		[Embed(source="/../assets/Sound/Alien/Detected_SFX.mp3")] 
		private var soundAsset1:Class;
		private var sound1:Sound = new soundAsset1() as Sound;
		[Embed(source="/../assets/Sound/Alien/Disarmed_SFX.mp3")] 
		private var soundAsset2:Class;
		private var sound2:Sound = new soundAsset2() as Sound;
		[Embed(source="/../assets/Sound/Alien/LifeFailing_SFX.mp3")] 
		private var soundAsset3:Class;
		private var sound3:Sound = new soundAsset3() as Sound;
		[Embed(source="/../assets/Sound/Alien/LifeDamaged_SFX.mp3")] 
		private var soundAsset4:Class;
		private var sound4:Sound = new soundAsset4() as Sound;
		[Embed(source="/../assets/Sound/Alien/LifeOperational_SFX.mp3")] 
		private var soundAsset5:Class;
		private var sound5:Sound = new soundAsset5() as Sound;
		[Embed(source="/../assets/Sound/Alien/YouTerminated_SFX.mp3")] 
		private var soundAsset6:Class;
		private var sound6:Sound = new soundAsset6() as Sound;
		[Embed(source="/../assets/Sound/Alien/YouDestroyed_SFX.mp3")] 
		private var soundAsset7:Class;
		private var sound7:Sound = new soundAsset7() as Sound;
		/**
		 * Boss4 Constructor sets up the boss health, the DAE (model), the hitbox(and two gun hitboxes,)
		 * adds them to the containers, and starts moving.
		 * @param x @param y @param z @param enemyContainer @param levelContainer 
		 * @return
		 */
		public function Boss4( x:int, y:int, z:int, enemyContainer:DisplayObject3D, levelContainer:DisplayObject3D)
		{
			super();
			_container = enemyContainer;
			_levelContainer = levelContainer;
			_warpSize = 10;
			_container.addChild(this);

			healthLevel = Constants.BOSS4HEALTH;
			gun1Health = 120;
			gun2Health = 120;
			
			_gun1 = new Number3D();
			_gun2 = new Number3D();
			_phase1 = true;
			
			_dae = new DAE();
			_dae.load("com/assets/Boss4.dae");
			_dae.scale = 15;
			addChild(_dae);
			
			_gun1dae = new DAE();
			_gun1dae.load("com/assets/Gun.dae");
			_gun1dae.rotationX = 180;
			_gun1dae.scale = 10;
			_gun1dae.y -= 16;
			_gun1dae.x += 70;
			_gun1dae.alpha = .8;
			addChild(_gun1dae);
			
			_gun2dae = new DAE();
			_gun2dae.load("com/assets/Gun.dae");
			_gun1dae.rotationX = 180;
			_gun2dae.scale = 10;
			_gun2dae.y -= 16;
			_gun2dae.x -= 70;
			_gun2dae.alpha = .8;
			addChild(_gun2dae);
			
			this.z = z;	
			this.x = x;
			this.y = y;
			
			_ml.addMaterial(_cm,"all");
			
			hitbox = new Cube(_ml,100,100,100);
			hitbox.position = this.position;
			_container.addChild(hitbox);
			
			gunbox1 = new Cube(_ml,40,40,40);
			gunbox1.position = this.position;
			_container.addChild(gunbox1);
			
			gunbox2 = new Cube(_ml,40,40,40);
			gunbox2.position = this.position;
			_container.addChild(gunbox2);
			
			warp();
			
			startMoving();
		}
		/**
		 * Update function.  This updates the current position of the boss, updates the two gun firing positions, then increases the counter that provides AI.
		 * Every couple seconds, Boss4 will choose a new X and Z velocity, fire it's guns if they are alive, and make a Smart2 Enemy.
		 * The boss heads in a direction until it crosses the 250 marker in either X direction.  Once it does, switch 
		 * the directional flag, make a Smart1 somewhere random, then call Move.  Sounds will Then play based upon timers.
		 * @return
		 */
		public override function update():void
		{ 
			//Update the current Position of Boss
			_gun1 = gunbox1.position;
			_gun2 = gunbox2.position;
			 
			_timer++;
			
			//If boss is on its position bounds, make an environment object and switch direction.
			if(_timer % 45 == 0) {
				_xVel = Math.round(Math.random() * (_highSpeed - _lowSpeed)) + _lowSpeed;
				_zVel = Math.round(Math.random() * (_highSpeed - _lowSpeed)) + _lowSpeed;
				if(gunbox1.visible)
					_enemyBeam = new EnemyBeam(_gun1,_container);
				if(gunbox2.visible)
					_enemyBeam = new EnemyBeam(_gun2,_container);
				var smart2:Smart2 = new Smart2(this.x,this.y,this.z, _container);
			}
			
			//Sounds
			if(_timer % 300 == 0)
				sound6.play();
			if(_timer % 750 == 0)
				sound7.play();
			if(_timer == 60)
				sound1.play();
			if(_timer == 175)
				sound5.play();
			
			if(x >= _xboundRIGHT || x <= _xboundLEFT)
				_xVel = -_xVel * 1.2;
			if(z >= _zboundFar || z <= _zboundClose)
				_zVel = -_zVel * 1.2;
			
			if(healthLevel == 100 && failPlayed == false) {
				sound3.play();
				failPlayed = true;
			}
			
			x += _xVel;
			z += _zVel;
			
			hitbox.position = this.position;
			gunbox1.x = x + 70;
			gunbox1.z = z;
			gunbox2.x = x - 70;
			gunbox2.z = z;
			
			checkCollision();
			checkHealth();
		}
		
		private function checkCollision():void { 
			// This will run 3 seperate collision detections for the two guns and the Boss.
			if(_phase1 == true) {
				//This is the first boss phase. check to see if the gun arms are getting hit.
				for each (var nextProjectile:Projectile in Projectile.registry)
				{ 
					if (nextProjectile.particles3D != null) {
						if (gunbox1.hitTestObject(nextProjectile.particles3D)) {
							hitGun1(Constants.LDMG);
							nextProjectile.destroy();
							return;
						}
						if (gunbox2.hitTestObject(nextProjectile.particles3D)) {
							hitGun2(Constants.LDMG);
							nextProjectile.destroy();
							return;
						}
					}// End laser hit.
					else if (nextProjectile.sphere != null) {
						if(gunbox1.visible){
							if(gunbox1.hitTestObject(nextProjectile.sphere)) {
								hitGun1(Constants.LDMG);
								return;
							}
						}
						if(gunbox2.hitTestObject(nextProjectile.sphere)) {
							hitGun2(Constants.LDMG);
							return;
						}
					}// End Nuke hit.
					else if (nextProjectile.plane != null) {
						if(gunbox1.hitTestPoint(nextProjectile.plane.x,gunbox1.y,gunbox1.z)) {
							hitGun1(Constants.BEAMDMG);
							return;
						}
						if(gunbox2.hitTestPoint(nextProjectile.plane.x,gunbox2.y,gunbox2.z)) {
							hitGun2(Constants.BEAMDMG);
							return;
						}
					} // End Plane hit.
				} // End Projectile reg
			} // End the First Phase Loop
			else {
				// This is the final boss phase.
				for each (var nextProjectile2:Projectile in Projectile.registry)
				{
					if (nextProjectile2.particles3D != null) {
						if (hitbox.hitTestObject(nextProjectile2.particles3D)) {
							hit(Constants.LDMG);
							nextProjectile2.destroy();
							return;
						}
					}
					else if (nextProjectile2.sphere != null) {
						if(hitbox.hitTestObject(nextProjectile2.sphere)) {
							hit(Constants.LDMG);
							return;
						}
					}
					else if (nextProjectile2.plane != null) {
						if(hitbox.hitTestPoint(nextProjectile2.plane.x,this.y,this.z)) {
							hit(Constants.BEAMDMG);
							return;
						}
					}
				}
			} // End The Boss Final phase.
		}
		
		private function hit(damage:int):void {
			healthLevel -= damage;
			var eventObj:EnemyDamageEvent = new EnemyDamageEvent(Constants.ENEMYDMG);
			eventObj.damage = damage;
			_container.dispatchEvent(eventObj);
		}
		private function hitGun1(damage:int):void {
			gun1Health -= damage;
			if(gun1Health > 0){
				hit(damage);
				explodeArm(gunbox1.x,gunbox1.y,gunbox1.z);
			}
			if(gun1Health <= 0 && gun1Destroyed == false) {
				removeChild(_gun1dae);
				gunbox1.visible = false;
				sound2.play();
				gun1Destroyed = true;
			}
			if(gunbox1.visible == false && gunbox2.visible == false){
				_phase1 = false;
				_highSpeed = 15;
				_lowSpeed = -15;
			} 
		}
		private function hitGun2(damage:int):void {
			gun2Health -= damage;
			if(gun2Health > 0){
				explodeArm(gunbox2.x,gunbox2.y,gunbox2.z);
				hit(damage);
			}
			if(gun2Health <= 0 && gun2Destroyed == false) {
				gunbox2.visible = false;
				removeChild(_gun2dae);
				sound2.play();
				gun2Destroyed = true;
			}
			if(gunbox1.visible == false && gunbox2.visible == false){
				_phase1 = false;
				_highSpeed = 15;
				_lowSpeed = -15;
			}
		}
		
		private function checkHealth():void {
			if (healthLevel <= 0) {
				tallyScore();
				destroy();
				// LEVEL EVENT = TRIGGER TO CHANGE THE LEVEL HERE
				var eventObj:modEvent = new modEvent(Constants.GOTOHIGHSCORE);
				eventObj.modName = Constants.GOTOHIGHSCORE;
				eventObj.string = "you win!!!";
				_container.dispatchEvent(eventObj);
			}
			if (healthLevel < 70 && _timer % 30 == 0) {
				explode();
			}
		}
		/**
		 * Tallys the score, fires the points through the container to gameController > PFX > Interface for the current ship.
		 * @return
		 */
		public override function tallyScore():void {
			var eventObj:ScoreEvent = new ScoreEvent(Constants.SCORE);
			eventObj.score = Constants.BOSS4PTS;
			_container.dispatchEvent(eventObj);
		}
		/**
		 * Fires an explode of the gun to the container to gameController for the current ship.
		 * @return
		 */
		private function explodeArm(x:int,y:int,z:int):void {
			var eventObj:ExplosionEvent = new ExplosionEvent(Constants.EXP);
			eventObj.size = 75;
			eventObj.location = new Vector3D(x, y, z);
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
			_cm.unregisterObject(gunbox1);
			_cm.unregisterObject(gunbox2);
			_container.removeChild(hitbox);
			_container.removeChild(gunbox1);
			_container.removeChild(gunbox2);
			_container.removeChild(this);
		}
	} // End Boss1
}