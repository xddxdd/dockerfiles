.text
.global _start
_start:
	mov %r7, $29
	swi $0
	b _start
