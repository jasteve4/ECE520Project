

module Output_TopExpression(
  input wire clock,
  input wire reset_n,
  input wire [19:0] DataIn,
  input wire [19:0] CdfMin,
  input wire StartIn,
  output reg StartOut,
  output reg [27:0] DataOut
  );
  
  reg [19:0] Data;
  wire [19:0] dataResult;
  reg [19:0] dataTop;
  reg dataCout;
  wire [13:0] result, data_Result;
  reg [13:0] dataBottom;
  wire cout, bottom_cout, data_cout;
  reg  Start0, Start1;
  wire [27:0] B;

//  assign Data = DataIn - CdfMin;


  DW01_add #(20)
    first_add(.A(DataIn), .B(~CdfMin), .CI(1'd1), .SUM(dataResult), .CO(data_Cout));

  always@(posedge clock or negedge reset_n)
    if(!reset_n)
      begin
        Data <= 20'b0;
        Start0 <= 1'd0;
      end
    else
      begin
        if(StartIn)
          begin
            Data <= dataResult;
            Start0 <= 1'd1;
          end
        else
          begin
            Data <= 20'b0;
            Start0 <= 1'd0;
          end
      end

  DW01_add #(14)
    bottom_add(.A({Data[5:0],8'd0}), .B(~Data[13:0]), .CI(1'd1), .SUM(data_Result), .CO(bottom_cout));

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          dataTop <= 20'd0;
          dataBottom <= 14'd0;
          dataCout <= 1'd0;
          Start1 <= 1'd0;
        end
      else
        begin
          if(Start0)
            begin
              dataTop <= Data;
              dataBottom <= data_Result;
              dataCout <= bottom_cout;
              Start1 <= 1'd1;
            end
          else
            begin
              dataTop <= 20'd0;
              dataBottom <= 14'd0;
              dataCout <= 1'd0;
              Start1 <= 1'd0;
            end
        end
    end
  
  DW01_add #(14)
    top_add(.A(dataTop[19:6]), .B(~{8'd0,dataTop[19:14]}), .CI(dataCout), .SUM(result), .CO(cout));

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          DataOut <= 28'b0;
          StartOut <= 1'd0;
        end
      else
        begin
          if(Start1)
            begin
                DataOut <= {result, dataBottom};
                StartOut <= 1'd1;
            end
          else
            begin
              DataOut <= 28'b0;
              StartOut <= 1'd0;
            end
        end
    end




endmodule
