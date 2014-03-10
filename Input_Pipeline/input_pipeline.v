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
reg memoryCounter;

//pipeline registers
reg [7:0] readVal_FI, readVal_FS, readVal_Accum;
reg [7:0] scratchVal_FS, scratchVal_Accum;


always@(rst_n or pipelineCounter or memoryCounter) begin
  if(!rst_n) begin
    for(i=0;i<255;i=i+1) begin  //initialize the scratchpad to 0
      m2WriteAddr <= 0;
    end
  end else begin
    //===============Fetch Initial(FI) Stage=========================
    m1ReadAddr <= memoryCounter;
    readVal_FI <= m1ReadVal[pipelineCounter+:8];
    
    //===============Fetch ScatchPad(FS) Stage=======================
    readVal_FS <= readVal_FI;
    m2ReadAddr <= readVal_FS;

    if(readVal_FI == readVal_Accum) begin
      scratchVal_FS <= scratchVal_Accum;
    end else begin
      scratchVal_FS <= (readVal_FI == m2ReadVal;
    end

    //===============Accumulate Stage (Accum)========================
    readVal_Accum <= readVal_FS;
    if(readVal_Accum == readVal_FS) begin
      scratchVal_Accum <= scratchVal_Accum + 1; 
    end else begin
      scratchVal_Accum <= scratchVal_FS + 1;
    end
    //===============Store ScratchPad (SS)===========================
    m2WriteAddr <= readVal_Accum;
    m2WriteVal <= scratchVal_Accum;
  end
end

always@(posedge clock or negedge rst_n) begin   
  if(!rst_n) begin            //Synchronous Active Low Reset
    pipelineCounter <= 0;
    memoryCounter <= 0;
 end else begin if(start) begin
    if(pipelineCounter > 119) begin
      pipelineCounter <= 0;
      memoryCounter <= memoryCounter + 1;
    end else begin
      pipelineCounter <= pipelineCounter + 8;
      memoryCounter <= memoryCounter;
    end
  end end
end

endmodule
