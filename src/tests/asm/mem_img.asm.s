.text
__reset:
li	ra,1
li	gp,2
li	tp,3
li	t0,4
li	t1,5
li	t2,6
li	s0,7
li	s1,8
li	a0,9
li	a1,10
li	a2,11
li	a3,12
li	a4,13
li	a5,14
li	a6,15
li	a7,16
li	s2,17
li	s3,18
li	s4,19
li	s5,20
li	s6,21
li	s7,22
li	s8,23
li	s9,24
li	s10,25
li	s11,26
li	t3,27
li	t4,28
li	t5,29
li	t6,30
addi	sp,sp,-32
sw	ra,28(sp)
sw	s0,24(sp)
addi	s0,sp,32
li	a5,1
sw	a5,-20(s0)
sw	zero,-24(s0)
j	c4 <__reset+0xc4>
lw	a5,-20(s0)
addi	a5,a5,1
mv	a1,a5
lw	a0,-20(s0)
auipc	ra,0x0
jalr	ra
mv	a5,a0
sw	a5,-20(s0)
lw	a5,-24(s0)
addi	a5,a5,1
sw	a5,-24(s0)
lw	a4,-24(s0)
li	a5,99
ble	a4,a5,98 <__reset+0x98>
lw	a5,-20(s0)
mv	a0,a5
lw	ra,28(sp)
lw	s0,24(sp)
addi	sp,sp,32
ret
