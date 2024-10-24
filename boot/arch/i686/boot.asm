;;; Blue Penguin Bootloader (32-bit) ;;;

[BITS 16]	; Using 16-bit code
[ORG 0x7C00]	; Start at address 0x7C00

;; MULTIBOOT Header
section .multiboot
align 4
	dd 0x1BADB002		; MULTIBOOT magic number, must be 0x1BADB002
	dd 0x00			; MULTIBOOT flags
	dd -(0x1BADB002 + 0x00)	; MULTIBOOT checksum, must be magic + flags + checksum = 0

;; Real Mode Entry Point
start_real_mode:
	;; Set up segment registers
	xor ax, ax	; Zero out AX
	mov ds, ax	; Data segment
	mov es, ax	; Extra segment
	mov ss, ax	; Stack segment
	mov sp, 0x7C00	; Set stack pointer to 0x7C00

	;; Load Kernel Into Memory
	mov bx, KERNEL_ADDR	; Address to load kernel
	mov ah, 0x02		; BIOS function to read sectors
	mov al, 10		; Number of sectors to read
	mov ch, 0		; Cylinder
	mov cl, 2		; Sector
	mov dh, 0		; Head
	int 0x13		; BIOS disk interrupt

	;; Load ES With 0x1000
	mov ax, 0x1000	; Load the 0x1000 segment value into AX
	mov es, ax	; Transfer the value into the extra segment (ES)

	;; Write Value To Memory
	mov di, 0x0000		; Offset address
	mov al, MEM_TEST_VAL	; Value to write
	mov [es:di], al		; Write value

	;; Read Value From Memory
	mov al, [es:di]	; Read value

	;; Compare Read Value With Write Value
	cmp al, MEM_TEST_VAL	; Compare with test value
	jne memerr		; If not equal, jump to error function

	;; Make The Switch
	cli		; Disable interrupts
	lgdt [gdt_desc]	; Load the GDT

	;; Set Up Control Registers For Protected Mode
	mov eax, cr0	; Load current value of cr0 into EAX
	or eax, 1	; Bitwise OR the value
	mov cr0, eax	; Load new value back into cr0

	;; Jump To Protected Mode Starting Point
	jmp CODESEG:start_protected_mode

;; Memory Error Handling
memerr:
	;; Set Video Mode To 320x200 256 Colors
	mov ah, 0x00	; BIOS function to set video mode
	mov al, 0x13	; 320x200 256 color graphics
	int 0x10	; BIOS video interrupt

	;; Load Video Memory Segment (0xA000) Into ES
	mov ax, 0xA000	; Load the 0xA000 segment value into AX
	mov es, ax	; Transfer the value into the extra segment (ES)

	;; Fill Screen
	mov cx, 0xFA00	; Total number of pixels
	mov al, 0x02	; Color index
	mov di, 0x0000	; Video memory segment
	rep stosb	; Fill video memory with color

	;; Halt System
	cli		; Disable interrupts
	hlt		; Halt the CPU

;; Global Descriptor Table (GDT)
gdt_start:
	dq 0x0000000000000000	; Null
	dq 0x00CF9A000000FFFF	; Code segment
	dq 0x00CF92000000FFFF	; Data segment
gdt_desc:
	dw gdt_end - gdt_start - 1
	dd gdt_start
gdt_end:

start_protected_mode:
	;; Set Up Segment Registers
	mov ax, DATASEG	; Load 0x10 for the data segment into AX
	mov ds, ax	; Data segment
	mov es, ax	; Extra segment
	mov fs, ax	; ...
	mov gs, ax	; ...
	mov ss, ax	; Stack segment

	;; Call Kernel
	call KERNEL_ADDR

	;; If Kernel Returns, Halt System
	hlt

;; Global Values
MEM_TEST_VAL equ 0x33
CODESEG equ 0x08
DATASEG equ 0x10
KERNEL_ADDR equ 0x1000

;; Bootsector Magic
times 510-($-$$) db 0	; Pad out 0s until 510th byte
dw 0xAA55		; Boot signature
