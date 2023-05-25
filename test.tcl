proc run_ariane {input_file {jtag_mem 0x00000000}} {
if {[file exists $input_file]} {
        puts "The file $input_file exists."
} else {
        exec sh make_hex_file.sh tata
}
# 	Read the input bit file and
#	 seperate the commands 
set input [split [read [open $input_file r]] "\n"]
# 	set output = reversed input commands (seperated by _)
set output [join [lreverse $input] "_"]			
#	count the lines ( #instructions of input file) and subtract the last line
set num_lines [expr {[llength $input] - 1}]
puts num_lines
#	Reset axi transactions
reset_hw_axi [get_hw_axis hw_axi_1]

#	create the axi transaction for the memory data that we will write
create_hw_axi_txn wr_txnm [get_hw_axis hw_axi_1] -type write -address $jtag_mem -data $output -len $num_lines -size 32
#	write these data
run_hw_axi [get_hw_axi_txns wr_txnm]

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

#	Erase Ram data
set era [join [lrepeat $num_lines "00000000"] "_"]
create_hw_axi_txn wr_er [get_hw_axis hw_axi_1] -type write -address $jtag_mem -data $era -len $num_lines -size 32
#	write these data
run_hw_axi [get_hw_axi_txns wr_er]

#	delete all transactions that were created
delete_hw_axi_txn [get_hw_axi_txns *]
}

