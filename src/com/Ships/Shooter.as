package com.Ships
{
	import com.Constants;
	import com.Objects.flyingObjs.projectile.ELaserOne;
	import com.Objects.flyingObjs.projectile.Projectile;
	
	import events.DamageEvent;
	import events.ExplosionEvent;
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
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.view.layer.ViewportLayer;
	
	public class Shooter extends Ship
	{
		/** hitbox used as the Collision detection */
		public var hitbox:Cube;
		// Model
		private var _dae:DAE;
		
		private var _laserOne:ELaserOne;
		private var _lastPos:Number3D;
		
		// Movement
		private var _xVel:int;
		private var _zVel:int;
		
		private var _cm:ColorMaterial = new ColorMaterial(0x00FFFF,0);
		private var _ml:MaterialsList = new MaterialsList();
		
		[Embed(source="assets/Sound/Tele/ShooterTele_SFX.mp3")] 
		private var soundAsset:Class;
		private var sound:Sound = new soundAsset() as Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUMEMED);
		/**
		 * Shooter is the enemy that flies in a specific direction and shoots periodically. 
		 * The Constructor sets up the DAE (model,)  and sets up the hitbox, then starts moving.
		 * @param x @param y @param z @param xVel @param zVel @param container 
		 * @return
		 */
		public function Shooter( x:int, y:int, z:int, xVel:int, zVel:int, container:DisplayObject3D)
		{
			super();
			container.addChild(this);
			_container = container;
			_warpSize = 6;
			
			_dae = new DAE();
			_dae.load("com/assets/Shooter.dae");
			_dae.rotationX = 180;
			_dae.x += 15;
			_dae.scale = 0;
			addChild(_dae);
			
			this.z = z;	
			this.x = x;
			this.y = y;
			_xVel = xVel;
			_zVel = zVel;
			
			_ml.addMaterial(_cm,"all");
			hitbox = new Cube(_ml,40,40,40);
			hitbox.position = this.position;
			_container.addChild(hitbox);
			
			warp();
			startMoving();
			sound.play(0,0,st);
		}
		
		public override function update():void
		{ 
			
			x += _xVel;
			z += _zVel;
			
			hitbox.position = this.position;
			
			_timer++;
			if (_timer < 20)
				_dae.scale += .25;
			
			if (_timer % 14 == 0)
			{
				_laserOne = new ELaserOne(this.position,_container);
			}
			
			checkCollision();
		}
		
		protected function checkCollision():void {
			if (this.z < -370) {
				destroy();
			}
			
			if (hitbox.hitTestObject(Ship.registry[0])) {
				explode();
				destroy();
				var eventObj:DamageEvent = new DamageEvent(Constants.DMG);
				eventObj.damage = Constants.SHOOTERDMG;
				_container.dispatchEvent(eventObj);
				return;
			}
			
			for each (var nextProjectile:Projectile in Projectile.registry) {
				if (nextProjectile.particles3D != null) {
					if (hitbox.hitTestObject(nextProjectile.particles3D)) {
						tallyScore();
						explode();
						destroy();
						nextProjectile.destroy();
						return;
					}
				}
				else if (nextProjectile.sphere != null) {
					if(hitbox.hitTestObject(nextProjectile.sphere)) {
						tallyScore();
						explode();
						destroy();
						return;
					}
				}
				else if (nextProjectile.plane != null) {
					if(hitbox.hitTestPoint(nextProjectile.plane.x,this.y,this.z)) {
						tallyScore();
						explode();
						destroy();
						return;
					}
				}
			}
		} // End CheckCollision
		
		public override function tallyScore():void {
			var eventObj:ScoreEvent = new ScoreEvent(Constants.SCORE);
			eventObj.score = Constants.SHOOTERPTS;
			_container.dispatchEvent(eventObj);
		}
		
		private function explode():void {
			var eventObj:ExplosionEvent = new ExplosionEvent(Constants.EXP);
			eventObj.size = 75;
			eventObj.location = new Vector3D(this.x, this.y, this.z);
			_container.dispatchEvent(eventObj);
		}
		
		/**
		 * Destroys this Ship.  Stops this from moving(updating.)
		 * Finds the position in the Registry and splices it out. 
		 * Then it calls a Tweenlight to alpha the drone down... when it is complete it calls
		 * throwAwayModel which unregisters all materials, and removes this from display tree.
		 * @return
		 */
		public override function destroy():void {
			stopMoving();
			var position:int = Ship.registry.indexOf(this,1);
			Ship.registry.splice(position,1);
			throwAwayModel();
		}
		private function throwAwayModel():void {
			_cm.unregisterObject(hitbox);
			_container.removeChild(hitbox);
			_container.removeChild(this);
		}
	} // End Drone
}