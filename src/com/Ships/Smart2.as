package com.Ships
{
	import com.Constants;
	import com.Objects.flyingObjs.projectile.ELaserThree;
	import com.Objects.flyingObjs.projectile.Projectile;
	
	import events.DamageEvent;
	import events.ExplosionEvent;
	import events.ScoreEvent;
	
	import flash.geom.Vector3D;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.primitives.Cube;
	
	public class Smart2 extends Ship
	{
		public var hitbox:Cube;
		// Model
		private var _dae:DAE;
		
		private var _laserThree:ELaserThree;
		
		// Movement
		private var _xVel:int;
		private var _zVel:int = -4;
		private var _xbound:int = 400;
		private var _zboundFar:int = 700;
		private var _zboundClose:int = -200;
		private var _highSpeed:int = 10;
		private var _lowSpeed:int = -10;
		
		private var _cm:ColorMaterial = new ColorMaterial(0xAA00FF,0);
		private var _ml:MaterialsList = new MaterialsList();
		
		[Embed(source="assets/Sound/Tele/Smart2Tele1_SFX.mp3")] 
		private var soundAsset1:Class;
		private var sound1:Sound = new soundAsset1() as Sound;
		[Embed(source="assets/Sound/Tele/Smart2Tele2_SFX.mp3")] 
		private var soundAsset2:Class;
		private var sound2:Sound = new soundAsset2() as Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUMEMED);
		
		public function Smart2( x:int, y:int, z:int, container:DisplayObject3D)
		{
			super();
			container.addChild(this);
			_container = container;
			_warpSize = 6;
			
			_dae = new DAE();
			_dae.load("com/assets/Smart2.dae");
			_dae.scale = 0;
			_dae.y += 16;
			addChild(_dae);
			
			this.z = z;	
			this.x = x;
			this.y = y;
			
			_ml.addMaterial(_cm,"all");
			hitbox = new Cube(_ml,40,40,40);
			hitbox.position = this.position;
			_container.addChild(hitbox);
			
			warp();
			startMoving();
			playTele();
		}
		
		private function playTele():void {
			var random:int = Math.round(Math.random() * (2 - 1)) + 1;
			if (random == 1) {
				sound1.play(0,0,st);
			}
			else {
				sound2.play(0,0,st);
			}
		}
		
		public override function update():void
		{ 
			_timer++;
			
			if (_timer < 20)
				_dae.scale += .8;
			
			hitbox.position = this.position;
			
			if(_timer % 40 == 0) {
				_xVel = Math.round(Math.random() * (_highSpeed - _lowSpeed)) + _lowSpeed;
				_zVel = Math.round(Math.random() * (_highSpeed - _lowSpeed)) + _lowSpeed;
				_laserThree = new ELaserThree(this.position,_container);
			}
			if(Math.abs(x) > _xbound)
				_xVel = -_xVel;
			if(z > _zboundFar || z < _zboundClose)
				_zVel = -_zVel;
			move();
					
			checkCollision();
		}
		private function move():void {
			x += _xVel;
			z += _zVel;
		}
		
		protected function checkCollision():void
		{
			if (this.z < -370)
				destroy();
			
			if (hitbox.hitTestObject(Ship.registry[0])) {
				explode();
				destroy();
				var eventObj:DamageEvent = new DamageEvent(Constants.DMG);
				eventObj.damage = Constants.SMART2DMG;
				_container.dispatchEvent(eventObj);
				return;
			}
			
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
					if(hitbox.hitTestObject(nextProjectile.sphere)) {
						hit();
						return;
					}
				}
				else if (nextProjectile.plane != null) {
					if(hitbox.hitTestPoint(nextProjectile.plane.x,this.y,this.z)) {
						hit();
						return;
					}
				}
			}
		} // End CheckCollision
		
		private function hit():void {
			tallyScore();
			explode();
			destroy();
		}
		
		public override function tallyScore():void {
			var eventObj:ScoreEvent = new ScoreEvent(Constants.SCORE);
			eventObj.score = Constants.SMART2PTS;
			_container.dispatchEvent(eventObj);
		}
		
		private function explode():void {
			var eventObj:ExplosionEvent = new ExplosionEvent(Constants.EXP);
			eventObj.size = 75;
			eventObj.location = new Vector3D(this.x, this.y, this.z);
			_container.dispatchEvent(eventObj);
		}
		
		public override function destroy():void
		{
			stopMoving();
			var position:int = Ship.registry.indexOf(this,1);
			Ship.registry.splice(position,1);
			_cm.unregisterObject(hitbox);
			_container.removeChild(hitbox);
			_container.removeChild(this);
		}
	} // End Drone
}