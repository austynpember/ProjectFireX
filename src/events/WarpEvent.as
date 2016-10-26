package events
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	public class WarpEvent extends Event
	{
		public var size:int;
		public var location:Vector3D;
		
		public function WarpEvent(type:String, bubbles:Boolean=true)
		{
			super(type, true);
		}
		
		override public function clone():Event
		{
			var eventObj:WarpEvent = new WarpEvent(type);
			eventObj.size = this.size;
			eventObj.location = this.location;
			return eventObj;
		}
	}
}