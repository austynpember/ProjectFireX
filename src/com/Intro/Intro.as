package com.Intro {
	import com.Constants;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.actions.ColorChange;
	import org.flintparticles.common.actions.Fade;
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.integration.papervision3d.PV3DPixelRenderer;
	import org.flintparticles.threeD.actions.Accelerate;
	import org.flintparticles.threeD.actions.Move;
	import org.flintparticles.threeD.emitters.Emitter3D;
	import org.flintparticles.threeD.initializers.Velocity;
	import org.flintparticles.threeD.zones.DiscZone;
	import org.papervision3d.core.effects.BitmapLayerEffect;
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.shaders.*;
	import org.papervision3d.materials.special.BitmapParticleMaterial;
	import org.papervision3d.materials.special.CompositeMaterial;
	import org.papervision3d.materials.special.ParticleMaterial;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.objects.special.ParticleField;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.BitmapEffectLayer;

	
	[SWF (width="800", height="600", backgroundColor="0x00FF00", frameRate="30")]
	
	public class Intro extends BasicView
	{
		//Objects, pixels, and layers
		private var sphere : Sphere; 
		private var cloudSphere : Sphere;
		private var light : PointLight3D;
		private var glowFilterEarth : GlowFilter;
		private var emitter:Emitter3D;
		private var flintRenderer:PV3DPixelRenderer;
		private var bitmapEffectLayer:BitmapEffectLayer;
		private var pixels:Pixels;
		private var stars : ParticleField;
		
		//Materials and DAE
		private var shader : Shader; 
		private var shadedMaterial : ShadedMaterial;
		private var cloudMaterial : BitmapMaterial; 
		private var compositeMaterial : CompositeMaterial;
		private var _cm:ColorMaterial = new ColorMaterial(0x0000FF);
		private var _dae : DAE;
		private var particleMat : ParticleMaterial;
		
		// Camera Info
		private var pitch : Number = 0; 
		private var targetPitch : Number = 0; 
		private var yaw : Number = 0; 
		private var targetYaw : Number = 0; 
		
		// Mouse info
		public var lastMousePoint : Point = new Point(); 
		public var isMouseDown : Boolean = false; 
		
		[Embed (source="/../assets/EarthWithClouds.jpg")]
		private var EarthMap : Class; 
		private var earthbmp:BitmapData;
		[Embed (source="/../assets/earthbump.jpg")]
		private var BumpMap : Class; 
		private var bumpmap :BitmapData 
		//[Embed (source="/../assets/earthcloudmap.png")]
		//private var CloudMap : Class; 
		//private var clouds : BitmapData
		[Embed (source="/../assets/star.png")]
		private var StarBitmap : Class; 
		
		private var earthmaterial : BitmapMaterial;
		
		[Embed(source="assets/Sound/Intro/IntroMusic_SFX.mp3")] 
		private var soundAsset1:Class;
		private var introMusic:Sound = new soundAsset1() as Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUME);
		private var myCurrentChannel:SoundChannel = new SoundChannel();
		
		/**
		 * This class sets everything up for the introductory screen.  Everything is private because this is such
		 * and independent class. It is loaded up under the IntroScreen module. Make the light, materials, DAE, fps counter,
		 * flint particle initialization, sounds, and then set up the earth/stars and run an EnterFrame loop.
		 * @return
		 */
		public function Intro()
		{
			setupLight();
			setupMaterials();
			setupDAE();
			fpsCounter();
			flintInit();
			setupSound();
			
			sphere = new Sphere(shadedMaterial, 150,28,18);
			scene.addChild(sphere);
			
			sphere.useOwnContainer=true;
			
			sphere.filters = [glowFilterEarth];
			
			camera.fov = 25;
			
			stars = new ParticleField(particleMat, 1000, 1);
			scene.addChild(stars);
	
			addEventListener(Event.ENTER_FRAME, runLoop, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
		}
		
		private function setupSound():void {
			myCurrentChannel = introMusic.play(0,3,st);
		}
		
		private function flintInit():void {
			setupPixels();
			setupEmitter();
			setupFlintRenderer();
			emitter.start();
		}
		
		private function setupPixels():void
		{
			// Create a layer to which there are going to be effects generated.
			bitmapEffectLayer = new BitmapEffectLayer(viewport,800,600);
			//Force this into the background.
			bitmapEffectLayer.forceDepth = true;
			viewport.containerSprite.addLayer( bitmapEffectLayer );
			// Create pixels that attach to this effect layer.
			pixels = new Pixels(bitmapEffectLayer);
			bitmapEffectLayer.addDisplayObject3D(pixels);
			scene.addChild(pixels);
			// Add the efects to the layer > pixels.
			bitmapEffectLayer.addEffect(new BitmapLayerEffect(new BlurFilter(3, 3, 1)));
			bitmapEffectLayer.addEffect(new BitmapLayerEffect(new ColorMatrixFilter([ 1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0.95,0 ])));
		}
		
		private function setupEmitter():void
		{
			emitter = new Emitter3D();
			emitter.counter = new Steady( 200 );
			// Velocity (area where this effect will occur)... First designate the area to be that of a disc.
			// Next, the first vector 3D is the length of the spray (actually the center of the effect), the 2nd Vector is the Normal vector (direction.
			emitter.addInitializer(new Velocity(new DiscZone(new Vector3D(0, 0, -100), new Vector3D(0, 0, -1), 10, 50)));////-600,600,100
			emitter.addInitializer(new Lifetime(1, 3));
			// Add these ideas to the emitter
			emitter.addAction(new Move());
			emitter.addAction(new ColorChange( 0xCCCC00, 0x22FF00 ) );
			emitter.addAction(new Accelerate(new Vector3D(0, 0, -30) ) );
			emitter.addAction(new Age());
			emitter.addAction(new Fade());
			emitter.runAhead( 3 );
		}
		
		private function setupFlintRenderer():void
		{
			flintRenderer = new PV3DPixelRenderer(pixels);
			flintRenderer.addEmitter(emitter);
		}
		
		private var startTime:Number;
		private var framesNumber:Number = 0;
		private var fps:TextField = new TextField();
		
		private function fpsCounter():void  {
			startTime = getTimer();
			fps.textColor = 0xFFFFFF;
			addChildAt(fps, 1);
			addEventListener(Event.ENTER_FRAME, checkFPS);
		}
		private function checkFPS(e:Event):void  
		{
			var currentTime:Number = (getTimer() - startTime) / 1000;
			framesNumber++;
			if (currentTime > 1)  {
				fps.text = "FPS: " + (Math.floor((framesNumber/currentTime)*10.0)/10.0);
				startTime = getTimer();
				framesNumber = 0;
			}
		}
		
		private function setupLight():void {
			light = new PointLight3D();
			light.z = -600;
			light.x = -250;
			light.y = 50;
			scene.addChild(light);
		}
		
		private function setupMaterials():void {
			// set up the bitmap for the material
			earthbmp = new EarthMap().bitmapData;
			bumpmap = new BumpMap().bitmapData;
	
			glowFilterEarth = new GlowFilter( 0x55AAFF, 0.4 , 12, 12 );
			
			particleMat = new BitmapParticleMaterial(new StarBitmap().bitmapData);
			
			// the bitmap material 
			earthmaterial = new BitmapMaterial(earthbmp);
			earthmaterial.smooth = true;
			
			// the type of shader to use... 
			shader = new PhongShader(light,0xFFFFFF,0x2A2A2A,0,bumpmap);
			// and the shaded material. 
			shadedMaterial = new ShadedMaterial(earthmaterial, shader);
	
		}
		
		private function setupDAE():void {
			// DAE for player.
			_dae = new DAE();
			_dae.load("com/assets/player1.dae");
			_dae.scale = 2;
			scene.addChild(_dae);
		}
		
		private function runLoop(e:Event) : void {
			sphere.yaw(-0.2);
			
			_dae.x = _dae.y = _dae.z = 0;
			_dae.rotationY += 2;
			_dae.rotationX += 3;
			_dae.moveUp(180);
			
			pixels.position = _dae.position;
			pixels.rotationY += 2;
			pixels.rotationX += 3;
			
			updateCameraAndRender();
		}
		
		private function updateCameraAndRender() : void
		{
			if(isMouseDown)
			{
				// If the mouse is down, we will be able to spin the camera around the central axis (0,0,0).
				targetPitch += ((mouseY - lastMousePoint.y)*0.1);
				targetYaw += ((mouseX - lastMousePoint.x)*0.1);
				
				lastMousePoint.x = mouseX; 
				lastMousePoint.y = mouseY; 
				//singleRender();
			}
			
			// Pitch and Yaw to the new target pitch set (if mouse down), else this doesnt change.
			pitch+=((targetPitch-pitch)*0.2); 
			yaw +=((targetYaw-yaw)*0.2); 
			
			// Make sure camera is always anchored to the origin.
			camera.x = camera.y = camera.z = 0;
			
			camera.rotationX = pitch;
			camera.rotationY = yaw; 
			
			// Move the camera back behind the ship initially, keep it 500 game length away from the origin.
			camera.moveBackward(900);
			
			singleRender();
		}
		
		private function destroy(e:Event) : void {
			removeEventListener(Event.ENTER_FRAME, runLoop);
			removeEventListener(Event.ENTER_FRAME, checkFPS);
			removeChild(fps);
			scene.removeChild(_dae);
			scene.removeChild(light);
			scene.removeChild(stars); 
			// UNREGISTER THE material in order to manually garbage collect.
			shadedMaterial.unregisterObject(sphere);
			scene.removeChild(sphere);
			// Remove Flint 
			emitter.stop();
			emitter.killAllParticles();
			flintRenderer.removeEmitter(emitter);
			viewport.containerSprite.removeAllLayers();
			scene.removeChild(pixels);
			//Remove sound
			myCurrentChannel.stop();
		}
		
		/**
		 * mouseDown will flag true and grab the mouseX and Y.  MouseDown signal, used for camera movement.
		 */
		private function mouseDown(e : MouseEvent) : void {
			// MouseDown signal, used for camera movement.
			isMouseDown = true; 
			lastMousePoint.x = mouseX; 
			lastMousePoint.y = mouseY; 
		}
		private function mouseUp(e : MouseEvent) : void {
			isMouseDown = false; 
		}
	}
}
