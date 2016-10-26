package com.Effects
{
	import flash.geom.Vector3D;
	
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.actions.Fade;
	import org.flintparticles.common.actions.ScaleImage;
	import org.flintparticles.common.counters.Blast;
	import org.flintparticles.common.displayObjects.RadialDot;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.integration.papervision3d.initializers.PV3DDisplayObjectClass;
	import org.flintparticles.threeD.actions.LinearDrag;
	import org.flintparticles.threeD.actions.Move;
	import org.flintparticles.threeD.actions.RandomDrift;
	import org.flintparticles.threeD.emitters.Emitter3D;
	import org.flintparticles.threeD.initializers.Position;
	import org.flintparticles.threeD.initializers.Velocity;
	import org.flintparticles.threeD.zones.ConeZone;
	import org.flintparticles.threeD.zones.PointZone;
	
	public class Eruption extends Emitter3D
	{
		private var eruptionPoint:Vector3D;
		private var directionalVector:Vector3D;
		/**
		 * Eruption is for Planet1 Object. This is a flint Emitter3D which chooses a pre-determined eruption point.
		 * Create a Blast of 14 particles that have a lifetime of about 5 seconds.  It then sets up an eruption going in 
		 * a conal direction out from the blast point.
		 * @param position
		 * @return
		 */
		public function Eruption( position:Vector3D )
		{
			//Choose 4 seperate eruption points.  Take the position of the planet and add these specific
			//positions to the vector to make the correct eruption point.
			var random:int = Math.round(Math.random() * (4-1)) + 1;
			switch(random) {
				case 1 :
					eruptionPoint = new Vector3D(-520,-30,-60).add(position);
					directionalVector = new Vector3D(-1,0,0);
					//trace("erp 1");
					break;
				case 2 :
					eruptionPoint = new Vector3D(0,-600,0).add(position);
					directionalVector = new Vector3D(0,-1,0);
					//trace("erp 2");
					break;
				case 3 :
					eruptionPoint = new Vector3D(-480,200,-50).add(position);
					directionalVector = new Vector3D(-1,0,0);
					//trace("erp 3");
					break;
				case 4 :
					eruptionPoint = new Vector3D(-480,0,-50).add(position);
					directionalVector = new Vector3D(-1,0,0);
					trace("erp 4");
					break;
				default :
					trace("Failed case in gas");
			}
			//Blast with 14 particles.
			counter = new Blast( 8 );
			//5-7 second lifespan
			addInitializer( new Lifetime( 3, 5 ) );
			addInitializer( new Position( new PointZone( eruptionPoint ) ) );
			//Cone from the eruptionpoint, in the direction chosen by case, with a 1 degree variance in direction. 175 height.
			addInitializer( new Velocity( new ConeZone( new Vector3D(0,0,0), directionalVector, 1 , 150 ) ) );
			addInitializer( new PV3DDisplayObjectClass( RadialDot, 10, 0x00EE44 ) );
			
			addAction( new Age( ) );
			addAction( new Move( ) );
			addAction( new LinearDrag( 0.01 ) );
			addAction( new ScaleImage( 4, 15 ) );
			addAction( new Fade( 0.6, 0 ) );
			addAction( new RandomDrift( 15, 15, 15 ) );
		}
	}
}