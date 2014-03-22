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
  input wire inputBaseOffset,
  output reg [15:0] m1ReadAddr, m2ReadAddr, m2WriteAddr, 
  output reg [127:0] m2WriteVal,
  output reg m2WE,
  output reg done
);

//NEEDED PARAMETERS
parameter ADDRESS_OF_LAST = 3;

//PIPELINE STATES
parameter [2:0]
  RESET = 3'b000,
  GET_VALUES = 3'b001,
  LOAD_NEXT = 3'b010,
  GET_LAST_VAL = 3'b011,
  FINAL_LOAD1 = 3'b100,
  FINAL_LOAD2 = 3'b101, 
  DONE = 3'b110;


reg [6:0] pipelineCounter, pipelineCounterFF;
reg [15:0] memoryCounter, memoryCounterFF;

//pipeline registers
reg [7:0] readVal_FI, readVal_FS, readVal_Accum;
reg [31:0] scratchVal_FS, scratchVal_Accum;
reg [1:0] addVal_FI, addVal_FS;
reg m2WE_FI, m2WE_FS, m2WE_Accum, write_enable;
reg done_FI, done_FS, done_enable;
reg [2:0] cstate, nstate;

always@(posedge clock) begin
  if(!rst_n && !start) begin
      m1ReadAddr <= 0;
      m2ReadAddr <= 0;
      m2WriteAddr <= 0;
      m2WriteVal <= 0;
      readVal_FI <= 0;
      readVal_FS <= 0;
      readVal_Accum <= 0;
      scratchVal_FS <= 0;
      scratchVal_Accum <= 0;
      m2WE_FI <= 1'b0;
      m2WE_FS <= 1'b0;
      m2WE_Accum <= 1'b0;
      m2WE <= 1'b0;
      done_FI <= 1'b0;
      done_FS <= 1'b0;
      done <= 1'b0;
  end else begin
    //===============Fetch Initial(FI) Stage=========================
    m1ReadAddr <= memoryCounterFF;
    readVal_FI <= m1ReadVal[pipelineCounterFF+:8'd8];
    m2WE_FI <= write_enable;
    done_FI <= done_enable;
    m2ReadAddr <= {inputBaseOffset,m1ReadVal[pipelineCounterFF+:8'd8]};
    
    if(m2WE &&(m2WriteAddr == m1ReadVal[pipelineCounterFF+:8'd8])) begin
      addVal_FI <= 2'd2;
    end else begin
      addVal_FI <= 2'b1;
    end

    //===============Fetch ScatchPad(FS) Stage=======================
    readVal_FS <= readVal_FI;
    addVal_FS <= addVal_FI;
    m2WE_FS <= m2WE_FI;
    done_FS <= done_FI;

    if(m2WE && (readVal_FI == m2WriteAddr)) begin
      scratchVal_FS <= m2WriteVal;
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

    if(m2WE && (m2WriteAddr == readVal_FS)) begin
      scratchVal_Accum <= m2WriteVal + addVal_FS; 
    end else begin
      scratchVal_Accum <= {16'hAAAA, scratchVal_FS[15:0]} + addVal_FS;
    end

    //===============Store ScratchPad (SS)===========================
    m2WriteAddr <= {inputBaseOffset,readVal_Accum};
    m2WE <= m2WE_Accum;
    m2WriteVal <= scratchVal_Accum;
  end
end

always@(cstate or start or pipelineCounterFF) begin
  case(cstate)
    RESET: begin
      pipelineCounter <= 8'b0;
      memoryCounter <= 16'b0;
      done_enable <= 1'b0;
      write_enable <= 1'b0;

      if(start) begin
        nstate <= GET_VALUES;
      end else begin
        nstate <= RESET;
      end
    end

    GET_VALUES: begin
      pipelineCounter <= pipelineCounter + 4'd8;
      memoryCounter <= memoryCounter;
      done_enable <= 1'b0;
      write_enable <= 1'b1;

      if(pipelineCounter < 8'd104) begin
        nstate <= GET_VALUES;
      end else begin
        nstate <= LOAD_NEXT;
      end
    end

    LOAD_NEXT: begin
      pipelineCounter <= pipelineCounter + 4'd8;
      memoryCounter <= memoryCounter + 16'd1;
      done_enable <= 1'b0;
      write_enable <= 1'b1;
      
      nstate <= GET_LAST_VAL;
    end

    GET_LAST_VAL: begin
      pipelineCounter <= pipelineCounter + 4'd8;
      memoryCounter <= memoryCounter;
      done_enable <= 1'b0;
      write_enable <= 1'b1;

      if(memoryCounter < 3) begin
        nstate <= GET_VALUES;
      end else begin
        nstate <= FINAL_LOAD1;
      end
    end

    FINAL_LOAD1: begin
      pipelineCounter <= pipelineCounter + 8'd8;
      memoryCounter <= memoryCounter;
      done_enable <= 1'b0;
      write_enable <= 1'b1;
      nstate <= FINAL_LOAD2;
    end

    FINAL_LOAD2: begin
      pipelineCounter <= pipelineCounter + 8'd8;
      memoryCounter <= memoryCounter;
      done_enable <= 1'b0;
      write_enable <= 1'b1;
      
      if(pipelineCounter < 8'd120) begin
        nstate <= FINAL_LOAD2;
      end else begin
        nstate <= DONE;
      end
    end

    DONE: begin
      pipelineCounter <= pipelineCounter;
      memoryCounter <= memoryCounter;
      done_enable <= 1'b1;
      write_enable <= 1'b0;
      if(start) begin
        nstate <= DONE;
      end else begin
        nstate <= RESET;
      end
    end

    default: begin
      nstate <= RESET;
    end
  endcase
end

always@(posedge clock or negedge rst_n) begin   
  if(!rst_n) begin            //Synchronous Active Low Reset
    cstate <= RESET;
  end else begin
    cstate <= nstate;
  end
  
  pipelineCounterFF <= pipelineCounter;
  memoryCounterFF <= memoryCounter;
end

endmodule
