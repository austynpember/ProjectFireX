package events
{
	import flash.events.Event;
	
	public class modEvent extends Event
	{
		public var modName:String;
		public var string:String;
		
		public function modEvent(type:String, bubbles:Boolean=true)
		{
			super(type,true );
		}
		override public function clone():Event
		{
			var eventObj:modEvent = new modEvent(type);
			eventObj.modName = this.modName;
			eventObj.string = this.string;
			return eventObj;
		}
	}
}