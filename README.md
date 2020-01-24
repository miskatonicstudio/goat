# GOAT

Godot Open Adventure Template (GOAT) is a tool for making 3D adventure
games. It supports a simple inventory system, interacting with objects,
playing voice recordings with subtitles, and changing game settings.

TODO: gif of GOAT

This README contains basic information about GOAT. Full documentation will be
available soon.

## Getting started

* install [Godot Engine](https://github.com/godotengine/godot)
[3.2 beta5](https://downloads.tuxfamily.org/godotengine/3.2/beta5/) on your machine
* clone this repository and import it as a Godot project
* play the project (F5) to start a demo game: **"2 minute adventure"**
* once you are familiar with how the template works, remove demo game files
and create your own adventure!

## Main concepts

GOAT is intended to help you make your own adventure games, but there are some
assumptions that you need to keep in mind while working with it. This section
provides a general overview of the template. More details can be found in other
sections of this document.

GOAT supports only 3D single player games. The player can explore the 3D environment
and interact with some objects in it. A special type of interaction allows the player
to pick up an object and add it to the inventory. The inventory contains 3D items
that can be rotated and interacted with. There is a general distinction between
the environment (where the player can move) and the inventory (where picked up
items are stored). However, both support practically the same types of
interaction, e.g. you can press a button on a wall (environment) or on a remote
control (inventory).

TODO: picture of remote button

The template uses some global variables (AutoLoad). One of them is the state
of the game. Currently, 4 states are implemented:

* `EXPLORING` the player is moving and interacting with the 3D environment
* `INVENTORY` the player is browsing 3D items in the inventory
* `CONTEXT_INVENTORY` the player is trying to use an inventory item on the
environment (e.g. open a door with a key)
* `SETTINGS` the settings screen is shown during the game

**Note: the game doesn't pause in any of these modes.**

GOAT is a Godot project. The assumption is that when you want to create your
own game, you will clone this repository and replace the demo game files with
your own. In order to create an interactive environment, you can use 3 main
scenes provided by GOAT (all described in detail in other sections):

* `Player`
* `InteractiveObject`
* `InteractiveScreen`

You also need to provide configuration for:

* inventory items
* voice recordings

And, of course, you need to connect everything. GOAT provides many signals,
that let you react to different situations in the game. For example, you can
decide to play a voice recording after a button on a wall is pressed or remove
an inventory item after the player uses it.

GOAT provides also default styles and layouts for the inventory, context
inventory, subtitles, and settings. Usually there is no reason to change
anything in the template files, unless you want to modify the style or add new
features (which you are encouraged to do, this is open source after all!).

## Directory structure

There are 2 directories in this repository:
* `goat`: contains all scenes and resources of the template; normally there is
no need to change anything here, unless you want to implement features that the
template doesn't support yet
* `demo`: contains actual game resources, such as sounds, voice recordings,
3D models, materials etc.

The structure of the `demo` folder looks like this:

```
demo
├── fonts             # All fonts used in the game
├── globals           # All global scripts, configured as Singletons (AutoLoad)
├── images            # All images, e.g. a custom cursor
├── inventory_items   # REQUIRED; configuration for inventory items
│   ├── icons         # Icons representing inventory items (one per item)
│   └── models        # 3D models representing inventory items (one per item)
├── materials         # Materials for 3D models
├── models            # 3D models (usually reused in more than one scene)
├── pickable_items    # 3D scenes representing environment objects that can be picked up
├── scenes            # Most of the scenes used in the game
│   ├── main          # Scenes responsible for main game screens (main menu, credits, settings, gameplay)
│   └── other         # All remaining scenes
├── sounds            # All sounds used in the game, except for voice recordings
└── voice             # REQUIRED; all voice recordings
```

When you start working on your project, you should replace the `demo` folder
with the resources of your own game. You can modify the structure in
the listing above, but you need to keep the folders marked as `REQUIRED`.

To use a custom game resources directory, you need to configure it first,
probably in one of your game's global files:

```
goat.GAME_RESOURCES_DIRECTORY = "demo"
```

As mentioned before, GOAT provides a default settings screen. The "Exit" button
on that screen exit the program by default. If you want it to redirect to e.g.
the main menu of your game, you can change it like this:

```
goat.EXIT_SCENE = "res://demo/scenes/main/MainMenu.tscn"
```













## Credits and licenses

### Game engine

This project uses [Godot Engine](https://github.com/godotengine/godot)
version [3.2 beta5](https://downloads.tuxfamily.org/godotengine/3.2/beta5/),
distributed under [MIT license](https://godotengine.org/license).

### Models

Pizza slice and plate models were created by [Quaternius](quaternius.com)
and are available in the [Ultimate Food Pack](https://drive.google.com/drive/folders/1zMfN7q9VU80M7mLAbBBJyY2OdoXslbl1?usp=sharing)
distributed under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

Floppy disk, remote, portal, and door models were created by Paweł Fertyk
and are distributed under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

The remaining models were created by [Dalton5000](https://twitter.com/dalton8000)
and can be found in [this repository](https://github.com/Byteron/robo-platformer)
distributed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/).

### Images

Item interaction icon was created using
[this image](https://publicdomainvectors.org/en/free-clipart/Silhouette-of-hand-palm/36250.html),
distributed under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

Screen interaction icon was created using
[this image](https://publicdomainvectors.org/en/free-clipart/Zoom-in-sign/44722.html),
distributed under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

### Voice

All voice samples were recorded by
[VoiceOverAngela](https://www.fiverr.com/voiceoverangela) and are now in public domain.

### Sounds

All sounds used in the project are in public domain and can be downloaded from
[Freesound](https://freesound.org):

* [generator.ogg](https://freesound.org/people/DiscoveryME/sounds/367175/)
* [button.ogg](https://freesound.org/people/LamaMakesMusic/sounds/403556/)
* [pick_up.ogg](https://freesound.org/people/SilverIllusionist/sounds/411177/)
* [tray.ogg](https://freesound.org/people/Handfan/sounds/71230/)
* [battery_on_remote.ogg](https://freesound.org/people/_lourii/sounds/491905/)
* [the_other_side.ogg](https://freesound.org/people/ricniclas/sounds/451949/)
* [shutter.ogg](https://freesound.org/people/aldenroth2/sounds/272017/)
