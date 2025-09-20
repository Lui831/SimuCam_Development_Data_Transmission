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

/* Declaring file for JTAG debug */
#if DEBUG_ON
FILE* fp;
#endif

// ----------------------- DEBUG FUNCTIONS ------------------------------------ //

// Define debug function for printing received TC command
void debug_print_tc(t_codec_pus_tc_recv_info received_tc, FILE* uart_pointer){

	fprintf(uart_pointer, "Received TC through Codec Pus! Information: \n");
    fprintf(uart_pointer, "\n");

	// Prints all information about the PKG_PRIM_HDR of the received TC
	fprintf(uart_pointer, "*---------------- Received PKG_PRIM_HDR ------------------ *\n");
	fprintf(uart_pointer, "APID: %u\n", (alt_u32) received_tc.oPkgPrimHdr.u16APID);
	fprintf(uart_pointer, "PKG_SEQ_COUNT: %u\n", (alt_u32) received_tc.oPkgPrimHdr.u16PkgSeqCount);
	fprintf(uart_pointer, "PKG_DATA_LEN: %u\n", (alt_u32) received_tc.oPkgPrimHdr.u32PkgAppDataLen);
	fprintf(uart_pointer, "SEC_HDR_FLAG: %u\n", (alt_u32) received_tc.oPkgPrimHdr.u8PkgSecHdrFlag);
	fprintf(uart_pointer, "PKG_SEC_FLAGS: %u\n", (alt_u32) received_tc.oPkgPrimHdr.u8PkgSeqFlags);
	fprintf(uart_pointer, "PKG_TYPE: %u\n", (alt_u32) received_tc.oPkgPrimHdr.u8PkgType);
	fprintf(uart_pointer, "PKG_VER_NUM: %u\n", (alt_u32) received_tc.oPkgPrimHdr.u8PkgVersionNumber);
	fprintf(uart_pointer, "\n");

	// Prints all information about the PKG_SEC_HDR of the received TC
	fprintf(uart_pointer, "*---------------- Received PKG_SEC_HDR ------------------ *\n");
	fprintf(uart_pointer, "SOURCE_ID: %u\n", (alt_u32) received_tc.oPkgSecHdr.u16SourceID);
	fprintf(uart_pointer, "ACK_FLAGS: %u\n", (alt_u32) received_tc.oPkgSecHdr.u8AckFlags);
	fprintf(uart_pointer, "PUS_VER_NUM: %u\n", (alt_u32) received_tc.oPkgSecHdr.u8PUSVersionNumber);
	fprintf(uart_pointer, "SERVICE_ID: %u\n", (alt_u32) received_tc.oPkgSecHdr.u8ServiceID);
	fprintf(uart_pointer, "SUBSERVICE_ID: %u\n", (alt_u32) received_tc.oPkgSecHdr.u8SubserviceID);
	fprintf(uart_pointer, "\n");

	fprintf(uart_pointer, "*---------------- PKG_APP_DATA (8 bytes) ------------------ *\n");
	fprintf(uart_pointer, "The first 32 bits are %u \n", received_tc.pAppData[3] + (received_tc.pAppData[2] << 8) + (received_tc.pAppData[1] << 16) + (received_tc.pAppData[0] << 24));
	fprintf(uart_pointer, "The last 32 bits are %u \n", received_tc.pAppData[7] + (received_tc.pAppData[6] << 8) + (received_tc.pAppData[5] << 16) + (received_tc.pAppData[4] << 24));
	fprintf(uart_pointer, "\n");

	fprintf(uart_pointer, "*---------------- PKG_ADDR and STATUS (8 bytes) ------------------ *\n");
	fprintf(uart_pointer, "PKG_ADDR: %u\n", (alt_u32) received_tc.u32PkgAddr);
	fprintf(uart_pointer, "PKG_STATUS: %u\n", (alt_u32) received_tc.u8StatusBits);
}

// Define debug function for receiving multiple tcs
void debug_receive_mult_tcs(t_codec_pus* codec_pus, const alt_u32 tcCont, FILE* uart_pointer){

	alt_u32 cont = 0;
	alt_u8 app_data[65535] = {0};
	t_codec_pus_tc_recv_info received_tc;
	received_tc.pAppData = (alt_u8 *) app_data;

	for(cont = 0; cont < tcCont; cont++){

		codec_pus_get_recv_tc_b(codec_pus, &received_tc, 100);
		debug_print_tc(received_tc, uart_pointer);
	}
}

// Define ISR function for the recv codec pus
void recv_ISR_function(void* pContext){

	// Reinterprets the context into a codec pus
	t_codec_pus* p_codec_pus = (t_codec_pus *) pContext;

	// Receives the tc
	t_codec_pus_tc_recv_info received_tc;

	codec_pus_get_recv_tc_b(p_codec_pus, &received_tc, 100);
	debug_print_tc(received_tc, fp);

	// Clears the IRQ
	codec_pus_clear_recv_irq(p_codec_pus);

}

