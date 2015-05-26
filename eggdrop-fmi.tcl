# eggdrop-fmi.tcl - FMI-sääscript for eggdrop IRC bot 
# by Roni "rolle" Laukkarinen
# rolle @ irc.quakenet.org
# Fetches finnish weather from ilmatieteenlaitos.fi

# Updated when:
set versijonummero "3.3.20150526"
#------------------------------------------------------------------------------------
# Elä herran tähen mäne koskemaan tai taivas putoaa niskaas!
# Minun reviiri alkaa tästä.

package require Tcl 8.5
package require http 2.1
package require tdom

bind pub - !fmi pub:fmi
bind pub - !saa pub:fmi
bind pub - !keli pub:fmi
bind pub - !sää pub:fmi

set fmiurl "http://ilmatieteenlaitos.fi/saa/Helsinki" 

proc pub:fmi { nick uhost hand chan text } { 

#putserv "PRIVMSG $chan :$text?"

    if {[string trim $text] ne ""} {
	set text [string toupper $text 0 0]
	set fmiurl "http://ilmatieteenlaitos.fi/saa/$text"
    } else {
	global fmiurl
    }

set fmisivu [::http::data [::http::geturl $fmiurl]]
set fmidata [dom parse -html $fmisivu] 
set fmi [$fmidata documentElement] 

# Haetaan eri osasia:
# Note to self: Kopioi uusi XPath jos sorsa muuttuu!

#------------------------------------------------------------------------------------
# Kaupunni:
#------------------------------------------------------------------------------------

# Tämä kohta on helpoin ottaa "Edellisen 2 vuorokauden havainnot" alla olevasta kuvasta (22.1.2015).
set kaupunkihaku [$fmi selectNodes {//*[@id="_localweatherportlet_WAR_fmiwwwweatherportlets_parameter_image"]}]
set kaupunkiHtml [$kaupunkihaku asHTML]
regexp {alt="(.*?)"} $kaupunkiHtml kaupunkiMatch kyla1
# Alt-tagihan on siis "Lämpötila, Helsinki Rautatientori", joten hankkiudutaan eroon "Lämpötila" -tekstistä splittaamalla se
set kaupunki [lindex [split $kyla1 ", "] 2]

#------------------------------------------------------------------------------------
# Lämpötila:
#------------------------------------------------------------------------------------

# "Paikalliset säähavainnot" -kohdan "Tuorein säähavainto:" alla oleva "Lämpötila" -sarake
set lampotilahaku [$fmi selectNodes {//*[@id="p_p_id_localweatherportlet_WAR_fmiwwwweatherportlets_"]/div/div/div/div[2]/div/div[2]/div[1]/div/div[1]/table/tbody/tr[1]/td[1]/span/span[2]}]
set lampotila [[[lindex $lampotilahaku 0] childNodes] nodeValue] 

#------------------------------------------------------------------------------------
# Mittausaika:
#------------------------------------------------------------------------------------

# "Tuorein säähavainto:" vieressä oikealla oleva päivämäärä (26.5.2015)
# Tämä näytti tältä 13.1.2014: <span class="time-stamp">13.1.2014 22:40&nbsp;Suomen aikaa</span>
set mittausaikahaku [$fmi selectNodes {//*[@id="p_p_id_localweatherportlet_WAR_fmiwwwweatherportlets_"]/div/div/div/div[2]/div/div[2]/div[1]/div/div[1]/table/caption/span[2]}]
set aika [$mittausaikahaku asText] 

# En saanut väliä pois joten olkoot "Suomen aikaa" tekstissä, ihan sama...
# Tämä hajosi 23.6.2014:
# set aikasplitted [lindex [split $aika "  Suomen aikaa "] 1]

#------------------------------------------------------------------------------------
# Mañana:
#------------------------------------------------------------------------------------

# Tämä on "Lähipäivien ennuste" kohdan sarakkeesta kellonajan 14 tai 15 kohdalla oleva lämpötilasolu
set huomennahaku [$fmi selectNodes {//*[@id="p_p_id_localweatherportlet_WAR_fmiwwwweatherportlets_"]/div/div/div/div[2]/div/div[1]/div/div[2]/table/tbody/tr[2]/td[8]/div}]
set huomenna [$huomennahaku asText]

#------------------------------------------------------------------------------------
# Auringon nousu ja -lasku ja päivän pituus:
#------------------------------------------------------------------------------------

# Tälle on oma palkkinsa, jossa vasemmalla oranssi aurinko-kuvake (26.5.2015)
set paivahaku [$fmi selectNodes {//*[@id="p_p_id_localweatherportlet_WAR_fmiwwwweatherportlets_"]/div/div/div/div[2]/div/div[1]/div/div[6]/div[2]}]
set paiva [$paivahaku asText]

#------------------------------------------------------------------------------------
# Tulostetaan palikat alle
# Malli: Tie 4 Jyväskylä, Puuppola -8.4°C (09:55, Heikko sade)
#
# Simsalabim:

putserv "PRIVMSG $chan :\002$kaupunki\002 $lampotila (mitattu $aika).$paiva\Huomispäiväksi luvattu \002$huomenna\002."
putlog "PRIVMSG $chan :\002$kaupunki\002 $lampotila (mitattu $aika).$paiva\Huomispäiväksi luvattu \002$huomenna\002."

#putserv "PRIVMSG $chan :\002$kaupunki\002 $lampotila ($kuvaus, mitattu $aika).$paiva\Huomiseksi luvattu \002$huomenna\002." 

# Output:
# 09:55:28 <rolle> !sää jyväskylä
# 09:55:29 <kummitus> Jyväskylä -13,4 °C (pilvistä, valoisaa, mitattu 13.1.2014 9:40 Suomen aikaa). Auringonnousu tänään 9:28.
# 		      Auringonlasku tänään 15:25. Päivän pituus on 5 h 57 min. Huomiseksi luvattu -14°.

}

# Kukkuluuruu.
putlog "Rolle's weatherscript (version $versijonummero) LOADED!"