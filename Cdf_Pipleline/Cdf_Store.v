module Cdf_Store(
  input wire clock,
  input wire reset_n,
  input wire StartIn,
  input wire [19:0] ResultIn,
  input wire [15:0] StoreAddressIn,
  output wire [127:0] WriteBus,
  output wire [15:0] WriteAddress,
  output wire WriteEnable
  );

  reg Write;
  reg [15:0] WriteAddr;
  reg [127:0] Write_Bus;

  assign WriteEnable = (Write) ? 1'b1 : 1'bz;
  assign WriteAddress = (Write) ? WriteAddr : 16'bz;
  assign WriteBus = (Write) ? Write_Bus : 128'bz;

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          Write_Bus <= 16'b0;
          WriteAddr <= 16'b0;
          Write <= 1'b0;
        end
      else
        begin
          if(StartIn)
            begin    
              Write_Bus <= ResultIn;
              WriteAddr <= StoreAddressIn;
              Write <= 1'b1;
            end
          else
            begin
              Write_Bus <= 16'b0;
              WriteAddr <= 16'b0;
              Write <= 1'b0;
            end
        end
    end

  endmodule
