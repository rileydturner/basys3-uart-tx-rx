`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2021 10:04:40 AM
// Design Name: 
// Module Name: UART_TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_TOP(
    input clk,
    input RsRx,
    output RsTx
    );
    wire [7:0] temp;
    wire DV;
    //parameter clkperiod = 100;
    parameter CLKS_PER_BIT = 10416; //10416
    //parameter bitperiod = 104100;
    
    
    UART_Rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uut0 (.clk(clk), .RsRx(RsRx), .RxByte(temp), .o_RX_DV(DV));
    
    UART_Tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uut1 (.clk(clk), .inputdata(temp), .RsTx(RsTx), .dataValue(DV), .active(), .done());
endmodule
