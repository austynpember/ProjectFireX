package events
{
	import flash.events.Event;
	
	public class LevelEvent extends Event
	{
		public var level:int;
		
		public function LevelEvent(type:String, bubbles:Boolean=true)
		{
			super(type, true);
		}
		
		override public function clone():Event
		{
			var eventObj:LevelEvent = new LevelEvent(type);
			eventObj.level = this.level;
			return eventObj;
		}
	}
}