module cdf_pipeline_tb();

reg clock = 1;
reg reset_n = 1;
reg start = 0;
reg input_base_offset = 0;
wire cdf_valid;
wire done;
wire [19:0] cdf_min;

reg           m2_WriteEnable = 1;
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




always #5 clock = ~clock;

initial begin
  $readmemh("input_output.txt",m2.Register);
  #10 reset_n = 0;
  #10 reset_n = 1;
  #20 start = 1;
  #2590
  start = 0;
  #20 input_base_offset = 1; 
  #10 start = 1; 
  #2590
  $writememh("./output/outputM2.txt",m2.Register);
  $writememh("./output/outputM4.txt",m4.Register);
  $finish;
end

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

Cdf_top output_top (
  .clock(clock),
  .reset_n(reset_n),
  .start(start),
  .SP_ReadBus(m2_ReadBus2),
  .SP_ReadAddress(m2_ReadAddress2),
  .WriteEnable(m4_WriteEnable),
  .Output_MEMBus(m4_WriteBus),
  .Output_MEMAddress(m4_WriteAddress),
  .Cdf_Min(cdf_min),
  .done(done),
  .input_base_offset(input_base_offset),
  .cdf_valid(cdf_valid)
  );

endmodule
