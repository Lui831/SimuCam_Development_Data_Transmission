/* ------------------------------------------------------------------------------------ */
// codec_pus_drivers.h
// Description: This file constains the definitions, macros, structures and prototypes
// for the codec PUS driver functions.
// Authors: Luiz H. A. Santos, Rafaella A. C. Zeron, Pedro A. W. Dian, João P. Fogetti, 
// Rodrigo M. França
// Date: 26/08/2025
/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
// Include libraries

#include <stdio.h>
#include "alt_types.h"
#include "system.h"
#include "sys/alt_irq.h"
#include "../../HAL/inc/io.h"

/* ------------------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------------------ */
// Codec PUS General constants

// Constant for defining an OK Received PKG from the status bits
#define CODEC_PUS_OK_TC_STATUS 0x0
#define CODEC_PUS_OK_TC_EXT_PROTOCOL_STATUS 0x0

// Enum for defining the error values for the Codec PUS status bits
typedef enum{
    CODEC_PUS_NO_ERR = 0,
    CODEC_PUS_VER_NUM_ERR = 1,
    CODEC_PUS_TYPE_ERR    = 2,
    CODEC_PUS_SEC_HDR_FLAG_ERR = 3,
    CODEC_PUS_SEQ_ERR          = 4,
    CODEC_PUS_PUSVNUM_ERR      = 5,
    CODEC_PUS_SERVICE_ID_ERR   = 6,
    CODEC_PUS_CRC_ERR          = 7,
    CODEC_PUS_EOP_ERR          = 8
} t_codec_pus_status_err_enum;

// Enum for defning the error values for the Codec PUS ext protocol status bits
typedef enum{
    CODEC_PUS_EXT_PROT_NO_ERR = 0,
    CODEC_PUS_EXT_PROT_ADDR_ERR = 1,
    CODEC_PUS_EXT_PROT_PROT_ID_ERR = 2
} t_codec_pus_ext_prot_status_err_enum;

// Determines the TIME field size, in bytes
#define CODEC_PUS_TIME_FIELD_SIZE 7

// Defines the maximum size of the Codec PUS Recv and Send Header Stack fifos
#define CODEC_PUS_RECV_HEADER_STACK_SIZE 1024
#define CODEC_PUS_SEND_HEADER_STACK_SIZE 1024

// Defines the maximum size of the application data
#define CODEC_PUS_MAX_APP_DATA_LEN 65536 - 1

/* ------------------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------------------ */
// Codec PUS related structures

// Codec PUS config struct
typedef struct t_codec_pus_config{

	// Codec PUS General Enable
	alt_u8 u8CodecPusEn;

    // Codec PUS enable for recv and send
    alt_u8 u8CodecPusRecvEn;
    alt_u8 u8CodecPusSendEn;

    // Codec PUS general irq en
    alt_u8 u8CodecPusIRQEn;

    // Codec PUS enable for recv and send irq
    alt_u8 u8CodecPusRecvIRQEn;
    alt_u8 u8CodecPusSendIRQEn;

} t_codec_pus_config;


// Codec PUS DMA config struct
typedef struct t_codec_pus_dma_config{

    // Base address of the DMA memory
    alt_u32 u32DmaMemBaseAddr;

    // Size of the DMA FIFO, in bytes
    alt_u32 u32DmaFifoSize;

} t_codec_pus_dma_config;


// Codec PUS External Protocol Config (SpW)
typedef struct t_codec_pus_ext_protocol_config{

    // SpW address of the node
    alt_u8 u8CodecPusSpWADDR;

} t_codec_pus_ext_protocol_config;

