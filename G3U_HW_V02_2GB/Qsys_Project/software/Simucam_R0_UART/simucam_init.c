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

	vRstcReleaseSimucamReset(0);

	/* Initialization and Test of basic HW */
	vInitSimucamBasicHW();
	bTestSimucamBasicHW();

	while (1)
		; /* Correct Program Flow never gets here. */

	return -1;
}
