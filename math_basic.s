
                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  ABS_ADD
                IMPORT  STR_LEN
                IMPORT  ARENA_ALLOC

ABS_ADD
                PUSH    {R4-R11, LR}       

                MOV     R4, R0          
                MOV     R5, R1           

                ; ?. ?????? ??????
                MOV     R0, R4
                BL      STR_LEN
                MOV     R6, R0             

                MOV     R0, R5
                BL      STR_LEN
                MOV     R7, R0           

                CMP     R6, R7
                BGE     Max_A
                MOV     R8, R7
                B       Do_Alloc
Max_A
                MOV     R8, R6
Do_Alloc
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
                BNE     Read_A
                CMP     R7, #0
                BEQ     Final_Carry

Read_A
                MOV     R1, #0             
                CMP     R6, #0
                BEQ     Read_B
                SUB     R12, R6, #1       
                LDRB    R1, [R4, R12]      
                SUB     R1, R1, #'0'      
                SUB     R6, R6, #1      

Read_B
                MOV     R2, #0             
                CMP     R7, #0
                BEQ     Calculate
                SUB     R12, R7, #1
                LDRB    R2, [R5, R12]
                SUB     R2, R2, #'0'
                SUB     R7, R7, #1

Calculate
                ; ?. ????? ??? ?????
                ADD     R3, R1, R2         
                ADD     R3, R3, R11      

                CMP     R3, #9
                BLS     No_Carry
                MOV     R11, #1           
                SUB     R3, R3, #10
                B       Store_Res
No_Carry
                MOV     R11, #0           
Store_Res
                ADD     R3, R3, #'0'      
                STRB    R3, [R10]         
                SUB     R10, R10, #1      

                B       Add_Loop

Final_Carry
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

                END