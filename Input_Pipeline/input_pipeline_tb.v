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
wire done;

reg [127:0] input_data [0:65535]; 
reg [127:0] memory [0:65535]; 
integer i;

always #5 clock = ~clock;

initial begin
  //$monitor("WriteBus: %h, ReadVal: %h, Done: %d", WriteBus2, WriteAddress2, done);
  $monitor("Write Counter: %d", dut1.write_cnt);

  clock = 0;
  rst_n = 0;
  start = 0;
  $readmemh("input_wiki.txt",m1.Register);
  
  #30
  rst_n = 1;
  #10 start = 1;
  #1000
  $writememh("./output/outputM1.txt",m1.Register);
  $writememh("./output/outputM2.txt",m2.Register);
  $display("DONE: %d", done);
  $display("number of writes: %d", dut1.write_cnt);
  $finish;
end

input_pipeline dut1 ( .start(start), .clock(clock), .rst_n(rst_n),
      .m1ReadVal(ReadBus1), .m2ReadVal(ReadBus2), .m1ReadAddr(ReadAddress1), 
      .m2ReadAddr(ReadAddress2), .m2WriteAddr(WriteAddress2), 
      .m2WriteVal(WriteBus2), .m2WE(WE2), .done(done));

sram_1R1W m1(.clock(clock), .WE(WE1), .WriteAddress(WriteAddress1), .ReadAddress(ReadAddress1), 
        .WriteBus(WriteBus1), .ReadBus(ReadBus1));

sram_1R1W m2(.clock(clock), .WE(WE2), .WriteAddress(WriteAddress2), .ReadAddress(ReadAddress2), 
        .WriteBus(WriteBus2), .ReadBus(ReadBus2));

sram_1R1W m3(.clock(clock), .WE(WE3), .WriteAddress(WriteAddress3), .ReadAddress(ReadAddress3), 
        .WriteBus(WriteBus3), .ReadBus(ReadBus3));

sram_1R1W m4(.clock(clock), .WE(WE4), .WriteAddress(WriteAddress4), .ReadAddress(ReadAddress4), 
        .WriteBus(WriteBus4), .ReadBus(ReadBus4));


endmodule
