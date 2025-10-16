/* ------------------------------------------------------------------------------------ */
// mailbox_drivers.h
// Description: This file contains the definitions, macros and prototypes for the mailbox
// drivers.
// Authors: Luiz H. A. Santos, Rafaella A. C. Zeron, Pedro A. W. Dian, João P. Fogetti, 
// Rodrigo M. França
// Date: 05/05/2025.
/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
// Include libraries

#include <stdio.h>
#include "alt_types.h"
#include "system.h"
#include "sys/alt_irq.h"

/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
// Mailbox registers struct

// -------------------------------------------------------------------
// Configuration and auxiliary structs

// Send status struct
typedef struct t_mailbox_send_status_bits{

    // Empty Flag
    alt_u32 u32EmptyFlag : 1; // 0x00
    // Full Flag
    alt_u32 u32FullFlag : 1; // 0x01
    // Message Size
    alt_u32 u32MsgSize : 16; // 0x02

} t_mailbox_send_status_bits;

// Recv status struct
typedef struct t_mailbox_recv_status_bits{

    // Empty Flag
    alt_u32 u32EmptyFlag : 1; // 0x00
    // Full Flag
    alt_u32 u32FullFlag : 1; // 0x01
    // Message Size
    alt_u32 u32MsgSize : 16; // 0x02

} t_mailbox_recv_status_bits;

// Recv Control Struct
typedef struct t_mailbox_recv_cntrl_bits{

    // Enable Flag
    alt_u32 u32EnFlag : 1; // 0x01
    // IRQ Enable Flag
    alt_u32 u32IrqEnFlag : 1; // 0x02

} t_mailbox_recv_cntrl_bits;


/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
// Defines and Macros for the mailbox

// Defines the important macros and constants for the Avalon MM Send interface of the Mailbox

// Register Offsets
#define MAILBOX_SEND_STATUS_REG_OFFSET 0x00 // Offset for the status register
#define MAILBOX_SEND_MESSAGE_REG_OFFSET 0x04 // Offset for the message register

// Offsets and sizes regarding the status register
#define MAILBOX_SEND_STATUS_REG_SIZE 0x04 // Size of the status register

#define MAILBOX_SEND_STATUS_REG_EMPTY_FLAG 0b01 << 0 // Flag for the empty status register
#define MAILBOX_SEND_STATUS_REG_EMPTY_OFFSET 0 // Offset for the empty status register flag

#define MAILBOX_SEND_STATUS_REG_FULL_FLAG 0b01 << 1 // Flag for the full status register
#define MAILBOX_SEND_STATUS_REG_FULL_OFFSET 1 // Offset for the full status register flag

#define MAILBOX_SEND_STATUS_REG_MSG_SIZE_FLAG 0xFFFF << 2 // Flag for the message size in the status register
#define MAILBOX_SEND_STATUS_REG_MSG_SIZE_OFFSET 2 // Offset for the message size in the status register

// Offsets and sizes regarding the message register
#define MAILBOX_SEND_MESSAGE_REG_SIZE 0x04 // Size of the message register

#define MAILBOX_SEND_MESSAGE_REG_SIZE_FLAG 0xFFFFFFFF // Flag for the message size in the message register
#define MAILBOX_SEND_MESSAGE_REG_SIZE_OFFSET 0 // Offset for the message size in the message register

// Important macros for the mailbox send interface
#define MAILBOX_SEND_STATUS_REG_GET(u32MailboxOffset, u32Val) (u32Val = IORD(u32MailboxOffset, MAILBOX_SEND_STATUS_REG_OFFSET / 4)) // Get the status register

#define MAILBOX_SEND_MESSAGE_REG_WRITE(u32MailboxOffset, u32Val) \
 IOWR(u32MailboxOffset, MAILBOX_SEND_MESSAGE_REG_OFFSET / 4, u32Val) // Write to the message register


// Defines the important macros and constants for the Avalon MM Recv interface of the Mailbox

// Register Offsets
#define MAILBOX_RECV_CNTRL_REG_OFFSET 0x00 // Offset for the control register
#define MAILBOX_RECV_STATUS_REG_OFFSET 0x04 // Offset for the status register
#define MAILBOX_RECV_MESSAGE_REG_OFFSET 0x08 // Offset for the message register

// Offsets and sizes regarding the cntrl register
#define MAILBOX_RECV_CNTRL_REG_SIZE 0x04 // Size of the control register

#define MAILBOX_RECV_CNTRL_REG_PROC_RST_FLAG 0b01 << 0 // Flag for the process reset in the control register
#define MAILBOX_RECV_CNTRL_REG_PROC_RST_OFFSET 0 // Offset for the process reset in the control register

#define MAILBOX_RECV_CNTRL_REG_EN_FLAG 0b01 << 1 // Flag for the enable in the control register
#define MAILBOX_RECV_CNTRL_REG_EN_OFFSET 1 // Offset for the enable in the control register

#define MAILBOX_RECV_CNTRL_REG_IRQ_EN_FLAG 0b01 << 2 // Flag for the IRQ enable in the control register
#define MAILBOX_RECV_CNTRL_REG_IRQ_EN_OFFSET 2 // Offset for the IRQ enable in the control register

#define MAILBOX_RECV_CNTRL_REG_IRQ_CLR_FLAG 0b01 << 3 // Flag for the IRQ clear in the control register
#define MAILBOX_RECV_CNTRL_REG_IRQ_CLR_OFFSET 3 // Offset for the IRQ clear in the control register

