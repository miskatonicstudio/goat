Context inventory
=================

Sometimes you might want to use an inventory item (e.g. a key) on an
object in the 3D environment (e.g. a door). You can do it by using the
context inventory. First, you need to approach an interactive item or
screen (until you see the interaction icon). Then, you need to click
RMB. A simple layout of all currently available inventory items will be
shown in the middle of the screen:

|Context inventory|

Selecting an item will emit a signal:

::

   goat_inventory.item_used(item_name, used_on_name)

Where ``item_name`` is the name of the selected inventory item and
``used_on_name`` is the ``unique_name`` property of the environment
object.

Currently, there are no signals or methods associated with the context
inventory.

.. |Context inventory| image:: https://user-images.githubusercontent.com/36821133/73209586-d11cd580-4148-11ea-8b5b-92d0762b0526.png
