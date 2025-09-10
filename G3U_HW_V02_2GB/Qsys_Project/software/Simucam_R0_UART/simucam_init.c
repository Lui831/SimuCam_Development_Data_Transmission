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

/* Declaring file for JTAG debug */
#if DEBUG_ON
FILE* fp;
#endif

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

	/* Test of some critical IPCores HW interfaces in the Simucam */
	if (!bTestSimucamCriticalHW()) {
#if DEBUG_ON
		fprintf(fp, "\n");
		fprintf(fp, "Failure to initialize SimuCam Critical HW!\n");
		fprintf(fp, "Initialization attempt %lu, ", uliRstcGetResetCounter());
#endif
		/* Need to reset 2 times (3 tries) before halting the SimuCam */
		if (3 > uliRstcGetResetCounter()) {
			/* There are more initialization tries to make */
#if DEBUG_ON
			fprintf(fp, "SimuCam will be reseted now!\n");
#endif
			vRstcHoldSimucamReset(0);
		} else {
			/* No more tries, lock the SimuCam */
#if DEBUG_ON

			fprintf(fp, "SimuCam will be halted now!\n");
#endif
			while(1) {};
		}
		return (-1);
	}

	/* Initialization and Test of basic HW */
	vInitSimucamBasicHW();
	bTestSimucamBasicHW();

	fprintf(fp, "CHEGUEI AQUI!\n");

	/*
	 * Channel initialization
	 */
	bDcomInitCh(&(xCh[4]), 4);

	/* Disable SpaceWire Link */
	bSpwcGetLinkConfig(&(xCh[4].xSpacewire));
	xCh[4].xSpacewire.xSpwcLinkConfig.bEnable = TRUE;
	xCh[4].xSpacewire.xSpwcLinkConfig.bAutostart = TRUE;
	xCh[4].xSpacewire.xSpwcLinkConfig.bLinkStart = FALSE;
	xCh[4].xSpacewire.xSpwcLinkConfig.bDisconnect = FALSE;
	bSpwcSetLinkConfig(&(xCh[4].xSpacewire));

	while (1){
		// Codigo de teste
	}


	return -1;
}
