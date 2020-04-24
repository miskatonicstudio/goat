Game mode
=========

GOAT stores the current mode of the game in a global ``goat.game_mode``
variable. There are 5 modes available at the moment:

-  ``NONE``
-  ``EXPLORING``
-  ``INVENTORY``
-  ``CONTEXT_INVENTORY``
-  ``SETTINGS``

Each game mode has a corresponding screen, e.g. ``CONTEXT_INVENTORY``
shows a compact view of all available inventory items and allows the
player to choose one of them and use it on the currently selected
environment object. The ``NONE`` mode should be used for e.g. main menu
of the game.

You can change the game mode at any time like this:

::

   goat.game_mode = goat.GameMode.EXPLORING

This will send a signal: ``goat.game_mode_changed`` with the new value
of the game mode. Each of the screens provided by GOAT is connected to
this signal and when its own mode is chosen, the screen shows up
(otherwise the screen is hidden). You can safely change the game mode's
value in order to force showing a specific screen (e.g. when an
important item is obtained, you might want to open the inventory to
indicate that the player should interact with it).

**Note: game mode is only used during gameplay, it should not affect
e.g. the main menu of the game. Also, the game doesn't pause in any of
these modes.**
