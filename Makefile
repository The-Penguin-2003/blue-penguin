AS = nasm
ASFLAGS = -f bin

CC32 = i686-elf-gcc
CC64 = x86_64-elf-gcc

CC32FLAGS = -Wall -m32 -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -ffreestanding -fno-stack-protector -I./include/arch/i686
CC64FLAGS = -Wall -m64 -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -ffreestanding -fno-stack-protector -I./include/arch/x86_64

LD32 = i686-elf-ld
LD64 = x86_64-elf-ld

LD32FLAGS = -g -m elf_i386 -T kernel/link.ld
LD64FLAGS = -g -m elf_x86_64 -T kernel/link.ld

all: i686-grub x86_64-grub i686-no-grub x86_64-no-grub

i686-grub: boot/arch/i686/boot.bin kernel/arch/i686/kernel.bin
	mkdir -p build/i686/isodir/boot/grub
	cp boot/arch/i686/boot.bin build/i686/isodir/boot/
	cp kernel/arch/i686/kernel.bin build/i686/isodir/boot/
	cp grub.cfg build/i686/isodir/boot/grub
	grub-mkrescue -o bluepenguin32-grub.iso build/i686/isodir

x86_64-grub: boot/arch/x86_64/boot.bin kernel/arch/x86_64/kernel.bin
	mkdir -p build/x86_64/isodir/boot/grub
	cp boot/arch/x86_64/boot.bin build/x86_64/isodir/boot/
	cp kernel/arch/x86_64/kernel.bin build/x86_64/isodir/boot/
	cp grub.cfg build/x86_64/isodir/boot/grub
	grub-mkrescue -o bluepenguin64-grub.iso build/x86_64/isodir

i686-no-grub: boot/arch/i686/boot.bin kernel/arch/i686/kernel.bin
	mkdir -p build-no-grub/i686
	cp boot/arch/i686/boot.bin build-no-grub/i686
	cp kernel/arch/i686/kernel.bin build-no-grub/i686
	cat build-no-grub/i686/boot.bin > bluepenguin32-no-grub.bin
	cat build-no-grub/i686/kernel.bin >> bluepenguin32-no-grub.bin
	dd status=noxfer conv=notrunc if=bluepenguin32-no-grub.bin of=bluepenguin32-no-grub.img
	truncate -s 1440k bluepenguin32-no-grub.img

x86_64-no-grub: boot/arch/x86_64/boot.bin kernel/arch/x86_64/kernel.bin
	mkdir -p build-no-grub/x86_64
	cp boot/arch/x86_64/boot.bin build-no-grub/x86_64
	cp kernel/arch/x86_64/kernel.bin build-no-grub/x86_64
	cat build-no-grub/x86_64/boot.bin > bluepenguin64-no-grub.bin
	cat build-no-grub/x86_64/kernel.bin >> bluepenguin64-no-grub.bin
	dd status=noxfer conv=notrunc if=bluepenguin64-no-grub.bin of=bluepenguin64-no-grub.img
	truncate -s 1440k bluepenguin64-no-grub.img

boot/arch/i686/boot.bin: boot/arch/i686/boot.asm
	$(AS) $(ASFLAGS) -o $@ $<

boot/arch/x86_64/boot.bin: boot/arch/x86_64/boot.asm
	$(AS) $(ASFLAGS) -o $@ $<

kernel/arch/i686/kernel.bin: kernel/arch/i686/kernel.o
	$(LD32) $(LD32FLAGS) -o $@ $<

kernel/arch/x86_64/kernel.bin: kernel/arch/x86_64/kernel.o
	$(LD64) $(LD64FLAGS) -o $@ $<

kernel/arch/i686/kernel.o: kernel/arch/i686/kernel.c
	$(CC32) $(CC32FLAGS) -c -o $@ $<

kernel/arch/x86_64/kernel.o: kernel/arch/x86_64/kernel.c
	$(CC64) $(CC64FLAGS) -c -o $@ $<

run32-grub: bluepenguin32-grub.iso
	qemu-system-i386 -cdrom bluepenguin32-grub.iso

run64-grub: bluepenguin64-grub.iso
	qemu-system-x86_64 -cdrom bluepenguin64-grub.iso

run32-no-grub: bluepenguin32-no-grub.img
	qemu-system-i386 -fda bluepenguin32-no-grub.img

run64-no-grub: bluepenguin64-no-grub.img
	qemu-system-x86_64 -fda bluepenguin64-no-grub.img

clean:
	rm -rf build build-no-grub boot/arch/i686/*.bin boot/arch/x86_64/*.bin kernel/arch/i686/*.bin kernel/arch/x86_64/*.bin kernel/arch/i686/*.o kernel/arch/x86_64/*.o *.img *.bin *.iso
