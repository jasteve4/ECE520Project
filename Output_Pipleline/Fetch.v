module Fetch(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [127:0]  ReadBus1,
  input wire [127:0]  ReadBus2,
  output reg [15:0]   ReadAddress1,
  output reg [15:0]   ReadAddress2,
  output reg [14:0]   AccumlateOut1,
  output reg [14:0]   AccumlateOut2,
  output reg [2:0]    store_count
  );

  reg [2:0] count;

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n & !start)
        begin
          ReadAddress1 <= 15'b0;
          ReadAddress2 <= 15'b0;
          count <= 3'b0;
        end
      else
        begin
          ReadAddress1 <= ReadAddress1 + 2'b10;
          ReadAddress2 <= ReadAddress2 + 2'b10;
          count <= count + 1'b1;
        end
    end

  always@(*)
    if(!reset_n)
      begin
        store_count <= 3'b0;
      end
    else
      begin
        store_count <= count;
      end


  always@(*)  
    begin
      if(!reset_n)
        begin
          AccumlateOut1 <= 15'b0;
          AccumlateOut2 <= 15'b0;
        end
      else
        begin
          AccumlateOut1 <= ReadBus1[14:0];
          AccumlateOut2 <= ReadBus2[14:0];
        end
    end

endmodule

