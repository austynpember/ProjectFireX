package com.Objects
{
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	
	public class SkyboxCube2 extends Cube 
	{
		
		[Embed (source="/../assets/space_env_front2.jpg")]
		private var BitmapFront : Class; 
		[Embed (source="/../assets/space_env_right2.jpg")]
		private var BitmapRight : Class; 
		[Embed (source="/../assets/space_env_back2.jpg")]
		private var BitmapBack : Class; 
		[Embed (source="/../assets/space_env_left2.jpg")]
		private var BitmapLeft : Class; 
		[Embed (source="/../assets/space_env_bottom2.jpg")]
		private var BitmapDown : Class; 
		[Embed (source="/../assets/space_env_top2.jpg")]
		private var BitmapUp : Class; 
		
		private var matFront : BitmapMaterial;
		private var matLeft : BitmapMaterial;
		private var matBack : BitmapMaterial;
		private var matUp : BitmapMaterial;
		private var matRight : BitmapMaterial;
		private var matDown : BitmapMaterial;
		private var ml : MaterialsList;
		/**
		 * SkyboxCube sets up 6 materials and double side them all. 
		 * @return
		 */
		public function SkyboxCube2()
		{
			
			matFront = new BitmapMaterial(new BitmapFront().bitmapData); 
			matLeft = new BitmapMaterial(new BitmapLeft().bitmapData); 
			matBack = new BitmapMaterial(new BitmapBack().bitmapData); 
			matUp = new BitmapMaterial(new BitmapUp().bitmapData); 
			matRight = new BitmapMaterial(new BitmapRight().bitmapData); 
			matDown  = new BitmapMaterial(new BitmapDown().bitmapData); 
			
			// set the doubleSided flag on each material otherwise we wouldn't be able to 
			// see the cube from the inside!
			
			matFront.doubleSided = true; 
			matLeft.doubleSided = true; 
			matBack.doubleSided = true; 
			matUp.doubleSided = true; 
			matRight.doubleSided = true; 
			matDown.doubleSided = true; 
			
			ml = new MaterialsList(); 
			
			ml.addMaterial(matFront, "front"); 
			ml.addMaterial(matLeft, "left"); 
			ml.addMaterial(matBack, "back"); 
			ml.addMaterial(matUp, "top"); 
			ml.addMaterial(matRight, "right"); 
			ml.addMaterial(matDown, "bottom"); 
			
			// make a massive cube for a skybox!
			super(ml,5000,5000,5000,6,6,6);
			
		}
		/**
		 * unregister all materials.
		 * @return
		 */
		public function unregisterMaterials():void {
			matFront.unregisterObject(super);
			matLeft.unregisterObject(super);
			matBack.unregisterObject(super);
			matUp.unregisterObject(super);
			matRight.unregisterObject(super);
			matDown.unregisterObject(super);
		}
		
	}
}