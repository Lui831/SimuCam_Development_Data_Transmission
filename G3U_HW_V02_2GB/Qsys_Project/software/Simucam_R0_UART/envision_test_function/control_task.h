/*
--------------------------------------------------------------------------------------------------------------
-> Name: control_task.h
-> Authors: João P. C. Fogetti, Luiz H. A. Santos, Pedro A. W. Dian, Rodrigo M. Franca, Sergio R. Augusto.
-> Date: 09-10-2025
-> Description: this file implements all the initialization of the data and RTOS objects for the VESM SW.
--------------------------------------------------------------------------------------------------------------
*/

// Includes Libraries
#include <stdio.h>
#include "alt_types.h"
#include "system.h"
#include "sys/alt_irq.h"



//Defines
#define U32_MAILBOX_OFFSET 0x0000
#define MAILBOX_STATUS_FULL_TRUE 0x01
#define MAILBOX_STATUS_FULL_FALSE 0x00
#define MAILBOX_STATUS_EMPTY_TRUE 0x01
#define MAILBOX_STATUS_EMPTY_FALSE 0x00
#define MAILBOX_IRQ_ID

// Functions 
void control_in_recv_ISR(void* pContext)