// Codec PUS General Struct
typedef struct t_codec_pus{

    // Base address of the Codec PUS
    alt_u32 u32CodecPUSBaseAddr;

    // Codec PUS config struct
    t_codec_pus_config oCodecPUSConfig;

    // Codec PUS Recv DMA struct
    t_codec_pus_dma_config oCodecPUSRecvDmaConfig;

    // Codec PUS Send DMA struct
    t_codec_pus_dma_config oCodecPUSSendDmaConfig;

    // Current offset for the recv DMA
    alt_u32 u32CurrentRecvDmaOffset;

    // Current offset and available space (in bytes) for the send DMA
    alt_u32 u32CurrentSendDmaOffset;
    alt_u32 u32CurrentSendDmaAvailableSpace;

    // External Protocol Config (SpW)
    t_codec_pus_ext_protocol_config oCodecPUSExtProtocolConfig;

} t_codec_pus;


// Codec PUS PKG_PRIM_HDR struct
typedef struct t_codec_pus_pkg_prim_hdr{

    // Pkg Version Number (3 bits)
    alt_u8 u8PkgVersionNumber;

    // Pkg Type (1 bit)
    alt_u8 u8PkgType;

    // Pkg Sec Hdr Flag (1 bit)
    alt_u8 u8PkgSecHdrFlag;

    // APID (11 bits)
    alt_u16 u16APID;

    // Pkg Seq flags (2 bits)
    alt_u8 u8PkgSeqFlags;

    // Pkg Seq Count (14 bits)
    alt_u16 u16PkgSeqCount;

    // Pkg App data len (32 bits)
    alt_u32 u32PkgAppDataLen;

} t_codec_pus_pkg_prim_hdr;


// Codec PUS TC PKG_SEC_HDR struct
typedef struct t_codec_pus_tc_pkg_sec_hdr{

    // PUS Version Number (4 bits)
    alt_u8 u8PUSVersionNumber;

    // Ack flags (4 bits)
    alt_u8 u8AckFlags;

    // Service ID (8 bits)
    alt_u8 u8ServiceID;

    // Subservice ID (8 bits)
    alt_u8 u8SubserviceID;

    // Source ID (16 bits)
    alt_u16 u16SourceID;

} t_codec_pus_tc_pkg_sec_hdr;


// Codec PUS TM PKG_SEC_HDR struct
typedef struct t_codec_pus_tm_pkg_sec_hdr{

    // Spacecraft Time Ref Status (4 bits)
    alt_u8 u8SpacecraftTimeRefStatus;

    // Service ID (8 bits)
    alt_u8 u8ServiceID;

    // Subservice ID (8 bits)
    alt_u8 u8SubserviceID;

    // Message type counter (16 bits)
    alt_u16 u16MessageTypeCounter;

    // Dest ID (16 bits)
    alt_u16 u16DestID;

    // Time
    alt_u8 u8Time[CODEC_PUS_TIME_FIELD_SIZE];

} t_codec_pus_tm_pkg_sec_hdr;


// Codec PUS TC External Protocol Info
typedef struct t_codec_pus_tc_ext_protocol_info{

    // Received SpW Addr
    alt_u8 u8SpWADDR;

    // Received Ext Protocol Status flags
    alt_u8 u8SpWStatusBits;

} t_codec_pus_tc_ext_protocol_info;


// Codec PUS TM External Protocol Info
typedef struct t_codec_pus_tm_ext_protocol_info{

    // Send SpW Addr
    alt_u8 u8SpWADDR;

} t_codec_pus_tm_ext_protocol_info;

// Codec PUS TC headers struct + App data definition
typedef struct t_codec_pus_tc_recv_info{

    // Received PKG_PRIM_HDR
    t_codec_pus_pkg_prim_hdr oPkgPrimHdr;

    // Received PKG_SEC_HDR
    t_codec_pus_tc_pkg_sec_hdr oPkgSecHdr;

    // Package address
    alt_u32 u32PkgAddr;

    // Status bits
    alt_u8 u8StatusBits;

    // Pointer to the App data already initialized
    alt_u8* pAppData;

    // External Protocol Info (SpW)
    t_codec_pus_tc_ext_protocol_info oExtProtocolInfo;

} t_codec_pus_tc_recv_info;


