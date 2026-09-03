
				AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  __main
                IMPORT  UART_INIT
                IMPORT  PRINT_STR
                IMPORT  SHELL_READ_LINE
                IMPORT  ARENA_INIT
                IMPORT  ARENA_ALLOC

__main
                BL      UART_INIT
                BL      ARENA_INIT

                ; --- ??? ??? ????? ????? ---
                MOV     R0, #10
                BL      ARENA_ALLOC
                ; ?? ????? R0 ?? ?? ?????? ????? ???? (????? ???)

                MOV     R0, #30
                BL      ARENA_ALLOC
                ; ?? ????? R0 ?? ????? ???? (???? 0x0A ????? ?? ????? ??? ????)

                ; ---------------------------

                LDR     R0, =Boot_Msg
                BL      PRINT_STR

OS_Shell_Loop
                LDR     R0, =Prompt_Msg
                BL      PRINT_STR

                LDR     R0, =CMD_Buffer
                MOV     R1, #64
                BL      SHELL_READ_LINE

                LDR     R0, =Echo_Msg
                BL      PRINT_STR
                LDR     R0, =CMD_Buffer
                BL      PRINT_STR
                LDR     R0, =Newline_Msg
                BL      PRINT_STR

                B       OS_Shell_Loop

                AREA    |.data|, DATA, READWRITE, ALIGN=3
CMD_Buffer      SPACE   64

                AREA    |.rodata|, DATA, READONLY, ALIGN=2
Boot_Msg        DCB     "StackOS v1.0 Initialized", 0x0D, 0x0A, 0
Prompt_Msg      DCB     "StackOS> ", 0
Echo_Msg        DCB     "Command: ", 0
Newline_Msg     DCB     0x0D, 0x0A, 0
                ALIGN

                END