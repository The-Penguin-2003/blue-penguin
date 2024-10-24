/* The Blue Penguin Linker */

ENTRY(kernel_main)

SECTIONS
{
	. = 0x00100000;

	.multiboot : ALIGN(4)
	{
		LONG(0x1BADB002)
		LONG(0x00000000)
		LONG(-(0x1BADB002 + 0x00000000))
	}

	.text : ALIGN(16)
	{
		*(.text)
		*(.rodata)
	}

	.data : ALIGN(16)
	{
		*(.data)
	}

	.bss : ALIGN(16)
	{
		*(.bss)
		*(COMMON)
	}
}
