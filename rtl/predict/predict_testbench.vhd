library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

use IEEE.math_real.all;

library work;
use work.predict_package.all;

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


    constant BIT_WIDTH : integer := 64;
    constant INPUT_SIZE : integer := 768;
    constant HIDDEN_SIZE : integer := 1024;
    constant OUTPUT_SIZE : integer := 10;

    -- address width must be able to address
    -- all input registers, so INPUT_SIZE/BIT_WIDTH
    -- or
    -- all weights_1 registers, so HIDDEN_SIZE * INPUT_SIZE/BIT_WIDTH
    -- or 
    -- all weights_2 registers, so OUTPUT_SIZE * HIDDEN_SIZE/BIT_WIDTH
    -- take the max of these
    -- address width input = integer(log2(real(INPUT_SIZE/BIT_WIDTH)))
    -- address width weights_1 = integer(log2(real(HIDDEN_SIZE * INPUT_SIZE/BIT_WIDTH)))
    -- address width weights_2 = integer(log2(real(OUTPUT_SIZE * HIDDEN_SIZE/BIT_WIDTH)))


    -- constant ADDRESS_WIDTH : integer := maximum(integer(log2(real(INPUT_SIZE/BIT_WIDTH))), maximum(integer(log2(real(HIDDEN_SIZE * INPUT_SIZE/BIT_WIDTH))), integer(log2(real(OUTPUT_SIZE * HIDDEN_SIZE/BIT_WIDTH)))));
  -- function get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH: integer) return integer is
    constant ADDRESS_WIDTH : integer := get_address_width(INPUT_SIZE, HIDDEN_SIZE, OUTPUT_SIZE, BIT_WIDTH);

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal start : std_logic := '0';
    signal done : std_logic;

    signal address : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
    signal data : std_logic_vector(BIT_WIDTH - 1 downto 0);

    signal set_weights_1 : std_logic;
    signal set_weights_2 : std_logic;
    signal set_input : std_logic;

    signal enable_input : std_logic;
    signal enable_weights_1 : std_logic;
    signal enable_weights_2 : std_logic;

    signal prediction : std_logic_vector(OUTPUT_SIZE - 1 downto 0);

    component predict
        generic (
            BIT_WIDTH : integer;
            INPUT_SIZE : integer;
            HIDDEN_SIZE : integer;
            OUTPUT_SIZE : integer
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            start : in std_logic;

            -- address bus for the weights/inputs (max size of log2(INPUT_SIZE) and log2(HIDDEN_SIZE))
            -- data bus for the weights/inputs 64 bits
            address : in std_logic_vector(maximum(integer(log2(real(INPUT_SIZE/BIT_WIDTH))), maximum(integer(log2(real(HIDDEN_SIZE * INPUT_SIZE/BIT_WIDTH))), integer(log2(real(OUTPUT_SIZE * HIDDEN_SIZE/BIT_WIDTH))))) - 1 downto 0);
            data : in std_logic_vector(BIT_WIDTH - 1 downto 0);

            -- set weights 1
            -- set weights 2
            -- set input
            -- enable (read) input
            -- enable (read) weights 1
            -- enable (read) weights 2
            set_weights_1 : in std_logic;
            set_weights_2 : in std_logic;
            set_input : in std_logic;

            enable_input : in std_logic;
            enable_weights_1 : in std_logic;
            enable_weights_2 : in std_logic;



            -- output bus for the prediction
            prediction : out std_logic_vector(OUTPUT_SIZE - 1 downto 0);


            -- debugging signals

            -- end debugging signals


            done : out std_logic
        );
    end component;

    signal were_there_errors : boolean := false;
    signal cycle_count : integer := 0;


begin
    uut: predict
        generic map (
            BIT_WIDTH => BIT_WIDTH,
            INPUT_SIZE => INPUT_SIZE,
            HIDDEN_SIZE => HIDDEN_SIZE,
            OUTPUT_SIZE => OUTPUT_SIZE
        )
        port map (
            clk => clk,
            rst => rst,
            start => start,

            address => address,
            data => data,

            set_weights_1 => set_weights_1,
            set_weights_2 => set_weights_2,
            set_input => set_input,

            enable_input => enable_input,
            enable_weights_1 => enable_weights_1,
            enable_weights_2 => enable_weights_2,

            prediction => prediction,

            done => done
        );

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




        -- read weights_1 file
        -- print each line read
        -- for each line:
        --  populate the internal weights_1 array by setting the address and set_weights_1 signal to 1
        -- wait for 20 ns
        -- for

















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

