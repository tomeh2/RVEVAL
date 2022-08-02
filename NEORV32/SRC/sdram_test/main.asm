
main.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	30005073          	csrwi	mstatus,0

00000004 <__crt0_pointer_init>:
   4:	80002117          	auipc	sp,0x80002
   8:	ff810113          	addi	sp,sp,-8 # 80001ffc <__crt0_stack_begin+0x0>
   c:	80000197          	auipc	gp,0x80000
  10:	7f818193          	addi	gp,gp,2040 # 80000804 <__crt0_stack_begin+0xffffe808>

00000014 <__crt0_cpu_csr_init>:
  14:	00000517          	auipc	a0,0x0
  18:	13050513          	addi	a0,a0,304 # 144 <__crt0_trap_handler>
  1c:	30551073          	csrw	mtvec,a0
  20:	30001073          	csrw	mstatus,zero
  24:	30401073          	csrw	mie,zero
  28:	34401073          	csrw	mip,zero
  2c:	32001073          	csrw	mcountinhibit,zero
  30:	30601073          	csrw	mcounteren,zero
  34:	b0001073          	csrw	mcycle,zero
  38:	b8001073          	csrw	mcycleh,zero
  3c:	b0201073          	csrw	minstret,zero
  40:	b8201073          	csrw	minstreth,zero

00000044 <__crt0_reg_file_init>:
  44:	00000213          	li	tp,0
  48:	00000293          	li	t0,0
  4c:	00000313          	li	t1,0
  50:	00000393          	li	t2,0
  54:	00000813          	li	a6,0
  58:	00000893          	li	a7,0
  5c:	00000913          	li	s2,0
  60:	00000993          	li	s3,0
  64:	00000a13          	li	s4,0
  68:	00000a93          	li	s5,0
  6c:	00000b13          	li	s6,0
  70:	00000b93          	li	s7,0
  74:	00000c13          	li	s8,0
  78:	00000c93          	li	s9,0
  7c:	00000d13          	li	s10,0
  80:	00000d93          	li	s11,0
  84:	00000e13          	li	t3,0
  88:	00000e93          	li	t4,0
  8c:	00000f13          	li	t5,0
  90:	00000f93          	li	t6,0

00000094 <__crt0_copy_data>:
  94:	7b000593          	li	a1,1968
  98:	80000617          	auipc	a2,0x80000
  9c:	f6860613          	addi	a2,a2,-152 # 80000000 <__crt0_stack_begin+0xffffe004>
  a0:	80000697          	auipc	a3,0x80000
  a4:	f6468693          	addi	a3,a3,-156 # 80000004 <__crt0_stack_begin+0xffffe008>
  a8:	00c58e63          	beq	a1,a2,c4 <__crt0_clear_bss>

000000ac <__crt0_copy_data_loop>:
  ac:	00d65c63          	bge	a2,a3,c4 <__crt0_clear_bss>
  b0:	0005a703          	lw	a4,0(a1)
  b4:	00e62023          	sw	a4,0(a2)
  b8:	00458593          	addi	a1,a1,4
  bc:	00460613          	addi	a2,a2,4
  c0:	fedff06f          	j	ac <__crt0_copy_data_loop>

000000c4 <__crt0_clear_bss>:
  c4:	80000717          	auipc	a4,0x80000
  c8:	f4070713          	addi	a4,a4,-192 # 80000004 <__crt0_stack_begin+0xffffe008>
  cc:	80000797          	auipc	a5,0x80000
  d0:	f3878793          	addi	a5,a5,-200 # 80000004 <__crt0_stack_begin+0xffffe008>

000000d4 <__crt0_clear_bss_loop>:
  d4:	00f75863          	bge	a4,a5,e4 <__crt0_call_constructors>
  d8:	00072023          	sw	zero,0(a4)
  dc:	00470713          	addi	a4,a4,4
  e0:	ff5ff06f          	j	d4 <__crt0_clear_bss_loop>

000000e4 <__crt0_call_constructors>:
  e4:	70c00413          	li	s0,1804
  e8:	70c00493          	li	s1,1804

