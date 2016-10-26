package com.Environments
{
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	
	public class EarthLevel extends Environment
	{
		[Embed (source="/../assets/EarthWithClouds.jpg")]
		private var BitmapImage : Class; 
		
		private var sphere:Sphere;
		private var _container:DisplayObject3D;
		private var _material:BitmapMaterial;
		/**
		 * EarthLevel is the 4th level environment.  Make the material, double side it, create the sphere.  
		 * @param x @param y @param z @param container
		 * @return
		 */
		public function EarthLevel(x:int, y:int, z:int, container:DisplayObject3D)
		{
			//Add this object to the levelContainer
			super();
			_container = container;
			_container.addChild(this);
			
			_material = new BitmapMaterial(new BitmapImage().bitmapData); 
			_material.doubleSided = true;
			
			sphere = new Sphere(_material,1300,10,6);
			_container.addChild(sphere);
			
			this.z = z;	
			this.x = x;
			this.y = y;
			
			sphere.position = this.position;
			sphere.rotationZ = 90;
			
			startMoving();
		}	
		/**
		 * Update by spinning the earth so as to appear flying over the earth.
		 * @return
		 */
		public override function update():void 
		{
			sphere.yaw(-0.045);
			sphere.pitch(-0.01);
			sphere.roll(-0.005);
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