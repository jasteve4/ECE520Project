module Top(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire [127:0] M1_ReadBus1,
  output wire [15:0] M1_ReadAddress1,
  input wire [127:0] M2_ReadBus1,
  input wire [127:0] M2_ReadBus2,
  output tri [15:0] M2_ReadAddress1,
  output wire [15:0] M2_ReadAddress2,
  output tri [127:0] M2_WriteBus,
  output tri [15:0] M2_WriteAddress,
  output tri M2_WriteEnable,
  input wire [127:0] M3_ReadBus1,
  input wire [127:0] M3_ReadBus2,
  output wire [15:0] M3_ReadAddress1,
  output wire [15:0] M3_ReadAddress2,
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
    .M2SP_ReadBus(M2_ReadBus2),
    .M2SP_ReadAddress(M2_ReadAddress2),
    .M3SP_ReadBus(M3_ReadBus2),
    .M3SP_ReadAddress(M3_ReadAddress2),
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

  input_pipeline dut_Input_Pipeline(
    .start(input_start), 
    .clock(clock), 
    .rst_n(reset_n),
    .m1ReadBus(M1_ReadBus1), 
    .m2ReadBus(M2_ReadBus1),
    .inputBaseOffset(input_base_offset),
    .m1ReadAddr(M1_ReadAddress1), 
    .m2ReadAddr(M2_ReadAddress1), 
    .m2WriteAddr(M2_WriteAddress), 
    .m2WriteBus(M2_WriteBus),
    .m2WE(M2_WriteEnable),
    .done(input_done),
    .cdf_valid(cdf_valid),
    .cdf_min(cdf_min)
  );

endmodule
