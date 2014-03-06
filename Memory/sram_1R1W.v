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
module sram_1R1W (clock, WE, WriteAddress, ReadAddress, WriteBus, ReadBus);
input  clock, WE; 
input  [15:0] WriteAddress, ReadAddress; 
input  [127:0] WriteBus;
output [127:0] ReadBus;

reg [127:0] Register [0:65535];   // 65536 words, with each 128 bits wide
reg [127:0] ReadBus;
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
    #2 ReadBus  =  Register[ReadAddress];
  end
endmodule
