module Output_TopExpression(
  input wire clock,
  input wire reset_n,
  input wire [19:0] DataIn,
  input wire [19:0] CdfMin,
  input wire StartIn,
  output reg StartOut,
  output reg [27:0] DataOut
  );
  
  wire [19:0] Data;

  assign Data = DataIn - CdfMin;



  always@(posedge clock or negedge reset_n)
    if(!reset_n)
      begin
        StartOut <= 1'b0;
      end
    else
      begin
        if(StartIn)
          begin
            StartOut <= 1'd1;
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
          DataOut <= 28'b0;
        end
      else
        begin
          if(StartIn)
            begin
              DataOut <= {(Data) ,8'd0} - Data;
            end
          else
            begin
              DataOut <= 28'b0;
            end
        end
    end


endmodule
