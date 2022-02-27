`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2021 04:53:43 PM
// Design Name: 
// Module Name: UART_Tx
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


module UART_Tx#(parameter CLKS_PER_BIT=10416)
  (
   input       clk,
   input [7:0] inputdata, 
   input       dataValue,
   output      active,
   output reg  RsTx,
   output      done
   );
  
  parameter S0 = 3'b000; //IDLE
  parameter S1 = 3'b001; //START
  parameter S2 = 3'b010; //DATA
  parameter S3 = 3'b011; //STOP
  parameter S4 = 3'b100; //CLEAN
   
  reg [2:0]    state     = 0;
  reg [15:0]    clockcounter = 0;
  reg [2:0]    index   = 0; //8 [2:0]
  reg [7:0]    tempdata     = 0; //[7]
  reg          tempdone     = 0;
  reg          tempactive   = 0;
     
  always @(posedge clk)
    begin
       
      case (state)
        S0 :
          begin
            RsTx   <= 1'b1;         // Drive Line High for Idle
            tempdone     <= 1'b0;
            clockcounter <= 0;
            index   <= 0;
            
            if(dataValue == 1'b1) begin
                tempactive <= 1'b1;
                tempdata   <= inputdata;
                state   <= S1;
            end
            else
            state <= S0; ///////////////////////////
          end // case: IDLE
         
         
        // Send out Start Bit. Start bit = 0
        S1 :
          begin
            RsTx <= 1'b0;
             
            // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (clockcounter < CLKS_PER_BIT-1)
              begin
                clockcounter <= clockcounter + 1;
                state     <= S1;
              end
            else
              begin
                clockcounter <= 0;
                state     <= S2;
              end
          end // case: START
         
         
        // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
        S2 :
          begin
            RsTx <= tempdata[index];
             
            if (clockcounter < CLKS_PER_BIT-1)
              begin
                clockcounter <= clockcounter + 1;
                state     <= S2;
              end
            else
              begin
                clockcounter <= 0;
                 
                // Check if we have sent out all bits
                if (index < 7) //7-------------------------------
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
          end // case: DATA
         
         
        // Send out Stop bit.  Stop bit = 1
        S3 :
          begin
            RsTx <= 1'b1;
             
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (clockcounter < CLKS_PER_BIT-1)
              begin
                clockcounter <= clockcounter + 1;
                state     <= S3;
              end
            else
              begin
                tempdone     <= 1'b1;
                clockcounter <= 0;
                state <= S4;
                tempactive   <= 1'b0;
              end
          end // case: STOP
          S4:
          begin
            tempdone <= 1'b1;
            state <= S0;
          end
         
        default :
          state <= S0;
         
      endcase
    end
 
  assign active = tempactive;
  assign done   = tempdone;
   
endmodule
