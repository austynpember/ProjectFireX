package com.Objects.flyingObjs.inatimate
{
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import org.papervision3d.objects.DisplayObject3D;
	
	public class InanimateObject extends DisplayObject3D
	{
		public static var _registry:Vector.<InanimateObject> = new Vector.<InanimateObject>();
		
		protected var updateInterval:uint;
		
		public static function get registry():Vector.<InanimateObject> {
			return _registry;
		}
		
		public static function set registry(v:Vector.<InanimateObject>):void {
			_registry = v;
		}
		
		public function InanimateObject()
		{
			super();
			_registry.push(this);
		}
		
		// Interval ise used for the UPDATE in all children.
		protected function startMoving():void {
			updateInterval = setInterval(update, 30);
		}
		
		public function stopMoving():void {
			clearInterval(updateInterval);
		}
		
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
		
		public function update():void
		{
			//Override inside Child
		}
		
		public function checkCollision():void {
			//Override inside child
		}
		
		public function destroy():void {
			// Override inside child
		}
	}
}