`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2021 04:10:51 PM
// Design Name: 
// Module Name: UART_Rx
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


module UART_Rx#(parameter CLKS_PER_BIT = 10416)//10416
  (
   input        clk,
   input        RsRx,
   output o_RX_DV,
   output [7:0] RxByte //o_Rx_Byte
   );
    
  parameter S0 = 3'b000; //IDLE
  parameter S1 = 3'b001; //START
  parameter S2 = 3'b010; //DATA
  parameter S3 = 3'b011; //STOP
  parameter S4 = 3'b100; //CLEAN
  //parameter s_CLEANUP      = 3'b100;
   
  reg           tempdata1 = 1'b1;
  reg           tempdata   = 1'b1;
   
  reg [15:0]    clockcounter = 0;
  reg [2:0]     index   = 0; //16 bits total //8 [2:0]
  reg [7:0]     tempRx     = 0; //{7:0}
  reg [2:0]     state         = 0;
  reg r_RX_DV = 0;
   
  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always @(posedge clk)
    begin
      tempdata1 <= RsRx;
      tempdata   <= tempdata1;
    end
   
   
  // Purpose: Control RX state machine
  always @(posedge clk)
    begin
       
      case (state)
        S0:
          begin
            r_RX_DV = 1'b0;
            clockcounter <= 0;
            index   <= 0;
             
            if (tempdata == 1'b0)          // Start bit detected
              state <= S1;
            else
              state <= S0;
          end
         
        // Check middle of start bit to make sure it's still low
        S1:
          begin
            if (clockcounter == (CLKS_PER_BIT-1)/2)
              begin
                if (tempdata == 1'b0)
                  begin
                    clockcounter <= 0;  // reset counter, found the middle
                    state <= S2;
                  end
                else
                  state <= S0;
              end
            else
              begin
                clockcounter <= clockcounter + 1;
                state <= S1;
              end
          end // case: s_RX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        S2:
          begin
            if (clockcounter < CLKS_PER_BIT-1)
              begin
                clockcounter <= clockcounter + 1;
                state <= S2;
              end
            else
              begin
                clockcounter          <= 0;
                tempRx[index] <= tempdata;
                 
                // Check if we have received all bits
                if (index < 7) //7---------------------------------
                  begin
                    index <= index + 1;
                    state   <= S2;
                  end
                else
                  begin
                    index <= 0;
                    state   <= S3;
                  end
              end
          end // case: s_RX_DATA_BITS
     
     
        // Receive Stop bit.  Stop bit = 1
        S3:
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (clockcounter < CLKS_PER_BIT-1)
              begin
                clockcounter <= clockcounter + 1;
                state <= S3;
              end
            else
              begin
                clockcounter <= 0;
                state <= S4;
                r_RX_DV =1'b1; //0
              end
          end // case: s_RX_STOP_BIT
     
         
        // Stay here 1 clock
        S4 :
          begin
            state <= S0;
            r_RX_DV   <= 1'b0;
          end
         
         
        default :
          state <= S0;
         
      endcase
    end   
   assign o_RX_DV = r_RX_DV;
  assign RxByte = tempRx; //o_Rx_Byte
   
endmodule // uart_rx