000000ec <__crt0_call_constructors_loop>:
  ec:	00945a63          	bge	s0,s1,100 <__crt0_call_constructors_loop_end>
  f0:	0009a083          	lw	ra,0(s3)
  f4:	000080e7          	jalr	ra
  f8:	00440413          	addi	s0,s0,4
  fc:	ff1ff06f          	j	ec <__crt0_call_constructors_loop>

00000100 <__crt0_call_constructors_loop_end>:
 100:	00000513          	li	a0,0
 104:	00000593          	li	a1,0
 108:	088000ef          	jal	ra,190 <main>

0000010c <__crt0_main_exit>:
 10c:	30047073          	csrci	mstatus,8
 110:	34051073          	csrw	mscratch,a0

00000114 <__crt0_call_destructors>:
 114:	70c00413          	li	s0,1804
 118:	70c00493          	li	s1,1804

0000011c <__crt0_call_destructors_loop>:
 11c:	00945a63          	bge	s0,s1,130 <__crt0_call_destructors_loop_end>
 120:	00042083          	lw	ra,0(s0)
 124:	000080e7          	jalr	ra
 128:	00440413          	addi	s0,s0,4
 12c:	ff1ff06f          	j	11c <__crt0_call_destructors_loop>

00000130 <__crt0_call_destructors_loop_end>:
 130:	00000093          	li	ra,0
 134:	00008463          	beqz	ra,13c <__crt0_main_aftermath_end>
 138:	000080e7          	jalr	ra

0000013c <__crt0_main_aftermath_end>:
 13c:	10500073          	wfi
 140:	0000006f          	j	140 <__crt0_main_aftermath_end+0x4>

00000144 <__crt0_trap_handler>:
 144:	ff810113          	addi	sp,sp,-8
 148:	00812023          	sw	s0,0(sp)
 14c:	00912223          	sw	s1,4(sp)
 150:	34202473          	csrr	s0,mcause
 154:	02044663          	bltz	s0,180 <__crt0_trap_handler_end>
 158:	34102473          	csrr	s0,mepc
 15c:	00041483          	lh	s1,0(s0)
 160:	0034f493          	andi	s1,s1,3
 164:	00240413          	addi	s0,s0,2
 168:	34141073          	csrw	mepc,s0
 16c:	00300413          	li	s0,3
 170:	00941863          	bne	s0,s1,180 <__crt0_trap_handler_end>
 174:	34102473          	csrr	s0,mepc
 178:	00240413          	addi	s0,s0,2
 17c:	34141073          	csrw	mepc,s0

00000180 <__crt0_trap_handler_end>:
 180:	00012403          	lw	s0,0(sp)
 184:	00412483          	lw	s1,4(sp)
 188:	00810113          	addi	sp,sp,8
 18c:	30200073          	mret

