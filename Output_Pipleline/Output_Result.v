module Output_Result(
  input wire clock,
  input wire reset_n,
  input wire [27:0] DataIn,
  input wire StartIn,
  input wire [19:0] Divisor,
  output wire StartOut,
  output wire [7:0] DataOut
  );
  

  
  pipeline_divider divider(
    .clock(clock),
    .reset_n(reset_n),
    .start(StartIn),
    .divided(DataIn),
    .divisor(Divisor),
    .q(DataOut),
    .StartOut(StartOut)
  );


endmodule
