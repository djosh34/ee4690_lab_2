

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
    signal enable : std_logic := '0';

    file input_file : text open read_mode is "/pwd/matrix_2_output/examples/input.txt";
    file expected_output_file : text open read_mode is "/pwd/matrix_2_output/examples/output.txt";

    file weights_2_file : text open read_mode is "/pwd/predict/weights/fc2_weight_bin.txt";
    constant weights_2_vector : weights_2_type := read_and_populate_weights_2(weights_2_file);


begin
  uut: entity work.matrix_2_output
        generic map (
            HIDDEN_DIM => HIDDEN_DIM,
            OUTPUT_DIM => OUTPUT_DIM
        )
        port map (
            clk => clk,
            rst => rst,
            enable => enable,
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

        -- weights_2_vector <= read_and_populate_weights_2;



        wait for clk_period;

        enable <= '1';


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
            report "Test failed" severity failure;
        else
            report "Test passed" severity failure;
        end if;

        wait;
    end process;

end architecture testbench;

