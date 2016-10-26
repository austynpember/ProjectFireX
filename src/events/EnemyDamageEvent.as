package events
{
	import flash.events.Event;
	
	public class EnemyDamageEvent extends Event
	{
		public var damage:int;
		
		public function EnemyDamageEvent(type:String, bubbles:Boolean=true)
		{
			super(type, true);
		}
		
		override public function clone():Event
		{
			var eventObj:EnemyDamageEvent = new EnemyDamageEvent(type);
			eventObj.damage = this.damage;
			return eventObj;
		}
	}
}