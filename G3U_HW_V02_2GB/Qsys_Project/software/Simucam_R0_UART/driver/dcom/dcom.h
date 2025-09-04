/*
 * dcom.h
 *
 *  Created on: 31/03/2019
 *      Author: rfranca
 */

#ifndef DCOM_H_
#define DCOM_H_

#include "../../simucam_definitions.h"
#include "rmap/rmap_mem_area.h"

//! [constants definition]
// irq numbers
#define DCOM_CH_1_TX_IRQ                 8
#define DCOM_CH_1_RPRT_IRQ               18
#define DCOM_CH_2_TX_IRQ                 9
#define DCOM_CH_2_RPRT_IRQ               19
#define DCOM_CH_3_TX_IRQ                 10
#define DCOM_CH_3_RPRT_IRQ               20
#define DCOM_CH_4_TX_IRQ                 11
#define DCOM_CH_4_RPRT_IRQ               21
#define DCOM_CH_5_TX_IRQ                 12
#define DCOM_CH_5_RPRT_IRQ               22
#define DCOM_CH_6_TX_IRQ                 13
#define DCOM_CH_6_RPRT_IRQ               23
#define DCOM_CH_7_TX_IRQ                 14
#define DCOM_CH_7_RPRT_IRQ               24
#define DCOM_CH_8_TX_IRQ                 15
#define DCOM_CH_8_RPRT_IRQ               25

// address
#define DCOM_CH_1_BASE_ADDR              DUMB_COMMUNICATION_MODULE_V2_2_BASE
#define DCOM_CH_2_BASE_ADDR              DUMB_COMMUNICATION_MODULE_V2_2_BASE
#define DCOM_CH_3_BASE_ADDR              DUMB_COMMUNICATION_MODULE_V2_3_BASE
#define DCOM_CH_4_BASE_ADDR              DUMB_COMMUNICATION_MODULE_V2_4_BASE
#define DCOM_CH_5_BASE_ADDR              DUMB_COMMUNICATION_MODULE_V2_5_BASE
#define DCOM_CH_6_BASE_ADDR              DUMB_COMMUNICATION_MODULE_V2_6_BASE
#define DCOM_CH_7_BASE_ADDR              DUMB_COMMUNICATION_MODULE_V2_7_BASE
#define DCOM_CH_8_BASE_ADDR              DUMB_COMMUNICATION_MODULE_V2_8_BASE
#define DCOM_RMAP_MEM_1_BASE_ADDR        RMAP_MEMORY_SUBUNIT_AREA_1_BASE
#define DCOM_RMAP_MEM_2_BASE_ADDR        RMAP_MEMORY_SUBUNIT_AREA_2_BASE
#define DCOM_RMAP_MEM_3_BASE_ADDR        RMAP_MEMORY_SUBUNIT_AREA_3_BASE
#define DCOM_RMAP_MEM_4_BASE_ADDR        RMAP_MEMORY_SUBUNIT_AREA_4_BASE
#define DCOM_RMAP_MEM_5_BASE_ADDR        RMAP_MEMORY_SUBUNIT_AREA_5_BASE
#define DCOM_RMAP_MEM_6_BASE_ADDR        RMAP_MEMORY_SUBUNIT_AREA_6_BASE
#define DCOM_RMAP_MEM_7_BASE_ADDR        RMAP_MEMORY_SUBUNIT_AREA_7_BASE
#define DCOM_RMAP_MEM_8_BASE_ADDR        RMAP_MEMORY_SUBUNIT_AREA_8_BASE

//! [constants definition]

//! [public module structs definition]
enum DcomSpwCh {
	eDcomSpwCh1 = 0, eDcomSpwCh2, eDcomSpwCh3, eDcomSpwCh4, eDcomSpwCh5, eDcomSpwCh6, eDcomSpwCh7, eDcomSpwCh8
} EDcomSpwCh;

/* Dcom Device Address Register Struct */
typedef struct DcomDevAddr {
	alt_u32 uliDevBaseAddr; /* Dcom Device Base Address */
} TDcomDevAddr;

/* Dcom IRQ Control Register Struct */
typedef struct DcomIrqControl {
	bool bGlobalIrqEn; /* Dcom Global IRQ Enable */
} TDcomIrqControl;

/* SpaceWire Device Address Register Struct */
typedef struct SpwcDevAddr {
	alt_u32 uliSpwcBaseAddr; /* SpaceWire Device Base Address */
} TSpwcDevAddr;

