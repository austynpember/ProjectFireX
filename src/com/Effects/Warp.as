package com.Effects
{
	import flash.geom.Vector3D;
	
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.actions.Fade;
	import org.flintparticles.common.actions.ScaleImage;
	import org.flintparticles.common.counters.Blast;
	import org.flintparticles.common.displayObjects.Ellipse;
	import org.flintparticles.common.displayObjects.RadialDot;
	import org.flintparticles.common.displayObjects.Ring;
	import org.flintparticles.common.easing.Quadratic;
	import org.flintparticles.common.initializers.ChooseInitializer;
	import org.flintparticles.common.initializers.InitializerGroup;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.integration.papervision3d.initializers.PV3DDisplayObjectClass;
	import org.flintparticles.threeD.actions.LinearDrag;
	import org.flintparticles.threeD.actions.Move;
	import org.flintparticles.threeD.emitters.Emitter3D;
	import org.flintparticles.threeD.initializers.Position;
	import org.flintparticles.threeD.zones.PointZone;
	
	public class Warp extends Emitter3D
	{
		/**
		 * @param position
		 * @return
		 */
		public function Warp( position:Vector3D, size:int )
		{
			counter = new Blast( 3 );
			
			var bubble:InitializerGroup = new InitializerGroup();
			bubble.addInitializer( new Lifetime( 1.5 ) );
			bubble.addInitializer( new PV3DDisplayObjectClass( RadialDot, 14, 0x00BBFF ) );
			
			var ellipse:InitializerGroup = new InitializerGroup();
			ellipse.addInitializer( new Lifetime( 1 ) );
			ellipse.addInitializer( new PV3DDisplayObjectClass( Ellipse, 16, 4, 0x00FFFF ) );
			
			var ring:InitializerGroup = new InitializerGroup();
			ring.addInitializer( new Lifetime( 1.5 ) );
			ring.addInitializer( new PV3DDisplayObjectClass( Ring, 4, 5, 0x00DDFF ) );
			
			addInitializer( new ChooseInitializer([bubble,ellipse,ring]));
			addInitializer( new Position( new PointZone( position ) ) );
			
			addAction( new Age( Quadratic.easeIn ) );
			addAction( new Move( ) );
			addAction( new LinearDrag( 0.01 ) );
			addAction( new ScaleImage( 1, size ) );
			addAction( new Fade( 0.5, 0 ) );
		}
	}
}