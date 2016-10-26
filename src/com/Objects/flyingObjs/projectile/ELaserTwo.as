package com.Objects.flyingObjs.projectile
{
	import org.papervision3d.core.geom.Particles;
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.special.BitmapParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class ELaserTwo extends EnemyProjectile
	{
		// Star Bitmap
		[Embed (source="/../assets/redPart.png")]
		private var BitmapRed : Class;
		
		// Info
		private var _redMat:BitmapParticleMaterial;
		private var _bullet:Particle;
		
		// Movement
		private var _xVel:int;
		private var _zVel:int;
		
		public function ELaserTwo(startPos:Number3D,container:DisplayObject3D, xVel:int)
		{
			super();
			//Put this in the gameContainer
			weaponType = "Laser Two";
			_container = container;
			_xVel = xVel;
			
			_redMat = new BitmapParticleMaterial(new BitmapRed().bitmapData);
			_bullet = new Particle(_redMat,2);
			_zVel = -12;
			
			//Add a new Particles3D Container that Will hold the individual bullet sprites(particle)
			particles3D = new Particles();
			particles3D.addParticle(_bullet);
			//Set the XYZ to the passed in StartingPositions
			particles3D.x = startPos.x;
			particles3D.y = startPos.y;
			particles3D.z = startPos.z;
			_container.addChild(particles3D);
			
			startMoving();
		}
		
		
		public override function update():void {
			particles3D.z += _zVel;
			particles3D.x += _xVel;
			
			if(particles3D.z < -360)
				destroy();
		}
		
		public override function destroy():void {
			// Stop moving and clear the Interval
			stopMoving();
			animateHit();
			// Clear the ProjectileRegistry
			EnemyProjectile.registry.shift();
		}
	}
}