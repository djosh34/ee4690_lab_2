# Submission Joshua Azimullah Group 4


All sources used are located in the `rtl/matrix_mutliplication` directory. 
The sources are as follows:
    - `matrix_multiplication.vhd` : The top level entity for the matrix multiplication module
    - `matrix_multiplication_testbech.vhd` : The testbench for the matrix multiplication module in VHDL-2008


## Running testbench using ghdl with docker

Go to the `rtl` directory and run the following command:

`sh docker_build.sh`
`sh docker_make.sh`

for cleaning/deleting the `build` directory run the following command:
`sh docker_make_clean.sh`


## Running using ghdl natively

Make sure to have `ghdl` installed on your system.

Go to the `rtl` directory and run the following command:
`make -f matrix_multiplier/Makefile`

note: the make clean does not work


## Genus Synthesis

The synthesis should work directly using the `genus` tool, from this directory. The run_script.tcl is adapted to run the synthesis on the matrix multiplication module and ignore the VHDL-2008 testbench.

`source run_script.tcl`


## Submission includes build folder

The submission includes the build folder to show a valid `.ghw` file located at `rtl/build/matrix_multiplication_testbench.ghw`

Furthermore, the ghdl artifact can be run without ghdl and docker by running `rtl/build/matrix_multiplication_testbench`


