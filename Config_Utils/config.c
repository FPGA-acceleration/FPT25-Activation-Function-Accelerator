#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

#define DMA_RANGE 0x10000
// Increased range to 0x20000 to cover const_addr (0xA4030000) and const_mode_addr (0xA4030004)
#define STWICH_RANGE 0x20000 
#define dma_addr_0 0xA4000000
#define dma_addr_1 0xA4010000
#define matrix_switch_addr 0xA4020000
#define const_addr 0xA4030000
#define const_mode_addr 0xA4030004

#define MM2S_CR   0x00
#define MM2S_SR   0x04
#define MM2S_ADDR 0x18
#define MM2S_LEN  0x28
#define S2MM_CR   0x30
#define S2MM_SR   0x34
#define S2MM_ADDR 0x48
#define S2MM_LEN  0x58


#define MI_CTRL 0X00
#define MI_MUX0 0X40
#define MI_MUX1 0X44
#define MI_MUX2 0X48
#define MI_MUX3 0X4C       
#define MI_MUX4 0X50
#define MI_MUX5 0X54
#define MI_MUX6 0X58
#define MI_MUX7 0X5C
#define MI_MUX8 0X60
#define MI_MUX9 0X64
#define MI_MUX10 0X68
#define MI_MUX11 0X6C
#define MI_MUX12 0X70
#define MI_MUX13 0X74
#define MI_MUX14 0X78
#define MI_MUX15 0X7C


void cfg_elwise_add(uint32_t *base) {
    // M0(Out) <== S10(add/sub)
    base[MI_MUX0/4] = 0xA;

    // M7(add/sub_0) <== S0(In_1)
    base[MI_MUX7/4] = 0x0;

    // M8(add/sub_1) <== S1(In_2)
    base[MI_MUX8/4] = 0x1;

    // Constants Configuration
    // Target: const_addr (0xA4030000)
    // Layout: High 16 bits = Add, Low 16 bits = Mul
    // Add=0x0000, Mul=0x0000 => Packed=0x00000000
    base[(const_addr - matrix_switch_addr)/4] = 0x00000000;
    // Addition Mode: Normal Add
    // Target: const_mode_addr (0xA4030004)
    // Value: 0x0=Add, 0x1=Sub, 0x2=Const Add
    base[(const_mode_addr - matrix_switch_addr)/4] = 0x0;

}

void cfg_elwise_mul(uint32_t *base) {
    // M0(Out) <== S12(mul)
    base[MI_MUX0/4] = 0xC;

    // M10(mul_1) <== S0(In_1)
    base[MI_MUX10/4] = 0x0;

    // M11(mul_2) <== S1(In_2)
    base[MI_MUX11/4] = 0x1;

    // Constants Configuration
    // Target: const_addr (0xA4030000)
    // Layout: High 16 bits = Add, Low 16 bits = Mul
    // Add=0x0000, Mul=0x0000 => Packed=0x00000000
    base[(const_addr - matrix_switch_addr)/4] = 0x00000000;
    // Addition Mode: Normal Add
    // Target: const_mode_addr (0xA4030004)
    // Value: 0x0=Add, 0x1=Sub, 0x2=Const Add
    base[(const_mode_addr - matrix_switch_addr)/4] = 0x0;

}

void cfg_gelu(uint32_t *base) {
    // M0(Out) <== S12(mul)
    base[MI_MUX0/4] = 0xC;

    // M2(AXI_Broad_1) <== S0(In_1)
    base[MI_MUX2/4] = 0x0;

    // M3(exp) <== S13(mul_const)
    base[MI_MUX3/4] = 0xD;

    // M6(reciprocal) <== S10(add/sub)
    base[MI_MUX6/4] = 0xA;

    // M7(add/sub_0) <== S6(exp)
    base[MI_MUX7/4] = 0x6;

    // M10(mul_1) <== S9(reciprocal)
    base[MI_MUX10/4] = 0x9;

    // M11(mul_2) <== S4(fifo128)
    base[MI_MUX11/4] = 0x4;

    // M12(mul_const) <== S5(AXI_Broad_1)
    base[MI_MUX12/4] = 0x5;

    // Constants Configuration
    // Target: const_addr (0xA4030000)
    // Layout: High 16 bits = Add, Low 16 bits = Mul
    // Add=0x3F80, Mul=0xBFDA => Packed=0x3F80BFDA
    base[(const_addr - matrix_switch_addr)/4] = 0x3F80BFDA;
    // Addition Mode: Const Add
    // Target: const_mode_addr (0xA4030004)
    // Value: 0x0=Add, 0x1=Sub, 0x2=Const Add
    base[(const_mode_addr - matrix_switch_addr)/4] = 0x2;

}

