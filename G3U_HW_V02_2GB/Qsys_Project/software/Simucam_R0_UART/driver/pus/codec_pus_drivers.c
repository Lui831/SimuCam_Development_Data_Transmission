/* ------------------------------------------------------------------------------------ */
// codec_pus_drivers.c
// Description: This file contains all the imlementations of the functions for the
// Codec PUS driver, as defined in codec_pus_drivers.h.
// Authors: Luiz H. A. Santos, Rafaella A. C. Zeron, Pedro A. W. Dian, João P. Fogetti, 
// Rodrigo M. França
// Date: 27/08/2025
/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
// Include libraries

#include <stdio.h>
#include "alt_types.h"
#include "system.h"
#include "sys/alt_irq.h"
#include "../../HAL/inc/io.h"
#include "codec_pus_drivers.h"

/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
// Function implementations

// Function to initialize the Codec PUS and it's DMAs
void codec_pus_init(t_codec_pus *pCodecPUS){

    // Initially resets the Codec PUS
    codec_pus_reset(pCodecPUS);

    // Configures the Codec PUS control register and DMAs registers
    codec_pus_config(pCodecPUS);

}


// Functions to configure and to reset the Codec PUS
void codec_pus_reset(t_codec_pus *pCodecPUS){

    // Writes a 1 and then a 0 to the reset bit of the control register
    CODEC_PUS_REG_SET(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_CNTRL_REG_OFFSET, CODEC_PUS_CNTRL_REG_PROC_RST_MASK);
    CODEC_PUS_REG_RESET(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_CNTRL_REG_OFFSET, CODEC_PUS_CNTRL_REG_PROC_RST_MASK);

}

void codec_pus_config(t_codec_pus *pCodecPUS){

    // Sets the bits of the control register according to the config struct
    alt_u32 tempVal = 0;

    if(pCodecPUS->oCodecPUSConfig.u8CodecPusEn){
        tempVal |= CODEC_PUS_CNTRL_REG_EN_MASK;
    }
    if(pCodecPUS->oCodecPUSConfig.u8CodecPusRecvEn){
        tempVal |= CODEC_PUS_CNTRL_REG_RECV_EN_MASK;
    }
    if(pCodecPUS->oCodecPUSConfig.u8CodecPusSendEn){
        tempVal |= CODEC_PUS_CNTRL_REG_SEND_EN_MASK;
    }
    if(pCodecPUS->oCodecPUSConfig.u8CodecPusIRQEn){
        tempVal |= CODEC_PUS_CNTRL_REG_IRQ_EN_MASK;
    }
    if(pCodecPUS->oCodecPUSConfig.u8CodecPusRecvIRQEn){
        tempVal |= CODEC_PUS_CNTRL_REG_RECV_IRQ_EN_MASK;
    }
    if(pCodecPUS->oCodecPUSConfig.u8CodecPusSendIRQEn){
        tempVal |= CODEC_PUS_CNTRL_REG_SEND_IRQ_EN_MASK;
    }
    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_CNTRL_REG_OFFSET, tempVal);

    // Configures the Recv DMA registers
    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_MEM_OFFSET_MEM_OFFSET_OFFSET, pCodecPUS->oCodecPUSRecvDmaConfig.u32DmaMemBaseAddr);
    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_FIFO_SIZE_FIFO_SIZE_OFFSET, pCodecPUS->oCodecPUSRecvDmaConfig.u32DmaFifoSize);

    // Configures the Send DMA registers
    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_MEM_OFFSET_MEM_OFFSET_MASK, pCodecPUS->oCodecPUSSendDmaConfig.u32DmaMemBaseAddr);
    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_FIFO_SIZE_FIFO_SIZE_OFFSET, pCodecPUS->oCodecPUSSendDmaConfig.u32DmaFifoSize);

    // Configures the available space for the send DMA as the full size of the FIFO
    pCodecPUS->u32CurrentSendDmaAvailableSpace = pCodecPUS->oCodecPUSSendDmaConfig.u32DmaFifoSize;

}


