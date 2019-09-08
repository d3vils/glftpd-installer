#!/bin/bash
VER=1.0
#--[ Script Start ]---------------------------------------------#
#                                                               #
# Ircnick by Teqno                                              #
#                                                               #
# Let's you check what ircnick user has on site, only 		#
# works for sites that require users to invite themselves into  #
# channels.                                                     #
#                                                               #
#--[ Script Start ]---------------------------------------------#
# Don't change anything below this line

if [ -z "$1" ]; then
	echo "Syntax: !ircnick username"
else
	cat /glftpd/ftp-data/logs/glftpd.log | grep -i "invite:" | grep -i $1 | tail -3 | awk -F " " '{print $1" "$2" "$3" "$4" "$5" "$6" irnick: "$7" username: "$8}'
fi

exit 0
