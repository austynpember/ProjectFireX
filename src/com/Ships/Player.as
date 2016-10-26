package com.Ships
{
	import com.Constants;
	import com.Objects.flyingObjs.projectile.*;
	
	import events.DamageEvent;
	import events.LevelEvent;
	import events.NukeEvent;
	import events.WeaponEvent;
	
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.primitives.Cube;
	
	public class Player extends Ship
	{
		// Model
		private var _dae:DAE;
		/** hitbox used as the Collision detection */
		public var hitbox:Cube;
		
		// Movement
		private const _speed:Number = .97;
		private const _friction:Number = 0.9;
		private const _maxspeed:Number = 10;
		private var _vx:Number = 0;
		private var _vy:Number = 0;
		private var _lastPos:Number3D;
		
		private var _paused:Boolean = false;
		//  ***  Weapons  *** //
		// Vector to cycle through weapons based on effectiveness and power
		private static var _weaponArray:Array;
		// This basic weapon will tell the space bar which type of weapon to fire
		/**  This basic weapon will tell the space bar which type of weapon to fire */
		public static var basicWeapon:String;
		// This holds the place value for the weapon in the weapon array
		/** This holds the place value for the weapon in the weapon array */
		public static var currentWeaponPosition:int;
		
		private var _laserOne:LaserOne;
		private var _laserTwo:LaserTwo;
		private var _laserThree:LaserThree;
		private var _beam:Beam;
		/** This holds the number of nukes that we currently have */
		public static var nukeNumber:int;
		private var _nuke:Nuke;
		/** This holds the timer at which we can fire a weapon - only %10 or 3.  Timer resets every release of spacebar*/
		public static var normalTimer:int;
		
		// Movement
		private const LEFT_BORDER:int = -210;
		private const RIGHT_BORDER:int = 210;
		
		public static var leftPressed:Boolean;
		public static var rightPressed:Boolean;
		/**  Basic weapon key press */
		public static var normalPressed:Boolean;
		
		// Material for the player hitbox (set to invisible)
		private var _cm:ColorMaterial = new ColorMaterial(0x0000FF,0);
		private var _ml:MaterialsList = new MaterialsList();
		/**
		 * This is the players ship that you control.  The constructor sets up the model, then the hitbox.  It sets the current
		 * weapon to the parameter, and then creates the WeaponArray which is an array to go through weapons
		 *  based on your weapon power up.  Then set up the number of nukes based on the parameter and startMoving.
		 * @param gameContainer @param weapon @param nuke
		 * @return
		 */
		public function Player(gameContainer:DisplayObject3D, weapon:int, nuke:int)
		{
			super();
			// Model
			_container = gameContainer;
			_dae = new DAE();
			_dae.load("com/assets/player1.dae");
			_dae.scale = 7;
			addChild(_dae);
			
			// Hitbox
			_ml.addMaterial(_cm,"all");
			hitbox = new Cube(_ml,40,40,40);
			hitbox.position = this.position;
			_container.addChild(hitbox);
			
			// Weapon set up
			currentWeaponPosition = weapon;
			createWeaponArray();
			nukeNumber = nuke;
			
			_lastPos = new Number3D();
			startMoving();
		}
		
		private function createWeaponArray():void {
			// This will set the basic weapon to the current weapon position in this list.
			_weaponArray = new Array(
				{type:Constants.LASERONE},
				{type:Constants.LASERTWO},
				{type:Constants.LASERTHREE},
				{type:Constants.BEAM}
				);
			var weaponObject:Object =  _weaponArray[currentWeaponPosition];
			basicWeapon = weaponObject.type;
		}
		/**
		 * Update Player. If a directional flag is pressed, move in that direction (unless beyond X=210 limits.)
		 * Apply friction to movement.  Swivel the ship.  Make sure you don't go over a maxspeed.
		 * Update the current Position of ship, centering it for weapon creation.  
		 * Check if the space is pressed, if it is - start it's timer and fire the current weapon every half second.
		 * @return
		 */
		public override function update():void
		{ 
			// Movement
			if(leftPressed && x > LEFT_BORDER) {
				_vx -= _speed;
			}
			if(rightPressed && x < RIGHT_BORDER) {
				_vx += _speed;
			}
			
			_vx *= _friction;
			
			x += _vx;

			//Update swivel of ship
			rotationZ = -_vx;
			
			//Make sure ship doesn't go over maxspeed.
			if (_vx > _maxspeed)
				_vx = _maxspeed;
			else if (_vx < -_maxspeed)
				_vx = -_maxspeed;
			
			//Update the current Position of ship, centering it for weapon creation
			_lastPos.x = x - 18;
			_lastPos.y = y + 24;
			_lastPos.z = z + 44;
			
			hitbox.position = this.position;
			
			// Weapons
			if(normalPressed) {
				normalTimer++;
				
				if(normalTimer % 10 == 0 || normalTimer == 3) {
					fireCurrentWeapon();
				}
			}
			
			checkCollision();
			
		} // END UPDATE
		/**
		 * Fire the secondary weapon (nuke).  First check if you have a nuke in your arsenal.
		 * Make a new nuke at the _lastPos, and get rid of your nuke number.  Then fire off a NukeEvent which
		 * fires to gameController > PFX > Interface and removes a nuke icon.
		 * @return
		 */
		public function fireSecondaryWeapon():void {
			if(nukeNumber != 0) {
				_nuke = new Nuke(_lastPos,_container);
				nukeNumber --;
				var eventObj:NukeEvent = new NukeEvent(Constants.NUKE);
				eventObj.Nuke = -1;
				_container.dispatchEvent(eventObj);
			}
		}
		/**
		 * Fires the weapon that is current.  Switch statement based on the number gathered from the weapon array.
		 * @return
		 */
		public function fireCurrentWeapon():void {
			// Find out Which weapon is currently selected and create the projectile for it.
			switch (basicWeapon) {
				case (Constants.LASERONE) :
					_laserOne = new LaserOne(_lastPos, _container);
					break;
				
				case (Constants.LASERTWO) :
					_laserTwo = new LaserTwo(_lastPos, _container, 0, 0);
					break;	
				
				case (Constants.LASERTHREE) :
					_laserThree = new LaserThree(_lastPos, _container);
					break;	
				
				case (Constants.BEAM) :
					_beam = new Beam(_lastPos, _container);
					break;	
				
				default :
					trace("Incorrect Weapon type");
			} // END SWITCH
		}
		/**
		 * Changes weapon with parameter called from hitting an Item.  If we are not at max or min weapon level, 
		 * increase/decrease currentweapon position. Calls to the weapon array.
		 * @param weapon
		 * @return
		 */
		public static function changeBasicWeapon(weapon:int):void {
			switch (weapon) {
				case 1 :
					if (currentWeaponPosition != _weaponArray.length -1) {
						currentWeaponPosition ++;
						var weaponObjectUp:Object =  _weaponArray[currentWeaponPosition];
						basicWeapon = weaponObjectUp.type;
					}
					break;

				case -1 : 
					if (currentWeaponPosition != 0) {
						currentWeaponPosition --;
						var weaponObjectDown:Object =  _weaponArray[currentWeaponPosition];
						basicWeapon = weaponObjectDown.type;
					}
					break;
				default :
					trace("Changed to no weapon");
			} // END SWITCH
		}
		
		private function dispatchWeaponEvent():void {
			var eventObj:WeaponEvent = new WeaponEvent(Constants.WPN);
			eventObj.weaponNumber = currentWeaponPosition;
			_container.dispatchEvent(eventObj);
		}
		
		protected function checkCollision():void {
			for each (var nextEnemyProjectile:EnemyProjectile in EnemyProjectile.registry)
			{
				if (nextEnemyProjectile.particles3D != null) {
 					if (hitbox.hitTestObject(nextEnemyProjectile.particles3D)) {
						var eventObj:DamageEvent = new DamageEvent(Constants.DMG);
						eventObj.damage = 1;
						_container.dispatchEvent(eventObj);
						nextEnemyProjectile.animateHit();
					}
				}
				else if (nextEnemyProjectile.plane != null) {
					if(hitbox.hitTestPoint(nextEnemyProjectile.plane.x,this.y,this.z)) {
						var eventObj2:DamageEvent = new DamageEvent(Constants.DMG);
						eventObj2.damage = 1;
						_container.dispatchEvent(eventObj2);
					}
				}
			} // END FOR
		}
		/**
		 * Destroys this Ship.  Stops this from moving(updating.)
		 * Finds the position in the Registry and splices it out. Unregisters all materials.
		 * Removes objects from the container to disconnect from display tree.
		 * @return
		 */
		public override function destroy():void
		{
			trace("In player Destroy");
			stopMoving();
			var position:int = Ship.registry.indexOf(this,0);
			Ship.registry.splice(position,1);
			_cm.unregisterObject(hitbox);
			_container.removeChild(hitbox);
			_container.removeChild(this);
		}
	}
}