void cfg_layernorm(uint32_t *base) {
    // M0(Out) <== S12(mul)
    base[MI_MUX0/4] = 0xC;

    // M1(AXI_Broad_0) <== S0(In_1)
    base[MI_MUX1/4] = 0x0;

    // M2(AXI_Broad_1) <== S10(add/sub)
    base[MI_MUX2/4] = 0xA;

    // M5(acc) <== S3(AXI_Broad_0)
    base[MI_MUX5/4] = 0x3;

    // M7(add/sub_0) <== S2(fifo_64)
    base[MI_MUX7/4] = 0x2;

    // M8(add/sub_1) <== S13(mul_const)
    base[MI_MUX8/4] = 0xD;

    // M9(invsqrt) <== S5(AXI_Broad_1)
    base[MI_MUX9/4] = 0x5;

    // M10(mul_1) <== S11(invsqrt)
    base[MI_MUX10/4] = 0xB;

    // M11(mul_2) <== S4(fifo128)
    base[MI_MUX11/4] = 0x4;

    // M12(mul_const) <== S8(acc)
    base[MI_MUX12/4] = 0x8;

    // Constants Configuration
    // Target: const_addr (0xA4030000)
    // Layout: High 16 bits = Add, Low 16 bits = Mul
    // Add=0x0000, Mul=0x3AAB => Packed=0x00003AAB
    base[(const_addr - matrix_switch_addr)/4] = 0x00003AAB;
    // Addition Mode: Normal Sub
    // Target: const_mode_addr (0xA4030004)
    // Value: 0x0=Add, 0x1=Sub, 0x2=Const Add
    base[(const_mode_addr - matrix_switch_addr)/4] = 0x1;

}

void cfg_rmsnorm(uint32_t *base) {
    // M0(Out) <== S12(mul)
    base[MI_MUX0/4] = 0xC;

    // M2(AXI_Broad_1) <== S0(In_1)
    base[MI_MUX2/4] = 0x0;

    // M9(invsqrt) <== S5(AXI_Broad_1)
    base[MI_MUX9/4] = 0x5;

    // M10(mul_1) <== S4(fifo128)
    base[MI_MUX10/4] = 0x4;

    // M11(mul_2) <== S11(invsqrt)
    base[MI_MUX11/4] = 0xB;

    // Constants Configuration
    // Target: const_addr (0xA4030000)
    // Layout: High 16 bits = Add, Low 16 bits = Mul
    // Add=0x0000, Mul=0x0000 => Packed=0x00000000
    base[(const_addr - matrix_switch_addr)/4] = 0x00000000;
    // Addition Mode: Normal Add
    // Target: const_mode_addr (0xA4030004)
    // Value: 0x0=Add, 0x1=Sub, 0x2=Const Add
    base[(const_mode_addr - matrix_switch_addr)/4] = 0x0;

}

void cfg_silu(uint32_t *base) {
    // M0(Out) <== S12(mul)
    base[MI_MUX0/4] = 0xC;

    // M2(AXI_Broad_1) <== S0(In_1)
    base[MI_MUX2/4] = 0x0;

    // M3(exp) <== S13(mul_const)
    base[MI_MUX3/4] = 0xD;

    // M6(reciprocal) <== S10(add/sub)
    base[MI_MUX6/4] = 0xA;

    // M7(add/sub_0) <== S6(exp)
    base[MI_MUX7/4] = 0x6;

    // M10(mul_1) <== S9(reciprocal)
    base[MI_MUX10/4] = 0x9;

    // M11(mul_2) <== S4(fifo128)
    base[MI_MUX11/4] = 0x4;

    // M12(mul_const) <== S5(AXI_Broad_1)
    base[MI_MUX12/4] = 0x5;

    // Constants Configuration
    // Target: const_addr (0xA4030000)
    // Layout: High 16 bits = Add, Low 16 bits = Mul
    // Add=0x3F80, Mul=0xBF80 => Packed=0x3F80BF80
    base[(const_addr - matrix_switch_addr)/4] = 0x3F80BF80;
    // Addition Mode: Const Add
    // Target: const_mode_addr (0xA4030004)
    // Value: 0x0=Add, 0x1=Sub, 0x2=Const Add
    base[(const_mode_addr - matrix_switch_addr)/4] = 0x2;

}

