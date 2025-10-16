/* ------------------------------------------------------------------------------------ */
// mailbox_drivers.c
// Description: This file contains the implementation of the mailbox drivers.
// Authors: Luiz H. A. Santos, Rafaella A. C. Zeron, Pedro A. W. Dian, João P. Fogetti, 
// Rodrigo M. França
// Date: 05/05/2025.
/* ------------------------------------------------------------------------------------ */

/* ------------------------------------------------------------------------------------ */
// Include libraries

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "alt_types.h"
#include "system.h"
#include "sys/alt_irq.h"
#include "../../HAL/inc/io.h"
#include "./mailbox_drivers.h"

/* ------------------------------------------------------------------------------------ */
// Function implementations

// -------------------------------------------------------------------------------------
// Functions to manually control the Mailbox and its interfaces

// Function to write to the message register of the send interface
void mailbox_send_write_message_reg(alt_u32 u32MailboxOffset, alt_u32 u32Message)
{
    MAILBOX_SEND_MESSAGE_REG_WRITE(u32MailboxOffset, u32Message);
}

// Function to get the status register of the send interface
alt_u32 mailbox_send_get_status_reg(alt_u32 u32MailboxOffset)
{
    alt_u32 u32StatusReg;
    MAILBOX_SEND_STATUS_REG_GET(u32MailboxOffset, u32StatusReg);
    return u32StatusReg;
}

// Function to set the control register of the recv interface
void mailbox_recv_set_cntrl_reg(alt_u32 u32MailboxOffset, alt_u32 u32CntrlRegFlags)
{
    MAILBOX_RECV_CNTRL_REG_SET(u32MailboxOffset, u32CntrlRegFlags);
}

// Function to reset the control register of the recv interface
void mailbox_recv_reset_cntrl_reg(alt_u32 u32MailboxOffset, alt_u32 u32CntrlRegFlags)
{
    MAILBOX_RECV_CNTRL_REG_RESET(u32MailboxOffset, u32CntrlRegFlags);
}

// Function to get the control register of the recv interface
alt_u32 mailbox_recv_get_cntrl_reg(alt_u32 u32MailboxOffset)
{
    alt_u32 u32CntrlReg;
    MAILBOX_RECV_CNTRL_REG_GET(u32MailboxOffset, u32CntrlReg);
    return u32CntrlReg;
}

// Function to get the status register of the recv interface
alt_u32 mailbox_recv_get_status_reg(alt_u32 u32MailboxOffset)
{
    alt_u32 u32StatusReg;
    MAILBOX_RECV_STATUS_REG_GET(u32MailboxOffset, u32StatusReg);
    return u32StatusReg;
}

// Function to get the message register of the recv interface
alt_u32 mailbox_recv_get_message_reg(alt_u32 u32MailboxOffset)
{
    alt_u32 u32MessageReg;
    MAILBOX_RECV_MESSAGE_REG_GET(u32MailboxOffset, u32MessageReg);
    return u32MessageReg;
}

// -------------------------------------------------------------------------------------
// Functions to control the mailbox and its interfaces with more abstraction

// Function to get the send status register information with abstraction
t_mailbox_send_status_bits mailbox_send_get_status_reg_abs(alt_u32 u32MailboxOffset)
{
    t_mailbox_send_status_bits statusBits;
    alt_u32 u32StatusReg = mailbox_send_get_status_reg(u32MailboxOffset);

    statusBits.u32EmptyFlag = (u32StatusReg & MAILBOX_SEND_STATUS_REG_EMPTY_FLAG) >> MAILBOX_SEND_STATUS_REG_EMPTY_OFFSET;
    statusBits.u32FullFlag = (u32StatusReg & MAILBOX_SEND_STATUS_REG_FULL_FLAG) >> MAILBOX_SEND_STATUS_REG_FULL_OFFSET;
    statusBits.u32MsgSize = (u32StatusReg & MAILBOX_SEND_STATUS_REG_MSG_SIZE_FLAG) >> MAILBOX_SEND_STATUS_REG_MSG_SIZE_OFFSET;

    return statusBits;
}

// Function to write to the send message register with abstraction
void mailbox_send_write_message_reg_abs(alt_u32 u32MailboxOffset, alt_u32 u32Message)
{
    mailbox_send_write_message_reg(u32MailboxOffset, u32Message);
}

// Function to reset and unreset the recv interface with abstraction
void mailbox_recv_reset_abs(alt_u32 u32MailboxOffset)
{
    mailbox_recv_set_cntrl_reg(u32MailboxOffset, MAILBOX_RECV_CNTRL_REG_PROC_RST_FLAG);
    mailbox_recv_reset_cntrl_reg(u32MailboxOffset, MAILBOX_RECV_CNTRL_REG_PROC_RST_FLAG);
}

// Function to configure the recv interface with abstraction
void mailbox_recv_config_abs(alt_u32 u32MailboxOffset, t_mailbox_recv_cntrl_bits *pMailboxRecvCntrlConfig, alt_u32 u32IRQId, void *pCallback, void *pContext)
{
    alt_u32 u32CntrlRegFlags = 0;

    if (pMailboxRecvCntrlConfig->u32EnFlag) {
        u32CntrlRegFlags |= MAILBOX_RECV_CNTRL_REG_EN_FLAG;
    }
    if (pMailboxRecvCntrlConfig->u32IrqEnFlag) {
        u32CntrlRegFlags |= MAILBOX_RECV_CNTRL_REG_IRQ_EN_FLAG;
    }

    mailbox_recv_set_cntrl_reg(u32MailboxOffset, u32CntrlRegFlags);

    // Register the IRQ if enabled
    if (pMailboxRecvCntrlConfig->u32IrqEnFlag) {
        alt_ic_isr_register(0, u32IRQId, pCallback, pContext, NULL);
    }
}

// Function to get the recv status register information with abstraction
t_mailbox_recv_status_bits mailbox_recv_get_status_reg_abs(alt_u32 u32MailboxOffset)
{
    t_mailbox_recv_status_bits statusBits;
    alt_u32 u32StatusReg = mailbox_recv_get_status_reg(u32MailboxOffset);

    statusBits.u32EmptyFlag = (u32StatusReg & MAILBOX_RECV_STATUS_REG_EMPTY_FLAG) >> MAILBOX_RECV_STATUS_REG_EMPTY_OFFSET;
    statusBits.u32FullFlag = (u32StatusReg & MAILBOX_RECV_STATUS_REG_FULL_FLAG) >> MAILBOX_RECV_STATUS_REG_FULL_OFFSET;
    statusBits.u32MsgSize = (u32StatusReg & MAILBOX_RECV_STATUS_REG_MSG_SIZE_FLAG) >> MAILBOX_RECV_STATUS_REG_MSG_SIZE_OFFSET;

    return statusBits;
}

// Function to get the recv message register information with abstraction
alt_u32 mailbox_recv_get_message_reg_abs(alt_u32 u32MailboxOffset)
{
    return mailbox_recv_get_message_reg(u32MailboxOffset);
}

// Function to deassert the IRQ of the recv interface with abstraction
void mailbox_recv_deassert_irq_abs(alt_u32 u32MailboxOffset)
{
    mailbox_recv_set_cntrl_reg(u32MailboxOffset, MAILBOX_RECV_CNTRL_REG_IRQ_CLR_FLAG);
    mailbox_recv_reset_cntrl_reg(u32MailboxOffset, MAILBOX_RECV_CNTRL_REG_IRQ_CLR_FLAG);
}
