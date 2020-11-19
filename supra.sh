#!/bin/bash

# This program is free software.  It may be redistributed and/or modified under the terms of the GNU General Public License, version 2, as published by the Free Software Foundation.

# Copyright © 2019, 2020 William J. Spurlin

# Attach useful filenames and metadata to SUPRA mp3's.

# Acquire the SUPRA zip (from e.g. https://stacks.stanford.edu/file/druid:xf457dx9166/supra-rw-mp3.zip) of all the available supra  mp3 renditions and unzip the mp3's into directory "supra-rw-mp3." 

# The individual mp3's will have unhelpful names like bb988jx6754.mp3 and will have no useful metadata.  The purpose of this program is to get the MARCXML file from github.com/pianoroll/SUPRA associated with each mp3 and retrieve information to set an appropriate filename for each mp3 and add metadata tags for  artist, title, year , date and composer.

# The program attempts to find a MARCXML describing each mp3 at https://github.com/pianoroll/SUPRA/tree/master/metadata/marcxml.
# See https://www.loc.gov/marc/concise/

# Requires ffmpeg to set mp3 metadata and xmlstarlet to parse the MARCXML files.

# Run this program from the directory immediately above supra-rw-mp3/ new/ and xml/. The program will populate the "xml" directory with the retrieved marcxml and the "new" directory with the re-named and tagged mp3's.  A log file will be produced each time the program is run.  

# To display tags in JSON format:
# ffprobe -print_format json -show_format -hide_banner new/<mp3 file>

# Many thanks to the SUPRA project at Stanford University, and to its creators, Shi Zhengshan and Craig Stuart Sapp.

shopt -s extglob;

# function cleanem: remove suspect characters from filenames/tags.
cleanem (){
    vv="$1";
    vv=${vv//\,};
    vv=${vv//\/};
    vv=${vv//\(};
    vv=${vv//\:};
    vv=${vv//\)};
    vv=${vv//\=};
    vv=${vv//$'.\n'/' '};
    vv=${vv//$'\n'};
    vv=${vv%%*(' ')};
    vv=${vv%%*('.')};
    vv=${vv//\;};
    vv=${vv//\[};
    vv=${vv//\]};
    vv=${vv//"    "};
    vv=${vv//\?};
    vv=${vv//\"};
    vv=${vv//\'};
    vv=${vv//\'};
    vv=${vv/\&amp/and};
}

date >> "../$$.log"; 

while getopts 'ph' c
do
  case $c in
    p) ADD_PERFORMER=1 ;;
    h) echo "Usage: \"supra.sh [ -p ] \" from a directory immediately above supra-rw-mp3/ xml/ and new/ . -p appends the performer to the filename." ;exit;
  esac
done


a=`ls supra-rw-mp3/ 2> /dev/null` || { echo "supra-rw-mp3 does not exist" ;exit 1;}
if [[ $a == "" ]];
then
    echo "supra-rw-mp3 is empty";
    exit;
fi
if  ! [ -d "xml" ] || ! [ -d "new" ];
then
   echo "Correct directories xml/new do not exist"
   exit;
fi

cd "xml";
for i in $a;
do y=`basename -s .mp3 $i`;
   echo $y;
   if ! [[ -e $y.marcxml ]]
      then
	  wget https://raw.githubusercontent.com/pianoroll/SUPRA/master/metadata/marcxml/${i:0:1}/$y.marcxml;
	  [[ $? == 0 ]] || { echo "$y.marcxml not found"; printf "$y.marcxml not found\n\n" >> "../$$.log"; };
   fi
done
cd "..";

for i in $a;
do
   y=`basename -s .mp3 $i`;
   echo $y.marcxml;
   if [ -e xml/$y.marcxml ];
   then
       # Get the filename from the "Title Statement".  See https://www.loc.gov/marc/bibliographic/bd245.html 
       o=`xmlstarlet sel  -N x='http://www.loc.gov/MARC21/slim'  -t -m "//x:datafield[@tag=245]" -v . -n xml/$y.marcxml`;
       # The title of the piece
       title=`xmlstarlet sel  -N x='http://www.loc.gov/MARC21/slim'  -t -m "//x:datafield[@tag=245]/x:subfield[@code='a']" -v . -n xml/$y.marcxml`;
       # The performer
       artist=`xmlstarlet sel  -N x='http://www.loc.gov/MARC21/slim'  -t -m "//x:datafield[@tag=511]" -v . -n xml/$y.marcxml`;
       # The year/date, where available
       year=`xmlstarlet sel  -N x='http://www.loc.gov/MARC21/slim'  -t -m "//x:datafield[@tag=264]/x:subfield[@code='c']" -v . -n xml/$y.marcxml`;
       # Put the name of the composer in the album metadata
       album=`xmlstarlet sel  -N x='http://www.loc.gov/MARC21/slim'  -t -m "//x:datafield[@tag=245]/x:subfield[@code='c']" -v . -n xml/$y.marcxml`;
   else
       echo $y.marcxml not found;
   fi;
   
   cleanem "$o";echo "vv = $vv";
   newfilename="${vv}"; 

   vv=${artist//", piano."}
   cleanem "$vv";
   artist="$vv";

   if [[ $ADD_PERFORMER == 1 ]]
   then
       newfilename="${newfilename} $artist";
   fi
   
   newfilename="${newfilename}.mp3";
   echo "newfilename = ${newfilename}"

   echo "$y -> ${newfilename}"  >> "$$.log";
   echo "Artist: $artist" >> "$$.log";

   vv=$title;
   cleanem "$vv";
   title="$vv";
   echo "Title: $title" >> "$$.log";
   year=${year//\[};
   year=${year//\]};
   echo "Year: $year" >> "$$.log";

   # The composer name can perhaps safely go in the ID3v2 "album_artist"/TPE2 tag, but I also put it in the album tag because
   # the album artist tag is not displayed in the Mercedes-Benz COMAND or Audio 20 media player.
   # See https://www.blisshq.com/music-library-management-blog/2010/10/12/how-to-use-album_artist/
   
   vv=$album;
   cleanem "$vv";
   album="$vv";
   echo "Composer: $album" >> "$$.log";

   if [ -e "new/$newfilename" ]
   then
       echo "$newfilename already exists" >> "$$.log";
       echo "" >> "$$.log";
       continue;
   fi
   echo "" >> "$$.log";


   cp "supra-rw-mp3/$i" "/tmp/$newfilename";

   ffmpeg -i "/tmp/$newfilename" -c copy -metadata artist="$artist" -metadata title="$title" -metadata year="$year" -metadata date="$year" -metadata album="$album Welte-Mignon SUPRA"  -metadata "TPE2"="$album" "new/$newfilename";
   rm -f "/tmp/$newfilename";
done

