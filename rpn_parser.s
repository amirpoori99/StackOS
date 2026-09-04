
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

                MACRO
$label          POP_AND_CHECK $reg
$label
                BL      MATH_POP
                CMN     R0, #1
                BEQ.W   Syntax_Error_Handler
                MOV     $reg, R0
                MEND
		
                MACRO
$label          PUSH_AND_CHECK
$label
                BL      MATH_PUSH
                CMN     R0, #1
                BEQ.W   Stack_Overflow_Handler
                MEND
				
RPN_EVAL
                PUSH    {R4-R11, LR}
                MOV     R4, R0             
                BL      MATH_INIT          

Tokenize_Loop
Skip_Spaces
                LDRB    R5, [R4]
                CMP     R5, #0
                BEQ.W   RPN_Finished       
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
                MOV     R8, R6
                LDRB    R9, [R8]
                CMP     R9, #'-'          
                BEQ     Skip_Sign
                CMP     R9, #'+'          
                BEQ     Skip_Sign
                B       Check_Digits
Skip_Sign
                ADD     R8, R8, #1     
Check_Digits
                LDRB    R9, [R8]
                CMP     R9, #0            
                BEQ     Validation_Done
                CMP     R9, #'0'
                BLT.W   Syntax_Error_Handler 
                CMP     R9, #'9'
                BGT.W   Syntax_Error_Handler 
                ADD     R8, R8, #1
                B       Check_Digits
Validation_Done
                MOV     R0, R6
                BL      STR_NORMALIZE      
				PUSH_AND_CHECK
                B       Tokenize_Loop    

Op_Add
                POP_AND_CHECK R8       
                POP_AND_CHECK R9
                MOV     R0, R9
                MOV     R1, R8
                BL      SIGNED_ADD
				PUSH_AND_CHECK
                B       Tokenize_Loop

Op_Sub
                POP_AND_CHECK R8
                POP_AND_CHECK R9
                MOV     R0, R9
                MOV     R1, R8
                BL      SIGNED_SUB
				PUSH_AND_CHECK
                B       Tokenize_Loop

Op_Mul
                POP_AND_CHECK R8
                POP_AND_CHECK R9
                MOV     R0, R9
                MOV     R1, R8
                BL      SIGNED_MUL
				PUSH_AND_CHECK
                B       Tokenize_Loop

Op_Div
                POP_AND_CHECK R8
                POP_AND_CHECK R9
                LDRB    R2, [R8]
                CMP     R2, #'0'
                BNE     Safe_To_Divide
                LDRB    R3, [R8, #1]
                CMP     R3, #0
                BEQ.W   Math_Error_Handler 
Safe_To_Divide
                MOV     R0, R9
                MOV     R1, R8
                BL      SIGNED_DIV
				PUSH_AND_CHECK
                B       Tokenize_Loop

Syntax_Error_Handler
                LDR     R0, =Msg_SyntaxErr
                BL      PRINT_STR
                B       System_Recovery

Math_Error_Handler
                LDR     R0, =Msg_MathErr
                BL      PRINT_STR
                B       System_Recovery

Stack_Overflow_Handler
                LDR     R0, =Msg_StackOvf
                BL      PRINT_STR
                B       System_Recovery
				
System_Recovery
                BL      MATH_INIT          
                POP     {R4-R11, PC}       

RPN_Finished
                BL      MATH_POP
                CMN     R0, #1
                BEQ     Empty_Line           
                MOV     R5, R0
                BL      MATH_POP
                CMN     R0, #1
                BNE.W   Syntax_Error_Handler  

                MOV     R0, R5
                BL      PRINT_STR
                LDR     R0, =Newline_RPN
                BL      PRINT_STR
Empty_Line
                POP     {R4-R11, PC}

                AREA    |.rodata|, DATA, READONLY, ALIGN=2
Newline_RPN     DCB     0x0D, 0x0A, 0
Msg_SyntaxErr   DCB     "Error: Invalid syntax.", 0x0D, 0x0A, 0
Msg_MathErr     DCB     "Error: Division by zero is undefined.", 0x0D, 0x0A, 0
Msg_StackOvf    DCB     "Error: Stack overflow.", 0x0D, 0x0A, 0
				ALIGN
                END