// Funtions to write and to read to and from the Codec PUS DMA FIFOs
void codec_pus_write_send_dma(t_codec_pus *pCodecPUS, alt_u8 *pAppData, alt_u32 u32AppDataLen){

    // Counter for the words written
    alt_u32 u32WrittenWords = 0;

    // Declares the pointer to the current position in the DMA FIFO
    volatile alt_u32* pDMAFIFOPtr = (volatile alt_u32*) (pCodecPUS->oCodecPUSSendDmaConfig.u32DmaMemBaseAddr + pCodecPUS->u32CurrentSendDmaOffset);

    // If the data to be sent is larget than the available space, the function returns without writing anything
    if(u32AppDataLen > pCodecPUS->u32CurrentSendDmaAvailableSpace){
        return;
    }
    // If the data to be sent fits in the available space, writes it to the DMA FIFO
    else{

        // Writes the data to the DMA FIFO, one word at a time
        for(alt_u32 count; count < u32AppDataLen; count += 4){

            // Writes a word to the DMA FIFO. If there are less than 4 bytes remaining, pads with zeros
            alt_u32 tempWord = 0;
            for(alt_u32 byte = 0; byte < 4; byte++){
                if(count + byte < u32AppDataLen){
                    tempWord |= pAppData[count + byte] << ((3 - byte) * 8);
                }
            }

            *pDMAFIFOPtr = tempWord;
 
            pDMAFIFOPtr += 4; // Increments the pointer to the next word in the DMA FIFO

            u32WrittenWords++;

        }
    }

    // Updates the current offset and available space for the send DMA
    pCodecPUS->u32CurrentSendDmaOffset = (pCodecPUS->u32CurrentSendDmaOffset + (u32WrittenWords * 4)) % pCodecPUS->oCodecPUSSendDmaConfig.u32DmaFifoSize;
    pCodecPUS->u32CurrentSendDmaAvailableSpace -= (u32WrittenWords * 4);

}

void codec_pus_read_recv_dma(t_codec_pus *pCodecPUS, alt_u8 *pAppData, alt_u32 u32AppDataLen){

    // Counter for the words read
    alt_u32 u32ReadWords = 0;

    // Declares the pointer to the current position in the DMA FIFO
    volatile alt_u32* pDMAFIFOPtr = (volatile alt_u32*) (pCodecPUS->oCodecPUSRecvDmaConfig.u32DmaMemBaseAddr + pCodecPUS->u32CurrentRecvDmaOffset);

    // Reads the data from the DMA FIFO, one word at a time
    for(alt_u32 count; count < u32AppDataLen; count += 4){

        // Reads a word from the DMA FIFO
        alt_u32 tempWord = *pDMAFIFOPtr;

        // Writes the word to the application data buffer, one byte at a time
        for(alt_u32 byte = 0; byte < 4; byte++){
            if(count + byte < u32AppDataLen){
                pAppData[count + byte] = (tempWord >> ((3 - byte) * 8)) & 0xFF;
            }
        }

        pDMAFIFOPtr += 4; // Increments the pointer to the next word in the DMA FIFO

        u32ReadWords++;

    }

    // Updates the current offset for the recv DMA
    pCodecPUS->u32CurrentRecvDmaOffset = (pCodecPUS->u32CurrentRecvDmaOffset + (u32ReadWords * 4)) % pCodecPUS->oCodecPUSRecvDmaConfig.u32DmaFifoSize;

}


