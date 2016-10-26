package com.Objects.flyingObjs.inatimate
{
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.objects.primitives.Cylinder;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.primitives.Sphere;

	//import org.papervision3d.objects.parsers.DAE;
	
	public class Wreckage extends InanimateObject
	{
		//private var dae:DAE;
		private var _container:DisplayObject3D;
		
		//Movement
		private var zVel:Number = -8;
		private var _wf:WireframeMaterial = new WireframeMaterial(0x222222);
		private var _wreck:DisplayObject3D;
		
		public function Wreckage(x:int, y:int, z:int, container:DisplayObject3D)
		{
			//Add this object to the levelContainer
			super();
			
			container.addChild(this);
			_container = container;
			
			var random:int = Math.round(Math.random() * (6-1)) + 1;
			
			switch (random) {
				case 1:
					_wreck = new Plane(_wf,80,120);
					break;
				case 2:
					_wreck = new Cylinder(_wf,14,150,6,2);
					break;
				case 3:
					_wreck = new Sphere(_wf,25,6,4);
					break;
				case 4:
					_wreck = new Sphere(_wf,35,8,6);
					break;
				case 5:
					_wreck = new Cylinder(_wf,8,110,2,3);
					break;
				case 6:
					_wreck = new Plane(_wf,40,140);
					break;
				default :
					trace("No Wreckage switch number");
			}
			var roll:int = Math.round(Math.random() * (180-1)) + 1;
			var yaw:int = Math.round(Math.random() * (180-1)) + 1;
			var pitch:int = Math.round(Math.random() * (180-1)) + 1;
			_wreck.roll(roll);
			_wreck.yaw(yaw);
			_wreck.pitch(pitch);
			addChild(_wreck);
			
			this.z = z;	
			this.x = x;
			this.y = y;
			
			startMoving();
		}
		
		public override function update():void {
			//Movement
			z+=zVel;
			
			if(this.z < -410)
				destroy();
		}
		
		public override function destroy():void
		{
			stopMoving();
			_wf.unregisterObject(_wreck);
			removeChild(_wreck);
			InanimateObject.registry.shift();
			_container.removeChild(this);
		}
	}
}