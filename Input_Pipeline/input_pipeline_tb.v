module input_pipeline_tb();

reg clock, WE;
reg [15:0] WriteAddress, ReadAddress;
reg [127:0] WriteBus;
wire [127:0] ReadBus;

reg [127:0] input_data [0:65535]; 
reg [127:0] memory [0:65535]; 
integer i;

always #5 clock = ~clock;

initial begin
  clock = 0;
  WE = 1;
  $readmemh("input_small_hex.txt",m1.Register);
  #500
  $writememh("output.txt",m1.Register);
  $finish;
end

sram_1R1W m1(.clock(clock), .WE(WE), .WriteAddress(WriteAddress), .ReadAddress(ReadAddress), 
        .WriteBus(WriteBus), .ReadBus(ReadBus));

endmodule
