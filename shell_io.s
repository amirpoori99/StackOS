				AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  UART_INIT
                EXPORT  UART_SEND
                EXPORT  UART_RECEIVE

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

                END