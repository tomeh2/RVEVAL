
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
  94:	72400593          	li	a1,1828
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
  e4:	6a800413          	li	s0,1704
  e8:	6a800493          	li	s1,1704

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
 114:	6a800413          	li	s0,1704
 118:	6a800493          	li	s1,1704

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
 1a0:	01212823          	sw	s2,16(sp)
 1a4:	00812c23          	sw	s0,24(sp)
 1a8:	00912a23          	sw	s1,20(sp)
 1ac:	01312623          	sw	s3,12(sp)
 1b0:	01412423          	sw	s4,8(sp)
 1b4:	430000ef          	jal	ra,5e4 <neorv32_gpio_port_set>
 1b8:	6a800513          	li	a0,1704
 1bc:	210000ef          	jal	ra,3cc <neorv32_uart0_print>
 1c0:	6c400513          	li	a0,1732
 1c4:	208000ef          	jal	ra,3cc <neorv32_uart0_print>
 1c8:	800006b7          	lui	a3,0x80000
 1cc:	ffff07b7          	lui	a5,0xffff0
 1d0:	0006a703          	lw	a4,0(a3) # 80000000 <__crt0_stack_begin+0xffffe004>
 1d4:	00068913          	mv	s2,a3
 1d8:	10078693          	addi	a3,a5,256 # ffff0100 <__crt0_stack_begin+0x7ffee104>
 1dc:	00f72023          	sw	a5,0(a4)
 1e0:	00178793          	addi	a5,a5,1
 1e4:	00470713          	addi	a4,a4,4
 1e8:	fed79ae3          	bne	a5,a3,1dc <main+0x4c>
 1ec:	6d800513          	li	a0,1752
 1f0:	1dc000ef          	jal	ra,3cc <neorv32_uart0_print>
 1f4:	6e000513          	li	a0,1760
 1f8:	1d4000ef          	jal	ra,3cc <neorv32_uart0_print>
 1fc:	00000493          	li	s1,0
 200:	40000993          	li	s3,1024
 204:	00092583          	lw	a1,0(s2)
 208:	6f800513          	li	a0,1784
 20c:	009585b3          	add	a1,a1,s1
 210:	0005a603          	lw	a2,0(a1)
 214:	00448493          	addi	s1,s1,4
 218:	20c000ef          	jal	ra,424 <neorv32_uart0_printf>
 21c:	ff3494e3          	bne	s1,s3,204 <main+0x74>
 220:	6d800513          	li	a0,1752
 224:	1a8000ef          	jal	ra,3cc <neorv32_uart0_print>
 228:	01c12083          	lw	ra,28(sp)
 22c:	01812403          	lw	s0,24(sp)
 230:	01412483          	lw	s1,20(sp)
 234:	01012903          	lw	s2,16(sp)
 238:	00c12983          	lw	s3,12(sp)
 23c:	00812a03          	lw	s4,8(sp)
 240:	00000513          	li	a0,0
 244:	02010113          	addi	sp,sp,32
 248:	00008067          	ret

