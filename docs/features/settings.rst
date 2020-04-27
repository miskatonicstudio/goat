Settings
========

GOAT provides a default settings screen, available when the player
presses Esc while in ``EXPLORING`` mode. Currently, only the most
important settings are supported. The settings file (INI-style) is saved
in ``user://settings.cfg``. When the program runs for the first time,
the file is created with the default values.

|Settings screen|

======== =================== =============
Section  Key                 Default value
======== =================== =============
graphics fullscreen_enabled  true
graphics glow_enabled        true
graphics reflections_enabled true
graphics shadows_enabled     true
graphics ao_enabled          true
sound    music_volume        1.0
sound    effects_volume      1.0
controls mouse_sensitivity   0.3
gui      subtitles           true
gui      scope               true
gui      language            first matched
======== =================== =============

**Note: the volume is a value between 0 (complete silence) and 1
(default bus volume), which is recalculated to a non-linear value between
-80 and 0 dB (using a linear value causes the sound to almost vanish long
before the volume slider reaches minimum). Mouse sensitivity is used
for player's camera rotation and inventory item rotation.**

The default value of the ``language`` setting is determined based on provided
translations and currently selected locale. Please check the
``goat_settings.find_matching_loaded_locale`` method for more details about the
process. The matching happens only once, when the game runs for the first time
and the ``language`` is not yet set. After that, the value is saved with the
rest of the settings and can be changed manually to any language with provided
translations.

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

