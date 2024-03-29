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
  input start, clock, rst_n,
  input [127:0] m1ReadBus,
  input [35:0] m2ReadBus,
  input inputBaseOffset,
  output reg [15:0] m1ReadAddr, 
  output reg [15:0] m2ReadAddr, 
  output reg [15:0] m2WriteAddr, m3WriteAddr, 
  output reg [127:0] m2WriteBus, m3WriteBus,
  output reg m2WE, m3WE,
  output reg input_done
);


//=====================NEEDED PARAMETERS=====================
//parameter ADDRESS_OF_LAST = 15'd3;
parameter ADDRESS_OF_LAST = 15'd19199;

//======================PIPELINE STATES======================
parameter [2:0]
  RESET = 3'b000,
  GET_VALUES = 3'b001,
  LOAD_NEXT = 3'b010,
  GET_LAST_VAL = 3'b011,
  FINAL_LOAD1 = 3'b100,
  FINAL_LOAD2 = 3'b101, 
  DONE = 3'b110;

//===================Pipeline Registers=====================
reg write_enable, m2WE_FI, m2WE_FS, m2WE_Accum;
reg [14:0] readInitial_FI, readInitial_FS, readInitial_Accum;
reg [35:0] scratchVal_FS, scratchVal_Accum;
reg done_FI, done_FS, done_Accum, done_enable;
reg [6:0] pipelineCounter;
reg [15:0] memoryCounter;

//===================MISC Wires and Regs===================
reg [15:0] m1ReadBus_Reg;
reg [35:0] m2ReadBus_Reg;

//===================Write To Memory=======================
always@(*) begin
  m1ReadBus_Reg <= m1ReadBus[pipelineCounter+:8'd8];
  m1ReadAddr <= memoryCounter;
 
  m2ReadAddr <= {inputBaseOffset,readInitial_FI};
  if(!input_done && (readInitial_FI == m2WriteAddr[14:0])) begin
    m2ReadBus_Reg <= m2WriteBus[35:0];
  end else begin 
    m2ReadBus_Reg <= m2ReadBus[35:0];
  end
end

always@(posedge clock) begin
  m2WE <= m2WE_Accum;
  m2WriteAddr <= {inputBaseOffset,readInitial_Accum};
  m2WriteBus <= scratchVal_Accum;

  m3WE <= m2WE_FI;
  m3WriteAddr <= {inputBaseOffset,m1ReadAddr[14:0]};
  m3WriteBus <= m1ReadBus;

  input_done <= done_Accum;
end

//===================Pipeline====================
always@(posedge clock or negedge rst_n) begin
  if(!rst_n) begin
      readInitial_FI <= 0;
      readInitial_FS <= 0;
      readInitial_Accum <= 0;
      scratchVal_FS <= 36'hAAAA00000;
      scratchVal_Accum <= 36'hAAAA00000;
      m2WE_FI <= 1'b0;
      m2WE_FS <= 1'b0;
      m2WE_Accum <= 1'b0;
      done_FI <= 1'b0;
      done_FS <= 1'b0;
      done_Accum <= 1'b0;   
  end else begin 
    if(start) begin
      //Fetch Initial Memory
      done_FI <= done_enable;
      m2WE_FI <= write_enable;
      readInitial_FI <= m1ReadBus_Reg;

      //Fetch Scratchpad Value
      done_FS <= done_FI;
      m2WE_FS <= m2WE_FI;
      readInitial_FS <= readInitial_FI;

      if(m2WE_Accum && (readInitial_FI == readInitial_Accum)) begin
        scratchVal_FS <= scratchVal_Accum;
      end else begin
        if(m2ReadBus_Reg[35:20] == 16'hAAAA) begin
          scratchVal_FS <= m2ReadBus_Reg;
        end else begin
          scratchVal_FS <= 36'hAAAA00000;
        end
      end

      //Accumulate Pixel Count
      done_Accum <= done_FS;
      m2WE_Accum <= m2WE_FS;
      readInitial_Accum <= readInitial_FS;
  
      if(m2WE_Accum && (readInitial_FS == readInitial_Accum)) begin
        scratchVal_Accum <= scratchVal_Accum + 1'b1;
      end else begin
        scratchVal_Accum <= scratchVal_FS + 1'b1;
      end
    end else begin
      readInitial_FI <= 0;
      readInitial_FS <= 0;
      readInitial_Accum <= 0;
      scratchVal_FS <= 36'hAAAA00000;
      scratchVal_Accum <= 36'hAAAA00000;
      m2WE_FI <= 1'b0;
      m2WE_FS <= 1'b0;
      m2WE_Accum <= 1'b0;
      done_FI <= 1'b0;
      done_FS <= 1'b0;
      done_Accum <= 1'b0;   
    end
  end
end

//======================Pipeline Controller/State Machine===================

always@(posedge clock or negedge rst_n) begin
  if(!rst_n) begin
    memoryCounter <= 0;
    pipelineCounter <= 0;
    write_enable <= 1'b0;
    done_enable <= 1'b0;
  end else begin
    if(start & (pipelineCounter != 127'd120)) begin
      memoryCounter <= memoryCounter;
      pipelineCounter <= pipelineCounter + 127'd8;
      write_enable <= 1'b1;
      done_enable <= 1'b0;
    end else begin
      if(start & (pipelineCounter == 127'd120)) begin
        if(memoryCounter[14:0] == ADDRESS_OF_LAST) begin
          memoryCounter <= memoryCounter;
          pipelineCounter <= pipelineCounter;
          write_enable <= 1'b0;
          done_enable <= 1'b1;
        end else begin
          memoryCounter <= memoryCounter + 1'b1;
          pipelineCounter <= 127'b0;
          write_enable <= 1'b1;
          done_enable <= 1'b0;
        end
      end else begin
        pipelineCounter <= 127'b0;
        memoryCounter <= 15'b0;
        write_enable <= 1'b1;
        done_enable <= 1'b0;
      end
    end
  end
end

endmodule
