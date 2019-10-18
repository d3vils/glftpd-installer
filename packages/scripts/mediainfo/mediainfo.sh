#!/bin/bash
VER=1.4
#---------------------------------------------------------------#
#                                                               #
# Mediainfo by Teqno                                       	#
#								#
# It extracts info from *.rar file for related releases to	#
# give the user the ability to compare quality.			#
#								#
#--[ Settings ]-------------------------------------------------#

GLROOT=/glftpd
TMP=$GLROOT/tmp
TMPFILE=$TMP/mediainfo.txt
INPUT=`echo "$@" | cut -d " " -f2`
TV=`echo $INPUT | grep -o ".*.S[0-9][0-9]E[0-9][0-9].\|.*.E[0-9][0-9].\|.*.[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]."`
MOVIE=`echo $INPUT | sed 's/[0-9][0-9][0-9][0-9]p//' | grep -o ".*.[0-9][0-9][0-9][0-9]."`

#--[ Script Start ]----------------------------------------------#

HELP="
Please enter full releasename ie Terminator.Salvation.2009.THEATRICAL.1080p.BluRay.x264-FLAME\n
Only works for releases in: TV-720 TV-1080 TV-2160 TV-NO TV-NORDIC X264-1080 X265-2160
"

if [ -z $INPUT ]
then
    echo -e $HELP
else
    if [ -z $TV ] 
    then
	case $INPUT in
	    *.2160p.*)
    	    section=X265-2160
	    release="$MOVIE*"
	    ;;
	    *.1080p.*)
	    section=X264-1080
	    release="$MOVIE*"
	    ;;
	    *)
	    echo -e $HELP
	    exit 0
	    ;;
	esac
    else
	case $INPUT in
            *.2160p.*)
            section=TV-2160
            release="$TV*2160p*"
            ;;
            *.DANiSH.1080p.*|*.DANISH.1080p.*|*.SWEDiSH.1080p.*|*.FINNISH.1080p.*)
            section=TV-NORDIC
            release="$TV*1080p*"
            ;;
            *.NORWEGiAN.1080p.*)
            section=TV-NO
            release="$TV*1080p*"
            ;;
            *.1080p.*)
            section=TV-1080
            release="$TV*1080p*"
            ;;
            *.DANiSH.720p.*|*.DANISH.720p.*|*.SWEDiSH.720p.*|*.FINNISH.720p.*)
            section=TV-NORDIC
            release="$TV*720p*"
            ;;
            *.NORWEGiAN.720p.*)
            section=TV-NO
            release="$TV*720p*"
            ;;
            *.720p.*)
            section=TV-720
            release="$TV*720p*"
            ;;
	    *)
            echo -e $HELP
	    exit 0
	    ;;
	esac
    fi

    if [ $(find $GLROOT/site/$section/$release -type f -name "* Complete -*" | wc -l ) != "0" ]
    then
        echo "Release not found or incomplete"
        exit 0
    else
	cd $GLROOT/bin
	if [ ! -d $TMP ]; then mkdir -m777 $GLROOT/tmp ; fi
	for info in `ls $GLROOT/site/$section | grep -iv ".*NUKED.*" | grep -iv ".*INCOMPLETE.*" | grep "$release"`
	do
	    for media in `ls $GLROOT/site/$section/$info | grep ".*.rar"`
	    do
        	./mediainfo-rar $GLROOT/site/$section/$info/$media > $TMPFILE
        	release=`cat $TMPFILE | grep "^Filename" | cut -d ":" -f2 | sed -e "s|$GLROOT/site/$section/||" -e 's|/.*||' -e 's/ //'`
        	echo -n "$release"
        	filesize=`cat $TMPFILE | grep "File size*" | grep "MiB\|GiB" | cut -d ":" -f2 | sed 's/ //'`
        	echo -n " | $filesize"
        	duration=`cat $TMPFILE | sed -n '/General/,/Video/p' | grep "^Duration" | cut -d ":" -f2 | sed 's/ //'`
        	echo -n " | $duration"
        	obitrate=`cat $TMPFILE | sed -n '/General/,/Video/p' | grep -v "Overall bit rate mode" | grep "Overall bit rate" | cut -d ":" -f2 | sed 's/ //'`
        	if [ "$obitrate" ]; then echo -n " | Overall: $obitrate" ; fi
        	vbitrate=`cat $TMPFILE | sed -n '/Video/,/Forced/p' | grep "^Bit rate  " | cut -d ":" -f2 | sed 's/ //'`
        	if [ "$vbitrate" ]; then echo -n " | Video: $vbitrate" ; fi
        	nbitrate=`cat $TMPFILE | sed -n '/Video/,/Forced/p' | grep "^Nominal bit rate  " | cut -d ":" -f2 | sed 's/ //'`
        	if [ "$nbitrate" ]; then  echo -n " | Video Nominal: $nbitrate" ; fi
        	if [ -z "`cat $TMPFILE | sed -n '/Audio #1/,/Forced/p'`" ]; then audio="Audio" ;  else audio="Audio #1" ; fi
        	abitrate=`cat $TMPFILE | sed -n "/$audio/,/Forced/p" | grep "^Bit rate  " | cut -d ":" -f2 | sed 's/ //'`
        	if [ "$abitrate" ]; then echo -n " | Audio: $abitrate" ; fi
        	mabitrate=`cat $TMPFILE | sed -n "/$audio/,/Forced/p" | grep "^Maximum bit rate  " | cut -d ":" -f2 | sed 's/ //'`
        	if [ "$mabitrate" ]; then echo -n " | Max Audio: $mabitrate" ; fi
        	format=`cat $TMPFILE | sed -n "/$audio/,/Forced/p" | grep "^Format  " | cut -d ":" -f2 | sed -e 's/ //' -e 's/UTF\-8//'`
        	if [ "$format" ]; then echo -n " | $format" ; fi
        	channels=`cat $TMPFILE | sed -n "/$audio/,/Forced/p" | grep "^Channel(s)" | cut -d ":" -f2 | sed 's/ //'`
        	if [ "$channels" ]; then echo -n " $channels" ; fi
        	language=`cat $TMPFILE | sed -n "/$audio/,/Forced/p" | grep "^Language  " | cut -d ":" -f2 | sed 's/ //'`
        	if [ "$language" ]; then echo -n " $language" ; fi
        	echo
	    done
	    rm $TMPFILE
	done
    fi
fi

exit 0