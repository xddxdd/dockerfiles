.text
.global _start
_start:
	mov $29, %eax
	int $0x80
	jmp _start
