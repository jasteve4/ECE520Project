  // synopsys translate_off
`include "/afs/bp/dist/synopsys_syn/dw/sim_ver/DW01_add.v"
  // synopsys translate_on

module input_pipeline_tb();

reg clock, start, rst_n;
wire WE1, WE2, WE3, WE4;
wire [15:0] WriteAddress1, ReadAddress1, 
            WriteAddress2, ReadAddress2, 
            WriteAddress3, ReadAddress3,
            WriteAddress4, ReadAddress4;
wire [127:0] WriteBus1, WriteBus2,
            WriteBus3, WriteBus4;
wire [127:0] ReadBus1, ReadBus2, 
              ReadBus3, ReadBus4;
wire [19:0] cdf_min;
wire cdf_valid;
wire done;

reg inputBaseOffset;
reg [127:0] input_data [0:65535]; 
reg [127:0] memory [0:65535]; 
integer i;

always #2 clock = ~clock;

initial begin
  //$monitor("WriteBus: %h, ReadVal: %h, Done: %d", WriteBus2, WriteAddress2, done);
  clock = 0;
  rst_n = 1;
  start = 0;
  inputBaseOffset = 1;
  #10 rst_n = 0;
  //$readmemh("input_small_hex.txt",m1.Register);
  $readmemh("input_wiki.txt",m1.Register);
  //$readmemh("input_oneColor.txt",m1.Register);
  
  #30
  rst_n = 1;
  #10 start = 1;
  #3000
  //#2000000
  start = 0;
  #20
  $writememh("./output/outputM1.txt",m1.Register);
  $writememh("./output/outputM2.txt",m2.Register);
  $writememh("./output/outputM3.txt",m3.Register);
  $display("DONE: %d", done);
  $finish;
end

input_top top_dut(.start(start), .clock(clock), .rst_n(rst_n), .m1ReadBus(ReadBus1), .m2ReadBus(ReadBus2[35:0]),
        .inputBaseOffset(inputBaseOffset), .m1ReadAddr(ReadAddress1), .m2ReadAddr(ReadAddress2), 
        .m2WriteAddr(WriteAddress2), .m3WriteAddr(WriteAddress3), .m2WriteBus(WriteBus2), .m3WriteBus(WriteBus3),
        .m2WE(WE2), .m3WE(WE3), .done(done), .cdf_valid(cdf_valid), .cdf_min(cdf_min));

/*input_pipeline dut1 ( .start(start), .clock(clock), .rst_n(rst_n),
      .m1ReadBus(ReadBus1), .m2ReadBus(ReadBus2[35:0]), .inputBaseOffset(inputBaseOffset), .m1ReadAddr(ReadAddress1), 
      .m2ReadAddr(ReadAddress2), .m2WriteAddr(WriteAddress2), .m3WriteAddr(WriteAddress3), 
      .m2WriteBus(WriteBus2), .m3WriteBus(WriteBus3), .m2WE(WE2), .m3WE(WE3), 
      .done(done), .cdf_min(cdf_min), .cdf_valid(cdf_valid));
*/
sram_2R1W m1(.clock(clock), .WE(WE1), .WriteAddress(WriteAddress1), .ReadAddress1(ReadAddress1), 
        .ReadAddress2(), .WriteBus(WriteBus1), .ReadBus1(ReadBus1), .ReadBus2());

sram_2R1W m2(.clock(clock), .WE(WE2), .WriteAddress(WriteAddress2), .ReadAddress1(ReadAddress2), 
        .ReadAddress2(), .WriteBus(WriteBus2), .ReadBus1(ReadBus2), .ReadBus2());

sram_2R1W m3(.clock(clock), .WE(WE3), .WriteAddress(WriteAddress3), .ReadAddress1(ReadAddress3), 
        .ReadAddress2(), .WriteBus(WriteBus3), .ReadBus1(ReadBus3), .ReadBus2());

sram_2R1W m4(.clock(clock), .WE(WE4), .WriteAddress(WriteAddress4), .ReadAddress1(ReadAddress4), 
        .ReadAddress2(), .WriteBus(WriteBus4), .ReadBus1(ReadBus4), .ReadBus2());


endmodule
