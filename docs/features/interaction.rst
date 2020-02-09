Interaction
===========

Interaction with objects is handled in the following way:

-  when an object is in range, it is selected
-  when an object is no longer in range, it is deselected
-  when an object is selected and LMB is pressed, the object is
   activated
-  when an object is selected and RMB is pressed, the object is
   activated alternatively

Every change of state emits a signal:

::

   goat_interaction.object_selected (object_name, point)
   goat_interaction.object_deselected (object_name)
   goat_interaction.object_activated (object_name, point)
   goat_interaction.object_activated_alternatively (object_name, point)

``object_name`` represents the unique name associated with an
interactive object that is currently being selected/deselected/activated
(either an item or a screen). Additionally, ``point`` stores a global 3D
location where an interaction took place (that usually doesn't matter
for items, but is quite important for screens).

To make things easier, currently selected objects and their
corresponding points are stored globally and can be accessed like this:

::

   goat_interaction.get_selected_object(category)
   goat_interaction.get_selected_point(category)

``category`` represents the type of interaction object. Currently, only
two values are used: ``environment`` and ``inventory``. Each category
can store only one item and one point at the same time. That means that
if a new object is selected, the previous one will be deselected first.

``goat_inventory`` contains methods for selecting/deselecting/activating
interactive objects, but they are used internally by GOAT and usually
don't need to be used directly by game developers.
