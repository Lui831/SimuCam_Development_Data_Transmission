// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/18.1std/ip/merlin/altera_irq_mapper/altera_irq_mapper.sv.terp#1 $
// $Revision: #1 $
// $Date: 2018/07/18 $
// $Author: psgswbuild $

// -------------------------------------------------------
// Altera IRQ Mapper
//
// Parameters
//   NUM_RCVRS        : 24
//   SENDER_IRW_WIDTH : 32
//   IRQ_MAP          : 0:4,1:5,2:6,3:0,4:1,5:7,6:16,7:19,8:20,9:21,10:23,11:22,12:24,13:25,14:2,15:17,16:3,17:9,18:10,19:11,20:13,21:12,22:14,23:15
//
// -------------------------------------------------------

`timescale 1 ns / 1 ns

module MebX_Qsys_Project_irq_mapper
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // IRQ Receivers
    // -------------------
    input                receiver0_irq,
    input                receiver1_irq,
    input                receiver2_irq,
    input                receiver3_irq,
    input                receiver4_irq,
    input                receiver5_irq,
    input                receiver6_irq,
    input                receiver7_irq,
    input                receiver8_irq,
    input                receiver9_irq,
    input                receiver10_irq,
    input                receiver11_irq,
    input                receiver12_irq,
    input                receiver13_irq,
    input                receiver14_irq,
    input                receiver15_irq,
    input                receiver16_irq,
    input                receiver17_irq,
    input                receiver18_irq,
    input                receiver19_irq,
    input                receiver20_irq,
    input                receiver21_irq,
    input                receiver22_irq,
    input                receiver23_irq,

    // -------------------
    // Command Source (Output)
    // -------------------
    output reg [31 : 0] sender_irq
);


    always @* begin
	sender_irq = 0;

        sender_irq[4] = receiver0_irq;
        sender_irq[5] = receiver1_irq;
        sender_irq[6] = receiver2_irq;
        sender_irq[0] = receiver3_irq;
        sender_irq[1] = receiver4_irq;
        sender_irq[7] = receiver5_irq;
        sender_irq[16] = receiver6_irq;
        sender_irq[19] = receiver7_irq;
        sender_irq[20] = receiver8_irq;
        sender_irq[21] = receiver9_irq;
        sender_irq[23] = receiver10_irq;
        sender_irq[22] = receiver11_irq;
        sender_irq[24] = receiver12_irq;
        sender_irq[25] = receiver13_irq;
        sender_irq[2] = receiver14_irq;
        sender_irq[17] = receiver15_irq;
        sender_irq[3] = receiver16_irq;
        sender_irq[9] = receiver17_irq;
        sender_irq[10] = receiver18_irq;
        sender_irq[11] = receiver19_irq;
        sender_irq[13] = receiver20_irq;
        sender_irq[12] = receiver21_irq;
        sender_irq[14] = receiver22_irq;
        sender_irq[15] = receiver23_irq;
    end

endmodule

