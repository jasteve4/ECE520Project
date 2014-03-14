module Fetch(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [127:0]  ReadBus,
  output reg [15:0]   ReadAddress,
  output reg [7:0]   DataOut,
  output reg          StartOut,
  output reg [15:0]   StoreAddress
  );

  reg [4:0]           short_count;
  reg [7:0]           data;

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
          StartOut <= 1'b0;
          DataOut <= 8'dx;
          short_count <= 0;
        end
      else
        begin
          if(start & (short_count != 4'hf))
            begin
              ReadAddress <= ReadAddress;
              StartOut <= 1'b1;
              DataOut <= data;
              short_count <= short_count + 1'b1;
            end
          else if(start & (short_count == 4'hf))
            begin
              ReadAddress <= ReadAddress + 1'd1;
              StartOut <= 1'd1;
              DataOut <= data;
              short_count <= 4'd0;
            end
          else
            begin
              ReadAddress <= 16'b0;
              StartOut <= 1'b0;
              DataOut <= 8'dx;
              short_count <= 1'b0;
            end
        end
    end

  always@(*)
    begin
      case(short_count)
        4'hf: data <= ReadBus[7:0];
        4'he: data <= ReadBus[15:8];
        4'hd: data <= ReadBus[23:16];
        4'hc: data <= ReadBus[31:24];
        4'hb: data <= ReadBus[39:32];
        4'ha: data <= ReadBus[47:40];
        4'h9: data <= ReadBus[55:48];
        4'h8: data <= ReadBus[63:56];
        4'h7: data <= ReadBus[71:64];
        4'h6: data <= ReadBus[79:72];
        4'h5: data <= ReadBus[87:80];
        4'h4: data <= ReadBus[95:88];
        4'h3: data <= ReadBus[103:96];
        4'h2: data <= ReadBus[111:104];
        4'h1: data <= ReadBus[119:112];
        4'h0: data <= ReadBus[127:120];
      endcase
    end


endmodule

