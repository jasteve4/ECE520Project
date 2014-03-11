/*=======================================
Christopher Scott Johnson
ECE 520 Histogram Equalizer

This module is responsible for performing the first step of the Histogram equalizer.
It counts the number of times that each pixel value is seen. This is a pipelined module
with 2 feedback loops.

NOTES:
m1 = the memory where the initial memory is stored
m2 = scratchpad memory 1
m3 = scratchpad memory 2
m4 = output memory

========================================*/

module input_pipeline(
  input wire start, clock, rst_n,
  input wire [127:0] m1ReadVal, m2ReadVal,
  output reg [15:0] m1ReadAddr, m2ReadAddr, m2WriteAddr, 
  output reg [127:0] m2WriteVal,
  output reg m2WE,
  output reg done
);

integer i; //used to reset memory
reg [7:0] pipelineCounter;
reg [15:0] memoryCounter;

//pipeline registers
reg [7:0] readVal_FI, readVal_FS, readVal_Accum;
reg [15:0] scratchVal_FS, scratchVal_Accum;
reg m2WE_FI, m2WE_FS, m2WE_Accum, write_enable;


always@(rst_n or pipelineCounter or memoryCounter) begin
  if(!rst_n) begin
      m1ReadAddr <= 0;
      m2ReadAddr <= 0;
      m2WriteAddr <= 0;
      m2WriteVal <= 0;
      readVal_FI <= 0;
      readVal_FS <= 0;
      readVal_Accum <= 0;
      scratchVal_FS <= 0;
      scratchVal_Accum <= 0;
  end else begin
    //===============Fetch Initial(FI) Stage=========================
    m1ReadAddr <= memoryCounter;
    readVal_FI <= m1ReadVal[pipelineCounter+:8'd8];
    m2WE_FI <= write_enable;

    //===============Fetch ScatchPad(FS) Stage=======================
    readVal_FS <= readVal_FI;
    m2ReadAddr <= readVal_FI;
    m2WE_FS <= m2WE_FI;

    if(readVal_FS == readVal_Accum) begin
      scratchVal_FS <= scratchVal_Accum;
    end else begin
      if(m2ReadVal[31:16] == 16'hAAAA) begin
        scratchVal_FS <= m2ReadVal;
      end else begin
        scratchVal_FS <= 32'hAAAA0000;
      end
    end

    //===============Accumulate Stage (Accum)========================
    readVal_Accum <= readVal_FS;
    m2WE_Accum <= m2WE_FS;

    if(readVal_Accum == readVal_FS) begin
      scratchVal_Accum <= scratchVal_Accum + 1'b1; 
    end else begin
      scratchVal_Accum <= scratchVal_FS + 1'b1;
    end

    //===============Store ScratchPad (SS)===========================
    m2WriteAddr <= readVal_Accum;
    m2WE <= m2WE_Accum;
    m2WriteVal <= {16'hAAAA, scratchVal_Accum[15:0]};
  end
end

always@(posedge clock or negedge rst_n) begin   
  if(!rst_n && !start) begin            //Synchronous Active Low Reset
    pipelineCounter <= 8'b0;
    memoryCounter <= 16'b0;
    m2WE_FI <= 1'b0;
    m2WE_FS <= 1'b0;
    m2WE_Accum <= 1'b0;
    m2WE <= 1'b0;
    write_enable <= 1'b0;
  end else begin
    if(memoryCounter < 15'd4) begin
      if(pipelineCounter < 8'd119) begin
        pipelineCounter <= pipelineCounter + 4'd8;
        memoryCounter <= memoryCounter;
      end else begin
        pipelineCounter <= 8'b0;
        memoryCounter <= memoryCounter + 16'b1;
      end

      write_enable <= 1'b1;
      done <= 1'b0;
    end else begin
      memoryCounter <= memoryCounter;
      write_enable <= 1'b0;
      done <= 1'b1;
    end
  end
end

endmodule
