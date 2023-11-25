# Ariane Testing

This repo, has been created to bare metal test the Ariane processor of the [CVA6 project](https://github.com/openhwgroup/cva6). It also contains the appropriate [files for installing](https://github.com/jimaandro/JTAG_TO_AXI/tree/main/install64) and testing Linux on Ariane. 

In this repository, different ways to test the Ariane have been developed. The [CVA6 project](https://github.com/openhwgroup/cva6), needs the existence of OpenOCD and a working Debug Module to bare metal test the Ariane. Here things are different. I have changed the design of [CVA6 project](https://github.com/openhwgroup/cva6), by adding a JTAG to AXI IP module connected to Memory, Reset Ariane and Reset of Debug Module. In this way we can control the whole system and write to memory, through the JTAG port using Tcl commands inside Vivado. 

This is NOT a standalone repository, it is part of a bigger private project called [Ariane_APU_U55C](https://github.com/jimaandro/Ariane_APU_U55C). This Ariane_APU_U55C project is the most part a copy of the [CVA6 project](https://github.com/openhwgroup/cva6), but the difference is that it is a Vivado block design project. It was developed during my master thesis with the contribution of CARV, FORTH and some parts the project are owned by CARV, FORTH. So it can only be accessed after consultation with CARV, FORTH. But you can actually use the current project with the official [CVA6 project](https://github.com/openhwgroup/cva6).


#### Features
- `test.tcl` is for testing a C++ program dirrectly to Ariane, through JTAG. you just need to source it in Vivado Tcl command line and then hit `run_ariane inputf.hex`.
- `test2.tcl` is for reading some specific space in memory. After sourcing it in Vivado, type `read_trnx 3  0x00000000`. This will read 3 32 bit numbers starting from address 0x0.
- `test3.tcl` is for just reseting the ariane and the debug module. This is only if you need to run Linux
- `make_hex_file.sh` is used by test.tcl for compiling your `main.cpp` to hex and then test1 writes it to memory.



#### Installation
- 'git clone https://github.com/jimaandro/JTAG_TO_AXI'