// Functions related to receiving TCs from the Codec PUS
alt_u8 codec_pus_get_recv_tc_nb(t_codec_pus *pCodecPUS, t_codec_pus_tc_recv_info *pRecvInfo){


    // Checks if there is a packet ready to be read
    if(!codec_pus_rdy_for_recv_tc(pCodecPUS)){
        return 0; // No packet ready, returns 0
    }

    // Recv TC informations from the Codec PUS registers

    /* -------------------------------------------------------------- */

    // Reads the PKG_PRIM_HDR1 register and stores it
    alt_u32 u32TempVal = 0;
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_PRIM_HDR1_REG_OFFSET, u32TempVal);

    // Gets all the info
    pRecvInfo->oPkgPrimHdr.u8PkgVersionNumber = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_VERNUM_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_VERNUM_OFFSET;
    pRecvInfo->oPkgPrimHdr.u8PkgType = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_TYPE_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_TYPE_OFFSET;
    pRecvInfo->oPkgPrimHdr.u8PkgSecHdrFlag = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_SEC_HDR_FLAG_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_SEC_HDR_FLAG_OFFSET;
    pRecvInfo->oPkgPrimHdr.u16APID = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_APID_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_APID_OFFSET;
    pRecvInfo->oPkgPrimHdr.u8PkgSeqFlags = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_FLAGS_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_FLAGS_OFFSET;
    pRecvInfo->oPkgPrimHdr.u16PkgSeqCount = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_COUNT_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_COUNT_OFFSET;


    // Reads the PKG_PRIM_HDR2 register and stores it
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_PRIM_HDR2_REG_OFFSET, u32TempVal);

    // Gets all the info
    pRecvInfo->oPkgPrimHdr.u32PkgAppDataLen = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR2_PKG_DATA_LEN_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR2_PKG_DATA_LEN_OFFSET;


    // Reads the PKG_SEC_HDR1 register and stores it
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_SEC_HDR1_REG_OFFSET, u32TempVal);

    // Gets all the info
    pRecvInfo->oPkgSecHdr.u8PUSVersionNumber = (u32TempVal & CODEC_PUS_RECV_PKG_SEC_HDR1_PUSVNUM_MASK) >> CODEC_PUS_RECV_PKG_SEC_HDR1_PUSVNUM_OFFSET;
    pRecvInfo->oPkgSecHdr.u8AckFlags = (u32TempVal & CODEC_PUS_RECV_PKG_SEC_HDR1_ACK_FLAGS_MASK) >> CODEC_PUS_RECV_PKG_SEC_HDR1_ACK_FLAGS_OFFSET;
    pRecvInfo->oPkgSecHdr.u8ServiceID = (u32TempVal & CODEC_PUS_RECV_PKG_SEC_HDR1_SERVICE_ID_MASK) >> CODEC_PUS_RECV_PKG_SEC_HDR1_SERVICE_ID_OFFSET;
    pRecvInfo->oPkgSecHdr.u8SubserviceID = (u32TempVal & CODEC_PUS_RECV_PKG_SEC_HDR1_SUBSERVICE_ID_MASK) >> CODEC_PUS_RECV_PKG_SEC_HDR1_SUBSERVICE_ID_OFFSET;


    // Reads the PKG_SEC_HDR2 register and stores it
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_SEC_HDR2_REG_OFFSET, u32TempVal);

    // Gets all the info
    pRecvInfo->oPkgSecHdr.u16SourceID = (u32TempVal & CODEC_PUS_RECV_PKG_SEC_HDR2_SOURCE_ID_MASK) >> CODEC_PUS_RECV_PKG_SEC_HDR2_SOURCE_ID_OFFSET;


    // Reads the PKG_ADDR register and stores it
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_ADDR_REG_OFFSET, u32TempVal);
    pRecvInfo->u32PkgAddr = (u32TempVal & CODEC_PUS_RECV_PKG_ADDR_PKG_ADDR_MASK) >> CODEC_PUS_RECV_PKG_ADDR_PKG_ADDR_OFFSET;


    // Reads the STATUS register and stores it
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_STATUS_REG_OFFSET, u32TempVal);
    pRecvInfo->u8StatusBits = (u32TempVal & CODEC_PUS_RECV_STATUS_STATUS_FLAGS_MASK) >> CODEC_PUS_RECV_STATUS_STATUS_FLAGS_OFFSET;

    /* -------------------------------------------------------------- */

    // If there is an Application Data, reads it from the DMA FIFO
    if(pRecvInfo->oPkgPrimHdr.u32PkgAppDataLen - 7 > 0){

        // Assuming that the user already allocated enough space for the incoming App Data
        codec_pus_read_recv_dma(pCodecPUS, pRecvInfo->pAppData, pRecvInfo->oPkgPrimHdr.u32PkgAppDataLen - 7);

    }

    // Sets the read bit to 1 in the Recv Handling register
    CODEC_PUS_REG_SET(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_HANDLING_REG_OFFSET, CODEC_PUS_RECV_HANDLING_DATA_RCV_RD_FLAG_MASK);

    return 1; // Returns 1 if a packet was read successfully

}