0000024c <__neorv32_uart_itoa>:
 24c:	fd010113          	addi	sp,sp,-48
 250:	02812423          	sw	s0,40(sp)
 254:	02912223          	sw	s1,36(sp)
 258:	03212023          	sw	s2,32(sp)
 25c:	01312e23          	sw	s3,28(sp)
 260:	01412c23          	sw	s4,24(sp)
 264:	02112623          	sw	ra,44(sp)
 268:	01512a23          	sw	s5,20(sp)
 26c:	00050493          	mv	s1,a0
 270:	00058413          	mv	s0,a1
 274:	00058523          	sb	zero,10(a1)
 278:	00000993          	li	s3,0
 27c:	00410913          	addi	s2,sp,4
 280:	70400a13          	li	s4,1796
 284:	00a00593          	li	a1,10
 288:	00048513          	mv	a0,s1
 28c:	3b8000ef          	jal	ra,644 <__umodsi3>
 290:	00aa0533          	add	a0,s4,a0
 294:	00054783          	lbu	a5,0(a0)
 298:	01390ab3          	add	s5,s2,s3
 29c:	00048513          	mv	a0,s1
 2a0:	00fa8023          	sb	a5,0(s5)
 2a4:	00a00593          	li	a1,10
 2a8:	354000ef          	jal	ra,5fc <__udivsi3>
 2ac:	00198993          	addi	s3,s3,1
 2b0:	00a00793          	li	a5,10
 2b4:	00050493          	mv	s1,a0
 2b8:	fcf996e3          	bne	s3,a5,284 <__neorv32_uart_itoa+0x38>
 2bc:	00090693          	mv	a3,s2
 2c0:	00900713          	li	a4,9
 2c4:	03000613          	li	a2,48
 2c8:	0096c583          	lbu	a1,9(a3)
 2cc:	00070793          	mv	a5,a4
 2d0:	fff70713          	addi	a4,a4,-1
 2d4:	01071713          	slli	a4,a4,0x10
 2d8:	01075713          	srli	a4,a4,0x10
 2dc:	00c59a63          	bne	a1,a2,2f0 <__neorv32_uart_itoa+0xa4>
 2e0:	000684a3          	sb	zero,9(a3)
 2e4:	fff68693          	addi	a3,a3,-1
 2e8:	fe0710e3          	bnez	a4,2c8 <__neorv32_uart_itoa+0x7c>
 2ec:	00000793          	li	a5,0
 2f0:	00f907b3          	add	a5,s2,a5
 2f4:	00000593          	li	a1,0
 2f8:	0007c703          	lbu	a4,0(a5)
 2fc:	00070c63          	beqz	a4,314 <__neorv32_uart_itoa+0xc8>
 300:	00158693          	addi	a3,a1,1
 304:	00b405b3          	add	a1,s0,a1
 308:	00e58023          	sb	a4,0(a1)
 30c:	01069593          	slli	a1,a3,0x10
 310:	0105d593          	srli	a1,a1,0x10
 314:	fff78713          	addi	a4,a5,-1
 318:	02f91863          	bne	s2,a5,348 <__neorv32_uart_itoa+0xfc>
 31c:	00b40433          	add	s0,s0,a1
 320:	00040023          	sb	zero,0(s0)
 324:	02c12083          	lw	ra,44(sp)
 328:	02812403          	lw	s0,40(sp)
 32c:	02412483          	lw	s1,36(sp)
 330:	02012903          	lw	s2,32(sp)
 334:	01c12983          	lw	s3,28(sp)
 338:	01812a03          	lw	s4,24(sp)
 33c:	01412a83          	lw	s5,20(sp)
 340:	03010113          	addi	sp,sp,48
 344:	00008067          	ret
 348:	00070793          	mv	a5,a4
 34c:	fadff06f          	j	2f8 <__neorv32_uart_itoa+0xac>

00000350 <__neorv32_uart_tohex>:
 350:	00758693          	addi	a3,a1,7
 354:	00000713          	li	a4,0
 358:	71000613          	li	a2,1808
 35c:	02000813          	li	a6,32
 360:	00e557b3          	srl	a5,a0,a4
 364:	00f7f793          	andi	a5,a5,15
 368:	00f607b3          	add	a5,a2,a5
 36c:	0007c783          	lbu	a5,0(a5)
 370:	00470713          	addi	a4,a4,4
 374:	fff68693          	addi	a3,a3,-1
 378:	00f680a3          	sb	a5,1(a3)
 37c:	ff0712e3          	bne	a4,a6,360 <__neorv32_uart_tohex+0x10>
 380:	00058423          	sb	zero,8(a1)
 384:	00008067          	ret

00000388 <__neorv32_uart_touppercase.constprop.0>:
 388:	00b50693          	addi	a3,a0,11
 38c:	01900613          	li	a2,25
 390:	00054783          	lbu	a5,0(a0)
 394:	f9f78713          	addi	a4,a5,-97
 398:	0ff77713          	andi	a4,a4,255
 39c:	00e66663          	bltu	a2,a4,3a8 <__neorv32_uart_touppercase.constprop.0+0x20>
 3a0:	fe078793          	addi	a5,a5,-32
 3a4:	00f50023          	sb	a5,0(a0)
 3a8:	00150513          	addi	a0,a0,1
 3ac:	fed512e3          	bne	a0,a3,390 <__neorv32_uart_touppercase.constprop.0+0x8>
 3b0:	00008067          	ret

