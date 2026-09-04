				AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   0x400
__initial_sp

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors

__Vectors
                DCD     __initial_sp
                DCD     Reset_Handler
                DCD     NMI_Handler              
                DCD     HardFault_Handler

                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  Reset_Handler
                EXPORT  NMI_Handler                
                EXPORT  HardFault_Handler  
                IMPORT  __main

Reset_Handler
                LDR     R0, =__main
                BX      R0

NMI_Handler   

HardFault_Handler                                 
                B       HardFault_Handler

                END