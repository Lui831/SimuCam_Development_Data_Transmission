/*
--------------------------------------------------------------------------------------------------------------
-> Name: pus.c
-> Authors: João P. C. Fogetti, Luiz H. A. Santos, Pedro A. W. Dian, Rodrigo M. Franca, Sergio R. Augusto.
-> Date: 09-10-2025
-> Description: library for defining PUS structures and commands.
--------------------------------------------------------------------------------------------------------------
*/

/* ------------------------------------------------------------------------------------------------------------- */
// Includes

#include "pus.h"


/* ------------------------------------------------------------------------------------------------------------- */


/* ------------------------------------------------------------------------------------------------------------- */
// Function Implementations

/* --------------------------------------------------- */
// Service #1

void pus_tm_1_1_gen_app_data(t_pus_tm_1_1_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;
    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);
    pAppData[5] = oBaseStruct.u8SeqFlags;
    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
};

void pus_tm_1_7_gen_app_data(t_pus_tm_1_7_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;
    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);
    pAppData[5] = oBaseStruct.u8SeqFlags;
    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);

};

void pus_tm_1_2_ack_fail_incomplete_gen_app_data(t_pus_tm_1_2_ack_fail_incomplete_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

    pAppData[21] = ((oBaseStruct.u16VESMLenReceived & 0xFF00) >> 8);
    pAppData[22] = ((oBaseStruct.u16VESMLenReceived & 0xFF) >> 0);

    pAppData[23] = ((oBaseStruct.u16VESMLenExpected & 0xFF00) >> 8);
    pAppData[24] = ((oBaseStruct.u16VESMLenExpected & 0xFF) >> 0);
};

void pus_tm_1_2_ack_fail_notccsds_gen_app_data(t_pus_tm_1_2_ack_fail_notccsds_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

};
void pus_tm_1_2_ack_fail_wrongapid_gen_app_data(t_pus_tm_1_2_ack_fail_wrongapid_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

};

void pus_tm_1_2_ack_fail_wrongpkgformat_gen_app_data(t_pus_tm_1_2_ack_fail_wrongpkgformat_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

};

void pus_tm_1_2_ack_fail_wrongpkgtype_gen_app_data(t_pus_tm_1_2_ack_fail_wrongpkgtype_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

};

void pus_tm_1_2_ack_fail_wrongsrcid_gen_app_data(t_pus_tm_1_2_ack_fail_wrongsrcid_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

};

void pus_tm_1_2_ack_fail_wrongsubtype_gen_app_data(t_pus_tm_1_2_ack_fail_wrongsubtype_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

};

void pus_tm_1_2_ack_fail_wrongtype_gen_app_data(t_pus_tm_1_2_ack_fail_wrongtype_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

};

void pus_tm_1_2_ack_fail_wrongcrc_gen_app_data(t_pus_tm_1_2_ack_fail_wrongcrc_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

    pAppData[21] = ((oBaseStruct.u16VESMCRCExpected & 0xFF00) >> 8);
    pAppData[22] = ((oBaseStruct.u16VESMCRCExpected & 0xFF) >> 0);

};

void pus_tm_1_2_ack_fail_wrongexecflags_gen_app_data(t_pus_tm_1_2_ack_fail_wrongexecflags_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

    pAppData[21] = oBaseStruct.u8VESMAckFlags;

};

void pus_tm_1_2_ack_fail_wrongpusversion_app_data(t_pus_tm_1_2_ack_fail_wrongpusversion_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

    pAppData[21] = oBaseStruct.u8VESMVersion;

};

void pus_tm_1_8_exec_fail_gen_app_data(t_pus_tm_1_8_exec_fail_gen_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

    pAppData[21]  = ((oBaseStruct.u32VESMGenErrID & 0xFF000000) >> 24);
    pAppData[22] = ((oBaseStruct.u32VESMGenErrID & 0x00FF0000) >> 16);
    pAppData[23] = ((oBaseStruct.u32VESMGenErrID & 0x0000FF00) >> 8);
    pAppData[24] = ((oBaseStruct.u32VESMGenErrID & 0x000000FF) >> 0);

};

