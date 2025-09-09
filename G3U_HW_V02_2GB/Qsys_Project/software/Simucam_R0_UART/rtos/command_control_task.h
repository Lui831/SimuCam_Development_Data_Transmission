/*
 ************************************************************************************************
 *                                              NSEE
 *                                             Address
 *
 *                                       All Rights Reserved
 *
 *
 * Filename     : command_control_task.c
 * Programmer(s): Yuri Bunduki
 * Created on: Dec 21, 2018
 * Description  : Header file for the command control management task.
 ************************************************************************************************
 */
/*$PAGE*/

/*
 ************************************************************************************************
 *                                        INCLUDE FILES
 ************************************************************************************************
 */
#include "includes.h"
#include "sub_unit_control_task.h"
#include "../simucam_definitions.h"
#include "../alt_error_handler.h"
#include "../utils/util.h"
#include "../utils/configs_simucam.h"
#include "../utils/crc.h"
#include "../api_drivers/ddr2/ddr2.h"
#include "../driver/sync/sync.h"
#include "../driver/uart/uart.h"
#include "../driver/dcom/dcom_channel.h"
#include "../driver/reset/reset.h"
#include "../driver/ctrl_io_lvds/ctrl_io_lvds.h"
#include "../driver/memory_filler/memory_filler.h"
// #include "simple_socket_server.h"			/* Used in the conn/send op */
/*
 * Include configurations for the communication modules [yb]
 */

/*$PAGE*/

#ifndef COMMAND_CONTROL_H_
#define COMMAND_CONTROL_H_

/*
 ************************************************************************************************
 *                  SSS_TX_BUF_SIZE                      CONSTANTS & MACROS
 ************************************************************************************************
 */

extern INT16U i_imagette_number;
extern INT16U i_imagette_counter;
extern TConfEth xConfEth;

/*$PAGE*/

/*
 ************************************************************************************************
 *                                        FUNCTION PROTOTYPES
 ************************************************************************************************
 */

void v_ack_creator(struct T_uart_payload* p_error_response, INT8U error_code);
INT32U i_compute_size(INT8U*);
void i_echo_dataset_direct_send(struct T_uart_payload*, INT8U*);
void v_HK_creator(INT8U);
void central_timer_callback_function(void *);
void simucam_running_timer_callback_function(void *);
int v_parse_data_teste(struct T_uart_payload *p_payload, Timagette_control *p_img_ctrl, x_imagette *dataset[MAX_IMAGETTES]);
void v_ack_int(T_uart_payload* p_error_response, INT8U error_code);
void vSendETHConfig(TConfEth xEthConf);
void vClearRam(void);
void v_p_event_creator(INT8U usi_eid);
void v_error_event_creator(INT8U usi_eid, INT8U usi_data);
void v_p_event_timecode_creator(INT8U usi_timecode, INT8U usi_channel);
/*$PAGE*/

#endif /* COMMAND_CONTROL_H_ */
