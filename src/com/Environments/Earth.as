package com.Environments
{
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	
	public class Earth extends Environment
	{
		[Embed (source="/../assets/SmallEarth.png")]
		private var BitmapImage : Class; 
		
		private var sphere:Sphere;
		private var _container:DisplayObject3D;
		private var _material:BitmapMaterial;
		/**
		 * Earth Class sets up a material and a sphere, and calls startMoving.
		 * @param x @param y @param z @param container
		 * @return
		 */
		public function Earth(x:int, y:int, z:int, container:DisplayObject3D)
		{
			//Add this object to the levelContainer
			super();
			_container = container;
			_container.addChild(this);
			
			_material = new BitmapMaterial(new BitmapImage().bitmapData);
			
			sphere = new Sphere(_material,300,14,12);
			_container.addChild(sphere);
			
			this.z = z;	
			this.x = x;
			this.y = y;
			
			sphere.x = this.x;
			sphere.y = this.y;
			sphere.z = this.z;
			sphere.rotationY = 20;
			
			startMoving();
		}	
		/**
		 * Update function will yaw(spin) the earth and move it slightly closer to the camera constantly.
		 * @return
		 */
		public override function update():void 
		{
			sphere.yaw(0.07);
			sphere.z += -0.5;
		}
		/**
		 * Destroys this environment.  Stops this from moving(updating.)
		 * Finds the position in the Registry and splices it out. Unregisters all materials.
		 * Removes objects from the container to disconnect from display tree.
		 * @return
		 */
		public override function destroy():void
		{
			stopMoving();
			var position:int = Environment.registry.indexOf(this,0)
			Environment.registry.splice(position,1);
			_material.unregisterObject(sphere);
			_container.removeChild(sphere);
			_container.removeChild(this);
		}
	}
}