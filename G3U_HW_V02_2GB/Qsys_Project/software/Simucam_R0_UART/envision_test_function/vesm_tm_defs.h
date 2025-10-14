/*
--------------------------------------------------------------------------------------------------------------
-> Name: vesm_init_structures.c
-> Authors: João P. C. Fogetti, Luiz H. A. Santos, Pedro A. W. Dian, Rodrigo M. Franca, Sergio R. Augusto.
-> Date: 09-10-2025
-> Description: this file implements all the initialization of the data and RTOS objects for the VESM SW.
--------------------------------------------------------------------------------------------------------------
*/

#include "alt_types.h"

#ifndef _VESM_TM_DEFS_
#define _VESM_TM_DEFS_

// Arbitrary definitions for the Codec PUS Configuration when receiving TC packets
#define VESM_TM_CODEC_PUS_SEND_DMA_OFFSET 10
#define VESM_TM_CODEC_PUS_SEND_DMA_SIZE 10
#define VESM_TM_ACK_DEST_SPW_ADDR 10
#define VESM_TM_ACK_DEST_APID 10
#define VESM_TM_APID ((alt_u16) 10)

#endif
