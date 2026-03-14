# JTAG to AXI Hardware Transaction Generator

This Tcl script provides a suite of procedures to interact with a hardware design via Xilinx Vivado's Hardware Manager. It uses a JTAG-to-AXI master (`hw_axi_1`) to perform memory reads and writes, manage burst transactions, reset slave components, and run automated memory verification tests. 

## Prerequisites
* **Xilinx Vivado:** Must be connected to a hardware target with an instantiated JTAG-to-AXI Master IP named `hw_axi_1`.
* **Environment:** A Unix-like environment (Linux/WSL) is required for shell commands like `diff`, `sh`, and `bash`.
* **External Scripts:** Some procedures rely on external bash and Tcl scripts:
  * `make_hex_file.sh`
  * `generate_random_hex.sh`
  * `Opcode_generator.tcl`

---

## Core Procedures

### Memory Write Procedures

* **`write_trnx {jtag_mem input_file bit_sz}`**
  Reads a newline-separated `.hex` file and writes the entire contents to the specified address in a single AXI transaction.
  * `jtag_mem` *(default: 0x1C0000000)*: Base address for the write.
  * `input_file` *(default: "inputf")*: The hex file containing the data.
  * `bit_sz` *(default: 64)*: The word size in bits.

* **`write_single_trnx {burst_size jtag_mem input_file bit_sz}`**
  An advanced write procedure that chunks data into specified burst sizes. If the `input_file` is missing, it attempts to generate it using `make_hex_file.sh`.
  * `burst_size` *(default: 1)*: Number of words to write per AXI transaction.
  * `jtag_mem` *(default: 0x1C0000000)*: Starting address.
  * `input_file` *(default: "inputf")*: Input hex file.
  * `bit_sz` *(default: 64)*: Word size in bits.

### Memory Read Procedures

* **`read_trnx {rd_sz jtag_mem bit_sz}`**
  Performs an AXI read transaction, parses the returned flat hex string into individual words, reverses the array to correct endianness/ordering, and returns the array.
  * `rd_sz`: Number of words to read.
  * `jtag_mem` *(default: 0x1C0000000)*: Base address.
  * `bit_sz` *(default: 64)*: Word size in bits.

* **`read_single_trnx {num_reads burst_size start_addr bit_sz filename}`**
  Reads memory in burst chunks and writes the padded 64-bit output to a file.
  * `num_reads`: Total number of words to read.
  * `burst_size` *(default: 1)*: Number of words to read per transaction.
  * `start_addr` *(default: 0x1C0000000)*: Starting address.
  * `bit_sz` *(default: 64)*: Word size in bits.
  * `filename` *(default: "read_output.hex")*: File to save the read data.

---

## Hardware Control & Testing

### `reset_slave {address}`
Creates and executes a specific sequence of AXI writes to reset a connected slave component (e.g., an Ariane RISC-V core).
* `address` *(default: 0xd0000800)*: The memory-mapped reset register address.
* **Write Sequence:** `0x00...00` -> `0x00...030000` -> `0x00...00`.

### `write_read_diff_trnx {jtag_mem input_file bit_sz burst_size}`
A complete verification flow. It writes data from a file to memory, reads it back into a new file (`read_back_<filename>.hex`), and uses the Unix `diff` command to verify that the written and read data match exactly.

### `run_test {burst_size jtag_mem input_file bit_sz}`
Polls the control register at `0xD0000800`. If it reads the specific trigger value `0000000003000000`, it executes `write_read_diff_trnx`. Otherwise, it skips the test.

### `run_test_random_burst_n {N jtag_mem input_file bit_sz}`
Runs `run_test` `N` times. In each iteration, it:
1. Randomly selects a burst size from `{1, 2, 4, 8, 16}`.
2. Regenerates random hex data by calling `generate_random_hex.sh` (if the default filename is used).
3. Executes the test.

### `run_test_opcode {N jtag_mem file_name bit_sz}`
Sources `Opcode_generator.tcl` to generate specific hardware accelerator instructions (e.g., NTT/INTT, MAC) and writes them to a file. It then uses `write_single_trnx` to push these opcodes into memory (default address `0x50000000`).

---

## Usage Example

To run a 5-iteration random burst memory test from the Vivado Tcl Console:

Run 5 random burst tests on the default address
```console
source test_axi_based_ip.tcl
run_test_random_burst_n 5
```