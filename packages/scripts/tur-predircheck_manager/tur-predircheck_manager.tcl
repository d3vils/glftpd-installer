#									     #
# Tur-Predircheck_Manager.tcl 1.2 by Teqno                                   #
#									     #
# If tur-predircheck_manager.sh is not located in /glftpd/bin, then          #
# change the path in 'set binary' below.                                     #
#                                                                            #
# Change mainchania below to your irc channel. Users must be in that chan or #
# they will be ignored. No capital letters in mainchan.                      #
#                                                                            #
# If you change irc trigger here then be sure it's the same in the script    #
# itself under "irctrigger"                                                  #
#                                                                            #
##############################################################################

bind pub o !block pub:tur-predircheck
bind pub - !banned pub:banned
bind pub - !blocked pub:banned

set mainchania "changeme"

##############################################################################

## Public chan.
proc pub:tur-predircheck {nick output binary chan text} {
  set binary {/glftpd/bin/tur-predircheck_manager.sh}
  global mainchania
  if {$chan == $mainchania} {
    foreach line [split [exec $binary $nick $text] "\n"] {
       putquick "PRIVMSG $chan :$line"
    }
  }
}

proc pub:banned {nick output binary chan text} {
  set binary {/glftpd/bin/tur-predircheck_manager.sh}
    foreach line [split [exec $binary $nick list groups] "\n"] {
       putquick "PRIVMSG $nick :$line"
    }
    foreach line [split [exec $binary $nick list sections] "\n"] {
       putquick "PRIVMSG $nick :$line"
    }


}

putlog "Tur-Predircheck_Manager.tcl 1.2 by Teqno loaded"
