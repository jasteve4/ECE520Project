module Cdf_top(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [127:0]  SP_ReadBus,
  output wire [15:0]  SP_ReadAddress,
  output wire         WriteEnable,
  output wire [127:0] Output_MEMBus,
  output wire [15:0]  Output_MEMAddress
  );

  wire [15:0]         Accumlate;
  wire [15:0]         AccumlateResult;
  wire [15:0]         store_address;
  wire [15:0]         store_address_to_store;
  wire                start_to_accumlate;
  wire                start_to_store;
  wire                done;





  Fetch stage1 (
    .clock(clock),
    .reset_n(reset_n),
    .start(start),
    .ReadBus(SP_ReadBus),
    .ReadAddress(SP_ReadAddress),
    .AccumlateOut(Accumlate),
    .StartOut(start_to_accumlate),
    .StoreAddress(store_address)
    );

  Accumlate stage2(
    .clock(clock),
    .reset_n(reset_n),
    .AccumlateIn(Accumlate),
    .StartIn(start_to_accumlate),
    .StoreAddressIn(store_address),
    .AccumlateResult(AccumlateResult),
    .StoreAddressOut(store_address_to_store),
    .StartOut(start_to_store)
    );

  Store stage3(
    .clock(clock),
    .reset_n(reset_n),
    .StartIn(start_to_store),
    .ResultIn(AccumlateResult),
    .StoreAddressIn(store_address_to_store),
    .WriteBus(Output_MEMBus),
    .WriteAddress(Output_MEMAddress),
    .WriteEnable(WriteEnable),
    .done(done)
  );

endmodule
