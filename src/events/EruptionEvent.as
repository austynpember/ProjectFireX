package events
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	public class EruptionEvent extends Event
	{
		public var location:Vector3D;
		
		public function EruptionEvent(type:String, bubbles:Boolean=true)
		{
			super(type, true);
		}
		
		override public function clone():Event
		{
			var eventObj:EruptionEvent = new EruptionEvent(type);
			eventObj.location = this.location;
			return eventObj;
		}
	}
}