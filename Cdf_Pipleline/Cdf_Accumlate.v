
  // synopsys translate_off
`include "/afs/bp/dist/synopsys_syn/dw/sim_ver/DW01_add.v"
  // synopsys translate_on

module Cdf_Accumlate(
  input wire clock,
  input wire reset_n,
  input wire [19:0] AccumlateIn,
  input wire StartIn,
  input wire [15:0] StoreAddressIn,
  output reg [19:0] AccumlateResult,
  output reg [15:0] StoreAddressOut,
  output reg StartOut,
  output reg [19:0] CdfMin,
  output reg CdfValid
  );

  wire [19:0] AccumlateOut;
  wire Cout;

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

  always@(posedge clock)
    begin
      StoreAddressOut <= StoreAddressIn;
    end

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          AccumlateResult <= 1'b0;
          CdfMin <= 20'd0;
          CdfValid <= 1'd0;
        end
      else
        begin
          if(StartIn)
            begin
              AccumlateResult <= AccumlateOut;
              if(CdfMin == 20'd0)
                begin
                  if(AccumlateResult > 20'd0)
                    begin
                      CdfMin <= AccumlateOut;
                      CdfValid <= 1'd1;
                    end
                  else
                    begin
                      CdfMin <= CdfMin;
                      CdfValid <= 1'd0;
                    end
                end
              else
                begin
                  CdfMin <= CdfMin;
                  CdfValid <= 1'd0;
                end
            end
          else
            begin
              AccumlateResult <= 1'b0;
              CdfMin <= 20'd0;
              CdfValid <= 1'd0;
            end
        end
    end

  DW01_add #(20)
    add(.A(AccumlateResult), .B(AccumlateIn), .CI(1'd0), .SUM(AccumlateOut), .CO(Cout));

endmodule