void pus_tm_1_8_exec_fail_notallowinmode_app_data(t_pus_tm_1_8_exec_fail_notallowinmode_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

    pAppData[21]  = ((oBaseStruct.u32VESMVESMMode & 0xFF000000) >> 24);
    pAppData[22] = ((oBaseStruct.u32VESMVESMMode & 0x00FF0000) >> 16);
    pAppData[23] = ((oBaseStruct.u32VESMVESMMode & 0x0000FF00) >> 8);
    pAppData[24] = ((oBaseStruct.u32VESMVESMMode & 0x000000FF) >> 0);

};

void pus_tm_1_8_exec_fail_notimplemented_app_data(t_pus_tm_1_8_exec_fail_notimplemented_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

};

void pus_tm_1_8_exec_fail_wrongcmdcode_app_data(t_pus_tm_1_8_exec_fail_wrongcmdcode_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

};

void pus_tm_1_8_exec_fail_wrongparamvalue_app_data(t_pus_tm_1_8_exec_fail_wrongparamvalue_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8PkgVerNum;
    pAppData[1] = oBaseStruct.u8PkgType;
    pAppData[2] = oBaseStruct.u8SecHdrFlag;

    pAppData[3] = (alt_u8) ((oBaseStruct.u16APID & 0xFF00) >> 8);
    pAppData[4] = (alt_u8) ((oBaseStruct.u16APID & 0xFF) >> 0);

    pAppData[5] = oBaseStruct.u8SeqFlags;

    pAppData[6] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF00) >> 8);
    pAppData[7] = (alt_u8) ((oBaseStruct.u16PkgSeqCount & 0xFF) >> 0);
    
    pAppData[8] = oBaseStruct.u8VESMDeviceID;

    pAppData[9]  = ((oBaseStruct.u32VESMAcceptErrID & 0xFF000000) >> 24);
    pAppData[10] = ((oBaseStruct.u32VESMAcceptErrID & 0x00FF0000) >> 16);
    pAppData[11] = ((oBaseStruct.u32VESMAcceptErrID & 0x0000FF00) >> 8);
    pAppData[12] = ((oBaseStruct.u32VESMAcceptErrID & 0x000000FF) >> 0);

    pAppData[13] = oBaseStruct.u8VESMServiceType;
    pAppData[14] = oBaseStruct.u8VESMServiceSubtype;

    pAppData[15]  = ((oBaseStruct.u32VESMSourceID & 0xFF000000) >> 24);
    pAppData[16] = ((oBaseStruct.u32VESMSourceID & 0x00FF0000) >> 16);
    pAppData[17] = ((oBaseStruct.u32VESMSourceID & 0x0000FF00) >> 8);
    pAppData[18] = ((oBaseStruct.u32VESMSourceID & 0x000000FF) >> 0);

    pAppData[19] = ((oBaseStruct.u16VESMCRCReceived & 0xFF00) >> 8);
    pAppData[20] = ((oBaseStruct.u16VESMCRCReceived & 0xFF) >> 0);

    pAppData[21] = ((oBaseStruct.u16VESMBitpos & 0xFF00) >> 8);
    pAppData[22] = ((oBaseStruct.u16VESMBitpos & 0xFF) >> 0);

    pAppData[23]  = ((oBaseStruct.u32ArrVESMValue[0] & 0xFF000000) >> 24);
    pAppData[24] = ((oBaseStruct.u32ArrVESMValue[0] & 0x00FF0000) >> 16);
    pAppData[25] = ((oBaseStruct.u32ArrVESMValue[0] & 0x0000FF00) >> 8);
    pAppData[26] = ((oBaseStruct.u32ArrVESMValue[0] & 0x000000FF) >> 0);
    pAppData[27]  = ((oBaseStruct.u32ArrVESMValue[1] & 0xFF000000) >> 24);
    pAppData[28] = ((oBaseStruct.u32ArrVESMValue[1] & 0x00FF0000) >> 16);
    pAppData[29] = ((oBaseStruct.u32ArrVESMValue[1] & 0x0000FF00) >> 8);
    pAppData[30] = ((oBaseStruct.u32ArrVESMValue[1] & 0x000000FF) >> 0);

};

/* --------------------------------------------------- */
// Service #3

