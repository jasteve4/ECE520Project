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
