module Output_Store(
  input wire clock,
  input wire reset_n,
  input wire StartIn,
  input wire [7:0] ResultIn,
  output reg [127:0] WriteBus,
  output reg [15:0] WriteAddress,
  output reg WriteEnable,
  input wire output_base_offset
  );
  
  reg [4:0] short_count;
  reg [15:0] next_WriteAddress;
  reg [127:0] data;
  reg [127:0] offset;

  always@(posedge clock)
    begin
      WriteAddress <= next_WriteAddress;
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          WriteBus <= 127'b0;
          next_WriteAddress <= 16'b0;
          WriteEnable <= 1'b0;
          short_count <= 4'd15;
        end
      else
        begin
          if(StartIn)
            begin
              case(short_count)
                4'h0: WriteBus <= {WriteBus[127:8], ResultIn};
                4'h1: WriteBus <= {WriteBus[127:16], ResultIn, WriteBus[7:0]};
                4'h2: WriteBus <= {WriteBus[127:24], ResultIn, WriteBus[15:0]};
                4'h3: WriteBus <= {WriteBus[127:32], ResultIn, WriteBus[23:0]};
                4'h4: WriteBus <= {WriteBus[127:40], ResultIn, WriteBus[31:0]};
                4'h5: WriteBus <= {WriteBus[127:48], ResultIn, WriteBus[39:0]};
                4'h6: WriteBus <= {WriteBus[127:56], ResultIn, WriteBus[47:0]};
                4'h7: WriteBus <= {WriteBus[127:64], ResultIn, WriteBus[55:0]};
                4'h8: WriteBus <= {WriteBus[127:72], ResultIn, WriteBus[63:0]};
                4'h9: WriteBus <= {WriteBus[127:80], ResultIn, WriteBus[71:0]};
                4'ha: WriteBus <= {WriteBus[127:88], ResultIn, WriteBus[79:0]};
                4'hb: WriteBus <= {WriteBus[127:96], ResultIn, WriteBus[87:0]};
                4'hc: WriteBus <= {WriteBus[127:104], ResultIn, WriteBus[95:0]};
                4'hd: WriteBus <= {WriteBus[127:112], ResultIn, WriteBus[103:0]};
                4'he: WriteBus <= {WriteBus[127:120], ResultIn, WriteBus[111:0]};
                4'hf: WriteBus <= {ResultIn, WriteBus[119:0]};
              endcase
              if(short_count == 4'h0)
                begin
                  next_WriteAddress <= next_WriteAddress + 1'd1;
                  WriteEnable <= 1'b1;
                  short_count <= 4'd15;
                end
              else
                begin
                  next_WriteAddress <= next_WriteAddress;
                  WriteEnable <= 1'b0;
                  short_count <= short_count - 1'b1;
                end
            end
          else
            begin
              WriteBus <= 127'b0;
              next_WriteAddress <= 16'b0;
              WriteEnable <= 1'b0;
              short_count <= 4'd15;
            end
        end
    end

  endmodule
