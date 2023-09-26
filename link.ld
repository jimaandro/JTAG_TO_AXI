OUTPUT_ARCH(riscv)
ENTRY(_start)

SECTIONS
{	  /* 0000800000000000 */
    ROM_BASE = 0x8200000000; /* ... but actually position independent */

    . = ROM_BASE;

    .text : {
    _TEXT_START_ = .;
        *(.text.init)
        *(.text)
    _TEXT_END_ = .;
    }

    .data : ALIGN(0x100) {
    _DATA_START_ = .;
        *(.data)
    _DATA_END_ = .;
    }

    .bss : ALIGN(0x100) {
    _BSS_START_ = .;
        *(.bss)
    _BSS_END_ = .;
    }
}
