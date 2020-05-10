Interactive items
=================

Simple interaction can be added to your program by using
``InteractiveItem.tscn`` scene. It represents an object that can be
activated, for example a switch on a wall or a button on a keyboard.

There are 3 types of iteractive items:

-  ``NORMAL``: can be activated multiple times, e.g. a door that opens
   and closes
-  ``SINGLE_USE``: can be activated only once, e.g. a rock pushed from a
   cliff
-  ``INVENTORY``: activating it removes the interactive item and adds an
   inventory item

Interactive item contains a collision shape that is detected by
raycasts. A default collision shape is provided, but you can easily
change it. You can also configure sounds that will be played randomly when the
item is activated.

**Note: interactive items don't have any visible elements by default. If
you want to associate them with a 3D model, add a mesh as interactive
item's child. You can also use models added elsewhere, but it will not
work correctly with** ``INVENTORY`` **items (which should be removed after
activation).**

When an interactive item is in range (that is: close enough and in front
of the camera or under the mouse cursor) it will be selected. This state
is indicated by an interaction icon:

|Interactive item's icon|

When an item is selected, LMB click will activate it. RMB click will
call an alternative activation, which for ``INVENTORY`` type items works
like normal activation (the item will be picked up), and for other items
shows the context inventory screen.

Interactive items work both in the environment and in the inventory,
however, in inventory mode alternative activation is not supported.

|Interactive item in inventory|

Each interactive item should have a unique name, which will be used to
send signals (more about it later). Moreover, for ``INVENTORY`` items
you need to configure the name of the inventory item that will be added
after interactive item is activated (inventory items configuration will
be explained later).

|Editor settings for interactive items|

.. |Interactive item's icon| image:: https://user-images.githubusercontent.com/36821133/73209757-37a1f380-4149-11ea-8934-9154d4a71ee3.png
.. |Interactive item in inventory| image:: https://user-images.githubusercontent.com/36821133/73208525-e55fd300-4146-11ea-9ce3-39e1c1caeaae.png
.. |Editor settings for interactive items| image:: https://user-images.githubusercontent.com/36821133/73211894-60c48300-414d-11ea-9c79-61f565aa1a81.png

