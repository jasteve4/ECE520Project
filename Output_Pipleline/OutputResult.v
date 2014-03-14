module OutputResult(
  input wire clock,
  input wire reset_n,
  input wire [15:0] DataIn,
  input wire StartIn,
  output reg StartOut,
  output reg [7:0] DataOut
  );
  


  always@(posedge clock or negedge reset_n)
    if(!reset_n)
      begin
        StartOut <= 1'b0;
      end
    else
      begin
        if(StartIn)
          begin
            StartOut <= 1'b1;
          end
        else
          begin
            StartOut <= 1'b0;
          end
      end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          DataOut <= 16'b0;
        end
      else
        begin
          if(StartIn)
            begin
              DataOut <= DataIn / 8'd63;
            end
          else
            begin
              DataOut <= 16'b0;
            end
        end
    end


endmodule
