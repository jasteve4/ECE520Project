#------------------------------------------------------------
#
# Basic Synthesis Script (TCL format)
#                                  
# Revision History                
#   1/15/03  : Author Shane T. Gehring - from class example
#   2/09/07  : Author Zhengtao Yu      - from class example
#   12/14/07 : Author Ravi Jenkal      - updated to 180 nm & tcl
#
#------------------------------------------------------------

#---------------------------------------------------------
# Read in Verilog file and map (synthesize) onto a generic
# library.
# MAKE SURE THAT YOU CORRECT ALL WARNINGS THAT APPEAR
# during the execution of the read command are fixed 
# or understood to have no impact.
# ALSO CHECK your latch/flip-flop list for unintended 
# latches                                            
#---------------------------------------------------------

read_verilog $RTL_DIR/Output_Fetch_Cdf.v
read_verilog $RTL_DIR/Output_Fetch_MEM.v
read_verilog $RTL_DIR/Output_Result.v
read_verilog $RTL_DIR/Output_Store.v
read_verilog $RTL_DIR/Output_TopExpression.v
read_verilog $RTL_DIR/Output_top.v
read_verilog $RTL_DIR/pipeline_divider.v
read_verilog $RTL_DIR/divider_pipe_stage.v
read_verilog $RTL_DIR/end_pipe_stage.v
