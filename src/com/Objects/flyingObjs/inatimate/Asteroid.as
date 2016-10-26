package com.Objects.flyingObjs.inatimate
{
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	
	public class Asteroid extends InanimateObject
	{
		private var dae:DAE;
		private var _container:DisplayObject3D;
		
		//Movement
		private var zVel:Number = -11;
		
		public function Asteroid(x:int, y:int, z:int, container:DisplayObject3D)
		{
			//Add this object to the levelContainer
			super();
			
			container.addChild(this);
			_container = container;
			
			//Add the model to this object
			dae = new DAE();
			dae.load("com/assets/ast2.dae");
			var scaleSize:int = Math.round(Math.random() * (26 - 14)) + 14;
			dae.scale = scaleSize;
			dae.alpha = 0;
			addChild(dae);
			
			this.z = z;	
			this.x = x;
			this.y = y;
			
			startMoving();
		}	
		
		public override function update():void {
			//Movement
			z += zVel;
			
			if(this.z < -410)
				destroy();
		}
		
		public override function destroy():void
		{
			stopMoving();
			InanimateObject.registry.shift();
			_container.removeChild(this);
		}
	}
}