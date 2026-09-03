
                AREA    |.text|, CODE, READONLY
                THUMB
                EXPORT  ARENA_INIT
                EXPORT  ARENA_ALLOC

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
                ADD     R3, R3, #2048      

                ADD     R5, R2, R4

                CMP     R5, R3
                BHI     Arena_Overflow

                STR     R5, [R1]

                MOV     R0, R2

                POP     {R4, R5, PC}

Arena_Overflow
                MOV     R0, #0             
                POP     {R4, R5, PC}

                AREA    |.data|, DATA, READWRITE
                ALIGN
Arena_Block     SPACE   2048               
Arena_Ptr       SPACE   4                  

                END