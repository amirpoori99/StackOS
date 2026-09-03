                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  ABS_ADD
                EXPORT  BIG_SUB
                IMPORT  STR_LEN
                IMPORT  ARENA_ALLOC

ABS_ADD
                PUSH    {R4-R11, LR}       

                MOV     R4, R0             
                MOV     R5, R1             

                MOV     R0, R4
                BL      STR_LEN
                MOV     R6, R0             

                MOV     R0, R5
                BL      STR_LEN
                MOV     R7, R0             

                CMP     R6, R7
                BGE     Max_A
                MOV     R8, R7
                B       Do_Alloc_Add
Max_A
                MOV     R8, R6
Do_Alloc_Add
                ADD     R8, R8, #2         

                MOV     R0, R8
                BL      ARENA_ALLOC
                MOV     R9, R0             

                ADD     R10, R9, R8
                SUB     R10, R10, #1       
                MOV     R0, #0
                STRB    R0, [R10]          
                SUB     R10, R10, #1       

                MOV     R11, #0            

Add_Loop
                CMP     R6, #0
                BNE     Read_A_Add
                CMP     R7, #0
                BEQ     Final_Carry_Add

Read_A_Add
                MOV     R1, #0             
                CMP     R6, #0
                BEQ     Read_B_Add
                SUB     R12, R6, #1        
                LDRB    R1, [R4, R12]      
                SUB     R1, R1, #'0'       
                SUB     R6, R6, #1         

Read_B_Add
                MOV     R2, #0             
                CMP     R7, #0
                BEQ     Calculate_Add
                SUB     R12, R7, #1
                LDRB    R2, [R5, R12]
                SUB     R2, R2, #'0'
                SUB     R7, R7, #1

Calculate_Add
                ADD     R3, R1, R2         
                ADD     R3, R3, R11        

                CMP     R3, #9
                BLS     No_Carry_Add
                MOV     R11, #1            
                SUB     R3, R3, #10
                B       Store_Res_Add
No_Carry_Add
                MOV     R11, #0            
Store_Res_Add
                ADD     R3, R3, #'0'       
                STRB    R3, [R10]          
                SUB     R10, R10, #1       

                B       Add_Loop

Final_Carry_Add
                CMP     R11, #1
                BNE     Done_Add
                MOV     R12, #'1'
                STRB    R12, [R10]
                MOV     R0, R10            
                B       Exit_Add
Done_Add
                ADD     R0, R10, #1        
Exit_Add
                POP     {R4-R11, PC}

STR_CMP_MAG
                PUSH    {R4-R7, LR}
                MOV     R4, R0
                MOV     R5, R1

                MOV     R0, R4
                BL      STR_LEN
                MOV     R6, R0             

                MOV     R0, R5
                BL      STR_LEN
                MOV     R7, R0             

                CMP     R6, R7
                BHI     A_Is_Greater
                BLO     B_Is_Greater

                MOV     R0, #0             
Cmp_Mag_Loop
                LDRB    R1, [R4, R0]       
                LDRB    R2, [R5, R0]       
                CMP     R1, R2
                BHI     A_Is_Greater
                BLO     B_Is_Greater

                ADD     R0, R0, #1
                CMP     R0, R6             
                BLT     Cmp_Mag_Loop

                MOV     R0, #0             
                POP     {R4-R7, PC}

A_Is_Greater
                MOV     R0, #1
                POP     {R4-R7, PC}

B_Is_Greater
                MOV     R0, #2
                POP     {R4-R7, PC}

BIG_SUB
                PUSH    {R4-R11, LR}       
                MOV     R4, R0             
                MOV     R5, R1             
                MOV     R11, #0            

                BL      STR_CMP_MAG
                CMP     R0, #0
                BEQ     Result_Is_Zero     

                CMP     R0, #1             
                BEQ     Setup_Sub

                MOV     R6, R4             
                MOV     R4, R5
                MOV     R5, R6
                MOV     R11, #1            

Setup_Sub
                MOV     R0, R4
                BL      STR_LEN
                MOV     R6, R0             

                MOV     R0, R5
                BL      STR_LEN
                MOV     R7, R0             

                MOV     R0, R6
                ADD     R0, R0, #2
                BL      ARENA_ALLOC
                MOV     R9, R0             

                ADD     R10, R9, R6
                MOV     R0, #0
                STRB    R0, [R10]          
                SUB     R10, R10, #1

                MOV     R8, #0             

Sub_Loop
                CMP     R6, #0
                BEQ     Trim_Zeros         

                SUB     R12, R6, #1
                LDRB    R1, [R4, R12]
                SUB     R1, R1, #'0'
                SUB     R6, R6, #1

                MOV     R2, #0
                CMP     R7, #0
                BEQ     Do_Sub
                SUB     R12, R7, #1
                LDRB    R2, [R5, R12]
                SUB     R2, R2, #'0'
                SUB     R7, R7, #1

Do_Sub
                SUB     R3, R1, R2
                SUB     R3, R3, R8

                CMP     R3, #0
                BGE     No_Borrow
                MOV     R8, #1             
                ADD     R3, R3, #10        
                B       Store_Digit
No_Borrow
                MOV     R8, #0             
Store_Digit
                ADD     R3, R3, #'0'       
                STRB    R3, [R10]          
                SUB     R10, R10, #1       

                B       Sub_Loop

Trim_Zeros
                ADD     R10, R10, #1       
Trim_Loop
                LDRB    R0, [R10]
                CMP     R0, #'0'
                BNE     Check_Negative

                LDRB    R1, [R10, #1]      
                CMP     R1, #0
                BEQ     Check_Negative     

                ADD     R10, R10, #1       
                B       Trim_Loop

Check_Negative
                CMP     R11, #1
                BNE     End_Sub
                SUB     R10, R10, #1
                MOV     R0, #'-'
                STRB    R0, [R10]          

End_Sub
                MOV     R0, R10            
                POP     {R4-R11, PC}

Result_Is_Zero
                MOV     R0, #2
                BL      ARENA_ALLOC
                MOV     R1, #'0'
                STRB    R1, [R0]           
                MOV     R1, #0
                STRB    R1, [R0, #1]       
                POP     {R4-R11, PC}

                END