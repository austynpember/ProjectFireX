package com.Ships
{
	import com.Constants;
	import com.Objects.flyingObjs.inatimate.GasCloud;
	import com.Objects.flyingObjs.projectile.Projectile;
	
	import events.DamageEvent;
	import events.ScoreEvent;
	
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	
	public class Drone extends Ship
	{
		private var _drone:Sphere;
		
		[Embed (source="/../assets/Drone.jpg")]
		private var BitmapImage : Class; 
		
		// Movement
		private var _xVel:int;
		private var _zVel:int;
		
		private var _texture:BitmapMaterial;
		
		[Embed(source="assets/Sound/Tele/DroneTele_SFX.mp3")] 
		private var soundAsset1:Class;
		private var sound1:Sound = new soundAsset1() as Sound;
		[Embed(source="assets/Sound/Explosions/DroneDeath_SFX.mp3")] 
		private var soundAsset2:Class;
		private var sound2:Sound = new soundAsset2() as Sound;
		private var st1:SoundTransform = new SoundTransform(Constants.VOLUME);
		private var st2:SoundTransform = new SoundTransform(Constants.VOLUMEMED);
		/**
		 * Drone is the first enemy ship.  It sets up a texture that gets applied to a sphere.
		 * @param x @param y @param z @param @param xVel @param zVel @param container
		 * @return
		 */
		public function Drone( x:int, y:int, z:int, xVel:int, zVel:int, container:DisplayObject3D)
		{
			super();
			container.addChild(this);
			_container = container;
			_warpSize = 6;
			
			_texture = new BitmapMaterial(new BitmapImage().bitmapData);
			_drone = new Sphere(_texture,20,4,4);
			_drone.useOwnContainer = true;
			_drone.alpha = 0;
			this.z = z;	
			this.x = x;
			this.y = y;
			this._xVel = xVel;
			this._zVel = zVel;
			_drone.position = this.position;
			
			_container.addChild(_drone);
			
			sound1.play(0,0,st1);
			
			warp();
			
			startMoving();
		}
		/** 
		 * Checks for a collision, then updates the position.
		 * @return
		 */
		public override function update():void
		{ 
			
			x += _xVel;
			z += _zVel;
			
			_timer++
			if (_timer < 20)
				_drone.alpha += .05;
			
			if (_timer == 20)
				_drone.useOwnContainer = false;
			
			_drone.position = this.position;
			
			checkCollision();
		}
		
		protected function checkCollision():void
		{
			if (this.z < -390)
			{
				destroy();
			}
		
			if (_drone.hitTestObject(Ship.registry[0],3))
			{
				explode();
				destroy();
				var eventObj:DamageEvent = new DamageEvent(Constants.DMG);
				eventObj.damage = Constants.DRONEDMG;
				_container.dispatchEvent(eventObj);
				return;
			}
				
			for each (var nextProjectile:Projectile in Projectile.registry)
			{
				if (nextProjectile.particles3D != null) {
					if (_drone.hitTestObject(nextProjectile.particles3D,3)) {
						tallyScore();
						explode();
						destroy();
						nextProjectile.destroy();
						return;
					}
				}
				else if (nextProjectile.sphere != null) {
					if(_drone.hitTestObject(nextProjectile.sphere)) {
						tallyScore();
						explode();
						destroy();
						return;
					}
				}
				else if (nextProjectile.plane != null) {
					if(_drone.hitTestPoint(nextProjectile.plane.x,this.y,this.z)) {
						tallyScore();
						explode();
						destroy();
						return;
					}
				}
			}
		} // End CheckCollision
		/**
		 * Tallys the score, fires the points through the container to gameController > PFX > Interface for the current ship.
		 * @return
		 */
		public override function tallyScore():void {
			var eventObj:ScoreEvent = new ScoreEvent(Constants.SCORE);
			eventObj.score = Constants.DRONEPTS;
			_container.dispatchEvent(eventObj);
		}
		/**
		 * Fires an explode to the container to gameController for the current ship.
		 * @return
		 */
		private function explode():void {
			var gas:GasCloud = new GasCloud(x,y,z, _container);
			sound2.play(0,0,st2);
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
			_drone.useOwnContainer = true;
			_texture.unregisterObject(_drone);
			_container.removeChild(_drone);
			_container.removeChild(this);
		}
	} // End Drone
}