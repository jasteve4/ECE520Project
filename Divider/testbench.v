/*module testbench();

    reg inst_clk = 1; 
    reg inst_rst_n = 1; 
    reg inst_en = 1; 
    reg inst_a = 63; 
    reg inst_b = 1000;
    wire quotient_inst; 
    wire remainder_inst; 
    wire divide_by_0_inst;

  DW_div_pipe_inst divider_inst(
    inst_clk, 
    inst_rst_n, 
    inst_en, 
    inst_a, 
    inst_b,
    quotient_inst, 
    remainder_inst, 
    divide_by_0_inst
    );
  always #5 inst_clk <= ~inst_clk;

  initial
    begin
    #10 inst_rst_n = 0;
    #10 inst_rst_n = 1;
    #40

    $finish;
    end


endmodule
*/

module test();
  reg  clock = 1;
  reg  reset_n = 1;
  reg  start = 0;
  reg  [27:0] z = 28'd765;
  reg  [19:0] d = 20'd63;
  wire [7:0] q;
  wire s;
 
 always #5 clock <= ~clock;

/*  n_cycle_divider divider(
    clock,
    reset_n,
    start,
    z,
    d,
    q,
    s
  );*/

  pipeline_divider divider(
    .clock(clock),
    .reset_n(reset_n),
    .start(start),
    .divided(z),
    .divisor(d),
    .q(q),
    .StartOut(s)
    );



  initial
    begin
    #20 reset_n = 0;
    #20 reset_n = 1;
    #20 start = 1;
    #10 z = 3315;
    #10 z = 5865;
    #10 z = 9180;
    #60
    $finish;
    end

endmodule

