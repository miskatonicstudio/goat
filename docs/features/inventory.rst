Inventory
=========

GOAT offers an inventory system. It holds a maximum of 8 items, each
represented by a 3D model that can be rotated and interacted with. Items
can be added either by your script or automatically when an
``INVENTORY`` interactive item is activated. You can also use items on
each other (drag and drop), on themselves ("Use" button), or on
environment (using the custom inventory, explained in the next section).

You can open the inventory by pressing Tab while in ``EXPLORING`` mode.
In inventory, you can rotate items by holding RMB and moving the mouse.
You can also interact with items by clicking on them with LMB (that is,
if they contain any interactive parts). Clicking on a button on the left
side selects a different item.

|Inventory with the "Use" button|

To use the inventory, you need to register an inventory item first:

::

   goat_inventory.register_item(item_name)

Inventory items must be stored in the ``inventory_items`` directory of
your game resources folder. You need to provide both a 2D icon (shown in
the inventory bar), and a 3D model. ``item_name`` must match both files
(without extension, and following Godot's naming convention for scenes).
For example, a ``floppy_disk`` item would need the following files:

::

   demo/inventory_items/
   ├── icons
   │   └── floppy_disk.png
   └── models
       ├── FloppyDisk.gd # This is not obligatory
       └── FloppyDisk.tscn

And the registration would look like this:

::

   goat_inventory.register_item("floppy_disk")

Icons have to be 64x64 PNG images, and should have a transparent
background. Models can be any Spatial scenes, and can have additional
logic included in a script. Models should be centered in (0, 0, 0) and
should not be larger than a sphere with a 1 unit radius (otherwise they
will not be displayed properly).

Item registration process stores the names of icons and models, but
nothing more. At some point you might want to actually load those
resources:

::

   goat_inventory.get_item_icon(item_name)
   goat_inventory.get_item_model(item_name)

Icons are returned as a ``StreamTexture``, models as a ``PackedScene``
(which has to be instanced). Both of these methods are used internally
by GOAT and usually don't have to be accessed directly by game
developers.

You can add, remove, and replace items in the inventory using the
following methods:

::

   goat_inventory.add_item(item_name)
   goat_inventory.remove_item(item_name)
   goat_inventory.replace_item(replaced_item_name, replacing_item_name)

You can also use items, but that part is handled automatically by GOAT
and there is usually no reason to use it directly:

::

   goat_inventory.use_item(item_name, used_on_name=null)

``item_name`` is an inventory item that you want to use on something
else. ``used_on_name`` can represent another inventory item, an
interactive item or screen (property ``unique_name``) or it can be null,
meaning that you use the item on itself or on the player (e.g. use a
pizza slice = eat it, use a lamp = turn it on).

GOAT also allows you to select one of the inventory items. That item
will be shown in the 3D inventory. If the inventory is empty, then no
item is selected.

This feature is usually managed by GOAT, but sometimes you might want to
select a specific item to bring more attention to it. You can do it like
this:

::

   goat_inventory.select_item(item_name)

``item_name`` can be null, which means that you deselect the current
item.

Each action mentioned above emits a signal:

::

   goat_inventory.item_added (item_name)
   goat_inventory.item_removed (item_name)
   goat_inventory.item_replaced (replaced_item_name, replacing_item_name)
   goat_inventory.item_used (item_name, used_on_name)
   goat_inventory.item_selected (item_name)

Moreover, every time the content of the inventory changes, this signal
will be emitted:

::

   goat_inventory.items_changed (new_items)

``new_items`` is the current content of the inventory (as ``Array``), in
order the items were added to it.

You can also access the list of items or the selected item at any time:

::

   goat_inventory.get_items()
   goat_inventory.get_selected_item()

If you want to clean the content of the inventory (but keep the
inventory item configuration created by ``register_item`` method) you
can do it like this:

::

   goat_inventory.reset()

.. |Inventory with the "Use" button| image:: https://user-images.githubusercontent.com/36821133/73211081-d3ccfa00-414b-11ea-82cf-366c2728a07a.png