000003b4 <neorv32_uart0_putc>:
 3b4:	00040737          	lui	a4,0x40
 3b8:	fa002783          	lw	a5,-96(zero) # ffffffa0 <__crt0_stack_begin+0x7fffdfa4>
 3bc:	00e7f7b3          	and	a5,a5,a4
 3c0:	fe079ce3          	bnez	a5,3b8 <neorv32_uart0_putc+0x4>
 3c4:	faa02223          	sw	a0,-92(zero) # ffffffa4 <__crt0_stack_begin+0x7fffdfa8>
 3c8:	00008067          	ret

000003cc <neorv32_uart0_print>:
 3cc:	ff010113          	addi	sp,sp,-16
 3d0:	00812423          	sw	s0,8(sp)
 3d4:	01212023          	sw	s2,0(sp)
 3d8:	00112623          	sw	ra,12(sp)
 3dc:	00912223          	sw	s1,4(sp)
 3e0:	00050413          	mv	s0,a0
 3e4:	00a00913          	li	s2,10
 3e8:	00044483          	lbu	s1,0(s0)
 3ec:	00140413          	addi	s0,s0,1
 3f0:	00049e63          	bnez	s1,40c <neorv32_uart0_print+0x40>
 3f4:	00c12083          	lw	ra,12(sp)
 3f8:	00812403          	lw	s0,8(sp)
 3fc:	00412483          	lw	s1,4(sp)
 400:	00012903          	lw	s2,0(sp)
 404:	01010113          	addi	sp,sp,16
 408:	00008067          	ret
 40c:	01249663          	bne	s1,s2,418 <neorv32_uart0_print+0x4c>
 410:	00d00513          	li	a0,13
 414:	fa1ff0ef          	jal	ra,3b4 <neorv32_uart0_putc>
 418:	00048513          	mv	a0,s1
 41c:	f99ff0ef          	jal	ra,3b4 <neorv32_uart0_putc>
 420:	fc9ff06f          	j	3e8 <neorv32_uart0_print+0x1c>

