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
  input wire [127:0] m1ReadBus, m2ReadBus,
  input wire inputBaseOffset,
  output reg [15:0] m1ReadAddr, 
  output reg [15:0] m2ReadAddr, 
  output reg [15:0] m2WriteAddr, m3WriteAddr, 
  output reg [127:0] m2WriteBus, m3WriteBus,
  output reg m2WE, m3WE,
  output wire done,
  output wire [19:0] cdf_min,
  output wire cdf_valid
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
reg [15:0] readInitial_FI, readInitial_FS, readInitial_Accum;
reg [35:0] scratchVal_FS, scratchVal_Accum;
reg done_FI, done_FS, done_Accum, done_enable;
reg [6:0] pipelineCounter;
reg [14:0] memoryCounter;

//===================MISC Wires and Regs===================
reg [15:0] m1ReadBus_Reg;
reg [35:0] m2ReadBus_Reg;
wire [15:0] CDF_m2ReadAddr, CDF_m2WriteAddr;
wire [127:0] CDF_m2WriteBus;
wire CDF_m2WE;
reg input_done;

//===================Write To Memory=======================
always@(*) begin
  m1ReadBus_Reg <= m1ReadBus[pipelineCounter+:8'd8];
  m1ReadAddr <= {inputBaseOffset,memoryCounter};
  m2ReadBus_Reg <= m2ReadBus[35:0];
  m2ReadAddr <= input_done ? CDF_m2ReadAddr : readInitial_FI;
end

always@(posedge clock) begin


  m2WE <= input_done ? CDF_m2WE : m2WE_Accum;
  m2WriteAddr <= input_done ? CDF_m2WriteAddr : readInitial_Accum;
  m2WriteBus <= input_done ? CDF_m2WriteBus : scratchVal_Accum;

  m3WE <= m2WE_FI;
  m3WriteAddr <= m1ReadAddr;
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

//========================Calculate the CDF================================
 /* Cdf_top dut_CDF_top(
    .clock(clock),
    .reset_n(rst_n),
    .start(input_done),
    .SP_ReadBus(m2ReadBus),
    .SP_ReadAddress(CDF_m2ReadAddr),
    .WriteEnable(CDF_m2WE),
    .Output_MEMBus(CDF_m2WriteBus),
    .Output_MEMAddress(CDF_m2WriteAddr),
    .Cdf_Min(cdf_min),
    .done(done),
    .input_base_offset(inputBaseOffset),
    .cdf_valid(cdf_valid)
  );*/


endmodule