// Define debug function for sending multiple TMs
void debug_send_multiple_tms(t_codec_pus* p_codec_pus, const alt_u32 tmCont, FILE* uart_pointer){

	alt_u32 cont = 0;
	t_codec_pus_tm_send_info tm_send;
	alt_u8 app_data[65535] = {0};

	// Declare some important values for the tm
	tm_send.oPkgPrimHdr.u32PkgAppDataLen = 65535;
	tm_send.u32PkgAddr = p_codec_pus->oCodecPUSSendDmaConfig.u32DmaMemBaseAddr;
    app_data[0] = 0xAA;
    app_data[1] = 0xBB;
    app_data[2] = 0xCC;
    app_data[3] = 0xDD;

    tm_send.pAppData = (alt_u8 *) app_data;

    fprintf(uart_pointer, "The number of packets sent until now is %u\n", (alt_u32) codec_pus_get_tms_sent_num(p_codec_pus));

	for(cont = 0; cont < tmCont; cont++){

		codec_pus_send_tm_nb(p_codec_pus, &tm_send);
	}

	fprintf(uart_pointer, "The updated of packets sent until now is %u\n", (alt_u32) codec_pus_get_tms_sent_num(p_codec_pus));

}

// ISR Function for sending TM PUS packages
void send_ISR_function(void* pContext){

	// Casts the codec_pus
	t_codec_pus*  p_codec_pus = (t_codec_pus *) pContext;

	// Declare some important values for the tm
	t_codec_pus_tm_send_info tm_send;

	tm_send.oPkgPrimHdr.u32PkgAppDataLen = 32;
	tm_send.u32PkgAddr = p_codec_pus->oCodecPUSSendDmaConfig.u32DmaMemBaseAddr;
	tm_send.pAppData[0] = 0xAA;
	tm_send.pAppData[1] = 0xBB;
	tm_send.pAppData[2] = 0xCC;
	tm_send.pAppData[3] = 0xDD;

	// Clears the IRQ
	codec_pus_clear_send_irq(p_codec_pus);

	// Sends the package
	codec_pus_send_tm_nb(p_codec_pus, &tm_send);
}

/* ------------------------------------------------------------------------------------ */
// General definitions for the test functions

// General small-size TM structure to be sent
alt_u8 timeArray[CODEC_PUS_TIME_FIELD_SIZE] = {0x12, 0x34}; // Example time array
alt_u8 appData[16] = { // Example app data
    0xDE, 0xAD, 0xBE, 0xEF,
    0xBA, 0xAD, 0xF0, 0x0D,
    0xCA, 0xFE, 0xBA, 0xBE,
    0xFE, 0xED, 0xFA, 0xCE
};

t_codec_pus_tm_send_info testTM = {
    .oPkgPrimHdr = {
        .u16APID = 0x01,
        .u32PkgAppDataLen = 16 + 11, // 16 bytes of app data
        .u16PkgSeqCount = 0x0001
    },
    .oPkgSecHdr = {
        .u8SpacecraftTimeRefStatus = 0,
        .u8ServiceID = 1,
        .u8SubserviceID = 1,
        .u16MessageTypeCounter = 1,
        .u16DestID = 0x0001,
        .u8Time = {0x12, 0x34}
    },
    .u32PkgAddr = 0x10000000, // Example address
    .pAppData = (alt_u8*) appData
};

// General Big-size TM structure to be sent
alt_u8 bigAppData[65536 - 1] = {0}; // Example big app data, filled with zeros
t_codec_pus_tm_send_info bigTestTM = {
    .oPkgPrimHdr = {
        .u16APID = 0x01,
        .u32PkgAppDataLen = 65536 - 1, // Maximum size of app data
        .u16PkgSeqCount = 0x0001
    },
    .oPkgSecHdr = {
        .u8SpacecraftTimeRefStatus = 0,
        .u8ServiceID = 1,
        .u8SubserviceID = 1,
        .u16MessageTypeCounter = 1,
        .u16DestID = 0x0001,
        .u8Time = {0x12, 0x34}
    },
    .u32PkgAddr = 0x10000000, // Example address
    .pAppData = (alt_u8*) bigAppData
};

alt_u8 packages_received_by_isr = 0;

// Struct for Context used in the ISR test
typedef struct t_codec_pus_isr_context{
    t_codec_pus* pCodecPUS;
    FILE* uart_pointer;
} t_codec_pus_isr_context;

/* ------------------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------------------ */
// Test functions for the Codec PUS drivers

// Functions to test the Codec PUS receiving TCs.

