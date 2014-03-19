


module n_cycle_divider(
  input wire clock,
  input wire reset_n,
  input wire start,
  input wire [15:0] z,
  input wire [7:0] d,
  output reg [7:0] q,
  output reg [7:0] s
  );
  
  reg [7:0] divisor;
  reg [15:0] divided;
  reg StartOut1;

  wire [15:0] stage0_divided,stage1_divided, stage2_divided, stage3_divided;
  wire [15:0] stage4_divided,stage5_divided, stage6_divided, stage7_divided;

  wire [8:0] stage0_result, stage1_result, stage2_result, stage3_result;
  wire [8:0] stage4_result, stage5_result, stage6_result, stage7_result;

  wire [15:0] stage0_out, stage1_out, stage2_out, stage3_out;
  wire [15:0] stage4_out, stage5_out, stage6_out, stage7_out;

  wire [7:0] q_out;

  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          divisor <= 8'd0;
          divided <= 16'd0;
          StartOut1 <= 1'd0;
        end
      else
        begin
          if(start)
            begin
              divisor <= ~d + 1;
              divided <= z;
              StartOut1 <= 1'd1;
            end
          else
            begin
              divisor <= 8'd0;
              divided <= 16'd0;
              StartOut1 <= 1'd0;
            end
        end
    end
    
    //stage 0
    assign stage0_divided = {divided, 1'd0};
    assign stage0_result = stage0_divided[15:8] + divisor;
    assign q_out[7] = stage0_result[8] ^ divided[15];
    assign stage0_out = q_out[7] ? {stage0_result, stage0_divided[7:0]} : stage0_divided;
    //stage 1
    assign stage1_divided = {stage0_out, 1'd0};
    assign stage1_result = stage1_divided[15:8] + divisor;
    assign q_out[6] = stage1_result[8] ^ stage0_out[15];
    assign stage1_out = q_out[6] ? {stage1_result, stage1_divided[7:0]} : stage1_divided;
    //stage 2
    assign stage2_divided = {stage1_out, 1'd0};
    assign stage2_result = stage2_divided[15:8] + divisor;
    assign q_out[5] = stage2_result[8] ^ stage1_out[15];
    assign stage2_out = q_out[5] ? {stage2_result, stage2_divided[7:0]} : stage2_divided;
    //stage 3
    assign stage3_divided = {stage2_out, 1'd0};
    assign stage3_result = stage3_divided[15:8] + divisor;
    assign q_out[4] = stage3_result[8] ^ stage2_out[15];
    assign stage3_out = q_out[4] ? {stage3_result, stage3_divided[7:0]} : stage3_divided;
    //stage 4
    assign stage4_divided = {stage3_out, 1'd0};
    assign stage4_result = stage4_divided[15:8] + divisor;
    assign q_out[3] = stage4_result[8] ^ stage3_out[15];
    assign stage4_out = q_out[3] ? {stage4_result, stage4_divided[7:0]} : stage4_divided;
    //stage 5
    assign stage5_divided = {stage4_out, 1'd0};
    assign stage5_result = stage5_divided[15:8] + divisor;
    assign q_out[2] = stage5_result[8] ^ stage4_out[15];
    assign stage5_out = q_out[2] ? {stage5_result, stage5_divided[7:0]} : stage5_divided;
    //stage 6
    assign stage6_divided = {stage5_out, 1'd0};
    assign stage6_result = stage6_divided[15:8] + divisor;
    assign q_out[1] = stage6_result[8] ^ stage5_out[15];
    assign stage6_out = q_out[1] ? {stage6_result, stage6_divided[7:0]} : stage6_divided;
    //stage 7
    assign stage7_divided = {stage6_out, 1'd0};
    assign stage7_result = stage7_divided[15:8] + divisor;
    assign q_out[0] = stage7_result[8] ^ stage6_out[15];
    assign stage7_out = q_out[0] ? {stage7_result, stage7_divided[7:0]} : stage7_divided;
    
    always@(posedge clock or negedge reset_n)
      begin
        if(!reset_n)
          begin
            s <= 4'd0;
            q <= 4'd0;
          end
        else
          begin
            if(StartOut1)
              begin
                s <= stage3_out;   
                q <= q_out;
              end
            else
              begin
                s <= 4'd0;
                q <= 4'd0;
              end
          end
      end
    

endmodule
