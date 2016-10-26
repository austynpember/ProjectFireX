package com.Environments
{
	import com.Constants;
	
	import events.EruptionEvent;
	
	import flash.geom.Vector3D;
	
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Sphere;
	
	public class Planet1 extends Environment
	{
		[Embed (source="/../assets/Planet.jpg")]
		private var BitmapImage : Class; 
		
		private var sphere:Sphere;
		private var _container:DisplayObject3D;
		private var _material:BitmapMaterial;
		private var _counter:int;
		/**
		 * Planet 1 will set up the planet on the first level.  Makes a material, creates a sphere, and starts moving.
		 * @param x @param y @param z @param container 
		 * @return
		 */
		public function Planet1(x:int, y:int, z:int, container:DisplayObject3D)
		{
			//Add this object to the levelContainer
			super();
			_container = container;
			_container.addChild(this);
			//{"trigger":2,"type":"Planet1","x":1100,"y":-500,"z":1400},
			
			_material = new BitmapMaterial(new BitmapImage().bitmapData);
			_material.tiled = true;
			_material.maxU = 2;
			_material.maxV = 2;
			_material.baked = true;
				
			sphere = new Sphere(_material,600,16,12);
			_container.addChild(sphere);
			this.z = z;	
			this.x = x;
			this.y = y;
			
			sphere.position = this.position;
			sphere.rotationY = 60;
			
			startMoving();
		}	
		/**
		 * updates the planet. spins, moves it closer, and fires off eruptions every 10 seconds or so.
		 * @return
		 */
		public override function update():void 
		{
			_counter++;
			sphere.yaw(-0.07);
			sphere.z += -0.5;
			if(_counter % 200 == 0) {
				var eventObj:EruptionEvent = new EruptionEvent(Constants.ERP);
				eventObj.location = new Vector3D(this.x, this.y, this.z);
				_container.dispatchEvent(eventObj);
			}
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