00000190 <main>:
 190:	fe010113          	addi	sp,sp,-32
 194:	00000593          	li	a1,0
 198:	00000513          	li	a0,0
 19c:	00112e23          	sw	ra,28(sp)
 1a0:	00812c23          	sw	s0,24(sp)
 1a4:	00912a23          	sw	s1,20(sp)
 1a8:	01312623          	sw	s3,12(sp)
 1ac:	01412423          	sw	s4,8(sp)
 1b0:	01212823          	sw	s2,16(sp)
 1b4:	494000ef          	jal	ra,648 <neorv32_gpio_port_set>
 1b8:	70c00513          	li	a0,1804
 1bc:	274000ef          	jal	ra,430 <neorv32_uart0_print>
 1c0:	72800513          	li	a0,1832
 1c4:	26c000ef          	jal	ra,430 <neorv32_uart0_print>
 1c8:	00000413          	li	s0,0
 1cc:	800004b7          	lui	s1,0x80000
 1d0:	ffff09b7          	lui	s3,0xffff0
 1d4:	3e800593          	li	a1,1000
 1d8:	00040513          	mv	a0,s0
 1dc:	500000ef          	jal	ra,6dc <__modsi3>
 1e0:	00051a63          	bnez	a0,1f4 <main+0x64>
 1e4:	00010637          	lui	a2,0x10
 1e8:	00040593          	mv	a1,s0
 1ec:	73c00513          	li	a0,1852
 1f0:	298000ef          	jal	ra,488 <neorv32_uart0_printf>
 1f4:	0004a783          	lw	a5,0(s1) # 80000000 <__crt0_stack_begin+0xffffe004>
 1f8:	00241713          	slli	a4,s0,0x2
 1fc:	00048913          	mv	s2,s1
 200:	00e787b3          	add	a5,a5,a4
 204:	01340733          	add	a4,s0,s3
 208:	00e7a023          	sw	a4,0(a5)
 20c:	00140413          	addi	s0,s0,1
 210:	000107b7          	lui	a5,0x10
 214:	fcf410e3          	bne	s0,a5,1d4 <main+0x44>
 218:	74800513          	li	a0,1864
 21c:	214000ef          	jal	ra,430 <neorv32_uart0_print>
 220:	75000513          	li	a0,1872
 224:	20c000ef          	jal	ra,430 <neorv32_uart0_print>
 228:	00000413          	li	s0,0
 22c:	ffff09b7          	lui	s3,0xffff0
 230:	3e800593          	li	a1,1000
 234:	00040513          	mv	a0,s0
 238:	4a4000ef          	jal	ra,6dc <__modsi3>
 23c:	00051a63          	bnez	a0,250 <main+0xc0>
 240:	00010637          	lui	a2,0x10
 244:	00040593          	mv	a1,s0
 248:	73c00513          	li	a0,1852
 24c:	23c000ef          	jal	ra,488 <neorv32_uart0_printf>
 250:	00092783          	lw	a5,0(s2)
 254:	00241593          	slli	a1,s0,0x2
 258:	01340633          	add	a2,s0,s3
 25c:	00b785b3          	add	a1,a5,a1
 260:	0005a683          	lw	a3,0(a1)
 264:	02d60863          	beq	a2,a3,294 <main+0x104>
 268:	76800513          	li	a0,1896
 26c:	21c000ef          	jal	ra,488 <neorv32_uart0_printf>
 270:	fff00513          	li	a0,-1
 274:	01c12083          	lw	ra,28(sp)
 278:	01812403          	lw	s0,24(sp)
 27c:	01412483          	lw	s1,20(sp)
 280:	01012903          	lw	s2,16(sp)
 284:	00c12983          	lw	s3,12(sp)
 288:	00812a03          	lw	s4,8(sp)
 28c:	02010113          	addi	sp,sp,32
 290:	00008067          	ret
 294:	00140413          	addi	s0,s0,1
 298:	000107b7          	lui	a5,0x10
 29c:	f8f41ae3          	bne	s0,a5,230 <main+0xa0>
 2a0:	74800513          	li	a0,1864
 2a4:	18c000ef          	jal	ra,430 <neorv32_uart0_print>
 2a8:	00000513          	li	a0,0
 2ac:	fc9ff06f          	j	274 <main+0xe4>

