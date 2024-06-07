set_db common_ui false

set_attribute lib_search_path "./libs"

set_attribute information_level 7

set_attribute library [glob -directory [get_attribute lib_search_path] -tails *.lib]

# set_attribute hdl_search_path "./rtl/matrix_multiplier"  

# set mylist [glob -directory [get_attribute hdl_search_path] -tails matrix_multiplier.vhd]

# read_hdl -vhdl $mylist

# Specify the VHDL version
# set_attribute hdl_language vhdl-2008
# set_db / .hdl_vhdl_read_version 2008


# List of VHDL files to be read in the specified order
# set mylist [list \
#     "./rtl/predict/predict_package.vhd" \
#     "./rtl/matrix_2_output/matrix_2_output.vhd" \
#     "./rtl/xnor_popcount/xnor_popcount.vhd" \
#     "./rtl/predict/predict.vhd"]

# set predict_package_list [glob -directory "./rtl/predict" -tails predict_package.vhd]
# set matrix_2_output_list [glob -directory "./rtl/matrix_2_output" -tails matrix_2_output.vhd]
# set xnor_popcount_list [glob -directory "./rtl/xnor_popcount" -tails xnor_popcount.vhd]
# set predict_list [glob -directory "./rtl/predict" -tails predict.vhd]

# Read HDL files in specified order
# foreach file $mylist {
#     read_hdl -vhdl2008 $file
# }

read_hdl -vhd "./rtl/predict/predict_package.vhd"
read_hdl -vhd "./rtl/predict/weights/fc_1_weights_package.vhd"
read_hdl -vhd "./rtl/predict/weights/fc_2_weights_package.vhd"
# read_hdl -vhd "./rtl/lfsr_10/lfsr_10.vhd"
read_hdl -vhd "./rtl/matrix_2_output/matrix_2_output.vhd"
read_hdl -vhd "./rtl/xnor_popcount/xnor_popcount.vhd"
read_hdl -vhd "./rtl/predict/predict.vhd"


# elaborate lfsr_10 
# elaborate matrix_2_output 
elaborate xnor_popcount 
# elaborate predict 

report hierarchy > ./output/hierarchy.txt

check_design -unresolved > ./output/check_design.txt

read_sdc ./timing.sdc

#---- Perform synthesis ------------------#
set_attribute syn_global_effort high 
# technology independent RTL optimiztion e.g. dead code removal
syn_gen
# map generic gates to gates from the chosen target technology library
syn_map
# optimize the mapped design
syn_opt
#-----------------------------------------#


write_hdl >             ./output/synth_out.v

write_sdc >             ./output/constraint_out.sdc

report power >          ./output/power.log

report area -depth 0 >  ./output/area.log

report timing >         ./output/timing.log
