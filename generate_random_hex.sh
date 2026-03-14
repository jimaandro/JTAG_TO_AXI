#!/bin/bash

# Parameters
num_words=512
output_file="random_hex_64bit.hex"

# Clear output file
> "$output_file"

# Generate 64-bit (16 hex digit) random values
for ((i=0; i<num_words; i++)); do
    # Use /dev/urandom to get 8 bytes, then convert to hex
    rand_hex=$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')
    printf "%016s\n" "$rand_hex" >> "$output_file"
done

echo "✅ Generated $num_words random 64-bit hex words in '$output_file'"