void codec_pus_get_recv_tc_b(t_codec_pus *pCodecPUS, t_codec_pus_tc_recv_info *pRecvInfo, alt_u32 u32TimeIncrement){

    // Waits until a packet is ready to be read
    while(!codec_pus_rdy_for_recv_tc(pCodecPUS)) usleep(u32TimeIncrement); // Sleeps for the specified time increment // TODO: check the Nios V sleep related function

    // Receives the TC packet

    // Reads the PKG_PRIM_HDR1 register and stores it
    alt_u32 u32TempVal = 0;
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_PRIM_HDR1_REG_OFFSET, u32TempVal);

    // Gets all the info
    pRecvInfo->oPkgPrimHdr.u8PkgVersionNumber = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_VERNUM_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_VERNUM_OFFSET;
    pRecvInfo->oPkgPrimHdr.u8PkgType = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_TYPE_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_TYPE_OFFSET;
    pRecvInfo->oPkgPrimHdr.u8PkgSecHdrFlag = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_SEC_HDR_FLAG_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_SEC_HDR_FLAG_OFFSET;
    pRecvInfo->oPkgPrimHdr.u16APID = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_APID_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_APID_OFFSET;
    pRecvInfo->oPkgPrimHdr.u8PkgSeqFlags = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_FLAGS_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_FLAGS_OFFSET;
    pRecvInfo->oPkgPrimHdr.u16PkgSeqCount = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_COUNT_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_COUNT_OFFSET;


    // Reads the PKG_PRIM_HDR2 register and stores it
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_PRIM_HDR2_REG_OFFSET, u32TempVal);

    // Gets all the info
    pRecvInfo->oPkgPrimHdr.u32PkgAppDataLen = (u32TempVal & CODEC_PUS_RECV_PKG_PRIM_HDR2_PKG_DATA_LEN_MASK) >> CODEC_PUS_RECV_PKG_PRIM_HDR2_PKG_DATA_LEN_OFFSET;


    // Reads the PKG_SEC_HDR1 register and stores it
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_SEC_HDR1_REG_OFFSET, u32TempVal);

    // Gets all the info
    pRecvInfo->oPkgSecHdr.u8PUSVersionNumber = (u32TempVal & CODEC_PUS_RECV_PKG_SEC_HDR1_PUSVNUM_MASK) >> CODEC_PUS_RECV_PKG_SEC_HDR1_PUSVNUM_OFFSET;
    pRecvInfo->oPkgSecHdr.u8AckFlags = (u32TempVal & CODEC_PUS_RECV_PKG_SEC_HDR1_ACK_FLAGS_MASK) >> CODEC_PUS_RECV_PKG_SEC_HDR1_ACK_FLAGS_OFFSET;
    pRecvInfo->oPkgSecHdr.u8ServiceID = (u32TempVal & CODEC_PUS_RECV_PKG_SEC_HDR1_SERVICE_ID_MASK) >> CODEC_PUS_RECV_PKG_SEC_HDR1_SERVICE_ID_OFFSET;
    pRecvInfo->oPkgSecHdr.u8SubserviceID = (u32TempVal & CODEC_PUS_RECV_PKG_SEC_HDR1_SUBSERVICE_ID_MASK) >> CODEC_PUS_RECV_PKG_SEC_HDR1_SUBSERVICE_ID_OFFSET;


    // Reads the PKG_SEC_HDR2 register and stores it
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_SEC_HDR2_REG_OFFSET, u32TempVal);

    // Gets all the info
    pRecvInfo->oPkgSecHdr.u16SourceID = (u32TempVal & CODEC_PUS_RECV_PKG_SEC_HDR2_SOURCE_ID_MASK) >> CODEC_PUS_RECV_PKG_SEC_HDR2_SOURCE_ID_OFFSET;


    // Reads the PKG_ADDR register and stores it
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_ADDR_REG_OFFSET, u32TempVal);
    pRecvInfo->u32PkgAddr = (u32TempVal & CODEC_PUS_RECV_PKG_ADDR_PKG_ADDR_MASK) >> CODEC_PUS_RECV_PKG_ADDR_PKG_ADDR_OFFSET;


    // Reads the STATUS register and stores it
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_PKG_STATUS_REG_OFFSET, u32TempVal);
    pRecvInfo->u8StatusBits = (u32TempVal & CODEC_PUS_RECV_STATUS_STATUS_FLAGS_MASK) >> CODEC_PUS_RECV_STATUS_STATUS_FLAGS_OFFSET;

    /* -------------------------------------------------------------- */

    // If there is an Application Data, reads it from the DMA FIFO
    if(pRecvInfo->oPkgPrimHdr.u32PkgAppDataLen - 7 > 0){

        // Assuming that the user already allocated enough space for the incoming App Data
        codec_pus_read_recv_dma(pCodecPUS, pRecvInfo->pAppData, pRecvInfo->oPkgPrimHdr.u32PkgAppDataLen - 7);

    }

    // Sets the read bit to 1 in the Recv Handling register
    CODEC_PUS_REG_SET(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_HANDLING_REG_OFFSET, CODEC_PUS_RECV_HANDLING_DATA_RCV_RD_FLAG_MASK);

}


