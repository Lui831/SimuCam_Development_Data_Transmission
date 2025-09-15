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
		vInitSimucamBasicHW();
		bTestSimucamBasicHW();

		fprintf(fp, "Oi, estou aqui!");

		IOWR(0x90000000, 0, 126);
		IOWR(0x90000000, 13, 512);

		while (1)
			; /* Correct Program Flow never gets here. */

	return -1;
}
