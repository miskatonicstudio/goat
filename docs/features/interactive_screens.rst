Interactive screens
===================

A different type of interaction is offered by ``InteractiveScreen.tscn``
scene. It represents a flat surface that the player can click on, such
as a touch screen of a smartphone. Any type of 2D content can be used
with interactive screens, including movie players and minigames.

There are some things to keep in mind while working with interactive
screens:

-  each screen needs a child node called ``Content``, which represents a
   2D content displayed on the screen
-  content size has to be specified
-  the screen's surface is a square mesh, but it can be resized to
   achieve other aspect ratios

When a screen is in range, an iteraction icon will be shown, and it will
follow the movement of the raycast (either the camera or the mouse
cursor):

|Interactive screen's icon|

While doing that, the ``Content`` node will receive
``InputEventMouseMotion`` events. When the screen is selected, LMB click
will activate it. As a result, the ``Content`` node will receive two
``InputEventMouseButton`` events, one for pressing the mouse button, and
one for releasing it. RMB click will show the context inventory screen
(but only for environment screens).

Similar to interactive items, interactive screens should have a unique
name. They also work both in the environment and in the inventory.
Additionally, you can set the emission energy, which can be useful for
computer screens.

.. |Interactive screen's icon| image:: https://user-images.githubusercontent.com/36821133/73209966-97000380-4149-11ea-8ef9-2fd9185fa7d0.png
