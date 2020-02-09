Directory structure
===================

There are 2 directories in this repository:

-  ``goat``: contains all scenes and resources of the template; normally
   there is no need to change anything here, unless you want to
   implement features that the template doesn't support yet
-  ``demo``: contains actual game resources, such as sounds, voice
   recordings, 3D models, materials etc.

The structure of the ``demo`` folder looks like this:

::

   demo
   ├── fonts             # All fonts used in the game
   ├── globals           # All global scripts, configured as Singletons (AutoLoad)
   ├── images            # All images, e.g. a custom cursor
   ├── inventory_items   # REQUIRED; configuration for inventory items
   │   ├── icons         # Icons representing inventory items (one per item)
   │   └── models        # 3D models representing inventory items (one per item)
   ├── materials         # Materials for 3D models
   ├── models            # 3D models (usually reused in more than one scene)
   ├── pickable_items    # 3D scenes representing environment objects that can be picked up
   ├── scenes            # Most of the scenes used in the game
   │   ├── main          # Scenes responsible for main game screens (main menu, credits, settings, gameplay)
   │   └── other         # All remaining scenes
   ├── sounds            # All sounds used in the game, except for voice recordings
   └── voice             # REQUIRED; all voice recordings

When you start working on your project, you should replace the ``demo``
folder with the resources of your own game. You can modify the structure
in the listing above, but you need to keep the folders marked as
``REQUIRED``.

To use a custom game resources directory, you need to configure it
first, probably in one of your game's global files:

::

   goat.GAME_RESOURCES_DIRECTORY = "demo"

As mentioned before, GOAT provides a default settings screen. The "Exit"
button on that screen exit the program by default. If you want it to
redirect to e.g. the main menu of your game, you can change it like
this:

::

   goat.EXIT_SCENE = "res://demo/scenes/main/MainMenu.tscn"