// Functions to test the Codec PUS receiving TCs.
void test1_codec_pus_recv_tc(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #1 for the Codec PUS TC receiving: Receiving a TC packet through the Codec PUS in a non-blocking way.\n");
    fprintf(uart_pointer, "Please, run this test under two conditions: send a TC packet to the Codec PUS and do not send any TC packet to the Codec PUS.\n");

    // Variables for the test
    t_codec_pus_tc_recv_info recvInfo;
    alt_u8 packetReceived;

    usleep(5*1000*1000);

    // Runs the non-blocking function once, checking if a packet was received
    packetReceived = codec_pus_get_recv_tc_nb(pCodecPUS, &recvInfo);

    // Checks if a packet was received and prints the result
    if(packetReceived){
        fprintf(uart_pointer, "A TC packet was received!\n");
        fprintf(uart_pointer, "Primary Header:\n");
        fprintf(uart_pointer, "  - Version Number: %u\n", recvInfo.oPkgPrimHdr.u8PkgVersionNumber);
        fprintf(uart_pointer, "  - Type: %u\n", recvInfo.oPkgPrimHdr.u8PkgType);
        fprintf(uart_pointer, "  - Sec Hdr Flag: %u\n", recvInfo.oPkgPrimHdr.u8PkgSecHdrFlag);
        fprintf(uart_pointer, "  - APID: %u\n", recvInfo.oPkgPrimHdr.u16APID);
        fprintf(uart_pointer, "  - Seq Flags: %u\n", recvInfo.oPkgPrimHdr.u8PkgSeqFlags);
        fprintf(uart_pointer, "  - Seq Count: %u\n", recvInfo.oPkgPrimHdr.u16PkgSeqCount);
        fprintf(uart_pointer, "  - App Data Len: %u\n", recvInfo.oPkgPrimHdr.u32PkgAppDataLen);

        fprintf(uart_pointer, "Secondary Header:\n");
        fprintf(uart_pointer, "  - Source ID: %u\n", recvInfo.oPkgSecHdr.u16SourceID);
        fprintf(uart_pointer, "  - Ack Flags: %u\n", recvInfo.oPkgSecHdr.u8AckFlags);
        fprintf(uart_pointer, "  - PUS Version Number: %u\n", recvInfo.oPkgSecHdr.u8PUSVersionNumber);
        fprintf(uart_pointer, "  - Service ID: %u\n", recvInfo.oPkgSecHdr.u8ServiceID);
        fprintf(uart_pointer, "  - Subservice ID: %u\n", recvInfo.oPkgSecHdr.u8SubserviceID);

        fprintf(uart_pointer, "\n");

        fprintf(uart_pointer, "Package Address: 0x%08X\n", recvInfo.u32PkgAddr);
        fprintf(uart_pointer, "Status Bits: 0x%02X\n", recvInfo.u8StatusBits);
        fprintf(uart_pointer, "App Data: ");
        for(int i = 0; i < recvInfo.oPkgPrimHdr.u32PkgAppDataLen -  7; i++){
            fprintf(uart_pointer, "%02X ", recvInfo.pAppData[i]);
        }
        fprintf(uart_pointer, "\n");
    } else {
        fprintf(uart_pointer, "No TC packet was received.\n");
        fprintf(uart_pointer, "\n");
    }
}

void test2_codec_pus_recv_tc(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #2 for the Codec PUS TC receiving: Receiving a TC packet through the Codec PUS in a blocking way.\n");
    fprintf(uart_pointer, "Please, send a TC packet to the Codec PUS to run this test.\n");

    static alt_u8 appdata[65536];

    // Variables for the test
    t_codec_pus_tc_recv_info recvInfo;
    recvInfo.pAppData = (alt_u8 *) appdata;

    // Runs the blocking function until a packet is received
    codec_pus_get_recv_tc_b(pCodecPUS, &recvInfo, 0); // Time increment is set to 0 for simplicity

    // Prints the result
    fprintf(uart_pointer, "A TC packet was received!\n");
	fprintf(uart_pointer, "Primary Header:\n");
	fprintf(uart_pointer, "  - Version Number: %u\n", recvInfo.oPkgPrimHdr.u8PkgVersionNumber);
	fprintf(uart_pointer, "  - Type: %u\n", recvInfo.oPkgPrimHdr.u8PkgType);
	fprintf(uart_pointer, "  - Sec Hdr Flag: %u\n", recvInfo.oPkgPrimHdr.u8PkgSecHdrFlag);
	fprintf(uart_pointer, "  - APID: %u\n", recvInfo.oPkgPrimHdr.u16APID);
	fprintf(uart_pointer, "  - Seq Flags: %u\n", recvInfo.oPkgPrimHdr.u8PkgSeqFlags);
	fprintf(uart_pointer, "  - Seq Count: %u\n", recvInfo.oPkgPrimHdr.u16PkgSeqCount);
	fprintf(uart_pointer, "  - App Data Len: %u\n", recvInfo.oPkgPrimHdr.u32PkgAppDataLen);

	fprintf(uart_pointer, "Secondary Header:\n");
	fprintf(uart_pointer, "  - Source ID: %u\n", recvInfo.oPkgSecHdr.u16SourceID);
	fprintf(uart_pointer, "  - Ack Flags: %u\n", recvInfo.oPkgSecHdr.u8AckFlags);
	fprintf(uart_pointer, "  - PUS Version Number: %u\n", recvInfo.oPkgSecHdr.u8PUSVersionNumber);
	fprintf(uart_pointer, "  - Service ID: %u\n", recvInfo.oPkgSecHdr.u8ServiceID);
	fprintf(uart_pointer, "  - Subservice ID: %u\n", recvInfo.oPkgSecHdr.u8SubserviceID);

	fprintf(uart_pointer, "\n");

	fprintf(uart_pointer, "Package Address: 0x%08X\n", recvInfo.u32PkgAddr);
	fprintf(uart_pointer, "Status Bits: 0x%02X\n", recvInfo.u8StatusBits);
	fprintf(uart_pointer, "App Data: ");
	for(int i = 0; i < recvInfo.oPkgPrimHdr.u32PkgAppDataLen -  7; i++){
		fprintf(uart_pointer, "%02X ", recvInfo.pAppData[i]);
	}
	fprintf(uart_pointer, "\n");

}

void test3_codec_pus_recv_tc_isr_function(void* pContext){

    // Casts the context to the appropriate type
    t_codec_pus_isr_context* context = (t_codec_pus_isr_context*) pContext;
    t_codec_pus* pCodecPUS = context->pCodecPUS;
    FILE* uart_pointer = context->uart_pointer;

    // Variables for the test
    t_codec_pus_tc_recv_info recvInfo;
    alt_u8 packetReceived;

    // Runs the non-blocking function once, checking if a packet was received
    codec_pus_get_recv_tc_b(pCodecPUS, &recvInfo, 0);

    // Increases the number
    packages_received_by_isr++;

    // Clears the interruption
    codec_pus_clear_recv_irq(pCodecPUS);


}

