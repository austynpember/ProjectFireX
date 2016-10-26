package com.game.Effects
{
	import flash.geom.Vector3D;
	
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.actions.ColorChange;
	import org.flintparticles.common.actions.Fade;
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.threeD.actions.Accelerate;
	import org.flintparticles.threeD.actions.Move;
	import org.flintparticles.threeD.emitters.Emitter3D;
	import org.flintparticles.threeD.initializers.Velocity;
	import org.flintparticles.threeD.zones.LineZone;
	
	public class SprayEmitter3D extends Emitter3D
	{
		/**
		 * This is a spray like on the intro screen for the player, this is not instantiated on the game for lag purposes.
		 * @return
		 */
		public function SprayEmitter3D()
		{
			counter = new Steady( 120 );
			addInitializer(new Velocity(new LineZone(new Vector3D(-200,0,-280), new Vector3D(200,0,-280))));
			addInitializer(new Lifetime(0.8, 1.4));
			addAction(new Move());
			addAction(new ColorChange( 0xCCCC00, 0x22FF00 ) );
			addAction(new Accelerate(new Vector3D(0, 0, -60) ) );
			addAction(new Age());
			addAction(new Fade());
			runAhead( 3 );
		}
	}
}