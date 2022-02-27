`timescale 1ns / 1ps
`include "UART_Rx.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2021 09:41:53 PM
// Design Name: 
// Module Name: UART_Rx_tb
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


module UART_Rx_tb(

    );
  parameter c_CLOCK_PERIOD_NS = 100;
  parameter c_CLKS_PER_BIT    = 1042;
   
  reg clk = 0;
  reg RsRx = 1;
  wire [7:0] RxByte;
  
  
       task UART_WRITE_BYTE;
        input [7:0] i_data;
        integer ii;
        begin
        RsRx <= 1'b0;
        #10420
        for(ii=0; ii<8; ii=ii+1)
        begin
            RsRx <= i_data[ii];
            #10420;
        end
        //send stop bit
        RsRx <=1'b1;
        #10420;
        end
        endtask
   
  UART_Rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_INST
    (.clk(clk),
     .RsRx(RsRx),
     .RxByte(RxByte)
     );
     

 
          always
    #(c_CLOCK_PERIOD_NS/2) clk <= !clk;

    
    initial begin
    @(posedge clk);
    UART_WRITE_BYTE(8'h3F);
    @(posedge clk);
    
    if(RxByte == 8'h3F)
    $display("Test Passed");
    else
    $display("Test Failed");
    end

    
endmodule
