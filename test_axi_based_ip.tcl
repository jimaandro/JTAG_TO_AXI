# use 'write_trnx' to call this function with default args
proc write_trnx {{jtag_mem 0x1C0000000} {input_file "inputf"} {bit_sz 64}} {
		# the input_file is the .hex file with all data we want to write. Words are seperated with \n
		# the jtag_mem is the base address we want to write
		# the bit_sz is the size of words we will write 
# 	Read the input bit file and
#	 seperate the commands 
set input [split [read [open $input_file r]] "\n"]
# 	set output = reversed input commands (seperated by _)
set output [join [lreverse $input] "_"]			
#	count the lines ( #instructions of input file) and subtract the last line
set num_lines [expr {[llength $input] - 1}]
#	Reset axi transactions
reset_hw_axi [get_hw_axis hw_axi_1]

#	create the axi transaction for the memory data that we will write
create_hw_axi_txn wr_txnm [get_hw_axis hw_axi_1] -type write -address $jtag_mem -data $output -len $num_lines -size $bit_sz
#	write these data
run_hw_axi [get_hw_axi_txns wr_txnm]
#	delete all previous created transactions
delete_hw_axi_txn [get_hw_axi_txns *]

}


proc reset_c2c {}  {

set address 0xd0000800 
# 	Create 2 transactions one for reset=1 and one for reset=0
create_hw_axi_txn wr_txn1 [get_hw_axis hw_axi_1] -type write -address $address -data {0000000000000000}
create_hw_axi_txn wr_txn3 [get_hw_axis hw_axi_1] -type write -address $address -data {0000000000030000}
#	Run reset transactions (Reset Ariane)

run_hw_axi [get_hw_axi_txns wr_txn1]
run_hw_axi [get_hw_axi_txns wr_txn3]
run_hw_axi [get_hw_axi_txns wr_txn1]

#	delete all transactions that were created
delete_hw_axi_txn [get_hw_axi_txns *]
}

# proc read_single_trnx {num_reads {burst_size 1} {start_addr 0x1C0000000} {bit_sz 64} {filename "read_output.hex"}} {
#     # Compute word size in bytes
#     set word_bytes [expr {$bit_sz == 32 ? 4 : 8}]

#     # Open file for writing
#     set fh [open $filename "w"]
#     set num_lines_copy $num_reads
#     set addr [format "0x%x" [expr {$start_addr}]]
#     set i 0
#     # Perform single-word reads in a loop
# while {$num_lines_copy > 0} {
#     # Calculate the number of lines to process in this iteration
#     set lines_to_process [expr {$num_lines_copy > $burst_size ? $burst_size : $num_lines_copy}]


#     set read_data [read_trnx $lines_to_process $addr $bit_sz]

# 	# puts "addr for iteration: $addr"
# 	# puts "num_lines_copy for iteration: $num_lines_copy"

# 	    # Increase addr
# 	set increment_hex [format "0x%x" [expr {$lines_to_process * ($bit_sz == 32 ? 4 : 8)}]]
# 	set addr [format "0x%08x" [expr {($addr) + $increment_hex}]]  
# 	set num_lines_copy [expr {$num_lines_copy - $lines_to_process}]
#     incr i
# 	# puts "increment_hex for iteration: $increment_hex"


#         # Flatten and extract the hex value 
#         # Assume read_data is a flat list like: {0 key0 1 key1}
# 		# puts "Read $i from $addr => $read_data"
#         array set tmp $read_data
#         set word $tmp(0)

#         # Pad to 16 hex digits (64-bit value) and write
#         puts $fh [format "%016s" $word]
#     }
#     close $fh
#     # puts "Read results written to '$filename'"
# }
proc read_trnx {rd_sz {jtag_mem 0x1C0000000} {bit_sz 64}} {
		# the rd_sz is the number of words we want to read
		# the jtag_mem is the base address we want to read
		# the bit_sz is the size of words we will read 

#	Create the read transaction
create_hw_axi_txn rd_txnm [get_hw_axis hw_axi_1] -type read -address $jtag_mem -len $rd_sz -size $bit_sz
#	Run the read transaction (read DATA)
run_hw_axi [get_hw_axi_txns rd_txnm]

#	this variable gets the DATA (these are the read data) from the rd_txnm object
set read_in [get_property DATA [get_hw_axi_txns rd_txnm]]
#	the hex_sz is the number of hex digits of its word we read
#	if data size is 32 then we need 8 hex digits to represent it (hex_sz =8)
#	if it is 64 then hex_sz =16
if { $bit_sz < 64} {
set hex_sz 8
} else {
set hex_sz 16
}

#	now we seperate the read data in rd_sz words 
#	based on the hex_sz (its word has hx_sz digits)
#	then we put its word in the array
for { set i 0} {$i < $rd_sz} {incr i} {
	set j [expr {$i * $hex_sz} ]
	set number [string range $read_in $j [expr {$j + $hex_sz -1}]]
      	set arr($i) $number
}
#	delete all previous created transactions
delete_hw_axi_txn [get_hw_axi_txns *]
#	reverse array
for {set i 0} { $i < $rd_sz } {incr i} {
set new_arr($i) $arr([expr {$rd_sz -$i -1 }])
}
for { set i 0} {$i < $rd_sz} {incr i} {
	puts "arr($i) = $new_arr($i)"
}
#	return the array
return [array get new_arr]
}

