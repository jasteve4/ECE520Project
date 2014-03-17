
module Top(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire M1_ReadBus1,
  output wire M1_ReadAddress1,
  input wire M2_ReadBus1,
  input wire M2_ReadBus2,
  output wire M2_ReadAddress1,
  output wire M2_ReadAddress2,
  output wire M2_WriteBus,
  output wire M2_WriteAddress,
  output wire M2_WriteEnable,
  input wire M3_ReadBus1,
  output wire M3_ReadAddress1,
  output wire M3_WriteBus,
  output wire M3_WriteAddress,
  output wire M3_WriteEnable,
  output wire M4_WriteBus,
  output wire M4_WriteAddress,
  output wire M4_WriteEnable,
  );






  Output_top(
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
    .done(output_done)
    );



  Cdf_top(
    .clock(clock),
    .reset_n(reset_n),
    .start(cdf_start),
    .SP_ReadBus(M2_ReadBus1),
    .SP_ReadAddress(M2_ReadAddress1),
    .WriteEnable(M2_WriteEnable),
    .Output_MEMBus(M2_WriteBus),
    .Output_MEMAddress(M2_WriteAddress),
    .Cdf_Min(cdf_min),
    .done(cdf_done)
    );



  Controllor(
    .clock(clock),
    .reset_n(reset_n),
    .start(start),
    .output_start(output_start),
    .cdf_start(cdf_start),
    .input_start(input_start),
    .input_done(input_done),
    .output_done(output_done),
    .cdf_done(cdf_done),
    .Cdf_Min(cdf_min),
    .Cdf_Min_Out(cdf_min_out)
    .Divisor(divisor)
    );


endmodule