// Codec PUS TM headers struct + App data definition
typedef struct t_codec_pus_tm_send_info{

    // To be sent PKG_PRIM_HDR
    t_codec_pus_pkg_prim_hdr oPkgPrimHdr;

    // To be sent PKG_SEC_HDR
    t_codec_pus_tm_pkg_sec_hdr oPkgSecHdr;

    // Package address
    alt_u32 u32PkgAddr;

    // Pointer to the App data already initialized
    alt_u8* pAppData;

    // External Protocol Info (SpW)
    t_codec_pus_tm_ext_protocol_info oExtProtocolInfo;

} t_codec_pus_tm_send_info;


/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
// Defines and Macros for the Codec PUS

// Defines for the Offset regs
#define CODEC_PUS_CNTRL_REG_OFFSET 0

#define CODEC_PUS_RECV_PKG_PRIM_HDR1_REG_OFFSET 4
#define CODEC_PUS_RECV_PKG_PRIM_HDR2_REG_OFFSET 8
#define CODEC_PUS_RECV_PKG_SEC_HDR1_REG_OFFSET 12
#define CODEC_PUS_RECV_PKG_SEC_HDR2_REG_OFFSET 16
#define CODEC_PUS_RECV_PKG_ADDR_REG_OFFSET 20
#define CODEC_PUS_RECV_PKG_STATUS_REG_OFFSET 24
#define CODEC_PUS_RECV_PKG_EXTRA_INFO_REG_OFFSET 28

#define CODEC_PUS_SEND_PKG_PRIM_HDR_REG_OFFSET 32
#define CODEC_PUS_SEND_PKG_PRIM_HDR2_REG_OFFSET 36
#define CODEC_PUS_SEND_PKG_SEC_HDR1_REG_OFFSET 40
#define CODEC_PUS_SEND_PKG_SEC_HDR2_REG_OFFSET 44
#define CODEC_PUS_SEND_PKG_SEC_HDR3_REG_OFFSET 48
#define CODEC_PUS_SEND_PKG_SEC_HDR4_REG_OFFSET 52
#define CODEC_PUS_SEND_PKG_ADDR_REG_OFFSET 56
#define CODEC_PUS_SEND_PKG_EXTRA_INFO_REG_OFFSET 60

#define CODEC_PUS_SEND_HANDLING_REG_OFFSET 64
#define CODEC_PUS_RECV_HANDLING_REG_OFFSET 68

#define CODEC_PUS_RECV_DMA_MEM_OFFSET_REG_OFFSET 72
#define CODEC_PUS_RECV_DMA_FIFO_SIZE_REG_OFFSET 76

#define CODEC_PUS_SEND_DMA_MEM_OFFSET_REG_OFFSET 80
#define CODEC_PUS_SEND_DMA_FIFO_SIZE_REG_OFFSET 84

#define CODEC_PUS_EXT_PROTOCOL_INFO_REG_OFFSET 88


// Defines important flags and default value for the cntrl register
#define CODEC_PUS_CNTRL_REG_PROC_RST_MASK 0x1 << 0
#define CODEC_PUS_CNTRL_REG_PROC_RST_OFFSET 0

#define CODEC_PUS_CNTRL_REG_EN_MASK 0x1 << 1
#define CODEC_PUS_CNTRL_REG_EN_OFFSET 1

#define CODEC_PUS_CNTRL_REG_RECV_EN_MASK 0x1 << 2
#define CODEC_PUS_CNTRL_REG_RECV_EN_OFFSET 2

#define CODEC_PUS_CNTRL_REG_SEND_EN_MASK 0x1 << 3
#define CODEC_PUS_CNTRL_REG_SEND_EN_OFFSET 3

#define CODEC_PUS_CNTRL_REG_IRQ_EN_MASK 0x1 << 4
#define CODEC_PUS_CNTRL_REG_IRQ_EN_OFFSET 4

#define CODEC_PUS_CNTRL_REG_RECV_IRQ_EN_MASK 0x1 << 5
#define CODEC_PUS_CNTRL_REG_RECV_IRQ_EN_OFFSET 5

