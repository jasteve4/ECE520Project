
module Controllor(
  input wire clock,
  input wire reset_n,
  input wire start,
  output reg output_start,
  output reg input_start,
  input wire input_done,
  input wire output_done,
  input wire [19:0] Cdf_Min,
  output reg [19:0] Cdf_Min_Out,
  output reg [19:0] Divisor,
  output reg output_base_offset,
  output reg input_base_offset,
  input wire cdf_valid
  );

  parameter INITIAL         = 2'd0;
  parameter BEGIN           = 2'd1;
  parameter BEGIN_CDF       = 2'd2;
  parameter REPEAT          = 2'd3;
  parameter WAIT_FOR_INPUT = 1'd1;
  parameter REPEAT_START    = 1'd0;
  parameter DIVIDEND        = 20'd307200;

  reg [19:0] cdf_min1;
  reg [19:0] cdf_min0;
  reg [1:0] State;
  reg RepeatState;

  always@(*)
    begin
      if(output_base_offset)
        begin
          Cdf_Min_Out <= cdf_min1;
          Divisor <= DIVIDEND - cdf_min1;
        end
      else
        begin
          Cdf_Min_Out <= cdf_min0;
          Divisor <= DIVIDEND - cdf_min0;
        end
    end

  always@(posedge cdf_valid)
    begin
      if(input_base_offset)
        begin
          cdf_min1 <= Cdf_Min;
        end
      else
        begin
          cdf_min0 <= Cdf_Min;
        end
    end


  always@(posedge clock or negedge reset_n)
    begin
      if(!reset_n)
        begin
          input_start <= 1'd0;
          output_start <= 1'd0;
          State <= INITIAL;
          input_base_offset <= 1'd0;
          output_base_offset <= 1'd0;
        end
      else
        begin
          case(State)
            INITIAL:
              begin
                if(start)
                  begin
                    input_start <= 1'd1;
                    output_start <= 1'd0;
                    State <= BEGIN;
                  end
                else
                  begin
                    input_start <= 1'd0;
                    output_start <= 1'd0;
                    State <= INITIAL; 
                  end
                  RepeatState <= REPEAT_START;
                  input_base_offset <= 1'd0;
                  output_base_offset <= 1'd0;
              end
            BEGIN:
              begin
                if(input_done)
                  begin
                    input_start <= 1'd0;
                    output_start <= 1'd0;
                    State <= REPEAT; 
                    input_base_offset <= 1'd1;
                    output_base_offset <= 1'd0;
                  end
                else
                  begin
                    input_start <= 1'd1;
                    output_start <= 1'd0;
                    State <= BEGIN; 
                    input_base_offset <= 1'd0;
                    output_base_offset <= 1'd0;
                  end
                  RepeatState <= REPEAT_START;
              end
            REPEAT:
              begin
                case(RepeatState)
                  REPEAT_START:
                    begin
                      if(output_done)
                        begin
                          input_start <= 1'd1; // change for all run 
                          output_start <= 1'd0;
                          RepeatState <= WAIT_FOR_INPUT;
                        end
                      else
                        begin
                          input_start <= 1'd1; 
                          output_start <= 1'd1;
                          RepeatState <= REPEAT_START;
                        end
                        input_base_offset <= input_base_offset;
                        output_base_offset <= output_base_offset;
                    end
                  WAIT_FOR_INPUT:
                    begin
                      if(input_done)
                        begin
                          input_start <= 1'd0; 
                          output_start <= 1'd0;
                          RepeatState <= REPEAT_START;
                          input_base_offset <= ~input_base_offset;
                          output_base_offset <= ~output_base_offset;
                        end
                      else
                        begin
                          input_start <= 1'd1; 
                          output_start <= 1'd0;
                          RepeatState <= WAIT_FOR_INPUT;
                          input_base_offset <= input_base_offset;
                          output_base_offset <= output_base_offset;
                        end
                    end
                endcase  
                State <= REPEAT;
              end
          endcase
        end
    end


endmodule