/* SpaceWire Link Config Register Struct */
typedef struct SpwcLinkConfig {
	bool bEnable; /* SpaceWire Link Config Enable */
	bool bDisconnect; /* SpaceWire Link Config Disconnect */
	bool bLinkStart; /* SpaceWire Link Config Linkstart */
	bool bAutostart; /* SpaceWire Link Config Autostart */
	alt_u32 ucTxDivCnt; /* SpaceWire Link Config TxDivCnt */
} TSpwcLinkConfig;

/* SpaceWire Link Status Register Struct */
typedef struct SpwcLinkStatus {
	bool bRunning; /* SpaceWire Link Running */
	bool bConnecting; /* SpaceWire Link Connecting */
	bool bStarted; /* SpaceWire Link Started */
} TSpwcLinkStatus;

/* SpaceWire Link Status Register Struct */
typedef struct SpwcLinkError {
	bool bDisconnect; /* SpaceWire Error Disconnect */
	bool bParity; /* SpaceWire Error Parity */
	bool bEscape; /* SpaceWire Error Escape */
	bool bCredit; /* SpaceWire Error Credit */
} TSpwcLinkError;

/* SpaceWire Timecode Control Register Struct */
typedef struct SpwcTimecodeControl {
	alt_u32 ucTxTime; /* SpaceWire Timecode Tx Time */
	alt_u32 ucTxControl; /* SpaceWire Timecode Tx Control */
	bool bTxSend; /* SpaceWire Timecode Tx Send */
	bool bRxReceivedClr; /* SpaceWire Timecode Rx Received Clear */
} TSpwcTimecodeControl;

/* SpaceWire Timecode Status Register Struct */
typedef struct SpwcTimecodeStatus {
	alt_u32 ucRxTime; /* SpaceWire Timecode Rx Time */
	alt_u32 ucRxControl; /* SpaceWire Timecode Rx Control */
	bool bRxReceived; /* SpaceWire Timecode Rx Received */
} TSpwcTimecodeStatus;

/* SpaceWire Codec Error Injection Control Register Struct */
typedef struct SpwcSpwCodecErrInj {
	bool bStartErrInj; /* Start SpaceWire Codec Error Injection */
	bool bResetErrInj; /* Reset SpaceWire Codec Error Injection */
	alt_u32 ucErrInjErrCode; /* SpaceWire Codec Error Injection Error Code */
	bool bErrInjBusy; /* SpaceWire Codec Error Injection is Busy */
	bool bErrInjReady; /* SpaceWire Codec Error Injection is Ready */
} TSpwcSpwCodecErrInj;

/* Data Scheduler Device Address Register Struct */
typedef struct DschDevAddr {
	alt_u32 uliDschBaseAddr; /* Data Scheduler Device Base Address */
} TDschDevAddr;

/* Data Scheduler Timer Control Register Struct */
typedef struct DschTimerControl {
	bool bStart; /* Data Scheduler Timer Start */
	bool bRun; /* Data Scheduler Timer Run */
	bool bStop; /* Data Scheduler Timer Stop */
	bool bClear; /* Data Scheduler Timer Clear */
} TDschTimerControl;

/* Data Scheduler Timer Config Register Struct */
typedef struct DschTimerConfig {
	bool bRunOnSync; /* Data Scheduler Timer Run on Sync */
	alt_u32 uliClockDiv; /* Data Scheduler Timer Clock Div */
	alt_u32 uliStartTime; /* Data Scheduler Timer Start Time */
} TDschTimerConfig;

/* Data Scheduler Timer Status Register Struct */
typedef struct DschTimerStatus {
	bool bStopped; /* Data Scheduler Timer Stopped */
	bool bStarted; /* Data Scheduler Timer Started */
	bool bRunning; /* Data Scheduler Timer Running */
	bool bCleared; /* Data Scheduler Timer Cleared */
	alt_u32 uliCurrentTime; /* Data Scheduler Timer Time */
} TDschTimerStatus;

/* Data Scheduler Packet Config Register Struct */
typedef struct DschPacketConfig {
	bool bSendEop; /* Data Scheduler Send EOP with Packet */
	bool bSendEep; /* Data Scheduler Send EEP with Packet */
} TDschPacketConfig;

/* Data Scheduler Buffer Status Register Struct */
typedef struct DschBufferStatus {
	alt_u32 usiUsedBytes; /* Data Scheduler Buffer Used [Bytes] */
	bool bEmpty; /* Data Scheduler Buffer Empty */
	bool bFull; /* Data Scheduler Buffer Full */
} TDschBufferStatus;