#define CODEC_PUS_CNTRL_REG_SEND_IRQ_EN_MASK 0x1 << 6
#define CODEC_PUS_CNTRL_REG_SEND_IRQ_EN_OFFSET 6


// Defines important flags and default value for the RECV_PKG_PRIM_HDR1
#define CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_VERNUM_MASK   0x7        // bits 2:0
#define CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_VERNUM_OFFSET 0

#define CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_TYPE_MASK     0x8        // bit 3
#define CODEC_PUS_RECV_PKG_PRIM_HDR1_PKG_TYPE_OFFSET   3

#define CODEC_PUS_RECV_PKG_PRIM_HDR1_SEC_HDR_FLAG_MASK 0x10       // bit 4
#define CODEC_PUS_RECV_PKG_PRIM_HDR1_SEC_HDR_FLAG_OFFSET 4

#define CODEC_PUS_RECV_PKG_PRIM_HDR1_APID_MASK         0xFFE0     // bits 15:5
#define CODEC_PUS_RECV_PKG_PRIM_HDR1_APID_OFFSET       5

#define CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_FLAGS_MASK    0x30000    // bits 17:16
#define CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_FLAGS_OFFSET  16

#define CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_COUNT_MASK    0xFFFC0000 // bits 31:18
#define CODEC_PUS_RECV_PKG_PRIM_HDR1_SEQ_COUNT_OFFSET  18


// Defines important flags and default value for the RECV_PKG_PRIM_HDR2
#define CODEC_PUS_RECV_PKG_PRIM_HDR2_PKG_DATA_LEN_MASK 0xFFFF      // bits 15:0
#define CODEC_PUS_RECV_PKG_PRIM_HDR2_PKG_DATA_LEN_OFFSET 0


// Defines important flags for the RECV_PKG_SEC_HDR1
#define CODEC_PUS_RECV_PKG_SEC_HDR1_PUSVNUM_MASK      0xF        // bits 3:0
#define CODEC_PUS_RECV_PKG_SEC_HDR1_PUSVNUM_OFFSET    0

#define CODEC_PUS_RECV_PKG_SEC_HDR1_ACK_FLAGS_MASK    0xF0       // bits 7:4
#define CODEC_PUS_RECV_PKG_SEC_HDR1_ACK_FLAGS_OFFSET  4

#define CODEC_PUS_RECV_PKG_SEC_HDR1_SERVICE_ID_MASK   0xFF00     // bits 15:8
#define CODEC_PUS_RECV_PKG_SEC_HDR1_SERVICE_ID_OFFSET 8

#define CODEC_PUS_RECV_PKG_SEC_HDR1_SUBSERVICE_ID_MASK   0xFF0000    // bits 23:16
#define CODEC_PUS_RECV_PKG_SEC_HDR1_SUBSERVICE_ID_OFFSET 16


// Defines important flags for the RECV_PKG_SEC_HDR2
#define CODEC_PUS_RECV_PKG_SEC_HDR2_SOURCE_ID_MASK    0xFFFF      // bits 15:0
#define CODEC_PUS_RECV_PKG_SEC_HDR2_SOURCE_ID_OFFSET  0


// Define important flags for the RECV_PKG_ADDR
#define CODEC_PUS_RECV_PKG_ADDR_PKG_ADDR_MASK         0xFFFFFFFF  // bits 31:0
#define CODEC_PUS_RECV_PKG_ADDR_PKG_ADDR_OFFSET       0


// Define important flags for the RECV_STATUS
#define CODEC_PUS_RECV_STATUS_STATUS_FLAGS_MASK       0xFF        // bits 7:0
#define CODEC_PUS_RECV_STATUS_STATUS_FLAGS_OFFSET     0


// Define important flags for the RECV_EXTRA_INFO
#define CODEC_PUS_RECV_EXTRA_INFO_SPW_ADDR_MASK 0xFF // bits 7:0
#define CODEC_PUS_RECV_EXTRA_INFO_SPW_ADDR_OFFSET 0

