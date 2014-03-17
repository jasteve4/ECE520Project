module Cdf_Fetch(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [127:0]  ReadBus,
  output reg [15:0]   ReadAddress,
  output reg [19:0]   AccumlateOut,
  output reg          StartOut,
  output reg [15:0]   StoreAddress
  );

  reg [8:0]           count;
  wire [15:0]          DataIn;

  assign DataIn = (ReadBus[45:20] == 16'haaaa) ? ReadBus[19:0] : 20'b0;

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          StoreAddress <= 16'b0;
        end
      else
        begin
          StoreAddress <= ReadAddress;
        end
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          ReadAddress <= 16'b0;
          AccumlateOut <= 20'b0;
          StartOut <= 1'b0;
          count <= 0;
        end
      else
        begin
          if(start & (count < 9'd256))
            begin
              ReadAddress <= ReadAddress + 1'b1;
              AccumlateOut <= DataIn;
              StartOut <= 1'b1;
              count <= count + 1'b1;
            end
          else if(start & (count >9'd255))
            begin
              ReadAddress <= 16'd0;
              AccumlateOut <= DataIn;
              StartOut <= 1'b0;
              count <= count;
            end
          else
            begin
              ReadAddress <= 16'b0;
              AccumlateOut <= 20'b0;
              StartOut <= 1'b0;
              count <= 1'b0;
            end
        end
    end

endmodule

