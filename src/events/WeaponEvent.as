package events
{
	import flash.events.Event;
	
	public class WeaponEvent extends Event
	{
		public var weaponNumber:int;
		
		public function WeaponEvent(type:String, bubbles:Boolean=false)
		{
			super(type, true);
		}
		override public function clone():Event
		{
			var eventObj:WeaponEvent = new WeaponEvent(type);
			eventObj.weaponNumber = this.weaponNumber;
			return eventObj;
		}
	}
}