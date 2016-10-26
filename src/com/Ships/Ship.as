package com.Ships
{
	import com.Constants;
	
	import events.WarpEvent;
	
	import flash.geom.Vector3D;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import org.papervision3d.objects.DisplayObject3D;
	
	public class Ship extends DisplayObject3D
	{
		/**
		 * Registry for all of the Environments to get put into. This provides access for other classes.
		 * @return
		 */
		public static var _registry:Vector.<Ship> = new Vector.<Ship>();
		private var updateInterval:uint;
		protected var _timer:int;
		protected var _container:DisplayObject3D;
		protected var _warpSize:int;
		/**
		 * gets the Registry
		 * @return
		 */
		public static function get registry():Vector.<Ship> {
			return _registry;
		}
		
		public static function set registry(v:Vector.<Ship>):void {
			_registry = v;
		}
		/**
		 * Ship is the parent class of all environmental objects. Push each child into this registry.
		 * @return
		 */
		public function Ship()
		{
			super();
			// Making sure everything gets put into this registry vector.
			_registry.push(this);
			
		}
		
		//   ENEMY SHIP MOVEMENT //
		// This Interval controls the UPDATE function on all Objects inheritting this.
		protected function startMoving():void {
			updateInterval = setInterval(update, 30);
		}
		
		protected function stopMoving():void {
			clearInterval(updateInterval);
		}
		
		//    PAUSE FUNCTIONALITY    //
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
		
		//    INITIALIZATION CALLS AND UPDATIONS    //
		/**
		 * Update() gets overrridden in child environments.
		 * @return
		 */
		public function update():void {
			// Override this in the child class or refactor later
		}
		/**
		 * Destroy() gets overrridden in child environments.
		 * @return
		 */
		public function destroy():void {
			// Override
		}
		/**
		 * tallyScore() gets overrridden in child environments.
		 * @return
		 */
		public function tallyScore():void {
			// Override
		}
		
		protected function warp():void {
			var eventObj:WarpEvent = new WarpEvent(Constants.WARP);
			eventObj.size = _warpSize;
			eventObj.location = new Vector3D(this.x, this.y, this.z);
			_container.dispatchEvent(eventObj);
		}
	}
}