void test3_codec_pus_recv_tc(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #3 for the Codec PUS TC receiving: Receiving a TC packet through the Codec PUS using an ISR.\n");
    fprintf(uart_pointer, "Please, send a TC packet to the Codec PUS to run this test.\n");

    // Context for the ISR
    t_codec_pus_isr_context context;
    context.pCodecPUS = pCodecPUS;
    context.uart_pointer = uart_pointer;

    // Registers the ISR
    if(codec_pus_register_recv_isr(pCodecPUS, 4, test3_codec_pus_recv_tc_isr_function, (void*) &context)){
        fprintf(uart_pointer, "ISR registered successfully. Please send a TC packet to the Codec PUS.\n");
    } else {
        fprintf(uart_pointer, "Failed to register the ISR.\n");
        return;
    }

	while(1){
		usleep(1000*1000);
		fprintf(uart_pointer, "Packages received until now: %u\n", packages_received_by_isr);
	}

}

void test4_codec_pus_recv_tc(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #4 for the Codec PUS TC receiving: Receiving a large TC packet.\n");
    fprintf(uart_pointer, "Please, send a large TC packet (with maximum size of app data) to the Codec PUS to run this test.\n");

    // Variables for the test
    t_codec_pus_tc_recv_info recvInfo;
    alt_u8 appdata[32] = {0};
    recvInfo.pAppData = (alt_u8 *) appdata;

    // Runs the blocking function until a packet is received
    codec_pus_get_recv_tc_b(pCodecPUS, &recvInfo, 0); // Time increment is set to 0 for simplicity

    // Prints the result
    fprintf(uart_pointer, "A TC packet was received!\n");
	fprintf(uart_pointer, "Primary Header:\n");
	fprintf(uart_pointer, "  - Version Number: %u\n", recvInfo.oPkgPrimHdr.u8PkgVersionNumber);
	fprintf(uart_pointer, "  - Type: %u\n", recvInfo.oPkgPrimHdr.u8PkgType);
	fprintf(uart_pointer, "  - Sec Hdr Flag: %u\n", recvInfo.oPkgPrimHdr.u8PkgSecHdrFlag);
	fprintf(uart_pointer, "  - APID: %u\n", recvInfo.oPkgPrimHdr.u16APID);
	fprintf(uart_pointer, "  - Seq Flags: %u\n", recvInfo.oPkgPrimHdr.u8PkgSeqFlags);
	fprintf(uart_pointer, "  - Seq Count: %u\n", recvInfo.oPkgPrimHdr.u16PkgSeqCount);
	fprintf(uart_pointer, "  - App Data Len: %u\n", recvInfo.oPkgPrimHdr.u32PkgAppDataLen);

	fprintf(uart_pointer, "Secondary Header:\n");
	fprintf(uart_pointer, "  - Source ID: %u\n", recvInfo.oPkgSecHdr.u16SourceID);
	fprintf(uart_pointer, "  - Ack Flags: %u\n", recvInfo.oPkgSecHdr.u8AckFlags);
	fprintf(uart_pointer, "  - PUS Version Number: %u\n", recvInfo.oPkgSecHdr.u8PUSVersionNumber);
	fprintf(uart_pointer, "  - Service ID: %u\n", recvInfo.oPkgSecHdr.u8ServiceID);
	fprintf(uart_pointer, "  - Subservice ID: %u\n", recvInfo.oPkgSecHdr.u8SubserviceID);
	fprintf(uart_pointer, "  - Time: ");

	fprintf(uart_pointer, "\n");

	fprintf(uart_pointer, "Package Address: 0x%08X\n", recvInfo.u32PkgAddr);
	fprintf(uart_pointer, "Status Bits: 0x%02X\n", recvInfo.u8StatusBits);
	fprintf(uart_pointer, "App Data: ");
	for(int i = 0; i < 255 + 7; i++){
		fprintf(uart_pointer, "%02X ", recvInfo.pAppData[i]);
	}
	fprintf(uart_pointer, "\n");

}

