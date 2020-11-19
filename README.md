Piano lovers, if they are not aware of the rendered Welte-Mignon piano rolls at SUPRA, https://exhibits.stanford.edu/supra, will be delighted by the MIDI and audio files found there.  It is possible to download 400 or more mp3's, mp4's etc. from https://purl.stanford.edu/xf457dx9166 in a single zip file.  Unfortunately, the mp3 files do not have intelligible titles or any associated metadata to aid the listener in identifying composer, performer or selection.

Fortunately the creators, Shi Zhengshan and Craig Stuart Sapp and the other contributors to SUPRA have made available a collection of MARCXML files on github.com that contains a comprehensively filled in schema for almost every rendered SUPRA selection available for download. The purpose of this program is to get the MARCXML file from github.com/pianoroll/SUPRA associated with each mp3 and retrieve information to set an appropriate filename for each mp3 and add metadata tags for  artist, title, year , date and composer.

Acquire the SUPRA zip (from e.g. https://stacks.stanford.edu/file/druid:xf457dx9166/supra-rw-mp3.zip) of all the available supra  mp3 renditions and un\
zip the mp3's into directory "supra-rw-mp3."                                                                                                              
The individual mp3's will have unhelpful names like bb988jx6754.mp3 and will have no useful metadata.  The purpose of this program is to get the MARCXM\
L file from github.com/pianoroll/SUPRA associated with each mp3 and retrieve information to set an appropriate filename for each mp3 and add metadata tags for  artist, title, year , date and composer.                                                                                                           
This shell program, supra.sh, running under Linux, attempts to find a MARCXML describing each mp3 at https://github.com/pianoroll/SUPRA/tree/master/metadata/marcxml. See https://www.loc.gov/marc/concise/                                                                                                                   
Requires ffmpeg to set mp3 metadata, wget to retrieve the MARCXML and xmlstarlet to parse the MARCXML files.                                                                          
Run supra.sh in a terminal from the directory immediately above supra-rw-mp3/ new/ and xml/, creating "new" and "xml" beforehand. The program will populate the "xml" directory with the retrieved marcxml and the "new" directory with the re-named and tagged mp3's.  A log file will be produced each time the program is run.                               

To display tags in JSON format:                                                                                                                         
ffprobe -print_format json -show_format -hide_banner new/<mp3 file>                                                                                     

Many thanks to the SUPRA project at Stanford University.

This program is free software.  It may be redistributed and/or modified under the terms of the GNU General Public License, version 2, as published by the Free Software Foundation.                                                                                                                              

Copyright © 2019, 2020 William J. Spurlin 

Bill Spurlin
bill@ideologue.net
November 18, 2020


# supra-script