// Offsets and sizes regarding the status register
#define MAILBOX_RECV_STATUS_REG_SIZE 0x04 // Size of the status register

#define MAILBOX_RECV_STATUS_REG_EMPTY_FLAG 0b01 << 0 // Flag for the empty status register
#define MAILBOX_RECV_STATUS_REG_EMPTY_OFFSET 0 // Offset for the empty status register flag

#define MAILBOX_RECV_STATUS_REG_FULL_FLAG 0b01 << 1 // Flag for the full status register
#define MAILBOX_RECV_STATUS_REG_FULL_OFFSET 1 // Offset for the full status register flag

#define MAILBOX_RECV_STATUS_REG_MSG_SIZE_FLAG 0xFFFF << 2 // Flag for the message size in the status register
#define MAILBOX_RECV_STATUS_REG_MSG_SIZE_OFFSET 2 // Offset for the message size in the status register

// Offsets and sizes regarding the message register
#define MAILBOX_RECV_MESSAGE_REG_SIZE 0x04 // Size of the message register

#define MAILBOX_SEND_MESSAGE_REG_SIZE_FLAG 0xFFFFFFFF // Flag for the message size in the message register
#define MAILBOX_SEND_MESSAGE_REG_SIZE_OFFSET 0 // Offset for the message size in the message register

// Important macros for the mailbox recv interface
#define MAILBOX_RECV_CNTRL_REG_SET(u32MailboxOffset, u32Val)          \
    do {                                                             \
        alt_u32 tempVal = IORD(u32MailboxOffset, MAILBOX_RECV_CNTRL_REG_OFFSET / 4); \
        tempVal |= u32Val;                                           \
        IOWR(u32MailboxOffset, MAILBOX_RECV_CNTRL_REG_OFFSET / 4, tempVal); \
    } while (0) // Set the control register

#define MAILBOX_RECV_CNTRL_REG_RESET(u32MailboxOffset, u32Val)       \
    do {                                                             \
        alt_u32 tempVal = IORD(u32MailboxOffset, MAILBOX_RECV_CNTRL_REG_OFFSET / 4); \
        tempVal &= ~u32Val;                                          \
        IOWR(u32MailboxOffset, MAILBOX_RECV_CNTRL_REG_OFFSET / 4, tempVal); \
    } while (0) // Reset the control register
	
#define MAILBOX_RECV_CNTRL_REG_GET(u32MailboxOffset, u32Val) (u32Val = IORD(u32MailboxOffset, MAILBOX_RECV_CNTRL_REG_OFFSET / 4)) // Get the control register

#define MAILBOX_RECV_STATUS_REG_GET(u32MailboxOffset, u32Val) (u32Val = IORD(u32MailboxOffset, MAILBOX_RECV_STATUS_REG_OFFSET / 4)) // Get the status register

#define MAILBOX_RECV_MESSAGE_REG_GET(u32MailboxOffset, u32Val) \
 (u32Val = IORD(u32MailboxOffset, MAILBOX_RECV_MESSAGE_REG_OFFSET / 4)) // Get the message register


/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
// Defines important prototypes for the functions

// -------------------------------------------------------------------------------------
// Functions to manually control the Mailbox and it's interfaces



// Function write to the message register
void mailbox_send_write_message_reg(alt_u32 u32MailboxOffset, alt_u32 u32Message);

// Function to get the status register
alt_u32 mailbox_send_get_status_reg(alt_u32 u32MailboxOffset);


// Functions to manually control the Recv interface of the mailbox

// Function to set the cntrl register
void mailbox_recv_set_cntrl_reg(alt_u32 u32MailboxOffset, alt_u32 u32CntrlRegFlags);

// Function to reset the cntrl register
void mailbox_recv_reset_cntrl_reg(alt_u32 u32MailboxOffset, alt_u32 u32CntrlRegFlags);

// Functions to set, reset and get the cntrl register
alt_u32 mailbox_recv_get_cntrl_reg(alt_u32 u32MailboxOffset);

// Function to get the status register
alt_u32 mailbox_recv_get_status_reg(alt_u32 u32MailboxOffset);

// Function to get the message register
alt_u32 mailbox_recv_get_message_reg(alt_u32 u32MailboxOffset);


// -------------------------------------------------------------------------------------
// Functions to control the mailbox and it's interfaces with more abstraction


// Functions to interact with the mailbox send interface

// Function to get the send status register informations
t_mailbox_send_status_bits mailbox_send_get_status_reg_abs(alt_u32 u32MailboxOffset);

// Function to get the send message register informations
void mailbox_send_write_message_reg_abs(alt_u32 u32MailboxOffset, alt_u32 u32Message);


// Functions to interact with the mailbox recv interface

// Function to reset and unreset the mailbox
void mailbox_recv_reset_abs(alt_u32 u32MailboxOffset);

// Function to configure the mailbox and it's interfaces, based on it's control register
void mailbox_recv_config_abs(alt_u32 u32MailboxOffset, t_mailbox_recv_cntrl_bits *pMailboxRecvCntrlConfig, alt_u32 u32IRQId, void *pCallback, void *pContext);

// Function to get the recv status register informations
t_mailbox_recv_status_bits mailbox_recv_get_status_reg_abs(alt_u32 u32MailboxOffset);

// Function to get the recv message register informations
alt_u32 mailbox_recv_get_message_reg_abs(alt_u32 u32MailboxOffset);

// Function to deassert the IRQ of the mailbox
void mailbox_recv_deassert_irq_abs(alt_u32 u32MailboxOffset);



/* ------------------------------------------------------------------------------------ */
