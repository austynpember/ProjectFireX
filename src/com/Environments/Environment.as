package com.Environments
{
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class Environment extends DisplayObject3D
	{
		/**
		* Registry for all of the Environments to get put into. This provides access for other classes.
		* @return
		*/
		public static var _registry:Vector.<Environment> = new Vector.<Environment>();
		/**
		 * gets the Registry
		 * @return
		 */
		public static function get registry():Vector.<Environment> {
			return _registry;
		}
		public static function set registry(v:Vector.<Environment>):void {
			_registry = v;
		}
		
		protected var updateInterval:uint;
		/**
		 * Environment is the parent class of all environmental objects. Push each child into this registry.
		 * @return
		 */
		public function Environment()
		{
			super();
			_registry.push(this);
		}
		
		protected function startMoving():void {
			updateInterval = setInterval(update, 30);
		}
		
		protected function stopMoving():void {
			clearInterval(updateInterval);
		}
		/**
		 * Pause Everything in this registry.
		 * @return
		 */
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
		/**
		 * Update() gets overrridden in child environments.
		 * @return
		 */
		public function update():void {
			// Override
		}
		/**
		 * Destroy() gets overrridden in child environments.
		 * @return
		 */
		public function destroy():void {
			// Override
		}
	}
}