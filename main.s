                GET     config.s

                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  __main
                EXPORT  OOM_ExceptionHandler
                IMPORT  UART_INIT
                IMPORT  PRINT_STR
                IMPORT  SHELL_READ_LINE
                IMPORT  ARENA_INIT
                IMPORT  ARENA_ALLOC
                IMPORT  STR_NORMALIZE
                IMPORT  SIGNED_ADD
                IMPORT  SIGNED_SUB
                IMPORT  SIGNED_MUL
                IMPORT  SIGNED_DIV

__main
                BL      UART_INIT
                BL      ARENA_INIT
                LDR     R0, =Boot_Msg
                BL      PRINT_STR

New_Chain
                BL      ARENA_INIT
                LDR     R0, =Msg_A
                BL      PRINT_STR
                LDR     R0, =CMD_Buffer
                MOV     R1, #CMD_MAX_LEN
                BL      SHELL_READ_LINE
                LDR     R0, =CMD_Buffer
                BL      STR_NORMALIZE
                MOV     R4, R0
                LDRB    R0, [R4]
                CMP     R0, #0
                BEQ     Need_Number_A

Read_Op
                LDR     R0, =Msg_Op
                BL      PRINT_STR
                MOV     R0, #CMD_BUF_SIZE
                BL      ARENA_ALLOC
                MOV     R7, R0
                MOV     R1, #CMD_MAX_LEN
                BL      SHELL_READ_LINE
                LDRB    R5, [R7]
                CMP     R5, #0
                BEQ     New_Chain               
                LDRB    R0, [R7, #1]
                CMP     R0, #0
                BNE     Bad_Op              
                CMP     R5, #'+'
                BEQ     Read_B
                CMP     R5, #'-'
                BEQ     Read_B
                CMP     R5, #'*'
                BEQ     Read_B
                CMP     R5, #'/'
                BEQ     Read_B
Bad_Op
                LDR     R0, =Msg_BadOp
                BL      PRINT_STR
                B       Read_Op

Read_B
                LDR     R0, =Msg_B
                BL      PRINT_STR
                MOV     R0, #CMD_BUF_SIZE
                BL      ARENA_ALLOC
                MOV     R6, R0
                MOV     R1, #CMD_MAX_LEN
                BL      SHELL_READ_LINE
                MOV     R0, R6
                BL      STR_NORMALIZE
                MOV     R6, R0
                LDRB    R0, [R6]
                CMP     R0, #0
                BEQ     Need_Number_B

                CMP     R5, #'/'               
                BNE     Dispatch
                LDRB    R0, [R6]
                CMP     R0, #'0'
                BNE     Dispatch
                LDRB    R0, [R6, #1]
                CMP     R0, #0
                BNE     Dispatch
                LDR     R0, =Msg_DivZero
                BL      PRINT_STR
                B       Read_Op              

Dispatch
                MOV     R0, R4
                MOV     R1, R6
                CMP     R5, #'+'
                BEQ     Do_Add
                CMP     R5, #'-'
                BEQ     Do_Sub
                CMP     R5, #'*'
                BEQ     Do_Mul
Do_Div
                BL      SIGNED_DIV
                B       Show
Do_Mul
                BL      SIGNED_MUL
                B       Show
Do_Sub
                BL      SIGNED_SUB
                B       Show
Do_Add
                BL      SIGNED_ADD
Show
                MOV     R4, R0                
                LDR     R0, =Msg_Eq
                BL      PRINT_STR
                MOV     R0, R4
                BL      PRINT_STR
                LDR     R0, =Newline_Msg
                BL      PRINT_STR
                B       Read_Op

Need_Number_A
                LDR     R0, =Msg_NeedNum
                BL      PRINT_STR
                B       New_Chain
Need_Number_B
                LDR     R0, =Msg_NeedNum
                BL      PRINT_STR
                B       Read_B

OOM_ExceptionHandler
                LDR     R0, =Newline_Msg
                BL      PRINT_STR
                LDR     R0, =Msg_OOM
                BL      PRINT_STR
OOM_Halt
                B       OOM_Halt

                AREA    |.data|, DATA, READWRITE, ALIGN=3
CMD_Buffer      SPACE   CMD_BUF_SIZE

                AREA    |.rodata|, DATA, READONLY, ALIGN=2
Boot_Msg        DCB     "SID: 40232011", ASCII_CR, ASCII_LF
                DCB     "StackOS v1.0 Initialized", ASCII_CR, ASCII_LF, 0
Msg_A           DCB     "A> ", 0
Msg_Op          DCB     "op> ", 0
Msg_B           DCB     "B> ", 0
Msg_Eq          DCB     "= ", 0
Msg_NeedNum     DCB     "Need a number.", ASCII_CR, ASCII_LF, 0
Msg_BadOp       DCB     "Unknown operator.", ASCII_CR, ASCII_LF, 0
Msg_DivZero     DCB     "Error: Division by zero is undefined.", ASCII_CR, ASCII_LF, 0
Newline_Msg     DCB     ASCII_CR, ASCII_LF, 0
Msg_OOM         DCB     "Error: Out of Memory (OOM)! Arena limit reached.", ASCII_CR, ASCII_LF
                DCB     "Hint: Reduce operand size or expression length.", ASCII_CR, ASCII_LF, 0
                ALIGN
                END