/* Data Scheduler Data Control Register Struct */
typedef struct DschDataControl {
	alt_u32 uliRdInitAddrHighDword; /* Data Scheduler Initial Read Address [High Dword] */
	alt_u32 uliRdInitAddrLowDword; /* Data Scheduler Initial Read Address [Low Dword] */
	alt_u32 uliRdDataLenghtBytes; /* Data Scheduler Read Data Length [Bytes] */
	bool bRdStart; /* Data Scheduler Data Read Start */
	bool bRdReset; /* Data Scheduler Data Read Reset */
	bool bRdAutoRestart; /* Data Scheduler Data Read Auto Restart */
	bool bDataEepInjectionEn; /* Data Scheduler Data EEP Injection Enable */
	alt_u32 uliDataEepInjectionCnt; /* Data Scheduler Data EEP Injection Counter */
} TDschDataControl;

/* Data Scheduler Data Status Register Struct */
typedef struct DschDataStatus {
	bool bRdBusy; /* Data Scheduler Data Read Busy */
} TDschDataStatus;

/* Data Scheduler IRQ Control Register Struct */
typedef struct DschIrqControl {
	bool bTxEndEn; /* Data Scheduler Tx End IRQ Enable */
	bool bTxBeginEn; /* Data Scheduler Tx Begin IRQ Enable */
} TDschIrqControl;

/* Data Scheduler IRQ Flags Register Struct */
typedef struct DschIrqFlag {
	bool bTxEndFlag; /* Data Scheduler Tx End IRQ Flag */
	bool bTxBeginFlag; /* Data Scheduler Tx Begin IRQ Flag */
} TDschIrqFlag;

/* Data Scheduler IRQ Flags Clear Register Struct */
typedef struct DschIrqFlagClr {
	bool bTxEndFlagClr; /* Data Scheduler Tx End IRQ Flag Clear */
	bool bTxBeginFlagClr; /* Data Scheduler Tx Begin IRQ Flag Clear */
} TDschIrqFlagClr;

/* RMAP Device Address Register Struct */
typedef struct RmapDevAddr {
	alt_u32 uliRmapBaseAddr; /* RMAP Device Base Address */
} TRmapDevAddr;

/* RMAP Echoing Mode Config Register Struct */
typedef struct RmapEchoingModeConfig {
	bool bRmapEchoingModeEn; /* RMAP Echoing Mode Enable */
	bool bRmapEchoingIdEn; /* RMAP Echoing ID Enable */
} TRmapEchoingModeConfig;

/* RMAP Codec Config Register Struct */
typedef struct RmapCodecConfig {
	bool bEnable; /* RMAP Target Enable */
	alt_u32 ucLogicalAddress; /* RMAP Target Logical Address */
	alt_u32 ucKey; /* RMAP Target Key */
	bool bUnaligmentEn; /* RMAP Unalignment Enable */
	alt_u32 ucWordWidth; /* RMAP Word Width */
} TRmapCodecConfig;

/* RMAP Codec Status Register Struct */
typedef struct RmapCodecStatus {
	bool bCommandReceived; /* RMAP Status Command Received */
	bool bWriteRequested; /* RMAP Status Write Requested */
	bool bWriteAuthorized; /* RMAP Status Write Authorized */
	bool bReadRequested; /* RMAP Status Read Requested */
	bool bReadAuthorized; /* RMAP Status Read Authorized */
	bool bReplySended; /* RMAP Status Reply Sended */
	bool bDiscardedPackage; /* RMAP Status Discarded Package */
} TRmapCodecStatus;

/* RMAP Codec Status Register Struct */
typedef struct RmapCodecError {
	bool bEarlyEop; /* RMAP Error Early EOP */
	bool bEep; /* RMAP Error EEP */
	bool bHeaderCRC; /* RMAP Error Header CRC */
	bool bUnusedPacketType; /* RMAP Error Unused Packet Type */
	bool bInvalidCommandCode; /* RMAP Error Invalid Command Code */
	bool bTooMuchData; /* RMAP Error Too Much Data */
	bool bInvalidDataCrc; /* RMAP Error Invalid Data CRC */
} TRmapCodecError;

/* RMAP Memory Area Config Register Struct */
typedef struct RmapMemAreaConfig {
	alt_u32 uliAddrOffset; /* RMAP Memory Area Address Offset */
} TRmapMemAreaConfig;