alt_u8 codec_pus_rdy_for_recv_tc(t_codec_pus *pCodecPUS){

	alt_u32 u32TempVal;

	// Reads the recv handling register and stores it into the temp val
	CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_HANDLING_REG_OFFSET, u32TempVal);

    // Returns the Data ready flag
    return (alt_u8) (u32TempVal & CODEC_PUS_RECV_HANDLING_DATA_RCV_RDY_FLAG_MASK) >> CODEC_PUS_RECV_HANDLING_DATA_RCV_RDY_FLAG_OFFSET;

}


alt_u8 codec_pus_register_recv_isr(t_codec_pus *pCodecPUS, alt_u32 u32IRQId, void *pCallback, void *pContext){

    // Verifies the irq flags of the Codec PUS to assure that the IRQ is enabled
    if(pCodecPUS->oCodecPUSConfig.u8CodecPusIRQEn && pCodecPUS->oCodecPUSConfig.u8CodecPusRecvIRQEn){

        // Registers the ISR
        alt_ic_isr_register(0, u32IRQId, pCallback, pContext, NULL);

    }
    else{
        return 0; // Returns 0 if the IRQ is not enabled
    }
}


void codec_pus_clear_recv_irq(t_codec_pus *pCodecPUS){

    // Sets the IRQ clear bit to 1 in the Recv Handling register
    CODEC_PUS_REG_SET(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_RECV_HANDLING_REG_OFFSET, CODEC_PUS_RECV_HANDLING_IRQ_RCV_CLR_MASK);

}


