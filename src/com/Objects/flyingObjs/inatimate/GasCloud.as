package com.Objects.flyingObjs.inatimate
{
	import flash.geom.Vector3D;
	
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.actions.Fade;
	import org.flintparticles.common.actions.ScaleImage;
	import org.flintparticles.common.counters.Blast;
	import org.flintparticles.common.displayObjects.RadialDot;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.integration.papervision3d.PV3DRenderer;
	import org.flintparticles.integration.papervision3d.initializers.PV3DDisplayObjectClass;
	import org.flintparticles.threeD.actions.LinearDrag;
	import org.flintparticles.threeD.actions.Move;
	import org.flintparticles.threeD.actions.RandomDrift;
	import org.flintparticles.threeD.emitters.Emitter3D;
	import org.flintparticles.threeD.initializers.Position;
	import org.flintparticles.threeD.initializers.Velocity;
	import org.flintparticles.threeD.zones.PointZone;
	import org.flintparticles.threeD.zones.SphereZone;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class GasCloud extends InanimateObject
	{
		private var _container:DisplayObject3D;
		//Movement
		private var flintRenderer:PV3DRenderer;
		private var gas:Emitter3D;
		private var positionVector:Vector3D;
		private var _counter:int;
		
		public function GasCloud(x:int, y:int, z:int, container:DisplayObject3D)
		{
			//Add this object to the levelContainer
			super();
			container.addChild(this);
			_container = container;
			this.z = z;	
			this.x = x;
			this.y = y;
			flintRenderer = new PV3DRenderer( this.scene );
			positionVector = new Vector3D(this.x,this.y,this.z);
			setupGasCloud();
			flintRenderer.addEmitter( gas );
			gas.start();
			startMoving();
		}	
		
		private function setupGasCloud():void {
			gas = new Emitter3D();
			gas.counter = new Blast(2);
			
			gas.addInitializer( new Lifetime( 2, 3) );
			gas.addInitializer( new Position( new PointZone( positionVector ) ) );
			gas.addInitializer( new Velocity( new SphereZone( new Vector3D(0,0,0),65) ) );
			gas.addInitializer( new PV3DDisplayObjectClass( RadialDot, 8, 0x00DD33 ) );
			
			gas.addAction( new Age( ) );
			gas.addAction( new Move( ) );
			gas.addAction( new LinearDrag( 0.01 ) );
			gas.addAction( new ScaleImage( 1, 15 ) );
			gas.addAction( new Fade( 0.4, 0 ) );
			gas.addAction( new RandomDrift( 15, 15, 15 ) );
		}
		
		public override function update():void {
			_counter ++;
			if(_counter > 200)
				destroy();
		}
		
		public override function destroy():void {
			stopMoving();
			gas.stop();
			flintRenderer.removeEmitter( gas );
			InanimateObject.registry.shift();
			_container.removeChild(this);
		}
	}
}