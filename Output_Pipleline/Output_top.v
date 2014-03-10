module Output_top(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [127:0]  SP_ReadBus1,
  input wire [127:0]  SP_ReadBus2,
  output wire [15:0]  SP_ReadAddress1,
  output wire [15:0]  SP_ReadAddress2,
  output wire         WriteEnable,
  output wire [127:0] Output_MEMBus,
  output wire [15:0]  Output_MEMAddress
  );

  wire [15:0]         Accumlate1;
  wire [15:0]         Accumlate2;
  wire [2:0]          RuningCount;
  

  Fetch stage1 (
  .clock(clock),
  .reset_n(reset_n),
  .start(start),
  .ReadBus1(SP_ReadBus1),
  .ReadBus2(SP_ReadBus2),
  .ReadAddress1(SP_ReadAddress1),
  .ReadAddress2(SP_ReadAddress2),
  .AccumlateOut1(Accumlate1),
  .AccumlateOut2(Accumlate2),
  .store_count(RunningCount)
  );

