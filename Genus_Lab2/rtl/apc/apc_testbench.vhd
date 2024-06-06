library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use std.env.all;

use IEEE.math_real.all;

library work;
use work.apc_package.all;

entity apc_testbench is
end apc_testbench;


architecture testbench of apc_testbench is
  constant CLK_PERIOD : time := 20 ns;


  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal total_reset : std_logic := '0';
  signal parallel_input_counter : std_logic_vector(15 downto 0) := (others => '0');

  signal done : std_logic;

  component apc is
    generic (
        INPUT_SIZE : integer := 768
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        total_reset : in std_logic;


        parallel_input_counter : in std_logic_vector(15 downto 0);

        -- debugging signals
        total : out natural;
        -- end debugging signals


        done : out std_logic
    );
  end component;

  type stored_inputs_type is array(0 to (768 / 16) - 1) of std_logic_vector(15 downto 0);
begin
    uut : apc
    generic map (
        INPUT_SIZE => 768
    )
    port map (
        clk => clk,
        rst => rst,
        total_reset => total_reset,
        parallel_input_counter => parallel_input_counter,
        done => done
    );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;


    -- Stimulus process
    stim_proc : process
        file testdata : text open read_mode is  "/pwd/predict/examples/1_test_data_bin.txt";
        file labeldata : text open read_mode is "/pwd/predict/examples/1_test_labels_bin.txt";

        file weights_1_file : text open read_mode is "/pwd/predict/weights/fc1_weight_bin.txt";
        -- file weights_2_file : text open read_mode is "/pwd/predict/weights/fc2_weight_bin.txt";

        variable input_0_line : line;
        variable weights_1_line : line;

        variable input_0_vector : std_logic_vector(767 downto 0);
        variable weights_1_vector : std_logic_vector(767 downto 0);

        variable stored_inputs : stored_inputs_type;
        variable temp_1s_counter : natural;
        variable stored_bit : natural;

        variable line_out : line;
    begin
        parallel_input_counter <= (others => '0');
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';

        readline(testdata, input_0_line);
        read(input_0_line, input_0_vector);

        readline(weights_1_file, weights_1_line);
        read(weights_1_line, weights_1_vector);

        for i in 0 to (768 / 16) - 1 loop
            stored_inputs(i) := input_0_vector(i * 16 + 15 downto i * 16) xnor weights_1_vector(i * 16 + 15 downto i * 16);
            write(line_out, string'("INPUT:   "));
            write(line_out, input_0_vector(i * 16 + 15 downto i * 16));
            writeline(output, line_out);

            write(line_out, string'("WEIGHT:  "));
            write(line_out, weights_1_vector(i * 16 + 15 downto i * 16));
            writeline(output, line_out);

            write(line_out, string'("XNOR:    "));
            write(line_out, stored_inputs(i));
            writeline(output, line_out);


            write(line_out, string'("Sum of 1s:  "));
            temp_1s_counter := 0;
            for j in 0 to 15 loop
                stored_bit := to_integer(unsigned(stored_inputs(i)(j downto j)));
                temp_1s_counter :=  temp_1s_counter + natural(stored_bit);
            end loop;

            write(line_out, temp_1s_counter);
            writeline(output, line_out);

            writeline(output, line_out);
        end loop;




        for i in 0 to 768 / 16 - 1 loop
            parallel_input_counter <= stored_inputs(i);
            wait for CLK_PERIOD;
        end loop;

        parallel_input_counter <= (others => '0');

        for i in 0 to 100 loop
            wait for CLK_PERIOD;
        end loop;

        write(line_out, string'("Done: "));
        writeline(output, line_out);




        finish;
    end process;
end architecture testbench;

