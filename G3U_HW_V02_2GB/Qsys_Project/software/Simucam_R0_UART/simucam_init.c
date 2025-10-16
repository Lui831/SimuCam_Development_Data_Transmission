/*
 ************************************************************************************************
 *                                              NSEE
 *                                             Address
 *
 *                                       All Rights Reserved
 *
 * Filename     : simucam_init.c
 * Programmer(s): Yuri Bunduki
 * Created on: May 27, 2019
 * Description  : Header file for the Simucam initialization task.
 ************************************************************************************************
 */
/*$PAGE*/

#include "rtos/simucam_init_task.h"
#include "simucam_definitions.h"
#include "utils/initialization_simucam.h"
#include "utils/test_module_simucam.h"
#include "driver/pus/codec_pus_drivers.h"
#include "driver/mailbox/mailbox_drivers.h"
#include "envision_test_function/mem_pool.h"
#include "envision_test_function/pus.h"

/* Declaring file for JTAG debug */
#if DEBUG_ON
FILE* fp;
#endif

// ----------------------- DEBUG FUNCTIONS ------------------------------------ //
/* 
 *  Main task
 */

typedef enum{
    PUS_IN_TC_WRONG,
    PUS_IN_TC_IMM_ACTION,
    PUS_IN_TC_PASS
} t_pus_in_tc_process_flags;

// Enum type for defining the possible ack errors based on VESM
typedef enum{
    NO_ERR,
    INCOMPLETE,
    NOT_CCSDS,
    WRONG_APID,
    WRONG_CRC,
    WRONG_EXEC_FLAGS,
    WRONG_PKG_FORMAT,
    WRONG_PKG_TYPE,
    WRONG_PUS_VER,
    WRONG_SRC_ID,
    WRONG_SUBTYPE,
    WRONG_TYPE
} t_pus_vesm_ack_err_flags;

static t_pus_vesm_ack_err_flags pus_recv_process_tc(t_codec_pus_tc_recv_info* oPUSTCRecvInfo){

    // Initialize the enum return for each of the TCs
    t_pus_vesm_ack_err_flags oEnumReturn;

    // Verifies if the received TC has some problem
    if((oPUSTCRecvInfo->u8StatusBits != CODEC_PUS_OK_TC_STATUS) || (oPUSTCRecvInfo->oExtProtocolInfo.u8SpWStatusBits != CODEC_PUS_OK_TC_EXT_PROTOCOL_STATUS)){

        if(((oPUSTCRecvInfo->u8StatusBits >> (CODEC_PUS_VER_NUM_ERR - 1)) & 0b1) == 0b1) return NOT_CCSDS;

        else if((oPUSTCRecvInfo->u8StatusBits >> (CODEC_PUS_TYPE_ERR - 1)) & 0b1 == 0b1) return WRONG_PKG_TYPE;

        else if((oPUSTCRecvInfo->u8StatusBits >> (CODEC_PUS_SEC_HDR_FLAG_ERR - 1)) & 0b1 == 0b1) return WRONG_PKG_FORMAT; // TODO: is this the correct error in this case?

        else if((oPUSTCRecvInfo->u8StatusBits >> (CODEC_PUS_SEQ_ERR - 1)) & 0b1 == 0b1) return WRONG_PKG_FORMAT; // TODO: is this the correct error in this case?

        else if((oPUSTCRecvInfo->u8StatusBits >> (CODEC_PUS_PUSVNUM_ERR - 1)) & 0b1 == 0b1) return WRONG_PUS_VER;

        // DEPRECATED: the CODEC_PUS_SERVICE_ID_ERR has been removed. The verification is going to be done by SW

        else if((oPUSTCRecvInfo->u8StatusBits >> (CODEC_PUS_CRC_ERR - 1)) & 0b1 == 0b1) return WRONG_CRC;

        else if((oPUSTCRecvInfo->u8StatusBits >> (CODEC_PUS_TYPE_ERR - 1)) & 0b1 == 0b1) return WRONG_PKG_TYPE;

        else{

            if((oPUSTCRecvInfo->oExtProtocolInfo.u8SpWStatusBits >> (CODEC_PUS_EXT_PROT_PROT_ID_ERR - 1)) & 0b1 == 0b1) return NOT_CCSDS;

            else return NO_ERR;
                // Need to verify the WRONG_APID, WRONG_TYPE, WRONG_SUBTYPE e WRONG_EXEC_FLAGS
            }
        }

    // If the TC doens't have a problem, verifies the action (main switch case for decision)
    else return NO_ERR;
}

