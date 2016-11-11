# Starbound Stored Outfits
A multiplayer friendly mod that adds custom items which can be used to store and quickly equip outfits.

The idea is that using an item to store the outfit is more convenient than having to open an interface and manually selecting the outfit from a list, since you have direct control over what items you're holding and where the items are.

Uses https://github.com/Silverfeelin/Starbound-ItemInterfaces for access to the `player` table by using an invisible `ScriptPane` interface.

## Table of Contents
- [Wiki](#wiki)
- [Features](#features)
- [Credits and Contribution](#credits-and-contribution)
- [Licenses](#licenses)

## Wiki
Installation, usage and further information can be found on the [Wiki](https://github.com/Silverfeelin/Starbound-StoredOutfits/wiki).

#### Quick Reference
* [Installation](https://github.com/Silverfeelin/Starbound-StoredOutfits/wiki/Installation)
* [Usage](https://github.com/Silverfeelin/Starbound-StoredOutfits/wiki/Usage)

## Features

* Storage of entire cosmetic outfits in an item.
* Swapping outfits with one click while holding the item.
 * The used item will be consumed, to prevent duplication.
 * The currently equipped outfit will be stored in a new outfit item.
* RC4 encryption on item data, to prevent outfit theft.
 * Using an outfit with an invalid encryption key will destroy (consume) the item.

## Credits and Contribution

Special thanks to ICDeadPixels for the idea of easily switching outfits.

People that have contributed directly to the project can be found on the [Contributors](https://github.com/Silverfeelin/Starbound-StoredOutfits/graphs/contributors) page.  
People that have made suggestions or reported issues can be found on the [Issues](https://github.com/Silverfeelin/Starbound-StoredOutfits/issues?utf8=%E2%9C%93&q=) page.

#### Want to contribute?

* Report bugs and issues, or send me suggestions by creating a [new Issue](https://github.com/Silverfeelin/Starbound-StoredOutfits/issues/new).
* If you want to modify or add code yourself, fork the repository and create pull requests.
 * Note that creating a pull request doesn't automatically mean your code will be added to the mod.
 * Keep in mind the [license of this repository](https://github.com/Silverfeelin/Starbound-StoredOutfits/blob/master/LICENSE) before redistributing, if you wish to do so.

## Licenses

 This repository includes a couple of scripts that fall under their own license. The licenses can be found in the headers of these scripts.

 Slight modifications to these scripts have been made to use them in Starbound. These changes are addressed in the headers of the scripts.

 * `/scripts/arc4.lua`
  * Source: https://www.rjek.com/arcfour.lua.txt
 * `/scripts/base64.lua`
  * Source: http://lua-users.org/wiki/BaseSixtyFour
