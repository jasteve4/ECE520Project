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

parameter ADDRESS_OF_LAST = 3;

reg [6:0] pipelineCounter;
reg [15:0] memoryCounter;

//pipeline registers
reg [7:0] readVal_FI, readVal_FS, readVal_Accum;
reg [15:0] scratchVal_FS;
reg [31:0] scratchVal_Accum;
reg m2WE_FI, m2WE_FS, m2WE_Accum, write_enable;
reg done_FI, done_FS, done_enable;

//debuggig
reg [256:0] write_cnt;

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
      write_cnt <= 0;
      m2WE_FI <= 1'b0;
      m2WE_FS <= 1'b0;
      m2WE_Accum <= 1'b0;
      m2WE <= 1'b0;
      done_FI <= 1'b0;
      done_FS <= 1'b0;
      done <= 1'b0;
  end else begin
    //===============Fetch Initial(FI) Stage=========================
    m1ReadAddr <= memoryCounter;
    readVal_FI <= m1ReadVal[pipelineCounter+:8'd8];
    m2WE_FI <= write_enable;
    m2ReadAddr <= m1ReadVal[pipelineCounter+:8'd8];

    //===============Fetch ScatchPad(FS) Stage=======================
    readVal_FS <= readVal_FI;
    m2WE_FS <= m2WE_FI;
    done_FS <= done_FI;

    if(readVal_FI == readVal_Accum) begin
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
    done <= done_FS;

    if(readVal_Accum == readVal_FS) begin
      scratchVal_Accum <= scratchVal_Accum + 1'b1; 
    end else begin
      scratchVal_Accum <= {16'hAAAA, scratchVal_FS[15:0]} + 1'b1;
    end

    //===============Store ScratchPad (SS)===========================
    m2WriteAddr <= readVal_Accum;
    m2WE <= m2WE_Accum;
    m2WriteVal <= scratchVal_Accum;

    //debugging
    if(m2WE) begin
      write_cnt <= write_cnt + 1;
    end else begin
      write_cnt <= write_cnt;
    end
  end
end

always@(posedge clock or negedge rst_n) begin   
  if(!rst_n) begin            //Synchronous Active Low Reset
    pipelineCounter <= 8'b0;
    memoryCounter <= 16'b0;
    done_enable <= 0;
    write_enable <= 1'b0;
  end else begin
    if(start) begin
      if(memoryCounter < ADDRESS_OF_LAST) begin
        if(pipelineCounter < 8'd111) begin
          pipelineCounter <= pipelineCounter + 4'd8;
          memoryCounter <= memoryCounter;
        end else begin 
          if (pipelineCounter < 8'd118) begin
            pipelineCounter <= pipelineCounter +4'd8;
            memoryCounter <= memoryCounter + 16'b1;
          end else begin
            pipelineCounter <= 8'b0;
            memoryCounter <= memoryCounter;
          end 
        end
      
        write_enable <= 1'b1;
        done_enable <= 1'b0;
      end else begin
        if (pipelineCounter < 8'd118) begin
          pipelineCounter <= pipelineCounter +4'd8;
          memoryCounter <= memoryCounter + 16'b1;
          write_enable <= 1'b1;
          done_enable <= 1'b0;
        end else begin
          pipelineCounter <= 8'b0;
          memoryCounter <= memoryCounter;
          write_enable <= 1'b0;
          done_enable <= 1'b1;
        end 
      end
    end else begin
      pipelineCounter <= 8'b0;
      memoryCounter <= 16'b0;
      done_enable <= 0;
      write_enable <= 1'b0;
    end
  end
end

endmodule