#define CODEC_PUS_RECV_EXTRA_INFO_STATUS_MASK 0xFF00 //bits 15:8
#define CODEC_PUS_RECV_EXTRA_INFO_STATUS_OFFSET 8


// Defines important flags and default value for the SEND_PKG_PRIM_HDR
#define CODEC_PUS_SEND_PKG_PRIM_HDR1_APID_MASK 0x7FF       // bits 10:0
#define CODEC_PUS_SEND_PKG_PRIM_HDR1_APID_OFFSET 0

#define CODEC_PUS_SEND_PKG_PRIM_HDR1_PKG_DATA_LEN_MASK 0x7FFFF800  // bits 26:11
#define CODEC_PUS_SEND_PKG_PRIM_HDR1_PKG_DATA_LEN_OFFSET 11


// Defines important flags and default values for the SEND_PKG_PRIM_HDR2
#define CODEC_PUS_SEND_PKG_PRIM_HDR2_SEQ_COUNT_MASK 0x3FFF      // bits 13:0
#define CODEC_PUS_SEND_PKG_PRIM_HDR2_SEQ_COUNT_OFFSET 0


// Defines important flags and default values for the SEND_PKG_SEC_HDR1
#define CODEC_PUS_SEND_PKG_SEC_HDR1_SPACECRAFT_TIME_REF_MASK 0xF      // bits 3:0
#define CODEC_PUS_SEND_PKG_SEC_HDR1_SPACECRAFT_TIME_REF_OFFSET 0

#define CODEC_PUS_SEND_PKG_SEC_HDR1_SERVICE_ID_MASK   0xFF0      // bits 11:4
#define CODEC_PUS_SEND_PKG_SEC_HDR1_SERVICE_ID_OFFSET 4

#define CODEC_PUS_SEND_PKG_SEC_HDR1_SUBSERVICE_ID_MASK   0xFF000    // bits 19:12
#define CODEC_PUS_SEND_PKG_SEC_HDR1_SUBSERVICE_ID_OFFSET 12


// Defines important flags and default values for the SEND_PKG_SEC_HDR2
#define CODEC_PUS_SEND_PKG_SEC_HDR2_MSG_TYPE_COUNTER_MASK 0xFFFF      // bits 15:0
#define CODEC_PUS_SEND_PKG_SEC_HDR2_MSG_TYPE_COUNTER_OFFSET 0

#define CODEC_PUS_SEND_PKG_SEC_HDR2_DEST_ID_MASK      0xFFFF0000  // bits 31:16
#define CODEC_PUS_SEND_PKG_SEC_HDR2_DEST_ID_OFFSET    16


// Defines important flags and default values for the SEND_PKG_SEC_HDR3
#define CODEC_PUS_SEND_PKG_SEC_HDR3_TIME_MASK         0xFFFFFFFF      // bits 31:0
#define CODEC_PUS_SEND_PKG_SEC_HDR3_TIME_OFFSET       0


// Defines important flags and default values for the SEND_PKG_SEC_HDR4
#define CODEC_PUS_SEND_PKG_SEC_HDR4_TIME_EXT_MASK 0xFFFFFF // bits 23:0
#define CODEC_PUS_SEND_PKG_SEC_HDR4_TIME_EXT_OFFSET 0


// Defines important flags and default values for the SEND_PKG_ADDR
#define CODEC_PUS_SEND_PKG_ADDR_PKG_ADDR_MASK         0xFFFFFFFF  // bits 31:0
#define CODEC_PUS_SEND_PKG_ADDR_PKG_ADDR_OFFSET       0


// Defines important flags and default values for the SEND_PKG_EXTRA_INFO
#define CODEC_PUS_SEND_PKG_EXTRA_INFO_SPW_ADDR_MASK 0xFF
#define CODEC_PUS_SEND_PKG_EXTRA_INFO_SPW_ADDR_OFFSET 0