00000424 <neorv32_uart0_printf>:
 424:	fa010113          	addi	sp,sp,-96
 428:	04f12a23          	sw	a5,84(sp)
 42c:	04410793          	addi	a5,sp,68
 430:	02812c23          	sw	s0,56(sp)
 434:	03212823          	sw	s2,48(sp)
 438:	03312623          	sw	s3,44(sp)
 43c:	03512223          	sw	s5,36(sp)
 440:	03612023          	sw	s6,32(sp)
 444:	01712e23          	sw	s7,28(sp)
 448:	01812c23          	sw	s8,24(sp)
 44c:	01912a23          	sw	s9,20(sp)
 450:	02112e23          	sw	ra,60(sp)
 454:	02912a23          	sw	s1,52(sp)
 458:	03412423          	sw	s4,40(sp)
 45c:	00050413          	mv	s0,a0
 460:	04b12223          	sw	a1,68(sp)
 464:	04c12423          	sw	a2,72(sp)
 468:	04d12623          	sw	a3,76(sp)
 46c:	04e12823          	sw	a4,80(sp)
 470:	05012c23          	sw	a6,88(sp)
 474:	05112e23          	sw	a7,92(sp)
 478:	00f12023          	sw	a5,0(sp)
 47c:	02500a93          	li	s5,37
 480:	00a00b13          	li	s6,10
 484:	07000913          	li	s2,112
 488:	05800993          	li	s3,88
 48c:	07500b93          	li	s7,117
 490:	07800c13          	li	s8,120
 494:	07300c93          	li	s9,115
 498:	00044483          	lbu	s1,0(s0)
 49c:	02049c63          	bnez	s1,4d4 <neorv32_uart0_printf+0xb0>
 4a0:	03c12083          	lw	ra,60(sp)
 4a4:	03812403          	lw	s0,56(sp)
 4a8:	03412483          	lw	s1,52(sp)
 4ac:	03012903          	lw	s2,48(sp)
 4b0:	02c12983          	lw	s3,44(sp)
 4b4:	02812a03          	lw	s4,40(sp)
 4b8:	02412a83          	lw	s5,36(sp)
 4bc:	02012b03          	lw	s6,32(sp)
 4c0:	01c12b83          	lw	s7,28(sp)
 4c4:	01812c03          	lw	s8,24(sp)
 4c8:	01412c83          	lw	s9,20(sp)
 4cc:	06010113          	addi	sp,sp,96
 4d0:	00008067          	ret
 4d4:	0f549c63          	bne	s1,s5,5cc <neorv32_uart0_printf+0x1a8>
 4d8:	00240a13          	addi	s4,s0,2
 4dc:	00144403          	lbu	s0,1(s0)
 4e0:	0d240263          	beq	s0,s2,5a4 <neorv32_uart0_printf+0x180>
 4e4:	06896463          	bltu	s2,s0,54c <neorv32_uart0_printf+0x128>
 4e8:	06300793          	li	a5,99
 4ec:	08f40463          	beq	s0,a5,574 <neorv32_uart0_printf+0x150>
 4f0:	0087ec63          	bltu	a5,s0,508 <neorv32_uart0_printf+0xe4>
 4f4:	0b340863          	beq	s0,s3,5a4 <neorv32_uart0_printf+0x180>
 4f8:	02500513          	li	a0,37
 4fc:	eb9ff0ef          	jal	ra,3b4 <neorv32_uart0_putc>
 500:	00040513          	mv	a0,s0
 504:	0800006f          	j	584 <neorv32_uart0_printf+0x160>
 508:	06400793          	li	a5,100
 50c:	00f40663          	beq	s0,a5,518 <neorv32_uart0_printf+0xf4>
 510:	06900793          	li	a5,105
 514:	fef412e3          	bne	s0,a5,4f8 <neorv32_uart0_printf+0xd4>
 518:	00012783          	lw	a5,0(sp)
 51c:	0007a403          	lw	s0,0(a5)
 520:	00478713          	addi	a4,a5,4
 524:	00e12023          	sw	a4,0(sp)
 528:	00045863          	bgez	s0,538 <neorv32_uart0_printf+0x114>
 52c:	02d00513          	li	a0,45
 530:	40800433          	neg	s0,s0
 534:	e81ff0ef          	jal	ra,3b4 <neorv32_uart0_putc>
 538:	00410593          	addi	a1,sp,4
 53c:	00040513          	mv	a0,s0
 540:	d0dff0ef          	jal	ra,24c <__neorv32_uart_itoa>
 544:	00410513          	addi	a0,sp,4
 548:	0200006f          	j	568 <neorv32_uart0_printf+0x144>
 54c:	05740063          	beq	s0,s7,58c <neorv32_uart0_printf+0x168>
 550:	05840a63          	beq	s0,s8,5a4 <neorv32_uart0_printf+0x180>
 554:	fb9412e3          	bne	s0,s9,4f8 <neorv32_uart0_printf+0xd4>
 558:	00012783          	lw	a5,0(sp)
 55c:	0007a503          	lw	a0,0(a5)
 560:	00478713          	addi	a4,a5,4
 564:	00e12023          	sw	a4,0(sp)
 568:	e65ff0ef          	jal	ra,3cc <neorv32_uart0_print>
 56c:	000a0413          	mv	s0,s4
 570:	f29ff06f          	j	498 <neorv32_uart0_printf+0x74>
 574:	00012783          	lw	a5,0(sp)
 578:	0007c503          	lbu	a0,0(a5)
 57c:	00478713          	addi	a4,a5,4
 580:	00e12023          	sw	a4,0(sp)
 584:	e31ff0ef          	jal	ra,3b4 <neorv32_uart0_putc>
 588:	fe5ff06f          	j	56c <neorv32_uart0_printf+0x148>
 58c:	00012783          	lw	a5,0(sp)
 590:	00410593          	addi	a1,sp,4
 594:	00478713          	addi	a4,a5,4
 598:	0007a503          	lw	a0,0(a5)
 59c:	00e12023          	sw	a4,0(sp)
 5a0:	fa1ff06f          	j	540 <neorv32_uart0_printf+0x11c>
 5a4:	00012783          	lw	a5,0(sp)
 5a8:	00410593          	addi	a1,sp,4
 5ac:	0007a503          	lw	a0,0(a5)
 5b0:	00478713          	addi	a4,a5,4
 5b4:	00e12023          	sw	a4,0(sp)
 5b8:	d99ff0ef          	jal	ra,350 <__neorv32_uart_tohex>
 5bc:	f93414e3          	bne	s0,s3,544 <neorv32_uart0_printf+0x120>
 5c0:	00410513          	addi	a0,sp,4
 5c4:	dc5ff0ef          	jal	ra,388 <__neorv32_uart_touppercase.constprop.0>
 5c8:	f7dff06f          	j	544 <neorv32_uart0_printf+0x120>
 5cc:	01649663          	bne	s1,s6,5d8 <neorv32_uart0_printf+0x1b4>
 5d0:	00d00513          	li	a0,13
 5d4:	de1ff0ef          	jal	ra,3b4 <neorv32_uart0_putc>
 5d8:	00140a13          	addi	s4,s0,1
 5dc:	00048513          	mv	a0,s1
 5e0:	fa5ff06f          	j	584 <neorv32_uart0_printf+0x160>

