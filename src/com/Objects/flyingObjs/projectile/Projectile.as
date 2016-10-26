package com.Objects.flyingObjs.projectile
{
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import org.papervision3d.core.geom.Particles;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;
	
	public class Projectile extends DisplayObject3D
	{
		public static var _registry:Vector.<Projectile> = new Vector.<Projectile>();
		
		public var particles3D:Particles;
		public var weaponType:String;
		public var sphere:Sphere;
		public var plane:Plane;
		protected var _container:DisplayObject3D;
		
		public static function get registry():Vector.<Projectile> {
			return _registry;
		}
		
		public static function set registry(v:Vector.<Projectile>):void {
			_registry = v;
		}
		
		private var updateInterval:uint;
		
		public function Projectile()
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
	}
}