// Defines important flags and default values for the SEND_HANDLING
#define CODEC_PUS_SEND_HANDLING_IRQ_SEND_CLR_MASK          0x1         // bit 0
#define CODEC_PUS_SEND_HANDLING_IRQ_SEND_CLR_OFFSET        0

#define CODEC_PUS_SEND_HANDLING_DATA_SEND_SUCCESS_FLAGS_MASK 0x1FE      // bits 8:1
#define CODEC_PUS_SEND_HANDLING_DATA_SEND_SUCCESS_FLAGS_OFFSET 1

#define CODEC_PUS_SEND_HANDLING_DATA_SEND_WR_FLAG_MASK     0x200       // bit 9
#define CODEC_PUS_SEND_HANDLING_DATA_SEND_WR_FLAG_OFFSET 9

#define CODEC_PUS_SEND_HANDLING_DATA_SEND_RDY_FLAG_MASK    0x400       // bit 9
#define CODEC_PUS_SEND_HANDLING_DATA_SEND_RDY_FLAG_OFFSET  10


// Defines important flags and default values for the RECV_HANDLING
#define CODEC_PUS_RECV_HANDLING_IRQ_RCV_CLR_MASK           0x1         // bit 0
#define CODEC_PUS_RECV_HANDLING_IRQ_RCV_CLR_OFFSET         0

#define CODEC_PUS_RECV_HANDLING_DATA_RCV_RD_FLAG_MASK      0x2         // bit 1
#define CODEC_PUS_RECV_HANDLING_DATA_RCV_RD_FLAG_OFFSET    1

#define CODEC_PUS_RECV_HANDLING_DATA_RCV_RDY_FLAG_MASK     0x4         // bit 2
#define CODEC_PUS_RECV_HANDLING_DATA_RCV_RDY_FLAG_OFFSET   2


// Defines important flags and default values for the RECV_MEM_OFFSET
#define CODEC_PUS_RECV_MEM_OFFSET_MEM_OFFSET_MASK     0xFFFFFFFF  // bits 31:0
#define CODEC_PUS_RECV_MEM_OFFSET_MEM_OFFSET_OFFSET   0


// Defines important flags and default values for the RECV_FIFO_SIZE
#define CODEC_PUS_RECV_FIFO_SIZE_FIFO_SIZE_MASK       0xFFFFFFFF  // bits 31:0
#define CODEC_PUS_RECV_FIFO_SIZE_FIFO_SIZE_OFFSET     0


// Defines important flags and default values for the SEND_MEM_OFFSET
#define CODEC_PUS_SEND_MEM_OFFSET_MEM_OFFSET_MASK     0xFFFFFFFF  // bits 31:0
#define CODEC_PUS_SEND_MEM_OFFSET_MEM_OFFSET_OFFSET   0


// Defines important flags and default values for the SEND_FIFO_SIZE
#define CODEC_PUS_SEND_FIFO_SIZE_FIFO_SIZE_MASK       0xFFFFFFFF  // bits 31:0
#define CODEC_PUS_SEND_FIFO_SIZE_FIFO_SIZE_OFFSET     0


// Defines important flags and default values for the EXT_PROTOCOL_INFO
#define CODEc_PUS_EXT_PROTOCOL_INFO_SPW_ADDR_MASK 0xFF
#define CODEC_PUS_EXT_PROTOCOL_INFO_SPW_ADDR_OFFSET 0


// Defines important macros for setting, resetting and reading a general register
#define CODEC_PUS_REG_SET(u32CodecPUSOffset, u32CodecPUSRegOffset, u32Val)          \
    do {                                                            \
        alt_u32 tempVal = IORD(u32CodecPUSOffset, u32CodecPUSRegOffset / 4); \
        tempVal |= u32Val;                                          \
        IOWR(u32CodecPUSOffset, u32CodecPUSRegOffset / 4, tempVal); \
    } while (0)

