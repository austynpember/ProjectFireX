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
	
	public class Smart1 extends Ship
	{
		public var hitbox:Cube;
		// Model
		private var _dae:DAE;
		
		private var _laserThree:ELaserThree;
		
		// Movement
		private var _xVel:int = 6;
		private var _zVel:int = -8;
		
		private var _cm:ColorMaterial = new ColorMaterial(0x00FF00,0);
		private var _ml:MaterialsList = new MaterialsList();
		
		private var goLeft:Boolean;
		private var goRight:Boolean;
		
		[Embed(source="assets/Sound/Tele/Smart1Tele_SFX.mp3")] 
		private var soundAsset:Class;
		private var sound:Sound = new soundAsset() as Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUME);
		
		public function Smart1( x:int, y:int, z:int, container:DisplayObject3D)
		{
			super();
			container.addChild(this);
			_container = container;
			_warpSize = 6;
			
			_dae = new DAE();
			_dae.load("com/assets/Smart1.dae");
			_dae.rotationX = 180;
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
			sound.play(0,0,st);
		}
		
		public override function update():void
		{ 
			_timer++;
			if (_timer < 20)
				_dae.scale += .25;
			
			if(goRight)
				x += _xVel;
			if(goLeft)
				x -= _xVel;
			z += _zVel;
			
			hitbox.position = this.position;
			
			//This is the AI. Smart1 looks at the X position of the player and changes its X velocity accordingly.
			if (_timer % 18 == 0 && x - 300 < Ship.registry[0].x && x + 300 > Ship.registry[0].x && z > Ship.registry[0].z + 40) 
			{
				if(Ship.registry[0].x >= x) {
					goRight = true;
					goLeft = false;
				}
				else {
					goRight = false;
					goLeft = true;
				}
				_laserThree = new ELaserThree(this.position,_container);
			}
			
			checkCollision();
		}
		
		protected function checkCollision():void
		{
			if (this.z < -370)
			{
				destroy();
			}
			
			if (hitbox.hitTestObject(Ship.registry[0]))
			{
				explode();
				destroy();
				//trace(this.text + "hit player");
				var eventObj:DamageEvent = new DamageEvent(Constants.DMG);
				eventObj.damage = Constants.SMART1DMG;
				_container.dispatchEvent(eventObj);
				return;
			}
			
			for each (var nextProjectile:Projectile in Projectile.registry)
			{
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
			eventObj.score = Constants.SMART1PTS;
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