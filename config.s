; --- Memory & Buffer Constraints ---
ARENA_SIZE          EQU     16384
STACK_CAPACITY      EQU     64          
STACK_MEM_SIZE      EQU     STACK_CAPACITY * 4
CMD_MAX_LEN         EQU     255         
CMD_BUF_SIZE        EQU     256         

; --- Hardware Peripheral Addresses ---
RCC_APB2ENR         EQU     0x40021018
GPIOA_CRH           EQU     0x40010804
USART1_BASE         EQU     0x40013800

; --- USART Register Offsets ---
USART_SR            EQU     0x00
USART_DR            EQU     0x04
USART_BRR           EQU     0x08
USART_CR1           EQU     0x0C

; --- Hardware Configuration Values ---
RCC_EN_VAL          EQU     0x00004005  
GPIOA_CFG_VAL       EQU     0x444444B4  
USART_BAUD_VAL      EQU     0x0341      
USART_CTRL_VAL      EQU     0x0000200C  

; --- ASCII & Control Codes ---
ASCII_BACKSPACE     EQU     0x08
ASCII_CR            EQU     0x0D        
ASCII_LF            EQU     0x0A        
ASCII_ESC           EQU     0x1B        
ASCII_SPACE         EQU     0x20
ASCII_MAX_PRINT     EQU     0x7E        

                    END