alt_u8 codec_pus_send_tm_nb(t_codec_pus *pCodecPUS, t_codec_pus_tm_send_info *pSendInfo){

    // Verifies if the Codec PUS is ready to send a packet
    if(!codec_pus_rdy_for_send_tm(pCodecPUS)){
        return 0; // Not ready, returns 0
    }

    // Sends the TM packet

    // Writes all the data to the Codec PUS registers

    /* -------------------------------------------------------------- */

    // Writes to the PKG_PRIM_HDR1 register
    alt_u32 u32TempVal = 0;

    u32TempVal |= (pSendInfo->oPkgPrimHdr.u16APID << CODEC_PUS_SEND_PKG_PRIM_HDR1_APID_OFFSET) & CODEC_PUS_RECV_PKG_PRIM_HDR1_APID_MASK;
    u32TempVal |= (pSendInfo->oPkgPrimHdr.u32PkgAppDataLen << CODEC_PUS_SEND_PKG_PRIM_HDR1_PKG_DATA_LEN_OFFSET) & CODEC_PUS_SEND_PKG_PRIM_HDR1_PKG_DATA_LEN_MASK;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_PRIM_HDR_REG_OFFSET, u32TempVal);


    // Writes to the PKG_PRIM_HDR2 register
    u32TempVal = 0;

    u32TempVal |= (pSendInfo->oPkgPrimHdr.u16PkgSeqCount << CODEC_PUS_SEND_PKG_PRIM_HDR2_SEQ_COUNT_OFFSET) & CODEC_PUS_SEND_PKG_PRIM_HDR2_SEQ_COUNT_MASK;
    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_PRIM_HDR2_REG_OFFSET, u32TempVal);


    // Writes to the PKG_SEC_HDR1 register
    u32TempVal = 0;

    u32TempVal |= (pSendInfo->oPkgSecHdr.u8SpacecraftTimeRefStatus << CODEC_PUS_SEND_PKG_SEC_HDR1_SPACECRAFT_TIME_REF_MASK) & CODEC_PUS_SEND_PKG_SEC_HDR1_SPACECRAFT_TIME_REF_OFFSET;
    u32TempVal |= (pSendInfo->oPkgSecHdr.u8ServiceID << CODEC_PUS_SEND_PKG_SEC_HDR1_SERVICE_ID_OFFSET) & CODEC_PUS_SEND_PKG_SEC_HDR1_SERVICE_ID_MASK;
    u32TempVal |= (pSendInfo->oPkgSecHdr.u8SubserviceID << CODEC_PUS_SEND_PKG_SEC_HDR1_SUBSERVICE_ID_OFFSET) & CODEC_PUS_SEND_PKG_SEC_HDR1_SUBSERVICE_ID_MASK;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_SEC_HDR1_REG_OFFSET, u32TempVal);


    // Writes to the PKG_SEC_HDR2 register
    u32TempVal = 0;

    u32TempVal |= (pSendInfo->oPkgSecHdr.u16MessageTypeCounter << CODEC_PUS_SEND_PKG_SEC_HDR2_MSG_TYPE_COUNTER_MASK) & CODEC_PUS_SEND_PKG_SEC_HDR2_MSG_TYPE_COUNTER_OFFSET;
    u32TempVal |= (pSendInfo->oPkgSecHdr.u16DestID << CODEC_PUS_SEND_PKG_SEC_HDR2_DEST_ID_MASK) & CODEC_PUS_SEND_PKG_SEC_HDR2_DEST_ID_OFFSET;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_SEC_HDR2_REG_OFFSET, u32TempVal);


    // Writes to the PKG_SEC_HDR3
    u32TempVal = 0;

    // TODO: adjust to dinamic size of the TIME field
    // u32TempVal |= (pSendInfo->oPkgSecHdr.u8SpacecraftTimeRefStatus << CODEC_PUS_SEND_PKG_SEC_HDR3_TIME_MASK) & CODEC_PUS_SEND_PKG_SEC_HDR3_TIME_OFFSET;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_SEC_HDR3_REG_OFFSET, u32TempVal);


    // Writes to the PKG_ADDR register
    u32TempVal = 0;

    u32TempVal |= (pSendInfo->u32PkgAddr << CODEC_PUS_SEND_PKG_ADDR_PKG_ADDR_OFFSET) & CODEC_PUS_SEND_PKG_ADDR_PKG_ADDR_MASK;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_ADDR_REG_OFFSET, u32TempVal);


    /* -------------------------------------------------------------- */

    // If there is Application Data, writes it to the Send DMA FIFO
    if(pSendInfo->oPkgPrimHdr.u32PkgAppDataLen - (9 + CODEC_PUS_TIME_FIELD_SIZE) > 0){

        // Assuming that the user already allocated enough space for the outgoing App Data
        codec_pus_write_send_dma(pCodecPUS, pSendInfo->pAppData, pSendInfo->oPkgPrimHdr.u32PkgAppDataLen - (9 + CODEC_PUS_TIME_FIELD_SIZE));

    }

    // Sets the send bit to 1 in the Send Handling register
    CODEC_PUS_REG_SET(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_HANDLING_REG_OFFSET, CODEC_PUS_SEND_HANDLING_DATA_SEND_WR_FLAG_MASK);

}


