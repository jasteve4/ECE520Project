/*=======================================
Christopher Scott Johnson and Joshua Stevens
ECE 520 Histogram Equalizer

The below modules are responsible for building a Histogram Equalizer.
This is responsible for adjusting the contrast of individual video frames.
========================================*/

// synopsys translate_off
`include "/afs/bp/dist/synopsys_syn/dw/sim_ver/DW01_add.v"
// synopsys translate_on

/*=======================================
Joshua Stevens & Christopher Johnson
MODULE: Top

This module is the upper most module
========================================*/
module Top(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire [127:0] M1_ReadBus1,
  output wire [15:0] M1_ReadAddress1,
  input wire [35:0] M2_ReadBus1,
  input wire [19:0] M2_ReadBus2,
  output tri [15:0] M2_ReadAddress1,
  output wire [15:0] M2_ReadAddress2,
  output tri [127:0] M2_WriteBus,
  output tri [15:0] M2_WriteAddress,
  output tri M2_WriteEnable,
  input wire [127:0] M3_ReadBus1,
  output wire [15:0] M3_ReadAddress1,
  output wire [127:0] M3_WriteBus,
  output wire [15:0] M3_WriteAddress,
  output wire M3_WriteEnable,
  output wire [127:0] M4_WriteBus,
  output wire [15:0] M4_WriteAddress,
  output wire M4_WriteEnable
  );


  wire input_base_offset, output_base_offset;
  wire output_start, input_start;
  wire output_done,input_done;
  wire [19:0] cdf_min, cdf_min_out, divisor;
  wire cdf_valid;


  Output_top dut_output_top(
    .clock(clock),
    .reset_n(reset_n),
    .start(output_start),
    .CdfMin(cdf_min_out),
    .divisor(divisor),
    .M2SP_ReadBus(M2_ReadBus2[19:0]),
    .M2SP_ReadAddress(M2_ReadAddress2),
    .M3SP_ReadBus(M3_ReadBus1),
    .M3SP_ReadAddress(M3_ReadAddress1),
    .WriteEnable(M4_WriteEnable),
    .Output_MEMBus(M4_WriteBus),
    .Output_MEMAddress(M4_WriteAddress),
    .done(output_done),
    .output_base_offset(output_base_offset)
    );




  Controllor dut_Controller(
    .clock(clock),
    .reset_n(reset_n),
    .start(start),
    .output_start(output_start),
    .input_start(input_start),
    .input_done(input_done),
    .output_done(output_done),
    .Cdf_Min(cdf_min),
    .Cdf_Min_Out(cdf_min_out),
    .Divisor(divisor),
    .input_base_offset(input_base_offset),
    .output_base_offset(output_base_offset),
    .cdf_valid(cdf_valid)
    );

//The below module is the first module in the overall pipeline
//This counts how many times each pixel value occurs and calculates the CDF
input_top top_dut(.start(input_start), .clock(clock), .rst_n(reset_n), .m1ReadBus(M1_ReadBus1), .m2ReadBus(M2_ReadBus1[35:0]),
        .inputBaseOffset(input_base_offset), .m1ReadAddr(M1_ReadAddress1), .m2ReadAddr(M2_ReadAddress1), 
        .m2WriteAddr(M2_WriteAddress), .m3WriteAddr(M3_WriteAddress), .m2WriteBus(M2_WriteBus), .m3WriteBus(M3_WriteBus),
        .m2WE(M2_WriteEnable), .m3WE(M3_WriteEnable), .done(input_done), .cdf_valid(cdf_valid), .cdf_min(cdf_min));


endmodule
/*=======================================
Joshua Stevens
MODULE: Controller

This module is responsible for communication between the pipelines.
========================================*/
module Controllor(
  input wire clock,
  input wire reset_n,
  input wire start,
  output reg output_start,
  output reg input_start,
  input wire input_done,
  input wire output_done,
  input wire [19:0] Cdf_Min,
  output reg [19:0] Cdf_Min_Out,
  output reg [19:0] Divisor,
  output reg output_base_offset,
  output reg input_base_offset,
  input wire cdf_valid
  );

  parameter INITIAL         = 2'd0;
  parameter BEGIN           = 2'd1;
  parameter BEGIN_CDF       = 2'd2;
  parameter REPEAT          = 2'd3;
  parameter WAIT_FOR_INPUT = 1'd1;
  parameter REPEAT_START    = 1'd0;
  parameter DIVIDEND        = 20'd307200;

  reg [19:0] cdf_min1;
  reg [19:0] cdf_min0;
  reg [1:0] State;
  reg RepeatState;

  always@(*)
    begin
      if(output_base_offset)
        begin
          Cdf_Min_Out <= cdf_min1;
          Divisor <= DIVIDEND - cdf_min1;
        end
      else
        begin
          Cdf_Min_Out <= cdf_min0;
          Divisor <= DIVIDEND - cdf_min0;
        end
    end

  always@(posedge cdf_valid)
    begin
      if(input_base_offset)
        begin
          cdf_min1 <= Cdf_Min;
        end
      else
        begin
          cdf_min0 <= Cdf_Min;
        end
    end


  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          input_start <= 1'd0;
          output_start <= 1'd0;
          State <= INITIAL;
          input_base_offset <= 1'd0;
          output_base_offset <= 1'd0;
        end
      else
        begin
          case(State)
            INITIAL:
              begin
                if(start)
                  begin
                    input_start <= 1'd1;
                    output_start <= 1'd0;
                    State <= BEGIN;
                  end
                else
                  begin
                    input_start <= 1'd0;
                    output_start <= 1'd0;
                    State <= INITIAL; 
                  end
                  RepeatState <= REPEAT_START;
                  input_base_offset <= 1'd0;
                  output_base_offset <= 1'd0;
              end
            BEGIN:
              begin
                if(input_done)
                  begin
                    input_start <= 1'd0;
                    output_start <= 1'd0;
                    State <= REPEAT; 
                    input_base_offset <= 1'd1;
                    output_base_offset <= 1'd0;
                  end
                else
                  begin
                    input_start <= 1'd1;
                    output_start <= 1'd0;
                    State <= BEGIN; 
                    input_base_offset <= 1'd0;
                    output_base_offset <= 1'd0;
                  end
                  RepeatState <= REPEAT_START;
              end
            REPEAT:
              begin
                case(RepeatState)
                  REPEAT_START:
                    begin
                      if(output_done)
                        begin
                          input_start <= 1'd1; // change for all run 
                          output_start <= 1'd0;
                          RepeatState <= WAIT_FOR_INPUT;
                        end
                      else
                        begin
                          input_start <= 1'd1; 
                          output_start <= 1'd1;
                          RepeatState <= REPEAT_START;
                        end
                        input_base_offset <= input_base_offset;
                        output_base_offset <= output_base_offset;
                    end
                  WAIT_FOR_INPUT:
                    begin
                      if(input_done)
                        begin
                          input_start <= 1'd0; 
                          output_start <= 1'd0;
                          RepeatState <= REPEAT_START;
                          input_base_offset <= ~input_base_offset;
                          output_base_offset <= ~output_base_offset;
                        end
                      else
                        begin
                          input_start <= 1'd1; 
                          output_start <= 1'd0;
                          RepeatState <= WAIT_FOR_INPUT;
                          input_base_offset <= input_base_offset;
                          output_base_offset <= output_base_offset;
                        end
                    end
                endcase  
                State <= REPEAT;
              end
          endcase
        end
    end
endmodule

/*=======================================
Christopher Johnson
MODULE: input_top

This module combines the input pipeline and CDF pipeline.
========================================*/
module input_top(
  input wire start, 
  input wire clock, 
  input wire rst_n,
  input wire [127:0] m1ReadBus, 
  input wire [35:0]m2ReadBus,
  input wire inputBaseOffset,
  output wire [15:0] m1ReadAddr, 
  output wire [15:0] m2ReadAddr, 
  output wire [15:0] m2WriteAddr, m3WriteAddr, 
  output wire [127:0] m2WriteBus, m3WriteBus,
  output wire m2WE, m3WE,
  output wire done,
  output wire cdf_valid,
  output wire [19:0] cdf_min
);

wire input_done;
wire [15:0] CDF_m2ReadAddr, CDF_m2WriteAddr, input_m2WriteAddr, input_m2ReadAddr;
wire [127:0] CDF_m2WriteBus, input_m2WriteBus;
wire CDF_m2WE, input_m2WE;

assign m2WriteAddr = input_done ? CDF_m2WriteAddr : input_m2WriteAddr;
assign m2WriteBus = input_done ? CDF_m2WriteBus : input_m2WriteBus;
assign m2ReadAddr = input_done ? CDF_m2ReadAddr : input_m2ReadAddr;
assign m2WE = input_done ? CDF_m2WE : input_m2WE;

input_pipeline input_dut(
  .start(start), .clock(clock), .rst_n(rst_n),
  .m1ReadBus(m1ReadBus),
  .m2ReadBus(m2ReadBus),
  .inputBaseOffset(inputBaseOffset),
  .m1ReadAddr(m1ReadAddr), 
  .m2ReadAddr(input_m2ReadAddr), 
  .m2WriteAddr(input_m2WriteAddr), .m3WriteAddr(m3WriteAddr), 
  .m2WriteBus(input_m2WriteBus), .m3WriteBus(m3WriteBus),
  .m2WE(input_m2WE), .m3WE(m3WE),
  .input_done(input_done)
);



//========================Calculate the CDF================================
Cdf_top CDF_dut(
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
  );

endmodule

/*=======================================
Christopher Scott Johnson
MODULE: input_pipeline

This module is responsible for performing the first step of the Histogram equalizer.
It counts the number of times that each pixel value is seen. This is a pipelined module
with 2 feedback loops.
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

/*=======================================
Joshua Stevens
MODULE: Cdf_Top

This module integrates all below Cdf modules.
========================================*/
module Cdf_top(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [35:0]  SP_ReadBus,
  output wire [15:0]  SP_ReadAddress,
  output wire         WriteEnable,
  output wire [127:0] Output_MEMBus,
  output wire [15:0]  Output_MEMAddress,
  output wire [19:0] Cdf_Min,
  output wire done,
  input wire input_base_offset,
  output wire cdf_valid
  );

  wire [19:0]         Accumlate;
  wire [19:0]         AccumlateResult;
  wire [15:0]         store_address;
  wire [15:0]         store_address_to_store;
  wire                start_to_accumlate;
  wire                start_to_store;




  Cdf_Fetch stage1 (
    .clock(clock),
    .reset_n(reset_n),
    .start(start),
    .ReadBus(SP_ReadBus),
    .ReadAddr(SP_ReadAddress),
    .AccumlateOut(Accumlate),
    .StartOut(start_to_accumlate),
    .StoreAddress(store_address),
    .input_base_offset(input_base_offset),
    .done(done)
    );

  Cdf_Accumlate stage2(
    .clock(clock),
    .reset_n(reset_n),
    .AccumlateIn(Accumlate),
    .StartIn(start_to_accumlate),
    .StoreAddressIn(store_address),
    .AccumlateResult(AccumlateResult),
    .StoreAddressOut(store_address_to_store),
    .StartOut(start_to_store),
    .CdfMin(Cdf_Min),
    .CdfValid(cdf_valid)
    );

  Cdf_Store stage3(
    .clock(clock),
    .reset_n(reset_n),
    .StartIn(start_to_store),
    .ResultIn(AccumlateResult),
    .StoreAddressIn(store_address_to_store),
    .WriteBus(Output_MEMBus),
    .WriteAddress(Output_MEMAddress),
    .WriteEnable(WriteEnable)
  );

endmodule

/*=======================================
Joshua Stevens
MODULE: Cdf_Fetch

This module is responsible for fetching values for the CDF pipeline.
========================================*/
module Cdf_Fetch(
  input wire          clock,
  input wire          reset_n,
  input wire         start,
  input wire [35:0]  ReadBus,
  output wire [15:0]   ReadAddr,
  output reg [19:0]   AccumlateOut,
  output reg          StartOut,
  output reg [15:0]   StoreAddress,
  input wire input_base_offset,
  output reg done
  );

  reg [8:0]           count;
  reg [19:0]         DataIn;
  reg [15:0]          ReadAddress;
  reg done0, done1;

 // assign DataIn = (ReadBus[45:20] == 16'haaaa) ? ReadBus[19:0] : 20'b0;
  assign ReadAddr =  ReadAddress;

  always@(*)
    begin
      if(ReadBus[35:20] == 16'haaaa)
        DataIn <= ReadBus[19:0];
      else
        DataIn <= 20'd0;
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          StoreAddress <= 16'b0;
          done1 <= 1'd0;
          done <= 1'd0;
        end
      else if(start)
        begin
          StoreAddress <= ReadAddress;
          done1 <= done0;
          done <= done1;
        end
      else
        begin
          StoreAddress <= 16'b0;
          done1 <= 1'd0;
          done <= 1'd0;
        end
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          ReadAddress <= 16'b0;
          AccumlateOut <= 20'b0;
          StartOut <= 1'b0;
          count <= 0;
          done0 <= 1'd0;
        end
      else
        begin
          if(start & (count < 9'd256))
            begin
              ReadAddress <= ReadAddress + 1'b1;
              AccumlateOut <= DataIn;
              StartOut <= 1'b1;
              count <= count + 1'b1;
              done0 <= 1'd0;
            end
          else if(start & (count >9'd255))
            begin
              ReadAddress <= 16'd0;
              AccumlateOut <= DataIn;
              StartOut <= 1'b0;
              count <= count;
              done0 <= 1'd1;
            end
          else
            begin
              ReadAddress <= {input_base_offset,15'b0};
              AccumlateOut <= 20'b0;
              StartOut <= 1'b0;
              count <= 1'b0;
              done0 <= 1'd0;
            end
        end
    end

endmodule

/*=======================================
Joshua Stevens
MODULE: Cdf_Accumulate

This module is responsible for accumulating the CDF.
========================================*/
module Cdf_Accumlate(
  input wire clock,
  input wire reset_n,
  input wire [19:0] AccumlateIn,
  input wire StartIn,
  input wire [15:0] StoreAddressIn,
  output reg [19:0] AccumlateResult,
  output reg [15:0] StoreAddressOut,
  output reg StartOut,
  output reg [19:0] CdfMin,
  output reg CdfValid
  );

  wire [19:0] AccumlateOut;
  wire Cout;

  always@(posedge clock or negedge reset_n)
    if(!reset_n)
      begin
        StartOut <= 1'b0;
      end
    else
      begin
        if(StartIn)
          begin
            StartOut <= 1'b1;
          end
        else
          begin
            StartOut <= 1'b0;
          end
      end

  always@(posedge clock)
    begin
      StoreAddressOut <= StoreAddressIn;
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          AccumlateResult <= 1'b0;
          CdfMin <= 20'd0;
          CdfValid <= 1'd0;
        end
      else
        begin
          if(StartIn)
            begin
              AccumlateResult <= AccumlateOut;
              if(CdfMin == 20'd0)
                begin
                  if(AccumlateOut > 20'd0)
                    begin
                      CdfMin <= AccumlateOut;
                      CdfValid <= 1'd1;
                    end
                  else
                    begin
                      CdfMin <= CdfMin;
                      CdfValid <= 1'd0;
                    end
                end
              else
                begin
                  CdfMin <= CdfMin;
                  CdfValid <= 1'd0;
                end
            end
          else
            begin
              AccumlateResult <= 1'b0;
              CdfMin <= 20'd0;
              CdfValid <= 1'd0;
            end
        end
    end

  DW01_add #(20)
    add(.A(AccumlateResult), .B(AccumlateIn), .CI(1'd0), .SUM(AccumlateOut), .CO(Cout));

endmodule

/*=======================================
Joshua Stevens
MODULE: Cdf_Store

This module is responsible for storing the CDF values to memory.
========================================*/
module Cdf_Store(
  input wire clock,
  input wire reset_n,
  input wire StartIn,
  input wire [19:0] ResultIn,
  input wire [15:0] StoreAddressIn,
  output reg [127:0] WriteBus,
  output reg [15:0] WriteAddress,
  output reg WriteEnable
  );

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          WriteBus <= 16'b0;
          WriteAddress <= 16'b0;
          WriteEnable <= 1'b0;
        end
      else
        begin
          if(StartIn)
            begin    
              WriteBus <= ResultIn;
              WriteAddress <= StoreAddressIn;
              WriteEnable <= 1'b1;
            end
          else
            begin
              WriteBus <= 16'b0;
              WriteAddress <= 16'b0;
              WriteEnable <= 1'b0;
            end
        end
    end

  endmodule


/*=======================================
Joshua Stevens
MODULE: divider_pipe_stage

This module is a pipelined left shift restoring divider.
========================================*/
module pipeline_divider(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire [27:0] divided,
  input wire [19:0] divisor,
  output wire [7:0] q,
  output wire StartOut
  );


  wire start1, start2, start3, start4, start5, start6, start7;
  wire [19:0] divisor1, divisor2, divisor3, divisor4, divisor5, divisor6, divisor7, divisor_in;
  wire [27:0] result1, result2, result3, result4, result5, result6, result7;
  wire [7:0] q0, q1, q2, q3, q4, q5, q6;
  wire [9:0] input_init;
  assign divisor_in = ~divisor;

  divider_pipe_stage stage0(
  .clock(clock),
  .reset_n(reset_n),
  .start(start),
  .divided(divided),
  .divisor(divisor_in),
  .q_in(8'd0),
  .start_out(start1),
  .divisor_out(divisor1),
  .result(result1),
  .q_out(q0)
  );

  divider_pipe_stage stage1(
  .clock(clock),
  .reset_n(reset_n),
  .start(start1),
  .divided(result1),
  .divisor(divisor1),
  .q_in(q0),
  .start_out(start2),
  .divisor_out(divisor2),
  .result(result2),
  .q_out(q1)
  );

  divider_pipe_stage stage2(
  .clock(clock),
  .reset_n(reset_n),
  .start(start2),
  .divided(result2),
  .divisor(divisor2),
  .q_in(q1),
  .start_out(start3),
  .divisor_out(divisor3),
  .result(result3),
  .q_out(q2)
  );

  
  divider_pipe_stage stage3(
  .clock(clock),
  .reset_n(reset_n),
  .start(start3),
  .divided(result3),
  .divisor(divisor3),
  .q_in(q2),
  .start_out(start4),
  .divisor_out(divisor4),
  .result(result4),
  .q_out(q3)
  );

  divider_pipe_stage stage4(
  .clock(clock),
  .reset_n(reset_n),
  .start(start4),
  .divided(result4),
  .divisor(divisor4),
  .q_in(q3),
  .start_out(start5),
  .divisor_out(divisor5),
  .result(result5),
  .q_out(q4)
  );

  divider_pipe_stage stage5(
  .clock(clock),
  .reset_n(reset_n),
  .start(start5),
  .divided(result5),
  .divisor(divisor5),
  .q_in(q4),
  .start_out(start6),
  .divisor_out(divisor6),
  .result(result6),
  .q_out(q5)
  );

  divider_pipe_stage stage6(
  .clock(clock),
  .reset_n(reset_n),
  .start(start6),
  .divided(result6),
  .divisor(divisor6),
  .q_in(q5),
  .start_out(start7),
  .divisor_out(divisor7),
  .result(result7),
  .q_out(q6)
  );

  end_pipe_stage stage7(
  .clock(clock),
  .reset_n(reset_n),
  .start(start7),
  .divided(result7),
  .divisor(divisor7),
  .q_in(q6),
  .start_out(StartOut),
  .q_out(q)
  );


endmodule


/*=======================================
Joshua Stevens
MODULE: divider_pipe_stage

This module is the pipelined stage of the divider.
========================================*/
module divider_pipe_stage(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire [27:0] divided,
  input wire [19:0] divisor,
  input wire [7:0] q_in,
  output reg start_out,
  output reg [19:0] divisor_out,
  output reg [27:0] result,
  output reg [7:0] q_out
  );


  wire [20:0] stage_result;
  wire [27:0] stage_divided;
  wire q;
  wire [7:0] q_inner;

  assign stage_divided = {divided, 1'd0};
  
  DW01_add #(20)
    stage_add(.A(stage_divided[27:8]), .B(divisor), .CI(1'd1), .SUM(stage_result[19:0]), .CO(stage_result[20]));

  assign q = stage_result[20] ^ divided[27];
  assign q_inner = {q_in,q};

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          divisor_out <= 20'd0;
          result <= 28'd0;
          q_out <= 8'd0;
          start_out <= 1'd0;
        end
      else
        begin
          if(start)
            begin
              divisor_out <= divisor;
              result <= q ? {stage_result, stage_divided[7:0]} : stage_divided;
              q_out <= q_inner;
              start_out <= 1'd1;
            end
          else
            begin
              divisor_out <= 20'd0;
              result <= 28'd0;
              q_out <= 8'd0;
              start_out <= 1'd0;
            end
        end
    end
endmodule


/*=======================================
Joshua Stevens
MODULE: end_pipe_stage

This is the last stage of the pipelined divider.
========================================*/
module end_pipe_stage(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire [27:0] divided,
  input wire [19:0] divisor,
  input wire [7:0] q_in,
  output reg start_out,
  output reg [7:0] q_out
  );


  reg [27:0] result;
  wire [20:0] stage_result;
  wire [27:0] stage_divided;
  wire q;
  wire [7:0] q_inner;
  wire [19:0] divided_input;

  assign stage_divided = {divided, 1'd0};
  assign divided_input = stage_divided[27:8];

  DW01_add #(20)
    stage_add(.A(divided_input), .B(divisor), .CI(1'd1), .SUM(stage_result[19:0]), .CO(stage_result[20]));

  assign q = stage_result[20] ^ divided[27];
  assign q_inner = {q_in,q};

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          result <= 28'd0;
          q_out <= 8'd0;
          start_out <= 1'd0;
        end
      else
        begin
          if(start)
            begin
              result <= stage_result;
              q_out <= q_inner;
              start_out <= 1'd1;
            end
          else
            begin
              result <= 28'd0;
              q_out <= 8'd0;
              start_out <= 1'd0;
            end
        end
    end
endmodule


/*=======================================
Joshua Stevens
MODULE: Output_top

This module is the upper most module of the output pipeline
========================================*/
module Output_top(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [19:0]   CdfMin,
  input wire [19:0]   divisor,
  input wire [19:0]  M2SP_ReadBus,
  output wire [15:0]  M2SP_ReadAddress,
  input wire [127:0]  M3SP_ReadBus,
  output wire [15:0]  M3SP_ReadAddress,
  output wire         WriteEnable,
  output wire [127:0] Output_MEMBus,
  output wire [15:0]  Output_MEMAddress,
  output wire done,
  input wire output_base_offset
  );

  wire                start_to_stage_two;

  wire [19:0]         DataToStageThree;
  wire                start_to_stage_three;

  wire [27:0]         DataToStageFour;
  wire                start_to_stage_four;

  wire [7:0]          result;
  wire                start_to_stage_five;
  
  Output_Fetch_MEM stage1(
    .clock(clock),
    .reset_n(reset_n),
    .start(start),
    .ReadBus(M3SP_ReadBus),
    .ReadAddress(M3SP_ReadAddress),
    .DataOut(M2SP_ReadAddress),
    .StartOut(start_to_stage_two),
    .output_base_offset(output_base_offset),
    .done(done)
    );


  Output_Fetch_Cdf stage2(
    .clock(clock),
    .reset_n(reset_n),
    .ReadBus(M2SP_ReadBus),
    .DataOut(DataToStageThree),
    .StartIn(start_to_stage_two),
    .StartOut(start_to_stage_three)
    );
  
  Output_TopExpression stage3(
    .clock(clock),
    .reset_n(reset_n),
    .DataIn(DataToStageThree),
    .CdfMin(CdfMin),
    .StartIn(start_to_stage_three),
    .StartOut(start_to_stage_four),
    .DataOut(DataToStageFour)
  );

  Output_Result stage4(
    .clock(clock),
    .reset_n(reset_n),
    .DataIn(DataToStageFour),
    .StartIn(start_to_stage_four),
    .StartOut(start_to_stage_five),
    .Divisor(divisor),
    .DataOut(result)
  );

  Output_Store stage5(
    .clock(clock),
    .reset_n(reset_n),
    .StartIn(start_to_stage_five),
    .ResultIn(result),
    .WriteBus(Output_MEMBus),
    .WriteAddress(Output_MEMAddress),
    .WriteEnable(WriteEnable),
    .output_base_offset(output_base_offset)
  );
endmodule


/*=======================================
Joshua Stevens
MODULE: Output_Fetch_MEM

This module is fetches CDF values for corrosponding pixels.
========================================*/
module Output_Fetch_Cdf(
  input wire          clock,
  input wire          reset_n,
  input wire [19:0]  ReadBus,
  output reg [19:0]   DataOut,
  input wire          StartIn,
  output reg          StartOut
  );

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          StartOut <= 1'b0;
          DataOut <= 20'bx;
        end
      else
        begin
          if(StartIn)
            begin
              StartOut <= 1'b1;
              DataOut <= ReadBus[19:0];
            end
          else
            begin
              StartOut <= 1'b0;
              DataOut <= 20'bx;
            end
        end
    end
endmodule
/*=======================================
Joshua Stevens
MODULE: Output_Fetch_MEM

This module is fills the output pipeline.
========================================*/
module Output_Fetch_MEM(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [127:0]  ReadBus,
  output reg [15:0]   ReadAddress,
  output reg [15:0]   DataOut,
  output reg          StartOut,
  input wire output_base_offset,
  output reg done
  );

  reg [3:0]           short_count;
  reg [127:0]           data_in;
  reg done0, done1, done2, done3, done4, done5, done6, done7, done8, done9, done10, done11;
  reg base_offset;
  reg StartOut1,  StartOut0;

//  assign StartOut = StartOut1 | StartOut0;

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          done1 <= 1'd0;
          done2 <= 1'd0;
          done3 <= 1'd0;
          done4 <= 1'd0;
          done5 <= 1'd0;
          done6 <= 1'd0;
          done7 <= 1'd0;
          done8 <= 1'd0;
          done9 <= 1'd0;
          done10 <= 1'd0;
          done11 <= 1'd0;
          done <= 1'd0;
        end
      else if(start)
        begin
          done1 <= done0;
          done2 <= done1;
          done3 <= done2;
          done4 <= done3;
          done5 <= done4;
          done6 <= done5;
          done7 <= done6;
          done8 <= done7;
          done9 <= done8;
          done10 <= done9;
          done11 <= done10;
          done <= done11;
        end
      else
         begin
          done1 <= 1'd0;
          done2 <= 1'd0;
          done3 <= 1'd0;
          done4 <= 1'd0;
          done5 <= 1'd0;
          done6 <= 1'd0;
          done7 <= 1'd0;
          done8 <= 1'd0;
          done9 <= 1'd0;
          done10 <= 1'd0;
          done11 <= 1'd0;
          done <= 1'd0;
        end
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          ReadAddress <= 16'b0;
          StartOut <= 1'b0;
          data_in <= 8'd0;
          short_count <= 4'd0;
          done0 <= 1'b0;
        end
      else
        begin
          if(start & (ReadAddress[14:0]) == 15'd19200)
            begin
              StartOut <= 1'd0;
              ReadAddress <= ReadAddress;
              data_in <= 8'd0;
              short_count <= 4'd0;
              done0 <= 1'b1;
            end
          else if(start & (short_count != 4'hf))
            begin
              ReadAddress <= ReadAddress;
              StartOut <= 1'b1;
              data_in <= ReadBus;
              short_count <= short_count + 1'b1;
              done0 <= 1'b0;
            end
          else if(start & (short_count == 4'hf))
            begin
              StartOut <= 1'd1;
              ReadAddress <= ReadAddress + 1'd1;
              short_count <= 4'd0;
              done0 <= 1'b0;
              data_in <= ReadBus;
            end
          else
            begin
              ReadAddress <= {output_base_offset, 15'b0};
              StartOut <= 1'b0;
              data_in <= 8'd0;
              short_count <= 1'b0;
              done0 <= 1'd0;
            end
        end
    end

  always@(posedge clock)
    base_offset <= output_base_offset;

  always@(*)
    begin
      case(short_count)
        16'hf: DataOut <= {base_offset,7'd0, data_in[15:8]};
        16'he: DataOut <= {base_offset,7'd0, data_in[23:16]};
        16'hd: DataOut <= {base_offset,7'd0, data_in[31:24]};
        16'hc: DataOut <= {base_offset,7'd0, data_in[39:32]};
        16'hb: DataOut <= {base_offset,7'd0, data_in[47:40]};
        16'ha: DataOut <= {base_offset,7'd0, data_in[55:48]};
        16'h9: DataOut <= {base_offset,7'd0, data_in[63:56]};
        16'h8: DataOut <= {base_offset,7'd0, data_in[71:64]};
        16'h7: DataOut <= {base_offset,7'd0, data_in[79:72]};
        16'h6: DataOut <= {base_offset,7'd0, data_in[87:80]};
        16'h5: DataOut <= {base_offset,7'd0, data_in[95:88]};
        16'h4: DataOut <= {base_offset,7'd0, data_in[103:96]};
        16'h3: DataOut <= {base_offset,7'd0, data_in[111:104]};
        16'h2: DataOut <= {base_offset,7'd0, data_in[119:112]};
        16'h1: DataOut <= {base_offset,7'd0, data_in[127:120]};
        16'h0: DataOut <= {base_offset,7'd0, data_in[7:0]};
      endcase
    end


endmodule

/*=======================================
Joshua Stevens
MODULE: Output_TopExpression

This module is responsible for the multiplication and subtraction
in the histogram equalizer equation.
========================================*/
module Output_TopExpression(
  input wire clock,
  input wire reset_n,
  input wire [19:0] DataIn,
  input wire [19:0] CdfMin,
  input wire StartIn,
  output reg StartOut,
  output reg [27:0] DataOut
  );
  
  reg [19:0] Data;
  wire [19:0] dataResult;
  reg [19:0] dataTop;
  reg dataCout;
  wire [13:0] result, data_Result;
  reg [13:0] dataBottom;
  wire cout, bottom_cout, data_cout;
  reg  Start0, Start1;
  wire [27:0] B;

//  assign Data = DataIn - CdfMin;


  DW01_add #(20)
    first_add(.A(DataIn), .B(~CdfMin), .CI(1'd1), .SUM(dataResult), .CO(data_cout));

  always@(posedge clock or negedge reset_n)
    if(!reset_n)
      begin
        Data <= data_cout;
        Start0 <= 1'd0;
      end
    else
      begin
        if(StartIn)
          begin
            Data <= dataResult;
            Start0 <= 1'd1;
          end
        else
          begin
            Data <= 20'b0;
            Start0 <= 1'd0;
          end
      end

  DW01_add #(14)
    bottom_add(.A({Data[5:0],8'd0}), .B(~Data[13:0]), .CI(1'd1), .SUM(data_Result), .CO(bottom_cout));

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          dataTop <= 20'd0;
          dataBottom <= 14'd0;
          dataCout <= 1'd0;
          Start1 <= 1'd0;
        end
      else
        begin
          if(Start0)
            begin
              dataTop <= Data;
              dataBottom <= data_Result;
              dataCout <= bottom_cout;
              Start1 <= 1'd1;
            end
          else
            begin
              dataTop <= 20'd0;
              dataBottom <= 14'd0;
              dataCout <= 1'd0;
              Start1 <= 1'd0;
            end
        end
    end
  
  DW01_add #(14)
    top_add(.A(dataTop[19:6]), .B(~{8'd0,dataTop[19:14]}), .CI(dataCout), .SUM(result), .CO(cout));

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          DataOut <= 28'b0;
          StartOut <= 1'd0;
        end
      else
        begin
          if(Start1)
            begin
                DataOut <= {result, dataBottom};
                StartOut <= 1'd1;
            end
          else
            begin
              DataOut <= 28'b0;
              StartOut <= 1'd0;
            end
        end
    end
endmodule


/*=======================================
Joshua Stevens
MODULE: Output_Result

This module is responsible for dividing in the histogram calculation.
========================================*/
module Output_Result(
  input wire clock,
  input wire reset_n,
  input wire [27:0] DataIn,
  input wire StartIn,
  input wire [19:0] Divisor,
  output wire StartOut,
  output wire [7:0] DataOut
  );
  

  
  pipeline_divider divider(
    .clock(clock),
    .reset_n(reset_n),
    .start(StartIn),
    .divided(DataIn),
    .divisor(Divisor),
    .q(DataOut),
    .StartOut(StartOut)
  );


endmodule

/*=======================================
joshua stevens
module: output_store

this module is responsible for storing the new pixel value.
========================================*/
module Output_Store(
  input wire clock,
  input wire reset_n,
  input wire StartIn,
  input wire [7:0] ResultIn,
  output reg [127:0] WriteBus,
  output reg [15:0] WriteAddress,
  output reg WriteEnable,
  input wire output_base_offset
  );
  
  reg [4:0] short_count;
  reg [15:0] next_WriteAddress;
  reg [127:0] data;
  reg [127:0] offset;

  always@(posedge clock)
    begin
      WriteAddress <= next_WriteAddress;
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          WriteBus <= 127'b0;
          next_WriteAddress <= 16'b0;
          WriteEnable <= 1'b0;
          short_count <= 4'd15;
        end
      else
        begin
          if(StartIn)
            begin
              case(short_count)
                4'h0: WriteBus <= {WriteBus[127:8], ResultIn};
                4'h1: WriteBus <= {WriteBus[127:16], ResultIn, WriteBus[7:0]};
                4'h2: WriteBus <= {WriteBus[127:24], ResultIn, WriteBus[15:0]};
                4'h3: WriteBus <= {WriteBus[127:32], ResultIn, WriteBus[23:0]};
                4'h4: WriteBus <= {WriteBus[127:40], ResultIn, WriteBus[31:0]};
                4'h5: WriteBus <= {WriteBus[127:48], ResultIn, WriteBus[39:0]};
                4'h6: WriteBus <= {WriteBus[127:56], ResultIn, WriteBus[47:0]};
                4'h7: WriteBus <= {WriteBus[127:64], ResultIn, WriteBus[55:0]};
                4'h8: WriteBus <= {WriteBus[127:72], ResultIn, WriteBus[63:0]};
                4'h9: WriteBus <= {WriteBus[127:80], ResultIn, WriteBus[71:0]};
                4'ha: WriteBus <= {WriteBus[127:88], ResultIn, WriteBus[79:0]};
                4'hb: WriteBus <= {WriteBus[127:96], ResultIn, WriteBus[87:0]};
                4'hc: WriteBus <= {WriteBus[127:104], ResultIn, WriteBus[95:0]};
                4'hd: WriteBus <= {WriteBus[127:112], ResultIn, WriteBus[103:0]};
                4'he: WriteBus <= {WriteBus[127:120], ResultIn, WriteBus[111:0]};
                4'hf: WriteBus <= {ResultIn, WriteBus[119:0]};
              endcase
              if(short_count == 4'h0)
                begin
                  next_WriteAddress <= next_WriteAddress + 1'd1;
                  WriteEnable <= 1'b1;
                  short_count <= 4'd15;
                end
              else
                begin
                  next_WriteAddress <= next_WriteAddress;
                  WriteEnable <= 1'b0;
                  short_count <= short_count - 1'b1;
                end
            end
          else
            begin
              WriteBus <= 127'b0;
              next_WriteAddress <= 16'b0;
              WriteEnable <= 1'b0;
              short_count <= 4'd15;
            end
        end
    end

  endmodule

/*=======================================
Joshua Stevens & Christopher Johnson
MODULE: Top_Testbench

This module is the testbench for our design.
========================================*/
//synopsys off
module Top_Testbench();


  reg clock = 1;
  reg reset_n = 1;
  reg start = 0;

  wire          m1_WriteEnable;
  wire [15:0]   m1_WriteAddress;
  wire [15:0]   m1_ReadAddress1;
  wire [15:0]   m1_ReadAddress2;
  wire [127:0]  m1_WriteBus;
  wire [127:0]  m1_ReadBus1;
  wire [127:0]  m1_ReadBus2;

  wire          m2_WriteEnable;
  wire [15:0]   m2_WriteAddress;
  wire [15:0]   m2_ReadAddress1;
  wire [15:0]   m2_ReadAddress2;
  wire [127:0]  m2_WriteBus;
  wire [127:0]  m2_ReadBus1;
  wire [127:0]  m2_ReadBus2;

  wire          m4_WriteEnable;
  wire [15:0]   m4_WriteAddress;
  wire [15:0]   m4_ReadAddress1;
  wire [15:0]   m4_ReadAddress2;
  wire [127:0]  m4_WriteBus;
  wire [127:0]  m4_ReadBus1;
  wire [127:0]  m4_ReadBus2;

  wire          m3_WriteEnable;
  wire [15:0]   m3_WriteAddress;
  wire [15:0]   m3_ReadAddress1;
  wire [15:0]   m3_ReadAddress2;
  wire [127:0]  m3_WriteBus;
  wire [127:0]  m3_ReadBus1;
  wire [127:0]  m3_ReadBus2;
  wire done;


  always #2 clock = ~clock;

  initial begin
    $readmemh("input_small_hex.txt",m1.Register);
    #10 reset_n = 0;
    #10 reset_n = 1;
    #20 start = 1;
    #1230000
    $writememh("./output/output0M1.txt",m1.Register);
    $writememh("./output/output0M2.txt",m2.Register);
    $writememh("./output/output0M3.txt",m3.Register);
    $writememh("./output/output0M4.txt",m4.Register);
    #1230000
    $writememh("./output/output1M1.txt",m1.Register);
    $writememh("./output/output1M2.txt",m2.Register);
    $writememh("./output/output1M3.txt",m3.Register);
    $writememh("./output/output1M4.txt",m4.Register);
    #1230000
    $writememh("./output/output2M1.txt",m1.Register);
    $writememh("./output/output2M2.txt",m2.Register);
    $writememh("./output/output2M3.txt",m3.Register);
    $writememh("./output/output2M4.txt",m4.Register);
    $finish;
  end

  sram_2R1W m1 (
    .clock(clock), 
    .WE(m1_WriteEnable), 
    .WriteAddress(m1_WriteAddress), 
    .ReadAddress1(m1_ReadAddress1), 
    .ReadAddress2(m1_ReadAddress2), 
    .WriteBus(m1_WriteBus), 
    .ReadBus1(m1_ReadBus1), 
    .ReadBus2(m1_ReadBus2)
    );

  sram_2R1W m2 (
    .clock(clock), 
    .WE(m2_WriteEnable), 
    .WriteAddress(m2_WriteAddress), 
    .ReadAddress1(m2_ReadAddress1), 
    .ReadAddress2(m2_ReadAddress2), 
    .WriteBus(m2_WriteBus), 
    .ReadBus1(m2_ReadBus1), 
    .ReadBus2(m2_ReadBus2)
    );

  sram_2R1W m3 (
    .clock(clock), 
    .WE(m3_WriteEnable), 
    .WriteAddress(m3_WriteAddress), 
    .ReadAddress1(m3_ReadAddress1), 
    .ReadAddress2(m3_ReadAddress2), 
    .WriteBus(m3_WriteBus), 
    .ReadBus1(m3_ReadBus1), 
    .ReadBus2(m3_ReadBus2)
    );

  sram_2R1W m4 (
    .clock(clock), 
    .WE(m4_WriteEnable), 
    .WriteAddress(m4_WriteAddress), 
    .ReadAddress1(m4_ReadAddress1), 
    .ReadAddress2(m4_ReadAddress2), 
    .WriteBus(m4_WriteBus), 
    .ReadBus1(m4_ReadBus1), 
    .ReadBus2(m4_ReadBus2)
    );


  Top dut_Top(
    .clock(clock),
    .reset_n(reset_n),
    .start(start),
    .M1_ReadBus1(m1_ReadBus1),
    .M1_ReadAddress1(m1_ReadAddress1),
    .M2_ReadBus1(m2_ReadBus1[35:0]),
    .M2_ReadBus2(m2_ReadBus2[19:0]),
    .M2_ReadAddress1(m2_ReadAddress1),
    .M2_ReadAddress2(m2_ReadAddress2),
    .M2_WriteBus(m2_WriteBus),
    .M2_WriteAddress(m2_WriteAddress),
    .M2_WriteEnable(m2_WriteEnable),
    .M3_ReadBus1(m3_ReadBus1),
    .M3_ReadAddress1(m3_ReadAddress1),
    .M3_WriteBus(m3_WriteBus),
    .M3_WriteAddress(m3_WriteAddress),
    .M3_WriteEnable(m3_WriteEnable),
    .M4_WriteBus(m4_WriteBus),
    .M4_WriteAddress(m4_WriteAddress),
    .M4_WriteEnable(m4_WriteEnable)
    );
endmodule

/*module************************************
*
* NAME:  sram_1R1W
*
* DESCRIPTION:   
*	Output Buffer: 64K*128bits, 2 Ports: 1R+1W
*  
* REVISION HISTORY
*   Date     Programmer    Description
*   2/4/13   Wenxu Zhao    Version 1.0
*   9/1/14   Sumon Dey	   Version 1.0
*   3/3/15   Sumon Dey     Version 1.1
*/
module sram_2R1W (clock, WE, WriteAddress, ReadAddress1, ReadAddress2, WriteBus, ReadBus1, ReadBus2);
input  clock, WE; 
input  [15:0] WriteAddress, ReadAddress1,ReadAddress2; 
input  [127:0] WriteBus;
output [127:0] ReadBus1, ReadBus2;

reg [127:0] Register [0:65535];   // 65536 words, with each 128 bits wide
reg [127:0] ReadBus1,ReadBus2;
// provide one write enable line per register
reg [65535:0] WElines;
integer i;

// Write '1' into write enable line for selected register
// Note the 2 ns delay - THIS IS THE INPUT DELAY FOR THE MEMORY FOR SYNTHESIS

always@(*)
#2 WElines = (WE << WriteAddress);
always@(posedge clock)
    for (i=0; i<=65535; i=i+1)
      if (WElines[i]) Register[i] <= WriteBus;
// Note the 2 ns delay - this is the OUTPUT DELAY FOR THE MEMORY FOR SYNTHESIS

always@(*) 
  begin 
    #2 ReadBus1  =  Register[ReadAddress1];
    ReadBus2  =  Register[ReadAddress2]; 
  end
endmodule
//synopsys on
