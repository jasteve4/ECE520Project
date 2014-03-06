module input_pipeline_tb();

reg [127:0] input_data [0:65535]; 
reg [127:0] memory [0:65535]; 
integer i;

initial begin
  $readmemh("../Hex_Files/input_small_hex.txt",input_data);
end

endmodule
