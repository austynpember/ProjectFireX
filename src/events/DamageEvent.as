package events
{
	import flash.events.Event;
	
	public class DamageEvent extends Event
	{
		public var damage:int;
		
		public function DamageEvent(type:String, bubbles:Boolean=true)
		{
			super(type, true);
		}
		
		override public function clone():Event
		{
			var eventObj:DamageEvent = new DamageEvent(type);
			eventObj.damage = this.damage;
			return eventObj;
		}
	}
}