000005e4 <neorv32_gpio_port_set>:
 5e4:	fc000793          	li	a5,-64
 5e8:	00a7a423          	sw	a0,8(a5)
 5ec:	00b7a623          	sw	a1,12(a5)
 5f0:	00008067          	ret

000005f4 <__divsi3>:
 5f4:	06054063          	bltz	a0,654 <__umodsi3+0x10>
 5f8:	0605c663          	bltz	a1,664 <__umodsi3+0x20>

000005fc <__udivsi3>:
 5fc:	00058613          	mv	a2,a1
 600:	00050593          	mv	a1,a0
 604:	fff00513          	li	a0,-1
 608:	02060c63          	beqz	a2,640 <__udivsi3+0x44>
 60c:	00100693          	li	a3,1
 610:	00b67a63          	bgeu	a2,a1,624 <__udivsi3+0x28>
 614:	00c05863          	blez	a2,624 <__udivsi3+0x28>
 618:	00161613          	slli	a2,a2,0x1
 61c:	00169693          	slli	a3,a3,0x1
 620:	feb66ae3          	bltu	a2,a1,614 <__udivsi3+0x18>
 624:	00000513          	li	a0,0
 628:	00c5e663          	bltu	a1,a2,634 <__udivsi3+0x38>
 62c:	40c585b3          	sub	a1,a1,a2
 630:	00d56533          	or	a0,a0,a3
 634:	0016d693          	srli	a3,a3,0x1
 638:	00165613          	srli	a2,a2,0x1
 63c:	fe0696e3          	bnez	a3,628 <__udivsi3+0x2c>
 640:	00008067          	ret

00000644 <__umodsi3>:
 644:	00008293          	mv	t0,ra
 648:	fb5ff0ef          	jal	ra,5fc <__udivsi3>
 64c:	00058513          	mv	a0,a1
 650:	00028067          	jr	t0
 654:	40a00533          	neg	a0,a0
 658:	00b04863          	bgtz	a1,668 <__umodsi3+0x24>
 65c:	40b005b3          	neg	a1,a1
 660:	f9dff06f          	j	5fc <__udivsi3>
 664:	40b005b3          	neg	a1,a1
 668:	00008293          	mv	t0,ra
 66c:	f91ff0ef          	jal	ra,5fc <__udivsi3>
 670:	40a00533          	neg	a0,a0
 674:	00028067          	jr	t0

00000678 <__modsi3>:
 678:	00008293          	mv	t0,ra
 67c:	0005ca63          	bltz	a1,690 <__modsi3+0x18>
 680:	00054c63          	bltz	a0,698 <__modsi3+0x20>
 684:	f79ff0ef          	jal	ra,5fc <__udivsi3>
 688:	00058513          	mv	a0,a1
 68c:	00028067          	jr	t0
 690:	40b005b3          	neg	a1,a1
 694:	fe0558e3          	bgez	a0,684 <__modsi3+0xc>
 698:	40a00533          	neg	a0,a0
 69c:	f61ff0ef          	jal	ra,5fc <__udivsi3>
 6a0:	40b00533          	neg	a0,a1
 6a4:	00028067          	jr	t0
