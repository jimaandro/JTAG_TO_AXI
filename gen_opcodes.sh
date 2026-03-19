#!/bin/bash

# 1. Define your Tcl script and output file
TCL_SCRIPT="your_script.tcl"
OUTPUT_FILE="operation_results.log"

# 2. Clear the output file so you start fresh every time you run this bash script
> "$OUTPUT_FILE"

# 3. Create a helper function to format the log and run the script
run_operation() {
    # Grab the very first argument (e.g., NTT_INTT)
    local first_arg=$1
    
    # Write the comment header to the output file (>> means append)
    echo "========================================" >> "$OUTPUT_FILE"
    echo "# Output for operation: $first_arg" >> "$OUTPUT_FILE"
    echo "========================================" >> "$OUTPUT_FILE"
    
    # Run standard Tcl, pass ALL arguments ("$@"), and append the output
    tclsh "$TCL_SCRIPT" "$@" >> "$OUTPUT_FILE"
    
    # Add a blank line at the end for readability
    echo "" >> "$OUTPUT_FILE"
    
    # Optional: Print to the terminal so you know it's working
    echo "Finished running: $first_arg"
}

# --- 4. RUN YOUR COMMANDS HERE ---

run_operation NTT_INTT MAC_GENERAL INTT LOAD_FROM_REG SAVE_TO_REG R2 1 4 7 1 1 0

# Add as many more as you want below!
# run_operation ANOTHER_OP 5 6 7 8
# run_operation MULTIPLY_OP 1 2 3