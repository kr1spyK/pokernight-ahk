# fastplay/AFK script for Poker Night at the Inventory
Written for AutoHotKey v2+.
I made this to grind the Straight Flush achievement, but naturally all hands would appear with some modification.

Speed up gameplay; AFK feature intended for 800x600 windowed resolution.

When script started, continously skips dialogue so it should force the game to run in background.
Due to limitations of the game and AHK, this script cannot run completely in background. Only skip dialogue will always run.

Added keyboard controls for gameplay:
My current settings are
| key     | action         | additional |
|---------|----------------|------------|
| W/UP    | increase bet   |            |
| S/Down  | decrease bet   |            |
| A/Left  | call           | menu left  |
| D/Right | raise/bet      | menu right |
| F/RCtrl | fold           |            |
| "\\"     | pause autoplay |            |
| F4      | exit script    |            |

Planned features: image/text recognition for straight flush optimization (fold low probability hands)
