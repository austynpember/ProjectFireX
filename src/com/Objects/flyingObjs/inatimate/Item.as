package com.Objects.flyingObjs.inatimate
{
	import com.Constants;
	import com.Ships.Player;
	import com.Ships.Ship;
	
	import events.DamageEvent;
	import events.NukeEvent;
	
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	import org.papervision3d.materials.WireframeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.primitives.Cube;
	
	public class Item extends InanimateObject
	{
		private var _kind:String;
		
		private var dae:DAE;
		private var hitbox:Cube;
		private var _container:DisplayObject3D;
		
		//Movement
		private var zVel:Number = -8;
		private var xVel:Number = 0;
		private var yVel:Number = 0;
		
		//Cube Materials
		private var _wf:WireframeMaterial = new WireframeMaterial(0xFF0000,0);
		private var _ml:MaterialsList = new MaterialsList();
		
		//Sound	
		[Embed(source="assets/Sound/Items/Health_SFX.mp3")] 
		private var healthAsset:Class;
		[Embed(source="assets/Sound/Items/NukePickup_SFX.mp3")] 
		private var nukeAsset:Class;
		[Embed(source="assets/Sound/Items/WeaponUpgrade_SFX.mp3")] 
		private var weaponAsset:Class;
		private var sound:Sound;
		private var st:SoundTransform = new SoundTransform(Constants.VOLUME);
		
		public function Item(x:int, y:int, z:int, container:DisplayObject3D, kind:String)
		{
			super();
			
			// Add this item to the levelContainer.
			container.addChild(this);
			_container = container;
			
			// Determine the kind of item this is.
			_kind = kind;
			
			//Add the model to this object
			dae = new DAE();
			switch(_kind) {
				case Constants.LASERITEM :
					dae.load("com/assets/itemLaser.dae");
					sound = new weaponAsset() as Sound;
					break;
				case Constants.NUKEITEM :
					dae.load("com/assets/itemNuke.dae");
					sound = new nukeAsset() as Sound;
					break;
				case Constants.HEALTHITEM :
					dae.load("com/assets/itemHealth.dae");
					sound = new healthAsset() as Sound;
					break;
			}
			dae.scale = 7;
			dae.rotationY = 180;
			dae.y += 16;
			addChild(dae);
			
			this.z = z;	
			this.x = x;
			this.y = y;
			//Add the hitbox to ensure that collisions can occur.
			_ml.addMaterial(_wf,"all");
			hitbox = new Cube(_ml,40,40,40);
			hitbox.position = this.position;
			_container.addChild(hitbox);
			
			startMoving();
		}
		
		public override function update():void {
			//Movement
			z+=zVel;
			
			//Rotate based on its velocities
			rotationX += zVel * .3;
			
			//Make sure the hitbox moves along with the itembox
			hitbox.position = this.position;
			
			checkCollision();
		}
		
		public override function checkCollision():void
		{
			if(this.z < -390)
				destroy();
			
			if (hitbox.hitTestObject(Ship.registry[0]))
			{ // If the item hits the player, figure out what kind of item it is and acclimate accordingly.
				switch (_kind)
				{
					case Constants.HEALTHITEM :
						var eventObj:DamageEvent = new DamageEvent(Constants.DMG);
						eventObj.damage = Constants.ITEMBOXHEALTH;
						_container.dispatchEvent(eventObj);
						sound.play(0,0,st);
						break;
					case Constants.LASERITEM :
						// Pass a weapon upgrade of ONE to the player1
						Player.changeBasicWeapon(1);
						sound.play(0,0,st);
						break;
					case Constants.NUKEITEM:
						//Give a player a nuke if they dont have 3 or more.
						if (Player.nukeNumber < 3) {
							Player.nukeNumber ++;
							var eventObj2:NukeEvent = new NukeEvent(Constants.NUKE);
							eventObj2.Nuke = 1;
							_container.dispatchEvent(eventObj2);
							sound.play(0,0,st);
						}
						break;
					default :
						trace("Not a kind of Item");
				}
				destroy();
			}
		}
		
		public override function destroy():void
		{
			stopMoving();
			var position:int = InanimateObject.registry.indexOf(this,0)
			InanimateObject.registry.splice(position,1);
			_wf.unregisterObject(hitbox);
			_container.removeChild(hitbox);
			_container.removeChild(this);
		}
		
	}
}