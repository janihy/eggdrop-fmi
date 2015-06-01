# eggdrop-fmi.tcl

There is really no good Finnish weather eggdrop script so I decided to create one. My TCL is not great, but this just works and is easy to maintain, so I'm sticking with it.

Feel free to use, but if you like it, considering joining [Pulina-channel](http://www.pulina.fi) if you are a Finn. (actually I have no idea why would any non-Finn use this script). 

By using this script, you no longer need to look out the window to check the weather, you can just simply type `!sää` in IRC. Nice, huh?

## Usage

1. Clone this repo to your ~/eggdrop/scripts folder and remove README.md
2. Add `script load scripts/eggdrop-fmi.tcl` to your eggdrop.conf
3. Telnet your bot and `.rehash` or `.restart` it or start if not running.
4. Have fun knowing the weather!

## Requirements

* Tcl >= 8.4
* http >= 2.1
* tdom