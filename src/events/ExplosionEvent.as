package events
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	public class ExplosionEvent extends Event
	{
		public var size:int;
		public var location:Vector3D;
		
		public function ExplosionEvent(type:String, bubbles:Boolean=true)
		{
			super(type, true);
		}
		
		override public function clone():Event
		{
			var eventObj:ExplosionEvent = new ExplosionEvent(type);
			eventObj.size = this.size;
			eventObj.location = this.location;
			return eventObj;
		}
	}
}