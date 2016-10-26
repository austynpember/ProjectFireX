package interfaces
{
	public interface IGameInterface
	{
		function registerDamage(dmg:int):void;
		function updateLevel(level:int):void;
		function damageBoss(edmg:int):void;
		function updateScore(score:int):void;
		function updateNuke(nuke:int):void;
		function showDebug():void;
		function hideDebug():void;
		function showHelp():void;
		function hideHelp():void;
		function showOptions():void;
		function clearBossHealth():void;
	}
}