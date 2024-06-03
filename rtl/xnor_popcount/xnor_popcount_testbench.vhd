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

    signal input_input : std_logic_vector(N-1 downto 0) := (others => '0');
    signal input_weights : std_logic_vector(N-1 downto 0) := (others => '0');

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

    -- component xnor_popcount
    --     generic (
    --         N : integer := 768
    --     );
    --     port (
    --         clk : in std_logic;
    --         rst : in std_logic;
    --         enable : in std_logic;
    --         is_valid : out std_logic;

    --         input_input : in std_logic_vector(N-1 downto 0);
    --         input_weights : in std_logic_vector(N-1 downto 0);

    --         is_sum_high : out std_logic;
            
            


    --         -- Debugging signals
    --         popcount_sum : out unsigned(clog2(N)-1 downto 0)
    --     );
    -- end component;






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

        variable input_vector_row : std_logic_vector(N-1 downto 0);
        variable weights_1_vector_row : std_logic_vector(N-1 downto 0);
        variable expected_sum_vector_row : integer;
        variable expected_is_high : std_logic;

        variable std_out : line;

        variable were_there_errors : boolean := false;
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
            writeline(output, std_out);
          end if;



        end loop;



















        -- while not endfile(test_file) loop
        --     readline(test_file, line_in);
        --     read(line_in, vec_a);

        --     readline(test_file, line_in);
        --     read(line_in, vec_b);

        --     readline(test_file, line_in);
        --     read(line_in, expected_xnor);

        --     readline(test_file, line_in);
        --     read(line_in, expected_popcount);

        --     readline(test_file, null_line);

        --     write(line_out, string'("A            : "));
        --     write(line_out, vec_a);
        --     writeline(output, line_out);
        --     write(line_out, string'("B            : "));
        --     write(line_out, vec_b);
        --     writeline(output, line_out);
        --     write(line_out, string'("Expected XNOR: "));
        --     write(line_out, expected_xnor);
        --     writeline(output, line_out);
        --     write(line_out, string'("Expected POPC: "));
        --     write(line_out, expected_popcount);
        --     writeline(output, line_out);

        --     weights_vector <= vec_a;
        --     input_vector <= vec_b;

        --     -- Apply reset
        --     rst <= '1';
        --     wait for 20 ns;
        --     rst <= '0';

        --     start <= '1';
        --     wait for 20 ns;
        --     start <= '0';

        --     while not done loop
        --     -- for i in 0 to 100 loop
        --         -- write(line_out, string'("Popcount: "));
        --         -- write(line_out, to_string(popcount));
        --         -- writeline(output, line_out);
        --         -- write(line_out, string'("XNOR    : "));
        --         -- write(line_out, xnor_result);

        --         -- writeline(output, line_out);
        --         wait for 20 ns;
        --     end loop;


        --     assert xnor_result = expected_xnor
        --         report "XNOR result mismatch expected " & to_string(expected_xnor) & " got " & to_string(xnor_result)
        --         severity error;

        --     assert to_integer(popcount) = expected_popcount
        --         report "Popcount mismatch expected " & integer'image(expected_popcount) & " got " & integer'image(to_integer(popcount))
        --         severity error;

        --     writeline(output, null_line);
        --     wait for 20 ns;
        -- end loop;

        if were_there_errors then
            report "Test failed";
        else
            report "Test passed";
        end if;

        wait;
    end process;

end architecture testbench;

