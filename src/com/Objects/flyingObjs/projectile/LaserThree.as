package com.Objects.flyingObjs.projectile
{
	import com.Objects.flyingObjs.projectile.LaserTwo;
	
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class LaserThree 
	{
		private var _laserLeft:LaserTwo;
		private var _laserMiddle:LaserTwo;
		private var _laserRight:LaserTwo;
		private var _xVelLeft:int = -10;
		private var _xVelMiddle:int = 0;
		private var _xVelRight:int = 10;
		private var soundDelay1:int = 0;
		private var soundDelay2:int = 600;
		private var soundDelay3:int = 1200;
		
		public function LaserThree(startPos:Number3D,container:DisplayObject3D)
		{ 	
			_laserLeft = new LaserTwo(startPos, container, _xVelLeft, soundDelay1);
			_laserMiddle = new LaserTwo(startPos, container, _xVelMiddle, soundDelay2);
			_laserRight = new LaserTwo(startPos,container, _xVelRight, soundDelay3);
		}
	}
}