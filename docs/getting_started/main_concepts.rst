Main concepts
=============

GOAT is intended to help you make your own adventure games, but there
are some assumptions that you need to keep in mind while working with
it. This section provides a general overview of the template. More
details can be found in other sections of this document.

GOAT supports only 3D, first person perspective, single player games.
The player can explore a 3D environment and interact with objects in it.
A special type of interaction allows the player to pick up an object and
add it to the inventory. The inventory contains 3D items that can be
rotated and interacted with. There is a general distinction between the
environment (where the player can move) and the inventory (where picked
up items are stored). However, both support practically the same types
of interaction, e.g. you can press a button on a wall (environment) or
on a remote control (inventory).

|Interactive button of a remote control in inventory|

The template uses several global variables (AutoLoad). One of them is
the mode of the game. Currently, 5 modes are implemented:

-  ``NONE`` the game hasn't started yet (default)
-  ``EXPLORING`` the player is moving and interacting with the 3D
   environment
-  ``INVENTORY`` the player is browsing 3D items in the inventory
-  ``CONTEXT_INVENTORY`` the player is trying to use an inventory item
   on the environment (e.g. open a door with a key)
-  ``SETTINGS`` the settings screen is shown during the game

**Note: the game doesn't pause in any of these modes.**

GOAT is a Godot project. The assumption is that if you want to create
your own game, you will clone this repository and replace the demo game
files with your own. In order to create an interactive environment, you
can use 3 main scenes provided by GOAT (all described in detail in other
sections):

-  ``Player``
-  ``InteractiveItem``
-  ``InteractiveScreen``

You also need to provide the configuration for:

-  inventory items
-  voice recordings

Most GOAT resources (voice recordings, interactive objects, inventory
items) are identified by unique names. In most cases, getter methods
return those names, not the actual resources (e.g. audio files or 3D
scenes).

GOAT provides many signals, that let you react to different situations
in the game. For example, you can decide to play a voice recording after
a button on a wall is pressed or remove an inventory item after the
player uses it.

GOAT provides also default styles and layouts for the inventory, context
inventory, subtitles, and settings. Usually, there is no reason to
change anything in the template files, unless you want to modify the
style or add new features (which you are encouraged to do, this is open
source after all!).

.. _Godot Engine: https://github.com/godotengine/godot
.. _3.2 stable: https://downloads.tuxfamily.org/godotengine/3.2/
.. _readthedocs: https://miskatonicstudio-goat.readthedocs.io

.. |Interactive button of a remote control in inventory| image:: https://user-images.githubusercontent.com/36821133/73209215-14c30f80-4148-11ea-8afc-3f2fc7ef9037.png
