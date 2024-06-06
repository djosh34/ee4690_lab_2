set_db common_ui false

set_attribute lib_search_path "./libs"

set_attribute information_level 7

set_attribute hdl_search_path "./rtl/matrix_multiplier"  

set_attribute library [glob -directory [get_attribute lib_search_path] -tails *.lib]

set mylist [glob -directory [get_attribute hdl_search_path] -tails matrix_multiplier.vhd]

read_hdl -vhdl $mylist

elaborate matrix_multiplier

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


write_hdl > ./output/synth_out.v

write_sdc > ./output/constraint_out.sdc

report power > ./output/power.log

report area -depth 0 > ./output/area.log

report timing > ./output/timing.log
