proc reset_ariane {}  {

# 	The base memory address for Ariane is 0x0000800000000000
#	here we create 2 transactions (32 bit each) for writing the base address to Ariane core
#	wr2 is the MSB, wr1 is the LSB
create_hw_axi_txn wr1 [get_hw_axis hw_axi_1] -type write -address 0x80002000 -data {80000000}
create_hw_axi_txn wr2 [get_hw_axis hw_axi_1] -type write -address 0x80002008 -data {00000000}
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


#	delete all transactions that were created
delete_hw_axi_txn [get_hw_axi_txns *]
}

proc ariane_off {} {
create_hw_axi_txn wr_txn3 [get_hw_axis hw_axi_1] -type write -address 0x80000000 -data {00000000}
#	Run reset transactions (Reset Ariane)
run_hw_axi [get_hw_axi_txns wr_txn3]
delete_hw_axi_txn [get_hw_axi_txns *]

}

proc ariane_on {} {
create_hw_axi_txn wr_txn3 [get_hw_axis hw_axi_1] -type write -address 0x80000000 -data {00000001}
#	Run reset transactions (Reset Ariane)
run_hw_axi [get_hw_axi_txns wr_txn3]
delete_hw_axi_txn [get_hw_axi_txns *]

}


proc reset_debug {}  {

# 	set the address of debug reset 
set address 0x40010000 
# 	Create 2 transactions one for reset=1 and one for reset=0
create_hw_axi_txn wr_txn1 [get_hw_axis hw_axi_1] -type write -address $address -data {00000001}
create_hw_axi_txn wr_txn3 [get_hw_axis hw_axi_1] -type write -address $address -data {00000000}
#	Run reset transactions (Reset Debug)
run_hw_axi [get_hw_axi_txns wr_txn3]
run_hw_axi [get_hw_axi_txns wr_txn1]
#	delete all transactions that were created
delete_hw_axi_txn [get_hw_axi_txns *]

}

