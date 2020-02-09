Settings
========

GOAT provides a default settings screen, available when the player
presses Esc while in ``EXPLORING`` mode. Currently, only the most
important settings are supported. The settings file (INI-style) is saved
in ``user://settings.cfg``. When the program runs for the first time,
the file is created with the default values.

|Settings screen|

======== ================= =============
Section  Key               Default value
======== ================= =============
graphics fullscreen        true
graphics glow              true
graphics reflections       true
graphics shadows           true
sound    music_volume      0.0
sound    effects_volume    0.0
controls mouse_sensitivity 0.3
======== ================= =============

**Note: the volume is stored in decibels, so 0.0 doesn't mean that the
sound is muted (it becomes muted at -60 dB). Mouse sensitivity is used
for player's camera rotation and inventory item rotation.**

In order to react to changes in settings, you can connect to a signal:

::

   goat_settings.value_changed (section, key)

Methods for reading and modifying the values are also available:

::

   goat_settings.get_value(section, key)
   goat_settings.set_value(section, key, value)

By default, any change will emit a signal and save the settings file.
You can prevent the file saving:

::

   goat_settings.autosave = false

.. |Settings screen| image:: https://user-images.githubusercontent.com/36821133/73210231-1db4e080-414a-11ea-8548-2517c6c204dd.png

