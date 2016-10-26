package com.Effects
{
	import flash.geom.Vector3D;
	
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.actions.Fade;
	import org.flintparticles.common.counters.Blast;
	import org.flintparticles.common.easing.Quadratic;
	import org.flintparticles.common.initializers.ColorInit;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.threeD.actions.Accelerate;
	import org.flintparticles.threeD.actions.LinearDrag;
	import org.flintparticles.threeD.actions.Move;
	import org.flintparticles.threeD.emitters.Emitter3D;
	import org.flintparticles.threeD.initializers.Position;
	import org.flintparticles.threeD.initializers.Velocity;
	import org.flintparticles.threeD.zones.PointZone;
	import org.flintparticles.threeD.zones.SphereZone;
	
	public class SphereBang extends Emitter3D
	{
		/**
		* Creates a spherical explosion with a size and position based upon the parameters.  This is for the explosions
		* that look like fireworks.
		* @param position
		* @param size
		* @return
		*/
		public function SphereBang( position:Vector3D, size:int )
		{
			counter = new Blast( size );
			addInitializer( new ColorInit( 0xFF4400, 0xFFCC00 ) );
			addInitializer( new Position( new PointZone( position ) ) );
			addInitializer( new Velocity( new SphereZone( new Vector3D(), size * 2 ) ) );
			addInitializer( new Lifetime( 0.8, 2 ) );
			addAction( new Age( Quadratic.easeIn ) );
			addAction( new Move() );
			addAction( new Fade() );
			addAction( new Accelerate( new Vector3D( 0, -150, 0 ) ) );
			addAction( new LinearDrag( 0.5 ) );
		}
	}
}