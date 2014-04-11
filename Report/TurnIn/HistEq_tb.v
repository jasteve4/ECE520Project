/*=======================================
Joshua Stevens & Christopher Johnson
MODULE: Top_Testbench

This module is the testbench for our design.
========================================*/
module Top_Testbench();
  reg clock = 1;
  reg reset_n = 1;
  reg start = 0;

  wire          m1_WriteEnable;
  wire [15:0]   m1_WriteAddress;
  wire [15:0]   m1_ReadAddress1;
  wire [15:0]   m1_ReadAddress2;
  wire [127:0]  m1_WriteBus;
  wire [127:0]  m1_ReadBus1;
  wire [127:0]  m1_ReadBus2;

  wire          m2_WriteEnable;
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


  always #2 clock = ~clock;

  initial begin
    $display("readingin picture 1");
    $readmemh("./input/input_small_hex.txt",m1.Register);
    #10 reset_n = 0;
    #10 reset_n = 1;
    #20 start = 1;
    
    wait(dut_Top.input_done) begin
      $display("readingin picture 2");
      $readmemh("./input/input_small_hex_2.txt",m1.Register);
    end
    wait(!dut_Top.input_done) begin
      $display("picture 1 done");
    end

    wait(dut_Top.input_done) begin
      $display("readingin picture 3");
      $readmemh("./input/input_small_hex.txt",m1.Register);
      $display("writing picture1");
      $writememh("./output/picture1/outputM1.txt",m1.Register);
      $writememh("./output/picture1/outputM2.txt",m2.Register);
      $writememh("./output/picture1/outputM3.txt",m3.Register);
      $writememh("./output/picture1/outputM4.txt",m4.Register);
    end
    wait(!dut_Top.input_done) begin
      $display("picture 2 done");
    end
    
    wait(dut_Top.input_done) begin
      $display("readingin picture 4");
      $readmemh("./input/input_small_hex_2.txt",m1.Register);
      $display("writing picture 2");
      $writememh("./output/picture2/outputM1.txt",m1.Register);
      $writememh("./output/picture2/outputM2.txt",m2.Register);
      $writememh("./output/picture2/outputM3.txt",m3.Register);
      $writememh("./output/picture2/outputM4.txt",m4.Register);
    end
    wait(!dut_Top.input_done) begin 
      $display("picture 3 done");
    end
    
    wait(dut_Top.input_done) begin
      $display("readingin picture 5");
      $readmemh("./input/input_small_hex.txt",m1.Register);
      $display("writing picture 3");
      $writememh("./output/picture3/outputM1.txt",m1.Register);
      $writememh("./output/picture3/outputM2.txt",m2.Register);
      $writememh("./output/picture3/outputM3.txt",m3.Register);
      $writememh("./output/picture3/outputM4.txt",m4.Register);
    end
    wait(dut_Top.output_done) begin
      $display("picture 4 done");
      $readmemh("./input/input_small_hex.txt",m1.Register);
      $display("writing picture 4");
      $writememh("./output/picture4/outputM1.txt",m1.Register);
      $writememh("./output/picture4/outputM2.txt",m2.Register);
      $writememh("./output/picture4/outputM3.txt",m3.Register);
      $writememh("./output/picture4/outputM4.txt",m4.Register);
    end
    $finish;
  end
  
  sram_2R1W m1 (
    .clock(clock), 
    .WE(m1_WriteEnable), 
    .WriteAddress(m1_WriteAddress), 
    .ReadAddress1(m1_ReadAddress1), 
    .ReadAddress2(m1_ReadAddress2), 
    .WriteBus(m1_WriteBus), 
    .ReadBus1(m1_ReadBus1), 
    .ReadBus2(m1_ReadBus2)
    );

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


  Top dut_Top(
    .clock(clock),
    .reset_n(reset_n),
    .start(start),
    .M1_ReadBus1(m1_ReadBus1),
    .M1_ReadAddress1(m1_ReadAddress1),
    .M2_ReadBus1(m2_ReadBus1[35:0]),
    .M2_ReadBus2(m2_ReadBus2[19:0]),
    .M2_ReadAddress1(m2_ReadAddress1),
    .M2_ReadAddress2(m2_ReadAddress2),
    .M2_WriteBus(m2_WriteBus),
    .M2_WriteAddress(m2_WriteAddress),
    .M2_WriteEnable(m2_WriteEnable),
    .M3_ReadBus1(m3_ReadBus1),
    .M3_ReadAddress1(m3_ReadAddress1),
    .M3_WriteBus(m3_WriteBus),
    .M3_WriteAddress(m3_WriteAddress),
    .M3_WriteEnable(m3_WriteEnable),
    .M4_WriteBus(m4_WriteBus),
    .M4_WriteAddress(m4_WriteAddress),
    .M4_WriteEnable(m4_WriteEnable)
    );
endmodule

/*module************************************
*
* NAME:  sram_1R1W
*
* DESCRIPTION:   
*	Output Buffer: 64K*128bits, 2 Ports: 1R+1W
*  
* REVISION HISTORY
*   Date     Programmer    Description
*   2/4/13   Wenxu Zhao    Version 1.0
*   9/1/14   Sumon Dey	   Version 1.0
*   3/3/15   Sumon Dey     Version 1.1
*/
module sram_2R1W (clock, WE, WriteAddress, ReadAddress1, ReadAddress2, WriteBus, ReadBus1, ReadBus2);
input  clock, WE; 
input  [15:0] WriteAddress, ReadAddress1,ReadAddress2; 
input  [127:0] WriteBus;
output [127:0] ReadBus1, ReadBus2;

reg [127:0] Register [0:65535];   // 65536 words, with each 128 bits wide
reg [127:0] ReadBus1,ReadBus2;
// provide one write enable line per register
reg [65535:0] WElines;
integer i;

// Write '1' into write enable line for selected register
// Note the 2 ns delay - THIS IS THE INPUT DELAY FOR THE MEMORY FOR SYNTHESIS

always@(*)
#2 WElines = (WE << WriteAddress);
always@(posedge clock)
    for (i=0; i<=65535; i=i+1)
      if (WElines[i]) Register[i] <= WriteBus;
// Note the 2 ns delay - this is the OUTPUT DELAY FOR THE MEMORY FOR SYNTHESIS

always@(*) 
  begin 
    #2 ReadBus1  =  Register[ReadAddress1];
    ReadBus2  =  Register[ReadAddress2]; 
  end
endmodule