void pus_tc_3_5_parse_app_data(t_pus_tc_3_5_app_data* pResultStruct, alt_u8* pAppData){

    pResultStruct->u16VESMNumSids = 0;
    pResultStruct->u16VESMNumSids += (pAppData[0] << 8);
    pResultStruct->u16VESMNumSids += (pAppData[1] << 0);

    for(alt_u16 u16Cont; u16Cont < pResultStruct->u16VESMNumSids; u16Cont++){

        pResultStruct->u8ArrVESMDeviceID[u16Cont] = pAppData[2 + u16Cont*2];
        pResultStruct->u8ArrVESMSid[u16Cont]      = pAppData[2 + u16Cont*2 + 1];
    }

};

void pus_tc_3_6_parse_app_data(t_pus_tc_3_6_app_data* pResultStruct, alt_u8* pAppData){

    pResultStruct->u16VESMNumSids = 0;
    pResultStruct->u16VESMNumSids += (pAppData[0] << 8);
    pResultStruct->u16VESMNumSids += (pAppData[1] << 0);

    for(alt_u16 u16Cont; u16Cont < pResultStruct->u16VESMNumSids; u16Cont++){

        pResultStruct->u8ArrVESMDeviceID[u16Cont] = pAppData[2 + u16Cont*2];
        pResultStruct->u8ArrVESMSid[u16Cont]      = pAppData[2 + u16Cont*2 + 1];
    }

};

void pus_tc_3_27_parse_app_data(t_pus_tc_3_27_app_data* pResultStruct, alt_u8* pAppData){

    pResultStruct->u16VESMNumSids = 0;
    pResultStruct->u16VESMNumSids += (pAppData[0] << 8);
    pResultStruct->u16VESMNumSids += (pAppData[1] << 0);

    for(alt_u16 u16Cont; u16Cont < pResultStruct->u16VESMNumSids; u16Cont++){

        pResultStruct->u8ArrVESMDeviceID[u16Cont] = pAppData[2 + u16Cont*2];
        pResultStruct->u8ArrVESMSid[u16Cont]      = pAppData[2 + u16Cont*2 + 1];
    }
  
};

void pus_tc_3_31_parse_app_data(t_pus_tc_3_31_app_data* pResultStruct, alt_u8* pAppData){

    pResultStruct->u16VESMNumSids = 0;
    pResultStruct->u16VESMNumSids += (pAppData[0] << 8);
    pResultStruct->u16VESMNumSids += (pAppData[1] << 0);

    for(alt_u16 u16Cont; u16Cont < pResultStruct->u16VESMNumSids; u16Cont++){

        pResultStruct->u8ArrVESMDeviceID[u16Cont]  = pAppData[2 + u16Cont*3];
        pResultStruct->u32ArrVESMSid[u16Cont]      = pAppData[2 + u16Cont*3 + 1] << 24;
        pResultStruct->u32ArrVESMSid[u16Cont]       = pAppData[2 + u16Cont*3 + 2] << 16;
        pResultStruct->u32ArrVESMSid[u16Cont]       = pAppData[2 + u16Cont*3 + 3] << 8;
        pResultStruct->u32ArrVESMSid[u16Cont]       = pAppData[2 + u16Cont*3 + 4] << 0;

        pResultStruct->u8ArrVESMSidPeriod[u16Cont] = pAppData[2 + u16Cont*3 + 5];
    }
  
};

void pus_tm_3_25_gen_app_data(t_pus_tm_3_25_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = oBaseStruct.u8VESMDeviceID;

    pAppData[1]  = ((oBaseStruct.u32VESMSid & 0xFF000000) >> 24);
    pAppData[2] = ((oBaseStruct.u32VESMSid & 0x00FF0000) >> 16);
    pAppData[3] = ((oBaseStruct.u32VESMSid & 0x0000FF00) >> 8);
    pAppData[4] = ((oBaseStruct.u32VESMSid & 0x000000FF) >> 0);

    pAppData[5] = oBaseStruct.u8VESMMode;

};

