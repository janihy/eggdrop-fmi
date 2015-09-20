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

    12:53:06 -!- rolle [~rolle@dsl-jklbrasgw1-54fbb9-1.dhcp.inet.fi]
    12:53:06 -!-  ircname  : Go to: rolle.wtf
    12:53:06 -!-  channels : @#dfig.takut @#pulina 
    12:53:06 -!-  server   : port80b.se.quakenet.org [Port80.se IRC Server]
    12:53:06 -!-  account  : RolleQ
    12:53:06 -!-  idle     : 0 days 1 hours 23 mins 2 secs [signon: Thu May 21 10:35:21 2015]
    12:53:06 -!- End of WHOIS

#### IRCnet

    12:51:11 -!- rolle [~rolle@dsl-jklbrasgw1-54fbb9-1.dhcp.inet.fi]
    12:51:11 -!-  ircname  : Go to: rolle.wtf
    12:51:11 -!-  channels : #twt 
    12:51:11 -!-  server   : irc2.inet.fi [Sonera/iNET IRC server]
    12:51:11 -!-  idle     : 0 days 0 hours 1 mins 9 secs [signon: Thu May 21 08:51:28 2015]
    12:51:11 -!- End of WHOIS
