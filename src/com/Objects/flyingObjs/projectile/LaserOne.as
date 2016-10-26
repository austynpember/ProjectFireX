package com.Objects.flyingObjs.projectile
{
	import com.Constants;
	
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import org.papervision3d.core.geom.Particles;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.special.BitmapParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;

	public class LaserOne extends Projectile
	{
		// Star Bitmap
		[Embed (source="/../assets/greenPart.png")]
		private var BitmapGreen : Class;
		// Info
		private var _greenMat:BitmapParticleMaterial;
		private var _bullet:Particle;
		
		// Movement
		private var _xVel:int;
		private var _zVel:int;
		
		//Sound	
		[Embed(source="assets/Sound/Weapons/Laser2_SFX.mp3")] 
		private var soundAsset:Class;
		private var sound:Sound;
		
		public function LaserOne(startPos:Number3D,container:DisplayObject3D)
		{
			super();
			//Put this in the gameContainer
			weaponType = "Laser One";
			_container = container;
			
			_greenMat = new BitmapParticleMaterial(new BitmapGreen().bitmapData);
			_bullet = new Particle(_greenMat,2);
			_zVel = 10;
			
			//Add a new Particles3D Container that Will hold the individual bullet sprites(particle)
			particles3D = new Particles();
			particles3D.addParticle(_bullet);
			//Set the XYZ to the passed in StartingPositions
			particles3D.position = startPos;
			_container.addChild(particles3D);
			
			startMoving();
			sound = new soundAsset() as Sound;
			var st:SoundTransform = new SoundTransform(Constants.VOLUME);
			sound.play(0,0,st);
		}
		
		
		public override function update():void {
			particles3D.z += _zVel;
			
			if(particles3D.z > 780)
				destroy();
		}
		
		public override function destroy():void {
			// Stop moving and clear the Interval
			stopMoving();
			particles3D.removeAllParticles();
			_container.removeChild(particles3D); 
			_container.removeChild(this);
			// Clear the ProjectileRegistry
			var position:int = Projectile.registry.indexOf(this,0);
			Projectile.registry.splice(position,1);
		}
	}
}