void test5_codec_pus_recv_tc(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #5 for the Codec PUS TC receiving: Receives to big TC packets to test the DMA circular buffer functionality.\n");
    fprintf(uart_pointer, "Please, send two large TC packets (with maximum size of app data) to the Codec PUS to run this test.\n");

    alt_u8 appdata[32] = {0};

    // Variables for the test
    t_codec_pus_tc_recv_info recvInfo1;
    t_codec_pus_tc_recv_info recvInfo2;

    recvInfo1.pAppData = (alt_u8 *) appdata;
    recvInfo2.pAppData = (alt_u8 *) appdata;

    // Runs the blocking function until the first packet is received
    codec_pus_get_recv_tc_b(pCodecPUS, &recvInfo1, 0); // Time increment is set to 0 for simplicity

    // Prints the result for the first packet
    fprintf(uart_pointer, "A TC packet was received!\n");
	fprintf(uart_pointer, "Primary Header:\n");
	fprintf(uart_pointer, "  - Version Number: %u\n", recvInfo1.oPkgPrimHdr.u8PkgVersionNumber);
	fprintf(uart_pointer, "  - Type: %u\n", recvInfo1.oPkgPrimHdr.u8PkgType);
	fprintf(uart_pointer, "  - Sec Hdr Flag: %u\n", recvInfo1.oPkgPrimHdr.u8PkgSecHdrFlag);
	fprintf(uart_pointer, "  - APID: %u\n", recvInfo1.oPkgPrimHdr.u16APID);
	fprintf(uart_pointer, "  - Seq Flags: %u\n", recvInfo1.oPkgPrimHdr.u8PkgSeqFlags);
	fprintf(uart_pointer, "  - Seq Count: %u\n", recvInfo1.oPkgPrimHdr.u16PkgSeqCount);
	fprintf(uart_pointer, "  - App Data Len: %u\n", recvInfo1.oPkgPrimHdr.u32PkgAppDataLen);

	fprintf(uart_pointer, "Secondary Header:\n");
	fprintf(uart_pointer, "  - Source ID: %u\n", recvInfo1.oPkgSecHdr.u16SourceID);
	fprintf(uart_pointer, "  - Ack Flags: %u\n", recvInfo1.oPkgSecHdr.u8AckFlags);
	fprintf(uart_pointer, "  - PUS Version Number: %u\n", recvInfo1.oPkgSecHdr.u8PUSVersionNumber);
	fprintf(uart_pointer, "  - Service ID: %u\n", recvInfo1.oPkgSecHdr.u8ServiceID);
	fprintf(uart_pointer, "  - Subservice ID: %u\n", recvInfo1.oPkgSecHdr.u8SubserviceID);
	fprintf(uart_pointer, "  - Time: ");

	fprintf(uart_pointer, "\n");

	fprintf(uart_pointer, "Package Address: 0x%08X\n", recvInfo1.u32PkgAddr);
	fprintf(uart_pointer, "Status Bits: 0x%02X\n", recvInfo1.u8StatusBits);
	fprintf(uart_pointer, "App Data: ");
	for(int i = 0; i < 255 + 7; i++){
		fprintf(uart_pointer, "%02X ", recvInfo1.pAppData[i]);
	}
	fprintf(uart_pointer, "\n");

    // Runs the blocking function until the second packet is received
    codec_pus_get_recv_tc_b(pCodecPUS, &recvInfo2, 0); // Time increment is set to 0 for simplicity

    // Prints the result for the second packet
    fprintf(uart_pointer, "A TC packet was received!\n");
	fprintf(uart_pointer, "Primary Header:\n");
	fprintf(uart_pointer, "  - Version Number: %u\n", recvInfo2.oPkgPrimHdr.u8PkgVersionNumber);
	fprintf(uart_pointer, "  - Type: %u\n", recvInfo2.oPkgPrimHdr.u8PkgType);
	fprintf(uart_pointer, "  - Sec Hdr Flag: %u\n", recvInfo2.oPkgPrimHdr.u8PkgSecHdrFlag);
	fprintf(uart_pointer, "  - APID: %u\n", recvInfo2.oPkgPrimHdr.u16APID);
	fprintf(uart_pointer, "  - Seq Flags: %u\n", recvInfo2.oPkgPrimHdr.u8PkgSeqFlags);
	fprintf(uart_pointer, "  - Seq Count: %u\n", recvInfo2.oPkgPrimHdr.u16PkgSeqCount);
	fprintf(uart_pointer, "  - App Data Len: %u\n", recvInfo2.oPkgPrimHdr.u32PkgAppDataLen);

	fprintf(uart_pointer, "Secondary Header:\n");
	fprintf(uart_pointer, "  - Source ID: %u\n", recvInfo2.oPkgSecHdr.u16SourceID);
	fprintf(uart_pointer, "  - Ack Flags: %u\n", recvInfo2.oPkgSecHdr.u8AckFlags);
	fprintf(uart_pointer, "  - PUS Version Number: %u\n", recvInfo2.oPkgSecHdr.u8PUSVersionNumber);
	fprintf(uart_pointer, "  - Service ID: %u\n", recvInfo2.oPkgSecHdr.u8ServiceID);
	fprintf(uart_pointer, "  - Subservice ID: %u\n", recvInfo2.oPkgSecHdr.u8SubserviceID);
	fprintf(uart_pointer, "  - Time: ");

	fprintf(uart_pointer, "\n");

	fprintf(uart_pointer, "Package Address: 0x%08X\n", recvInfo2.u32PkgAddr);
	fprintf(uart_pointer, "Status Bits: 0x%02X\n", recvInfo2.u8StatusBits);
	fprintf(uart_pointer, "App Data: ");
	for(int i = 0; i < 255 + 7; i++){
		fprintf(uart_pointer, "%02X ", recvInfo2.pAppData[i]);
	}
	fprintf(uart_pointer, "\n");

}

