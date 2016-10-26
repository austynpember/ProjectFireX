package com.Environments
{
	import com.Objects.SkyboxCube2;
	
	import org.papervision3d.objects.DisplayObject3D;
	
	public class Skybox2 extends Environment
	{
		private var _container:DisplayObject3D;
		private var skyboxCube2:SkyboxCube2;
		/**
		 * Skybox2 sets up the skyBox2 cube.
		 * @param x @param y @param z @param levelContainer 
		 * @return
		 */
		public function Skybox2(x:int, y:int, z:int, levelContainer:DisplayObject3D)
		{
			super();
			_container = levelContainer;
			_container.addChild(this);
			skyboxCube2 = new SkyboxCube2;
			_container.addChild(skyboxCube2);
		}
		/**
		 * Destroys this environment.  Stops this from moving(updating.)
		 * Finds the position in the Registry and splices it out. Unregisters all materials.
		 * Removes objects from the container to disconnect from display tree.
		 * @return
		 */
		public override function destroy():void {
			stopMoving();
			var position:int = Environment.registry.indexOf(this,0)
			Environment.registry.splice(position,1);
			skyboxCube2.unregisterMaterials();
			_container.removeChild(skyboxCube2);
			_container.removeChild(this);
		}
	}
}