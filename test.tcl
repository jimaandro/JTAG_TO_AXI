proc run_ariane {input_file {jtag_mem 0x00000000}} {
if {[file exists $input_file]} {
        puts "The file $input_file exists."
} else {
        exec sh make_hex_file.sh $input_file
}
# 	Read the input bit file and
#	 seperate the commands 
set input [split [read [open $input_file r]] "\n"]

#	count the lines ( #instructions of input file) and subtract the last line
set num_lines [expr {[llength $input] - 1}]
set num_lines_copy $num_lines

while {$num_lines_copy > 0} {
    # Calculate the number of lines to process in this iteration
    set lines_to_process [expr {$num_lines_copy > 256 ? 256 : $num_lines_copy}]

    # Get the subset of lines to process in this iteration
    set input_subset [lrange $input 0 [expr {$lines_to_process - 1}]]
	set input_subset [lreverse $input_subset ]
    # Process the lines in this iteration
    set output [join $input_subset "_"]

    # Update the variables for the next iteration
    set input [lrange $input $lines_to_process end]


    #	create the axi transaction for the memory data that we will write
	create_hw_axi_txn wr_txnm [get_hw_axis hw_axi_1] -type write -address $jtag_mem -data $output -len $lines_to_process -size 32
	#	write these data
	run_hw_axi [get_hw_axi_txns wr_txnm]
	delete_hw_axi_txn wr_txnm
puts "Output for iteration: $output"
puts "jtag_mem for iteration: $jtag_mem"
puts "num_lines_copy for iteration: $num_lines_copy"

	    # Increase jtag_mem
   set increment_hex [format "0x%x" [expr {$lines_to_process * 4}]]
    set jtag_mem [format "0x%08x" [expr {($jtag_mem) + $increment_hex}]]  
    set num_lines_copy [expr {$num_lines_copy - $lines_to_process}]
puts "increment_hex for iteration: $increment_hex"

}

# 	The base memory address for Ariane is 0x0000800000000000
#	here we create 2 transactions (32 bit each) for writing the base address to Ariane core
#	wr2 is the MSB, wr1 is the LSB
create_hw_axi_txn wr1 [get_hw_axis hw_axi_1] -type write -address 0x80002000 -data {00000000}
create_hw_axi_txn wr2 [get_hw_axis hw_axi_1] -type write -address 0x80002008 -data {00008000}
#	write base address
run_hw_axi [get_hw_axi_txns wr1]
run_hw_axi [get_hw_axi_txns wr2]

# 	set the address of ariane reset 
set address 0x80000000 
# 	Create 2 transactions one for reset=1 and one for reset=0
create_hw_axi_txn wr_txn1 [get_hw_axis hw_axi_1] -type write -address $address -data {00000001}
create_hw_axi_txn wr_txn3 [get_hw_axis hw_axi_1] -type write -address $address -data {00000000}
#	Run reset transactions (Reset Ariane)
run_hw_axi [get_hw_axi_txns wr_txn3]
run_hw_axi [get_hw_axi_txns wr_txn1]


set num_lines_copy $num_lines
set jtag_mem 0x00000000
while {$num_lines_copy > 0} {
    # Calculate the number of lines to process in this iteration
    set lines_to_process [expr {$num_lines_copy > 256 ? 256 : $num_lines_copy}]


    #	Erase Ram data
set era [join [lrepeat $lines_to_process "00000000"] "_"]

create_hw_axi_txn wr_er [get_hw_axis hw_axi_1] -type write -address $jtag_mem -data $era -len $lines_to_process -size 32
#	write these data
 run_hw_axi [get_hw_axi_txns wr_er]


	delete_hw_axi_txn wr_er

	    # Increase jtag_mem
    set jtag_mem [expr { $jtag_mem + ($lines_to_process * 32) } ]

    set num_lines_copy [expr {$num_lines_copy - $lines_to_process}]
}

#	delete all transactions that were created
delete_hw_axi_txn [get_hw_axi_txns *]

}
