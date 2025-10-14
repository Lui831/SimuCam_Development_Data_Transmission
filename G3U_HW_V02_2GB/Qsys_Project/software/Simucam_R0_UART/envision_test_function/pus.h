/*
--------------------------------------------------------------------------------------------------------------
-> Name: pus.h
-> Authors: João P. C. Fogetti, Luiz H. A. Santos, Pedro A. W. Dian, Rodrigo M. Franca, Sergio R. Augusto.
-> Date: 09-10-2025
-> Description: library for defining PUS structures and commands.
--------------------------------------------------------------------------------------------------------------
*/

#ifndef _PUS_
#define _PUS_

/* ------------------------------------------------------------------------------------------------------------- */
// Includes

#include "alt_types.h"
#include "vesm_tm_defs.h"
#include "vesm_tc_defs.h"


/* ------------------------------------------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------------------------------------------- */
// Protocol customization

#define TM_TIME_BYTE_SIZE 7
#define TC_SPARE_BYTE_SIZE 1

#define PUS_APP_DATA_MAX_SIZE 655353
#define PUS_SERVICES_MAX_SIZE 255


/* ------------------------------------------------------------------------------------------------------------- */


/* ------------------------------------------------------------------------------------------------------------- */
// General structs

// PKG_PRIM_HDR struct
typedef struct t_pus_pkg_prim_hdr{

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

} t_pus_pkg_prim_hdr;


// Codec PUS TC PKG_SEC_HDR struct
typedef struct t_pus_tc_pkg_sec_hdr{

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

} t_pus_tc_pkg_sec_hdr;


// Codec PUS TM PKG_SEC_HDR struct
typedef struct t_pus_tm_pkg_sec_hdr{

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
    alt_u8 u8Time[TM_TIME_BYTE_SIZE];

} t_pus_tm_pkg_sec_hdr;


// Codec PUS TC External Protocol Info
typedef struct t_pus_tc_ext_protocol_info{

    // Received SpW Addr
    alt_u8 u8SpWADDR;

    // Received Ext Protocol Status flags
    alt_u8 u8SpWStatusBits;

} t_pus_tc_ext_protocol_info;


// Codec PUS TM External Protocol Info
typedef struct t_pus_tm_ext_protocol_info{

    // Send SpW Addr
    alt_u8 u8SpWADDR;

} t_pus_tm_ext_protocol_info;


// Codec PUS TC headers struct + App data definition
typedef struct t_pus_tc_recv_info{

    // Received PKG_PRIM_HDR
    t_pus_pkg_prim_hdr oPkgPrimHdr;

    // Received PKG_SEC_HDR
    t_pus_tc_pkg_sec_hdr oPkgSecHdr;

    // Package address
    alt_u32 u32PkgAddr;

    // Status bits
    alt_u8 u8StatusBits;

    // Pointer to the App data already initialized
    alt_u8* pAppData;

    // External Protocol Info (SpW)
    t_pus_tc_ext_protocol_info oExtProtocolInfo;

} t_pus_tc_recv_info;


// Codec PUS TM headers struct + App data definition
typedef struct t_pus_tm_send_info{

    // To be sent PKG_PRIM_HDR
    t_pus_pkg_prim_hdr oPkgPrimHdr;

    // To be sent PKG_SEC_HDR
    t_pus_tm_pkg_sec_hdr oPkgSecHdr;

    // Package address
    alt_u32 u32PkgAddr;

    // Pointer to the App data already initialized
    alt_u8* pAppData;

    // External Protocol Info (SpW)
    t_pus_tm_ext_protocol_info oExtProtocolInfo;

} t_pus_tm_send_info;


/* ------------------------------------------------------------------------------------------------------------- */


/* ------------------------------------------------------------------------------------------------------------- */
// Service #1 Types and Functions - Especified to the VESM use case

// TM OK (TM(1,1) and TM(1,7))
typedef struct t_pus_tm_1_1_app_data{

    alt_u8 u8PkgVerNum;

    // Fields for the PKG ID
    alt_u8 u8PkgType;
    alt_u8 u8SecHdrFlag;
    alt_u16 u16APID;

    // Fields for the PKG Seq control
    alt_u8 u8SeqFlags;
    alt_u16 u16PkgSeqCount;

} t_pus_tm_1_1_app_data, t_pus_tm_1_7_app_data;

// Defines prototypes for generating the app data for these TMs
void pus_tm_1_1_gen_app_data(t_pus_tm_1_1_app_data oBaseStruct, alt_u8* pAppData);
void pus_tm_1_7_gen_app_data(t_pus_tm_1_7_app_data oBaseStruct, alt_u8* pAppData);

// TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_INCOMPLETE
typedef struct t_pus_tm_1_2_ack_fail_incomplete_app_data{

    alt_u8 u8PkgVerNum;

    // Fields for the PKG ID
    alt_u8 u8PkgType;
    alt_u8 u8SecHdrFlag;
    alt_u16 u16APID;

    // Fields for the PKG Seq control
    alt_u8 u8SeqFlags;
    alt_u16 u16PkgSeqCount;

    // Specifics for this payload
    alt_u8 u8VESMDeviceID;
    alt_u32 u32VESMAcceptErrID;
    alt_u8 u8VESMServiceType;
    alt_u8 u8VESMServiceSubtype;
    alt_u32 u32VESMSourceID;
    alt_u16 u16VESMCRCReceived;
    alt_u16 u16VESMLenReceived;
    alt_u16 u16VESMLenExpected;

} t_pus_tm_1_2_ack_fail_incomplete_app_data;

// Defines prototypes for generating the app_data for this TM
void pus_tm_1_2_ack_fail_incomplete_gen_app_data(t_pus_tm_1_2_ack_fail_incomplete_app_data oBaseStruct, alt_u8* pAppData);

// TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_NOT_CCSDS; TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_WRONG_APID, TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_WRONG_PACKET_FORMAT,
// TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_WRONG_PACKET_TYPE, TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_WRONG_SOURCE_ID, TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_WRONG_SUBTYPE,
// TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_WRONG_TYPE
typedef struct t_pus_tm_1_2_ack_fail_notccsds_app_data{

    alt_u8 u8PkgVerNum;

    // Fields for the PKG ID
    alt_u8 u8PkgType;
    alt_u8 u8SecHdrFlag;
    alt_u16 u16APID;

    // Fields for the PKG Seq control
    alt_u8 u8SeqFlags;
    alt_u16 u16PkgSeqCount;

    // Specifics for this payload
    alt_u8 u8VESMDeviceID;
    alt_u32 u32VESMAcceptErrID;
    alt_u8 u8VESMServiceType;
    alt_u8 u8VESMServiceSubtype;
    alt_u32 u32VESMSourceID;
    alt_u16 u16VESMCRCReceived;

} t_pus_tm_1_2_ack_fail_notccsds_app_data, t_pus_tm_1_2_ack_fail_wrongapid_app_data, t_pus_tm_1_2_ack_fail_wrongpkgformat_app_data,
  t_pus_tm_1_2_ack_fail_wrongpkgtype_app_data, t_pus_tm_1_2_ack_fail_wrongsrcid_app_data, t_pus_tm_1_2_ack_fail_wrongsubtype_app_data,
  t_pus_tm_1_2_ack_fail_wrongtype_app_data;

// Defines prototypes for generating app_data for these TMs
void pus_tm_1_2_ack_fail_notccsds_gen_app_data(t_pus_tm_1_2_ack_fail_notccsds_app_data oBaseStruct, alt_u8* pAppData);
void pus_tm_1_2_ack_fail_wrongapid_gen_app_data(t_pus_tm_1_2_ack_fail_wrongapid_app_data oBaseStruct, alt_u8* pAppData);
void pus_tm_1_2_ack_fail_wrongpkgformat_gen_app_data(t_pus_tm_1_2_ack_fail_wrongpkgformat_app_data oBaseStruct, alt_u8* pAppData);
void pus_tm_1_2_ack_fail_wrongpkgtype_gen_app_data(t_pus_tm_1_2_ack_fail_wrongpkgtype_app_data oBaseStruct, alt_u8* pAppData);
void pus_tm_1_2_ack_fail_wrongsrcid_gen_app_data(t_pus_tm_1_2_ack_fail_wrongsrcid_app_data oBaseStruct, alt_u8* pAppData);
void pus_tm_1_2_ack_fail_wrongsubtype_gen_app_data(t_pus_tm_1_2_ack_fail_wrongsubtype_app_data oBaseStruct, alt_u8* pAppData);
void pus_tm_1_2_ack_fail_wrongtype_gen_app_data(t_pus_tm_1_2_ack_fail_wrongtype_app_data oBaseStruct, alt_u8* pAppData);

// TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_WRONG_CRC
typedef struct t_pus_tm_1_2_ack_fail_wrongcrc_app_data{

    alt_u8 u8PkgVerNum;

    // Fields for the PKG ID
    alt_u8 u8PkgType;
    alt_u8 u8SecHdrFlag;
    alt_u16 u16APID;

    // Fields for the PKG Seq control
    alt_u8 u8SeqFlags;
    alt_u16 u16PkgSeqCount;

    // Specifics for this payload
    alt_u8 u8VESMDeviceID;
    alt_u32 u32VESMAcceptErrID;
    alt_u8 u8VESMServiceType;
    alt_u8 u8VESMServiceSubtype;
    alt_u32 u32VESMSourceID;
    alt_u16 u16VESMCRCReceived;
    alt_u16 u16VESMCRCExpected;

} t_pus_tm_1_2_ack_fail_wrongcrc_app_data;

// Defines prototype for generating app_data for this TM
void pus_tm_1_2_ack_fail_wrongcrc_gen_app_data(t_pus_tm_1_2_ack_fail_wrongcrc_app_data oBaseStruct, alt_u8* pAppData);

// TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_WRONG_EXECUTION_FLAGS
typedef struct t_pus_tm_1_2_ack_fail_wrongexecflags_app_data{

    alt_u8 u8PkgVerNum;

    // Fields for the PKG ID
    alt_u8 u8PkgType;
    alt_u8 u8SecHdrFlag;
    alt_u16 u16APID;

    // Fields for the PKG Seq control
    alt_u8 u8SeqFlags;
    alt_u16 u16PkgSeqCount;

    // Specifics for this payload
    alt_u8 u8VESMDeviceID;
    alt_u32 u32VESMAcceptErrID;
    alt_u8 u8VESMServiceType;
    alt_u8 u8VESMServiceSubtype;
    alt_u32 u32VESMSourceID;
    alt_u16 u16VESMCRCReceived;
    alt_u8 u8VESMAckFlags;

} t_pus_tm_1_2_ack_fail_wrongexecflags_app_data;

// Defines prototype for generating app_data for this TM
void pus_tm_1_2_ack_fail_wrongexecflags_gen_app_data(t_pus_tm_1_2_ack_fail_wrongexecflags_app_data oBaseStruct, alt_u8* pAppData);

// TM(1,2) VESM_R_TC_ACKNOWLEDGE_FAILURE_WRONG_PUS_VERSION
typedef struct t_pus_tm_1_2_ack_fail_wrongpusversion_app_data{

    alt_u8 u8PkgVerNum;

    // Fields for the PKG ID
    alt_u8 u8PkgType;
    alt_u8 u8SecHdrFlag;
    alt_u16 u16APID;

    // Fields for the PKG Seq control
    alt_u8 u8SeqFlags;
    alt_u16 u16PkgSeqCount;

    // Specifics for this payload
    alt_u8 u8VESMDeviceID;
    alt_u32 u32VESMAcceptErrID;
    alt_u8 u8VESMServiceType;
    alt_u8 u8VESMServiceSubtype;
    alt_u32 u32VESMSourceID;
    alt_u16 u16VESMCRCReceived;
    alt_u8 u8VESMVersion;

} t_pus_tm_1_2_ack_fail_wrongpusversion_app_data;

// Defines prototype for generating app_data for this TM
void pus_tm_1_2_ack_fail_wrongpusversion_app_data(t_pus_tm_1_2_ack_fail_wrongpusversion_app_data oBaseStruct, alt_u8* pAppData);

// TM(1,8) VESM_R_TC_EXECUTION_FAILURE_GENERIC
typedef struct t_pus_tm_1_8_exec_fail_gen_app_data{

    alt_u8 u8PkgVerNum;

    // Fields for the PKG ID
    alt_u8 u8PkgType;
    alt_u8 u8SecHdrFlag;
    alt_u16 u16APID;

    // Fields for the PKG Seq control
    alt_u8 u8SeqFlags;
    alt_u16 u16PkgSeqCount;

    // Specifics for this payload
    alt_u8 u8VESMDeviceID;
    alt_u32 u32VESMAcceptErrID;
    alt_u8 u8VESMServiceType;
    alt_u8 u8VESMServiceSubtype;
    alt_u32 u32VESMSourceID;
    alt_u16 u16VESMCRCReceived;
    alt_u32 u32VESMGenErrID;

} t_pus_tm_1_8_exec_fail_gen_app_data;

// Defines prototype for generating app_data for this TM
void pus_tm_1_8_exec_fail_gen_app_data(t_pus_tm_1_8_exec_fail_gen_app_data oBaseStruct, alt_u8* pAppData);