void cfg_softmax(uint32_t *base) {
    // M0(Out) <== S12(mul)
    base[MI_MUX0/4] = 0xC;

    // M1(AXI_Broad_0) <== S0(In_1)
    base[MI_MUX1/4] = 0x0;

    // M2(AXI_Broad_1) <== S6(exp)
    base[MI_MUX2/4] = 0x6;

    // M3(exp) <== S10(add/sub)
    base[MI_MUX3/4] = 0xA;

    // M4(max) <== S3(AXI_Broad_0)
    base[MI_MUX4/4] = 0x3;

    // M5(acc) <== S5(AXI_Broad_1)
    base[MI_MUX5/4] = 0x5;

    // M6(reciprocal) <== S8(acc)
    base[MI_MUX6/4] = 0x8;

    // M7(add/sub_0) <== S2(fifo_64)
    base[MI_MUX7/4] = 0x2;

    // M8(add/sub_1) <== S7(max)
    base[MI_MUX8/4] = 0x7;

    // M10(mul_1) <== S9(reciprocal)
    base[MI_MUX10/4] = 0x9;

    // M11(mul_2) <== S4(fifo128)
    base[MI_MUX11/4] = 0x4;

    // Constants Configuration
    // Target: const_addr (0xA4030000)
    // Layout: High 16 bits = Add, Low 16 bits = Mul
    // Add=0x0000, Mul=0x0000 => Packed=0x00000000
    base[(const_addr - matrix_switch_addr)/4] = 0x00000000;
    // Addition Mode: Normal Sub
    // Target: const_mode_addr (0xA4030004)
    // Value: 0x0=Add, 0x1=Sub, 0x2=Const Add
    base[(const_mode_addr - matrix_switch_addr)/4] = 0x1;

}


typedef struct {
    const char* name;          // Operation Name
    void (*func)(uint32_t* base);   // Config Function
} MatrixEntry;


MatrixEntry matrix_table[] = {
    {"add",   cfg_elwise_add},
    {"mul",   cfg_elwise_mul},
    {"gelu",   cfg_gelu},
    {"layernorm",   cfg_layernorm},
    {"rmsnorm",   cfg_rmsnorm},
    {"silu",   cfg_silu},
    {"softmax",   cfg_softmax},
    {NULL, NULL}
};


void Matrix_configure(uint32_t *switch_addr, const char* operation_name)
{
    // 1. Disable all MUXs
    switch_addr[MI_MUX0/4] = 0x80000000;  // Disable M0
    switch_addr[MI_MUX1/4] = 0x80000000;  // Disable M1
    switch_addr[MI_MUX2/4] = 0x80000000;  // Disable M2
    switch_addr[MI_MUX3/4] = 0x80000000;  // Disable M3
    switch_addr[MI_MUX4/4] = 0x80000000;  // Disable M4
    switch_addr[MI_MUX5/4] = 0x80000000;  // Disable M5
    switch_addr[MI_MUX6/4] = 0x80000000;  // Disable M6
    switch_addr[MI_MUX7/4] = 0x80000000;  // Disable M7
    switch_addr[MI_MUX8/4] = 0x80000000;  // Disable M8
    switch_addr[MI_MUX9/4] = 0x80000000;  // Disable M9
    switch_addr[MI_MUX10/4] = 0x80000000;  // Disable M10
    switch_addr[MI_MUX11/4] = 0x80000000;  // Disable M11
    switch_addr[MI_MUX12/4] = 0x80000000;  // Disable M12
    switch_addr[MI_MUX13/4] = 0x80000000;  // Disable M13
    switch_addr[MI_MUX14/4] = 0x80000000;  // Disable M14
    switch_addr[MI_MUX15/4] = 0x80000000;  // Disable M15

    // 2. Call routing function
    for(int i=0; i < sizeof(matrix_table)/sizeof(MatrixEntry); i++) {
        if(matrix_table[i].name && strcmp(matrix_table[i].name, operation_name) == 0) {
            if (matrix_table[i].func) {
                matrix_table[i].func(switch_addr);
            }
            break;
        }
    }
    
    // control update
    switch_addr[MI_CTRL/4] = 0x2;
  
}



