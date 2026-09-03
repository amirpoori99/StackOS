				GET     config.s           

                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  __main
                EXPORT  OOM_ExceptionHandler 
                IMPORT  UART_INIT
                IMPORT  PRINT_STR
                IMPORT  SHELL_READ_LINE
                IMPORT  ARENA_INIT
                IMPORT  RPN_EVAL
                IMPORT  __Vectors        

__main
                BL      UART_INIT
                BL      ARENA_INIT
                
                LDR     R0, =Boot_Msg
                BL      PRINT_STR

OS_Shell_Loop
                BL      ARENA_INIT         

                LDR     R0, =Prompt_Msg
                BL      PRINT_STR

                LDR     R0, =CMD_Buffer
                MOV     R1, #CMD_MAX_LEN    
                BL      SHELL_READ_LINE

                LDR     R0, =CMD_Buffer
                BL      RPN_EVAL          

                B       OS_Shell_Loop

OOM_ExceptionHandler
                LDR     R0, =__Vectors     
                LDR     SP, [R0]        
                
                BL      ARENA_INIT         
                
                LDR     R0, =Msg_OOM
                BL      PRINT_STR
                
                B       OS_Shell_Loop
				
                AREA    |.data|, DATA, READWRITE, ALIGN=3
CMD_Buffer      SPACE   CMD_BUF_SIZE        

                AREA    |.rodata|, DATA, READONLY, ALIGN=2
Boot_Msg        DCB     "StackOS v1.0 Initialized", ASCII_CR, ASCII_LF, 0
Prompt_Msg      DCB     "StackOS> ", 0

Msg_OOM         DCB     "Error: Out of Memory (OOM)! Arena limit reached.", ASCII_CR, ASCII_LF
                DCB     "Hint: Increase ARENA_SIZE in config.s", ASCII_CR, ASCII_LF, 0
                ALIGN

                END