// Functions to test the Codec PUS sending TMs.
void test1_codec_pus_send_tm(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #1 for the Codec PUS TM sending: Sending a small TM packet through the Codec PUS in a non-blocking way.\n");

    // Creates a small TM packet
    t_codec_pus_tm_send_info* pSendInfo = &testTM;

    // Sends the TM packet
    if(codec_pus_send_tm_nb(pCodecPUS, pSendInfo)){
        fprintf(uart_pointer, "TM packet sent successfully in a non-blocking way.\n");
        fprintf(uart_pointer, "Primary Header:\n");
        fprintf(uart_pointer, "  - Version Number: %u\n", pSendInfo->oPkgPrimHdr.u8PkgVersionNumber);
        fprintf(uart_pointer, "  - Type: %u\n", pSendInfo->oPkgPrimHdr.u8PkgType);
        fprintf(uart_pointer, "  - Sec Hdr Flag: %u\n", pSendInfo->oPkgPrimHdr.u8PkgSecHdrFlag);
        fprintf(uart_pointer, "  - APID: %u\n", pSendInfo->oPkgPrimHdr.u16APID);
        fprintf(uart_pointer, "  - Seq Flags: %u\n", pSendInfo->oPkgPrimHdr.u8PkgSeqFlags);
        fprintf(uart_pointer, "  - Seq Count: %u\n", pSendInfo->oPkgPrimHdr.u16PkgSeqCount);
        fprintf(uart_pointer, "  - App Data Len: %u\n", pSendInfo->oPkgPrimHdr.u32PkgAppDataLen);
        fprintf(uart_pointer, "Secondary Header:\n");
        fprintf(uart_pointer, "  - Spacecraft Time Ref Status: %u\n", pSendInfo->oPkgSecHdr.u8SpacecraftTimeRefStatus);
        fprintf(uart_pointer, "  - Service ID: %u\n", pSendInfo->oPkgSecHdr.u8ServiceID);
        fprintf(uart_pointer, "  - Subservice ID: %u\n", pSendInfo->oPkgSecHdr.u8SubserviceID);
        fprintf(uart_pointer, "  - Message Type Counter: %u\n", pSendInfo->oPkgSecHdr.u16MessageTypeCounter);
        fprintf(uart_pointer, "  - Dest ID: %u\n", pSendInfo->oPkgSecHdr.u16DestID);
        fprintf(uart_pointer, "  - Time: ");
        for(int i = 0; i < CODEC_PUS_TIME_FIELD_SIZE; i++){
            fprintf(uart_pointer, "%02X ", pSendInfo->oPkgSecHdr.u8Time[i]);
        }
        fprintf(uart_pointer, "\n");
        fprintf(uart_pointer, "Package Address: 0x%08X\n", pSendInfo->u32PkgAddr);
        fprintf(uart_pointer, "App Data: ");
        for(int i = 0; i < pSendInfo->oPkgPrimHdr.u32PkgAppDataLen - 9; i++){
            fprintf(uart_pointer, "%02X ", pSendInfo->pAppData[i]);
        }
        fprintf(uart_pointer, "\n");
    } else {
        fprintf(uart_pointer, "Failed to send the TM packet in a non-blocking way.\n");
    }

}

void test2_codec_pus_send_tm(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #2 for the Codec PUS TM sending: Sending a small TM packet through the Codec PUS in a blocking way.\n");

    // Creates a small TM packet
    t_codec_pus_tm_send_info* pSendInfo = &testTM;

    // Sends the TM packet
    codec_pus_send_tm_b(pCodecPUS, pSendInfo, 0);

    fprintf(uart_pointer, "TM packet sent successfully in a blocking way.\n");
    fprintf(uart_pointer, "Primary Header:\n");
    fprintf(uart_pointer, "  - Version Number: %u\n", pSendInfo->oPkgPrimHdr.u8PkgVersionNumber);
    fprintf(uart_pointer, "  - Type: %u\n", pSendInfo->oPkgPrimHdr.u8PkgType);
    fprintf(uart_pointer, "  - Sec Hdr Flag: %u\n", pSendInfo->oPkgPrimHdr.u8PkgSecHdrFlag);
    fprintf(uart_pointer, "  - APID: %u\n", pSendInfo->oPkgPrimHdr.u16APID);
    fprintf(uart_pointer, "  - Seq Flags: %u\n", pSendInfo->oPkgPrimHdr.u8PkgSeqFlags);
    fprintf(uart_pointer, "  - Seq Count: %u\n", pSendInfo->oPkgPrimHdr.u16PkgSeqCount);
    fprintf(uart_pointer, "  - App Data Len: %u\n", pSendInfo->oPkgPrimHdr.u32PkgAppDataLen);
    fprintf(uart_pointer, "Secondary Header:\n");
    fprintf(uart_pointer, "  - Spacecraft Time Ref Status: %u\n", pSendInfo->oPkgSecHdr.u8SpacecraftTimeRefStatus);
    fprintf(uart_pointer, "  - Service ID: %u\n", pSendInfo->oPkgSecHdr.u8ServiceID);
    fprintf(uart_pointer, "  - Subservice ID: %u\n", pSendInfo->oPkgSecHdr.u8SubserviceID);
    fprintf(uart_pointer, "  - Message Type Counter: %u\n", pSendInfo->oPkgSecHdr.u16MessageTypeCounter);
    fprintf(uart_pointer, "  - Dest ID: %u\n", pSendInfo->oPkgSecHdr.u16DestID);
    fprintf(uart_pointer, "  - Time: ");
    for(int i = 0; i < CODEC_PUS_TIME_FIELD_SIZE; i++){
        fprintf(uart_pointer, "%02X ", pSendInfo->oPkgSecHdr.u8Time[i]);
    }
    fprintf(uart_pointer, "\n");
    fprintf(uart_pointer, "Package Address: 0x%08X\n", pSendInfo->u32PkgAddr);
    fprintf(uart_pointer, "App Data: ");
    for(int i = 0; i < pSendInfo->oPkgPrimHdr.u32PkgAppDataLen - 11; i++){
        fprintf(uart_pointer, "%02X ", pSendInfo->pAppData[i]);
    }
    fprintf(uart_pointer, "\n");
}

// ISR
void test_codec_pus_send_tm_isr_function(void* pContext){

    // Casts the context to the appropriate type
    t_codec_pus_isr_context* context = (t_codec_pus_isr_context*) pContext;
    t_codec_pus* pCodecPUS = context->pCodecPUS;
    FILE* uart_pointer = context->uart_pointer;

    // Creates a small TM packet
    t_codec_pus_tm_send_info* pSendInfo = &testTM;

    // Updates the DMA status
    codec_pus_get_tms_sent_num(pCodecPUS);

    // Clears the interruption
    codec_pus_clear_send_irq(pCodecPUS);

    // Sends the TM packet again
    codec_pus_send_tm_nb(pCodecPUS, pSendInfo);

    usleep(1000*1000);

}

