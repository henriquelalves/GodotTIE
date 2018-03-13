# GodotTIE
A simple Text Interface Engine to control text output (like in a RPG dialogue) for Godot.

The "Cave-Story" font was created by enigmansmp1824; it's CC-BY-SA licensed, and can be found in https://fontlibrary.org/pt/font/cave-story.

A simple demonstration video: https://www.youtube.com/watch?v=fkd-nIIPxVw

## Compatibility
This is the Godot v3.x version of the plugin; for Godot v2.x compatibility, check the `Godot_v2.x` branch. 

## Features:

* Control the velocity in which the text is going to be displayed! (Even text dialogues can have emotions!)
* Adjust visually the Interface size, so it can fit it in any Dialogue box you want! The script will handle the maximum number of lines and characters!
* Buffer texts, inputs, and breaks in the Dialogue, with easy to use methods!
* Control the Dialogue flow from the outside with the available user signals!
* Use tags on specific parts of your text! (In a RPG, you may want to show specific animations during certain parts of the dialogue; e.g. a "!" question mark popup in the head of a character in one of the moments of the dialogue)
* User scroll friendly; Log all the text printed; auto-clip words; and more!

Take a look at the 'public' methods in the script and the export variables available; it should give you a hint about the stuff you can easily customize in the engine!

## Installation:
You'll need the Godot Engine to do this.

To use GodotTIE as an Addon:

1. Copy the "addons" folder to your project.
2. Enable GodotTIE addon on "Project Settings".
3. Instance a TextInterfaceEngine node to your scene.

Done!

## Updates:
* 13/03/18:
	* Merged dalton5000 pull-request: Added Godot 3.x compatibility!
	* Added new branch for Godot 2.x version of the addon.
* 10/10/17:
	* Corrected Issue of last lines not appearing on very large texts.
* 10/05/17:
	* Merged radicaled pull-request: Added "buff_clear" as a new buff to reset the text.
* 30/04/17:
	* Merged radicaled pull-request: Changed add_user_signal to signal keyword.
* 08/12/16:
	* Font-overriding bug (max_lines) corrected by David Paiva!
	* Since Addons on Godot are gold since v.2.0, I deleted the old GodotTIE folder to make the addon easier to understand and install - also updated the project Icon and scene file.
* 26/11/16:
	* Corrected bug with "set_buff_speed". Thanks David Paiva!
* 26/02/16:
	* Changed the "buffs" to dictionaries, to increase readability.
	* Fixed bug with "tag" signals (should only call it once).
* 25/02/16:
	* Setup of the finished project on GitHub.

## License:

MIT License.
