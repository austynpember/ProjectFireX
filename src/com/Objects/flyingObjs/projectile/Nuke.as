package com.Objects.flyingObjs.projectile
{
	import com.Constants;
	
	import flash.filters.GlowFilter;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.special.BitmapParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	
	public class Nuke extends Projectile
	{
		// Star Bitmap
		[Embed (source="/../assets/lava.jpg")]
		private var BitmapImage : Class;
		
		//Sound	
		[Embed(source="assets/Sound/Weapons/NukeExplosion_SFX.mp3")] 
		private var soundAsset1:Class;
		[Embed(source="assets/Sound/Weapons/NukeFire_SFX.mp3")] 
		private var soundAsset2:Class;
		private var sound1:Sound = new soundAsset1() as Sound;
		private var sound2:Sound = new soundAsset2() as Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUMEHIGH);
		
		// Info
		private var _greenMat:BitmapParticleMaterial;
		private var _bullet:Particle;
		private var _material:BitmapMaterial; 
		
		public function Nuke(startPos:Number3D,container:DisplayObject3D)
		{
			super();
			//Put this in the gameContainer
			weaponType = "Nuke";
			_container = container;
			
			_material = new BitmapMaterial(new BitmapImage().bitmapData);
			sphere = new Sphere(_material,600,10,6);
			// Set scale down to represent center of explosion then move sphere outwards with UPDATE().
			sphere.scale = 0.03;
			sphere.useOwnContainer = true;
			var glowFilter:GlowFilter = new GlowFilter(0xFF6600,1,130,130,4);
			sphere.filters = [glowFilter];

			_container.addChild(sphere);
			
			//Position infront of player so bitmap doesnt lag screen.
			sphere.x = startPos.x + 18;
			sphere.y = startPos.y;
			sphere.z = startPos.z + 140;
			
			// Kill every Enemy Projectile on screen.
			EnemyProjectile.pauseAll();
			for (var n:int = EnemyProjectile.registry.length - 1; n >= 0; n--) {
				EnemyProjectile.registry[0].destroy();
			}
			
			startMoving();
			sound1.play(0,0,st);
			sound2.play(1800,0,st);
		}
		
		
		public override function update():void {
			//Scale up and alpha down.
			sphere.scale += 0.05;
			sphere.alpha *= 0.92;
			
			if (sphere.scale > 0.6)
				destroy();
		}
		
		public override function destroy():void {
			// Stop moving and clear the Interval
			stopMoving();
			_material.unregisterObject(sphere);
			_container.removeChild(sphere);
			_container.removeChild(this);
			// Clear the ProjectileRegistry
			var position:int = Projectile.registry.indexOf(this,0);
			Projectile.registry.splice(position,1);
		}
	}
}