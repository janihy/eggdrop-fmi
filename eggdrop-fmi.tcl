# eggdrop-fmi.tcl - FMI-sääscript for eggdrop IRC bot
# originally by Roni "rolle" Laukkarinen
# modified by tuplis
# Fetches finnish weather from ilmatieteenlaitos.fi
# API querys: http://ilmatieteenlaitos.fi/tallennetut-kyselyt

# Updated when: 3/2020
set versio "4.9"
#------------------------------------------------------------------------------------
package require Tcl 8.6
package require http 2.8
package require tls

package require tdom

bind pub - !saa pub:fmi
bind pub - !keli pub:fmi
bind pub - !sää pub:fmi

set systemTime [clock seconds]
set starttime [expr { $systemTime - 3600 }]
set fmiurl "https://opendata.fmi.fi/wfs?request=getFeature&storedquery_id=fmi::observations::weather::timevaluepair&place=Espoo&timezone=Europe/Helsinki&starttime=$starttime"
set fmiforecasturl "http://opendata.fmi.fi/wfs?service=WFS&version=2.0.0&request=getFeature&storedquery_id=fmi::forecast::hirlam::surface::point::timevaluepair&place=Espoo&timezone=Europe/Helsinki&starttime=$starttime"
set message ""

proc pub:fmi { nick uhost hand chan text } {
  http::register https 443 ::tls::socket
  set systemTime [clock seconds]
  set starttime [expr { $systemTime - 9600 }]

  if {[string trim $text] ne ""} {
       set text [string toupper $text 0 0]
       set fmiurl "https://opendata.fmi.fi/wfs?request=getFeature&storedquery_id=fmi::observations::weather::timevaluepair&place=$text&timezone=Europe/Helsinki&starttime=$starttime"
       set fmiforecasturl "http://opendata.fmi.fi/wfs?service=WFS&version=2.0.0&request=getFeature&storedquery_id=fmi::forecast::hirlam::surface::point::timevaluepair&place=$text&timezone=Europe/Helsinki&starttime=$starttime"

    } else {
       global fmiurl
       global fmiforecasturl
    }

  set fmisivu [::http::data [::http::geturl $fmiurl]]
  set fmidata [dom parse $fmisivu]
  set fmi [$fmidata documentElement]

  set fmiforecastsivu [::http::data [::http::geturl $fmiforecasturl]]
  set fmiforecastdata [dom parse $fmiforecastsivu]
  set fmiforecast [$fmiforecastdata documentElement]


  #------------------------------------------------------------------------------------
  # Kaupunki:
  #------------------------------------------------------------------------------------

  set kaupunkihaku [$fmi selectNodes {(//target:Location[1]/gml:name[@codeSpace="http://xml.fmi.fi/namespace/locationcode/name"])[1]}]
  set kaupunki [$kaupunkihaku asText]


  #------------------------------------------------------------------------------------
  # Lämpötila:
  #------------------------------------------------------------------------------------

  set lampotilahaku [$fmi selectNodes {(//om:result[1]/wml2:MeasurementTimeseries/wml2:point[last()]/wml2:MeasurementTVP/wml2:value)[1]}]
  set lampotila [$lampotilahaku asText]
  if {$lampotila eq "NaN"} {
    set lampotila "-"
  }


  #------------------------------------------------------------------------------------
  # Mittausaika:
  #------------------------------------------------------------------------------------

  set mittausaikahaku [$fmi selectNodes {(//om:result[1]/wml2:MeasurementTimeseries/wml2:point[last()]/wml2:MeasurementTVP/wml2:time)[2]}]
  set aika [$mittausaikahaku asText]
  set aikahieno [lindex [split $aika "T"] 1]
  set aikahienoformatted [lindex [split $aikahieno "+"] 0]
  set tunnit [lindex [split $aikahienoformatted ":"] 0]
  set minuutit [lindex [split $aikahienoformatted ":"] 1]

  append message "\002$kaupunki\002 $lampotila\°C ($tunnit:$minuutit), "


  #------------------------------------------------------------------------------------
  # Säätila:
  #------------------------------------------------------------------------------------

  set saatila [[$fmiforecast selectNodes {(//wml2:MeasurementTimeseries[@gml:id='mts-1-1-WeatherSymbol3']/wml2:point/wml2:MeasurementTVP/wml2:value)[2]}] asText]
  set rex [regexp {[0-9]+} $saatila saatila]
  set saatila [pub:parseWeatherSymbol $saatila]

  append message "$saatila. "


  #------------------------------------------------------------------------------------
  # Ilmankosteus:
  #------------------------------------------------------------------------------------

  set rhhaku [$fmi selectNodes {(//wml2:MeasurementTimeseries[@gml:id='obs-obs-1-1-rh']/wml2:point[last()]/wml2:MeasurementTVP/wml2:value)[1]}]
  set rh [$rhhaku asText]


  #------------------------------------------------------------------------------------
  # Sade:
  #------------------------------------------------------------------------------------

  # Edeltävän tunnin sateen määrä:
  set sademaarahaku [$fmi selectNodes {(//om:result[1]/wml2:MeasurementTimeseries/wml2:point[last()]/wml2:MeasurementTVP/wml2:value)[8]}]
  set sademaara [$sademaarahaku asText]


  if {$rh ne "NaN"} {
    set rh [format "%.f" [$rhhaku asText]]
    append message "Ilmankosteus $rh %"
    if {$sademaara ne "NaN"} {
      append message ", sademäärä (<1h): $sademaara mm. "
    } else {
      append message ". "
    }
  }





  #------------------------------------------------------------------------------------
  # Tuuli:
  #------------------------------------------------------------------------------------

  set ws [[$fmi selectNodes {(//wml2:MeasurementTimeseries[@gml:id='obs-obs-1-1-ws_10min']/wml2:point[last()]/wml2:MeasurementTVP/wml2:value)[1]}] asText]

  if {$ws ne "NaN"} {
    set wddegrees [format "%.0f" [[$fmi selectNodes {(//wml2:MeasurementTimeseries[@gml:id='obs-obs-1-1-wd_10min']/wml2:point[last()]/wml2:MeasurementTVP/wml2:value)[1]}] asText]]
    set wd [pub:parseWindDirection $wddegrees]
    set ws [format "%.1f" $ws]
    append message "Tuulee $ws m/s $wd ($wddegrees°). "
  }


  #------------------------------------------------------------------------------------
  # Huomenna:
  #------------------------------------------------------------------------------------

  set timestamp [clock format [expr { $systemTime + 86400 }] -format "%Y-%m-%dT15:00:00+02:00"]
  set saatilahuomenna [[$fmiforecast selectNodes {(//wml2:MeasurementTimeseries[@gml:id='mts-1-1-WeatherSymbol3']/wml2:point/wml2:MeasurementTVP/wml2:time[.=$timestamp]/following-sibling::wml2:value)}] asText]
  set rex [regexp {[0-9]+} $saatilahuomenna saatilahuomenna]
  set saatilahuomenna [pub:parseWeatherSymbol $saatilahuomenna]
  set huomenna [format "%.1f" [[$fmiforecast selectNodes {(//wml2:MeasurementTimeseries[@gml:id='mts-1-1-Temperature']/wml2:point/wml2:MeasurementTVP/wml2:time[.=$timestamp]/following-sibling::wml2:value)}] asText]]

  append message "Huomispäiväksi luvattu $huomenna\°C, $saatilahuomenna."

  putserv "PRIVMSG $chan :$message"
}

proc pub:parseWeatherSymbol {symbol} {
  set symbol [string map -nocase {
    "21" "heikkoja sadekuuroja"
    "22" "sadekuuroja"
    "23" "voimakkaita sadekuuroja"
    "31" "heikkoa vesisadetta"
    "32" "vesisadetta"
    "33" "voimakasta vesisadetta"
    "41" "heikkoja lumikuuroja"
    "42" "lumikuuroja"
    "43" "voimakkaita lumikuuroja"
    "51" "heikkoa lumisadetta"
    "52" "lumisadetta"
    "53" "voimakasta lumisadetta"
    "61" "ukkoskuuroja"
    "62" "voimakkaita ukkoskuuroja"
    "63" "ukkosta"
    "64" "voimakasta ukkosta"
    "71" "heikkoja räntäkuuroja"
    "72" "räntäkuuroja"
    "73" "voimakkaita räntäkuuroja"
    "81" "heikkoa räntäsadetta"
    "82" "räntäsadetta"
    "83" "voimakasta räntäsadetta"
    "91" "utua"
    "92" "sumua"
    "1" "selkeää"
    "2" "puolipilvistä"
    "3" "pilvistä"
  } $symbol]
  return $symbol
}

proc pub:parseWindDirection {direction} {
  set direction [expr {int(($direction+22.5)/45)%8}]
  set direction [string map -nocase {
    "0" "pohjoisesta"
    "1" "koillisesta"
    "2" "idästä"
    "3" "kaakosta"
    "4" "etelästä"
    "5" "lounaasta"
    "6" "lännestä"
    "7" "luoteesta"
  } $direction]
  return $direction
}


# Kukkuluuruu.
putlog "Rolle's weatherscript (version $versio) LOADED!"
