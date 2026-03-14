# Define the enumeration mappings based on the SystemVerilog package
array set sv_enums {
    # mac_sub_op_t
    MAC_GENERAL        0
    MAC_MODMULT        1
    MAC_MODADD         2

    # ntt_sub_op_t
    NTT                0
    INTT               1

    # kernel_op
    MAC                0
    NTT_INTT           1
    AUTO               2
    MEM_OP_LOAD        3
    MEM_OP_STORE       4

    # load_type_t
    LOAD_FROM_MEM      0
    LOAD_FROM_REG      1
    LOAD_FROM_PREVIOUS 2

    # save_type_t
    SAVE_TO_MEM        0
    SAVE_TO_REG        1
    FORWARD_TO_NEXT    2
}

# The procedure to generate the 64-bit hex opcode
proc run_operation {base_op mac_subtype ntt_subtype load_type save_type a_reg sel_start sel_end a_addr_offset b_addr_offset Num_of_loads_A Num_of_loads_B} {
    global sv_enums

    # Look up enum values (default to 0 if not found, though you can add error handling here)
    set val_base_op      $sv_enums($base_op)
    set val_mac_subtype  $sv_enums($mac_subtype)
    set val_ntt_subtype  $sv_enums($ntt_subtype)
    set val_load_type    $sv_enums($load_type)
    set val_save_type    $sv_enums($save_type)

    # Parse register (e.g., "R2" -> 2)
    set val_a_reg [string trimleft $a_reg "R"]

    # Ensure integer values for numeric inputs
    set val_a_addr_offset [expr {$a_addr_offset}]
    set val_b_addr_offset [expr {$b_addr_offset}]
    set val_Num_of_loads_A [expr {$Num_of_loads_A}]
    set val_Num_of_loads_B [expr {$Num_of_loads_B}]

    # Apply bit masking to ensure values fit in their designated widths
    set val_save_type       [expr {$val_save_type       & 0x3}]   ;# 2 bits [1:0]
    set val_load_type       [expr {$val_load_type       & 0x3}]   ;# 2 bits [3:2]
    set val_ntt_subtype     [expr {$val_ntt_subtype     & 0x1}]   ;# 1 bit  [4]
    set val_mac_subtype     [expr {$val_mac_subtype     & 0x3}]   ;# 2 bits [6:5]
    set val_base_op         [expr {$val_base_op         & 0x7}]   ;# 3 bits [9:7]
    set val_a_reg           [expr {$val_a_reg           & 0x3F}]  ;# 6 bits [15:10]
    set val_a_addr_offset   [expr {$val_a_addr_offset   & 0x7F}]  ;# 7 bits [22:16]
    set val_b_addr_offset   [expr {$val_b_addr_offset   & 0x7F}]  ;# 7 bits [29:23]
    set val_Num_of_loads_A  [expr {$val_Num_of_loads_A  & 0x1FF}] ;# 9 bits [38:30]
    set val_Num_of_loads_B  [expr {$val_Num_of_loads_B  & 0x1FF}] ;# 9 bits [47:39]

    # Assemble the 64-bit opcode via bitwise shifts
    # Using wide() ensures Tcl treats the shifts as 64-bit operations
    set opcode [expr {
        (wide($val_Num_of_loads_B) << 39) |
        (wide($val_Num_of_loads_A) << 30) |
        (wide($val_b_addr_offset)  << 23) |
        (wide($val_a_addr_offset)  << 16) |
        (wide($val_a_reg)          << 10) |
        (wide($val_base_op)        << 7)  |
        (wide($val_mac_subtype)    << 5)  |
        (wide($val_ntt_subtype)    << 4)  |
        (wide($val_load_type)      << 2)  |
        (wide($val_save_type)      << 0)
    }]

    # Format the result as a 64-bit uppercase Hexadecimal string (zero-padded to 16 characters)
    set hex_opcode [format "0x%016llX" $opcode]
    
    return $hex_opcode
}

# --- Example Usage ---
# run_operation(NTT_INTT, MAC_GENERAL, INTT, LOAD_FROM_REG, SAVE_TO_REG, R2, sel_start, sel_end, a_addr_input_offset, b_addr_input_offset, q_in, Num_of_loads_A, Num_of_loads_B)
set my_hex [run_operation NTT_INTT MAC_GENERAL INTT LOAD_FROM_REG SAVE_TO_REG R2 0 4 7 1 1 0]
puts "Generated Opcode: $my_hex"