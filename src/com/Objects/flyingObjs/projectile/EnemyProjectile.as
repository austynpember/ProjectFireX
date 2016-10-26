package com.Objects.flyingObjs.projectile
{
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import org.papervision3d.core.geom.Particles;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	
	public class EnemyProjectile extends DisplayObject3D
	{
		public static var _registry:Vector.<EnemyProjectile> = new Vector.<EnemyProjectile>();
		public static function get registry():Vector.<EnemyProjectile> {
			return _registry;
		}
		public static function set registry(v:Vector.<EnemyProjectile>):void {
			_registry = v;
		}
		
		public var particles3D:Particles;
		public var plane:Plane;
		public var weaponType:String;
		protected var _container:DisplayObject3D;
		private var updateInterval:uint;
		
		public function EnemyProjectile()
		{
			super();
			_registry.push(this);
		}
		
		// This Interval controls the UPDATE function on all Objects inheritting this.
		protected function startMoving():void {
			updateInterval = setInterval(update, 30);
		}
		
		protected function stopMoving():void {
			clearInterval(updateInterval);
		}
		
		//    PAUSE FUNCTIONALITY    //
		public static function pauseAll():void {
			for (var i:uint = 0; i < _registry.length; i++) {
				_registry[i].stopMoving();
			}
		}
		public static function unpauseAll():void {
			for (var i:uint = 0; i < _registry.length; i++) {
				_registry[i].startMoving();
			}
		}
		
		//    INITIALIZATION CALLS AND UPDATIONS    //
		public function update():void
		{
			//Override inside Child
		}
		
		public function destroy():void
		{
			//Override inside child
		}
		
		public function animateHit():void
		{
			// Visually kick the projectile offstage, but still exist in the registry to not screw up the registry.shift
			particles3D.removeAllParticles()
			_container.removeChild(particles3D);
			_container.removeChild(this);
		}
	}
}