int main(int argc, char* argv[], char* envp[]) {
//  INT8U error_code;

	/* Debug device initialization - JTAG USB */
	#if DEBUG_ON
		fp = fopen(JTAG_UART_0_NAME, "r+");
	#endif

	#if DEBUG_ON
		if (T_simucam.T_conf.usiDebugLevels <= xMajor) {
			fprintf(fp, "Main entry point.\n");
		}
	#endif

		/* Initialization of core HW */
		if (bInitSimucamCoreHW()) {
	#if DEBUG_ON
		if (T_simucam.T_conf.usiDebugLevels <= xMajor) {
			fprintf(fp, "\n");
			fprintf(fp, "SimuCam Release: %s\n", SIMUCAM_RELEASE);
			fprintf(fp, "SimuCam HW Version: %s.%s\n", SIMUCAM_RELEASE, SIMUCAM_HW_VERSION);
			fprintf(fp, "SimuCam FW Version: %s.%s.%s\n", SIMUCAM_RELEASE, SIMUCAM_HW_VERSION, SIMUCAM_FW_VERSION);
			fprintf(fp, "\n");
		}
	#endif
		} else {
	#if DEBUG_ON
		if (T_simucam.T_conf.usiDebugLevels <= xCritical) {
			fprintf(fp, "\n");
			fprintf(fp, "CRITICAL HW FAILURE: Hardware TimeStamp or System ID does not match the expected! SimuCam will be halted.\n");
			fprintf(fp, "CRITICAL HW FAILURE: Expected HW release: %s.%s\n", SIMUCAM_RELEASE, SIMUCAM_HW_VERSION);
			fprintf(fp, "CRITICAL HW FAILURE: SimuCam will be halted.\n");
			fprintf(fp, "\n");
		}
	#endif
			while (1) {
			}
		}

		/* Initialization and Test of basic HW */
		bEnableIsoLogic();
		bEnableIsoDrivers();
		bEnableLvdsBoard();


		// --------------------------------------------------------------- //
		// CODEC PUS TEST REPART;

		// Tests the mem_pool.c functions -----------------------------------

		// Starts the mem_pool_gen
		mem_pool_gen oMemPool;
		mem_pool_init_manager(&oMemPool);

		// Starts a memory_pool_unit
		oMemPool.u8MemPoolIsAlloc[0] = 1;
		oMemPool.u8MemPoolIsAlloc[1] = 1;
		mem_pool_init_unit(&oMemPool.oMemPoolUnits[0], (void *) ONCHIP_MEMORY2_0_BASE, (size_t) 128, (alt_u32) 32, 1);
		mem_pool_init_unit(&oMemPool.oMemPoolUnits[1], (void *) ONCHIP_MEMORY2_0_BASE + 0x800, (size_t) 256, (alt_u32) 32, 1);

		// Allocs some memory based on the pool
		alt_u8* pu8Pointer = (alt_u8*) mem_pool_gen_alloc(&oMemPool, (size_t) 64);
		pu8Pointer[0] = 0xAA;
		pu8Pointer[1] = 0xBB;
		mem_pool_gen_free(&oMemPool, (void*) pu8Pointer, (size_t) 64);


		// Tests the pus.c functions -----------------------------------

		t_codec_pus oCodecPUS;

		// Initializes the necessary structs with pre-configured values for the PUS Codec
		t_codec_pus_config oCodecPUSConfig = {
			.u8CodecPusEn = 1,

			.u8CodecPusRecvEn = 1,
			.u8CodecPusSendEn = 1,

			.u8CodecPusIRQEn = 1,

			.u8CodecPusRecvIRQEn = 1,
			.u8CodecPusSendIRQEn = 1
		};

		t_codec_pus_dma_config oCodecPUSSendDMAConfig = {
			.u32DmaMemBaseAddr = 0x88000800,
			.u32DmaFifoSize    = 1024
		};

		t_codec_pus_dma_config oCodecPUSRecvDMAConfig = {
			.u32DmaMemBaseAddr = 0x88000F00,
			.u32DmaFifoSize    = 1024
		};

		t_codec_pus_ext_protocol_config oCodecPUSExtProtocolConfig = {
			.u8CodecPusSpWADDR = VESM_TC_CODEC_PUS_EXTERNAL_PROTOCOL_SPW_ADDR
		};

		// Sets the oCodecPUS global variable
		oCodecPUS.u32CodecPUSBaseAddr = CODEC_PUS_V01_0_BASE;

		oCodecPUS.oCodecPUSConfig = oCodecPUSConfig;

		oCodecPUS.oCodecPUSRecvDmaConfig = oCodecPUSRecvDMAConfig;

		oCodecPUS.oCodecPUSSendDmaConfig = oCodecPUSSendDMAConfig;

		oCodecPUS.u32CurrentRecvDmaOffset = 0;

		oCodecPUS.u32CurrentSendDmaOffset = 0;
		oCodecPUS.u32CurrentSendDmaAvailableSpace = 65536;

		oCodecPUS.oCodecPUSExtProtocolConfig = oCodecPUSExtProtocolConfig;


		// Initializes the PUS Codec and the ISR mutex
		codec_pus_init(&oCodecPUS);

		// Initializes a TM send info
		t_pus_tm_send_info oTMSendInfo;
		oTMSendInfo.oPkgPrimHdr.u32PkgAppDataLen = 48;

		t_pus_tm_1_2_ack_fail_incomplete_app_data oTMAppDataStruct = {
		                .u8PkgVerNum = 10,

		                .u8PkgType = 22,
		                .u8SecHdrFlag = 3,
		                .u16APID = 4,

		                .u8SeqFlags = 5,
		                .u16PkgSeqCount = 7,

		                .u8VESMDeviceID = 0xFF, // TODO: this field needs to be verified later
		                .u32VESMAcceptErrID = 0xFF, // TODO: this field needs to be verified later
		                .u8VESMServiceType = 1,
		                .u8VESMServiceSubtype = 2,
		                .u32VESMSourceID = 3,
		                .u16VESMCRCReceived = 0xFFFF, // TODO: function to receive CRC needs to be added later
		                .u16VESMLenReceived = 4 + 6,
		                .u16VESMLenExpected = 0xFFFF // TODO: need to verify how the expected len is going to be generated
		            };

		            // Allocs memory for the app data and stores it
		            alt_u8* pAppData = (alt_u8*) mem_pool_gen_alloc(&oMemPool, (size_t) 128);
		            pus_tm_1_2_ack_fail_incomplete_gen_app_data(oTMAppDataStruct, (alt_u8*) pAppData);

		            // Creates and customizes the TM
		            pus_initialize_default_tm(&oTMSendInfo);
		            pus_customize_tm(&oTMSendInfo, 1, 2, VESM_TM_ACK_DEST_APID, pAppData, VESM_TM_ACK_DEST_SPW_ADDR);

		            // Sends TM through the PUS Codec
		            codec_pus_get_tms_sent_num(&oCodecPUS);
		            codec_pus_send_tm_b(&oCodecPUS, &oTMSendInfo, (alt_u32) 1000000);


		 // Creates a tc recv info struct
		 t_codec_pus_tc_recv_info oTCRecvInfo;
		 // codec_pus_get_recv_tc_b(&oCodecPUS, &oTCRecvInfo, 1000000);
		 //fprintf(fp, "The received flags are: %d\n", pus_recv_process_tc(&oTCRecvInfo));

		 // Tests the mailbox functions -----------------------------------

         // Configs the mailbox
		 t_mailbox_recv_cntrl_bits oMailboxConfig =
		 {
			 .u32EnFlag = 1,
			 .u32IrqEnFlag = 0
		 };

		 // mailbox_recv_reset_abs(AVALON_MAILBOX_0_AVALON_MM_RECV_SLAVE_1_BASE);
		 // mailbox_recv_config_abs(AVALON_MAILBOX_0_AVALON_MM_RECV_SLAVE_1_BASE, &oMailboxConfig, NULL, NULL, NULL);
		 IOWR(AVALON_MAILBOX_0_AVALON_MM_RECV_SLAVE_1_BASE, 0, 2);

		 IOWR(AVALON_MAILBOX_0_AVALON_MM_SEND_AGENT_BASE, 0, 0xFF);
		 fprintf(fp, "The received msg is %d\n", (alt_u32) mailbox_recv_get_message_reg_abs(AVALON_MAILBOX_0_AVALON_MM_RECV_SLAVE_1_BASE));






	return -1;
}
