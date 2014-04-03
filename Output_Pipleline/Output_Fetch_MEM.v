module Output_Fetch_MEM(
  input wire          clock,
  input wire          reset_n,
  input wire          start,
  input wire [127:0]  ReadBus,
  output reg [15:0]   ReadAddress,
  output reg [15:0]   DataOut,
  output reg          StartOut,
  input wire output_base_offset,
  output reg done
  );

  reg [3:0]           short_count;
  reg [127:0]           data_in;
  reg done0, done1, done2, done3, done4, done5, done6, done7, done8;
  reg base_offset;

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          done1 <= 1'd0;
          done2 <= 1'd0;
          done3 <= 1'd0;
          done4 <= 1'd0;
          done5 <= 1'd0;
          done6 <= 1'd0;
          done7 <= 1'd0;
          done8 <= 1'd0;
          done <= 1'd0;
        end
      else
        begin
          done1 <= done0;
          done2 <= done1;
          done3 <= done2;
          done4 <= done3;
          done5 <= done4;
          done6 <= done5;
          done7 <= done6;
          done8 <= done7;
          done <= done8;
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
              if((ReadAddress[14:0]) == 15'd19199) //15'd19200)
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

  always@(posedge clock)
    base_offset <= output_base_offset;

  always@(*)
    begin
      case(short_count)
        16'hf: DataOut <= {base_offset,7'd0, data_in[15:8]};
        16'he: DataOut <= {base_offset,7'd0, data_in[23:16]};
        16'hd: DataOut <= {base_offset,7'd0, data_in[31:24]};
        16'hc: DataOut <= {base_offset,7'd0, data_in[39:32]};
        16'hb: DataOut <= {base_offset,7'd0, data_in[47:40]};
        16'ha: DataOut <= {base_offset,7'd0, data_in[55:48]};
        16'h9: DataOut <= {base_offset,7'd0, data_in[63:56]};
        16'h8: DataOut <= {base_offset,7'd0, data_in[71:64]};
        16'h7: DataOut <= {base_offset,7'd0, data_in[79:72]};
        16'h6: DataOut <= {base_offset,7'd0, data_in[87:80]};
        16'h5: DataOut <= {base_offset,7'd0, data_in[95:88]};
        16'h4: DataOut <= {base_offset,7'd0, data_in[103:96]};
        16'h3: DataOut <= {base_offset,7'd0, data_in[111:104]};
        16'h2: DataOut <= {base_offset,7'd0, data_in[119:112]};
        16'h1: DataOut <= {base_offset,7'd0, data_in[127:120]};
        16'h0: DataOut <= {base_offset,7'd0, data_in[7:0]};
      endcase
    end


endmodule

