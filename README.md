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

## Contact

**rolle** @ QuakeNet
**rolle** or **rolle_** @ IRCnet (depending on which one is available)

Feel free to chat if you use and like the script!

`/whois rolle` or `/whois rolle_` should look something like this:

#### QuakeNet

    17:34:15          * | rolle (~rolle@dsl-jklbrasgw1-54fbb7-147.dhcp.inet.fi)
    17:34:15          * | ircname: Roni Laukkarinen
    17:34:15          * | Channels: @#kammio #dfig.takut @#pulina 
    17:34:15          * | Server: servercentral.il.us.quakenet.org Server Central Network
    17:34:15          * | Info: RolleQ
    17:34:15          * | Idle: since 0 days 0 hours 4 mins 36 secs Signed on: Thu Nov 26 21:47:01 2015
    17:34:15          * | End of WHOIS

#### IRCnet

    17:35:14          * | rolle_ (~rolle@dsl-jklbrasgw1-54fbb7-147.dhcp.inet.fi)
    17:35:14          * | ircname: Roni Laukkarinen
    17:35:14          * | Channels: #twt 
    17:35:14          * | Server: irc2.inet.fi Sonera/iNET IRC server
    17:35:14          * | Idle: since 2 days 13 hours 55 mins 4 secs Signed on: Fri Nov 27 02:38:12 2015
    17:35:14          * | End of WHOIS
