package events
{
	import flash.events.Event;
	
	public class ScoreEvent extends Event
	{
		public var score:int;
		
		public function ScoreEvent(type:String, bubbles:Boolean=true)
		{
			super(type, true);
		}
		
		override public function clone():Event
		{
			var eventObj:ScoreEvent = new ScoreEvent(type);
			eventObj.score = this.score;
			return eventObj;
		}
	}
}