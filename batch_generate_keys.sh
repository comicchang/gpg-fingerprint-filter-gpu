#!/usr/bin/env bash

set -e

GPU_INDEX=$1
KEY_COUNT=$2
ALGO=$3
OUTPUT_FOLDER=$4
if [ -z $OUTPUT_FOLDER ]; then
    OUTPUT_FOLDER=./"$ALGO"
fi

if [ -z "$ALGO" ]; then
    echo "Usage: $0 GPU_INDEX KEY_COUNT ALGO OUTPUT_FOLDER"
    echo
    echo "e.g. $0 0 100  ed25519          (use GPU0 to generate 100 ed25519 keys, save into ./ed25519)"
    echo "     $0 1 1000 cv25519 ~/output (use GPU1 to generate 1000 cv25519 keys, save into ~/output)"
    exit 1
fi

export CUDA_DEVICE_ORDER="PCI_BUS_ID" CUDA_VISIBLE_DEVICES="$GPU_INDEX"

mkdir -p $OUTPUT_FOLDER > /dev/null 2>&1

for i in `seq 1 $KEY_COUNT`; do
    ./gpg-fingerprint-filter-gpu \
        -a $ALGO \
        -t 63115200 \
        "x{12}|xxxxxxxxy{8}|yyyyxxxxxxxxy{4}|yyyyyyyyxxxxy{4}|yyyyxxxxy{8}|wwwwxxxxy{8}|xxxxxxxxxxxxy{4}|xxxxyyyyxxxxyyyy|wwwwxxxxyyyyzzzz|(wxyz){4}|1145141919810|23{11}" \
        $OUTPUT_FOLDER/

    # in case of ctrl+c
    sleep 0.5
done
