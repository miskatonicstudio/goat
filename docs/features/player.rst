Player
======

GOAT features ``Player.tscn`` scene. Adding it to your project enables a
3D rotating camera (first person perspective) that can move (currently
only on flat surfaces). Movement can be performed using arrow keys or
WSAD keys. Player is surrounded with a collision shape, so it will
interact properly with obstacles in your game. It also includes a
raycast used for selecting 3D environment objects.

All GOAT interface elements are already attached to the player. That way
you only need to instance ``Player.tscn``, and you will automatically
get an inventory, context inventory, subtitles for voice recordings, and
a simple settings screen.
