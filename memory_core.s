				GET     config.s

                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  ARENA_INIT
                EXPORT  ARENA_ALLOC
                EXPORT  MATH_INIT
                EXPORT  MATH_PUSH
                EXPORT  MATH_POP
                IMPORT  OOM_ExceptionHandler 

ARENA_INIT
                LDR     R0, =Arena_Block
                LDR     R1, =Arena_Ptr
                STR     R0, [R1]
                BX      LR

ARENA_ALLOC
                PUSH    {R4, R5, LR}
                MOV     R4, R0             
                LDR     R1, =Arena_Ptr
                LDR     R2, [R1]           
                LDR     R3, =Arena_Block
                ADD     R3, R3, #ARENA_SIZE  
                ADD     R5, R2, R4
                CMP     R5, R3
                BHI     Arena_Overflow
                STR     R5, [R1]
                MOV     R0, R2
                POP     {R4, R5, PC}

Arena_Overflow
                B       OOM_ExceptionHandler 

MATH_INIT
                LDR     R1, =Stack_Count
                MOV     R0, #0
                STRB    R0, [R1]
                BX      LR

MATH_PUSH
                PUSH    {R4-R6, LR}        
                LDR     R1, =Stack_Count
                LDRB    R2, [R1]           
                CMP     R2, #STACK_CAPACITY  
                BEQ     Push_Overflow
                LDR     R3, =Math_Stack
                LSL     R4, R2, #2         
                STR     R0, [R3, R4]       
                ADD     R2, R2, #1         
                STRB    R2, [R1]           
                MOV     R0, #1             
                POP     {R4-R6, PC}

Push_Overflow
                LDR     R0, =0xFFFFFFFF    
                POP     {R4-R6, PC}

MATH_POP
                PUSH    {R4-R6, LR}        
                LDR     R1, =Stack_Count
                LDRB    R2, [R1]
                CMP     R2, #0             
                BEQ     Pop_Underflow
                SUB     R2, R2, #1         
                STRB    R2, [R1]           
                LDR     R3, =Math_Stack
                LSL     R4, R2, #2         
                LDR     R0, [R3, R4]       
                POP     {R4-R6, PC}

Pop_Underflow
                LDR     R0, =0xFFFFFFFF    
                POP     {R4-R6, PC}

                AREA    |.data|, DATA, READWRITE
                ALIGN
Arena_Block     SPACE   ARENA_SIZE         
Arena_Ptr       SPACE   4                  
Math_Stack      SPACE   STACK_MEM_SIZE     
Stack_Count     SPACE   1                  
                ALIGN

                END