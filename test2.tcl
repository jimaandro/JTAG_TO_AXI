proc write_trnx {input_file {jtag_mem 0x40000000} {bit_sz 32}} {
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

proc read_trnx {rd_sz {jtag_mem 0x40000000} {bit_sz 32}} {
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

proc example_wr_rd {input_file rd_sz {jtag_mem 0x40000000} {bit_sz 32}} {
		# the input_file is the .hex file with all data we want to write. Words are seperated with \n
		# the rd_sz is the number of words we want to read
		# the jtag_mem is the base address we want to read
		# the bit_sz is the size of words we will read 
#	this is just an example that uses the previous two procedures
#	and prints the array
write_trnx input_file.hex $jtag_mem $bit_sz
array set arr [read_trnx $rd_sz $jtag_mem $bit_sz]

for { set i 0} {$i < $rd_sz} {incr i} {
	puts "arr($i) = $arr($i)"
}

}

