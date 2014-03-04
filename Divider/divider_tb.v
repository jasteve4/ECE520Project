module divider_tb;

parameter NUM_POINTS = 100;
parameter RND_SEED = 1;

reg clk, rst_n, start;
reg [3:0] A, B;
wire [7:0] Q;
wire done;

integer i,div_ab;
reg seq_error, seq_total;

always
	#5 clk = ~clk;

initial
begin
	clk = 1;
	rst_n = 0;
	A = 0;
	B = 0;
	start = 0;

	#10 rst_n = 1;

	for(i=0; i<NUM_POINTS; i=i+1)
	begin
		//generate random numbers
		A={$random} % 16;
		B={$random} % 16;
		
		//start calculation and wait for done
		wait(!done);
		@(posedge clk) #1
		start = 1;
		@(posedge clk) #1
		start = 0;
		wait(done); #1

		//self checking
		div_ab = A*B;
		seq_error = (div_ab == Q) ? 0 : 1;
		seq_total = seq_error ? 1: seq_total;

		$display("%2d * %2d = %3d, Seq = %3d (%s)",
			A, B, div_ab,
			Q, seq_error ? "FAIL" : "PASS" );
	end

	#100

	$display("Divider : %s",seq_total);
	$stop;

end

mult_4x4_seq DUT(clk, rst_n, start, A, B, M, done);

endmodule
