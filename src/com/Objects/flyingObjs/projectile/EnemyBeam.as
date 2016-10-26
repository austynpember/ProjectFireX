package com.Objects.flyingObjs.projectile
{
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	
	public class EnemyBeam extends EnemyProjectile
	{
		// Star Bitmap
		[Embed (source="/../assets/EnemyBeam.png")]
		private var BitmapBeam : Class;
		// Info
		private var _beamMat:BitmapMaterial;
		private var _timer:int;
		
		public function EnemyBeam(startPos:Number3D,container:DisplayObject3D)
		{
			super();
			//Put this in the gameContainer
			weaponType = "Beam";
			_container = container;
			
			_beamMat = new BitmapMaterial(new BitmapBeam().bitmapData);
			_beamMat.doubleSided = true;
			plane = new Plane(_beamMat,40,900);
			plane.rotationX = 90;
			plane.useOwnContainer = true;
			//var glowFilter:GlowFilter = new GlowFilter(0x00FFFF,0.7,30,30,1);
			//plane.filters = [glowFilter];
			plane.x = startPos.x;
			plane.y = startPos.y;
			plane.z = startPos.z - 450;
			_container.addChild(plane);
			
			startMoving(); 
		}
		
		
		public override function update():void {
			_timer ++;
			plane.rotationZ += 45;
			plane.alpha -= 0.1;
			
			if (_timer > 10)
				destroy();
		}
		
		public override function destroy():void {
			// Stop moving and clear the Interval
			stopMoving();
			_beamMat.unregisterObject(plane);
			_container.removeChild(plane); 
			// Clear the ProjectileRegistry
			var position:int = EnemyProjectile.registry.indexOf(this,0);
			EnemyProjectile.registry.splice(position,1);
			_container.removeChild(this);
		}
	}
}