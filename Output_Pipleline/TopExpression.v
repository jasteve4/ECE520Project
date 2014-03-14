module TopExpression(
  input wire clock,
  input wire reset_n,
  input wire [7:0] DataIn,
  input wire [7:0] CdfMin,
  input wire StartIn,
  output reg StartOut,
  output reg [15:0] DataOut
  );
  
  reg [7:0] sub;
  reg [7:0] sub1;
  reg [15:0] left_shift;

  reg StartOut1;
  reg StartOut2;

  always@(posedge clock or negedge reset_n)
    if(!reset_n)
      begin
        StartOut1 <= 1'b0;
        StartOut2 <= 1'b0;
        StartOut <= 1'b0;
      end
    else
      begin
        if(StartIn)
          begin
            StartOut1 <= 1'b1;
            StartOut2 <= StartOut1;
            StartOut <= StartOut2;
          end
        else
          begin
            StartOut1 <= 1'b0;
            StartOut2 <= StartOut1;
            StartOut <= StartOut2;
          end
      end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          sub <= 8'b0;
          sub1 <= 8'b0;
          left_shift <= 16'b0;
          DataOut <= 16'b0;
        end
      else
        begin
          if(StartIn | StartOut1 | StartOut2)
            begin
              sub <= DataIn - CdfMin;
              sub1 <= sub;
              left_shift <= sub << 8;
              DataOut <= left_shift - sub1;
            end
          else
            begin
              sub <= 8'b0;
              sub1 <= 1'b0;
              left_shift <= 16'b0;
              DataOut <= 16'b0;
            end
        end
    end


endmodule