000002b0 <__neorv32_uart_itoa>:
 2b0:	fd010113          	addi	sp,sp,-48
 2b4:	02812423          	sw	s0,40(sp)
 2b8:	02912223          	sw	s1,36(sp)
 2bc:	03212023          	sw	s2,32(sp)
 2c0:	01312e23          	sw	s3,28(sp)
 2c4:	01412c23          	sw	s4,24(sp)
 2c8:	02112623          	sw	ra,44(sp)
 2cc:	01512a23          	sw	s5,20(sp)
 2d0:	00050493          	mv	s1,a0
 2d4:	00058413          	mv	s0,a1
 2d8:	00058523          	sb	zero,10(a1)
 2dc:	00000993          	li	s3,0
 2e0:	00410913          	addi	s2,sp,4
 2e4:	79000a13          	li	s4,1936
 2e8:	00a00593          	li	a1,10
 2ec:	00048513          	mv	a0,s1
 2f0:	3b8000ef          	jal	ra,6a8 <__umodsi3>
 2f4:	00aa0533          	add	a0,s4,a0
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	01390ab3          	add	s5,s2,s3
 300:	00048513          	mv	a0,s1
 304:	00fa8023          	sb	a5,0(s5)
 308:	00a00593          	li	a1,10
 30c:	354000ef          	jal	ra,660 <__udivsi3>
 310:	00198993          	addi	s3,s3,1 # ffff0001 <__crt0_stack_begin+0x7ffee005>
 314:	00a00793          	li	a5,10
 318:	00050493          	mv	s1,a0
 31c:	fcf996e3          	bne	s3,a5,2e8 <__neorv32_uart_itoa+0x38>
 320:	00090693          	mv	a3,s2
 324:	00900713          	li	a4,9
 328:	03000613          	li	a2,48
 32c:	0096c583          	lbu	a1,9(a3)
 330:	00070793          	mv	a5,a4
 334:	fff70713          	addi	a4,a4,-1
 338:	01071713          	slli	a4,a4,0x10
 33c:	01075713          	srli	a4,a4,0x10
 340:	00c59a63          	bne	a1,a2,354 <__neorv32_uart_itoa+0xa4>
 344:	000684a3          	sb	zero,9(a3)
 348:	fff68693          	addi	a3,a3,-1
 34c:	fe0710e3          	bnez	a4,32c <__neorv32_uart_itoa+0x7c>
 350:	00000793          	li	a5,0
 354:	00f907b3          	add	a5,s2,a5
 358:	00000593          	li	a1,0
 35c:	0007c703          	lbu	a4,0(a5) # 10000 <__neorv32_ram_size+0xe000>
 360:	00070c63          	beqz	a4,378 <__neorv32_uart_itoa+0xc8>
 364:	00158693          	addi	a3,a1,1
 368:	00b405b3          	add	a1,s0,a1
 36c:	00e58023          	sb	a4,0(a1)
 370:	01069593          	slli	a1,a3,0x10
 374:	0105d593          	srli	a1,a1,0x10
 378:	fff78713          	addi	a4,a5,-1
 37c:	02f91863          	bne	s2,a5,3ac <__neorv32_uart_itoa+0xfc>
 380:	00b40433          	add	s0,s0,a1
 384:	00040023          	sb	zero,0(s0)
 388:	02c12083          	lw	ra,44(sp)
 38c:	02812403          	lw	s0,40(sp)
 390:	02412483          	lw	s1,36(sp)
 394:	02012903          	lw	s2,32(sp)
 398:	01c12983          	lw	s3,28(sp)
 39c:	01812a03          	lw	s4,24(sp)
 3a0:	01412a83          	lw	s5,20(sp)
 3a4:	03010113          	addi	sp,sp,48
 3a8:	00008067          	ret
 3ac:	00070793          	mv	a5,a4
 3b0:	fadff06f          	j	35c <__neorv32_uart_itoa+0xac>

000003b4 <__neorv32_uart_tohex>:
 3b4:	00758693          	addi	a3,a1,7
 3b8:	00000713          	li	a4,0
 3bc:	79c00613          	li	a2,1948
 3c0:	02000813          	li	a6,32
 3c4:	00e557b3          	srl	a5,a0,a4
 3c8:	00f7f793          	andi	a5,a5,15
 3cc:	00f607b3          	add	a5,a2,a5
 3d0:	0007c783          	lbu	a5,0(a5)
 3d4:	00470713          	addi	a4,a4,4
 3d8:	fff68693          	addi	a3,a3,-1
 3dc:	00f680a3          	sb	a5,1(a3)
 3e0:	ff0712e3          	bne	a4,a6,3c4 <__neorv32_uart_tohex+0x10>
 3e4:	00058423          	sb	zero,8(a1)
 3e8:	00008067          	ret

000003ec <__neorv32_uart_touppercase.constprop.0>:
 3ec:	00b50693          	addi	a3,a0,11
 3f0:	01900613          	li	a2,25
 3f4:	00054783          	lbu	a5,0(a0)
 3f8:	f9f78713          	addi	a4,a5,-97
 3fc:	0ff77713          	andi	a4,a4,255
 400:	00e66663          	bltu	a2,a4,40c <__neorv32_uart_touppercase.constprop.0+0x20>
 404:	fe078793          	addi	a5,a5,-32
 408:	00f50023          	sb	a5,0(a0)
 40c:	00150513          	addi	a0,a0,1
 410:	fed512e3          	bne	a0,a3,3f4 <__neorv32_uart_touppercase.constprop.0+0x8>
 414:	00008067          	ret