void codec_pus_send_tm_b(t_codec_pus *pCodecPUS, t_codec_pus_tm_send_info *pSendInfo, alt_u32 u32TimeIncrement){

    // Verifies if the Codec PUS is ready to send a packet
    while(!codec_pus_rdy_for_send_tm(pCodecPUS)) usleep(u32TimeIncrement); // Sleeps for the specified time increment // TODO: check the Nios V sleep related function

    // Sends the TM packet

    // Writes all the data to the Codec PUS registers

    /* -------------------------------------------------------------- */

    // Writes to the PKG_PRIM_HDR1 register
    alt_u32 u32TempVal = 0;

    u32TempVal |= (pSendInfo->oPkgPrimHdr.u16APID << CODEC_PUS_SEND_PKG_PRIM_HDR1_APID_OFFSET) & CODEC_PUS_RECV_PKG_PRIM_HDR1_APID_MASK;
    u32TempVal |= (pSendInfo->oPkgPrimHdr.u32PkgAppDataLen << CODEC_PUS_SEND_PKG_PRIM_HDR1_PKG_DATA_LEN_OFFSET) & CODEC_PUS_SEND_PKG_PRIM_HDR1_PKG_DATA_LEN_MASK;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_PRIM_HDR_REG_OFFSET, u32TempVal);


    // Writes to the PKG_PRIM_HDR2 register
    u32TempVal = 0;

    u32TempVal |= (pSendInfo->oPkgPrimHdr.u16PkgSeqCount << CODEC_PUS_SEND_PKG_PRIM_HDR2_SEQ_COUNT_OFFSET) & CODEC_PUS_SEND_PKG_PRIM_HDR2_SEQ_COUNT_MASK;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_PRIM_HDR2_REG_OFFSET, u32TempVal);


    // Writes to the PKG_SEC_HDR1 register
    u32TempVal = 0;

    u32TempVal |= (pSendInfo->oPkgSecHdr.u8SpacecraftTimeRefStatus << CODEC_PUS_SEND_PKG_SEC_HDR1_SPACECRAFT_TIME_REF_MASK) & CODEC_PUS_SEND_PKG_SEC_HDR1_SPACECRAFT_TIME_REF_OFFSET;
    u32TempVal |= (pSendInfo->oPkgSecHdr.u8ServiceID << CODEC_PUS_SEND_PKG_SEC_HDR1_SERVICE_ID_OFFSET) & CODEC_PUS_SEND_PKG_SEC_HDR1_SERVICE_ID_MASK;
    u32TempVal |= (pSendInfo->oPkgSecHdr.u8SubserviceID << CODEC_PUS_SEND_PKG_SEC_HDR1_SUBSERVICE_ID_OFFSET) & CODEC_PUS_SEND_PKG_SEC_HDR1_SUBSERVICE_ID_MASK;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_SEC_HDR1_REG_OFFSET, u32TempVal);


    // Writes to the PKG_SEC_HDR2 register
    u32TempVal = 0;

    u32TempVal |= (pSendInfo->oPkgSecHdr.u16MessageTypeCounter << CODEC_PUS_SEND_PKG_SEC_HDR2_MSG_TYPE_COUNTER_MASK) & CODEC_PUS_SEND_PKG_SEC_HDR2_MSG_TYPE_COUNTER_OFFSET;
    u32TempVal |= (pSendInfo->oPkgSecHdr.u16DestID << CODEC_PUS_SEND_PKG_SEC_HDR2_DEST_ID_MASK) & CODEC_PUS_SEND_PKG_SEC_HDR2_DEST_ID_OFFSET;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_SEC_HDR2_REG_OFFSET, u32TempVal);


    // Writes to the PKG_SEC_HDR3
    u32TempVal = 0;

    // TODO: adjust to dinamic size of the TIME field
    // u32TempVal |= (pSendInfo->oPkgSecHdr.u32TimeRef << CODEC_PUS_SEND_PKG_SEC_HDR3_TIME_MASK) & CODEC_PUS_SEND_PKG_SEC_HDR3_TIME_OFFSET;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_SEC_HDR3_REG_OFFSET, u32TempVal);


    // Writes to the PKG_ADDR register
    u32TempVal = 0;

    u32TempVal |= (pSendInfo->u32PkgAddr << CODEC_PUS_SEND_PKG_ADDR_PKG_ADDR_OFFSET) & CODEC_PUS_SEND_PKG_ADDR_PKG_ADDR_MASK;

    CODEC_PUS_REG_WRITE(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_PKG_ADDR_REG_OFFSET, u32TempVal);

    /* -------------------------------------------------------------- */

    // If there is Application Data, writes it to the Send DMA FIFO
    if(pSendInfo->oPkgPrimHdr.u32PkgAppDataLen - (9 + CODEC_PUS_TIME_FIELD_SIZE) > 0){

        // Assuming that the user already allocated enough space for the outgoing App Data
        codec_pus_write_send_dma(pCodecPUS, pSendInfo->pAppData, pSendInfo->oPkgPrimHdr.u32PkgAppDataLen - (9 + CODEC_PUS_TIME_FIELD_SIZE));

    }

    // Sets the send bit to 1 in the Send Handling register
    CODEC_PUS_REG_SET(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_HANDLING_REG_OFFSET, CODEC_PUS_SEND_HANDLING_DATA_SEND_WR_FLAG_MASK);

}


