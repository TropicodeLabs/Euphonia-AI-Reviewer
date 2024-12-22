#!/usr/bin/env bash
#
# merge_python.sh
#
# A bash script that prints the contents of the specified Python files
# into a single .txt file, separating them by a header line with the filename.
#
# Usage: ./merge_python.sh

# List of Python files to merge
FILES=("play_screen.dart" "bird_audio_utils.dart" "../pubspec.yaml")

# Output file name
OUTPUT_FILE="merged_files.txt"

echo "Merging the following files into $OUTPUT_FILE:"
printf ' - %s\n' "${FILES[@]}"
echo

# Overwrite the file if it already exists
> "$OUTPUT_FILE"

# Loop over each file and append its contents
for f in "${FILES[@]}"; do
    if [[ -f "$f" ]]; then
        echo "===== BEGIN $f =====" >> "$OUTPUT_FILE"
        cat "$f" >> "$OUTPUT_FILE"
        echo "===== END $f =====" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    else
        echo "Warning: '$f' not found, skipping..."
    fi
done

echo "Done! Output written to $OUTPUT_FILE."
