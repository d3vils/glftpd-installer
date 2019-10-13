#!/bin/bash
VER=1.0
#---------------------------------------------------------------#
#                                                               #
# Mediainfo by Teqno                                       	#
#								#
# It extracts info from *.rar file for related releases to	#
# give the user ability to compare quality.			#
#								#
#--[ Settings ]-------------------------------------------------#

GLROOT=/glftpd
TMP=$glroot/tmp
INPUT=`echo "$@" | cut -d " " -f2`
TV=`echo $INPUT | grep -o ".*S[0-9][0-9]E[0-9][0-9]."`
MOVIE=`echo $INPUT | sed 's/[0-9][0-9][0-9][0-9]p//' | grep -o ".*[0-9][0-9][0-9][0-9]."`

#--[ Script Start ]----------------------------------------------#

if [ -z $INPUT ]
then
    echo "Please enter full releasename ie Terminator.Salvation.2009.THEATRICAL.1080p.BluRay.x264-FLAME"
    echo "Only works for releases in: X264-1080 X265-2160 TV-720 TV-1080 TV-2160"
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
	    echo "Please enter full releasename ie Terminator.Salvation.2009.THEATRICAL.1080p.BluRay.x264-FLAME"
	    echo "Only works for releases in: X264-1080 X265-2160 TV-720 TV-1080 TV-2160"
	    exit 0
	    ;;
	esac
    else
	case $INPUT in
	    *.2160p.*)
	    section=TV-2160
	    release="$TV*2160p*"
	    ;;
	    *.1080p.*)
	    section=TV-1080
	    release="$TV*1080p*"
    	    ;;
	    *.720p.*)
	    section=TV-720
	    release="$TV*720p*"
	    ;;
	    *)
	    echo "Please enter full releasename ie Hard.Sun.S01E06.iNTERNAL.2160p.WEB.h265-BREXiT"
	    echo "Only works for releases in: X264-1080 X265-2160 TV-720 TV-1080 TV-2160"
	    exit 0
	    ;;
	esac
    fi
    cd /glftpd/bin
    if [ ! -d $TMP ]; then mkdir -m777 $glroot/tmp ; fi
    for info in `find $glroot/site/$section -name "$release"`
    do
	for media in `find $info -name "*.rar" -not -path "*/Subs*"`
	do
	    ./mediainfo-rar $media > $TMP/mediainfo.txt
	    release=`cat $TMP/mediainfo.txt | grep "^Filename" | cut -d ":" -f2 | sed -e "s|$glroot/site/$section/||" -e 's|/.*||' -e 's/ //'`
	    echo -n "$release"
	    filesize=`cat $TMP/mediainfo.txt | grep "File size*" | grep "MiB\|GiB" | cut -d ":" -f2 | sed 's/ //'`
	    echo -n " | $filesize"
	    duration=`cat $TMP/mediainfo.txt | grep "^Duration" | head -1 | cut -d ":" -f2 | sed 's/ //'`
	    echo -n " | $duration"
	    obitrate=`cat $TMP/mediainfo.txt | grep -v "Overall bit rate mode" | grep "Overall bit rate" | head -1 | cut -d ":" -f2 | sed 's/ //'`
	    if [ "$obitrate" ]; then echo -n " | Overall: $obitrate" ; fi
	    vbitrate=`cat $TMP/mediainfo.txt | grep "^Bit rate  " | head -1 | cut -d ":" -f2 | sed 's/ //'`
	    if [ "$vbitrate" ]; then echo -n " | Video: $vbitrate" ; fi
	    nbitrate=`cat $TMP/mediainfo.txt | grep "^Nominal bit rate  " | head -2 | tail -1 | cut -d ":" -f2 | sed 's/ //'`
	    if [ "$nbitrate" ]; then  echo -n " | Video Nominal: $nbitrate" ; fi
	    abitrate=`cat $TMP/mediainfo.txt | grep "^Bit rate  " | head -2 | tail -1 | cut -d ":" -f2 | sed 's/ //'`
	    if [ "$abitrate" ]; then echo -n " | Audio: $abitrate" ; fi
	    format=`cat $TMP/mediainfo.txt | grep "^Format         " | head -3 | tail -1 | cut -d ":" -f2 | sed -e 's/ //' -e 's/UTF\-8//'`
	    if [ "$format" ]; then echo -n " | $format" ; fi
	    channels=`cat $TMP/mediainfo.txt | grep "^Channel(s)" | head -1 | cut -d ":" -f2 | sed 's/ //'`
	    if [ "$channels" ]; then echo -n " $channels" ; fi
	    language=`cat $TMP/mediainfo.txt | grep "^Language         " | head -1 | cut -d ":" -f2 | sed 's/ //'`
	    if [ "$language" ]; then echo -n " $language" ; fi
	    echo
	done
    done
fi

exit 0