alt_u8 codec_pus_rdy_for_send_tm(t_codec_pus *pCodecPUS){

	alt_u32 u32TempVal;

	// Reads the Send handling register
	CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_HANDLING_REG_OFFSET, u32TempVal);

    // Returns the Data ready flag
    return (alt_u8) (u32TempVal & CODEC_PUS_SEND_HANDLING_DATA_SEND_RDY_FLAG_MASK) >> CODEC_PUS_SEND_HANDLING_DATA_SEND_RDY_FLAG_OFFSET;

}


alt_u8 codec_pus_get_tms_sent_num(t_codec_pus *pCodecPUS){

    // Creates a static variable for storing the current state of the TMs sent counter
    static alt_u8 u8TMsSentCounter = 0;

    // Reads the TMs sent counter from the SEND HANDLING register
    alt_u32 u32TempVal = 0;
    CODEC_PUS_REG_READ(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_HANDLING_REG_OFFSET, u32TempVal);

    // Stores the current value of the TMs sent counter
    alt_u8 u8CurrentTMsSentCounter = (u32TempVal & CODEC_PUS_SEND_HANDLING_DATA_SEND_SUCCESS_FLAGS_MASK) >> CODEC_PUS_SEND_HANDLING_DATA_SEND_SUCCESS_FLAGS_OFFSET;

    // Stores the difference between the current and the previous value of the TMs sent counter
    alt_u8 u8TMsSentDiff = 0;

    if (u8CurrentTMsSentCounter >= u8TMsSentCounter){
        u8TMsSentDiff = u8CurrentTMsSentCounter - u8TMsSentCounter;
    }
    else{
        u8TMsSentDiff = (u8CurrentTMsSentCounter + 256) - u8TMsSentCounter; // 256 is used because the counter is 8 bits and wraps around
    }

    // Updates the static variable with the current value of the TMs sent counter
    u8TMsSentCounter = u8CurrentTMsSentCounter;

    // Returns the difference
    return u8TMsSentDiff;

}


alt_u8 codec_pus_register_send_isr(t_codec_pus *pCodecPUS, alt_u32 u32IRQId, void *pCallback, void *pContext){

    // Verifies the irq flags of the Codec PUS to assure that the IRQ is enabled
    if(pCodecPUS->oCodecPUSConfig.u8CodecPusIRQEn && pCodecPUS->oCodecPUSConfig.u8CodecPusSendIRQEn){

        // Registers the ISR
        alt_ic_isr_register(0, u32IRQId, pCallback, pContext, NULL);

    }
    else{
        return 0; // Returns 0 if the IRQ is not enabled
    }
}


void codec_pus_clear_send_irq(t_codec_pus *pCodecPUS){

    // Sets the IRQ clear bit to 1 in the Send Handling register
    CODEC_PUS_REG_SET(pCodecPUS->u32CodecPUSBaseAddr, CODEC_PUS_SEND_HANDLING_REG_OFFSET, CODEC_PUS_SEND_HANDLING_IRQ_SEND_CLR_MASK);
    
}