00000418 <neorv32_uart0_putc>:
 418:	00040737          	lui	a4,0x40
 41c:	fa002783          	lw	a5,-96(zero) # ffffffa0 <__crt0_stack_begin+0x7fffdfa4>
 420:	00e7f7b3          	and	a5,a5,a4
 424:	fe079ce3          	bnez	a5,41c <neorv32_uart0_putc+0x4>
 428:	faa02223          	sw	a0,-92(zero) # ffffffa4 <__crt0_stack_begin+0x7fffdfa8>
 42c:	00008067          	ret

00000430 <neorv32_uart0_print>:
 430:	ff010113          	addi	sp,sp,-16
 434:	00812423          	sw	s0,8(sp)
 438:	01212023          	sw	s2,0(sp)
 43c:	00112623          	sw	ra,12(sp)
 440:	00912223          	sw	s1,4(sp)
 444:	00050413          	mv	s0,a0
 448:	00a00913          	li	s2,10
 44c:	00044483          	lbu	s1,0(s0)
 450:	00140413          	addi	s0,s0,1
 454:	00049e63          	bnez	s1,470 <neorv32_uart0_print+0x40>
 458:	00c12083          	lw	ra,12(sp)
 45c:	00812403          	lw	s0,8(sp)
 460:	00412483          	lw	s1,4(sp)
 464:	00012903          	lw	s2,0(sp)
 468:	01010113          	addi	sp,sp,16
 46c:	00008067          	ret
 470:	01249663          	bne	s1,s2,47c <neorv32_uart0_print+0x4c>
 474:	00d00513          	li	a0,13
 478:	fa1ff0ef          	jal	ra,418 <neorv32_uart0_putc>
 47c:	00048513          	mv	a0,s1
 480:	f99ff0ef          	jal	ra,418 <neorv32_uart0_putc>
 484:	fc9ff06f          	j	44c <neorv32_uart0_print+0x1c>