proc read_single_trnx {num_reads {burst_size 1} {start_addr 0x1C0000000} {bit_sz 64} {filename "read_output.hex"}} {
    set word_bytes [expr {$bit_sz == 32 ? 4 : 8}]
    set fh [open $filename "w"]

    set i 0
    while {$i < $num_reads} {
        # Determine how many words to read in this burst
        set this_burst [expr {min($burst_size, $num_reads - $i)}]

        # Compute address for this burst
        set addr [format "0x%x" [expr {$start_addr + ($i * $word_bytes)}]]

        # Read burst
        set read_data [read_trnx $this_burst $addr $bit_sz]
        # puts "🔄 Burst read $this_burst words from $addr"

        # Parse flat key-value list from returned array
        array set tmp $read_data
        for {set j 0} {$j < $this_burst} {incr j} {
            set word $tmp($j)
            puts $fh [format "%016s" $word]
        }

        incr i $this_burst
    }

    close $fh
    # puts "✅ Read results written to '$filename'"
}

# Helper: min() for Tcl (if not defined)
proc min {a b} {
    if {$a < $b} { return $a } else { return $b }
}

proc write_single_trnx {{burst_size 1} {jtag_mem 0x1C0000000} {input_file "inputf"} {bit_sz 64}} {
if {[file exists $input_file]} {
        # puts "The file $input_file exists."
} else {
        exec sh make_hex_file.sh $input_file
}
# 	Read the input bit file and
#	 seperate the commands 
set input [split [read [open $input_file r]] "\n"]

#	count the lines ( #instructions of input file) and subtract the last line
global num_lines
set num_lines [expr {[llength $input] - 1}]
set num_lines_copy $num_lines

while {$num_lines_copy > 0} {
    # Calculate the number of lines to process in this iteration
    set lines_to_process [expr {$num_lines_copy > $burst_size ? $burst_size : $num_lines_copy}]

    # Get the subset of lines to process in this iteration
    set input_subset [lrange $input 0 [expr {$lines_to_process - 1}]]
	set input_subset [lreverse $input_subset ]
    # Process the lines in this iteration
    set output [join $input_subset "_"]

    # Update the variables for the next iteration
    set input [lrange $input $lines_to_process end]


    #	create the axi transaction for the memory data that we will write
	create_hw_axi_txn wr_txnm [get_hw_axis hw_axi_1] -type write -address $jtag_mem -data $output -len $lines_to_process -size $bit_sz
	#	write these data
	run_hw_axi [get_hw_axi_txns wr_txnm]
	delete_hw_axi_txn wr_txnm

	# puts "Output for iteration: $output"
	# puts "jtag_mem for iteration: $jtag_mem"
	# puts "num_lines_copy for iteration: $num_lines_copy"

	    # Increase jtag_mem
	set increment_hex [format "0x%x" [expr {$lines_to_process * ($bit_sz == 32 ? 4 : 8)}]]
	set jtag_mem [format "0x%08x" [expr {($jtag_mem) + $increment_hex}]]  
	set num_lines_copy [expr {$num_lines_copy - $lines_to_process}]
	# puts "increment_hex for iteration: $increment_hex"

}

}


proc write_read_diff_trnx {{jtag_mem 0x1C0000000} {input_file "inputf"} {bit_sz 64} {burst_size 1}} {
    set read_back_file "read_back_[file tail $input_file].hex"

    # Step 1: Get number of lines in the input file
    set fh_in [open $input_file r]
    set lines [split [read $fh_in] "\n"]
    close $fh_in
    set num_words [expr {[llength [lsearch -all -inline $lines *]] - 1}] ;# Skip empty lines

    # Step 2: Write input data to JTAG memory
    puts "✍️  Writing $num_words words from '$input_file' to address $jtag_mem..."
    write_single_trnx $burst_size $jtag_mem $input_file $bit_sz

    # Step 3: Read back into a separate file
    puts "📥 Reading back $num_words words to '$read_back_file'..."
    read_single_trnx $num_words $burst_size $jtag_mem $bit_sz $read_back_file

    # Step 4: Diff the files line by line
    puts "🔍 Running diff between '$input_file' and '$read_back_file'..."
    set result [exec bash -c "diff -iu $input_file $read_back_file"]

    if {[string length $result] == 0} {
        puts "✅ Files match!"
    } else {
        puts "❌ Files differ:"
        puts $result
    }
}

proc run_test {{burst_size 1} {jtag_mem 0x1C0000000} {input_file "inputf"} {bit_sz 64}} {
    # Read one word from 0xD0000800
    set reg_val_arr [read_trnx 1 0xD0000800 64]

    # Extract the value from the array
    array set reg_val $reg_val_arr
    set val $reg_val(0)

    puts "🔎 Read from 0xD0000800: $val"

    # Check if value matches expected trigger
    if {[string tolower $val] eq "0000000003000000"} {
        puts "✅ Match found — running write_read_diff_trnx..."
        write_read_diff_trnx $jtag_mem $input_file $bit_sz $burst_size
    } else {
        puts "❌ No match — skipping write_read_diff_trnx"
    }
}


proc run_test_random_burst_n {N {jtag_mem 0x1C0000000} {input_file "random_hex_64bit.hex"} {bit_sz 64}} {
    set burst_sizes {1 2 4 8 16}
    # reset_c2c
	puts "⏳ Waiting 6 seconds..."
	after 6000

    for {set i 0} {$i < $N} {incr i} {
        puts "\n🔁 Test iteration [expr {$i + 1}] of $N"

        # Step 1: Pick random burst size
        set index [expr {int(rand() * [llength $burst_sizes])}]
        set burst_size [lindex $burst_sizes $index]
        puts "🎲 Selected burst_size: $burst_size"

        # Step 2: Regenerate random hex if needed
        if {[string equal $input_file "random_hex_64bit.hex"]} {
            puts "⚙️  Generating new 'random_hex_64bit.hex'..."
            exec bash ./generate_random_hex.sh
        }

        # Step 3: Run test
        run_test $burst_size $jtag_mem $input_file $bit_sz
        puts "🎲 Selected burst_size: $burst_size"
    }
}

