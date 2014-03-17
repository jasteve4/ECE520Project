module output_pipeline_tb();

reg clock = 1;
reg reset_n = 1;
reg start = 0;
reg [19:0] cdf_min = 8'd1;
reg [19:0] divisor = 20'd63;

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

wire          m3_WriteEnable;
wire [15:0]   m3_WriteAddress;
wire [15:0]   m3_ReadAddress1;
wire [15:0]   m3_ReadAddress2;
wire [127:0]  m3_WriteBus;
wire [127:0]  m3_ReadBus1;
wire [127:0]  m3_ReadBus2;
wire done;


always #5 clock = ~clock;

initial begin
  $readmemh("cdr_input.txt",m2.Register);
  $readmemh("input_wiki.txt",m3.Register);
  #10 reset_n = 0;
  #10 reset_n = 1;
  #20 start = 1;
  #1000  
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

Output_top output_top (
  .clock(clock),
  .reset_n(reset_n),
  .start(start),
  .divisor(divisor),
  .CdfMin(cdf_min),
  .M2SP_ReadBus(m2_ReadBus2),
  .M2SP_ReadAddress(m2_ReadAddress2),
  .M3SP_ReadBus(m3_ReadBus2),
  .M3SP_ReadAddress(m3_ReadAddress2),
  .WriteEnable(m4_WriteEnable),
  .Output_MEMBus(m4_WriteBus),
  .Output_MEMAddress(m4_WriteAddress),
  .done(done)
  );

endmodule