00000488 <neorv32_uart0_printf>:
 488:	fa010113          	addi	sp,sp,-96
 48c:	04f12a23          	sw	a5,84(sp)
 490:	04410793          	addi	a5,sp,68
 494:	02812c23          	sw	s0,56(sp)
 498:	03212823          	sw	s2,48(sp)
 49c:	03312623          	sw	s3,44(sp)
 4a0:	03512223          	sw	s5,36(sp)
 4a4:	03612023          	sw	s6,32(sp)
 4a8:	01712e23          	sw	s7,28(sp)
 4ac:	01812c23          	sw	s8,24(sp)
 4b0:	01912a23          	sw	s9,20(sp)
 4b4:	02112e23          	sw	ra,60(sp)
 4b8:	02912a23          	sw	s1,52(sp)
 4bc:	03412423          	sw	s4,40(sp)
 4c0:	00050413          	mv	s0,a0
 4c4:	04b12223          	sw	a1,68(sp)
 4c8:	04c12423          	sw	a2,72(sp)
 4cc:	04d12623          	sw	a3,76(sp)
 4d0:	04e12823          	sw	a4,80(sp)
 4d4:	05012c23          	sw	a6,88(sp)
 4d8:	05112e23          	sw	a7,92(sp)
 4dc:	00f12023          	sw	a5,0(sp)
 4e0:	02500a93          	li	s5,37
 4e4:	00a00b13          	li	s6,10
 4e8:	07000913          	li	s2,112
 4ec:	05800993          	li	s3,88
 4f0:	07500b93          	li	s7,117
 4f4:	07800c13          	li	s8,120
 4f8:	07300c93          	li	s9,115
 4fc:	00044483          	lbu	s1,0(s0)
 500:	02049c63          	bnez	s1,538 <neorv32_uart0_printf+0xb0>
 504:	03c12083          	lw	ra,60(sp)
 508:	03812403          	lw	s0,56(sp)
 50c:	03412483          	lw	s1,52(sp)
 510:	03012903          	lw	s2,48(sp)
 514:	02c12983          	lw	s3,44(sp)
 518:	02812a03          	lw	s4,40(sp)
 51c:	02412a83          	lw	s5,36(sp)
 520:	02012b03          	lw	s6,32(sp)
 524:	01c12b83          	lw	s7,28(sp)
 528:	01812c03          	lw	s8,24(sp)
 52c:	01412c83          	lw	s9,20(sp)
 530:	06010113          	addi	sp,sp,96
 534:	00008067          	ret
 538:	0f549c63          	bne	s1,s5,630 <neorv32_uart0_printf+0x1a8>
 53c:	00240a13          	addi	s4,s0,2
 540:	00144403          	lbu	s0,1(s0)
 544:	0d240263          	beq	s0,s2,608 <neorv32_uart0_printf+0x180>
 548:	06896463          	bltu	s2,s0,5b0 <neorv32_uart0_printf+0x128>
 54c:	06300793          	li	a5,99
 550:	08f40463          	beq	s0,a5,5d8 <neorv32_uart0_printf+0x150>
 554:	0087ec63          	bltu	a5,s0,56c <neorv32_uart0_printf+0xe4>
 558:	0b340863          	beq	s0,s3,608 <neorv32_uart0_printf+0x180>
 55c:	02500513          	li	a0,37
 560:	eb9ff0ef          	jal	ra,418 <neorv32_uart0_putc>
 564:	00040513          	mv	a0,s0
 568:	0800006f          	j	5e8 <neorv32_uart0_printf+0x160>
 56c:	06400793          	li	a5,100
 570:	00f40663          	beq	s0,a5,57c <neorv32_uart0_printf+0xf4>
 574:	06900793          	li	a5,105
 578:	fef412e3          	bne	s0,a5,55c <neorv32_uart0_printf+0xd4>
 57c:	00012783          	lw	a5,0(sp)
 580:	0007a403          	lw	s0,0(a5)
 584:	00478713          	addi	a4,a5,4
 588:	00e12023          	sw	a4,0(sp)
 58c:	00045863          	bgez	s0,59c <neorv32_uart0_printf+0x114>
 590:	02d00513          	li	a0,45
 594:	40800433          	neg	s0,s0
 598:	e81ff0ef          	jal	ra,418 <neorv32_uart0_putc>
 59c:	00410593          	addi	a1,sp,4
 5a0:	00040513          	mv	a0,s0
 5a4:	d0dff0ef          	jal	ra,2b0 <__neorv32_uart_itoa>
 5a8:	00410513          	addi	a0,sp,4
 5ac:	0200006f          	j	5cc <neorv32_uart0_printf+0x144>
 5b0:	05740063          	beq	s0,s7,5f0 <neorv32_uart0_printf+0x168>
 5b4:	05840a63          	beq	s0,s8,608 <neorv32_uart0_printf+0x180>
 5b8:	fb9412e3          	bne	s0,s9,55c <neorv32_uart0_printf+0xd4>
 5bc:	00012783          	lw	a5,0(sp)
 5c0:	0007a503          	lw	a0,0(a5)
 5c4:	00478713          	addi	a4,a5,4
 5c8:	00e12023          	sw	a4,0(sp)
 5cc:	e65ff0ef          	jal	ra,430 <neorv32_uart0_print>
 5d0:	000a0413          	mv	s0,s4
 5d4:	f29ff06f          	j	4fc <neorv32_uart0_printf+0x74>
 5d8:	00012783          	lw	a5,0(sp)
 5dc:	0007c503          	lbu	a0,0(a5)
 5e0:	00478713          	addi	a4,a5,4
 5e4:	00e12023          	sw	a4,0(sp)
 5e8:	e31ff0ef          	jal	ra,418 <neorv32_uart0_putc>
 5ec:	fe5ff06f          	j	5d0 <neorv32_uart0_printf+0x148>
 5f0:	00012783          	lw	a5,0(sp)
 5f4:	00410593          	addi	a1,sp,4
 5f8:	00478713          	addi	a4,a5,4
 5fc:	0007a503          	lw	a0,0(a5)
 600:	00e12023          	sw	a4,0(sp)
 604:	fa1ff06f          	j	5a4 <neorv32_uart0_printf+0x11c>
 608:	00012783          	lw	a5,0(sp)
 60c:	00410593          	addi	a1,sp,4
 610:	0007a503          	lw	a0,0(a5)
 614:	00478713          	addi	a4,a5,4
 618:	00e12023          	sw	a4,0(sp)
 61c:	d99ff0ef          	jal	ra,3b4 <__neorv32_uart_tohex>
 620:	f93414e3          	bne	s0,s3,5a8 <neorv32_uart0_printf+0x120>
 624:	00410513          	addi	a0,sp,4
 628:	dc5ff0ef          	jal	ra,3ec <__neorv32_uart_touppercase.constprop.0>
 62c:	f7dff06f          	j	5a8 <neorv32_uart0_printf+0x120>
 630:	01649663          	bne	s1,s6,63c <neorv32_uart0_printf+0x1b4>
 634:	00d00513          	li	a0,13
 638:	de1ff0ef          	jal	ra,418 <neorv32_uart0_putc>
 63c:	00140a13          	addi	s4,s0,1
 640:	00048513          	mv	a0,s1
 644:	fa5ff06f          	j	5e8 <neorv32_uart0_printf+0x160>

