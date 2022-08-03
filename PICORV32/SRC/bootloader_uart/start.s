.global _start

.extern bootloader_main

_start:
	jal bootloader_main
