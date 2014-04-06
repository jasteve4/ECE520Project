module Output_Fetch_Cdf(
  input wire          clock,
  input wire          reset_n,
  input wire [127:0]  ReadBus,
  output reg [19:0]   DataOut,
  input wire          StartIn,
  output reg          StartOut
  );

  reg [107:0] DeadIn;

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          StartOut <= 1'b0;
          DataOut <= 20'bx;
          DeadIn <= 108'd0;
        end
      else
        begin
          if(StartIn)
            begin
              StartOut <= 1'b1;
              DataOut <= ReadBus[19:0];
              DeadIn <= ReadBus[127:20];
            end
          else
            begin
              StartOut <= 1'b0;
              DataOut <= 20'bx;
              DeadIn <= 107'd0;
            end
        end
    end



endmodule

