package com.Environments
{
	import com.Objects.SkyboxCube;
	
	import org.papervision3d.objects.DisplayObject3D;

	public class Skybox extends Environment
	{
		private var _container:DisplayObject3D;
		private var skyboxCube:SkyboxCube;
		/**
		 * Skybox sets up the skyBox cube.
		 * @param x @param y @param z @param levelContainer 
		 * @return
		 */
		public function Skybox(x:int, y:int, z:int, levelContainer:DisplayObject3D)
		{
			super();
			_container = levelContainer;
			_container.addChild(this);
			skyboxCube = new SkyboxCube;
			_container.addChild(skyboxCube);
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
			skyboxCube.unregisterMaterials();
			_container.removeChild(skyboxCube);
			_container.removeChild(this);
		}
	}
}