// TM(1,8) VESM_R_TC_EXECUTION_FAILURE_NOT_ALLOWED_IN_MODE
typedef struct t_pus_tm_1_8_exec_fail_notallowinmode_app_data{

    alt_u8 u8PkgVerNum;

    // Fields for the PKG ID
    alt_u8 u8PkgType;
    alt_u8 u8SecHdrFlag;
    alt_u16 u16APID;

    // Fields for the PKG Seq control
    alt_u8 u8SeqFlags;
    alt_u16 u16PkgSeqCount;

    // Specifics for this payload
    alt_u8 u8VESMDeviceID;
    alt_u32 u32VESMAcceptErrID;
    alt_u8 u8VESMServiceType;
    alt_u8 u8VESMServiceSubtype;
    alt_u32 u32VESMSourceID;
    alt_u16 u16VESMCRCReceived;
    alt_u16 u32VESMVESMMode;

} t_pus_tm_1_8_exec_fail_notallowinmode_app_data;

// Defines prototype for generating app_data for this TM
void pus_tm_1_8_exec_fail_notallowinmode_app_data(t_pus_tm_1_8_exec_fail_notallowinmode_app_data oBaseStruct, alt_u8* pAppData);

// TM(1,8) VESM_R_TC_EXECUTION_FAILURE_NOT_IMPLEMENTED, TM(1,8) VESM_R_TC_EXECUTION_FAILURE_WRONG_COMMAND_CODE
typedef struct t_pus_tm_1_8_exec_fail_notimplemented_app_data{

    alt_u8 u8PkgVerNum;

    // Fields for the PKG ID
    alt_u8 u8PkgType;
    alt_u8 u8SecHdrFlag;
    alt_u16 u16APID;

    // Fields for the PKG Seq control
    alt_u8 u8SeqFlags;
    alt_u16 u16PkgSeqCount;

    // Specifics for this payload
    alt_u8 u8VESMDeviceID;
    alt_u32 u32VESMAcceptErrID;
    alt_u8 u8VESMServiceType;
    alt_u8 u8VESMServiceSubtype;
    alt_u32 u32VESMSourceID;
    alt_u16 u16VESMCRCReceived;

} t_pus_tm_1_8_exec_fail_notimplemented_app_data, t_pus_tm_1_8_exec_fail_wrongcmdcode_app_data;

// Defines prototype for generating app_data for these TMs
void pus_tm_1_8_exec_fail_notimplemented_app_data(t_pus_tm_1_8_exec_fail_notimplemented_app_data oBaseStruct, alt_u8* pAppData);
void pus_tm_1_8_exec_fail_wrongcmdcode_app_data(t_pus_tm_1_8_exec_fail_wrongcmdcode_app_data oBaseStruct, alt_u8* pAppData);

// TM(1,8) VESM_R_TC_EXECUTION_FAILURE_WRONG_PARAMETER_VALUE
typedef struct t_pus_tm_1_8_exec_fail_wrongparamvalue_app_data{

    alt_u8 u8PkgVerNum;

    // Fields for the PKG ID
    alt_u8 u8PkgType;
    alt_u8 u8SecHdrFlag;
    alt_u16 u16APID;

    // Fields for the PKG Seq control
    alt_u8 u8SeqFlags;
    alt_u16 u16PkgSeqCount;

    // Specifics for this payload
    alt_u8 u8VESMDeviceID;
    alt_u32 u32VESMAcceptErrID;
    alt_u8 u8VESMServiceType;
    alt_u8 u8VESMServiceSubtype;
    alt_u32 u32VESMSourceID;
    alt_u16 u16VESMCRCReceived;
    alt_u16 u16VESMBitpos;
    alt_u32 u32ArrVESMValue[2];

} t_pus_tm_1_8_exec_fail_wrongparamvalue_app_data;

// Defines prototype for generating app_data for these TMs
void pus_tm_1_8_exec_fail_wrongparamvalue_app_data(t_pus_tm_1_8_exec_fail_wrongparamvalue_app_data oBaseStruct, alt_u8* pAppData);

/* ------------------------------------------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------------------------------------------- */
// Service #3 - Housekeeping

#define MAX_NUM_SIDS 65535

// TC(3,5) VESM_R_HK_ENABLE, TC(3,6) VESM_R_HK_DISABLE, TC(3,27) VESM_R_HK_ONE_SHOT_REQ, TC(3,33) VESM_R_REQ_HK_CONFIG
typedef struct t_pus_tc_3_5_app_data{

    // Addition of NUM_SIDS
    alt_u16 u16VESMNumSids;

    // Addition of DEVICE_ID and SID
    alt_u8 u8ArrVESMDeviceID[MAX_NUM_SIDS];
    alt_u8 u8ArrVESMSid[MAX_NUM_SIDS];

} t_pus_tc_3_5_app_data, t_pus_tc_3_6_app_data, t_pus_tc_3_27_app_data;

