

module pipeline_divider(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire [27:0] divided,
  input wire [19:0] divisor,
  output wire [7:0] q,
  output wire StartOut
  );


  wire start1, start2, start3, start4, start5, start6, start7;
  wire [19:0] divisor1, divisor2, divisor3, divisor4, divisor5, divisor6, divisor7, divisor_in;
  wire [27:0] result1, result2, result3, result4, result5, result6, result7;
  wire [7:0] q0, q1, q2, q3, q4, q5, q6;
  wire [9:0] input_init;
  assign divisor_in = ~divisor;

  divider_pipe_stage stage0(
  .clock(clock),
  .reset_n(reset_n),
  .start(start),
  .divided(divided),
  .divisor(divisor_in),
  .q_in(8'd0),
  .start_out(start1),
  .divisor_out(divisor1),
  .result(result1),
  .q_out(q0)
  );

  divider_pipe_stage stage1(
  .clock(clock),
  .reset_n(reset_n),
  .start(start1),
  .divided(result1),
  .divisor(divisor1),
  .q_in(q0),
  .start_out(start2),
  .divisor_out(divisor2),
  .result(result2),
  .q_out(q1)
  );

  divider_pipe_stage stage2(
  .clock(clock),
  .reset_n(reset_n),
  .start(start2),
  .divided(result2),
  .divisor(divisor2),
  .q_in(q1),
  .start_out(start3),
  .divisor_out(divisor3),
  .result(result3),
  .q_out(q2)
  );

  
  divider_pipe_stage stage3(
  .clock(clock),
  .reset_n(reset_n),
  .start(start3),
  .divided(result3),
  .divisor(divisor3),
  .q_in(q2),
  .start_out(start4),
  .divisor_out(divisor4),
  .result(result4),
  .q_out(q3)
  );

  divider_pipe_stage stage4(
  .clock(clock),
  .reset_n(reset_n),
  .start(start4),
  .divided(result4),
  .divisor(divisor4),
  .q_in(q3),
  .start_out(start5),
  .divisor_out(divisor5),
  .result(result5),
  .q_out(q4)
  );

  divider_pipe_stage stage5(
  .clock(clock),
  .reset_n(reset_n),
  .start(start5),
  .divided(result5),
  .divisor(divisor5),
  .q_in(q4),
  .start_out(start6),
  .divisor_out(divisor6),
  .result(result6),
  .q_out(q5)
  );

  divider_pipe_stage stage6(
  .clock(clock),
  .reset_n(reset_n),
  .start(start6),
  .divided(result6),
  .divisor(divisor6),
  .q_in(q5),
  .start_out(start7),
  .divisor_out(divisor7),
  .result(result7),
  .q_out(q6)
  );

  end_pipe_stage stage7(
  .clock(clock),
  .reset_n(reset_n),
  .start(start7),
  .divided(result7),
  .divisor(divisor7),
  .q_in(q6),
  .start_out(StartOut),
  .q_out(q)
  );


endmodule