void test3_codec_pus_send_tm(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #3 for the Codec PUS TM sending: Sending a small TM packet through the Codec PUS using an ISR.\n");

    // Context for the ISR
    t_codec_pus_isr_context context;
    context.pCodecPUS = pCodecPUS;
    context.uart_pointer = uart_pointer;

    // Registers the ISR
    if(codec_pus_register_send_isr(pCodecPUS, 5, test_codec_pus_send_tm_isr_function, (void*) &context)){
        fprintf(uart_pointer, "ISR registered successfully. Sending a TM packet to the Codec PUS.\n");
    } else {
        fprintf(uart_pointer, "Failed to register the ISR.\n");
        return;
    }

    // Creates a small TM packet
    t_codec_pus_tm_send_info* pSendInfo = &testTM;

    // Sends the TM packet
    if(codec_pus_send_tm_nb(pCodecPUS, pSendInfo)){
        fprintf(uart_pointer, "TM packet sent successfully in a non-blocking way. Waiting for the ISR to be triggered.\n");
    } else {
        fprintf(uart_pointer, "Failed to send the TM packet in a non-blocking way.\n");
    }

}

void test4_codec_pus_send_tm(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #4 for the Codec PUS TM sending: Sending a large TM packet through the Codec PUS in a blocking way.\n");

    // Creates a large TM packet
    t_codec_pus_tm_send_info* pSendInfo = &bigTestTM;

    // Sends the TM packet
    codec_pus_send_tm_b(pCodecPUS, pSendInfo, 0);

    fprintf(uart_pointer, "Large TM packet sent successfully in a blocking way.\n");
    fprintf(uart_pointer, "Primary Header:\n");
    fprintf(uart_pointer, "  - Version Number: %u\n", pSendInfo->oPkgPrimHdr.u8PkgVersionNumber);
    fprintf(uart_pointer, "  - Type: %u\n", pSendInfo->oPkgPrimHdr.u8PkgType);
    fprintf(uart_pointer, "  - Sec Hdr Flag: %u\n", pSendInfo->oPkgPrimHdr.u8PkgSecHdrFlag);
    fprintf(uart_pointer, "  - APID: %u\n", pSendInfo->oPkgPrimHdr.u16APID);
    fprintf(uart_pointer, "  - Seq Flags: %u\n", pSendInfo->oPkgPrimHdr.u8PkgSeqFlags);
    fprintf(uart_pointer, "  - Seq Count: %u\n", pSendInfo->oPkgPrimHdr.u16PkgSeqCount);
    fprintf(uart_pointer, "  - App Data Len: %u\n", pSendInfo->oPkgPrimHdr.u32PkgAppDataLen);
    fprintf(uart_pointer, "Secondary Header:\n");
    fprintf(uart_pointer, "  - Spacecraft Time Ref Status: %u\n", pSendInfo->oPkgSecHdr.u8SpacecraftTimeRefStatus);
    fprintf(uart_pointer, "  - Service ID: %u\n", pSendInfo->oPkgSecHdr.u8ServiceID);
    fprintf(uart_pointer, "  - Subservice ID: %u\n", pSendInfo->oPkgSecHdr.u8SubserviceID);
    fprintf(uart_pointer, "  - Message Type Counter: %u\n", pSendInfo->oPkgSecHdr.u16MessageTypeCounter);
    fprintf(uart_pointer, "  - Dest ID: %u\n", pSendInfo->oPkgSecHdr.u16DestID);
    fprintf(uart_pointer, "  - Time: ");
    for(int i = 0; i < CODEC_PUS_TIME_FIELD_SIZE; i++){
        fprintf(uart_pointer, "%02X ", pSendInfo->oPkgSecHdr.u8Time[i]);
    }
    fprintf(uart_pointer, "\n");
    fprintf(uart_pointer, "Package Address: 0x%08X\n", pSendInfo->u32PkgAddr);
    fprintf(uart_pointer, "App Data: ");
    for(int i = 0; i < 255 + 11; i++){
        fprintf(uart_pointer, "%02X ", pSendInfo->pAppData[i]);
    }
    fprintf(uart_pointer, "\n");

}

void test5_codec_pus_send_tm(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #5 for the Codec PUS TM sending: Sending multiple TM packets to test the DMA circular buffer functionality.\n");

    // Creates a small TM packet
    t_codec_pus_tm_send_info* pSendInfo = &bigTestTM;

    // Sends multiple TM packets
    for(int i = 0; i < 10; i++){
        codec_pus_send_tm_nb(pCodecPUS, pSendInfo);

        // While the package has not been sent, updates the DMA status
        while(codec_pus_get_tms_sent_num(pCodecPUS) < 1){

        usleep(10000);

    }

}

}

t_codec_pus_tm_send_info* testTMSimulatedFIFO5[5] = {&bigTestTM, &testTM, &bigTestTM, &testTM, &bigTestTM};

// Functions to test the Nominal Codec PUS operation
void test1_codec_pus_nominal_operation_recv_isr(void* pContext){

    // Casts the context to the appropriate type
    t_codec_pus* pCodecPUS = (t_codec_pus *) pContext;


    // Variables for the test
    static alt_u8 u8Itrt = 0;
    static t_codec_pus_tc_recv_info recvInfo;
    static alt_u8 appdata[65536];
    recvInfo.pAppData = (alt_u8 *) appdata;
    alt_u8 packetReceived;

    // Runs the non-blocking function once, checking if a packet was received
    packetReceived = codec_pus_get_recv_tc_nb(pCodecPUS, &recvInfo);

    // Increases the pkgs received by the isr
    packages_received_by_isr++;

    codec_pus_get_tms_sent_num(pCodecPUS);
    codec_pus_send_tm_nb(pCodecPUS, testTMSimulatedFIFO5[u8Itrt]);
    u8Itrt = (u8Itrt + 1) % 5;

    codec_pus_clear_recv_irq(pCodecPUS);

}


