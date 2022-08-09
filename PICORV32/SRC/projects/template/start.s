.global _start

.extern bootloader_entry

_start:
	jal bootloader_entry
