;;; Blue Penguin Bootloader (64-bit) ;;;

[BITS 16]	; Using 16-bit code
[ORG 0x7C00]	; Boot code starts at memory address 0x7C00

;; MULTIBOOT Header
section .multiboot
align 4
	dd 0x1BADB002		; MULTIBOOT magic number
	dd 0x00			; MULTIBOOT flags
	dd -(0x1BADB002 + 0x00)	; MULTIBOOT checksum, must be magic + flags + checksum = 0

;; Real Mode Entry Point
start_real_mode:
	;; Set Up Segment Registers
	xor ax, ax	; Zero out AX
	mov ds, ax	; Data segment
	mov es, ax	; Extra segment
	mov ss, ax	; Stack segment
	mov sp, 0x7C00	; Set stack pointer to 0x7C00

	;; Load Kernel
	mov bx, KERNEL_ADDR	; Address to load kernel into
	mov ah, 0x02		; BIOS function to read disk sectors
	mov al, 10		; Number of sectors to read
	mov ch, 0		; Cylinder
	mov cl, 2		; Sector
	mov dh, 0		; Head
	int 0x13		; BIOS disk interrupt

	;; Switch To Protected Mode
	cli		; Disable interrupts
	lgdt [gdt_desc]	; Load GDT

	;; Set Up Control Registers For Protected Mode
	mov eax, cr0	; Move current value of CR0 into EAX
	or eax, 1	; Bitwise OR the value
	mov cr0, eax	; Move the new value back into CR0

	;; Jump To Protected Mode
	jmp CODESEG:start_protected_mode	; Far jump to protected mode entry point

;; Global Descriptor Table (GDT)
gdt_start:
	dq 0x0000000000000000	; Null
	dq 0x00CF9A000000FFFF	; 32-bit code segment
	dq 0x00CF92000000FFFF	; 32-bit data segment
	dq 0x00CF9A000000FFFF	; 64-bit code segment
	dq 0x00CF92000000FFFF	; 64-bit data segment
gdt_desc:
	dw gdt_end - gdt_start - 1
	dd gdt_start
gdt_end:

;; Protected Mode Entry Point
start_protected_mode:
	;; Set Up Long Mode
	mov eax, cr4		; Move current value of CR4 into EAX
	or eax, 0x00000020	; Enable PAE
	mov cr4, eax		; Move new value back into CR4

	;; Enable Long Mode
	mov eax, 0xC0000080	; IA32_EFER MSR
	rdmsr
	or eax, 0x00000100	; Set LME
	wrmsr

	;; Enable Paging
	mov eax, cr0		; Move current value of CR0 into EAX
	or eax, 0x80000001	; Set PG and PE bits
	mov cr0, eax		; Move new value back into CR0

	;; Jump To Long Mode
	jmp DATASEG:start_long_mode	; Far jump to long mode entry point

;; Long Mode Entry Point
start_long_mode:
	;; Set Up Segment Registers
	mov eax, DATASEG	; Move 0x10 into EAX
	mov ds, eax		; Data segment
	mov es, eax		; Extra segment
	mov fs, eax		; ...
	mov gs, eax		; ...
	mov ss, eax		; Stack segment

	;; Call Kernel
	call KERNEL_ADDR	; Call the kernel entry function

	;; If Kernel Returns, Halt System
	hlt	; Halt CPU

;; Global Values
CODESEG equ 0x08
DATASEG equ 0x10
KERNEL_ADDR equ 0x1000

;; Bootloader Magic
times 510-($-$$) db 0	; Pad out 0s until 510th byte
dw 0xAA55		; Boot signature