double dma_transfer_one_input(
    uint32_t input_addr,
    uint32_t output_addr,
    uint32_t length,
    const char* operation_name
){
    int fd;
    volatile uint32_t *dma;
    volatile uint32_t *switch_cfg;
    struct timespec t1, t2;

    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) return -1;

    dma = mmap(NULL, DMA_RANGE, PROT_READ | PROT_WRITE,
               MAP_SHARED, fd, dma_addr_0);
    switch_cfg = mmap(NULL, STWICH_RANGE, PROT_READ | PROT_WRITE,
               MAP_SHARED, fd, matrix_switch_addr);
    if (dma == MAP_FAILED || switch_cfg == MAP_FAILED) return -1;
    Matrix_configure((uint32_t*)switch_cfg, operation_name);
    // Reset
    dma[MM2S_CR/4] = 1 << 2;
    dma[S2MM_CR/4] = 1 << 2;

    // S2MM
    dma[S2MM_CR/4]   = (1<<0) | (1<<12);
    dma[S2MM_ADDR/4] = output_addr;
    dma[S2MM_LEN/4]  = length;

    // MM2S
    dma[MM2S_CR/4]   = 1<<0;
    dma[MM2S_ADDR/4] = input_addr;
    dma[MM2S_LEN/4]  = length;

    clock_gettime(CLOCK_MONOTONIC, &t1);

    while(!(dma[S2MM_SR/4] & (1<<12)));

    clock_gettime(CLOCK_MONOTONIC, &t2);

    close(fd);

    dma[S2MM_SR/4] = 1<<12;
    munmap((void*)dma, DMA_RANGE);
    munmap((void*)switch_cfg, STWICH_RANGE);

    return (t2.tv_sec - t1.tv_sec)*1e9 + (t2.tv_nsec - t1.tv_nsec);
}

double dma_transfer_two_inputs(
    uint32_t input_addr_x,
    uint32_t input_addr_y,
    uint32_t output_addr,
    uint32_t length,
    const char* operation_name
){
    int fd;
    volatile uint32_t *dma0, *dma1;
    volatile uint32_t *switch_cfg;
    struct timespec t1, t2;

    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) return -1;

    dma0 = mmap(NULL, DMA_RANGE, PROT_READ | PROT_WRITE,
                MAP_SHARED, fd, dma_addr_0);
    dma1 = mmap(NULL, DMA_RANGE, PROT_READ | PROT_WRITE,
                MAP_SHARED, fd, dma_addr_1);
    switch_cfg = mmap(NULL, STWICH_RANGE, PROT_READ | PROT_WRITE,
        MAP_SHARED, fd, matrix_switch_addr);
    if (dma0==MAP_FAILED || dma1==MAP_FAILED || switch_cfg==MAP_FAILED) return -1;
    Matrix_configure((uint32_t*)switch_cfg, operation_name);
    

    // Reset
    dma0[MM2S_CR/4] = 1<<2;
    dma0[S2MM_CR/4] = 1<<2;
    dma1[MM2S_CR/4] = 1<<2;

    // S2MM Output
    dma0[S2MM_CR/4]   = (1<<0)|(1<<12);
    dma0[S2MM_ADDR/4] = output_addr;
    dma0[S2MM_LEN/4]  = length;

    // Input X
    dma0[MM2S_CR/4]   = 1<<0;
    dma0[MM2S_ADDR/4] = input_addr_x;
    dma0[MM2S_LEN/4]  = length;

    // Input Y
    dma1[MM2S_CR/4]   = 1<<0;
    dma1[MM2S_ADDR/4] = input_addr_y;
    dma1[MM2S_LEN/4]  = length;

    clock_gettime(CLOCK_MONOTONIC, &t1);

    while (!(dma0[S2MM_SR/4] & (1 << 12)));

    clock_gettime(CLOCK_MONOTONIC, &t2);
    close(fd);

    dma0[S2MM_SR/4] = 1 << 12;
    munmap((void*)dma0, DMA_RANGE);
    munmap((void*)dma1, DMA_RANGE);
    munmap((void*)switch_cfg, STWICH_RANGE);

    return (t2.tv_sec - t1.tv_sec)*1e9 + (t2.tv_nsec - t1.tv_nsec);
}
