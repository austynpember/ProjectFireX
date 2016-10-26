package com.Objects.flyingObjs.projectile
{
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.objects.DisplayObject3D;
	import com.Objects.flyingObjs.projectile.ELaserTwo;
	
	public class ELaserThree 
	{
		private var _laserLeft:ELaserTwo;
		private var _laserMiddle:ELaserTwo;
		private var _laserRight:ELaserTwo;
		private var _xVelLeft:int = -10;
		private var _xVelMiddle:int = 0;
		private var _xVelRight:int = 10;
		
		public function ELaserThree(startPos:Number3D,container:DisplayObject3D)
		{ 
			_laserLeft = new ELaserTwo(startPos, container, _xVelLeft);
			_laserMiddle = new ELaserTwo(startPos, container, _xVelMiddle);
			_laserRight = new ELaserTwo(startPos,container, _xVelRight);
		}
	}
}