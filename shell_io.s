				AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  UART_INIT
                EXPORT  UART_SEND
                EXPORT  UART_RECEIVE
                EXPORT  PRINT_STR
                EXPORT  SHELL_READ_LINE

UART_INIT
                PUSH    {R1, R2, LR}
                LDR     R1, =0x40021018
                LDR     R2, =0x00004005
                STR     R2, [R1]
                LDR     R1, =0x40010804
                LDR     R2, =0x444444B4
                STR     R2, [R1]
                LDR     R1, =0x40013800
                LDR     R2, =0x0341
                STR     R2, [R1, #0x08]
                LDR     R2, =0x0000200C
                STR     R2, [R1, #0x0C]
                POP     {R1, R2, PC}

UART_SEND
                LDR     R1, =0x40013800
Tx_Wait
                LDR     R2, [R1, #0x00]
                TST     R2, #0x80
                BEQ     Tx_Wait
                STRH    R0, [R1, #0x04]
                BX      LR

UART_RECEIVE
                LDR     R1, =0x40013800
Rx_Wait
                LDR     R2, [R1, #0x00]
                TST     R2, #0x20
                BEQ     Rx_Wait
                LDRH    R0, [R1, #0x04]
                BX      LR

PRINT_STR
                PUSH    {R4, LR}
                MOV     R4, R0
Print_Loop
                LDRB    R0, [R4]
                CMP     R0, #0
                BEQ     Print_End
                BL      UART_SEND
                ADD     R4, R4, #1
                B       Print_Loop
Print_End
                POP     {R4, PC}

SHELL_READ_LINE
                PUSH    {R4, R5, R6, LR}
                MOV     R4, R0
                MOV     R5, R1
                MOV     R6, R0
Read_Loop
                BL      UART_RECEIVE
                CMP     R0, #0x0D          ; ????? ???? Enter
                BEQ     End_Read_Line
                CMP     R0, #0x08          ; ????? ???? Backspace
                BEQ     Handle_Backspace
                
                CMP     R0, #0x20          ; ????? ?????????? ?????? (Arrow/Tab)
                BLT     Read_Loop          ; ?????? ????? ?????
                
                CMP     R5, #1             ; ????? ????? ????
                BLE     Read_Loop
                
                STRB    R0, [R4]
                BL      UART_SEND
                ADD     R4, R4, #1
                SUB     R5, R5, #1
                B       Read_Loop

Handle_Backspace
                CMP     R4, R6
                BEQ     Read_Loop
                
                SUB     R4, R4, #1
                ADD     R5, R5, #1
                
                MOV     R0, #0x08
                BL      UART_SEND
                MOV     R0, #0x20
                BL      UART_SEND
                MOV     R0, #0x08
                BL      UART_SEND
                B       Read_Loop

End_Read_Line
                MOV     R0, #0
                STRB    R0, [R4]
                MOV     R0, #0x0D
                BL      UART_SEND
                MOV     R0, #0x0A
                BL      UART_SEND
                POP     {R4, R5, R6, PC}

                END