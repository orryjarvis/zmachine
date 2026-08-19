ENTRY(_start)

SECTIONS
{
    . = 0x80000000;

    .text : ALIGN(16)
    {
        KEEP(*(.text.boot))
        *(.text)
        *(.text.*)
    }

    .rodata : ALIGN(16)
    {
        *(.rodata)
        *(.rodata.*)
        *(.srodata)
        *(.srodata.*)
    }

    .data : ALIGN(16)
    {
        *(.data)
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
    }

    .bss (NOLOAD) : ALIGN(16)
    {
        __bss_start = .;

        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
        *(COMMON)

        . = ALIGN(8);
        __bss_end = .;

        . = ALIGN(16);
        __stack_bottom = .;

        . += 16K;

        . = ALIGN(16);
        __stack_top = .;
    }
}
