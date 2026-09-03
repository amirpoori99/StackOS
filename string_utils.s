
                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  STR_LEN
                EXPORT  STR_CMP
                EXPORT  STR_NORMALIZE

STR_LEN
                PUSH    {R4, LR}
                MOV     R4, #0
Len_Loop
                LDRB    R1, [R0, R4]
                CMP     R1, #0
                BEQ     Len_End
                ADD     R4, R4, #1
                B       Len_Loop
Len_End
                MOV     R0, R4
                POP     {R4, PC}

STR_CMP
                PUSH    {R4, R5, R6, LR}
                MOV     R4, R0
                MOV     R5, R1
Cmp_Loop
                LDRB    R0, [R4], #1       
                LDRB    R1, [R5], #1       
                
                CMP     R0, R1
                BNE     Not_Equal          
                
                CMP     R0, #0
                BEQ     Is_Equal           
                B       Cmp_Loop

Not_Equal
                MOV     R0, #1
                B       Cmp_End
Is_Equal
                MOV     R0, #0
Cmp_End
                POP     {R4, R5, R6, PC}

STR_NORMALIZE
                PUSH    {R4-R7, LR}
                MOV     R4, R0             
                MOV     R5, #0             
                
                LDRB    R6, [R4]
                CMP     R6, #'+'
                BNE     Check_Minus
                ADD     R4, R4, #1         
                B       Skip_Zeros
Check_Minus
                CMP     R6, #'-'
                BNE     Skip_Zeros
                MOV     R5, #1             
                ADD     R4, R4, #1         

Skip_Zeros
                LDRB    R6, [R4]
                CMP     R6, #'0'
                BNE     End_Normalize      
                
                LDRB    R7, [R4, #1]       
                CMP     R7, #0             
                BEQ     Zero_Handler       
                
                ADD     R4, R4, #1         
                B       Skip_Zeros

Zero_Handler
                MOV     R5, #0
                B       Return_Pointer

End_Normalize
                CMP     R5, #1             
                BNE     Return_Pointer
                
                SUB     R4, R4, #1         
                MOV     R6, #'-'
                STRB    R6, [R4]           

Return_Pointer
                MOV     R0, R4             
                POP     {R4-R7, PC}

                END