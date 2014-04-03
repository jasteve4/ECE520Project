
  // synopsys translate_off
`include "/afs/bp/dist/synopsys_syn/dw/sim_ver/DW01_add.v"
  // synopsys translate_on

module pipeline_divider(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire [27:0] divided,
  input wire [19:0] divisor,
  output wire [7:0] q,
  output reg StartOut
  );


  wire [27:0] stage0_result, stage1_result, stage2_result, stage3_result, stage4_result;
  wire [27:0] stage5_result, stage6_result, stage7_result;
  wire [19:0] divisor_n;

  reg [27:0] pipe0_result, pipe1_result, pipe2_result, pipe3_result, pipe4_result, pipe5_result, pipe6_result;
  reg [19:0] pipe0_divisor_n, pipe1_divisor_n, pipe2_divisor_n, pipe3_divisor_n, pipe4_divisor_n, pipe5_divisor_n, pipe6_divisor_n;
  wire q_bit0, q_bit1, q_bit2, q_bit3 ,q_bit4 ,q_bit5 ,q_bit6 ,q_bit7;
  reg [7:0] pipe0_q, pipe1_q, pipe2_q, pipe3_q, pipe4_q, pipe5_q, pipe6_q;

  reg StartOut0, StartOut1, StartOut2, StartOut3, StartOut4, StartOut5;
  
  // Pipe zero
  assign divisor_n = ~divisor;

  pipleline_stage stage0(.divided(divided), .divisor(divisor_n), .q(q_bit7), .stage_out(stage0_result));
  
  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          pipe0_result <= 28'd0;
          pipe0_divisor_n <= 20'd0;
          pipe0_q <= 8'd0;
          StartOut0 <= 1'd0;
        end
      else
        begin
          if(start)
            begin
              pipe0_result <= stage0_result;
              pipe0_divisor_n <= divisor_n;
              pipe0_q <= q_bit7;
              StartOut0 <= 1'd1;
            end
          else
            begin
              pipe0_result <= 28'd0;
              pipe0_divisor_n <= 20'd0;
              pipe0_q <= 8'd0;
              StartOut0 <= 1'd0;
            end
        end
    end
  
  pipleline_stage stage1(.divided(pipe0_result), .divisor(pipe0_divisor_n), .q(q_bit6), .stage_out(stage1_result));

  // Pipe One
  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          pipe1_result <= 28'd0;
          pipe1_divisor_n <= 20'd0;
          pipe1_q <= 8'd0;
          StartOut1 <= 1'd0;
        end
      else
        begin
          if(StartOut0)
            begin
              pipe1_result <= stage1_result;
              pipe1_divisor_n <= pipe0_divisor_n;
              pipe1_q <= {pipe0_q,q_bit6};
              StartOut1 <= 1'd1;
            end
          else
            begin
              pipe1_result <= 28'd0;
              pipe1_divisor_n <= 20'd0;
              pipe1_q <= 8'd0;
              StartOut1 <= 1'd0;
            end
        end
    end

  // Pipe One
  pipleline_stage stage2(.divided(pipe1_result), .divisor(pipe1_divisor_n), .q(q_bit5), .stage_out(stage2_result));
  
  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          pipe2_result <= 28'd0;
          pipe2_divisor_n <= 20'd0;
          pipe2_q <= 8'd0;
          StartOut2 <= 1'd0;
        end
      else
        begin
          if(StartOut1)
            begin
              pipe2_result <= stage2_result;
              pipe2_divisor_n <= pipe1_divisor_n;
              pipe2_q <= {pipe1_q,q_bit5};
              StartOut2 <= 1'd1;
            end
          else
            begin
              pipe2_result <= 28'd0;
              pipe2_divisor_n <= 20'd0;
              pipe2_q <= 8'd0;
              StartOut2 <= 1'd0;
            end
        end
    end

  pipleline_stage stage3(.divided(pipe2_result), .divisor(pipe2_divisor_n), .q(q_bit4), .stage_out(stage3_result));

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          pipe3_result <= 28'd0;
          pipe3_divisor_n <= 20'd0;
          pipe3_q <= 8'd0;
          StartOut3 <= 1'd0;
        end
      else
        begin
          if(StartOut2)
            begin
              pipe3_result <= stage3_result;
              pipe3_divisor_n <= pipe2_divisor_n;
              pipe3_q <= {pipe2_q, q_bit4};
              StartOut3 <= 1'd1;
            end
          else
            begin
              pipe3_result <= 28'd0;
              pipe3_divisor_n <= 20'd0;
              pipe3_q <= 8'd0;
              StartOut3 <= 1'd0;
            end
        end
    end

  // Pipe Two
  pipleline_stage stage4(.divided(pipe3_result), .divisor(pipe3_divisor_n), .q(q_bit3), .stage_out(stage4_result));
  
  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          pipe4_result <= 28'd0;
          pipe4_divisor_n <= 20'd0;
          pipe4_q <= 8'd0;
          StartOut4 <= 1'd0;
        end
      else
        begin
          if(StartOut3)
            begin
              pipe4_result <= stage4_result;
              pipe4_divisor_n <= pipe3_divisor_n;
              pipe4_q <= {pipe3_q, q_bit3};
              StartOut4 <= 1'd1;
            end
          else
            begin
              pipe4_result <= 28'd0;
              pipe4_divisor_n <= 20'd0;
              pipe4_q <= 8'd0;
              StartOut4 <= 1'd0;
            end
        end
    end

  pipleline_stage stage5(.divided(pipe4_result), .divisor(pipe4_divisor_n), .q(q_bit2), .stage_out(stage5_result));
  
  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          pipe5_result <= 28'd0;
          pipe5_divisor_n <= 20'd0;
          pipe5_q <= 8'd0;
          StartOut5 <= 1'd0;
        end
      else
        begin
          if(StartOut4)
            begin
              pipe5_result <= stage5_result;
              pipe5_divisor_n <= pipe4_divisor_n;
              pipe5_q <= {pipe4_q, q_bit2};
              StartOut5 <= 1'd1;
            end
          else
            begin
              pipe5_result <= 28'd0;
              pipe5_divisor_n <= 20'd0;
              pipe5_q <= 8'd0;
              StartOut5 <= 1'd0;
            end
        end
    end
  
  // Pipe Three
  pipleline_stage stage6(.divided(pipe5_result), .divisor(pipe5_divisor_n), .q(q_bit1), .stage_out(stage6_result));
  
  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          pipe6_result <= 28'd0;
          pipe6_divisor_n <= 20'd0;
          pipe6_q <= 8'd0;
          StartOut <= 1'd0;
        end
      else
        begin
          if(StartOut5)
            begin
              pipe6_result <= stage6_result;
              pipe6_divisor_n <= pipe5_divisor_n;
              pipe6_q <= {pipe5_q, q_bit1};
              StartOut <= 1'd1;
            end
          else
            begin
              pipe6_result <= 28'd0;
              pipe6_divisor_n <= 20'd0;
              pipe6_q <= 8'd0;
              StartOut <= 1'd0;
            end
        end
    end
  
  pipleline_stage stage7(.divided(pipe6_result), .divisor(pipe6_divisor_n), .q(q_bit0), .stage_out(stage7_result));

  assign q =(pipe6_divisor_n != 20'd0) ? {pipe6_q, q_bit0} : 20'd0;

endmodule




module pipleline_stage(
  input wire [27:0] divided,
  input wire [19:0] divisor,
  output q,
  output [27:0] stage_out
  );

  wire [20:0] stage_result;
  wire [27:0] stage_divided;

  DW01_add #(20)
    stage_add(.A(stage_divided[27:8]), .B(divisor), .CI(1'd1), .SUM(stage_result[19:0]), .CO(stage_result[20]));

  assign stage_divided = {divided, 1'd0};
//  assign stage_result = stage_divided[27:8] + divisor;
  assign q = stage_result[20] ^ divided[27];
  assign stage_out = q ? {stage_result, stage_divided[7:0]} : stage_divided;

/*
  assign stage_result = divided[14:7] + divisor;
  assign q = stage_result[8] ^ divided[15];
  assign stage_out = q ? {stage_result, divided[8:1]} : {divided, 1'd0};
*/
endmodule
