/* The Blue Penguin Kernel (64-bit) */

#include <types.h>
#include <multiboot.h>

void kernel_main();

multiboot_header_t mboot_head = 
{
	.magic = 0x1BADB002,
	.flags = 0x0,
	.checksum = -(0x1BADB002 + 0x0),
	.header_addr = (uint64_t)&mboot_head,
	.load_addr = 0x0,
	.load_end_addr = 0x0,
	.bss_end_addr = 0x0,
	.entry_addr = (uint64_t)&kernel_main
};

void kernel_main()
{
	while (1);
}
