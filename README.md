# Sternly Worded Peninsula; Archipelago Support for Sternly Worded Adventures

This is a mod for Sternly Worded Adventures that provides support for the Archipelago Multiworld Randomiser.
The mod has been developed and tested on Sternly Worded Adventures V52, and may not work on past or future versions.

## Gameplay Changes
With this mod active, item rewards from locations such as crypt chests, forest chests, chapel ruins, and other loot sources are replaced with Archipelago checks.
The number of checks distributed to each location type is determined by the player's .yaml file configurations.

Travelling between locations is now gated to create progression; at the start of the game, the player can only travel to level 1-3 locations, with locations of a higher level being inaccessible until the appropriate "Node Access" check is received.
If the player runs out of new locations to travel to in order to collect new checks, they can either wait to receive their next tier of Node Access, or they can start a new run to collect more checks in the locations currently accessible to them.
Keep in mind that the item pool contains far more checks of each location type than can be acquired in a single run. Doing multiple runs is an expected part of progression!

Additionally, this mod introduces a new class to the game; the Wayfarer. Playing as this class is the intended experience for this mod, though you may play as other classes if you wish.
The Wayfarer has very few items in its item/loot pool, and none are from the vanilla game. Instead, they start with a passive "Nexus Satchel", and each Nexus Charge received, be it from SWA itself or another game in the multiworld, allows the player to withdraw a random item or consumable from the Nexus Satchel, similarly to how the Endless Potion Bag grants random potions.

To complete your Archipelago slot and release any remaining checks, defeat the Anomaly once.

Good luck!

## Installation
To install the mod, create a `mods` folder inside of SWA's save directory (typically `AppData/Roaming/SternlyWordedAdventures`), and drop the `Archipelago` folder from this repository into said `mods` folder.
After that, launch the game, open the Almanac from the title screen, click Mods, activate the mod, then save.
The game should restart with the mod active. You can verify by going to Sandbox mode, and seeing if the Wayfarer class has been added.

## Connecting
The mod contains a config file called `apconfig.lua`, found in `Archipelago/mount/ap`. Within it are the three basic values needed to connect to an Archipelago Multiworld; the slot name, password, and server. Edit them to the appropriate values.
Launch the game and, if necessary, start a run. The client should then connect and be ready to send and receive Archipelago checks.
If the game was already open when editing the `apconfig.lua` file, close and restart it for the changes to register.

## Miscellaneous Notes
**NOTE:** When connecting to a new AP room after finishing a run, the game still retains the persistent save data from previous runs. Therefore, before starting a new run, one must wipe the archipelago-related data from their `persistentSaveData` file, found in `AppData/Roaming/SternlyWordedAdventures`. If one wishes to participate in multiple Multiworlds and play SWA in them, back the data up and reinsert it as necessary instead.