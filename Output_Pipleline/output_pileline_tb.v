module input_pipeline_tb();

reg clock = 1;
reg reset_n = 1;
reg start = 0;
reg m2_WriteEnable = 1;
wire m2_WriteAddress;
wire m2_ReadAddress1;
wire m2_ReadAddress2
wire m2_WriteBus;
wire m2_ReadBus1;
wire m2 ReadBus2;


wire m4_WriteEnable;
wire m4_WriteAddress;
wire m4_ReadAddress1;
wire m4_ReadAddress2
wire m4_WriteBus;
wire m4_ReadBus1;
wire m4 ReadBus2;



integer i;

always #5 clock = ~clock;

initial begin
  $readmemh("input_wiki_hex.txt",m2.Register);
  #500
  $finish;
end

sram_1R1W m2 (
  .clock(clock), 
  .WE(m2_WriteEnable), 
  .WriteAddress(m2_WriteAddress), 
  .ReadAddress1(m2_ReadAddress1), 
  .ReadAddress2(m2_ReadAddress2), 
  .WriteBus(m2_WriteBus), 
  .ReadBus1(m2_ReadBus1), 
  .ReadBus2(m2_ReadBus2)
  );


sram_1R1W m4 (
  .clock(clock), 
  .WE(m4_WriteEnable), 
  .WriteAddress(m4_WriteAddress), 
  .ReadAddress1(m4_ReadAddress1), 
  .ReadAddress2(m4_ReadAddress2), 
  .WriteBus(m4_WriteBus), 
  .ReadBus1(m4_ReadBus1), 
  .ReadBus2(m4_ReadBus2)
  );


module Output_top(
  .clock(clock),
  .reset_n(reset_n),
  .start(start),
  .SP_ReadBus1(m2_ReadBus1),
  .SP_ReadBus2(m2_ReadBus2),
  .SP_ReadAddress1(m2_ReadAddress1),
  .SP_ReadAddress2(m2_ReadAddress2),
  .WriteEnable(m4_WriteEnable),
  .Output_MEMBus(m4_WriteBus),
  .Output_MEMAddress(m4_WriteAddress)
  );

endmodule
