# GodotTIE
A simple Text Interface Engine to control text output (like in a RPG dialogue) for Godot.

The "Cave-Story" font was created by enigmansmp1824; it's CC-BY-SA licensed, and can be found in https://fontlibrary.org/pt/font/cave-story.

A simple demonstration video: https://www.youtube.com/watch?v=fkd-nIIPxVw

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

1. Clone or download this repository;
2. Copy the folder "Text Interface Engine" to your Godot project;
3. Instance "text_interface_engine.scn" as a node in the scene that you want the Text Interface.

The "addon" is a experimental feature (as it is only available in Godot HEAD version on GitHub for now).
To use GodotTIE as an Addon:

1. Copy the "addons" folder to your project.
2. Enable GodotTIE addon on "Project Settings".
3. Instance a TextInterfaceEngine node to your scene.

Done!

## Updates:

* 26/02:
	* Changed the "buffs" to dictionaries, to increase readability.
	* Fixed bug with "tag" signals (should only call it once).
* 25/02:
	* Setup of the finished project on GitHub.

## License:

MIT License.
