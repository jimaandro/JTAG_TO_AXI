#!/bin/bash

# Parameters
start_addr=0x1C0000000
num_words=512
output_file="sequential_addr.hex"

# Convert start_addr to decimal
start_dec=$((start_addr))

# Write to file
> "$output_file"  # Clear file if it exists

for ((i=0; i<num_words; i++)); do
    addr=$((start_dec + i * 8))
    printf "%016X\n" "$addr" >> "$output_file"
done

echo "✅ Generated $num_words 64-bit address words in '$output_file'"
