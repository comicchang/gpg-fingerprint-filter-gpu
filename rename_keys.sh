#!/usr/bin/env bash

set -e

WORK_FOLDER=$1
if [ -z "$WORK_FOLDER" ]; then
    echo "Usage: $0 <work_folder>"
    echo "Batch rename gpg keys in WORK_FOLDER to <timestamp>-<fingerprint>.gpg"
    echo "WARNING: backup your keys before running this script"
    exit 1
fi

# find files with extension .gpg .asc or .key, and not containing "-"(this means already renamed)
for filename in $(find $WORK_FOLDER -type f \( -name "*.gpg" -o -name "*.asc" -o -name "*.key" \) -not -name "*-*"); do
    timestamp=$(gpg --list-packets $filename | perl -ne 'print $1,"\n" if /created (\d+)/' | head -n 1)
    if [ -z "$timestamp" ]; then
        echo "Failed to get timestamp for $filename, skipping"
        continue
    fi
    fingerprint=$(gpg --list-packets $filename | perl -ne 'print $1,"\n" if /keyid: (.+)/' | head -n 1)
    if [ -z "$fingerprint" ]; then
        echo "Failed to get fingerprint for $filename, skipping"
        continue
    fi
    new_filename=$(dirname $filename)/"$timestamp-$fingerprint.gpg"
    if [ -f "$new_filename" ]; then
        echo "File $new_filename already exists, skipping"
        continue
    fi

    echo "Rename $filename to $new_filename"
    mv $filename $new_filename
done