00000648 <neorv32_gpio_port_set>:
 648:	fc000793          	li	a5,-64
 64c:	00a7a423          	sw	a0,8(a5)
 650:	00b7a623          	sw	a1,12(a5)
 654:	00008067          	ret

00000658 <__divsi3>:
 658:	06054063          	bltz	a0,6b8 <__umodsi3+0x10>
 65c:	0605c663          	bltz	a1,6c8 <__umodsi3+0x20>

00000660 <__udivsi3>:
 660:	00058613          	mv	a2,a1
 664:	00050593          	mv	a1,a0
 668:	fff00513          	li	a0,-1
 66c:	02060c63          	beqz	a2,6a4 <__udivsi3+0x44>
 670:	00100693          	li	a3,1
 674:	00b67a63          	bgeu	a2,a1,688 <__udivsi3+0x28>
 678:	00c05863          	blez	a2,688 <__udivsi3+0x28>
 67c:	00161613          	slli	a2,a2,0x1
 680:	00169693          	slli	a3,a3,0x1
 684:	feb66ae3          	bltu	a2,a1,678 <__udivsi3+0x18>
 688:	00000513          	li	a0,0
 68c:	00c5e663          	bltu	a1,a2,698 <__udivsi3+0x38>
 690:	40c585b3          	sub	a1,a1,a2
 694:	00d56533          	or	a0,a0,a3
 698:	0016d693          	srli	a3,a3,0x1
 69c:	00165613          	srli	a2,a2,0x1
 6a0:	fe0696e3          	bnez	a3,68c <__udivsi3+0x2c>
 6a4:	00008067          	ret

000006a8 <__umodsi3>:
 6a8:	00008293          	mv	t0,ra
 6ac:	fb5ff0ef          	jal	ra,660 <__udivsi3>
 6b0:	00058513          	mv	a0,a1
 6b4:	00028067          	jr	t0
 6b8:	40a00533          	neg	a0,a0
 6bc:	00b04863          	bgtz	a1,6cc <__umodsi3+0x24>
 6c0:	40b005b3          	neg	a1,a1
 6c4:	f9dff06f          	j	660 <__udivsi3>
 6c8:	40b005b3          	neg	a1,a1
 6cc:	00008293          	mv	t0,ra
 6d0:	f91ff0ef          	jal	ra,660 <__udivsi3>
 6d4:	40a00533          	neg	a0,a0
 6d8:	00028067          	jr	t0

000006dc <__modsi3>:
 6dc:	00008293          	mv	t0,ra
 6e0:	0005ca63          	bltz	a1,6f4 <__modsi3+0x18>
 6e4:	00054c63          	bltz	a0,6fc <__modsi3+0x20>
 6e8:	f79ff0ef          	jal	ra,660 <__udivsi3>
 6ec:	00058513          	mv	a0,a1
 6f0:	00028067          	jr	t0
 6f4:	40b005b3          	neg	a1,a1
 6f8:	fe0558e3          	bgez	a0,6e8 <__modsi3+0xc>
 6fc:	40a00533          	neg	a0,a0
 700:	f61ff0ef          	jal	ra,660 <__udivsi3>
 704:	40b00533          	neg	a0,a1
 708:	00028067          	jr	t0
