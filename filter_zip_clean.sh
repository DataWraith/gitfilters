#!/bin/bash

#
# This is a simple filter that decompresses ZIP-files (stores all files
# uncompressed inside a new ZIP file). This can increase the storage efficiency
# inside a git-repository, since
#
# a) the entire file is compressed by git, and compressing already compressed
#    files tends to not be very efficient.
#
# and
#
# b) without the compression, it will be easier for git to determine
#    similarities between files when making a pack. This is especially
#    important for OpenDocument files that are changed frequently.
#
# The disadvantage is, that the file inside your working copy will be bigger
# than before. ALSO: It does not seem to work with .jar-files.
#
# When the --odf option is passed on the commandline, the script will also
# remove superfluous files inside a OpenDocument file (cache, thumbnails).
#
# filter_zip_clean.sh relies on Info-Zip (sudo apt-get install unzip) and will
# not work if it is not available.
#
# To use the script add the following to your .gitconfig:
#
# [filter "zip"]
#         clean = "/path/to/script/filter_zip_clean.sh"
#
# [filter "odf"]
#         clean = "/path/to/script/filter_zip_clean.sh --odf"
#
# and add glob-patterns for zip and OpenDocument files to the .gitattributes
# file at the root of a git working copy:
#
# *.zip         filter=zip
# *.od[tpsgb]   filter=odf
#

set -e

# Check for Info-ZIP, and exit if it's not found
VERSION_STR=`zip -v | head -1`
if ! [[ $VERSION_STR == *Info-ZIP* ]]
then
  echo "filter_zip_clean.sh needs Info-ZIP installed to work! (\"sudo apt-get install unzip\")"
  exit 1
fi

# Get working directory to restore later
CUR_PWD=`pwd`

UNZIP_TMPDIR=`mktemp -d zipfilter.XXXXXXXXXX`
ZIP_TMPFILE=`mktemp -u zipfilter.XXXXXXXXXX` # The manpage claims this is unsafe? Why?

# Unzip input to temporary directory
unzip -qq -d "${UNZIP_TMPDIR}" /dev/stdin

# Remove unneccessary files if input is an ODF-file
if [ "$1" = "--odf" ]
then
        rm -f -- "${UNZIP_TMPDIR}/layout-cache"
        rm -rf -- "${UNZIP_TMPDIR}/Thumbnails/"
fi

# Re-zip everything and restore working directory
cd "${UNZIP_TMPDIR}"
zip -r -0 "${ZIP_TMPFILE}.zip" .
cd "${CUR_PWD}"

# Hand the re-zipped file back to git
cp -f -- "${ZIP_TMPFILE}.zip" /dev/stdout

# Clean up behind ourselves
rm -rf -- "${UNZIP_TMPDIR}"
rm -f  -- "${ZIP_TMPFILE}.zip"
