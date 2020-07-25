.text
.global _start
_start:
	mov w8, 29
	svc 0
	b _start
