#ifndef __MULTIBOOT_H__
#define __MULTIBOOT_H__

#include <types.h>

typedef struct multiboot_header
{
	uint64_t magic;
	uint64_t flags;
	uint64_t checksum;
	uint64_t header_addr;
	uint64_t load_addr;
	uint64_t load_end_addr;
	uint64_t bss_end_addr;
	uint64_t entry_addr;
} multiboot_header_t;

#endif /* __MULTIBOOT_H__ */
