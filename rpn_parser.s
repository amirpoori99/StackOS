				AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  RPN_EVAL

                IMPORT  MATH_INIT
                IMPORT  MATH_PUSH
                IMPORT  MATH_POP
                IMPORT  STR_NORMALIZE
                IMPORT  SIGNED_ADD
                IMPORT  SIGNED_SUB
                IMPORT  SIGNED_MUL
                IMPORT  SIGNED_DIV
                IMPORT  PRINT_STR

RPN_EVAL
                PUSH    {R4-R11, LR}
                MOV     R4, R0             
                BL      MATH_INIT          

Tokenize_Loop
Skip_Spaces
                LDRB    R5, [R4]
                CMP     R5, #0
                BEQ     RPN_Finished       
                CMP     R5, #' '           
                BNE     Start_Token        
                ADD     R4, R4, #1         
                B       Skip_Spaces

Start_Token
                MOV     R6, R4             

Find_Token_End
                LDRB    R5, [R4]
                CMP     R5, #0             
                BEQ     Process_Token
                CMP     R5, #' '           
                BEQ     Cut_Token
                ADD     R4, R4, #1
                B       Find_Token_End

Cut_Token
                MOV     R5, #0
                STRB    R5, [R4]
                ADD     R4, R4, #1         

Process_Token
                LDRB    R5, [R6]
                LDRB    R7, [R6, #1]       

                CMP     R7, #0          
                BNE     Is_Number

                CMP     R5, #'+'
                BEQ     Op_Add
                CMP     R5, #'-'
                BEQ     Op_Sub
                CMP     R5, #'*'
                BEQ     Op_Mul
                CMP     R5, #'/'
                BEQ     Op_Div

Is_Number
                MOV     R0, R6
                BL      STR_NORMALIZE      
                BL      MATH_PUSH
                B       Tokenize_Loop      

Op_Add
                BL      MATH_POP
                MOV     R8, R0          
                BL      MATH_POP
                MOV     R9, R0            
                MOV     R0, R9
                MOV     R1, R8
                BL      SIGNED_ADD
                BL      MATH_PUSH
                B       Tokenize_Loop

Op_Sub
                BL      MATH_POP
                MOV     R8, R0             
                BL      MATH_POP
                MOV     R9, R0             
                MOV     R0, R9
                MOV     R1, R8
                BL      SIGNED_SUB
                BL      MATH_PUSH
                B       Tokenize_Loop

Op_Mul
                BL      MATH_POP
                MOV     R8, R0             
                BL      MATH_POP
                MOV     R9, R0             
                MOV     R0, R9
                MOV     R1, R8
                BL      SIGNED_MUL
                BL      MATH_PUSH
                B       Tokenize_Loop

Op_Div
                BL      MATH_POP
                MOV     R8, R0             
                BL      MATH_POP
                MOV     R9, R0             
                MOV     R0, R9
                MOV     R1, R8
                BL      SIGNED_DIV
                BL      MATH_PUSH
                B       Tokenize_Loop

RPN_Finished
                BL      MATH_POP
                MOV     R5, R0             
                MOV     R0, R5
                BL      PRINT_STR          
                LDR     R0, =Newline_RPN
                BL      PRINT_STR
                POP     {R4-R11, PC}

                AREA    |.rodata|, DATA, READONLY, ALIGN=2
Newline_RPN     DCB     0x0D, 0x0A, 0
Error_Msg       DCB     "Error: Invalid syntax or empty stack.\r\n", 0
                ALIGN
                END