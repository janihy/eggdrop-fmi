# eggdrop-fmi.tcl - FMI-sääscript for eggdrop IRC bot
# by Roni "rolle" Laukkarinen
# rolle @ irc.quakenet.org
# Fetches finnish weather from ilmatieteenlaitos.fi
# API querys: http://ilmatieteenlaitos.fi/tallennetut-kyselyt

# Updated when: 2/2019
set versio "4.8"
#------------------------------------------------------------------------------------
package require Tcl 8.6
package require http 2.8
package require tls

package require tdom

bind pub - !fmi pub:fmi
bind pub - !saa pub:fmi
bind pub - !keli pub:fmi
bind pub - !sää pub:fmi

set systemTime [clock seconds]
set starttime [expr { $systemTime - 9600 }]
set timestamp [clock format $starttime -format %Y-%m-%dT%H:%M:%S]
set fmiurl "https://data.fmi.fi/fmi-apikey/0218711b-a299-44b2-a0b0-a4efc34b6160/wfs?request=getFeature&storedquery_id=fmi::observations::weather::timevaluepair&place=elimäki&timezone=Europe/Helsinki&starttime=$starttime"
set fmiurlhtml "https://ilmatieteenlaitos.fi/saa/Elimäki"

proc pub:fmi { nick uhost hand chan text } {
  http::register https 443 ::tls::socket
  http::config -urlencoding utf-8
  set systemTime [clock seconds]
  set starttime [expr { $systemTime - 9600 }]
  set timestamp [clock format $starttime -format %Y-%m-%dT%H:%M:%S]

  if {[string trim $text] ne ""} {

       set text [string toupper $text 0 0]
       set fmiurl "https://data.fmi.fi/fmi-apikey/0218711b-a299-44b2-a0b0-a4efc34b6160/wfs?request=getFeature&storedquery_id=fmi::observations::weather::timevaluepair&place=$text&timezone=Europe/Helsinki&starttime=$starttime"
       set fmiurlhtml "https://ilmatieteenlaitos.fi/saa/$text"

    } else {
       global fmiurl
       global fmiurlhtml
    }

  set fmisivu [::http::data [::http::geturl $fmiurl]]
  set fmidata [dom parse $fmisivu]
  set fmi [$fmidata documentElement]

  set fmisivuhtml [::http::data [::http::geturl $fmiurlhtml]]
  set fmihtmlsrc [dom parse -html $fmisivuhtml]
  set fmihtml [$fmihtmlsrc documentElement]

  #------------------------------------------------------------------------------------
  # Kaupunki:
  #------------------------------------------------------------------------------------

  #putlog [$fmi asText]
  set kaupunkihaku [$fmi selectNodes {(//target:Location[1]/gml:name[@codeSpace="http://xml.fmi.fi/namespace/locationcode/name"])[1]}]
  set kaupunki [$kaupunkihaku asText]


  #------------------------------------------------------------------------------------
  # Lämpötila:
  #------------------------------------------------------------------------------------

  set lampotilahaku [$fmi selectNodes {(//om:result[1]/wml2:MeasurementTimeseries/wml2:point[last()]/wml2:MeasurementTVP/wml2:value)[1]}]
  set lampotila [$lampotilahaku asText]

  #------------------------------------------------------------------------------------
  # Mittausaika:
  #------------------------------------------------------------------------------------

  set mittausaikahaku [$fmi selectNodes {(//om:result[1]/wml2:MeasurementTimeseries/wml2:point[last()]/wml2:MeasurementTVP/wml2:time)[2]}]
  set aika [$mittausaikahaku asText]
  set aikahieno [lindex [split $aika "T"] 1]
  set aikahienoformatted [lindex [split $aikahieno "+"] 0]
  set tunnit [lindex [split $aikahienoformatted ":"] 0]
  set minuutit [lindex [split $aikahienoformatted ":"] 1]

  #------------------------------------------------------------------------------------
  # Säätila:
  #------------------------------------------------------------------------------------

  # Lähituntien ennuste -välilehti ja ensimmäisen sarakkeen kuvake
  set saatilahaku [$fmihtml selectNodes {//*[@class='first-mobile-forecast-time-step-content']//*[@class='weather-symbol-container']/div}]
  #putlog [$saatilahaku asHTML]
  set saatilaHtml [$saatilahaku asHTML]
  regexp {title="(.*?)"} $saatilaHtml saatilaMatch saatila1
  set saatila [lindex [split $saatila1 "."] 0]

  set rhhaku [$fmi selectNodes {(//wml2:MeasurementTimeseries[@gml:id='obs-obs-1-1-rh']/wml2:point[last()]/wml2:MeasurementTVP/wml2:value)[1]}]
  set rh [$rhhaku asText]
  if {$rh ne "NaN"} {
    set rh [format "%.f" [$rhhaku asText]]
  }


  #------------------------------------------------------------------------------------
  # Sade:
  #------------------------------------------------------------------------------------

  # Edeltävän tunnin sateen määrä:
  set sademaarahaku [$fmi selectNodes {(//om:result[1]/wml2:MeasurementTimeseries/wml2:point[last()]/wml2:MeasurementTVP/wml2:value)[8]}]
  set sademaara [$sademaarahaku asText]

  #------------------------------------------------------------------------------------
  # Mañana:
  #------------------------------------------------------------------------------------

  # Tämä on "Lähipäivien ennuste" kohdan sarakkeesta kellonajan 14 tai 15 kohdalla oleva lämpötilasolu
  set huomennahaku [$fmihtml selectNodes {(//div[contains(@class, 'mid')]/table/tbody/tr[@class='meteogram-temperatures']/td/div[contains(@class, 'temperature')])}]
  #putlog [[lindex $huomennahaku 7] asText]
  set huomenna [[lindex $huomennahaku 7] asText]


  # Klo 15 seuraavan päivän sarakkeen kuvake
  set saatilahakuhuomenna [$fmihtml selectNodes {(//div[contains(@class, 'mid')]/table/tbody/tr[@class='meteogram-weather-symbols']/td/div)}]
  set saatilahuomennaHtml [[lindex $saatilahakuhuomenna 7] asHTML]
  regexp {title="(.*?)"} $saatilahuomennaHtml saatilahuomennaMatch saatilahuomenna1
  set saatilahuomenna [lindex [split $saatilahuomenna1 "."] 0]

  #------------------------------------------------------------------------------------
  # Auringon nousu ja -lasku ja päivän pituus:
  #------------------------------------------------------------------------------------

  # Tälle on oma palkkinsa, jossa vasemmalla oranssi aurinko-kuvake (19.11.2015)
  set paivahaku [$fmihtml selectNodes {//*[@class='celestial-status-text']}]
  set paiva [[lindex $paivahaku 1] asText]

  #------------------------------------------------------------------------------------
  # Tulostetaan palikat alle
  # Malli: Tie 4 Jyväskylä, Puuppola -8.4°C (09:55, Heikko sade)
  #
  # Simsalabim:

  putserv "PRIVMSG $chan :\002$kaupunki\002 $lampotila\°C ($tunnit:$minuutit), $saatila. Ilmankosteus $rh %, sademäärä (<1h): $sademaara mm. \Huomispäiväksi luvattu \002$huomenna\002C, $saatilahuomenna. $paiva"

  # Output:
  # 09:55:28 <rolle> !sää jyväskylä
  # 09:55:29 <kummitus> Jyväskylä -13,4 °C (pilvistä, valoisaa, mitattu 13.1.2014 9:40 Suomen aikaa). Auringonnousu tänään 9:28.
  #           Auringonlasku tänään 15:25. Päivän pituus on 5 h 57 min. Huomiseksi luvattu -14°.

}

# Kukkuluuruu.
putlog "Rolle's weatherscript (version $versio) LOADED!"
