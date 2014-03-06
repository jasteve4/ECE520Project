module divider_tb;

parameter NUM_POINTS = 1000;
parameter RND_SEED = 1;

reg clk, rst_n, start;
reg [15:0] A, B;
wire [15:0] Q, remainder;
wire done;

integer i,div_ab;
reg seq_error;
reg [31:0] seq_total;

always
	#5 clk = ~clk;

initial
begin
	clk = 1;
	rst_n = 0;
	A = 0;
	B = 0;
	start = 0;
  seq_total = 0;

	#10 rst_n = 1;
	    start = 1;

	for(i=0; i<NUM_POINTS; i=i+1)
	begin
		//generate random numbers
		A={$random} % 65535;
		B={$random} % 65535 + 1;
		
		//start calculation and wait for done
		wait(!done);
		@(posedge clk) #1
		start = 1;
		@(posedge clk) #1
		start = 0;
		wait(done); #1

		//self checking
		div_ab = A/B+1;
		seq_error = (div_ab == Q) ? 0 : 1;
		seq_total = seq_total + (seq_error ? 0 : 1);

		$display("%2d / %2d = %3d, Seq = %3d (%s)",
			A, B, div_ab,
			Q, seq_error ? "FAIL" : "PASS" );
	end

	#100

	$display("Divider ERRORS: %s",seq_total);
	$stop;
end

divider DUT(.clk(clk), .start(start), .done(done), .A(A), .B(B), .Q(Q));

endmodule
