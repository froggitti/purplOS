;******************** (C) COPYRIGHT 2014 STMicroelectronics ********************
;* File Name          : startup_stm32f030xc.s
;* Author             : MCD Application Team
;* Version            : V1.5.0
;* Date               : 05-December-2014
;* Description        : STM32F030CC/STM32F030RC devices vector table for MDK-ARM toolchain.
;*                      This module performs:
;*                      - Set the initial SP
;*                      - Set the initial PC == Reset_Handler
;*                      - Set the vector table entries with the exceptions ISR address
;*                      - Configure the system clock
;*                      - Branches to __main in the C library (which eventually
;*                        calls main()).
;*                      After Reset the CortexM0 processor is in Thread mode,
;*                      priority is Privileged, and the Stack is set to Main.
;* <<< Use Configuration Wizard in Context Menu >>>
;*******************************************************************************
;  @attention
;
;  Licensed under MCD-ST Liberty SW License Agreement V2, (the "License");
;  You may not use this file except in compliance with the License.
;  You may obtain a copy of the License at:
;
;         http://www.st.com/software_license_agreement_liberty_v2
;
;  Unless required by applicable law or agreed to in writing, software
;  distributed under the License is distributed on an "AS IS" BASIS,
;  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;  See the License for the specific language governing permissions and
;  limitations under the License.
;
;*******************************************************************************
;
; Amount of memory (in bytes) allocated for Stack
; Tailor this value to your application needs
; <h> Stack Configuration
;   <o> Stack Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit

Stack_Size      EQU     0x00001800  ; Most of my ram should be stack

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp


; <h> Heap Configuration
;   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Heap_Size       EQU     0

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit

                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset
                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors
                EXPORT  __Vectors_End
                EXPORT  __Vectors_Size

                EXPORT  __HW_REVISION
                EXPORT  __HW_MODEL
                EXPORT  __EIN

__Vectors       DCD     __initial_sp                   ; Top of Stack
                DCD     Reset_Handler                  ; Reset Handler
                DCD     NMI_Handler                    ; NMI Handler
                DCD     HardFault_Handler              ; Hard Fault Handler
__HW_REVISION   DCD     10                             ; Current Hardware Revision
__HW_MODEL      DCD     1                              ; Current Model
__EIN           DCD     0xFFFFFFFF                     ; EIN(0)
                DCD     0xFFFFFFFF                     ; EIN(1)
                DCD     0xFFFFFFFF                     ; EIN(2)
                DCD     0xFFFFFFFF                     ; EIN(3)
                DCD     1                              ; Bootloader Revision
                DCD     SVC_Handler                    ; SVCall Handler
                DCD     0                              ; Reserved
                DCD     0                              ; Reserved
                DCD     PendSV_Handler                 ; PendSV Handler
                DCD     SysTick_Handler                ; SysTick Handler

                ; External Interrupts
                DCD     WWDG_IRQHandler                ; Window Watchdog
                DCD     0                              ; Reserved
                DCD     RTC_IRQHandler                 ; RTC through EXTI Line
                DCD     FLASH_IRQHandler               ; FLASH
                DCD     RCC_IRQHandler                 ; RCC
                DCD     EXTI0_1_IRQHandler             ; EXTI Line 0 and 1
                DCD     EXTI2_3_IRQHandler             ; EXTI Line 2 and 3
                DCD     EXTI4_15_IRQHandler            ; EXTI Line 4 to 15
                DCD     0                              ; Reserved
                DCD     DMA1_Channel1_IRQHandler       ; DMA1 Channel 1
                DCD     DMA1_Channel2_3_IRQHandler     ; DMA1 Channel 2 and Channel 3
                DCD     DMA1_Channel4_5_IRQHandler     ; DMA1 Channel 4 and Channel 5
                DCD     ADC1_IRQHandler                ; ADC1
                DCD     TIM1_BRK_UP_TRG_COM_IRQHandler ; TIM1 Break, Update, Trigger and Commutation
                DCD     TIM1_CC_IRQHandler             ; TIM1 Capture Compare
                DCD     0                              ; Reserved
                DCD     TIM3_IRQHandler                ; TIM3
                DCD     0                              ; Reserved
                DCD     0                              ; Reserved
                DCD     TIM14_IRQHandler               ; TIM14

__Vectors_End

__Vectors_Size  EQU  __Vectors_End - __Vectors

                AREA    |.text|, CODE, READONLY

; Reset handler routine
Reset_Handler    PROC
                 EXPORT  Reset_Handler                 [WEAK]
        IMPORT  __main
        IMPORT  SystemInit

        LDR     R0, =__initial_sp          ; set stack pointer
        MSR     MSP, R0

;;Check if boot space corresponds to test memory

        LDR R0,=0x00000004
        LDR R1, [R0]
        LSRS R1, R1, #24
        LDR R2,=0x1F
        CMP R1, R2

        BNE ApplicationStart

;; SYSCFG clock enable

        LDR R0,=0x40021018
        LDR R1,=0x00000001
        STR R1, [R0]

;; Set CFGR1 register with flash memory remap at address 0

        LDR R0,=0x40010000
        LDR R1,=0x00000000
        STR R1, [R0]
ApplicationStart
        LDR     R0, =SystemInit
        BLX     R0
        LDR     R0, =__main
        CPSIE   I
        BX      R0
        ENDP

        ; Pass execution to the loaded (verified) application
        EXPORT StartApplication
StartApplication
        CPSID I
        MOV SP, R0
        BX  R1

; Dummy Exception Handlers (infinite loops which can be modified)

Default_Handler PROC

                EXPORT  NMI_Handler                    [WEAK]
                EXPORT  HardFault_Handler              [WEAK]
                EXPORT  SVC_Handler                    [WEAK]
                EXPORT  PendSV_Handler                 [WEAK]
                EXPORT  SysTick_Handler                [WEAK]
                EXPORT  WWDG_IRQHandler                [WEAK]
                EXPORT  RTC_IRQHandler                 [WEAK]
                EXPORT  FLASH_IRQHandler               [WEAK]
                EXPORT  RCC_IRQHandler                 [WEAK]
                EXPORT  EXTI0_1_IRQHandler             [WEAK]
                EXPORT  EXTI2_3_IRQHandler             [WEAK]
                EXPORT  EXTI4_15_IRQHandler            [WEAK]
                EXPORT  DMA1_Channel1_IRQHandler       [WEAK]
                EXPORT  DMA1_Channel2_3_IRQHandler     [WEAK]
                EXPORT  DMA1_Channel4_5_IRQHandler     [WEAK]
                EXPORT  ADC1_IRQHandler                [WEAK]
                EXPORT  TIM1_BRK_UP_TRG_COM_IRQHandler [WEAK]
                EXPORT  TIM1_CC_IRQHandler             [WEAK]
                EXPORT  TIM3_IRQHandler                [WEAK]
                EXPORT  TIM14_IRQHandler               [WEAK]


NMI_Handler
HardFault_Handler
SVC_Handler
PendSV_Handler
SysTick_Handler
WWDG_IRQHandler
RTC_IRQHandler
FLASH_IRQHandler
RCC_IRQHandler
EXTI0_1_IRQHandler
EXTI2_3_IRQHandler
EXTI4_15_IRQHandler
DMA1_Channel1_IRQHandler
DMA1_Channel2_3_IRQHandler
DMA1_Channel4_5_IRQHandler
ADC1_IRQHandler
TIM1_BRK_UP_TRG_COM_IRQHandler
TIM1_CC_IRQHandler
TIM3_IRQHandler
TIM14_IRQHandler

                B       .

                ENDP
                ALIGN

                END

;************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE*****
