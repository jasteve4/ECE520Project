module Cdf_Accumlate(
  input wire clock,
  input wire reset_n,
  input wire [19:0] AccumlateIn,
  input wire StartIn,
  input wire [15:0] StoreAddressIn,
  output reg [19:0] AccumlateResult,
  output reg [15:0] StoreAddressOut,
  output reg StartOut
  );

  always@(posedge clock or negedge reset_n)
    if(!reset_n)
      begin
        StartOut <= 1'b0;
      end
    else
      begin
        if(StartIn)
          begin
            StartOut <= 1'b1;
          end
        else
          begin
            StartOut <= 1'b0;
          end
      end

  always@(posedge clock)
    begin
      StoreAddressOut <= StoreAddressIn;
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          AccumlateResult <= 1'b0;
        end
      else
        begin
          if(StartIn)
            begin
              AccumlateResult <= AccumlateResult + AccumlateIn;
            end
          else
            begin
              AccumlateResult <= 1'b0;
            end
        end
    end

endmodule
