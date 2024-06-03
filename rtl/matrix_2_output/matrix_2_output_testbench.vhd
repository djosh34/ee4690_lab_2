

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

use IEEE.math_real.all;
use work.predict_package.all;

entity matrix_2_output_testbench is
end matrix_2_output_testbench;

architecture testbench of matrix_2_output_testbench is
    constant HIDDEN_DIM : integer := 1024;
    constant OUTPUT_DIM : integer := 10;
    constant clk_period : time := 20 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal current_weights_row : std_logic_vector(0 to OUTPUT_DIM - 1) := (others => '0');
    signal current_input_bit : std_logic := '0';

    signal prediction : std_logic_vector(0 to OUTPUT_DIM - 1);
    signal done : std_logic;

    file input_file : text open read_mode is "/pwd/matrix_2_output/examples/input.txt";
    file expected_output_file : text open read_mode is "/pwd/matrix_2_output/examples/output.txt";
    file weights_2_file : text open read_mode is "/pwd/predict/weights/fc2_weight_bin.txt";






    signal weights_2_vector : weights_2_type; -- 1024 x 10

    type weights_temp_array_type is array(0 to OUTPUT_DIM - 1) of std_logic_vector(0 to HIDDEN_DIM - 1);


    -- populate the weights_2 array
    function read_and_populate_weights_2 return weights_2_type is
      variable weights_temp_array : weights_temp_array_type;
      variable weights_out_array : weights_2_type;

      variable weights_line : line;
      variable output_i : integer := 0;


      variable line_out : line;
    begin
      write(line_out, string'("Reading weights 2 from file..."));
      writeline(output, line_out);

      -- weights array: 10 x 1024
      while not endfile(weights_2_file) loop

        readline(weights_2_file, weights_line);
        read(weights_line, weights_temp_array(output_i));

        -- write(line_out, string'("output_i: "));
        -- write(line_out, int_to_leading_zeros(output_i, 4));
        -- write(line_out, string'(" "));
        -- write(line_out, string'(" Data: "));
        -- write(line_out, weights_array(output_i));
        -- writeline(output, line_out);

        output_i := output_i + 1;
      end loop;

      write(line_out, string'("Done reading weights 2 from file..."));
      writeline(output, line_out);
      write(line_out, string'("Populating weights 2..."));
      writeline(output, line_out);

    -- virtual transpose, so now output for each hidden_i output 10 bits
      weights_out_array := (others => (others => '0'));
      for i in 0 to HIDDEN_SIZE - 1 loop

        for j in 0 to OUTPUT_SIZE - 1 loop
          weights_out_array(i)(j) := weights_temp_array(j)(i);
        end loop;

        -- write(line_out, string'("i: "));
        -- write(line_out, int_to_leading_zeros(i, 4));
        -- write(line_out, string'(" Data: "));
        -- write(line_out, weights_out_array(i));
        -- writeline(output, line_out);

      end loop;


      return weights_out_array;
    end function;

begin
  uut: entity work.matrix_2_output
        generic map (
            HIDDEN_DIM => HIDDEN_DIM,
            OUTPUT_DIM => OUTPUT_DIM
        )
        port map (
            clk => clk,
            rst => rst,
            current_weights_row => current_weights_row,
            current_input_bit => current_input_bit,
            prediction => prediction,
            done => done
        );





    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;






    -- Test process
    process


        variable input_line_row : line;
        variable output_line_row : line;
        variable weights_2_line_row : line;

        variable input_vector_row : std_logic_vector(0 to HIDDEN_DIM - 1);
        variable output_vector_row : std_logic_vector(0 to OUTPUT_DIM - 1);


        variable std_out : line;
        variable this_test_ok : boolean := true;
        variable were_there_errors : boolean := false;
        variable max_test_counter : integer := 0;

        variable test_i : integer := 0;
    begin
        wait for clk_period;
        rst <= '1';

        wait for clk_period;
        rst <= '0';

        weights_2_vector <= read_and_populate_weights_2;



        wait for clk_period;


		-- - [ ] while input_file not end
		-- 	- [ ] input_line <- readline input
		-- 	- [ ] input_var <- input_line
		-- 	- [ ] for i in 0 to input_var'length - 1
		-- 		- [ ] current_weights <= weights_2_array(i)
		-- 		- [ ] current_input <= input_var(i)
		-- 		- [ ] advance clock
		-- 	- [ ] check signal done = 1
		-- 	- [ ] output_line <- readline output_file
		-- 	- [ ] check prediction = ouput
		-- 	- [ ] reset sequence

        while not endfile(input_file) loop
            readline(input_file, input_line_row);
            read(input_line_row, input_vector_row);

            readline(expected_output_file, output_line_row);
            read(output_line_row, output_vector_row);

            for i in 0 to input_vector_row'length - 1 loop
                current_weights_row <= weights_2_vector(i);
                current_input_bit <= input_vector_row(i);

                wait for clk_period;

            end loop;

            write(std_out, string'("Test iteration: "));
            write(std_out, int_to_leading_zeros(test_i, 4));
            write(std_out, string'(" "));

            if done /= '1' then
                were_there_errors := true;
                this_test_ok := false;
                write(std_out, string'("Test failed: done signal not high  "));
            end if;

            if prediction /= output_vector_row then
                were_there_errors := true;
                this_test_ok := false;
                write(std_out, string'("Test failed: expected output: "));
                write(std_out, output_vector_row);
                write(std_out, string'(" "));
                write(std_out, string'("actual output: "));
                write(std_out, prediction);

            end if;


            if this_test_ok then
                write(std_out, string'("Test passed"));
            end if;

            writeline(output, std_out);

            max_test_counter := max_test_counter + 1;
            test_i := test_i + 1;

            -- if max_test_counter > 10 then
            --     were_there_errors := true;
            --     report "Test failed: too many tests" severity failure;
            -- end if;



            rst <= '1';

            wait for clk_period;

            rst <= '0';
        end loop;




        if were_there_errors then
            report "Test failed";
            finish;
        else
            report "Test passed";
            finish;
        end if;

        wait;
    end process;

end architecture testbench;

