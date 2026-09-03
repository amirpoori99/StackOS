
                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  ABS_MUL
                EXPORT  ABS_DIV
                IMPORT  STR_LEN
                IMPORT  ARENA_ALLOC
                IMPORT  STR_CMP_MAG
                IMPORT  BIG_SUB

ABS_MUL
                PUSH    {R4-R12, LR}
                MOV     R4, R0
                MOV     R5, R1

                MOV     R0, R4
                BL      STR_LEN
                MOV     R6, R0

                MOV     R0, R5
                BL      STR_LEN
                MOV     R7, R0

                MOV     R0, R6
                ADD     R0, R0, R7
                MOV     R8, R0
                ADD     R0, R0, #1
                BL      ARENA_ALLOC
                MOV     R9, R0

                MOV     R10, R9
                MOV     R11, R8
                MOV     R12, #'0'

Format_Loop
                STRB    R12, [R10]
                ADD     R10, R10, #1
                SUB     R11, R11, #1
                CMP     R11, #0
                BNE     Format_Loop

                MOV     R12, #0
                STRB    R12, [R10]

                MOV     R10, R7
Outer_Loop
                CMP     R10, #0
                BEQ     Trim_Mul_Zeros
                SUB     R10, R10, #1

                LDRB    R2, [R5, R10]
                SUB     R2, R2, #'0'

                CMP     R2, #0
                BEQ     Outer_Loop

                MOV     R11, R6
                MOV     R12, #0
Inner_Loop
                CMP     R11, #0
                BEQ     Store_Row_Carry
                SUB     R11, R11, #1

                LDRB    R1, [R4, R11]
                SUB     R1, R1, #'0'

                MUL     R3, R1, R2
                ADD     R3, R3, R12

                MOV     R0, R10
                ADD     R0, R0, R11
                ADD     R0, R0, #1

                LDRB    R1, [R9, R0]
                SUB     R1, R1, #'0'
                ADD     R3, R3, R1

                MOV     R1, #10
                UDIV    R12, R3, R1
                MLS     R3, R12, R1, R3

                ADD     R3, R3, #'0'
                STRB    R3, [R9, R0]

                B       Inner_Loop

Store_Row_Carry
                ADD     R12, R12, #'0'
                STRB    R12, [R9, R10]
                B       Outer_Loop

Trim_Mul_Zeros
                MOV     R10, R9
Trim_Loop_Mul
                LDRB    R0, [R10]
                CMP     R0, #'0'
                BNE     End_Mul

                LDRB    R1, [R10, #1]
                CMP     R1, #0
                BEQ     End_Mul

                ADD     R10, R10, #1
                B       Trim_Loop_Mul

End_Mul
                MOV     R0, R10
                POP     {R4-R12, PC}

ABS_DIV
                PUSH    {R4-R12, LR}
                MOV     R4, R0             
                MOV     R5, R1             

                MOV     R0, R4
                MOV     R1, R5
                BL      STR_CMP_MAG
                CMP     R0, #2             
                BNE     Check_Zero_Div
                
                MOV     R0, #2
                BL      ARENA_ALLOC
                MOV     R1, #'0'
                STRB    R1, [R0]
                MOV     R1, #0
                STRB    R1, [R0, #1]
                POP     {R4-R12, PC}

Check_Zero_Div
                MOV     R0, R5
Check_Zero_Loop
                LDRB    R1, [R0], #1
                CMP     R1, #0
                BEQ     Div_By_Zero_Error  
                CMP     R1, #'0'
                BEQ     Check_Zero_Loop    
                
                MOV     R0, R4
                BL      STR_LEN
                MOV     R6, R0             

                MOV     R0, R6
                ADD     R0, R0, #2         
                BL      ARENA_ALLOC
                MOV     R9, R0             
                MOV     R10, R9            

                MOV     R0, R5
                BL      STR_LEN
                MOV     R7, R0             

                MOV     R0, R6
                ADD     R0, R0, R7         
                ADD     R0, R0, #2
                BL      ARENA_ALLOC
                MOV     R8, R0             

                MOV     R0, #0             
Copy_Div_Loop
                LDRB    R1, [R5, R0]
                STRB    R1, [R8, R0]
                ADD     R0, R0, #1
                CMP     R0, R7
                BLT     Copy_Div_Loop

                MOV     R11, R6
                SUB     R11, R11, R7       
                CMP     R11, #0
                BLE     End_Pad_Zero

                MOV     R12, #'0'
Pad_Zero_Loop
                STRB    R12, [R8, R0]
                ADD     R0, R0, #1
                SUB     R11, R11, #1
                CMP     R11, #0
                BGT     Pad_Zero_Loop
End_Pad_Zero
                MOV     R1, #0
                STRB    R1, [R8, R0]       
                MOV     R6, R0          

Div_Sliding_Window_Loop
                CMP     R6, R7
                BLT     End_Div            

                MOV     R11, #0            

Repeated_Sub_Loop
                MOV     R0, R4
                MOV     R1, R8
                BL      STR_CMP_MAG
                CMP     R0, #2             
                BEQ     Save_Quotient_Digit

                MOV     R0, R4
                MOV     R1, R8
                BL      BIG_SUB
                MOV     R4, R0             

                ADD     R11, R11, #1       
                B       Repeated_Sub_Loop

Save_Quotient_Digit
                ADD     R11, R11, #'0'     
                STRB    R11, [R10]         
                ADD     R10, R10, #1       

                SUB     R6, R6, #1
                MOV     R0, #0
                STRB    R0, [R8, R6]      
                B       Div_Sliding_Window_Loop

End_Div
                MOV     R0, #0
                STRB    R0, [R10]

                MOV     R10, R9
Trim_Loop_Div
                LDRB    R0, [R10]
                CMP     R0, #'0'
                BNE     End_Div_Trim

                LDRB    R1, [R10, #1]      
                CMP     R1, #0
                BEQ     End_Div_Trim       

                ADD     R10, R10, #1       
                B       Trim_Loop_Div

End_Div_Trim
                MOV     R0, R10            
                POP     {R4-R12, PC}

Div_By_Zero_Error
                MOV     R0, #2
                BL      ARENA_ALLOC
                MOV     R1, #'E'           
                STRB    R1, [R0]
                MOV     R1, #0
                STRB    R1, [R0, #1]
                POP     {R4-R12, PC}

                END