# godot_various
A collection of my Godot scripts, shaders, and sundry

## BitflagSM - [link](https://github.com/belzecue/godot_various/blob/main/BitflagSM.gd)

Easily define enums based on bit-level operations.  Pack a lot of meaning into a byte.

## Bitmap3D - [link](https://github.com/belzecue/godot_various/blob/main/BitMap3D.gd)

Creates a 3D boolean array in a 2D BitMap object.  Useful for doing logical operations on a 3D volume where you want to know "is the answer YES or NO for this 3D coordinate?"

## RegisterGlobal - [link](https://github.com/belzecue/godot_various/tree/main/RegisterGlobal)

Autoload singleton and custom node that registers its parent in the global reference dictionary, so that anything anywhere can grab a reference to a registered object.  Expired/deleted references get cleaned from the dictionary safely.

## Sexy Stupid State Machine - [link](https://github.com/belzecue/godot_various/blob/main/SSSM.gd)

As seen on [Reddit](https://www.reddit.com/r/godot/comments/rfzwom/sexystupid_state_machine_in_8_lines/).  Originally an 8-line solution for a quick and dirty finite state machine pattern built on the magic of setget. Now expanded into its own base class to be more useful and modular.
