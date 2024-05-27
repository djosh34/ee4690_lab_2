library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

use IEEE.math_real.all;

entity predict_testbench is
end predict_testbench;

architecture testbench of predict_testbench is

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

    component xnor_popcount
        generic (
            N : integer := 64
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;
            done : out std_logic


        );
    end component;

    signal were_there_errors : boolean := false;
    signal cycle_count : integer := 0;
    signal clk : std_logic := '0';


    constant INPUT_DATA_WIDTH : integer := 768;
    constant REG_DATA_WIDTH : integer := 64;
    constant N_INPUTS : integer := INPUT_DATA_WIDTH / REG_DATA_WIDTH;

    constant HIDDEN_LAYER_1_SIZE : integer := 1024;
    constant N_HIDDEN_LAYER_1 : integer := HIDDEN_LAYER_1_SIZE / REG_DATA_WIDTH;


begin
    -- uut: xnor_popcount
    --     generic map (
    --         N => N
    --     )
    --     port map (
    --         clk => clk,
    --         rst => rst,
    --         start => start,
    --         done => done,
    --         weights_vector => weights_vector,
    --         input_vector => input_vector,
    --         popcount => popcount,
    --         xnor_result => xnor_result,
    --         step => step
    --     );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Test process
    process
        file testdata : text open read_mode is  "/pwd/predict/examples/1_test_data_bin.txt";
        file labeldata : text open read_mode is "/pwd/predict/examples/1_test_labels_bin.txt";

        file weights_1 : text open read_mode is "/pwd/predict/weights/fc1_weight_bin.txt";
        file weights_2 : text open read_mode is "/pwd/predict/weights/fc2_weight_bin.txt";

        variable line_in : line;
        -- variable vec_a, vec_b : std_logic_vector(N-1 downto 0);
        -- variable expected_xnor : std_logic_vector(N-1 downto 0);
        -- variable expected_popcount : integer;
        variable line_out : line;
        variable null_line : line;
    begin
        wait for 20 ns;

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