void test1_codec_pus_nominal_operation(t_codec_pus *pCodecPUS, FILE* uart_pointer){

    // Starts the test
    fprintf(uart_pointer, "Starting the Test #1 for the Nominal Codec PUS operation: Receiving TC packets and Sending TM packets using ISRs.\n");
    fprintf(uart_pointer, "Please, send TC packets to the Codec PUS to see the reception in action.\n");

    // Registers the ISR for receiving TC packets
    if(codec_pus_register_recv_isr(pCodecPUS, 4, test1_codec_pus_nominal_operation_recv_isr, (void*) pCodecPUS)){
        fprintf(uart_pointer, "ISR for receiving TC packets registered successfully. Please send TC packets to the Codec PUS.\n");
    } else {
        fprintf(uart_pointer, "Failed to register the ISR for receiving TC packets.\n");
        return;
    }

    // While Loop printing packages received
    while(1){
    	fprintf(uart_pointer, "Packages received by the isr: %u\n", packages_received_by_isr);
    	usleep(1*1000*1000);
    }

}

/* 
 *  Main task
 */
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
		// CODEC PUS TEST REPARTITION

		fprintf(fp, "Initializing codec_pus test...\n");

		// Initializes the codec pus config struct
		t_codec_pus_config o_codec_pus_config = {
				.u8CodecPusEn = 1,
				.u8CodecPusRecvEn = 1,
				.u8CodecPusSendEn = 1,
				.u8CodecPusIRQEn = 1,
				.u8CodecPusRecvIRQEn = 1,
				.u8CodecPusSendIRQEn = 1
		};

		// Initializes the DMA Config for the Send and Receive parts
		t_codec_pus_dma_config o_codec_pus_send_dma_config = {
				.u32DmaMemBaseAddr = 0x88000000,
				.u32DmaFifoSize    = 65536
		};
		t_codec_pus_dma_config o_codec_pus_recv_dma_config = {
				.u32DmaMemBaseAddr = 0x88000000 + 65536,
				.u32DmaFifoSize = 65536
		};

		// Initializes the codec pus general struct
		t_codec_pus codec_pus = {
				.u32CodecPUSBaseAddr    = 0x90000000,
				.oCodecPUSConfig        = o_codec_pus_config,
				.oCodecPUSRecvDmaConfig = o_codec_pus_recv_dma_config,
				.oCodecPUSSendDmaConfig = o_codec_pus_send_dma_config,
				.u32CurrentRecvDmaOffset = 0,
			    .u32CurrentSendDmaOffset = 0,
				.u32CurrentSendDmaAvailableSpace = 65536
		};

		// Initializes the codec_pus
		codec_pus_init(&codec_pus);

		// -------------------------- TEST FOR THE TC DRIVER FUNCTIONS --------------------------- //

		// Receives multiple tcs through a block operation
		// debug_receive_mult_tcs(&codec_pus, 10, fp);

		// Register ISR for receiving TCs
		// codec_pus_register_recv_isr(&codec_pus, 4, recv_ISR_function, (void*) &codec_pus);


		// -------------------------- TEST FOR THE TM DRIVER FUNCTIONS --------------------------- //

		// Sends multiple TMs through a block operation
		// debug_send_multiple_tms(&codec_pus, 10, fp);

		// alt_u8 app_data[65535] = {0};
		// alt_u32 u32Cont = 0;

		// for(u32Cont = 0; u32Cont < 65535; u32Cont++){
		//	app_data[u32Cont] = (alt_u8) u32Cont & 0b11111111;
			// fprintf(fp, "Value: %u\n", u32Cont);
		//}

		// t_codec_pus_tm_send_info tm_send;
		// tm_send.oPkgPrimHdr.u32PkgAppDataLen = 65535;
		// tm_send.pAppData = (alt_u8*) app_data;



		// codec_pus_clear_send_irq(&codec_pus);
		// codec_pus_send_tm_nb(&codec_pus, &tm_send);
		// usleep(6500);
		// fprintf(fp, "%u\n", (alt_u32) codec_pus_get_tms_sent_num(&codec_pus));
		// codec_pus_send_tm_nb(&codec_pus, &tm_send);
		// codec_pus_send_tm_nb(&codec_pus, &tm_send);
		// codec_pus_get_tms_sent_num(&codec_pus);
		//codec_pus_send_tm_nb(&codec_pus, &tm_send);
		// codec_pus_send_tm_nb(&codec_pus, &tm_send);
		// codec_pus_get_tms_sent_num(&codec_pus);

		// fprintf(fp, "%u\n", (alt_u32) codec_pus_get_tms_sent_num(&codec_pus));

		// debug_receive_mult_tcs(&codec_pus, 3, fp);
		// codec_pus_send_tm_b(&codec_pus, &tm_send, 100);

		// debug_send_multiple_tms(&codec_pus, 10, fp);

	    // codec_pus_register_send_isr(&codec_pus, 5, send_ISR_function, (void *) &codec_pus);

		test4_codec_pus_recv_tc(&codec_pus, fp);




		while (1) usleep(5*1000*1000); /* Correct Program Flow never gets here. */

	return -1;
}
