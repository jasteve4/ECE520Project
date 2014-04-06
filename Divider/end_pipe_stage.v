
module end_pipe_stage(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire [27:0] divided,
  input wire [19:0] divisor,
  input wire [7:0] q_in,
  output reg start_out,
  output reg [7:0] q_out
  );


  reg [27:0] result;
  wire [20:0] stage_result;
  wire [27:0] stage_divided;
  wire q;
  wire [7:0] q_inner;
  wire [19:0] divided_input;

  assign stage_divided = {divided, 1'd0};
  assign divided_input = stage_divided[27:8];

  DW01_add #(20)
    stage_add(.A(divided_input), .B(divisor), .CI(1'd1), .SUM(stage_result[19:0]), .CO(stage_result[20]));

  assign q = stage_result[20] ^ divided[27];
  assign q_inner = {q_in,q};

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          result <= 28'd0;
          q_out <= 8'd0;
          start_out <= 1'd0;
        end
      else
        begin
          if(start)
            begin
              result <= stage_result;
              q_out <= q_inner;
              start_out <= 1'd1;
            end
          else
            begin
              result <= 28'd0;
              q_out <= 8'd0;
              start_out <= 1'd0;
            end
        end
    end
endmodule
