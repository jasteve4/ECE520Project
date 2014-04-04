module Cdf_Fetch(
  input wire          clock,
  input wire          reset_n,
  input wire         start,
  input wire [35:0]  ReadBus,
  output wire [15:0]   ReadAddr,
  output reg [19:0]   AccumlateOut,
  output reg          StartOut,
  output reg [15:0]   StoreAddress,
  input wire input_base_offset,
  output reg done
  );

  reg [8:0]           count;
  reg [19:0]         DataIn;
  reg [15:0]          ReadAddress;
  reg done0, done1;

 // assign DataIn = (ReadBus[45:20] == 16'haaaa) ? ReadBus[19:0] : 20'b0;
  assign ReadAddr = (start) ? ReadAddress : 16'bz;

  always@(*)
    begin
      if(ReadBus[35:20] == 16'haaaa)
        DataIn <= ReadBus[19:0];
      else
        DataIn <= 20'd0;
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          StoreAddress <= 16'b0;
          done1 <= 1'd0;
          done <= 1'd0;
        end
      else
        begin
          StoreAddress <= ReadAddress;
          done1 <= done0;
          done <= done1;
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
          done0 <= 1'd0;
        end
      else
        begin
          if(start & (count < 9'd256))
            begin
              ReadAddress <= ReadAddress + 1'b1;
              AccumlateOut <= DataIn;
              StartOut <= 1'b1;
              count <= count + 1'b1;
              done0 <= 1'd0;
            end
          else if(start & (count >9'd255))
            begin
              ReadAddress <= 16'd0;
              AccumlateOut <= DataIn;
              StartOut <= 1'b0;
              count <= count;
              done0 <= 1'd1;
            end
          else
            begin
              ReadAddress <= {input_base_offset,15'b0};
              AccumlateOut <= 20'b0;
              StartOut <= 1'b0;
              count <= 1'b0;
              done0 <= 1'd0;
            end
        end
    end

endmodule