void pus_tm_3_35_gen_app_data(t_pus_tm_3_35_app_data oBaseStruct, alt_u8* pAppData){
  
    pAppData[0] = ((oBaseStruct.u16VESMNumSids & 0xFF00) >> 8);
    pAppData[1] = ((oBaseStruct.u16VESMNumSids & 0xFF) >> 0);

    for(alt_u16 u16Cont; u16Cont < oBaseStruct.u16VESMNumSids; u16Cont++){

        pAppData[2 + u16Cont*7] = oBaseStruct.u8VESMDeviceID[u16Cont];

        pAppData[2 + u16Cont*7 + 1]  = ((oBaseStruct.u32VESMSid[u16Cont] & 0xFF000000) >> 24);
        pAppData[2 + u16Cont*7 + 2] = ((oBaseStruct.u32VESMSid[u16Cont] & 0x00FF0000) >> 16);
        pAppData[2 + u16Cont*7 + 3] = ((oBaseStruct.u32VESMSid[u16Cont] & 0x0000FF00) >> 8);
        pAppData[2 + u16Cont*7 + 4] = ((oBaseStruct.u32VESMSid[u16Cont] & 0x000000FF) >> 0);

        pAppData[2 + u16Cont*7 + 5] = oBaseStruct.u8VESMMode[u16Cont];

        pAppData[2 + u16Cont*7 + 6] = ((oBaseStruct.u16VESMSidPeriod[u16Cont] & 0xFF00) >> 8);
        pAppData[2 + u16Cont*7 + 7] = ((oBaseStruct.u16VESMSidPeriod[u16Cont] & 0xFF) >> 0);

    }
};

/* --------------------------------------------------- */
// Service #17

void pus_tc_17_129_parse_app_data(t_pus_tc_17_129_app_data* pResultStruct, alt_u8* pAppData){

    pResultStruct->u16VESMDataLength = 0;
    pResultStruct->u16VESMDataLength += (pAppData[0] << 8);
    pResultStruct->u16VESMDataLength += (pAppData[1] << 0);

    for(alt_u16 u16Cont; u16Cont < pResultStruct->u16VESMDataLength; u16Cont++){

        pResultStruct->u8ArrVESMData[u16Cont] = pAppData[u16Cont + 2];

    }

};

void pus_tm_17_130_gen_app_data(t_pus_tm_17_130_app_data oBaseStruct, alt_u8* pAppData){

    pAppData[0] = ((oBaseStruct.u16VESMDataLength & 0xFF00) >> 8);
    pAppData[1] = ((oBaseStruct.u16VESMDataLength & 0xFF) >> 0);

    for(alt_u16 u16Cont; u16Cont < oBaseStruct.u16VESMDataLength; u16Cont++){

        pAppData[u16Cont + 2] = oBaseStruct.u8ArrVESMData[u16Cont];

    }
}

/* ------------------------------------------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------------------------------------------- */
// General TC/TM functions

// Function to initialize a general TM
void pus_initialize_default_tm(t_pus_tm_send_info* oTMSendInfo){

    // Places all the default values for the Pkg Prim Hdr
    oTMSendInfo->oPkgPrimHdr.u8PkgVersionNumber = 2;
    oTMSendInfo->oPkgPrimHdr.u8PkgType          = 0;
    oTMSendInfo->oPkgPrimHdr.u8PkgSecHdrFlag    = 1;
    oTMSendInfo->oPkgPrimHdr.u16APID            = VESM_TM_APID;
    oTMSendInfo->oPkgPrimHdr.u8PkgSeqFlags     = 3;

    // Places all the default values for the Pkg Sec Hdr
    oTMSendInfo->oPkgSecHdr.u8SpacecraftTimeRefStatus = 0;

}

void pus_customize_tm(t_pus_tm_send_info* oTMSendInfo , alt_u8 u8ServiceID, alt_u8 u8SubserviceID, alt_u16 u16DestID, alt_u8* pAppData, alt_u8 u8SpWADDR){

    // Sets the values for the Pkg Sec Hdr of the TM
    oTMSendInfo->oPkgSecHdr.u8ServiceID    = u8ServiceID;
    oTMSendInfo->oPkgSecHdr.u8SubserviceID = u8SubserviceID;
    oTMSendInfo->oPkgSecHdr.u16DestID      = u16DestID;
    oTMSendInfo->oPkgSecHdr.u8Time[0]      = 0x00; // TODO: initialize the TIME field

    // Sets the app_data pointer
    oTMSendInfo->pAppData = pAppData;

    // Sets the SpW ADDR
    oTMSendInfo->oExtProtocolInfo.u8SpWADDR = u8SpWADDR;

}

