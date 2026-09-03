
                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  __main
                IMPORT  UART_INIT
                IMPORT  PRINT_STR
                IMPORT  SHELL_READ_LINE
                IMPORT  ARENA_INIT
                IMPORT  RPN_EVAL

__main
                BL      UART_INIT
                BL      ARENA_INIT
                
                LDR     R0, =Boot_Msg
                BL      PRINT_STR

                LDR     R0, =Equation_Test
                LDR     R1, =CMD_Buffer
Copy_Loop
                LDRB    R2, [R0]
                STRB    R2, [R1]
                ADD     R0, R0, #1
                ADD     R1, R1, #1
                CMP     R2, #0
                BNE     Copy_Loop

                LDR     R0, =CMD_Buffer
                BL      RPN_EVAL         

OS_Shell_Loop
                BL      ARENA_INIT         

                LDR     R0, =Prompt_Msg
                BL      PRINT_STR

                LDR     R0, =CMD_Buffer
                MOV     R1, #64
                BL      SHELL_READ_LINE

                LDR     R0, =CMD_Buffer
                BL      RPN_EVAL          

                B       OS_Shell_Loop

                AREA    |.data|, DATA, READWRITE, ALIGN=3
CMD_Buffer      SPACE   64

                AREA    |.rodata|, DATA, READONLY, ALIGN=2
Equation_Test   DCB     "10 20 + 5 *", 0
Boot_Msg        DCB     "StackOS v1.0 Initialized", 0x0D, 0x0A, 0
Prompt_Msg      DCB     "StackOS> ", 0
                ALIGN

                END