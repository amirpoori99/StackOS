				GET     config.s           

                MACRO
$label          SEND_CHAR $char
$label
                MOV     R0, #$char
                BL      UART_SEND
                MEND

                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  UART_INIT
                EXPORT  UART_SEND
                EXPORT  UART_RECEIVE
                EXPORT  PRINT_STR
                EXPORT  SHELL_READ_LINE

UART_INIT
                PUSH    {R1, R2, LR}
                LDR     R1, =RCC_APB2ENR
                LDR     R2, =RCC_EN_VAL    
                STR     R2, [R1]
                
                LDR     R1, =GPIOA_CRH
                LDR     R2, =GPIOA_CFG_VAL 
                STR     R2, [R1]
                
                LDR     R1, =USART1_BASE
                LDR     R2, =USART_BAUD_VAL
                STR     R2, [R1, #USART_BRR] 
                
                LDR     R2, =USART_CTRL_VAL
                STR     R2, [R1, #USART_CR1] 
                POP     {R1, R2, PC}

UART_SEND
                LDR     R1, =USART1_BASE
Tx_Wait
                LDR     R2, [R1, #USART_SR] 
                TST     R2, #0x80
                BEQ     Tx_Wait
                STRH    R0, [R1, #USART_DR] 
                BX      LR

UART_RECEIVE
                LDR     R1, =USART1_BASE
Rx_Wait
                LDR     R2, [R1, #USART_SR] 
                TST     R2, #0x20
                BEQ     Rx_Wait
                LDRH    R0, [R1, #USART_DR]  
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

                CMP     R0, #ASCII_ESC     
                BEQ     Eat_Escape         
                CMP     R0, #ASCII_CR      
                BEQ     End_Read_Line
                CMP     R0, #ASCII_BACKSPACE 
                BEQ     Handle_Backspace
                CMP     R0, #ASCII_SPACE   
                BLT     Read_Loop          
                CMP     R0, #ASCII_MAX_PRINT 
                BGT     Read_Loop          
                CMP     R5, #1             
                BLE     Read_Loop
                
                STRB    R0, [R4]
                BL      UART_SEND
                ADD     R4, R4, #1
                SUB     R5, R5, #1
                B       Read_Loop

Eat_Escape
                BL      UART_RECEIVE       
                BL      UART_RECEIVE       
                B       Read_Loop

Handle_Backspace
                CMP     R4, R6
                BEQ     Read_Loop
                SUB     R4, R4, #1
                ADD     R5, R5, #1
                SEND_CHAR ASCII_BACKSPACE  
                SEND_CHAR ASCII_SPACE
                SEND_CHAR ASCII_BACKSPACE
                B       Read_Loop

End_Read_Line
                MOV     R0, #0
                STRB    R0, [R4]
                SEND_CHAR ASCII_CR         
                SEND_CHAR ASCII_LF
                POP     {R4, R5, R6, PC}

                END