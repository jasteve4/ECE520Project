module Cdf_Store(
  input wire clock,
  input wire reset_n,
  input wire StartIn,
  input wire [19:0] ResultIn,
  input wire [15:0] StoreAddressIn,
  output reg [127:0] WriteBus,
  output reg [15:0] WriteAddress,
  output reg WriteEnable
  );

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          WriteBus <= 16'b0;
          WriteAddress <= 16'b0;
          WriteEnable <= 1'b0;
        end
      else
        begin
          if(StartIn)
            begin    
              WriteBus <= ResultIn;
              WriteAddress <= StoreAddressIn;
              WriteEnable <= 1'b1;
            end
          else
            begin
              WriteBus <= 16'b0;
              WriteAddress <= 16'b0;
              WriteEnable <= 1'b0;
            end
        end
    end

  endmodule