#define CODEC_PUS_REG_RESET(u32CodecPUSOffset, u32CodecPUSRegOffset, u32Val)        \
    do {                                                            \
        alt_u32 tempVal = IORD(u32CodecPUSOffset, u32CodecPUSRegOffset / 4); \
        tempVal &= ~u32Val;                                         \
        IOWR(u32CodecPUSOffset, u32CodecPUSRegOffset / 4, tempVal); \
    } while (0)

#define CODEC_PUS_REG_READ(u32CodecPUSOffset, u32CodecPUSRegOffset, u32Val)          \
    (u32Val = IORD(u32CodecPUSOffset, u32CodecPUSRegOffset / 4))

#define CODEC_PUS_REG_WRITE(u32CodecPUSOffset, u32CodecPUSRegOffset, u32Val)         \
    (IOWR(u32CodecPUSOffset, u32CodecPUSRegOffset / 4, u32Val))


/* ------------------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------------------ */
// Defines important prototypes for the functions


// Functions to control and interact with the Codec PUS, also for reading and providing data to it's DMA

// Function to initialize the Codec PUS and it's DMAs
void codec_pus_init(t_codec_pus *pCodecPUS); // Returns void

// Functions to configure and to reset the Codec PUS
void codec_pus_config(t_codec_pus *pCodecPUS); // Returns void
void codec_pus_reset(t_codec_pus *pCodecPUS); // Returns void

// Functions to write and to read to and from the Codec PUS DMA FIFOs
void codec_pus_write_send_dma(t_codec_pus *pCodecPUS, alt_u8* pAppData, alt_u32 u32AppDataLen);
void codec_pus_read_recv_dma(t_codec_pus *pCodecPUS, alt_u8* pAppData, alt_u32 u32AppDataLen);

// Functions to get a received TC packet from the Codec PUS
alt_u8 codec_pus_get_recv_tc_nb(t_codec_pus *pCodecPUS, t_codec_pus_tc_recv_info *pRecvInfo); // Non-blocking, returns 1 if a packet was received, 0 otherwise
void codec_pus_get_recv_tc_b(t_codec_pus *pCodecPUS, t_codec_pus_tc_recv_info *pRecvInfo, alt_u32 u32TimeIncrement); // Blocking, returns void
alt_u8 codec_pus_rdy_for_recv_tc(t_codec_pus *pCodecPUS); // Returns 1 if a packet is ready to be read, 0 otherwise

alt_u8 codec_pus_register_recv_isr(t_codec_pus *pCodecPUS, alt_u32 u32IRQId, void *pCallback, void *pContext); // Registers an ISR for the Codec PUS recv IRQ, returns 1 if successful, 0 otherwise
void codec_pus_clear_recv_irq(t_codec_pus *pCodecPUS); // Clears the Codec PUS recv IRQ

// Functions to send a TM packet through the Codec PUS
alt_u8 codec_pus_send_tm_nb(t_codec_pus *pCodecPUS, t_codec_pus_tm_send_info *pSendInfo); // Non-blocking, doesn't wait for the packet to be actually sent. // TODO: add flag to inform if the Codec PUS is ready to send TMs
void codec_pus_send_tm_b(t_codec_pus *pCodecPUS, t_codec_pus_tm_send_info *pSendInfo, alt_u32 u32TimeIncrement); // Blocking, waits for the packet to be actually sent
alt_u8 codec_pus_rdy_for_send_tm(t_codec_pus *pCodecPUS); // Returns 1 if the Codec PUS is ready to send a packet, 0 otherwise
alt_u8 codec_pus_get_tms_sent_num(t_codec_pus *pCodecPUS); // Returns the number of TMs sent by the last iteration

alt_u8 codec_pus_register_send_isr(t_codec_pus *pCodecPUS, alt_u32 u32IRQId, void *pCallback, void *pContext); // Registers an ISR for the Codec PUS send IRQ, returns 1 if successful, 0 otherwise
void codec_pus_clear_send_irq(t_codec_pus *pCodecPUS); // Clears the Codec PUS send IRQ



/* ------------------------------------------------------------------------------------ */

