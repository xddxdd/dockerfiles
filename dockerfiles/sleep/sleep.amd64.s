.text
.global _start
_start:
	mov $29, %rax
	int $0x80
	jmp _start
