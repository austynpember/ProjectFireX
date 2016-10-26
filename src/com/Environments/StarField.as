package com.Environments
{
	import org.papervision3d.materials.special.BitmapParticleMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.special.ParticleField;

	public class StarField extends Environment
	{
		// Game utils
		private var particlemat:BitmapParticleMaterial;
		private var stars:ParticleField;
		private var _container:DisplayObject3D;
		
		// Star Bitmap
		[Embed (source="/../assets/star.png")]
		private var BitmapStar : Class;
		/**
		 * Starfield set up.  This is for level 2, star particles flying.
		 * @param x @param y @param z @param levelContainer 
		 * @return
		 */
		public function StarField(x:int, y:int, z:int, levelContainer:DisplayObject3D)
		{
			super();
			_container = levelContainer;
			_container.addChild(this);
			buildStarField();
		}
		
		// ****************** STAR FIELD FUNCTIONS **************** //
		private function buildStarField():void {
			particlemat = new BitmapParticleMaterial(new BitmapStar().bitmapData);
			stars = new ParticleField(particlemat, 400,1,1400,1400,4000);
			displayStarField();
			startMoving();
		}
		
		private function displayStarField():void {
			stars.x = 0;
			stars.y = 0;
			stars.z = 1800;
			_container.addChild(stars);
		}
		/**
		 * updates stars, then will reset the star field after it is about to escape from the camera's view.
		 * @return
		 */
		public override function update():void 
		{
			//This function will reset the star field after it is about to escape from the camera's view.
			stars.z -= 11;
			if(stars.z < -1700)
			{
				_container.removeChild(stars)
				displayStarField();
			}
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
			_container.removeChild(stars);
			_container.removeChild(this);
		}
	}
}