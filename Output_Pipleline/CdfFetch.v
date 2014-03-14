module CdfFetch(
  input wire          clock,
  input wire          reset_n,
  input wire [127:0]  ReadBus,
  output wire [15:0]  ReadAddress,
  input wire [7:0]    DataIn,
  output reg [7:0]    DataOut,
  input wire          StartIn,
  output reg          StartOut
  );

  reg [7:0]           data;

  assign ReadAddress = {8'b0,DataIn};

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          StartOut <= 1'b0;
          DataOut <= 8'bx;
        end
      else
        begin
          if(StartIn)
            begin
              StartOut <= 1'b1;
              DataOut <= ReadBus[7:0];
            end
          else
            begin
              StartOut <= 1'b0;
              DataOut <= 8'bx;
            end
        end
    end



endmodule

