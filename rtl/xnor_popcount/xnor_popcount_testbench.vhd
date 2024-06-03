library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

use IEEE.math_real.all;
use work.predict_package.all;

entity xnor_popcount_testbench is
end xnor_popcount_testbench;

architecture testbench of xnor_popcount_testbench is
    constant N : integer := 768;
    constant clk_period : time := 20 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal enable : std_logic := '0';

    signal is_valid : std_logic;

    signal input_input : std_logic_vector(0 to N-1) := (others => '0');
    signal input_weights : std_logic_vector(0 to N-1) := (others => '0');

    signal is_sum_high : std_logic;
    signal popcount_sum : unsigned(clog2(N)-1 downto 0);


    function log2ceil(val : integer) return integer is
        variable result : integer := 0;
        variable v : integer := val-1;
    begin
        while v > 0 loop
            v := v / 2;
            result := result + 1;
        end loop;
        return result;
    end function;




begin
  uut: entity work.xnor_popcount
        generic map (
            N => N
        )
        port map (
            clk => clk,
            rst => rst,
            enable => enable,
            is_valid => is_valid,

            input_input => input_input,
            input_weights => input_weights,

            is_sum_high => is_sum_high,

            popcount_sum => popcount_sum
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
        file input_file : text open read_mode is "/pwd/predict/examples/1_test_data_bin.txt";
        file weights_1_file : text open read_mode is "/pwd/predict/weights/fc1_weight_bin.txt";
        file expected_output_file : text open read_mode is "/pwd/predict/examples/temp_matrix_summed.txt";


        variable input_line_row : line;
        variable weights_1_line_row : line;
        variable expected_sum_row : line;

        variable input_vector_row : std_logic_vector(0 to N-1);
        variable weights_1_vector_row : std_logic_vector(0 to N-1);
        variable expected_sum_vector_row : integer;
        variable expected_is_high : std_logic;

        variable std_out : line;

        variable were_there_errors : boolean := false;

        variable max_test_counter : integer := 0;
    begin
        wait for clk_period;
        rst <= '1';
        enable <= '0';
        input_input <= (others => '0');
        input_weights <= (others => '0');

        wait for clk_period;
        rst <= '0';




        -- read one row for input 
        readline(input_file, input_line_row);
        read(input_line_row, input_vector_row);
        input_input <= input_vector_row;

        wait for clk_period;

        while not endfile(weights_1_file) loop

          -- read row for weights
          readline(weights_1_file, weights_1_line_row);
          read(weights_1_line_row, weights_1_vector_row);
          input_weights <= weights_1_vector_row;


          enable <= '1';



          wait for clk_period;

          if is_valid = '1' then
            -- read row for expected sum
            readline(expected_output_file, expected_sum_row);
            read(expected_sum_row, expected_sum_vector_row);

            expected_is_high := '1' when expected_sum_vector_row >= 384 else '0';


            write(std_out, string'("Expected - Real sum:   "));
            write(std_out, int_to_leading_zeros(expected_sum_vector_row, 4));
            write(std_out, string'(" - "));
            write(std_out, int_to_leading_zeros(to_integer(popcount_sum), 4));
            write(std_out, string'("         Expected - Real:   "));
            write(std_out, string'(std_logic_to_boolean_char(expected_is_high)));
            write(std_out, string'(" - "));
            write(std_out, string'(std_logic_to_boolean_char(is_sum_high)));

            if expected_sum_vector_row /= to_integer(popcount_sum) then
              were_there_errors := true;
              write(std_out, string'("    ERROR SUM!!!"));
            else  
              write(std_out, string'("                "));
            end if;

            if expected_is_high /= is_sum_high then
              were_there_errors := true;
              write(std_out, string'("    ERROR IS_HIGH_COMPARISON!!!"));
            end if;



            max_test_counter := max_test_counter + 1;

            if max_test_counter = 100 then
              exit;
            end if;

            writeline(output, std_out);
          end if;



        end loop;




        writeline(output, std_out);
        writeline(output, std_out);
        writeline(output, std_out);


        if were_there_errors then
            report "Test failed";
        else
            report "Test passed";
        end if;

        wait;
    end process;

end architecture testbench;

