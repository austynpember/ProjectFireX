package com.Objects.flyingObjs.projectile
{
	import com.Constants;
	
	import flash.filters.GlowFilter;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	
	public class Beam extends Projectile
	{
		// Star Bitmap
		[Embed (source="/../assets/Beam.png")]
		private var BitmapBeam : Class;
		// Info
		private var _beamMat:BitmapMaterial;
		private var _timer:int;
		
		//Sound	
		[Embed(source="assets/Sound/Weapons/Beam_SFX.mp3")] 
		private var soundAsset:Class;
		private var sound:Sound = new soundAsset() as Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUME); 
		
		public function Beam(startPos:Number3D,container:DisplayObject3D)
		{
			super();
			//Put this in the gameContainer
			weaponType = "Beam";
			_container = container;
			
			_beamMat = new BitmapMaterial(new BitmapBeam().bitmapData);
			_beamMat.doubleSided = true;
			plane = new Plane(_beamMat,40,800);
			plane.rotationY = 180;
			plane.rotationX = 90;
			plane.useOwnContainer = true;
			var glowFilter:GlowFilter = new GlowFilter(0x00FFFF,0.7,30,30,1);
			plane.filters = [glowFilter];
			plane.x = startPos.x + 18;
			plane.y = startPos.y - 20;
			plane.z = startPos.z + 390;
			_container.addChild(plane);
			
			startMoving(); 
			sound.play(0,0,st);
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
			_container.removeChild(this);
			// Clear the ProjectileRegistry
			var position:int = Projectile.registry.indexOf(this,0);
			Projectile.registry.splice(position,1);
		}
	}
}