/* RMAP Memory Area Pointer Register Struct */
typedef struct RmapMemAreaPrt {
	TRmapMemArea *puliRmapAreaPrt; /* RMAP Memory Area Pointer */
} TRmapMemAreaPrt;

/* RMAP Error Injection Control Register Struct */
typedef struct RmapRmapErrInj {
	bool bResetErr; /* Reset RMAP Error */
	bool bTriggerErr; /* Trigger RMAP Error */
	alt_u32 ucErrorId; /* Error ID of RMAP Error */
	alt_u32 uliValue; /* Value of RMAP Error */
	alt_u32 usiRepeats; /* Repetitions of RMAP Error */
} TRmapRmapErrInj;

/* Report Device Address Register Struct */
typedef struct RprtDevAddr {
	alt_u32 uliRprtBaseAddr; /* Report Device Base Address */
} TRprtDevAddr;

 /* Report IRQ Control Register Struct */
typedef struct RprtIrqControl {
	bool bSpwLinkConnectedEn; /* Report SpW Link Connected IRQ Enable */
	bool bSpwLinkDisconnectedEn; /* Report SpW Link Disconnected IRQ Enable */
	bool bSpwErrDisconnectEn; /* Report SpW Error Disconnect IRQ Enable */
	bool bSpwErrParityEn; /* Report SpW Error Parity IRQ Enable */
	bool bSpwErrEscapeEn; /* Report SpW Error Escape IRQ Enable */
	bool bSpwErrCreditEn; /* Report SpW Error Credit IRQ Enable */
	bool bRxTimecodeReceivedEn; /* Report Rx Timecode Received IRQ Enable */
	bool bRmapErrEarlyEopEn; /* Report Rmap Error Early EOP IRQ Enable */
	bool bRmapErrEepEn; /* Report Rmap Error EEP IRQ Enable */
	bool bRmapErrHeaderCrcEn; /* Report Rmap Error Header CRC IRQ Enable */
	bool bRmapErrUnusedPacketTypeEn; /* Report Rmap Error Unused Packet Type IRQ Enable */
	bool bRmapErrInvalidCommandCodeEn; /* Report Rmap Error Invalid Command Code IRQ Enable */
	bool bRmapErrTooMuchDataEn; /* Report Rmap Error Too Much Data IRQ Enable */
	bool bRmapErrInvalidDataCrcEn; /* Report Rmap Error Invalid Data Crc IRQ Enable */
} TRprtIrqControl;

/* Report IRQ Flags Register Struct */
typedef struct RprtIrqFlag {
	bool bSpwLinkConnectedFlag; /* Report SpW Link Connected IRQ Flag */
	bool bSpwLinkDisconnectedFlag; /* Report SpW Link Disconnected IRQ Flag */
	bool bSpwErrDisconnectFlag; /* Report SpW Error Disconnect IRQ Flag */
	bool bSpwErrParityFlag; /* Report SpW Error Parity IRQ Flag */
	bool bSpwErrEscapeFlag; /* Report SpW Error Escape IRQ Flag */
	bool bSpwErrCreditFlag; /* Report SpW Error Credit IRQ Flag */
	bool bRxTimecodeReceivedFlag; /* Report Rx Timecode Received IRQ Flag */
	bool bRmapErrEarlyEopFlag; /* Report Rmap Error Early EOP IRQ Flag */
	bool bRmapErrEepFlag; /* Report Rmap Error EEP IRQ Flag */
	bool bRmapErrHeaderCrcFlag; /* Report Rmap Error Header CRC IRQ Flag */
	bool bRmapErrUnusedPacketTypeFlag; /* Report Rmap Error Unused Packet Type IRQ Flag */
	bool bRmapErrInvalidCommandCodeFlag; /* Report Rmap Error Invalid Command Code IRQ Flag */
	bool bRmapErrTooMuchDataFlag; /* Report Rmap Error Too Much Data IRQ Flag */
	bool bRmapErrInvalidDataCrcFlag; /* Report Rmap Error Invalid Data Crc IRQ Flag */
} TRprtIrqFlag;

