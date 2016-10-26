package events
{
	import flash.events.Event;
	
	public class NukeEvent extends Event
	{
		public var Nuke:int;
		
		public function NukeEvent(type:String, bubbles:Boolean=true)
		{
			super(type, true);
		}
		
		override public function clone():Event
		{
			var eventObj:NukeEvent = new NukeEvent(type);
			eventObj.Nuke = this.Nuke;
			return eventObj;
		}
	}
}