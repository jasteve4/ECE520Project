
module divider_pipe_stage(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire [27:0] divided,
  input wire [19:0] divisor,
  input wire [7:0] q_in,
  output reg start_out,
  output reg [19:0] divisor_out,
  output reg [27:0] result,
  output reg [7:0] q_out
  );


  wire [20:0] stage_result;
  wire [27:0] stage_divided;
  wire q;
  wire [7:0] q_inner;

  assign stage_divided = {divided, 1'd0};
  
  DW01_add #(20)
    stage_add(.A(stage_divided[27:8]), .B(divisor), .CI(1'd1), .SUM(stage_result[19:0]), .CO(stage_result[20]));

  assign q = stage_result[20] ^ divided[27];
  assign q_inner = {q_in,q};

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          divisor_out <= 20'd0;
          result <= 28'd0;
          q_out <= 8'd0;
          start_out <= 1'd0;
        end
      else
        begin
          if(start)
            begin
              divisor_out <= divisor;
              result <= q ? {stage_result, stage_divided[7:0]} : stage_divided;
              q_out <= q_inner;
              start_out <= 1'd1;
            end
          else
            begin
              divisor_out <= 20'd0;
              result <= 28'd0;
              q_out <= 8'd0;
              start_out <= 1'd0;
            end
        end
    end
endmodule
