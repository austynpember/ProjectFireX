Project Fire X (PFX) is the development name for a futuristic space scrolling-shooter game built for Flash.

PFX runs in Adobe Flash Player, either through a web version or an AIR application.
The game itself is housed inside of a Flex framework, which loads/interacts with the GameController.swf.
This framework enables the end user to flip through modules using menus or procedural navigation.

Flex enables “Skins” which are customizable “versions” of components ( example : ButtonEx )
ActionScript3 logic is written inside Flex components to control the visual Flex

PFX main application is a controller which has a module loader that loads either the IntroScreen, Interface, or HighScore modules.PFX

IntroScreen loads Intro.swf, which instantiate sand updates the introductory screen ( earth rotating.)
Interface is the GUI overlaying and loading GameController.swf. GameController runs the main loop for all game mechanics and instantiates all objects.

There are 5 main registries (vectors) which hold everything on screen for control of objects. These registries can be paused or filtered through in order to look for collisions.

    Papervision3D
    PFX uses the Papervision 3D library, which enables the world to be build upon 3D models, textures, and environments.
    PV3D is an open source 3D engine (library) for Flash. Sets up an environment or “view” which takes the place of a normal flash program’s “stage.”
    
    Most objects extent DisplayObject3D, which are very much like 2D DisplayObjects.
    I make my models/textures in Maya and export them as a Collada files. PV3D loads the assets as DAE files.

    Flint Particle System
    Flint is an Actionscript3 library for 2D & 3D effects that integrates with Papervision3D & Away 3D PFX uses Flint to render particle effects such as explosions, eruptions, gas clouds, and jet exhaust.
