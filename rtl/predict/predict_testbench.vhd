library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

use IEEE.math_real.all;
use std.env.all;

library work;
use work.predict_package.all;

entity predict_testbench is
end predict_testbench;

architecture testbench of predict_testbench is

    constant INPUT_SIZE : integer := 768;
    constant HIDDEN_SIZE : integer := 1024;
    constant OUTPUT_SIZE : integer := 10;
    constant clk_period : time := 20 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal input_row : std_logic_vector(0 to INPUT_SIZE - 1);
    signal output_row : std_logic_vector(0 to OUTPUT_SIZE - 1);
    signal done : std_logic;


    constant weights_1_filename : string := "/pwd/predict/weights/fc1_weight_bin.txt";
    constant weights_2_filename : string := "/pwd/predict/weights/fc2_weight_bin.txt";




begin
    uut: entity work.predict
        generic map (
            INPUT_SIZE => INPUT_SIZE,
            HIDDEN_SIZE => HIDDEN_SIZE,
            OUTPUT_SIZE => OUTPUT_SIZE,
            weights_1_filename => weights_1_filename,
            weights_2_filename => weights_2_filename 
        )
        port map (
            clk => clk,
            rst => rst,

            input_row => input_row,
            output_row => output_row,

            done => done
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Test process
    process
        file testdata : text open read_mode is  "/pwd/predict/examples/all_test_data_bin.txt";
        file labeldata : text open read_mode is "/pwd/predict/examples/all_test_labels_bin.txt";


        variable line_in : line;
        variable line_out : line;
        variable null_line : line;

        variable input_row_var : std_logic_vector(0 to INPUT_SIZE - 1);
        variable expected_output : std_logic_vector(0 to OUTPUT_SIZE - 1);
        variable i_loop_stopper : integer := 0;
        variable were_there_errors : boolean := false;
        variable error_counter : integer := 0;
    begin
        wait for 20 ns;


	-- - [ ] testbench
	-- 	- [ ] for i in input_file
	-- 		- [ ] set 768 bit vector from line data file 
	-- 		- [ ] set expected 10 bit output from line labels file
	-- 		- [ ] wait until done = 1
	-- 		- [ ] check expected_output = output
	-- 		- [ ] rst = 1
	-- 		- [ ] advance clock
	-- 		- [ ] rst = 0
	-- 		- [ ] advance clock

        i_loop_stopper := 0;

        while not endfile(testdata) loop
            readline(testdata, line_in);
            readline(labeldata, line_out);

            read(line_in, input_row_var);
            read(line_out, expected_output);

            -- write(line_out, string'("Setting input row..."));
            -- writeline(output, line_out);
            -- write(line_out, string'("Setting expected output..."));
            -- writeline(output, line_out);

            input_row <= input_row_var; 
            rst <= '0';
            wait for 20 ns;

            rst <= '1';
            wait for 20 ns;

            rst <= '0';
            wait for 20 ns;

            -- write(line_out, string'("Waiting for done..."));
            -- writeline(output, line_out);

            wait until done = '1';

            -- write(line_out, string'("Checking output..."));
            -- writeline(output, line_out);

            for i in 0 to OUTPUT_SIZE - 1 loop
                if output_row(i) /= expected_output(i) then
                    were_there_errors := true;
                    write(line_out, string'("Error in output"));
                    writeline(output, line_out);
                    write(line_out, string'("Expected: "));
                    write(line_out, expected_output);
                    writeline(output, line_out);
                    write(line_out, string'("Got:      "));
                    write(line_out, output_row);
                    writeline(output, line_out);
                    were_there_errors := true;
                    error_counter := error_counter + 1;
                end if;
            end loop;

            write(line_out, string'("i: "));
            write(line_out, int_to_leading_zeros(i_loop_stopper, 4));
            write(line_out, string'("  Output is correct"));
            writeline(output, line_out);

            i_loop_stopper := i_loop_stopper + 1;

            wait for 20 ns;
        end loop;

        --     wait for 20 ns;




        --     i_loop_stopper := i_loop_stopper + 1;

        --     if i_loop_stopper > 100 then
        --         report "Test failed";
        --         finish;
        --     end if;
        -- end loop;




        write(line_out, string'("Test is finished..."));
        writeline(output, line_out);



        wait for 20 ns;

        write(line_out, string'("Score: "));
        write(line_out, int_to_leading_zeros(error_counter, 4));
        write(line_out, string'(" / "));
        write(line_out, int_to_leading_zeros(i_loop_stopper, 4));
        writeline(output, line_out);


        wait;
    end process;

end architecture testbench;

