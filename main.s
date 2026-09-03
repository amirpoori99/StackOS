				AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  __main
                IMPORT  UART_INIT
                IMPORT  UART_SEND

__main
                BL      UART_INIT
                MOV     R0, #'A'
                BL      UART_SEND
Wait_Forever
                B       Wait_Forever

                END