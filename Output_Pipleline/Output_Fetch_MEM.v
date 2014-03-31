module Output_Fetch_MEM(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [127:0]  ReadBus,
  output reg [15:0]   ReadAddress,
  output reg [7:0]   DataOut,
  output reg          StartOut,
  output reg [15:0]   StoreAddress,
  input wire output_base_offset,
  output reg done
  );

  reg [3:0]           short_count;
  reg [127:0]           data_in;
  reg done0, done1, done2, done3, done4, done5;

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          StoreAddress <= 16'b0;
          done1 <= 1'd0;
          done2 <= 1'd0;
          done3 <= 1'd0;
          done4 <= 1'd0;
          done5 <= 1'd0;
          done <= 1'd0;
        end
      else
        begin
          StoreAddress <= ReadAddress;
          done1 <= done0;
          done2 <= done1;
          done3 <= done2;
          done4 <= done3;
          done5 <= done4;
          done <= done5;
        end
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          ReadAddress <= 16'b0;
          StartOut <= 1'b0;
          data_in <= 8'dx;
          short_count <= 0;
          done0 <= 1'b0;
        end
      else
        begin
          if(start & (short_count != 4'hf))
            begin
              ReadAddress <= ReadAddress;
              StartOut <= 1'b1;
              data_in <= ReadBus;
              short_count <= short_count + 1'b1;
              done0 <= 1'b0;
            end
          else if(start & (short_count == 4'hf))
            begin
              if((ReadAddress[14:0] +1'd1) == 15'd16) //15'd19200)
                begin
                  StartOut <= 1'd0;
                  ReadAddress <= ReadAddress;
                  short_count <= short_count;
                  done0 <= 1'b1;
                end
              else
                begin
                  StartOut <= 1'd1;
                  ReadAddress <= ReadAddress + 1'd1;
                  short_count <= 4'd0;
                  done0 <= 1'b0;
                end
              data_in <= ReadBus;
            end
          else
            begin
              ReadAddress <= {output_base_offset, 15'b0};
              StartOut <= 1'b0;
              data_in <= 8'dx;
              short_count <= 1'b0;
              done0 <= 1'd0;
            end
        end
    end

  always@(*)
    begin
      case(short_count)
        4'h0: DataOut <= data_in[7:0];
        4'hf: DataOut <= data_in[15:8];
        4'he: DataOut <= data_in[23:16];
        4'hd: DataOut <= data_in[31:24];
        4'hc: DataOut <= data_in[39:32];
        4'hb: DataOut <= data_in[47:40];
        4'ha: DataOut <= data_in[55:48];
        4'h9: DataOut <= data_in[63:56];
        4'h8: DataOut <= data_in[71:64];
        4'h7: DataOut <= data_in[79:72];
        4'h6: DataOut <= data_in[87:80];
        4'h5: DataOut <= data_in[95:88];
        4'h4: DataOut <= data_in[103:96];
        4'h3: DataOut <= data_in[111:104];
        4'h2: DataOut <= data_in[119:112];
        4'h1: DataOut <= data_in[127:120];
      endcase
    end


endmodule

