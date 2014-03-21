module Output_Store(
  input wire clock,
  input wire reset_n,
  input wire StartIn,
  input wire [7:0] ResultIn,
  output reg [127:0] WriteBus,
  output reg [15:0] WriteAddress,
  output reg WriteEnable,
  output reg done,
  input wire output_base_offset
  );
  
  reg [4:0] short_count;
  reg [15:0] next_WriteAddress;
  reg [127:0] data;
  reg [127:0] offset;
  integer i, j;

  always@(posedge clock)
    begin
      WriteAddress <= next_WriteAddress;
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          WriteBus <= 127'bz;
          next_WriteAddress <= 16'b0;
          WriteEnable <= 1'b0;
          short_count <= 4'd15;
          done <= 1'd1;
        end
      else
        begin
          if(StartIn & (short_count == 4'h0))
            begin    
              WriteBus <= data;
              next_WriteAddress <= next_WriteAddress + 1'd1;
              WriteEnable <= 1'b1;
              short_count <= 4'd15;
              done <= 1'b0;
            end
          else if(StartIn)
            begin
              WriteBus <= 127'bz;
              next_WriteAddress <= next_WriteAddress;
              WriteEnable <= 1'b0;
              short_count <= short_count - 1'b1;
              done <= 1'b0;
            end
          else
            begin
              WriteBus <= 127'bz;
              next_WriteAddress <= {output_base_offset,15'b0};
              WriteEnable <= 1'b0;
              short_count <= 4'd15;
              done <= 1'b1;
            end
        end
    end

  always@(*)
    begin
      for(i = 4'b0; i <= 4'd15; i = i + 4'b1)
        begin
          if(i == short_count)
            begin
              offset = i << 3;
              for(j = 3'd0; j <= 3'd7; j = j + 3'd1)
                begin
                  data[offset + j] = ResultIn[j];
                end
            end
          else
            begin
              offset = i << 3;
              for(j = 3'd0; j <= 3'd7; j = j + 3'd1)
                begin
                  data[offset + j] = data[offset + j];
                end
            end
        end
    end

  endmodule