/* Report IRQ Flags Clear Register Struct */
typedef struct RprtIrqFlagClr {
	bool bSpwLinkConnectedFlagClr; /* Report SpW Link Connected IRQ Flag Clear */
	bool bSpwLinkDisconnectedFlagClr; /* Report SpW Link Disconnected IRQ Flag Clear */
	bool bSpwErrDisconnectFlagClr; /* Report SpW Error Disconnect IRQ Flag Clear */
	bool bSpwErrParityFlagClr; /* Report SpW Error Parity IRQ Flag Clear */
	bool bSpwErrEscapeFlagClr; /* Report SpW Error Escape IRQ Flag Clear */
	bool bSpwErrCreditFlagClr; /* Report SpW Error Credit IRQ Flag Clear */
	bool bRxTimecodeReceivedFlagClr; /* Report Rx Timecode Received IRQ Flag Clear */
	bool bRmapErrEarlyEopFlagClr; /* Report Rmap Error Early EOP IRQ Flag Clear */
	bool bRmapErrEepFlagClr; /* Report Rmap Error EEP IRQ Flag Clear */
	bool bRmapErrHeaderCrcFlagClr; /* Report Rmap Error Header CRC IRQ Flag Clear */
	bool bRmapErrUnusedPacketTypeFlagClr; /* Report Rmap Error Unused Packet Type IRQ Flag Clear */
	bool bRmapErrInvalidCommandCodeFlagClr; /* Report Rmap Error Invalid Command Code IRQ Flag Clear */
	bool bRmapErrTooMuchDataFlagClr; /* Report Rmap Error Too Much Data IRQ Flag Clear */
	bool bRmapErrInvalidDataCrcFlagClr; /* Report Rmap Error Invalid Data Crc IRQ Flag Clear */
} TRprtIrqFlagClr;

/* General Struct for SpW Channel Registers Access */
typedef struct SpwcChannel {
	TSpwcDevAddr xSpwcDevAddr;
	TSpwcLinkConfig xSpwcLinkConfig;
	TSpwcLinkStatus xSpwcLinkStatus;
	TSpwcLinkError xSpwcLinkError;
	TSpwcTimecodeControl xSpwcTimecodeControl;
	TSpwcTimecodeStatus xSpwcTimecodeStatus;
	TSpwcSpwCodecErrInj xSpwcSpwCodecErrInj;
} TSpwcChannel;

/* General Struct for Data Scheduler Registers Access */
typedef struct DschChannel {
	TDschDevAddr xDschDevAddr;
	TDschTimerControl xDschTimerControl;
	TDschTimerConfig xDschTimerConfig;
	TDschTimerStatus xDschTimerStatus;
	TDschPacketConfig xDschPacketConfig;
	TDschBufferStatus xDschBufferStatus;
	TDschDataControl xDschDataControl;
	TDschDataStatus xDschDataStatus;
	TDschIrqControl xDschIrqControl;
	TDschIrqFlag xDschIrqFlag;
	TDschIrqFlagClr xDschIrqFlagClr;
} TDschChannel;

/* General Struct for RMAP Registers Access */
typedef struct RmapChannel {
	TRmapDevAddr xRmapDevAddr;
	TRmapEchoingModeConfig xRmapEchoingModeConfig;
	TRmapCodecConfig xRmapCodecConfig;
	TRmapCodecStatus xRmapCodecStatus;
	TRmapCodecError xRmapCodecError;
	TRmapMemAreaConfig xRmapMemAreaConfig;
	TRmapMemAreaPrt xRmapMemAreaPrt;
	TRmapRmapErrInj xRmapRmapErrInj;
} TRmapChannel;

/* General Struct for Report Registers Access */
typedef struct RprtChannel {
	TRprtDevAddr xRprtDevAddr;
	TRprtIrqControl xRprtIrqControl;
	TRprtIrqFlag xRprtIrqFlag;
	TRprtIrqFlagClr xRprtIrqFlagClr;
} TRprtChannel;

/* General Struct for Communication Module Registers Access */
typedef struct DcomChannel {
	TDcomDevAddr xDcomDevAddr;
	TDcomIrqControl xDcomIrqControl;
	TSpwcChannel xSpacewire;
	TDschChannel xDataScheduler;
	TRmapChannel xRmap;
	TRprtChannel xReport;
} TDcomChannel;

//! [public module structs definition]

//! [public function prototypes]
//! [public function prototypes]

//! [data memory public global variables - use extern]
//! [data memory public global variables - use extern]

//! [flags]
//! [flags]

//! [program memory public global variables - use extern]
//! [program memory public global variables - use extern]

//! [macros]
//! [macros]

#endif /* DCOM_H_ */