// Defines prototypes for parsing the app_data for these TCs
void pus_tc_3_5_parse_app_data(t_pus_tc_3_5_app_data* pResultStruct, alt_u8* pAppData);
void pus_tc_3_6_parse_app_data(t_pus_tc_3_6_app_data* pResultStruct, alt_u8* pAppData);
void pus_tc_3_27_parse_app_data(t_pus_tc_3_27_app_data* pResultStruct, alt_u8* pAppData);

// TC(3,31) VESM_R_SET_HK_PERIOD
typedef struct t_pus_tc_3_31_app_data{

    // Addition of NUM_SIDS
    alt_u16 u16VESMNumSids;

    // Addition of DEVICE_ID and SID
    alt_u8 u8ArrVESMDeviceID[MAX_NUM_SIDS];
    alt_u32 u32ArrVESMSid[MAX_NUM_SIDS];
    alt_u8 u8ArrVESMSidPeriod[MAX_NUM_SIDS];

} t_pus_tc_3_31_app_data;
 
// Defines prototype for parsing the app_data for this TC
void pus_tc_3_31_parse_app_data(t_pus_tc_3_31_app_data* pResultStruct, alt_u8* pAppData);

// TC(3,25) VESM_R_HK_ESSENTIAL_REPORT
typedef struct t_pus_tm_3_25_app_data{

    // Addition of DEVICE_ID, SID and MODE
    alt_u8 u8VESMDeviceID;
    alt_u32 u32VESMSid;
    alt_u8 u8VESMMode;


} t_pus_tm_3_25_app_data;

// Defines prototype for generating the app_data for this TM
void pus_tm_3_25_gen_app_data(t_pus_tm_3_25_app_data oBaseStruct, alt_u8* pAppData);

// TM(3,35) VESM_R_HK_CONFIGURATION_REPORT
typedef struct t_pus_tm_3_35_app_data{

    // Addition of NUM_SIDS
    alt_u16 u16VESMNumSids;
    
    // Addition of DEVICE_ID, SID and MODE
    alt_u8 u8VESMDeviceID[MAX_NUM_SIDS];
    alt_u32 u32VESMSid[MAX_NUM_SIDS];
    alt_u8 u8VESMMode[MAX_NUM_SIDS];

    // Addition of SID_PERIOD
    alt_u16 u16VESMSidPeriod[MAX_NUM_SIDS];

} t_pus_tm_3_35_app_data;

// Defines prototype for generating the app_data for this TM
void pus_tm_3_35_gen_app_data(t_pus_tm_3_35_app_data oBaseStruct, alt_u8* pAppData);

/* ------------------------------------------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------------------------------------------- */
// Service #17 - Test Connection

#define MAX_NUM_TEST_DATA 65535

// TC(17,129) VESM_R_REQ_CONCT_TST_DATA
typedef struct t_pus_tc_17_129_app_data{

    // Addition of DATA LENGTH
    alt_u16 u16VESMDataLength;

    // Addition of DATA
    alt_u8 u8ArrVESMData[MAX_NUM_TEST_DATA];

} t_pus_tc_17_129_app_data;

// Defines prototype for parsing the app_data for this TC
void pus_tc_17_129_parse_app_data(t_pus_tc_17_129_app_data* pResultStruct, alt_u8* pAppData);

// TM(17,130) VESM_R_CONNECTION_TEST_DATA_REPORT
typedef struct t_pus_tm_17_130_app_data{

    // Addition of DATA LENGTH
    alt_u16 u16VESMDataLength;

    // Addition of DATA
    alt_u8 u8ArrVESMData[MAX_NUM_TEST_DATA];

} t_pus_tm_17_130_app_data;

// Defines prototype for generating the app_data for this TM
void pus_tm_17_130_gen_app_data(t_pus_tm_17_130_app_data oBaseStruct, alt_u8* pAppData);

/* ------------------------------------------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------------------------------------------- */
// Service #209 - State transition

// All TCs have no Payload determined

/* ------------------------------------------------------------------------------------------------------------- */


/* ------------------------------------------------------------------------------------------------------------- */


/* ------------------------------------------------------------------------------------------------------------- */

#endif
