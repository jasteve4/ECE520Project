module Output_top(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [19:0]   CdfMin,
  input wire [19:0]   divisor,
  input wire [127:0]  M2SP_ReadBus,
  output wire [15:0]  M2SP_ReadAddress,
  input wire [127:0]  M3SP_ReadBus,
  output wire [15:0]  M3SP_ReadAddress,
  output wire         WriteEnable,
  output wire [127:0] Output_MEMBus,
  output wire [15:0]  Output_MEMAddress,
  output wire done,
  input wire output_base_offset
  );

  wire [7:0]          DataToStageTwo;
  wire                start_to_stage_two;
  wire [15:0]         store_address;

  wire [19:0]         DataToStageThree;
  wire                start_to_stage_three;

  wire [27:0]         DataToStageFour;
  wire                start_to_stage_Four;

  wire [7:0]          result;
  wire                start_to_stage_Five;

  Output_Fetch_MEM stage1(
    .clock(clock),
    .reset_n(reset_n),
    .start(start),
    .ReadBus(M3SP_ReadBus),
    .ReadAddress(M3SP_ReadAddress),
    .DataOut(DataToStageTwo),
    .StartOut(start_to_stage_two),
    .StoreAddress(store_address),
    .output_base_offset(output_base_offset)
    );


  Output_Fetch_Cdf stage2(
    .clock(clock),
    .reset_n(reset_n),
    .ReadBus(M2SP_ReadBus),
    .ReadAddress(M2SP_ReadAddress),
    .DataIn(DataToStageTwo),
    .DataOut(DataToStageThree),
    .StartIn(start_to_stage_two),
    .StartOut(start_to_stage_three)
    .output_base_offset(output_base_offset)
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
    .done(done)
  );
endmodule
