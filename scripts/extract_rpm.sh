#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <file.rpm>"
  exit 1
fi

RPM_FILE="$1"
OUTPUT_DIR="${RPM_FILE%.rpm}_extracted"

mkdir -p "$OUTPUT_DIR"

# rpm2cpio converts RPM to cpio archive, then cpio extracts it
rpm2cpio "$RPM_FILE" | cpio -idmv -D "$OUTPUT_DIR"

echo "Extracted to: $OUTPUT_DIR"
